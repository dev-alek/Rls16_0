block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы типы дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-card-type OLD old_dis-card-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы типы дисконтных карт".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.dis-card-type.emitent-host-code
                         , ub.dis-card-type.type
                         , ub.dis-card-type.host-code
                        , ub.dis-card-type.obj-type
                        , ub.dis-card-type.obj-code
                         ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/key-rec.i }

define variable v-date         as date      no-undo .
define variable v-time         as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-descr        as character no-undo .
define buffer buf_c-dis-card-type for ub.c-dis-card-type.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if not g#news then 
    do:
        if new(ub.dis-card-type) then 
        do:
            run gen-key-rec in this-procedure ( input {&table_dis-card-type}
                ,input buffer ub.dis-card-type:handle
                ,output v-uniq-key-rec).

            if ub.dis-card-type.uniq-key-rec <> v-uniq-key-rec then 
            do:
                if ub.dis-card-type.uniq-key-rec = '':U then 
                do:
                    ub.dis-card-type.uniq-key-rec = v-uniq-key-rec.
                end.
                else 
                do:
                    run vss-get-parameters in this-procedure (output v-descr).
                    message
                        vss-workfile vss-revision vss-description skip
                        "Неверное значение поля uniq-key-rec" ub.dis-card-type.uniq-key-rec skip
                        "Должно быть" v-uniq-key-rec
                        v-descr
                        view-as alert-box error .
                    ub.dis-card-type.uniq-key-rec = v-uniq-key-rec.
                    undo main-block, return error .

                end.
            end.
        end.
        else 
        do:
            if ub.dis-card-type.type <> old_dis-card-type.type
                or ub.dis-card-type.emitent-host-code <> old_dis-card-type.emitent-host-code
                then 
            do:
                run vss-get-parameters in this-procedure (output v-descr).
                message
                    vss-workfile vss-revision vss-description skip
                    "Нельзя изменять поля первичного ключа" skip
                    v-descr skip
                    "Старый ПК" old_dis-card-type.uniq-key-rec
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.
    end.
    define variable v-cmp as logical no-undo .
    if not new(ub.dis-card-type) then 
    do:
        buffer-compare ub.dis-card-type
            to old_dis-card-type
            case-sensitive
            save result in v-cmp.
    end.
    else 
    do:
        v-cmp = no.
    end.
    if not v-cmp then 
    do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-dis-card-type.
        buffer-copy old_dis-card-type to buf_c-dis-card-type
            assign
            buf_c-dis-card-type.emitent-host-code    = ub.dis-card-type.emitent-host-code
            buf_c-dis-card-type.type                 = ub.dis-card-type.type
            buf_c-dis-card-type.host-code            = ub.dis-card-type.host-code
            buf_c-dis-card-type.obj-type             = ub.dis-card-type.obj-type
            buf_c-dis-card-type.obj-code             = ub.dis-card-type.obj-code
            buf_c-dis-card-type.chip-num           = next-value (s-dc-chip, {&db-name_schema})
            buf_c-dis-card-type.corr-time          = v-time
            buf_c-dis-card-type.corr-user-db-num   = g#db-num
            buf_c-dis-card-type.corr-user-name     = g#userid
            buf_c-dis-card-type.corr-date          = v-date
            buf_c-dis-card-type.action = (if new ub.dis-card-type then integer({&hn-create}) else integer({&hn-update}))
            buf_c-dis-card-type.subject = {&table_dis-card-type}
            buf_c-dis-card-type.uniq-key-rec         = ub.dis-card-type.uniq-key-rec
            .
    end.
    /*callnews.p не вызываем, потому что работаем через cmd-bush*/

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_dis-card-type}
            , input ( buffer ub.dis-card-type:handle )
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
    if new(ub.dis-card-type) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
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
    else 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_update}
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
end.