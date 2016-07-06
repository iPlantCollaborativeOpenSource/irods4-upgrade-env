FROM irods_base
MAINTAINER tedgin@cyverse.org

COPY build-icommands.sh /

# Prepare iRODS
RUN sed --in-place --expression='s/^# *NETCDF_CLIENT=.*/NETCDF_CLIENT=1/' \
        /home/irods/iRODS/config/config.mk.in && \
    /build-icommands.sh

COPY bootstrap.sh /

WORKDIR /home/irods

USER irods

ENTRYPOINT [ "/bootstrap.sh" ]
