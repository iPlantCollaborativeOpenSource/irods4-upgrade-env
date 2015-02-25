FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

RUN yum update -y
RUN yum install -y sudo wget which

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# download iRODS
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-database-plugin-postgres-1.3-centos5.rpm -O /tmp/irods-dbplugin.rpm
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-icat-4.0.3-64bit-centos5.rpm -O /tmp/irods-icat.rpm

# install packages
RUN yum install -y --nogpgcheck /tmp/irods-icat.rpm 
RUN yum install -y --nogpgcheck /tmp/irods-dbplugin.rpm

RUN mkdir /opt/irods

ADD ./genresp.sh /opt/irods/genresp.sh
ADD ./config.sh /opt/irods/config.sh
ADD ./bootstrap.sh /opt/irods/bootstrap.sh
ADD ./assign-resource-host.sh /opt/irods/assign-resource-host.sh
RUN chmod a+x /opt/irods/*.sh

EXPOSE 1247 20000-20199
ENTRYPOINT [ "/opt/irods/bootstrap.sh" ]
