using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.mercury.*.
using ibs.th.str.gds.*.
block-level on error undo, throw.
class ibs.th.str.mercury.gdsmercsub implements ithsub:
  define property ID as integer no-undo
    get.
    set.
  define property DBNum as integer no-undo
    get.
    set.
  define property GdsCode as integer no-undo
    get.
    set.
  define property UUID as character no-undo
    get.
    set.
  define property GUID_ as character no-undo
    get.
    set.
  define property MercName as character no-undo
    get.
    set.
  define property DateCr as date no-undo
    get.
    set.
  define property DateUpdate as date no-undo
    get.
    set.
  define property ProdType as character no-undo
    get.
    set.
  define property GUIDType as character no-undo
    get.
    set.
  define property GUIDSubType as character no-undo
    get.
    set.
  define property StatusErr as logical no-undo
    get.
    private set.
  define property Msg as character no-undo
    get.
    private set.
  constructor public gdsmercsub (  ):
  end constructor.
  method public logical checkuuid( uuid as character ):
    return true.
  end method.
  method public void setMsg( arg as character ):
    Msg = arg.
  end.
  method public void setStatusErr( arg as logical ):
    StatusErr = arg.
  end.
end class.
