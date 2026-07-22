block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории связки ТРК-ПИСТОЛЕТ

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/24/08
Author: Dmitry Ukhanov
Creation date: 03/24/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-pump-nozzle.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на удаление истории связки ТРК-ПИСТОЛЕТ":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.c-pump-nozzle.obj-type
                         , ub.c-pump-nozzle.obj-code
                         , ub.c-pump-nozzle.pump-code
                         , ub.c-pump-nozzle.nozzle-code
                         , ub.c-pump-nozzle.chip-num
                         ) " }


Main-Block:
do transaction on error   undo Main-Block, return error
               on end-key undo Main-Block, return error
               on stop    undo Main-Block, return error :

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись истории связки ТРК-ПИСТОЛЕТ"
  view-as alert-box error .
  undo main-block, return error .


end. /* Main-Block */