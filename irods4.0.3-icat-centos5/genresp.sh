#!/bin/bash
# genresp.sh
# Generates responses for iRODS' setup_irods.sh script.
# Zone SID, agent key, database admin, and admin password are all randomized.

RESPFILE=$1

if [ -z "$LOCAL_ZONE_SID" ]
then
  LOCAL_ZONE_SID=$(openssl rand -base64 16 | sed 's,/,S,g' | cut -c 1-16 | tr -d '\n' ; echo "-SID")
fi

if [ -z "$AGENT_KEY" ]
then
  AGENT_KEY=$(openssl rand -base64 32 | sed 's,/,S,g' | cut -c 1-32)
fi

echo "irods"                >  $RESPFILE  # service account user ID
echo "irods"                >> $RESPFILE  # service account group ID
echo "tempZone"             >> $RESPFILE  # initial zone name
echo "1247"                 >> $RESPFILE  # service port #
echo "20000"                >> $RESPFILE  # transport starting port #
echo "20199"                >> $RESPFILE  # transport ending port #
echo "/var/lib/irods/Vault" >> $RESPFILE  # vault path
echo "$LOCAL_ZONE_SID"      >> $RESPFILE  # zone SID
echo "$AGENT_KEY"           >> $RESPFILE  # agent key
echo "rods"                 >> $RESPFILE  # iRODS admin account
echo "$RODS_PASSWORD"       >> $RESPFILE  # iRODS admin password
echo "yes"                  >> $RESPFILE  # confirm iRODS settings+
echo "db"                   >> $RESPFILE  # database hostname
echo "5432"                 >> $RESPFILE  # database port
echo "ICAT"                 >> $RESPFILE  # database DB name
echo "irods"                >> $RESPFILE  # database admin username
echo "$DB_PASSWORD"         >> $RESPFILE  # database admin password
echo "yes"                  >> $RESPFILE  # confirm database settings

