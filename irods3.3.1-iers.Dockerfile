FROM centos:5
MAINTAINER tedgin@iplantcollaborative.org

ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

ADD http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm \
    pgdg-centos90-9.0-5.noarch.rpm
ADD http://irods.sdsc.edu/cgi-bin/upload18.cgi/irods3.3.1.tgz irods3.3.1.tgz

RUN yum install -y --nogpgcheck /pgdg-centos90-9.0-5.noarch.rpm
RUN yum update -y
RUN yum install -y gcc gcc-c++ make perl.x86_64 postgresql90-server sudo unixODBC64-devel.x86_64 \
                   unixODBC-libs.x86_64 which

RUN ln -s /usr/lib64/libodbcpsql.so /usr/pgsql-9.0/lib/libodbcpsql.so

COPY irods3.3.1-iers/bootstrap.sh /
COPY scripts/add-host.sh /
RUN chmod a+x /*.sh

RUN adduser -r --create-home irods
COPY irods3.3.1-iers/odbc.ini /home/irods/.odbc.ini
RUN tar --get --gzip --directory /home/irods --file irods3.3.1.tgz
RUN chown -R irods:irods /home/irods

EXPOSE 1247
ENTRYPOINT [ "/bootstrap.sh" ]
