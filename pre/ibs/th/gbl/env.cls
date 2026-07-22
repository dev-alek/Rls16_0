using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.env.utd.
using ibs.th.gbl.env.marking.
using ibs.th.gbl.sys.env.ini.
using ibs.th.gbl.env.conf.
using ibs.th.gbl.env.prmtrs.section.
block-level on error undo, throw.
class ibs.th.gbl.env inherits objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Сущности системы" get.
  define property Utd as class utd no-undo
    get.
    private set.
  define property Marking as class marking no-undo
    get.
    private set.
  define property ParametrsOfSection as class section no-undo
    get.
    private set.
  constructor public env (  ):
    super ().
Utd = new utd ().
ObjSrv:Regobj(this-object,Utd,
"Utd"
) .
 .
Marking = new marking ().
ObjSrv:Regobj(this-object,Marking,
"Marking"
) .
ParametrsOfSection = new section ().
ObjSrv:Regobj(this-object,ParametrsOfSection,
"ParametrsOfSection"
) .
 .
  end constructor.
end class.
