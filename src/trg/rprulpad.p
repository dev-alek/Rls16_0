block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление связки параметры профайла-параметры правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/07
Author: Bakhtadze Natalya
Creation date: 05/25/07

*/

TRIGGER PROCEDURE FOR DELETE OF ub.rp-rule-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление связки параметры профайла-параметры правила".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                         , ub.rp-rule-param.profile_id
                         , ub.rp-rule-param.codex_id
                         , ub.rp-rule-param.ruleset_id
                         , ub.rp-rule-param.rule_id
                         , ub.rp-rule-param.rp_order_id
                         , ub.rp-rule-param.rule-param-name
                         , ub.rp-rule-param.rp-param-name
                         ) " }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ gbl/cur-time.i }
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_c-rule-profile for ub.c-rule-profile.
define buffer buf_c-rp-rule-param for ub.c-rp-rule-param.
define buffer other_rp-rule-param for ub.rp-rule-param.



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news then do:
    if g#db-num > 0 then do:
      message
      vss-workfile vss-revision vss-description skip
      "Запрещено  удалять связки ПАРАМЕТР ПРОФАЙЛА - ПАРАМЕТР ПРАВИЛА в УБД"
      view-as alert-box error .
      undo main-block, return error .
    end.
    find first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = ub.rp-rule-param.profile_id no-error .
    if not available buf_rule-profile then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Не найден профайл &1 для связки ПАРАМЕТР ПРОФАЙЛА - ПАРАМЕТР ПРАВИЛА&2" +
                 "профайл &1 кодекс &3 набор правил &4 порядок вызова &5 правило &6"
                 , ub.rp-rule-param.profile_id
                 , {&new-line}
                 ,ub.rp-rule-param.codex_id
                 ,ub.rp-rule-param.ruleset_id
                 ,ub.rp-rule-param.rp_order_id
                 ,ub.rp-rule-param.rule_id)
     view-as alert-box error .
     undo main-block, return error .
    end.
    run gen-key-rec in this-procedure (
                                        input {&table_rule-profile}
                                        ,input  buffer buf_rule-profile:handle
                                        ,output v-uniq-key-rec
                                        ).
    find first buf_ruledict where
              buf_ruledict.entry-type  = {&rdict-etype-rule-profile}
          and buf_ruledict.uniq-key-rec  = v-uniq-key-rec no-error.

    if not available buf_ruledict then do:
      message
      vss-workfile vss-revision vss-description skip
      substitute("Не найдена запись в словаре правил для профайла &1"
                 , ub.rp-rule-param.profile_id
                 )
     view-as alert-box error .
     undo main-block, return error .
    end.
    find current buf_ruledict exclusive-lock .
    find first buf_ruledict-param where
              buf_ruledict-param.entry-id = buf_ruledict.entry-id
          and buf_ruledict-param.param-name = ub.rp-rule-param.rp-param-name no-error  .
    if available buf_ruledict-param
    and not can-find (first other_rp-rule-param where
              other_rp-rule-param.profile_id = ub.rp-rule-param.profile_id
          /*and other_rp-rule-param.codex_id = ub.rp-rule-param.codex_id
          and other_rp-rule-param.ruleset_id = ub.rp-rule-param.ruleset_id
          */
          and other_rp-rule-param.rp-param-name = ub.rp-rule-param.rp-param-name
          and (other_rp-rule-param.rule_id <>  ub.rp-rule-param.rule_id
               or
               other_rp-rule-param.rp_order_id <>  ub.rp-rule-param.rp_order_id))
    then do:
      /*delete buf_ruledict-param.*/
    end.
  end.
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-rp-rule-param.
    assign
    buf_c-rp-rule-param.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-rp-rule-param.corr-time          = v-time
    buf_c-rp-rule-param.corr-user-db-num   = g#db-num
    buf_c-rp-rule-param.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-rp-rule-param.corr-date          = v-date
    .
    create buf_c-rule-profile.
    buffer-copy buf_c-rp-rule-param to buf_c-rule-profile
    assign
    buf_c-rule-profile.action = integer(if new(ub.rp-rule-param) then {&hn-create} else {&hn-update})
    buf_c-rule-profile.subject = {&table_rp-rule-param}
    .
  end.

end.