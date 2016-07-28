#! /bin/bash

source env.properties

docker-compose --project-name "$PROJECT_NAME" run --no-deps --rm ansible -c "
  printf '%s' '$(cat id_rsa)' > /root/.ssh/id_rsa
  chmod go= /root/.ssh/id_rsa
  bash
"
