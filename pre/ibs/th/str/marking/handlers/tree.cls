using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.
class ibs.th.str.marking.handlers.tree inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Бибилиотека обработки марок" get.
  method public logical LevelDownUTD(mark as char, doc-id as integer, db-num as integer):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:LevelDownUTD(mark , doc-id , db-num ).
     delete object mExem no-error.
     return vflag.
  end method.
  method public logical LevelDownDoc(mark as char, obj-code as integer, obj-type as character, in-code as character, out-code as character):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:LevelDownDoc(mark, obj-code , obj-type , in-code , out-code).
     delete object mExem no-error.
     return vflag.
  end method.
  method public logical LevelUpUTD(mark as char, doc-id as integer, db-num as integer):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:LevelUpUTD(mark, doc-id, db-num ).
     delete object mExem no-error.
     return vflag.
  end method.
  method public logical StatusDownUTD(mark as char, doc-id as integer, db-num as integer, sts as integer):
     define variable vqnty-check as integer  no-undo.
     define variable vOk         as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vOk = mExem:StatusDownUTD(mark , doc-id , db-num , sts ).
     delete object mExem no-error.
     return vOk.
  end method.
  method public logical StatusUpUTD(mark as char, doc-id as integer, db-num as integer, sts as integer):
     define variable vOk         as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vOk = mExem:StatusUpUTD(mark , doc-id , db-num , sts ).
     delete object mExem no-error.
     return vOk.
  end method.
  method public integer StatusDownDoc(mark as char, obj-code as integer, obj-type as character, in-code as character, out-code as character, sts as integer):
     define variable vqnty-check as integer  no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vqnty-check = mExem:StatusDownDoc(mark , obj-code, obj-type, in-code, out-code, sts ).
     delete object mExem no-error.
     return vqnty-check.
  end method.
  method public integer DeleteDownDoc(mark as char, obj-code as integer, obj-type as character, in-code as character, out-code as character):
     define variable vqnty-check as integer  no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vqnty-check = mExem:DeleteDownDoc(mark, obj-code , obj-type , in-code , out-code ).
     delete object mExem no-error.
     return vqnty-check.
  end method.
  method public logical UnGroupUTD(mark as char, doc-id as integer, db-num as integer):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:UnGroupUTD(mark , doc-id , db-num ).
     delete object mExem no-error.
     return vflag.
  end method.
  method public logical UnGroupDoc(mark as char, in-code as character, out-code as character, obj-code as integer, obj-type as character):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:UnGroupDoc(mark , in-code , out-code , obj-code , obj-type ).
     delete object mExem no-error.
     return vflag.
  end method.
  method public logical UnGroupMark(mark as char):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:UnGroupMark(mark).
     delete object mExem no-error.
     return vflag.
  end method.
  method public logical LevelDown(mark as char):
     define variable vflag as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vflag = mExem:LevelDown(mark).
     delete object mExem no-error.
     return vflag.
  end method.
  method public void LockInvChildeMark (mark as char, doc-code as char):
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     mExem:LockInvChildeMark (mark , doc-code ).
     delete object mExem no-error.
  end method.
  method public void LockChkChildeMark (Imark as char):
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     mExem:LockChkChildeMark (Imark).
     delete object mExem no-error.
  end method.
  method public integer  GetQntySts(mark as char,  sts as integer):
     define variable vqnty-check as integer  no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vqnty-check = mExem:GetQntySts(mark ,  sts ).
     delete object mExem no-error.
     return vqnty-check.
  end method.
 method public integer  GetQntyStsUnit(db-num as integer, doc-id as integer, line-num as integer, sts as integer):
     define variable vqnty-check as integer  no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vqnty-check = mExem:GetQntyStsUnit( db-num ,doc-id , line-num, sts ).
     delete object mExem no-error.
     return vqnty-check.
  end method.
 method public integer  GetQntyCheckMark(db-num as integer, doc-id as integer, line-num as integer):
     define variable vqnty-check as integer  no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vqnty-check = mExem:GetQntyCheckMark( db-num ,doc-id , line-num).
     delete object mExem no-error.
     return vqnty-check.
  end method.
   method public logical checkedAllMarksOfUpakUTD(iMarkUpak as character, iDbNum as integer, iDocId as integer):
     define variable vIsChecked as logical no-undo.
     define variable mExem as class ibs.th.str.marking.handlers.treeexem no-undo.
mExem = new ibs.th.str.marking.handlers.treeexem ().
ObjSrv:Regobj(this-object,mExem,
"mExem"
) .
     vIsChecked = mExem:checkedAllMarksOfUpakUTD( iMarkUpak, iDbNum ,iDocId ).
     delete object mExem no-error.
     return vIsChecked.
  end method.
end class.
