#! /bin/bash

PASSWORD=password
LOCAL_ZONE_SID=LZ_SID
AGENT_KEY=agentkey901234567890123456789012

DB_NAME=icat-db
ICAT_NAME=icat
RES1_NAME=centos5RS

./stop.sh >/dev/null 2>/dev/null
docker run --detach --env POSTGRES_PASSWORD=$PASSWORD --name $DB_NAME irods4.0.3-icatdb-postgres9.3
sleep 10
docker run --detach --tty --env DB_PASSWORD=$PASSWORD --env RODS_PASSWORD=$PASSWORD \
           --env LOCAL_ZONE_SID=$LOCAL_ZONE_SID --env AGENT_KEY=$AGENT_KEY --link $DB_NAME:db \
           --name $ICAT_NAME irods4.0.3-icat-centos5
sleep 10
docker run --detach --tty --env RODS_PASSWORD=$PASSWORD --env LOCAL_ZONE_SID=$LOCAL_ZONE_SID \
           --env AGENT_KEY=$AGENT_KEY --hostname $RES1_NAME --link $ICAT_NAME:icat \
           --name $RES1_NAME irods4.0.3-centos5
sleep 10
RES1_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $RES1_NAME)
docker exec --tty $ICAT_NAME ./assign-resource-host.sh ${RES1_NAME}Resource $RES1_NAME $RES1_IP
docker run --interactive --rm --tty --env RODS_PASSWORD=$PASSWORD --link $ICAT_NAME:icat \
           --name icommands icommands4.0.3
./stop.sh
