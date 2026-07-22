block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы ext-classif-attr

Автор: Белоусов Илья Александрович
Дата создания: 01/11/07
Author: Ilia Belousov
Creation date: 01/11/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ext-classif-attr.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление таблицы ext-classif-attr".


{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/trg-def.i }
{ ref/extclass.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/key-rec.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if g#db-num = 0 or not g#news then do :
    run nws/cmd-del.p
      ( input {&table_ext-classif-attr}
        ,input (buffer ub.ext-classif-attr:handle)
        ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
end. /* main-block */
