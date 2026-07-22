/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Содержательная часть правила 1971

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/08
Author: Bakhtadze Natalya
Creation date: 08/03/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found as logical no-undo .
define variable v-discnt as decimal no-undo .
define variable v-rule-num as integer no-undo .
define variable v-nonunique as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-cycle as integer   no-undo .
define variable v-for-gds-obj-type as character no-undo .
define variable v-for-gds-obj-code as integer   no-undo .
define variable v-for-host-code as integer   no-undo .
define variable v-for-obj-type as character no-undo .
define variable v-for-obj-code as integer   no-undo .

{ str/cdrdcal1.i def }

define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.

assign
v-new-src-price = v-src-price
v-new-src-discnt = v-src-discnt
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

  if v-bh[{&chk-gds}]:buffer-field("without-gds-discnt"):buffer-value > 0 then return.

  find first buf_temp-discnt-role where
            buf_temp-discnt-role.codex_id = v-codex-id
        and buf_temp-discnt-role.ruleset_id = v-ruleset-id
        and buf_temp-discnt-role.order_id = p-order-id
        and buf_temp-discnt-role.rule_id = p-rule-id
        and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
        and buf_temp-discnt-role.subject-type = integer({&discnt-gds})
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
          v-for-host-code = v-current-host-code
          v-for-obj-type = ''
          v-for-obj-code = 0
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
          _dis-gds-rule:
          for each buf_dis-gds-rule no-lock where
                    buf_dis-gds-rule.obj-type = v-for-gds-obj-type
                and buf_dis-gds-rule.obj-code = v-for-gds-obj-code
                and buf_dis-gds-rule.gds-code = v-gds-code
                and buf_dis-gds-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-gds-rule.pos-type = p-pos-type-for-discnt:
            assign
            v-rule-num = buf_dis-gds-rule.rule-num
            v-templ-rl-root = buf_dis-gds-rule.templ-rl-root
            v-nonunique = buf_Dis-gds-rule.nonunique
            .
            if lookup(buf_dis-gds-rule.discnt-role, {&dgr-pcnt-kat}) > 0
            and (v-bh[{&chk-context}]:buffer-field("src-d-card"):buffer-value = ""
                 or
                 v-bh[{&chk-context}]:buffer-field("src-d-card"):buffer-value = ?)
            then next _dis-gds-rule.
            { rul/000001971i.i }
          end. /*      for each buf_dis-gds-rule no-lock where*/
          if v-found then leave _cycle.
        end.
        when {&table_dis-grp-rule} then do:
          _dis-grp-rule:
          for each buf_dis-grp-rule no-lock where
                   buf_dis-grp-rule.classif-type = {&table_sum-grp}
                and buf_dis-grp-rule.host-code = v-for-host-code
                and buf_dis-grp-rule.obj-type = v-for-obj-type
                and buf_dis-grp-rule.obj-code = v-for-obj-code
                and buf_dis-grp-rule.node-code = v-sum-grp-code
                and buf_dis-grp-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-grp-rule.pos-type = p-pos-type-for-discnt:
            assign
            v-rule-num = buf_dis-grp-rule.rule-num
            v-templ-rl-root = buf_dis-grp-rule.templ-rl-root
            v-nonunique = buf_Dis-grp-rule.nonunique
            .
            { rul/000001971i.i }
            if v-found then leave _cycle.
          end. /*      for each buf_dis-gds-rule no-lock where*/
        end. /*when {&table_dis-gds-rule}*/
        when {&table_dis-dc-rule} then do:
          case buf_temp-discnt-role.link-prop:
            when integer({&dr-no-rule}) then do:
              assign
              v-rule-num = buf_temp-discnt-role.templ-rl-root
              v-found = (v-bh[{&chk-context}]:buffer-field("src-d-card"):buffer-value > ""
                         and
                         v-bh[{&chk-context}]:buffer-field("d-pcnt"):buffer-value <> 0
                         )
              v-templ-rl-root = buf_temp-discnt-role.templ-rl-root
              v-nonunique = ''
              .
              if v-found then do:
                { rul/000001971i.i }
              end.
              if v-found then leave _cycle.
            end.
          end case.
        end.
        when {&table_dis-thbj-rule} then do:
          _dis-thbj-rule:
          for each buf_dis-thbj-rule no-lock where
                    buf_dis-thbj-rule.obj-type = v-for-gds-obj-type
                and buf_dis-thbj-rule.obj-code = v-for-gds-obj-code
                and buf_dis-thbj-rule.discnt-role = buf_temp-discnt-role.discnt-role
                and buf_dis-thbj-rule.pos-type = p-pos-type-for-discnt:
            case buf_temp-discnt-role.link-prop:
              when integer({&dr-appl-object}) then do:
                assign
                v-rule-num = buf_dis-thbj-rule.rule-num
                v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root
                v-nonunique = buf_Dis-thbj-rule.nonunique
                .
                { rul/000001971i.i }
              end.
            end case.
            if v-found then leave _cycle.
          end. /*      for each buf_dis-gds-rule no-lock where*/
          if v-found then leave _cycle.
        end. /*when {&table_dis-thbj-rule} then do:*/
      end case. /*      case buf_temp-discnt-role.table-name: */
    end. /*do v-cycle = 1 to 3 :*/
    if v-found and not p-add-discnts then do:
      leave _roles.
    end.
  end. /*if available buf_temp-discnt-role then do:*/
end. /*for each buf_temp-rule-call-param where*/


/* $Workfile$ e n d */