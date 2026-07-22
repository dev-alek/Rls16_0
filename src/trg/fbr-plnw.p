block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись документа план-меню

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.fbr-pln old buffer old-fbr-pln .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа план-меню".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

main-block:
do transaction
on error undo main-block, return error
:
    if ub.fbr-pln.creid = ""
    then do:        /* записываем того, кто создал документ производства */
        assign
            ub.fbr-pln.creid = g#userid
        .
    end.
    if not g#news
    then do:      /* обновляем пользователя, дату и время последнего обновления */
        { gbl/curdburt.i
            ub.fbr-pln.user-db-num
            ub.fbr-pln.user-name
            ub.fbr-pln.sys-date
            ub.fbr-pln.sys-time
            ub.fbr-pln.sys-time-int
        }
    end.
    if not g#news
    then do:        /* создаем историю изменений документа */
        run trg/fbr-plnh.p (
              buffer old-fbr-pln
            , buffer ub.fbr-pln
        ) no-error .
        if error-status:error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при создании истории изменений документа план-меню"
                skip "Документ" ub.fbr-pln.doc-code
            view-as alert-box .
            undo main-block, return error.
        end.
    end.
    if ub.fbr-pln.status_ = {&fact}
    then do:        /* закрытие документа по факту */
        if not g#news
        then do:        /* проверяем факт дату, время */
            run gbl/chk-date.p (
                  input ub.fbr-pln.obj-type
                , input ub.fbr-pln.obj-code
                , input ub.fbr-pln.fact-date
                , input 1
                , input ub.fbr-pln.shift-date
                , input ub.fbr-pln.shift-num
                , yes
            ) no-error.
            if error-status:error
            then do:
                message
                    "Ошибка при установке дат, времен, смен в документе план-меню (fbr-pln)."
                view-as alert-box error.
                undo main-block, return error.
            end.
        end.
        if old-fbr-pln.status_ <> ub.fbr-pln.status_
        then do:        /* передаем документ в новости */
            run str/callnews.p (
                  input "fbr-pln"
                , input (buffer  ub.fbr-pln :handle)
            ) no-error .
            if error-status:error
            then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при передаче документа план-меню в новости"
                    skip "Документ" ub.fbr-pln.doc-code
                view-as alert-box .
                undo main-block, return error.
            end.
        end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_fbr-pln}
        , input ( buffer ub.fbr-pln:handle )
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
END.