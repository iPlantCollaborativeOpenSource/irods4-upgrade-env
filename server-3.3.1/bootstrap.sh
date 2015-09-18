#! /bin/bash

function setup_irods ()
{
su - irods <<EOS
    cd /home/irods/iRODS 
    yes | ./irodssetup
EOS
}


if [ -e /init-scripts/pre.sh ]
then
  echo Running pre init script
  bash /init-scripts/pre.sh
fi

# Start uuidd
uuidd

# Configure the bisque script
sed --in-place \
    "{  
       s|^BISQUE_HOST=.*\$|BISQUE_HOST='http://$BISQUE_HOST'|
       s|^BISQUE_ADMIN_PASS=.*\$|BISQUE_ADMIN_PASS='$BISQUE_SERVICE_PASSWORD'|
       s|^IRODS_HOST=.*\$|IRODS_HOST='irods://ies'|
     }" \
    /home/irods/iRODS/server/bin/cmd/insert2bisque.py 

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

echo 'export PATH="$PATH":"$HOME/iRODS/clients/icommands/bin"' >> /home/irods/.bashrc

setup_irods

# The iRODS server may not have started, try again
if [ $? -ne 0 ]
then
  setup_irods
fi

echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> /home/irods/.bashrc

if [ -e /init-scripts/post.sh ]
then
  echo Running post init script
  bash /init-scripts/post.sh
fi

echo ready
bash