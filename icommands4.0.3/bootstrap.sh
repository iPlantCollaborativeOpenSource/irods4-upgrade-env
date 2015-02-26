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


genresp | iinit

bash