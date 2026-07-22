block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wndpar_d.p $
$Archive: gbl/wndpar_d.p $

Удаление пользовательских параметров настройки интерфейса

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/05

*/

define input  parameter p-db-num     as integer   no-undo .
define input  parameter p-user-id    as character no-undo .
define input  parameter p-param-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wndpar_d.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/wndpar_d.p $":U .
define variable vss-description as character no-undo init "Удаление пользовательских параметров настройки интерфейса".
{ cmp/vssrevis.i "substitute('&1|&2|&3':U,p-db-num,p-user-id,p-param-code)" }
{ cmp/trg-def.i  }

define buffer buf_user-login for ub.user-login .

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

  find first buf_user-login exclusive-lock
    where buf_user-login.db-num  = p-db-num
      and buf_user-login.user-id = p-user-id
    no-error .
  if not available buf_user-login
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена запись логина пользователя" skip
      "База данных" p-db-num skip
      "Идентификатор пользователя" p-user-id skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  case p-param-code :
    when {&user-window-maximize}
    then do:
      assign
        buf_user-login.user-window-maximize = ?
      .
    end.
    when {&user-window-size-store}
    then do:
      assign
        buf_user-login.user-window-size-store = ?
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение параметра p-param-code" skip
        "p-param-code" p-param-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end.