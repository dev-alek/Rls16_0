/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ - сбор данных - тело цикла по строкам оплат

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .

FIND FIRST grp-h WHERE
           grp-h.grp-code = v-obj-code
       AND grp-h.grp-code = chk-pay.pay-code
       ANd grp-h.other-code = chk-pay.curr-code NO-ERROR .
if v-obj-code > 0 then do:
  FIND FIRST tot_grp-h WHERE
            tot_grp-h.obj-code = 0
        AND tot_grp-h.grp-code = chk-pay.pay-code
        ANd tot_grp-h.other-code = chk-pay.curr-code NO-ERROR .
end.
if NOT available grp-h then do:
    CREATE grp-h .
    assign
    grp-h.obj-code            = v-obj-code
    grp-h.grp-code            = chk-pay.pay-code
    grp-h.other-code          = chk-pay.curr-code
    grp-h.sum[ii-sec + 1]     = 0
    grp-h.num-chk[ii-sec + 1] = 0
    .
end.
if v-obj-code > 0 AND NOT available tot_grp-h then do:
    CREATE tot_grp-h .
    assign
    tot_grp-h.obj-code            = 0
    tot_grp-h.grp-code            = chk-pay.pay-code
    tot_grp-h.other-code          = chk-pay.curr-code
    tot_grp-h.sum[ii-sec + 1]     = 0
    tot_grp-h.num-chk[ii-sec + 1] = 0
    .
end.
assign
grp-h.sum[ii-sec + 1]     = grp-h.sum[ii-sec + 1]  + (if v-curr-r-b = {&r-b-base} then chk-pay.tot-base else chk-pay.tot-rubl)
grp-h.num-chk[ii-sec + 1] = grp-h.num-chk[ii-sec + 1] + 1
.
if v-obj-code > 0 then
assign
tot_grp-h.sum[ii-sec + 1]     = tot_grp-h.sum[ii-sec + 1]  + (if v-curr-r-b = {&r-b-base} then chk-pay.tot-base else chk-pay.tot-rubl)
tot_grp-h.num-chk[ii-sec + 1] = tot_grp-h.num-chk[ii-sec + 1] + 1
.

PROCESS EVENTS .
accum-chk-pay = accum-chk-pay .
if ( ( ACCUM-chk-pay) modulo 50 ) = 0 AND
    ( ACCUM-chk-pay ) >= 50
then
run waitfram-show in this-procedure ( "Обработано строк оплат : " + string( ACCUM-chk-pay ) ) .



/* $Workfile$ e n d */