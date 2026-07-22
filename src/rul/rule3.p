block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление rule".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_rule  for ub.rule.
define buffer buf2_rule  for ub.rule.
define buffer buf_rule-by-profile  for ub.rule-by-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_rule-script for ub.rule-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_rule-by-call  for ub.rule-by-call.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule exclusive-lock where
          recid(buf_rule) = p-rec .
  if buf_rule.sts = integer({&to-delete-status-int})
  or buf_rule.sts = integer({&req-to-del-int})
  or buf_rule.sts = integer({&used-status-int})
  then do:
&scop status-code string(buf_rule.sts)
    assign
    v-mess = substitute("Правило находится в статусе &1, удаление невозможно", {&rule-status-int-name}).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-by-call no-lock where
            buf_rule-by-call.rule_id = buf_rule.rule_id no-error.
  if available buf_rule-by-call then do:
    v-mess = substitute("Нельзя удалить правило - правило вызывается:&1" +
                        "Точка вызова &2(&3), кодекс &4, набор правил &5"
                       , {&new-line}
                       , buf_rule-by-call.call#_id
                       , buf_rule-by-call.call_id
                       , buf_rule-by-call.codex_id
                       , buf_rule-by-call.ruleset_id
                       ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.

  find first buf_rule-by-profile no-lock where
            buf_rule-by-profile.rule_id = buf_rule.rule_id no-error.
  if available buf_rule-by-profile then do:
    v-mess = substitute("Нельзя удалить правило - есть привязанный профайл &1"
                       , buf_rule-by-profile.profile_id ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  for each buf_ruledict where
        buf_ruledict.entry-type = {&rdict-etype-rule}
    and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec
  on error undo main-block, return error:
    for each buf_ruledict-param where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
    on error undo main-block, return error:
      delete buf_ruledict-param.
    end.
    delete buf_ruledict.
  end.
  for each buf2_rule where
        buf2_rule.upper_rule_id = buf_rule.rule_id
  on error undo main-block, return error :
     delete buf2_rule.
  end.
  for each buf_rule-script where
        buf_rule-script.rule_id = buf_rule.rule_id
  on error undo main-block, return error :
     delete buf_rule-script.
  end.
  for each buf_rule-i-script where
        buf_rule-i-script.root_rule_id = buf_rule.rule_id
  on error undo main-block, return error :
     delete buf_rule-i-script.
  end.


  delete buf_rule no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Правило &1: &2"
                         , buf_rule.rule_id
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.