/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вывод параметров вызова rule в читаемом виде

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/26/06
Author: Bakhtadze Natalya
Creation date: 10/26/06

*/

{ rul/tempstrn.i }

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure display-ruledict-params :
define input parameter p-mode as character no-undo .
define input parameter p-rule-id as integer no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule for ub.rule.
define variable v-string as character no-undo .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  find first buf_rule no-lock where
            buf_rule.rule_id = p-rule-id.
  find first buf_ruledict no-lock where
            buf_ruledict.entry-type = {&rdict-etype-rule}
        and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.

  run temp-string_write in this-procedure ( input "ПАРАМЕТРЫ").
  if p-mode = "text" then do:
    run temp-string_write in this-procedure ( input "").
  end.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id:
    assign
    v-string = substitute("&1 (&2) (&3)"
                          , buf_ruledict-param.param-label
                          , buf_ruledict-param.param-data-type
                          , buf_ruledict-param.param-name).
    run temp-string_write in this-procedure ( input v-string).
  end.
end.

end procedure. /* display-prop-script */