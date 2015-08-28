# bisque.re  
# Bisque related rules for > iRods 3.0
# put this in server/config/reConfigs/bisque.re
# include this file from within ipc-custom.re
###########################
# NOTE:
# CHANGE CMD_HOST to be irods server host name containing the insert2bisque.py script
###############################################

logMsg(*Msg) = writeLine('serverLog', 'BISQUE: *Msg')

joinPath(*ParentColl, *ObjName) = *ParentColl ++ '/' ++ *ObjName

getHomeUser(*Path) =
  let *nodes = split(*Path, '/') 
  in if size(*nodes) <= 2
     then '' 
     else let *user = elem(*nodes, 2)     
          in if *user == 'shared' then '' else *user

getSubmitter(*Path) =
   let *homeUser = getHomeUser(*Path)
   in if *homeUser == '' then $userNameClient else *homeUser

ensureBisqueWritePerm(*Path) = msiSetACL('default', 'write', 'bisque', *Path)

ensureBisqueWritePermColl(*Path) {
  logMsg('permitting bisque user RW on *Path');
  ensureBisqueWritePerm(*Path);
  msiSetACL('recursive', 'inherit', 'null', *Path);
}

removeBisquePerm(*Path) = msiSetACL('default', 'null', 'bisque', *Path)

isInNEVP(*Path) = *Path like '/iplant/home/shared/NEVP/\*'

isInSernec(*Path) = *Path like '/iplant/home/shared/sernec/\*'

isInUser(*Path) = *Path like regex '/iplant/home/[^/]\*/bisque_data/.\*' 
                  && !(*Path like '/iplant/home/shared/\*')

isInBisqueCollection(*Path) = isInUser(*Path) || isInNEVP(*Path) || isInSernec(*Path)

isForBisque(*Path) = $userNameClient != "bisque" && isInBisqueCollection(*Path)

insert2bisque(*Path, *Permission, *CmdHost) {
  delay("<PLUSET>1s</PLUSET>") {
    *pathArg = execCmdArg(*Path);
    *submitArg = execCmdArg(getSubmitter(*Path));
    *permArg = execCmdArg(*Permission);
    logMsg('scheduling insert of object *Path for *submitArg');
    *argStr = '*pathArg *submitArg *permArg';
    *status = msiExecCmd("insert2bisque.py", *argStr, *CmdHost, "null", "null", *cmdOut);
    if (*status == 0) {
      msiGetStdoutInExecCmdOut(*cmdOut, *resp);
      *id = hd(split(*resp, ' '));
      *uri = substr(*resp, strlen(*id) + 1, strlen(*resp));
      msiString2KeyValPair('bisque-id=*id%bisque-uri=*uri', *kv);
      msiSetKeyValuePairsToObj(*kv, *Path, '-d');
      logMsg('inserted object *Path');
    } else {
      msiGetStderrInExecCmdOut(*cmdOut, *resp);
      logMsg('FAILURE - *resp');
    }
  }
}

removeFromBisque(*Path, *CmdHost) {
  # This is the stub rule for removing an image from Bisque.
}

handleNewObject(*Path, *CmdHost) {
  ensureBisqueWritePerm(*Path);
  *perm = if isInNEVP(*Path) || isInSernec(*Path) then 'published' else 'private';
  insert2bisque(*Path, *perm, *CmdHost);
}

handleFormerObject(*ParentColl, *ObjName, *CmdHost) {
  *path = joinPath(*ParentColl, *ObjName);
  logMsg('scheduling removal of object *path'); 
  *hasBisqueAVUs = false;
  foreach (*val in SELECT META_DATA_ATTR_VALUE 
                     WHERE COLL_NAME == *ParentColl 
                       AND DATA_NAME == *ObjName 
                       AND META_DATA_ATTR_NAME == 'bisque-id') {
    msiAddKeyVal(*bisqueAVUs, 'bisque-id', *val.META_DATA_ATTR_VALUE);
    *hasBisqueAVUs = true;
  }
  foreach (*val in SELECT META_DATA_ATTR_VALUE 
                     WHERE COLL_NAME == *ParentColl 
                       AND DATA_NAME == *ObjName 
                       AND META_DATA_ATTR_NAME == 'bisque-uri') {
    msiAddKeyVal(*bisqueAVUs, 'bisque-uri', *val.META_DATA_ATTR_VALUE);
    *hasBisqueAVUs = true;
  }
  if (*hasBisqueAVUs) {
    msiRemoveKeyValuePairsFromObj(*bisqueAVUs, *path, '-d');
  }
  removeFromBisque(*path, *CmdHost);
  removeBisquePerm(*path);
}


# Add a call to this rule from inside the acPostProcForCollCreate PEP.
bisque_acPostProcForCollCreate {
  if ($collName like regex "/iplant/home/[^/]\*/bisque_data") {
    ensureBisqueWritePermColl($collName);
  }   
}

# Add a call to this rule from inside the acPostProcForPut PEP. 
bisque_acPostProcForPut(*CmdHost) {
  if (isForBisque($objPath)) {
    handleNewObject($objPath, *CmdHost);
  }
}

# Add a call to this rule from inside the acPostProcForCopy PEP.
bisque_acPostProcForCopy(*CmdHost) {
  if (isForBisque($objPath)) {
    handleNewObject($objPath, *CmdHost);
  }
}

# Add a call to this rule from inside the acPostProcForObjRename PEP.
bisque_acPostProcForObjRename(*SrcEntity, *DestEntity, *CmdHost) {
  msiGetObjType(*DestEntity, *type);
  if (!isInBisqueCollection(*SrcEntity) && isForBisque(*DestEntity)) {
    if (*type == '-c') {
      ensureBisqueWritePermColl(*DestEntity);

      # Ensure all member collections have the correct permissions
      foreach(*row in SELECT COLL_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
        ensureBisqueWritePermColl(*row.COLL_NAME);
      }   

      # Ensure all immediate member data objects have the correct permissions
      foreach(*row in SELECT DATA_NAME WHERE COLL_NAME == '*DestEntity') {
        handleNewObject(joinPath(*DestEntity, *row.DATA_NAME), *CmdHost);
      }   

      # Ensure the data objects more deeply nested have the correct permissions
      foreach(*row in SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
        handleNewObject(joinPath(*row.COLL_NAME, *row.DATA_NAME), *CmdHost);
      }
    } else if (*type == '-d') {
      handleNewObject(*DestEntity, *CmdHost);
    }
  } else if (isInBisqueCollection(*SrcEntity) && !isInBisqueCollection(*DestEntity)) {
#    if (*type == '-c') {
#      # Ensure all immediate member data objects have been processed
#      foreach(*row in SELECT DATA_NAME WHERE COLL_NAME == '*DestEntity') {
#        handleFormerObject(*DestEntity, *row.DATA_NAME, *CmdHost);
#      }
#   
#      # Ensure all data objects more deeply nested have been processed
#      foreach(*row in SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
#        handleFormerObject(*row.COLL_NAME, *row.DATA_NAME, *CmdHost);
#      }
#
#      # Ensure all member collections have the correct permissions
#      foreach(*row in SELECT COLL_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
#        removeBisquePerm(*row.COLL_NAME);
#      }  
#
#      removeBisquePerm(*DestEntity); 
#    } else if (*type == '-d') {
#      msiSplitPath(*DestEntity, *parentColl, *objName);
#      handleFormerObject(*parentColl, *objName, *CmdHost);
#    }
  }
}

# Add a call to this rule from inside the acPostProcForDelete PEP.
bisque_acPostProcForDelete(*CmdHost) {
#	if (isInBisqueCollection($objPath)) {
#    removeFromBisque($objPath, *CmdHost);
#  }
}

