block-level on error undo, throw.
define input parameter p-host-code       like ub.fin-statement.host-code no-undo .
define input parameter p-sttm-code    like ub.fin-statement.sttm-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmlfstt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xmlfstt.p $":U .
define variable vss-description as character no-undo init "Выгрузка банковской выписки в формате xml".
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
  define buffer buf_fin-statement        for ub.fin-statement.
  define buffer buf_fin-statement-line   for ub.fin-statement-line.
  define variable v-doc-date        like ub.fin-statement.doc-date   no-undo.
  define variable v-fact-date       like ub.fin-statement.fact-date  no-undo.
  define variable v-doc-PS          like ub.fin-statement.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .
  define buffer buf_currency for ub.currency.
  define buffer buf_sysconf for ub.sysconf.
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
  find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code.
define stream fin-sttm-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream fin-sttm-out to value ("./" + "fs":U + string(p-sttm-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
     ).
end.
else do:
  if p-first-document then do:
    output stream fin-sttm-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
      ).
  end.
  else do:
    output stream fin-sttm-out to value(paroutput-file) append.
  end.
end.
 find first buf_fin-statement no-lock where
           buf_fin-statement.host-code = p-host-code
       AND buf_fin-statement.sttm-code = p-sttm-code no-error .
if not available buf_fin-statement then do:
  return error substitute ("Не найдена выписка: фирма &1 вн номер &2", p-host-code, p-sttm-code).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'finstatement') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sttm-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementCodeOperation', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.fins-ext-doc-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStatus', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.status_))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.host-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDocCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.prn-doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDateDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.doc-date, '99.99.9999':U))) + v-suffix ) .
if buf_fin-statement.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDateFact', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.fact-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_fin-statement.bank-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDateBank', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.bank-date, '99.99.9999':U))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDocDBNum', xml-doc_ReplaceSpecSymbols(string(buf_sysconf.firm-db-num))) + v-suffix ) .
find first buf_currency no-lock where
          buf_currency.curr-code = buf_fin-STATEMENT.curr-code no-error .
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
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumDocTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sum-doc-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementCrcCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.curr-code))) + v-suffix ) .
if v-exch-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-exch-abbr))) + v-suffix ) .
end.
if v-exch-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementCrcname', xml-doc_ReplaceSpecSymbols(string(v-exch-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumRublTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sum-rubl-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sumBaseTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.sum-base-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcCode', xml-doc_ReplaceSpecSymbols(string(v-base-code))) + v-suffix ) .
if v-base-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-base-abbr))) + v-suffix ) .
end.
if v-base-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcname', xml-doc_ReplaceSpecSymbols(string(v-base-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartDate', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-date, '99.99.9999':U))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndDate', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.end-date, '99.99.9999':U))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementNumDocs', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.num-docs))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementNumDocsTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.num-docs-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartSumDocTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-sum-doc-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartSumRublTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-sum-rubl-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementStartSumBaseTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.start-sum-base-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.End-sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndSumDocTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.End-sum-doc-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.End-sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndSumRublTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.End-sum-rubl-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.End-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementEndSumBaseTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.End-sum-base-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementInSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.In-sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementInSumDocTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.In-sum-doc-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementInSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.In-sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementInSumRublTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.In-sum-rubl-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementInSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.In-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementInSumBaseTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.In-sum-base-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementOutSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Out-sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementOutSumDocTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Out-sum-doc-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementOutSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Out-sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementOutSumRublTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Out-sum-rubl-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementOutSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Out-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementOutSumBaseTh', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Out-sum-base-th))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementFutureSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Future-sum-doc))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementFutureSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Future-sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementFutureSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.Future-sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAuthor', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.cl-bank))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'holderName', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.cli-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementBankCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.code-bank))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementBankName', xml-doc_ReplaceSpecSymbols(string((buf_fin-statement.bank-name + chr(44) + chr(32) + buf_fin-statement.bank-city)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementBIK', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.bIK))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAccountCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.code-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.r-schet))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementCorrAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.c-schet))) + v-suffix ) .
if buf_fin-statement.dop1 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAddInfo1', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.dop1))) + v-suffix ) .
end.
if buf_fin-statement.dop2 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAddInfo2', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.dop2))) + v-suffix ) .
end.
if buf_fin-statement.dop3 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAddInfo3', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.dop3))) + v-suffix ) .
end.
if buf_fin-statement.dop4 <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementAddInfo4', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.dop4))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'comment', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement.PS))) + v-suffix ) .
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'finstatement') + chr(10))).
for each buf_fin-statement-line no-lock
    where buf_fin-statement-line.sttm = buf_fin-statement.sttm-code
    AND   buf_fin-statement-line.host-code = buf_fin-statement.host-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'statementLine') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementDocID', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.sttm-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'statementLineNum', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.line-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumDoc', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.sum-doc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.sum-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumBase', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.sum-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineCodeOperation', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.fin-ext-doc-type))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineDatePay', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.pay-date, '99.99.9999':U))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineDocCode', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.prn-doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineCorrAccount', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.rp-c-schet))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineComment', xml-doc_ReplaceSpecSymbols(string(buf_fin-statement-line.ps))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'statementLine') + chr(10))).
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
output stream fin-sttm-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "fs":U + string(p-sttm-code) + ".xml") <> ? then do:
     os-delete value ("./" + "fs":U + string(p-sttm-code) + ".xml").
  end.
  os-copy value ("./" + "fs":U + string(p-sttm-code) + ".tmp") value ("./" + "fs":U + string(p-sttm-code) + ".xml").
  os-delete value ("./" + "fs":U +  string(p-sttm-code) + ".tmp").
  run gbl/filename.p (
                  input "./" + "fs":U + string(p-sttm-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream fin-sttm-out unformatted parstring.
end.
