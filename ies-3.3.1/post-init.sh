#! /bin/bash

# configure custom indices
PGPASSWORD="$POSTGRES_PASSWORD" psql --host dbms ICAT "$POSTGRES_USER" <<EOSQL
  CREATE INDEX idx_coll_main_coll_type ON r_coll_main (coll_type);
  CREATE INDEX idx_coll_main_parent_coll_name ON r_coll_main (parent_coll_name);
  CREATE INDEX idx_objt_access_access_type_id ON r_objt_access (access_type_id);
  CREATE INDEX idx_objt_access_user_id ON r_objt_access (user_id);
  CREATE INDEX idx_tokn_main_token_namespace ON r_tokn_main (token_namespace);
  CREATE INDEX idx_user_main_user_type_name ON r_user_main (user_type_name);
  CREATE INDEX idx_user_password_user_id ON r_user_password (user_id);
EOSQL

su - irods <<EOS
  # Initial the specific queries
  /home/irods/init-specific-queries.sh

  iadmin atg rodsadmin ipc_admin

  # Give rodsadmin group ownership of everything
  ichmod -r admin:own rodsadmin /

  # Remove the default resource
  iadmin rmresc demoResc

  # Generate UUIDs for all collections
  colls=\$(psql --tuples-only \
                --host=dbms \
                --dbname=ICAT \
                --username="$POSTGRES_USER" \
                --command='SELECT coll_name FROM r_coll_main')
  
  for coll in \$colls
  do
    imeta set -c \$coll ipc_UUID \$(uuidgen -t)
  done

  iadmin mkuser anonymous rodsuser

  # Configure /home/shared collection
  imv '/$ZONE/home/public' '/$ZONE/home/shared'
  ichmod read public '/$ZONE/home' '/$ZONE/home/shared'
  imv '/$ZONE/trash/home/public' '/$ZONE/trash/home/shared'
  ichmod null public '/$ZONE/trash/home/shared'  
EOS

