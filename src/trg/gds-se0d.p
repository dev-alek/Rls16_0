block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы gds-season-attr

Автор: Чернова Светлана Александровна
Дата создания: 11/15/07
Author: Svetlana Chernova
Creation date: 11/15/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-season-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы gds-season-attr".

define buffer buf_clients for ub.clients.

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    find first ub.season-attr no-lock where ub.season-attr.sea-code = ub.gds-season-attr.sea-code
      and ub.season-attr.db-num = ub.gds-season-attr.db-num and ub.season-attr.attr-code = {&seaattr-obj} no-error.

    if not g#news then do:
      if not available ub.season-attr or g#db-num <> 0 then do:  
        run nws/cmd-del.p
          ( input {&table_gds-season-attr}
           ,input (buffer ub.gds-season-attr:handle)
           ,input "":U
          ) no-error .
        if error-status :error then do:
          undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
        end.
      end.
      else do:
        find first buf_clients no-lock where buf_clients.obj-type = substring (ub.season-attr.attr-value, 1, 3)
          and buf_clients.obj-code = integer(substring (ub.season-attr.attr-value, 4)).
        if buf_clients.db-num <> 0 then do:
          run nws/cmd-del.p
            ( input {&table_gds-season-attr}
             ,input (buffer ub.gds-season-attr:handle)
             ,input string(buf_clients.db-num)
            ) no-error .
          if error-status :error then do:
            undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
          end.
        end.
      end.
    end.


end. /* main-block */