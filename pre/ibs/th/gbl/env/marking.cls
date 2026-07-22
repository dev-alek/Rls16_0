using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.marking.sts.
using ibs.th.str.marking.types.
block-level on error undo, throw.
class ibs.th.gbl.env.marking inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Маркировка товаров" get.
  define public property Sts as class sts no-undo
    get.
    set.
  define public property Types as class Types no-undo
    get.
    set.
  constructor public marking (  ):
    super ().
Sts = new sts ().
ObjSrv:Regobj(this-object,Sts,
"Sts"
) .
Types = new Types ().
ObjSrv:Regobj(this-object,Types,
"Types"
) .
  end constructor.
  METHOD OVERRIDE PUBLIC LOGICAL RefrashObject(  ):
      if valid-object(Types) then
        delete object Types.
Types = new Types ().
ObjSrv:Regobj(this-object,Types,
"Types"
) .
  END METHOD.
end class.
