#! /bin/bash

PASSWORD=password
LOCAL_ZONE_SID=LZ_SID
AGENT_KEY=agentkey901234567890123456789012

DB_NAME=icat-db
ICAT_NAME=icat

./stop.sh >/dev/null 2>/dev/null
docker run -d -e POSTGRES_PASSWORD=$PASSWORD --name $DB_NAME irods4.0.3-icatdb-postgres9.3
sleep 10
docker run -dt -e DB_PASSWORD=$PASSWORD -e RODS_PASSWORD=$PASSWORD \
           -e LOCAL_ZONE_SID=$LOCAL_ZONE_SID -e AGENT_KEY=$AGENT_KEY --link $DB_NAME:db \
           --name $ICAT_NAME irods4.0.3-icat-centos5
sleep 10
docker run -dt -e RODS_PASSWORD=$PASSWORD -e LOCAL_ZONE_SID=$LOCAL_ZONE_SID \
           -e AGENT_KEY=$AGENT_KEY -p 1247:1247 -p 20000-20199:20000-20199 --link $ICAT_NAME:icat \
           --name res-centos5 irods4.0.3-centos5
docker run -it --rm -e "RODS_PASSWORD=$PASSWORD" --link $ICAT_NAME:icat --name icommands \
           icommands4.0.3 
