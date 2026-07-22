block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clr-arh.p $
$Archive: utl/clr-arh.p $

Полная очистка складского архива по товарам

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/01/03

*/


define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clr-arh.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/clr-arh.p $":U .
define variable vss-description as character no-undo initial "Полная очистка складского архива по товарам".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }

do
on error undo, return error return-value
:
  define variable v-message-on as logical   no-undo .

  assign
    v-message-on = true
  .
  define buffer calc-arh-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-arh}
    ,input p-obj-code
    ,input 0
    ,input 0
    ,input p-obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по товарам"
    ,input v-message-on
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if v-message-on = true
    or error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно произвести очистку складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "В данный момент рассчитывается складской архив по товарам" .
  end.

  define variable v-ok as logical no-undo .

  run clntattr-delete in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input {&attr-arh-detail-date}
    ,output v-ok
    ) .

  run clntattr-delete in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input {&attr-arh-start-date}
    ,output v-ok
    ) .

  run clntattr-delete in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input {&attr-arh-recalc-date}
    ,output v-ok
    ) .

  run clntattr-write in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input {&attr-arh-del}
    ,input true
    ) .

  run clntattr-write in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input {&attr-arh-calc}
    ,input true
    ) .

  run trg/arhclr.p
    (input p-obj-type /* p-obj-type        */
    ,input p-obj-code /* p-obj-code        */
    ,input 0          /* p-last-fact-order */
    ,input 0          /* p-cut-fact-order  */
    ,input ""         /* p-file-name       */
    ) .
end.