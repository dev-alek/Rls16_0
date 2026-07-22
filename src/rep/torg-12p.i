/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для печатной формы torg-12p

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&if "{2}" <> "" &then
    if FullGdsName then
        do:
            do while gds-str2 <> "" :
                assign gds-str = gds-str2.
                gds-str1 = breakstr(gds-str, {2}, input-output gds-str1, input-output gds-str2).
                display stream out-stream
                    gds-str1 @ goods.gds-name
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10
                    sym11 sym12 sym13 sym14 sym15
                    with frame f-doc .
                down stream out-stream 1 with frame f-doc .
            end. /* do while ... */
        end.
&endif

if page-number( out-stream ) > prevpage then
    assign
      v-page-qnty                 = 0
      v-page-qnty-kg              = 0
      v-page-sum-without-vat-slt  = 0
      v-page-sum-vat              = 0
      v-page-sum-without-slt      = 0
        .

do:
    put stream out-stream v-single-line format "x(189)" skip.
    display stream out-stream
        "Итого" @ goods.gds-name
        v-page-qnty                 @ doc-line.fact-qnty
        v-page-qnty-kg              @ v-qnty-kg
        v-page-sum-without-vat-slt  @ v-sum-without-vat-slt
        v-page-sum-vat              @ v-sum-vat
        v-page-sum-without-slt      @ v-sum-without-slt
        with frame f-doc .
    down stream out-stream 1 with frame f-doc .
    prevpage = prevpage + 1.
end.

/* $Workfile$ e n d */