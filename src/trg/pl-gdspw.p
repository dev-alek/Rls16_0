block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись pl-gds-pump

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/16/07
Author: Dmitry Ukhanov
Creation date: 08/16/07


*/

TRIGGER PROCEDURE FOR WRITE OF ub.pl-gds-pump NEW BUFFER new_pl-gds-pump OLD BUFFER old_pl-gds-pump.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись pl-gds-pump":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , new_pl-gds-pump.obj-type
                         , new_pl-gds-pump.obj-code
                         , new_pl-gds-pump.gds-code
                         , new_pl-gds-pump.pump-code
                         , new_pl-gds-pump.pl-code
                          ) " }

{ cmp/trg-def.i  }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today     as date    no-undo .
DEFINE VARIABLE v-time      as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_c-pl-gds-pump for ub.c-pl-gds-pump.
define buffer buf_c-gds-hist    for ub.c-gds-hist.
define buffer buf_c-plc-hist    for ub.c-plc-hist.
define buffer buf_c-pmp-hist    for ub.c-pmp-hist.
define buffer buf_c-table-bind  for ub.c-table-bind.


main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


    run str/callnews.p
        ( input {&table_pl-gds-pump}
        ,input ( buffer new_pl-gds-pump :handle )
        ).
    if g#news <> yes then 
    do:
        /*нам надо бы прикрепить историю и к place и к goods и pump
        поэтому пишем ТРИ раза
        в ветку c-gds-hist
        и в ветку c-plc-hist
        и в ветку c-pmp-hist
        */
        /*дату время читаем один раз*/
        run cur-time in this-procedure(output v-today, output v-time).

        /*пишем куст для c-plc-hist*/
        create buf_c-pl-gds-pump.
        buffer-copy old_pl-gds-pump
            except
            gds-code
            obj-type
            obj-code
            pl-code
            gds-code
            pump-code
            to buf_c-pl-gds-pump
            assign
            buf_c-pl-gds-pump.gds-code           = new_pl-gds-pump.gds-code
            buf_c-pl-gds-pump.obj-type           = new_pl-gds-pump.obj-type
            buf_c-pl-gds-pump.obj-code           = new_pl-gds-pump.obj-code
            buf_c-pl-gds-pump.pl-code            = new_pl-gds-pump.pl-code
            buf_c-pl-gds-pump.pump-code          = new_pl-gds-pump.pump-code
            buf_c-pl-gds-pump.chip-num           = next-value (s-plc-chip, {&db-name_schema})
            buf_c-pl-gds-pump.corr-time          = v-time
            buf_c-pl-gds-pump.corr-user-db-num   = g#db-num
            buf_c-pl-gds-pump.corr-user-name     = g#userid
            buf_c-pl-gds-pump.corr-date          = v-today
            .

        create buf_c-plc-hist.
        buffer-copy buf_c-pl-gds-pump to buf_c-plc-hist
            assign
            buf_c-plc-hist.action = (if new new_pl-gds-pump then integer({&hn-create}) else integer({&hn-update}))
            buf_c-plc-hist.subject = {&table_pl-gds-pump}
            buf_c-plc-hist.is-news = g#news
            .
        if buf_c-pl-gds-pump.status_ <> new_pl-gds-pump.status_ then 
        do:
            define variable v-vid-param as LONGCHAR  no-undo .
            define variable v-gds-name  as character no-undo .
            find first ub.goods no-lock where ub.goods.gds-code = buf_c-plc-hist.gds-code no-error .    
            if AVAILABLE ub.goods then                                                                   
            do:                                                                                         
                v-gds-name = ub.goods.gds-name .                                                         
            end.
            { str/initiator.i }

            v-vid-param = 
                "Initiator=" + v-initiator + {&delim-par} +
                "SHOP_NUM=" + string(buf_c-plc-hist.obj-code) + {&delim-par} +
                "pl-code=" + string(buf_c-plc-hist.pl-code) + {&delim-par} +
                "old-status_=" + buf_c-pl-gds-pump.status_  + {&delim-par} +
                "status_=" + new_pl-gds-pump.status_ + {&delim-par} +
                "gds-code=" + string(buf_c-plc-hist.gds-code) + {&delim-par} +
                "gds-name=" + v-gds-name.
              
            run trg/userlog.p (
                input {&nwsdochs_action_update}
                , input {&table_c-plc-hist}
                , input ( buffer buf_c-plc-hist :handle )
                , input 61
                , input v-vid-param
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
    /*создаем куст для c-gds-hist*/
        { gbl/hostcode.i new_pl-gds-pump.obj-type new_pl-gds-pump.obj-code v-host-code }

        create buf_c-gds-hist.
        buffer-copy buf_c-pl-gds-pump
            except chip-num
            to buf_c-gds-hist
            assign
            buf_c-gds-hist.action = (if new new_pl-gds-pump then integer({&hn-create}) else integer({&hn-update}))
            buf_c-gds-hist.subject = {&table_pl-gds-pump}
            buf_c-gds-hist.host-code = v-host-code
            buf_c-gds-hist.is-news = g#news
            buf_c-gds-hist.chip-num =   next-value (s-gds-chip, {&db-name_schema})
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

        /*в новости пустим c-pl-gds тиз УБД в ГБД*/
        /*теперь пишем куст для c-pmp-hist*/
        create buf_c-pmp-hist.
        buffer-copy buf_c-pl-gds-pump
            except chip-num
            to buf_c-pmp-hist
            assign
            buf_c-pmp-hist.action = (if new new_pl-gds-pump then integer({&hn-create}) else integer({&hn-update}))
            buf_c-pmp-hist.chip-num = next-value (s-pmp-chip, {&db-name_schema})
            buf_c-pmp-hist.subject = {&table_pl-gds-pump}
            buf_c-pmp-hist.is-news = g#news
            buf_c-pmp-hist.gds-code = new_pl-gds-pump.gds-code
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
            input {&nwsdochs_action_update}
            , input {&table_pl-gds-pump}
            , input ( buffer ub.pl-gds-pump:handle )
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
/*    if new(buf_c-pl-gds-pump) then                                                                 */
/*    do:                                                                                            */
/*        run trg/userlog.p (                                                                        */
/*                input {&nwsdochs_action_update}                                                    */
/*                , input {&table_c-plc-hist}                                                        */
/*                , input ( buffer buf_c-plc-hist :handle )                                          */
/*                , input ?                                                                          */
/*                , input ""                                                                         */
/*                ) no-error.                                                                        */
/*            if error-status :error                                                                 */
/*                then                                                                               */
/*            do:                                                                                    */
/*                undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"*/
/*                    , {&new-line}                                                                  */
/*                    , vss-workfile                                                                 */
/*                    , return-value                                                                 */
/*                    , error-status :get-message ( 1 ) ).                                           */
/*            end.                                                                                   */
/*        run trg/userlog.p (                                                                        */
/*            input {&nwsdochs_action_create}                                                        */
/*            , input {&table_pl-gds-pump}                                                           */
/*            , input ( buffer buf_c-pl-gds-pump :handle )                                           */
/*            , input ?                                                                              */
/*            , input ""                                                                             */
/*            ) no-error.                                                                            */
/*        if error-status :error                                                                     */
/*            then                                                                                   */
/*        do:                                                                                        */
/*            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"    */
/*                , {&new-line}                                                                      */
/*                , vss-workfile                                                                     */
/*                , return-value                                                                     */
/*                , error-status :get-message ( 1 ) ).                                               */
/*        end.                                                                                       */
/*    end.                                                                                           */
/*    else                                                                                           */
/*    do:                                                                                            */
/*        run trg/userlog.p (                                                                        */
/*            input {&nwsdochs_action_update}                                                        */
/*            , input {&table_pl-gds-pump}                                                           */
/*            , input ( buffer buf_c-pl-gds-pump :handle )                                           */
/*            , input ?                                                                              */
/*            , input ""                                                                             */
/*            ) no-error.                                                                            */
/*        if error-status :error                                                                     */
/*            then                                                                                   */
/*        do:                                                                                        */
/*            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"    */
/*                , {&new-line}                                                                      */
/*                , vss-workfile                                                                     */
/*                , return-value                                                                     */
/*                , error-status :get-message ( 1 ) ).                                               */
/*        end.                                                                                       */
/*                                                                                                   */
/*    end.                                                                                           */
end. /* main-block */