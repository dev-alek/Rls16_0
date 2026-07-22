block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись таблицы фильтр

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

trigger procedure for write of ubflt.filter new buffer new-filter old buffer old-filter .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы фильтр".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

main-block:
do transaction
on error undo, return error return-value
:
  if new new-filter then do :
    assign
      ubflt.new-filter.num-flt = next-value(next-num-filter, ubflt)
    .
  end.
end.