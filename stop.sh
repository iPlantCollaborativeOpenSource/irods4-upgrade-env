#! /bin/bash

CONTAINERS="icommands centos5RS centos6RS ubuntuRS iers icat-db"

docker stop $CONTAINERS
docker rm $CONTAINERS
