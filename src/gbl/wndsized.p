block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wndsized.p $
$Archive: gbl/wndsized.p $

Удаление пользовательских параметров настройки интерфейса

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/05

*/

define input  parameter p-db-num      as integer   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-window-name as character no-undo .
define input  parameter p-attr-code  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wndsized.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/wndsized.p $":U .
define variable vss-description as character no-undo init "Удаление пользовательских параметров настройки интерфейса".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-user-id,p-window-name,p-attr-code)" }
{ cmp/trg-def.i  }

define buffer buf_user-window-attr for ubflt.user-window-attr .

do
on error undo, return error return-value
:
  if p-db-num = ?
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

  find first buf_user-window-attr exclusive-lock
    where buf_user-window-attr.db-num           = p-db-num
      and buf_user-window-attr.user-id          = p-user-id
      and buf_user-window-attr.user-window-name = p-window-name
      and buf_user-window-attr.attr-code        = p-attr-code
    no-error .
  if available buf_user-window-attr
  then do:
    delete buf_user-window-attr .
  end.
end.