block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение prop-script

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/11/07
Author: Bakhtadze Natalya
Creation date: 02/11/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-language as character no-undo .
define input parameter        p-script-name   as character no-undo .
define input parameter        p-revis-id as integer no-undo .
define input parameter        p-script-label as character no-undo .
define input parameter        p-class-dtm-code as integer no-undo .
define input parameter        p-documentation as character no-undo .
define input parameter        p-proc-type as character no-undo .
define input parameter        p-script-type as character no-undo .
define input parameter        p-script-value-type as character no-undo .
define input parameter        p-script-head as character no-undo .
define input parameter        p-script-body as character no-undo .
define input parameter        p-script-foot as character no-undo .
define input parameter        p-signature as character no-undo .
define input parameter        p-hidden_  as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение prop-script".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ rul/signalib.i }
{ gbl/key-rec.i }

define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-param-string as character no-undo .
define variable v-signature as character no-undo .
define variable v-signature0 as character no-undo .
define variable v-region-nl as character no-undo .
define variable v-script-label as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-revis-id as integer no-undo .
define variable glog as logical no-undo .
define buffer buf_prop-head  for ub.prop-head.
define buffer buf2_prop-head  for ub.prop-head.
define buffer buf_prop-script for ub.prop-script.
define buffer last_ruledict for ub.ruledict.
define buffer first_ruledict for ub.ruledict.
define buffer buf_ruledict for ub.ruledict.
define buffer last_prop-script for ub.prop-script.
define buffer buf_rule-i-script for ub.rule-i-script.

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
do for buf_prop-script
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  v-revis-id = p-revis-id.
  if p-language = '':U
  or p-script-name = '':U then do:
    assign
    v-mess = "Не задан язык и/или имя скрипта".
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if lookup(p-proc-type, {&script-ptype-list}) = 0
  and p-proc-type <> '':U
  then do:
    assign
    v-mess = substitute("Неверное значение типа процедуры: &1", p-proc-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'proc-type':U).
  end.
  if lookup(p-script-type, {&prop-script-type-list}) = 0
  and p-script-type <> '':U
  then do:
    assign
    v-mess = substitute("Неверное значение типа скрипта: &1", p-script-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'script-type':U).
  end.
  if lookup(entry(1, p-script-value-type), {&ABL-simple-datatype-list} + {&comma-char} +
                                           {&abl-datatype-void} + {&comma-char} +
                                           {&abl-datatype-handle}
                                           ) = 0
  and p-proc-type <> '':U
  then do:
    assign
    v-mess = substitute("Неверное значение типа возвращаемых данных для скрипта: &1", p-script-value-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'script-value-type':U).
  end.
  if p-mode = {&add-def} then do:
    find first buf_prop-script no-lock where
              buf_prop-script.dtm-code = p-dtm-code
          and buf_prop-script.language = p-language
          and buf_prop-script.script-name = p-script-name
          and buf_prop-script.revis_id = p-revis-id no-error.
    if available buf_prop-script then do:
      assign
      v-mess = "Уже существует prop-script с таким именем для такого объекта, языка, Версии".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-dtm-code <> 0 then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = p-dtm-code no-error.
      if not available buf_prop-head then do:
        assign
        v-mess = substitute("Не существует Объект-операнд &1", p-dtm-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    create buf_prop-script.
    assign
    buf_prop-script.dtm-code = p-dtm-code
    buf_prop-script.language = p-language
    buf_prop-script.script-name = p-script-name
    .
  end.
  if p-mode = {&update} then do:
    find first buf_prop-script exclusive-lock where
              recid(buf_prop-script) = p-rec .
    if buf_prop-script.dtm-code <> p-dtm-code
    or buf_prop-script.language <> p-language
    or buf_prop-script.script-name <> p-script-name
    or buf_prop-script.revis_id <> p-revis-id
    then do:
      assign
      v-mess = substitute("Для уже существующего prop-script невозможно изменение Объекта, Языка, имени, версии&1" +
                              "старые значения объекта, языка, имени и версии: &2, &3, &4 &5"
                              , {&new-line}
                              , buf_prop-script.dtm-code
                              , buf_prop-script.language
                              , buf_prop-script.script-name
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-class-dtm-code <> p-dtm-code then do:
      find first buf2_prop-head no-lock where
                buf2_prop-head.dtm-code = p-class-dtm-code no-error.
      if not available buf2_prop-head then do:
        assign
        v-mess = substitute("Не существует Объект-операнд обслуживающего класса &1", p-class-dtm-code).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    find first buf_rule-i-script no-lock where
              buf_rule-i-script.dtm-code = p-dtm-code
         and  buf_rule-i-script.class-dtm-code = p-class-dtm-code
         and  buf_rule-i-script.script-name = p-script-name
         and  buf_rule-i-script.script-type = p-script-type
         and  buf_rule-i-script.revis_id = p-revis-id no-error.
    if available buf_rule-i-script then do:
      if not p-silent then do:
         message
         "Скрипт данной версии входит в правила" skip
         "Хотите создать скрипт новой версии?"
         view-as alert-box question buttons YES-NO update glog.
      end.
      else do:
        glog = yes.
      end.
      if not glog then do:
        return.
      end.
      find last last_prop-script no-lock where
              last_prop-script.dtm-code = p-dtm-code
          and last_prop-script.language = p-language
          and last_prop-script.script-name = p-script-name no-error.
      if available last_prop-script then do:
        v-revis-id =  last_prop-script.revis_id + 1.
      end.
      else do:
        v-revis-id =  0.
      end.
    end.
  end.
  if p-proc-type <> '':U then do:
    if (p-signature begins "@") then do:
      assign
      v-signature = left-trim(p-signature, "@")
      v-signature0 = p-signature
      .
    end.
    else do:
      run signalib_fill-signature in this-procedure ( input p-script-name
                                          ,input p-script-head
                                          ,input p-proc-type
                                          ,output v-signature) no-error.
      if error-status:error then do:
        assign
        v-mess = substitute("Ошибки при заполнении сигнатуры&1&2&1&3"
                           , {&new-line}
                           , error-status:get-message(1)
                           , return-value
                           ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else '':U).

      end.
      v-signature0 = v-signature.
    end.
  end.
  if p-script-label = '':U then do:
    if p-dtm-code > 0
    then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = p-dtm-code .
      if index(p-script-name, "_host@") > 0
      or index(p-script-name, "_host@#") > 0
      or r-index(p-script-name, "_host") = length(entry(1, p-script-name, "(")) - 4 then do:
        v-region-nl = "_Фирма".
      end.
      if index(p-script-name, "_obj@") > 0
      or index(p-script-name, "_obj@#") > 0
      or r-index(p-script-name, "_obj") = length(entry(1, p-script-name, "(")) - 3 then do:
        v-region-nl = "_Объект".
      end.
      if index(p-script-name, "_@") > 0
      or index(p-script-name, "_@#") > 0
      or r-index(p-script-name, "_") = length(entry(1, p-script-name, "(")) then do:
        v-region-nl = "_".
      end.
      if index(p-script-name, "@":U) > 0 then do:
        v-script-label = buf_prop-head.prop-label + v-region-nl + '.':U + p-script-label.
      end.
      else do:
        v-script-label = buf_prop-head.prop-label + v-region-nl.
      end.
    end.
    else do:
      v-script-label = p-script-label.
    end.
    if p-script-type = {&prop-script-type-set}
    then do:
      assign
      v-script-label = substitute ('&1 = &&1', v-script-label).
    end.
    if p-script-type = {&prop-script-type-create} then do:
      assign
      v-script-label = substitute ('&1.Создать', v-script-label).
    end.
  end.
  else do:
    v-script-label = p-script-label.
  end.
  assign
  buf_prop-script.class-dtm-code = p-class-dtm-code
  buf_prop-script.documentation = p-documentation
  buf_prop-script.proc-type     = p-proc-type
  buf_prop-script.script-type   = p-script-type
  buf_prop-script.script-value-type    = p-script-value-type
  buf_prop-script.script-head   = p-script-head
  buf_prop-script.script-body   = p-script-body
  buf_prop-script.script-foot   = p-script-foot
  buf_prop-script.signature     = v-signature0
  buf_prop-script.revis_id      = v-revis-id
  buf_prop-script.hidden_       = p-hidden_
  p-rec = recid(buf_prop-script)
  .
  run gen-key-rec in this-procedure (
                                      input {&table_prop-script}
                                      ,input  buffer buf_prop-script:handle
                                      ,output v-uniq-key-rec
                                      ).
  assign
  buf_prop-script.uniq-key-rec = v-uniq-key-rec
  .
  find first buf_ruledict where
            buf_ruledict.entry-type  = {&rdict-etype-prop-script}
        and buf_ruledict.uniq-key-rec  = v-uniq-key-rec no-error.
  if not available buf_ruledict then do:
    find first first_ruledict exclusive-lock use-index pi.
    find last last_ruledict no-lock use-index pi.
    create buf_ruledict.
    assign
    buf_ruledict.entry-type = {&rdict-etype-prop-script}
    buf_ruledict.uniq-key-rec = v-uniq-key-rec
    buf_ruledict.entry-id = last_ruledict.entry-id + 1
    buf_ruledict.language = "ABL"
    .
  end.
  assign
  buf_ruledict.script-al = p-script-name
  buf_ruledict.script-nl = v-script-label
  .
  assign
  v-param-string = signalib_get-params-from-signa( input p-proc-type, input v-signature).
  if v-param-string <> '':U then do:
    run signalib_write-rdp  in this-procedure ( input buf_ruledict.entry-id
                                    ,input "ABL":U
                                    ,input v-param-string
                                    ) .
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Скрипт: объект-операнд &1 язык: &2: скрипт &3 версия &4:&5&6"
                         , p-dtm-code
                         , p-language
                         , p-script-name
                         , p-revis-id
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