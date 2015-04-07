#!/bin/bash

ADMIN_USER=ipc_admin
DB_USER=rodsuser
PASSWORD=password
ZONE=iplant

DB_NAME=icat-db
ICAT_NAME=icat


function run-resource-server ()
{
    NAME=$1
    IMAGE=$2

    docker run --detach --tty \
               --env ADMIN_USER=$ADMIN_USER \
               --env ADMIN_PASSWORD=$PASSWORD \
               --env RESOURCE_NAME=${NAME}Resc \
               --env ZONE=$ZONE \
               --hostname $NAME --link $ICAT_NAME:icat --name $NAME \
               $IMAGE

    IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $NAME)
    docker exec --tty $ICAT_NAME ./assign-resource-host.sh $NAME $IP
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
           --link $DB_NAME:db \
           --name $ICAT_NAME \
           irods3.3.1-icat

run-resource-server centos5RS irods3.3.1-rs-centos5
run-resource-server centos6RS irods3.3.1-rs-centos6

docker run --interactive --tty \
           --env irodsUserName=$ADMIN_USER --env irodsZone=$ZONE --env RODS_PASSWORD=$PASSWORD \
           --link $ICAT_NAME:icat \
           --name icommands \
           icommands3.3.1

./stop.sh
