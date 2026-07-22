block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление prop-head

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
define variable vss-description as character no-undo init "Удаление prop-head".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_prop-head  for dictdb.prop-head.
define buffer buf_prop-ruleset  for dictdb.prop-ruleset.
define buffer buf_prop-script for ub.prop-script.
define buffer buf_prop-map for ub.prop-map.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_prop-head exclusive-lock where
          recid(buf_prop-head) = p-rec .
  find first buf_prop-ruleset no-lock where
            buf_prop-ruleset.dtm-code = buf_prop-head.dtm-code no-error.
  if available buf_prop-ruleset then do:
    v-mess = substitute("Невозможно удалить ОБЪЕКТ-ОПЕРАНД &1&2" +
               "СУЩЕСТВУЕТ привязка к кодексу или набору правил &3&4"
               , buf_prop-head.dtm-code
               , {&new-line}
               , buf_prop-ruleset.codex_id
               , buf_prop-ruleset.ruleset_id
               ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.


  find first buf_prop-map no-lock where
            buf_prop-map.dtm-code = buf_prop-head.dtm-code no-error.
  if available buf_prop-map then do:
    v-mess = substitute("Невозможно удалить ОБЪЕКТ-ОПЕРАНД &1&2" +
               "СУЩЕСТВУЕТ маппинг  с node-code &3"
               , buf_prop-head.dtm-code
               , {&new-line}
               , buf_prop-map.node-code
               ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_prop-script no-lock where
            buf_prop-script.dtm-code = buf_prop-head.dtm-code  no-error.
  if available buf_prop-script  then do:
    v-mess = substitute("Невозможно удалить ОБЪЕКТ-ОПЕРАНД&1" +
               "существует СКРИПТ &2 &3"
               , {&new-line}
               , buf_prop-script.language
               , buf_prop-script.script-name).
   run err-mess in this-procedure ( input-output v-mess) .
   undo, return error (if p-silent = yes then v-mess else '':U).
  end.
  /*удалим записи словаря*/
  for each buf_ruledict where
          buf_ruledict.uniq-key-rec = buf_prop-head.uniq-key-rec
  on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
   for each buf_ruledict-param where
           buf_ruledict-param.entry-id = buf_ruledict.entry-id
   on error undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
      delete buf_ruledict-param.
   end.
   delete buf_Ruledict.
  end.

  delete buf_prop-head no-error.
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
      p-mess = substitute("Объект-операнд: код объекта &1:&2&3"
                         , buf_prop-head.dtm-code
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
