# VERSION: 4
#
# The production environment rule customizations belong in this file.


acSetRescSchemeForCreate {
    msiSetDefaultResc("iplantRG","preferred");
    msiSetRescSortScheme("random");
}

acSetRescSchemeForRepl { msiSetDefaultResc("iplantRG","preferred"); }

ipc_AMQP_HOST = 
ipc_AMQP_PORT = 
ipc_AMQP_USER = 
ipc_AMQP_PASSWORD = 
ipc_AMQP_EPHEMERAL = false

ipc_RODSADMIN = 
ipc_RE_HOST = ies
