block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

trigger procedure for delete of ubflt.filter.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление фильтра".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block:
do transaction
on error undo, return error return-value
:
  for each ubflt.usr-flt
    where ubflt.usr-flt.call-point = ubflt.filter.call-point
      and ubflt.usr-flt.naim       = ubflt.filter.naim
  on error undo, return error
  :
    delete ubflt.usr-flt .
  end.
end.