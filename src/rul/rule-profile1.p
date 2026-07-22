block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение rule-profile

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-profile-id as integer no-undo .
define input parameter        p-profile-type as character no-undo .
define input parameter        p-name       as character no-undo .
define input parameter        p-is_dynamic as logical no-undo .
define input parameter        p-documentation as character no-undo .
define input parameter        p-param-code as character no-undo .
define input parameter        p-param-value as character no-undo .
define input parameter        p-short-name as character no-undo .
define input parameter        p-action-head-code as integer no-undo .
define input parameter        p-action-item-id as character no-undo .
define input parameter        p-action-item-context as character no-undo .
define input parameter        p-custom-param-form as integer no-undo .
define input parameter        p-reusable-params as character no-undo .
define input parameter        p-parent-feature as integer no-undo .

define temp-table tt-ruledict-param no-undo like ub.ruledict-param.
DEFINE INPUT PARAMETER TABLE FOR tt-ruledict-param.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение rule-profile".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-entry-id as integer no-undo .
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_ruledict for ub.ruledict.
define buffer last_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_tt-ruledict-param for tt-ruledict-param.


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
do for buf_rule-profile
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    find first buf_rule-profile no-lock where
             buf_rule-profile.profile_id = p-profile-id no-error.
    if available buf_rule-profile then do:
      assign
      v-mess = "Уже существует профайл c таким id".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if lookup( p-profile-type, {&profile-type-list}) = 0 then do:
      assign
      v-mess = substitute("Неверный тип профайла &1", p-profile-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_rule-profile.
    assign
    buf_rule-profile.profile_id = p-profile-id
    buf_rule-profile.profile-type = p-profile-type
    .
    run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                        ,input buffer buf_rule-profile:handle
                                        ,output v-uniq-key-rec).
    find first buf_ruledict where
              buf_ruledict.entry-type = {&rdict-etype-rule-profile}
          and buf_ruledict.uniq-key-rec =  v-uniq-key-rec no-error.
    if not available buf_ruledict then do:
      find last last_ruledict no-lock use-index pi.
      create buf_ruledict.
      assign
      buf_ruledict.entry-type = {&rdict-etype-rule-profile}
      buf_ruledict.uniq-key-rec = v-uniq-key-rec
      buf_ruledict.entry-id = last_ruledict.entry-id + 1
      buf_ruledict.language = "ABL"
      .
    end.
    assign
    buf_ruledict.script-al = string(buf_rule-profile.profile_id, "999999999":U)
    buf_ruledict.script-nl = buf_rule-profile.name
    v-entry-id = buf_ruledict.entry-id
    .
  end.
  if p-mode = {&update} then do:
    find first buf_rule-profile exclusive-lock where
              recid(buf_rule-profile) = p-rec .
    if buf_rule-profile.profile_id <> p-profile-id
    then do:
      assign
      v-mess = substitute("Для уже существующего профайла невозможно изменение id&1" +
                              "старое значение id: &2"
                              , {&new-line}
                              , buf_rule-profile.profile_id)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if buf_rule-profile.profile-type <> p-profile-type then do:
      find first buf_rule-by-profile no-lock where
                buf_rule-by-profile.profile_id = buf_rule-profile.profile_id no-error.
      if available buf_rule-by-profile then do:
      assign
      v-mess = substitute("Для уже существующего профайла невозможно изменение типа,&1" +
                              "если имеется привязанное правило:&1" +
                              "старое значение типа &2"
                              , {&new-line}
                              , buf_rule-profile.profile-type
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).

      end.
    end.
    run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                        ,input buffer buf_rule-profile:handle
                                        ,output v-uniq-key-rec).
    find first buf_ruledict where
              buf_ruledict.entry-type = {&rdict-etype-rule-profile}
          and buf_ruledict.uniq-key-rec =  v-uniq-key-rec no-error.
    IF NOT AVAILABLE BUF_RULEDICT THEN DO:
      assign
      v-mess = substitute("Не найден термин в словаре для профайла").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    END.
    v-entry-id = buf_ruledict.entry-id.
    if buf_rule-profile.parent-feature = integer({&rp-parentf-ordinal})
    and p-parent-feature = integer({&rp-parentf-only-in-combo})
    and can-find (first ub.rp-by-call no-lock where
                      ub.rp-by-call.parent-profile_id = 0
                  and ub.rp-by-call.profile_id = p-profile-id)
    then do:
      assign
      v-mess = substitute("Нельзя поменять СОЧЕТАЕМОСТЬ - у профайла есть привязки").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  if lookup(string(p-parent-feature), {&rp-parentf-list}) = 0 then do:
    assign
    v-mess = substitute("Неверное значение СОЧЕТАЕМОСТИ для профайла").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  assign
  buf_rule-profile.name = p-name
  buf_rule-profile.is_dynamic = p-is_dynamic
  buf_rule-profile.profile-type = p-profile-type
  buf_rule-profile.documentation = p-documentation
  buf_rule-profile.param-code = p-param-code
  buf_rule-profile.param-value = p-param-value
  buf_rule-profile.short-name = p-short-name
  buf_rule-profile.action-head-code  = action-head-code
  buf_rule-profile.action-item-id = p-action-item-id
  buf_rule-profile.action-item-context = p-action-item-context
  buf_rule-profile.custom-param-form = p-custom-param-form
  buf_rule-profile.reusable-params = p-reusable-params
  buf_rule-profile.parent-feature = p-parent-feature
  p-rec = recid(buf_rule-profile)
  .
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
    if buf_ruledict-param.param-data-type = {&abl-datatype-character}
    and buf_ruledict-param.param-2-data-type = "xsd"
    then do:
       run rul/rdp-clob.p ( buffer buf_ruledict-param
                           ,input p-mode) no-error.
       if error-status:error then  do:
         v-mess = substitute("Не удалось сохранить CLOB &1:&2&3&2&4"
                            ,buf_ruledict-param.init-value-character
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
         run err-mess in this-procedure ( input-output v-mess).
         return error (if p-silent = yes then v-mess else '':U).
       end.
    end.
  end.
  for each buf_ruledict-param where buf_ruledict-param.entry-id = v-entry-id
  on error undo _main, return error  substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    find first tt-ruledict-param where
              tt-ruledict-param.entry-id = buf_ruledict-param.entry-id
          and tt-ruledict-param.param-num = buf_ruledict-param.param-num
            no-error.
    if not available tt-ruledict-param then do:
      if buf_ruledict-param.param-data-type = {&abl-datatype-character}
      and buf_ruledict-param.param-2-data-type = "xsd"
      then do:
        find first buf_tt-ruledict-param where
                  buf_tt-ruledict-param.param-data-type = {&abl-datatype-character}
              and buf_tt-ruledict-param.param-2-data-type = "xsd"
              and buf_tt-ruledict-param.init-value-character = tt-ruledict-param.init-value-character
              and recid(buf_tt-ruledict-param) = recid(tt-ruledict-param ) no-error.
        if not available buf_tt-ruledict-param then do:
        run rul/rdp-clob.p ( buffer buf_ruledict-param
                            ,input {&deletion}) no-error.
        if error-status:error then do:
          v-mess = substitute("Не удалось удалить CLOB &1:&2&3&2&4"
                              ,buf_ruledict-param.init-value-character
                              ,{&new-line}
                              , error-status:get-message(1)
                              , return-value ).
          run err-mess in this-procedure ( input-output v-mess).
          return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
      end.
      delete buf_ruledict-param.
    end.
  end.

end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Профайл: id &1:&2&3"
                         , p-profile-id
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