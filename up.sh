#! /bin/bash

# This scripts brings up the iRODS grid,


source env.properties


dc()
{
  docker-compose --project-name "$PROJECT_NAME" "$@"
}


dc-up()
{
  dc up -d --no-recreate "$@"
}


dbms_psql() 
{      
  dc exec --user postgres dbms psql "$@"
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

  printf 'waiting for service %s\n' "$service"

  until dc exec "$service" bash -c "exec <>/dev/tcp/localhost/'$port'"
  do
    sleep 1
  done >/dev/null 2>&1
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


dc-up dbms
dc-up ies
dc-up aegisasu1 aegisua1 hades lucy snoopy
prepare_dbms

dc exec ies bash -c "
  printf 'waiting for iRODS on ies\n'

  until [ -e /IRODS_READY ]
  do
    sleep 1
  done
"

dc exec --user irods ies bash -c "
  printf 'contents' > /home/irods/test-file

  for resc in aegisASU1Res hadesRes lucyRes snoopyRes
  do
    printf 'waiting for resource %s\n' \"\$resc\"
    until \$(ilsresc \"\$resc\" >/dev/null)
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
    user=user-\"\$i\"
    printf 'creating %s and giving data\n' \"\$user\"
    iadmin mkuser \"\$user\" rodsuser
    iadmin moduser \"\$user\" password password

    clientUserName=\"\$user\" imkdir /iplant/home/\"\$user\"/coll
    clientUserName=\"\$user\" imkdir /iplant/home/\"\$user\"/coll-☠
    clientUserName=\"\$user\" imkdir /iplant/home/\"\$user\"/nested
    clientUserName=\"\$user\" imkdir /iplant/home/\"\$user\"/nested/coll-1
    clientUserName=\"\$user\" imkdir /iplant/home/\"\$user\"/nested/coll-2

    clientUserName=\"\$user\" iput /home/irods/test-file /iplant/home/\"\$user\"/file-☠

    for f in \$(seq 3)
    do
      clientUserName=\"\$user\" \\
      iput /home/irods/test-file /iplant/home/\"\$user\"/nested/coll-2/file-\"\$f\"
    done
 
    clientUserName=\"\$user\" iput -R hadesRes /home/irods/test-file /iplant/home/\"\$user\"/hades-file
  done

  rm --force /home/irods/test-file
"

