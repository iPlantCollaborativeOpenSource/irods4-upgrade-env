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


start_resources()
{
  services="$@"

  for service in $services
  do
    docker exec $(container_for $service) touch /IES_UP
  done

  for service in $services
  do
    wait_for_service $service 1247
  done
}
 

docker-compose --project-name $PROJECT_NAME up -d --no-recreate ies
prepare_dbms
wait_for_service ies 1247
start_resources aegisasu1 aegisua1 hades lucy snoopy

docker exec --interactive --user irods $(container_for ies) bash <<EOS
  echo "contents" > /home/irods/test-file

  iadmin atg rodsadmin ipc_admin

  for resc in aegisASU1Res lucyRes snoopyRes
  do
    echo waiting for resource \$resc
    until \$(ilsresc \$resc >/dev/null)
    do
      sleep 1
    done
  done

  iadmin atrg iplantRG lucyRes
  iadmin atrg iplantRG snoopyRes
  iadmin atrg aegisRG aegisASU1Res
  iadmin rmresc demoResc

  imkdir /iplant/home/shared/aegis
  iput /home/irods/test-file /iplant/home/shared/aegis/test-file

  for i in \$(cat <(seq 10) <(echo ☠))
  do
    user=user-\$i
    echo creating \$user and giving data
    iadmin mkuser \$user rodsuser
    iadmin moduser \$user password password

    clientUserName=\$user imkdir /iplant/home/\${user}/coll
    clientUserName=\$user imkdir /iplant/home/\${user}/coll-☠
    clientUserName=\$user imkdir /iplant/home/\${user}/nested
    clientUserName=\$user imkdir /iplant/home/\${user}/nested/coll-1
    clientUserName=\$user imkdir /iplant/home/\${user}/nested/coll-2

    clientUserName=\$user iput /home/irods/test-file /iplant/home/\${user}/file-☠

    for f in \$(seq 100)
    do
      clientUserName=\$user iput /home/irods/test-file /iplant/home/\${user}/nested/coll-2/file-\$f
    done
 
    clientUserName=\$user iput -R hadesRes /home/irods/test-file /iplant/home/\${user}/hades-file
  done

  rm --force /home/irods/test-file
EOS


