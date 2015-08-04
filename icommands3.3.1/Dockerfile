FROM debian
MAINTAINER tedgin@iplantcollaborative.org

RUN apt-get update
RUN apt-get upgrade --fix-missing --yes
RUN apt-get install --yes adduser g++ make perl-modules sudo

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

COPY build-icommands.sh /
RUN chmod a+x build-icommands.sh

RUN adduser --system --group irods
RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz

RUN chown --recursive irods:irods /home/irods
RUN /build-icommands.sh
ENV PATH=$PATH:/home/irods/iRODS/clients/icommands/bin

COPY bootstrap.sh /
RUN chmod a+x bootstrap.sh
RUN chown irods:irods bootstrap.sh

WORKDIR /home/irods
USER irods
ENTRYPOINT [ "/bootstrap.sh" ]
