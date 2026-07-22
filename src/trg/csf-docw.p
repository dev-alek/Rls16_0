block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись счета-фактуры

Автор: Чернова Светлана Александровна
Дата создания: 10/06/05
Author: Svetlana Chernova
Creation date: 10/06/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-schet-fact-doc OLD old_c-schet-fact-doc .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись счета-фактуры".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.c-schet-fact-doc.doc-code, ub.c-schet-fact-doc.doc-date, ub.c-schet-fact-doc.status_) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
/* все шлем в новости в триггере schet-fact-doc */

end.