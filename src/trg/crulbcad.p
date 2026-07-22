block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории алгоритма расчета по типу ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/06
Author: Bakhtadze Natalya
Creation date: 09/14/06

*/


TRIGGER PROCEDURE FOR DELETE OF ub.c-rule-by-call.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории алгоритма расчета по типу ДК".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6'
                         , ub.c-rule-by-call.call#_id
                         , ub.c-rule-by-call.codex_id
                        , ub.c-rule-by-call.ruleset_id
                        , ub.c-rule-by-call.order_id
                        , ub.c-rule-by-call.corr-user-db-num
                        , ub.c-rule-by-call.chip-num
                         ) " }

{ cmp/trg-def.i }


main-block :
do transaction
on error undo main-block, return error return-value
:

  message
  vss-workfile vss-revision vss-description skip
  "Нельзя удалять запись ИСТОРИИ АЛГОРИТМА РАСЧЕТА ПО ПРАВИЛАМ"
  view-as alert-box error .
  undo main-block, return error .

end.