block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: discfgr1.p $
$Archive: utl/discfgr1.p $

Сохранение записи конфигурации правила скидки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/07
Author: Bakhtadze Natalya
Creation date: 05/27/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-table-name as character no-undo .
define input parameter        p-pos-type   as character no-undo .
define input parameter        p-templ-rl-root as integer no-undo .
define input parameter        p-discnt-role as character no-undo .
define input parameter        p-time-templ-rl-root as integer no-undo .
define input parameter        p-self-nonunique as character no-undo .
define input parameter        p-nonunique as character no-undo .
define input parameter        p-has-glob as integer no-undo .
define input parameter        p-has-host as integer no-undo .
define input parameter        p-has-obj as integer no-undo .
define input parameter        p-link-prop as integer no-undo .
define input parameter        p-projection as character no-undo .
define input parameter        p-discnt-type as integer no-undo .
define input parameter        p-subject-type as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: discfgr1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/discfgr1.p $":U .
define variable vss-description as character no-undo init "Сохранение записи конфигурации правила скидки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/disrules.i def }
{ gbl/distruls.i def }

define variable v-discnt-role-list as character no-undo .
define variable v-mess as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.

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
do for buf_dis-cfg-rule
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    find first buf_dis-cfg-rule no-lock where
             buf_dis-cfg-rule.table-name = p-table-name
         and buf_dis-cfg-rule.pos-type = p-pos-type
         and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
         and buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
         and buf_dis-cfg-rule.discnt-role = p-discnt-role
               no-error.
    if available buf_dis-cfg-rule then do:
      assign
      v-mess = "Уже существует такая запись конфигурации".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
    if not (p-table-name = {&table_dis-gds-rule}
           or
           p-table-name = {&table_dis-cp-rule}
           or
           p-table-name = {&table_dis-dc-rule}
           or
           p-table-name = {&table_dis-dct-rule}
           or
           p-table-name = {&table_dis-grp-rule}
           or
           p-table-name = {&table_dis-thbj-rule}
           or
           p-table-name = {&table_dis-some-rule}
           ) then do:
      assign
      v-mess = substitute("Неверная таблица связи &1", p-table-name).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'table-name':U).
    end.
    if lookup(p-pos-type, {&cd-type-codes-discnt}) = 0 then do:
      assign
      v-mess = substitute("Неверное место исп скидки &1", p-pos-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'pos-type':U).
    end.
    if not can-find(first ub.dis-rule no-lock where
                        ub.dis-rule.rule-num = p-templ-rl-root)
    or p-templ-rl-root > {&max-num-dr-template} then do:
      assign
      v-mess = substitute("Неверный шаблон скидки &1", p-templ-rl-root).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'templ-rl-root':U).

    end.
    if p-time-templ-rl-root <> 0
    and (not can-find(first ub.dis-time-rule no-lock where
                        ub.dis-time-rule.time-rule-num = p-time-templ-rl-root)
    or p-time-templ-rl-root > {&max-num-dr-template}) then do:
      assign
      v-mess = substitute("Неверный шаблон расписания &1", p-time-templ-rl-root).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'time-templ-rl-root':U).
    end.
    case p-table-name:
      when {&table_dis-gds-rule} then do:
        assign
        v-discnt-role-list = {&disgdsru-list}
        .
      end.
      when {&table_dis-cp-rule} then do:
        assign
        v-discnt-role-list = {&dcpr-list}
        .
      end.
      when {&table_dis-dc-rule} then do:
        assign
        v-discnt-role-list = {&ddcr-list}
        .
      end.
      when {&table_dis-dct-rule} then do:
        assign
        v-discnt-role-list = {&ddctr-list}
        .
      end.
      when {&table_dis-grp-rule} then do:
        if p-self-nonunique = {&table_sum-grp} then do:
          assign
          v-discnt-role-list = {&dggrr-list}
          .
        end.
        if p-self-nonunique = {&table_cli-grp} then do:
          assign
          v-discnt-role-list = {&dclgr-list}
          .
        end.
      end.
      when {&table_dis-some-rule} then do:
      end.
      when {&table_dis-thbj-rule} then do:
        assign
        v-discnt-role-list = {&dthbjr-list}
        .
      end.
    end case.
    if lookup(p-discnt-role, v-discnt-role-list) = 0 then do:
      assign
      v-mess = substitute("Неверная роль скидки &1", p-discnt-role).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'discnt-role':U).
    end.
    if lookup(string(p-discnt-type), {&discnt-type-list}) = 0 then do:
      assign
      v-mess = substitute("Неверный тип скидки &1", p-discnt-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'discnt-type':U).
    end.
    if lookup(string(p-subject-type), {&discnt-target-list}) = 0 then do:
      assign
      v-mess = substitute("Неверный объект воздействия скидки &1", p-subject-type).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'subject-type':U).
    end.

    create buf_dis-cfg-rule.
    assign
    buf_dis-cfg-rule.table-name = p-table-name
    buf_dis-cfg-rule.pos-type = p-pos-type
    buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
    buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-cfg-rule.self-nonunique = p-self-nonunique
    .
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
  if lookup(string(p-link-prop), {&dr-link-codes}) = 0 then do:
    assign
    v-mess = substitute("Неверный тип объекта приложения правила &1", p-link-prop).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'link-prop':U).
  end.
  if p-link-prop = 0
  and p-projection <> '':U then do:
    assign
    v-mess = substitute("Не надо задавать проекцию для прямого объекта приложения правила").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'projection':U).
  end.
  if p-mode = {&update} then do:
    find first buf_dis-cfg-rule exclusive-lock where
             buf_dis-cfg-rule.table-name = p-table-name
         and buf_dis-cfg-rule.pos-type = p-pos-type
         and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
         and buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root
         and buf_dis-cfg-rule.self-nonunique = p-self-nonunique
         no-error.

    if buf_dis-cfg-rule.table-name <> p-table-name
    or buf_dis-cfg-rule.pos-type <> p-pos-type
    or buf_dis-cfg-rule.templ-rl-root <> p-templ-rl-root
    or buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root
    or buf_dis-cfg-rule.self-nonunique <> p-self-nonunique
    then do:
      assign
      v-mess = substitute("Для уже существующей записи конфигурации правил скидок невозможно изменение&1" +
                            "таблицы связи, места использования скидки, шаблона правила скидок, шаблона расписания и роли скидки&1" +
                            "старое значение таблицы связи, места использования скидки, шаблона  правила скидки, шаблона расписания, роли скидки, доп поля&1: &2, &3, &4, &5 и &6"
                              , {&new-line}
                              , buf_dis-cfg-rule.table-name
                              , buf_dis-cfg-rule.pos-type
                              , buf_dis-cfg-rule.templ-rl-root
                              , buf_dis-cfg-rule.time-templ-rl-root
                              , buf_dis-cfg-rule.discnt-role
                              , buf_dis-cfg-rule.self-nonunique
                              )
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end. /*if p-mode = {&update} then do:*/
  assign
  buf_dis-cfg-rule.has-glob = p-has-glob
  buf_dis-cfg-rule.has-host = p-has-host
  buf_dis-cfg-rule.has-obj = p-has-obj
  buf_dis-cfg-rule.nonunique = p-nonunique
  buf_dis-cfg-rule.discnt-role = p-discnt-role
  buf_dis-cfg-rule.link-prop = p-link-prop
  buf_dis-cfg-rule.projection = p-projection
  buf_dis-cfg-rule.discnt-type = p-discnt-type
  buf_dis-cfg-rule.subject-type = p-subject-type
  .
  p-rec = recid(buf_dis-cfg-rule).
end.  /*_main:*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Запись конфигурации правил скидок:&1таблица связи &2&1" +
                         "Место использ. &3&1" +
                         "Шаблон правила &4&1" +
                         "Тип скидки &6&1" +
                         "Тип скидки &6&1"  +
                         "Шаблон расписания &5&1" +
                         "Уникальность &6&1&7"
                         ,{&new-line}
                         ,p-table-name
                         ,p-pos-type
                         ,p-templ-rl-root
                         ,p-discnt-role
                         ,p-time-templ-rl-root
                         ,p-self-nonunique
                         ,p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.