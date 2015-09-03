#!/bin/bash

if [ -z "$RESOURCE_NAME" ]
then
    echo "The RESOURCE_NAME environment variables needs to be set" 1>&2
    exit 1
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
    echo "\$DATABASE_TYPE = '';"
    echo "\$DATABASE_ODBC_TYPE = '';"
    echo "\$DATABASE_EXCLUSIVE_TO_IRODS = '0';"
    echo "\$DATABASE_HOME = '';"
    echo "\$DATABASE_LIB = '';"
    echo ""
    echo "\$DATABASE_HOST = '';"
    echo "\$DATABASE_PORT = '';"
    echo "\$DATABASE_ADMIN_PASSWORD = '';"
    echo "\$DATABASE_ADMIN_NAME = '';"
    echo ""
    echo "# iRODS configuration"
    echo ""
    echo "\$IRODS_HOME = '/home/irods/iRODS';"
    echo "\$IRODS_PORT = '1247';"
    echo "\$SVR_PORT_RANGE_START = '20000';"
    echo "\$SVR_PORT_RANGE_END = '20399';"
    echo "\$IRODS_ADMIN_NAME = '$ADMIN_USER';"
    echo "\$IRODS_ADMIN_PASSWORD = '$ADMIN_PASSWORD';"
    echo "\$IRODS_ICAT_HOST = 'ies';"
    echo ""
    echo "\$DB_NAME = 'ICAT';"
    echo "\$RESOURCE_NAME = '$RESOURCE_NAME';"
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


# Add docker host IP address to /etc/hosts and identify it as ies.
iesIP=$(ip route | awk '/default/ { print $3 }')
echo "$iesIP	ies" >> /etc/hosts

# Ensure Vault is owned by irods
chown irods:irods /home/irods/iRODS/Vault

mk_irods_config > /home/irods/iRODS/config/irods.config
chown irods:irods /home/irods/iRODS/config/irods.config
su - irods --command="echo 'export LD_LIBRARY_PATH=/usr/local/lib' >> /home/irods/.bashrc"

setup_irods

# This probably failed because ies hasn't finished starting. The icommands have been built now, so
# we can use imiscsvrinfo to detect when ies has started.
sudo -H -u irods sh -c '
    export irodsHost=ies;
    export irodsPort=1247;
    while true
    do
        /home/irods/iRODS/clients/icommands/bin/imiscsvrinfo
        if [ $? -eq 0 ]
        then
            break
        fi
        sleep 1
    done'

setup_irods

# The iRODS server may not have started, try again
if [ $? -ne 0 ]
then
    setup_irods
fi

bash
