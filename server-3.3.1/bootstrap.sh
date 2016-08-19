#! /bin/bash

setup_irods()
{
su - irods <<EOS
  cd /home/irods/iRODS 
  yes | ./irodssetup
EOS
}

# Configure iptables
iptables --append INPUT \
         --match state --state NEW \
         --match tcp --protocol tcp \
         --dport 1247 \
         --jump ACCEPT

iptables --append INPUT \
         --match state --state NEW \
         --match tcp --protocol tcp \
         --dport 1248 \
         --jump REJECT

service iptables save

# Start uuidd
uuidd

if [ -e /init-scripts/pre.sh ]
then
  printf 'Running pre init script\n'
  bash /init-scripts/pre.sh
fi

readonly IesIpAddr=$(host ies | head --lines 1 | cut --delimiter \  --fields 4)

# Configure the rules
sed --in-place \
  "{  
     s/RABBITMQ_DEFAULT_USER/$RABBITMQ_DEFAULT_USER/g
     s/RABBITMQ_DEFAULT_PASS/$RABBITMQ_DEFAULT_PASS/g
     s/IES_IP_ADDR/$IesIpAddr/g
     s/ADMIN_USER/$ADMIN_USER/g
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
