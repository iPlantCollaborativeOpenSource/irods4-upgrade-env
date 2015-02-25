#! /bin/bash

RESC=$1
HOST=$2
ADDR=$3

echo "$ADDR $HOST" >> /etc/hosts
sudo -H -u irods iadmin modresc $RESC host $HOST
