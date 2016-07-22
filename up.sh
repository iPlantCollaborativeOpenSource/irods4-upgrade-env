#! /bin/bash

# This scripts brings up the iRODS grid,


source env.properties


container_for()
{
  local service="$1"

  printf '%s_%s_1' "$PROJECT_NAME" "$service"
}


dbms_psql() 
{      
  docker exec --user postgres $(container_for dbms) psql "$@"
}


query_icat() 
{
  local cmd="$1"

  dbms_psql --command="$cmd" ICAT
}


wait_for_service() 
{
  local service="$1"
  local port="$2"

  local container=$(container_for "$service")

  printf 'waiting for service on %s\n' "$service"

  until docker exec --interactive "$container" bash -c "exec <>/dev/tcp/localhost/'$port'" 
  do
    sleep 1
  done 2>/dev/null
}


add_icat_reader()
{
  local user="$1"
  local password="$2"
  local connLimit="$3"

  query_icat "CREATE USER $user WITH CONNECTION LIMIT $connLimit PASSWORD '$password'" >/dev/null
  query_icat "GRANT SELECT ON ALL TABLES IN SCHEMA public TO $user" >/dev/null
}


prepare_dbms()
{
  wait_for_service dbms 5432

  printf 'waiting for ICAT database\n'

  until dbms_psql --list 2>/dev/null | grep --silent ICAT 
  do
    sleep 1
  done

  add_icat_reader icat_reader password 100
  add_icat_reader icat_reader_mirrors password 250
}


start_resources()
{
  local services="$@"

  for service in $services
  do
    docker exec $(container_for "$service") touch /IES_UP
  done

  for service in $services
  do
    wait_for_service "$service" 1247
  done
}
 

docker-compose --project-name "$PROJECT_NAME" up -d --no-recreate ies
prepare_dbms
wait_for_service ies 1247

docker-compose --project-name "$PROJECT_NAME" \
        up -d --no-recreate aegisasu1 aegisua1 hades lucy snoopy

start_resources aegisasu1 aegisua1 hades lucy snoopy

docker exec --interactive --user irods $(container_for ies) bash <<EOS
  printf 'contents' > /home/irods/test-file

  iadmin atg rodsadmin ipc_admin

  for resc in aegisASU1Res hadesRes lucyRes snoopyRes
  do
    printf 'waiting for resource %s\n' "\$resc"
    until \$(ilsresc "\$resc" >/dev/null)
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

  for i in \$(cat <(seq 2) <(echo ☠))
  do
    user=user-"\$i"
    printf 'creating %s and giving data\n' "\$user"
    iadmin mkuser "\$user" rodsuser
    iadmin moduser "\$user" password password

    clientUserName="\$user" imkdir /iplant/home/"\$user"/coll
    clientUserName="\$user" imkdir /iplant/home/"\$user"/coll-☠
    clientUserName="\$user" imkdir /iplant/home/"\$user"/nested
    clientUserName="\$user" imkdir /iplant/home/"\$user"/nested/coll-1
    clientUserName="\$user" imkdir /iplant/home/"\$user"/nested/coll-2

    clientUserName="\$user" iput /home/irods/test-file /iplant/home/"\$user"/file-☠

    for f in \$(seq 3)
    do
      clientUserName="\$user" \\
      iput /home/irods/test-file /iplant/home/"\$user"/nested/coll-2/file-"\$f"
    done
 
    clientUserName="\$user" iput -R hadesRes /home/irods/test-file /iplant/home/"\$user"/hades-file
  done

  rm --force /home/irods/test-file
EOS

