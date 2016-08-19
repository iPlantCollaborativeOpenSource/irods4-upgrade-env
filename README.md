# irods4-upgrade

Ansible scripts for upgrading CyVerse's iRODS grids

## Installation steps

1. Install requirements for running ansible

    sudo ansible-galaxy install -f -r requirements.yml

1. build the msiSetAVU microservice plugin

    git clone https://github.com/iPlantCollaborativeOpenSource/irods-setavu-plugin.git
    cd irods-setavu-plugin
    ./build.sh
    cd ..

1. build the NetCDF plugins

    cd irods-netcdf-plugin
    ./build.sh
    cd ..

1. Perform the upgrade

    ansible-playbook -K -i /path/to/inventory main.yml | ./pretty.sh

