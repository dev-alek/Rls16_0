block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись в таблице ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/04
Author: Bakhtadze Natalya
Creation date: 03/22/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.deliv-type-cond-keep OLD old_deliv-type-cond-keep.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ".
{ cmp/vssrevis.i "substitute('&1|&2', ub.deliv-type-cond-keep.deliv-type-code, ub.deliv-type-cond-keep.cond-keep-code) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-deliv-type-cond-keep for ub.c-deliv-type-cond-keep.
define buffer buf_delivery-type for ub.delivery-type.
define buffer buf_condition-keeping for ub.condition-keeping.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя изменять запись ВОЗМОЖНОСТИ ДОСТАВКИ ПО УСЛОВИЯМ ХРАНЕНИЯ в УБД" skip
      view-as alert-box error .
      undo main-block, return error .
    end.
    /*проверим реляционность*/
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = ub.deliv-type-cond-keep.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ" skip
      "код типа доставки" ub.deliv-type-cond-keep.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_condition-keeping no-lock where
               buf_condition-keeping.cond-keep-code = ub.deliv-type-cond-keep.cond-keep-code  no-error .
    if not available buf_condition-keeping then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на УСЛОВИЯ ХРАНЕНИЯ" skip
      "код условий хранения" ub.deliv-type-cond-keep.cond-keep-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.

  if not g#news then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-deliv-type-cond-keep.
    buffer-copy old_deliv-type-cond-keep to buf_c-deliv-type-cond-keep
    assign
    buf_c-deliv-type-cond-keep.deliv-type-code    = ub.deliv-type-cond-keep.deliv-type-code
    buf_c-deliv-type-cond-keep.cond-keep-code    = ub.deliv-type-cond-keep.cond-keep-code
    buf_c-deliv-type-cond-keep.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-deliv-type-cond-keep.corr-time          = v-time
    buf_c-deliv-type-cond-keep.corr-user-db-num   = g#db-num
    buf_c-deliv-type-cond-keep.corr-user-name     = g#userid
    buf_c-deliv-type-cond-keep.corr-date          = v-date
    .
  end.

  run str/callnews.p
    (input "deliv-type-cond-keep"
    ,input (buffer ub.deliv-type-cond-keep:handle)
    ).

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_deliv-type-cond-keep}
        , input ( buffer ub.deliv-type-cond-keep:handle )
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