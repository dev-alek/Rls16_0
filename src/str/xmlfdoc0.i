/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка в XML одного платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/23/04
Author: Bakhtadze Natalya
Creation date: 04/23/04

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


  define buffer buf_fin-doc-tax          for ub.fin-doc-tax.
  define buffer buf_fin-doc              for ub.fin-doc.
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

/*
  &scop tagname       findoc
  &scop fill-string  fill(2, {&space-char})
*/
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
&scop tag-name    findoc
{&tag-open}

&scop tag-level 1

&scop tag-name paymentDocID
&scop tag-value buf_fin-doc.fin-doc-code
{&tag-put}

&scop tag-name  cashbookid
&scop tag-value buf_fin-doc.cashbookid
{&tag-put}
  
&scop tag-name paymentCodeOperation
&scop tag-value buf_fin-doc.fin-ext-doc-type
{&tag-put}

&scop tag-name paymentStatus
&scop tag-value buf_fin-doc.status_
{&tag-put}

&scop tag-name host
&scop tag-value buf_fin-doc.host-code
{&tag-put}

&scop tag-name paymentDocCode
&scop tag-value buf_fin-doc.prn-doc-code
{&tag-put}

&scop tag-name object
&scop tag-value buf_fin-doc.obj-type + string(buf_fin-doc.obj-code)
{&tag-put}

&scop tag-name paymentDateDoc
&scop tag-value buf_fin-doc.doc-date
{&tag-put-date}

if buf_fin-doc.fact-date <> ? then do:
  &scop tag-name paymentDateFact
  &scop tag-value buf_fin-doc.fact-date
  {&tag-put-date}
end.

if buf_fin-doc.pay-date <> ? then do:
  &scop tag-name paymentDatePay
  &scop tag-value buf_fin-doc.pay-date
  {&tag-put-date}
end.

if buf_fin-doc.perm-date <> ? then do:
  &scop tag-name paymentDatePermission
  &scop tag-value buf_fin-doc.perm-date
  {&tag-put-date}
end.

&scop tag-name paymentDocDBNum
&scop tag-value buf_fin-doc.user-db-num-doc
{&tag-put}

if buf_fin-doc.fact-date <> ? then do:
  &scop tag-name paymentFactDBNum
  &scop tag-value buf_fin-doc.user-db-num-fact
  {&tag-put}
end.

if buf_fin-doc.pay-date <> ? then do:
  &scop tag-name paymentPayDBNum
  &scop tag-value buf_fin-doc.user-db-num-pl
  {&tag-put}
end.

if buf_fin-doc.perm-date <> ? then do:
  &scop tag-name paymentPermissionDBNum
  &scop tag-value buf_fin-doc.user-db-num-perm
  {&tag-put}
end.

&scop tag-name paymentDocUserName
&scop tag-value buf_fin-doc.user-name-doc
{&tag-put}

if buf_fin-doc.fact-date <> ? then do:
  &scop tag-name paymentFactUserName
  &scop tag-value buf_fin-doc.user-name-fact
  {&tag-put}
end.

if buf_fin-doc.pay-date <> ? then do:
  &scop tag-name paymentPayUserName
  &scop tag-value buf_fin-doc.user-name-pl
  {&tag-put}
end.

if buf_fin-doc.perm-date <> ? then do:
  &scop tag-name paymentPermissionUserName
  &scop tag-value buf_fin-doc.user-name-perm
  {&tag-put}
end.


/*валюты*/
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

&scop tag-name sumDoc
&scop tag-value buf_fin-doc.sum-doc
{&tag-put}

&scop tag-name paymentCrcCode
&scop tag-value buf_fin-doc.curr-code
{&tag-put}

if v-exch-abbr <> "":U then do:
&scop tag-name paymentCrcAbbr
&scop tag-value v-exch-abbr
{&tag-put}
end.

if v-exch-name <> "":U then do:
&scop tag-name paymentCrcname
&scop tag-value v-exch-name
{&tag-put}
end.

&scop tag-name paymentCrcRate
&scop tag-value buf_fin-doc.exch-rate
{&tag-put}

&scop tag-name paymentCrcScale
&scop tag-value buf_fin-doc.exch-scale
{&tag-put}

&scop tag-name actualPaymentCrcRate
&scop tag-value buf_fin-doc.actual-exch-rate
{&tag-put}

&scop tag-name actualPaymentCrcScale
&scop tag-value buf_fin-doc.actual-exch-scale
{&tag-put}


&scop tag-name sumRubl
&scop tag-value buf_fin-doc.sum-rubl
{&tag-put}


&scop tag-name sumBase
&scop tag-value buf_fin-doc.sum-base
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
&scop tag-value buf_fin-doc.base-rate
{&tag-put}

&scop tag-name baseCrcScale
&scop tag-value buf_fin-doc.base-scale
{&tag-put}

&scop tag-name actualBaseCrcRate
&scop tag-value buf_fin-doc.actual-base-rate
{&tag-put}

&scop tag-name actualBaseCrcScale
&scop tag-value buf_fin-doc.actual-base-scale
{&tag-put}


&scop tag-name conStat
&scop tag-value buf_fin-doc.con-stat
{&tag-put}

&scop tag-name conSumBase
&scop tag-value buf_fin-doc.con-sum-base
{&tag-put}

&scop tag-name conSumRubl
&scop tag-value buf_fin-doc.con-sum-rubl
{&tag-put}


if buf_fin-doc.contract-code <> 0 then do:

  find first buf_contract no-lock where
            buf_contract.contract-code = buf_fin-doc.contract-code no-error .
  if available buf_contract then
  assign
  v-contract-prn-code = buf_contract.contract-prn-code
  v-contract-date     = buf_contract.contract-date
  .

&scop tag-name contractCode
&scop tag-value buf_fin-doc.contract-code
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

  &scop tag-name sumcontract
  &scop tag-value buf_fin-doc.sum-contr
  {&tag-put}

  &scop tag-name contractCrcCode
  &scop tag-value buf_fin-doc.contract-curr
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
  &scop tag-value buf_fin-doc.contract-rate
  {&tag-put}

  &scop tag-name contractCrcScale
  &scop tag-value buf_fin-doc.contract-scale
  {&tag-put}

  &scop tag-name actualContractCrcRate
  &scop tag-value buf_fin-doc.actual-contract-rate
  {&tag-put}

  &scop tag-name actualContractCrcScale
  &scop tag-value buf_fin-doc.actual-contract-scale
  {&tag-put}
end.
if buf_fin-doc.an-uchet-code <> 0 then do:
  &scop tag-name analiticCode
  &scop tag-value buf_fin-doc.an-uchet-code
  {&tag-put}

  &scop tag-name analiticCodeValue
  &scop tag-value buf_fin-doc.an-uchet-value
  {&tag-put}
end.

if buf_fin-doc.cel-nazn-code <> 0 then do:
  &scop tag-name destinationCode
  &scop tag-value buf_fin-doc.cel-nazn-code
  {&tag-put}

  &scop tag-name destinationCodeValue
  &scop tag-value buf_fin-doc.cel-nazn-value
  {&tag-put}
end.

if buf_fin-doc.cor-acc <> 0 then do:
  &scop tag-name corAccCode
  &scop tag-value buf_fin-doc.cor-acc
  {&tag-put}

  &scop tag-name corAccCodeValue
  &scop tag-value buf_fin-doc.cor-acc-value
  {&tag-put}
end.

if buf_fin-doc.cor-acc1 <> 0 then do:
  &scop tag-name corAcc1Code
  &scop tag-value buf_fin-doc.cor-acc1
  {&tag-put}

  &scop tag-name corAcc1CodeValue
  &scop tag-value buf_fin-doc.cor-acc1-value
  {&tag-put}
end.

&scop tag-name paymentPurpose
&scop tag-value replace(buf_fin-doc.naznach-plat, "@", "":U)
{&tag-put}

if buf_fin-doc.fin-doc-type = {&income-cash}
or buf_fin-doc.fin-doc-type = {&expense-cash} then do:
  &scop tag-name enclosure
  &scop tag-value buf_fin-doc.enclosure
  {&tag-put}
end.
if buf_fin-doc.fin-doc-type = {&income-cash}
or buf_fin-doc.fin-doc-type = {&expense-cash}
or buf_fin-doc.fin-doc-type = {&income-payoff}
or buf_fin-doc.fin-doc-type = {&expense-payoff}
then do:
  &scop tag-name strDepart
  &scop tag-value buf_fin-doc.str-podr-type + string(buf_fin-doc.str-podr-code)
  {&tag-put}

  &scop tag-name strDepartName
  &scop tag-value buf_fin-doc.str-podr-name
  {&tag-put}
end.

if buf_fin-doc.fin-doc-type = {&income-payoff}
or buf_fin-doc.fin-doc-type = {&expense-payoff} then do:
  if num-entries(buf_fin-doc.payer-sign1, {&delim-par}) > 1 then do:
    &scop tag-name fromPayerHeadPosition
    &scop tag-value entry(1, buf_fin-doc.payer-sign1, {&delim-par})
    {&tag-put}

    &scop tag-name fromPayer
    &scop tag-value entry(2, buf_fin-doc.payer-sign1, {&delim-par})
    {&tag-put}
  end.
  else do:
    &scop tag-name fromPayer
    &scop tag-value buf_fin-doc.payer-sign1
    {&tag-put}
  end.

  if num-entries(buf_fin-doc.receiver-sign1, {&delim-par}) > 1 then do:
    &scop tag-name fromReceiverHeadPosition
    &scop tag-value entry(1, buf_fin-doc.receiver-sign1, {&delim-par})
    {&tag-put}

    &scop tag-name fromReceiver
    &scop tag-value entry(2, buf_fin-doc.receiver-sign1, {&delim-par})
    {&tag-put}
  end.
  else do:
    &scop tag-name fromReceiver
    &scop tag-value buf_fin-doc.receiver-sign1
    {&tag-put}
  end.
end.
if buf_fin-doc.fin-doc-type = {&income-cash} then do:
  &scop tag-name seniorAccounter
  &scop tag-value buf_fin-doc.receiver-sign2
  {&tag-put}

  &scop tag-name cashier
  &scop tag-value buf_fin-doc.receiver-sign3
  {&tag-put}
end.

if buf_fin-doc.fin-doc-type = {&expense-cash} then do:
  if num-entries(buf_fin-doc.payer-sign1, {&delim-par}) > 1 then do:
    &scop tag-name  payerHeadPosition
    &scop tag-value entry(1, buf_fin-doc.payer-sign1, {&delim-par})
    {&tag-put}
    &scop tag-name  payerDirector
    &scop tag-value entry(2, buf_fin-doc.payer-sign1, {&delim-par})
    {&tag-put}
  end.
  else do:
    &scop tag-name  payerDirector
    &scop tag-value buf_fin-doc.payer-sign1
    {&tag-put}
  end.

  &scop tag-name seniorAccounter
  &scop tag-value buf_fin-doc.payer-sign2
  {&tag-put}


  &scop tag-name cashier
  &scop tag-value buf_fin-doc.payer-sign3
  {&tag-put}
end.

if buf_fin-doc.fin-doc-type = {&income-cashless}
or buf_fin-doc.fin-doc-type = {&expense-cashless} then do:
  &scop tag-name  payerDirector
  &scop tag-value buf_fin-doc.payer-sign1
  {&tag-put}

  &scop tag-name seniorAccounter
  &scop tag-value buf_fin-doc.payer-sign2
  {&tag-put}

end.

if buf_fin-doc.fin-doc-type = {&income-cash} then do:
  &scop tag-name including
  &scop tag-value replace(buf_fin-doc.including, "@":U, "":U)
  {&tag-put}
end.

if buf_fin-doc.fin-doc-type = {&income-cashless}
or buf_fin-doc.fin-doc-type = {&expense-cashless} then do:
  &scop tag-name  paymentQueue
  &scop tag-value buf_fin-doc.ocher-pl
  {&tag-put}

  &scop tag-name  paymentPurposeCode
  &scop tag-value buf_fin-doc.nazn-pl
  {&tag-put}

  &scop tag-name  f22
  &scop tag-value buf_fin-doc.f23
  {&tag-put}

  &scop tag-name  f23ReservField
  &scop tag-value buf_fin-doc.f23
  {&tag-put}

  &scop tag-name  operationType
  &scop tag-value buf_fin-doc.vid-opl
  {&tag-put}

  &scop tag-name  paymentType
  &scop tag-value buf_fin-doc.vid-plat
  {&tag-put}


  &scop tag-name  paymentTerm
  &scop tag-value buf_fin-doc.srok-pl
  {&tag-put}

  if buf_fin-doc.stat-pl <> "":U then do:
    &scop tag-name  taxPayerStatus
    &scop tag-value buf_fin-doc.stat-pl
    {&tag-put}

    &scop tag-name  KBK
    &scop tag-value buf_fin-doc.f104
    {&tag-put}

    &scop tag-name  OKATO
    &scop tag-value buf_fin-doc.f105
    {&tag-put}

    &scop tag-name  taxPaymentBase
    &scop tag-value buf_fin-doc.f106
    {&tag-put}

    &scop tag-name  taxPeriod
    &scop tag-value buf_fin-doc.f107
    {&tag-put}

    &scop tag-name  taxDocumentNo
    &scop tag-value buf_fin-doc.f108
    {&tag-put}

    &scop tag-name  taxDocumentDAte
    &scop tag-value buf_fin-doc.f109
    {&tag-put}

    &scop tag-name  taxPaymentType
    &scop tag-value buf_fin-doc.f110
    {&tag-put}
  end.
end.

/*ПЛАТЕЛЬЩИК*/

&scop tag-name  payer
&scop tag-value buf_fin-doc.payer-type + string(buf_fin-doc.payer-code)
{&tag-put}

&scop tag-name  payerName
&scop tag-value buf_fin-doc.payer-name
{&tag-put}

if buf_fin-doc.fin-doc-type = {&income-cashless}
or buf_fin-doc.fin-doc-type = {&expense-cashless} then do:

  &scop tag-name  payerINN
  &scop tag-value buf_fin-doc.payer-INN
  {&tag-put}

  &scop tag-name  payerKPP
  &scop tag-value buf_fin-doc.payer-KPP
  {&tag-put}

  if false then do:
  &scop tag-name  payerOKPO
  &scop tag-value buf_fin-doc.payer-OKPO
  {&tag-put}
  end.

  &scop tag-name  payerBankName
  &scop tag-value (buf_fin-doc.payer-bank-name + ~{&comma-char~} + ~{&space-char~} + buf_fin-doc.payer-bank-city)
  {&tag-put}

  &scop tag-name  payerBIK
  &scop tag-value buf_fin-doc.payer-bIK
  {&tag-put}

  &scop tag-name  payerAccountCode
  &scop tag-value buf_fin-doc.payer-code-schet
  {&tag-put}

  &scop tag-name  payerAccount
  &scop tag-value buf_fin-doc.payer-r-schet
  {&tag-put}

  &scop tag-name  payerCorrAccount
  &scop tag-value buf_fin-doc.payer-c-schet
  {&tag-put}
end.
if buf_fin-doc.payer-dop1 <> "":U then do:
  &scop tag-name  payerAddInfo1
  &scop tag-value buf_fin-doc.payer-dop1
  {&tag-put}
end.
if buf_fin-doc.payer-dop2 <> "":U then do:
  &scop tag-name  payerAddInfo2
  &scop tag-value buf_fin-doc.payer-dop2
  {&tag-put}
end.
if buf_fin-doc.payer-dop3 <> "":U then do:
  &scop tag-name  payerAddInfo3
  &scop tag-value buf_fin-doc.payer-dop3
  {&tag-put}
end.
if buf_fin-doc.payer-dop4 <> "":U then do:
  &scop tag-name  payerAddInfo4
  &scop tag-value buf_fin-doc.payer-dop4
  {&tag-put}
end.
if buf_fin-doc.fin-doc-type = {&income-cash}
or buf_fin-doc.fin-doc-type = {&expense-cash} then do:
  if buf_fin-doc.payer-passport <> "":U then do:
    &scop tag-name  payerPassport
    &scop tag-value buf_fin-doc.payer-passport
    {&tag-put}
  end.
end.

/*ПОЛУЧАТЕЛЬ*/

&scop tag-name  receiver
&scop tag-value buf_fin-doc.receiver-type + string(buf_fin-doc.receiver-code)
{&tag-put}

&scop tag-name  receiverName
&scop tag-value buf_fin-doc.receiver-name
{&tag-put}

if buf_fin-doc.fin-doc-type = {&income-cashless}
or buf_fin-doc.fin-doc-type = {&expense-cashless} then do:

  &scop tag-name  receiverINN
  &scop tag-value buf_fin-doc.receiver-INN
  {&tag-put}

  &scop tag-name  receiverKPP
  &scop tag-value buf_fin-doc.receiver-KPP
  {&tag-put}

  &scop tag-name  receiverBankName
  &scop tag-value (buf_fin-doc.receiver-bank-name + ~{&comma-char~} + ~{&space-char~} + buf_fin-doc.receiver-bank-city)
  {&tag-put}

  &scop tag-name  receiverBIK
  &scop tag-value buf_fin-doc.receiver-bIK
  {&tag-put}

  &scop tag-name  receiverAccountCode
  &scop tag-value buf_fin-doc.receiver-code-schet
  {&tag-put}

  &scop tag-name  receiverAccount
  &scop tag-value buf_fin-doc.receiver-r-schet
  {&tag-put}

  &scop tag-name  receiverCorrAccount
  &scop tag-value buf_fin-doc.receiver-c-schet
  {&tag-put}
end.
if buf_fin-doc.fin-doc-type = {&income-cash} or buf_fin-doc.fin-doc-type = {&income-payoff} then do:
  &scop tag-name  receiverOKPO
  &scop tag-value buf_fin-doc.receiver-OKPO
  {&tag-put}
end.

if buf_fin-doc.receiver-dop1 <> "":U then do:
  &scop tag-name  receiverAddInfo1
  &scop tag-value buf_fin-doc.receiver-dop1
  {&tag-put}
end.
if buf_fin-doc.receiver-dop2 <> "":U then do:
  &scop tag-name  receiverAddInfo2
  &scop tag-value buf_fin-doc.receiver-dop2
  {&tag-put}
end.
if buf_fin-doc.receiver-dop3 <> "":U then do:
  &scop tag-name  receiverAddInfo3
  &scop tag-value buf_fin-doc.receiver-dop3
  {&tag-put}
end.
if buf_fin-doc.receiver-dop4 <> "":U then do:
  &scop tag-name  receiverAddInfo4
  &scop tag-value buf_fin-doc.receiver-dop4
  {&tag-put}
end.
if buf_fin-doc.fin-doc-type = {&income-cash}
or buf_fin-doc.fin-doc-type = {&expense-cash} then do:
  if buf_fin-doc.receiver-passport <> "":U then do:
    &scop tag-name  receiverPassport
    &scop tag-value buf_fin-doc.receiver-passport
    {&tag-put}
  end.
end.

&scop tag-name  comment
&scop tag-value buf_fin-doc.PS
{&tag-put}


&scop tag-level 0

&scop tag-name  findoc
{&tag-close}

/* Обработка строк по налогам */
for each buf_fin-doc-tax no-lock
    where buf_fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code
    AND   buf_fin-doc-tax.host-code = buf_fin-doc.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  taxLine
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  paymentDocID
  &scop tag-value buf_fin-doc.fin-doc-code
  {&tag-put}

  &scop tag-name  cashbookid
  &scop tag-value buf_fin-doc.cashbookid
  {&tag-put}
  
  &scop tag-name  taxLineNum
  &scop tag-value buf_fin-doc-tax.line-num
  {&tag-put}

  &scop tag-name  lineSumDoc
  &scop tag-value buf_fin-doc-tax.sum-line-doc
  {&tag-put}

  &scop tag-name  lineSumRubl
  &scop tag-value buf_fin-doc-tax.sum-line-rubl
  {&tag-put}

  &scop tag-name  lineSumBase
  &scop tag-value buf_fin-doc-tax.sum-line-base
  {&tag-put}

  if buf_fin-doc.contract-code <> 0 then do:
    &scop tag-name  lineSumContr
    &scop tag-value buf_fin-doc-tax.sum-line-contr
    {&tag-put}
  end.

  &scop tag-name  lineVatSumDoc
  &scop tag-value buf_fin-doc-tax.sum-vat-line-doc
  {&tag-put}

  &scop tag-name  lineVatSumRubl
  &scop tag-value buf_fin-doc-tax.sum-vat-line-rubl
  {&tag-put}

  &scop tag-name  lineVatSumBase
  &scop tag-value buf_fin-doc-tax.sum-vat-line-base
  {&tag-put}

  if buf_fin-doc.contract-code <> 0 then do:
    &scop tag-name  lineVatSumContr
    &scop tag-value buf_fin-doc-tax.sum-vat-line-contr
    {&tag-put}
  end.

  &scop tag-name  lineVat
  &scop tag-value buf_fin-doc-tax.vat-pc
  {&tag-put}

  &scop tag-name  lineWithVat
  &scop tag-value (if buf_fin-doc-tax.with-vat then "yes" else "no")
  {&tag-put}

  &scop tag-level 0
  &scop tag-name taxLine
  {&tag-close}

end.        /* for each buf_fin-doc-tax */


&endif

/*{1} = run*/

/* $Workfile$ e n d */