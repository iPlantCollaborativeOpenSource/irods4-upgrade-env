#! /bin/bash

# This scripts brings up the iRODS grid,


source env.properties

readonly DBMS_CONTAINER=${PROJECT_NAME}_dbms_1
readonly IES_CONTAINER=${PROJECT_NAME}_ies_1


dbms_psql () 
{      
  docker exec --user postgres $DBMS_CONTAINER psql "$@"
}


query_icat () 
{
  dbms_psql "--command=$1" ICAT
}


wait_for_icat () 
{
  echo waiting for ICAT database

  until $(docker exec $DBMS_CONTAINER netstat -4 --listening --numeric --tcp | grep --silent 5432) 
  do
    sleep 1
  done

  until $(dbms_psql --list | grep --silent ICAT)
  do
    sleep 1
  done
}


add_icat_reader()
{
  user=$1
  password=$2
  connLimit=$3

  query_icat "CREATE USER $user WITH CONNECTION LIMIT $connLimit PASSWORD '$password'"
  query_icat "GRANT SELECT ON ALL TABLES IN SCHEMA public TO $user" 
}


prepare_dbms()
{
  wait_for_icat
  add_icat_reader icat_reader password 100
  add_icat_reader icat_reader_mirrors password 250
}


docker-compose --project-name $PROJECT_NAME up -d --no-recreate ies
prepare_dbms

