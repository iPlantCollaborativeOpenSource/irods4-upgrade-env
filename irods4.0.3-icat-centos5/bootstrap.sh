#!/bin/bash

if [ -z "$DB_NAME" ]
then
  echo "A tedgin/irods4.0.3-icat-db-postgres9.3 container needs to be linked to 'db'." 
  exit 1
fi

if [ -z "$DB_PASSWORD" ]
then
  echo "The environment variable DB_PASSWORD is not defined." 
  exit 1
fi

if [ -z "$RODS_PASSWORD" ]
then
  echo "The environment variable RODS_PASSWORD is not defined." 
  exit 1
fi

# generate configuration responses
/opt/irods/genresp.sh /opt/irods/setup_responses

# set up iRODS
/opt/irods/config.sh /opt/irods/setup_responses

# change irods user's irodsEnv file to point to localhost, since it was configured with a transient 
# Docker container's $
sed -i 's/^irodsHost.*/irodsHost localhost/' /var/lib/irods/.irods/.irodsEnv

# this script must end with a persistent foreground process
tail -f /var/lib/irods/iRODS/server/log/rodsLog.*
