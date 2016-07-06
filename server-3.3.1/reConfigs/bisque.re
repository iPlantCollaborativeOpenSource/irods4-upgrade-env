# bisque.re  
# Bisque related rules for > iRods 3.0
# put this in server/config/reConfigs/bisque.re
# include this file from within ipc-custom.re
###########################
# NOTE:
# CHANGE CMD_HOST to be irods server host name containing the insert2bisque.py script
###############################################

BISQUE_GROUPS = list('NEVP', 'sernec')

logMsg(*Msg) = writeLine('serverLog', 'BISQUE: *Msg')

mkURL(*IESHost, *Path) = "irods://" ++ *IESHost ++ *Path

# Tells BisQue to create a link for a given user to a data object.
#
# bisque_ops.py ln -P permission --alias user irods://ies.host/path/to/data.object
ln(*IESHost, *Permission, *Client, *Path) {
  logMsg("scheduling linking of *Path for *Client with permission *Permission");
  delay("<PLUSET>1s</PLUSET>") {
    logMsg("linking *Path for *Client with permission *Permission");
    *pArg = execCmdArg(*Permission);
    *aliasArg = execCmdArg(*Client);
    *pathArg = execCmdArg(mkURL(*IESHost, *Path));
    *argStr = 'ln -P *pArg --alias *aliasArg *pathArg';
    *status = errorcode(msiExecCmd("bisque_ops.py", *argStr, *IESHost, "null", "null", *out));
    if (*status != 0) {
# This is broken in iRODS 3
#      msiGetStderrInExecCmdOut(*cmdOut, *resp);
#      logMsg('FAILURE - *resp');
      logMsg('failed to link *Path for *Client with permission *Permission');
      fail;
    } else {
# Workaround for above ^^^
      msiGetStderrInExecCmdOut(*out, *errMsg);
      if (strlen(*errMsg) > 0) {
        logMsg(*errMsg);
        logMsg('failed to link *Path for *Client with permission *Permission');
        fail;
      }
# End of workaround
      msiGetStdoutInExecCmdOut(*out, *resp);
      *props = split(trimr(triml(*resp, ' '), '/'), ' ');
# This is broken in iRODS 3
#      *msiStrArray2String(*props, *kvStr);
# Workaround
      *kvStr = "";
      foreach(*prop in *props) {
        if (*kvStr == "" ) {
          *kvStr = *prop;
        } else {
          *kvStr = *kvStr ++ "%" ++ *prop;
        }
      }
# End of workaround
      msiString2KeyValPair(*kvStr, *kvs);
      msiGetValByKey(*kvs, 'resource_uniq', *qId);
      *id = substr(*qId, 1, strlen(*qId) - 2);
      msiGetValByKey(*kvs, 'uri', *qURI);
      *uri = substr(*qURI, 1, strlen(*qURI) - 2);
      msiString2KeyValPair('ipc-bisque-id=*id%ipc-bisque-uri=*uri', *kv);
      msiSetKeyValuePairsToObj(*kv, *Path, '-d');
      logMsg('linked *Path for *Client with permission *Permission');
    }
  }
}

# Tells BisQue to change the path of a linked data object.
#
# bisque_ops.py mv --alias user \
#     irods://ies.host/old/path/to/data.object irods://ies.host/new/path/to/data.object
mv(*IESHost, *Client, *OldPath, *NewPath) {
  logMsg('scheduling link move from *OldPath to *NewPath for *Client');
  delay("<PLUSET>1s</PLUSET>") {
    logMsg('moving link from *OldPath to *NewPath for *Client');
    *aliasArg = execCmdArg(*Client);
    *oldPathArg = execCmdArg(mkURL(*IESHost, *OldPath));
    *newPathArg = execCmdArg(mkURL(*IESHost, *NewPath));
    *argStr = 'mv --alias *aliasArg *oldPathArg *newPathArg';
    *status = errorcode(msiExecCmd('bisque_ops.py', *argStr, *IESHost, 'null', 'null', *out));
    if (*status != 0) {
# This is broken in iRODS 3
#      msiGetStderrInExecCmdOut(*cmdOut, *resp);
#      logMsg('FAILURE - *resp');
      logMsg('failed to move link from *OldPath to *NewPath for *Client');
      fail;
    } else {
# Workaround for above ^^^
      msiGetStderrInExecCmdOut(*out, *errMsg);
      if (strlen(*errMsg) > 0) {
        logMsg(*errMsg);
        logMsg('failed to move link from *OldPath to *NewPath for *Client');
        fail;
      }
# End of workaround
      logMsg('moved link from *OldPath to *NewPath for *Client');
    }
  }
}

# Tells BisQue to remove a link to data object.
#
# bisque_ops.py rm --alias user irods://ies.host/path/to/data.object
rm(*IESHost, *Client, *Path) {
  logMsg("scheduling removal of linking to *Path for *Client");
  delay("<PLUSET>1s</PLUSET>") {
    logMsg("Removing link from *Path for *Client");
    *aliasArg = execCmdArg(*Client);
    *pathArg = execCmdArg(mkURL(*IESHost, *Path));
    *argStr = 'rm --alias *aliasArg *pathArg';
    *status = errorcode(msiExecCmd("bisque_ops.py", *argStr, *IESHost, "null", "null", *out));
    if (*status != 0) {
# This is broken in iRODS 3
#      msiGetStderrInExecCmdOut(*cmdOut, *resp);
#      logMsg('FAILURE - *resp');
      logMsg('failed to remove link to *Path for *Client');
      fail;
    } else {
# Workaround for above ^^^
      msiGetStderrInExecCmdOut(*out, *errMsg);
      if (strlen(*errMsg) > 0) {
        logMsg(*errMsg);
        logMsg('failed to remove link to *Path for *Client');
        fail;
      }
# End of workaround
      logMsg('removed link to *Path for *Client');
    }
  }
}

joinPath(*ParentColl, *ObjName) = *ParentColl ++ '/' ++ *ObjName

getHomeUser(*Path) =
  let *nodes = split(*Path, '/') 
  in if size(*nodes) <= 2
     then '' 
     else let *user = elem(*nodes, 2)     
          in if *user == 'shared' then '' else *user

getClient(*Path) =
   let *homeUser = getHomeUser(*Path)
   in if *homeUser == '' then $userNameClient else *homeUser

ensureBisqueWritePerm(*Path) = msiSetACL('default', 'write', 'bisque', *Path)

ensureBisqueWritePermColl(*Path) {
  logMsg('permitting bisque user RW on *Path');
  ensureBisqueWritePerm(*Path);
  msiSetACL('recursive', 'inherit', 'null', *Path);
}

isInGroup(*Group, *Path) = *Path like '/iplant/home/shared/*Group/\*'

isInGroups(*Groups, *Path) {
  *result = false;
  foreach(*group in *Groups) {
    if (isInGroup(*group, *Path)) {
      *result = true;
      break;
    }
  }
  *result;
}

isInUser(*Path) = *Path like regex '/iplant/home/[^/]\*/bisque_data/.\*' 
                  && !(*Path like '/iplant/home/shared/\*')

isInBisqueCollection(*Path) = isInUser(*Path) || isInGroups(BISQUE_GROUPS, *Path) 

isForBisque(*Path) = $userNameClient != "bisque" && isInBisqueCollection(*Path)

handleNewObject(*IESHost, *Client, *Path) {
  ensureBisqueWritePerm(*Path);
  *perm = if isInGroups(BISQUE_GROUPS, *Path) then 'published' else 'private';
  ln(*IESHost, *perm, *Client, *Path);
}

# Add a call to this rule from inside the acPostProcForCollCreate PEP.
bisque_acPostProcForCollCreate {
  if ($collName like regex "/iplant/home/[^/]\*/bisque_data") {
    ensureBisqueWritePermColl($collName);
  }   
}

# Add a call to this rule from inside the acPostProcForPut PEP. 
bisque_acPostProcForPut(*IESHost) {
  if (isForBisque($objPath)) {
    handleNewObject(*IESHost, getClient($objPath), $objPath);
  }
}

# Add a call to this rule from inside the acPostProcForCopy PEP.
bisque_acPostProcForCopy(*IESHost) {
  if (isForBisque($objPath)) {
    handleNewObject(*IESHost, getClient($objPath), $objPath);
  }
}

# Add a call to this rule from inside the acPostProcForObjRename PEP.
bisque_acPostProcForObjRename(*SrcEntity, *DestEntity, *IESHost) {
  msiGetObjType(*DestEntity, *type);
  *client = getClient(*SrcEntity);
  if (isInBisqueCollection(*SrcEntity)) {
    if (*type == '-c') {
      # Ensure all immediate member data objects have the correct permissions
      foreach(*row in SELECT DATA_NAME WHERE COLL_NAME == '*DestEntity') {
        mv(*IESHost, 
           *client, 
           joinPath(*SrcEntity, *row.DATA_NAME), 
           joinPath(*DestEntity, *row.DATA_NAME));
      }   

      # Ensure the data objects more deeply nested have the correct permissions
      *destCollLen = strlen(*DestEntity);

      foreach(*row in SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
        *destObj = joinPath(*row.COLL_NAME, *row.DATA_NAME);
        *srcObj = *SrcEntity ++ substr(*destObj, *destCollLen, strlen(*destObj));
        mv(*IESHost, *client, *srcObj, *destObj);
      }
    } else if (*type == '-d') {
      mv(*IESHost, *client, *SrcEntity, *DestEntity);
    }
  } else if (isForBisque(*DestEntity)) {
    if (*type == '-c') {
      ensureBisqueWritePermColl(*DestEntity);

      # Ensure all member collections have the correct permissions
      foreach(*row in SELECT COLL_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
        ensureBisqueWritePermColl(*row.COLL_NAME);
      }   

      # Ensure all immediate member data objects have the correct permissions
      foreach(*row in SELECT DATA_NAME WHERE COLL_NAME == '*DestEntity') {
        handleNewObject(*IESHost, *client, joinPath(*DestEntity, *row.DATA_NAME));
      }   

      # Ensure the data objects more deeply nested have the correct permissions
      foreach(*row in SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME LIKE '*DestEntity/%') {
        handleNewObject(*IESHost, *client, joinPath(*row.COLL_NAME, *row.DATA_NAME));
      }
    } else if (*type == '-d') {
      handleNewObject(*IESHost, *client, *DestEntity);
    }
  }
}

# Add a call to this rule from inside the acPostProcForDelete PEP.
bisque_acPostProcForDelete(*IESHost) {
  if (isInBisqueCollection($objPath)) {
    rm(*IESHost, getClient($objPath), $objPath);
  }
}

