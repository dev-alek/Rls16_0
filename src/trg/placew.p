block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись place

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR WRITE OF ub.place OLD oldplace.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись place".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.place.obj-type
                         , ub.place.obj-code
                         , ub.place.pl-code
                         ) " }

{ cmp/trg-def.i  }
{ trg/new-bcod.i  }

define variable v-db-num as integer no-undo .

main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

    if g#news then 
    do:
        assign
            v-db-num = g#news-source-db
            .
    end.
    else 
    do:
        assign
            v-db-num = g#db-num
            .
    end.

    if new(ub.place) then 
    do:
       
       define variable conf-par as character no-undo.
       define variable par-type as character no-undo.
       { gbl/conf-rd.i
             "'is-erpRN'"
             0
             "''"
             0
             "''"
             "''"
             "''"
             NO
             conf-par
             par-type
             no-error
         }
         IF not error-status:error and conf-par = "yes":U 
         then do: 
         end.
         else do:
        /* только для новых записей надо искать диапазон
         старые и так там находятся */
        run gen-new-code-range-if-neces in this-procedure (
            input v-db-num
            ,input {&gbl-bc-code}
            ,input ub.place.pl-code
            ,input g#news
            ,input g#db-num
            ,input g#news-source-db
            ) no-error .
        if error-status:error then 
        do:
            message
                vss-workfile vss-revision vss-description skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error .
            undo main-block,  return error .
        end.
        end.
        run trg/userlog.p (
            input {&nwsdochs_action_create}
            , input {&table_place}
            , input ( buffer ub.place :handle )
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
            , input {&table_place}
            , input ( buffer ub.place :handle )
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
    run str/callnews.p
        ( input {&table_place}
        ,input (buffer ub.place:handle)
        ) .

    if not g#news then 
    do:
        run trg/placeh.p ( buffer oldplace, buffer ub.place ).
    end.
    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_update}
            , input {&table_place}
            , input ( buffer ub.place:handle )
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
end.