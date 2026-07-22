/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка в XML одного ДопРасхода

Автор: Хныкин Павел Андреевич
Дата создания: 01/14/08
Author: Pavel Khnykin
Creation date: 01/14/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def" &then

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

&if "{2}" = "ONE" &then
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .

  { gbl/basecode.i p-host-code v-base-code }

  define buffer buf_currency for ub.currency.

  find first buf_currency no-lock where
             buf_currency.curr-code = v-base-code no-error .
  if available buf_currency then
  assign
  v-base-abbr = buf_currency.curr-abbr
  v-base-name = buf_currency.curr-name
  .
&endif


&endif

&if "{1}" = "run" &then


&if "{2}" = "ONE" &then
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .
    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .
  &scop tag-put       run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', '~{&tag-name~}', xml-doc_ReplaceSpecSymbols(string(~{&tag-value~}))) + v-suffix ) .
  &scop tag-put-date  run write-string in this-procedure  (input v-prefix + substitute('<&1>&2</&1>', '~{&tag-name~}', xml-doc_ReplaceSpecSymbols(string(~{&tag-value~}, '99.99.9999':U))) + v-suffix ) .
  &scop tag-open      run write-string in this-procedure  (input (substitute("&1<&2>", ~{&fill-string~}, '~{&tag-name~}') + ~{&new-line~}) ) .

  &scop tag-close     run write-string in this-procedure (input (substitute("&1</&2>", ~{&fill-string~}, '~{&tag-name~}') + ~{&new-line~})).

  &scop fill-string   fill( ~{&space-char~}, 2 * (~{&tag-level~} + 1) )

&endif
&if "{2}" = "LIST" &then

   &if "{3}" = "bge-xml" &then

  &scop tag-put       run wp-xmltagput in this-procedure ( input ~{&tag-level~} + 4, input substitute('&1', '~{&tag-name~}'),  input string(~{&tag-value~}), input 1 ).
  &scop tag-put-date  run wp-xmltagput in this-procedure ( input ~{&tag-level~} + 4, input substitute('&1', '~{&tag-name~}'),  input string(~{&tag-value~}, '99.99.9999'), input 1 ).
  &scop tag-open      run wp-xmltagopen in this-procedure ( input ~{&tag-level~} + 4, substitute("&1", '~{&tag-name~}'),  "" ).
  &scop tag-close     run wp-xmltagclose in this-procedure ( input ~{&tag-level~} + 4, substitute("&1", '~{&tag-name~}')).

  &else

  &scop tag-put       run bgelib-tag-put in this-procedure ( input ~{&tag-level~}, input substitute('&1', '~{&tag-name~}'),  input string(~{&tag-value~}), input 1 ).
  &scop tag-put-date  run bgelib-tag-put in this-procedure ( input ~{&tag-level~}, input substitute('&1', '~{&tag-name~}'),  input string(~{&tag-value~}, '99.99.9999'), input 1 ).
  &scop tag-open      run bgelib-tag-open in this-procedure ( input ~{&tag-level~}, substitute("&1", '~{&tag-name~}'),  "" ).
  &scop tag-close     run bgelib-tag-close in this-procedure ( input ~{&tag-level~}, substitute("&1", '~{&tag-name~}')).

  &endif

&endif

&scop tag-level 0
&scop tag-name  AddDoc
{&tag-open}

&scop tag-level 1

&scop tag-name DocID
&scop tag-value buf_add-doc.doc-code
{&tag-put}


&scop tag-name Status_
&scop tag-value buf_add-doc.status_
{&tag-put}

&scop tag-name Host
&scop tag-value buf_add-doc.host-code
{&tag-put}

&scop tag-name Object
&scop tag-value buf_add-doc.obj-type + string(buf_add-doc.obj-code)
{&tag-put}

&scop tag-name DateDoc
&scop tag-value buf_add-doc.doc-date
{&tag-put-date}

if buf_add-doc.fact-date <> ? then do:
  &scop tag-name DateFact
  &scop tag-value buf_add-doc.fact-date
  {&tag-put-date}
end.


&scop tag-name DocDBNum
&scop tag-value buf_add-doc.cr-db-num
{&tag-put}


&scop tag-name DocUserName
&scop tag-value buf_add-doc.user-name
{&tag-put}


/*валюты*/
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

&scop tag-name CrcCode
&scop tag-value buf_add-doc.exch-code
{&tag-put}

if v-exch-abbr <> "":U then do:
&scop tag-name CrcAbbr
&scop tag-value v-exch-abbr
{&tag-put}
end.

if v-exch-name <> "":U then do:
&scop tag-name Crcname
&scop tag-value v-exch-name
{&tag-put}
end.

&scop tag-name CrcRate
&scop tag-value buf_add-doc.exch-rate
{&tag-put}

&scop tag-name CrcScale
&scop tag-value buf_add-doc.exch-scale
{&tag-put}


&scop tag-name SumRubl
&scop tag-value buf_add-doc.sum-rubl
{&tag-put}

&scop tag-name SumVatRubl
&scop tag-value buf_add-doc.vat-Rubl
{&tag-put}



&scop tag-name baseCrcCode
&scop tag-value v-base-code
{&tag-put}

if v-base-abbr <> "":U then do:
&scop tag-name baseCrcAbbr
&scop tag-value v-base-abbr
{&tag-put}
end.

if v-base-name <> "":U then do:
&scop tag-name baseCrcname
&scop tag-value v-base-name
{&tag-put}
end.

&scop tag-name baseCrcRate
&scop tag-value buf_add-doc.base-rate
{&tag-put}

&scop tag-name baseCrcScale
&scop tag-value buf_add-doc.base-scale
{&tag-put}

&scop tag-name SumBase
&scop tag-value buf_add-doc.sum-base
{&tag-put}

&scop tag-name SumVatBase
&scop tag-value buf_add-doc.vat-base
{&tag-put}

&scop tag-name VatType
&scop tag-value buf_add-doc.vat-type
{&tag-put}


&scop tag-name  comment
&scop tag-value buf_add-doc.PS
{&tag-put}


&scop tag-level 0

&scop tag-name  AddDoc
{&tag-close}

/* Обработка строк */
for each buf_add-line no-lock
    where buf_add-line.doc-code  = buf_add-doc.doc-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  AddLine
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  DocID
  &scop tag-value buf_add-line.doc-code
  {&tag-put}

  &scop tag-name  GdsCode
  &scop tag-value buf_add-line.gds-code
  {&tag-put}

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

  &scop tag-name  Name
  &scop tag-value v-gds-name
  {&tag-put}


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
  &scop tag-name  Algoritm
  &scop tag-value v-algoritm
  {&tag-put}

  &scop tag-name  CostInclude
  &scop tag-value v-cost-include
  {&tag-put}

/*ПОЛУЧАТЕЛЬ*/

find first buf_clients no-lock where
            buf_clients.obj-type  = buf_add-line.cli-type and
            buf_clients.obj-code  = buf_add-line.cli-code no-error .
if available buf_clients then
   v-receiver-name = buf_clients.obj-name.
else
  v-receiver-name = 'не найден ' + buf_add-line.cli-type + string(buf_add-line.cli-code) .

&scop tag-name  receiver
&scop tag-value buf_add-line.cli-type + string(buf_add-line.cli-code)
{&tag-put}

&scop tag-name  receiverName
&scop tag-value v-receiver-name
{&tag-put}


if buf_add-line.contract-code <> 0 then do:

  find first buf_contract no-lock where
             buf_contract.host-code     = buf_add-line.host-code and
             buf_contract.contract-code = buf_add-line.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .

&scop tag-name contractCode
&scop tag-value buf_add-line.contract-code
{&tag-put}

  if v-contract-prn-code <> "":U then do:
    &scop tag-name contractNo
    &scop tag-value v-contract-prn-code
    {&tag-put}
  end.

  if v-contract-date <> ? then do:
    &scop tag-name contractDate
    &scop tag-value v-contract-date
    {&tag-put-date}
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

  &scop tag-name contractCrcCode
  &scop tag-value buf_add-doc.exch-code
  {&tag-put}

  if v-exch-abbr <> "":U then do:
  &scop tag-name contractCrcAbbr
  &scop tag-value v-contr-abbr
  {&tag-put}
  end.

  if v-exch-name <> "":U then do:
  &scop tag-name contractCrcname
  &scop tag-value v-contr-name
  {&tag-put}
  end.

  &scop tag-name contractCrcRate
  &scop tag-value buf_add-doc.exch-rate
  {&tag-put}

  &scop tag-name contractCrcScale
  &scop tag-value buf_add-doc.exch-scale
  {&tag-put}
end.

  &scop tag-name  lineSumRubl
  &scop tag-value buf_add-line.sum-rubl
  {&tag-put}

  &scop tag-name  lineSumBase
  &scop tag-value buf_add-line.sum-base
  {&tag-put}

  &scop tag-name  lineVat
  &scop tag-value buf_add-line.vat-pc
  {&tag-put}

  &scop tag-name  lineVatSumRubl
  &scop tag-value buf_add-line.vat-rubl
  {&tag-put}

  &scop tag-name  lineVatSumBase
  &scop tag-value buf_add-line.vat-base
  {&tag-put}

  &scop tag-level 0
  &scop tag-name AddLine
  {&tag-close}

end.
/* for each buf_add-line */


/* Обработка связей с накладными */
for each buf_add-trn no-lock
    where buf_add-trn.doc-code  = buf_add-doc.doc-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  AddTrn
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  DocID
  &scop tag-value buf_add-doc.doc-code
  {&tag-put}

  &scop tag-name  TrnDocId
  &scop tag-value buf_add-trn.trn-doc-code
  {&tag-put}

  &scop tag-level 0
  &scop tag-name AddTrn
  {&tag-close}

end.        /* for each buf_add-trn */

&endif

/*{1} = run*/

/* $Workfile$ e n d */