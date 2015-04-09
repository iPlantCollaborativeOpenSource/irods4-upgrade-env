FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN yum update --assumeyes
RUN yum install --assumeyes gcc gcc-c++ perl tar which

RUN useradd --create-home --system irods
WORKDIR /home/irods

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz
RUN tar --get --gzip --file irods3.3.1.tgz

COPY irods3.3.1-icat/build-irods.sh ./
RUN chmod a+x build-irods.sh

RUN chown --recursive irods:irods *

USER irods
RUN ./build-irods.sh
USER root

ENV PATH /home/irods/iRODS/clients/icommands/bin:$PATH

COPY irods3.3.1-icat/odbc.ini ./.odbc.ini
COPY irods3.3.1-icat/bootstrap.sh ./
RUN chmod a+x bootstrap.sh
RUN chown irods:irods .odbc.ini bootstrap.sh

EXPOSE 1247
USER irods
ENTRYPOINT [ "./bootstrap.sh" ]
