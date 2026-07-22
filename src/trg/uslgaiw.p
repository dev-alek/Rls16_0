block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись user-login-action-item

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.user-login-action-item OLD BUFFER old_user-login-action-item .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы user-login-action-item".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do transaction
on error   undo main-block, return error substitute('uslgaiw error main-block,&1', return-value )
on end-key undo main-block, return error substitute('uslgaiw end-key main-block,&1', return-value )
:

  run str/callnews.p
    (input {&table_user-login-action-item}
    ,input (buffer ub.user-login-action-item :handle)
    ) no-error .
  if error-status:error then do:
    undo main-block,  return error return-value .
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_user-login-action-item}
        , input ( buffer ub.user-login-action-item:handle )
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