block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись связки параметры профайла-параметры правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/07
Author: Bakhtadze Natalya
Creation date: 05/25/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rp-rule-param OLD old_rp-rule-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись связки параметры профайла-параметры правила".
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
{ gbl/cur-time.i }
{ gbl/key-rec.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-param-num as integer no-undo .
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_rule for ub.rule.
define buffer rule_ruledict for ub.ruledict.
define buffer rule_ruledict-param for ub.ruledict-param.
define buffer buf_c-rule-profile for ub.c-rule-profile.
define buffer buf_c-rp-rule-param for ub.c-rp-rule-param.


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
      "Запрещено  создавать связки ПАРАМЕТР ПРОФАЙЛА - ПАРАМЕТР ПРАВИЛА в УБД"
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
    if not available buf_ruledict-param then do:
      find first buf_rule share-lock where
                buf_rule.rule_id = ub.rp-rule-param.rule_id.
      find first rule_ruledict no-lock where
                rule_ruledict.entry-type = {&rdict-etype-rule}
            and rule_ruledict.uniq-key-rec = buf_rule.uniq-key-rec no-error .
      if not available rule_ruledict then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("Не найдена запись в словаре правил для правила &1"
                  , buf_rule.rule_id
                  )
        view-as alert-box error .
        undo main-block, return error .
      end.
      find first rule_ruledict-param where
                rule_ruledict-param.entry-id = rule_ruledict.entry-id
            and rule_ruledict-param.language = rule_ruledict.language
            and rule_ruledict-param.param-name = ub.rp-rule-param.rule-param-name no-error.
      if not available rule_ruledict-param then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("Не найдена запись в словаре правил для параметра &1 правила &2"
                  , ub.rp-rule-param.rule-param-name
                  , buf_rule.rule_id
                  , {&new-line})
        view-as alert-box error .
        undo main-block, return error .
      end.
      do v-param-num = 1 to 999999999:
        find first buf_ruledict-param no-lock where
                buf_ruledict-param.entry-id = buf_ruledict.entry-id
            and buf_ruledict-param.language = buf_ruledict.language
            and buf_ruledict-param.param-num = v-param-num no-error .
        if not available buf_ruledict-param then do:
           leave.
        end.
      end.
      if ub.rp-rule-param.rp-param-name > '' then do:
      create buf_ruledict-param.
      buffer-copy rule_ruledict-param
      except param-name
      entry-id
      language
      param-num
      to buf_ruledict-param
      assign
      buf_ruledict-param.entry-id = buf_ruledict.entry-id
      buf_ruledict-param.language = buf_ruledict.language
      buf_ruledict-param.param-num = v-param-num
      buf_ruledict-param.param-name = ub.rp-rule-param.rp-param-name
      .
    end.
  end.
  end.
  if not g#news
  or g#db-num <> 0 then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-rp-rule-param.
    assign
    buf_c-rp-rule-param.profile_id         = ub.rp-rule-param.profile_id
    buf_c-rp-rule-param.codex_id           = ub.rp-rule-param.codex_id
    buf_c-rp-rule-param.ruleset_id         = ub.rp-rule-param.ruleset_id
    buf_c-rp-rule-param.rp_order_id        = ub.rp-rule-param.rp_order_id
    buf_c-rp-rule-param.rule_id            = ub.rp-rule-param.rule_id
    buf_c-rp-rule-param.rule-param-name    = ub.rp-rule-param.rule-param-name
    buf_c-rp-rule-param.rp-param-name      = ub.rp-rule-param.rp-param-name
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
  if not g#news
  and g#db-num = 0
  then do:
    run str/callnews.p
      (input {&table_rp-rule-param}
      ,input (buffer ub.rp-rule-param:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_rp-rule-param}
        , input ( buffer ub.rp-rule-param:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end. /*doe*/