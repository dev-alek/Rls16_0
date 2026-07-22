block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка возможности удаления или изменения правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/19/07
Author: Bakhtadze Natalya
Creation date: 02/19/07

*/


define input parameter p-mode as character no-undo .
define input parameter p-rule-id as integer no-undo .
define output parameter p-ok as logical no-undo .
define output parameter p-mess as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка возможности удаления или изменения правила".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/waitfram.i noprocess }


define buffer buf_rule-by-set for ub.rule-by-set.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-by-profile for ub.rule-by-profile.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  run waitfram-show in this-procedure ( input "Ждите..." ).

  find first buf_rule-by-call no-lock where
            buf_rule-by-call.rule_id = p-rule-id no-error.
  if available buf_rule-by-call  then do:
    p-mess =  substitute("Невозможно удалить/изменить правило &1&2" +
              "Правило вызывается в точке &3(&4) кодекс &5  набор &6 порядок вызова &7"
              , p-rule-id
              , {&new-line}
              , buf_rule-by-call.call#_id
              , buf_rule-by-call.call_id
              , buf_rule-by-call.codex_id
              , buf_rule-by-call.ruleset_id
              , buf_rule-by-call.order_id
              ).
    run waitfram-hide in this-procedure .
    return.
  end.


  find first buf_rule-by-set no-lock where
            buf_rule-by-set.rule_id = p-rule-id no-error.
  if available buf_rule-by-set  then do:
    p-mess =  substitute("Невозможно удалить/изменить правило &1&2" +
              "Правило привязано к своду правил &3 кодекс &4"
              , p-rule-id
              , {&new-line}
              , buf_rule-by-set.ruleset_id
              , buf_rule-by-set.codex_id).
    run waitfram-hide in this-procedure .
    return.
  end.
  find first buf_rule-by-profile no-lock where
          buf_rule-by-profile.rule_id = p-rule-id no-error.
  if available buf_rule-by-profile then do:
    p-mess =  substitute("Невозможно удалить правило &1&2" +
              "Правило привязано к алгоритму &3"
              , p-rule-id
              , {&new-line}
              , buf_rule-by-profile.profile_id
              ).
    run waitfram-hide in this-procedure .
    return.
  end.
  assign
  p-ok = yes.
  run waitfram-hide in this-procedure .
end. /*doe*/