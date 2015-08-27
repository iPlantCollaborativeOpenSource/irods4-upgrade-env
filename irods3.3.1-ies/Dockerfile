FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

ADD http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm \
    pgdg-centos90-9.0-5.noarch.rpm
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

COPY bootstrap.sh /

RUN yum install -y epel-release && \
    yum install -y --nogpgcheck /pgdg-centos90-9.0-5.noarch.rpm && \
    yum update -y && \
    yum install -y \
        gcc gcc-c++ make perl.x86_64 postgresql90-server python-pika python26 sudo \
        unixODBC64-devel.x86_64 unixODBC-libs.x86_64 uuidd which \
        git && \
    ln -s /usr/lib64/libodbcpsql.so /usr/pgsql-9.0/lib/libodbcpsql.so && \
    adduser -r --create-home irods && \
    tar --get --gzip --directory /home/irods --file irods3.3.1.tgz && \
    git clone https://github.com/iPlantCollaborativeOpenSource/irods-setavu-mod.git \
        /home/irods/iRODS/modules/setavu && \
    rm -rf /home/irods/iRODS/modules/setavu/.git && \
    git clone https://github.com/iPlantCollaborativeOpenSource/irods-cmd-scripts.git && \
    cp /irods-cmd-scripts/amqptopicsend.py /irods-cmd-scripts/generateuuid.sh \
        /home/irods/iRODS/server/bin/cmd/ && \
    rm -rf /irods-cmd-scripts && \
    yum remove -y git && \
    yum clean all && \
    rm -f irods3.3.1.tgz pgdg-centos90-9.0-5.noarch.rpm

COPY collection.c /home/irods/iRODS/server/core/src/
COPY odbc.ini /home/irods/.odbc.ini
COPY insert2bisque.py /home/irods/iRODS/server/bin/cmd/

RUN chown -R irods:irods /home/irods

EXPOSE 1247

ENTRYPOINT [ "/bootstrap.sh" ]
