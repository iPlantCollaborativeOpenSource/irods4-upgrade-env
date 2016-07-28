FROM williamyeh/ansible:ubuntu14.04

RUN sed --in-place 's/^#allow_world_readable_tmpfiles .*/allow_world_readable_tmpfiles = True/' \
                   /etc/ansible/ansible.cfg && \
    mkdir --parents /root/.ssh && \
    chmod go= /root/.ssh && \
    mkdir /playbooks

COPY hosts /etc/ansible/hosts
COPY ssh-config /root/.ssh/config

VOLUME /playbooks
WORKDIR /playbooks

ENTRYPOINT [ "bash" ]
