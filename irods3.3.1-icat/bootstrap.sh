#!/usr/bin/env bash


iRODS/irodsctl start

iadmin modresc demoResc host $HOSTNAME

if [ $# -ge 1 ]
then
    PASSWORD="$1"

    iadmin moduser rods password "$PASSWORD"
    echo "$PASSWORD" | iinit
fi

bash
