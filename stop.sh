#! /bin/bash

CONTAINERS="icommands icat centos5RS centos6RS ubuntuRS iers icat-db"

docker stop $CONTAINERS
docker rm $CONTAINERS
