block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: disrul0.p $
$Archive: utl/disrul0.p $

Сохранение записи template правила скидки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/07
Author: Bakhtadze Natalya
Creation date: 05/27/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-templ-rl-root as integer no-undo .
define input parameter        p-des as character no-undo .
define input parameter        p-discnt-type as integer no-undo .
define input parameter        p-other-inf as character no-undo .
define input parameter        p-subject-type as integer no-undo .
define input parameter        p-uniq-field as character no-undo .
define input parameter        p-value-type as integer no-undo .
define input parameter        p-sts as integer no-undo .
define input parameter        p-level-1 as character no-undo .
define input parameter        p-level-2 as character no-undo .
define input parameter        p-has-glob as integer no-undo .
define input parameter        p-has-host as integer no-undo .
define input parameter        p-has-obj as integer no-undo .
define temp-table tt-drt-prop no-undo like ub.drt-prop
field full-prop-name as character
.
DEFINE INPUT PARAMETER TABLE FOR tt-drt-prop.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: disrul0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/disrul0.p $":U .
define variable vss-description as character no-undo init "Сохранение записи конфигурации правила скидки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/disrules.i def }
{ gbl/distruls.i def }

define variable v-discnt-role-list as character no-undo .
define variable v-mess as character no-undo .
define variable v-ii as integer no-undo .

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_file  for ub._file.
define buffer buf_field  for ub._field.
define buffer buf_drt-prop for ub.drt-prop.

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
do for buf_dis-rule
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = {&add-def} then do:
    find first buf_dis-rule no-lock where
             buf_dis-rule.rule-num = p-templ-rl-root
               no-error.
    if available buf_dis-rule then do:
      assign
      v-mess = "Уже существует такая запись template".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if p-templ-rl-root > {&max-num-dr-template}  then do:
      assign
      v-mess = substitute("Неверный номер template = &1", p-templ-rl-root).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'templ-rl-root':U).
    end.
    create buf_dis-rule.
    assign
    buf_dis-rule.templ-rl-root = p-templ-rl-root
    buf_dis-rule.rule-num = p-templ-rl-root
    buf_dis-rule.rl-root = p-templ-rl-root
    buf_dis-rule.root = yes
    buf_dis-rule.is-term = yes
    buf_dis-rule.lvl-num  = 0
    buf_dis-rule.sts      = 0
    .
    create buf_dis-cfg-rule.
    assign
    buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
    buf_dis-cfg-rule.pos-type = '':U
    buf_dis-cfg-rule.discnt-role = '':U
    buf_dis-cfg-rule.time-templ-rl-root = 0
    .
  end.
  if lookup(string(p-value-type), {&discnt-v-list}) = 0 then do:
    assign
    v-mess = substitute("Неверное значение поля value-type &1", p-value-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'value-type':U).
  end.
  if lookup(string(p-discnt-type), {&discnt-type-list}) = 0 then do:
    assign
    v-mess = substitute("Неверное значение поля discnt-type &1", p-discnt-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'discnt-type':U).

  end.
  if lookup(string(p-subject-type), {&discnt-target-list} ) = 0 then do:
    assign
    v-mess = substitute("Неверное значение поля subject-type &1", p-subject-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'subject-type':U).

  end.
  if p-des = '':U
  then do:
    assign
    v-mess = substitute("Пустое значение поля des &1", p-des).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'des':U).
  end.
  if p-sts <> integer({&current-status-int})
  and p-sts <> integer({&deleted-status-int}) then do:
    assign
    v-mess = substitute("Неверное значение поля статус &1", p-sts).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'sts':U).
  end.
  if p-uniq-field <> '':U then do:
    find first buf_file no-lock where
              buf_file._file-name = {&table_dis-rule} .
    do v-ii = 1 to num-entries(p-uniq-field):
      find first buf_field no-lock where
                buf_field._field-name = entry(v-ii, p-uniq-field)
            and buf_field._file-recid = recid(buf_file) no-error .
      if not available buf_field then do:
        assign
        v-mess = substitute("Неверное значение поля uniq &1", p-uniq-field).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'uniq':U).
      end.
    end.
  end.
  if not (p-has-glob = 0
          or
          p-has-glob = 1)
  then do:
    assign
    v-mess = substitute("Неверное значение поля has-glob &1", p-has-glob).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'has-glob':U).
  end.
  if not (p-has-host = 0
          or
          p-has-host = 1)
  then do:
    assign
    v-mess = substitute("Неверное значение поля has-host &1", p-has-host).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'has-host':U).
  end.
  if not (p-has-obj = 0
          or
          p-has-obj = 1)
  then do:
    assign
    v-mess = substitute("Неверное значение поля has-obj &1", p-has-obj).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'has-obj':U).
  end.

  if p-mode = {&update} then do:
    find first buf_dis-rule exclusive-lock where
            buf_dis-rule.rule-num = p-templ-rl-root
               no-error.
    find first buf_Dis-cfg-rule exclusive-lock where
              buf_Dis-cfg-rule.table-name = '':U
          and buf_Dis-cfg-rule.pos-type = '':U
          and buf_Dis-cfg-rule.time-templ-rl-root = 0
          and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
          and buf_dis-cfg-rule.self-nonunique = '':U
          no-error.
    /*
    if buf_dis-rule.table-name <> p-table-name
    then do:
      assign
      v-mess = substitute("Для уже существующей записи конфигурации парвил скидок невозможно изменение&1" +
                            "таблицы связи, места использования скидки, шаблона правила скидок, шаблона расписания и роли скидки" +
                            "старое значение таблицы связи, места использования скидки, шаблона  правила скидки, шаблона расписания и роли скидки: &2, &3, &4 и &5"
                              , {&new-line}
                              , buf_dis-rule.table-name
                              , buf_dis-rule.pos-type
                              , buf_dis-rule.templ-rl-root
                              , buf_dis-rule.time-templ-rl-root
                              , buf_dis-rule.discnt-role
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    */
  end. /*if p-mode = {&update} then do:*/
  assign
  buf_Dis-rule.des       = p-des
  buf_Dis-rule.dis-kat = (if lookup("dis-kat", p-level-1) > 0
                          or lookup("dis-kat", p-level-2) > 0
                          then 0
                          else -1)
  buf_Dis-rule.doc-qnty = (if lookup("doc-qnty", p-level-1) > 0
                          or lookup("doc-qnty", p-level-2) > 0
                          then 0
                          else -1)
  buf_Dis-rule.tot-sum = (if lookup("tot-sum", p-level-1) > 0
                          or lookup("tot-sum", p-level-2) > 0
                          then 0
                          else -1)
  buf_Dis-rule.time-rule-num = (if lookup("time-rule-num", p-level-1) > 0
                          or lookup("time-rule-num", p-level-2) > 0
                          then 0
                          else -1)
  buf_Dis-rule.charkey_one = (if lookup("charkey_one", p-level-1) > 0
                          or lookup("charkey_one", p-level-2) > 0
                          then '':U
                          else ?)
  buf_Dis-rule.charkey_two = (if lookup("charkey_two", p-level-1) > 0
                          or lookup("charkey_two", p-level-2) > 0
                          then '':U
                          else ?)
  buf_Dis-rule.charkey_three = (if lookup("charkey_three", p-level-1) > 0
                          or lookup("charkey_three", p-level-2) > 0
                          then '':U
                          else ?)
  buf_Dis-rule.deckey_one = (if lookup("deckey_one", p-level-1) > 0
                          or lookup("deckey_one", p-level-2) > 0
                          then 0
                          else ?)
  buf_Dis-rule.deckey_two = (if lookup("deckey_two", p-level-1) > 0
                          or lookup("deckey_two", p-level-2) > 0
                          then 0
                          else ?)
  buf_Dis-rule.deckey_three = (if lookup("deckey_three", p-level-1) > 0
                          or lookup("deckey_three", p-level-2) > 0
                          then 0
                          else ?)
  buf_Dis-rule.key#_one = (if lookup("key#_one", p-level-1) > 0
                          or lookup("key#_one", p-level-2) > 0
                          then 0
                          else ?)
  buf_Dis-rule.key#_two = (if lookup("key#_two", p-level-1) > 0
                          or lookup("key#_two", p-level-2) > 0
                          then 0
                          else ?)
  buf_Dis-rule.key#_three = (if lookup("key#_three", p-level-1) > 0
                          or lookup("key#_three", p-level-2) > 0
                          then 0
                          else ?)
  buf_Dis-rule.discnt-type = p-discnt-type
  buf_Dis-rule.other-inf   = p-other-inf
  buf_Dis-rule.subject-type = p-subject-type
  buf_Dis-rule.uniq-field   = p-uniq-field
  buf_Dis-rule.value-type   = p-value-type
  buf_dis-rule.sts          = p-sts
  buf_dis-cfg-rule.other-inf = (p-level-1 +
                                (if p-level-2 > '':U
                                 then ";":U
                                 else '':U) + p-level-2)
  buf_dis-cfg-rule.has-glob = p-has-glob
  buf_dis-cfg-rule.has-host = p-has-host
  buf_dis-cfg-rule.has-obj = p-has-obj
  buf_dis-cfg-rule.link-prop = 0
  p-rec = recid(buf_dis-rule)
  .
  release buf_dis-rule no-error.
  if error-status:error then do:
    assign
    v-mess = substitute("Ошибка при сохранении записи правила скидки &1&2&3"
                       , error-status:get-message(1)
                       , {&new-line}
                       , return-value
                       ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  for each tt-drt-prop
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    if tt-drt-prop.prop-code = '':u then next.
    find first buf_drt-prop where
              buf_drt-prop.templ-rl-root = tt-drt-prop.templ-rl-root
          and buf_drt-prop.node-code = tt-drt-prop.node-code no-error .
    if not available buf_drt-prop then do:
       create buf_drt-prop.
       assign
       buf_drt-prop.templ-rl-root = tt-drt-prop.templ-rl-root
       buf_drt-prop.prop-code = tt-drt-prop.prop-code
       buf_drt-prop.upper-prop-code = tt-drt-prop.upper-prop-code
       buf_drt-prop.node-code = tt-drt-prop.node-code
       buf_drt-prop.upper-node-code = tt-drt-prop.upper-node-code no-error .
       .
    end.
    assign
    buf_drt-prop.property-value = tt-drt-prop.property-value.
  end.
  for each buf_drt-prop
  where buf_drt-prop.templ-rl-root = p-templ-rl-root
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
    find first tt-drt-prop where
              tt-drt-prop.templ-rl-root = buf_drt-prop.templ-rl-root
          and tt-drt-prop.node-code = buf_drt-prop.node-code  no-error .
    if not available tt-drt-prop then do:
      delete buf_drt-prop.
    end.
  end.
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Запись template правил скидок:&1" +
                          "Шаблон правила &2&1&3"
                          ,{&new-line}
                          ,p-templ-rl-root
                          ,p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.