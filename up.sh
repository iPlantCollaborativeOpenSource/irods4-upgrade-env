#! /bin/bash

# This scripts brings up the iRODS grid. 

readonly DBMS_CONTAINER=irods4upgradeenv_dbms_1


dbms_exec ()
{
  eval "docker exec --user postgres $DBMS_CONTAINER $@"
}


wait_for_dbms ()
{
  while ! dbms_exec psql --list 2> /dev/null >&2
  do
    sleep 1
  done
}


docker-compose up -d --no-recreate ies
wait_for_dbms
dbms_exec psql --command=\"CREATE USER icat_reader WITH PASSWORD \'password\'\"
