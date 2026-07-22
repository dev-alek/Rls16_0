block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/06
Author: Bakhtadze Natalya
Creation date: 08/16/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rule OLD old_rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись правила".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.rule.rule_id
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i }

define variable v-uniq-key-rec as character no-undo .
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer first_ruledict for ub.ruledict.
define buffer last_ruledict for ub.ruledict.
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_c-rule for ub.c-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news
  then do:
    if ub.rule.upper_rule_id = 0 then do:
      run gen-key-rec in this-procedure ( input {&table_rule}
                                          ,input buffer ub.rule:handle
                                          ,output v-uniq-key-rec).
      assign
      ub.rule.uniq-key-rec = v-uniq-key-rec
      .
      find first buf_ruledict where
                buf_ruledict.entry-type = {&rdict-etype-rule}
            and buf_ruledict.uniq-key-rec =  v-uniq-key-rec no-error.
      if not available buf_ruledict then do:
        find first first_ruledict exclusive-lock use-index pi.
        find last last_ruledict no-lock use-index pi.
        create buf_ruledict.
        assign
        buf_ruledict.entry-type = {&rdict-etype-rule}
        buf_ruledict.uniq-key-rec = v-uniq-key-rec
        buf_ruledict.entry-id = last_ruledict.entry-id + 1
        buf_ruledict.language = "ABL"
        .
      end.
      assign
      buf_ruledict.script-al = string(ub.rule.rule_id, "999999999":U)
      buf_ruledict.script-nl = ub.rule.name
      .
    end.
    else do:
      for each buf_ruledict where
            buf_ruledict.entry-type = {&rdict-etype-rule}
        and buf_ruledict.uniq-key-rec = ub.rule.uniq-key-rec
      on error undo main-block, return error:
        for each buf_ruledict-param where
              buf_ruledict-param.entry-id = buf_ruledict.entry-id
        on error undo main-block, return error:
          delete buf_ruledict-param.
        end.
        delete buf_ruledict.
      end.
    end. /*else if ub.rule.upper_rule_id = 0 then do:*/
  end. /*if not g#news*/
  if not g#news
  or g#db-num <> 0
  and ub.rule.upper_rule_id = 0
  then do:
    run cur-time in this-procedure ( output v-date, output v-time).
    create buf_c-rule.
    buffer-copy old_rule to buf_c-rule
    assign
    buf_c-rule.action             = integer(if new(ub.rule) then {&hn-create} else {&hn-update})
    buf_C-rule.subject            = {&table_rule}
    buf_c-rule.rule_id            = ub.rule.rule_id
    buf_c-rule.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-rule.corr-time          = v-time
    buf_c-rule.corr-user-db-num   = g#db-num
    buf_c-rule.corr-user-name     = (if g#news
                                    then {&nts-user}
                                    else g#userid)
    buf_c-rule.corr-date          = v-date
    .
  end.
  if not new(ub.rule) then do:
    buffer-compare old_rule to ub.rule
    case-sensitive
    save result in v-result.
  end.
  if not g#news
  and g#db-num = 0
  and ub.rule.sts <> integer({&new-status-int})
  and not ((v-result  = 'sts' and ub.rule.sts = integer({&to-delete-status-int}))
           or
           (v-result  = 'sts' and ub.rule.sts = integer({&req-to-del-int}))
         )
         /*последнее - выполняется по two-commit*/
  then do:
    run str/callnews.p
      (input {&table_rule}
      ,input (buffer ub.rule:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_rule}
        , input ( buffer ub.rule:handle )
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