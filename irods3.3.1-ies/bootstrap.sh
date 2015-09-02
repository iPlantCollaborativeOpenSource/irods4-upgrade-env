#!/bin/sh

if [ -z "$DBMS_NAME" ]
then
  echo "An irods-dbms container needs to be linked to 'dbms'" 1>&2
  exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]
then
  echo "The environment variable POSTGRES_PASSWORD wasn't set" 1>&2
  exit 1
fi

if [ -z "$POSTGRES_USER" ]
then
  POSTGRES_USER=irods
fi

if [ -z "$ADMIN_USER" ]
then
  ADMIN_USER=rods
fi

if [ -z "$ADMIN_PASSWORD" ]
then
  ADMIN_PASSWORD=rods
fi

if [ -z "$ZONE" ]
then
  ZONE=tempZone
fi


export PGPASSWORD="$POSTGRES_PASSWORD"


function setup_irods ()
{
  su - irods <<EOS
    cd /home/irods/iRODS 
    yes | ./irodssetup
EOS
}


# Start UUID generation daemon
uuidd

# Create aegis resource vaults
mkdir /home/irods/aegisVault/UA1 /home/irods/aegisVault/ASU1
chown -R irods:irods /home/irods/aegisVault

# Configure the bisque script
sed --in-place \
    "{ 
       s|^BISQUE_HOST=.*\$|BISQUE_HOST='http://$BISQUE_HOST'|
       s|^BISQUE_ADMIN_PASS=.*\$|BISQUE_ADMIN_PASS='$BISQUE_PASSWORD'|
       s|^IRODS_HOST=.*\$|IRODS_HOST='irods://ies'|
     }" \
    /home/irods/iRODS/server/bin/cmd/insert2bisque.py 

# Configure the rules
sed --in-place \
    "{
       s/^ipc_AMQP_HOST .*\$/ipc_AMQP_HOST = $AMQP_HOST/
       s/^ipc_AMQP_PORT .*\$/ipc_AMQP_PORT = $AMQP_PORT/
       s/^ipc_AMQP_USER .*\$/ipc_AMQP_USER = $AMQP_USER/
       s/^ipc_AMQP_PASSWORD .*\$/ipc_AMQP_PASSWORD = $AMQP_PASSWORD/
       s/^ipc_RODSADMIN .*\$/ipc_RODSADMIN = $ADMIN_USER/
     }" \
    /home/irods/iRODS/server/config/reConfigs/ipc-env-prod.re

# Create the build configuration
cat >/home/irods/iRODS/config/irods.config <<-EOS  
  # Database configuration

  \$DATABASE_TYPE = 'postgres';
  \$DATABASE_ODBC_TYPE = 'unix';
  \$DATABASE_EXCLUSIVE_TO_IRODS = '0';
  \$DATABASE_HOME = '/usr/pgsql-9.0';
  \$DATABASE_LIB = '';

  \$DATABASE_HOST = 'dbms';
  \$DATABASE_PORT = '5432';
  \$DATABASE_ADMIN_PASSWORD = '$POSTGRES_PASSWORD';
  \$DATABASE_ADMIN_NAME = '$POSTGRES_USER';
 
  # iRODS configuration
 
  \$IRODS_HOME = '/home/irods/iRODS';
  \$IRODS_PORT = '1247';
  \$SVR_PORT_RANGE_START = '20000';
  \$SVR_PORT_RANGE_END = '20399';
  \$IRODS_ADMIN_NAME = '$ADMIN_USER';
  \$IRODS_ADMIN_PASSWORD = '$ADMIN_PASSWORD';
  \$IRODS_ICAT_HOST = '';
  
  \$DB_NAME = 'ICAT';
  \$RESOURCE_NAME = 'demoResc';
  \$RESOURCE_DIR = '/home/irods/iRODS/Vault';
  \$ZONE_NAME = '$ZONE';
  \$DB_KEY = '123';
  
  \$GSI_AUTH = '0';
  \$GLOBUS_LOCATION = '';
  \$GSI_INSTALL_TYPE = '';
  
  \$KRB_AUTH = '0';
  \$KRB_LOCATION = '';
  
  # NCCS Audit Extensions
  
  \$AUDIT_EXT = '0';
  
  # UNICODE
  
  \$UNICODE = '0';
  
  return 1;
EOS

chown irods:irods /home/irods/iRODS/config/irods.config

# Wait for the DBMS to be ready
while true
do
  psql --list --quiet --host dbms postgres $POSTGRES_USER

  if [ $? -eq 0 ]
  then
    break
  fi

  sleep 1
done

setup_irods

# The iRODS server may not have started, try again
if [ $? -ne 0 ]
then
  setup_irods
fi

# Add icommands to PATH
su - irods \
    --command="echo 'export PATH=\$PATH:\$HOME/iRODS/clients/icommands/bin' >> /home/irods/.bashrc"

# configure custom indices
psql --host dbms ICAT $POSTGRES_USER <<EOSQL
  CREATE INDEX idx_coll_main_coll_type ON r_coll_main (coll_type);
  CREATE INDEX idx_coll_main_parent_coll_name ON r_coll_main (parent_coll_name);
  CREATE INDEX idx_objt_access_access_type_id ON r_objt_access (access_type_id);
  CREATE INDEX idx_objt_access_user_id ON r_objt_access (user_id);
  CREATE INDEX idx_tokn_main_token_namespace ON r_tokn_main (token_namespace);
  CREATE INDEX idx_user_main_user_type_name ON r_user_main (user_type_name);
  CREATE INDEX idx_user_password_user_id ON r_user_password (user_id);
EOSQL

# initialisd the specific queries, add the iPlant resources and resource groups, and give the 
# rodsadmin group ownership of everything
su - irods <<EOS
  /home/irods/init-specific-queries.sh
  iadmin atrg iplantRG demoResc
  iadmin mkresc aegisUA1Res 'unix file system' archive ies /home/irods/aegisVault/UA1
  iadmin mkresc aegisASU1Res 'unix file system' archive ies /home/irods/aegisVault/ASU1
  iadmin atrg aegisRG aegisASU1Res
  ichmod -r admin:own rodsadmin /

  colls=\$(psql --tuples-only \
                --host=dbms \
                --dbname=ICAT \
                --username=$POSTGRES_USER \
                --command='SELECT coll_name FROM r_coll_main')
  
  for coll in \$colls
  do
    imeta set -c \$coll ipc_UUID \$(uuidgen -t)
  done
EOS

echo ready

bash
