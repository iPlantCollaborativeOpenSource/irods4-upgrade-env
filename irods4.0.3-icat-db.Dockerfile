FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

COPY irods4.0.3-icat-db/init-icat-db.sh /docker-entrypoint-initdb.d/
