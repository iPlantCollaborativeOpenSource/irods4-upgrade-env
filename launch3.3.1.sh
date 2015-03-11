#!/bin/bash

ADMIN_USER=ipc_admin
DB_USER=rodsuser
PASSWORD=password

DB_NAME=icat-db
ICAT_NAME=icat


./stop.sh >/dev/null 2>/dev/null

docker run --detach --env POSTGRES_USER=$DB_USER --env POSTGRES_PASSWORD=$PASSWORD --name $DB_NAME \
           icat-db

docker run --detach --tty \
           --env ADMIN_USER=$ADMIN_USER \
           --env ADMIN_PASSWORD=$PASSWORD \
           --env DB_USER=$DB_USER \
           --env DB_PASSWORD=$PASSWORD \
           --env ZONE=iplant \
           --link $DB_NAME:db \
           --name $ICAT_NAME \
           irods3.3.1-icat

docker run --interactive --tty \
           --env irodsHost=irods-2.iplantcollaborative.org --env irodsZone=iplant --name icommands \
           icommands3.3.1

./stop.sh