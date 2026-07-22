block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: arhichk.p $
$Archive: utl/arhichk.p $

Создание истории по проверке архива, переоценок

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/19/04

*/

define input  parameter p-obj-type         as character no-undo .
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-archive-type     as character no-undo .
define input  parameter p-action-type      as character no-undo .
define input  parameter p-start-check-date as date      no-undo .
define input  parameter p-error-number     as integer   no-undo .
define input  parameter p-status-message   as character no-undo .
define output parameter p-create-chip-num  as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: arhichk.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/arhichk.p $":U .
define variable vss-description as character no-undo initial "Создание истории по сохранению архива".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

define buffer buf_archive-history for ub.archive-history .

do
on error undo, return error return-value
:
  if p-archive-type = ?
  or lookup(p-archive-type
           , {&btpr-type-arh}
           + {&comma-char} + {&btpr-type-ahsp}
           + {&comma-char} + {&btpr-type-aht}
           + {&comma-char} + {&btpr-type-prc}
           ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра типа архива" skip
      "Объект" p-obj-type p-obj-code skip
      "Тип архива" p-archive-type skip
      "Действие" p-action-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-action-type = ?
  or lookup(p-action-type
           ,{&archive-history-check-start}
           + {&comma-char} + {&archive-history-check-stop}
           ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра действия" skip
      "Объект" p-obj-type p-obj-code skip
      "Тип архива" p-archive-type skip
      "Действие" p-action-type skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define variable v-chip-num as integer   no-undo .

  find last buf_archive-history exclusive-lock
    where buf_archive-history.obj-type     = p-obj-type
      and buf_archive-history.obj-code     = p-obj-code
      and buf_archive-history.archive-type = p-archive-type
    use-index pi
    no-error .
  if available buf_archive-history
  then do:
    assign
      v-chip-num = buf_archive-history.chip-num + 1
    .
  end.
  else do:
    assign
      v-chip-num = 1
    .
  end.

  assign
    p-create-chip-num = v-chip-num
  .

  create buf_archive-history .
  assign
    buf_archive-history.obj-type     = p-obj-type
    buf_archive-history.obj-code     = p-obj-code
    buf_archive-history.archive-type = p-archive-type
    buf_archive-history.chip-num     = v-chip-num
    buf_archive-history.action-type  = p-action-type
  .

  { gbl/curdburt.i
    buf_archive-history.corr-user-db-num
    buf_archive-history.corr-user-name
    buf_archive-history.corr-date
    buf_archive-history.corr-time-str
    buf_archive-history.corr-time
  }

  assign
    buf_archive-history.source-date = p-start-check-date
    buf_archive-history.PS          = p-status-message
  .
end.