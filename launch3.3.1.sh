#!/bin/bash

ADMIN_USER=ipc_admin
DB_USER=rodsuser
PASSWORD=password
ZONE=iplant

DB_NAME=icat-db
IERS_NAME=iers
RES1_NAME=centos5RSResc
RES2_NAME=centos6RSResc
RES3_NAME=ubuntuRSResc


function run-resource-server ()
{
    NAME=$1
    RESC=$2
    IMAGE=$3

    docker run --detach --tty \
               --env ADMIN_USER=$ADMIN_USER \
               --env ADMIN_PASSWORD=$PASSWORD \
               --env RESOURCE_NAME=$RESC \
               --env ZONE=$ZONE \
               --hostname $NAME --link $IERS_NAME:iers --name $NAME \
               $IMAGE

    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $NAME)
    docker exec --tty $IERS_NAME ./assign-resource-host.sh $NAME $IP
}


./stop.sh >/dev/null 2>/dev/null

docker run --detach --env POSTGRES_USER=$DB_USER --env POSTGRES_PASSWORD=$PASSWORD --name $DB_NAME \
           icat-db

docker run --detach --tty \
           --env ADMIN_USER=$ADMIN_USER \
           --env ADMIN_PASSWORD=$PASSWORD \
           --env DB_USER=$DB_USER \
           --env DB_PASSWORD=$PASSWORD \
           --env ZONE=$ZONE \
           --hostname $IERS_NAME \
           --link $DB_NAME:db \
           --name $IERS_NAME \
           irods3.3.1-iers

run-resource-server centos5RS $RES1_NAME irods3.3.1-rs-centos5
run-resource-server centos6RS $RES2_NAME irods3.3.1-rs-centos6
run-resource-server ubuntuRS $RES3_NAME irods3.3.1-rs-ubuntu

xterm -e docker run --interactive --tty --hostname icat --name icat irods3.3.1-icat &

docker run --interactive --tty \
           --env irodsUserName=$ADMIN_USER --env irodsZone=$ZONE --env RODS_PASSWORD=$PASSWORD \
           --link $IERS_NAME:iers \
           --name icommands \
           icommands3.3.1 $RES1_NAME $RES2_NAME $RES3_NAME

./stop.sh
