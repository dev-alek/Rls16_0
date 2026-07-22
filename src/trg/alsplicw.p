block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование лицензии на поставки алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.alc-supp-lic old old-alc-supp-lic.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".

define variable v-field-chg as character no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .

define buffer bf_c-alc-supp-lic for ub.c-alc-supp-lic .
define buffer buf_sys-ctrl   for ub.sys-ctrl .

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u, ub.alc-supp-lic-type.create-user-db-num, ub.alc-supp-lic-type.alc-supp-lic-code )" }
{ cmp/trg-def.i } /* глобальности для триггеров */
{ gbl/cur-time.i }    /* текущее время */

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   /* пишем историю */
   buffer-compare ub.alc-supp-lic to old-alc-supp-lic
   CASE-SENSITIVE
   save result in v-field-chg.
   if v-field-chg <> "stts":U
   then do:
      find first buf_sys-ctrl no-lock .
      run cur-time in this-procedure
         ( output v-date
         ,output v-time
         ).

      create bf_c-alc-supp-lic.
      if new(ub.alc-supp-lic) then do:
         assign
         bf_c-alc-supp-lic.create-user-db-num          = ub.alc-supp-lic.create-user-db-num
         bf_c-alc-supp-lic.alc-supp-lic-code           = ub.alc-supp-lic.alc-supp-lic-code
         .
      end.
      else do:
         buffer-copy old-alc-supp-lic to bf_c-alc-supp-lic .
      end.
      assign
         bf_c-alc-supp-lic.chip-num         = next-value (s-alc-supp-lic-chip, {&db-name_schema})
         bf_c-alc-supp-lic.corr-time        = v-time
         bf_c-alc-supp-lic.corr-date        = v-date
         bf_c-alc-supp-lic.corr-user-db-num = buf_sys-ctrl.db-num
         bf_c-alc-supp-lic.corr-user-name   = (if g#news = true then "СПН" else g#userid )
         /*bf_c-alc-supp-lic.action         = integer(if new(ub.alc-supp-lic) then {&hn-create} else {&hn-update})*/
      .
   end.

   run str/callnews.p
      (input {&table_alc-supp-lic}
      ,input (buffer ub.alc-supp-lic:handle)
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute("&1. Невозможно маршрутизировать alc-supp-lic для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.

   if g#oxml = yes
   then do:
   run str/calloxml.p (
         input {&nwsdochs_action_update}
      , input {&table_alc-supp-lic}
      , input ( buffer ub.alc-supp-lic:handle )
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