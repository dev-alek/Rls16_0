block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение записи в логе событий на кассе

Автор: Белоусов Илья Александрович
Дата создания: 11/27/08
Author: Ilia Belousov
Creation date: 11/27/08

Input:

Output:

*/
TRIGGER PROCEDURE FOR WRITE OF cd-event-log.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение записи в логе событий на кассе".
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
   /* историю НЕ пишем
      по новостям не ходим
   run str/callnews.p
      (input {&table_cd-event-log}
      ,input (buffer ub.cd-event-log:handle)
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute("&1. Невозможно маршрутизировать cd-event-log для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.

   if g#oxml = yes
   then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
         , input {&table_cd-event-log}
         , input ( buffer ub.cd-event-log:handle )
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
   */

end.