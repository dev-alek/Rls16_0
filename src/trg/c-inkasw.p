block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории по продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/29/05
Author: Bakhtadze Natalya
Creation date: 11/29/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-inkas old buffer old-c-inkas .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории продажи".

{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.c-inkas.inkas-code,ub.c-inkas.chip-num,ub.c-inkas.status_)" }
{ cmp/trg-def.i  }
define variable v-host-code like c-inkas.host-code no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile ):

  find first ub.clients no-lock
    where ub.clients.obj-type = ub.c-inkas.obj-type
      and ub.clients.obj-code = ub.c-inkas.obj-code
    no-error .
  if not available ub.clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Продажа" ub.c-inkas.inkas-code skip
      "Не найден объект" ub.c-inkas.obj-type ub.c-inkas.obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  /* проверяем, что фирма правильно заполнена */
  { gbl/hostcode.i
    ub.c-inkas.obj-type
    ub.c-inkas.obj-code
    v-host-code
    no-error
  }
  if error-status :error then do:
    message
     vss-workfile vss-revision vss-description skip
     "Ошика при определении кода фирмы для объекта" skip
     "Продажа" ub.c-inkas.inkas-code skip
     "obj-type" ub.c-inkas.obj-type skip
     "obj-code" ub.c-inkas.obj-code skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.c-inkas.host-code <> v-host-code then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заполнено поле фирма" skip
      "Продажа" ub.c-inkas.inkas-code skip
      "Объект"  ub.c-inkas.obj-type ub.c-inkas.obj-code skip
      "Фирма"   ub.c-inkas.host-code skip
      "Должна быть фирма" v-host-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if  not g#news
  and ub.c-inkas.corr-user-name = "" then do:
    assign
      ub.c-inkas.corr-user-name = g#userid
    .
  end.

  /* передача документа сверки через СПН (Система Передачи Новостей) ТОЛЬКО УДАЛЕННЫХ ЗАКРЫТЫХ НА ФАКТ ПРОДАЖ*/
  if not g#news
  and ub.c-inkas.status_ = {&fact}
  then do:
    run str/callnews.p (
        input {&table_c-inkas}         /* t-name  */
       ,input (buffer ub.c-inkas:handle)
       ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать c-inkas для отправки в новости" skip
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
        , input {&table_c-inkas}
        , input ( buffer ub.c-inkas:handle )
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