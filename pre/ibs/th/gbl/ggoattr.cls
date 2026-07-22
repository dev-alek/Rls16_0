using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.ggoattr:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-ggoattr as handle.
  constructor public ggoattr ():
    run gbl\ggoattr.p persistent (output hndl-proc-ggoattr) no-error.
  end constructor.
  method public void ggoattr-code (
    input  p-code           as character,
    output p-type           as character,
    output p-format         as character,
    output p-label          as character,
    output p-user-can-edit  as logical  ,
    output p-output-display as logical  ,
    output p-other          as character
    ):
    run ggoattr-code in hndl-proc-ggoattr (
      input  p-code,
      output p-type,
      output p-format,
      output p-label,
      output p-user-can-edit,
      output p-output-display,
      output p-other
      ) no-error.
    if error-status:error
      then
    do:
       return error return-value.
    end.
  end.
  method public void ggoattr-value (
  input   p-node-code    like ub.gds-grp-obj-attr.node-code ,
  input   p-host-code    like ub.gds-grp-obj-attr.host-code ,
  input   p-obj-type     like ub.gds-grp-obj-attr.obj-type ,
  input   p-obj-code     like ub.gds-grp-obj-attr.obj-code ,
  input   p-code      like ub.gds-grp-obj-attr.attr-code  ,
  output  p-value     like ub.gds-grp-obj-attr.attr-value ,
  output  p-type      as character
  ):
  run ggoattr-value in hndl-proc-ggoattr (
  input   p-node-code ,
  input   p-host-code,
  input   p-obj-type,
  input   p-obj-code,
  input   p-code ,
  output  p-value ,
  output  p-type
  ) no-error.
    if error-status:error
      then
    do:
       return error return-value.
    end.
  end.
  method public void ggoattr-write (
    input  p-node-code as integer,
    input  p-host-code as integer,
    input  p-obj-type  as character,
    input  p-obj-code  as integer,
    input p-code  as character,
    input p-value as character
    ):
    run ggoattr-write in hndl-proc-ggoattr (
      input  p-node-code,
      input  p-host-code,
      input  p-obj-type,
      input  p-obj-code,
      input p-code,
      input p-value
      ) no-error.
    if error-status:error
      then
    do:
       return error return-value.
    end.
  end.
  method public void ggoattr-delete (
    input  p-node-code as integer,
    input  p-host-code as integer,
    input  p-obj-type  as character,
    input  p-obj-code  as integer,
    input p-code  as character,
    output p-deleted as logical
    ):
    run ggoattr-delete in hndl-proc-ggoattr (
      input  p-node-code,
      input  p-host-code,
      input  p-obj-type,
      input  p-obj-code,
      input p-code,
      output p-deleted
      ) no-error.
    if error-status:error
      then
    do:
       return error return-value.
    end.
  end.
  destructor public ggoattr ():
    delete object hndl-proc-ggoattr no-error.
  end destructor.
end class.
