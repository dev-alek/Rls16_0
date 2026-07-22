block-level on error undo, throw.
define input parameter p-host-code       like ub.contract.host-code no-undo .
define input parameter p-contract-code    like ub.contract.contract-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlcontr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xmlcontr.p $":U .
define variable vss-description as character no-undo init "Выгрузка договора в формате xml".
define variable varr-b  as character no-undo.
define variable vartype as character no-undo.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function xml-doc_replacespecsymbols returns char (input sinput as char).
  assign
    sinput = replace(sinput, '&', "&#038;")
    sinput = replace(sinput, '"', "&#034;")
    sinput = replace(sinput, '<', "&#060;")
    sinput = replace(sinput, '>', "&#062;")
    sinput = replace(sinput, chr(10), "&#010;")
  .
  return sinput.
end function.
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  define buffer buf_contract for ub.contract.
  define buffer buf_contract-attr for ub.contract-attr .
  define buffer buf_contract-specif for ub.contract-specif.
  define stream contr-out.
  if paroutput-file = ?  or paroutput-file = "" then do:
    output stream contr-out to value ("./" + "f":U + string(p-contract-code) + ".tmp").
    run write-string in this-procedure (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10) ).
  end.
  else do:
    if p-first-document then do:
      output stream contr-out to value (paroutput-file).
      run write-string in this-procedure (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10) ).
    end.
    else do:
      output stream contr-out to value(paroutput-file) append.
    end.
  end.
  find first buf_contract no-lock
    where buf_contract.host-code = p-host-code
      AND buf_contract.contract-code = p-contract-code
  no-error .
  if not available buf_contract then do:
    return error substitute ("Не найден договор: фирма &1 вн номер &2", p-host-code, p-contract-code).
  end.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'contract') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-code', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host-code', xml-doc_ReplaceSpecSymbols(string(buf_contract.host-code))) + v-suffix ) .
if buf_contract.contract-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-date', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_contract.contract-date-beg <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-date-beg', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-date-beg, '99.99.9999':U))) + v-suffix ) .
end.
if buf_contract.contract-date-end <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-date-end', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-date-end, '99.99.9999':U))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-type', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'status_', xml-doc_ReplaceSpecSymbols(string(buf_contract.status_))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-prn-code', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-prn-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-city', xml-doc_ReplaceSpecSymbols(string(buf_contract.contract-city))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'curr-code', xml-doc_ReplaceSpecSymbols(string(buf_contract.curr-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'usl-opl', xml-doc_ReplaceSpecSymbols(string(buf_contract.usl-opl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'srok-opl', xml-doc_ReplaceSpecSymbols(string(buf_contract.srok-opl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'doc-type', xml-doc_ReplaceSpecSymbols(string(buf_contract.doc-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'str-uslov-oplat', xml-doc_ReplaceSpecSymbols(string(buf_contract.str-uslov-oplat))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fin-VAT-pc', xml-doc_ReplaceSpecSymbols(string(buf_contract.fin-VAT-pc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'pay-nal', xml-doc_ReplaceSpecSymbols(string(buf_contract.pay-nal))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-db-num', xml-doc_ReplaceSpecSymbols(string(buf_contract.user-db-num))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.user-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'auto-pay', xml-doc_ReplaceSpecSymbols(string(buf_contract.auto-pay))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'client', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-type + string(buf_contract.cli-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-addres', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-addres))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-inn', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-inn))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-kpp', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-kpp))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-bank-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-bank-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-bik', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-bik))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-r-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-r-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-c-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-c-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-sign-post', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-sign-post))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-sign', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-sign))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-code-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-code-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-code-schet-start', xml-doc_ReplaceSpecSymbols(string(buf_contract.cli-code-schet-start))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-addres', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-addres))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-inn', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-inn))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-kpp', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-kpp))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-bank-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-bank-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-bik', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-bik))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-r-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-r-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-c-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-c-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-sign-post', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-sign-post))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-sign', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-sign))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-code-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-code-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-code-schet-start', xml-doc_ReplaceSpecSymbols(string(buf_contract.own-code-schet-start))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posrednik', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-type + string(buf_contract.posr-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-addres', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-addres))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-inn', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-inn))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-kpp', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-kpp))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-bank-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-bank-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-bik', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-bik))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-r-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-r-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-c-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-c-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-sign-post', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-sign-post))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-sign', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-sign))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-code-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-code-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'posr-code-schet-start', xml-doc_ReplaceSpecSymbols(string(buf_contract.posr-code-schet-start))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agent', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-type + string(buf_contract.agnt-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-addres', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-addres))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-inn', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-inn))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-kpp', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-kpp))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-bank-name', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-bank-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-bik', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-bik))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-r-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-r-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-c-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-c-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-sign-post', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-sign-post))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-sign', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-sign))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-code-schet', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-code-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'agnt-code-schet-start', xml-doc_ReplaceSpecSymbols(string(buf_contract.agnt-code-schet-start))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'mngr-code', xml-doc_ReplaceSpecSymbols(string(buf_contract.mngr-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc-in', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc-in))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'an-uchet-code-in', xml-doc_ReplaceSpecSymbols(string(buf_contract.an-uchet-code-in))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cel-nazn-code-in', xml-doc_ReplaceSpecSymbols(string(buf_contract.cel-nazn-code-in))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc1-in', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc1-in))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc-out', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc-out))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'an-uchet-code-out', xml-doc_ReplaceSpecSymbols(string(buf_contract.an-uchet-code-out))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cel-nazn-code-out', xml-doc_ReplaceSpecSymbols(string(buf_contract.cel-nazn-code-out))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc1-out', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc1-out))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc-in-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc-in-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'an-uchet-code-in-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.an-uchet-code-in-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cel-nazn-code-in-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.cel-nazn-code-in-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc1-in-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc1-in-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc-out-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc-out-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'an-uchet-code-out-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.an-uchet-code-out-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cel-nazn-code-out-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.cel-nazn-code-out-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc1-out-cash', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc1-out-cash))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc-in-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc-in-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'an-uchet-code-in-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.an-uchet-code-in-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cel-nazn-code-in-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.cel-nazn-code-in-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc1-in-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc1-in-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc-out-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc-out-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'an-uchet-code-out-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.an-uchet-code-out-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cel-nazn-code-out-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.cel-nazn-code-out-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cor-acc1-out-payoff', xml-doc_ReplaceSpecSymbols(string(buf_contract.cor-acc1-out-payoff))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'spec-prc', xml-doc_ReplaceSpecSymbols(string(buf_contract.spec-prc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'spec-check', xml-doc_ReplaceSpecSymbols(string(buf_contract.spec-check))) + v-suffix ) .
for first buf_contract-attr no-lock where buf_contract-attr.host-code = buf_contract.host-code and buf_contract-attr.contract-code = buf_contract.contract-code and
buf_contract-attr.attr-code = "contract-edi":
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'edi', xml-doc_ReplaceSpecSymbols(string(if buf_contract-attr.attr-value = "yes" then "1" else "0"))) + v-suffix ) .
end.
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'contract') + chr(10))).
for each buf_contract-specif no-lock
    where buf_contract-specif.contract-num = buf_contract.contract-code
    AND   buf_contract-specif.host-code = buf_contract.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'contract-specif') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-num', xml-doc_ReplaceSpecSymbols(string(buf_contract-specif.contract-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host-code', xml-doc_ReplaceSpecSymbols(string(buf_contract-specif.host-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gds-code', xml-doc_ReplaceSpecSymbols(string(buf_contract-specif.gds-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'price-cli', xml-doc_ReplaceSpecSymbols(string(buf_contract-specif.price-cli))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'prc', xml-doc_ReplaceSpecSymbols(string(buf_contract-specif.prc))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'contract-specif') + chr(10))).
end.
  if paroutput-file = ?  or paroutput-file = "" then do:
    run write-string in this-procedure (input '</root>':u + chr(10)).
  end.
  else do:
    if p-last-document then  run write-string in this-procedure (input '</root>':u + chr(10)).
  end.
  output stream contr-out close.
  if paroutput-file = ?  or paroutput-file = "" then do:
    if search ("./" + "f":U + string(p-contract-code) + ".xml") <> ? then do:
      os-delete value ("./" + "f":U + string(p-contract-code) + ".xml").
    end.
    os-copy value ("./" + "f":U + string(p-contract-code) + ".tmp") value ("./" + "f":U + string(p-contract-code) + ".xml").
    os-delete value ("./" + "f":U +  string(p-contract-code) + ".tmp").
    run gbl/filename.p (
                  input "./" + "f":U + string(p-contract-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  end.
  procedure write-string :
    define input parameter parstring as character no-undo.
    put stream contr-out unformatted parstring.
  end.
