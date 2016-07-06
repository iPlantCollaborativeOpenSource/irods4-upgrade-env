FROM centos:6
MAINTAINER tedgin@cyverse.org

RUN yum install --assumeyes gcc-c++ git && \
    yum clean all && \
    useradd --create-home --system irods && \
    git clone --branch 3.3.1-custom https://github.com/cyverse/irods-legacy.git && \
    mv irods-legacy/iRODS /home/irods/ && \
    rm --force --recursive irods-legacy && \
    chown --recursive irods:irods /home/irods 
 
ENV PATH "$PATH":/home/irods/iRODS/clients/icommands/bin

