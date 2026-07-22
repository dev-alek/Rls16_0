block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Open XML. Триггер на изменение записи типа данных импорта

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.datatype-imp old buffer old-datatype-imp .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Open XML. Триггер на изменение записи типа данных импорта".
{ cmp/vssrevis.i }

main-block:
do transaction
on error undo main-block, return error
:
END.