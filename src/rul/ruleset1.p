block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение ruleset

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-codex-id as integer no-undo .
define input parameter        p-ruleset-id as integer no-undo .
define input parameter        p-name       as character no-undo .
define input parameter        p-documentation as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение ruleset".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
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
do for buf_ruleset
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = p-codex-id
          and buf_ruleset.ruleset_id = p-ruleset-id no-error.
    if available buf_ruleset then do:
      assign
      v-mess = "Уже существует ruleset c таким кодексом и набором правил".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-ruleset-id <> 0 then do:
      find first buf_ruleset no-lock where
                buf_ruleset.codex_id = p-codex-id
            and buf_ruleset.ruleset_id = 0 no-error.
      if not available buf_ruleset then do:
        assign
        v-mess = substitute("Не существует КОДЕКС &1", p-codex-id).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    create buf_ruleset.
    assign
    buf_ruleset.codex_id = p-codex-id
    buf_ruleset.ruleset_id = p-ruleset-id
    .
  end.
  if p-mode = {&update} then do:
    find first buf_ruleset exclusive-lock where
              recid(buf_ruleset) = p-rec .
    if buf_ruleset.codex_id <> p-codex-id
    or buf_ruleset.ruleset_id <> p-ruleset-id
    then do:
      assign
      v-mess = substitute("Для уже существующего ruleset невозможно изменеие кодекса и набора правил&1" +
                              "старые значения кодекса и набора правил: &2 и &3"
                              , {&new-line}
                              , buf_ruleset.codex_id
                              , buf_ruleset.ruleset_id)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_ruleset.name = p-name
  buf_ruleset.documentation = p-documentation
  p-rec = recid(buf_ruleset)
  .
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Кодекс правил: &1 набор правил: &2: &3"
                         , p-codex-id
                         , p-ruleset-id
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