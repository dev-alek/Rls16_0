/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временная таблица обеспечения корректности МНОГОКРАТНОГО вызова правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/31/07
Author: Bakhtadze Natalya
Creation date: 03/31/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define temp-table temp-rule-reusable no-undo
field call_id as character
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field profile_id as integer
field rule_id as integer
field reusable-string as character
index pi is unique primary
call_id codex_id  ruleset_id order_id
index ireuse
call_id
codex_id
ruleset_id
rule_id
reusable-string
.

procedure check-reusable :
define input parameter p-call-id as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-reusable-string as character no-undo .
define output parameter p-can-run as logical no-undo init yes.
define buffer buf_temp-rule-reusable for temp-rule-reusable.
define buffer buf_rule-call-param for ub.rule-call-param.

define variable v-ii as integer no-undo .
define variable v-reusable-string as character no-undo .
do
on error undo, return error return-value
:
   if p-reusable-string = "0" then return.
   if p-reusable-string = "-":u then do:
     v-reusable-string = string(p-rule-id).
   end.
   else do:
     do v-ii = 1 to num-entries(p-reusable-string):
        find first buf_rule-call-param no-lock where
                 buf_rule-call-param.codex_id = p-codex-id
             and buf_rule-call-param.ruleset_id = p-ruleset-id
             and buf_rule-call-param.call_id = p-call-id
             and buf_rule-call-param.order_id = p-order-id
             and buf_rule-call-param.rule_id = p-rule-id
             and buf_rule-call-param.param-name = entry(v-ii, p-reusable-string)
             and buf_rule-call-param.p-index = 0
             no-error.
        if available buf_rule-call-param then do:
          assign
          v-reusable-string = v-reusable-string + (if v-reusable-string = '':u then '':U else {&delim-key}) +
                              buffer buf_rule-call-param:buffer-field(substitute("param-value-&1"
                                                                     , entry(1, buf_rule-call-param.param-data-type, "_"))):string-value
          .
        end.
     end.
   end.
   find first buf_temp-rule-reusable no-lock where
            buf_temp-rule-reusable.reusable-string = v-reusable-string
        and buf_temp-rule-reusable.rule_id = p-rule-id
        and buf_temp-rule-reusable.call_id = p-call-id
        and buf_temp-rule-reusable.codex_id = p-codex-id
        and buf_temp-rule-reusable.ruleset_id = p-ruleset-id  no-error.
   if available buf_temp-rule-reusable then do:
     p-can-run = no.
   end.
   create buf_temp-rule-reusable.
   assign
   buf_temp-rule-reusable.call_id = p-call-id
   buf_temp-rule-reusable.codex_id = p-codex-id
   buf_temp-rule-reusable.ruleset_id = p-ruleset-id
   buf_temp-rule-reusable.order_id = p-order-id
   buf_temp-rule-reusable.profile_id = p-profile-id
   buf_temp-rule-reusable.rule_id = p-rule-id
   buf_temp-rule-reusable.reusable-string = v-reusable-string
   .

end.

end procedure. /* check-reusable */

/* $Workfile$ e n d */