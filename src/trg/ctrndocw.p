block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории по документу

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-trn-doc old buffer old-c-doc .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на запись документа":U .

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|5',ub.c-trn-doc.doc-code,ub.c-trn-doc.chip-num,ub.c-trn-doc.ext-doc-type,ub.c-trn-doc.status_,ub.c-trn-doc.flag_)" }
{ cmp/trg-def.i  }

define variable v-host-code like c-trn-doc.host-code no-undo.

MAIN-BLOCK :
do
on error   undo main-block, return error
on end-key undo main-block, return error
on stop    undo main-block, return error
:
  find first ub.clients no-lock where
             ub.clients.obj-type = ub.c-trn-doc.obj-type and
             ub.clients.obj-code = ub.c-trn-doc.obj-code no-error .
  if not available ub.clients then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильная ссылка на объект" skip
            "Документ " ub.c-trn-doc.doc-code skip
            "Не найден объект" ub.c-trn-doc.obj-type ub.c-trn-doc.obj-code skip
    view-as alert-box error .
    undo main-block, return error .
  end.

  /* проверяем уникальность кода документа */
  run trg/chkchpnm.p ( input ub.c-trn-doc.doc-code /* p-doc-code   */
                 , input ub.c-trn-doc.chip-num /* p-chip-num   */
                 , input "c-trn-doc":U         /* p-table-name */
                 , input recid( ub.c-trn-doc ) /* p-recid      */
                 ) no-error .
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка при проверке уникальности кода документа" skip
            "Документ " ub.c-trn-doc.doc-code skip
            error-status :get-message( 1 ) skip
            return-value skip
    view-as alert-box error .
    undo main-block, return error .
  end.

  /* if ub.c-trn-doc.status_ <> {&fact} then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильный статус документа " skip
            "Документ сверки" ub.c-trn-doc.doc-code skip
            "Статус" ub.c-trn-doc.status_ skip
    view-as alert-box error .
    undo main-block, return error .
  end. */

  /* проверяем, что фирма правильно заполнена */
  { gbl/hostcode.i ub.c-trn-doc.obj-type
               ub.c-trn-doc.obj-code
               v-host-code           no-error }
  if error-status :error then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошика при определении кода фирмы для объекта" skip
            "Документ " ub.c-trn-doc.doc-code skip
            "obj-type"  ub.c-trn-doc.obj-type skip
            "obj-code"  ub.c-trn-doc.obj-code skip
            error-status :get-message( 1 ) skip
            return-value skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  if ub.c-trn-doc.host-code <> v-host-code then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неправильно заполнено поле фирма" skip
            "Документ " ub.c-trn-doc.doc-code skip
            "Объект"    ub.c-trn-doc.obj-type ub.c-trn-doc.obj-code skip
            "Фирма"     ub.c-trn-doc.host-code skip
            "Должна быть фирма" v-host-code skip
    view-as alert-box error .
    undo main-block, return error .
  end.

  if g#news <> yes then do:
    if ub.c-trn-doc.corr-user-name = "":U then do:
      assign
        ub.c-trn-doc.corr-user-name = g#userid
      .
    end.

    /* передача документа сверки через СПН (Система Передачи Новостей) */
    run str/callnews.p ( input "c-trn-doc"
                   , input ( buffer ub.c-trn-doc :handle )
                   ) no-error .
    if error-status :error then do:
      message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
              "Невозможно маршрутизировать c-trn-doc для отправки в новости" skip
              error-status :get-message( 1 ) skip
              return-value skip
      view-as alert-box error .
      undo, return error .
    end.
  end. /* if not g#news */
    if g#oxml = true
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-trn-doc}
        , input ( buffer ub.c-trn-doc:handle )
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