# irods4-upgrade-env
A collection of docker containers that mimic our production environment intended to test our iRODS 4
upgrade process 

# Notes

Because of the need for bidirection communication between the IES and the resource server,
containers need to be able to talk to each through IP ports on the docker0 interface. To allow this,
make sure your firewall allows communication between ports on the docker0 interface.
