block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование связи товара с лицензией продавцов алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.alc-sale-lic-type old old-alc-sale-lic-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".

define variable v-field-chg as character no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .

define buffer bf_c-alc-sale-lic-type for ub.c-alc-sale-lic-type .
define buffer buf_sys-ctrl   for ub.sys-ctrl .

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u, ub.alc-sale-lic-type.alc-sale-lic-code, ub.alc-sale-lic-type.create-user-db-num, ub.alc-sale-lic-type.alc-type-inner-code, ub.alc-sale-lic-type.create-alc-type-user-db-num )" }
{ cmp/trg-def.i }
{ gbl/cur-time.i }    /* текущее время */

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   /* пишем историю */
   buffer-compare ub.alc-sale-lic-type to old-alc-sale-lic-type save result in v-field-chg.
   if v-field-chg <> "stts":U
   then do:
      find first buf_sys-ctrl no-lock .
      run cur-time in this-procedure
         ( output v-date
         ,output v-time
         ).

      create bf_c-alc-sale-lic-type.
      if new(ub.alc-sale-lic-type) then do:
         assign
         bf_c-alc-sale-lic-type.alc-sale-lic-code           = ub.alc-sale-lic-type.alc-sale-lic-code
         bf_c-alc-sale-lic-type.create-user-db-num          = ub.alc-sale-lic-type.create-user-db-num
         bf_c-alc-sale-lic-type.alc-type-inner-code         = ub.alc-sale-lic-type.alc-type-inner-code
         bf_c-alc-sale-lic-type.create-alc-type-user-db-num = ub.alc-sale-lic-type.create-alc-type-user-db-num
         .
      end.
      else do:
         buffer-copy old-alc-sale-lic-type to bf_c-alc-sale-lic-type .
      end.
      assign
         bf_c-alc-sale-lic-type.chip-num         = next-value (s-alc-sale-lic-chip, {&db-name_schema})
         bf_c-alc-sale-lic-type.corr-time        = v-time
         bf_c-alc-sale-lic-type.corr-date        = v-date
         bf_c-alc-sale-lic-type.corr-user-db-num = buf_sys-ctrl.db-num
         bf_c-alc-sale-lic-type.corr-user-name   = (if g#news = true then "СПН" else g#userid )
         /*bf_c-alc-sale-lic-type.action           = integer(if new(ub.alc-sale-lic-type) then {&hn-create} else {&hn-update})*/
      .
   end.

   run str/callnews.p
      (input {&table_alc-sale-lic-type}
      ,input (buffer ub.alc-sale-lic-type:handle)
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute("&1. Невозможно маршрутизировать alc-sale-lic-type для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.

   if g#oxml = yes
   then do:
   run str/calloxml.p (
         input {&nwsdochs_action_update}
      , input {&table_alc-sale-lic-type}
      , input ( buffer ub.alc-sale-lic-type:handle )
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