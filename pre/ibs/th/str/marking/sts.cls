using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.marking.sts.mark.
block-level on error undo, throw.
class ibs.th.str.marking.sts inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Статусы марок" get.
   define public property Mark as class mark no-undo
    get.
    protected set.
  constructor public sts (  ):
    super ().
Mark = new mark ().
ObjSrv:Regobj(this-object,Mark,
"Mark"
) .
  end constructor.
end class.
