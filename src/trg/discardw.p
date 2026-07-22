block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/01/05
Author: Bakhtadze Natalya
Creation date: 12/01/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-card OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись дисконтной карты".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ trg/new-bcod.i }
{ gbl/cur-time.i }
{ trg/discardh.i trig oldb ub.dis-card }


DEFINE VARIABLE conf-par    as character no-undo .
DEFINE VARIABLE par-type    as character no-undo .
DEFINE VARIABLE v-l-chr     as character no-undo .
define variable ii          as integer   no-undo .
define variable v-run-hist  as logical   no-undo .
define variable v-trg-param as character no-undo .
v-trg-param = ub.dis-card.trg-param.
ub.dis-card.trg-param = '':U.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


    if new(ub.dis-card) then 
    do:
        run gen-new-code-range-if-neces( input g#db-num,
            input {&gbl-dc-code},
            input ub.dis-card.card-num,
            input g#news,
            input g#db-num,
            input g#news-source-db
            ) no-error .
        if error-status:error then 
        do:
            undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
        end.
    end.

    { ref/send-ref.i conf-par par-type }
    /*создаем batchporcess для отсылки на кассы*/
    if not g#news and send-ref then 
    do:
        run trg/nu_dcard.p (
            input  ub.dis-card.d-card
            ,input  ub.dis-card.emitent-host-code
            ,input  "":U
            ,input  0
            ,input  "U":U
            ).
    end.
    buffer-compare ub.dis-card
        to oldb
        case-sensitive
        save result in v-l-chr .

    if v-l-chr <> "":U then 
    do:
        do ii =  1 to num-entries(v-l-chr):
            if lookup(entry(ii, v-l-chr), "card-num,cli-code,cli-type,d-card":U) > 0 then
                assign
                    v-run-hist = yes
                    .
        end.
    end.
    if lookup({&trg-param-no-hist}, v-trg-param) = 0
        then 
    do:
        assign
            v-run-hist = yes
            .
    end.
    if v-run-hist then 
    do:
        run discardh_write-dis-card-trigger in this-procedure  (
            input new(ub.dis-card)
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
    end.
    if (v-l-chr = "status_"
        and (ub.dis-card.status_ = {&nonused-status}
        or
        (ub.dis-card.status_ = {&chown-status}
        or
        oldb.status_ = {&chown-status}
        )
        )
        ) then 
    do:
    end.
    else 
    do:
        if lookup({&trg-param-no-callnews}, v-trg-param) = 0 then 
        do:
            run str/callnews.p
                (input {&table_dis-card}
                ,input (buffer ub.dis-card:handle)
                ) no-error .
            if error-status:error then 
            do:
                undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) ).
            end.
        end.
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_dis-card}
            , input ( buffer ub.dis-card:handle )
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
    if new(ub.dis-card) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
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
    else 
    do:
        run trg/userlog.p (
            input {&nwsdochs_action_update}
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
end.