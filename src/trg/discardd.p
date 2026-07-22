block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи Дисконтная карта

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-card .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи Дисконтная карта".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/discardh.i trig ub.dis-card ub.dis-card delete }
define buffer buf_dis-obj             for ub.dis-obj.
define buffer buf_dis-host            for ub.dis-host.
define buffer buf_c-dc-hist           for ub.c-dc-hist .
define buffer buf_c-dis-obj           for ub.c-dis-obj .
define buffer buf_c-dis-host          for ub.c-dis-host .
define buffer buf_dis-card-property   for ub.dis-card-property.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
define buffer buf_dis-dc-rule         for ub.dis-dc-rule.
define buffer buf_c-dis-dc-rule       for ub.c-dis-dc-rule.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if ub.dis-card.status_ <> {&nonused-status} then 
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Физическое удаление дисконтной карты возможно только для НЕИСПОЛЬЗОВАВШИХСЯ карт" skip
            view-as alert-box error .
        undo main-block, return error.
    end.
    for each buf_dis-card-property where
        buf_dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.dis-card-property where
            recid(ub.dis-card-property) = recid(buf_dis-card-property) .
        assign
            ub.dis-card-property.card-num = - abs(ub.dis-card-property.card-num).
        delete ub.dis-card-property.
    end.
    for each buf_dis-obj where
        buf_dis-obj.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.dis-obj where
            recid(ub.dis-obj) = recid(buf_dis-obj) .
        assign
            ub.dis-obj.card-num = - abs(ub.dis-obj.card-num).
        delete ub.dis-obj.
    end.
    for each buf_dis-host where
        buf_dis-host.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        find first ub.dis-host where
            recid(ub.dis-host) = recid(buf_dis-host) .
        assign
            ub.dis-host.card-num = - abs(ub.dis-host.card-num).
        delete ub.dis-host.
    end.
    for each buf_c-dis-card-property where
        buf_c-dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:

        find first ub.c-dis-card-property where
            recid(ub.c-dis-card-property) = recid(buf_c-dis-card-property) .
        assign
            ub.c-dis-card-property.card-num = - abs(ub.c-dis-card-property.card-num).
        delete ub.c-dis-card-property.
    end.
    for each buf_c-dis-obj where
        buf_c-dis-obj.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:

        find first ub.c-dis-obj where
            recid(ub.c-dis-obj) = recid(buf_c-dis-obj) .
        assign
            ub.c-dis-obj.card-num = - abs(ub.c-dis-obj.card-num).
        delete ub.c-dis-obj.
    end.
    for each buf_c-dis-host where
        buf_c-dis-host.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:

        find first ub.c-dis-host where
            recid(ub.c-dis-host) = recid(buf_c-dis-host) .
        assign
            ub.c-dis-host.card-num = - abs(ub.c-dis-host.card-num).
        delete ub.c-dis-host.
    end.
    for each buf_c-dc-hist where
        buf_c-dc-hist.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        if buf_c-dc-hist.subject <> {&table_dis-card} then 
        do:
            find first ub.c-dc-hist where
                recid(ub.c-dc-hist) = recid(buf_c-dc-hist) .
            assign
                ub.c-dc-hist.card-num = - abs(ub.c-dc-hist.card-num).
            delete ub.c-dc-hist.
        end.
    end.
    for each buf_dis-card-property where
        buf_Dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_Dis-card-property.card-num = - abs(buf_dis-card-property.card-num).
        delete buf_dis-card-property.
    end.
    for each buf_c-dis-card-property where
        buf_c-Dis-card-property.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_c-Dis-card-property.card-num = - abs(buf_c-dis-card-property.card-num).
        delete buf_c-dis-card-property.
    end.
    for each buf_dis-dc-rule where
        buf_dis-dc-rule.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_Dis-dc-rule.card-num = - abs(buf_dis-dc-rule.card-num).
        delete buf_dis-dc-rule.
    end.
    for each buf_c-dis-dc-rule where
        buf_c-dis-dc-rule.d-card = ub.dis-card.d-card
        on error undo main-block, return error
        on stop undo main-block, return error:
        assign
            buf_c-Dis-dc-rule.card-num = - abs(buf_c-dis-dc-rule.card-num).
        delete buf_c-dis-dc-rule.
    end.
    /*по новостям команду не посылаем - потому что удаляться может карта только с помощью two-commit*/
    run discardh_write-dis-card-trigger in this-procedure  (
        input no /*new*/
        ,input (if g#news
        then {&hn-source-db}
        else (if g#esys
        then {&hn-source-esys}
        else "":U)
        )
        ,input  (if g#news
        then string(g#news-source-db)
        else (if g#esys
        then string(g#esys-source-esys)
        else "":U)
        )
        ) .

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_dis-card}
            , input ( buffer ub.dis-card:handle )
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
        , input {&table_dis-card}
        , input ( buffer ub.dis-card :handle )
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