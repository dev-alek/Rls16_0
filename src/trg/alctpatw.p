block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

изменение атрибутов типов алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.alc-type-attr old old-alc-type-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".

define variable v-field-chg as character no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .

define buffer bf_c-alc-type-attr for ub.c-alc-type-attr .
define buffer buf_sys-ctrl   for ub.sys-ctrl .

{ cmp/vssrevis.i "substitute('&1|&2|&3':u, ub.alc-type-attr.alc-type-inner-code, ub.alc-type-attr.create-user-db-num, ub.alc-type-attr.attr-code )" }
{ cmp/trg-def.i } /* глобальности для триггеров */
{ gbl/cur-time.i }    /* текущее время */

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   /* пишем историю */
   buffer-compare ub.alc-type-attr to old-alc-type-attr CASE-SENSITIVE save result in v-field-chg.
   if v-field-chg <> "stts":U
   then do:
      find first buf_sys-ctrl no-lock .
      run cur-time in this-procedure
         ( output v-date
         ,output v-time
         ).

      create bf_c-alc-type-attr.
      if new(ub.alc-type-attr) then do:
         assign
            bf_c-alc-type-attr.alc-type-inner-code = ub.alc-type-attr.alc-type-inner-code
            bf_c-alc-type-attr.create-user-db-num  = ub.alc-type-attr.create-user-db-num
            bf_c-alc-type-attr.attr-code           = ub.alc-type-attr.attr-code
         .
      end.
      else do:
         buffer-copy old-alc-type-attr to bf_c-alc-type-attr .
      end.
      assign
         bf_c-alc-type-attr.chip-num         = next-value (s-alc-type-chip, {&db-name_schema})
         bf_c-alc-type-attr.corr-time        = v-time
         bf_c-alc-type-attr.corr-date        = v-date
         bf_c-alc-type-attr.corr-user-db-num = buf_sys-ctrl.db-num
         bf_c-alc-type-attr.corr-user-name   = (if g#news = true then "СПН" else g#userid )
         /*bf_c-alc-type-attr.action           = integer(if new(ub.alc-type-attr) then {&hn-create} else {&hn-update})*/
      .
   end.

   run str/callnews.p
      (input {&table_alc-type-attr}
      ,input (buffer ub.alc-type-attr:handle)
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute("&1. Невозможно маршрутизировать alc-type-attr для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.

   if g#oxml = yes
   then do:
   run str/calloxml.p (
         input {&nwsdochs_action_update}
      , input {&table_alc-type-attr}
      , input ( buffer ub.alc-type-attr:handle )
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