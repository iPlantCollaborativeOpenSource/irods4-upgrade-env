#! /bin/bash

if [ -z "$ICAT_NAME" ]
then
  echo "An irods4.0.3-icat container needs to be linked to 'icat'."
  exit 1
fi

if [ -z "$RODS_PASSWORD" ]
then
  echo "The environment variable RODS_PASSWORD is required."
  exit 1
fi


function genresp ()
{
    echo "icat"
    echo "1247"
    echo "rods"
    echo "tempZone"
    echo "$RODS_PASSWORD"
}


while true
do
    echo "$RODS_PASSWORD" \
        | irodsHost=icat irodsPort=1247 irodsUserName=rods irodsZone=tempZone imiscsvrinfo

    if [ $? -eq 0 ]
    then
        break
    fi

    sleep 1
done

genresp | iinit
bash