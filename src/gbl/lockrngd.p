block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lockrngd.p $
$Archive: gbl/lockrngd.p $

Блокировка переименования товара

Автор: Перваков Михаил Сергеевич
Дата создания: 03/02/04
Author: Mikhail Pervakov
Creation date: 03/02/04

*/

define input  parameter p-lock-gds-type   as character no-undo .
define input  parameter p-sub-type        as character no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lockrngd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/lockrngd.p $":U .
define variable vss-description as character no-undo initial "Блокировка переименования товара".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-lock-gds-type,p-sub-type)" }
{ cmp/trg-def.i  }


do
on error undo, return error return-value
:
  if  p-lock-gds-type <> {&lock-prc-goods-rename-artic}
  and p-lock-gds-type <> {&lock-prc-goods-rename-gds-code}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение типа блокировки" skip
      "Тип блокировки" p-lock-gds-type skip
      "Подтип блокировки" p-sub-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if  p-sub-type <> {&lock-prc-subtype-disable}
  and p-sub-type <> {&lock-prc-subtype-enable}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение подтипа блокировки" skip
      "Тип блокировки" p-lock-gds-type skip
      "Подтип блокировки" p-sub-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run gbl/lock-swi.p
    (input p-lock-gds-type           /* p-process-key     */
    ,input p-sub-type                /* p-sub-key         */
    ,input 3600                      /* p-timeout         */
    ,input "Переименование артикула" /* p-key-descr       */
    ,input 0                         /* p-Key#_One        */
    ,input 0                         /* p-Key#_Two        */
    ,input 0                         /* p-Key#_Three      */
    ,input ""                        /* p-CharKey_One     */
    ,input ""                        /* p-CharKey_Two     */
    ,input ""                        /* p-CharKey_Three   */
    ,buffer lock_batchprocess        /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры lock-swi.p" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
end.