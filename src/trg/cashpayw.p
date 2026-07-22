block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись вида оплаты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/06
Author: Bakhtadze Natalya
Creation date: 03/22/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cash-pay OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись вида оплаты".
{ cmp/vssrevis.i "substitute('&1|&2'
                        , ub.cash-pay.cdpay-code
                        , ub.cash-pay.curr-code) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-cash-pay for ub.c-cash-pay.


DEFINE VARIABLE var-entry as character no-undo .

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run trg/cashpay2.p (
        input no
        ,INPUT ub.cash-pay.cdpay-code
        ,INPUT ub.cash-pay.obj-name
        ,INPUT ub.cash-pay.curr-code
        ,INPUT ub.cash-pay.pay-code
        ,INPUT ub.cash-pay.wth-code
        ,INPUT ub.cash-pay.pay-limit
        ,INPUT ub.cash-pay.pay-card-view
        ) no-error.
    if error-status:error then 
    do:
        undo main-block, return error return-value.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cash-pay.
    buffer-copy oldb to buf_c-cash-pay
        assign
        buf_c-cash-pay.cdpay-code         = ub.cash-pay.cdpay-code
        buf_c-cash-pay.curr-code          = ub.cash-pay.curr-code
        buf_c-cash-pay.chip-num           = next-value (s-corr-chip, {&db-name_schema})
        buf_c-cash-pay.corr-time          = v-time
        buf_c-cash-pay.corr-user-db-num   = g#db-num
        buf_c-cash-pay.corr-user-name     = g#userid
        buf_c-cash-pay.corr-date          = v-date
        buf_c-cash-pay.action = (if new ub.cash-pay then integer({&hn-create}) else integer({&hn-update}))
        buf_c-cash-pay.subject = {&table_cash-pay}
        .
    define variable v-new-cash-pay as logical no-undo .

    assign
        v-new-cash-pay = new(ub.cash-pay)
        .
    if v-new-cash-pay = true then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_cash-pay}
            , input ( buffer ub.cash-pay :handle )
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
            , input {&table_cash-pay}
            , input ( buffer ub.cash-pay :handle )
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
    run str/callnews.p
        (input {&table_cash-pay}
        ,input (buffer ub.cash-pay:handle)
        ) no-error .
    if error-status:error then 
    do:
        undo main-block,  return error return-value.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_cash-pay}
            , input ( buffer ub.cash-pay:handle )
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
end.