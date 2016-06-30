#! /bin/bash

source env.properties

docker-compose --project-name "$PROJECT_NAME" run --no-deps --rm icommands "$@" 
