block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление c-point-io

Автор: Чернова Светлана Александровна
Дата создания: 04/26/06
Author: Svetlana Chernova
Creation date: 04/26/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-point-io.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление c-point-io".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'~
                           ,ub.c-point-io.db-num~
                           , ub.c-point-io.point-code
                           , ub.c-point-io.corr-user-db-num
                           , ub.c-point-io.chip-num) " }
{ cmp/trg-def.i  }

main-block:
do on error undo main-block, return error return-value :

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории ПУНКТА ОТГРУЗКИ/ДОСТАВКИ"
  view-as alert-box error .
  undo main-block, return error .

end.