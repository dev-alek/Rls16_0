block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление rule-profile

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
define variable vss-description as character no-undo init "Удаление rule-profile".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-mess as character no-undo .
define buffer buf_rule-profile  for dictdb.rule-profile.
define buffer buf_rule-by-profile  for ub.rule-by-profile.
define buffer buf_rp-by-call for ub.rp-by-call.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_rule-profile exclusive-lock where
          recid(buf_rule-profile) = p-rec .
  find first buf_rule-by-profile no-lock where
            buf_rule-by-profile.profile_id = buf_rule-profile.profile_id no-error.
  if available buf_rule-by-profile then do:
    v-mess = substitute("Нельзя удалить профайл - есть привязаннле правило &1"
                       , buf_rule-by-profile.rule_id ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.

  find first buf_rp-by-call no-lock where
            buf_rp-by-call.profile_id = buf_rule-profile.profile_id no-error.
  if available buf_rp-by-call then do:
    v-mess = substitute("Нельзя удалить профайл - профайл испольуется в точке вызова &1"
                       , buf_rp-by-call.call_id).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.

  delete buf_rule-profile no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Профайл &1: &2"
                         , buf_rule-profile.profile_id
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