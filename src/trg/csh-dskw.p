block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись cash-desk

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.cash-desk OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись cash-desk".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',  ub.cash-desk.db-num
                                        , ub.cash-desk.obj-code
                                        , ub.cash-desk.pos-type
                                        , ub.cash-desk.cash-num
                                          ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define variable v-date as date    no-undo .
define variable v-time as integer no-undo .


define buffer buf_cash-desk      for ub.cash-desk.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf_c-cash-desk    for ub.c-cash-desk.
define buffer buf_shop           for ub.shop.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    if not g#news and ub.cash-desk.db-num <> g#db-num then 
    do:
        message
            "Нельзя изменять запись о кассе," skip
            "принадлежащей другой БД"
            view-as alert-box .
        undo main-block, return error.
    end.
    find first buf_shop no-lock where
        buf_shop.obj-code = ub.cash-desk.obj-code no-error .
    if not avail buf_shop then 
    do:
        message
            "Не найден магазин" ub.cash-desk.obj-code  "для кассы" skip
            "БД" ub.cash-desk.db-num
            "маг" ub.cash-desk.obj-code
            "тип" ub.cash-desk.pos-type
            "N кассы" ub.cash-desk.cash-num
            view-as alert-box .
        undo main-block, return error.
    end.
    if (buf_shop.is-kitchen
        or buf_shop.is-kitchen-store)
        and not buf_shop.is-catering
        then 
    do:
        message
            "Нельзя создавать/изменять запись кассы для магазина, который имеет признаки КУХНЯ и/или СКЛАД КУХНИ" skip
            "и не является РЕСТОРАНОМ"
            "БД" ub.cash-desk.db-num
            "маг" ub.cash-desk.obj-code
            "тип" ub.cash-desk.pos-type
            "N кассы" ub.cash-desk.cash-num
            view-as alert-box .
        undo main-block, return error.
    end.
    FIND FIRST ub.wth-place NO-LOCK where
        ub.wth-place.obj-code = oldb.obj-code AND
        ub.wth-place.obj-type = {&shop} AND
        ub.wth-place.cash-desk = oldb.cash-num NO-ERROR.
    IF AVAIL ub.wth-place and
        NOT (oldb.obj-code = ub.cash-desk.obj-code) then 
    do:
        message "Данная касса привязана к МХ МЦ!" skip
            "изменение невозможно!" view-as alert-box ERROR.
        undo main-block, return error.
    end.
    find first buf_cash-desk No-LOCK WHERE
        buf_cash-desk.obj-code = ub.cash-desk.obj-code AND
        buf_cash-desk.pos-type = ub.cash-desk.pos-type AND
        buf_cash-desk.cash-num = ub.cash-desk.cash-num no-error .
    if available buf_cash-desk and
        recid(ub.cash-desk) <> recid(Buf_cash-desk) then 
    do:
        message
            "В магазине" ub.cash-desk.obj-code "уже есть касса типа" ub.cash-desk.pos-type skip
            "с номером" ub.cash-desk.cash-num
            view-as alert-box error .
        undo main-block, return error .
    end.
    if not g#news then 
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-cash-desk.
        buffer-copy oldb to buf_c-cash-desk
            assign
            buf_c-cash-desk.db-num             =  ub.cash-desk.db-num
            buf_c-cash-desk.obj-code           =  ub.cash-desk.obj-code
            buf_c-cash-desk.pos-type           =  ub.cash-desk.pos-type
            buf_c-cash-desk.cash-num           =  ub.cash-desk.cash-num
            buf_c-cash-desk.chip-num           = next-value (s-cash-desk-chip, {&db-name_schema})
            buf_c-cash-desk.corr-time          = v-time
            buf_c-cash-desk.corr-user-db-num   = g#db-num
            buf_c-cash-desk.corr-user-name     = g#userid
            buf_c-cash-desk.corr-date          = v-date
            buf_c-cash-desk.subject            = {&table_cash-desk}
            buf_c-cash-desk.action             = integer(if new(ub.cash-desk) then {&hn-create} else {&hn-update})
            .
    end.
    define variable v-new-cash-desk as logical no-undo .

    assign
        v-new-cash-desk = new(ub.cash-desk)
        .
    if v-new-cash-desk = true then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
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
    else 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_update}
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
    run str/callnews.p
        ( input {&table_cash-desk}
        ,input (buffer ub.cash-desk:handle)
        ) .
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_cash-desk}
            , input ( buffer ub.cash-desk:handle )
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