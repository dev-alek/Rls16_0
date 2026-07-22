/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ - сбор данных - тело цикла по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
IF With-goods = 0 then do:
  FIND FIRST grp-h WHERE
          grp-h.obj-code = v-obj-code
      AND grp-h.grp-code = 0
      NO-ERROR .
 if v-obj-code > 0 then
  FIND FIRST tot_grp-h WHERE
          tot_grp-h.obj-code = 0
      AND tot_grp-h.grp-code = 0
      NO-ERROR .
end.
else do:
  FIND FIRST grp-h WHERE
          grp-h.obj-code = v-obj-code
      AND grp-h.grp-code = chk-doc.pay-desk
      AND grp-h.other-code = chk-doc.obj-code NO-ERROR .
 if v-obj-code > 0 then
  FIND FIRST tot_grp-h WHERE
          tot_grp-h.obj-code = 0
      AND tot_grp-h.grp-code = 0
      and tot_grp-h.other-code = 0 NO-ERROR .

end.
if NOT available grp-h then do:
    CREATE grp-h .
    assign
    grp-h.grp-code             = (IF with-goods = 1 THEN chk-doc.pay-desk else 0)
    grp-h.obj-code             = (IF with-goods = 1 then chk-doc.obj-code else v-obj-code)
    grp-h.other-code           = (IF with-goods = 1 then chk-doc.obj-code else 0)
    grp-h.sum[ii-sec + 1]      = 0
    grp-h.sum_disc[ii-sec + 1] = 0
    grp-h.num-chk[ii-sec + 1]  = 0
    .
end.
if v-obj-code > 0 AND NOT available tot_grp-h then do:
    CREATE tot_grp-h .
    assign
    tot_grp-h.grp-code             = 0
    tot_grp-h.obj-code             = 0
    tot_grp-h.other-code           = 0
    tot_grp-h.sum[ii-sec + 1]      = 0
    tot_grp-h.sum_disc[ii-sec + 1] = 0
    tot_grp-h.num-chk[ii-sec + 1]  = 0
    .
end.
assign
grp-h.sum[ii-sec + 1]      = grp-h.sum[ii-sec + 1] + chk-doc.tot-doc
grp-h.sum_disc[ii-sec + 1] = grp-h.sum_disc[ii-sec + 1] + chk-doc.discnt
grp-h.num-chk[ii-sec + 1]  = grp-h.num-chk[ii-sec + 1] + 1
.
if v-obj-code > 0 then
assign
tot_grp-h.sum[ii-sec + 1]      = tot_grp-h.sum[ii-sec + 1] + chk-doc.tot-doc
tot_grp-h.sum_disc[ii-sec + 1] = tot_grp-h.sum_disc[ii-sec + 1] + chk-doc.discnt
tot_grp-h.num-chk[ii-sec + 1]  = tot_grp-h.num-chk[ii-sec + 1] + 1
.
PROCESS EVENTS .
accum-chk-doc = accum-chk-doc + 1.
if ( ( ACCUM-chk-doc ) modulo 50 ) = 0 AND
      ( accum-chk-doc ) >= 50
then
run waitfram-show in this-procedure ( "Обработано  чеков : " + string( ACCUM-chk-doc ) ) .



/* $Workfile$ e n d */