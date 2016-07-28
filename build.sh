#! /bin/bash

if [ ! -f id_rsa -o ! -f id_rsa.pub ]
then
  ssh-keygen -f id_rsa -N ''
fi

docker-compose --project-name irods build base
docker-compose --project-name irods build server
docker-compose --project-name irods build
