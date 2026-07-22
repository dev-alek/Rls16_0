block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lockgdoc.p $
$Archive: gbl/lockgdoc.p $

Блокировка создания записей gds-obj на объекте

Автор: Перваков Михаил Сергеевич
Дата создания: 03/15/05
Author: Mikhail Pervakov
Creation date: 03/15/05

*/

define input  parameter p-obj-type      as character no-undo .
define input  parameter p-obj-code      as integer   no-undo .
define input  parameter p-lock-gds-type as character no-undo .
define input  parameter p-sub-type      as character no-undo .
define parameter buffer lock_batchprocess for ub.batchprocess .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lockgdoc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/lockgdoc.p $":U .
define variable vss-description as character no-undo initial "Блокировка переименования товара".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,p-obj-type,p-obj-code,p-lock-gds-type,p-sub-type)" }
{ cmp/trg-def.i  }

define variable v-lock-type as character no-undo .

do
on error undo, return error return-value
:
  if  p-lock-gds-type <> {&lock-prc-gds-obj-create}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение типа блокировки" skip
      "Объект" p-obj-type p-obj-code skip
      "Тип блокировки" p-lock-gds-type skip
      "Подтип блокировки" p-sub-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  case p-sub-type
  :
    when {&lock-prc-subtype-enable}
    then do:
      assign
        v-lock-type = 'share-lock':u
      .
    end.
    when {&lock-prc-subtype-disable}
    then do:
      assign
        v-lock-type = 'exclusive-lock':u
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение подтипа блокировки" skip
        "Тип блокировки" p-lock-gds-type skip
        "Подтип блокировки" p-sub-type skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  run gbl/lockshpr.p
    (input p-lock-gds-type    /* p-process-key     */
    ,input p-obj-code         /* p-Key#_One        */
    ,input 0                  /* p-Key#_Two        */
    ,input 0                  /* p-Key#_Three      */
    ,input p-obj-type         /* p-CharKey_One     */
    ,input ""                 /* p-CharKey_Two     */
    ,input ""                 /* p-CharKey_Three   */
    ,input v-lock-type        /* p-lock-type       */
    ,buffer lock_batchprocess /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры lockshpr.p" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end.