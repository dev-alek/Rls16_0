block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись автоцистерны

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/11/06
Author: Dmitry Ukhanov
Creation date: 04/11/06

*/

trigger procedure for write of ub.auto-tank old old-auto-tank .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на запись автоцистерны".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable v-date as date    no-undo .
define variable v-time as integer no-undo .

main-block:
do
    on error undo main-block, return error
    :
    run cur-time in this-procedure
        (output v-date
        ,output v-time
        ).

    run str/callnews.p
        (input {&table_auto-tank}
        ,input (buffer ub.auto-tank:handle)
        ).

    if not g#news
        then 
    do:
        if new (ub.auto-tank)
            then 
        do:
            create ub.c-auto-tank .
            assign
                ub.c-auto-tank.auto-num         = ub.auto-tank.auto-num
                ub.c-auto-tank.action           = integer({&hn-create})
                ub.c-auto-tank.is-add           = true
                ub.c-auto-tank.is-del           = false
                ub.c-auto-tank.chip-num         = next-value (s-ref-corr-chip, {&db-name_schema})
                ub.c-auto-tank.corr-date        = v-date
                ub.c-auto-tank.corr-time        = v-time
                ub.c-auto-tank.corr-user-db-num = g#db-num
                ub.c-auto-tank.corr-user-name   = g#userid
                ub.c-auto-tank.subject          = {&table_auto-tank}
                .
        end.
        else 
        do:
            create ub.c-auto-tank .
            buffer-copy old-auto-tank to ub.c-auto-tank
                assign
                ub.c-auto-tank.auto-num         = ub.auto-tank.auto-num
                ub.c-auto-tank.action           = integer({&hn-update})
                ub.c-auto-tank.is-add           = false
                ub.c-auto-tank.is-del           = false
                ub.c-auto-tank.chip-num         = next-value (s-ref-corr-chip, {&db-name_schema})
                ub.c-auto-tank.corr-date        = v-date
                ub.c-auto-tank.corr-time        = v-time
                ub.c-auto-tank.corr-user-db-num = g#db-num
                ub.c-auto-tank.corr-user-name   = g#userid
                ub.c-auto-tank.subject          = {&table_auto-tank}
                .
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_auto-tank}
            , input ( buffer ub.auto-tank:handle )
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
    if new(ub.auto-tank) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_auto-tank}
            , input ( buffer ub.auto-tank :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end. 
    else 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_update}
            , input {&table_auto-tank}
            , input ( buffer ub.auto-tank :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then 
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.

    end.      
end.