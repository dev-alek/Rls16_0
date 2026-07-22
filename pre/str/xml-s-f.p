block-level on error undo, throw.
DEFINE INPUT  PARAMETER parparentproc        AS WIDGET-HANDLE        NO-UNDO.
define input parameter p-host-code   like ub.schet-fact-doc.host-code no-undo .
define input parameter p-doc-code    like ub.schet-fact-doc.doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xml-s-f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/xml-s-f.p $":U .
define variable vss-description as character no-undo init "Выгрузка счета-фактуры в формате xml".
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
initial "@(#)$Workfile$".
  define buffer buf_schet-fact-doc  for ub.schet-fact-doc.
  define buffer buf_schet-fact-line for ub.schet-fact-line.
  define variable g#db-num as integer   no-undo .
  run get-db-num  in parParentProc ( output g#db-num ).
  define stream contr-out.
  if paroutput-file = ?  or paroutput-file = "" then do:
    output stream contr-out to value ("./" + "f":U + string(p-doc-code) + ".tmp").
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
  find first buf_schet-fact-doc no-lock
    where buf_schet-fact-doc.host-code = p-host-code
      AND buf_schet-fact-doc.doc-code  = p-doc-code
  no-error .
  if not available buf_schet-fact-doc then do:
    return error substitute ("Не найден счет-фактура: фирма &1 номер &2", p-host-code, p-doc-code).
  end.
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$".
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'header') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fileName', xml-doc_ReplaceSpecSymbols(string(string( "f":U + string(p-doc-code) + ".xml")))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fileNumber', xml-doc_ReplaceSpecSymbols(string(string(1)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'HostList', xml-doc_ReplaceSpecSymbols(string(string(p-host-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'docName', xml-doc_ReplaceSpecSymbols(string("schet-fact"))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'version', xml-doc_ReplaceSpecSymbols(string("15.0 " + replace( vss-revision + vss-date, "$", " " )))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'exportDate', xml-doc_ReplaceSpecSymbols(string(string( today,          "99/99/9999" )))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'exportTime', xml-doc_ReplaceSpecSymbols(string(string( time,           "HH:MM:SS"   )))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseNum', xml-doc_ReplaceSpecSymbols(string(g#db-num))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DateFrom', xml-doc_ReplaceSpecSymbols(string(""))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DateTo', xml-doc_ReplaceSpecSymbols(string(""))) + v-suffix ) .
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'header') + chr(10))).
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'schet-fact-doc') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'doc-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'doc-date', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.doc-date, '99.99.9999':U))) + v-suffix ) .
if buf_schet-fact-doc.pay-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'pay-date', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.pay-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_schet-fact-doc.in-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'in-date', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.in-date, '99.99.9999':U))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'doc-type', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.doc-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'ext-doc-type', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.ext-doc-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'status_', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.status_))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contract-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.contract-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.host-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'book-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.book-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'obj-type', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.obj-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'obj-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.obj-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-type', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.cli-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.cli-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-name', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.cli-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-inn', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.cli-inn))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'cli-address', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.cli-address))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Gruz-otprav', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.Gruz-otprav))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Gruz-poluch', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.Gruz-poluch))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-name', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.own-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-inn', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.own-inn))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'own-address', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.own-address))) + v-suffix ) .
if buf_schet-fact-doc.fact-order <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-order', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.fact-order))) + v-suffix ) .
end.
if buf_schet-fact-doc.in-doc-code <> "" then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'in-doc-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.in-doc-code))) + v-suffix ) .
end.
if buf_schet-fact-doc.in-doc-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'in-doc-date', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.in-doc-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_schet-fact-doc.base-rate <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'base-rate', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.base-rate))) + v-suffix ) .
end.
if buf_schet-fact-doc.base-scale <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'base-scale', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.base-scale))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-20-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-20-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-20-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.VAT-20-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-10-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-10-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-10-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.VAT-10-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-0-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-0-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-no-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-no-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-20-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-20-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-20-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.VAT-20-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-10-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-10-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-10-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.VAT-10-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-0-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-0-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-VAT-no-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sum-VAT-no-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'PS', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.PS))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'out-code-list', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.out-code-list))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gtd', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.gtd))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'country', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.country))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-user-db-num', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.fact-user-db-num))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-user-name', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.fact-user-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-db-num', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.user-db-num))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'user-name', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.user-name))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'PS', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.PS))) + v-suffix ) .
if buf_schet-fact-doc.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-date', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.fact-date, '99.99.9999':U))) + v-suffix ) .
end.
if buf_schet-fact-doc.fact-time <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-time', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.fact-time))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sys-date', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sys-date, '99.99.9999':U))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sys-time', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.sys-time))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'office', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.office))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'curr-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-doc.curr-code))) + v-suffix ) .
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'schet-fact-doc') + chr(10))).
for each buf_schet-fact-line no-lock
    where buf_schet-fact-line.doc-code = buf_schet-fact-doc.doc-code
    AND   buf_schet-fact-line.db-num = buf_schet-fact-doc.db-num
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'schet-fact-line') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'doc-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gds-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.gds-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-qnty', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.fact-qnty))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'price-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.price-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'price-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.price-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.sum-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.sum-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.VAT-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.VAT-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-rubl-VAT', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.sum-rubl-VAT))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'sum-base-VAT', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.sum-base-VAT))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'obj-type', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.obj-type))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'obj-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.obj-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VAT-pc', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.VAT-pc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'ext-doc-type', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.ext-doc-type))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'fact-order', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.fact-order))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'status_', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.status_))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'line-num', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.line-num))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'excise', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.excise))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'other-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.other-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'other-rubl', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.other-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gtd', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.gtd))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'country', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.country))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'host-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.host-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gds-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.gds-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'in-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.in-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'part-code', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.part-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'gds-name', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.gds-name))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'unit-base', xml-doc_ReplaceSpecSymbols(string(buf_schet-fact-line.unit-base))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'schet-fact-line') + chr(10))).
end.
  if paroutput-file = ?  or paroutput-file = "" then do:
    run write-string in this-procedure (input '</root>':u + chr(10)).
  end.
  else do:
    if p-last-document then  run write-string in this-procedure (input '</root>':u + chr(10)).
  end.
  output stream contr-out close.
  if paroutput-file = ?  or paroutput-file = "" then do:
    if search ("./" + "f":U + string(p-doc-code) + ".xml") <> ? then do:
      os-delete value ("./" + "f":U + string(p-doc-code) + ".xml").
    end.
    os-copy value ("./" + "f":U + string(p-doc-code) + ".tmp") value ("./" + "f":U + string(p-doc-code) + ".xml").
    os-delete value ("./" + "f":U +  string(p-doc-code) + ".tmp").
    run gbl/filename.p (
                  input "./" + "f":U + string(p-doc-code) + ".xml"
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
