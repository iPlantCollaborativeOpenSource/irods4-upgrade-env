#! /bin/bash

docker build --tag irods-netcdf-build .

if [ -e src ]
then
  (cd src; git pull)
else
  git clone https://github.com/irods/irods_netcdf.git src
fi

docker run --rm --tty --user=$(id -u):$(id -g) --volume=$(pwd)/src:/src --name=netcdf-builder \
       irods-netcdf-build  bash -c '
  for pkg in api microservices icommands
  do
    "$pkg"/packaging/build.sh clean
    "$pkg"/packaging/build.sh -r
  done
'
