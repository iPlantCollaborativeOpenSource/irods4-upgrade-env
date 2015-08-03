#!/bin/sh

docker build --file icommands3.3.1.Dockerfile   --tag icommands3.3.1 .
docker build --file irods3.3.1-dbms.Dockerfile --tag irods3.3.1-dbms .
docker build --file irods3.3.1-ies.Dockerfile  --tag irods3.3.1-ies .
docker build --file irods3.3.1-rs.Dockerfile   --tag irods3.3.1-rs .

danglers=$(docker images --quiet --filter 'dangling=true')

if [ -n "$danglers" ]
then
    docker rmi $danglers
fi
