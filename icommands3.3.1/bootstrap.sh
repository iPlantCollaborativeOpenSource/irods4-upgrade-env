#!/bin/bash
#
# The arguments are a list of resources to wait for. The script will not start the bash shell until
# all of the listed resources are registered with ies.


export irodsHost=ies
export irodsPort=1247
export irodsZone=$ZONE

if [ $# -ge 1 ]
then
  export irodsUserName=$1
else
  export irodsUserName=$ADMIN_USER
fi

until $(imiscsvrinfo >/dev/null)
do
  sleep 1
done

bash
