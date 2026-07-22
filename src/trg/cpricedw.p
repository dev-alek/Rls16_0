block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории по документу переоценки

Автор: Чернова Светлана Александровна
Дата создания: 04/04/06
Author: Svetlana Chernova
Creation date: 04/04/06


*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-price-doc old buffer old-c-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа переоценки ".
{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.c-price-doc.doc-num,ub.c-price-doc.chip-num,ub.c-price-doc.status_) " }
{ cmp/trg-def.i  }

define variable v-host-code like c-price-doc.host-code no-undo.
MAIN-BLOCK :
do
on error   undo main-block, return error
on end-key undo main-block, return error
on stop    undo main-block, return error
:
  find first ub.clients no-lock
    where ub.clients.obj-type = ub.c-price-doc.obj-type
      and ub.clients.obj-code = ub.c-price-doc.obj-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Документ " ub.c-price-doc.doc-num skip
      "Не найден объект" ub.c-price-doc.obj-type ub.c-price-doc.obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

/*
  if ub.c-price-doc.status_ <> {&act-overvalue} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный статус документа " skip
      "Документ сверки" ub.c-price-doc.doc-num skip
      "Статус" ub.c-price-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  */

  /* проверяем, что фирма правильно заполнена */
  { gbl/hostcode.i
    ub.c-price-doc.obj-type
    ub.c-price-doc.obj-code
    v-host-code
    no-error
  }
  if error-status :error then do:
    message
     vss-workfile vss-revision vss-description skip
     "Ошика при определении кода фирмы для объекта" skip
     "Документ " ub.c-price-doc.doc-num skip
     "obj-type" ub.c-price-doc.obj-type skip
     "obj-code" ub.c-price-doc.obj-code skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.c-price-doc.host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Документ " ub.c-price-doc.doc-num skip
      "Объект"  ub.c-price-doc.obj-type ub.c-price-doc.obj-code skip
      "Фирма"   ub.c-price-doc.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if  not g#news
  and ub.c-price-doc.corr-man = "" then do:
    assign
      ub.c-price-doc.corr-man = g#userid
    .
  end.

  if  g#news  = false   then do:
    run str/callnews.p
      (input "c-price-doc"
      ,input (buffer ub.c-price-doc:handle)
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать c-price-doc для отправки в новости" skip
        "Документ " ub.c-price-doc.doc-num skip
        "chip-num " ub.c-price-doc.chip-num skip
        "Объект"  ub.c-price-doc.obj-type ub.c-price-doc.obj-code skip
        "Фирма"   ub.c-price-doc.host-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
 end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-price-doc}
        , input ( buffer ub.c-price-doc:handle )
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