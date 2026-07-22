/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по ВЕЛИЧИНЕ СУММ ПРОДАЖ - сбор данных - тело цикла по строкам чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

IF chk-doc.netto < 0 and NOT RETS then NEXT.
ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
for-sum = (chk-gds.price-base - chk-gds.discnt) * chk-gds.doc-qnty.
if chk-gds.doc-qnty < 0 AND chk-doc.netto > 0 then do: /*отмены и аннуляции*/
  rest = chk-gds.doc-qnty.
  FOR EACH for-gds WHERE
        for-gds.Doc-code = chk-gds.doc-code AND
        for-gds.b-code = chk-gds.b-code AND
        for-gds.doc-qnty > 0 AND
        recid(for-gds) <> recid(chk-gds) NO-LOCK :
  FIND FIRST cancells where cancells.rd = recid(for-gds) NO-LOCK NO-ERROR.
  IF NOT AVAILABLE(cancells) then do:
    create cancells.
    assign cancells.rd = recid(for-gds)
    cancells.doc-qnty = for-gds.doc-qnty.
  end.
  for-sum = cancells.doc-qnty * (for-gds.price-base - for-gds.discnt).
  FIND FIRST for-sum-vals WHERE
              for-sum-vals.sum1 <   for-sum AND
              for-sum-vals.sum2 >= for-sum NO-LOCK NO-ERROR.
  IF AVAILABLE (for-sum-vals) then do:
    FIND FIRST grp-h WHERE
              grp-h.obj-code  = v-obj-code
          AND grp-h.grp-code  = goods.grp-code
          AND grp-h.sum1 = for-sum-vals.sum1 no-error .
    IF AVAILABLE(grp-h)
    THEN
    ASSIGN
    grp-h.num-chk[ii-sec + 1] = grp-h.num-chk[ii-sec + 1] - 1
    .
    if byobject then do:
      FIND FIRST tot_grp-h WHERE
                tot_grp-h.obj-code  = 0
            AND tot_grp-h.grp-code  = goods.grp-code
            AND tot_grp-h.sum1 = for-sum-vals.sum1 no-error .
      IF AVAILABLE(tot_grp-h)
      THEN
      ASSIGN
      tot_grp-h.num-chk[ii-sec + 1] = tot_grp-h.num-chk[ii-sec + 1] - 1
      .
    end.
    assign
    rest = cancells.doc-qnty + rest.
    cancells.doc-qnty = rest.
    if rest >= 0 then do:
        for-sum = rest * (for-gds.price-base - for-gds.discnt).
        LEAVE.
    end.
  end. /*IF avail for-sum-vals*/
      end. /*FOR EACH*/
end. /*отмены и аннуляции*/
IF for-sum = 0 then NEXT.
FIND  FIRST sum-vals WHERE
            sum-vals.sum1 <   for-sum AND
            sum-vals.sum2 >= for-sum NO-LOCK NO-ERROR.
IF AVAILABLE (sum-vals) then do:
  FIND FIRST grp-h WHERE
             grp-h.obj-code = v-obj-code
         AND grp-h.grp-code = goods.grp-code
         AND grp-h.sum1 = sum-vals.sum1 NO-ERROR .
  if byobject then
  FIND FIRST tot_grp-h WHERE
             tot_grp-h.obj-code = 0
         AND tot_grp-h.grp-code = goods.grp-code
         AND tot_grp-h.sum1 = sum-vals.sum1 NO-ERROR .
  if NOT available grp-h then do:
    CREATE grp-h .
    assign
    grp-h.obj-code  = v-obj-code
    grp-h.grp-code  = goods.grp-code
    grp-h.sum1 = sum-vals.sum1.
  end.
  if byobject and NOT available tot_grp-h then do:
    CREATE tot_grp-h .
    assign
    tot_grp-h.obj-code  = 0
    tot_grp-h.grp-code  = goods.grp-code
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
ACCUM-chk-gds = accum-chk-gds + 1 .
if ( ( ACCUM-chk-gds) modulo 50 ) = 0 AND ( ACCUM-chk-gds ) >= 50
then
run waitfram-show in this-procedure ( "Обработано строк чеков : " + string( ACCUM-chk-gds ) ) .


/* $Workfile$ e n d */