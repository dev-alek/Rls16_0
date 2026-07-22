block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории по доку МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-wth-doc old buffer old-c-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                          ,ub.c-wth-doc.doc-code
                          ,ub.c-wth-doc.ext-doc-type
                          ,ub.c-wth-doc.status_
                          ,ub.c-wth-doc.corr-user-db-num
                          ,ub.c-wth-doc.chip-num)" }
{ cmp/trg-def.i  }
define variable v-host-code like c-wth-doc.host-code no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first ub.clients no-lock
    where ub.clients.obj-type = ub.c-wth-doc.obj-type
      and ub.clients.obj-code = ub.c-wth-doc.obj-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Документ МЦ" ub.c-wth-doc.doc-code skip
      "Не найден объект" ub.c-wth-doc.obj-type ub.c-wth-doc.obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* проверять уникальность кода документа мы не будем так как его номер генериться не из общей послед*/

  /* проверяем, что фирма правильно заполнена */
  { gbl/hostcode.i
    ub.c-wth-doc.obj-type
    ub.c-wth-doc.obj-code
    v-host-code
    no-error
  }
  if error-status :error then do:
    message
     vss-workfile vss-revision vss-description skip
     "Ошика при определении кода фирмы для объекта" skip
     "Документ " ub.c-wth-doc.doc-code skip
     "obj-type" ub.c-wth-doc.obj-type skip
     "obj-code" ub.c-wth-doc.obj-code skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.c-wth-doc.host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Документ МЦ" ub.c-wth-doc.doc-code skip
      "Объект"  ub.c-wth-doc.obj-type ub.c-wth-doc.obj-code skip
      "Фирма"   ub.c-wth-doc.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if  not g#news
  and ub.c-wth-doc.corr-user-name = "" then do:
    assign
      ub.c-wth-doc.corr-user-name = g#userid
    .
  end.

  /* передача документа сверки через СПН (Система Передачи Новостей) */
  if not g#news
  and ub.c-wth-doc.is-del
  AND ub.c-wth-doc.status_ = {&fact}
  then do:
    run str/callnews.p
       (input {&table_c-wth-doc}
       ,input (buffer ub.c-wth-doc:handle)
       ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать c-wth-doc для отправки в новости" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-wth-doc}
        , input ( buffer ub.c-wth-doc:handle )
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
end.