# irods4-upgrade-env

This is a collection of docker containers that mimic The iPlant Collaborative's production iRODS 
grid. It is intended to be the grid used to test The iPlant Colalborative's process for upgrading
production grid to iRODS 4.

## iPlant Collaborative's current production deployment of iRODS

The iPlant Collaborative's production iRODS grid uses a patched version of iRODS 3.3.1. It consists 
of an IES that isn't also a resource server. The ICAT database is hosted on a dedicated postgres 
DBMS running on a separate server. There are currently 19 resource servers, spread across 5 
institutions.

The iPlant Collaborative's production iRODS zone, `iplant`, consists of 20 resources and 3 resource
groups. The default resource group, `iplantRG`, acts as the default resource. It consists of a pool 
of resources randomly chosen for new data. Currently, the pool consists of the resources `lucyRes` 
and `pennyRes`. The `aegisRG` group contains remote replicas of data written to 
`/iplant/home/shared/aegis` collection. It consists of the resources `aegisASU1Res` and 
`aegisNAU1Res`. A resource is chosen randomly for new data. The `iclimateRG` resource group contains 
only the `aegisUA1Res` resource.

There is a largely, one-to-one mapping between resource servers and resources with one exception. 
The server `apollo` hosts both the `apolloRes` and `homeResc` resources. We plan to move the
files in `homeResc` to another resource and delete `homeResc` before the migration, so this 
shouldn't need to be considered in the test grid. 

The `aegisUA1Res` is special. Besides being the sole member of the `iclimateRG` resource group, all
new data destinated for the `/iplant/home/shared/aegis` collection. This is the data that is 
replicated to the `aegisRG` group.

The production zone depends on the existence of an AMQP message broker. This broker is a RabbitMQ 
broker service running on its own server. The zone uses rules to push messages to the broker. The
exchange is configured by a script deployed with iRODS and called by the rules.

## The test grid

The test grid consists of nine containers.

* `irods_amqp_1` holds the RabbitMQ broker service
* `irods_dbms_1` holds the PostgreSQL DBMS
* `irods_ies_1` holds the iRODS IES service
* `irods_lucy_1` and `irods_snoopy_1` hold iRODS resource server services for holding the resources
   that compose the representation of `iplantRG` resource group.
* `irods_aegisua1_1` holds a resource server service for holding a representation of the 
   `aegisUA1Res` resource. 
* `irods_aegisasu1_1` and holds a resource server service for holding a resource that composes the
   representation of the `aegisRG` group.
   that compose the representation of `iplantRG` resource group.
* `irods_hades_1` holds an iRODS resource server service for holding a representation of an 
   ungrouped production resource.
* `irods_data_1` is a data container backing the DBMS and all resource servers.

There is a container, `irods_icommands_run_1`, that acts as a client for interacting with the test 
grid.

Because one random resource group is already represented, the representation of the `aegisRG` only
contains one resource.

Because `iclimateRG` is so simple, it is not included in the test grid.

# Usage

This collection of container is intented to be managed by docker compose. However, because of the 
intricacies of the interactions between the containers during start up, docker compose needs a
little help to orchastrate start up.

Before running the container collection, the containers need to be built. Use the `build.sh` script.


```
? ./build.sh
```


When the build is finished, `docker images` should show the following.

```
? docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
irods_icommands     latest              a50b673757ed        2 minutes ago       582.9 MB
irods_ies           latest              ccae523913a9        2 minutes ago       878.2 MB
irods_dbms          latest              5a1ec381ac94        5 minutes ago       264.3 MB
irods_rs            latest              19f76bb08bc9        5 minutes ago       709.7 MB
irods_server        latest              9adc848ce02b        5 minutes ago       709.7 MB
irods_base          latest              61d6c5903260        6 minutes ago       523.7 MB
postgres            9.3                 4489c15e5c90        2 weeks ago         264.3 MB
centos              6                   72703a0520b7        3 weeks ago         190.6 MB
```

To bring up the collection of containers, use the `up.sh` script.

```
? ./up.sh
```

Once the containers have been brought, you should see the following processes running.

```
? docker-compose -p irods ps
      Name                     Command               State            Ports          
------------------------------------------------------------------------------------
irods_aegisasu1_1   /bootstrap.sh                    Up       1247/tcp               
irods_aegisua1_1    /bootstrap.sh                    Up       1247/tcp               
irods_amqp_1        /docker-entrypoint.sh rabb ...   Up       15672/tcp, 5672/tcp    
irods_data_1        /true                            Exit 0                          
irods_dbms_1        /docker-entrypoint.sh postgres   Up       5432/tcp               
irods_hades_1       /bootstrap.sh                    Up       1247/tcp               
irods_ies_1         /bootstrap.sh                    Up       0.0.0.0:1247->1247/tcp 
irods_lucy_1        /bootstrap.sh                    Up       1247/tcp               
irods_snoopy_1      /bootstrap.sh                    Up       1247/tcp   
```

The IES can be connected to via `localhost` on port `1247`. The admin user is `ipc_admin` and has a
password of `password`.  

There is also an icommands container that can be launched with the `client.sh` script. Optionally,
the name of the user to connect as can be provided as the first argument. If no argument is 
provided, the script will attempt to connect with the admin account, `ipc_admin`. 

```
./client.sh
```

To bring down the collection of containers, use the `down.sh` script.

```
./down.sh
```


# Notes

Because of the need for bidirection communication between the IES and the resource server,
containers need to be able to talk to each through IP ports on the `docker0` interface. To allow 
this, make sure your firewall allows communication between ports on the `docker0` interface.
