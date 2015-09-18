FROM irods_base
MAINTAINER tedgin@iplantcollaborative.org

# Install NetCDF Support
RUN yum install --assumeyes epel-release && \
    yum install --assumeyes netcdf-devel && \
    sed --in-place \
        --expression='s/^# *NETCDF_API.*/NETCDF_API=1/' \
        --expression="s|^ *NETCDF_DIR.*|NETCDF_DIR=$(nc-config --prefix)|" \
        --expression='s/^# *NETCDF4_API=.*/NETCDF4_API=1/' \
        /home/irods/iRODS/config/config.mk.in 

# Install customizations
COPY server-3.3.1/insert2bisque.py /home/irods/iRODS/server/bin/cmd/
COPY server-3.3.1/reConfigs/* /home/irods/iRODS/server/config/reConfigs/

RUN yum install --assumeyes python-pika uuidd && \
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
    chown --recursive irods:irods /home/irods && \    
    yum clean all 

# Set up initialization
RUN mkdir /init-scripts

COPY server-3.3.1/bootstrap.sh /

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]