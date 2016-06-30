#! /bin/bash

# This script brings down the iRODS grid

source env.properties

docker-compose --project-name "$PROJECT_NAME" stop
docker-compose --project-name "$PROJECT_NAME" rm -v --force
