block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории параметра статьи словар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07


*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-ruledict-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории параметра статьи словар".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.c-ruledict-param.entry-id
                         , ub.c-ruledict-param.param-num
                         , ub.c-ruledict-param.corr-user-db-num
                         , ub.c-ruledict-param.chip-num
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
    "Физическое удаление истории параметра статьи словаря в системе запрещено" skip
    view-as alert-box error .
  undo main-block, return error.

end.


