using Progress.Lang.*.
using ibs.th.str.utd.sts.*.
using ibs.th.str.marking.sts.*.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.
class ibs.th.str.utd.sts inherits objth:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Статусы электронных документов" get.
  define public property EDI as class edi no-undo
    get.
    protected set.
  define public property TH as class th no-undo
    get.
    protected set.
  define public property Receipt as class receipt no-undo
    get.
    protected set.
  define public property Direction as class direction no-undo
    get.
    protected set.
  constructor public sts (  ):
    super ().
EDI = new edi ().
ObjSrv:Regobj(this-object,EDI,
"EDI"
) .
TH = new th ().
ObjSrv:Regobj(this-object,TH,
"TH"
) .
Receipt = new receipt ().
ObjSrv:Regobj(this-object,Receipt,
"Receipt"
) .
Direction = new direction ().
ObjSrv:Regobj(this-object,Direction,
"Direction"
) .
  end constructor.
end class.
