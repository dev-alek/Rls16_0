block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление rule-by-set

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
define variable vss-description as character no-undo init "Удаление rule-by-set".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_rule-by-set  for ub.rule-by-set.
define buffer buf_rule  for ub.rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule-by-set exclusive-lock where
          recid(buf_rule-by-set) = p-rec .
  find first buf_rule no-lock where
            buf_rule.rule_id = buf_rule-by-set.rule_id no-error.
  if available buf_rule then do:
    find  current buf_rule exclusive-lock .
  end.
  delete buf_rule-by-set no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  if available buf_rule then do:
    define variable v-ok as logical no-undo .
    run trg/rule-chk.p ( input {&deletion}
                        ,input buf_rule.rule_id
                        ,output v-ok
                        ,output v-mess
                        ) no-error.
    if not error-status:error
    and v-ok then do:
      if buf_rule.sts <> integer({&ready-status-int}) then do:
        buf_rule.sts = integer({&ready-status-int}).
      end.
    end.
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Привязка правила к набору кодекс: &1 набор: &2 № правила &3:&4&5"
                         , buf_rule-by-set.codex_id
                         , buf_rule-by-set.ruleset_id
                         , buf_rule-by-set.rule_id
                         , {&new-line}
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