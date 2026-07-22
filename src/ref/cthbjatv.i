/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/29/08
Author: Bakhtadze Natalya
Creation date: 09/29/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rul/calldscr.i }

define variable v-thbj-attr-uniq-key-rec as character no-undo .
define buffer current_c-thbj-attr for ub.c-thbj-attr.
function  getPSwd returns character (istr as char ):
   
   return fill("*",length(istr)).
   
end.

procedure thbj-attr-self-proc :
define input parameter p-action as integer no-undo .
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-tooltip-code as character no-undo .
define variable v-global as logical no-undo .
define variable v-host as logical no-undo .
define variable v-shop as logical no-undo .
define variable v-store as logical no-undo .
define variable v-db as logical   no-undo .
define variable v-other as character no-undo .
define variable v-user-can-edit as logical no-undo .
define variable v-output-display as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-prop-type-list as character no-undo .
define variable v-prop-label-list as character no-undo .
define variable v-fields-name-list as character no-undo .
define variable v-label-param as character no-undo .
define variable v-prop-code-num as integer no-undo .
define variable v-type as character no-undo .


do
on error undo, return error
:
  run thbjattr_tooltip in this-procedure (
                input  current_c-thbj-attr.upper-prop-code
              ,input  current_c-thbj-attr.prop-code
              ,output v-tooltip
              ,output v-label
              ,output v-tooltip-code
              ) no-error .
  p-description = "Параметр" + {&space-char} + v-label.
  run thbjattr_code in this-procedure (
      input  current_c-thbj-attr.upper-prop-code
      ,input current_c-thbj-attr.prop-code
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ,output v-prop-list
      ,output v-prop-type-list
      ,output v-prop-label-list
      ,output v-global
      ,output v-host
      ,output v-shop
      ,output v-store
      ,output v-db
      ) no-error .


  assign
  v-prop-code-num = lookup(current_c-thbj-attr.prop-code, v-prop-list)
  v-type = entry(v-prop-code-num, v-prop-type-list)
  no-error
  .
  if current_c-thbj-attr.subject = {&table_thbj-attr}
  or current_c-thbj-attr.subject = ''
  then do:
    &scop fields-name-list "upper-prop-code, prop-code,prop-value-type,obj-type,obj-code"
    v-label-param =  "upper-prop-code" + {&delim-par} + "Группа параметра" + {&delim-par} + "" + {&delim-flf}
                    + " prop-code" + {&delim-par} + "Параметр" + {&delim-par} + "" + {&delim-flf}
                    + "prop-value-type" + {&delim-par} + "Тип Значения" + {&delim-par} + "" + {&delim-flf}
                    + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
                    + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + ""  .

    case v-type:
      when {&abl-datatype-character} then do:
         if     current_c-thbj-attr.upper-prop-code eq "gismt"
            and (current_c-thbj-attr.prop-code eq "oflinepswd"
                 or current_c-thbj-attr.prop-code eq "proxypswd"
                 or current_c-thbj-attr.prop-code eq "MaxApiToken")
         then v-label-param = "property-value-character" + {&delim-par} + "Значение(строк.)" + {&delim-par} + "getpswd" + {&delim-flf} +
                      v-label-param.
         else assign
             v-label-param = "property-value-character" + {&delim-par} + "Значение(строк.)" + {&delim-par} + "" + {&delim-flf} +
                      v-label-param.
        v-fields-name-list = "property-value-character," + {&fields-name-list}.
      end.
      when {&abl-datatype-date} then do:
        v-label-param = "property-value-date" + {&delim-par} + "Значение(Дата)" + {&delim-par} + "" + {&delim-flf}  +
                      v-label-param.
        v-fields-name-list = "property-value-date," + {&fields-name-list}.
      end.
      when {&abl-datatype-decimal} then do:
        v-label-param = "property-value-decimal" + {&delim-par} + "Значение" + {&delim-par} + "" + {&delim-flf} +
                        v-label-param.
        v-fields-name-list = "property-value-decimal," + {&fields-name-list}.
      end.
      when {&abl-datatype-integer} then do:
        v-label-param = "property-value-integer" + {&delim-par} + "Значение" + {&delim-par} + "" + {&delim-flf} +
                        v-label-param.
        v-fields-name-list = "property-value-integer," + {&fields-name-list}.
      end.
      when {&abl-datatype-logical} then do:
        v-label-param = "property-value-logical" + {&delim-par} + "Значение" + {&delim-par} + "" + {&delim-flf} +
        v-label-param.
        v-fields-name-list = "property-value-logical," + {&fields-name-list}.
      end.
    end case.


    run proc-full-temp-changes in this-procedure (
                                                input p-action = integer({&hn-create})
                                                ,input p-action = integer({&hn-delete})
                                                ,input  buffer current_c-thbj-attr:handle
                                                ,input  {&table_thbj-attr}
                                                ,input  v-fields-name-list
                                                ,input  v-label-param).

  end.
end.
end procedure. /* thbj-attr */

procedure rp-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rp-by-call for ub.c-rp-by-call .

  do
  on error undo, return error
  :
    find first current_c-rp-by-call no-lock where
               current_c-rp-by-call.chip-num = current_c-thbj-attr.chip-num
           AND current_c-rp-by-call.corr-user-db-num = current_c-thbj-attr.corr-user-db-num
           AND current_c-rp-by-call.call_id = v-thbj-attr-uniq-key-rec no-error .
    if not avail current_c-rp-by-call then do:
       v-mess = "Неверная ссылка на c-rp-by-call в таблице c-thbj-attr".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "call_id,call#_id,profile_id"

define variable v-label-param as character no-undo .

v-label-param =
  "call_id" + {&delim-par} + "Точка вызова" + {&delim-par} + "calldscr" + {&delim-flf}
 + "call#_id" + {&delim-par} + "Уник.идент.точки вызова" + {&delim-par} + "" + {&delim-flf}
 + "profile_id" + {&delim-par} + "Профайл" + {&delim-par} + "" .
 run proc-full-temp-changes in this-procedure (
                                             input  (current_c-thbj-attr.action = integer({&hn-create}))
                                            ,input  (current_c-thbj-attr.action = integer({&hn-delete}))
                                            ,input  buffer current_c-rp-by-call:handle
                                            ,input  {&table_rp-by-call}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.
end procedure. /* rp-by-call-proc */

procedure rule-by-call-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-by-call for ub.c-rule-by-call .

  do
  on error undo, return error
  :
    find first current_c-rule-by-call no-lock where
               current_c-rule-by-call.chip-num = current_c-thbj-attr.chip-num
           AND current_c-rule-by-call.corr-user-db-num = current_c-thbj-attr.corr-user-db-num
           AND current_c-rule-by-call.call_id = v-thbj-attr-uniq-key-rec no-error .
    if not avail current_c-rule-by-call then do:
       v-mess = "Неверная ссылка на c-rule-by-call в таблице c-thbj-attr".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "call_id,call#_id,profile_id,can-calc,can-run,codex_id,ruleset_id,order_id,algo-des,rule_id,is_dynamic"

define variable v-label-param as character no-undo .

v-label-param =
  "call_id" + {&delim-par} + "Точка вызова" + {&delim-par} + "calldscr" + {&delim-flf}
 + "call#_id" + {&delim-par} + "Уник.идент.точки вызова" + {&delim-par} + "" + {&delim-flf}
 + "profile_id" + {&delim-par} + "Профайл" + {&delim-par} + ""  + {&delim-flf}
 + "can-calc" + {&delim-par} + "Включено" + {&delim-par} + ""  + {&delim-flf}
 + "can-run" + {&delim-par} + "Может быть включено" + {&delim-par} + ""  + {&delim-flf}
 + "codex_id" + {&delim-par} + "Кодекс" + {&delim-par} + ""  + {&delim-flf}
 + "ruleset_id" + {&delim-par} + "Набор правил" + {&delim-par} + ""  + {&delim-flf}
 + "order_id" + {&delim-par} + "Порядок вызова" + {&delim-par} + ""  + {&delim-flf}
 + "rule_id" + {&delim-par} + "№ правила" + {&delim-par} + ""  + {&delim-flf}
 + "algo-des" + {&delim-par} + "Описание правила" + {&delim-par} + ""  + {&delim-flf}
 + "is_dynamic" + {&delim-par} + "Отключаемое" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (current_c-thbj-attr.action = integer({&hn-create}))
                                            ,input  (current_c-thbj-attr.action = integer({&hn-delete}))
                                            ,input  buffer current_c-rule-by-call:handle
                                            ,input  {&table_rule-by-call}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.


end procedure. /* rule-by-call-proc */

procedure rule-call-param-proc :
define output parameter p-description as character no-undo .
define buffer current_c-rule-call-param for ub.c-rule-call-param .

  do
  on error undo, return error
  :
    find first current_c-rule-call-param no-lock where
               current_c-rule-call-param.chip-num = current_c-thbj-attr.chip-num
           AND current_c-rule-call-param.corr-user-db-num = current_c-thbj-attr.corr-user-db-num
           AND current_c-rule-call-param.call_id = v-thbj-attr-uniq-key-rec no-error .
    if not avail current_c-rule-call-param then do:
       v-mess = "Неверная ссылка на c-rule-call-param в таблице c-thbj-attr".
       run err-mess(input-output v-mess).
    end.

&scop fields-name-list "call_id,call#_id,profile_id,codex_id,ruleset_id,order_id,rule_id,~
param-des,param-data-type,param-label,param-mode,param-name,param-num,param-value-character,~
param-value-date,param-value-decimal,param-value-integer,param-value-logical"

define variable v-label-param as character no-undo .

v-label-param =
  "call_id" + {&delim-par} + "Точка вызова" + {&delim-par} + "calldscr" + {&delim-flf}
 + "call#_id" + {&delim-par} + "Уник.идент.точки вызова" + {&delim-par} + "" + {&delim-flf}
 + "profile_id" + {&delim-par} + "Профайл" + {&delim-par} + ""  + {&delim-flf}
 + "codex_id" + {&delim-par} + "Кодекс" + {&delim-par} + ""  + {&delim-flf}
 + "ruleset_id" + {&delim-par} + "Набор правил" + {&delim-par} + ""  + {&delim-flf}
 + "order_id" + {&delim-par} + "Порядок вызова" + {&delim-par} + ""  + {&delim-flf}
 + "rule_id" + {&delim-par} + "№ правила" + {&delim-par} + ""  + {&delim-flf}
 + "param-des" + {&delim-par} + "Описание параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-data-type" + {&delim-par} + "Тип данных" + {&delim-par} + ""  + {&delim-flf}
 + "param-2-data-type" + {&delim-par} + "Тип данных2" + {&delim-par} + ""  + {&delim-flf}
 + "param-3-data-type" + {&delim-par} + "Тип данных3" + {&delim-par} + ""  + {&delim-flf}
 + "param-label" + {&delim-par} + "Лейбл параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-mode" + {&delim-par} + "Мода параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-name" + {&delim-par} + "Имя параметра" + {&delim-par} + ""  + {&delim-flf}
 + "p-index" + {&delim-par} + "Индекс" + {&delim-par} + ""  + {&delim-flf}
 + "param-num" + {&delim-par} + "№ параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-character" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-date" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-decimal" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-integer" + {&delim-par} + "Значение параметра" + {&delim-par} + ""  + {&delim-flf}
 + "param-value-logical" + {&delim-par} + "Значение параметра" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (current_c-thbj-attr.action = integer({&hn-create}))
                                            ,input  (current_c-thbj-attr.action = integer({&hn-delete}))
                                            ,input  buffer current_c-rule-call-param:handle
                                            ,input  {&table_rule-call-param}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.


end procedure. /* rule-call-param-proc */



/* $Workfile$ e n d */