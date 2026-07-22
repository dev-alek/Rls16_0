/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовая статистика розничных продаж по ВЕЛИЧИНЕ СУММ ПРОДАЖ - сбор данных - тело цикла по строкам оплат

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

IF chk-doc.netto < 0 and NOT RETS then NEXT.
ii-sec = integer( truncate( chk-doc.chk-time / 3600 , 0 ) ) .
for-sum = (if v-curr-r-b = {&r-b-base} then chk-pay.tot-base else chk-pay.tot-rubl).

if (
    (v-curr-r-b = {&r-b-base} and chk-pay.tot-base < 0)
OR
    (v-curr-r-b = {&r-b-rubl} and chk-pay.tot-rubl < 0)
   )
AND chk-doc.netto >= 0  then do: /*сдача*/
  rest = (if v-curr-r-b = {&r-b-base} then chk-pay.tot-base else chk-pay.tot-rubl).
  found-similar = no.
  FOR EACH for-pay WHERE
        for-pay.Doc-code = chk-pay.doc-code AND
        for-pay.pay-code = chk-pay.pay-code AND
        for-pay.curr-code = chk-pay.curr-code and
            recid(for-pay) <> recid(chk-pay) NO-LOCK :
    if (v-curr-r-b = {&r-b-base} and  for-pay.tot-BASE <= 0)
    OR (v-curr-r-b = {&r-b-RUBL} and  for-pay.tot-RUBL <= 0) THEN next.
    FIND FIRST cancells where cancells.rd = recid(for-pay) NO-LOCK NO-ERROR.
    IF NOT AVAILABLE(cancells) then do:
      create cancells.
      assign cancells.rd = recid(for-pay)
      cancells.doc-qnty = (IF v-curr-r-b = {&r-b-base}
                           THEN for-pay.tot-BASE
                           ELSE for-pay.tot-rUBL)
                           .
    end.
    for-sum = cancells.doc-qnty.
    IF AVAILABLE (for-sum-vals) then do:
      FIND FIRST grp-h WHERE
                 grp-h.obj-code  = v-obj-code
             AND grp-h.grp-code  = chk-pay.pay-code
             AND grp-h.other-code  = chk-pay.curr-code
             AND grp-h.sum1 = for-sum-vals.sum1 No-ERROR.
      IF AVAILABLE(grp-h) THEN
      ASSIGN
      grp-h.num-chk[ii-sec + 1] = grp-h.num-chk[ii-sec + 1] - 1
      .
      if byobject then do:
        FIND FIRST tot_grp-h WHERE
                  tot_grp-h.obj-code  = 0
              AND tot_grp-h.grp-code  = chk-pay.pay-code
              AND tot_grp-h.other-code  = chk-pay.curr-code
              AND tot_grp-h.sum1 = for-sum-vals.sum1 No-ERROR.
        IF AVAILABLE(tot_grp-h) THEN
        ASSIGN
        tot_grp-h.num-chk[ii-sec + 1] = tot_grp-h.num-chk[ii-sec + 1] - 1
        .
      end.
      assign rest = cancells.doc-qnty + rest.
      cancells.doc-qnty = rest.
      if rest >= 0 then do:
          for-sum = rest .
          LEAVE.
      end.
    end. /*IF avail for-sum-vals*/
  end. /*FOR EACH*/

  if not found-similar then do:
    FOR EACH for-pay WHERE
          for-pay.Doc-code = chk-pay.doc-code AND

          recid(for-pay) <> recid(chk-pay) NO-LOCK :
      IF (V-CURR-R-B = {&r-b-base} and for-pay.tot-base <= 0 )
      OR (V-CURR-R-B = {&r-b-rubl} and for-pay.tot-rubl <= 0 )  THEN NEXT.
      FIND FIRST cancells where cancells.rd = recid(for-pay) NO-LOCK NO-ERROR.
      IF NOT AVAILABLE(cancells) then do:
        create cancells.
        assign cancells.rd = recid(for-pay)
        cancells.doc-qnty = (if V-CURR-R-B = {&r-b-base}
                             then for-pay.tot-base
                             else for-pay.tot-rubl)
                             .
      end.
      for-sum = cancells.doc-qnty.
      if byobject then
      FIND FIRST for-sum-vals WHERE
                  for-sum-vals.sum1 <   for-sum
              AND for-sum-vals.sum2 >= for-sum NO-LOCK NO-ERROR.
      IF AVAILABLE (for-sum-vals) then do:
        FIND FIRST grp-h WHERE
                   grp-h.obj-code  = chk-pay.obj-code
               AND grp-h.grp-code  = chk-pay.pay-code
               AND grp-h.other-code  = chk-pay.curr-code
               AND grp-h.sum1 = for-sum-vals.sum1 No-ERROR.
        IF AVAILABLE(grp-h) THEN
        ASSIGN
        grp-h.num-chk[ii-sec + 1] = grp-h.num-chk[ii-sec + 1] - 1
        .
        if byobject then do:
          FIND FIRST tot_grp-h WHERE
                    tot_grp-h.obj-code  = 0
                AND tot_grp-h.grp-code  = chk-pay.pay-code
                AND tot_grp-h.other-code  = chk-pay.curr-code
                AND tot_grp-h.sum1 = for-sum-vals.sum1 No-ERROR.
          IF AVAILABLE(tot_grp-h) THEN
          ASSIGN
          tot_grp-h.num-chk[ii-sec + 1] = tot_grp-h.num-chk[ii-sec + 1] - 1
          .
        end.
        assign rest = cancells.doc-qnty + rest.
        cancells.doc-qnty = rest.
        if rest >= 0 then do:
            for-sum = rest .
            LEAVE.
        end.
      end. /*IF avail for-sum-vals*/
    END. /*OFR EAC*/
  end.
end. /*отмены и аннуляции*/
IF for-sum = 0 then NEXT.
FIND  FIRST sum-vals WHERE
            sum-vals.sum1 <   for-sum AND
            sum-vals.sum2 >= for-sum NO-LOCK NO-ERROR.
IF AVAILABLE (sum-vals) then do:
  FIND FIRST grp-h WHERE
             grp-h.obj-code = v-obj-code
         AND grp-h.grp-code = chk-pay.pay-code
         AND grp-h.other-code = chk-pay.curr-code
         AND grp-h.sum1 = sum-vals.sum1 NO-ERROR .
  if byobject then FIND FIRST tot_grp-h WHERE
             tot_grp-h.obj-code = 0
         AND tot_grp-h.grp-code = chk-pay.pay-code
         AND tot_grp-h.other-code = chk-pay.curr-code
         AND tot_grp-h.sum1 = sum-vals.sum1 NO-ERROR .
  if NOT available grp-h then do:
    CREATE grp-h .
    assign
    grp-h.obj-code  = v-obj-code
    grp-h.grp-code  = chk-pay.pay-code
    grp-h.other-code = chk-pay.curr-code
    grp-h.sum1 = sum-vals.sum1.
  end.
  if byobject and NOT available tot_grp-h then do:
    CREATE tot_grp-h .
    assign
    tot_grp-h.obj-code  = 0
    tot_grp-h.grp-code  = chk-pay.pay-code
    tot_grp-h.other-code = chk-pay.curr-code
    tot_grp-h.sum1 = sum-vals.sum1.
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
ACCUM-chk-pay = accum-chk-pay + 1 .
if ( ( ACCUM-chk-pay) modulo 50 ) = 0 AND ( ACCUM-chk-pay ) >= 50
then
run waitfram-show in this-procedure ("Обработано строк оплат : " + string( ACCUM-chk-pay ) ) .



/* $Workfile$ e n d */