FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

ADD http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm \
    pgdg-centos90-9.0-5.noarch.rpm
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install -y --nogpgcheck epel-release /pgdg-centos90-9.0-5.noarch.rpm
RUN yum update -y 
RUN yum install -y \
    gcc gcc-c++ make perl.x86_64 postgresql90-server sudo unixODBC64-devel.x86_64 \
    unixODBC-libs.x86_64 uuidd which
RUN yum install -y git

RUN ln -s /usr/lib64/libodbcpsql.so /usr/pgsql-9.0/lib/libodbcpsql.so

COPY bootstrap.sh /
RUN chmod a+x /*.sh

RUN adduser -r --create-home irods
COPY odbc.ini /home/irods/.odbc.ini
RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz
COPY collection.c /home/irods/iRODS/server/core/src/
RUN git clone https://github.com/iPlantCollaborativeOpenSource/irods-setavu-mod.git \
    /home/irods/iRODS/modules/setavu
RUN chown -R irods:irods /home/irods

RUN yum remove -y git

EXPOSE 1247
ENTRYPOINT [ "/bootstrap.sh" ]
