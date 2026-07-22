block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи bar-code

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.bar-code .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи bar-code".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
/*ВНИМАНИЕ! при вызове с параметров p-action = {&hn-delete} надо отключать trigger на wrtie c-bar-code!!!*/
/* отменяем триггер для того чтобы не срабатывала проверка на наличие bar-code при записи c-bar-code */
on write of ub.c-bar-code override do: end.

define buffer buf_bar-code-attr for ub.bar-code-attr.
define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr.

{ trg/bar-codh.i trig ub.bar-code ub.bar-code }


define buffer buf_prod-bc for ub.prod-bc .


MAIN-BLOCK:
do
on error   undo main-block, return error
on end-key undo main-block, return error
:
  find first ub.prod-bc no-lock
    where ub.prod-bc.b-code = ub.bar-code.b-code
    no-error .
  if available ub.prod-bc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалить основной бар-код, для которого существуют дополнительные бар-коды" skip
      "Основной бар-код" ub.bar-code.b-code skip
      "Дополнительный бар-код" ub.prod-bc.b-str skip
      view-as alert-box error .
    undo, return error .
  end.

 run bar-codh_write-bar-code-trigger in this-procedure  (
                                       input no
                                      ,input integer({&hn-delete})
                                      ,input (if g#news
                                              then {&hn-source-db}
                                              else (if g#esys
                                                    then {&hn-source-esys}
                                                    else "":U)
                                              )
                                      ,input (if g#news
                                              then string(g#news-source-db)
                                              else (if g#esys
                                                    then string(g#esys-source-esys)
                                                    else "")
                                              )
                                    ) .


  /* отправляем команду на удаление в другие БД если это не two-commit*/
{ gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&goods-proc_dellcode}
      " buffer ub.bar-code:handle "
      ?
      ''
      ''
      no-error
      }
    if error-status:error
    then do:
      if not g#news then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры rum-runa.i" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo main-block,  return error return-value .
    end.
  if ub.bar-code.stts_ <> integer({&hn-delete}) then do:
    for each buf_bar-code-attr share-lock where
            buf_bar-code-attr.b-code = ub.bar-code.b-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_bar-code-attr.
    end.
    for each buf_bar-code-obj-attr share-lock where
            buf_bar-code-obj-attr.b-code = ub.bar-code.b-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_bar-code-obj-attr.
    end.
    run nws/cmd-del.p
      ( input {&table_bar-code}
       ,input (buffer ub.bar-code:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_bar-code}
        , input ( buffer ub.bar-code:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                            , {&new-line}
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
    end.
  end.
end.