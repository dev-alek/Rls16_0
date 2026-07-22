block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: isanybdy.p $
$Archive: adm/isanybdy.p $

Определяет число пользователей, работающих в системе

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input  parameter p-check-menu-group as logical   no-undo .
define input  parameter p-menu-code        as integer   no-undo .
define input  parameter p-menu-group-id    as character no-undo .
define output parameter p-total-user-num   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: isanybdy.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/isanybdy.p $":U .
define variable vss-description as character no-undo init "Определяет число пользователей, работающих в системе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/sys-time.i }
define buffer buf_user-login      for ub.user-login .
define buffer buf_lock_user-login for ub.user-login .

define variable v-max-user-display as integer   no-undo .
define variable v-user-info        as character no-undo .

do
on error undo, return error return-value
:
  assign
    p-total-user-num   = 0
    v-max-user-display = 3
    v-user-info        = '':U
  .

  if p-check-menu-group = false
  then do:
    for each buf_user-login
    on error undo, return error
    :
      find buf_lock_user-login exclusive-lock
        where recid(buf_lock_user-login) = recid(buf_user-login)
        no-wait
        no-error .
      if  not available buf_lock_user-login
      and locked(buf_lock_user-login)
      then do:
        assign
          p-total-user-num = p-total-user-num + 1
        .

        if p-total-user-num <= v-max-user-display
        then do:
          assign
            v-user-info = v-user-info
                        + (if v-user-info <> '':U
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
                        + {&new-line} + substitute("Дата и время входа в систему &1"
                                                  ,sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd)
                                                  )
          .

        end.
      end.
    end.
  end.
  else do:
    for each buf_user-login
      where /*buf_user-login.cntxt-menu-code     = p-menu-code
        and*/ buf_user-login.cntxt-menu-group-id = p-menu-group-id
    on error undo, return error
    :
      find buf_lock_user-login exclusive-lock
        where recid(buf_lock_user-login) = recid(buf_user-login)
        no-wait
        no-error .
      if  not available buf_lock_user-login
      and locked(buf_lock_user-login)
      then do:
        assign
          p-total-user-num = p-total-user-num + 1
        .

        if p-total-user-num <= v-max-user-display
        then do:
          assign
            v-user-info = v-user-info
                        + (if v-user-info <> '':U
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
                        + {&new-line} + substitute("Дата и время входа в систему &1"
                                                  ,sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd)
                                                  )
          .

        end.
      end.
    end.
  end.


  return substitute("Работает пользователей &1"
                   ,p-total-user-num
                   ) + {&new-line}
         + (if p-total-user-num > v-max-user-display
           then {&new-line} + "Частичный список работающих пользователей" + {&new-line}
           else ""
           )
         + v-user-info .
end.