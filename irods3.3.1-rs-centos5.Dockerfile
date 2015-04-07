FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum update -y
RUN yum install -y gcc gcc-c++ make perl.x86_64 sudo which

COPY irods3.3.1-rs/bootstrap.sh /
RUN chmod a+x /bootstrap.sh

RUN adduser -r --create-home irods

RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz
RUN chown -R irods:irods /home/irods

EXPOSE 1247
ENTRYPOINT [ "/bootstrap.sh" ]