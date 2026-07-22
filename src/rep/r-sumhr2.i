/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ - сбор данных - тело цикла по строкам чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
FIND FIRST grp-h WHERE
       grp-h.obj-code = v-obj-code
   AND grp-h.grp-code = goods.grp-code NO-ERROR .
if v-obj-code > 0 then do:
  FIND FIRST tot_grp-h WHERE
        tot_grp-h.obj-code = 0
    AND tot_grp-h.grp-code = goods.grp-code NO-ERROR .
end.
if NOT available grp-h then do:
    CREATE grp-h .
    assign
    grp-h.grp-code             = goods.grp-code
    grp-h.obj-code             = v-obj-code
    grp-h.sum[ii-sec + 1]      = 0
    grp-h.sum_disc[ii-sec + 1] = 0
    .
end.
if v-obj-code > 0 and NOT available tot_grp-h then do:
    CREATE tot_grp-h .
    assign
    tot_grp-h.grp-code             = goods.grp-code
    tot_grp-h.obj-code             = 0
    tot_grp-h.sum[ii-sec + 1]      = 0
    tot_grp-h.sum_disc[ii-sec + 1] = 0
    .
end.
assign
grp-h.sum[ii-sec + 1]      = grp-h.sum[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.price-base
grp-h.sum_disc[ii-sec + 1] = grp-h.sum_disc[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.discnt
.
if v-obj-code > 0 then
assign
tot_grp-h.sum[ii-sec + 1]      = tot_grp-h.sum[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.price-base
tot_grp-h.sum_disc[ii-sec + 1] = tot_grp-h.sum_disc[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.discnt
.

if With-Goods = 3 then do:
    FIND FIRST gds-h WHERE
                    gds-h.obj-code = v-obj-code
                AND gds-h.grp-code = goods.grp-code
                AND gds-h.b-code = bar-code.b-code NO-ERROR .
    if v-obj-code > 0 then
    FIND FIRST tot_gds-h WHERE
                    tot_gds-h.obj-code = 0
                AND tot_gds-h.grp-code = goods.grp-code
                AND tot_gds-h.b-code = bar-code.b-code NO-ERROR .
    if NOT available gds-h then do:
        CREATE gds-h .
        assign
        gds-h.obj-code             = v-obj-code
        gds-h.gds-name             = goods.gds-name
        gds-h.grp-code             = goods.grp-code
        gds-h.b-code               = bar-code.b-code
        gds-h.uniq                 = goods.artic + goods.prod-type + string( goods.prod-code )
        gds-h.artic                = goods.artic
        gds-h.sum[ii-sec + 1]      = 0
        gds-h.sum_disc[ii-sec + 1] = 0
        .
    end.
    if v-obj-code > 0 and NOT available tot_gds-h then do:
        CREATE tot_gds-h .
        assign
        tot_gds-h.obj-code             = 0
        tot_gds-h.gds-name             = goods.gds-name
        tot_gds-h.grp-code             = goods.grp-code
        tot_gds-h.b-code               = bar-code.b-code
        tot_gds-h.uniq                 = goods.artic + goods.prod-type + string( goods.prod-code )
        tot_gds-h.artic                = goods.artic
        tot_gds-h.sum[ii-sec + 1]      = 0
        tot_gds-h.sum_disc[ii-sec + 1] = 0
        .
    end.
    assign
    gds-h.sum[ii-sec + 1]      = gds-h.sum[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.price-base
    gds-h.sum_disc[ii-sec + 1] = gds-h.sum_disc[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.discnt
    .
    if v-obj-code > 0 then
    assign
    tot_gds-h.sum[ii-sec + 1]      = tot_gds-h.sum[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.price-base
    tot_gds-h.sum_disc[ii-sec + 1] = tot_gds-h.sum_disc[ii-sec + 1] + chk-gds.doc-qnty * chk-gds.discnt
    .

end.
PROCESS EVENTS .
accum-chk-gds = accum-chk-gds .
if ( ( ACCUM-chk-gds) modulo 50 ) = 0 AND
    ( ACCUM-chk-gds ) >= 50
then
run waitfram-show in this-procedure ("Обработано строк чеков : " +
                string( ACCUM-chk-gds ) ) .



/* $Workfile$ e n d */