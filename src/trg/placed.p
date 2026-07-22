block-level on error undo, throw.
/*

$Revision: 72f0e5104d0d, 1337, rls $
$Author: EShklyar $
$Date: Sat Apr 28 13:31:57 2018 +0300 $
$Workfile: placed.p $
$Archive: trg/placed.p $

Триггер на удаление place

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.place.

define variable vss-revision    as character no-undo initial "$Revision: 72f0e5104d0d, 1337, rls $":U.
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U.
define variable vss-date        as character no-undo initial "$Date: Sat Apr 28 13:31:57 2018 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: placed.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: trg/placed.p $":U.
define variable vss-description as character no-undo initial "Триггер на удаление place":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.place.obj-type
                         , ub.place.obj-code
                         , ub.place.pl-code
                         ) " }


{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable str1    as character no-undo.
define variable jj      as integer   no-undo.
DEFINE VARIABLE v-today as date      no-undo .
DEFINE VARIABLE v-time  as integer   no-undo .
define buffer buf_c-place    for ub.c-place.
define buffer buf_c-plc-hist for ub.c-plc-hist.

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    do on error   undo Main-Block, return error return-value
        on end-key undo Main-Block, return error return-value
        on stop    undo Main-Block, return error return-value :
        find first ub.pl-gds where
            ub.pl-gds.obj-type  =  ub.place.obj-type and
            ub.pl-gds.obj-code  =  ub.place.obj-code and
            ub.pl-gds.pl-code   =  ub.place.pl-code  and
            ( ub.pl-gds.fact-qnty <> 0                 or
            ub.pl-gds.free-qnty <> 0 )               no-error.
        if available ub.pl-gds then 
        do:
            message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
                "На месте хранения имеется товар!" skip
                "Удаление невозможно!" skip
                "Объект" ub.place.obj-type ub.place.obj-code skip
                "Код места хранения" ub.place.pl-code skip
                "Внутренний код товара" ub.pl-gds.gds-code skip
                view-as alert-box error.
            undo Main-Block, return error.
        end.
        for each ub.pl-gds where
            ub.pl-gds.pl-code  = ub.place.pl-code  and
            ub.pl-gds.obj-type = ub.place.obj-type and
            ub.pl-gds.obj-code = ub.place.obj-code
            on error   undo Main-Block, return error
            on end-key undo Main-Block, return error
            on stop    undo Main-Block, return error :
            delete ub.pl-gds.
        end.

        for each ub.pl-pump where
            ub.pl-pump.pl-code  = ub.place.pl-code  and
            ub.pl-pump.obj-type = ub.place.obj-type and
            ub.pl-pump.obj-code = ub.place.obj-code
            on error   undo Main-Block, return error
            on end-key undo Main-Block, return error
            on stop    undo Main-Block, return error :
            delete ub.pl-pump.
        end.

        if not g#news then 
        do:
            run nws/cmd-del.p ( input {&table_place}
                , input ( buffer ub.place :handle )
                , input "":U ) no-error.
            if error-status :error then 
            do:
                assign 
                    str1 = {&new-line}.
                do jj = 1 to error-status :num-messages :
                    assign 
                        str1 = str1 + {&new-line} + error-status :get-message ( jj ).
                end.
                undo Main-Block, return error
                    substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4",
                    vss-workfile, {&new-line}, return-value, str1 ).
            end.
        end.
    end.
    if not g#news then 
    do:
        run cur-time in this-procedure(output v-today, output v-time).
        create buf_c-place.
        buffer-copy ub.place to buf_c-place.
        assign
            buf_c-place.chip-num         = next-value (s-plc-chip, {&db-name_schema})
            buf_c-place.corr-time        = v-time
            buf_c-place.corr-user-db-num = g#db-num
            buf_c-place.corr-user-name   = g#userid
            buf_c-place.corr-date        = v-today
            .
        create buf_c-plc-hist.
        buffer-copy buf_c-place to buf_c-plc-hist
            assign
            buf_c-plc-hist.action =  integer({&hn-delete})
            buf_c-plc-hist.subject = {&table_place}
            buf_c-plc-hist.is-news = g#news
            buf_c-plc-hist.gds-code = ?
            .
    end.

    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_c-place}
        , input ( buffer buf_c-place :handle )
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

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_place}
            , input ( buffer ub.place:handle )
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

   { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
    {&thref-proc_ref-event}
    " buffer ub.place:handle "
    ''
    ''
    ''
    no-error
  }
    if error-status :error
        then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.  
  
define buffer buf_place-attr for ub.place-attr .
for each buf_place-attr exclusive-lock where
            buf_place-attr.pl-code  = ub.place.pl-code  and
            buf_place-attr.obj-type = ub.place.obj-type and
            buf_place-attr.obj-code = ub.place.obj-code:
            delete buf_place-attr.  
end.

end. /* Main-Block */