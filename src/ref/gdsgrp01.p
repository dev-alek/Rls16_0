block-level on error undo, throw.
/*

$Revision: 74e644abf59e, 1135, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:54 2017 +0300 $
$Workfile: gdsgrp01.p $
$Archive: ref/gdsgrp01.p $

Проверка и создание группы товара

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

define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-get-node-code as logical no-undo .
define input parameter p-fill-tax-from-upper as logical no-undo .
define input-output parameter p-node-code  like ub.gds-grp.node-code no-undo .
define input-output parameter p-upper-code like ub.gds-grp.upper-code no-undo .
define input parameter p-node-name   like ub.gds-grp.node-name no-undo .
define input parameter p-calc-method like ub.gds-grp.calc-method no-undo .
define input parameter p-increase-pc like ub.gds-grp.increase-pc no-undo .
define input parameter p-print-code  like ub.gds-grp.print-code no-undo .
define input parameter p-round-method as character no-undo .
define input parameter p-base         as decimal no-undo .
/*метод округления + {&space-char} + string(база, "->>>>9.99":U)*/
define output parameter p-rid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: 74e644abf59e, 1135, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:54 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gdsgrp01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gdsgrp01.p $":U .
define variable vss-description as character no-undo init "Проверка и создание группы товара".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/grplib.i }
{ ref/grpobj.i }
{ str/tt-tax.i "NEW SHARED" tt-tax full }

DEFINE VARIABLE v-full-name as character no-undo .
DEFINE VARIABLE v-error-message as character no-undo .
DEFINE VARIABLE v-list as character no-undo .
DEFINE VARIABLE v-node-code like ub.gds-grp.node-code no-undo .
define variable v-last-node-code as integer no-undo .
define variable v-is-import as logical no-undo .
define variable v-print-code  as character no-undo .
define variable v-value as character no-undo.
define variable v-ttype as character no-undo.

define buffer upper_gds-grp  for ub.gds-grp.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
define buffer buf_gds-grp for ub.gds-grp.

main-block:
do
on error undo, return error
:

  if NOT (p-mode = {&add-def}
       or p-mode = {&update}
       or p-mode = "import":U
       ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-mode" p-mode
    view-as alert-box error .
    return error .
  end.
run gbl/conf-rd.p ("is-erpRN", "", "", 0, "", "", "", no, output v-value, output v-ttype) no-error.
if v-value = "no"  then do:   
  if g#db-num <> 0 then do:
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
    if p-mode = {&add-def}  then 
  do:
    find first buf_gds-grp  no-lock where
      buf_gds-grp.node-code <> p-node-code and
      buf_gds-grp.print-code = p-print-code no-error.
    if available buf_gds-grp then 
    do:
      assign
        v-error-message = substitute("Уже есть группа с кодом. № &1", p-print-code).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "print-code").
    end.
  end.
  if p-mode = {&update} then 
  do:
    find first buf_gds-grp exclusive-lock where
      buf_gds-grp.node-code = p-node-code
      AND buf_gds-grp.upper-code = p-upper-code no-error .
    if not avail buf_gds-grp then 
    do:
      assign
        v-error-message = substitute("Не найдена группа товаров, которую предполагается изменить", p-node-code).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "node-code").
    end.
    else 
    do:
      find first buf_gds-grp  no-lock where
        buf_gds-grp.node-code <> p-node-code and
        buf_gds-grp.print-code = p-print-code no-error.
      if AVAILABLE buf_gds-grp then 
      do:
        assign
          v-error-message = substitute("Уже есть группа с кодом. № &1", p-print-code).
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "print-code").
      end.
      else 
      do:
        assign
          p-rid = recid(buf_gds-grp)
          .
        run grplib-get-full-name in this-procedure (
          input p-node-code
          ,output v-full-name).
      end.    
    end.  
    
  end.
  
  if p-mode = {&add-def}
  and p-get-node-code = yes  then do:
    find first buf_gds-grp  no-lock where
              buf_gds-grp.node-code = p-node-code no-error.
    if available buf_gds-grp then do:
      assign
      v-error-message = substitute("Уже есть группа с внутр. № &1", p-node-code).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "node-code").
    end.
  end.
  if p-mode = {&update} then do:
    find first buf_gds-grp exclusive-lock where
               buf_gds-grp.node-code = p-node-code
           AND buf_gds-grp.upper-code = p-upper-code no-error .
    if not avail buf_gds-grp then do:
      assign
      v-error-message = substitute("Не найдена группа товаров, которую предполагается изменить", p-node-code).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "node-code").
    end.
    assign
    p-rid = recid(buf_gds-grp)
    .
    run grplib-get-full-name in this-procedure (
                                                input p-node-code
                                               ,output v-full-name).
  end.

  if p-mode = {&add-def} then do:
    find first upper_gds-grp exclusive-lock where
               upper_gds-grp.node-code = p-upper-code no-error .
    if not avail upper_gds-grp then do:
      assign
      v-error-message = substitute("Не найдена группа верхнего уровня с внутр. № &1", p-upper-code).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "upper-code").
    end.
    if p-get-node-code = yes then do:
      find last buf_gds-grp no-lock use-index pi.
      assign
      v-last-node-code = buf_gds-grp.node-code.
      find first buf_gds-grp no-lock where
                buf_gds-grp.node-code = p-node-code no-error.
      if available buf_gds-grp then do:
        assign
        v-error-message = substitute("Уже есть группа с внутр. № &1", p-node-code).
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "node-code").
      end.
    end.
    run grplib-get-full-name in this-procedure (
                                                input p-upper-code
                                               ,output v-full-name).
    /*такое полное имя БУДЕТ - сейчас еще нет  поэтому нельзя использовать библ функцию и full-grp.p*/
    assign
    v-full-name = v-full-name + {&delim-grp} + p-node-name + {&delim-grp}
    .
  end.
  CASE p-calc-method:
    when ? or when "":U then do:
      assign
      v-error-message = substitute("Поле <СПОСОБ РАСЧЕТА> должно быть заполнено").
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "calc-method").
    end.
    otherwise do:
     run str/pr-listv.p (
                     input {&pr-calc-methods-grp-list}
                   , "":U
                   , output v-list) .
      if LOOKUP(p-calc-method, v-list) = 0 then do:
        assign
        v-error-message = substitute("Поле <СПОСОБ РАСЧЕТА> может принимать значения &1", v-list).
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "calc-method").
      end.
    end.
  END CASE.

  CASE p-round-method:
    when ? or when "":U then do:
      assign
      v-error-message = substitute("Поле <МЕТОД ОКРУГЛЕНИЯ> должно быть заполнено").
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "round-method").
    end.
    otherwise do:
      if LOOKUP(p-round-method, {&pr-rounds}) = 0 then do:
        assign
        v-error-message = substitute("Поле <МЕТОД ОКРУГЛЕНИЯ> может принимать значения &1", v-list).
        run err-mess in this-procedure ( input-output v-error-message).
        undo main-block, return error (if p-silent then v-error-message else "round-method").
      end.
    end.
  END CASE.
  if lookup(p-round-method, {&pr-rounds-need-coef}) > 0 and
  p-base = 0 then do:
    assign
    v-error-message = substitute("Неверное значение коэффициента 0 для метода округления").
     run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "round-method").
  end.
  run  grplib-analyze-grp-name in this-procedure
                                                  ( input p-node-name
                                                   ,input p-upper-code
                                                   ,output v-error-message ) no-error .
  if error-status:error or v-error-message <> "":U then do:
    assign
    v-error-message = substitute("Группа &1&2&3", p-node-name, {&new-line}, v-error-message).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "node-name").
  end.
  if can-find (ub.gds-grp where ub.gds-grp.upper-code = p-upper-code
                        AND gds-grp.node-name = p-node-name
                        and gds-grp.print-code = p-print-code
                        AND recid (ub.gds-grp) <> p-rid) then do:
    assign
    v-error-message = substitute("Группа &1&2Группа с таким названием уже есть"
                                , v-full-name
                                , {&new-line}).
    run err-mess in this-procedure ( input-output v-error-message).
    undo main-block, return error (if p-silent then v-error-message else "node-name").
  end.
  if p-fill-tax-from-upper then do:
    run ref/dtaxgrps.p (
                   input (if p-mode = {&add-def} then 0 else p-node-code)
                  ,input p-upper-code
                  ,input 0 /*p-host-code*/
                  ,input "":U /*p-obj-type*/
                  ,input 0 /*p-obj-code*/
                  ) no-error .
    if error-status:error then do:
      assign
      v-error-message = substitute("Группа &1&2Ошибка при заполнении записей НАЛОГИ ПО УМОЛЧАНИЮ ДЛЯ ГРУППЫ ТОВАРОВ&2&3&2&4"
                                  , v-full-name
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "").
    end.
  end.
  if p-mode = {&add-def} then do:
    create buf_gds-grp.
    assign
    buf_gds-grp.node-code = (if p-get-node-code
                            then  p-node-code
                            else next-value (s-gds-grp, {&db-name_schema}))
    buf_gds-grp.upper-code = p-upper-code
    buf_gds-grp.print-code = p-print-code
    p-node-code = buf_gds-grp.node-code
    .
  end.
  assign
  buf_gds-grp.node-name = p-node-name
  buf_gds-grp.calc-method = p-calc-method
  buf_gds-grp.increase-pc = p-increase-pc
  buf_gds-grp.print-code  = p-print-code
  p-rid = recid(buf_gds-grp)
  v-node-code = buf_gds-grp.node-code
  
  .
  release buf_gds-grp no-error.
  if error-status:error then do:
    assign
    v-error-message = substitute("Ошибка при сохранении группы товаров:&1&2&1&3"
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
      ,input "s-gds-grp":U
      ,input no
      ) no-error .
    if error-status :error then do:
      assign
      v-error-message = substitute("Ошибка при восстановлении последовательности вн.№ групп товаров:&1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value  ).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "").
    end.
  end.
 if p-mode = {&add-def} then do:
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = v-node-code
           and buf_gds-grp-obj.host-code  = 0
           and buf_gds-grp-obj.obj-type   = "":U
           and buf_gds-grp-obj.obj-code   = 0
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = v-node-code
                buf_gds-grp-obj.host-code  = 0
                buf_gds-grp-obj.obj-type   = "":U
                buf_gds-grp-obj.obj-code   = 0
        .
    end.
    assign
    buf_gds-grp-obj.min-increase =  ?
    buf_gds-grp-obj.max-increase = ?
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-base
    buf_gds-grp-obj.calc-method = p-calc-method
    .
  end.
  /*for news */
  if p-fill-tax-from-upper then do:
    run ref/dtaxgrpu.p (
                     input p-node-code
                    ,input p-upper-code
                    ,input yes
                    ,input 0 /*p-host-code*/
                    ,input "":U /*p-obj-type*/
                    ,input 0 /*p-obj-code*/
                    )  no-error.
    if error-status:error then do:
      assign
      v-error-message = substitute("Группа &1&2Ошибка при сохранении записей НАЛОГИ ПО УМОЛЧАНИЮ ДЛЯ ГРУППЫ ТОВАРОВ&2&3&2&4"
                                  , v-full-name
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
      run err-mess in this-procedure ( input-output v-error-message).
      undo main-block, return error (if p-silent then v-error-message else "").
    end.
  END.
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