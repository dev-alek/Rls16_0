block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sndusrnw.p $
$Archive: utl/sndusrnw.p $

Отправить настройки пользователя - права, меню по новостям

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 02/01/07

"action-post"             "trg/actnpstd.p" "trg/actnpstw.p"
"action-post-host"        "trg/actnpshd.p" "trg/actnpshw.p"
"action-post-obj"         "trg/actnpsod.p" "trg/actnpsow.p"
"action-post-role"        "trg/actnpsrd.p" "trg/actnpsrw.p"
"action-post-user-login"  "trg/actnpuld.p" "trg/actnpulw.p"
"action-role"             "trg/actnrld.p"  "trg/actnrlw.p"
"action-role-item"        "trg/actnrtd.p"  "trg/actnrtw.p"
"user-account"            "trg/useraccd.p" "trg/useraccw.p"
"user-host"               "trg/userhstd.p" "trg/userhstw.p"
"user-login"              "trg/userlgnd.p" "trg/userlgnw.p"
"user-login-action-item"  "trg/uslgaid.p"  "trg/uslgaiw.p"
"user-login-action-role"  "trg/uslgrld.p"  "trg/uslgrlw.p"
"user-login-attr"         "trg/userlgad.p" "trg/userlgaw.p"
"user-obj"                "trg/userobjd.p" "trg/userobjw.p"

Эти таблицы по новостям не ходят
"user-window-attr"        "trg/userwatd.p" "trg/userwatw.p"
"menu-user-call"          "trg/mnuscald.p" "trg/mnuscalw.p"
"user-context-history"    "trg/usctxhid.p" "trg/usctxhiw.p"


*/

define input  parameter parparentproc       as widget-handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sndusrnw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/sndusrnw.p $":U .
define variable vss-description as character no-undo init "Отправить настройки пользователя - права, меню по новостям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }

define variable v-ind as integer   no-undo .
define variable v-ok  as logical   no-undo .

define buffer buf_user-account           for ub.user-account .
define buffer buf_user-login             for ub.user-login .
define buffer buf_user-menu-group        for ub.user-menu-group .
define buffer buf_user-host              for ub.user-host .
define buffer buf_user-obj               for ub.user-obj .
define buffer buf_user-login-attr        for ub.user-login-attr .
define buffer buf_action-role            for ub.action-role .
define buffer buf_action-role-item       for ub.action-role-item .
define buffer buf_action-post            for ub.action-post .
define buffer buf_action-post-obj        for ub.action-post-obj .
define buffer buf_action-post-host       for ub.action-post-host .
define buffer buf_action-post-role       for ub.action-post-role .
define buffer buf_action-post-user-login for ub.action-post-user-login .
define buffer buf_user-login-action-role for ub.user-login-action-role .
define buffer buf_user-login-action-item for ub.user-login-action-item .
define buffer buf_action-post-menu-group for ub.action-post-menu-group .

do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  message
    vss-description
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return . /* --->>>--- */
  end.

  if v-cntxt-db-num = 0
  then do:
    /* отправить информацию об аккаунтах во все БД */
    for each buf_user-account exclusive-lock
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.

      run str/callnews.p
        (input {&table_user-account}
        ,input (buffer buf_user-account :handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
  end.
  else do:
    /* отправить информацию об аккаунтах в ГБД */
    for each buf_user-account exclusive-lock
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-account}
        ,input (buffer buf_user-account :handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-login exclusive-lock
      where buf_user-login.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-login}
        ,input (buffer buf_user-login:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-menu-group exclusive-lock
      where buf_user-menu-group.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-menu-group}
        ,input (buffer buf_user-menu-group:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-host exclusive-lock
      where buf_user-host.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-host}
        ,input (buffer buf_user-host:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-obj exclusive-lock
      where buf_user-obj.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-obj}
        ,input (buffer buf_user-obj:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-login-attr exclusive-lock
      where buf_user-login-attr.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-login-attr}
        ,input (buffer buf_user-login-attr:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-role exclusive-lock
      where buf_action-role.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-role}
        ,input (buffer buf_action-role:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-role-item exclusive-lock
      where buf_action-role-item.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-role-item}
        ,input (buffer buf_action-role-item:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-post exclusive-lock
      where buf_action-post.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-post}
        ,input (buffer buf_action-post:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-post-obj exclusive-lock
      where buf_action-post-obj.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-post-obj}
        ,input (buffer buf_action-post-obj:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-post-host exclusive-lock
      where buf_action-post-host.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-post-host}
        ,input (buffer buf_action-post-host:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-post-role exclusive-lock
      where buf_action-post-role.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-post-role}
        ,input (buffer buf_action-post-role:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-post-user-login exclusive-lock
      where buf_action-post-user-login.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-post-user-login}
        ,input (buffer buf_action-post-user-login:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-login-action-role exclusive-lock
      where buf_user-login-action-role.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-login-action-role}
        ,input (buffer buf_user-login-action-role:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_user-login-action-item exclusive-lock
      where buf_user-login-action-item.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_user-login-action-item}
        ,input (buffer buf_user-login-action-item:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.

    for each buf_action-post-menu-group exclusive-lock
      where buf_action-post-menu-group.db-num = v-cntxt-db-num
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Отправлено записей &1", v-ind)
          ) .
      end.
      run str/callnews.p
        (input {&table_action-post-menu-group}
        ,input (buffer buf_action-post-menu-group:handle)
        ) no-error .
      if error-status:error then do:
        undo,  return error return-value .
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

  message
    vss-description skip
    "Утилита закончила работу" skip
    "Отправлено записей" v-ind skip
    view-as alert-box information .


end.