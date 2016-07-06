# VERSION: 7
#
# The production environment rule customizations belong in this file.


#ipc_AMQP_HOST = 'bugs.iplantcollaborative.org'
#ipc_AMQP_PORT = 31333
ipc_AMQP_HOST = 'ares.iplantcollaborative.org'
ipc_AMQP_PORT = 20400
ipc_AMQP_USER = 'ipc'
ipc_AMQP_PASSWORD = 'mostly810S'
ipc_AMQP_EPHEMERAL = false

ipc_IES_IP = '206.207.252.32'
ipc_RE_HOST = 'data.iplantcollaborative.org'
ipc_RODSADMIN = 'ipc_admin'


acSetNumThreads {
  ON($rescName == "cshlWildcatRes" && $clientAddr == ipc_IES_IP) { 
    msiSetNumThreads("default", "0", "default");
  }
}

acSetRescSchemeForCreate {
  msiSetDefaultResc("iplantRG","preferred");
  msiSetRescSortScheme("random");
}

acSetRescSchemeForRepl { msiSetDefaultResc("iplantRG","preferred"); }

