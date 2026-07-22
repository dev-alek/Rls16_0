block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы season-attr

Автор: Чернова Светлана Александровна
Дата создания: 11/15/07
Author: Svetlana Chernova
Creation date: 11/15/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.season-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы season-attr".

define buffer buf_clients for ub.clients.
define buffer buf_season-attr for ub.season-attr.

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    if ub.season-attr.attr-code <>  {&seaattr-obj} then
      find first buf_season-attr where buf_season-attr.sea-code = ub.season-attr.sea-code
        and buf_season-attr.sea-code = ub.season-attr.sea-code
        and buf_season-attr.attr-code = {&seaattr-obj}
        no-error.

    if not g#news then do:
      if (ub.season-attr.attr-code <>  {&seaattr-obj} and not available buf_season-attr) or g#db-num <> 0 then do:  
        run nws/cmd-del.p
          ( input {&table_season-attr}
           ,input (buffer ub.season-attr:handle)
           ,input "":U
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
      else do:  
        find first buf_clients no-lock where buf_clients.obj-type = (if available buf_season-attr then substring (buf_season-attr.attr-value, 1, 3) else substring (ub.season-attr.attr-value, 1, 3))
          and buf_clients.obj-code = (if available buf_season-attr then integer(substring (buf_season-attr.attr-value, 4)) else integer(substring (ub.season-attr.attr-value, 4))).
        if buf_clients.db-num <> 0 then do:
          run nws/cmd-del.p
            ( input {&table_season-attr}
             ,input (buffer ub.season-attr:handle)
             ,input string(buf_clients.db-num)
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
        end.
      end.
    end.


end. /* main-block */