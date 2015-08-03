#!/bin/bash
#
# The arguments are a list of resources to wait for. The script will not start the bash shell until
# all of the listed resources are registered with ies.


if [ -z "$IES_NAME" ]
then
    export irodsHost=localhost
else
    export irodsHost=ies
fi

if [ -z "$irodsPort" ]
then
    export irodsPort=1247
fi

if [ -z "$ADMIN_USER" ]
then
    export irodsUserName=rods
else
    export irodsUserName=$ADMIN_USER
fi

if [ -z "$ZONE" ]
then
    export irodsZone=tempZone
else
    export irodsZone=$ZONE
fi

if [ -z "$ADMIN_PASSWORD" ]
then
    ADMIN_PASSWORD=rods
fi


while true
do
    imiscsvrinfo

    if [ $? -eq 0 ]
    then
        break
    fi

    sleep 1
done

echo "$ADMIN_PASSWORD" | iinit

if [ -n "$RESOURCE_NAME" ]
then
    while [ "$(iadmin lr $RESOURCE_NAME)" == "No rows found" ]
    do
        sleep 1
    done
fi

bash
