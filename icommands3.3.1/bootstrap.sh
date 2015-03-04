#!/bin/bash

if [ -z "$irodsHost" ]
then
   export irodsHost=localhost
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


bash