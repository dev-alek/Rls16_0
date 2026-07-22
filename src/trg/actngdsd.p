block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

изменение привязки прав к товару

Автор: Белоусов Илья Александрович
Дата создания: 04/22/08
Author: Ilia Belousov
Creation date: 04/22/08

Input:

Output:

*/
TRIGGER PROCEDURE FOR DELETE OF ub.action-role-item-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "изменение привязки прав к товару".
{ cmp/vssrevis.i }
{ cmp/trg-def.i } /* глобальности для триггеров */
{ cmp/showinf.i  }
/*{ gbl/cur-time.i }     текущее время */

define variable v-message     as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


   run nws/cmd-del.p
      ( input "action-role-item-gds":U
      ,input (buffer ub.action-role-item-gds:handle)
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
      , input {&table_action-role-item-gds}
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