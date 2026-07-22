using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.cur-time:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-curtime as handle.
  constructor public cur-time ():
    run gbl\cur-time.p persistent (output hndl-proc-curtime) no-error.
  end constructor.
  method public void CurTime (
    output p-today      as date,
    output p-time       as integer ):
    run cur-time in hndl-proc-curtime ( output p-today
      ,output p-time) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  destructor public cur-time ():
    delete object hndl-proc-curtime no-error.
    if error-status:error
      then
    do:
    end.
  end destructor.
end class.
