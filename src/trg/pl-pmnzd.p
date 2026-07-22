block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление place-pump-nozzle

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/16/07
Author: Dmitry Ukhanov
Creation date: 08/16/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.pl-pump-nozzle.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление pl-pump-nozzle":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.pl-pump-nozzle.obj-type
                         , ub.pl-pump-nozzle.obj-code
                         , ub.pl-pump-nozzle.pl-code
                         , ub.pl-pump-nozzle.pump-code
                         , ub.pl-pump-nozzle.nozzle-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }
define variable v-today as date    no-undo .
define variable v-time  as integer no-undo .

define buffer buf_c-pl-pump-nozzle for ub.c-pl-pump-nozzle.
define buffer buf_c-plc-hist       for ub.c-plc-hist.
define buffer buf_c-pmp-hist       for ub.c-pmp-hist.
define buffer buf_c-nzl-hist       for ub.c-nzl-hist.
define buffer buf_c-table-bind     for ub.c-table-bind.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):

    /* удаление истории, которая не привязана к месту хранения */
    if not g#news then 
    do:
        run nws/cmd-del.p
            ( input {&table_pl-pump-nozzle}
            ,input ( buffer ub.pl-pump-nozzle :handle )
            ,input "":U
            ) no-error .
        if error-status :error then 
        do:
            undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4"
                ,vss-workfile, {&new-line}, return-value, error-status :get-message(1) ).
        end.
    end.

    if not g#news then 
    do:
        /*теперь пишем куст для c-plc-hist*/
        run cur-time in this-procedure
            ( output v-today
            ,output v-time
            ).
        create buf_c-pl-pump-nozzle.
        buffer-copy ub.pl-pump-nozzle to buf_c-pl-pump-nozzle
            assign
            buf_c-pl-pump-nozzle.chip-num           = next-value (s-plc-chip, {&db-name_schema})
            buf_c-pl-pump-nozzle.corr-time          = v-time
            buf_c-pl-pump-nozzle.corr-user-db-num   = g#db-num
            buf_c-pl-pump-nozzle.corr-user-name     = g#userid
            buf_c-pl-pump-nozzle.corr-date          = v-today
            .
        create buf_c-plc-hist.
        buffer-copy buf_c-pl-pump-nozzle to buf_c-plc-hist
            assign
            buf_c-plc-hist.action = integer({&hn-delete})
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
            buf_c-pmp-hist.action = integer({&hn-delete})
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


        /*теперь пишем куст для c-nzl-hist*/
        create buf_c-nzl-hist.
        buffer-copy buf_c-pl-pump-nozzle
            except chip-num
            to buf_c-nzl-hist
            assign
            buf_c-nzl-hist.chip-num           = next-value (s-nzl-chip, {&db-name_schema})
            buf_c-nzl-hist.action = integer({&hn-delete})
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

    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_pl-pump-nozzle}
            , input ( buffer ub.pl-pump-nozzle:handle )
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
        , input {&table_pl-pump-nozzle}
        , input ( buffer ub.pl-pump-nozzle :handle )
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