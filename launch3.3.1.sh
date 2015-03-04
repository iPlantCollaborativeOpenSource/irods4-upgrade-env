#!/bin/bash

./stop.sh >/dev/null 2>/dev/null

docker run --interactive --tty \
           --env irodsHost=irods-2.iplantcollaborative.org --env irodsZone=iplant --name icommands \
           icommands3.3.1

./stop.sh