FROM centos:6
MAINTAINER tedgin@iplantcollaborative.org

# Update base
RUN yum update --assumeyes && \
    yum install --assumeyes tar

# Install NetCDF4
RUN yum install --assumeyes epel-release && \
    yum install --assumeyes netcdf-devel

# Install PostgreSQL
ADD http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-centos90-9.0-5.noarch.rpm \
    pgdg-centos90-9.0-5.noarch.rpm

RUN yum install --assumeyes --nogpgcheck /pgdg-centos90-9.0-5.noarch.rpm && \
    yum install --assumeyes postgresql90-server

# Install ODBC
RUN yum install --assumeyes file gcc-c++ libtool && \
    yum install --assumeyes wget && \
    wget ftp://anonymous:anonymous@ftp.unixodbc.org/pub/unixODBC/unixODBC-2.2.12.tar.gz && \
    yum remove --assumeyes wget && \
    tar --get --gzip --file unixODBC-2.2.12.tar.gz

WORKDIR /unixODBC-2.2.12

RUN ./configure --disable-gui && \
    make && \
    make install

WORKDIR /

RUN rm --force --recursive unixODBC-2.2.12 unixODBC-2.2.12.tar.gz

# Prepare iRODS
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install --assumeyes sudo which && \
    ln --symbolic /usr/local/lib/libodbcpsql.so /usr/pgsql-9.0/lib/libodbcpsql.so && \
    useradd --create-home --system irods && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    sed --in-place \
        --expression='s/^# *NETCDF_API.*/NETCDF_API=1/' \
        --expression="s|^ *NETCDF_DIR.*|NETCDF_DIR=$(nc-config --prefix)|" \
        --expression='s/^# *NETCDF4_API=.*/NETCDF4_API=1/' \
        /home/irods/iRODS/config/config.mk.in

COPY 3.3.1/collection.c /home/irods/iRODS/server/core/src/

RUN rm --force irods3.3.1.tgz

# Place iPlant customizations
COPY ies-3.3.1/odbc.ini /home/irods/.odbc.ini
COPY ies-3.3.1/init-specific-queries.sh /home/irods/
COPY 3.3.1/insert2bisque.py /home/irods/iRODS/server/bin/cmd/
COPY 3.3.1/reConfigs/* /home/irods/iRODS/server/config/reConfigs/

RUN yum install --assumeyes python-pika && \
    yum install --assumeyes git && \
    git clone https://github.com/iPlantCollaborativeOpenSource/irods-setavu-mod.git \
        /home/irods/iRODS/modules/setavu && \
    git clone https://github.com/iPlantCollaborativeOpenSource/irods-cmd-scripts.git && \
    cp /irods-cmd-scripts/amqptopicsend.py /irods-cmd-scripts/generateuuid.sh \
        /home/irods/iRODS/server/bin/cmd/ && \ 
    rm --force --recursive /home/irods/iRODS/modules/setavu/.git /irods-cmd-scripts && \
    yum remove --assumeyes git && \
    ln --symbolic /home/irods/iRODS/server/config/reConfigs/ipc-env-prod.re \ 
        /home/irods/iRODS/server/config/reConfigs/ipc-env.re && \
    sed --in-place 's/^reRuleSet.*$/reRuleSet ipc-custom,core/' \
        /home/irods/iRODS/server/config/server.config.in && \
    mkdir --parents /home/irods/aegisVault && \
    chown --recursive irods:irods /home/irods

ENV PATH "$PATH:/home/irods/iRODS/clients/icommands/bin"

# Prepare uuidd
RUN yum install --assumeyes uuidd && \
    yum remove --assumeyes tar && \
    yum clean all

COPY ies-3.3.1/bootstrap.sh /

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]

