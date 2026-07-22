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

procedure display-rule-call-params :
define input parameter p-mode as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-handle as handle no-undo .
&if "{1}" = "temp" &then
define buffer buf_rule-call-param for tt0-rule-call-param.
&else
define buffer buf_rule-call-param for ub.rule-call-param.
&endif
define variable v-string as character no-undo .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  run temp-string_write in p-handle ( input "ПАРАМЕТРЫ").
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
  _rr:
  for each buf_rule-call-param no-lock where
          buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id:
    if p-once-more >= 0 and
    buf_rule-call-param.once-more <> p-once-more then next.
    v-string = '':U.
    if lookup("LIST", buf_rule-call-param.param-3-data-type) > 0 then do:
      if buf_rule-call-param.p-index = 0 then do:
        assign
        v-string = buf_rule-call-param.param-label +  {&space-char}  + "=".
        run temp-string_write in p-handle ( input v-string).
        next _rr.
      end.
      else do:
        assign
        v-string = fill( {&space-char}, length(buf_rule-call-param.param-label) + 2).
      end.
    end.
    else do:
      assign
      v-string = buf_rule-call-param.param-label +  {&space-char}  + "=".
    end.
    CASE buf_rule-call-param.param-data-type:
      when {&ABL-datatype-character} then do:
        v-string = v-string + buf_rule-call-param.param-value-character.
      end.
      when {&ABL-datatype-date} then do:
        v-string = v-string + string(buf_rule-call-param.param-value-date, "99/99/9999").
      end.
      when {&ABL-datatype-logical} then do:
        v-string = v-string + string(buf_rule-call-param.param-value-logical, "ДА/НЕТ").
      end.
      when {&ABL-datatype-decimal} then do:
        v-string = v-string + string(buf_rule-call-param.param-value-decimal).
      end.
      when {&ABL-datatype-integer} then do:
        v-string = v-string + string(buf_rule-call-param.param-value-integer).
      end.
    END CASE.
    run temp-string_write in p-handle ( input v-string).
  end.
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
end.

end procedure. /* display-rule-call-params */