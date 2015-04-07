#!/bin/sh

docker build --file icat-db.Dockerfile --tag icat-db .

docker build --file irods3.3.1-icat.Dockerfile       --tag irods3.3.1-icat .
docker build --file irods3.3.1-rs-centos5.Dockerfile --tag irods3.3.1-rs-centos5 .
docker build --file icommands3.3.1.Dockerfile        --tag icommands3.3.1 .

docker build --file irods4.0.3-icat.Dockerfile       --tag irods4.0.3-icat .
docker build --file irods4.0.3-rs-centos5.Dockerfile --tag irods4.0.3-rs-centos5 .
docker build --file irods4.0.3-rs-centos6.Dockerfile --tag irods4.0.3-rs-centos6 .
docker build --file irods4.0.3-rs-ubuntu.Dockerfile  --tag irods4.0.3-rs-ubuntu .
docker build --file icommands4.0.3.Dockerfile        --tag icommands4.0.3 .

danglers=$(docker images --quiet --filter 'dangling=true')

if [ -n "$danglers" ]
then
    docker rmi $danglers
fi
