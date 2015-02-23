#!/bin/bash
# genresp.sh
# Generates responses for iRODS' setup_irods.sh script.
# Zone SID, agent key, database admin, and admin password are all randomized.

RESPFILE=$1

echo "irods"                >  $RESPFILE  # service account user ID
echo "irods"                >> $RESPFILE  # service account group ID
echo "1247"                 >> $RESPFILE  # service port #
echo "20000"                >> $RESPFILE  # transport starting port #
echo "20199"                >> $RESPFILE  # transport ending port #
echo "/var/lib/irods/Vault" >> $RESPFILE  # vault path
echo "$LOCAL_ZONE_SID"      >> $RESPFILE  # zone SID
echo "$AGENT_KEY"           >> $RESPFILE  # agent key
echo "rods"                 >> $RESPFILE  # iRODS admin account
echo "yes"                  >> $RESPFILE  # confirm iRODS settings+
echo "icat"                 >> $RESPFILE  # ICAT host
echo "tempZone"             >> $RESPFILE  # initial zone name
echo "yes"                  >> $RESPFILE  # confirm iRODS settings+
echo "$RODS_PASSWORD"       >> $RESPFILE  # iRODS admin password

