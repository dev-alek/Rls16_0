block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление СКРИПТА ДЛЯ ОБЪЕКТА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/06
Author: Bakhtadze Natalya
Creation date: 10/04/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.prop-script.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление СКРИПТА ДЛЯ ОБЪЕКТА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.prop-script.dtm-code
                         , ub.prop-script.language
                         , ub.prop-script.script-name
                         , ub.prop-script.revis_id
                         ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer buf_pscript-ruleset for ub.pscript-ruleset.
define buffer buf_c-prop-script for ub.c-prop-script.
define buffer buf_c-prop-head for ub.c-prop-head.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_rule-i-script no-lock where
            buf_rule-i-script.script-name = ub.prop-script.script-name
        and buf_rule-i-script.dtm-code = ub.prop-script.dtm-code  no-error.
  if available buf_rule-i-script  then do:
    message
    substitute("Невозможно удалить СКРИПТ &1&2" +
               "СКРИПТ привязан к правилу &3"
               , ub.prop-script.script-name
               , {&new-line}
               , buf_rule-i-script.root_rule_id
               )
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_pscript-ruleset no-lock where
            buf_pscript-ruleset.dtm-code = ub.prop-script.dtm-code
        and buf_pscript-ruleset.language = ub.prop-script.language
        and buf_pscript-ruleset.script-name = ub.prop-script.script-name  no-error.
  if available buf_pscript-ruleset  then do:
    message
    substitute("Невозможно удалить СКРИПТ &1&2" +
               "СКРИПТ привязан к своду правил &3 кодекс &4"
               , ub.prop-script.script-name
               , {&new-line}
               , buf_pscript-ruleset.ruleset_id
               , buf_pscript-ruleset.codex_id)
    view-as alert-box error .
    undo main-block, return error .
  end.
  for each buf_ruledict where
        buf_ruledict.entry-type = {&rdict-etype-prop-script}
    and buf_ruledict.uniq-key-rec = ub.prop-script.uniq-key-rec
  on error undo main-block, return error:
    for each buf_ruledict-param where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
    on error undo main-block, return error:
      delete buf_ruledict-param.
    end.
    delete buf_ruledict.
  end.
  if not g#news
  or g#db-num > 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-prop-script.
    buffer-copy ub.prop-script to buf_c-prop-script
    assign
    buf_c-prop-script.dtm-code           = ub.prop-script.dtm-code
    buf_c-prop-script.language           = ub.prop-script.language
    buf_c-prop-script.script-name        = ub.prop-script.script-name
    buf_c-prop-script.revis_id           = ub.prop-script.revis_id
    buf_c-prop-script.chip-num           = next-value (s-ref-corr-chip, {&db-name_schema})
    buf_c-prop-script.corr-time          = v-time
    buf_c-prop-script.corr-user-db-num   = g#db-num
    buf_c-prop-script.corr-user-name     = g#userid
    buf_c-prop-script.corr-date          = v-date
    .
    if ub.prop-script.dtm-code > 0 then do:
      create buf_c-prop-head.
      buffer-copy buf_c-prop-script
      except uniq-key-rec
      to buf_c-prop-head
      assign
      buf_c-prop-head.action             = integer({&hn-delete})
      buf_C-prop-head.subject            = {&table_prop-script}
      .
    end.
  end.
  if not g#news
  and g#db-num = 0
  then do:
    run nws/cmd-del.p
      ( input {&table_prop-script}
       ,input (buffer ub.prop-script:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_prop-script}
        , input ( buffer ub.prop-script:handle )
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