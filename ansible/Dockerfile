FROM williamyeh/ansible:ubuntu16.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install --assume-yes apt-utils 2>/dev/null
RUN dpkg-reconfigure apt-utils

COPY ssh-config /root/.ssh/config
RUN mkdir --parents /root/.ssh
RUN chmod go= /root/.ssh

RUN apt-get install --assume-yes python-dnspython
COPY ansible.cfg /etc/ansible/ansible.cfg
COPY ds-ansible /ds-ansible
RUN ansible-galaxy install --role-file /ds-ansible/irods4-upgrade/requirements.yml

COPY bootstrap.sh /bootstrap.sh

WORKDIR /ds-ansible

ENTRYPOINT [ "/bootstrap.sh" ]
