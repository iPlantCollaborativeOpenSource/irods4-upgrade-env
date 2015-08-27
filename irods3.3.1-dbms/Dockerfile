FROM postgres:9.3
MAINTAINER tedgin@iplantcollaborative.org

COPY set-postgresql-conf.sh /docker-entrypoint-initdb.d/

RUN apt-get update && \
    apt-get --yes install apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes install net-tools && \
    apt-get clean

