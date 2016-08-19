FROM irods_server
MAINTAINER tedgin@cyverse.org

RUN yum install --assumeyes --nogpgcheck \
        http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-2.noarch.rpm
RUN yum install --assumeyes postgresql93-odbc postgresql93-server unixODBC-devel

RUN mkdir --parents /etc/bisque /var/log/bisque

COPY odbc.ini /home/irods/.odbc.ini
COPY init-specific-queries.sh /home/irods/
COPY bisque_ops.py /home/irods/iRODS/server/bin/cmd/
COPY bisque_config.tmpl /bisque_config.tmpl

RUN chown --recursive irods:irods /home/irods/.* /etc/bisque /var/log/bisque

COPY pre-init.sh /init-scripts/pre.sh
COPY post-init.sh /init-scripts/post.sh

