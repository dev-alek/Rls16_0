block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lockuser.p $
$Archive: gbl/lockuser.p $

Блокирование всех пользователей системы

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/23/06

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lockuser.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/lockuser.p $":U .
define variable vss-description as character no-undo init "Блокирование всех пользователей системы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/sys-time.i }

define variable v-total-lock-count  as integer   no-undo .
define variable v-max-message-count as integer   no-undo .
define variable v-error-message     as character no-undo .

do
on error undo, return error return-value
:
  define buffer buf_sys-ctrl        for ub.sys-ctrl .
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

  find first buf_sys-ctrl no-lock .

  for each buf_user-login no-lock
    where buf_user-login.db-num = buf_sys-ctrl.db-num
  on error undo, return error return-value
  :
    find first buf_lock_user-login exclusive-lock
      where rowid(buf_lock_user-login) = rowid(buf_user-login)
      no-error no-wait .
    if not available buf_lock_user-login
    then do:
      assign
        v-total-lock-count = v-total-lock-count + 1
      .
      if v-total-lock-count <= v-max-message-count
      then do:
        assign
          v-error-message = v-error-message
                          + (if v-error-message <> '':U
                            then {&new-line}
                            else '':U
                            )
                          + {&new-line} + substitute("Компьютер &1"
                                                    ,buf_user-login.last-login-computer-name
                                                    )
                          + {&new-line} + substitute("Пользователь компьютера &1"
                                                    ,buf_user-login.last-login-computer-user
                                                    )
                          + {&new-line} + substitute("Идентификатор процесса &1"
                                                    ,buf_user-login.last-login-process-id
                                                    )
                          + {&new-line} + substitute("Номер подключения к БД &1"
                                                    ,buf_user-login.last-login-connection-id
                                                    )
                          + {&new-line} + substitute("Дата и время входа в систему &1"
                                                    ,sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd)
                                                    )
        .
      end.
    end.
  end.

  if v-total-lock-count <> 0
  then do:
    undo, return error substitute("Работает пользователей &1"
                                 ,v-total-lock-count
                                 ) + {&new-line}
                       + (if v-total-lock-count > v-max-message-count
                          then {&new-line} + "Частичный список работающих пользователей" + {&new-line}
                          else ""
                         )
                       + v-error-message .

  end.
  else do:
    return .
  end.
end.