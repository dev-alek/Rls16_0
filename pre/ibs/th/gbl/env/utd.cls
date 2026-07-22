using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.utd.sts.
using ibs.th.str.utd.edoctype.
block-level on error undo, throw.
class ibs.th.gbl.env.utd inherits objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Ёлектронные документы" get.
  define public property Sts as class sts no-undo
    get.
    set.
  define public property EDocType as class edoctype no-undo
    get.
    set.
  constructor public utd (  ):
    super ().
Sts = new sts ().
ObjSrv:Regobj(this-object,Sts,
"Sts"
) .
EDocType = new edoctype ().
ObjSrv:Regobj(this-object,EDocType,
"EDocType"
) .
  end constructor.
end class.
