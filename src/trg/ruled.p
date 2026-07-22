block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление правила

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/16/06
Author: Bakhtadze Natalya
Creation date: 08/16/06

*/


TRIGGER PROCEDURE FOR DELETE OF ub.rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление правила".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.rule.rule_id
                         ) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-mess as character no-undo .
define variable v-ok as logical no-undo .
define buffer buf_c-rule for ub.c-rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_rule-by-set for ub.rule-by-set .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule for ub.rule.
define buffer buf_rule-script for ub.rule-script.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  /*проверим ссылки*/
  if ub.rule.upper_rule_id = 0 then do:
    if ub.rule.sts <> integer({&new-status-int})
    and ub.rule.sts <> integer({&ready-status-int})
    and ub.rule.sts <> integer({&deleted-status-int})
    and g#news = no
    then do:
&scop status-code string(ub.rule.sts)
       message
       "Нельзя удалить правило" skip
       "правило находится в статусе" {&rule-status-int-name}
       view-as alert-box error .
       undo, return error .

    end.
    if not g#news then do:
      run trg/rule-chk.p ( input {&deletion}
                          ,input ub.rule.rule_id
                          ,output v-ok
                          ,output v-mess
                          ) no-error.
      if error-status:error
      or not v-ok then do:
        message
        "Нельзя удалить правило" skip
        error-status:get-message(1) skip
        v-mess
        view-as alert-box error .
        undo, return error .
      end.
    end.
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
  end.
  for each buf_rule where
        buf_rule.upper_rule_id = ub.rule.rule_id
  on error undo main-block, return error :
     delete buf_rule.
  end.
  for each buf_rule-script where
        buf_rule-script.rule_id = ub.rule.rule_id
  on error undo main-block, return error :
     delete buf_rule-script.
  end.
  if ub.rule.upper_rule_id = 0 then do:
    if not g#news
    or g#db-num <> 0 then do:
      run cur-time in this-procedure ( output v-date, output v-time).
      create buf_c-rule.
      buffer-copy ub.rule to buf_c-rule
      assign
      buf_c-rule.action             = integer({&hn-delete})
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
    if not g#news
    and g#db-num = 0
    then do:
      run nws/cmd-del.p
        ( input {&table_rule}
        ,input (buffer ub.rule:handle)
        ,input "":U
        ) no-error .
      if error-status :error then do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_rule}
        , input ( buffer ub.rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.