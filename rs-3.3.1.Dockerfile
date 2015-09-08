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
        /home/irods/iRODS/config/config.mk.in

COPY 3.3.1/collection.c /home/irods/iRODS/server/core/src/

RUN rm --force irods3.3.1.tgz 

# Place iPlant customizations
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
    chown --recursive irods:irods /home/irods

ENV PATH "$PATH:/home/irods/iRODS/clients/icommands/bin"

# Prepare uuidd
RUN yum install --assumeyes uuidd && \
    yum clean all

COPY rs-3.3.1/bootstrap.sh /

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]
