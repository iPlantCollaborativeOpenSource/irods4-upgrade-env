#! /bin/bash

# Add docker host IP address to /etc/hosts and identify it as ies.
iesIP=$(ip route | awk '/default/ { print $3 }')
echo "$iesIP  ies" >> /etc/hosts

# Ensure Vault is owned by irods
chown irods:irods /rsVault

# Create the build configuration
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
  \$RESOURCE_DIR = '/rsVault';
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

# Wait for IES to become available
until $(exec <>/dev/tcp/ies/1247)
do
  sleep 1
done

