block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление атрибута партии

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/23/03

*/

TRIGGER PROCEDURE FOR DELETE OF ub.parts-attr .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на удаление атрибута партии".

{ cmp/vssrevis.i "substitute('&1|&2|&3':u,ub.parts-attr.in-code,ub.parts-attr.gds-code,ub.parts-attr.part-code)" }
{ cmp/trg-def.i  }

MAIN-BLOCK:
do transaction
on error   undo main-block, return error
:

end.