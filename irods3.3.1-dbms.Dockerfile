FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

COPY irods3.3.1-dbms/init-icat-db.sh /docker-entrypoint-initdb.d/
