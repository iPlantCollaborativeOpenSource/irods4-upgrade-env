FROM ubuntu:12.04
MAINTAINER tedgin@iplantcollaborative.org

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update
RUN apt-get upgrade --yes
RUN apt-get install --yes g++ make perl-modules sudo

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

COPY irods3.3.1-rs/bootstrap.sh /
RUN chmod a+x /bootstrap.sh

RUN useradd --create-home --system irods

RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz
RUN chown --recursive irods:irods /home/irods

EXPOSE 1247
ENTRYPOINT [ "./bootstrap.sh" ]
