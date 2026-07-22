block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы user-login

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/09/06

*/

trigger procedure for write of ub.user-login old buffer old-user-login .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы user-login".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/str-glbl.i }
{ adm/userpro.i &NoCheckWorkUser = yes}
define buffer buf_user-login   for ub.user-login .
define buffer buf_c-user-login for ub.c-user-login .
define buffer buf_c-usr-hist   for ub.c-usr-hist .

main-block:
do transaction
on error   undo main-block, return error substitute('userlgnd error main-block,&1', return-value )
on end-key undo main-block, return error substitute('userlgnd end-key main-block,&1', return-value )
:

  if ub.user-login.db-num = g#db-num
  then do:
    if  not new(ub.user-login)
    and old-user-login.status_ = {&bef-user-status-normal}
    then do:
      find first ub._user exclusive-lock
        where ub._user._userid = old-user-login.user-login
        no-error .
      if not available ub._user
      then do:
/*        message
          vss-workfile vss-revision vss-description skip
          "Не найдена запись логина в словаре базы данных" skip
          "БД" old-user-login.db-num skip
          "Идентификатор" old-user-login.user-id skip
          "Логин" old-user-login.user-login skip
          view-as alert-box error .
        undo main-block, return error return-value .*/
         ub.user-login.status_                    = {&uls-disabled}.
      end.
      else
         delete ub._user .
    end.
    
       
    { trg/user.i ub }

  end.
  
  define variable v-chip-num as integer   no-undo .
  define variable v-today    as date      no-undo .
  define variable v-time     as integer   no-undo .

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  assign
    v-chip-num = next-value(s-usr-chip)

  .

  create buf_c-user-login .
  buffer-copy old-user-login except db-num user-id to buf_c-user-login
  assign
    buf_c-user-login.db-num           = ub.user-login.db-num
    buf_c-user-login.user-id          = ub.user-login.user-id
    buf_c-user-login.corr-date        = v-today
    buf_c-user-login.corr-time        = v-time
    buf_c-user-login.corr-user-db-num = g#db-num
    buf_c-user-login.corr-user-name   = (if g#news then {&nts-user} else g#userid)
    buf_c-user-login.chip-num         = v-chip-num
    
  NO-ERROR.
  IF ERROR-STATUS :ERROR
  THEN DO:
     undo main-block, RETURN ERROR SUBSTITUTE( "&1. &2&3&4", vss-workfile , RETURN-VALUE, {&new-line}, ERROR-STATUS:GET-MESSAGE(1)).
  END.
  buffer-copy buf_c-user-login to buf_c-usr-hist
  assign
    buf_c-usr-hist.subject = {&table_user-login}
    buf_c-usr-hist.action  = (if new(ub.user-login) then integer({&hn-create}) else integer({&hn-update}))
    buf_c-usr-hist.is-news = g#news
    buf_c-usr-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-usr-hist.source-ref  = (if g#news then string(g#news-source-db) else "":U)
  .
    if AVAILABLE ub.user-login then do:
        if AVAILABLE buf_c-user-login then do:
            if ub.user-login.last-login-mjd <> buf_c-user-login.last-login-mjd then do:
                run trg/userlog.p (
                      input {&nwsdochs_action_update}
                    , input {&table_c-usr-hist}
                    , input ( buffer buf_c-usr-hist :handle )
                    , input ?
                    , input "" 
                ) no-error.
                if error-status :error
                then do:
                    undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                        , {&new-line}
                                        , vss-workfile
                                        , return-value
                                        , error-status :get-message ( 1 ) ).
                end.                
            end.    
        end.    
    end. 
/*    if ub.user-login.db-num = g#db-num*/
/*  then do:                            */
/*                                      */
    if new(ub.user-login)
    then
       run trg/userlog.p (
                      input {&nwsdochs_action_create}
                    , input {&table_c-user-login} 
                    , input ( buffer buf_c-user-login :handle )
                    , input ?
                    , input "" 
                ) no-error.
    else if ub.user-login.user-login ne old-user-login.user-login
    then
       run trg/userlog.p (
                      input {&nwsdochs_action_update}
                    , input {&table_c-user-login} 
                    , input ( buffer buf_c-user-login :handle )
                    , input ?
                    , input "" 
                ) no-error.
    if ub.user-login.user-administrator ne old-user-login.user-administrator
    then
       run trg/userlog.p (
                      input if ub.user-login.user-administrator then {&nwsdochs_action_create} else {&nwsdochs_action_delete}
                    , input {&table_c-user-login} + {&delim-key} + "adm"
                    , input ( buffer buf_c-user-login :handle )
                    , input ?
                    , input "" 
                ) no-error.
     
    
    if     old-user-login.user-password-encoded ne user-login.user-password-encoded
    then do:
        
       run SaveLastPWD(ub.user-login.db-num,
                       ub.user-login.user-id,
                       ub.user-login.user-password-encoded).
       
       /* Установим новое время смены пароля если это смена пароля у этого логина, если это пораждениее смены пароля у другого логина то там будет установлено и время */
       if    old-user-login.user-password-set-mjd eq user-login.user-password-set-mjd
       then do:
          user-login.user-password-set-mjd = cur-time-mjd().
       end.
          run trg/userlog.p (
                      input {&nwsdochs_action_update}
                    , input {&table_c-user-login} + {&delim-key} + "user-password" 
                    , input ( buffer buf_c-user-login :handle )
                    , input ?
                    , input "" 
                ) no-error.
                if error-status :error
                then do:
                    undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                        , {&new-line}
                                        , vss-workfile
                                        , return-value
                                        , error-status :get-message ( 1 ) ).
                end. 
    
       
    end.
    
     
/*  end.*/
     
  run str/callnews.p
    (input {&table_user-login}
    ,input (buffer ub.user-login :handle)
    ) no-error .
  if error-status:error then do:
    undo main-block,  return error return-value .
  end.

    if g#oxml = yes
    then do:
       run str/calloxml.p (
             input {&nwsdochs_action_update}
           , input {&table_user-login}
           , input ( buffer ub.user-login:handle )
       ) no-error.
       if error-status :error
       then do:
           undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                                , {&new-line}
                                , vss-workfile
                                , return-value
                                , error-status :get-message ( 1 ) ).
       end.
   end.
end.