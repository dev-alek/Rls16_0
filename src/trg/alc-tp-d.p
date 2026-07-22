block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер удаления позиции в классификаторе алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.alc-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".
{ cmp/vssrevis.i "substitute('&1|&2':u, ub.alc-type.alc-type-inner-code, ub.alc-type.create-user-db-num)" }
{ cmp/trg-def.i } /* глобальности для триггеров */
{ gbl/cur-time.i }    /* текущее время */
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   define variable v-date        as date      no-undo .
   define variable v-time        as integer   no-undo .
   define variable v-message     as character no-undo .

   define buffer buf_c-alc-type        for ub.c-alc-type .
   define buffer buf_sys-ctrl          for ub.sys-ctrl .
   define buffer buf_alc-type-attr     for ub.alc-type-attr .
   define buffer buf_alc-type-gds      for ub.alc-type-gds .
   define buffer buf_alc-supp-lic-type for ub.alc-supp-lic-type.
   define buffer buf_alc-sale-lic-type for ub.alc-sale-lic-type.

   find first buf_sys-ctrl no-lock .

   for each  buf_alc-sale-lic-type exclusive-lock
       where buf_alc-sale-lic-type.alc-type-inner-code = ub.alc-type.alc-type-inner-code
       :
       delete buf_alc-sale-lic-type .
   end.     /* for each alc-sale-lic-type */

   for each  buf_alc-supp-lic-type exclusive-lock
       where buf_alc-supp-lic-type.alc-type-inner-code = ub.alc-type.alc-type-inner-code
      :
       delete buf_alc-supp-lic-type .
   end.     /* for each alc-supp-lic-type */

   for each buf_alc-type-attr exclusive-lock
      where buf_alc-type-attr.alc-type-inner-code = ub.alc-type.alc-type-inner-code
   on error undo, return error
   :
      delete buf_alc-type-attr .
   end.     /* for each buf_alc-type-attr */
   for each buf_alc-type-gds exclusive-lock
      where buf_alc-type-gds.alc-type-inner-code = ub.alc-type.alc-type-inner-code
   on error undo, return error
   :
      delete buf_alc-type-gds .
   end.     /* for each buf_alc-type-gds */

   /* пишем историю */
   run cur-time in this-procedure
      ( output v-date
      ,output v-time
      ).
   create buf_c-alc-type.
   buffer-copy ub.alc-type to buf_c-alc-type
   assign
      buf_c-alc-type.alc-type-status  = 1
      buf_c-alc-type.chip-num         = next-value (s-alc-type-chip, {&db-name_schema})
      buf_c-alc-type.corr-time        = v-time
      buf_c-alc-type.corr-date        = v-date
      buf_c-alc-type.corr-user-db-num = buf_sys-ctrl.db-num
      buf_c-alc-type.corr-user-name   = g#userid
   .
   run nws/cmd-del.p
      ( input "alc-type":U
      ,input (buffer ub.alc-type:handle)
      ,input ""
      ) no-error .
   if error-status :error
   then do:
      assign
      v-message = substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) )
      .
      return error v-message .
   end.

   if g#oxml = yes
   then do:
   run str/calloxml.p (
         input {&nwsdochs_action_delete}
      , input {&table_alc-type}
      , input ( buffer ub.alc-type:handle )
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