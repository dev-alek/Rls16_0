using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.spegrpmt:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-spegrpmt as handle.
  constructor public spegrpmt ():
    run ref\spegrpmt.p persistent (output hndl-proc-spegrpmt) no-error.
  end constructor.
  method public void SpecGr-gds-code-yes (
    input     p-gds-code        as integer,
    input     p-node-code       as integer,
    input     p-contract-num    as integer,
    input     p-host-code       as integer,
    output    p-ask             as logical):
    run SpecGr-gds-code-yes in hndl-proc-spegrpmt (
    input     p-gds-code        ,
    input     p-node-code       ,
    input     p-contract-num    ,
    input     p-host-code       ,
    output    p-ask             ) no-error.
    if error-status:error
      then
    do:
    end.
  end.
   method public void recalc-gds-SpecGr  (
    input     p-action          as character,
    input     p-node-code       as integer,
    input     p-contract-num    as integer,
    input     p-host-code       as integer):
    run recalc-gds-SpecGr  in hndl-proc-spegrpmt (
    input     p-action          ,
    input     p-node-code       ,
    input     p-contract-num    ,
    input     p-host-code       ) no-error.
    if error-status:error
      then
    do:
    end.
  end.
  destructor public spegrpmt ():
    delete object hndl-proc-spegrpmt no-error.
    if error-status:error
      then
    do:
    end.
  end destructor.
end class.
