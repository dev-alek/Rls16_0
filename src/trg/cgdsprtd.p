block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер удаления истории шкал

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/31/05
Author: Bakhtadze Natalya
Creation date: 08/31/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-gds-prt.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер удаления истории шкал".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                        ,  ub.c-gds-prt.node-code
                        , ub.c-gds-prt.corr-user-db-num
                        , ub.c-gds-prt.chip-num

                        ) " }
{ cmp/trg-def.i }

main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ ШКАЛЫ"
  view-as alert-box error .
  undo main-block, return error .

end.
