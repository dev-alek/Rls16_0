block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы user-account

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/09/06

*/

trigger procedure for write of ub.user-account old buffer old-user-account .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы user-account".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define buffer buf_c-user-account for ub.c-user-account .
define buffer buf_c-usr-hist   for ub.c-usr-hist .

main-block:
do transaction
on error   undo main-block, return error substitute('useraccw error main-block,&1', return-value )
on end-key undo main-block, return error substitute('useraccw end-key main-block,&1', return-value )
:

  define variable v-chip-num as integer   no-undo .
  define variable v-today    as date      no-undo .
  define variable v-time     as integer   no-undo .
  if old-user-account.status_ ne user-account.status_
  then do:
     for each user-login where user-login.user-id = user-account.user-id
     exclusive-lock:
        user-login.status_ = user-account.status_.
     end.
      
  end.
  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  assign
    v-chip-num = next-value(s-usr-chip)
  .

  create buf_c-user-account .
  buffer-copy old-user-account except user-id to buf_c-user-account
  assign
    buf_c-user-account.user-id          = ub.user-account.user-id
    buf_c-user-account.corr-date        = v-today
    buf_c-user-account.corr-time        = v-time
    buf_c-user-account.corr-user-db-num = g#db-num
    buf_c-user-account.corr-user-name   = (if g#news then {&nts-user} else g#userid)
    buf_c-user-account.chip-num         = v-chip-num
  .

  create buf_c-usr-hist .
  buffer-copy buf_c-user-account to buf_c-usr-hist
  assign
    buf_c-usr-hist.subject = {&table_user-account}
    buf_c-usr-hist.action  = (if new(ub.user-account) then integer({&hn-create}) else integer({&hn-update}))
    buf_c-usr-hist.is-news = g#news
    buf_c-usr-hist.source-type = (if g#news then {&hn-source-db} else "":U)
    buf_c-usr-hist.source-ref  = (if g#news then string(g#news-source-db) else "":U)
  .
  run trg/userlog.p (
                      input if new(ub.user-account) then {&nwsdochs_action_Create} else {&nwsdochs_action_update}
                    , input {&table_c-user-account}  
                    , input ( buffer  buf_c-user-account :handle )
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
  run str/callnews.p
    (input {&table_user-account}
    ,input (buffer ub.user-account :handle)
    ) no-error .
  if error-status:error then do:
    undo main-block,  return error return-value .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_user-account}
        , input ( buffer ub.user-account:handle )
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