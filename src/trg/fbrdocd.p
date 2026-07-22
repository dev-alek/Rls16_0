block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи документ производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.fbr-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи документ производства".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/fbrcode.i  }

define variable v-message as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if ub.fbr-doc.status_ = {&fact}
  and not g#news
  then do:
    if ub.fbr-doc.is-del = no
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять документ, закрытый до статуса" {&fact} skip
      "Документ        " ub.fbr-doc.doc-code skip
      "Статус документа" ub.fbr-doc.status_ skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    else do:
      run check-fact-trn-doc in this-procedure (
          input {&income}
      ) no-error.
      if error-status :error
      then do:
        undo main-block, return error .
      end.
      run check-fact-trn-doc in this-procedure (
          input {&expense}
      ) no-error.
      if error-status :error
      then do:
        undo main-block, return error .
      end.
      run check-fact-trn-doc in this-procedure (
          input {&write-off}
      ) no-error.
      if error-status :error
      then do:
        undo main-block, return error .
      end.
      run trg/userlog.p (
                          input {&nwsdochs_action_delete}
                        , input {&table_fbr-doc}
                        , input ( buffer ub.fbr-doc :handle )
                        , input ?
                        , input ""
                    ) no-error.
                    if error-status :error
                    then do:
                        undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                                            , {&new-line}
                                            , vss-workfile
                                            , return-value
                                            , error-status :get-message ( 1 ) ).
                    end.
    end.
  end.

  { gbl/rum-runa.i
    ?
    this-procedure:handle
    ?
      {&edoc-proc_event_fbr-doc}
    " buffer ub.fbr-doc:handle "
    ?
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
      if not g#news
      and not g#auto
      and not g#esys
      then do:
      message
      v-message
      view-as alert-box error .
    end.
    undo main-block,  return error v-message.
  end.

  /* проверяем, что не осталось подчиненных линий */
  if g#news then do:
    for each ub.fbr-line share-lock where
            ub.fbr-line.doc-code = ub.fbr-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete ub.fbr-line.
    end.
    for each ub.fbr-recipe share-lock where
            ub.fbr-recipe.doc-code = ub.fbr-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete ub.fbr-recipe.
    end.
    for each ub.fbr-recipe-gds share-lock where
            ub.fbr-recipe-gds.doc-code = ub.fbr-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete ub.fbr-recipe-gds.
    end.
  end.
  else do:
    find first ub.fbr-line no-lock
      where ub.fbr-line.doc-code = ub.fbr-doc.doc-code
      no-error .
    if available ub.fbr-line then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при удалении документа производства" skip
        "Найдена строка документа производства" skip
        "Документ"    ub.fbr-line.doc-code    skip
        "trn-type"    ub.fbr-line.trn-type    skip
        "recipe-code" ub.fbr-line.recipe-code skip
        "artic"       ub.fbr-line.artic       skip
        "prod-type"   ub.fbr-line.prod-type   skip
        "prod-code"   ub.fbr-line.prod-code   skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  find first ub.fbr-recipe no-lock
    where ub.fbr-recipe.doc-code = ub.fbr-doc.doc-code
    no-error .
  if available ub.fbr-recipe then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при удалении документа производства" skip
    "Найден рецепт документа производства"       skip
    "Документ"       ub.fbr-recipe.doc-code      skip
    "recipe-code"    ub.fbr-recipe.recipe-code   skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first ub.fbr-recipe-gds no-lock
    where ub.fbr-recipe-gds.doc-code = ub.fbr-doc.doc-code
    no-error .
  if available ub.fbr-recipe-gds then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при удалении документа производства" skip
    "Найдена строка рецепта документа производства" skip
    "Документ"    ub.fbr-line.doc-code    skip
    "recipe-code" ub.fbr-recipe-gds.recipe-code skip
    "artic"       ub.fbr-recipe-gds.artic       skip
    "prod-type"   ub.fbr-recipe-gds.prod-type   skip
    "prod-code"   ub.fbr-recipe-gds.prod-code   skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_fbr-doc}
        , input ( buffer ub.fbr-doc:handle )
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
  run nws/cmd-del.p
    ( input {&table_fbr-doc}
     ,input (buffer ub.fbr-doc:handle)
     ,input ''
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

end.

/*==========================================================================*/
procedure check-fact-trn-doc :
define input parameter p-doc-type as character    no-undo.

define variable v-doc-code          like trn-doc.doc-code       no-undo.
define buffer buf_trn-doc       for trn-doc.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run fbrcode-trn-doc in this-procedure (
        input {&manufacturing}
      , input ub.fbr-doc.doc-code
      , input p-doc-type
      , output v-doc-code
  ).
  find first buf_trn-doc
        where buf_trn-doc.doc-code = v-doc-code
  no-error.
  if available buf_trn-doc
  then do:
    message
    vss-workfile vss-revision vss-description
    skip "Нельзя удалять документ производства, закрытый до статуса" {&fact}
    skip "Номер документа " ub.fbr-doc.doc-code
    skip "Статус документа" ub.fbr-doc.status_
    skip (1) "Есть связанный складской документ:"
    skip "Тип документа  " buf_trn-doc.doc-type
    skip "Номер документа" buf_trn-doc.doc-code
    view-as alert-box error .
    undo main-block, return error .
  end.
end.
end procedure. /* check-fact-trn-doc */