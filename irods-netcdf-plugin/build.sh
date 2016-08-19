#! /bin/bash

docker build --tag irods-dev-build .

if [ -e src ]
then
  (cd src; git pull)
else
  git clone https://github.com/irods/irods_netcdf.git src
fi

docker run --rm --tty --volume=$(pwd)/src:/src --name=netcdf-builder \
       irods-dev-build  bash -c '
  for pkg in api microservices icommands
  do
    "$pkg"/packaging/build.sh clean
    "$pkg"/packaging/build.sh -r
  done
'
