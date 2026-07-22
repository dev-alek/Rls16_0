/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выгрузка в XML договоров

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "def" &then
/*  define variable v-contract-code      as character    no-undo.*/
/*  define variable v-curr-abbr       like ub.currency.curr-abbr no-undo .*/
/*  define variable v-curr-name       like ub.currency.curr-name no-undo .*/

  define buffer buf_contract for ub.contract.
  define buffer buf_contract-attr for ub.contract-attr .
  define buffer buf_contract-specif for ub.contract-specif.
/*  define buffer buf_contract-line for ub.contract-line.*/

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

&scop tag-level 0
&scop tag-name    contract
{&tag-open}

&scop tag-level 1

&scop tag-name contract-code
&scop tag-value buf_contract.contract-code
{&tag-put}
&scop tag-name host-code
&scop tag-value buf_contract.host-code
{&tag-put}
if buf_contract.contract-date <> ? then do:
  &scop tag-name contract-date
  &scop tag-value buf_contract.contract-date
  {&tag-put-date}
end.
if buf_contract.contract-date-beg <> ? then do:
  &scop tag-name contract-date-beg
  &scop tag-value buf_contract.contract-date-beg
  {&tag-put-date}
end.
if buf_contract.contract-date-end <> ? then do:
  &scop tag-name contract-date-end
  &scop tag-value buf_contract.contract-date-end
  {&tag-put-date}
end.
&scop tag-name contract-type
&scop tag-value buf_contract.contract-type
{&tag-put}
&scop tag-name status_
&scop tag-value buf_contract.status_
{&tag-put}
&scop tag-name contract-prn-code
&scop tag-value buf_contract.contract-prn-code
{&tag-put}
&scop tag-name contract-name
&scop tag-value buf_contract.contract-name
{&tag-put}
&scop tag-name contract-city
&scop tag-value buf_contract.contract-city
{&tag-put}
&scop tag-name curr-code
&scop tag-value buf_contract.curr-code
{&tag-put}
&scop tag-name usl-opl
&scop tag-value buf_contract.usl-opl
{&tag-put}
&scop tag-name srok-opl
&scop tag-value buf_contract.srok-opl
{&tag-put}
&scop tag-name doc-type
&scop tag-value buf_contract.doc-type
{&tag-put}
&scop tag-name str-uslov-oplat
&scop tag-value buf_contract.str-uslov-oplat
{&tag-put}
&scop tag-name fin-VAT-pc
&scop tag-value buf_contract.fin-VAT-pc
{&tag-put}
&scop tag-name pay-nal
&scop tag-value buf_contract.pay-nal
{&tag-put}
&scop tag-name user-db-num
&scop tag-value buf_contract.user-db-num
{&tag-put}
&scop tag-name user-name
&scop tag-value buf_contract.user-name
{&tag-put}
&scop tag-name auto-pay
&scop tag-value buf_contract.auto-pay
{&tag-put}


&scop tag-name client
&scop tag-value buf_contract.cli-type + string(buf_contract.cli-code)
{&tag-put}
&scop tag-name cli-name
&scop tag-value buf_contract.cli-name
{&tag-put}
&scop tag-name cli-addres
&scop tag-value buf_contract.cli-addres
{&tag-put}
&scop tag-name cli-inn
&scop tag-value buf_contract.cli-inn
{&tag-put}
&scop tag-name cli-kpp
&scop tag-value buf_contract.cli-kpp
{&tag-put}
&scop tag-name cli-bank-name
&scop tag-value buf_contract.cli-bank-name
{&tag-put}
&scop tag-name cli-bik
&scop tag-value buf_contract.cli-bik
{&tag-put}
&scop tag-name cli-r-schet
&scop tag-value buf_contract.cli-r-schet
{&tag-put}
&scop tag-name cli-c-schet
&scop tag-value buf_contract.cli-c-schet
{&tag-put}
&scop tag-name cli-sign-post
&scop tag-value buf_contract.cli-sign-post
{&tag-put}
&scop tag-name cli-sign
&scop tag-value buf_contract.cli-sign
{&tag-put}
&scop tag-name cli-code-schet
&scop tag-value buf_contract.cli-code-schet
{&tag-put}
&scop tag-name cli-code-schet-start
&scop tag-value buf_contract.cli-code-schet-start
{&tag-put}

&scop tag-name own-name
&scop tag-value buf_contract.own-name
{&tag-put}
&scop tag-name own-addres
&scop tag-value buf_contract.own-addres
{&tag-put}
&scop tag-name own-inn
&scop tag-value buf_contract.own-inn
{&tag-put}
&scop tag-name own-kpp
&scop tag-value buf_contract.own-kpp
{&tag-put}
&scop tag-name own-bank-name
&scop tag-value buf_contract.own-bank-name
{&tag-put}
&scop tag-name own-bik
&scop tag-value buf_contract.own-bik
{&tag-put}
&scop tag-name own-r-schet
&scop tag-value buf_contract.own-r-schet
{&tag-put}
&scop tag-name own-c-schet
&scop tag-value buf_contract.own-c-schet
{&tag-put}
&scop tag-name own-sign-post
&scop tag-value buf_contract.own-sign-post
{&tag-put}
&scop tag-name own-sign
&scop tag-value buf_contract.own-sign
{&tag-put}
&scop tag-name own-code-schet
&scop tag-value buf_contract.own-code-schet
{&tag-put}
&scop tag-name own-code-schet-start
&scop tag-value buf_contract.own-code-schet-start
{&tag-put}

&scop tag-name posrednik
&scop tag-value buf_contract.posr-type + string(buf_contract.posr-code)
{&tag-put}
&scop tag-name posr-name
&scop tag-value buf_contract.posr-name
{&tag-put}
&scop tag-name posr-addres
&scop tag-value buf_contract.posr-addres
{&tag-put}
&scop tag-name posr-inn
&scop tag-value buf_contract.posr-inn
{&tag-put}
&scop tag-name posr-kpp
&scop tag-value buf_contract.posr-kpp
{&tag-put}
&scop tag-name posr-bank-name
&scop tag-value buf_contract.posr-bank-name
{&tag-put}
&scop tag-name posr-bik
&scop tag-value buf_contract.posr-bik
{&tag-put}
&scop tag-name posr-r-schet
&scop tag-value buf_contract.posr-r-schet
{&tag-put}
&scop tag-name posr-c-schet
&scop tag-value buf_contract.posr-c-schet
{&tag-put}
&scop tag-name posr-sign-post
&scop tag-value buf_contract.posr-sign-post
{&tag-put}
&scop tag-name posr-sign
&scop tag-value buf_contract.posr-sign
{&tag-put}
&scop tag-name posr-code-schet
&scop tag-value buf_contract.posr-code-schet
{&tag-put}
&scop tag-name posr-code-schet-start
&scop tag-value buf_contract.posr-code-schet-start
{&tag-put}

&scop tag-name agent
&scop tag-value buf_contract.agnt-type + string(buf_contract.agnt-code)
{&tag-put}
&scop tag-name agnt-name
&scop tag-value buf_contract.agnt-name
{&tag-put}
&scop tag-name agnt-addres
&scop tag-value buf_contract.agnt-addres
{&tag-put}
&scop tag-name agnt-inn
&scop tag-value buf_contract.agnt-inn
{&tag-put}
&scop tag-name agnt-kpp
&scop tag-value buf_contract.agnt-kpp
{&tag-put}
&scop tag-name agnt-bank-name
&scop tag-value buf_contract.agnt-bank-name
{&tag-put}
&scop tag-name agnt-bik
&scop tag-value buf_contract.agnt-bik
{&tag-put}
&scop tag-name agnt-r-schet
&scop tag-value buf_contract.agnt-r-schet
{&tag-put}
&scop tag-name agnt-c-schet
&scop tag-value buf_contract.agnt-c-schet
{&tag-put}
&scop tag-name agnt-sign-post
&scop tag-value buf_contract.agnt-sign-post
{&tag-put}
&scop tag-name agnt-sign
&scop tag-value buf_contract.agnt-sign
{&tag-put}
&scop tag-name agnt-code-schet
&scop tag-value buf_contract.agnt-code-schet
{&tag-put}
&scop tag-name agnt-code-schet-start
&scop tag-value buf_contract.agnt-code-schet-start
{&tag-put}

&scop tag-name mngr-code
&scop tag-value buf_contract.mngr-code
{&tag-put}

&scop tag-name cor-acc-in
&scop tag-value buf_contract.cor-acc-in
{&tag-put}
&scop tag-name an-uchet-code-in
&scop tag-value buf_contract.an-uchet-code-in
{&tag-put}
&scop tag-name cel-nazn-code-in
&scop tag-value buf_contract.cel-nazn-code-in
{&tag-put}
&scop tag-name cor-acc1-in
&scop tag-value buf_contract.cor-acc1-in
{&tag-put}
&scop tag-name cor-acc-out
&scop tag-value buf_contract.cor-acc-out
{&tag-put}
&scop tag-name an-uchet-code-out
&scop tag-value buf_contract.an-uchet-code-out
{&tag-put}
&scop tag-name cel-nazn-code-out
&scop tag-value buf_contract.cel-nazn-code-out
{&tag-put}
&scop tag-name cor-acc1-out
&scop tag-value buf_contract.cor-acc1-out
{&tag-put}
&scop tag-name cor-acc-in-cash
&scop tag-value buf_contract.cor-acc-in-cash
{&tag-put}
&scop tag-name an-uchet-code-in-cash
&scop tag-value buf_contract.an-uchet-code-in-cash
{&tag-put}
&scop tag-name cel-nazn-code-in-cash
&scop tag-value buf_contract.cel-nazn-code-in-cash
{&tag-put}
&scop tag-name cor-acc1-in-cash
&scop tag-value buf_contract.cor-acc1-in-cash
{&tag-put}
&scop tag-name cor-acc-out-cash
&scop tag-value buf_contract.cor-acc-out-cash
{&tag-put}
&scop tag-name an-uchet-code-out-cash
&scop tag-value buf_contract.an-uchet-code-out-cash
{&tag-put}
&scop tag-name cel-nazn-code-out-cash
&scop tag-value buf_contract.cel-nazn-code-out-cash
{&tag-put}
&scop tag-name cor-acc1-out-cash
&scop tag-value buf_contract.cor-acc1-out-cash
{&tag-put}
&scop tag-name cor-acc-in-payoff
&scop tag-value buf_contract.cor-acc-in-payoff
{&tag-put}
&scop tag-name an-uchet-code-in-payoff
&scop tag-value buf_contract.an-uchet-code-in-payoff
{&tag-put}
&scop tag-name cel-nazn-code-in-payoff
&scop tag-value buf_contract.cel-nazn-code-in-payoff
{&tag-put}
&scop tag-name cor-acc1-in-payoff
&scop tag-value buf_contract.cor-acc1-in-payoff
{&tag-put}
&scop tag-name cor-acc-out-payoff
&scop tag-value buf_contract.cor-acc-out-payoff
{&tag-put}
&scop tag-name an-uchet-code-out-payoff
&scop tag-value buf_contract.an-uchet-code-out-payoff
{&tag-put}
&scop tag-name cel-nazn-code-out-payoff
&scop tag-value buf_contract.cel-nazn-code-out-payoff
{&tag-put}
&scop tag-name cor-acc1-out-payoff
&scop tag-value buf_contract.cor-acc1-out-payoff
{&tag-put}


&scop tag-name spec-prc
&scop tag-value buf_contract.spec-prc
{&tag-put}
&scop tag-name spec-check
&scop tag-value buf_contract.spec-check
{&tag-put}
for first buf_contract-attr no-lock where buf_contract-attr.host-code = buf_contract.host-code and buf_contract-attr.contract-code = buf_contract.contract-code and
buf_contract-attr.attr-code = "contract-edi":
&scop tag-name edi
&scop tag-value if buf_contract-attr.attr-value = "yes" then "1" else "0"
{&tag-put}
end.
&scop tag-level 0

&scop tag-name  contract
{&tag-close}

/* Обработка строк */
for each buf_contract-specif no-lock
    where buf_contract-specif.contract-num = buf_contract.contract-code
    AND   buf_contract-specif.host-code = buf_contract.host-code
on error undo, return error
:

  &scop tag-level 0
  &scop tag-name  contract-specif
  {&tag-open}

  &scop tag-level 1

  &scop tag-name  contract-num
  &scop tag-value buf_contract-specif.contract-num
  {&tag-put}

  &scop tag-name  host-code
  &scop tag-value buf_contract-specif.host-code
  {&tag-put}

  &scop tag-name  gds-code
  &scop tag-value buf_contract-specif.gds-code
  {&tag-put}

  &scop tag-name  price-cli
  &scop tag-value buf_contract-specif.price-cli
  {&tag-put}

  &scop tag-name  prc
  &scop tag-value buf_contract-specif.prc
  {&tag-put}

  &scop tag-level 0
  &scop tag-name contract-specif
  {&tag-close}

end.        /* for each buf_fin-doc-tax */


&endif

/*{1} = run*/

/* $Workfile$ e n d */