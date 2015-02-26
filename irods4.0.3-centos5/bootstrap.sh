#!/bin/bash

if [ -z "$ICAT_PORT_1247_TCP_ADDR" ]
then
  echo "A tedgin/irods4.0.3-icat-centos5 container needs to be linked to 'icat'." 
  exit 1
fi

if [ -z "$RODS_PASSWORD" ]
then
  echo "The environment variable RODS_PASSWORD is not defined." 
  exit 1
fi

if [ -z "$LOCAL_ZONE_SID" ]
then
  echo "The environment variable LOCAL_ZONE_SID is not defined." 
  exit 1
fi

if [ -z "$AGENT_KEY" ]
then
  echo "The environment variable AGENT_KEY is not defined." 
  exit 1
fi


# generate configuration responses
function genresp ()
{
    echo "irods"                 # service account user ID
    echo "irods"                 # service account group ID
    echo "1247"                  # service port #
    echo "20000"                 # transport starting port #
    echo "20199"                 # transport ending port #
    echo "/var/lib/irods/Vault"  # vault path
    echo "$LOCAL_ZONE_SID"       # zone SID
    echo "$AGENT_KEY"            # agent key
    echo "rods"                  # iRODS admin account
    echo "yes"                   # confirm iRODS settings+
    echo "icat"                  # ICAT host
    echo "tempZone"              # initial zone name
    echo "yes"                   # confirm iRODS settings+
    echo "$RODS_PASSWORD"        # iRODS admin password
}


genresp | /var/lib/irods/packaging/setup_irods.sh

# change irods user's irodsEnv file to point to localhost, since it was configured with a transient
# Docker container's $
sed -i 's/^irodsHost.*/irodsHost icat/' /var/lib/irods/.irods/.irodsEnv
sed -i 's/^irodsDefResource.*/irodsDefResource demoResc/' /var/lib/irods/.irods/.irodsEnv

# this script must end with a persistent foreground process
tail -f /var/lib/irods/iRODS/server/log/rodsLog.*
