FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN yum update --assumeyes
RUN yum install --assumeyes gcc gcc-c++ perl sudo tar which

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

COPY irods3.3.1-rs/bootstrap.sh /
RUN chmod a+x /bootstrap.sh

RUN useradd --create-home --system irods

RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz
RUN chown --recursive irods:irods /home/irods

EXPOSE 1247
ENTRYPOINT [ "/bootstrap.sh" ]
