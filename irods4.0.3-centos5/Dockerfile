FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

RUN yum update -y
RUN yum install -y sudo wget which

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN wget --output-document=/tmp/irods.rpm \
         ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-resource-4.0.3-64bit-centos5.rpm
RUN yum install -y --nogpgcheck /tmp/irods.rpm

ADD ./get_icat_server_password.sh /var/lib/irods/packaging/get_icat_server_password.sh
RUN chmod a+x /var/lib/irods/packaging/get_icat_server_password.sh

ADD ./bootstrap.sh bootstrap.sh
RUN chmod a+x bootstrap.sh

EXPOSE 1247 20000-20199

ENTRYPOINT [ "./bootstrap.sh" ]
