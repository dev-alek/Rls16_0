block-level on error undo, throw.
define input parameter p-host-code       like ub.fin-doc.host-code no-undo .
define input parameter p-fin-doc-code    like ub.fin-doc.fin-doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlfdoc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xmlfdoc.p $":U .
define variable vss-description as character no-undo init "Выгрузка платежа в формате xml".
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
  define buffer buf_fin-doc-tax          for ub.fin-doc-tax.
  define buffer buf_fin-doc              for ub.fin-doc.
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
define stream fin-doc-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream fin-doc-out to value ("./" + "f":U + string(p-fin-doc-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
     ).
end.
else do:
  if p-first-document then do:
    output stream fin-doc-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
      ).
  end.
  else do:
    output stream fin-doc-out to value(paroutput-file) append.
  end.
end.
 find first buf_fin-doc no-lock where
           buf_fin-doc.host-code = p-host-code
       AND buf_fin-doc.fin-doc-code = p-fin-doc-code no-error .
if not available buf_fin-doc then do:
  return error substitute ("Не найден финансовый документ: фирма &1 вн номер &2", p-host-code, p-fin-doc-code).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'findoc') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.fin-doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cashbookid', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cashbookid))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentCodeOperation', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.fin-ext-doc-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentStatus', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.status_))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.host-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDocCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.prn-doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'object', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.obj-type + string(buf_fin-doc.obj-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDateDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.doc-date, '99.99.9999':U))) + v-suffix ) .
if buf_fin-doc.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDateFact', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.fact-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_fin-doc.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDatePay', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.pay-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_fin-doc.perm-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDatePermission', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.perm-date, '99.99.9999':U))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDocDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-db-num-doc))) + v-suffix ) .
if buf_fin-doc.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentFactDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-db-num-fact))) + v-suffix ) .
end.
if buf_fin-doc.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentPayDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-db-num-pl))) + v-suffix ) .
end.
if buf_fin-doc.perm-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentPermissionDBNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-db-num-perm))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDocUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-name-doc))) + v-suffix ) .
if buf_fin-doc.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentFactUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-name-fact))) + v-suffix ) .
end.
if buf_fin-doc.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentPayUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-name-pl))) + v-suffix ) .
end.
if buf_fin-doc.perm-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentPermissionUserName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.user-name-perm))) + v-suffix ) .
end.
find first buf_currency no-lock where
          buf_currency.curr-code = buf_fin-doc.curr-code no-error .
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
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentCrcCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.curr-code))) + v-suffix ) .
if v-exch-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-exch-abbr))) + v-suffix ) .
end.
if v-exch-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentCrcname', xml-doc_ReplaceSpecSymbols(string(v-exch-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.exch-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.exch-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualPaymentCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.actual-exch-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualPaymentCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.actual-exch-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcCode', xml-doc_ReplaceSpecSymbols(string(v-base-code))) + v-suffix ) .
if v-base-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-base-abbr))) + v-suffix ) .
end.
if v-base-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcname', xml-doc_ReplaceSpecSymbols(string(v-base-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.base-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.base-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualBaseCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.actual-base-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualBaseCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.actual-base-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conStat', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.con-stat))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.con-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'conSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.con-sum-rubl))) + v-suffix ) .
if buf_fin-doc.contract-code <> 0 then do:
  find first buf_contract no-lock where
            buf_contract.contract-code = buf_fin-doc.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.contract-code))) + v-suffix ) .
  if v-contract-prn-code <> "":U then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractNo', xml-doc_ReplaceSpecSymbols(string(v-contract-prn-code))) + v-suffix ) .
  end.
  if v-contract-date <> ? then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractDate', xml-doc_ReplaceSpecSymbols(string(v-contract-date, '99.99.9999':U))) + v-suffix ) .
  end.
  find first buf_currency no-lock where
            buf_currency.curr-code = buf_fin-doc.contract-curr no-error .
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
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumcontract', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.sum-contr))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.contract-curr))) + v-suffix ) .
  if v-exch-abbr <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-contr-abbr))) + v-suffix ) .
  end.
  if v-exch-name <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcname', xml-doc_ReplaceSpecSymbols(string(v-contr-name))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.contract-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.contract-scale))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualContractCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.actual-contract-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'actualContractCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.actual-contract-scale))) + v-suffix ) .
end.
if buf_fin-doc.an-uchet-code <> 0 then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'analiticCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.an-uchet-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'analiticCodeValue', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.an-uchet-value))) + v-suffix ) .
end.
if buf_fin-doc.cel-nazn-code <> 0 then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'destinationCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cel-nazn-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'destinationCodeValue', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cel-nazn-value))) + v-suffix ) .
end.
if buf_fin-doc.cor-acc <> 0 then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'corAccCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cor-acc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'corAccCodeValue', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cor-acc-value))) + v-suffix ) .
end.
if buf_fin-doc.cor-acc1 <> 0 then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'corAcc1Code', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cor-acc1))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'corAcc1CodeValue', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cor-acc1-value))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentPurpose', xml-doc_ReplaceSpecSymbols(string(replace(buf_fin-doc.naznach-plat, "@", "":U)))) + v-suffix ) .
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'enclosure', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.enclosure))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U
or buf_fin-doc.fin-doc-type = 'апп':U
or buf_fin-doc.fin-doc-type = 'апр':U
then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'strDepart', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.str-podr-type + string(buf_fin-doc.str-podr-code)))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'strDepartName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.str-podr-name))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'апп':U
or buf_fin-doc.fin-doc-type = 'апр':U then do:
  if num-entries(buf_fin-doc.payer-sign1, chr(4)) > 1 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fromPayerHeadPosition', xml-doc_ReplaceSpecSymbols(string(entry(1, buf_fin-doc.payer-sign1, chr(4))))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fromPayer', xml-doc_ReplaceSpecSymbols(string(entry(2, buf_fin-doc.payer-sign1, chr(4))))) + v-suffix ) .
  end.
  else do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fromPayer', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-sign1))) + v-suffix ) .
  end.
  if num-entries(buf_fin-doc.receiver-sign1, chr(4)) > 1 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fromReceiverHeadPosition', xml-doc_ReplaceSpecSymbols(string(entry(1, buf_fin-doc.receiver-sign1, chr(4))))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fromReceiver', xml-doc_ReplaceSpecSymbols(string(entry(2, buf_fin-doc.receiver-sign1, chr(4))))) + v-suffix ) .
  end.
  else do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fromReceiver', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-sign1))) + v-suffix ) .
  end.
end.
if buf_fin-doc.fin-doc-type = 'пко':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'seniorAccounter', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-sign2))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cashier', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-sign3))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'рко':U then do:
  if num-entries(buf_fin-doc.payer-sign1, chr(4)) > 1 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerHeadPosition', xml-doc_ReplaceSpecSymbols(string(entry(1, buf_fin-doc.payer-sign1, chr(4))))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerDirector', xml-doc_ReplaceSpecSymbols(string(entry(2, buf_fin-doc.payer-sign1, chr(4))))) + v-suffix ) .
  end.
  else do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerDirector', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-sign1))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'seniorAccounter', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-sign2))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cashier', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-sign3))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerDirector', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-sign1))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'seniorAccounter', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-sign2))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'пко':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'including', xml-doc_ReplaceSpecSymbols(string(replace(buf_fin-doc.including, "@":U, "":U)))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentQueue', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.ocher-pl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentPurposeCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.nazn-pl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'f22', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f23))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'f23ReservField', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f23))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'operationType', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.vid-opl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentType', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.vid-plat))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentTerm', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.srok-pl))) + v-suffix ) .
  if buf_fin-doc.stat-pl <> "":U then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxPayerStatus', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.stat-pl))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'KBK', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f104))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'OKATO', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f105))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxPaymentBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f106))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxPeriod', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f107))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxDocumentNo', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f108))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxDocumentDAte', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f109))) + v-suffix ) .
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxPaymentType', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.f110))) + v-suffix ) .
  end.
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payer', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-type + string(buf_fin-doc.payer-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-name))) + v-suffix ) .
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerINN', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-INN))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerKPP', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-KPP))) + v-suffix ) .
  if false then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerOKPO', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-OKPO))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerBankName', xml-doc_ReplaceSpecSymbols(string((buf_fin-doc.payer-bank-name + chr(44) + chr(32) + buf_fin-doc.payer-bank-city)))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerBIK', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-bIK))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerAccountCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-code-schet))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-r-schet))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerCorrAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-c-schet))) + v-suffix ) .
end.
if buf_fin-doc.payer-dop1 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerAddInfo1', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-dop1))) + v-suffix ) .
end.
if buf_fin-doc.payer-dop2 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerAddInfo2', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-dop2))) + v-suffix ) .
end.
if buf_fin-doc.payer-dop3 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerAddInfo3', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-dop3))) + v-suffix ) .
end.
if buf_fin-doc.payer-dop4 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerAddInfo4', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-dop4))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U then do:
  if buf_fin-doc.payer-passport <> "":U then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'payerPassport', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.payer-passport))) + v-suffix ) .
  end.
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiver', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-type + string(buf_fin-doc.receiver-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverName', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-name))) + v-suffix ) .
if buf_fin-doc.fin-doc-type = 'ппп':U
or buf_fin-doc.fin-doc-type = 'рпп':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverINN', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-INN))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverKPP', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-KPP))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverBankName', xml-doc_ReplaceSpecSymbols(string((buf_fin-doc.receiver-bank-name + chr(44) + chr(32) + buf_fin-doc.receiver-bank-city)))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverBIK', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-bIK))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverAccountCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-code-schet))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-r-schet))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverCorrAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-c-schet))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'пко':U or buf_fin-doc.fin-doc-type = 'апп':U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverOKPO', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-OKPO))) + v-suffix ) .
end.
if buf_fin-doc.receiver-dop1 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverAddInfo1', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-dop1))) + v-suffix ) .
end.
if buf_fin-doc.receiver-dop2 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverAddInfo2', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-dop2))) + v-suffix ) .
end.
if buf_fin-doc.receiver-dop3 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverAddInfo3', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-dop3))) + v-suffix ) .
end.
if buf_fin-doc.receiver-dop4 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverAddInfo4', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-dop4))) + v-suffix ) .
end.
if buf_fin-doc.fin-doc-type = 'пко':U
or buf_fin-doc.fin-doc-type = 'рко':U then do:
  if buf_fin-doc.receiver-passport <> "":U then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverPassport', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.receiver-passport))) + v-suffix ) .
  end.
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'comment', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.PS))) + v-suffix ) .
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'findoc') + chr(10))).
for each buf_fin-doc-tax no-lock
    where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code
    AND   buf_fin-doc-tax.host-code = buf_fin-doc.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'taxLine') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'paymentDocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.fin-doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cashbookid', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc.cashbookid))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'taxLineNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.line-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-line-doc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-line-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-line-base))) + v-suffix ) .
  if buf_fin-doc.contract-code <> 0 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumContr', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-line-contr))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-vat-line-doc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-vat-line-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-vat-line-base))) + v-suffix ) .
  if buf_fin-doc.contract-code <> 0 then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumContr', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.sum-vat-line-contr))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVat', xml-doc_ReplaceSpecSymbols(string(buf_fin-doc-tax.vat-pc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineWithVat', xml-doc_ReplaceSpecSymbols(string((if buf_fin-doc-tax.with-vat then "yes" else "no")))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'taxLine') + chr(10))).
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
output stream fin-doc-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "f":U + string(p-fin-doc-code) + ".xml") <> ? then do:
     os-delete value ("./" + "f":U + string(p-fin-doc-code) + ".xml").
  end.
  os-copy value ("./" + "f":U + string(p-fin-doc-code) + ".tmp") value ("./" + "f":U + string(p-fin-doc-code) + ".xml").
  os-delete value ("./" + "f":U +  string(p-fin-doc-code) + ".tmp").
  run gbl/filename.p (
                  input "./" + "f":U + string(p-fin-doc-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream fin-doc-out unformatted parstring.
end.
