using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.curdburt:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-curdburt as handle.
  constructor public curdburt ():
    run gbl\curdburt.p persistent (output hndl-proc-curdburt) no-error.
  end constructor.
  method public void curd_burt (
   output p-user-db-num   as  integer,
   output p-user-name     as  character,
   output p-sys-date      as  date,
   output p-sys-time      as  character,
   output p-sys-time-int  as  integer):
    run curd_burt in hndl-proc-curdburt (
   output p-user-db-num,
   output p-user-name,
   output p-sys-date,
   output p-sys-time,
   output p-sys-time-int) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  destructor public curdburt ():
    delete object hndl-proc-curdburt no-error.
    if error-status:error
      then
    do:
    end.
  end destructor.
end class.
