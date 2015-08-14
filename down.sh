#! /bin/bash

# This script brings down the iRODS grid

docker-compose stop
docker-compose rm -v --force
