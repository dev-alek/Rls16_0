block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление шапки истории пистолета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/05
Author: Bakhtadze Natalya
Creation date: 08/07/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-nzl-hist.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление шапки истории пистолета".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.c-nzl-hist.obj-type
                         , ub.c-nzl-hist.obj-code
                         , ub.c-nzl-hist.nozzle-code
                         , ub.c-nzl-hist.corr-user-db-num
                         , ub.c-nzl-hist.chip-num
                         , ub.c-nzl-hist.subject) " }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять главную запись ИСТОРИИ ПИСТОЛЕТА"
  view-as alert-box error .
  undo main-block, return error .

end.