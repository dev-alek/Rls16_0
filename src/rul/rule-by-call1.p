block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение привязки rule к точке вызова

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-cmd-proc-handle as handle no-undo .
define input parameter        p-cmd-code as integer no-undo .
define input parameter        p-call#-id as integer no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-order-id as integer no-undo .
define input parameter        p-call-id as character no-undo .
define input parameter        p-rule-id as integer no-undo .
define input parameter        p-profile-id as integer no-undo .
define input parameter        p-once-more as integer no-undo .
define input parameter        p-is-dynamic as logical no-undo .
define input parameter        p-can-calc as logical no-undo .
define input parameter        p-algo-des as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки rule к точке вызова".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-cmp as logical no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-rec-ord as integer no-undo .
define buffer buf_ruleset for dictdb.ruleset.
define buffer buf_rule-by-call for dictdb.rule-by-call.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule for dictdb.rule.
define temp-table temp-rule-by-call no-undo like ub.rule-by-call.

if p-mode <> {&add-def}
and p-mode <> {&update}
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

_main:
do for buf_ruleset
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_ruleset no-lock where
            buf_ruleset.codex_id = p-codex-id
        and buf_ruleset.ruleset_id = p-ruleset-id no-error.
  if not available buf_ruleset then do:
    assign
    v-mess = "Не найден набор правил".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = p-profile-id no-error.
  if not available buf_rule-profile then do:
    assign
    v-mess = "Не найден профайл".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule no-lock where
            buf_rule.rule_id = p-rule-id no-error.
  if not available buf_rule then do:
    assign
    v-mess = "Не найдено правило c таким №".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule exclusive-lock where
            buf_rule.rule_id = p-rule-id no-error.
  if buf_rule.sts = integer({&new-status-int})
  or buf_rule.sts = integer({&deleted-status-int})
  or buf_rule.sts = integer({&to-delete-status-int})
  or buf_rule.sts = integer({&req-to-del-int}) then do:
&scop status-code string( buf_rule.sts)
    assign
    v-mess = substitute("Правило находится в статусе &1", {&rule-status-int-name}).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'sts':U).
  end.
  if p-mode = {&add-def} then do:
    find first buf_rule-by-call no-lock where
              buf_rule-by-call.call#_id = p-call#-id
          and buf_rule-by-call.codex_id = p-codex-id
          and buf_rule-by-call.ruleset_id = p-ruleset-id
          and buf_rule-by-call.order_id = p-order-id   no-error.
    if available buf_rule-by-call
    then do:
      assign
      v-mess = "Уже есть такая привязка правила к точке вызова".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_rule-by-call.
    assign
    buf_rule-by-call.call#_id = p-call#-id
    buf_rule-by-call.call_id = p-call-id
    buf_rule-by-call.codex_id = p-codex-id
    buf_rule-by-call.ruleset_id = p-ruleset-id
    buf_rule-by-call.order_id = p-order-id
    buf_rule-by-call.uniq-key-rec = v-uniq-key-rec
    p-rec = recid(buf_rule-by-call)
    .
    run gen-key-rec in this-procedure ( input {&table_rule-by-call}
                                    ,input buffer buf_rule-by-call:handle
                                    ,output v-uniq-key-rec).

  end. /*if p-mode = {&add-def} then do:*/

  if p-mode = {&update} then do:
    find first buf_rule-by-call exclusive-lock where
              recid(buf_rule-by-call) = p-rec .
    if buf_rule-by-call.codex_id <> p-codex-id
    or buf_rule-by-call.ruleset_id <> p-ruleset-id
    or buf_rule-by-call.call_id <> p-call-id
    or buf_rule-by-call.call#_id <> p-call#-id
    or buf_rule-by-call.order_id <> p-order-id
    then do:
      assign
      v-mess = substitute("Для уже существующей привязки правила невозможно изменение кодекса и набора правил&1" +
                          "идентификатора точки вызова и порядка вызова&1" +
                          "старые значения идентификатора точки вызова, кодекса, набора правил и порядка вызова:&1" +
                          "&2(&3) &4 &5 &6"
                          , {&new-line}
                          , buf_rule-by-call.call#_id
                          , buf_rule-by-call.call_id
                          , buf_rule-by-call.codex_id
                          , buf_rule-by-call.ruleset_id
                          , buf_rule-by-call.order_id
                          )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  create temp-rule-by-call.
  buffer-copy buf_rule-by-call to temp-rule-by-call.
  assign
  buf_rule-by-call.profile_id = p-profile-id
  buf_rule-by-call.once-more = p-once-more
  buf_rule-by-call.rule_id = p-rule-id
  buf_rule-by-call.is_dynamic  = p-is-dynamic
  buf_rule-by-call.can-calc  = p-can-calc
  buf_rule-by-call.algo-des  = p-algo-des
  .
  if buf_rule.sts <> integer({&used-status-int}) then do:
    buf_rule.sts = integer({&used-status-int}).
  end.
  buffer-compare buf_rule-by-call to temp-rule-by-call save result in v-cmp.
  if  valid-handle(p-cmd-proc-handle)
  and (p-mode = {&add-def}
      or v-cmp = no )
  then do:
    run add-dump in p-cmd-proc-handle
      (input p-cmd-code
      ,input {&table_rule-by-call}
      ,input '+update'
      ,input buffer buf_rule-by-call:handle
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      v-mess = substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,{&table_rule-by-call}
                                          ,p-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value
                                          ) .
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  p-rec = recid(buf_rule-by-call).
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("rule-by-call идент точки вызова &1(&2) кодекс &3 набор &4 порядок вызова &5&6:&7"
                         , p-call#-id
                         , p-call-id
                         , p-codex-id
                         , p-ruleset-id
                         , p-order-id
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