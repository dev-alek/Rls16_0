block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление атрибута лицензии поставщика алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/
TRIGGER PROCEDURE FOR DELETE OF ub.alc-supp-lic-attr.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".
/*{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u,  !!! список полей первичного индекса )" } */
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

   define buffer buf_c-alc-supp-lic-attr for ub.c-alc-supp-lic-attr .
   define buffer buf_sys-ctrl for ub.sys-ctrl .

   find first buf_sys-ctrl no-lock .

   /* пишем историю */
   run cur-time in this-procedure
      ( output v-date
      ,output v-time
      ).
   create buf_c-alc-supp-lic-attr.
   buffer-copy ub.alc-supp-lic-attr to buf_c-alc-supp-lic-attr
   assign
      buf_c-alc-supp-lic-attr.attr-status      = 1
      buf_c-alc-supp-lic-attr.chip-num         = next-value (s-alc-supp-lic-chip, {&db-name_schema})
      buf_c-alc-supp-lic-attr.corr-time        = v-time
      buf_c-alc-supp-lic-attr.corr-date        = v-date
      buf_c-alc-supp-lic-attr.corr-user-db-num = buf_sys-ctrl.db-num
      buf_c-alc-supp-lic-attr.corr-user-name   = g#userid
   .
   run nws/cmd-del.p
      ( input "alc-supp-lic-attr":U
      ,input (buffer ub.alc-supp-lic-attr:handle)
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
      , input {&table_alc-supp-lic-attr}
      , input ( buffer ub.alc-supp-lic-attr:handle )
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