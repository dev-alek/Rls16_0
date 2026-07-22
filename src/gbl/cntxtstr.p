block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cntxtstr.p $
$Archive: gbl/cntxtstr.p $

Сохранить контекст пользователя.

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/07/06

*/

define input  parameter p-cntxt-db-num          as integer   no-undo .
define input  parameter p-cntxt-user-id         as character no-undo .
define input  parameter p-cntxt-menu-code       as integer   no-undo .
define input  parameter p-cntxt-menu-group-code as integer   no-undo .
define input  parameter p-cntxt-level           as character no-undo .
define input  parameter p-cntxt-host-code-obj   as integer   no-undo .
define input  parameter p-cntxt-obj-type        as character no-undo .
define input  parameter p-cntxt-obj-code        as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cntxtstr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/cntxtstr.p $":U .
define variable vss-description as character no-undo init "Сохранить контекст пользователя".
{ cmp/vssrevis.i }
{ gbl/sys-time.i }
{ gbl/get-ro.i   }

define variable v-user-context-history-id as integer   no-undo .
define variable v-current-mjd             as decimal   no-undo .
define variable v-last-group-menu         as character    no-undo .
define variable v-cntxt-menu-group-id     as character    no-undo .
define variable v-cntxt-menu-code         as integer      no-undo.
define variable v-get-ro_read-only        as logical   no-undo .

define buffer buf_menu-group           for ub.menu-group .
define buffer buf_user-login           for ub.user-login .
define buffer buf_user-context-history for ubflt.user-context-history .

do
on error undo, return error return-value
:

  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .

  if v-get-ro_read-only = false then do:
    find first buf_user-login exclusive-lock
      where buf_user-login.db-num  = p-cntxt-db-num
        and buf_user-login.user-id = p-cntxt-user-id
      no-error .
  end.
  else do:
    find first buf_user-login no-lock
      where buf_user-login.db-num  = p-cntxt-db-num
        and buf_user-login.user-id = p-cntxt-user-id
      no-error .
  end.
  if not available buf_user-login
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден логин пользователя" skip
      "База данных" p-cntxt-db-num skip
      "Идентификатор пользователя" p-cntxt-user-id skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  find first buf_menu-group no-lock
    where buf_menu-group.menu-code       = p-cntxt-menu-code
      and buf_menu-group.menu-group-code = p-cntxt-menu-group-code
    no-error .
  if not available buf_menu-group
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена группа пунктов меню" skip
      "Код меню" p-cntxt-menu-code skip
      "Код группы пунктов меню" p-cntxt-menu-group-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
      v-cntxt-menu-group-id = buf_menu-group.menu-group-id
      v-cntxt-menu-code     = buf_menu-group.menu-group-code
  .

  find last buf_user-context-history exclusive-lock
    where buf_user-context-history.db-num  = p-cntxt-db-num
      and buf_user-context-history.user-id = p-cntxt-user-id
    no-error .
  if available buf_user-context-history
  then do:
    assign
      v-user-context-history-id = buf_user-context-history.user-context-history-id + 1
      v-last-group-menu         = buf_user-context-history.cntxt-menu-group-id
    .
  end.
  else do:
    assign
      v-user-context-history-id = 1
    .
  end.

  assign
    v-current-mjd = sys-time_get-mjd-func()
  .
  /* для пользователя адм всегда по умолчанию группа меню Администратор
  if buf_user-login.user-login = "адм" then
  _adm:
  do:
     if v-last-group-menu <> "adm":u
     or v-cntxt-menu-group-id <> "adm":u then do:
         find first buf_menu-group
              where buf_menu-group.menu-code     = p-cntxt-menu-code
                and buf_menu-group.menu-group-id = "adm":u
              no-lock
              no-error
              .
         if not available buf_menu-group then do:
            leave _adm .
         end.
         assign
            v-cntxt-menu-group-id = buf_menu-group.menu-group-id
            v-cntxt-menu-code     = buf_menu-group.menu-group-code
         .
     end.
  end.
  */

  if v-get-ro_read-only = false then do:
    /* сюда сохраняются значения для проверки лицензионной политики */
    assign
      buf_user-login.cntxt-menu-code     = v-cntxt-menu-code
      buf_user-login.cntxt-menu-group-id = v-cntxt-menu-group-id
    .
  end.

  create buf_user-context-history .
  assign
    buf_user-context-history.db-num                  = p-cntxt-db-num
    buf_user-context-history.user-id                 = p-cntxt-user-id
    buf_user-context-history.user-context-history-id = v-user-context-history-id
    buf_user-context-history.cntxt-change-mjd        = v-current-mjd
    buf_user-context-history.cntxt-level             = p-cntxt-level
    buf_user-context-history.cntxt-host-code         = p-cntxt-host-code-obj
    buf_user-context-history.cntxt-obj-type          = p-cntxt-obj-type
    buf_user-context-history.cntxt-obj-code          = p-cntxt-obj-code
    buf_user-context-history.cntxt-menu-code         = p-cntxt-menu-code
    buf_user-context-history.cntxt-menu-group-id     = buf_menu-group.menu-group-id
  .
end.