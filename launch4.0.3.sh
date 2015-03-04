#! /bin/bash

PASSWORD=password
LOCAL_ZONE_SID=LZ_SID
AGENT_KEY=agentkey901234567890123456789012

DB_NAME=icat-db
ICAT_NAME=icat
RES1_NAME=centos5RS
RES2_NAME=centos6RS
RES3_NAME=ubuntuRS


function run-resource-server ()
{
    NAME=$1
    IMAGE=$2

    docker run --detach --tty \
               --env AGENT_KEY=$AGENT_KEY \
               --env LOCAL_ZONE_SID=$LOCAL_ZONE_SID \
               --env RODS_PASSWORD=$PASSWORD \
               --hostname $NAME \
               --link $ICAT_NAME:icat \
               --name $NAME \
               $IMAGE
}


function assign-resource-host ()
{
    HOST=$1

    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $HOST)
    docker exec --tty $ICAT_NAME ./assign-resource-host.sh $HOST $IP
}


./stop.sh >/dev/null 2>/dev/null

docker run --detach --env POSTGRES_PASSWORD=$PASSWORD --name $DB_NAME icat-db

docker run --detach --tty \
           --env AGENT_KEY=$AGENT_KEY \
           --env DB_PASSWORD=$PASSWORD \
           --env LOCAL_ZONE_SID=$LOCAL_ZONE_SID \
           --env RODS_PASSWORD=$PASSWORD \
           --link $DB_NAME:db \
           --name $ICAT_NAME \
           irods4.0.3-icat

run-resource-server $RES1_NAME irods4.0.3-rs-centos5
run-resource-server $RES2_NAME irods4.0.3-rs-centos6
run-resource-server $RES3_NAME irods4.0.3-rs-ubuntu

assign-resource-host $RES1_NAME
assign-resource-host $RES2_NAME
assign-resource-host $RES3_NAME

docker run --interactive --tty \
           --env RODS_PASSWORD=$PASSWORD \
           --link $ICAT_NAME:icat \
           --name icommands \
           icommands4.0.3

./stop.sh
