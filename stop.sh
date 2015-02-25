#! /bin/bash

CONTAINERS="icommands centos5RS icat icat-db"

docker stop $CONTAINERS
docker rm $CONTAINERS
