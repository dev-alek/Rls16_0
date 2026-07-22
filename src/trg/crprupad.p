block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление истории связки параметр профайла-параметр правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/07
Author: Bakhtadze Natalya
Creation date: 05/25/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.c-rp-rule-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление истории связки параметр профайла-параметр правила".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7|&8|&9'
                         , ub.c-rp-rule-param.profile_id
                         , ub.c-rp-rule-param.codex_id
                         , ub.c-rp-rule-param.ruleset_id
                         , ub.c-rp-rule-param.rp_order_id
                         , ub.c-rp-rule-param.rule_id
                         , ub.c-rp-rule-param.rule-param-name
                         , ub.c-rp-rule-param.rp-param-name
                         , ub.c-rp-rule-param.corr-user-db-num
                         , ub.c-rp-rule-param.chip-num
                         ) " }

{ cmp/str-glbl.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  message
  vss-workfile vss-revision vss-description skip
  "Физическое удаление истории связки параметр профайла-параметр правила ЗАПРЕЩЕНО"
  view-as alert-box error .
  undo main-block, return error .

end.