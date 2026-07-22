using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.marking.handlers.tree.
using ibs.th.gbl.keyrec.
using Ibs.Th.Gbl.gbl-print.
block-level on error undo, throw.
class ibs.th.gbl.lib inherits objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Библиотеки системы" get.
  define variable marTree as class tree no-undo.
  define public property MarkingTree as class tree no-undo
  get:
    if not valid-object (MarkingTree)
    then do:
marTree = new tree ().
ObjSrv:Regobj(this-object,marTree,
"marTree"
) .
    end.
    return marTree .
  end.
  define public property KeyRec as class keyrec no-undo
  get.
  private set.
  define public property prnLib as class gbl-print no-undo
  get.
  private set.
  constructor public lib (  ):
    super ().
marTree = new tree ().
ObjSrv:Regobj(this-object,marTree,
"marTree"
) .
KeyRec = new keyrec ().
ObjSrv:Regobj(this-object,KeyRec,
"KeyRec"
) .
prnLib = new gbl-print ().
ObjSrv:Regobj(this-object,prnLib,
"prnLib"
) .
  end constructor.
end class.
