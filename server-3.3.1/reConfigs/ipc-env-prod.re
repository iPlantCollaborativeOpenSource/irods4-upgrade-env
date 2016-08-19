# VERSION: 7
#
# The production environment rule customizations belong in this file.


ipc_AMQP_HOST = 'amqp'
ipc_AMQP_PORT = 5672
ipc_AMQP_USER = 'RABBITMQ_DEFAULT_USER'
ipc_AMQP_PASSWORD = 'RABBITMQ_DEFAULT_PASS'
ipc_AMQP_EPHEMERAL = false

ipc_IES_IP = 'IES_IP_ADDR'
ipc_RE_HOST = 'ies.irods_default'
ipc_RODSADMIN = 'ADMIN_USER'


acSetNumThreads {
  ON($rescName == "aegisASU1Res" && $clientAddr == ipc_IES_IP) { 
    msiSetNumThreads("default", "0", "default");
  }
}

acSetRescSchemeForCreate {
  msiSetDefaultResc("iplantRG","preferred");
  msiSetRescSortScheme("random");
}

acSetRescSchemeForRepl { msiSetDefaultResc("iplantRG","preferred"); }

