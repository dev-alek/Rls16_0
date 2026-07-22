block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись СКРИПТА ДЛЯ ОБЪЕКТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/06
Author: Bakhtadze Natalya
Creation date: 10/04/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.prop-script OLD old_prop-script.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись СКРИПТА ДЛЯ ОБЪЕКТА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.prop-script.dtm-code
                         , ub.prop-script.language
                         , ub.prop-script.script-name
                         , ub.prop-script.revis_id
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-ii as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_c-prop-script for ub.c-prop-script.
define buffer buf_c-prop-head for ub.c-prop-head.



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news
  or g#db-num > 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-prop-script.
    buffer-copy old_prop-script to buf_c-prop-script
    assign
    buf_c-prop-script.dtm-code           = ub.prop-script.dtm-code
    buf_c-prop-script.language           = ub.prop-script.language
    buf_c-prop-script.script-name        = ub.prop-script.script-name
    buf_c-prop-script.revis_id           = ub.prop-script.revis_id
    buf_c-prop-script.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-prop-script.corr-time          = v-time
    buf_c-prop-script.corr-user-db-num   = g#db-num
    buf_c-prop-script.corr-user-name     = g#userid
    buf_c-prop-script.corr-date          = v-date
    .
    if ub.prop-script.dtm-code > 0 then do:
      create buf_c-prop-head.
      buffer-copy buf_c-prop-script
      except uniq-key-rec
      to buf_c-prop-head
      assign
      buf_c-prop-head.action             = integer(if new(ub.prop-script) then {&hn-create} else {&hn-update})
      buf_C-prop-head.subject            = {&table_prop-script}
      .
    end.
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_prop-script}
      ,input (buffer ub.prop-script:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_prop-script}
        , input ( buffer ub.prop-script:handle )
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