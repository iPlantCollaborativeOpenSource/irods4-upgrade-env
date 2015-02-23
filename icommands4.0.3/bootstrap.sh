#! /bin/bash

if [ -z "$ICAT_NAME" ]
then
  echo "An irods4.0.3-icat-centos5 container needs to be linked to 'icat'."
  exit 1
fi

if [ -z "$RODS_PASSWORD" ]
then
  echo "The environment variable RODS_PASSWORD is required."
  exit 1
fi

echo "icat"           >  iinit_responses
echo "1247"           >> iinit_responses
echo "rods"           >> iinit_responses
echo "tempZone"       >> iinit_responses
echo "$RODS_PASSWORD" >> iinit_responses

iinit < iinit_responses

if [ $? -eq 0 ]
then
  rm -f iinit_responses

  bash
fi
