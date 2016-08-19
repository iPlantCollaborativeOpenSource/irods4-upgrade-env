FROM postgres:9.3
MAINTAINER tedgin@cyverse.org

# Configure for ansible
RUN apt-get update && \
    apt-get install --assume-yes openssh-server sudo && \
    sed --in-place 's/^Port .*/Port 1657/' /etc/ssh/sshd_config && \
    usermod --home /var/lib/postgresql postgres

COPY set-postgresql-conf.sh /docker-entrypoint-initdb.d/
COPY start-sshd.sh /docker-entrypoint-initdb.d/

