block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение привязки profile к profile

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/09
Author: Bakhtadze Natalya
Creation date: 10/20/09

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-profile-id as integer no-undo .
define input parameter        p-child-profile-id as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение привязки profile к profile".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruleset for ub.ruleset.
define buffer buf_profile-by-profile for ub.profile-by-profile.
define buffer buf_rule-profile for ub.rule-profile.

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

  find first buf_rule-profile no-lock where
            buf_rule-profile.profile_id = p-profile-id no-error.
  if not available buf_rule-profile then do:
    assign
    v-mess = substitute("Не найден профайл &1", p-profile-id).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if buf_rule-profile.profile-type <> {&cmb} then do:
    assign
    v-mess = substitute("Алгоритм &1 должен быть комбинированным", p-profile-id).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  find first buf_rule-profile no-lock where
            buf_rule-profile.profile_id = p-child-profile-id no-error.
  if not available buf_rule-profile then do:
    assign
    v-mess = substitute("Не найден профайл &1", p-child-profile-id).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if buf_rule-profile.profile-type = {&cmb} then do:
    assign
    v-mess = substitute("Алгоритм &1 не должен быть комбинированным", p-child-profile-id).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if p-mode = {&add-def} then do:
    create buf_profile-by-profile.
    assign
    buf_profile-by-profile.child-profile_id = p-child-profile-id
    buf_profile-by-profile.profile_id = p-profile-id
    p-rec = recid(buf_profile-by-profile)
    .
  end.
  else do:
    find first buf_profile-by-profile exclusive-lock where
              recid(buf_profile-by-profile) = p-rec .
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Привязка профайла к профайлу:&1профайл &2 подчиненный профайл &3"
                         , {&new-line}
                         , p-profile-id
                         , p-child-profile-id
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