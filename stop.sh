#! /bin/bash

CONTAINERS="icommands res-centos5 icat icat-db"

docker stop $CONTAINERS
docker rm $CONTAINERS
