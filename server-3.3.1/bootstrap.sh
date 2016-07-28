#! /bin/bash

setup_irods()
{
su - irods <<EOS
  cd /home/irods/iRODS 
  yes | ./irodssetup
EOS
}


iptables-input()
{
   local protocol="$1"
   local dport="$2"

   iptables --append INPUT \
            --match state --state NEW \
            --match "$protocol" --protocol "$protocol" \
            --dport "$dport" \
            --jump ACCEPT
}


# Configure iptables
iptables-input tcp 1247
iptables-input tcp 20000:20399
iptables-input udp 20000:20399
iptables-input tcp "$SSH_PORT"
/etc/init.d/iptables save

# Start uuidd
uuidd

if [ -e /init-scripts/pre.sh ]
then
  printf 'Running pre init script\n'
  bash /init-scripts/pre.sh
fi

# Configure the rules
sed --in-place \
  "{  
     s/^ipc_AMQP_HOST .*\$/ipc_AMQP_HOST = amqp/
     s/^ipc_AMQP_PORT .*\$/ipc_AMQP_PORT = 5672/
     s/^ipc_AMQP_USER .*\$/ipc_AMQP_USER = $RABBITMQ_DEFAULT_USER/
     s/^ipc_AMQP_PASSWORD .*\$/ipc_AMQP_PASSWORD = $RABBITMQ_DEFAULT_PASS/
     s/^ipc_RODSADMIN .*\$/ipc_RODSADMIN = $ADMIN_USER/
     }" \
  /home/irods/iRODS/server/config/reConfigs/ipc-env-prod.re

printf 'export PATH="$PATH":"$HOME"/iRODS/clients/icommands/bin\n' >> /home/irods/.bashrc

setup_irods

# The iRODS server may not have started, try again
if [ "$?" -ne 0 ]
then
  setup_irods
fi

if [ -e /init-scripts/post.sh ]
then
  printf 'Running post init script\n'
  bash /init-scripts/post.sh
fi

touch /IRODS_READY

# Configure sshd
sed --in-place "s/#Port .*/Port $SSH_PORT/" /etc/ssh/sshd_config
service sshd restart

printf '%s\n%s\n' "$ANSIBLE_PASSWORD" "$ANSIBLE_PASSWORD" | passwd ansible

printf 'ready\n'
bash
