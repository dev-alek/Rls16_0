block-level on error undo, throw.
/*

$Revision: cb37b650f92a, 1185, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: cligrp01.p $
$Archive: ref/cligrp01.p $

Проверка и создание группы клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/
using ibs.th.gbl.gbl-var.

define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-get-node-code as logical no-undo .
define input-output parameter p-node-code  like ub.cli-grp.node-code no-undo .
define input-output parameter p-upper-code like ub.cli-grp.upper-code no-undo .
define input parameter p-node-name   like ub.cli-grp.node-name no-undo .
define output parameter p-rid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: cb37b650f92a, 1185, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:20:27 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cligrp01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cligrp01.p $":U .
define variable vss-description as character no-undo init "Проверка и создание группы клиентов".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/cgrplib.i }

DEFINE VARIABLE v-full-name as character no-undo .
DEFINE VARIABLE v-error-message as character no-undo .
DEFINE VARIABLE v-list as character no-undo .
DEFINE VARIABLE v-node-code like ub.cli-grp.node-code no-undo .
define variable v-last-node-code as integer no-undo .
define buffer upper_cli-grp  for ub.cli-grp.
define buffer buf_cli-grp for ub.cli-grp.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

  if NOT (p-mode = {&add-def} or p-mode = {&update}) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-mode" p-mode
    view-as alert-box error .
    undo main-block, return error .
  end.
    run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
    if v-value = "no"  then do:   
  if gbl-var:g#db-num <> 0 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя добавлять/изменить группы клиентов в УБД"
    view-as alert-box error .
    undo main-block, return error .
  end.
  end.
  if p-node-name = ""
  or p-node-name = ? then do:
    assign
    v-error-message = substitute("Не задано название группы" ).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "node-name").
  end.
  if p-mode = {&update} then do:
    find first buf_cli-grp exclusive-lock
         where buf_cli-grp.node-code = p-node-code no-error no-wait .
    if locked(buf_cli-grp) then do:
      v-error-message = substitute(  "Запись о группе клиентов с внутр. № [&1] занята другим пользователем",  p-node-code  ).
      run err-mess in this-procedure (input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "node-code").
    end.         
    if not available buf_cli-grp then do:
      v-error-message = substitute(  "Запись о группе клиентов с внутр. № [&1] отсутствует",  p-node-code  ).
      run err-mess in this-procedure (input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "node-code").
    end.
    if buf_cli-grp.upper-code <> p-upper-code then do:
      v-error-message = substitute(
        "Расхождение текущего кода родителя с параметрами обновления у группы клиентов с внутр. № [&1].&3" +
        "Код родителя у группы = [&2], код родителя в параметрах обновления = [&4]",
        p-node-code, buf_cli-grp.upper-code, {&new-line}, p-upper-code 
      ) .
      run err-mess in this-procedure (input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "node-code").
    end.
    assign
    p-rid = recid(buf_cli-grp)
    .
    run cli-grplib-get-full-name in this-procedure (
                                                input p-node-code
                                               ,output v-full-name).
  end.
  if p-mode = {&add-def} then do:
    find first upper_cli-grp exclusive-lock where
               upper_cli-grp.node-code = p-upper-code no-error .
    if not avail upper_cli-grp then do:
      assign
      v-error-message = substitute("Не найдена группа верхнего уровня с внутр. № &1", p-upper-code).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "upper-code").
    end.
    if p-get-node-code = yes then do:
      find last buf_cli-grp no-lock use-index pi.
      assign
      v-last-node-code = buf_cli-grp.node-code.
      find first buf_cli-grp no-lock where
                buf_cli-grp.node-code = p-node-code no-error.
      if available buf_cli-grp then do:
        assign
        v-error-message = substitute("Уже есть группа с внутр. № &1", p-node-code).
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "node-code").
      end.
    end.
    run cli-grplib-get-full-name in this-procedure (
                                                input p-upper-code
                                               ,output v-full-name).
    /*такое полное имя БУДЕТ - сейчас еще нет  поэтому нельзя использовать библ функцию и full-grp.p*/
    assign
    v-full-name = v-full-name + {&delim-grp} + p-node-name + {&delim-grp}
    .
  end.
  run  cgrplib-analyze-grp-name in this-procedure
                                                  ( input p-node-name
                                                   ,input p-upper-code
                                                   ,output v-error-message ) no-error .
  if error-status:error or v-error-message <> "":U then do:
    assign
    v-error-message = substitute("&1", v-error-message).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "node-name").

  end.
  if can-find (ub.cli-grp where ub.cli-grp.upper-code = p-upper-code
                            AND ub.cli-grp.node-name  = p-node-name
                        AND recid (ub.cli-grp) <> p-rid) then do:
    v-error-message = substitute(
      "В группе верхнего уровня с внутр. № [&1] уже есть группа с названием [&2].&3" +
      "Внутр. № существующей группы отличается от внутр. № [&4] добавляемой группы",
      p-upper-code, p-node-name, {&new-line}, p-node-code
    ) .
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "node-name").
  end.
  if p-mode = {&add-def} then do:
    create buf_cli-grp.
    assign
    buf_cli-grp.node-code = (if p-get-node-code
                             then p-node-code
                             else next-value (s-cli-grp, {&db-name_schema}))
    buf_cli-grp.upper-code = p-upper-code
    p-node-code = buf_cli-grp.node-code
    .
  end.
  assign
  buf_cli-grp.node-name = p-node-name
  p-rid = recid(buf_cli-grp)
  v-node-code = buf_cli-grp.node-code
  .
  release buf_cli-grp no-error .
  if error-status:error then do:
    assign
    v-error-message = substitute("Ошибка при сохранении группы клиентов:&1&2&1&3"
                                 , {&new-line}
                                 , error-status:get-message(1)
                                 , return-value  ).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "").
  end.
  if p-mode = {&add-def}
  and p-get-node-code
  and p-node-code > v-last-node-code
  then do:
    run adm/restseqr.p
      ( input "rest-no-msg":U
      ,input "s-cli-grp":U
      ,input no
      ) no-error .
    if error-status :error then do:
      assign
      v-error-message = substitute("Ошибка при восстановлении последовательности вн.№ групп клиентов:&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value  ).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "").
    end.
  end.
  /*for news */
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Группа c внутр. №: &1 (&2):&3&4"
                         , p-node-code
                         , p-node-name
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