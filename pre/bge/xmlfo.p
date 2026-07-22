block-level on error undo, throw.
define input parameter p-host-code       like ub.fin-ob.host-code no-undo .
define input parameter p-doc-code        like ub.fin-ob.doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlfo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/xmlfo.p $":U .
define variable vss-description as character no-undo init "Выгрузка ФО в формате xml".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-doc-code      as character    no-undo.
  define variable v-exch-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-exch-name       like ub.currency.curr-name no-undo .
  define variable v-contr-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-contr-name       like ub.currency.curr-name no-undo .
  define variable v-contract-prn-code like ub.contract.contract-prn-code no-undo .
  define variable v-contract-date     like ub.contract.contract-date no-undo .
  define buffer buf_fin-ob-tax-before          for ub.fin-ob-tax-before.
  define buffer buf_fin-ob-tax          for ub.fin-ob-tax.
  define buffer buf_fin-ob              for ub.fin-ob.
  define buffer buf_fin-ob-before       for ub.fin-ob-before.
  define buffer buf_fin-ob-trn          for ub.fin-ob-trn.
  define buffer buf_fin-gds-part        for ub.fin-gds-part.
  define buffer buf_fin-connect         for ub.fin-connect.
  define buffer buf_contract for ub.contract.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .
  define buffer buf_currency for ub.currency.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
  find first buf_currency no-lock where
            buf_currency.curr-code = v-base-code no-error .
  if available buf_currency then
  assign
  v-base-abbr = buf_currency.curr-abbr
  v-base-name = buf_currency.curr-name
  .
define stream fin-ob-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream fin-ob-out to value ("./" + "fo":U + string(p-doc-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
     ).
end.
else do:
  if p-first-document then do:
    output stream fin-ob-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
      ).
  end.
  else do:
    output stream fin-ob-out to value(paroutput-file) append.
  end.
end.
 find first buf_fin-ob no-lock where
           buf_fin-ob.host-code = p-host-code
       AND buf_fin-ob.doc-code = p-doc-code no-error .
if not available buf_fin-ob then do:
  return error substitute ("Не найдено ФО: фирма &1 вн номер &2", p-host-code, p-doc-code).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'fin-ob') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Status_', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.status_))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.host-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.prn-doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'object', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.obj-type + string(buf_fin-ob.obj-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DateDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.doc-date, '99.99.9999':U))) + v-suffix ) .
if buf_fin-ob.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DateFact', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.fact-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_fin-ob.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DatePay', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.pay-date, '99.99.9999':U))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.user-db-num-doc))) + v-suffix ) .
if buf_fin-ob.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'FactDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.user-db-num-fact))) + v-suffix ) .
end.
if buf_fin-ob.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'PayDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.user-db-num-pay))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.user-name-doc))) + v-suffix ) .
if buf_fin-ob.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'FactUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.user-name-fact))) + v-suffix ) .
end.
if buf_fin-ob.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'PayUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.user-name-pay))) + v-suffix ) .
end.
find first buf_currency no-lock where
          buf_currency.curr-code = buf_fin-ob.curr-code no-error .
if available buf_currency then
assign
v-exch-abbr = buf_currency.curr-abbr
v-exch-name = buf_currency.curr-name
.
else
assign
v-exch-abbr = "":U
v-exch-name = "":U
.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.curr-code))) + v-suffix ) .
if v-exch-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-exch-abbr))) + v-suffix ) .
end.
if v-exch-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Crcname', xml-doc_ReplaceSpecSymbols(string(v-exch-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.exch-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.exch-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.actual-exch-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.actual-exch-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcCode', xml-doc_ReplaceSpecSymbols(string(v-base-code))) + v-suffix ) .
if v-base-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-base-abbr))) + v-suffix ) .
end.
if v-base-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcname', xml-doc_ReplaceSpecSymbols(string(v-base-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.base-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.base-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualBaseCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.actual-base-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualBaseCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.actual-base-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conStat', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.con-stat))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.con-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.con-sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-tax-doc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-tax-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-tax-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-tax-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-tax-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-tax-base))) + v-suffix ) .
               run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.con-sum-doc))) + v-suffix ) .
if buf_fin-ob.contract-code <> 0 then do:
  find first buf_contract no-lock where
            buf_contract.host-code     = buf_fin-ob.host-code and
            buf_contract.contract-code = buf_fin-ob.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.contract-code))) + v-suffix ) .
  if v-contract-prn-code <> "":U then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractNo', xml-doc_ReplaceSpecSymbols(string(v-contract-prn-code))) + v-suffix ) .
  end.
  if v-contract-date <> ? then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractDate', xml-doc_ReplaceSpecSymbols(string(v-contract-date, '99.99.9999':U))) + v-suffix ) .
  end.
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-ob.contract-curr no-error .
  if available buf_currency then
  assign
  v-contr-abbr = buf_currency.curr-abbr
  v-contr-name = buf_currency.curr-name
  .
  else
  assign
  v-contr-abbr = "":U
  v-contr-name = "":U
  .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumcontract', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-contr))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.contract-curr))) + v-suffix ) .
  if v-exch-abbr <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-contr-abbr))) + v-suffix ) .
  end.
  if v-exch-name <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcname', xml-doc_ReplaceSpecSymbols(string(v-contr-name))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.contract-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.contract-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualContractCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.actual-contract-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualContractCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.actual-contract-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conSumcontract', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.con-sum-contr))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumTaxContract', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.sum-tax-contract))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payer', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.payer-type + string(buf_fin-ob.payer-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerName', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.payer-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiver', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.receiver-type + string(buf_fin-ob.receiver-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverName', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.receiver-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'comment', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.PS))) + v-suffix ) .
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'fin-ob') + chr(10))).
for each buf_fin-ob-tax no-lock
    where buf_fin-ob-tax.doc-code  = buf_fin-ob.doc-code
    AND   buf_fin-ob-tax.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'taxLine') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxLineNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.line-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-line-doc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-line-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-line-base))) + v-suffix ) .
  if buf_fin-ob.contract-code <> 0 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumContr', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-line-contr))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-vat-line-doc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-vat-line-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-vat-line-base))) + v-suffix ) .
  if buf_fin-ob.contract-code <> 0 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumContr', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-vat-line-contr))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVat', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.vat-pc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineWithVat', xml-doc_ReplaceSpecSymbols(string((if buf_fin-ob-tax.with-vat then "yes" else "no")))) + v-suffix ) .
  if buf_fin-ob-tax.SLT-pc <> 0 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSLTSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-SLT-line-doc))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSLTSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-SLT-line-rubl))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSLTSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-SLT-line-base))) + v-suffix ) .
    if buf_fin-ob.contract-code <> 0 then do:
                  run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSLTSumContr', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.sum-SLT-line-contr))) + v-suffix ) .
    end.
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSLT', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-tax.SLT-pc))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineWithSLT', xml-doc_ReplaceSpecSymbols(string((if buf_fin-ob-tax.with-SLT then "yes" else "no")))) + v-suffix ) .
  end.
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'taxLine') + chr(10))).
end.
for each buf_fin-ob-trn no-lock
    where buf_fin-ob-trn.doc-code  = buf_fin-ob.doc-code
    AND   buf_fin-ob-trn.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'finObTrn') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob.doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'TrnDocId', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-trn.trn-doc-code))) + v-suffix ) .
  if buf_fin-ob-trn.ps <> "" then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Comment', xml-doc_ReplaceSpecSymbols(string(buf_fin-ob-trn.ps))) + v-suffix ) .
  end.
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'finObTrn') + chr(10))).
end.
for each buf_fin-gds-part no-lock
    where buf_fin-gds-part.fin-ob-code  = buf_fin-ob.doc-code
    AND   buf_fin-gds-part.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'finParts') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.fin-ob-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gds-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.gds-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'doc-qnty', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.doc-qnty))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'exch-rate', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.exch-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'exch-scale', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.exch-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'base-rate', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.base-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'base-scale', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.base-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-date', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.fact-date, '99.99.9999':U))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-qnty', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.fact-qnty))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-time', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.fact-time))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'part-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.part-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'in-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.in-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'out-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.out-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'object', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.obj-type + string(buf_fin-gds-part.obj-code)))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'other-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.other-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'other-contract', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.other-contract))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'other-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.other-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'road-tax-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.road-tax-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'road-tax-contract', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.road-tax-contract))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'road-tax-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.road-tax-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'status_dop', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.status_dop))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.sum-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-contract', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.sum-contract))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.sum-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'transport-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.transport-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'transport-contract', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.transport-contract))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'transport-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.transport-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-db-num', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.user-db-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-name', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.user-name))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'vat-pc', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.vat-pc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'vat-type', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.vat-type))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'vat-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.vat-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'vat-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.vat-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'vat-contract', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.vat-contract))) + v-suffix ) .
  if buf_fin-gds-part.SLT-pc <> 0 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'SLT-pc', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.SLT-pc))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'SLT-type', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.SLT-type))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'slt-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.slt-rubl))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'slt-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.slt-base))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'slt-contract', xml-doc_ReplaceSpecSymbols(string(buf_fin-gds-part.slt-contract))) + v-suffix ) .
  end.
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'finParts') + chr(10))).
end.
for each buf_fin-connect no-lock
    where buf_fin-connect.fin-ob-code  = buf_fin-ob.doc-code
    AND   buf_fin-connect.host-code = buf_fin-ob.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'finConnect') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.fin-ob-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'PS', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.PS))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'base-rate', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.base-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'base-scale', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.base-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'connect-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.connect-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.contract-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-curr', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.contract-curr))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-rate', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.contract-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-scale', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.contract-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'curr-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.curr-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'exch-rate', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.exch-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'exch-scale', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.exch-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-date', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.fact-date, '99.99.9999':U))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-time', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.fact-time))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fin-doc-code', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.fin-doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.host-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'status_', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.status_))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-base-ob', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-base-ob))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-base', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-contr-ob', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-contr-ob))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-contr', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-contr))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-doc', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-doc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-rubl-ob', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-rubl-ob))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-rubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.sum-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-db-num', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.user-db-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-name', xml-doc_ReplaceSpecSymbols(string(buf_fin-connect.user-name))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'finConnect') + chr(10))).
end.
if paroutput-file = ?  or
   paroutput-file = "" then do:
   run write-string in this-procedure
     (input '</root>':u + chr(10)).
end.
else do:
  if p-last-document then do:
    run write-string in this-procedure
      (input '</root>':u + chr(10)).
  end.
end.
output stream fin-ob-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "fo":U + string(p-doc-code) + ".xml") <> ? then do:
     os-delete value ("./" + "fo":U + string(p-doc-code) + ".xml").
  end.
  os-copy value ("./" + "fo":U + string(p-doc-code) + ".tmp") value ("./" + "fo":U + string(p-doc-code) + ".xml").
  os-delete value ("./" + "fo":U +  string(p-doc-code) + ".tmp").
  run gbl/filename.p
   (              input "./" + "fo":U + string(p-doc-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream fin-ob-out unformatted parstring.
end.
