#! /bin/bash

. "$(dirname $0)"/env.properties

docker-compose --project "$PROJECT_NAME" "$@"
