block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись единицы измерения.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.units OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись единицы измерения".
{ cmp/vssrevis.i "substitute('&1', ub.units.unit-name) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-units for ub.c-units.


define variable old-type as char no-undo. /* тип единиц измерения в позиционном виде */
define variable new-type as char no-undo. /* тип единиц измерения в позиционном виде */

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


  /* нужно проверять возможные переходы графа типов единиц измерения */
    { trg/unit-chk.i ub.units oldb }
    run str/callnews.p
        (input "units"
        ,input (buffer ub.units:handle)
        ) no-error .
    if error-status:error then 
    do:
        undo main-block, return error return-value.
    end.

    if not g#news then 
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-units.
        buffer-copy oldb to buf_c-units
            assign
            buf_c-units.unit-name          = ub.units.unit-name
            buf_c-units.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
            buf_c-units.corr-time          = v-time
            buf_c-units.corr-user-db-num   = g#db-num
            buf_c-units.corr-user-name     = g#userid
            buf_c-units.corr-date          = v-date
            .
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_units}
            , input ( buffer ub.units:handle )
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
    if new(ub.units) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_units}
            , input ( buffer ub.units :handle )
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
            , input {&table_units}
            , input ( buffer ub.units :handle )
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