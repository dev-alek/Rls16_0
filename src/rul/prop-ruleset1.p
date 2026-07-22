block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение привязки prop-head к ruleset

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
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-is-dynamic as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки prop-head к ruleset".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruleset for dictdb.ruleset.
define buffer buf_prop-ruleset for dictdb.prop-ruleset.
define buffer buf_prop-head for dictdb.prop-head.

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

  if p-mode = {&add-def} then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = p-codex-id
          and buf_ruleset.ruleset_id = p-ruleset-id no-error.
    if not available buf_ruleset then do:
      assign
      v-mess = "Не найден ruleset c таким кодексом и набором правил".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_prop-head no-lock where
              buf_prop-head.dtm-code = p-dtm-code no-error.
    if not available buf_prop-head then do:
      assign
      v-mess = "Не найден prop-head c таким dtm-code".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_prop-ruleset.
    assign
    buf_prop-ruleset.codex_id = p-codex-id
    buf_prop-ruleset.ruleset_id = p-ruleset-id
    buf_prop-ruleset.dtm-code = p-dtm-code
    buf_prop-ruleset.is_dynamic = p-is-dynamic
    .
  end.
  if p-mode = {&update} then do:
    find first buf_prop-ruleset exclusive-lock where
              recid(buf_prop-ruleset) = p-rec .
    if buf_prop-ruleset.codex_id <> p-codex-id
    or buf_prop-ruleset.ruleset_id <> p-ruleset-id
    or buf_prop-ruleset.dtm-code <> p-dtm-code
    then do:
      assign
      v-mess = substitute("Для уже существующего prop-ruleset невозможно изменеие кодекса, набора правил и кода объекта &1" +
                              "старые значения кодекса и набора правил: &2, &3 и &4"
                              , {&new-line}
                              , buf_prop-ruleset.codex_id
                              , buf_prop-ruleset.ruleset_id
                              , buf_prop-ruleset.dtm-code
                              )
      .
    end.
  end.
  assign
  buf_prop-ruleset.is_dynamic = p-is-dynamic
  .
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("prop-ruleset кодекс: &1 набор: &2 объект &3: &4"
                         , p-codex-id
                         , p-ruleset-id
                         , p-dtm-code
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