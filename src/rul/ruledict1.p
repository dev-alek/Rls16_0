block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение ruledict

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-entry-id as integer no-undo .
define input parameter        p-entry-type as character no-undo .
define input parameter        p-script-al       as character no-undo .
define input parameter        p-script-nl       as character no-undo .
define input parameter        p-documentation as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение ruledict".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.

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
do for buf_ruledict
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if lookup(p-entry-type, {&rdict-etype-list}) = 0
  and not (p-mode = {&update}  and p-entry-id = 0)
  then do:
      assign
      v-mess = "Неверное значение типа термина".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
  end.

  if p-mode = {&add-def} then do:
    if p-entry-id = 0 then do:
      find last buf_ruledict no-lock  no-error.
      assign
      p-entry-id = buf_ruledict.entry-id + 1.
    end.
    find first buf_ruledict no-lock where
             buf_ruledict.entry-id = p-entry-id no-error.
    if available buf_ruledict then do:
      assign
      v-mess = "Уже существует СТАТЬЯ c таким id".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_ruledict.
    assign
    buf_ruledict.entry-type = p-entry-type
    buf_ruledict.entry-id = p-entry-id
    .
  end.
  if p-mode = {&update} then do:
    find first buf_ruledict exclusive-lock where
              recid(buf_ruledict) = p-rec .
    if buf_ruledict.entry-id <> p-entry-id
    then do:
      assign
      v-mess = substitute("Для уже существующего термина невозможно изменение id&1" +
                              "старое значения id: &2"
                              , {&new-line}
                              , buf_ruledict.entry-id
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_ruledict.entry-type <> p-entry-type then do:
      find first buf_ruledict-param no-lock where
                buf_ruledict-param.entry-id = buf_ruledict.entry-id no-error.
      if available buf_ruledict-param then do:
      assign
      v-mess = substitute("Для уже существующего термина невозможно изменение типа,&1" +
                              "если имеется привязанный параметр:&1" +
                              "старое значение типа &2"
                              , {&new-line}
                              , buf_ruledict.entry-type
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).

      end.
    end.

  end.
  assign
  buf_ruledict.entry-type = p-entry-type
  buf_ruledict.script-nl = p-script-nl
  buf_ruledict.script-al = p-script-al
  buf_ruledict.documentation = p-documentation
  p-rec = recid(buf_ruledict)
  .
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Термин: id &1&2: &3"
                         , p-entry-id
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