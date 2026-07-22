block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление таблицы user-account

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/09/06

*/

trigger procedure for delete of ub.user-account .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись таблицы user-account".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block:
do transaction
on error   undo main-block, return error substitute('useraccd error main-block,&1', return-value )
on end-key undo main-block, return error substitute('useraccd end-key main-block,&1', return-value )
:

  message
    vss-workfile vss-revision vss-description skip
    "Запись user-account нельзя удалять" skip
    view-as alert-box error .
  undo main-block, return error return-value .
end.