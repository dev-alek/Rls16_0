/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История для раскладок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/08
Author: Bakhtadze Natalya
Creation date: 10/24/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }

procedure layouth_create-layout_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define parameter buffer buf_layout for ub.layout.
define output parameter p-chip-num as integer no-undo .
define variable v-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_c-layout for ub.c-layout.

do
on error undo, return error
:

  run cur-time in this-procedure ( output v-today, output v-time).
  find last buf_c-layout no-lock where
            buf_c-layout.layout-id = p-layout-id
       and  buf_c-layout.corr-user-db-num = g#db-num
       use-index pi no-error.
  assign
  v-chip-num = (if available buf_c-layout
                then buf_c-layout.chip-num + 1
                else 0).
  create buf_c-layout.
  if available buf_layout
  and p-mode <> {&add-def}
  then do:
    buffer-copy buf_layout
    to buf_c-layout.
  end.
  if not available buf_layout then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  if p-mode = {&add-def} then do:
    assign
    buf_c-layout.layout-id = p-layout-id
    .
  end.
  assign
  buf_c-layout.subject = {&table_layout}
  buf_c-layout.action = (if p-mode = {&add-def}
                         then integer({&hn-create})
                         else (if p-mode = {&update}
                               then integer({&hn-update})
                               else integer({&hn-delete})
                               )
                        )
  buf_c-layout.chip-num = v-chip-num
  buf_c-layout.corr-user-db-num = g#db-num
  buf_c-layout.corr-user-name = g#userid
  buf_c-layout.corr-date = v-today
  buf_c-layout.corr-time = v-time
  p-chip-num = v-chip-num
  .
end.
end procedure. /* layouth_create-layout_h */


procedure layouth_create-layout-elem-rule_h :
define input parameter p-mode as character no-undo .
define input parameter p-layout-id as character no-undo .
define input parameter p-mode-id as character no-undo .
define input parameter p-widget-id as character no-undo .
define parameter buffer buf_layout-elem-rule for ub.layout-elem-rule.
define input parameter p-chip-num as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_c-layout-elem-rule for ub.c-layout-elem-rule.

do
on error undo, return error
:

  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-layout-elem-rule.
  if available buf_layout-elem-rule
  and p-mode <> {&add-def}
  then do:
    buffer-copy buf_layout-elem-rule
    to buf_c-layout-elem-rule.
  end.
  if p-mode = {&add-def} then do:
    assign
    buf_c-layout-elem-rule.layout-id = p-layout-id
    buf_c-layout-elem-rule.mode-id = p-mode-id
    buf_c-layout-elem-rule.widget-id = p-widget-id
    .
  end.
  assign
  buf_c-layout-elem-rule.subject = {&table_layout-elem-rule}
  buf_c-layout-elem-rule.action = (if p-mode = {&add-def}
                         then integer({&hn-create})
                         else (if p-mode = {&update}
                               then integer({&hn-update})
                               else integer({&hn-delete})
                               )
                        )
  buf_c-layout-elem-rule.chip-num = p-chip-num
  buf_c-layout-elem-rule.corr-user-db-num = g#db-num
  buf_c-layout-elem-rule.corr-user-name = g#userid
  buf_c-layout-elem-rule.corr-date = v-today
  buf_c-layout-elem-rule.corr-time = v-time
  .

end.

end procedure. /* layouth_create-layout-elem-rule_h */

procedure layouth_create-rule-call-param_h :
define input parameter p-mode as character no-undo .
define input parameter p-call#-id as integer no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-param-name as character no-undo .
define input parameter p-index as integer no-undo .
define input parameter p-call-id as character no-undo .
define parameter buffer buf_rule-call-param for ub.rule-call-param.
define input parameter p-chip-num as integer no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_c-rule-call-param for ub.c-rule-call-param.

do
on error undo, return error
:

  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_c-rule-call-param.
  if available buf_rule-call-param
  and p-mode <> {&add-def}
  then do:
    buffer-copy buf_rule-call-param
    to buf_c-rule-call-param.
  end.
  if p-mode = {&add-def} then do:
    assign
    buf_c-rule-call-param.call#_id = p-call#-id
    buf_c-rule-call-param.codex_id = p-codex-id
    buf_c-rule-call-param.ruleset_id = p-ruleset-id
    buf_c-rule-call-param.order_id = p-order-id
    buf_c-rule-call-param.param-name = p-param-name
    buf_c-rule-call-param.p-index = p-index
    buf_c-rule-call-param.call_id = p-call-id
    .
  end.
  assign
  buf_c-rule-call-param.action = (if p-mode = {&add-def}
                                  then integer({&hn-create})
                                  else (if p-mode = {&deletion}
                                        then integer({&hn-delete})
                                        else integer({&hn-update})
                                        )
                                  )
  buf_c-rule-call-param.chip-num = p-chip-num
  buf_c-rule-call-param.corr-user-db-num = g#db-num
  buf_c-rule-call-param.corr-user-name = g#userid
  buf_c-rule-call-param.corr-date = v-today
  buf_c-rule-call-param.corr-time = v-time
  .

end.

end procedure. /* layouth_create-rule-call-param_h */




/* $Workfile$ e n d */