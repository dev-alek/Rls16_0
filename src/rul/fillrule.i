/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ПРоцедура заполнения врем таблицы для правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/14/07
Author: Bakhtadze Natalya
Creation date: 10/14/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


DEFINE TEMP-TABLE tt-rule NO-UNDO LIKE ub.rule
       field level as integer.
DEFINE TEMP-TABLE tt-rule-script NO-UNDO LIKE ub.rule-script
       field level as integer
       field gen-order as character
       field upper_rule_id as integer
       field start-script_id as integer
       field end-script_id as integer
       field edge-type as character
       .
define temp-table temp-rule-i-script no-undo
like ub.rule-i-script.


PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-gen-order AS character NO-UNDO.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_rule-script FOR ub.RULE-script.
DEFINE BUFFER buf_tt-rule FOR tt-RULE.
DEFINE BUFFER buf_tt-rule-script FOR tt-RULE-script.
if p-level = 0 then do:
  find first buf_rule where
            buf_rule.rule_id = p-root-rule-id.
  create buf_tt-rule.
  buffer-copy buf_rule to buf_tt-rule.
  release buf_tt-rule.
end.
p-level = p-level + 1.
FOR EACH buf_rule NO-LOCK WHERE
        buf_rule.UPPER_rule_id = p-rule-id:
   find first buf_tt-rule where
            buf_tt-rule.rule_id = buf_rule.rule_id no-error.
   if not available buf_tt-rule then do:
    CREATE buf_tt-rule.
    buffer-copy buf_rule to buf_tt-rule.
    ASSIGN
    buf_tt-rule.root_rule_id = p-root-rule-id
    .
   end.
   buf_tt-rule.level = p-level.
   RUN fill-tables IN THIS-PROCEDURE (  INPUT buf_tt-rule.RULE_id
                                       ,INPUT p-root-rule-id
                                       ,INPUT-OUTPUT p-level
                                       ,INPUT (p-gen-order +
                                        STRING(p-level, "99") +
                                        STRING(buf_tt-rule.salience, "999"))).

END.
FOR EACH buf_rule-script NO-LOCK WHERE
        buf_rule-script.rule_id = p-rule-id:
   find first buf_tt-rule-script where
            buf_tt-rule-script.script_id = buf_rule-script.script_id
       AND  buf_tt-rule-script.LANGUAGE = buf_rule-script.LANGUAGE
       no-error.
   if not available buf_tt-rule-script
   then do:
    find first buf_tt-rule no-lock where
              buf_tt-rule.rule_id = buf_rule-script.rule_id.
    CREATE buf_tt-rule-script.
    buffer-copy buf_rule-script to buf_tt-rule-script.
    ASSIGN
    buf_tt-rule-script.root_rule_id = p-root-rule-id
    buf_tt-rule-script.upper_rule_id = buf_tt-rule.upper_rule_id
    .
   end.
   assign
   buf_tt-rule-script.level = p-level
   buf_tt-rule-script.gen-order = p-gen-order +
                                  STRING(buf_tt-rule-script.level, "99") +
                                  STRING(buf_tt-rule-script.salience, "999").
   .
END.

p-level = p-level - 1.


END PROCEDURE.




/* $Workfile$ e n d */