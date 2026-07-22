using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.clients.*.
using ibs.th.str.mercury.*.
block-level on error undo, throw.
class ibs.th.str.mercury.unitsub implements ithsub:
  define property Msg as character no-undo
    get.
    private set.
  define property UnitName as character no-undo
    get.
    set.
  define property UnitFullName as character no-undo
    get.
    set.
  define property UnitGuid as character no-undo
    get.
    set.
  define property UnitCoef as decimal no-undo
    get.
    set.
  define property StatusErr as logical no-undo
    get:
      def var err as log no-undo.
      err = StatusErr.
      StatusErr = false.
      return err.
    end.
    private set.
  constructor public unitsub (  ):
  end constructor.
  method public void setMsg( arg as character ):
    Msg = arg.
  end.
  method public void setStatusErr( arg as logical ):
    StatusErr = arg.
  end.
end class.
