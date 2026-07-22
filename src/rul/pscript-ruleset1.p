block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение привязки prop-script к ruleset

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
define input parameter        p-language as character no-undo .
define input parameter        p-script-name as character no-undo .
define input parameter        p-revis-id as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки prop-script к ruleset".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruleset for ub.ruleset.
define buffer buf_pscript-ruleset for ub.pscript-ruleset.
define buffer buf_prop-script for ub.prop-script.

if p-mode <> {&add-def}
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
    find first buf_prop-script no-lock where
              buf_prop-script.dtm-code = p-dtm-code
          and buf_prop-script.language = p-language
          and buf_prop-script.script-name = p-script-name
          and buf_prop-script.revis_id = p-revis-id   no-error.
    if not available buf_prop-script then do:
      assign
      v-mess = substitute("Не найден prop-script c кодом объекта &1, язык &2&3 название &4 версия &5"
                           , p-dtm-code
                           , p-language
                           , p-script-name
                           , p-revis-id
                           ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_pscript-ruleset no-lock where
              buf_pscript-ruleset.codex_id = p-codex-id
          and buf_pscript-ruleset.ruleset_id = p-ruleset-id
          and buf_pscript-ruleset.dtm-code = p-dtm-code
          and buf_pscript-ruleset.language = p-language
          and buf_pscript-ruleset.script-name = p-script-name
          and buf_pscript-ruleset.revis_id = p-revis-id no-error.
    if available buf_pscript-ruleset then do:
      assign
      v-mess = substitute("Уже есть привязка скипта &1 к кодексу &2 набору правил &3"
                          , p-script-name
                          , p-codex-id
                          , p-ruleset-id
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_pscript-ruleset.
    assign
    buf_pscript-ruleset.codex_id = p-codex-id
    buf_pscript-ruleset.ruleset_id = p-ruleset-id
    buf_pscript-ruleset.dtm-code = p-dtm-code
    buf_pscript-ruleset.language = p-language
    buf_pscript-ruleset.script-name = p-script-name
    buf_pscript-ruleset.revis_id = p-revis-id
    .
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Привязка СКРИПТА к набору правил кодекс: &1 набор правил: &2&3объект &4 язык &5 название &6&1&7"
                         , {&new-line}
                         , p-codex-id
                         , p-ruleset-id
                         , p-dtm-code
                         , p-language
                         , p-script-name
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