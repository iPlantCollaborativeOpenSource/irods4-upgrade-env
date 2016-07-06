FROM centos:6
MAINTAINER tedgin@cyverse.org

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum update --assumeyes && \
    yum install --assumeyes gcc-c++ perl tar which && \
    useradd --create-home --system irods && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz 

COPY collection.c /home/irods/iRODS/server/core/src/

RUN chown --recursive irods:irods /home/irods && \
    rm --force irods3.3.1.tgz && \
    yum clean all
 
ENV PATH "$PATH:/home/irods/iRODS/clients/icommands/bin"

