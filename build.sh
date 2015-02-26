#!/bin/sh

docker build --file irods4.0.3-icat-db.Dockerfile --tag irods4.0.3-icat-db .
docker build --file irods4.0.3-icat.Dockerfile --tag irods4.0.3-icat .
docker build --file irods4.0.3-rs-centos5.Dockerfile --tag irods4.0.3-rs-centos5 .
docker build --file irods4.0.3-rs-centos6.Dockerfile --tag irods4.0.3-rs-centos6 .
docker build --file irods4.0.3-rs-ubuntu.Dockerfile --tag irods4.0.3-rs-ubuntu .
docker build --file icommands4.0.3.Dockerfile --tag icommands4.0.3 .
