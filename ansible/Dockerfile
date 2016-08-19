FROM williamyeh/ansible:ubuntu16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install --assume-yes apt-utils 2>/dev/null
RUN dpkg-reconfigure apt-utils
RUN apt-get install --assume-yes git python-dnspython
RUN mkdir --parents /root/.ssh
RUN chmod go= /root/.ssh
RUN mkdir /playbooks

COPY ansible.cfg /etc/ansible/ansible.cfg
COPY group_vars /etc/ansible/group_vars
COPY hosts /etc/ansible/hosts
COPY ssh-config /root/.ssh/config
COPY bootstrap.sh /bootstrap.sh

VOLUME /playbooks

WORKDIR /playbooks

ENTRYPOINT [ "/bootstrap.sh" ]
