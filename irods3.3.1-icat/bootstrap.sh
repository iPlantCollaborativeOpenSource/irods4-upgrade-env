#!/usr/bin/env bash


iRODS/irodsctl start

if [ $# -ge 1 ]
then
    PASSWORD="$1"

    iadmin moduser rods password "$PASSWORD"
    echo "$PASSWORD" | iinit
fi

bash
