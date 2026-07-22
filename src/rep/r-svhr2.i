/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по ВЕЛИЧИНЕ СУММ ПРОДАЖ - сбор данных - тело цикла по чекам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

IF chk-doc.netto < 0 and NOT RETS then NEXT.
ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
FIND  FIRST sum-vals WHERE
            sum-vals.sum1 <   chk-doc.netto AND
            sum-vals.sum2 >= chk-doc.netto NO-LOCK NO-ERROR.
IF AVAILABLE (sum-vals) then do:
  FIND FIRST grp-h WHERE
             grp-h.obj-code = v-obj-code
         AND grp-h.sum1 = sum-vals.sum1 NO-ERROR .
  if byobject then
  FIND FIRST tot_grp-h WHERE
             tot_grp-h.obj-code = 0
         AND tot_grp-h.sum1 = sum-vals.sum1 NO-ERROR .

  if NOT available grp-h then  do:
    CREATE grp-h .
    assign
    grp-h.obj-code = v-obj-code
    grp-h.sum1 = sum-vals.sum1
    .
  end.
  if byobject and NOT available tot_grp-h then  do:
    CREATE tot_grp-h .
    assign
    tot_grp-h.obj-code = 0
    tot_grp-h.sum1 = sum-vals.sum1
    .
  end.

  assign
  grp-h.num-chk[ii-sec + 1] = grp-h.num-chk[ii-sec + 1] + 1
  .
  if byobject then
  assign
  tot_grp-h.num-chk[ii-sec + 1] = tot_grp-h.num-chk[ii-sec + 1] + 1
  .
END. /*IF avail SUM-vals*/
PROCESS EVENTS .
ACCUM-chk-doc = accum-chk-doc + 1 .
if ( ( ACCUM-chk-doc ) modulo 50 ) = 0 AND ( ACCUM-chk-doc ) >= 50
then
run waitfram-show in this-procedure ( "Обработано чеков : " +  string( ACCUM-chk-doc ) ) .



/* $Workfile$ e n d */