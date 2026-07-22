block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 11/27/08
Author: Ilia Belousov
Creation date: 11/27/08

Input:

Output:

*/
TRIGGER PROCEDURE FOR DELETE OF cd-events.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "удаление событий на кассе".
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
   define buffer buf_cd-events-attr   for cd-events-attr .
   define buffer buf_cd-video-link    for cd-video-link  .

   FOR EACH buf_cd-events-attr where buf_cd-events-attr.event-id = ub.cd-events.event-id
       EXCLUSIVE-LOCK
       :
       DELETE buf_cd-events-attr.
   END.
   FOR EACH buf_cd-video-link where buf_cd-video-link.event-id = ub.cd-events.event-id
       EXCLUSIVE-LOCK
       :
       DELETE buf_cd-video-link.
   END. 

   run nws/cmd-del.p
      ( input "cd-events":U
      ,input (buffer ub.cd-events:handle)
      ,input ""
      ) no-error .
   if error-status :error
   then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ) .
   end.

   if g#oxml = yes
   then do:
      run str/calloxml.p (
            input {&nwsdochs_action_delete}
         , input {&table_cd-events}
         , input ( buffer ub.cd-events:handle )
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