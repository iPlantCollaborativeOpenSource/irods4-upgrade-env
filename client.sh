#! /bin/bash

docker-compose --project-name irods run --no-deps --rm icommands "$@" 
