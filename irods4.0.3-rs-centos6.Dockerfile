FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

RUN yum update --assumeyes

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN yum install --assumeyes sudo which

RUN yum install --assumeyes \
                ftp://ftp.renci.org/pub/irods/releases/4.0.3/irods-resource-4.0.3-64bit-centos6.rpm

COPY irods4.0.3-rs/get_icat_server_password.sh /var/lib/irods/packaging/get_icat_server_password.sh
RUN chmod a+x /var/lib/irods/packaging/get_icat_server_password.sh

COPY irods4.0.3-rs/bootstrap.sh bootstrap.sh
RUN chmod a+x bootstrap.sh

EXPOSE 1247 20000-20199

ENTRYPOINT [ "./bootstrap.sh" ]
