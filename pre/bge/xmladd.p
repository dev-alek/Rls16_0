block-level on error undo, throw.
define input parameter p-host-code       like ub.add-doc.host-code no-undo .
define input parameter p-doc-code        like ub.add-doc.doc-code no-undo.
define input-output parameter paroutput-file    as   character           no-undo.
define input parameter p-first-document  as logical no-undo .
define input parameter p-last-document   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: xmladd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/xmladd.p $":U .
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
  define variable v-doc-code          as character    no-undo.
  define variable v-exch-abbr         like ub.currency.curr-abbr no-undo .
  define variable v-exch-name         like ub.currency.curr-name no-undo .
  define variable v-contr-abbr        like ub.currency.curr-abbr no-undo .
  define variable v-contr-name        like ub.currency.curr-name no-undo .
  define variable v-contract-prn-code like ub.contract.contract-prn-code no-undo .
  define variable v-contract-date     like ub.contract.contract-date no-undo .
  define variable v-receiver-name as character no-undo .
  define variable v-gds-name     as character no-undo .
  define variable v-algoritm     as character no-undo .
  define variable v-cost-include  as character no-undo .
  define buffer buf_add-line             for ub.add-line.
  define buffer buf_add-doc              for ub.add-doc.
  define buffer buf_add-trn              for ub.add-trn.
  define buffer buf_gds-add-charges      for ub.gds-add-charges.
  define buffer buf_contract             for ub.contract.
  define buffer buf_clients              for ub.clients.
  define buffer buf_goods                for ub.goods.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
  define buffer buf_currency for ub.currency.
  find first buf_currency no-lock where
             buf_currency.curr-code = v-base-code no-error .
  if available buf_currency then
  assign
  v-base-abbr = buf_currency.curr-abbr
  v-base-name = buf_currency.curr-name
  .
define stream add-doc-out.
if paroutput-file = ?  or
   paroutput-file = ""
   then do:
   output stream add-doc-out to value ("./" + "ad":U + string(p-doc-code) + ".tmp").
   run write-string in this-procedure
     (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
     ).
end.
else do:
  if p-first-document then do:
    output stream add-doc-out to value (paroutput-file).
    run write-string in this-procedure
      (input '<?xml version="1.0" encoding="windows-1251"?>':u + chr(10) + '<root>':u + chr(10)
      ).
  end.
  else do:
    output stream add-doc-out to value(paroutput-file) append.
  end.
end.
 find first buf_add-doc no-lock where
            buf_add-doc.doc-code = p-doc-code no-error .
if not available buf_add-doc then do:
  return error substitute ("Не найден документ ДопРасхода: фирма &1 вн номер &2", p-host-code, p-doc-code).
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = chr(10)
    .
run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'AddDoc') + chr(10)) ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.doc-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Status_', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.status_))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Host', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.host-code))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Object', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.obj-type + string(buf_add-doc.obj-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DateDoc', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.doc-date, '99.99.9999':U))) + v-suffix ) .
if buf_add-doc.fact-date <> ? then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DateFact', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.fact-date, '99.99.9999':U))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocDBNum', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.cr-db-num))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocUserName', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.user-name))) + v-suffix ) .
find first buf_currency no-lock where
          buf_currency.curr-code = buf_add-doc.exch-code no-error .
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
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcCode', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.exch-code))) + v-suffix ) .
if v-exch-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-exch-abbr))) + v-suffix ) .
end.
if v-exch-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Crcname', xml-doc_ReplaceSpecSymbols(string(v-exch-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcRate', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.exch-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CrcScale', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.exch-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'SumRubl', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.sum-rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'SumVatRubl', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.vat-Rubl))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcCode', xml-doc_ReplaceSpecSymbols(string(v-base-code))) + v-suffix ) .
if v-base-abbr <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-base-abbr))) + v-suffix ) .
end.
if v-base-name <> "":U then do:
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcname', xml-doc_ReplaceSpecSymbols(string(v-base-name))) + v-suffix ) .
end.
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.base-rate))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'baseCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.base-scale))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'SumBase', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.sum-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'SumVatBase', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.vat-base))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'VatType', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.vat-type))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'comment', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.PS))) + v-suffix ) .
run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'AddDoc') + chr(10))).
for each buf_add-line no-lock
    where buf_add-line.doc-code  = buf_add-doc.doc-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'AddLine') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_add-line.doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'GdsCode', xml-doc_ReplaceSpecSymbols(string(buf_add-line.gds-code))) + v-suffix ) .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_add-line.gds-code no-error .
if available buf_goods then
assign
v-gds-name = buf_goods.gds-name
.
else
assign
v-gds-name = ''
.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Name', xml-doc_ReplaceSpecSymbols(string(v-gds-name))) + v-suffix ) .
find first buf_gds-add-charges no-lock where
           buf_gds-add-charges.gds-code = buf_add-line.gds-code no-error .
  if available buf_gds-add-charges then do:
      assign
        v-algoritm     = 'Пропорционально ' + entry(int(buf_gds-add-charges.algoritm),"сумме приходных цен,количеству(в баз. ед.изм.),количеству(в пост. ед.изм.),весу")
        v-cost-include = string(buf_gds-add-charges.cost-include,"вкючать в уч.цену/не вкючать в уч.цену")
        no-error .
      if error-status :error then
        assign
          v-algoritm     = ''
          v-cost-include = ''
          .
  end.
else
assign
v-algoritm     = ''
v-cost-include = ''
.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'Algoritm', xml-doc_ReplaceSpecSymbols(string(v-algoritm))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'CostInclude', xml-doc_ReplaceSpecSymbols(string(v-cost-include))) + v-suffix ) .
find first buf_clients no-lock where
            buf_clients.obj-type  = buf_add-line.cli-type and
            buf_clients.obj-code  = buf_add-line.cli-code no-error .
if available buf_clients then
   v-receiver-name = buf_clients.obj-name.
else
  v-receiver-name = 'не найден ' + buf_add-line.cli-type + string(buf_add-line.cli-code) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiver', xml-doc_ReplaceSpecSymbols(string(buf_add-line.cli-type + string(buf_add-line.cli-code)))) + v-suffix ) .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'receiverName', xml-doc_ReplaceSpecSymbols(string(v-receiver-name))) + v-suffix ) .
if buf_add-line.contract-code <> 0 then do:
  find first buf_contract no-lock where
             buf_contract.host-code     = buf_add-line.host-code and
             buf_contract.contract-code = buf_add-line.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .
run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCode', xml-doc_ReplaceSpecSymbols(string(buf_add-line.contract-code))) + v-suffix ) .
  if v-contract-prn-code <> "":U then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractNo', xml-doc_ReplaceSpecSymbols(string(v-contract-prn-code))) + v-suffix ) .
  end.
  if v-contract-date <> ? then do:
            run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractDate', xml-doc_ReplaceSpecSymbols(string(v-contract-date, '99.99.9999':U))) + v-suffix ) .
  end.
  find first buf_currency no-lock where
             buf_currency.curr-code = buf_add-doc.exch-code no-error .
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
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcCode', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.exch-code))) + v-suffix ) .
  if v-exch-abbr <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcAbbr', xml-doc_ReplaceSpecSymbols(string(v-contr-abbr))) + v-suffix ) .
  end.
  if v-exch-name <> "":U then do:
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcname', xml-doc_ReplaceSpecSymbols(string(v-contr-name))) + v-suffix ) .
  end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcRate', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.exch-rate))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'contractCrcScale', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.exch-scale))) + v-suffix ) .
end.
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_add-line.sum-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineSumBase', xml-doc_ReplaceSpecSymbols(string(buf_add-line.sum-base))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVat', xml-doc_ReplaceSpecSymbols(string(buf_add-line.vat-pc))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumRubl', xml-doc_ReplaceSpecSymbols(string(buf_add-line.vat-rubl))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'lineVatSumBase', xml-doc_ReplaceSpecSymbols(string(buf_add-line.vat-base))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'AddLine') + chr(10))).
end.
for each buf_add-trn no-lock
    where buf_add-trn.doc-code  = buf_add-doc.doc-code
on error undo, return error
:
      run write-string in this-procedure  (input (substitute("&1<&2>", fill( chr(32), 2 * (0 + 1) ), 'AddTrn') + chr(10)) ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'DocID', xml-doc_ReplaceSpecSymbols(string(buf_add-doc.doc-code))) + v-suffix ) .
      run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', 'TrnDocId', xml-doc_ReplaceSpecSymbols(string(buf_add-trn.trn-doc-code))) + v-suffix ) .
      run write-string in this-procedure (input (substitute("&1</&2>", fill( chr(32), 2 * (0 + 1) ), 'AddTrn') + chr(10))).
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
output stream add-doc-out close.
if paroutput-file = ?  or
   paroutput-file = "" then do:
  if search ("./" + "ad":U + string(p-doc-code) + ".xml") <> ? then do:
     os-delete value ("./" + "ad":U + string(p-doc-code) + ".xml").
  end.
  os-copy value ("./" + "ad":U + string(p-doc-code) + ".tmp") value ("./" + "ad":U + string(p-doc-code) + ".xml").
  os-delete value ("./" + "ad":U +  string(p-doc-code) + ".tmp").
  run gbl/filename.p
   (              input "./" + "ad":U + string(p-doc-code) + ".xml"
                  ,output paroutput-file
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
end.
procedure write-string :
 define input parameter parstring as character no-undo.
 put stream add-doc-out unformatted parstring.
end.
