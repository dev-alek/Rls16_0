block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись данных настройки и конфигурации системы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/18/00
Author: Dmitry Ukhanov
Creation date: 11/18/00

*/

TRIGGER PROCEDURE FOR WRITE OF ub.config old old-config.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись данных настройки и конфигурации системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/conf-enc.i }
{ gbl/cur-time.i }
/*{ adm/cnf-inc.i &new="new" }*/

main-block:
do
    on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on endkey undo main-block, return error substitute("&1. endkey")
    on stop   undo main-block, return error substitute("&1. stop")
    :
    define variable v-ok              as logical   no-undo .
    define variable v-host-code       as integer   no-undo .
    define variable v-assignment-type as character no-undo .
    define variable v-field-chg       as character no-undo .

    define variable v-date            as date      no-undo .
    define variable v-time            as integer   no-undo .

    define buffer buf_c-config for ub.c-config .
    define buffer buf_sys-ctrl for ub.sys-ctrl .

    if ub.config.param-code = ""
        or ub.config.param-code = ?
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Имя параметра должно быть задано" skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        undo, return error .
    end.

    if not new ub.config
        and ub.config.param-code <> old-config.param-code
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя изменить имя параметра" skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        return error .
    end.

    if length(ub.config.param-code) > 8
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Длина имени параметра не может превышать 8 символов" skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        undo, return error .
    end.

    if lookup( ub.config.param-type, "C,L,D,I,T") = 0
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип параметра" skip
            "param-code" ub.config.param-code skip
            "param-type" ub.config.param-type skip
            view-as alert-box error .
        undo, return error .
    end.

    /* проверка привязки к фирме */
    if ub.config.host-code <> 0
        then 
    do:
        find first ub.sysconf no-lock
            where ub.sysconf.host-code = ub.config.host-code
            no-error .
        if not available ub.sysconf
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Задан неправильный код фирмы"    skip
                "param-code" ub.config.param-code skip
                "host-code"  ub.config.host-code  skip
                view-as alert-box error .
            undo, return error .
        end.
    end.

    /* если задан объект, то должна быть задана фирма */
    if ub.config.obj-type <> ""
        or ub.config.obj-code <> 0
        then 
    do:
        { gbl/hostcode.i
      ub.config.obj-type
      ub.config.obj-code
      v-host-code
      no-error
    }
        if error-status :error
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении кода фирмы для объекта" skip
                "param-code" ub.config.param-code skip
                "ub.config.obj-type" ub.config.obj-type skip
                "ub.config.obj-code" ub.config.obj-code skip
                view-as alert-box error .
            undo, return error .
        end.

        if ub.config.host-code = 0
            or ub.config.host-code = ?
            then 
        do:
            assign
                ub.config.host-code = v-host-code
                .
        end.
        if ub.config.host-code <> v-host-code
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Фирма не соответствует объекту"  skip
                "param-code" ub.config.param-code skip
                "host-code"  ub.config.host-code  skip
                "obj-type"   ub.config.obj-type   skip
                "obj-code"   ub.config.obj-code   skip
                view-as alert-box error .
            undo, return error .
        end.
    end.

    /* проверка задания привязки параметра */
    /* тип параметра                    v-assignment-type
    глобальный                       00000
    привязан к фирме                 10000
    привязан к фирме и объекту       11000
    привязан к группе                00100
    привязан к пользователю          00010
    привязан к АРМУ                  00001
    */

    assign
        v-assignment-type = ( if  ub.config.host-code = 0  then "0" else "1" )
                        + ( if  ub.config.obj-type  = ""
                            and ub.config.obj-code  = 0
                            then "0" else "1"
                          )
        .
    if lookup( v-assignment-type, '00,10,11':U ) = 0
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неправильная привязка параметра конфигурации" skip
            "param-code" ub.config.param-code skip
            "host-code"  ub.config.host-code  skip
            "obj-type"   ub.config.obj-type   skip
            "obj-code"   ub.config.obj-code   skip
            "привязка"   v-assignment-type    skip
            view-as alert-box error .
        undo, return error .
    end.

    if not new ub.config
        and ub.config.conf-type <> old-config.conf-type
        then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя изменить тип параметра." skip
            "param-code" ub.config.param-code skip
            view-as alert-box error .
        return error .
    end.

    /* запись уже существовала и параметр кодированный */
    if not new ub.config
        and ub.config.conf-type = {&cnf-type-list-protect}
        then 
    do:
        /* запрет изменения привязки для кодированных параметров */
        if ub.config.host-code  <> old-config.host-code
            or ub.config.obj-type   <> old-config.obj-type
            or ub.config.obj-code   <> old-config.obj-code
            then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Параметр кодированный" skip
                "Нельзя изменить привязку кодированного параметра" skip
                "param-code" ub.config.param-code skip
                view-as alert-box error .
            return error .
        end.
    end.

    if lookup( ub.config.conf-type, {&cnf-type-list-protect} ) > 0
        then 
    do:
        /* проверка кодированного параметра */
        find first ub.db no-lock
            where ub.db.db-num = ub.config.db-num
            .
        /* проверка кодирования */
        run check-enc in this-procedure
            ( input ub.config.db-num
            ,input ub.db.db-key
            ,input ub.config.param-code
            ,input ub.config.param-value
            ,input ub.config.beg-date
            ,input ub.config.end-date
            ,input ub.config.param-encoded
            ,output v-ok
            ) no-error .
        if error-status :error
            then 
        do:
            undo main-block, return error substitute("&1. Ошибка при проверке кодировки параметра &2&3&4&3&5", vss-workfile, ub.config.param-code, {&new-line}, return-value, error-status :get-message ( 1 ) ).
        end.
        if v-ok <> true
            then 
        do:
            undo main-block, return error substitute("&1. Неверное кодированное значение параметра &2", vss-workfile, ub.config.param-code ).
        end.
    end.


    if  ub.config.db-num = g#db-num
        and lookup(ub.config.conf-type, {&cnf-type-list-protect}) > 0
        then 
    do:
        /* конфигурация изменилась */
        /* помечаем текущее меню, как требующее перезагрузки */
        run gbl/menu-clr.p
            (input {&menu-code-main} /* p-menu-code */
            ) .

        /* помечаем права, как требующие перезагрузки */
        run gbl/actn-clr.p
            (input {&action-head-code-main} /* p-action-head-code */
            ) .
    end.


    if ub.config.beg-date = ?
        or ub.config.end-date = ?
        then 
    do:
        undo main-block, return error substitute("&1. Не задана дата начала и/или окончания действия параметра &2", vss-workfile, ub.config.param-code ).
    end.

    /* пишем историю если мы не просто поставили флажек на удаление */
    buffer-compare ub.config to old-config save result in v-field-chg.
    if v-field-chg <> "stts":U
        then 
    do:
        find first buf_sys-ctrl no-lock .
        run cur-time in this-procedure
            ( output v-date
            ,output v-time
            ).
        create buf_c-config.
        if new(ub.config) then 
        do:
            assign
                buf_c-config.param-code = ub.config.param-code
                buf_c-config.host-code  = ub.config.host-code
                buf_c-config.obj-type   = ub.config.obj-type
                buf_c-config.obj-code   = ub.config.obj-code
                buf_c-config.beg-date   = ub.config.beg-date
                buf_c-config.end-date   = ub.config.end-date
                buf_c-config.db-num     = ub.config.db-num
                .
        end.
        else 
        do:
            buffer-copy old-config to buf_c-config .
        end.
        assign
            buf_c-config.chip-num         = next-value (s-cfg-chip, {&db-name_schema})
            buf_c-config.corr-time        = v-time
            buf_c-config.corr-date        = v-date
            buf_c-config.corr-user-db-num = buf_sys-ctrl.db-num
            buf_c-config.corr-user-name   = (if g#news = true then "СПН" else g#userid )
            buf_c-config.action           = integer(if new(ub.config) then {&hn-create} else {&hn-update})
            .
        if trim( buf_c-config.corr-user-name ) = "":U then 
        do:
            assign
                buf_c-config.corr-user-name = userid( "ub":U )
                .
        end.
    end.

    run str/callnews.p
        (input {&table_config}
        ,input (buffer ub.config:handle)
        ) no-error .
    if error-status :error
        then 
    do:
        undo main-block, return error substitute("&1. Невозможно маршрутизировать config для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
    end.

    if g#oxml = yes then 
    do:
        run str/calloxml.p
            ( input {&nwsdochs_action_update}
            ,input {&table_config}
            ,input ( buffer ub.config:handle )
            ) no-error.
        if error-status :error then 
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , {&new-line}
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    if new(ub.config) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_config}
            , input ( buffer ub.config :handle )
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
            , input {&table_config}
            , input ( buffer ub.config :handle )
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