block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление описаний таблиц типов данных.

Автор: Белоусов Илья Александрович
Дата создания: 02/21/07
Author: Ilia Belousov
Creation date: 02/21/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.datatype-table .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление описаний таблиц типов данных.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  if g#auto <> true then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Удалять записи описаний таблиц для типов данных запрещено!!!" ) skip
      view-as alert-box error
    .
  end.
  return error substitute( "Удалять записи описаний таблиц для типов данных запрещено!!!" ).
end.