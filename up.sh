#! /bin/bash

# This scripts brings up the iRODS grid,


source env.properties

readonly DBMS_CONTAINER=${PROJECT_NAME}_dbms_1


dbms_psql () {
  eval "docker exec --user postgres $DBMS_CONTAINER psql $@"
}


query_icat () 
{
  cmd="$1"
  echo $1
  dbms_psql --command=\"$cmd\" ICAT
}


wait_for_postgres () 
{
  echo waiting for postgres

  until $(docker exec $DBMS_CONTAINER netstat -4 --listening --numeric --tcp | grep --silent 5432) 
  do
    sleep 1
  done
}


wait_for_icat ()
{
  echo waiting for ICAT database

  until $(dbms_psql --list | grep --silent ICAT)
  do
    sleep 1
  done
}


create_indices()
{
  for table in r_coll_main r_objt_access r_tokn_main r_user_main r_user_password
  do
    echo waiting for $table table

    until $(query_icat '\dt' | grep --silent $table)
    do
      sleep 1
    done
  done

  query_icat 'CREATE INDEX idx_coll_main_coll_type ON r_coll_main (coll_type)'
  query_icat 'CREATE INDEX idx_coll_main_parent_coll_name ON r_coll_main (parent_coll_name)'
  query_icat 'CREATE INDEX idx_objt_access_access_type_id ON r_objt_access (access_type_id)'
  query_icat 'CREATE INDEX idx_objt_access_user_id ON r_objt_access (user_id)'
  query_icat 'CREATE INDEX idx_tokn_main_token_namespace ON r_tokn_main (token_namespace)'
  query_icat 'CREATE INDEX idx_user_main_user_type_name ON r_user_main (user_type_name)'
  query_icat 'CREATE INDEX idx_user_password_user_id ON r_user_password (user_id)'
}


add_icat_reader()
{
  user=$1
  password=$2
  connLimit=$3

  query_icat "CREATE USER $user WITH CONNECTION LIMIT $connLimit PASSWORD '$password'"
  query_icat "GRANT SELECT ON ALL TABLES IN SCHEMA \"ICAT\" TO $user" 
}


docker-compose --project-name $PROJECT_NAME up -d --no-recreate ies
wait_for_postgres
wait_for_icat
add_icat_reader icat_reader password 100
add_icat_reader icat_reader_mirrors password 250
create_indices

