block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись даты на объекте

Автор: Белоусов Илья Александрович
Дата создания: 07/09/07
Author: Ilia Belousov
Creation date: 07/09/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.obj-date old buffer old-obj-date .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись даты на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4', ub.obj-date.obj-type, ub.obj-date.obj-code, ub.obj-date.sys-date, ub.obj-date.status_) " }
{ cmp/trg-def.i  }
{ trg/factord.i  }
{ gbl/cur-time.i }

main-block :
do transaction
on error undo main-block, return error
:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define buffer next_obj-date for ub.obj-date .
  /* проверяем существование объекта */
  define variable l-obj-exist as logical no-undo .
  { gbl/objat.i
    ub.obj-date.obj-type
    ub.obj-date.obj-code
    "'check-exist':u"
    l-obj-exist
    no-error
  }
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на объект" skip
      "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
      "Дата" ub.obj-date.sys-date skip
      "Статус" ub.obj-date.status_ skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* информация о дате должна быть задана */
  if ub.obj-date.sys-date = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не задана системная дата" skip
      "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
      "Дата" ub.obj-date.sys-date skip
      "Статус" ub.obj-date.status_ skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  if new ub.obj-date = false then do:
    /* проверяем, что нельзя менять информацию в первичном ключе */
    if  ub.obj-date.obj-type <> old-obj-date.obj-type
    and ub.obj-date.obj-code <> old-obj-date.obj-code
    and ub.obj-date.sys-date <> old-obj-date.sys-date
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не допускается изменение информации о дате на объекте" skip
        "Новый объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
        "Новая дата" ub.obj-date.sys-date skip
        "Новый статус" ub.obj-date.status_ skip
        "Старый объект" old-obj-date.obj-type old-obj-date.obj-code skip
        "Старая дата" old-obj-date.sys-date skip
        "Старый статус" old-obj-date.status_ skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    /* проверяем, что нельзя открывать закрытую дату */
    if  old-obj-date.status_ = {&objdt-closed}
    and ub.obj-date.status_  <> {&objdt-closed}
    and not g#news
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Нельзя открыть закрытый день" skip
        "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
        "Дата" ub.obj-date.sys-date skip
        "Новый статус" ub.obj-date.status_ skip
        "Старый статус" old-obj-date.status_ skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  if ub.obj-date.status_ = {&objdt-current}
  then do:        /* Проверка на образование второй текущей даты */
    find first next_obj-date
      where next_obj-date.obj-type = ub.obj-date.obj-type
        and next_obj-date.obj-code = ub.obj-date.obj-code
        and next_obj-date.status_  = {&objdt-current}
        and recid( next_obj-date ) <> recid( ub.obj-date )
    no-error .
    if available next_obj-date
      then do:
          if g#news then next_obj-date.status_  = {&objdt-closed} .
          else do:         
        message
          vss-workfile vss-revision vss-description
          skip "На объекте обнаружена текущая дата: " next_obj-date.sys-date
          skip "Не допускается создание второй текущей даты на объекте."
          skip "Объект:" ub.obj-date.obj-type ub.obj-date.obj-code
          skip error-status :get-message(1)
          skip return-value
        view-as alert-box error .
        undo, return error .
          end.
    end.
  end.        /* if ub.obj-date.status_ = {&objdt-current} */

  /* нужно проверять возможные переходы графа статусов */
  if lookup (ub.obj-date.status_, {&objdt-stts}) = 0 then do:
    /* Недопустимый статус даты на объекте */
    message
      vss-workfile vss-revision vss-description skip
      "Недопустимый статус даты на объекте" skip
      "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
      "Дата" ub.obj-date.sys-date skip
      "Статус" ub.obj-date.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.


  if not g#news then do:
    if ub.obj-date.status_ = {&objdt-current} then do:
      /* проверяем, что не существует более поздней даты на объекте */
      find first next_obj-date
        where next_obj-date.obj-type = ub.obj-date.obj-type
          and next_obj-date.obj-code = ub.obj-date.obj-code
          and next_obj-date.sys-date > ub.obj-date.sys-date
        no-error .
      if available next_obj-date then do:
        message
          vss-workfile vss-revision vss-description skip
          "Найдена более поздняя дата на объекте" next_obj-date.sys-date skip
          "Не допускается создание даты на объекте задним числом" skip
          "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
          "Дата" ub.obj-date.sys-date skip
          "Статус" ub.obj-date.status_ skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      /* заполняем информацию об открытии */
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        ub.obj-date.open-id   = g#userid
        ub.obj-date.open-date = v-today
        ub.obj-date.open-time = v-time
      .

      /* проверяем, что в каждый момент времени */
      /* может быть активна только одна дата на объекте */
      define buffer prev_obj-date for ub.obj-date .
      find first prev_obj-date
        where prev_obj-date.obj-type = ub.obj-date.obj-type
          and prev_obj-date.obj-code = ub.obj-date.obj-code
          and prev_obj-date.status_  = {&objdt-current}
          and recid(prev_obj-date)   <> recid(ub.obj-date)
        no-error .
      if available prev_obj-date then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно открыть новую активную дату на объекте" skip
          "Уже существует активная дата" prev_obj-date.sys-date skip
          "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
          "Дата" ub.obj-date.sys-date skip
          "Статус" ub.obj-date.status_ skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.


    if ub.obj-date.status_ = {&objdt-closed}  then do:
      /* заполняем информацию о закрытии */
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        ub.obj-date.close-id   = g#userid
        ub.obj-date.close-date = v-today
        ub.obj-date.close-time = v-time
      .

      /* определяем fact-order */
      define variable v-day-end-fact-order   as decimal no-undo .

      run factord-end-day in this-procedure
        (input  ub.obj-date.sys-date      /* p-fact-date            */
        ,output v-day-end-fact-order      /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      or v-day-end-fact-order = ?
      or v-day-end-fact-order = 0 then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении фактического номера даты на объекте" skip
          "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
          "Дата" ub.obj-date.sys-date skip
          "Статус" ub.obj-date.status_ skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      assign
        ub.obj-date.fact-order = v-day-end-fact-order
      .
    end.
    if ub.obj-date.status_ <> "" then do:
      run str/callnews.p
        (input "obj-date"
        ,input (buffer ub.obj-date:handle)
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно маршрутизировать obj-date для отправки в новости" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_obj-date}
        , input ( buffer ub.obj-date:handle )
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