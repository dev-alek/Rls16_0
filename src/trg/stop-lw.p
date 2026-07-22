block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись шапки стоплиста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.stop-list OLD old-stop-list.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись шапки стоплиста".
{ cmp/vssrevis.i "substitute('&1|&2'
                           , ub.stop-list.classif-type
                           , ub.stop-list.stop-list-code
                                                      ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-stop-list for ub.c-stop-list.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /* обновляем пользователя, дату и время последнего обновления */
  if not (old-stop-list.user-db-num = ub.stop-list.user-db-num
          and
          old-stop-list.user-name = ub.stop-list.user-name)
    and not new(ub.stop-list)
    or (g#news and g#db-num > 0)
    then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    create buf_c-stop-list.
    buffer-copy old-stop-list
    except classif-type
    stop-list-code
    to buf_c-stop-list
    assign
    buf_c-stop-list.action = (if new(ub.stop-list) then integer({&hn-create}) else integer({&hn-update}))
    buf_c-stop-list.classif-type = ub.stop-list.classif-type
    buf_c-stop-list.stop-list-code = ub.stop-list.stop-list-code
    buf_c-stop-list.corr-user-db-num = g#db-num
    buf_c-stop-list.corr-user-name = g#userid
    buf_c-stop-list.doc-date = ub.stop-list.doc-date
    buf_c-stop-list.corr-date = v-today
    buf_c-stop-list.corr-time = v-time
    buf_c-stop-list.chip-num = next-value(s-ref-corr-chip, {&db-name_schema})
    .
  end.

  if not g#news
  then do:
    { gbl/curdburt.i
      ub.stop-list.user-db-num
      ub.stop-list.user-name
      ub.stop-list.sys-date
      ub.stop-list.sys-time
      ub.stop-list.sys-time-int
    }
  end.
  if old-stop-list.status_ = ub.stop-list.status_ then do:
    return . /* --->>>--- */
  end.
    /* запрещаем открывать стоплист, закрытый до статуса факт */
  if  not new ub.stop-list
  and old-stop-list.status_ = {&fact}
  and ub.stop-list.status_  <> old-stop-list.status_ then do:
    message
      vss-workfile vss-revision vss-description skip
      "Изменение статуса стоплиста невозможно" skip
      "СТоплист" ub.stop-list.classif-type  ub.stop-list.stop-list-code skip
      "Стоплист закрыты до статуса" {&fact} skip
      "Нельзя изменить статус стоплиста на" ub.stop-list.status_ skip
      view-as alert-box error .
    undo main-block, return error.
  end.

  if  not g#news
  and ub.stop-list.status_ = {&fact}
  then do:
    run str/callnews.p
      (input {&table_stop-list}
      ,input (buffer ub.stop-list:handle)
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно маршрутизировать СТОПЛИСТ для отправки в новости" skip
        ub.stop-list.classif-type skip
        ub.stop-list.stop-list-code skip
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
        , input {&table_stop-list}
        , input ( buffer ub.stop-list:handle )
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