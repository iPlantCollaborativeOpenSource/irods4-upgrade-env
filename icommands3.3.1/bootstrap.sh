#!/bin/bash

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
bash