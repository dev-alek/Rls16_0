block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление кассы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/30/06
Author: Bakhtadze Natalya
Creation date: 03/30/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.cash-desk.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление кассы ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',  ub.cash-desk.db-num
                                        , ub.cash-desk.obj-code
                                        , ub.cash-desk.pos-type
                                        , ub.cash-desk.cash-num
                                          ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date    as date      no-undo .
define variable v-time    as integer   no-undo .
define variable v-no-news as logical   no-undo .
define variable v-db-list as character no-undo .

define buffer buf_db             for ub.db.
define buffer buf_c-cash-desk    for ub.c-cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_inkas-pay-wth  for ub.inkas-pay-wth.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


    if not g#news and ub.cash-desk.db-num <> g#db-num then 
    do:
        find first buf_db no-lock where
            buf_db.db-num = ub.cash-desk.db-nu  no-error.
        if available buf_db then 
        do:
            message
                "Нельзя удалять запись о кассе," skip
                "принадлежащей другой БД"
                view-as alert-box .
            undo main-block, return error.
        end.
        else 
        do:
            assign
                v-no-news = yes.
        end.
    end.
    if g#db-num = 0
        and g#news
        and ub.cash-desk.db-num > 0
        then 
    do:
        /*пришла команда на удаление из УБД обратно ее маршрутизировать не будем - потому, что за это время там могут кассу снова создать*/
        assign
            v-no-news = yes.
    end.


    if ub.cash-desk.autonomy <> integer({&cd-manager}) then 
    do:
        FIND FIRST ub.wth-place NO-LOCK where
            ub.wth-place.obj-code = ub.cash-desk.obj-code AND
            ub.wth-place.obj-type = {&shop} AND
            ub.wth-place.cash-desk = ub.cash-desk.cash-num NO-ERROR.
        IF AVAIL ub.wth-place then 
        do:
            message "Данная касса привязана к МХ МЦ!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
        FIND FIRST ub.shift-cash No-LOCK WHERE
            ub.shift-cash.cash-num = ub.cash-desk.cash-num
            AND ub.shift-cash.obj-code = ub.cash-desk.obj-code
            AND ub.shift-cash.obj-type = {&shop}
            AND ub.shift-cash.status_ <> {&sht-closed}
            No-ERROR.
        if avail ub.shift-cash then 
        do:
            message "Для данной кассы имеются незакрытые смены!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
    end.

    for each buf_cash-desk-attr where
        buf_cash-desk-attr.db-num = ub.cash-desk.db-num
        AND  buf_cash-desk-attr.obj-code = ub.cash-desk.obj-code
        AND  buf_cash-desk-attr.pos-type = ub.cash-desk.pos-type
        AND  buf_cash-desk-attr.cash-num = ub.cash-desk.cash-num
        on error undo main-block, return error return-value:
        delete buf_cash-desk-attr.
    end.
    for each buf_inkas-pay-wth where
        buf_inkas-pay-wth.obj-type = {&shop}
        AND  buf_inkas-pay-wth.obj-code = ub.cash-desk.obj-code
        AND  buf_inkas-pay-wth.pay-desk = ub.cash-desk.cash-num
        AND  buf_inkas-pay-wth.cashier = 0
        AND  buf_inkas-pay-wth.inkas-code = ''
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :

        delete buf_inkas-pay-wth.
    end.

    if not g#news then 
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-cash-desk.
        buffer-copy ub.cash-desk to buf_c-cash-desk
            assign
            buf_c-cash-desk.chip-num           = next-value (s-corr-chip, {&db-name_schema})
            buf_c-cash-desk.corr-time          = v-time
            buf_c-cash-desk.corr-user-db-num   = g#db-num
            buf_c-cash-desk.corr-user-name     = g#userid
            buf_c-cash-desk.corr-date          = v-date
            buf_c-cash-desk.is-del             = yes
            buf_c-cash-desk.attr-code          = "":U
            buf_c-cash-desk.subject            = {&table_cash-desk}
            buf_c-cash-desk.action             = integer({&hn-delete})
            .

    end.


    /* посылаем команду на удаление кассы */
    if not v-no-news then 
    do:
        if g#db-num = 0
            and not g#news
            and ub.cash-desk.db-num <> 0 then 
        do:
            /*хотя такого не бывает*/
            assign
                v-db-list = string(ub.cash-desk.db-num)
                .
        end.
        if g#db-num <> 0 then 
        do:
            assign
                v-db-list = string(0)
                .
        end.
        run nws/cmd-del.p
            ( input {&table_cash-desk}
            ,input (buffer ub.cash-desk:handle)
            ,input v-db-list
            ) no-error .
        if error-status :error then 
        do:
            return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
        run trg/userlog.p (
            input {&nwsdochs_action_delete}
            , input {&table_cash-desk}
            , input ( buffer ub.cash-desk :handle )
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

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_cash-desk}
            , input ( buffer ub.cash-desk:handle )
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
end.