block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prdocdel.p $
$Archive: utl/prdocdel.p $

Удаление незакрытых переоценок

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 12/27/01

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prdocdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prdocdel.p $":U .
define variable vss-description as character no-undo init "Удаление незакрытых переоценок".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

do
on error undo, return error return-value
:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
define buffer buf_c-price-doc  for ub.c-price-doc  .
define buffer buf_c-price-list for ub.c-price-list  .
define buffer buf_c-price-list-attr for ub.c-price-list-attr  .

  on delete of ub.price-doc override do: end.

  define stream slog .

  define variable v-doc-code as character no-undo .

  run gbl/d-prompt.w (
      'title=':u + "Введите номер переоценки" + '\':u
    + 'text1=':u + "Введите номер переоценки" + '\':u
    + 'text2=':u + "которую необходимо удалить" + '\':u
    + 'format=X(14)\':u
    ,input-output v-doc-code
    ).
  if return-value = 'false':u then do:
    return .
  end.

  define buffer buf_price-doc for ub.price-doc .
  find first buf_price-doc no-lock
    where buf_price-doc.doc-num = v-doc-code
    no-error .
  if not available buf_price-doc then do:
    message
      "Переоценка не найдена" skip
      "Переоценка" v-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if buf_price-doc.status_ = {&act-overvalue} then do:
    message
      "Удаление невозможно" skip
      "Переоценка закрыта до статуса" {&act-overvalue} skip
      "Переоценка" buf_price-doc.doc-num skip
      "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
      "Статус" buf_price-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.

  if buf_price-doc.status_ = {&permitted} then do:
    message
      "Переоценка находится в статусе" {&permitted} skip
      "Если товары на кассе заблокированы" skip
      "вам необходимо сделать повторную переоценку по всем товарам" skip
      "удаляемой переоценки" skip
      "Переоценка" buf_price-doc.doc-num skip
      "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
      "Статус" buf_price-doc.status_ skip
      view-as alert-box information .
  end.

  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = buf_price-doc.obj-type
      and buf_clients.obj-code = buf_price-doc.obj-code
    no-error .
  if available buf_clients
  and buf_clients.db-num <> 0 then do:
    message
      "Переоценка принадлежит удаленной базе данных" skip
      "Возможно переоценка уже была передана в офис" skip
      "Свящитесь с администратором ГБД и попросите его удалить данную переоценку в ГБД" skip
      "Переоценка" buf_price-doc.doc-num skip
      "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
      "Статус" buf_price-doc.status_ skip
      "База данных" buf_clients.db-num skip
      view-as alert-box information .
  end.

  define variable v-ok as logical   no-undo .
  assign
    v-ok = false
  .
  message
    "Удаление переоценки" skip
    "Переоценка" buf_price-doc.doc-num skip
    "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
    "Статус" buf_price-doc.status_ skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
    return .
  end.

  do transaction
  on error undo, return error
  :
    /* накладываем блокировку на все используемые товары */
    /* не обращаемся к стандартным бибилиотекам */
    /* так как утилита предназначена для удаления "плохих" товаров */
    define buffer buf_price-list for ub.price-list  .
    for each buf_price-list exclusive-lock
      where buf_price-list.doc-num = buf_price-doc.doc-num
    :
      define buffer buf_gds-obj for ub.gds-obj .
      find first buf_gds-obj exclusive-lock
        where buf_gds-obj.obj-type  = buf_price-list.obj-type
          and buf_gds-obj.obj-code  = buf_price-list.obj-code
          and buf_gds-obj.artic     = buf_price-list.artic
          and buf_gds-obj.prod-type = buf_price-list.prod-type
          and buf_gds-obj.prod-code = buf_price-list.prod-code
        no-error .
    end.

    /* блокируем переоценку */
    find current buf_price-doc exclusive-lock .

    output stream slog to value('prdocdel.txt':u) append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export stream slog string(v-today, '99/99/9999') string(v-time, 'HH:MM:SS') "delete price-doc" buf_price-doc.doc-num .
    export stream slog buf_price-doc .
    output stream slog close .

  /* записываем историю удаления записи */
   if buf_price-doc.status_ <> {&g___new} then do:
      create buf_c-price-doc.
      BUFFER-COPY buf_price-doc TO buf_c-price-doc
      assign
        buf_c-price-doc.chip-num           = next-value (s-corr-chip, {&db-name_schema})
        buf_c-price-doc.corr-time          = time
        buf_c-price-doc.corr-user-db-num   = g#db-num
        buf_c-price-doc.corr-man           = g#userid
        buf_c-price-doc.corr-date          = today
        buf_c-price-doc.is-del             = true
      .
   end.


    output stream slog to value('prdocdel.gds':u) .
    output stream slog close .

    /* удаляем строки переоценки */
    for each buf_price-list exclusive-lock
      where buf_price-list.doc-num = buf_price-doc.doc-num
    :

      output stream slog to value('prdocdel.txt':u) append .
      export stream slog buf_price-list .
      output stream slog close .

      output stream slog to value('prdocdel.gds':u) append .
      export stream slog buf_price-list.prod-type buf_price-list.prod-code buf_price-list.artic 0 .
      output stream slog close .

      /* если на товаре был установлен признак, что она заблокирован в переоценке */
      /* сбрасываем этот признак */
      if buf_price-doc.status_ = {&permitted} then do:
        find first buf_gds-obj exclusive-lock
          where buf_gds-obj.obj-type  = buf_price-list.obj-type
            and buf_gds-obj.obj-code  = buf_price-list.obj-code
            and buf_gds-obj.artic     = buf_price-list.artic
            and buf_gds-obj.prod-type = buf_price-list.prod-type
            and buf_gds-obj.prod-code = buf_price-list.prod-code
          no-error .
        if available buf_gds-obj
        and buf_gds-obj.ov-on = true then do:
          assign
            buf_gds-obj.ov-on = false
          .
        end.
      end.
    if buf_price-doc.status_ <> {&g___new} then do:
      create buf_c-price-list.
      BUFFER-COPY buf_price-list TO buf_c-price-list
      assign
        buf_c-price-list.chip-num           = buf_c-price-doc.chip-num
        buf_c-price-list.corr-time           = time
        buf_c-price-list.corr-user-db-num    = g#db-num
        buf_c-price-list.corr-user-name     = g#userid
        buf_c-price-list.corr-date          = today
        buf_c-price-list.is-del             = true
      .
     end.

      delete buf_price-list .
    end.

    delete buf_price-doc .

    output stream slog to value('prdocdel.txt':u) append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export stream slog string(v-today, '99/99/9999') string(v-time, 'HH:MM:SS') "finish delete price-doc" v-doc-code .
    output stream slog close .
  end.

  message
    "Переоценка успешно удалена" skip
    "Информация по удаленной переоценке выведена в файл" 'prdocdel.txt':u skip
    "Список товаров выведен в файл" 'prdocdel.gds':u skip
    view-as alert-box information .
end.