#! /bin/bash

# Ensure Vault is owned by irods
chown irods:irods "$RESOURCE_DIR"

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
  \$IRODS_ICAT_HOST = 'irods_ies_1';
                                        
  \$DB_NAME = 'ICAT';
  \$RESOURCE_NAME = '$RESOURCE_NAME';
  \$RESOURCE_DIR = '$RESOURCE_DIR';
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
echo "Waiting for IES"

until [ -e /IES_UP ]
do
  sleep 1
done

rm --force /IES_UP

echo "IES is up"

