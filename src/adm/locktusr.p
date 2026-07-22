block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: locktusr.p $
$Archive: adm/locktusr.p $

Блокирование всех пользователей системы с записью их даных в temp-table

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/05/06
Author: Bakhtadze Natalya
Creation date: 06/05/06

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: locktusr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/locktusr.p $":U .
define variable vss-description as character no-undo init "Блокирование всех пользователей системы с записью их даных в temp-table".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/sys-time.i }

define variable v-total-lock-count  as integer   no-undo .
define variable v-max-message-count as integer   no-undo .
define variable v-error-message     as character no-undo .

do
on error undo, return error return-value
:
  define buffer buf_user-login      for ub.user-login .
  define buffer buf_lock_user-login for ub.user-login .

  assign
    v-total-lock-count  = 0
    v-max-message-count = 3
    v-error-message     = '':U
  .

  if transaction <> true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка в способе вызова процедуры" skip
      "В момент вызова процедуры должна быть активна транзакция" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  for each buf_user-login no-lock
  on error undo, return error return-value
  :
    find first buf_lock_user-login exclusive-lock
      where rowid(buf_lock_user-login) = rowid(buf_user-login)
      no-error no-wait .
    if not available buf_lock_user-login
    then do:
      run create-not-locked-user in p-parent-handle ( input rowid(buf_user-login)).
      assign
        v-total-lock-count = v-total-lock-count + 1
      .
    end.
  end.

  if v-total-lock-count <> 0
  then do:
    undo, return error substitute("Работает пользователей &1"
                                 ,v-total-lock-count
                                 ) + {&new-line}
                       + v-error-message .

  end.
  else do:
    return .
  end.
end.