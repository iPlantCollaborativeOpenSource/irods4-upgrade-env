#!/usr/bin/env bash


function gen-resp ()
{
    echo "no"                       # no advanced settings
    echo "yes"                      # build a server
    echo "yes"                      # ICAT-enabled
    echo "tempZone"                 # the zone
    echo "rods"                     # main account
    echo "rods"                     # default password
    echo "yes"                      # download postgresql
    echo "/home/irods"              # postgresql parent directory
    echo "irods"                    # database user
    echo "password"                 # database password
    echo "postgresql-9.3.2.tar.gz"  # postgresql version
    echo "unixODBC-2.2.12.tar.gz"   # ODBC version
    echo "no"                       # no GSI
    echo "no"                       # no Kerberos
    echo "no"                       # no NCCS Auditing extensions
    echo "yes"                      # save configuration
    echo "yes"                      # start build
}


(cd iRODS && gen-resp | ./irodssetup)
iRODS/irodsctl stop
sed -i 's/^irodsHost.*/irodsHost localhost/' .irods/.irodsEnv
