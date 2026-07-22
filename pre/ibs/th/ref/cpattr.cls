using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.cpattr:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-cpattr as handle.
  constructor public cpattr ():
    run ref\cp-attr.p persistent (output hndl-proc-cpattr) no-error.
  end constructor.
  method public void CpAttrCode (
    input     p-code        as character,
    output    p-type        as character,
    output    p-format      as character,
    output    p-label       as character,
    output    p-range       as integer,
    output    p-user-can-edit as logical,
    output    p-output-display  as logical,
    output    p-other       as character):
    run cp-attr-code in hndl-proc-cpattr (
    input     p-code,
    output    p-type,
    output    p-format,
    output    p-label,
    output    p-range,
    output    p-user-can-edit,
    output    p-output-display,
    output    p-other) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CpAttrTooltip (
    input   p-code      as character,
    output  p-tooltip   as character,
    output  p-label     as character
    ):
    run cp-attr-tooltip in hndl-proc-cpattr (
      input   p-code,
      output  p-tooltip,
      output  p-label) no-error.
    if error-status:error
      then
    do:
    end.
  end.
    method public void CpAttrValue (
    input    p-cdpay-code     as integer,
    input    p-curr-code      as integer,
    input    p-host-code      as integer,
    input    p-obj-type       as character,
    input    p-obj-code       as integer,
    input    p-code           as character,
    output   p-value          as character,
    output   p-type           as character):
    run cp-attr-value in hndl-proc-cpattr (
    input     p-cdpay-code,
    input     p-curr-code,
    input     p-host-code,
    input     p-obj-type,
    input     p-obj-code,
    input     p-code,
    output    p-value,
    output    p-type) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CpAttrWrite (
    input    p-cdpay-code     as integer,
    input    p-curr-code      as integer,
    input    p-host-code      as integer,
    input    p-obj-type       as character,
    input    p-obj-code       as integer,
    input    p-code           as character,
    input    p-value          as character):
    run cp-attr-write in hndl-proc-cpattr (
    input     p-cdpay-code,
    input     p-curr-code,
    input     p-host-code,
    input     p-obj-type,
    input     p-obj-code,
    input     p-code,
    input     p-value) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CpAttrExist (
    input    p-cdpay-code     as integer,
    input    p-curr-code      as integer,
    input    p-host-code      as integer,
    input    p-obj-type       as character,
    input    p-obj-code       as integer,
    input    p-code           as character,
    output   p-exist          as logical):
    run cp-attr-exist in hndl-proc-cpattr (
    input     p-cdpay-code,
    input     p-curr-code,
    input     p-host-code,
    input     p-obj-type,
    input     p-obj-code,
    input     p-code,
    output    p-exist) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CpAttrDelete (
    input    p-cdpay-code     as integer,
    input    p-curr-code      as integer,
    input    p-host-code      as integer,
    input    p-obj-type       as character,
    input    p-obj-code       as integer,
    input    p-code           as character,
    output   p-deleted        as logical):
    run cp-attr-delete in hndl-proc-cpattr (
    input     p-cdpay-code,
    input     p-curr-code,
    input     p-host-code,
    input     p-obj-type,
    input     p-obj-code,
    input     p-code,
    output    p-deleted) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CpAttrNews (
    input   p-code      as character,
    output  p-news      as logical
    ):
    run cp-attr-news in hndl-proc-cpattr (
      input   p-code,
      output  p-news) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  method public void CpAttrHist (
    input   p-code      as character,
    output  p-hist      as logical
    ):
    run cp-attr-hist in hndl-proc-cpattr (
      input   p-code,
      output  p-hist) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  destructor public cpattr ():
    delete object hndl-proc-cpattr no-error.
    if error-status:error
      then
    do:
    end.
  end destructor.
end class.
