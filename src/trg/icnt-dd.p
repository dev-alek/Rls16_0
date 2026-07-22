block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление документа счетчиков ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.icnt-doc.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление документа счетчиков ТРК ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:



  /* Проверяем статус документа, в котором мы можем удалять документ */
  if not g#news
  then do:
    if ub.icnt-doc.status_ <> {&g___new} then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка удаления документа счетчиков ТРК" skip
        "Документ может быть удален только в статусе новый" skip
        "Документ " ub.icnt-doc.doc-code skip
        "Статус" ub.icnt-doc.status_ skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end.

  /* Документы сверки, закрытые до статуса {&fact} удалять нельзя */
  if ub.icnt-doc.status_ = {&fact} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка удаления документа счетчиков ТРК" skip
      "Документ не может быть удален в статусе" {&fact} skip
      "Документ " ub.icnt-doc.doc-code skip
      "Статус" ub.icnt-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  /* удаляем связанные таблицы */
  for each ub.icnt-line exclusive-lock
    where ub.icnt-line.doc-code = ub.icnt-doc.doc-code
  on error undo main-block, return error
  :
    delete ub.icnt-line .
  end.



  /* удаляем таблицу маршрутизации */
  for each ub.doc-attr where ub.doc-attr.doc-code = ub.icnt-doc.doc-code
    on error undo main-block, return error
    :
    delete ub.doc-attr.
  end.

  /* посылаем команду на удаление документа сверки */
  run nws/cmd-del.p
    ( input {&table_icnt-doc}
     ,input (buffer ub.icnt-doc:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_icnt-doc}
        , input ( buffer ub.icnt-doc:handle )
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
  
  if ub.icnt-doc.status_ = {&fact} then do:
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
      {&edoc-proc_event_icnt-doc}
      " buffer ub.icnt-doc:handle "
      ''
      ''
      ''
      no-error
    }
    if error-status :error
    then
    do:
        return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
            , {&new-line}
            , vss-workfile
            , return-value
            , error-status :get-message ( 1 ) ).
    end.
  end .
  
end.