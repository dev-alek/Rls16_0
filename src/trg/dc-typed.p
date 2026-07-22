block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление типа дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-card-type.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление типа дисконтной карты".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.dis-card-type.emitent-host-code
                         , ub.dis-card-type.type
                         , ub.dis-card-type.host-code
                        , ub.dis-card-type.obj-type
                        , ub.dis-card-type.obj-code
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-card-type    for ub.c-dis-card-type.
define buffer buf_hist-nws-option    for ub.hist-nws-option.
define buffer buf_rule-call-param    for ub.rule-call-param.
define buffer buf_rp-by-call         for ub.rp-by-call.
define buffer buf_rule-by-call       for ub.rule-by-call.
define buffer buf_Dis-card-type      for ub.dis-card-type.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_dis-dct-rule       for ub.dis-dct-rule.
define buffer buf_prop-ref-call      for ub.prop-ref-call.



main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    if not g#news
        and g#db-num <> 0 then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Запрещено удаление типа ДК в УБД"
            view-as alert-box error .
        undo main-block, return error .
    end.
    if ub.dis-card-type.host-code = 0
        and ub.dis-card-type.obj-code = 0
        and ub.dis-card-type.obj-type = '':U
        then 
    do:
        FIND FIRST ub.dis-card No-LOCK WHERE
            ub.dis-card.type = ub.dis-card-type.type AND
            ub.dis-card.emitent-host-code = ub.dis-card-type.emitent-host-code NO-ERROR.
        if avail ub.dis-card then 
        do:
            message "Для типа дисконтной карты имеются карты!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.
        end.
        find first buf_prop-ref-call no-lock where
            buf_prop-ref-call.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_prop-ref-call then 
        do:
            message "Для типа дисконтной карты имеются срезы/итоги!" skip
                "Удаление невозможно!" view-as alert-box ERROR.
            undo main-block, return error.

        end.

        find first buf_dis-card-type-attr no-lock where
            buf_dis-card-type-attr.emitent-host-code = ub.dis-card-type.emitent-host-code
            and buf_dis-card-type-attr.type = ub.dis-card-type.type no-error.
        if available buf_dis-card-type-attr then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются записи атрибутов типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.

        find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code = ub.dis-card-type.emitent-host-code
            and buf_dis-card-type.type = ub.dis-card-type.type
            and buf_dis-card-type.host-code > 0 no-error.
        if available buf_dis-card-type then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются записи локальных (фирма или объект) настроек для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_hist-nws-option no-lock where
            buf_hist-nws-option.table-name = {&table_dis-card-type}
            and buf_hist-nws-option.host-code = ub.dis-card-type.emitent-host-code
            AND buf_hist-nws-option.charkey_one = ub.dis-card-type.type no-error .
        if available buf_hist-nws-option then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются записи опций маршрутизации и записи истории для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_rule-by-call no-lock where
            buf_rule-by-call.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_rule-by-call then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются привязки правил к типу ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_rp-by-call then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются привязки правил к профайлам правил для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
        find first buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = ub.dis-card-type.uniq-key-rec no-error.
        if available buf_rule-call-param then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Имеются параметры вызова правил для типа ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    for each buf_dis-dct-rule  where
        buf_Dis-dct-rule.emitent-host-code = ub.dis-card-type.emitent-host-code
        and buf_Dis-dct-rule.type = ub.dis-card-type.type
        and buf_Dis-dct-rule.host-code = ub.dis-card-type.host-code
        and buf_Dis-dct-rule.obj-type = ub.dis-card-type.obj-type
        and buf_Dis-dct-rule.obj-code = ub.dis-card-type.obj-code
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
        if buf_Dis-dct-rule.discnt-role = {&ddctr-def-categ}
            or buf_Dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
            or buf_Dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt} then 
        do:
            delete buf_Dis-dct-rule.
        end.
        else 
        do:

&scop dis-dct-rule-code buf_dis-dct-rule.discnt-role
            message
                vss-workfile vss-revision vss-description skip
                "Имеются скидки для ТИПА ДК" skip
                "Тип ДК" ub.dis-card-type.type "Эмитент" ub.dis-card-type.emitent-host-code
                "Фирма" ub.dis-card-type.host-code
                "Объект" ub.dis-card-type.obj-type ub.dis-card-type.obj-code
                "Объект"
                "Тип скидки"  {&dis-dct-rule-name}
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-card-type.
    buffer-copy ub.dis-card-type to buf_c-dis-card-type
        assign
        buf_c-dis-card-type.chip-num           = next-value (s-dc-chip, {&db-name_schema})
        buf_c-dis-card-type.corr-time          = v-time
        buf_c-dis-card-type.corr-user-db-num   = g#db-num
        buf_c-dis-card-type.corr-user-name     = g#userid
        buf_c-dis-card-type.corr-date          = v-date
        buf_c-dis-card-type.action = integer({&hn-delete})
        buf_c-dis-card-type.subject = {&table_dis-card-type}
        .

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_dis-card-type}
            , input ( buffer ub.dis-card-type:handle )
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
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_dis-card-type}
        , input ( buffer ub.dis-card-type :handle )
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