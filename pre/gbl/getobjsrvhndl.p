block-level on error undo, throw.
using ibs.th.gbl.sys.objsrv.
define input-output parameter ObjSrv as class objsrv no-undo.
define new global shared variable g#libobj  as handle no-undo .
if not valid-handle (g#libobj)
  then run gbl/libobj.p persistent.
run GetObjServ in g#libobj (input-output ObjSrv).
