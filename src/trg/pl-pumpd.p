block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление pl-pump

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.pl-pump.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление pl-pump":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.pl-pump.obj-type
                         , ub.pl-pump.obj-code
                         , ub.pl-pump.pl-code
                         , ub.pl-pump.pump-code
                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date    no-undo .
DEFINE VARIABLE v-time  as integer no-undo .

define buffer buf_c-pl-pump    for ub.c-pl-pump.
define buffer buf_c-plc-hist   for ub.c-plc-hist.
define buffer buf_c-pmp-hist   for ub.c-pmp-hist.
define buffer buf_c-table-bind for ub.c-table-bind.


define buffer b-pl-pump        for ub.pl-pump.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ) :

    if not g#news then 
    do:
        run nws/cmd-del.p
            ( input {&table_pl-pump}
            ,input (buffer ub.pl-pump:handle)
            ,input "":U
            ) no-error .
        if error-status :error then 
        do:
            undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
    end.

    if g#news <> yes then 
    do:
        run cur-time in this-procedure(output v-today, output v-time).
        create buf_c-pl-pump.
        buffer-copy ub.pl-pump to buf_c-pl-pump
            assign
            buf_c-pl-pump.chip-num           = next-value (s-plc-chip, {&db-name_schema})
            buf_c-pl-pump.corr-time          = v-time
            buf_c-pl-pump.corr-user-db-num   = g#db-num
            buf_c-pl-pump.corr-user-name     = g#userid
            buf_c-pl-pump.corr-date          = v-today
            .
        create buf_c-plc-hist.
        buffer-copy buf_c-pl-pump to buf_c-plc-hist
            assign
            buf_c-plc-hist.action = integer({&hn-delete})
            buf_c-plc-hist.subject = {&table_pl-pump}
            buf_c-plc-hist.is-news = g#news
            buf_c-plc-hist.gds-code = ?
            .
        /*теперь пишем куст для c-pmp-hist*/

        create buf_c-pmp-hist.
        buffer-copy buf_c-pl-pump
            except chip-num
            to buf_c-pmp-hist
            assign
            buf_c-pmp-hist.chip-num  = next-value (s-pmp-chip, {&db-name_schema})
            buf_c-pmp-hist.action = integer({&hn-delete})
            buf_c-pmp-hist.subject = {&table_pl-pump}
            buf_c-pmp-hist.is-news = g#news
            buf_c-pmp-hist.gds-code = ?
            .
        create buf_c-table-bind.
        assign
            buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num
            buf_c-table-bind.chip-num-src     = buf_c-pl-pump.chip-num
            buf_c-table-bind.corr-user-db-num = buf_c-pl-pump.corr-user-db-num
            buf_c-table-bind.tbl-name-rec     = {&table_c-pmp-hist}
            buf_c-table-bind.tbl-name-src     = {&table_c-plc-hist}
            buf_c-table-bind.is-news          = g#news
            buf_c-table-bind.corr-user-name   = g#userid
            buf_c-table-bind.subject          = {&table_pl-pump}
            .
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_pl-pump}
            , input ( buffer ub.pl-pump:handle )
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
        , input {&table_pl-pump}
        , input ( buffer ub.pl-pump :handle )
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