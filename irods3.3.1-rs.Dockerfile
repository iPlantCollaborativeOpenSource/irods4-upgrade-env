FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

# Update base
RUN yum update --assumeyes

# Install NetCDF4
RUN yum install --assumeyes epel-release && \
    yum install --assumeyes netcdf-devel

# Prepare iRODS
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install --assumeyes gcc-c++ sudo which && \
    useradd --create-home --system irods && \
    yum install --assumeyes tar && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    yum remove --assumeyes tar && \
    sed --in-place \
        --expression='s/^# *NETCDF_API.*/NETCDF_API=1/' \
        --expression="s|^ *NETCDF_DIR.*|NETCDF_DIR=$(nc-config --prefix)|" \
        --expression='s/^# *NETCDF4_API=.*/NETCDF4_API=1/' \
        /home/irods/iRODS/config/config.mk.in && \
    chown --recursive irods:irods /home/irods && \
    rm --force irods3.3.1.tgz && \
    yum clean all

COPY irods3.3.1-rs/bootstrap.sh /

VOLUME /home/irods/iRODS/Vault

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]
