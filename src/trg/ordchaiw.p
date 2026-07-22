block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись цепочки

Автор: Чернова Светлана Александровна
Дата создания: 05/07/07
Author: Svetlana Chernova
Creation date: 05/07/07

*/
TRIGGER PROCEDURE FOR WRITE OF ub.ord-chain.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись цепочки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }

main-block :
do transaction
on error undo main-block, return error
:
end.