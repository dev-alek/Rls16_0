block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление ruledict

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Удаление ruledict".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .

define buffer buf_ruledict  for ub.ruledict.
define buffer buf_ruledict-param  for ub.ruledict-param.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Данная процедура не может вызываться в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find first buf_ruledict exclusive-lock where
        recid(buf_ruledict) = p-rec .
  find first buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id no-error .
  if available buf_ruledict-param then do:
  v-mess = substitute("К данному термину привязаны параметры&1&2&1Удаление невозможно"
                      , buf_ruledict-param.param-name
                      , {&new-line}
                      ).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else '':U).
  end.

  delete buf_ruledict.
end.

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Термин &1 (тип термина &2, относится к &3)"
                         , buf_ruledict.entry-id
                         , buf_ruledict.entry-type
                         , buf_ruledict.uniq-key-rec
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