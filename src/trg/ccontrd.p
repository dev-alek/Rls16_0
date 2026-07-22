block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории договора

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-contract .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории договора".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.c-contract.contract-code, ub.c-contract.host-code, ub.c-contract.status_) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
  end.