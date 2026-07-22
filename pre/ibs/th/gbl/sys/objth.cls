using Progress.Lang.*.
using ibs.th.gbl.sys.objsrv.
block-level on error undo, throw.
class ibs.th.gbl.sys.objth abstract:
define public var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
  define abstract property vss-revision    as character no-undo get.
  define abstract property vss-author      as character no-undo get.
  define abstract property vss-date        as character no-undo get.
  define abstract property vss-workfile    as character no-undo get.
  define abstract property vss-archive     as character no-undo get.
  define abstract property vss-description as character no-undo get.
  method final void vss-get-info (
     output o-vss-revision    as character,
     output o-vss-author      as character,
     output o-vss-date        as character,
     output o-vss-workfile    as character,
     output o-vss-archive     as character,
     output o-vss-description as character
):
     assign
       o-vss-revision    = vss-revision
       o-vss-author      = vss-author
       o-vss-date        = vss-date
       o-vss-workfile    = vss-workfile
       o-vss-archive     = vss-archive
       o-vss-description = vss-description
     .
   end.
   method public char getLable():
      return vss-description.
   end.
  constructor protected objth ():
    getobjserv().
    if valid-object (ObjSrv)
      then ObjSrv:Regobj(this-object).
  end constructor.
  destructor public objth (  ):
    getobjserv().
    if valid-object (ObjSrv)
      then ObjSrv:Delobj(this-object).
  end destructor.
  method public void getobjserv():
run gbl/getobjsrvhndl.p (input-output ObjSrv).
  end method.
  method public logical RefrashObject():
  end method.
end class.
