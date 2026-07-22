block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории связки СКРИПТА ДЛЯ ОБЪЕКТА-НАБОР ПРАВИЛ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-pscript-ruleset.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории связки СКРИПТА ДЛЯ ОБЪЕКТА-НАБОР ПРАВИЛ".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8'
                         , ub.c-pscript-ruleset.codex_id
                         , ub.c-pscript-ruleset.ruleset_id
                         , ub.c-pscript-ruleset.dtm-code
                         , ub.c-pscript-ruleset.language
                         , ub.c-pscript-ruleset.script-name
                         , ub.c-pscript-ruleset.revis_id
                         , ub.c-pscript-ruleset.corr-user-db-num
                         , ub.c-pscript-ruleset.chip-num
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
    "Физическое удаление истории связки СКРИПТА ДЛЯ ОБЪЕКТА-НАБОР ПРАВИЛ запрещено" skip
    view-as alert-box error .
  undo main-block, return error.
end.