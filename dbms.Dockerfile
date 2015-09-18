FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

COPY dbms/set-postgresql-conf.sh /docker-entrypoint-initdb.d/

