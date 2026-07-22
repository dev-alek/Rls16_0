block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calc-bal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/calc-bal.p $":U .
define variable vss-description as character no-undo init "пересчет текущего баланса по договору".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input  parameter p-type          as character no-undo .
define input  parameter p-znak          as logical   no-undo .
define input  parameter p-doc-type      as character no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-sum           as decimal   no-undo .
define input  parameter p-sum-rubl      as decimal   no-undo .
define input  parameter p-sum-base      as decimal   no-undo .
define buffer buf_contract for ub.contract.
find first buf_contract exclusive-lock
  where buf_contract.host-code     = p-host-code
    and buf_contract.contract-code = p-contract-code
no-error .
if available buf_contract then do:
  if p-type = "finob" then do:
    if p-znak then
      assign
        buf_contract.balance-fo      = buf_contract.balance-fo      + p-sum
        buf_contract.balance-fo-rubl = buf_contract.balance-fo-rubl + p-sum-rubl
        buf_contract.balance-fo-base = buf_contract.balance-fo-base + p-sum-base
      .
    else
      assign
        buf_contract.balance-fo      = buf_contract.balance-fo      - p-sum
        buf_contract.balance-fo-rubl = buf_contract.balance-fo-rubl - p-sum-rubl
        buf_contract.balance-fo-base = buf_contract.balance-fo-base - p-sum-base
      .
  end.
  else do:
    if p-doc-type = 'рпп':U or p-doc-type = 'рко':U or p-doc-type = 'апр':U  then assign p-znak = not p-znak .
    if p-znak then
      assign
        buf_contract.balance-plat      = buf_contract.balance-plat      + p-sum
        buf_contract.balance-plat-rubl = buf_contract.balance-plat-rubl + p-sum-rubl
        buf_contract.balance-plat-base = buf_contract.balance-plat-base + p-sum-base
      .
    else
      assign
        buf_contract.balance-plat      = buf_contract.balance-plat      - p-sum
        buf_contract.balance-plat-rubl = buf_contract.balance-plat-rubl - p-sum-rubl
        buf_contract.balance-plat-base = buf_contract.balance-plat-base - p-sum-base
      .
  end.
end.
