/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Содержательная часть правила 1973

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/08
Author: Bakhtadze Natalya
Creation date: 08/03/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found as logical no-undo .
define variable v-delta-discnt-r-b as decimal no-undo .
define variable v-delta-discnt-rubl as decimal no-undo .
define variable v-delta-discnt-base as decimal no-undo .
define variable v-delta-discnt-curr as decimal no-undo .

define variable v-rule-num as integer no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-cycle as integer   no-undo .
define variable v-for-gds-obj-type as character no-undo .
define variable v-for-gds-obj-code as integer   no-undo .
define variable v-for-host-code as integer   no-undo .
define variable v-for-obj-type as character no-undo .
define variable v-for-obj-code as integer   no-undo .
define variable v-qh as handle no-undo .
define variable v-line-type as integer   no-undo .
define variable v-ok as logical   no-undo .
{ str/cdrdcal1.i def }

define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
assign
v-new-curr-sum      = v-curr-sum
v-new-rubl-sum      = v-rubl-sum
v-new-base-sum      = v-base-sum
v-new-discnt-curr   = v-discnt-curr
v-new-discnt-rubl   = v-discnt-rubl
v-new-discnt-base   = v-discnt-base
.


_roles:
for each buf_temp-rule-call-param where
      buf_temp-rule-call-param.call_id = p-call-id
  and buf_temp-rule-call-param.codex_id = v-codex-id
  and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
  and buf_temp-rule-call-param.order_id = p-order-id
  and buf_temp-rule-call-param.rule_id = p-rule-id
  and buf_temp-rule-call-param.param-name = "p-discnt-roles"
  and buf_temp-rule-call-param.p-index > 0
  by buf_temp-rule-call-param.call_id
  by buf_temp-rule-call-param.codex_id
  by buf_temp-rule-call-param.ruleset_id
  by buf_temp-rule-call-param.order_id
  by buf_temp-rule-call-param.param-name
  by buf_temp-rule-call-param.p-index:

  find first buf_temp-discnt-role where
            buf_temp-discnt-role.codex_id = v-codex-id
        and buf_temp-discnt-role.ruleset_id = v-ruleset-id
        and buf_temp-discnt-role.order_id = p-order-id
        and buf_temp-discnt-role.rule_id = p-rule-id
        and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
        and buf_temp-discnt-role.subject-type = integer({&discnt-payment})
        no-error.

  if available buf_temp-discnt-role then do:
    _cycle:
    do v-cycle = 1 to 3 :
      if v-cycle = 1 then do:
        if buf_temp-discnt-role.has-obj = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = v-current-obj-type
          v-for-obj-code = v-current-obj-code
          v-for-gds-obj-type = v-current-obj-type
          v-for-gds-obj-code = v-current-obj-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 2 then do:
        if buf_temp-discnt-role.has-host = 1 then do:
          assign
          v-for-host-code = v-current-host-code
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-gds-obj-type = {&cmp}
          v-for-gds-obj-code = v-current-host-code
          .
        end.
        else do:
          next _cycle.
        end.
      end.
      if v-cycle = 3 then do:
        if buf_temp-discnt-role.has-glob = 1 then do:
          assign
          v-for-obj-type = ''
          v-for-obj-code = 0
          v-for-host-code = 0
          v-for-gds-obj-type = ''
          v-for-gds-obj-code = 0

          .
        end.
        else do:
          next _cycle.
        end.
      end.
      case buf_temp-discnt-role.table-name:
        when {&table_dis-gds-rule} then do:
          v-line-type = integer({&discnt-payment}).
          create query v-qh.
          v-ok = v-qh:set-buffers(v-bh[{&chk-gds}], (buffer buf_dis-gds-rule:handle)).
          v-ok = v-qh:QUERY-PREPARE(
                                    substitute('FOR EACH libthpos_chk-gds WHERE libthpos_chk-gds.doc-code = "&1", ' +
                                              'first buf_dis-gds-rule no-lock where buf_dis-gds-rule.gds-code = libthpos_chk-gds.gds-code ' +
                                              ' and  buf_dis-gds-rule.obj-type = "&2" ' +
                                              ' and buf_dis-gds-rule.obj-code = &3 ' +
                                              ' and buf_dis-gds-rule.discnt-role = "&4" ' +
                                              ' and buf_dis-gds-rule.pos-type = "&5" '
                                                                                      ,v-bh[{&chk-context}]:buffer-field("doc-code"):buffer-value
                                                                                      ,v-for-gds-obj-type
                                                                                      ,v-for-gds-obj-code
                                                                                      ,buf_temp-discnt-role.discnt-role
                                                                                      ,p-pos-type-for-discnt)).
          v-qh:QUERY-OPEN.
          _repeat:
          REPEAT :
            v-qh:GET-NEXT().
            IF v-qh:QUERY-OFF-END THEN LEAVE.
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            v-templ-rl-root = buf_dis-gds-rule.templ-rl-root
            .
            { rul/000001973i.i }
            if v-found then leave _repeat.
          END.
          v-qh:QUERY-CLOSE().
          DELETE OBJECT v-qh.
          if v-found then do:
            if buf_temp-discnt-role.discnt-role = {&dgr-without-disc} then do:
              v-found = no.
            end.
            leave _cycle.
          end.
        end.
        when {&table_dis-cp-rule} then do:
          v-line-type = integer({&discnt-payment}).
          _dis-thbj-rule:
          for each buf_dis-cp-rule no-lock where
                   buf_dis-cp-rule.host-code = v-for-host-code
                and buf_dis-cp-rule.obj-type = v-for-obj-type
                and buf_dis-cp-rule.obj-code = v-for-obj-code
                and buf_dis-cp-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-cp-rule.pos-type = p-pos-type-for-discnt
                and buf_dis-cp-rule.cdpay-code = v-cdpay-code
                and buf_dis-cp-rule.curr-code = v-curr-code
                :
            assign
            v-rule-num = buf_dis-cp-rule.rule-num
            v-templ-rl-root = buf_dis-cp-rule.templ-rl-root
            .
            { rul/000001973i.i }
            if v-found then leave _cycle.
          end. /*      for each buf_dis-gds-rule no-lock where*/
        end. /*when {&table_dis-gds-rule}*/
      end case. /*      case buf_temp-discnt-role.table-name: */
    end. /*do v-cycle = 1 to 3 :*/
    if v-found and not p-add-discnts then do:
      leave _roles.
    end.
  end. /*if available buf_temp-discnt-role then do:*/
end. /*for each buf_temp-rule-call-p*/


/* $Workfile$ e n d */