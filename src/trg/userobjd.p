block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы user-obj

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/09/06

*/

trigger procedure for delete of ub.user-obj .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление user-obj".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do transaction
    on error   undo main-block, return error substitute('userobjd error main-block,&1', return-value )
    on end-key undo main-block, return error substitute('userobjd end-key main-block,&1', return-value )
    :
    define buffer buf_user-menu-group        for user-menu-group .
    define buffer buf_user-login-action-role for user-login-action-role .

    for each  buf_user-menu-group
        where buf_user-menu-group.db-num   = ub.user-obj.db-num
        and buf_user-menu-group.user-id  = ub.user-obj.user-id
        and buf_user-menu-group.obj-type = ub.user-obj.obj-type
        and buf_user-menu-group.obj-code = ub.user-obj.obj-code
        and buf_user-menu-group.menu-group-context = {&cntxt-object}
        exclusive-lock
        :
        delete buf_user-menu-group.
    end.

    for each  buf_user-login-action-role
        where buf_user-login-action-role.db-num  = ub.user-obj.db-num
        and buf_user-login-action-role.user-id = ub.user-obj.user-id
        and buf_user-login-action-role.obj-type = ub.user-obj.obj-type
        and buf_user-login-action-role.obj-code = ub.user-obj.obj-code
        and buf_user-login-action-role.action-role-context = {&cntxt-object}
        exclusive-lock
        :
        delete buf_user-login-action-role.
    end.

    run nws/cmd-del.p
        ( input {&table_user-obj}
        ,input (buffer ub.user-obj:handle)
        ,input "":U
        ) no-error .
    if error-status :error then 
    do:
        undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_user-obj}
            , input ( buffer ub.user-obj:handle )
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.

    end.
    run trg/userhist.p ( 
        input integer({&hn-delete})
        ,input {&table_user-obj}
        ,input string(ub.user-obj.obj-type + " " + STRING (ub.user-obj.obj-code))
        ,input ub.user-obj.user-id
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