block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись документа производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fbr-doc old buffer old-fbr-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-message as character no-undo .

main-block:
do transaction
on error undo main-block, return error
:
    /* записываем того, кто создал документ производства */
    if ub.fbr-doc.creid = "" then do:
        assign
        ub.fbr-doc.creid = g#userid
        .
    end.

    /* обновляем пользователя, дату и время последнего обновления */
    if not g#news
    then do:
        { gbl/curdburt.i
        ub.fbr-doc.user-db-num
        ub.fbr-doc.user-name
        ub.fbr-doc.sys-date
        ub.fbr-doc.sys-time
        ub.fbr-doc.sys-time-int
        }
    end.

    /* создаем историю изменений документа */
    if not g#news
    then do:
        run trg/fbrdoch.p (
          buffer old-fbr-doc
        , buffer ub.fbr-doc
        ) no-error .
        if error-status:error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании истории изменений документа производства" skip
                "Документ" ub.fbr-doc.doc-code skip
                view-as alert-box .
            undo main-block, return error.
        end.
    end.

    /* закрытие документа по факту */
    if ub.fbr-doc.status_ = {&fact} then do:
        if not g#news then do:
        /* проверяем факт дату, время */
        run gbl/chk-date.p
            (input ub.fbr-doc.obj-type
            ,input ub.fbr-doc.obj-code
            ,input ub.fbr-doc.fact-date
            ,input 1
            ,input ub.fbr-doc.shift-date
            ,input ub.fbr-doc.shift-num
            ,yes) no-error.
        if error-status:error then do:
            message "Ошибка при установке дат, времен, смен в документе производства(fbr-doc)."
            view-as alert-box.
            undo main-block, return error.
        end.
        end.

        /* передаем документ в новости */
        if old-fbr-doc.status_ <> ub.fbr-doc.status_
        then do:
            run str/callnews.p
            (input "fbr-doc"
            ,input (buffer ub.fbr-doc:handle)
            ) no-error .
            if error-status:error then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при передаче документа производства в новости" skip
                "Документ" ub.fbr-doc.doc-code skip
                view-as alert-box .
            undo main-block, return error.
            end.
        end.
    end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-doc}
        , input ( buffer ub.fbr-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
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
      {&edoc-proc_event_fbr-doc}
      " buffer old-fbr-doc:handle "
      " buffer ub.fbr-doc:handle "
      ''
      ''
      no-error
    }
    if error-status:error
    then do:
      v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
      if not g#news then do:
        message
        v-message
        view-as alert-box error .
      end.
      undo main-block,  return error v-message.
    end.

    
END.