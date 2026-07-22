block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории расписания скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/24
Author: Bakhtadze Natalya
Creation date: 04/05/24

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-dis-time-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории расписания скидок".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        ,  ub.c-dis-time-rule.time-rule-num
                        , ub.c-dis-time-rule.corr-user-db-num
                        , ub.c-dis-time-rule.chip-num
                        ) " }
{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ РАСПИСАНИЯ СКИДОК"
  view-as alert-box error .
  undo main-block, return error .

end.