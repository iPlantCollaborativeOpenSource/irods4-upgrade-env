FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN yum update --assumeyes
RUN yum install --assumeyes gcc gcc-c++ perl sudo tar which

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN useradd --create-home --system irods
RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz
COPY irods3.3.1-icat/build-irods.sh /home/irods/
RUN chmod a+x /home/irods/build-irods.sh
RUN chown --recursive irods:irods /home/irods

USER irods
RUN /home/irods/build-irods.sh
USER root

COPY irods3.3.1-icat/odbc.ini /home/irods/.odbc.ini
RUN chown irods:irods /home/irods/.odbc.ini

COPY irods3.3.1-icat/bootstrap.sh /
RUN chmod a+x bootstrap.sh

EXPOSE 1247
ENTRYPOINT [ "/bootstrap.sh" ]
