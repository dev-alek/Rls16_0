block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление даты на объекте

Автор: Белоусов Илья Александрович
Дата создания: 07/09/07
Author: Ilia Belousov
Creation date: 07/09/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR DELETE OF ub.obj-date.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление даты на объекте".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4', ub.obj-date.obj-type, ub.obj-date.obj-code, ub.obj-date.sys-date, ub.obj-date.status_) " }
{ cmp/trg-def.i  }

main-block:
do
on error undo main-block, return error
:

  if not g#news then do:
    message
      "Нельзя удалить информацию о дате на объекте" skip
      "Объект" ub.obj-date.obj-type ub.obj-date.obj-code skip
      "Дата" ub.obj-date.sys-date skip
      "Статус" ub.obj-date.status_ skip
      view-as alert-box error.
    undo main-block, return error.
  end.

end.