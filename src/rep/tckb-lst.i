/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Печать ценников (этикеток) по списку бар-кодов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/12/05
Author: Bakhtadze Natalya
Creation date: 09/12/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-value{&vssseq} as character no-undo .
&scop need-prn ~
  if prn-prt = false ~
    and bar-code.node-code <> rootnode_code ~
  then do: ~
    next. ~
  end. ~
  if prn-prt = true then do: ~
    find first gds-prt no-lock ~
      where gds-prt.node-code = bar-code.node-code ~
    . ~
    if gds-prt.is-term = false then do: ~
      next. ~
    end. ~
  end. ~


if NOT can-find(first {1}) then
    RETURN.

for each {1}
&if "{2}" = "gds-name" &then
by {1}.gds-name
&endif
&if "{2}" = "artic" &then
by {1}.artic
by {1}.prod-type
by {1}.prod-code
&endif
&if "{2}" = "b-code" &then
by {1}.b-code
&endif
&if "{2}" = "order-num" &then
by {1}.order-num
&endif
:

  if {1}.b-str = "":U then next.
  find ub.goods no-lock
    where ub.goods.prod-type = {1}.prod-type
      and ub.goods.prod-code = {1}.prod-code
      and ub.goods.artic = {1}.artic
  .
  find ub.gds-prt no-lock
    where ub.gds-prt.upper-code = ub.goods.prt-root
  .

  if {1}.qnty = ? then do:
    run gbl/d-prompt.w (
      'title=':u +  substitute("ЕАН &1" , {1}.b-str )  + '\':u
    + 'text1=':u + substitute("Для товара  &1 &2" ,  ub.goods.artic , ub.goods.gds-name )  + '\':u
    + 'text2=':u + "Введите количество" + '\':u
    + 'format=' + ">>>>9" + '\':u
    + 'type=' + {&type-int} + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=7\':u
    + 'fillin_height=1\':u
    + 'max-chars=5\':u
    + 'readonly=no\':u
    , input-output v-value{&vssseq}
    ).
    if return-value = 'false':u
        then {1}.qnty .
        else {1}.qnty = int(v-value{&vssseq}) .
  end.
  assign
    rootnode_code = ub.gds-prt.node-code
    list-qnty = {1}.qnty
  .

  if v-cntxp-doc-prt AND TickOnS AND can-find(first ub.gds-prt where ub.gds-prt.upper-code = rootnode_code) then do:
    assign
      prn-prt = TRUE
    .
  end.
  else do:
    assign
      prn-prt = FALSE
    .
  end.


  find first ub.bar-code no-lock where
            ub.bar-code.b-code = {1}.b-code no-error .
  if available ub.bar-code then do:
    if {1}.b-str <> "":U
    and not {1}.loc-ean then do:
      define buffer buf_prod-bc for ub.prod-bc.
      find first buf_prod-bc where buf_prod-bc.b-code =
                  {1}.b-code
              AND buf_prod-bc.b-str = {1}.b-str no-error .
      ListProdbc = buf_prod-bc.b-str.
      do on error undo, return error :
        {&need-prn}
        { rep/ticket.i }
      end. /*doe*/
    end. /*if {1}.b-str = "":U*/
    if {1}.b-str <> "":U
    and {1}.loc-ean then do:
      ListProdbc = {1}.b-str.
      do on error undo, return error :
        {&need-prn}
        { rep/ticket.i }
      end. /*doe*/
    end. /*if {1}.b-str = "":U*/

  end. /*if available bar-code then do:*/

end. /*for each {1}*/

{ rep/tick-end.i }

/* $Workfile$ e n d */