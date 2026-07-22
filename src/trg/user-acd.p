block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы user-account-attr

Автор: Белоусов Илья Александрович
Дата создания: 01/11/07
Author: Ilia Belousov
Creation date: 01/11/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.user-account-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы user-account-attr".


{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vBufhist as handle no-undo.
define variable vRow as rowid no-undo.
run trg/userhisto.p ( 
    input integer({&hn-delete})
    ,input {&table_user-account-attr } + "." +  ub.user-account-attr.attr-code
    ,input ub.user-account-attr.attr-value
    ,input ub.user-account-attr.user-id
    ,output vRow
    ) no-error .
  if error-status :error
    then 
  do:
    undo, return error substitute( "&2&1Ошибка при отправке записи в user-hist &1&3&1&4"
      , {&new-line}
      , vss-workfile
      , return-value
      , error-status :get-message ( 1 ) ).
  end.

  define buffer buf_c-usr-hist            for ub.c-usr-hist .
  find first buf_c-usr-hist where rowid (buf_c-usr-hist) eq vrow no-lock.
  
  run trg/userlog.p (
                      input if user-account-attr.attr-code eq "superadm" then {&nwsdochs_action_delete} else {&nwsdochs_action_delete}
                    , input {&table_user-account} + if user-account-attr.attr-code eq "superadm" then {&delim-key} + "SuperAdm" else "" 
                    , input (buffer buf_c-usr-hist:handle)
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
end. /* main-block */
