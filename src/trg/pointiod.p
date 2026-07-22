block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление point-io

Автор: Чернова Светлана Александровна
Дата создания: 04/26/06
Author: Svetlana Chernova
Creation date: 04/26/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.point-io.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление point-io".
{ cmp/vssrevis.i "substitute('&1|&2', ub.point-io.db-num, ub.point-io.point-code ) " }
{ cmp/trg-def.i  }

main-block:
do on error undo main-block, return error return-value :

  message
    vss-workfile vss-revision vss-description skip
    "Физическое удаление ПУНКТА ДОСТАВКИ/ОТГРУЗКИ в системе запрещено" skip
    view-as alert-box error .
  undo main-block, return error.

end.