/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ПОКУПОК - сбор данных - тело цикла

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
find first num-h where num-h.obj-code = v-obj-code no-error .
if not available num-h then do:
  create num-h.
  assign
  num-h.obj-code = v-obj-code
  .
end.
assign
num-h.qnty = num-h.qnty + (if for-h[ii-sec + 1] then 1 else 0)
num-h.hour[ii-sec + 1] = num-h.hour[ii-sec + 1] + 1
.
if byobject then do:
  find first tot_num-h where tot_num-h.obj-code = 0 no-error .
  if not available tot_num-h then do:
    create tot_num-h.
    assign
    tot_num-h.obj-code = 0
    .
  end.
  assign
  tot_num-h.qnty = tot_num-h.qnty + (if for-h[ii-sec + 1] then 1 else 0)
  tot_num-h.hour[ii-sec + 1] = tot_num-h.hour[ii-sec + 1] + 1
  .
end.
accum-chk-doc = accum-chk-doc + 1.
if ( ( ACCUM-chk-doc ) modulo 50 ) = 0 AND
    ( ACCUM-chk-doc) >= 50 then
run waitfram-show in this-procedure ( "Обработано чеков : " +  string( ACCUM-chk-doc ) ) .
FOR EACH ub.chk-gds WHERE
         ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK ,
    FIRST ub.bar-code WHERE
          ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK ,
    FIRST ub.goods WHERE
          ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK:
    if rs-option = 3 then
    FIND FIRST chk-h WHERE
                    chk-h.grp-code = 0
                AND chk-h.obj-code = v-obj-code
    NO-ERROR .
    else
    FIND FIRST chk-h WHERE
                    chk-h.grp-code = ub.goods.grp-code
                AND chk-h.obj-code = v-obj-code
    NO-ERROR .

    if byobject then do:
      if rs-option = 3 then
      FIND FIRST tot_chk-h WHERE
                      tot_chk-h.grp-code = 0
                  AND tot_chk-h.obj-code = 0
      NO-ERROR .
      else
      FIND FIRST tot_chk-h WHERE
                      tot_chk-h.grp-code = ub.goods.grp-code
                  AND tot_chk-h.obj-code = 0
      NO-ERROR .

    end.
    if NOT available chk-h then do:
      CREATE chk-h .
      assign
      chk-h.grp-code = (IF RS-OPTION = 3 then 0  else ub.goods.grp-code  )
      chk-h.obj-code = v-obj-code
      .
    end.
    if byobject and NOT available tot_chk-h then do:
      CREATE tot_chk-h .
      assign
      tot_chk-h.grp-code = (IF RS-OPTION = 3 then 0  else ub.goods.grp-code  )
      tot_chk-h.obj-code = 0
      .
    end.

  assign
  chk-h.qnty = chk-h.qnty + (if for-h[ii-sec + 1] then ( if ub.chk-gds.doc-qnty > 0 then 1 else ( - 1 ) ) else 0)
  chk-h.hour[ii-sec + 1] = chk-h.hour[ii-sec + 1] + ( if ub.chk-gds.doc-qnty > 0 then 1 else ( - 1 ) )
  .
  if byobject then do:
    assign
    tot_chk-h.qnty = tot_chk-h.qnty + (if for-h[ii-sec + 1] then ( if ub.chk-gds.doc-qnty > 0 then 1 else ( - 1 ) ) else 0)
    tot_chk-h.hour[ii-sec + 1] = tot_chk-h.hour[ii-sec + 1] + ( if ub.chk-gds.doc-qnty > 0 then 1 else ( - 1 ) )
    .
  end.
  PROCESS EVENTS .
END.


/* $Workfile$ e n d */