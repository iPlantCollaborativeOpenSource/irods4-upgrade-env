# aegis.re
# AEGIS related rules for > iRods 3.0
# put this in server/config/reConfigs/aegis.re
# include this file from within ipc-custom.re 

aegis_acPostProcForPut {
    if ($objPath like "/iplant/home/shared/aegis/*") {
        delay("<PLUSET>5s</PLUSET>") {
            msiSysReplDataObj("aegisRG", "null");
        }
    }
}
