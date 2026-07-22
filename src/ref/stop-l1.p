block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: stop-l1.p $
$Archive: ref/stop-l1.p $

Создание нового стоплиста ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/21/08
Author: Bakhtadze Natalya
Creation date: 01/21/08

*/

define input parameter p-silent as logical no-undo .
define output parameter p-stop-list-code as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: stop-l1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/stop-l1.p $":U .
define variable vss-description as character no-undo init "Создание нового стоплиста ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-status_ as character no-undo .
define variable v-fact-time as integer no-undo .
define variable v-mess as character no-undo .
define buffer buf_stop-list for ub.stop-list.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num > 0 then do:
    undo, return error "Нельзя создавать стоплисты в УБД".
  end.

  find last buf_stop-list no-lock where
         buf_stop-list.classif-type = {&table_dis-card}
          no-error .
  if not available buf_stop-list then do:
    p-stop-list-code = STRING(1, "999999999").
  end.
  ELSE DO:
      if buf_stop-list.status_ <> {&fact} then do:
        v-mess =
        substitute("Предыдущий стоплист &1 не закрыт до статуса &2&3Добавление невозможно"
                  ,buf_stop-list.stop-list-code
                  ,{&fact}
                  ,{&new-line}).
        if not p-silent then do:
          message v-mess
          view-as alert-box error .
        end.
        undo, return error (if p-silent = yes then v-mess else '':U).
      end.
      /*p-stop-list-code = string(integer(buf_stop-list.attr-code) + 1, "999999999").*/
      p-stop-list-code = STRING(next-value(s-stop-list, {&db-name_schema}), "999999999").
  END.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  v-doc-date = v-today
  v-fact-date = ?
  v-fact-time = 0
  v-status_ = '':U
  .
  create buf_stop-list.
  assign
  buf_stop-list.classif-type = {&table_dis-card}
  buf_stop-list.stop-list-code = p-stop-list-code
  buf_stop-list.doc-date = v-doc-date
  buf_stop-list.status_ = {&g___new}
  .
  release buf_stop-list no-error.
  if error-status:error then do:
    v-mess =  substitute("Ошибка при записи шапки стоплиста &1&2" +
                            "&3&2&4"
                            ,p-stop-list-code
                            ,{&new-line}
                            ,error-status:get-message(1)
                            ,return-value ).
    if not p-silent then do:
      message v-mess
      view-as alert-box error .
    end.
    undo, return error (if p-silent = yes then v-mess else '':U).
  end.
end.