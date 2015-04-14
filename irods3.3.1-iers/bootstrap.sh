#!/bin/sh

if [ -z "$DB_NAME" ]
then
    echo "An icat-db container needs to be linked to 'db'" 1>&2
    exit 1
fi

if [ -z "$DB_PASSWORD" ]
then
    echo "The environment variable DB_PASSWORD wasn't set" 1>&2
    exit 1
fi

if [ -z "$DB_USER" ]
then
    DB_USER=irods
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
    echo "\$DATABASE_HOST = 'db';"
    echo "\$DATABASE_PORT = '5432';"
    echo "\$DATABASE_ADMIN_PASSWORD = '$DB_PASSWORD';"
    echo "\$DATABASE_ADMIN_NAME = '$DB_USER';"
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
    sudo -H -u irods sh -c "cd /home/irods/iRODS; yes | ./irodssetup"
}


mk_irods_config > /home/irods/iRODS/config/irods.config
chown irods:irods /home/irods/iRODS/config/irods.config

while true
do
    PGPASSWORD=$DB_PASSWORD psql --list --quiet --host db postgres $DB_USER

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

tail -f /home/irods/iRODS/server/log/rodsLog.*
