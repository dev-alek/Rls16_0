block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 8af0ca92507d, 852, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Oct 19 12:26:26 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: limcontr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/limcontr.p $":U .
define variable vss-description as character no-undo init "проверка на превышение лимита кредита по договору".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-type          as integer   no-undo .
define input  parameter p-sum-rubl      as decimal   no-undo .
define input  parameter p-sum-base      as decimal   no-undo .
define buffer buf_contract for ub.contract.
define variable v-exch-rate   as decimal   no-undo .
define variable v-exch-scale  as integer   no-undo .
define variable v-curr-abbr   as character no-undo .
define variable v-kredit-sum  as decimal   no-undo .
find first buf_contract no-lock
  where buf_contract.host-code     = p-host-code
    and buf_contract.contract-code = p-contract-code
no-error .
if available buf_contract and buf_contract.kredit-limit = yes then do:
  assign v-kredit-sum = buf_contract.kredit-sum .
  if buf_contract.curr-code > 0 then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_contract.curr-code
  ,input  today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  )  .
    assign v-kredit-sum = v-kredit-sum * v-exch-rate / v-exch-scale .
  end.
    case p-type :
      when 0 then do:
        if buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl + p-sum-rubl > v-kredit-sum then
          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 руб; лимит &3 руб; сумма по документу: &4 руб', p-contract-code, buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl, v-kredit-sum , p-sum-base) .
      end.
      when 1 then do:
        if buf_contract.balance-fo-base - buf_contract.balance-plat-base + p-sum-base > v-kredit-sum then
          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 ; лимит &3 ; сумма по документу: &4 ', p-contract-code, buf_contract.balance-fo-base - buf_contract.balance-plat-base, v-kredit-sum , p-sum-base) .
      end.
      when 2 then do:
        if buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl + p-sum-rubl > v-kredit-sum or
           buf_contract.balance-fo-base - buf_contract.balance-plat-base + p-sum-base > v-kredit-sum then
          return  ERROR substitute('Превышен лимит кредита по договору (вн.№) &1 : текущий баланс &2 руб; лимит &3 руб; сумма по документу: &4 руб', p-contract-code, buf_contract.balance-fo-rubl - buf_contract.balance-plat-rubl, v-kredit-sum , p-sum-rubl) .
      end.
    end.
  end.
