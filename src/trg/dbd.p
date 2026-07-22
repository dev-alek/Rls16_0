block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи базы данных

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/03
Author: Dmitry Ukhanov
Creation date: 03/22/03

*/

trigger procedure for delete of ub.db .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи базы данных".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/trg-def.i  }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_db                for ub.db .
  define buffer buf_c-db              for ub.c-db .
  define buffer buf_sys-ctrl          for ub.sys-ctrl .
  define buffer buf-shop_clients      for ub.clients .
  define buffer buf-store_clients     for ub.clients .
  define buffer buf_cash-desk         for ub.cash-desk .
  define buffer buf_code-range        for ub.code-range .
  define buffer buf_schedule          for ub.schedule .
  define buffer buf_schedule-attr     for ub.schedule-attr .
  define buffer buf_prod-bc-db        for ub.prod-bc-db .
  define buffer buf_ext-file          for ub.ext-file .
  define buffer buf_ext-file-line     for ub.ext-file-line .
  define buffer buf_ext-file-par      for ub.ext-file-par .
  define buffer buf_db-rec-attr       for ub.db-rec-attr .
  define buffer buf_nws-doc-hist      for ub.nws-doc-hist .
  define buffer buf_pck-sent          for ub.pck-sent .
  define buffer buf_pck-rcvd          for ub.pck-rcvd .
  define buffer buf_route             for ub.route .
  define buffer buf_db-status         for ub.db-status .
  define buffer buf_upgrade           for ub.upgrade .
  define buffer buf_db-attr           for ub.db-attr .
  define buffer buf_hist-nws-option   for ub.hist-nws-option.
  define buffer buf_c-hist-nws-option for ub.c-hist-nws-option.

  define variable v-date    as date      no-undo .
  define variable v-time    as integer   no-undo .
  define variable v-db-num  as integer   no-undo .
  define variable v-msg     as logical   no-undo .
  define variable v-message as character no-undo .
  define variable v-db-list as character no-undo .

  define temp-table tt_range-stts no-undo
    field range-type like ub.code-range.range-type
    field first-code like ub.code-range.first-code
    field stts       like ub.code-range.stts
  .

  define variable v-action  as character no-undo .
  define variable v-counter as integer   no-undo .
  define variable v-mod     as integer   no-undo .
  define frame inf
    v-action  label "Таблица" format "X(50)" skip
    v-counter label "Записей" format ">>>>>>>>>9"
    with view-as dialog-box side-labels 1 columns three-d title "Удаление БД".

  &scop view-process assign v-counter = v-counter + 1 .~
    if ( v-counter MODULO v-mod ) = 0 then do: ~
      do with frame inf ~
      : ~
        assign ~
          v-action :screen-value  = string( v-action, v-action :format) ~
          v-counter :screen-value = string( v-counter, v-counter :format) ~
        . ~
      end. ~
    end.

  find first buf_sys-ctrl no-lock .

  assign
    v-db-num = ub.db.db-num
  .

  if g#news = false then do:
    assign
      v-msg = true
    .

    if buf_sys-ctrl.db-num <> 0 then do:
      assign
        v-message = "Удаление БД может проводиться только в ГБД!!!"
      .
      if v-msg = true then do:
        message
          v-message
          view-as alert-box error.
      end.
      return error v-message .
    end.
  end.

  /* Удаляемая БД не должна быть главной */
  if v-db-num = 0 then do:
    assign
      v-message = "Нельзя удалить ГБД !!!"
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error.
    end.
    return error v-message .
  end.

  /* В удаляемой БД не должно быть объектов. */
  find first buf-shop_clients no-lock
    where buf-shop_clients.db-num   = v-db-num
      and buf-shop_clients.obj-type = {&shop}
    no-error
  .
  find first buf-store_clients no-lock
    where buf-store_clients.db-num   = v-db-num
      and buf-store_clients.obj-type = {&stock}
    no-error
  .
  if available buf-shop_clients
    or available buf-store_clients
  then do:
    assign
      v-message = substitute( "Есть объекты привязаные к БД &1. &2Нельзя удалить БД.", v-db-num, {&new-line} )
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error .
    end.
    return error v-message .
  end.

  /* К удаляемой БД не должно быть привязано касс (cash-desk). */
  find first buf_cash-desk no-lock
    where buf_cash-desk.db-num = v-db-num
    no-error .
  if available buf_cash-desk then do:
    assign
      v-message = substitute( "Есть кассы привязаные к БД &1. &2Нельзя удалить БД.", v-db-num, {&new-line} )
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error .
    end.
    return error v-message .
  end.

  view frame inf .

  assign
    v-counter = 0
    v-action  = "Создание записи истории"
    v-mod     = 5
  .
  run cur-time in this-procedure
    ( output v-date
    , output v-time
    ).
  create buf_c-db.
  buffer-copy ub.db to buf_c-db .
  assign
    buf_c-db.action           = integer({&hn-delete})
    buf_c-db.chip-num         = dynamic-next-value ( "s-db-chip", "{&db-name_schema}")
    buf_c-db.corr-time        = v-time
    buf_c-db.corr-date        = v-date
    buf_c-db.corr-user-db-num = buf_sys-ctrl.db-num
    buf_c-db.corr-user-name   = (if g#news = true then "СПН" else g#userid )
  .
  if trim( buf_c-db.corr-user-name ) = "":U then do:
    assign
      buf_c-db.corr-user-name = userid( "ub":U )
    .
  end.

  assign
    v-counter = 0
    v-action  = "Перепривязка диапазонов кодов"
    v-mod     = 5
  .
  for each tt_range-stts
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    delete tt_range-stts .
  end.
  for each buf_code-range exclusive-lock
    where buf_code-range.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    create tt_range-stts.
    assign
      tt_range-stts.range-type = buf_code-range.range-type
      tt_range-stts.first-code = buf_code-range.first-code
      tt_range-stts.stts       = buf_code-range.stts
      buf_code-range.stts      = "X->0":U
      buf_code-range.db-num    = 0
    .
  end.
  for each tt_range-stts
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    find first buf_code-range exclusive-lock
      where buf_code-range.range-type = tt_range-stts.range-type
        and buf_code-range.first-code = tt_range-stts.first-code
    .

    if tt_range-stts.stts = "a":U then do:
      assign
        tt_range-stts.stts = "u":U
      .
    end.
    assign
      buf_code-range.stts = tt_range-stts.stts
    .
  end.
  for each tt_range-stts
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    delete tt_range-stts .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление строк расписания"
    v-mod     = 1
  .
  /* Удаляем schedule и schedule-attr (расписание) по удаляемой БД.*/
  for each buf_schedule exclusive-lock
    where buf_schedule.cre-db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_schedule .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление строк атрибутов расписания"
    v-mod     = 1
  .
  for each buf_schedule-attr exclusive-lock
    where buf_schedule-attr.cre-db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_schedule-attr .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление бар-кодов по базе данных"
    v-mod     = 5
  .
  for each buf_prod-bc-db exclusive-lock
    where buf_prod-bc-db.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_prod-bc-db .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление информации из внешних файлов"
    v-mod     = 5
  .
  /* Удаляем ext-file, ext-file-line (информацию из внешних файлов) по удаляемой БД.*/
  for each buf_ext-file exclusive-lock
    where buf_ext-file.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    for each buf_ext-file-line exclusive-lock
      where buf_ext-file-line.db-num = buf_ext-file.db-num
        and buf_ext-file-line.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-line.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      delete buf_Ext-file-line.
    end.
    for each buf_ext-file-par exclusive-lock
      where buf_ext-file-par.db-num = buf_ext-file.db-num
        and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-par.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      delete buf_Ext-file-par.
    end.

    delete buf_ext-file .
  end.

  for each buf_ext-file exclusive-lock
    where buf_ext-file.from-db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    for each buf_ext-file-line exclusive-lock
      where buf_ext-file-line.db-num = buf_ext-file.db-num
        and buf_ext-file-line.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-line.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      delete buf_Ext-file-line.
    end.
    for each buf_ext-file-par exclusive-lock
      where buf_ext-file-par.db-num = buf_ext-file.db-num
        and buf_ext-file-par.from-db-num = buf_ext-file.from-db-num
        and buf_ext-file-par.file-num = buf_ext-file.file-num
    on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      delete buf_Ext-file-par.
    end.

    delete buf_ext-file .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление строк информации из внешних файлов"
    v-mod     = 5
  .
  for each buf_ext-file-line exclusive-lock
    where buf_ext-file-line.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_ext-file-line .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление настроек записей истории и маршрутизации"
    v-mod     = 5
  .

  on delete of ub.hist-nws-option override do: end.

  for each buf_hist-nws-option exclusive-lock
    where buf_hist-nws-option.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_hist-nws-option .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление истории изменения настроек записей истории и маршрутизации"
    v-mod     = 5
  .

  on delete of ub.c-hist-nws-option override do: end.

  for each buf_c-hist-nws-option exclusive-lock
    where buf_c-hist-nws-option.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_c-hist-nws-option .
  end.


  assign
    v-counter = 0
    v-action  = "Удаление записей в таблице для распределения блокировки"
    v-mod     = 5
  .
  /* Удаляем db-rec-attr (таблица для распределения блокировки) по удаляемой БД.*/
  for each buf_db-rec-attr exclusive-lock
    where buf_db-rec-attr.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_db-rec-attr .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление истории по документам, пришедшим по новостям"
    v-mod     = 5
  .
  /* Удаляем nws-doc-hist (по полю db-num) (история по документам, пришедшим по новостям) по удаляемой БД.*/
  for each buf_nws-doc-hist exclusive-lock
    where buf_nws-doc-hist.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_nws-doc-hist .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление записей состояния БД"
    v-mod     = 1
  .
  for each buf_db-status exclusive-lock
    where buf_db-status.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_db-status .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление записей upgrade"
    v-mod     = 5
  .
  for each buf_upgrade exclusive-lock
    where buf_upgrade.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_upgrade .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление атрибутов БД"
    v-mod     = 5
  .
  for each buf_db-attr exclusive-lock
    where buf_db-attr.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_db-attr .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление подтверждений отправленных пакетов"
    v-mod     = 5
  .
  /* Удаляем pck-sent, pck-rsvd (пакеты новостей для и от) удаляемой БД.*/
  for each buf_pck-sent exclusive-lock
    where buf_pck-sent.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_pck-sent .
  end.
  assign
    v-counter = 0
    v-action  = "Удаление подтверждений полученных пакетов"
    v-mod     = 5
  .
  for each buf_pck-rcvd exclusive-lock
    where buf_pck-rcvd.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_pck-rcvd .
  end.

  assign
    v-counter = 0
    v-action  = "Удаление маршрутизации СПН по БД"
    v-mod     = 5
  .
  /* Удаляем все записи таблицы route (новости) по этой БД. */
  for each buf_route exclusive-lock
    where buf_route.db-num = v-db-num
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    {&view-process}
    delete buf_route.
  end.

  assign
    v-counter = 0
    v-action  = "Отправка в СПН информации об удалении БД"
    v-mod     = 1
  .
  {&view-process}
  /* пишем команду на удаление в новости */
  run nws/cmd-del.p
    ( input {&table_db}
     ,input (buffer ub.db:handle)
     ,input "":U
    ) no-error .
  if error-status :error then do:
    assign
      v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление записи БД. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
    .
    if v-msg = true then do:
      message
        v-message
        view-as alert-box error.
    end.
    return error v-message .
  end.

  assign
    v-counter = 0
    v-action  = "Отправка в систему OpenXML информации об удалении БД"
    v-mod     = 1
  .
  {&view-process}
  if g#oxml = yes then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_db}
        , input ( buffer ub.db:handle )
    ) no-error.
    if error-status :error then do:
      undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4", {&new-line}, vss-workfile, return-value, error-status :get-message ( 1 ) ).
    end.
  end.

  hide frame inf .
end.