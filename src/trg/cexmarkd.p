block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории акцизной или специальной марки

Автор: Хныкин Павел Андреевич
Дата создания: 03/01/06
Author: Pavel Khnykin
Creation date: 03/01/06

*/

trigger procedure for delete of ub.c-ex-mark.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории акцизной или специальной марки".
{ cmp/vssrevis.i "substitute('&1|&2'
                            , ub.c-ex-mark.db-num
                            , ub.c-ex-mark.mark-code
                            , ub.c-ex-mark.corr-user-db-num
                            , ub.c-ex-mark.chip-num
                            ) " }

main-block :
do transaction
on error undo main-block, return error
:
  message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись таблицы ИСТОРИЯ АКЦИЗНЫХ МАРОК"
    view-as alert-box error .
  undo main-block, return error .

end.