block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ctaxhisv.p $
$Archive: ref/ctaxhisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории налогов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/17/04
Author: Bakhtadze Natalya
Creation date: 08/17/04

*/

define input parameter p-tax-code  like ub.c-tax-hist.tax-code no-undo .
define input parameter p-rate-code like ub.c-tax-hist.rate-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-tax-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-tax-hist.chip-num no-undo .
define input parameter p-host-code like ub.c-tax-hist.host-code no-undo .
define input parameter p-obj-type like ub.c-tax-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-tax-hist.obj-code no-undo .
define input parameter p-subject like ub.c-tax-hist.subject no-undo .
define input parameter p-action   like ub.c-tax-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ctaxhisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ctaxhisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории налогов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-tax-hist for ub.c-tax-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


if p-action = integer({&hn-delete}) then return.
find first buf_c-tax-hist no-lock where
          buf_c-tax-hist.tax-code = p-tax-code
      AND buf_c-tax-hist.rate-code = p-rate-code
      AND buf_c-tax-hist.chip-num = p-chip-num
      AND buf_c-tax-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-tax-hist.host-code = p-host-code
      AND buf_c-tax-hist.obj-type = p-obj-type
      AND buf_c-tax-hist.obj-code = p-obj-code
      AND buf_c-tax-hist.subject  = p-subject no-error .
if not available buf_c-tax-hist then do:
  return error .
end.

CASE p-subject:
  when {&table_tax} then do:
    run tax-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_tax-rate} then do:
    run tax-rate-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_tax-rate-value} then do:
    run tax-rate-value-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_tax-units} then do:
    run tax-units-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.


procedure tax-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax for ub.c-tax  .

  do
  on error undo, return error
  :
    find first current_c-tax no-lock where
               current_c-tax.tax-code = p-tax-code
           AND current_c-tax.chip-num = p-chip-num
           AND current_c-tax.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax then do:
       v-mess = "Неверная ссылка на c-tax в таблице c-tax-hist".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "individual,status_,tax-code,tax-name,tax-type,to-cashdesk"

define variable v-label-param as character no-undo .

v-label-param =
  "individual" + {&delim-par} + "Индивидуальный" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "tax-code" + {&delim-par} + "Код" + {&delim-par} + "" + {&delim-flf}
 + "tax-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "tax-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "to-cashdesk" + {&delim-par} + "Посылать ли на кассу" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-tax-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-tax-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-tax:handle
                                            ,input  {&table_tax}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.
end procedure. /* tax-proc */


procedure tax-rate-value-proc :
define output parameter p-description as character no-undo .
define variable v-first as logical no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-old-rate-value like ub.tax-rate-value.rate-value no-undo .
define variable v-new-rate-value like ub.tax-rate-value.rate-value no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .



define buffer curr_c-tax-rate-value for ub.tax-rate-value  .
define buffer prev_c-tax-rate-value for ub.tax-rate-value.
define buffer buf_tax for ub.tax.

  do
  on error undo, return error
  :
    find first buf_tax no-lock where buf_tax.tax-code = p-tax-code .
    assign
    p-description = substitute("&1, ставка &2", buf_tax.tax-name, p-rate-code)
    .
    find first curr_c-tax-rate-value no-lock where
              curr_c-tax-rate-value.tax-code =  p-tax-code
           AND curr_c-tax-rate-value.rate-code = p-rate-code
           AND curr_c-tax-rate-value.host-code = p-host-code
           AND curr_c-tax-rate-value.obj-type = p-obj-type
           AND curr_c-tax-rate-value.obj-code  = p-obj-code
           AND curr_c-tax-rate-value.chip-num = p-chip-num
           AND curr_c-tax-rate-value.corr-user-db-num = p-corr-user-db-num
           no-error .
    if available curr_c-tax-rate-value then do:
      find last prev_c-tax-rate-value no-lock where
                  prev_c-tax-rate-value.tax-code = p-rate-code
              AND prev_c-tax-rate-value.rate-code = p-rate-code
              AND prev_c-tax-rate-value.host-code = p-host-code
              AND prev_c-tax-rate-value.obj-type = p-obj-type
              AND prev_c-tax-rate-value.obj-code  = p-obj-code
              AND prev_c-tax-rate-value.fact-order < curr_c-tax-rate-value.fact-order
              no-error.
      if not avail prev_c-tax-rate-value then do:
        assign
        v-first = yes
        .
      end.
    end.
    if available curr_c-tax-rate-value
    and available prev_c-tax-rate-value then do:
      buffer-compare curr_c-tax-rate-value except chip-num corr-date corr-time corr-user-name corr-user-db-num corr-time
      to prev_c-tax-rate-value
      save result in v-chg-fields.
    end.
    else do:
      assign
      v-chg-fields =  "rate-value,fact-date" .
    end.

&scop fields-name-list "rate-value,fact-date,status_"
&scop fields-label-list  "Значение,Дата включения,Статус"
&scop fields-function-list ",,"


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
    temp-changes.v_old =  (if (v-first or temp-changes.f_name  <> "rate-value")
                           then '':U
                          else  (if temp-changes.f_name = "rate-value":U
                                 then string(v-old-rate-value)
                                 else  string(buffer prev_c-tax-rate-value:buffer-field(v-field-name):buffer-value)
                                 )
                          )
    temp-changes.v_new =  if available curr_c-tax-rate-value
                          then string(buffer curr_c-tax-rate-value:buffer-field(v-field-name):buffer-value)
                          else {&question-mark}
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.

end procedure. /* tax-rate-value-proc */



procedure tax-rate-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax-rate for ub.c-tax-rate  .
define buffer buf_tax for ub.tax.

  do
  on error undo, return error
  :

    find first buf_tax no-lock where buf_tax.tax-code = p-tax-code .
    assign
    p-description = substitute("&1, ставка &2", buf_tax.tax-name, p-rate-code)
    .

    find first current_c-tax-rate no-lock where
               current_c-tax-rate.tax-code = p-tax-code
           AND current_c-tax-rate.rate-code = p-rate-code
           AND current_c-tax-rate.chip-num = p-chip-num
           AND current_c-tax-rate.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax-rate then do:
       v-mess = "Неверная ссылка на c-tax-rate в таблице c-tax-hist".
       run err-mess in this-procedure ( input-output v-mess ).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "rate-code,rate-name,status_,tax-code"
define variable v-label-param as character no-undo .

v-label-param =
  "rate-code" + {&delim-par} + "Код ставки" + {&delim-par} + "" + {&delim-flf}
 + "rate-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "tax-code" + {&delim-par} + "Код налога" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-tax-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-tax-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-tax-rate:handle
                                            ,input  {&table_tax-rate}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* tax-rate-proc */


procedure tax-units-proc :
define output parameter p-description as character no-undo .
define buffer current_c-tax-units for ub.c-tax-units  .

  do
  on error undo, return error
  :


    find first current_c-tax-units no-lock where
               current_c-tax-units.tax-code = p-tax-code
           AND current_c-tax-units.TYPE = buf_c-tax-hist.type
           AND current_c-tax-units.chip-num = p-chip-num
           AND current_c-tax-units.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-tax-units then do:
       v-mess = "Неверная ссылка на c-tax-units в таблице c-tax-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list "type,tax-code"
define variable v-label-param as character no-undo .

v-label-param =
  "type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "tax-code" + {&delim-par} + "Код налога" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-tax-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-tax-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-tax-units:handle
                                            ,input  {&table_tax-units}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.
end procedure. /* tax-units */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess =
      substitute("История налога &1 ставка &2: щепка &3 БД:&4 фирма: &5 объект &6&7 Предмет изменений &8",
                 p-tax-code, p-rate-code,  p-chip-num, p-corr-user-db-num, p-host-code, p-obj-type, p-obj-code, p-subject) +
                 {&new-line} + p-mess.

    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.