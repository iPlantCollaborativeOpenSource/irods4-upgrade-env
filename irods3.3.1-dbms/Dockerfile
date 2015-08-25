FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

RUN apt-get update
RUN apt-get install net-tools

COPY set-postgresql-conf.sh /docker-entrypoint-initdb.d/
