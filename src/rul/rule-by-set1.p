block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение привязки rule к ruleset

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-rule-id as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки rule к ruleset".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruleset for dictdb.ruleset.
define buffer buf_rule-by-set for dictdb.rule-by-set.
define buffer buf_rule for dictdb.rule.

if p-mode <> {&add-def}
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_ruleset
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = p-codex-id
          and buf_ruleset.ruleset_id = p-ruleset-id no-error.
    if not available buf_ruleset then do:
      assign
      v-mess = "Не найден набор правил".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_rule no-lock where
              buf_rule.rule_id = p-rule-id no-error.
    if not available buf_rule then do:
      assign
      v-mess = "Не найдено правило c таким №".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_rule share-lock where
              buf_rule.rule_id = p-rule-id no-error.
    if buf_rule.sts = integer({&new-status-int})
    or buf_rule.sts = integer({&deleted-status-int})
    or buf_rule.sts = integer({&to-delete-status-int})
    or buf_rule.sts = integer({&req-to-del-int}) then do:
&scop status-code string( buf_rule.sts)
      assign
      v-mess = substitute("Правило находится в статусе &1", {&rule-status-int-name}).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'sts':U).
    end.
    create buf_rule-by-set.
    assign
    buf_rule-by-set.codex_id = p-codex-id
    buf_rule-by-set.ruleset_id = p-ruleset-id
    buf_rule-by-set.rule_id = p-rule-id
    .
    if buf_rule.sts <> integer({&used-status-int}) then do:
      buf_rule.sts = integer({&used-status-int}).
    end.
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("rule-by-set кодекс: &1 набор: &2 объект &3: &4"
                         , p-codex-id
                         , p-ruleset-id
                         , p-rule-id
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