#! /bin/bash

setup_irods ()
{
su - irods <<EOS
  cd /home/irods/iRODS 
  yes | ./irodssetup
EOS
}


if [ -e /init-scripts/pre.sh ]
then
  printf 'Running pre init script\n'
  bash /init-scripts/pre.sh
fi

# Start uuidd
uuidd

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

printf 'ready\n'
bash
