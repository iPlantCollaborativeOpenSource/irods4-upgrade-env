FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

RUN apt-get update && \
    apt-get --yes install apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes install net-tools && \
    apt-get clean

COPY dbms/set-postgresql-conf.sh /docker-entrypoint-initdb.d/

