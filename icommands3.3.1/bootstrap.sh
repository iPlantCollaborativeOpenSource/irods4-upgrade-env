#!/bin/bash
#
# The arguments are a list of resources to wait for. The script will not start the bash shell until
# all of the listed resources are registered with icat.


if [ -z "$ICAT_NAME" ]
then
    export irodsHost=localhost
else
    export irodsHost=icat
fi

if [ -z "$irodsPort" ]
then
    export irodsPort=1247
fi

if [ -z "$irodsUserName" ]
then
    export irodsUserName=rods
fi

if [ -z "$irodsZone" ]
then
    export irodsZone=tempZone
fi

if [ -z "$RODS_PASSWORD" ]
then
    RODS_PASSWORD=rods
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

echo "$RODS_PASSWORD" | iinit

for rs in $@
do
    while [ "$(iadmin lr $rs)" == "No rows found" ]
    do
        sleep 1
    done
done

bash