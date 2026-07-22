block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление prop-script

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
define variable vss-description as character no-undo init "Удаление prop-script".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_prop-script  for dictdb.prop-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_pscript-ruleset for ub.pscript-ruleset.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_prop-script exclusive-lock where
          recid(buf_prop-script) = p-rec .
  find first buf_rule-i-script no-lock where
            buf_rule-i-script.script-name = buf_prop-script.script-name
        and buf_rule-i-script.dtm-code = buf_prop-script.dtm-code
        and buf_rule-i-script.revis_id = buf_prop-script.revis_id
            no-error.
  if available buf_rule-i-script  then do:
    v-mess = substitute("Невозможно удалить СКРИПТ &1&2" +
               "СКРИПТ привязан к правилу &3"
               , buf_prop-script.script-name
               , {&new-line}
               , buf_rule-i-script.root_rule_id
               ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_pscript-ruleset no-lock where
            buf_pscript-ruleset.dtm-code = buf_prop-script.dtm-code
        and buf_pscript-ruleset.language = buf_prop-script.language
        and buf_pscript-ruleset.script-name = buf_prop-script.script-name
        and buf_pscript-ruleset.revis_id = buf_prop-script.revis_id  no-error.
  if available buf_pscript-ruleset  then do:
    v-mess = substitute("Невозможно удалить СКРИПТ &1&2" +
               "СКРИПТ привязан к своду правил &3 кодекс &4"
               , buf_prop-script.script-name
               , {&new-line}
               , buf_pscript-ruleset.ruleset_id
               , buf_pscript-ruleset.codex_id).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  /*удалим записи словаря*/
  for each buf_ruledict where
          buf_ruledict.uniq-key-rec = buf_prop-script.uniq-key-rec
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
   for each buf_ruledict-param where
           buf_ruledict-param.entry-id = buf_ruledict.entry-id
   on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_ruledict-param.
   end.
   delete buf_Ruledict.
  end.
  delete buf_prop-script no-error.
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
      p-mess = substitute("Скрипт: код объекта &1 язык &2 скрипт &3 версия &4:&5&6"
                         , buf_prop-script.dtm-code
                         , buf_prop-script.language
                         , buf_prop-script.script-name
                         , buf_prop-script.revis_id
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