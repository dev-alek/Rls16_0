block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление шапки стоплиста

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/07/07
Author: Bakhtadze Natalya
Creation date: 07/07/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.stop-list.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление шапки стоплиста".
{ cmp/vssrevis.i "substitute('&1|&2'
                           , ub.stop-list.classif-type
                           , ub.stop-list.stop-list-code
                           ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-stop-list for ub.c-stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if  ub.stop-list.status_ = {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять стоплист, закрытый до статуса" ub.stop-list.status_ skip
       ub.stop-list.classif-type skip
      "Номер стоплиста" ub.stop-list.stop-list-code skip
      "Статус стоплиста" ub.stop-list.status_ skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_stop-list-line no-lock where
            buf_stop-list-line.classif-type = ub.stop-list.classif-type
        and buf_stop-list-line.stop-list-code = ub.stop-list.stop-list-code no-error.
  if available buf_stop-list-line then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении стоплиста" skip
      "Найдена строка стоплиста" skip
      ub.stop-list.classif-type skip
      "Стоплист" ub.stop-list.stop-list-code skip
      "resource_id" buf_stop-list-line.resource_id skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-stop-list.
  buffer-copy ub.stop-list
  to buf_c-stop-list
  assign
  buf_c-stop-list.action = integer({&hn-delete})
  buf_c-stop-list.corr-user-db-num = g#db-num
  buf_c-stop-list.corr-user-name = g#userid
  buf_c-stop-list.doc-date = ub.stop-list.doc-date
  buf_c-stop-list.corr-date = v-today
  buf_c-stop-list.corr-time = v-time
  buf_c-stop-list.chip-num = next-value(s-ref-corr-chip, {&db-name_schema})
  .
end.