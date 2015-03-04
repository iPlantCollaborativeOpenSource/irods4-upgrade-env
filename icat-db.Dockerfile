FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

COPY icat-db/init-icat-db.sh /docker-entrypoint-initdb.d/
