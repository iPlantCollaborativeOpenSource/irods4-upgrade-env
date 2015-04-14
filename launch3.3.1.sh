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
ICAT_NAME=icat


function assign-host ()
{
    FROM_HOST=$1
    TO_HOST=$2

    while true
    do
        TO_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $TO_HOST)
        if [ $? -eq 0 ]; then break; fi
        sleep 1
    done

    docker exec --tty $FROM_HOST /add-host.sh $TO_HOST $TO_IP
}


function run-resource-server ()
{
    NAME=$1
    RESC=$2
    IMAGE=$3

    xterm -e docker run --interactive --tty \
                        --env ADMIN_USER=$ADMIN_USER \
                        --env ADMIN_PASSWORD=$PASSWORD \
                        --env RESOURCE_NAME=$RESC \
                        --env ZONE=$ZONE \
                        --hostname $NAME --link $IERS_NAME:iers --name $NAME \
                        $IMAGE &

    assign-host $IERS_NAME $NAME
}


./stop.sh >/dev/null 2>/dev/null

docker run --detach \
           --env POSTGRES_USER=$DB_USER --env POSTGRES_PASSWORD=$PASSWORD \
           --volume $(pwd)/icat-db:/docker-entrypoint-initdb.d/ \
           --name $DB_NAME \
           postgres:9.3

xterm -e docker run --interactive --tty \
                    --env ADMIN_USER=$ADMIN_USER \
                    --env ADMIN_PASSWORD=$PASSWORD \
                    --env DB_USER=$DB_USER \
                    --env DB_PASSWORD=$PASSWORD \
                    --env ZONE=$ZONE \
                    --hostname $IERS_NAME \
                    --link $DB_NAME:db \
                    --name $IERS_NAME \
                    irods3.3.1-iers &

sleep 1
run-resource-server centos5RS $RES1_NAME irods3.3.1-rs-centos5
run-resource-server centos6RS $RES2_NAME irods3.3.1-rs-centos6
run-resource-server ubuntuRS $RES3_NAME irods3.3.1-rs-ubuntu

xterm -e docker run --interactive --tty --hostname $ICAT_NAME --name $ICAT_NAME irods3.3.1-icat &

docker run --interactive --tty \
           --env irodsUserName=$ADMIN_USER --env irodsZone=$ZONE --env RODS_PASSWORD=$PASSWORD \
           --link $IERS_NAME:iers \
           --name icommands \
           icommands3.3.1 # $RES1_NAME $RES2_NAME $RES3_NAME

./stop.sh
