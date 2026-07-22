block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись pl-pump-nozzle

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/15/07
Author: Dmitry Ukhanov
Creation date: 08/15/07


*/

TRIGGER PROCEDURE FOR WRITE OF ub.pl-pump-nozzle NEW BUFFER newb_pl-pump-nozzle OLD BUFFER oldb_pl-pump-nozzle.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись pl-pump-nozzle":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , newb_pl-pump-nozzle.obj-type
                         , newb_pl-pump-nozzle.obj-code
                         , newb_pl-pump-nozzle.pl-code
                         , newb_pl-pump-nozzle.pump-code
                         , newb_pl-pump-nozzle.nozzle-code
                         ) " }

{ cmp/trg-def.i  }

{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date    no-undo .
DEFINE VARIABLE v-time  as integer no-undo .

define buffer buf_c-pl-pump-nozzle for ub.c-pl-pump-nozzle.
define buffer buf_c-plc-hist       for ub.c-plc-hist.
define buffer buf_c-pmp-hist       for ub.c-pmp-hist.
define buffer buf_c-nzl-hist       for ub.c-nzl-hist.
define buffer buf_c-table-bind     for ub.c-table-bind.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run str/callnews.p
        ( input {&table_pl-pump-nozzle}
        ,input ( buffer newb_pl-pump-nozzle :handle )
        ).

    if g#news <> yes then 
    do:
        run cur-time in this-procedure
            ( output v-today
            ,output v-time
            ).
        create buf_c-pl-pump-nozzle.
        buffer-copy oldb_pl-pump-nozzle
            except
            obj-type
            obj-code
            pl-code
            pump-code
            nozzle-code
            to buf_c-pl-pump-nozzle
            assign
            buf_c-pl-pump-nozzle.obj-type           = newb_pl-pump-nozzle.obj-type
            buf_c-pl-pump-nozzle.obj-code           = newb_pl-pump-nozzle.obj-code
            buf_c-pl-pump-nozzle.pl-code            = newb_pl-pump-nozzle.pl-code
            buf_c-pl-pump-nozzle.pump-code          = newb_pl-pump-nozzle.pump-code
            buf_c-pl-pump-nozzle.nozzle-code        = newb_pl-pump-nozzle.nozzle-code
            buf_c-pl-pump-nozzle.chip-num           = next-value (s-plc-chip, {&db-name_schema})
            buf_c-pl-pump-nozzle.corr-time          = v-time
            buf_c-pl-pump-nozzle.corr-user-db-num   = g#db-num
            buf_c-pl-pump-nozzle.corr-user-name     = g#userid
            buf_c-pl-pump-nozzle.corr-date          = v-today
            .
        create buf_c-plc-hist.
        buffer-copy buf_c-pl-pump-nozzle to buf_c-plc-hist
            assign
            buf_c-plc-hist.action = (if new newb_pl-pump-nozzle then integer({&hn-create}) else integer({&hn-update}))
            buf_c-plc-hist.subject = {&table_pl-pump-nozzle}
            buf_c-plc-hist.is-news = g#news
            buf_c-plc-hist.gds-code = ?
            .

        create buf_c-pmp-hist.
        buffer-copy buf_c-pl-pump-nozzle
            except chip-num
            to buf_c-pmp-hist
            assign
            buf_c-pmp-hist.chip-num           = next-value (s-pmp-chip, {&db-name_schema})
            buf_c-pmp-hist.action = (if new newb_pl-pump-nozzle then integer({&hn-create}) else integer({&hn-update}))
            buf_c-pmp-hist.subject = {&table_pl-pump-nozzle}
            buf_c-pmp-hist.is-news = g#news
            buf_c-pmp-hist.gds-code = ?
            .
        create buf_c-table-bind.
        assign
            buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num
            buf_c-table-bind.chip-num-src     = buf_c-pl-pump-nozzle.chip-num
            buf_c-table-bind.corr-user-db-num = buf_c-pl-pump-nozzle.corr-user-db-num
            buf_c-table-bind.tbl-name-rec     = {&table_c-pmp-hist}
            buf_c-table-bind.tbl-name-src     = {&table_c-plc-hist}
            buf_c-table-bind.is-news          = g#news
            buf_c-table-bind.corr-user-name   = g#userid
            buf_c-table-bind.subject          = {&table_pl-pump-nozzle}
            .

        create buf_c-nzl-hist.
        buffer-copy buf_c-pl-pump-nozzle
            except chip-num
            to buf_c-nzl-hist
            assign
            buf_c-nzl-hist.chip-num           = next-value (s-nzl-chip, {&db-name_schema})
            buf_c-nzl-hist.action = (if new newb_pl-pump-nozzle then integer({&hn-create}) else integer({&hn-update}))
            buf_c-nzl-hist.subject = {&table_pl-pump-nozzle}
            buf_c-nzl-hist.is-news = g#news
            .
        create buf_c-table-bind.
        assign
            buf_c-table-bind.chip-num-rec     = buf_c-nzl-hist.chip-num
            buf_c-table-bind.chip-num-src     = buf_c-pl-pump-nozzle.chip-num
            buf_c-table-bind.corr-user-db-num = buf_c-pl-pump-nozzle.corr-user-db-num
            buf_c-table-bind.tbl-name-rec     = {&table_c-nzl-hist}
            buf_c-table-bind.tbl-name-src     = {&table_c-plc-hist}
            buf_c-table-bind.is-news          = g#news
            buf_c-table-bind.corr-user-name   = g#userid
            buf_c-table-bind.subject          = {&table_pl-pump-nozzle}
            .


    end. /* if not g#news */
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_pl-pump-nozzle}
            , input ( buffer newb_pl-pump-nozzle:handle )
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
    if new(ub.pl-pump-nozzle) then 
    do:   
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_pl-pump-nozzle}
            , input ( buffer newb_pl-pump-nozzle :handle )
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
            , input {&table_pl-pump-nozzle}
            , input ( buffer newb_pl-pump-nozzle :handle )
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