block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы user-login

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/09/06

*/

trigger procedure for delete of ub.user-login .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление user-login".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_user for {&db-name_schema}._user .
define buffer buf_c-user-login for ub.c-user-login .
define buffer buf_c-usr-hist   for ub.c-usr-hist .

main-block:
do transaction
on error   undo main-block, return error substitute('userlgnd error main-block,&1', return-value )
on end-key undo main-block, return error substitute('userlgnd end-key main-block,&1', return-value )
:
  if ub.user-login.db-num = g#db-num
  then do:
    if ub.user-login.status_ = {&bef-user-status-normal}
    then do:
      find first buf_user exclusive-lock
        where buf_user._userid = ub.user-login.user-login
        no-error .
      if not available buf_user
      then do:
/*        message                                                */
/*          vss-workfile vss-revision vss-description skip       */
/*          "Не найдена запись логина в словаре базы данных" skip*/
/*          "БД" ub.user-login.db-num skip                       */
/*          "Идентификатор" ub.user-login.user-id skip           */
/*          "Логин" ub.user-login.user-login skip                */
/*          view-as alert-box error .                            */
/*        undo, return error return-value .                      */
      end.
      else do:

      delete buf_user .
      end.
    end.
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
  buffer-copy ub.user-login to buf_c-user-login
  assign
    buf_c-user-login.corr-date        = v-today
    buf_c-user-login.corr-time        = v-time
    buf_c-user-login.corr-user-db-num = g#db-num
    buf_c-user-login.corr-user-name   = (if g#news then {&nts-user} else g#userid)
    buf_c-user-login.chip-num         = v-chip-num
  .

  create buf_c-usr-hist .
  buffer-copy buf_c-user-login to buf_c-usr-hist
  assign
    buf_c-usr-hist.subject = {&table_user-login}
    buf_c-usr-hist.action  = integer({&hn-delete})
    buf_c-usr-hist.is-news = g#news
    buf_c-usr-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-usr-hist.source-ref  = (if g#news then string(g#news-source-db) else "":U)
  .
  run trg/userlog.p (
                      input {&nwsdochs_action_delete}
                    , input {&table_c-user-login}
                    , input ( buffer buf_c-user-login :handle )
                    , input ?
                    , input "" 
                ) no-error.
  run nws/cmd-del.p
    ( input {&table_user-login}
      ,input (buffer ub.user-login:handle)
      ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_user-login}
        , input ( buffer ub.user-login:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.