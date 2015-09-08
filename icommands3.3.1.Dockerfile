FROM debian
MAINTAINER tedgin@iplantcollaborative.org

# Upgrade base packages
RUN apt-get update && \
    apt-get --yes install apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes upgrade 

# Prepare iRODS
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN DEBIAN_FRONTEND=noninteractive apt-get --yes install g++ make perl-modules && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes install adduser && \
    adduser --system --group irods && \
    DEBIAN_FRONTEND=noninteractive apt-get --yes purge adduser && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    chown --recursive irods:irods /home/irods && \
    rm --force irods3.3.1.tgz 

COPY icommands3.3.1/build-icommands.sh /

RUN /build-icommands.sh

ENV PATH=$PATH:/home/irods/iRODS/clients/icommands/bin

RUN DEBIAN_FRONTEND=noninteractive apt-get --yes purge g++ make perl-modules && \
    apt-get clean

COPY icommands3.3.1/bootstrap.sh /

WORKDIR /home/irods

USER irods

ENTRYPOINT [ "/bootstrap.sh" ]
