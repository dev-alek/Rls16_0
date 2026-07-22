block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

удаление записи атрибута лога событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 11/27/08
Author: Ilia Belousov
Creation date: 11/27/08

Input:

Output:

*/
TRIGGER PROCEDURE FOR DELETE OF cd-event-log-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "удаление записи в логе событий на кассе".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/showinf.i  }
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   /* историю НЕ пишем */
   run nws/cmd-del.p
      ( input "cd-event-log-attr":U
      ,input (buffer ub.cd-event-log-attr:handle)
      ,input ""
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ) .
   end.

   if g#oxml = yes
   then do:
      run str/calloxml.p (
            input {&nwsdochs_action_delete}
         , input {&table_cd-event-log-attr}
         , input ( buffer ub.cd-event-log-attr:handle )
      ) no-error.
      if error-status :error
      then do:
         undo main-block, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                              , {&new-line}
                              , vss-workfile
                              , return-value
                              , error-status :get-message ( 1 ) ).
      end.
   end.
end.