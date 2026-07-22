block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление акцизной или специальной марки

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06

*/

trigger procedure for delete of ub.ex-mark.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление акцизной или специальной марки".
{ cmp/vssrevis.i "substitute('&1|&2'
                            , ub.ex-mark.db-num
                            , ub.ex-mark.mark-code
                            ) " }

main-block :
do transaction
on error undo main-block, return error
:
  message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись таблицы АКЦИЗНЫЕ И СПЕЦИАЛЬНЫЕ МАРКИ"
    view-as alert-box error .
  undo main-block, return error .

end.