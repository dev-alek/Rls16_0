block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-rule-id as integer no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-upper-rule-id as integer no-undo .
define input parameter        p-root-rule-id as integer no-undo .
define input parameter        p-reusable-params as character no-undo .
define input parameter        p-salience as integer no-undo .
define input parameter        p-name       as character no-undo .
define input parameter        p-documentation  as character no-undo .
define input parameter        p-no-save-mode as integer no-undo .
define input parameter        p-hidden-content as integer no-undo .
define input parameter        p-image-file-name as character no-undo .
define temp-table tt-rule no-undo like ub.rule
field level as integer.
DEFINE INPUT PARAMETER TABLE FOR tt-rule.
define temp-table tt-rule-script no-undo like ub.rule-script
field level as integer
field gen-order as character
field upper_rule_id as integer
.
DEFINE INPUT PARAMETER TABLE FOR tt-rule-script.
define temp-table tt-rule-i-script no-undo like ub.rule-i-script.
DEFINE INPUT PARAMETER TABLE FOR tt-rule-i-script.
define temp-table tt-ruledict-param no-undo like ub.ruledict-param.
DEFINE INPUT PARAMETER TABLE FOR tt-ruledict-param.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение rule".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }

define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable glog as logical no-undo .
define variable v-entry-id as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-num-params as integer no-undo .
define variable v-is-admin-mode as logical no-undo .
define buffer buf_rule for ub.rule.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_ruleset for ub.ruleset.
define buffer buf_rule-script for ub.rule-script.
define buffer buf_rule-i-script for ub.rule-i-script.
define buffer tree_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer last_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.

if num-entries(p-mode) > 1 then do:
  assign
  v-is-admin-mode = logical(entry(2, p-mode)) no-error .
  p-mode = entry(1, p-mode).
end.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_rule
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = {&add-def} then do:
    find first buf_rule no-lock where
             buf_rule.rule_id = p-rule-id no-error.
    if available buf_rule then do:
      assign
      v-mess = "Уже существует провило c таким id".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_rule.
    assign
    buf_rule.rule_id = p-rule-id
    buf_rule.upper_rule_id = p-upper-rule-id
    buf_rule.root_rule_id = p-root-rule-id
    buf_rule.codex_id = p-codex-id
    buf_rule.sts = integer({&new-status-int})
    .
    run gen-key-rec in this-procedure ( input {&table_rule}
                                        ,input buffer buf_rule:handle
                                        ,output v-uniq-key-rec).
    assign
    buf_rule.uniq-key-rec = v-uniq-key-rec
    .
    find first buf_ruledict where
              buf_ruledict.entry-type = {&rdict-etype-rule}
          and buf_ruledict.uniq-key-rec =  v-uniq-key-rec no-error.
    if not available buf_ruledict then do:
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
    buf_ruledict.script-al = string(buf_rule.rule_id, "999999999":U)
    buf_ruledict.script-nl = buf_rule.name
    v-entry-id = buf_ruledict.entry-id
    .
  end.
  if p-mode = {&update} then do:
    find first buf_rule exclusive-lock where
              recid(buf_rule) = p-rec .
    if buf_rule.sts = integer({&to-delete-status-int})
    or buf_rule.sts = integer({&req-to-del-int})
    then do:
&scop status-code string(buf_rule.sts)
      assign
      v-mess = substitute("Правило находится в статусе &1, изменение невозможно"
                         , {&rule-status-int-name}
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_ruledict where
              buf_ruledict.entry-type = {&rdict-etype-rule}
          and buf_ruledict.uniq-key-rec =  buf_rule.uniq-key-rec no-error.
    IF NOT AVAILABLE BUF_RULEDICT THEN DO:
      assign
      v-mess = substitute("Не найден термин в словаре для правила").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).

    END.
    v-entry-id = buf_ruledict.entry-id.
    if buf_rule.sts <> integer({&new-status-int}) then do:
      if p-silent then do:
&scop status-code string(buf_rule.sts)
        assign
        v-mess = substitute("Правило находится в статусе &1, изменение невозможно"
                             , {&rule-status-int-name}
                             ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
      else do:
&scop status-code string(buf_rule.sts)
        message
        substitute("Правило находится в статусе &1, можно изменить только название и описание правила&2" +
                   "Продолжить?"
                   , {&rule-status-int-name}
                   , {&new-line}
                   )
        view-as alert-box question buttons YES-NO update glog.
        if not glog then do:
          return.
        end.
      end.
    end.
    if buf_rule.rule_id <> p-rule-id
    or buf_rule.upper_rule_id <> p-upper-rule-id
    or buf_rule.codex_id <> p-codex-id
    or buf_rule.root_rule_id <> p-root-rule-id
    then do:
      assign
      v-mess = substitute("Для уже существующего правила невозможно изменение id, id правила-родителя, id корневого правила и кодекса&1" +
                              "старое значение id, id правила-родителя, корневого правила и кодекса: &2, &3, &4 и &5"
                              , {&new-line}
                              , buf_rule.rule_id
                              , buf_rule.upper_rule_id
                              , buf_rule.root_rule_id
                              , buf_rule.codex_id
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_rule.reusable-params <> p-reusable-params
    and buf_rule.reusable-params = "0" then do:
      find first buf_rule-by-call no-lock where
                buf_rule-by-call.rule_id = buf_rule.rule_id no-error.
      if available buf_rule-by-call then do:
        assign
        v-mess = substitute("Для уже существующего правила невозможно изменение свойства <ВЫПОЛНЯЕТСЯ МНОГОКРАТНО>,&1" +
                                "если существуют вызовы этого правила"
                                , {&new-line}
                                )
        .
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'reusable':U).

      end.
    end.
  end.
  find first buf_ruleset no-lock where
            buf_ruleset.codex_id = p-codex-id
          and buf_ruleset.ruleset_id = 0 no-error.
  if not available buf_ruleset then do:
    assign
    v-mess = substitute("Не найден кодекс &1", p-codex-id
                            )
    .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'CODEX_ID':U).

  end.
  if p-upper-rule-id = 0
  and p-salience <> 0 THEN DO:
    assign
    v-mess = substitute("Для корневого правила порядок выполнения всегда должен = 0"
                            )
    .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'salience':U).
  END.
  assign
  buf_rule.name = p-name
  buf_rule.documentation = p-documentation
  buf_rule.image-file-name = p-image-file-name
  buf_rule.reusable-params = (if buf_rule.sts = integer({&new-status-int}) or v-is-admin-mode
                      then p-reusable-params
                      else buf_rule.reusable-params)
  buf_rule.salience = (if buf_rule.sts = integer({&new-status-int})
                       then p-salience
                       else buf_rule.salience)
  buf_rule.no-save-mode = (if buf_rule.sts = integer({&new-status-int})
                          then p-no-save-mode
                          else buf_rule.no-save-mode)
  buf_rule.hidden-content = p-hidden-content
  .
  if v-is-admin-mode or buf_rule.sts = integer({&new-status-int})  then do:
    for each tt-rule
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first tree_rule where
                tree_rule.rule_id = tt-rule.rule_Id no-error.
      if not available tree_rule then do:
        create tree_rule.
      end.
      if tt-rule.rule_id <> p-rule-id then
      buffer-copy tt-rule to tree_rule.
    end.
    for each tree_rule where tree_rule.root_rule_id = buf_rule.rule_id
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first tt-rule where
                tt-rule.rule_id = tree_rule.rule_Id no-error.
      if not available tt-rule then do:
        delete tree_rule.
      end.
    end.
    for each tt-ruledict-param
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first buf_ruledict-param where
                buf_ruledict-param.entry-id = v-entry-id
            and buf_ruledict-param.param-num = tt-ruledict-param.param-num
             no-error.
      if not available buf_ruledict-param then do:
        create buf_ruledict-param.
      end.
      buffer-copy tt-ruledict-param
      except entry-id
      to buf_ruledict-param
      assign
      buf_ruledict-param.entry-id = v-entry-id
      tt-ruledict-param.entry-id = v-entry-id
      .
    end.
    assign
    v-num-params = 0.
    for each buf_ruledict-param where buf_ruledict-param.entry-id = v-entry-id
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first tt-ruledict-param where
                tt-ruledict-param.entry-id = buf_ruledict-param.entry-id
            and tt-ruledict-param.param-num = buf_ruledict-param.param-num
             no-error.
      if not available tt-ruledict-param then do:
        delete buf_ruledict-param.
      end.
      assign
      v-num-params = v-num-params + 1
      .
    end.
    buf_rule.num-params = string(v-num-params)
    .
    for each tt-rule-i-script
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first buf_rule-i-script where
                buf_rule-i-script.root_rule_id = tt-rule-i-script.root_rule_id
            and buf_rule-i-script.i-script-name = tt-rule-i-script.i-script-name
            and buf_rule-i-script.script_id = tt-rule-i-script.script_id no-error.
      if not available buf_rule-i-script then do:
        create buf_rule-i-script.
      end.
      buffer-copy tt-rule-i-script to buf_rule-i-script.
    end.
    for each buf_rule-i-script where buf_rule-i-script.root_rule_i = buf_rule.rule_id
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first tt-rule-i-script where
                tt-rule-i-script.root_rule_id = buf_rule-i-script.root_rule_id
            and tt-rule-i-script.i-script-name = buf_rule-i-script.i-script-name
            and tt-rule-i-script.script_id = buf_rule-i-script.script_id no-error.
      if not available tt-rule-i-script then do:
        delete buf_rule-i-script.
      end.
    end.
    for each tt-rule-script
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first buf_rule-script where
              buf_rule-script.script_id = tt-rule-script.script_id
            and buf_rule-script.language = tt-rule-script.language no-error.
      if not available buf_rule-script then do:
        create buf_rule-script.
      end.
      buffer-copy tt-rule-script to buf_rule-script.
    end.
    for each buf_rule-script where buf_rule-script.root_rule_id = buf_rule.rule_id
    on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      find first tt-rule-script where
               tt-rule-script.script_id = buf_rule-script.script_id
            and tt-rule-script.language = buf_rule-script.language no-error.
      if not available tt-rule-script then do:
        delete buf_rule-script.
      end.
    end.
  end.
  p-rec = recid(buf_rule).
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Правило: id &1:&2&3"
                         , p-rule-id
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.