FROM debian
MAINTAINER tedgin@iplantcollaborative.org

RUN apt-get update
RUN apt-get install --yes adduser g++ make perl-modules

RUN adduser --system irods

WORKDIR /home/irods

ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz
RUN tar --get --gzip --file irods3.3.1.tgz

COPY icommands3.3.1/iputs.sh /home/irods/
RUN chmod a+x /home/irods/iputs.sh

COPY icommands3.3.1/iputs-retry.sh /home/irods/
RUN chmod a+x /home/irods/iputs-retry.sh

COPY icommands3.3.1/bootstrap.sh ./
COPY icommands3.3.1/build-icommands.sh iRODS/
RUN chmod a+x bootstrap.sh iRODS/build-icommands.sh
RUN chown -R irods *

USER irods
WORKDIR iRODS
RUN ./build-icommands.sh

ENV PATH=$PATH:/home/irods/iRODS/clients/icommands/bin

WORKDIR ..

ENTRYPOINT [ "./bootstrap.sh" ]
