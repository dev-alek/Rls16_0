block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cggrhisv.p $
$Archive: ref/cggrhisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/25/04
Author: Bakhtadze Natalya
Creation date: 08/25/04

*/

define input parameter p-node-code  like ub.c-gds-grp-hist.node-code no-undo .
define input parameter p-attr-code  like ub.c-gds-grp-hist.attr-code no-undo .
define input parameter p-tax-code  like ub.c-gds-grp-hist.tax-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-gds-grp-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-gds-grp-hist.chip-num no-undo .
define input parameter p-host-code like ub.c-gds-grp-hist.host-code no-undo .
define input parameter p-obj-type like ub.c-gds-grp-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-gds-grp-hist.obj-code no-undo .
define input parameter p-subject like ub.c-gds-grp-hist.subject no-undo .
define input parameter p-action   like ub.c-gds-grp-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define output parameter p-full-name-old as character no-undo .
define output parameter p-full-name-new as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cggrhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cggrhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории групп товаров".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ ref/grp-attr.i }
{ ref/disgrpru.i }
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action"}


find first buf_c-gds-grp-hist no-lock where
          buf_c-gds-grp-hist.node-code = p-node-code
      AND buf_c-gds-grp-hist.attr-code = p-attr-code
      AND buf_c-gds-grp-hist.tax-code = p-tax-code
      AND buf_c-gds-grp-hist.chip-num = p-chip-num
      AND buf_c-gds-grp-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-gds-grp-hist.host-code = p-host-code
      AND buf_c-gds-grp-hist.obj-type = p-obj-type
      AND buf_c-gds-grp-hist.obj-code = p-obj-code
      AND buf_c-gds-grp-hist.subject  = p-subject no-error .
if not available buf_c-gds-grp-hist then do:
  return error .
end.

CASE p-subject:
  when {&table_gds-grp} then do:
    run gds-grp-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_gds-grp-attr} then do:
    run gds-grp-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_gds-grp-obj} then do:
    run gds-grp-obj-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_tax-rate-gds-grp} then do:
    run tax-rate-gds-grp-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-grp-rule} then do:
    run dis-grp-rule-proc in this-procedure(output p-description) no-error .
  end.


END CASE.
if error-status:error then do:
  return error .
end.


procedure gds-grp-proc :
define output parameter p-description as character no-undo .

define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .



define buffer current_gds-grp for ub.gds-grp  .
define buffer current_c-gds-grp for ub.c-gds-grp  .
define buffer new_c-gds-grp for ub.c-gds-grp  .

  do
  on error undo, return error
  :
    find first current_c-gds-grp no-lock where
               current_c-gds-grp.node-code = p-node-code
           AND current_c-gds-grp.chip-num = p-chip-num
           AND current_c-gds-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-grp then do:
       v-mess = "Неверная ссылка на c-gds-grp в таблице c-gds-grp-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    if buf_c-gds-grp-hist.action = integer({&hn-create}) then do:
      assign
      v-is-created = yes
      v-chg-fields = get-all-fields ("gds-grp")
      .
    end.
    if buf_c-gds-grp-hist.action = integer({&hn-delete}) then do:
      assign
      v-is-deleted = yes
      v-chg-fields = get-all-fields ("gds-grp")
      .
    end.


    find first new_c-gds-grp no-lock where
               new_c-gds-grp.node-code = p-node-code
           AND new_c-gds-grp.chip-num > p-chip-num
           AND new_c-gds-grp.corr-user-db-num = p-corr-user-db-num
            no-error .
    if not available new_c-gds-grp then do:
        find first current_gds-grp no-lock where
               current_gds-grp.node-code = p-node-code no-error .
        if not available current_gds-grp
        and not  v-is-deleted
        then do:
            return error.
        end.
        if available current_gds-grp then
        buffer-compare current_gds-grp to current_c-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-gds-grp except chip-num corr-date corr-time corr-user-name corr-user-db-num
        to current_c-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    if lookup("node-code", v-chg-fields ) > 0
    or lookup("upper-code", v-chg-fields ) > 0 then do:
       if not v-is-created then
       run c-get-full-name  in this-procedure (
                                                  input  yes /* p-c */
                                                 ,input p-node-code
                                                 ,input p-chip-num
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-old
                                                ) no-error .
       if not v-is-deleted then
       run c-get-full-name  in this-procedure (
                                                  input  (if available new_c-gds-grp
                                                          then yes
                                                          else no) /* p-c */
                                                 ,input p-node-code
                                                 ,input (if available new_c-gds-grp
                                                         then new_c-gds-grp.chip-num
                                                         else 0)
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-new
                                                ) no-error .
    end.
&scop fields-name-list "calc-method,d-pcnt,increase-pc,is-term,lvl-num,node-code,node-name,unit-base,upper-code"
&scop fields-label-list  "Способ расчета,Процент скидки,Процент наценки,Терминальная,Уровень,Вн №,Наименование,Осн.ед.изм.,Вн № выш.группы"
&scop fields-function-list ",,,,,,,,"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    v-field-function = entry(jj, {&fields-function-list})
    .

    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if v-is-created
                           then "":U
                           else  string(buffer current_c-gds-grp:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new =  if available new_c-gds-grp
                          then string(buffer new_c-gds-grp:buffer-field(v-field-name):buffer-value)
                          else (if v-is-deleted
                                then '':U
                               else string(buffer current_gds-grp:buffer-field(v-field-name):buffer-value))
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.
end procedure. /* gds-grp-proc */


procedure gds-grp-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .

define buffer current_c-gds-grp-attr for ub.c-gds-grp-attr  .

  do
  on error undo, return error
  :
    find first current_c-gds-grp-attr no-lock where
               current_c-gds-grp-attr.node-code = p-node-code
           AND current_c-gds-grp-attr.attr-code = p-attr-code
           AND current_c-gds-grp-attr.host-code = p-host-code
           AND current_c-gds-grp-attr.obj-type  = p-obj-type
           AND current_c-gds-grp-attr.obj-code = p-obj-code
           AND current_c-gds-grp-attr.chip-num = p-chip-num
           AND current_c-gds-grp-attr.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-grp-attr then do:
       v-mess = "Неверная ссылка на c-gds-grp-attr в таблице c-gds-grp-attr-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    run grp-attr-tooltip in this-procedure (
                input  string(current_c-gds-grp-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list "node-code,attr-code,attr-value,host-code,obj-type,obj-code"
define variable v-label-param as character no-undo .

v-label-param =
  "node-code" + {&delim-par} + "Вн № группы" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-grp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-grp-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-gds-grp-attr:handle
                                            ,input  {&table_gds-grp-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* gds-grp-attr-proc */


procedure gds-grp-obj-proc :
define output parameter p-description as character no-undo .

define buffer current_c-gds-grp-obj for ub.c-gds-grp-obj  .

  do
  on error undo, return error
  :
    find first current_c-gds-grp-obj no-lock where
               current_c-gds-grp-obj.node-code = p-node-code
           AND current_c-gds-grp-obj.host-code = p-host-code
           AND current_c-gds-grp-obj.obj-type  = p-obj-type
           AND current_c-gds-grp-obj.obj-code = p-obj-code
           AND current_c-gds-grp-obj.chip-num = p-chip-num
           AND current_c-gds-grp-obj.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-gds-grp-obj then do:
       v-mess = "Неверная ссылка на c-gds-grp-obj в таблице c-gds-grp-obj-hist".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "node-code,host-code,obj-type,obj-code,calc-method,cli-code,cli-type,increase-pc,max-increase," + ~
"min-increase,round-coeff,round-method"

                                             define variable v-label-param as character no-undo .

v-label-param =
  "node-code" + {&delim-par} + "Вн № группы" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "calc-method" + {&delim-par} + "Способ расчета" + {&delim-par} + "" + {&delim-flf}
 + "cli-code" + {&delim-par} + "Код поставщика" + {&delim-par} + "" + {&delim-flf}
 + "cli-type" + {&delim-par} + "Тип поставщика" + {&delim-par} + "" + {&delim-flf}
 + "increase-pc" + {&delim-par} + "% наценки" + {&delim-par} + "" + {&delim-flf}
 + "max-increase" + {&delim-par} + "Max % наценки" + {&delim-par} + "" + {&delim-flf}
 + "min-increase" + {&delim-par} + "Min % наценки" + {&delim-par} + "" + {&delim-flf}
 + "round-coeff" + {&delim-par} + "Коэф.округ." + {&delim-par} + "" + {&delim-flf}
 + "round-method" + {&delim-par} + "Метод округл." + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-grp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-grp-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-gds-grp-obj:handle
                                            ,input  {&table_gds-grp-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* gds-grp-obj-proc */


procedure tax-rate-gds-grp-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp  .
define buffer buf_tax for ub.tax.

  do
  on error undo, return error
  :
    find first current_c-tax-rate-gds-grp no-lock where
               current_c-tax-rate-gds-grp.node-code = p-node-code
           AND current_c-tax-rate-gds-grp.tax-code = p-tax-code
           AND current_c-tax-rate-gds-grp.host-code = p-host-code
           AND current_c-tax-rate-gds-grp.obj-type  = p-obj-type
           AND current_c-tax-rate-gds-grp.obj-code = p-obj-code
           AND current_c-tax-rate-gds-grp.chip-num = p-chip-num
           AND current_c-tax-rate-gds-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax-rate-gds-grp then do:
       v-mess = "Неверная ссылка на c-tax-rate-gds-grp в таблице c-tax-rate-gds-grp-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    find first buf_tax no-lock where buf_tax.tax-code = p-tax-code .
    assign
    p-description = buf_tax.tax-name
    .
&scop fields-name-list "node-code,host-code,obj-type,obj-code,tax-code,rate-code"

  define variable v-label-param as character no-undo .

v-label-param =
  "node-code" + {&delim-par} + "Вн № группы" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "tax-code" + {&delim-par} + "Код налога" + {&delim-par} + "" + {&delim-flf}
 + "rate-code" + {&delim-par} + "Код ставки налога" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-grp-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-grp-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-tax-rate-gds-grp:handle
                                            ,input  {&table_tax-rate-gds-grp}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* tax-rate-gds-grp-proc */


procedure dis-grp-rule-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-grp-rule for ub.c-dis-grp-rule  .

  do
  on error undo, return error
  :
    find first current_c-dis-grp-rule no-lock where
               current_c-dis-grp-rule.classif-type = {&table_gds-grp}
           AND current_c-dis-grp-rule.node-code = p-node-code
           AND current_c-dis-grp-rule.host-code  = p-host-code
           AND current_c-dis-grp-rule.obj-type  = p-obj-type
           AND current_c-dis-grp-rule.obj-code = p-obj-code
           AND current_c-dis-grp-rule.chip-num = p-chip-num
           AND current_c-dis-grp-rule.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-dis-grp-rule then do:
       v-mess = "Неверная ссылка на c-dis-grp-rule в таблице c-dis-grp-rule-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
    define variable v-label-param as character no-undo .
    &scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role"
v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Место использ." + {&delim-par} + "" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Тип шаблона" + {&delim-par} + "disgrpru-get-disc-label"  + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disgrpru-get-disc-role-label"
 .
    run proc-full-temp-changes in this-procedure (
                                                input  (p-action = integer({&hn-create}))
                                                ,input  (p-action = integer({&hn-delete}))
                                                ,input  buffer current_c-dis-grp-rule:handle
                                                ,input  {&table_dis-grp-rule}
                                                ,input  {&fields-name-list}
                                                ,input  v-label-param).


end.
end procedure. /* dis-grp-rule-proc */




procedure c-get-full-name :
/*получение полного имени группы с учетом изменений во времени*/
do
on error undo, return error
:
define input parameter p-c          as logical no-undo .
define input parameter p-node-code  as integer      no-undo.
define input parameter p-chip-num  as integer no-undo .
define input parameter p-corr-user-db-num as integer no-undo .
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define variable v-c as logical no-undo .

    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.

    define buffer buf_c-gds-grp       for ub.c-gds-grp.
    define buffer buf_c-upper_gds-grp for ub.c-gds-grp.

    if p-c then do:
      find first buf_c-gds-grp no-lock
          where buf_c-gds-grp.node-code = p-node-code
            AND buf_c-gds-grp.chip-num  = p-chip-num
            AND buf_c-gds-grp.corr-user-db-num  = p-corr-user-db-num
      no-error.
      if not available buf_c-gds-grp
      then do:
          undo, return error substitute("Не найдена запись истории для группа товаров: вн № &1, chip-num &2, БД-корректор &3"
                                        , p-node-code
                                        , p-chip-num
                                        , p-corr-user-db-num
                                        ).
      end.
    end.
    else do:
      find first buf_gds-grp no-lock
          where buf_gds-grp.node-code = p-node-code
      no-error.
      if not available buf_gds-grp
      then do:
          undo, return error substitute("Не найдена запись группы товаров: вн № &1"
                                        , p-node-code
                                        ).
      end.
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
        v-c = p-c
    .
    do while
    ( v-c = no and buf_gds-grp.upper-code <> 0)
    or ( v-c = yes and  buf_c-gds-grp.upper-code <> 0)
    on error undo, return error "Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = (if v-c = yes
                            then buf_c-gds-grp.node-name
                            else buf_gds-grp.node-name)
                         + (if p-full-name <> "" then {&delim-grp} else "")
                         + p-full-name
            v-upper-code = (if v-c
                            then buf_c-gds-grp.upper-code
                            else buf_gds-grp.upper-code)
        .
        find first buf_c-gds-grp no-lock
             where buf_c-gds-grp.node-code = v-upper-code
               AND buf_c-gds-grp.chip-num  > p-chip-num
               AND buf_c-gds-grp.corr-user-db-num  > p-corr-user-db-num no-error .
        if not available buf_c-gds-grp then do:
          assign
          v-c = no
          .
          find first buf_gds-grp no-lock
              where buf_gds-grp.node-code = v-upper-code
          no-error.
          if not available buf_gds-grp
          then do:
              undo, return error substitute("Не найдена группа товаров с кодом &1" +
                                             ". Ошибка ссылки в дереве товаров для записи истории групп товаров:" +
                                             "вн № &2, chip-num &3, БД-корректор &4"
                                            ,  v-upper-code
                                            ,  p-node-code
                                            , p-chip-num
                                            , p-corr-user-db-num).
          end.
        end.
        else do:
          assign
          v-c = yes
          .
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else {&delim-grp})
    .
end.
end procedure. /* grplib-get-full-name */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("История групп товаров&1" +
                          "Вн Код группы: &2&1" +
                          "щепка &3 БД:&4&1&5&6"
                          ,{&new-line}
                          ,p-node-code
                          ,p-chip-num
                          ,p-corr-user-db-num
                          ,{&new-line}
                          ,p-mess).

    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.