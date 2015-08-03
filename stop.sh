#! /bin/bash

CONTAINERS="icommands rs ies irods-dbms"

docker stop $CONTAINERS
docker rm $CONTAINERS
