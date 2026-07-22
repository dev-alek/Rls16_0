/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка в XML счетов-фактур

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

&if "{1}" = "def" &then
  define buffer buf_schet-fact-doc  for ub.schet-fact-doc.
  define buffer buf_schet-fact-line for ub.schet-fact-line.
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

  &scop tag-put       run bgelib-tag-put in this-procedure ( input ~{&tag-level~}, input substitute('&1', '~{&tag-name~}'),  input string(~{&tag-value~}), input 1 ).
  &scop tag-put-date  run bgelib-tag-put in this-procedure ( input ~{&tag-level~}, input substitute('&1', '~{&tag-name~}'),  input string(~{&tag-value~}, '99.99.9999'), input 1 ).
  &scop tag-open      run bgelib-tag-open in this-procedure ( input ~{&tag-level~}, substitute("&1", '~{&tag-name~}'),  "" ).
  &scop tag-close     run bgelib-tag-close in this-procedure ( input ~{&tag-level~}, substitute("&1", '~{&tag-name~}')).

&endif


&if "{2}" = "ONE" &then

&scop tag-level 0
&scop tag-name    header
{&tag-open}
&scop tag-level 1
/*paroutput-file*/
&scop tag-name fileName
&scop tag-value string( "f":U + string(p-doc-code) + ".xml")
{&tag-put}
&scop tag-name fileNumber
&scop tag-value string(1)
{&tag-put}
&scop tag-name HostList
&scop tag-value string(p-host-code)
{&tag-put}
&scop tag-name docName
&scop tag-value "schet-fact"
{&tag-put}
&scop tag-name version
&scop tag-value {&version-string}
{&tag-put}
&scop tag-name exportDate
&scop tag-value string( today,          "99/99/9999" )
{&tag-put}
&scop tag-name exportTime
&scop tag-value string( time,           "HH:MM:SS"   )
{&tag-put}
&scop tag-name baseNum
&scop tag-value g#db-num
{&tag-put}
&scop tag-name DateFrom
&scop tag-value ""
{&tag-put}
&scop tag-name DateTo
&scop tag-value ""
{&tag-put}

&scop tag-level 0

&scop tag-name  header
{&tag-close}

&endif


&scop tag-level 0

&scop tag-name    schet-fact-doc
{&tag-open}

&scop tag-level 1

&scop tag-name doc-code
&scop tag-value buf_schet-fact-doc.doc-code
{&tag-put}
&scop tag-name doc-date
&scop tag-value buf_schet-fact-doc.doc-date
{&tag-put-date}
if buf_schet-fact-doc.pay-date <> ? then do:
  &scop tag-name pay-date
  &scop tag-value buf_schet-fact-doc.pay-date
  {&tag-put-date}
end.
if buf_schet-fact-doc.in-date <> ? then do:
  &scop tag-name in-date
  &scop tag-value buf_schet-fact-doc.in-date
  {&tag-put-date}
end.
&scop tag-name doc-type
&scop tag-value buf_schet-fact-doc.doc-type
{&tag-put}
&scop tag-name ext-doc-type
&scop tag-value buf_schet-fact-doc.ext-doc-type
{&tag-put}
&scop tag-name status_
&scop tag-value buf_schet-fact-doc.status_
{&tag-put}
&scop tag-name contract-code
&scop tag-value buf_schet-fact-doc.contract-code
{&tag-put}
&scop tag-name host-code
&scop tag-value buf_schet-fact-doc.host-code
{&tag-put}
&scop tag-name book-code
&scop tag-value buf_schet-fact-doc.book-code
{&tag-put}
&scop tag-name obj-type
&scop tag-value buf_schet-fact-doc.obj-type
{&tag-put}
&scop tag-name obj-code
&scop tag-value buf_schet-fact-doc.obj-code
{&tag-put}
&scop tag-name cli-type
&scop tag-value buf_schet-fact-doc.cli-type
{&tag-put}
&scop tag-name cli-code
&scop tag-value buf_schet-fact-doc.cli-code
{&tag-put}
&scop tag-name cli-name
&scop tag-value buf_schet-fact-doc.cli-name
{&tag-put}
&scop tag-name cli-inn
&scop tag-value buf_schet-fact-doc.cli-inn
{&tag-put}
&scop tag-name cli-address
&scop tag-value buf_schet-fact-doc.cli-address
{&tag-put}
&scop tag-name Gruz-otprav
&scop tag-value buf_schet-fact-doc.Gruz-otprav
{&tag-put}
&scop tag-name Gruz-poluch
&scop tag-value buf_schet-fact-doc.Gruz-poluch
{&tag-put}
&scop tag-name own-name
&scop tag-value buf_schet-fact-doc.own-name
{&tag-put}
&scop tag-name own-inn
&scop tag-value buf_schet-fact-doc.own-inn
{&tag-put}
&scop tag-name own-address
&scop tag-value buf_schet-fact-doc.own-address
{&tag-put}
if buf_schet-fact-doc.fact-order <> ? then do:
  &scop tag-name fact-order
  &scop tag-value buf_schet-fact-doc.fact-order
  {&tag-put}
end.
if buf_schet-fact-doc.in-doc-code <> "" then do:
  &scop tag-name in-doc-code
  &scop tag-value buf_schet-fact-doc.in-doc-code
  {&tag-put}
end.
if buf_schet-fact-doc.in-doc-date <> ? then do:
  &scop tag-name in-doc-date
  &scop tag-value buf_schet-fact-doc.in-doc-date
  {&tag-put-date}
end.
if buf_schet-fact-doc.base-rate <> ? then do:
  &scop tag-name base-rate
  &scop tag-value buf_schet-fact-doc.base-rate
  {&tag-put}
end.
if buf_schet-fact-doc.base-scale <> ? then do:
  &scop tag-name base-scale
  &scop tag-value buf_schet-fact-doc.base-scale
  {&tag-put}
end.
&scop tag-name sum-rubl
&scop tag-value buf_schet-fact-doc.sum-rubl
{&tag-put}
&scop tag-name sum-VAT-20-rubl
&scop tag-value buf_schet-fact-doc.sum-VAT-20-rubl
{&tag-put}
&scop tag-name VAT-20-rubl
&scop tag-value buf_schet-fact-doc.VAT-20-rubl
{&tag-put}
&scop tag-name sum-VAT-10-rubl
&scop tag-value buf_schet-fact-doc.sum-VAT-10-rubl
{&tag-put}
&scop tag-name VAT-10-rubl
&scop tag-value buf_schet-fact-doc.VAT-10-rubl
{&tag-put}
&scop tag-name sum-VAT-0-rubl
&scop tag-value buf_schet-fact-doc.sum-VAT-0-rubl
{&tag-put}
&scop tag-name sum-VAT-no-rubl
&scop tag-value buf_schet-fact-doc.sum-VAT-no-rubl
{&tag-put}
&scop tag-name sum-base
&scop tag-value buf_schet-fact-doc.sum-base
{&tag-put}
&scop tag-name sum-VAT-20-base
&scop tag-value buf_schet-fact-doc.sum-VAT-20-base
{&tag-put}
&scop tag-name VAT-20-base
&scop tag-value buf_schet-fact-doc.VAT-20-base
{&tag-put}
&scop tag-name sum-VAT-10-base
&scop tag-value buf_schet-fact-doc.sum-VAT-10-base
{&tag-put}
&scop tag-name VAT-10-base
&scop tag-value buf_schet-fact-doc.VAT-10-base
{&tag-put}
&scop tag-name sum-VAT-0-base
&scop tag-value buf_schet-fact-doc.sum-VAT-0-base
{&tag-put}
&scop tag-name sum-VAT-no-base
&scop tag-value buf_schet-fact-doc.sum-VAT-no-base
{&tag-put}
&scop tag-name PS
&scop tag-value buf_schet-fact-doc.PS
{&tag-put}
&scop tag-name out-code-list
&scop tag-value buf_schet-fact-doc.out-code-list
{&tag-put}
&scop tag-name gtd
&scop tag-value buf_schet-fact-doc.gtd
{&tag-put}
&scop tag-name country
&scop tag-value buf_schet-fact-doc.country
{&tag-put}
&scop tag-name fact-user-db-num
&scop tag-value buf_schet-fact-doc.fact-user-db-num
{&tag-put}
&scop tag-name fact-user-name
&scop tag-value buf_schet-fact-doc.fact-user-name
{&tag-put}
&scop tag-name user-db-num
&scop tag-value buf_schet-fact-doc.user-db-num
{&tag-put}
&scop tag-name user-name
&scop tag-value buf_schet-fact-doc.user-name
{&tag-put}
&scop tag-name PS
&scop tag-value buf_schet-fact-doc.PS
{&tag-put}
if buf_schet-fact-doc.fact-date <> ? then do:
  &scop tag-name fact-date
  &scop tag-value buf_schet-fact-doc.fact-date
  {&tag-put-date}
end.
if buf_schet-fact-doc.fact-time <> ? then do:
  &scop tag-name fact-time
  &scop tag-value buf_schet-fact-doc.fact-time
  {&tag-put}
end.
&scop tag-name sys-date
&scop tag-value buf_schet-fact-doc.sys-date
{&tag-put-date}
&scop tag-name sys-time
&scop tag-value buf_schet-fact-doc.sys-time
{&tag-put}
&scop tag-name office
&scop tag-value buf_schet-fact-doc.office
{&tag-put}
&scop tag-name curr-code
&scop tag-value buf_schet-fact-doc.curr-code
{&tag-put}

&scop tag-level 0

&scop tag-name  schet-fact-doc
{&tag-close}

/* Обработка строк */
for each buf_schet-fact-line no-lock
    where buf_schet-fact-line.doc-code = buf_schet-fact-doc.doc-code
    AND   buf_schet-fact-line.db-num = buf_schet-fact-doc.db-num
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  schet-fact-line
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  doc-code
  &scop tag-value buf_schet-fact-line.doc-code
  {&tag-put}
  &scop tag-name  gds-code
  &scop tag-value buf_schet-fact-line.gds-code
  {&tag-put}
  &scop tag-name  fact-qnty
  &scop tag-value buf_schet-fact-line.fact-qnty
  {&tag-put}
  &scop tag-name  price-rubl
  &scop tag-value buf_schet-fact-line.price-rubl
  {&tag-put}
  &scop tag-name  price-base
  &scop tag-value buf_schet-fact-line.price-base
  {&tag-put}
  &scop tag-name  sum-rubl
  &scop tag-value buf_schet-fact-line.sum-rubl
  {&tag-put}
  &scop tag-name  sum-base
  &scop tag-value buf_schet-fact-line.sum-base
  {&tag-put}
  &scop tag-name  VAT-rubl
  &scop tag-value buf_schet-fact-line.VAT-rubl
  {&tag-put}
  &scop tag-name  VAT-base
  &scop tag-value buf_schet-fact-line.VAT-base
  {&tag-put}
  &scop tag-name  sum-rubl-VAT
  &scop tag-value buf_schet-fact-line.sum-rubl-VAT
  {&tag-put}
  &scop tag-name  sum-base-VAT
  &scop tag-value buf_schet-fact-line.sum-base-VAT
  {&tag-put}
  &scop tag-name  obj-type
  &scop tag-value buf_schet-fact-line.obj-type
  {&tag-put}
  &scop tag-name  obj-code
  &scop tag-value buf_schet-fact-line.obj-code
  {&tag-put}
  &scop tag-name  VAT-pc
  &scop tag-value buf_schet-fact-line.VAT-pc
  {&tag-put}
  &scop tag-name  ext-doc-type
  &scop tag-value buf_schet-fact-line.ext-doc-type
  {&tag-put}
  &scop tag-name  fact-order
  &scop tag-value buf_schet-fact-line.fact-order
  {&tag-put}
  &scop tag-name  status_
  &scop tag-value buf_schet-fact-line.status_
  {&tag-put}
  &scop tag-name  line-num
  &scop tag-value buf_schet-fact-line.line-num
  {&tag-put}
  &scop tag-name  excise
  &scop tag-value buf_schet-fact-line.excise
  {&tag-put}
  &scop tag-name  other-base
  &scop tag-value buf_schet-fact-line.other-base
  {&tag-put}
  &scop tag-name  other-rubl
  &scop tag-value buf_schet-fact-line.other-rubl
  {&tag-put}
  &scop tag-name  gtd
  &scop tag-value buf_schet-fact-line.gtd
  {&tag-put}
  &scop tag-name  country
  &scop tag-value buf_schet-fact-line.country
  {&tag-put}
  &scop tag-name  host-code
  &scop tag-value buf_schet-fact-line.host-code
  {&tag-put}
  &scop tag-name  gds-code
  &scop tag-value buf_schet-fact-line.gds-code
  {&tag-put}
  &scop tag-name  in-code
  &scop tag-value buf_schet-fact-line.in-code
  {&tag-put}
  &scop tag-name  part-code
  &scop tag-value buf_schet-fact-line.part-code
  {&tag-put}
  &scop tag-name  gds-name
  &scop tag-value buf_schet-fact-line.gds-name
  {&tag-put}
  &scop tag-name  unit-base
  &scop tag-value buf_schet-fact-line.unit-base
  {&tag-put}


  &scop tag-level 0
  &scop tag-name schet-fact-line
  {&tag-close}

end.        /* for each buf_fin-doc-tax */


&endif

/*{1} = run*/

/* $Workfile$ e n d */