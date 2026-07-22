/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка в XML одного ФО

Автор: Хныкин Павел Андреевич
Дата создания: 03/03/06
Author: Pavel Khnykin
Creation date: 03/03/06

Дата создания: 11/30/04
*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}" = "def" &then

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

&if "{2}" = "ONE" &then
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .

  define buffer buf_currency for ub.currency.

  { gbl/basecode.i p-host-code v-base-code }

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
&scop tag-name    fin-ob
{&tag-open}

&scop tag-level 1

&scop tag-name DocID
&scop tag-value buf_fin-ob.doc-code
{&tag-put}


&scop tag-name Status_
&scop tag-value buf_fin-ob.status_
{&tag-put}

&scop tag-name host
&scop tag-value buf_fin-ob.host-code
{&tag-put}

&scop tag-name DocCode
&scop tag-value buf_fin-ob.prn-doc-code
{&tag-put}

&scop tag-name object
&scop tag-value buf_fin-ob.obj-type + string(buf_fin-ob.obj-code)
{&tag-put}

&scop tag-name DateDoc
&scop tag-value buf_fin-ob.doc-date
{&tag-put-date}

if buf_fin-ob.fact-date <> ? then do:
  &scop tag-name DateFact
  &scop tag-value buf_fin-ob.fact-date
  {&tag-put-date}
end.

if buf_fin-ob.pay-date <> ? then do:
  &scop tag-name DatePay
  &scop tag-value buf_fin-ob.pay-date
  {&tag-put-date}
end.


&scop tag-name DocDBNum
&scop tag-value buf_fin-ob.user-db-num-doc
{&tag-put}

if buf_fin-ob.fact-date <> ? then do:
  &scop tag-name FactDBNum
  &scop tag-value buf_fin-ob.user-db-num-fact
  {&tag-put}
end.

if buf_fin-ob.pay-date <> ? then do:
  &scop tag-name PayDBNum
  &scop tag-value buf_fin-ob.user-db-num-pay
  {&tag-put}
end.

&scop tag-name DocUserName
&scop tag-value buf_fin-ob.user-name-doc
{&tag-put}

if buf_fin-ob.fact-date <> ? then do:
  &scop tag-name FactUserName
  &scop tag-value buf_fin-ob.user-name-fact
  {&tag-put}
end.

if buf_fin-ob.pay-date <> ? then do:
  &scop tag-name PayUserName
  &scop tag-value buf_fin-ob.user-name-pay
  {&tag-put}
end.



/*валюты*/
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

&scop tag-name sumDoc
&scop tag-value buf_fin-ob.sum-doc
{&tag-put}

&scop tag-name CrcCode
&scop tag-value buf_fin-ob.curr-code
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
&scop tag-value buf_fin-ob.exch-rate
{&tag-put}

&scop tag-name CrcScale
&scop tag-value buf_fin-ob.exch-scale
{&tag-put}

&scop tag-name actualCrcRate
&scop tag-value buf_fin-ob.actual-exch-rate
{&tag-put}

&scop tag-name actualCrcScale
&scop tag-value buf_fin-ob.actual-exch-scale
{&tag-put}


&scop tag-name sumRubl
&scop tag-value buf_fin-ob.sum-rubl
{&tag-put}


&scop tag-name sumBase
&scop tag-value buf_fin-ob.sum-base
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
&scop tag-value buf_fin-ob.base-rate
{&tag-put}

&scop tag-name baseCrcScale
&scop tag-value buf_fin-ob.base-scale
{&tag-put}

&scop tag-name actualBaseCrcRate
&scop tag-value buf_fin-ob.actual-base-rate
{&tag-put}

&scop tag-name actualBaseCrcScale
&scop tag-value buf_fin-ob.actual-base-scale
{&tag-put}


&scop tag-name conStat
&scop tag-value buf_fin-ob.con-stat
{&tag-put}

&scop tag-name conSumBase
&scop tag-value buf_fin-ob.con-sum-base
{&tag-put}

&scop tag-name conSumRubl
&scop tag-value buf_fin-ob.con-sum-rubl
{&tag-put}


&scop tag-name sum-tax-doc
&scop tag-value buf_fin-ob.sum-tax-doc
{&tag-put}

&scop tag-name sum-tax-rubl
&scop tag-value buf_fin-ob.sum-tax-rubl
{&tag-put}

&scop tag-name sum-tax-base
&scop tag-value buf_fin-ob.sum-tax-base
{&tag-put}
               &scop tag-name conSumDoc
&scop tag-value buf_fin-ob.con-sum-doc
{&tag-put}



if buf_fin-ob.contract-code <> 0 then do:

  find first buf_contract no-lock where
            buf_contract.host-code     = buf_fin-ob.host-code and
            buf_contract.contract-code = buf_fin-ob.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .

&scop tag-name contractCode
&scop tag-value buf_fin-ob.contract-code
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

  &scop tag-name sumcontract
  &scop tag-value buf_fin-ob.sum-contr
  {&tag-put}

  &scop tag-name contractCrcCode
  &scop tag-value buf_fin-ob.contract-curr
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
  &scop tag-value buf_fin-ob.contract-rate
  {&tag-put}

  &scop tag-name contractCrcScale
  &scop tag-value buf_fin-ob.contract-scale
  {&tag-put}

  &scop tag-name actualContractCrcRate
  &scop tag-value buf_fin-ob.actual-contract-rate
  {&tag-put}

  &scop tag-name actualContractCrcScale
  &scop tag-value buf_fin-ob.actual-contract-scale
  {&tag-put}

  &scop tag-name conSumcontract
  &scop tag-value buf_fin-ob.con-sum-contr
  {&tag-put}


  &scop tag-name  sumTaxContract
  &scop tag-value buf_fin-ob.sum-tax-contract
  {&tag-put}




end.


/*ПЛАТЕЛЬЩИК*/

&scop tag-name  payer
&scop tag-value buf_fin-ob.payer-type + string(buf_fin-ob.payer-code)
{&tag-put}

&scop tag-name  payerName
&scop tag-value buf_fin-ob.payer-name
{&tag-put}



/*ПОЛУЧАТЕЛЬ*/

&scop tag-name  receiver
&scop tag-value buf_fin-ob.receiver-type + string(buf_fin-ob.receiver-code)
{&tag-put}

&scop tag-name  receiverName
&scop tag-value buf_fin-ob.receiver-name
{&tag-put}


&scop tag-name  comment
&scop tag-value buf_fin-ob.PS
{&tag-put}


&scop tag-level 0

&scop tag-name  fin-ob
{&tag-close}

/* Обработка строк по налогам */
for each buf_fin-ob-tax no-lock
    where buf_fin-ob-tax.doc-code  = buf_fin-ob.doc-code
    AND   buf_fin-ob-tax.host-code = buf_fin-ob.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  taxLine
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  DocID
  &scop tag-value buf_fin-ob.doc-code
  {&tag-put}

  &scop tag-name  taxLineNum
  &scop tag-value buf_fin-ob-tax.line-num
  {&tag-put}

  &scop tag-name  lineSumDoc
  &scop tag-value buf_fin-ob-tax.sum-line-doc
  {&tag-put}

  &scop tag-name  lineSumRubl
  &scop tag-value buf_fin-ob-tax.sum-line-rubl
  {&tag-put}

  &scop tag-name  lineSumBase
  &scop tag-value buf_fin-ob-tax.sum-line-base
  {&tag-put}

  if buf_fin-ob.contract-code <> 0 then do:
    &scop tag-name  lineSumContr
    &scop tag-value buf_fin-ob-tax.sum-line-contr
    {&tag-put}
  end.

  &scop tag-name  lineVatSumDoc
  &scop tag-value buf_fin-ob-tax.sum-vat-line-doc
  {&tag-put}

  &scop tag-name  lineVatSumRubl
  &scop tag-value buf_fin-ob-tax.sum-vat-line-rubl
  {&tag-put}

  &scop tag-name  lineVatSumBase
  &scop tag-value buf_fin-ob-tax.sum-vat-line-base
  {&tag-put}

  if buf_fin-ob.contract-code <> 0 then do:
    &scop tag-name  lineVatSumContr
    &scop tag-value buf_fin-ob-tax.sum-vat-line-contr
    {&tag-put}
  end.

  &scop tag-name  lineVat
  &scop tag-value buf_fin-ob-tax.vat-pc
  {&tag-put}

  &scop tag-name  lineWithVat
  &scop tag-value (if buf_fin-ob-tax.with-vat then "yes" else "no")
  {&tag-put}
  if buf_fin-ob-tax.SLT-pc <> 0 then do:
    &scop tag-name  lineSLTSumDoc
    &scop tag-value buf_fin-ob-tax.sum-SLT-line-doc
    {&tag-put}

    &scop tag-name  lineSLTSumRubl
    &scop tag-value buf_fin-ob-tax.sum-SLT-line-rubl
    {&tag-put}

    &scop tag-name  lineSLTSumBase
    &scop tag-value buf_fin-ob-tax.sum-SLT-line-base
    {&tag-put}

    if buf_fin-ob.contract-code <> 0 then do:
      &scop tag-name  lineSLTSumContr
      &scop tag-value buf_fin-ob-tax.sum-SLT-line-contr
      {&tag-put}
    end.

    &scop tag-name  lineSLT
    &scop tag-value buf_fin-ob-tax.SLT-pc
    {&tag-put}

    &scop tag-name  lineWithSLT
    &scop tag-value (if buf_fin-ob-tax.with-SLT then "yes" else "no")
    {&tag-put}
  end.

  &scop tag-level 0
  &scop tag-name taxLine
  {&tag-close}

end.        /* for each buf_fin-ob-tax */


/* Обработка связей с накладными */
for each buf_fin-ob-trn no-lock
    where buf_fin-ob-trn.doc-code  = buf_fin-ob.doc-code
    AND   buf_fin-ob-trn.host-code = buf_fin-ob.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  finObTrn
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  DocID
  &scop tag-value buf_fin-ob.doc-code
  {&tag-put}

  &scop tag-name  TrnDocId
  &scop tag-value buf_fin-ob-trn.trn-doc-code
  {&tag-put}

  if buf_fin-ob-trn.ps <> "" then do:
    &scop tag-name  Comment
    &scop tag-value buf_fin-ob-trn.ps
    {&tag-put}

  end.

  &scop tag-level 0
  &scop tag-name finObTrn
  {&tag-close}

end.        /* for each buf_fin-ob-trn */

  /* ПАРТИИ */
for each buf_fin-gds-part no-lock
    where buf_fin-gds-part.fin-ob-code  = buf_fin-ob.doc-code
    AND   buf_fin-gds-part.host-code = buf_fin-ob.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  finParts
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  DocID
  &scop tag-value buf_fin-gds-part.fin-ob-code
  {&tag-put}
  &scop tag-name  gds-code
  &scop tag-value buf_fin-gds-part.gds-code
  {&tag-put}
  &scop tag-name  doc-qnty
  &scop tag-value buf_fin-gds-part.doc-qnty
  {&tag-put}
  &scop tag-name  exch-rate
  &scop tag-value buf_fin-gds-part.exch-rate
  {&tag-put}
  &scop tag-name  exch-scale
  &scop tag-value buf_fin-gds-part.exch-scale
  {&tag-put}
  &scop tag-name  base-rate
  &scop tag-value buf_fin-gds-part.base-rate
  {&tag-put}
  &scop tag-name  base-scale
  &scop tag-value buf_fin-gds-part.base-scale
  {&tag-put}
  &scop tag-name  fact-date
  &scop tag-value buf_fin-gds-part.fact-date
  {&tag-put-date}
  &scop tag-name  fact-qnty
  &scop tag-value buf_fin-gds-part.fact-qnty
  {&tag-put}
  &scop tag-name  fact-time
  &scop tag-value buf_fin-gds-part.fact-time
  {&tag-put}
  &scop tag-name  part-code
  &scop tag-value buf_fin-gds-part.part-code
  {&tag-put}
  &scop tag-name  in-code
  &scop tag-value buf_fin-gds-part.in-code
  {&tag-put}
  &scop tag-name  out-code
  &scop tag-value buf_fin-gds-part.out-code
  {&tag-put}
  &scop tag-name  object
  &scop tag-value buf_fin-gds-part.obj-type + string(buf_fin-gds-part.obj-code)
  {&tag-put}
  &scop tag-name  other-base
  &scop tag-value buf_fin-gds-part.other-base
  {&tag-put}
  &scop tag-name  other-contract
  &scop tag-value buf_fin-gds-part.other-contract
  {&tag-put}
  &scop tag-name  other-rubl
  &scop tag-value buf_fin-gds-part.other-rubl
  {&tag-put}
  &scop tag-name  road-tax-base
  &scop tag-value buf_fin-gds-part.road-tax-base
  {&tag-put}
  &scop tag-name  road-tax-contract
  &scop tag-value buf_fin-gds-part.road-tax-contract
  {&tag-put}
  &scop tag-name  road-tax-rubl
  &scop tag-value buf_fin-gds-part.road-tax-rubl
  {&tag-put}
  &scop tag-name  status_dop
  &scop tag-value buf_fin-gds-part.status_dop
  {&tag-put}
  &scop tag-name  sum-base
  &scop tag-value buf_fin-gds-part.sum-base
  {&tag-put}
  &scop tag-name  sum-contract
  &scop tag-value buf_fin-gds-part.sum-contract
  {&tag-put}
  &scop tag-name  sum-rubl
  &scop tag-value buf_fin-gds-part.sum-rubl
  {&tag-put}
  &scop tag-name  transport-base
  &scop tag-value buf_fin-gds-part.transport-base
  {&tag-put}
  &scop tag-name  transport-contract
  &scop tag-value buf_fin-gds-part.transport-contract
  {&tag-put}
  &scop tag-name  transport-rubl
  &scop tag-value buf_fin-gds-part.transport-rubl
  {&tag-put}
  &scop tag-name  user-db-num
  &scop tag-value buf_fin-gds-part.user-db-num
  {&tag-put}
  &scop tag-name  user-name
  &scop tag-value buf_fin-gds-part.user-name
  {&tag-put}
  &scop tag-name  vat-pc
  &scop tag-value buf_fin-gds-part.vat-pc
  {&tag-put}
  &scop tag-name  vat-type
  &scop tag-value buf_fin-gds-part.vat-type
  {&tag-put}
  &scop tag-name  vat-rubl
  &scop tag-value buf_fin-gds-part.vat-rubl
  {&tag-put}
  &scop tag-name  vat-base
  &scop tag-value buf_fin-gds-part.vat-base
  {&tag-put}
  &scop tag-name  vat-contract
  &scop tag-value buf_fin-gds-part.vat-contract
  {&tag-put}
  if buf_fin-gds-part.SLT-pc <> 0 then do:
    &scop tag-name  SLT-pc
    &scop tag-value buf_fin-gds-part.SLT-pc
    {&tag-put}
    &scop tag-name  SLT-type
    &scop tag-value buf_fin-gds-part.SLT-type
    {&tag-put}
    &scop tag-name  slt-rubl
    &scop tag-value buf_fin-gds-part.slt-rubl
    {&tag-put}
    &scop tag-name  slt-base
    &scop tag-value buf_fin-gds-part.slt-base
    {&tag-put}
    &scop tag-name  slt-contract
    &scop tag-value buf_fin-gds-part.slt-contract
    {&tag-put}
  end.
  &scop tag-level 0
  &scop tag-name finParts
  {&tag-close}

end.        /* for each buf_fin-gds-parts */

  /*  связи с платежами */
for each buf_fin-connect no-lock
    where buf_fin-connect.fin-ob-code  = buf_fin-ob.doc-code
    AND   buf_fin-connect.host-code = buf_fin-ob.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  finConnect
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  DocID
  &scop tag-value buf_fin-connect.fin-ob-code
  {&tag-put}

  &scop tag-name  PS
  &scop tag-value buf_fin-connect.PS
  {&tag-put}
  &scop tag-name  base-rate
  &scop tag-value buf_fin-connect.base-rate
  {&tag-put}
  &scop tag-name  base-scale
  &scop tag-value buf_fin-connect.base-scale
  {&tag-put}
  &scop tag-name  connect-code
  &scop tag-value buf_fin-connect.connect-code
  {&tag-put}
  &scop tag-name  contract-code
  &scop tag-value buf_fin-connect.contract-code
  {&tag-put}
  &scop tag-name  contract-curr
  &scop tag-value buf_fin-connect.contract-curr
  {&tag-put}
  &scop tag-name  contract-rate
  &scop tag-value buf_fin-connect.contract-rate
  {&tag-put}
  &scop tag-name  contract-scale
  &scop tag-value buf_fin-connect.contract-scale
  {&tag-put}
  &scop tag-name  curr-code
  &scop tag-value buf_fin-connect.curr-code
  {&tag-put}
  &scop tag-name  exch-rate
  &scop tag-value buf_fin-connect.exch-rate
  {&tag-put}
  &scop tag-name  exch-scale
  &scop tag-value buf_fin-connect.exch-scale
  {&tag-put}
  &scop tag-name  fact-date
  &scop tag-value buf_fin-connect.fact-date
  {&tag-put-date}
  &scop tag-name  fact-time
  &scop tag-value buf_fin-connect.fact-time
  {&tag-put}
  &scop tag-name  fin-doc-code
  &scop tag-value buf_fin-connect.fin-doc-code
  {&tag-put}
  &scop tag-name  host
  &scop tag-value buf_fin-connect.host-code
  {&tag-put}
  &scop tag-name  status_
  &scop tag-value buf_fin-connect.status_
  {&tag-put}
  &scop tag-name  sum-base-ob
  &scop tag-value buf_fin-connect.sum-base-ob
  {&tag-put}
  &scop tag-name  sum-base
  &scop tag-value buf_fin-connect.sum-base
  {&tag-put}
  &scop tag-name  sum-contr-ob
  &scop tag-value buf_fin-connect.sum-contr-ob
  {&tag-put}
  &scop tag-name  sum-contr
  &scop tag-value buf_fin-connect.sum-contr
  {&tag-put}
  &scop tag-name  sum-doc
  &scop tag-value buf_fin-connect.sum-doc
  {&tag-put}
  &scop tag-name  sum-rubl-ob
  &scop tag-value buf_fin-connect.sum-rubl-ob
  {&tag-put}
  &scop tag-name  sum-rubl
  &scop tag-value buf_fin-connect.sum-rubl
  {&tag-put}
  &scop tag-name  user-db-num
  &scop tag-value buf_fin-connect.user-db-num
  {&tag-put}
  &scop tag-name  user-name
  &scop tag-value buf_fin-connect.user-name
  {&tag-put}


  &scop tag-level 0
  &scop tag-name finConnect
  {&tag-close}

end.        /* for each buf_fin-Connect */



&endif

/*{1} = run*/

/* $Workfile$ e n d */