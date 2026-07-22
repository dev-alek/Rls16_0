block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usrld15.p $
$Archive: utl/usrld15.p $

Перенос информации о пользователях из таблицы userconf в таблицы user-account, user-login

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Инициализация пользователей

*/

define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usrld15.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/usrld15.p $":U .
define variable vss-description as character no-undo init "Перенос информации о пользователях из таблицы userconf в таблицы user-account, user-login".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

{ gbl/getcntxt.i def }

define variable v-ok                          as logical   no-undo .
define variable v-db-num                      as integer   no-undo .
define variable v-user-id                     as character no-undo .
define variable v-user-login                  as character no-undo .
define variable v-last-name                   as character no-undo .
define variable v-user-password-encoded       as character no-undo .
define variable v-cntxt-menu-group-id         as character no-undo .

define variable v1-cntxt-level                 as character no-undo .
define variable v1-cntxt-host-code-obj         as integer   no-undo .
define variable v1-cntxt-obj-type              as character no-undo .
define variable v1-cntxt-obj-code              as integer   no-undo .
define variable v-arm-code-list               as character no-undo .
define variable v-arm-code-lookup-index       as integer   no-undo .
define variable v-menu-group-id-list          as character no-undo .
define variable v-menu-group-id               as character no-undo .
define variable v-ind                         as integer   no-undo .
define variable v-err-count                   as integer   no-undo .
define variable v-userconf-filename           as character no-undo .

define temp-table temp-userconf no-undo
   field user-name      as character
   field obj-code       as integer
   field obj-type       as character
   field ARM            as character  format "X(12)"
   field on-line        as logical
   field max-discnt     as decimal
   field quest-print    as logical
   field arm-host-code  as integer
   index pu is primary unique
         user-name
.

define buffer buf_temp-userconf        for temp-userconf .
define buffer buf__user                for ub._user .
define buffer buf_db                   for ub.db .
define buffer buf_user-account         for ub.user-account .
define buffer buf_user-login           for ub.user-login .
define buffer buf_user-context-history for ubflt.user-context-history .
define buffer buf_clients              for ub.clients .
define buffer buf_menu-group           for ub.menu-group .

define stream sinp .

on write of ub.user-account         override do: end.
on write of ub.user-login           override do: end.
on write of ubflt.user-context-history override do: end.

do
on error undo, return error return-value
:
  if p-install = false
  then do:
    message
      vss-description skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return . /* --->>>--- */
    end.
  end.

  assign
    v-db-num = v-cntxt-db-num
  .

  if "{&language}" = "rus":U
  then do:
    assign
      v-arm-code-list = 'офи':U
                      + {&comma-char} + 'скл':U
                      + {&comma-char} + 'маг':U
                      + {&comma-char} + 'рес':U
                      + {&comma-char} + 'фин':U
                      + {&comma-char} + 'бгх':U
                      + {&comma-char} + 'бух':U
                      + {&comma-char} + 'осн':U
                      + {&comma-char} + 'адм':U
    .
  end.
  else do:
    assign
      v-arm-code-list = 'off':U
                      + {&comma-char} + 'str':U
                      + {&comma-char} + 'shp':U
                      + {&comma-char} + 'res':U
                      + {&comma-char} + 'fin':U
                      + {&comma-char} + 'eac':U
                      + {&comma-char} + 'acc':U
                      + {&comma-char} + 'fas':U
                      + {&comma-char} + 'adm':U
    .
  end.

  assign
    v-menu-group-id-list = 'off,str,shp,res,fin,bge,buh,fas,adm':U
  .

    assign
      v-userconf-filename = search('usr-conf.142':U)
    .
    if v-userconf-filename = ?
    or v-userconf-filename = '':U
    then do:
      undo, return error substitute("Не найден файл с пользователями &1"
                                   ,'usr-conf.142':U
                                   ) .
    end.
    for each buf_temp-userconf
    on error undo, return error return-value
    :
      delete buf_temp-userconf .
    end.

    input stream sinp from value(v-userconf-filename) .
    repeat
    :
      create buf_temp-userconf .
      import stream sinp buf_temp-userconf .
    end.
    input stream sinp close .

  for each buf_temp-userconf
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .

    find first buf__user
      where buf__user._userid = buf_temp-userconf.user-name
      no-error .
    if available buf__user
    then do:
      assign
        v-user-login            = buf__user._userid
        v-last-name             = buf__user._user-name
        v-user-password-encoded = buf__user._password
      .
    end.
    else do:
      assign
        v-user-login            = '':U
        v-last-name             = '':U
        v-user-password-encoded = '':U
      .
    end.

    assign
      v-user-id = substitute('&1-&2':U
                            ,v-db-num
                            ,next-value(s-user-id)
                            )
    .

    create buf_user-account .
    assign
      buf_user-account.user-id               = v-user-id
      buf_user-account.status_               = 0
      buf_user-account.first-name            = '':U
      buf_user-account.second-name           = '':U
      buf_user-account.last-name             = v-last-name
      buf_user-account.company               = '':U
      buf_user-account.department            = '':U
      buf_user-account.e-mail                = '':U
      buf_user-account.internal-phone-number = '':U
      buf_user-account.mobile-phone-number   = '':U
      buf_user-account.phone-number          = '':U
      buf_user-account.position              = '':U
      buf_user-account.PS                    = '':U
      buf_user-account.room                  = '':U
      buf_user-account.parent-user-id        = '':U
      buf_user-account.check-parent          = false
    .

    assign
      v-cntxt-menu-group-id        = '':U
      v1-cntxt-level                = {&cntxt-global}
      v1-cntxt-host-code-obj        = ?
      v1-cntxt-obj-type             = '':U
      v1-cntxt-obj-code             = ?
    .

    assign
      v-arm-code-lookup-index = lookup(buf_temp-userconf.ARM, v-arm-code-list)
    .
    if v-arm-code-lookup-index > 0
    then do:
      assign
        v-menu-group-id = entry(v-arm-code-lookup-index
                               ,v-menu-group-id-list
                               ,{&comma-char}
                               )
      .
      find first buf_menu-group no-lock
        where buf_menu-group.menu-code     = {&menu-code-main}
          and buf_menu-group.menu-group-id = v-menu-group-id
        no-error .
      if available buf_menu-group
      then do:
        assign
          v-cntxt-menu-group-id = buf_menu-group.menu-group-id
        .
      end.
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = buf_temp-userconf.obj-type
        and buf_clients.obj-code = buf_temp-userconf.obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        v1-cntxt-level         = {&cntxt-object}
        v1-cntxt-host-code-obj = buf_clients.host-code
        v1-cntxt-obj-type      = buf_clients.obj-type
        v1-cntxt-obj-code      = buf_clients.obj-code
      .
    end.
    else do:
      find first buf_clients no-lock
        where buf_clients.obj-type = {&cmp}
          and buf_clients.obj-code = buf_temp-userconf.arm-host-code
        no-error .
      if available buf_clients
      then do:
        assign
          v1-cntxt-level         = {&cntxt-firm}
          v1-cntxt-host-code-obj = buf_clients.host-code
          v1-cntxt-obj-type      = buf_clients.obj-type
          v1-cntxt-obj-code      = buf_clients.obj-code
        .
      end.
    end.

    create buf_user-login .
    assign
      buf_user-login.db-num                     = v-db-num
      buf_user-login.user-id                    = v-user-id
      buf_user-login.last-login-computer-name   = '':U
      buf_user-login.last-login-computer-userid = '':U
      buf_user-login.last-login-mjd             = 0.0
      buf_user-login.last-login-process-id      = 0
      buf_user-login.login-error-count          = 0
      buf_user-login.max-discnt                 = buf_temp-userconf.max-discnt
      buf_user-login.quest-print                = buf_temp-userconf.quest-print
      buf_user-login.status_                    = {&uls-disabled}
      buf_user-login.user-administrator         = (if v-user-login = 'адм':U
                                                   then true
                                                   else false
                                                  )
      buf_user-login.user-login                 = v-user-login
      buf_user-login.user-password-encoded      = v-user-password-encoded
    .

    create buf_user-context-history .
    assign
      buf_user-context-history.db-num                  = v-db-num
      buf_user-context-history.user-id                 = v-user-id
      buf_user-context-history.user-context-history-id = 1
      buf_user-context-history.cntxt-menu-code         = {&menu-code-main}
      buf_user-context-history.cntxt-menu-group-id     = v-cntxt-menu-group-id
      buf_user-context-history.cntxt-level             = v1-cntxt-level
      buf_user-context-history.cntxt-host-code         = v1-cntxt-host-code-obj
      buf_user-context-history.cntxt-obj-type          = v1-cntxt-obj-type
      buf_user-context-history.cntxt-obj-code          = v1-cntxt-obj-code
      buf_user-context-history.cntxt-change-mjd        = 0
    .
  end.

  if p-install = false
  then do:
    for each buf_user-login
    on error undo, return error return-value
    :
      assign
        buf_user-login.status_ = {&uls-normal}
      .
    end.
  end.

  return substitute("Обработано записей &1. Ошибок &2"
                   ,v-ind
                   ,v-err-count
                   ) .
end.