block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение rule-process

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/15/08
Author: Bakhtadze Natalya
Creation date: 07/15/08

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-pchain-type as character no-undo .
define input parameter        p-pchain-id as character no-undo .
define input parameter        p-start-from as integer no-undo .
define input parameter        p-link-id as integer no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-run-db0 as integer no-undo .
define input parameter        p-run-rdb as integer no-undo .
define input parameter        p-link-btwn-profiles as integer no-undo .
define input parameter        p-is-export as integer no-undo .
define input parameter        p-is-import as integer no-undo .
define input parameter        p-needs-efile as integer no-undo .
define input parameter        p-needs-ifile as integer no-undo .
define input parameter        p-is-routing as integer no-undo .
define input parameter        p-is-esys-import as integer no-undo .
define input parameter        p-main-link as integer no-undo .
define input parameter        p-can-be-start as integer no-undo .
define input parameter        p-documentation as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение rule-process".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-entry-id as integer no-undo .
define buffer buf_rule-process for ub.rule-process.
define buffer buf_ruleset for ub.ruleset.

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
do for buf_rule-process
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    find first buf_rule-process no-lock where
             buf_rule-process.pchain-type = p-pchain-type
         and buf_rule-process.pchain-id = p-pchain-id
         and buf_rule-process.start-from = p-start-from
         and buf_rule-process.link-id = p-link-id
               no-error.
    if available buf_rule-process then do:
      assign
      v-mess = "Уже существует такое звено".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if lookup( entry(1, p-pchain-type, "_") , {&pchain-type-list}) = 0 then do:
      assign
      v-mess = substitute("Неверный тип процесса &1", p-pchain-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_rule-process.
    assign
    buf_rule-process.pchain-type = p-pchain-type
    buf_rule-process.pchain-id = p-pchain-id
    buf_rule-process.start-from = p-start-from
    buf_rule-process.link-id = p-link-id

    .
  end.
  if p-mode = {&update} then do:
    find first buf_rule-process exclusive-lock where
              recid(buf_rule-process) = p-rec .
    if buf_rule-process.pchain-type <> p-pchain-type
    or buf_rule-process.pchain-id <> p-pchain-id
    or buf_rule-process.start-from <> p-start-from
    or buf_rule-process.link-id <> p-link-id
    then do:
      assign
      v-mess = substitute("Для уже существующего звена процесса невозможно изменение тип процесса, id, места старта и ID звена&1"
                              , {&new-line}
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  find first buf_ruleset no-lock where
            buf_ruleset.codex_id = p-codex-id
        and buf_ruleset.ruleset_id = p-ruleset-id no-error.
  if not available buf_ruleset then do:
    assign
    v-mess = substitute("Не найден набор правил &2 в кодексе &1"
                            ,p-codex-id
                            ,p-ruleset-id)
    .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  assign
  buf_rule-process.pchain-type = p-pchain-type
  buf_rule-process.pchain-id = p-pchain-id
  buf_rule-process.start-from = p-start-from
  buf_rule-process.link-id = p-link-id
  buf_rule-process.codex_id = p-codex-id
  buf_rule-process.ruleset_id = p-ruleset-id
  buf_rule-process.run-db0 = p-run-db0
  buf_rule-process.run-rdb = p-run-rdb
  buf_rule-process.link-btwn-profiles = p-link-btwn-profiles
  buf_rule-process.is-export = p-is-export
  buf_rule-process.is-import = p-is-import
  buf_rule-process.needs-efile = p-needs-efile
  buf_rule-process.needs-ifile = p-needs-ifile
  buf_rule-process.is-routing = p-is-routing
  buf_rule-process.is-esys-import = p-is-esys-import
  buf_rule-process.main-link = p-main-link
  buf_rule-process.can-be-start = p-can-be-start
  buf_rule-process.documentation = p-documentation
  p-rec = recid(buf_rule-process)
  .
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Звено процесса: тип &1 id &2 Старт из &3 link-id &4&5:&6"
                         , p-pchain-type
                         , p-pchain-id
                         , p-start-from
                         , p-link-id
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