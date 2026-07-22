block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF UB.ORD-DOC .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление заказа".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block :
do transaction
    on error undo main-block, return error
    :

    define variable v-message as character no-undo .
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      " (if ub.ord-doc.doc-type = {&o-r} then {&edoc-proc_event_intorder} else {&edoc-proc_event_order}) "
      " buffer ub.ord-doc:handle "
      ?
      ''
      ''
      no-error
      }
    if error-status:error
        then 
    do:
        v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
            ,vss-workfile
            ,vss-revision
            ,vss-description
            ,{&new-line}
            , error-status:get-message(1)
            , return-value ).
        if not g#news then 
        do:
            message
                v-message
                view-as alert-box error .
        end.
        undo main-block,  return error v-message.
    end.


    /* удаление всех строк документа */
    for each ub.ord-line
        where ub.ord-line.doc-code = ub.ORD-doc.doc-code
        on error undo main-block, return error
        :
        delete ub.ord-line .
    end.


    /* атрибуты заказов */
    for each ub.ord-doc-attr
        where ub.ord-doc-attr.doc-code = ub.ord-doc.doc-code
        on error undo main-block, return error
        :
        delete ub.ord-doc-attr .
    end.


    /* удаление всех строк внешних поставок  */
    for each ub.ord-doc-rcv
        where ub.ord-doc-rcv.doc-code = ub.ord-doc.doc-code
        and ub.ord-doc-rcv.doc-type = "out":U
        and ub.ord-doc-rcv.status_  = {&g___new}
        on error undo main-block, return error
        :
        delete ub.ord-doc-rcv .
    end.
  
    run trg/userlog.p (
        input {&nwsdochs_action_delete}
        , input {&table_ord-doc}
        , input ( buffer ub.ord-doc :handle )
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
  
    if ub.ord-doc.status_ = {&ord-req} then 
    do:
        run nws/cmd-del.p
            ( input "ord-doc":U
            ,input (buffer ub.ord-doc:handle)
            ,input "":U
            ) no-error .
        if error-status :error then 
        do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
    end.

    if g#oxml = yes
        then 
    do:
        run str/calloxml.p (
            input {&nwsdochs_action_delete}
            , input {&table_ORD-DOC}
            , input ( buffer ub.ORD-DOC:handle )
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
end.