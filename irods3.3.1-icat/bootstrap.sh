#!/usr/bin/env bash


sudo -H -u irods /home/irods/iRODS/irodsctl start

if [ $# -ge 1 ]
then
    PASSWORD="$1"

    sudo -H -u irods \
        /home/irods/iRODS/clients/icommands/bin/iadmin moduser rods password "$PASSWORD"
fi

bash
