#!/bin/bash

ADMIN_USER=ipc_admin
DB_USER=rodsuser
PASSWORD=password
ZONE=iplant


docker run --detach \
           --env POSTGRES_USER=$DB_USER --env POSTGRES_PASSWORD=$PASSWORD \
	   --hostname irods-dbms \
           --name irods-dbms \
           irods3.3.1-dbms

xterm -e docker run --interactive --tty \
                    --env ADMIN_USER=$ADMIN_USER \
                    --env ADMIN_PASSWORD=$PASSWORD \
                    --env DB_USER=$DB_USER \
                    --env DB_PASSWORD=$PASSWORD \
                    --env ZONE=$ZONE \
                    --hostname ies \
                    --link irods-dbms:dbms \
                    --name ies \
                    irods3.3.1-ies &

sleep 1

xterm -e docker run --interactive --tty \
                    --env ADMIN_USER=$ADMIN_USER \
                    --env ADMIN_PASSWORD=$PASSWORD \
                    --env RESOURCE_NAME=rsResc \
                    --env ZONE=$ZONE \
                    --hostname rs \
                    --link ies:ies \
	            --name rs \
                    irods3.3.1-rs &

while true
do
  RS_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' rs)
  if [ $? -eq 0 ]; then break; fi
  sleep 1
done

docker exec --tty ies /add-host.sh rs $RS_IP

docker run --interactive --tty \
           --env irodsUserName=$ADMIN_USER --env irodsZone=$ZONE --env RODS_PASSWORD=$PASSWORD \
           --link ies:ies \
           --name icommands \
           icommands3.3.1

./stop.sh
