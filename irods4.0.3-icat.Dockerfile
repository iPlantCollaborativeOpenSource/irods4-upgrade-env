FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

RUN yum update -y
RUN yum install -y sudo wget which

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# download iRODS
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos5.rpm
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos5.rpm

# install packages
RUN yum install -y --nogpgcheck \
                irods-database-plugin-postgres-1.3-centos5.rpm irods-icat-4.0.3-64bit-centos5.rpm

COPY irods4.0.3-icat/bootstrap.sh bootstrap.sh
COPY irods4.0.3-icat/assign-resource-host.sh assign-resource-host.sh
RUN chmod a+x *.sh

EXPOSE 1247 20000-20199
ENTRYPOINT [ "./bootstrap.sh" ]
