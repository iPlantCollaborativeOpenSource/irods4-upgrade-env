#!/bin/bash

if [ -z "$DB_NAME" ]
then
  echo "An irods4.0.3-icat-db container needs to be linked to 'db'."
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
function genresp ()
{
    echo "irods"                 # service account user ID
    echo "irods"                 # service account group ID
    echo "tempZone"              # initial zone name
    echo "1247"                  # service port #
    echo "20000"                 # transport starting port #
    echo "20199"                 # transport ending port #
    echo "/var/lib/irods/Vault"  # vault path
    echo "$LOCAL_ZONE_SID"       # zone SID
    echo "$AGENT_KEY"            # agent key
    echo "rods"                  # iRODS admin account
    echo "$RODS_PASSWORD"        # iRODS admin password
    echo "yes"                   # confirm iRODS settings+
    echo "db"                    # database hostname
    echo "5432"                  # database port
    echo "ICAT"                  # database DB name
    echo "irods"                 # database admin username
    echo "$DB_PASSWORD"          # database admin password
    echo "yes"                   # confirm database settings
}


while true
do
    PGPASSWORD=$DB_PASSWORD psql --list --quiet --host db postgres irods

    if [ $? -eq 0 ]
    then
        break
    fi

    sleep 1
done

PGPASSWORD=$DB_PASSWORD psql --host db postgres irods <<- EOSQL
    CREATE DATABASE "ICAT";
    GRANT ALL PRIVILEGES ON DATABASE "ICAT" TO irods;
EOSQL

genresp | /var/lib/irods/packaging/setup_irods.sh

# change irods user's irodsEnv file to point to localhost, since it was configured with a transient 
# Docker container's $
sed -i 's/^irodsHost.*/irodsHost localhost/' /var/lib/irods/.irods/.irodsEnv

# this script must end with a persistent foreground process
#tail -f /var/lib/irods/iRODS/server/log/rodsLog.*

bash
