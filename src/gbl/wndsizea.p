block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wndsizea.p $
$Archive: gbl/wndsizea.p $

Удаление пользовательских параметров настройки интерфейса для всех окон

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/05

*/

define input  parameter p-db-num  as integer   no-undo .
define input  parameter p-user-id as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wndsizea.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/wndsizea.p $":U .
define variable vss-description as character no-undo init "Удаление пользовательских параметров настройки интерфейса для всех окон".
{ cmp/vssrevis.i "substitute('&1':u,p-user-id)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }

define variable v-ind as integer   no-undo .

define buffer buf_user-window-attr for ubflt.user-window-attr .

do
on error undo, return error return-value
:
  if p-db-num  = ?
  then do:
    assign
      p-db-num = g#db-num
    .
  end.

  if p-user-id = ""
  then do:
    assign
      p-user-id = g#userid
    .
  end.

  assign
    v-ind = 0
  .

  run waitfram-show in this-procedure
    (input  substitute("Удаление атрибутов окон для пользователя &1", p-user-id)
    ) .
  for each buf_user-window-attr exclusive-lock
    where buf_user-window-attr.db-num  = p-db-num
      and buf_user-window-attr.user-id = p-user-id
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    delete buf_user-window-attr .
  end.

  message
    "Удаление атрибутов окон успешно завершено" skip
    "Удалено записей" v-ind skip
    view-as alert-box information .
end.