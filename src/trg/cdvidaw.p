block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение атрибута связи между событиями на кассе и событиями СВ

Автор: Белоусов Илья Александрович
Дата создания: 11/27/08
Author: Ilia Belousov
Creation date: 11/27/08

Input:

Output:

*/
TRIGGER PROCEDURE FOR WRITE OF cd-video-link-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Изменение атрибута связи между событиями на кассе и событиями СВ".
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
   run str/callnews.p
      (input {&table_cd-video-link-attr}
      ,input (buffer ub.cd-video-link-attr:handle)
      ) no-error .
   if error-status :error
   then do:
      undo main-block, return error substitute("&1. Невозможно маршрутизировать cd-video-link-attr для отправки в новости &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).
   end.

   if g#oxml = yes
   then do:
      run str/calloxml.p (
            input {&nwsdochs_action_update}
         , input {&table_cd-video-link-attr}
         , input ( buffer ub.cd-video-link-attr:handle )
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