block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование связи товара с типами алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.alc-type-gds old old-alc-type-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".

define variable v-field-chg as character no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .
  
define buffer bf_c-alc-type-gds for ub.c-alc-type-gds .
define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_alc-type-gds for ub.alc-type-gds .

{ cmp/vssrevis.i "substitute('&1|&2|&3':u, ub.alc-type-gds.alc-type-inner-code, ub.alc-type-gds.create-user-db-num, ub.alc-type-gds.gds-code)" }
{ cmp/trg-def.i } /* глобальности для триггеров */
{ gbl/cur-time.i }    /* текущее время */

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   /* пишем историю */
   buffer-compare ub.alc-type-gds to old-alc-type-gds
   CASE-SENSITIVE
   save result in v-field-chg.
   if v-field-chg <> "stts":U
   then do:
      find first buf_sys-ctrl no-lock .
      run cur-time in this-procedure
         ( output v-date
         ,output v-time
         ).

      create bf_c-alc-type-gds.
      if new(ub.alc-type-gds) then do:
         assign
         bf_c-alc-type-gds.alc-type-inner-code = ub.alc-type-gds.alc-type-inner-code
         bf_c-alc-type-gds.create-user-db-num  = ub.alc-type-gds.create-user-db-num
         bf_c-alc-type-gds.gds-code            = ub.alc-type-gds.gds-code
         .
      end.
      else do:
         buffer-copy old-alc-type-gds to bf_c-alc-type-gds .
      end.
      assign
/*         bf_c-alc-type-gds.chip-num         = next-value (s-gds-chip, {&db-name_schema})*/
         bf_c-alc-type-gds.chip-num         = next-value (s-alc-type-chip, {&db-name_schema})
         bf_c-alc-type-gds.corr-time        = v-time
         bf_c-alc-type-gds.corr-date        = v-date
         bf_c-alc-type-gds.corr-user-db-num = buf_sys-ctrl.db-num
         bf_c-alc-type-gds.corr-user-name   = (if g#news = true then "СПН" else g#userid )
         /*bf_c-alc-type-gds.action           = integer(if new(ub.alc-type-gds) then {&hn-create} else {&hn-update})*/
      .
   end.
   
/*    if g#db-num <> 0 then do:*/
     for each buf_alc-type-gds where buf_alc-type-gds.gds-code = ub.alc-type-gds.gds-code 
                                 and recid(buf_alc-type-gds) <> recid(ub.alc-type-gds):
     delete buf_alc-type-gds.
     end.                                    
/*    end.*/
   
   run str/callnews.p
      (input {&table_alc-type-gds}
      ,input (buffer ub.alc-type-gds:handle)
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute("&1. Невозможно маршрутизировать alc-type-gds для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.

   if g#oxml = yes
   then do:
   run str/calloxml.p (
         input {&nwsdochs_action_update}
      , input {&table_alc-type-gds}
      , input ( buffer ub.alc-type-gds:handle )
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