#!/bin/bash

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
  \$SVR_PORT_RANGE_START = '';
  \$SVR_PORT_RANGE_END = '';
  \$IRODS_ADMIN_NAME = '';
  \$IRODS_ADMIN_PASSWORD = '';
  \$IRODS_ICAT_HOST = '';
   
  \$DB_NAME = '';
  \$RESOURCE_NAME = '';
  \$RESOURCE_DIR = '';
  \$ZONE_NAME = '';
  \$DB_KEY = '';
    
  \$GSI_AUTH = '0';
  \$GLOBUS_LOCATION = '';
  \$GSI_INSTALL_TYPE = '';
  
  \$KRB_AUTH = '0';
  \$KRB_LOCATION = '';
   
  # NCCS Audit Extensions
   
  \$AUDIT_EXT = '0';
  
  # UNICODE
  
  \$UNICODE = '';
  
  return 1;
EOS

chown irods:irods /home/irods/iRODS/config/irods.config

su --shell=/bin/bash - irods <<EOS 
  cd /home/irods/iRODS 
  yes | ./irodssetup
EOS
