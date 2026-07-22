block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление шкалы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.gds-prt.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление gds-prt".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block:
do
on error undo main-block, return error
:

  message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалить шкалу если она уже ушла в новости" skip
    "Код шкалы" ub.gds-prt.node-code skip
    "Название шкалы" ub.gds-prt.node-name skip
    view-as alert-box error .
  undo, return error .

end.