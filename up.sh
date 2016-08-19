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


dc-up aegisasu1 aegisua1 hades lucy snoopy

for service in dbms ies aegisasu1 aegisua1 hades lucy snoopy
do
  dc exec "$service" bash -c "
    homeDir=\$(grep --regexp \"^\$SSH_USER\" /etc/passwd | cut --delimiter : --fields 6)
    sshDir=\"\$homeDir\"/.ssh
    mkdir --parents \"\$sshDir\"
    printf '%s' '$(cat id_rsa.pub)' > \"\$sshDir\"/authorized_keys
    chown --recursive \"\$SSH_USER\":\"\$SSH_USER\" \"\$sshDir\"
    chmod --recursive go= \"\$sshDir\"
  "
done

prepare_dbms

for service in ies aegisasu1 aegisua1 hades lucy snoopy
do
  printf 'waiting for iRODS on %s\n' "$service"

  dc exec "$service" bash -c "
    until [ -e /IRODS_READY ]
    do
      sleep 1
    done
  "
done

dc exec --user irods ies bash -c "
  # Create required service accounts
  iadmin mkuser '$DE_USER' rodsadmin
  iadmin moduser '$DE_USER' password '$DE_PASSWORD'

  iadmin mkuser '$BISQUE_USER' rodsuser
  iadmin moduser '$BISQUE_USER' password '$BISQUE_PASSWORD'

  iadmin mkuser '$COGE_USER' rodsuser
  iadmin moduser '$COGE_USER' password '$COGE_PASSWORD'

  imkdir /iplant/home/shared/aegis

  iadmin atrg iplantRG lucyRes
  iadmin atrg iplantRG snoopyRes
  iadmin atrg aegisRG aegisASU1Res
  iadmin atrg iclimateRG aegisUA1Res

  printf 'contents' > /home/irods/test-file

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
 
    clientUserName=\"\$user\" \\
      iput -R hadesRes /home/irods/test-file /iplant/home/\"\$user\"/hades-file
  done

  rm --force /home/irods/test-file
"

