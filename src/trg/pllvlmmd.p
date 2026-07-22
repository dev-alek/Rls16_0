block-level on error undo, throw.
/*

$Revision: f7f4e950f623, 0, rls $
$Author: expertek $
$Date: 2024/03/14 08:06:47 $
$Workfile: pl-lvlmmw.p $
$Archive: trg/pl-lvlmmd.p $

Триггер на удаление таблицы поясов на объекте

Автор: Ростовцев Александр Михайлович
Дата создания: 14/03/2024
Author: Aleksandr Rostovtsev
Creation date: 03/14/2024

*/

trigger procedure for delete of ub.pl-level-mm.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление таблицы поясов на объекте":U.

{ cmp/vssrevis.i "substitute('&1|&2|&3',ub.pl-level-mm.obj-type,ub.pl-level-mm.obj-code,ub.pl-level-mm.pl-code)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

define variable str1     as   character    no-undo.
define variable jj       as   integer      no-undo.

Main-Block:
do on error   undo Main-Block, return error return-value
   on end-key undo Main-Block, return error return-value
   on stop    undo Main-Block, return error return-value :

  if g#news <> yes then do:
    run nws/cmd-del.p ( input "pl-level-mm":U, input ( buffer ub.pl-level-mm :handle ), input "":U ) no-error.
    if error-status :error then do:
      assign str1 = {&new-line}.
      do jj = 1 to error-status :num-messages :
        assign str1 = str1 + {&new-line} + error-status :get-message ( jj ).
      end.
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&4",
                                     vss-workfile, {&new-line}, return-value, str1 ).
    end.
  end. /* if not g#news */

end. /* Main-Block */
