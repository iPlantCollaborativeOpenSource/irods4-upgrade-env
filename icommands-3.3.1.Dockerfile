FROM irods_base
MAINTAINER tedgin@iplantcollaborative.org

COPY icommands-3.3.1/build-icommands.sh /

# Prepare iRODS
RUN sed --in-place --expression='s/^# *NETCDF_CLIENT=.*/NETCDF_CLIENT=1/' \
        /home/irods/iRODS/config/config.mk.in && \
    /build-icommands.sh

COPY icommands-3.3.1/bootstrap.sh /

WORKDIR /home/irods

USER irods

ENTRYPOINT [ "/bootstrap.sh" ]
