# coge.re
# COGE related rules for > iRods 3.0
# put this in server/config/reConfigs/coge.re

ZONE = 'iplant'

isForCoge(*Path) = *Path like '/' ++ ZONE ++ '/home/*/coge_data' || 
                   *Path like '/' ++ ZONE ++ '/home/*/coge_data/*'

setCogePerm(*Path) {
  *lvl = if *Path == '/' ++ ZONE ++ '/home/coge/coge_data' || 
            *Path like '/' ++ ZONE ++ '/home/coge/coge_data/*' ||
            *Path like '/' ++ ZONE ++ '/home/coge/*/coge/data' ||
            *Path like '/' ++ ZONE ++ '/home/coge/*/coge_data/*'
         then 'own'
         else 'write';
  msiSetACL('default', *lvl, 'coge', *Path);
}

ensureCogeWritePermColl(*Path) {
  setCogePerm(*Path);
  msiSetACL('recursive', 'inherit', 'null', *Path);
}

ensureCogeWritePermObj(*Path) {
  setCogePerm(*Path);
}

coge_acPostProcForCollCreate {
  if(isForCoge($collName)) {
    writeLine('serverLog', 'COGE: permitting coge user RW on $collName');
    ensureCogeWritePermColl($collName);    
  }
}

coge_acPostProcForObjRename(*SrcEntity, *DestEntity) {
  if(!isForCoge(*SrcEntity) && isForCoge(*DestEntity)) {
    msiGetObjType(*DestEntity, *type);
    if (*type == '-c') {
      ensureCogeWritePermColl(*DestEntity);

      # Ensure all member collections have the correct permissions
      msiExecStrCondQuery("SELECT COLL_NAME WHERE COLL_NAME LIKE '*DestEntity/%'", *results);
      foreach(*row in *results) {
        msiGetValByKey(*row, "COLL_NAME", *coll);
        ensureCogeWritePermColl(*coll);
      }

      # Ensure all immediate member data objects have the correct permissions
      msiExecStrCondQuery("SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME = '*DestEntity'", *results);
      foreach(*row in *results) {
        msiGetValByKey(*row, "COLL_NAME", *coll);
        msiGetValByKey(*row, "DATA_NAME", *obj);
        ensureCogeWritePermObj(*coll++'/'++*obj);
      }

      # Ensure the data objects more deeply nested have the correct permissions
      msiExecStrCondQuery("SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME LIKE '*DestEntity/%'", 
                          *results);
      foreach(*row in *results) {
        msiGetValByKey(*row, "COLL_NAME", *coll);
        msiGetValByKey(*row, "DATA_NAME", *obj);
        ensureCogeWritePermObj(*coll++'/'++*obj);
      }
    } else if (*type == '-d') {
      ensureCogeWritePermObj(*DestEntity);
    }
  }
}

