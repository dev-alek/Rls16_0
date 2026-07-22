block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление переоценки

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.price-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление переоценки".
{ cmp/vssrevis.i "substitute('&1|&2',ub.price-doc.doc-num,ub.price-doc.status_)" }
{ cmp/trg-def.i }

define buffer buf_c-price-doc  for ub.c-price-doc  .
define buffer buf_c-price-list for ub.c-price-list  .
define buffer buf_c-price-list-attr for ub.c-price-list-attr  .
define buffer buf_c-doc-attr for ub.c-doc-attr .

define variable v-is-erpRN    as logical no-undo .
define variable par-is-erpRN  as character no-undo .
define variable par-type      as character no-undo .

main-block :
do transaction
on error undo main-block, return error
:

  { gbl/conf-rd.i "'is-erpRN'"   "''" "''" 0 "''" "''" "''"  no par-is-erpRN     par-type      no-error}

  v-is-erpRN = lookup(par-is-erpRN, "true,yes":U) > 0.

  /* Проверяем статус документа, в котором мы можем удалять переоценку */
  if ub.price-doc.status_ = {&act-overvalue}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении документа переоценки" skip
      "Нельзя удалять переоценку, находящуюся в статусе" {&act-overvalue} skip
      "Документ переоценки" ub.price-doc.doc-num skip
      "Статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  /* в статусе {&order} можно удалять переоценки, */
  /* которые принадлежат объектам и магазинам главной БД */
  /* в статусе {&permitted} можно удалять переценки на только на объектах  */
  /* (для магазинов удалять нельзя) */
  /* в УБД можно удалять только переоценки в статусе {&g___new} */
  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = ub.price-doc.obj-type
      and buf_clients.obj-code = ub.price-doc.obj-code
    no-error .
  if not available buf_clients then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден объект" skip
      "Переоценка" ub.price-doc.doc-num skip
      "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if g#news
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Удаление переоценки в новостях невозможно" skip
      "Переоцека" ub.price-doc.doc-num skip
      "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
      "Статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.

  /* переоценка удаляется на объекте, принадлежащем УБД */
  if buf_clients.db-num <> 0
  and not v-is-erpRN
  and ub.price-doc.status_ <> {&g___new} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Удаление переоценки УБД возвможно только в статусе" {&g___new} skip
      "Переоцека" ub.price-doc.doc-num skip
      "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
      "Статус" ub.price-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.

  if ub.price-doc.status_ = {&permitted} then do:
    if ub.price-doc.obj-type = {&shop} then do:
      message
        vss-workfile vss-revision vss-description skip
        "Для магазина запрещено удаление переоценок в статусе" ub.price-doc.status_ skip
        "Переоцека" ub.price-doc.doc-num skip
        "Объект" ub.price-doc.obj-type ub.price-doc.obj-code skip
        "Статус" ub.price-doc.status_ skip
        view-as alert-box error .
      undo, return error . /* --->>>--- */
    end.

    /* для склада возможно удаление переоценок в статусе {&permitted} */
    /* в этом случае необходимо снять блокировки на товаре */
    for each ub.price-list
      where ub.price-list.doc-num = ub.price-doc.doc-num
    on error undo, return error
    break
    by ub.price-list.artic
    by ub.price-list.prod-type
    by ub.price-list.prod-code
    :
      if last-of(ub.price-list.prod-code) then do:
        /* снятие блокировки с товара */
        define variable l-ov-on as logical no-undo .
        { gbl/gdsobjat.i
          ub.price-list.obj-type
          ub.price-list.obj-code
          ub.price-list.artic
          ub.price-list.prod-type
          ub.price-list.prod-code
          "'ov-on=false'"
          l-ov-on
          no-error
        }
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка задания признака товара на объекте" skip
            "Переоценка" ub.price-list.doc-num skip
            "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
            "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
            "action" "ov-on=false" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.

  /* записываем историю удаления записи */
   if ub.price-doc.status_ <> {&g___new} then do:
      create buf_c-price-doc.
      BUFFER-COPY ub.price-doc TO buf_c-price-doc
      assign
        buf_c-price-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
        buf_c-price-doc.corr-time          = time
        buf_c-price-doc.corr-user-db-num   = g#db-num
        buf_c-price-doc.corr-man           = g#userid
        buf_c-price-doc.corr-date          = today
        buf_c-price-doc.is-del             = true
      .
   end.

  /* удаление всех строк переоценки */
  for each ub.price-list exclusive-lock
    where ub.price-list.doc-num = ub.price-doc.doc-num
  on error undo main-block, return error
  :
    if ub.price-doc.status_ <> {&g___new} then do:
      create buf_c-price-list.
      BUFFER-COPY ub.price-list TO buf_c-price-list
      assign
        buf_c-price-list.chip-num           = buf_c-price-doc.chip-num
        buf_c-price-list.corr-time           = time
        buf_c-price-list.corr-user-db-num    = g#db-num
        buf_c-price-list.corr-user-name     = g#userid
        buf_c-price-list.corr-date          = today
        buf_c-price-list.is-del             = true
      .
     end.
    delete ub.price-list .
  end.
  for each ub.doc-attr where ub.doc-attr.doc-code = ub.price-doc.doc-num
    on error undo main-block, return error
    :
    if ub.price-doc.status_ <> {&g___new} then do:
      create buf_c-doc-attr.
      BUFFER-COPY ub.doc-attr TO buf_c-doc-attr
      assign
        buf_c-doc-attr.chip-num           = buf_c-price-doc.chip-num
        buf_c-doc-attr.corr-time           = time
        buf_c-doc-attr.corr-user-db-num    = g#db-num
        buf_c-doc-attr.corr-user-name     = g#userid
        buf_c-doc-attr.corr-date          = today
      .
    end.
    delete ub.doc-attr.
  end.
  for each ub.price-list-attr where ub.price-list-attr.doc-num = ub.price-doc.doc-num
    on error undo main-block, return error
    :
    if ub.price-doc.status_ <> {&g___new} then do:
      create buf_c-price-list-attr.
      BUFFER-COPY ub.price-list-attr TO buf_c-price-list-attr
      assign
        buf_c-price-list-attr.chip-num           = buf_c-price-doc.chip-num
        buf_c-price-list-attr.corr-time           = time
        buf_c-price-list-attr.corr-user-db-num    = g#db-num
        buf_c-price-list-attr.corr-user-name     = g#userid
        buf_c-price-list-attr.corr-date          = today
        buf_c-price-list-attr.is-del             = true
      .
    end.
    delete ub.price-list-attr.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_price-doc}
        , input ( buffer ub.price-doc:handle )
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
  if ub.price-doc.PS <> "temp"
  then do :   
      { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
          {&edoc-proc_event_price-doc}
        " buffer ub.price-doc:handle "
        ?
        ''
        ''
        no-error
        }
      if error-status:error
      then do:
        define variable v-message as character no-undo .
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
  end.
end.