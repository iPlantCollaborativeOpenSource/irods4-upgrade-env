#! /bin/bash

CONTAINERS="icommands centos5RS centos6RS ubuntuRS icat icat-db"

docker stop $CONTAINERS
docker rm $CONTAINERS
