block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка наличия привязок к prop-ref

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/12/07
Author: Bakhtadze Natalya
Creation date: 05/12/07

*/

define input parameter p-mode as character no-undo .
define input parameter p-from as character no-undo .
define input parameter p-dtm-code as integer no-undo .
define input parameter p-dt-code as integer no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-mess as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка наличия привязок к prop-ref".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }

define buffer buf_prop-head for ub.prop-head.
define buffer buf_dis-host for ub.dis-host.
define buffer buf_dis-obj for ub.dis-obj.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_prop-ref-call for ub.prop-ref-call.



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run waitfram-show in this-procedure ( input "Ждите..." ).


  /*проверим что нет записей*/
  find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = p-dtm-code.
  CASE buf_prop-head.storage-place:
    when {&table_dis-host} then do:
      find first buf_dis-host no-lock where
                buf_dis-host.dt-code = p-dt-code no-error.
      if available buf_dis-host then do:
        p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - имеются записи в хранилице", p-dt-code ).
        return.
      end.
    end.
    when {&table_dis-card-property} then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.dt-code = p-dt-code no-error.
      if available buf_dis-card-property then do:
        p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - имеются записи в хранилице", p-dt-code ).
        return.
      end.
    end.
  end case.
  CASE buf_prop-head.storage-place-host:
    when {&table_dis-host} then do:
      find first buf_dis-host no-lock where
                buf_dis-host.dt-code = p-dt-code
            and buf_dis-host.host-code > 0
                no-error.
      if available buf_dis-host then do:
        p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - имеются записи в хранилице", p-dt-code ).
        return.
      end.
    end.
    when {&table_dis-card-property} then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.dt-code = p-dt-code
            and buf_dis-card-property.host-code > 0
                no-error.
      if available buf_dis-card-property then do:
        p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - имеются записи в хранилице", p-dt-code ).
        return.
      end.
    end.
  end case.
  CASE buf_prop-head.storage-place-obj:
    when {&table_dis-obj} then do:
      find first buf_dis-obj no-lock where
                buf_dis-obj.dt-code = p-dt-code  no-error.
      if available buf_dis-host then do:
        p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - имеются записи в хранилице", p-dt-code ).
        return.
      end.
    end.
    when {&table_dis-card-property} then do:
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.obj-type > '':U
            and buf_dis-card-property.dt-code = p-dt-code
                no-error.
      if available buf_dis-card-property then do:
        p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - имеются записи в хранилице", p-dt-code ).
        return.
      end.
    end.
  end case.
  if p-from <> "ruprcall" then do:
    find first buf_prop-ref-call no-lock where
              buf_prop-ref-call.dt-code = p-dt-code no-error.
    if available buf_prop-ref-call
    then do:
      p-mess = substitute("Нельзя удалить срез/итог с кодом &1 - срез используется: &2"
                          , p-dt-code
                          , calldscr(buf_prop-ref-call.call_id) ).
      return.
    end.
  end.
  p-ok = yes.
end.