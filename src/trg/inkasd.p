block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи продажа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/29/05
Author: Bakhtadze Natalya
Creation date: 11/29/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.inkas .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи продажа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

/*define variable cre-pay like ub.sysconf.credit-pay no-undo .*/
define variable conf-par as character no-undo .
define variable par-type as character no-undo .

define buffer buf_sysconf  for ub.sysconf .
define buffer buf_cash-pay for ub.cash-pay.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )

    :

    if  (ub.inkas.status_ = {&fact}
        or
        ub.inkas.status_ = {&inquiry} )
        and ub.inkas.is-del = no
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя удалять продажу, закрытую до статуса" ub.inkas.status_ skip
            "Номер продажи" ub.inkas.inkas-code skip
            "Статус продажи" ub.inkas.status_ skip
            view-as alert-box error .
        undo main-block, return error .
    end.

    /* проверяем, что не осталось подчиненных линий */
    find first ub.inkas-pay no-lock
        where ub.inkas-pay.inkas-code = ub.inkas.inkas-code
        no-error .
    if available ub.inkas-pay then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа продажи" skip
            "Найдена строка документа продажи" skip
            "Продажа" ub.inkas-pay.inkas-code skip
            "pay-code" ub.inkas-pay.pay-code skip
            "curr-code" ub.inkas-pay.curr-code skip
            view-as alert-box error .
        undo main-block, return error .
    end.


    find first ub.inkas-pay-desk no-lock
        where ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code
        no-error .
    if available ub.inkas-pay-desk then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа продажи" skip
            "Найдена строка документа продажи - выручка по кассе" skip
            "Продажа" ub.inkas-pay-desk.inkas-code skip
            "pay-code" ub.inkas-pay-desk.pay-code skip
            "curr-code" ub.inkas-pay-desk.curr-code skip
            "pay-desk" ub.inkas-pay-desk.pay-desk skip
            "doc-type" ub.inkas-pay-desk.doc-type skip
            "cashier" ub.inkas-pay-desk.cashier skip
            view-as alert-box error .
        undo main-block, return error .
    end.
    find first ub.inkas-pay-wth no-lock
        where ub.inkas-pay-wth.inkas-code = ub.inkas.inkas-code
        no-error .
    if available ub.inkas-pay-wth then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Ошибка при удалении документа продажи" skip
            "Найдена строка документа продажи - выручка по кассе с номиналами" skip
            "Продажа" ub.inkas-pay-wth.inkas-code skip
            "pay-code" ub.inkas-pay-wth.pay-code skip
            "curr-code" ub.inkas-pay-wth.curr-code skip
            "wth-code" ub.inkas-pay-wth.wth-code skip
            "par-code" ub.inkas-pay-wth.par-code skip
            "pay-desk" ub.inkas-pay-wth.pay-desk skip
            "chk-type" ub.inkas-pay-wth.chk-type skip
            "cashier" ub.inkas-pay-wth.cashier skip
            view-as alert-box error .
        undo main-block, return error .
    end.


    /* проверяем, что не осталось привязанных чеков */
    if not g#news then 
    do:
        find first ub.chk-doc no-lock
            where ub.chk-doc.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-doc then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена чек привязанный к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-doc.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        /* проверяем, что не осталось привязанных строк товаров */
        find first ub.chk-gds no-lock
            where ub.chk-gds.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-gds then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена строка чека привязанная к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-gds.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        /* проверяем, что не осталось привязанных строк оплаты */
        find first ub.chk-pay no-lock
            where ub.chk-pay.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-pay then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена строка оплаты, привязанная к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-pay.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.

        /* проверяем, что не осталось привязанных строк скидок */
        find first ub.chk-discnt no-lock
            where ub.chk-discnt.out-code = ub.inkas.inkas-code
            no-error .
        if available ub.chk-discnt then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при удалении документа продажи" skip
                "Найдена строка скидки привязанная к продаже" skip
                "Продажа" ub.inkas.inkas-code skip
                "Код чека" ub.chk-discnt.doc-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    /*отправляем в новости команду на удаление*/
    if not g#news
        and (ub.inkas.status_ = {&fact}
        or
        ub.inkas.status_ = {&inquiry}
        )
        then 
    do:
        run nws/cmd-del.p
            ( input "inkas":U
            ,input (buffer ub.inkas:handle)
            ,input "":U
            ) no-error .
        if error-status :error then 
        do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_inkas}
            , input ( buffer ub.inkas:handle )
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
   
    { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&edoc-proc_event_inkas}
    " buffer ub.inkas:handle "
    ''
    ''
    ''
    no-error
  }
    if error-status :error
        then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
      
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_inkas}
        , input ( buffer ub.inkas :handle )
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