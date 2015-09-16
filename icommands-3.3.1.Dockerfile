FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

# Update base
RUN yum update --assumeyes 

# Prepare iRODS
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install --assumeyes gcc-c++ perl which && \
    useradd --create-home --system irods && \
    yum install --assumeyes tar && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    yum remove --assumeyes tar && \
    sed --in-place --expression='s/^# *NETCDF_CLIENT=.*/NETCDF_CLIENT=1/' \
        /home/irods/iRODS/config/config.mk.in && \
    chown --recursive irods:irods /home/irods && \
    rm --force irods3.3.1.tgz 

COPY icommands-3.3.1/build-icommands.sh /

RUN /build-icommands.sh

ENV PATH=$PATH:/home/irods/iRODS/clients/icommands/bin

RUN yum remove --assumeyes gcc-c++ perl which && \
    yum clean all

COPY icommands-3.3.1/bootstrap.sh /

WORKDIR /home/irods

USER irods

ENTRYPOINT [ "/bootstrap.sh" ]
