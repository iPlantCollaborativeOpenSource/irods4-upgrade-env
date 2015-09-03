FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

# Update base
RUN yum update --assumeyes

# Prepare iRODS
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install --assumeyes gcc gcc-c++ perl sudo tar which && \
    useradd --create-home --system irods && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    chown --recursive irods:irods /home/irods && \
    rm --force irods3.3.1.tgz && \
    yum clean all

COPY bootstrap.sh /

VOLUME /home/irods/iRODS/Vault

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]
