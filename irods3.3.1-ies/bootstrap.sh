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


function mk_irods_config ()
{
  echo "# Database configuration"
  echo ""
  echo "\$DATABASE_TYPE = 'postgres';"
  echo "\$DATABASE_ODBC_TYPE = 'unix';"
  echo "\$DATABASE_EXCLUSIVE_TO_IRODS = '0';"
  echo "\$DATABASE_HOME = '/usr/pgsql-9.0';"
  echo "\$DATABASE_LIB = '';"
  echo ""
  echo "\$DATABASE_HOST = 'dbms';"
  echo "\$DATABASE_PORT = '5432';"
  echo "\$DATABASE_ADMIN_PASSWORD = '$POSTGRES_PASSWORD';"
  echo "\$DATABASE_ADMIN_NAME = '$POSTGRES_USER';"
  echo ""
  echo "# iRODS configuration"
  echo ""
  echo "\$IRODS_HOME = '/home/irods/iRODS';"
  echo "\$IRODS_PORT = '1247';"
  echo "\$SVR_PORT_RANGE_START = '20000';"
  echo "\$SVR_PORT_RANGE_END = '20399';"
  echo "\$IRODS_ADMIN_NAME = '$ADMIN_USER';"
  echo "\$IRODS_ADMIN_PASSWORD = '$ADMIN_PASSWORD';"
  echo "\$IRODS_ICAT_HOST = '';"
  echo ""
  echo "\$DB_NAME = 'ICAT';"
  echo "\$RESOURCE_NAME = 'demoResc';"
  echo "\$RESOURCE_DIR = '/home/irods/iRODS/Vault';"
  echo "\$ZONE_NAME = '$ZONE';"
  echo "\$DB_KEY = '123';"
  echo ""
  echo "\$GSI_AUTH = '0';"
  echo "\$GLOBUS_LOCATION = '';"
  echo "\$GSI_INSTALL_TYPE = '';"
  echo ""
  echo "\$KRB_AUTH = '0';"
  echo "\$KRB_LOCATION = '';"
  echo ""
  echo "# NCCS Audit Extensions"
  echo ""
  echo "\$AUDIT_EXT = '0';"
  echo ""
  echo "# UNICODE"
  echo ""
  echo "\$UNICODE = '0';"
  echo ""
  echo "return 1;"
}


function setup_irods ()
{
  sudo -H -u irods bash -c "cd /home/irods/iRODS; yes | ./irodssetup"
}


mkdir /home/irods/aegisVault/UA1 /home/irods/aegisVault/ASU1
chown -R irods:irods /home/irods/aegisVault

sed --in-place \
    "{
       s|^BISQUE_HOST=.*\$|BISQUE_HOST='http://$BISQUE_HOST'|
       s|^BISQUE_ADMIN_PASS=.*\$|BISQUE_ADMIN_PASS='$BISQUE_PASSWORD'|
       s|^IRODS_HOST=.*\$|IRODS_HOST='irods://ies'|
     }" \
    /home/irods/iRODS/server/bin/cmd/insert2bisque.py 

sed --in-place \
    "{
       s/^ipc_AMQP_HOST .*\$/ipc_AMQP_HOST = $AMQP_HOST/
       s/^ipc_AMQP_PORT .*\$/ipc_AMQP_PORT = $AMQP_PORT/
       s/^ipc_AMQP_USER .*\$/ipc_AMQP_USER = $AMQP_USER/
       s/^ipc_AMQP_PASSWORD .*\$/ipc_AMQP_PASSWORD = $AMQP_PASSWORD/
       s/^ipc_RODSADMIN .*\$/ipc_RODSADMIN = $ADMIN_USER/
     }" \
    /home/irods/iRODS/server/config/reConfigs/ipc-env-prod.re

mk_irods_config > /home/irods/iRODS/config/irods.config
chown irods:irods /home/irods/iRODS/config/irods.config

while true
do
  PGPASSWORD=$POSTGRES_PASSWORD psql --list --quiet --host dbms postgres $POSTGRES_USER

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

# configure custom indices
PGPASSWORD=$POSTGRES_PASSWORD psql --host dbms ICAT $POSTGRES_USER <<-EOSQL
  CREATE INDEX idx_coll_main_coll_type ON r_coll_main (coll_type);
  CREATE INDEX idx_coll_main_parent_coll_name ON r_coll_main (parent_coll_name);
  CREATE INDEX idx_objt_access_access_type_id ON r_objt_access (access_type_id);
  CREATE INDEX idx_objt_access_user_id ON r_objt_access (user_id);
  CREATE INDEX idx_tokn_main_token_namespace ON r_tokn_main (token_namespace);
  CREATE INDEX idx_user_main_user_type_name ON r_user_main (user_type_name);
  CREATE INDEX idx_user_password_user_id ON r_user_password (user_id);
EOSQL

sudo -E -H -u irods bash -c \
    "echo 'export PATH=\$PATH:/home/irods/iRODS/clients/icommands/bin' >> /home/irods/.bashrc
     /home/irods/init-specific-queries.sh
     iadmin atrg iplantRG demoResc
     iadmin mkresc aegisUA1Res 'unix file system' archive ies /home/irods/aegisVault/UA1
     iadmin mkresc aegisASU1Res 'unix file system' archive ies /home/irods/aegisVault/ASU1
     iadmin atrg aegisRG aegisASU1Res"

bash
