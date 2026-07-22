block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление истории связи типов алкоголя с лицензиями продавцов алкогол

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-alc-sale-lic-type.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер ".
/*{ cmp/vssrevis.i "substitute('&1|&2|&3|&4':u, /* !!! список полей первичного индекса */)" }*/
{ cmp/trg-def.i } /* глобальности для триггеров */
{ gbl/cur-time.i }    /* текущее время */


main-block :
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

   if g#oxml = yes
   then do:
   run str/calloxml.p (
         input {&nwsdochs_action_delete}
      , input {&table_c-alc-sale-lic-type}
      , input ( buffer ub.c-alc-sale-lic-type:handle )
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