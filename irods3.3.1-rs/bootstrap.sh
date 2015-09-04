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


function setup_irods ()
{
su - irods <<EOS
    cd /home/irods/iRODS 
    yes | ./irodssetup
EOS
}


# Add docker host IP address to /etc/hosts and identify it as ies.
iesIP=$(ip route | awk '/default/ { print $3 }')
echo "$iesIP	ies" >> /etc/hosts

# Ensure Vault is owned by irods
chown irods:irods /home/irods/iRODS/Vault

cat > /home/irods/iRODS/config/irods.config <<-EOS
  # Database configuration
   
  \$DATABASE_TYPE = '';
  \$DATABASE_ODBC_TYPE = '';
  \$DATABASE_EXCLUSIVE_TO_IRODS = '0';
  \$DATABASE_HOME = '';
  \$DATABASE_LIB = '';
   
  \$DATABASE_HOST = '';
  \$DATABASE_PORT = '';
  \$DATABASE_ADMIN_PASSWORD = '';
  \$DATABASE_ADMIN_NAME = '';
   
  # iRODS configuration
  
  \$IRODS_HOME = '/home/irods/iRODS';
  \$IRODS_PORT = '1247';
  \$SVR_PORT_RANGE_START = '20000';
  \$SVR_PORT_RANGE_END = '20399';
  \$IRODS_ADMIN_NAME = '$ADMIN_USER';
  \$IRODS_ADMIN_PASSWORD = '$ADMIN_PASSWORD';
  \$IRODS_ICAT_HOST = 'ies';
    
  \$DB_NAME = 'ICAT';
  \$RESOURCE_NAME = '$RESOURCE_NAME';
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
  
  \$UNICODE = '1';

  return 1;
EOS

chown irods:irods /home/irods/iRODS/config/irods.config

# Need to do this as irods to ensure the default .bashrc has been created
su - irods <<EOS
echo '
export PATH=\$PATH:\$HOME/iRODS/clients/icommands/bin
export LD_LIBRARY_PATH=/usr/local/lib' \
    >> /home/irods/.bashrc
EOS

setup_irods

# This probably failed because ies hasn't finished starting. The icommands have been built now, so
# we can use imiscsvrinfo to detect when ies has started.
su - irods <<EOS
  export irodsHost=ies
  export irodsPort=1247

  until \$(imiscsvrinfo >/dev/null)
  do
    sleep 1
  done
EOS

setup_irods

# The iRODS server may not have started, try again
if [ $? -ne 0 ]
then
    setup_irods
fi

bash
