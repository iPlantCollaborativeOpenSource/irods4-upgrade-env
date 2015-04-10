#!/bin/sh

docker build --file icommands3.3.1.Dockerfile        --tag icommands3.3.1 .
docker build --file irods3.3.1-icat.Dockerfile       --tag irods3.3.1-icat .
docker build --file irods3.3.1-iers.Dockerfile       --tag irods3.3.1-iers .
docker build --file irods3.3.1-rs-centos5.Dockerfile --tag irods3.3.1-rs-centos5 .
docker build --file irods3.3.1-rs-centos6.Dockerfile --tag irods3.3.1-rs-centos6 .
docker build --file irods3.3.1-rs-ubuntu.Dockerfile  --tag irods3.3.1-rs-ubuntu .

danglers=$(docker images --quiet --filter 'dangling=true')

if [ -n "$danglers" ]
then
    docker rmi $danglers
fi
