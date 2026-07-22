block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение изменений ruledict-param

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/07
Author: Bakhtadze Natalya
Creation date: 02/13/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-entry-id as integer no-undo .
define input parameter        p-language as character no-undo .
define input parameter        p-param-num as integer no-undo .
define input parameter        p-param-name as character no-undo .
define input parameter        p-param-label as character no-undo .
define input parameter        p-param-data-type as character no-undo .
define input parameter        p-param-2-data-type as character no-undo .
define input parameter        p-param-3-data-type as character no-undo .
define input parameter        p-param-mode as character no-undo .
define input parameter        p-documentation as character no-undo .
define input parameter        p-init-value-character as character no-undo .
define input parameter        p-init-value-date as date no-undo .
define input parameter        p-init-value-decimal as decimal no-undo .
define input parameter        p-init-value-integer as integer no-undo .
define input parameter        p-init-value-logical as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение изменений ruledict-param".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-clob-db-num as integer   no-undo init ?.
define variable v-int64-id as integer   no-undo init 0.
define variable v-part-num as integer   no-undo .
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict for ub.ruledict.


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
do for buf_ruledict-param
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-param-name = '':u then do:
    assign
    v-mess = "Имя параметра не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-name':U).
  end.
  if p-param-label = '':u then do:
    assign
    v-mess = "Лейбл параметра не может быть пустым".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-lable':U).
  end.
  if p-param-num = 0 then do:
    assign
    v-mess = "№ параметра не может = 0".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-num':U).
  end.
  if lookup(p-param-data-type, {&ABL-pardatatype-list} + {&comma-char} + {&abl-datatype-longchar}) = 0
  then do:
    assign
    v-mess = substitute("Неверное значение типа параметра: &1", p-param-data-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-data-type':U).
  end.
  if lookup(p-param-mode, {&script-parmode-list}) = 0
  then do:
    assign
    v-mess = substitute("Неверное значение моды параметра: &1", p-param-mode).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'param-mode':U).
  end.
  if p-mode = {&add-def} then do:
    find first buf_ruledict-param exclusive-lock where
              buf_ruledict-param.entry-id = p-entry-id
          and buf_ruledict-param.language = p-language
          and buf_ruledict-param.param-num = p-param-num no-error.
    if available buf_ruledict-param then do:
      assign
      v-mess = "Уже существует ruledict-param c таким ID термина, языком и № пар-ра".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    find first buf_ruledict no-lock where
              buf_Ruledict.entry-id = p-entry-id no-error.
    if not available buf_ruledict then do:
      assign
      v-mess = "Не найден термин".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_ruledict-param.
    assign
    buf_ruledict-param.entry-id = p-entry-id
    buf_ruledict-param.language = p-language
    buf_ruledict-param.param-num = p-param-num
    .
  end.
  if p-mode = {&update} then do:
    find first buf_ruledict-param exclusive-lock where
              recid(buf_ruledict-param) = p-rec .
    if buf_ruledict-param.entry-id <> p-entry-id
    or buf_ruledict-param.language <> p-language
    or buf_ruledict-param.param-num <> p-param-num
    then do:
      assign
      v-mess = substitute("Для уже существующего ruledict-param невозможно изменение ID термина, языка и № пар-ра1" +
                              "старые значения ID термина, языка и № пар-ра: &2, &3 и &4"
                              , {&new-line}
                              , buf_ruledict-param.entry-id
                              , buf_ruledict-param.language
                              , buf_Ruledict-param.param-num)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  do v-ii = 1 to num-entries(p-param-3-data-type):
    if not (entry(v-ii, p-param-3-data-type) = "LIST"
            or
            entry(v-ii, p-param-3-data-type) = "READ-ONLY"
            or
            entry(v-ii, p-param-3-data-type) = "SORTED-LIST"
            ) then do:
      assign
      v-mess = substitute("Неизвестный тип данных3 = &1"
                              , {&new-line}
                              , p-param-3-data-type )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).

    end.
  end.
  assign
  buf_ruledict-param.param-name          = p-param-name
  buf_ruledict-param.param-label         = p-param-label
  buf_ruledict-param.param-data-type     = p-param-data-type
  buf_ruledict-param.param-2-data-type   = p-param-2-data-type
  buf_ruledict-param.param-3-data-type   = p-param-3-data-type
  buf_ruledict-param.param-mode          = p-param-mode
  buf_ruledict-param.documentation       = p-documentation
  buf_ruledict-param.init-value-character = (if p-param-data-type = {&abl-datatype-character}
                                             then p-init-value-character
                                             else '':U)
  buf_ruledict-param.init-value-date      = (if p-param-data-type = {&abl-datatype-date}
                                             then p-init-value-date
                                             else ?)
  buf_ruledict-param.init-value-decimal   = (if p-param-data-type = {&abl-datatype-decimal}
                                             then p-init-value-decimal
                                             else 0.0)
  buf_ruledict-param.init-value-integer   = (if p-param-data-type = {&abl-datatype-integer}
                                             then p-init-value-integer
                                             else 0)
  buf_ruledict-param.init-value-logical   = (if p-param-data-type = {&abl-datatype-logical}
                                             then p-init-value-logical
                                             else no)
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
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("ruledict-param ID термина: &1 язык: &2: № пар-ра &3:&4&5"
                         , p-entry-id
                         , p-language
                         , p-param-num
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