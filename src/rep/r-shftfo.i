/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение fact-order (start и end) для смены

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/29/08
Author: Dmitry Ukhanov
Creation date: 04/29/08

*/

/*находим fact-order*/
define buffer end_shift-obj      for ub.shift-obj .
define buffer previous-shift-obj for ub.shift-obj.
define variable fo      as decimal no-undo init 0.
define variable prev-fo as decimal no-undo init 0.
define variable moving  as logical no-undo init yes.

find first end_shift-obj share-lock
  where end_shift-obj.obj-type   = pobj-type
    and end_shift-obj.obj-code   = pobj-code
    and end_shift-obj.shift-date = pshift-date1
    and end_shift-obj.shift-num  = pshift-num1
    no-error.
if not available end_shift-obj then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute("Не найдена смена с порядковым номером &1 от &2 для объекта &3 &4", pshift-num1, pshift-date1, pobj-type, pobj-code ) skip
    view-as alert-box error .
  return error.
end.
else do:
  assign
    fo = end_shift-obj.fact-order
  .
end.
find last previous-shift-obj share-lock
  where previous-shift-obj.obj-type = pobj-type
    and previous-shift-obj.obj-code = pobj-code
    and (( previous-shift-obj.shift-date = pshift-date
           and previous-shift-obj.shift-num < pshift-num
         )
         or previous-shift-obj.shift-date < pshift-date
        )
    use-index pi no-error.
if available previous-shift-obj then do:
  &if "{1}" = "attr-arh-detail-date" &then
    if  previous-shift-obj.shift-date < p-previous-shift-date then do:
      run day-begin-fact-order in this-procedure (
                                              input  p-previous-shift-date
                                             ,output prev-fo).
    end.
    else do:
  &endif
    assign
      prev-fo = previous-shift-obj.fact-order
    .
  &if "{1}" = "attr-arh-detail-date" &then
    end.
  &endif
end.

/* $Workfile$ e n d */