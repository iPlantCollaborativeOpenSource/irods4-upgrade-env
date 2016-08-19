#! /bin/bash


# Configure the bisque script
sed "{  
       s/BISQUE_ADMIN_PASS/$BISQUE_SERVICE_PASSWORD/g
       s/BISQUE_HOST/$BISQUE_HOST/g
     }" \
    /bisque_config.tmpl \
    > /etc/bisque/bisque_config

chown irods:irods /etc/bisque/bisque_config

# Create the build configuration
cat >/home/irods/iRODS/config/irods.config <<-EOS  
  # Database configuration

  \$DATABASE_TYPE = 'postgres';
  \$DATABASE_ODBC_TYPE = 'system';
  \$DATABASE_EXCLUSIVE_TO_IRODS = '0';
  \$DATABASE_HOME = '/usr/pgsql-9.3';
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
                      
  \$UNICODE = '1';
                        
  return 1;
EOS

chown irods:irods /home/irods/iRODS/config/irods.config

# Wait for the DBMS to be ready
export PGPASSWORD="$POSTGRES_PASSWORD"

until psql --list --quiet --host dbms postgres "$POSTGRES_USER" >/dev/null 2>&1
do
  sleep 1
done

