block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись типа оплаты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.pay-type OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись типа оплаты".
{ cmp/vssrevis.i "substitute('&1',
                         ub.pay-type.obj-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date    no-undo .
DEFINE VARIABLE v-time  as integer no-undo .

define buffer buf_c-pay-type for ub.c-pay-type.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    run str/callnews.p
        (input {&table_pay-type}
        ,input (buffer ub.pay-type:handle)
        ).
    if not g#news then 
    do:
        run cur-time in this-procedure(output v-today, output v-time).
        create buf_c-pay-type.
        buffer-copy oldb
            except obj-code
            to buf_c-pay-type
            assign
            buf_c-pay-type.obj-code           = ub.pay-type.obj-code
            buf_c-pay-type.action             = (if new(ub.pay-type) then integer({&hn-create}) else integer({&hn-update}))
            buf_c-pay-type.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
            buf_c-pay-type.corr-time          = v-time
            buf_c-pay-type.corr-user-db-num   = g#db-num
            buf_c-pay-type.corr-user-name     = g#userid
            buf_c-pay-type.corr-date          = v-today
            .
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_pay-type}
            , input ( buffer ub.pay-type:handle )
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
    if new(ub.pay-type) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_pay-type}
            , input ( buffer ub.pay-type :handle )
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
            , input {&table_pay-type}
            , input ( buffer ub.pay-type :handle )
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