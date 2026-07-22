block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись user-login-action-role

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/20/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.user-login-action-role OLD BUFFER old_user-login-action-role .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы user-login-action-role".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do transaction
    on error   undo main-block, return error substitute('uslgrlw error main-block,&1', return-value )
    on end-key undo main-block, return error substitute('uslgrlw end-key main-block,&1', return-value )
    :
    if not g#news then 
    do:
        run str/callnews.p
            (input {&table_user-login-action-role}
            ,input (buffer ub.user-login-action-role :handle)
            ) no-error .
        if error-status:error then 
        do:
            undo main-block,  return error return-value .
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_user-login-action-role}
            , input ( buffer ub.user-login-action-role:handle )
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    define BUFFER buf_action-role for ub.action-role .
      
    For FIRST buf_action-role
        WHERE buf_action-role.db-num                    = ub.user-login-action-role.db-num
        AND buf_action-role.action-head-code            = {&action-head-code-main}
        AND buf_action-role.action-role-code            = ub.user-login-action-role.action-role-code
        NO-LOCK
        :
           
        run trg/userhist.p ( 
            input integer({&hn-create})
            ,input {&table_user-login-action-role}
            ,input string(ub.user-login-action-role.action-role-context + " " + string(buf_action-role.action-role-name) + " " + string(ub.user-login-action-role.obj-type) + " " + string(ub.user-login-action-role.obj-code) + " " + if string(ub.user-login-action-role.gds-grp-code) <> ? then STRING (ub.user-login-action-role.gds-grp-code) else "")
            ,input ub.user-login-action-role.user-id
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
    end.
end.

