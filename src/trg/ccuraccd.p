block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление в таблице ИСТОРИЯ  КУРСА ММВБ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/18/05
Author: Bakhtadze Natalya
Creation date: 04/18/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-curr-accnt.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление в таблице ИСТОРИЯ КУРСА ММВБ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                        , ub.c-curr-accnt.curr-code
                        , ub.c-curr-accnt.exch-date
                        , ub.c-curr-accnt.corr-user-db-num
                        , ub.c-curr-accnt.chip-num
                        ) " }

main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ КУРСА ММВБ"
  view-as alert-box error .
  undo main-block, return error .


end.