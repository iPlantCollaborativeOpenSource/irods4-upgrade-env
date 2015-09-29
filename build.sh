#! /bin/bash

docker-compose --project-name irods build base
docker-compose --project-name irods build server
docker-compose --project-name irods build
