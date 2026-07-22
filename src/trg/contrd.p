block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление договора

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.contract .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление договора".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.contract.contract-code, ub.contract.host-code, ub.contract.status_) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error
:
  MESSAGE
    "Договоры удалять запрещено!." SKIP
    "Удаление невозможно!" SKIP
    VIEW-AS ALERT-BOX ERROR.
    UNDO , RETURN ERROR.
end.