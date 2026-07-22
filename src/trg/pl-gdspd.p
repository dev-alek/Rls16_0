block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление pl-gds-pump

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/16/07
Author: Dmitry Ukhanov
Creation date: 08/16/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.pl-gds-pump.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление pl-gds-pump":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.pl-gds-pump.obj-type
                         , ub.pl-gds-pump.obj-code
                         , ub.pl-gds-pump.gds-code
                         , ub.pl-gds-pump.pump-code
                         , ub.pl-gds-pump.pl-code
                          ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/key-rec.i }

define variable str1           as character no-undo.
define variable jj             as integer   no-undo.
DEFINE VARIABLE v-today        as date      no-undo .
DEFINE VARIABLE v-time         as integer   no-undo .
define variable v-host-code    like ub.sysconf.host-code no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_c-pl-gds-pump for ub.c-pl-gds-pump.
define buffer buf_c-gds-hist    for ub.c-gds-hist.
define buffer buf_c-plc-hist    for ub.c-plc-hist.
define buffer buf_c-pmp-hist    for ub.c-pmp-hist.
define buffer buf_c-table-bind  for ub.c-table-bind.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):

    if not g#news then 
    do:
        run nws/cmd-del.p ( input {&table_pl-gds-pump}
            ,input ( buffer ub.pl-gds-pump :handle )
            ,input "":U                                    ) no-error.
        if error-status :error then 
        do:
            assign 
                str1 = "":U.
            do jj = 1 to error-status :num-messages :
                assign 
                    str1 = str1 + {&new-line} + error-status :get-message ( jj ).
            end.
            undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4",
                vss-workfile, {&new-line}, return-value, str1 ).
        end.
    end.
    if g#news <> yes then 
    do:
        run cur-time in this-procedure(output v-today, output v-time).

        /*пишем куст для c-plc-hist*/

        create buf_c-pl-gds-pump.
        buffer-copy ub.pl-gds-pump to buf_c-pl-gds-pump
            assign
            buf_c-pl-gds-pump.chip-num           = next-value (s-plc-chip, {&db-name_schema})
            buf_c-pl-gds-pump.corr-time          = v-time
            buf_c-pl-gds-pump.corr-user-db-num   = g#db-num
            buf_c-pl-gds-pump.corr-user-name     = g#userid
            buf_c-pl-gds-pump.corr-date          = v-today
            .
        create buf_c-plc-hist.
        buffer-copy buf_c-pl-gds-pump to buf_c-plc-hist
            assign
            buf_c-plc-hist.action = integer({&hn-delete})
            buf_c-plc-hist.subject = {&table_pl-gds-pump}
            buf_c-plc-hist.is-news = g#news
            .

    /*сначала создаем куст для c-gds-hist*/
        { gbl/hostcode.i ub.pl-gds-pump.obj-type ub.pl-gds-pump.obj-code v-host-code }
        run gen-key-rec in this-procedure ( input {&table_pl-gds-pump}
            ,input buffer ub.pl-gds-pump:handle
            ,output v-uniq-key-rec).

        create buf_c-gds-hist.
        buffer-copy buf_c-pl-gds-pump
            except chip-num
            to buf_c-gds-hist
            assign
            buf_c-gds-hist.action = integer({&hn-delete})
            buf_c-gds-hist.subject = {&table_pl-gds-pump}
            buf_c-gds-hist.host-code = v-host-code
            buf_c-gds-hist.is-news = g#news
            buf_c-gds-hist.chip-num = next-value (s-gds-chip, {&db-name_schema})
            buf_c-gds-hist.source-type = (if g#news then {&hn-source-db} else "":U)
            buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
            .
        create buf_c-table-bind.
        assign
            buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num
            buf_c-table-bind.chip-num-src     = buf_c-pl-gds-pump.chip-num
            buf_c-table-bind.corr-user-db-num = buf_c-pl-gds-pump.corr-user-db-num
            buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
            buf_c-table-bind.tbl-name-src     = {&table_c-plc-hist}
            buf_c-table-bind.is-news          = g#news
            buf_c-table-bind.corr-user-name   = g#userid
            buf_c-table-bind.subject          = {&table_pl-gds-pump}
            .

        /*в новости пустим c-pl-gds-pump из УБД в ГБД*/
        /*теперь пишем куст для c-pmp-hist*/

        create buf_c-pmp-hist.
        buffer-copy buf_c-pl-gds-pump
            except chip-num
            to buf_c-pmp-hist
            assign
            buf_c-pmp-hist.chip-num = next-value (s-pmp-chip, {&db-name_schema})
            buf_c-pmp-hist.action = integer({&hn-delete})
            buf_c-pmp-hist.subject = {&table_pl-gds-pump}
            buf_c-pmp-hist.is-news = g#news
            buf_c-pmp-hist.gds-code = ub.pl-gds-pump.gds-code
            .

        create buf_c-table-bind.
        assign
            buf_c-table-bind.chip-num-rec     = buf_c-pmp-hist.chip-num
            buf_c-table-bind.chip-num-src     = buf_c-pl-gds-pump.chip-num
            buf_c-table-bind.corr-user-db-num = buf_c-pl-gds-pump.corr-user-db-num
            buf_c-table-bind.tbl-name-rec     = {&table_c-pmp-hist}
            buf_c-table-bind.tbl-name-src     = {&table_c-plc-hist}
            buf_c-table-bind.is-news          = g#news
            buf_c-table-bind.corr-user-name   = g#userid
            buf_c-table-bind.subject          = {&table_pl-gds-pump}

            .


    end. /* if not g#news */

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_pl-gds-pump}
            , input ( buffer ub.pl-gds-pump:handle )
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
        , input {&table_pl-gds-pump}
        , input ( buffer buf_c-pl-gds-pump :handle )
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
end. /* main-block */