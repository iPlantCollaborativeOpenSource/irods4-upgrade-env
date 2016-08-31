#! /bin/bash

if [ ! -f id_rsa -o ! -f id_rsa.pub ]
then
  ssh-keygen -f id_rsa -N ''
fi

readonly IRODS4UpgradeDir="$(dirname '$0')"/ansible/ds-ansible/irods4-upgrade

readonly SetAVUPluginDir="$IRODS4UpgradeDir"/irods-setavu-plugin
if [ -e "$SetAVUPluginDir" ]
then
  (cd "$SetAVUPluginDir" && git pull)
else  
  git clone https://github.com/iPlantCollaborativeOpenSource/irods-setavu-plugin.git \
      "$(dirname '$0')"/ansible/ds-ansible/irods4-upgrade/irods-setavu-plugin
fi
(cd "$SetAVUPluginDir" && ./build.sh)

(cd "$IRODS4UpgradeDir"/irods-netcdf-plugin && ./build.sh)

docker-compose --project-name irods build base
docker-compose --project-name irods build server
docker-compose --project-name irods build
