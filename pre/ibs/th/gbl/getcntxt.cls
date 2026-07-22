using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.getcntxt:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-getcntxt as handle.
  constructor public getcntxt ():
    run gbl\getcntxt.p persistent (output hndl-proc-getcntxt) no-error.
  end constructor.
  method public void MainMenuGetcntxt (
  output v-cntxt-db-num        as integer,
  output v-cntxt-userid        as character,
  output v-cntxt-level         as character,
  output v-cntxt-host-code-obj as integer,
  output v-cntxt-obj-type      as character,
  output v-cntxt-obj-code      as integer,
  output v-cntxt-db-num-obj    as integer,
  output v-cntxt-is-admin      as logical
  ):
    run mainmenu_getcntxt in hndl-proc-getcntxt (
    output v-cntxt-db-num,
    output v-cntxt-userid,
    output v-cntxt-level,
    output v-cntxt-host-code-obj,
    output v-cntxt-obj-type,
    output v-cntxt-obj-code,
    output v-cntxt-db-num-obj,
    output v-cntxt-is-admin) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  destructor public getcntxt ():
    delete object hndl-proc-getcntxt no-error.
    if error-status:error
      then
    do:
    end.
  end destructor.
end class.
