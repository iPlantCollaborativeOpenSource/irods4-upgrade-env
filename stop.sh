#! /bin/bash

CONTAINERS="icommands centos5RS centos6RS icat icat-db"

docker stop $CONTAINERS
docker rm $CONTAINERS
