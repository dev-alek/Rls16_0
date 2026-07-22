/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка в XML одного банковской выписки

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

  define buffer buf_fin-statement        for ub.fin-statement.
  define buffer buf_fin-statement-line   for ub.fin-statement-line.



&if "{2}" = "ONE" &then
  define variable v-doc-date        like ub.fin-statement.doc-date   no-undo.
  define variable v-fact-date       like ub.fin-statement.fact-date  no-undo.
  define variable v-doc-PS          like ub.fin-statement.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .

  define buffer buf_currency for ub.currency.
  define buffer buf_sysconf for ub.sysconf.

  { gbl/basecode.i p-host-code v-base-code }

  find first buf_currency no-lock where
            buf_currency.curr-code = v-base-code no-error .
  if available buf_currency then
  assign
  v-base-abbr = buf_currency.curr-abbr
  v-base-name = buf_currency.curr-name
  .
  find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code.
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
&scop tag-name    finstatement
{&tag-open}

&scop tag-level 1

&scop tag-name statementDocID
&scop tag-value buf_fin-statement.sttm-code
{&tag-put}

&scop tag-name statementCodeOperation
&scop tag-value buf_fin-statement.fins-ext-doc-type
{&tag-put}

&scop tag-name statementStatus
&scop tag-value buf_fin-statement.status_
{&tag-put}

&scop tag-name host
&scop tag-value buf_fin-statement.host-code
{&tag-put}

&scop tag-name statementDocCode
&scop tag-value buf_fin-statement.prn-doc-code
{&tag-put}

&scop tag-name statementDateDoc
&scop tag-value buf_fin-statement.doc-date
{&tag-put-date}

if buf_fin-statement.fact-date <> ? then do:
  &scop tag-name statementDateFact
  &scop tag-value buf_fin-statement.fact-date
  {&tag-put-date}
end.

if buf_fin-statement.bank-date <> ? then do:
  &scop tag-name statementDateBank
  &scop tag-value buf_fin-statement.bank-date
  {&tag-put-date}
end.

&scop tag-name statementDocDBNum
&scop tag-value buf_sysconf.firm-db-num
{&tag-put}


/*валюты*/
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

&scop tag-name sumDoc
&scop tag-value buf_fin-statement.sum-doc
{&tag-put}

&scop tag-name sumDocTh
&scop tag-value buf_fin-statement.sum-doc-th
{&tag-put}


&scop tag-name statementCrcCode
&scop tag-value buf_fin-statement.curr-code
{&tag-put}

if v-exch-abbr <> "":U then do:
&scop tag-name statementCrcAbbr
&scop tag-value v-exch-abbr
{&tag-put}
end.

if v-exch-name <> "":U then do:
&scop tag-name statementCrcname
&scop tag-value v-exch-name
{&tag-put}
end.

&scop tag-name sumRubl
&scop tag-value buf_fin-statement.sum-rubl
{&tag-put}

&scop tag-name sumRublTh
&scop tag-value buf_fin-statement.sum-rubl-th
{&tag-put}


&scop tag-name sumBase
&scop tag-value buf_fin-statement.sum-base
{&tag-put}

&scop tag-name sumBaseTh
&scop tag-value buf_fin-statement.sum-base-th
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


&scop tag-name statementStartDate
&scop tag-value buf_fin-statement.start-date
{&tag-put-date}

&scop tag-name statementEndDate
&scop tag-value buf_fin-statement.end-date
{&tag-put-date}

&scop tag-name statementNumDocs
&scop tag-value buf_fin-statement.num-docs
{&tag-put}

&scop tag-name statementNumDocsTh
&scop tag-value buf_fin-statement.num-docs-th
{&tag-put}


&scop tag-name statementStartSumDoc
&scop tag-value buf_fin-statement.start-sum-doc
{&tag-put}

&scop tag-name statementStartSumDocTh
&scop tag-value buf_fin-statement.start-sum-doc-th
{&tag-put}

&scop tag-name statementStartSumRubl
&scop tag-value buf_fin-statement.start-sum-rubl
{&tag-put}

&scop tag-name statementStartSumRublTh
&scop tag-value buf_fin-statement.start-sum-rubl-th
{&tag-put}

&scop tag-name statementStartSumBase
&scop tag-value buf_fin-statement.start-sum-base
{&tag-put}

&scop tag-name statementStartSumBaseTh
&scop tag-value buf_fin-statement.start-sum-base-th
{&tag-put}

&scop tag-name statementEndSumDoc
&scop tag-value buf_fin-statement.End-sum-doc
{&tag-put}

&scop tag-name statementEndSumDocTh
&scop tag-value buf_fin-statement.End-sum-doc-th
{&tag-put}

&scop tag-name statementEndSumRubl
&scop tag-value buf_fin-statement.End-sum-rubl
{&tag-put}

&scop tag-name statementEndSumRublTh
&scop tag-value buf_fin-statement.End-sum-rubl-th
{&tag-put}

&scop tag-name statementEndSumBase
&scop tag-value buf_fin-statement.End-sum-base
{&tag-put}

&scop tag-name statementEndSumBaseTh
&scop tag-value buf_fin-statement.End-sum-base-th
{&tag-put}

&scop tag-name statementInSumDoc
&scop tag-value buf_fin-statement.In-sum-doc
{&tag-put}

&scop tag-name statementInSumDocTh
&scop tag-value buf_fin-statement.In-sum-doc-th
{&tag-put}

&scop tag-name statementInSumRubl
&scop tag-value buf_fin-statement.In-sum-rubl
{&tag-put}

&scop tag-name statementInSumRublTh
&scop tag-value buf_fin-statement.In-sum-rubl-th
{&tag-put}

&scop tag-name statementInSumBase
&scop tag-value buf_fin-statement.In-sum-base
{&tag-put}

&scop tag-name statementInSumBaseTh
&scop tag-value buf_fin-statement.In-sum-base-th
{&tag-put}

&scop tag-name statementOutSumDoc
&scop tag-value buf_fin-statement.Out-sum-doc
{&tag-put}

&scop tag-name statementOutSumDocTh
&scop tag-value buf_fin-statement.Out-sum-doc-th
{&tag-put}

&scop tag-name statementOutSumRubl
&scop tag-value buf_fin-statement.Out-sum-rubl
{&tag-put}

&scop tag-name statementOutSumRublTh
&scop tag-value buf_fin-statement.Out-sum-rubl-th
{&tag-put}

&scop tag-name statementOutSumBase
&scop tag-value buf_fin-statement.Out-sum-base
{&tag-put}

&scop tag-name statementOutSumBaseTh
&scop tag-value buf_fin-statement.Out-sum-base-th
{&tag-put}

&scop tag-name statementFutureSumDoc
&scop tag-value buf_fin-statement.Future-sum-doc
{&tag-put}

&scop tag-name statementFutureSumRubl
&scop tag-value buf_fin-statement.Future-sum-rubl
{&tag-put}

&scop tag-name statementFutureSumBase
&scop tag-value buf_fin-statement.Future-sum-base
{&tag-put}


&scop tag-name statementAuthor
&scop tag-value buf_fin-statement.cl-bank
{&tag-put}

/*держатель счета*/

&scop tag-name  holderName
&scop tag-value buf_fin-statement.cli-name
{&tag-put}

/*банк счет*/

&scop tag-name  statementBankCode
&scop tag-value buf_fin-statement.code-bank
{&tag-put}


&scop tag-name  statementBankName
&scop tag-value (buf_fin-statement.bank-name + ~{&comma-char~} + ~{&space-char~} + buf_fin-statement.bank-city)
{&tag-put}

&scop tag-name  statementBIK
&scop tag-value buf_fin-statement.bIK
{&tag-put}

&scop tag-name  statementAccountCode
&scop tag-value buf_fin-statement.code-schet
{&tag-put}

&scop tag-name  statementAccount
&scop tag-value buf_fin-statement.r-schet
{&tag-put}

&scop tag-name  statementCorrAccount
&scop tag-value buf_fin-statement.c-schet
{&tag-put}

if buf_fin-statement.dop1 <> "":U then do:
  &scop tag-name  statementAddInfo1
  &scop tag-value buf_fin-statement.dop1
  {&tag-put}
end.
if buf_fin-statement.dop2 <> "":U then do:
  &scop tag-name  statementAddInfo2
  &scop tag-value buf_fin-statement.dop2
  {&tag-put}
end.
if buf_fin-statement.dop3 <> "":U then do:
  &scop tag-name  statementAddInfo3
  &scop tag-value buf_fin-statement.dop3
  {&tag-put}
end.
if buf_fin-statement.dop4 <> "":U then do:
  &scop tag-name  statementAddInfo4
  &scop tag-value buf_fin-statement.dop4
  {&tag-put}
end.


&scop tag-name  comment
&scop tag-value buf_fin-statement.PS
{&tag-put}


&scop tag-level 0

&scop tag-name  finstatement
{&tag-close}

/* Обработка строк  */
for each buf_fin-statement-line no-lock
    where buf_fin-statement-line.sttm = buf_fin-statement.sttm-code
    AND   buf_fin-statement-line.host-code = buf_fin-statement.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  statementLine
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  statementDocID
  &scop tag-value buf_fin-statement-line.sttm-code
  {&tag-put}

  &scop tag-name  statementLineNum
  &scop tag-value buf_fin-statement-line.line-num
  {&tag-put}

  &scop tag-name  lineSumDoc
  &scop tag-value buf_fin-statement-line.sum-doc
  {&tag-put}

  &scop tag-name  lineSumRubl
  &scop tag-value buf_fin-statement-line.sum-rubl
  {&tag-put}

  &scop tag-name  lineSumBase
  &scop tag-value buf_fin-statement-line.sum-base
  {&tag-put}

  &scop tag-name  lineCodeOperation
  &scop tag-value buf_fin-statement-line.fin-ext-doc-type
  {&tag-put}

  &scop tag-name lineDatePay
  &scop tag-value buf_fin-statement-line.pay-date
  {&tag-put-date}

  &scop tag-name lineDocCode
  &scop tag-value buf_fin-statement-line.prn-doc-code
  {&tag-put}

  &scop tag-name lineCorrAccount
  &scop tag-value buf_fin-statement-line.rp-c-schet
  {&tag-put}

  &scop tag-name lineComment
  &scop tag-value buf_fin-statement-line.ps
  {&tag-put}

  &scop tag-level 0
  &scop tag-name statementLine
  {&tag-close}

end.        /* for each buf_fin-statement-line */


&endif

/*{1} = run*/

/* $Workfile$ e n d */