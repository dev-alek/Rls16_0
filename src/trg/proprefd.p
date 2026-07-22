block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление СРЕЗА ДАННЫХ по ОБЪЕКТУ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/11/06
Author: Bakhtadze Natalya
Creation date: 08/11/06

*/


TRIGGER PROCEDURE FOR DELETE OF ub.prop-ref.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление СРЕЗА ДАННЫХ по ОБЪЕКТУ".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.prop-ref.dt-code
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-prop-ref for ub.c-prop-ref.
define buffer buf_c-prop-head for ub.c-prop-head.
define buffer buf_prop-ref-call for ub.prop-ref-call.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_prop-ref-call no-lock where
            buf_prop-ref-call.dt-code = ub.prop-ref.dt-code no-error .
  if available buf_prop-ref-call then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалить срез/итог - он используется в " buf_prop-ref-call.call_id
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-prop-ref.
    buffer-copy ub.prop-ref to buf_c-prop-ref
    assign
    buf_c-prop-ref.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-prop-ref.corr-time          = v-time
    buf_c-prop-ref.corr-user-db-num   = g#db-num
    buf_c-prop-ref.corr-user-name     = g#userid
    buf_c-prop-ref.corr-date          = v-date
    .
    if ub.prop-ref.dtm-code > 0 then do:
      create buf_c-prop-head.
      buffer-copy buf_c-prop-ref
      except uniq-key-rec
      to buf_c-prop-head
      assign
      buf_c-prop-head.action             = integer({&hn-delete})
      buf_C-prop-head.subject            = {&table_prop-ref}
      .
    end.
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run nws/cmd-del.p
      ( input {&table_prop-ref}
      ,input (buffer ub.prop-ref:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_prop-ref}
        , input ( buffer ub.prop-ref:handle )
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
end.