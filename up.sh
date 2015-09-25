#! /bin/bash

# This scripts brings up the iRODS grid,


source env.properties


container_for()
{
  service=$1

  echo ${PROJECT_NAME}_${service}_1
}


dbms_psql() 
{      
  docker exec --user postgres $(container_for dbms) psql "$@"
}


query_icat() 
{
  dbms_psql "--command=$1" ICAT
}


wait_for_service() 
{
  service=$1
  port=$2

  container=$(container_for $service)

  echo waiting for service on $service

  until $(docker exec --interactive $container bash -c "exec <>/dev/tcp/localhost/$port" \
          2>/dev/null) 
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
  wait_for_service dbms 5432

  echo waiting for ICAT database

  until $(dbms_psql --list | grep --silent ICAT)
  do
    sleep 1
  done

  add_icat_reader icat_reader password 100
  add_icat_reader icat_reader_mirrors password 250
}


docker-compose --project-name $PROJECT_NAME up -d --no-recreate ies
prepare_dbms

wait_for_service ies 1247

for service in hades lucy snoopy
do
  docker exec $(container_for $service) touch /IES_UP
done
