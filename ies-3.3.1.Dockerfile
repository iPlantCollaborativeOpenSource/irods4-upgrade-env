FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

# Configure yum and update
RUN yum update -y

# Install HDF5
ADD https://www.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.10/bin/RPMS/hdf5-1.8.10-1.el5.x86_64.rpm \
    hdf5-1.8.10-1.el5.x86_64.rpm

RUN yum install -y ed && \
    yum install -y --nogpgcheck /hdf5-1.8.10-1.el5.x86_64.rpm && \
    rm --force hdf5-1.8.10-1.el5.x86_64.rpm

# Install NetCDF4
ADD http://pkgs.fedoraproject.org/repo/pkgs/netcdf/netcdf-4.2.1.1.tar.gz/5eebcf19e6ac78a61c73464713cbfafc/netcdf-4.2.1.1.tar.gz \
    netcdf-4.2.1.1.tar.gz

RUN yum install -y curl-devel.x86_64 file gcc make && \
    tar --get --gzip --file netcdf-4.2.1.1.tar.gz

WORKDIR netcdf-4.2.1.1

RUN ./configure --enable-netcdf-4 && \
    make check install

WORKDIR /

RUN rm --force --recursive netcdf-4.2.1.1 netcdf-4.2.1.1.tar.gz

# Prepare iRODS
ADD http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm \
    pgdg-centos90-9.0-5.noarch.rpm
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install -y epel-release && \
    yum install -y --nogpgcheck /pgdg-centos90-9.0-5.noarch.rpm && \
    yum install -y \
        gcc-c++ perl.x86_64 postgresql90-server sudo unixODBC64-devel.x86_64 \
        unixODBC-libs.x86_64 which && \
    ln --symbolic /usr/lib64/libodbcpsql.so /usr/pgsql-9.0/lib/libodbcpsql.so && \
    adduser -r --create-home irods && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    sed --in-place \
        --expression='s/^# *NETCDF_API.*/NETCDF_API=1/' \
        --expression="s|^ *NETCDF_DIR.*|NETCDF_DIR=$(nc-config --prefix)|" \
        --expression='s/^# *NETCDF4_API=.*/NETCDF4_API=1/' \
        /home/irods/iRODS/config/config.mk.in

COPY 3.3.1/collection.c /home/irods/iRODS/server/core/src/

RUN rm --force irods3.3.1.tgz pgdg-centos90-9.0-5.noarch.rpm

# Place iPlant customizations
COPY ies-3.3.1/odbc.ini /home/irods/.odbc.ini
COPY ies-3.3.1/init-specific-queries.sh /home/irods/
COPY 3.3.1/insert2bisque.py /home/irods/iRODS/server/bin/cmd/
COPY 3.3.1/reConfigs/* /home/irods/iRODS/server/config/reConfigs/

RUN yum install -y python-pika python26 && \
    yum install -y git && \
    git clone https://github.com/iPlantCollaborativeOpenSource/irods-setavu-mod.git \
        /home/irods/iRODS/modules/setavu && \
    git clone https://github.com/iPlantCollaborativeOpenSource/irods-cmd-scripts.git && \
    cp /irods-cmd-scripts/amqptopicsend.py /irods-cmd-scripts/generateuuid.sh \
        /home/irods/iRODS/server/bin/cmd/ && \ 
    rm --force --recursive /home/irods/iRODS/modules/setavu/.git /irods-cmd-scripts && \
    yum remove -y git && \
    ln --symbolic /home/irods/iRODS/server/config/reConfigs/ipc-env-prod.re \ 
        /home/irods/iRODS/server/config/reConfigs/ipc-env.re && \
    sed --in-place 's/^reRuleSet.*$/reRuleSet ipc-custom,core/' \
        /home/irods/iRODS/server/config/server.config.in && \
    mkdir --parents /home/irods/aegisVault && \
    chown --recursive irods:irods /home/irods

ENV PATH "$PATH:/home/irods/iRODS/clients/icommands/bin"

# Prepare uuidd
RUN yum install -y uuidd && \
    yum clean all

COPY ies-3.3.1/bootstrap.sh /

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]

