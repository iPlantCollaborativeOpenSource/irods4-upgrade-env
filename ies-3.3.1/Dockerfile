FROM irods_server
MAINTAINER tedgin@iplantcollaborative.org

# Install PostgreSQL
ADD http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-centos90-9.0-5.noarch.rpm \
    pgdg-centos90-9.0-5.noarch.rpm

RUN yum install --assumeyes --nogpgcheck /pgdg-centos90-9.0-5.noarch.rpm && \
    yum install --assumeyes postgresql90-server

# Install ODBC
RUN yum install --assumeyes file libtool && \
    yum install --assumeyes wget && \
    wget ftp://anonymous:anonymous@ftp.unixodbc.org/pub/unixODBC/unixODBC-2.2.12.tar.gz && \
    yum remove --assumeyes wget && \
    tar --get --gzip --file unixODBC-2.2.12.tar.gz && \
    yum clean all

WORKDIR /unixODBC-2.2.12

RUN ./configure --disable-gui && \
    make && \
    make install

WORKDIR /

RUN rm --force --recursive unixODBC-2.2.12 unixODBC-2.2.12.tar.gz

# Prepare iRODS
RUN ln --symbolic /usr/local/lib/libodbcpsql.so /usr/pgsql-9.0/lib/libodbcpsql.so

# Place iPlant customizations
COPY odbc.ini /home/irods/.odbc.ini
COPY init-specific-queries.sh /home/irods/

RUN chown irods:irods /home/irods/.*

COPY pre-init.sh /init-scripts/pre.sh
COPY post-init.sh /init-scripts/post.sh

