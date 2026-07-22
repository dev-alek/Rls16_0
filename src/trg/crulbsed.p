block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории связки ПРАВИЛО-НАБОР ПРАВИЛ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-rule-by-set.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории связки ПРАВИЛО-НАБОР ПРАВИЛ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                         , ub.c-rule-by-set.codex_id
                         , ub.c-rule-by-set.ruleset_id
                         , ub.c-rule-by-set.rule_id
                         , ub.c-rule-by-set.corr-user-db-num
                         , ub.c-rule-by-set.chip-num
                         ) " }


{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
    vss-workfile vss-revision vss-description skip
    "Физическое удаление истории связки ПРАВИЛО-НАБОР ПРАВИЛ" skip
    view-as alert-box error .
  undo main-block, return error.
end.
