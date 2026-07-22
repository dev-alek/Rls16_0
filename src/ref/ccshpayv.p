block-level on error undo, throw.
/*

$Revision: 99feb687c1d2, 89, rls $
$Author: EShklyar $
$Date: Thu Oct 30 18:56:09 2014 +0300 $
$Workfile: ccshpayv.p $
$Archive: ref/ccshpayv.p $

Заполнение временной таблицы для показа изменений по таблицам истории касс платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/04/04
Author: Bakhtadze Natalya
Creation date: 06/04/04

*/


define input parameter  p-cdpay-code            like  ub.c-cash-pay.cdpay-code         no-undo .
define input parameter  p-curr-code             like  ub.c-cash-pay.curr-code          no-undo .
define input parameter  p-attr-code             like  ub.c-cash-pay.attr-code          no-undo .
define input parameter  p-corr-user-db-num      like  ub.c-cash-pay.corr-user-db-num   no-undo .
define input parameter  p-chip-num              like  ub.c-cash-pay.chip-num           no-undo .
define input parameter  p-subject               like  ub.c-cash-pay.subject            no-undo .
define input parameter p-action   like ub.c-cash-pay.action no-undo .
define input parameter p-silent  as logical no-undo .
define input parameter p-log-file as character no-undo .
define output parameter p-description as character no-undo .



define variable vss-revision    as character no-undo init "$Revision: 99feb687c1d2, 89, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Oct 30 18:56:09 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ccshpayv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/ccshpayv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории касс платежей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/discprul.i }
{ ref/cp-attr.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-cash-pay for ub.c-cash-pay.

{ ref/tmpchgs.i "SHARED" " " "with-action" }

if p-action = integer({&hn-delete}) then return.
find first buf_c-cash-pay no-lock where
          buf_c-cash-pay.cdpay-code   = p-cdpay-code
      AND buf_c-cash-pay.curr-code = p-curr-code
      AND buf_c-cash-pay.corr-user-db-num = p-corr-user-db-num
      AND buf_c-cash-pay.chip-num = p-chip-num
      AND buf_c-cash-pay.subject  = p-subject no-error .
if not available buf_c-cash-pay then do:
  return error .
end.

CASE p-subject:
  when {&table_cash-pay} or when "":U then do:
    run cash-pay-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_cash-pay-attr} then do:
    run cash-pay-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-cp-rule} then do:
    run dis-cp-rule-proc in this-procedure(output p-description) no-error .
  end.

END CASE.
if error-status:error then do:
  return error .
end.


procedure cash-pay-proc :
define output parameter p-description as character no-undo .
define buffer current_c-cash-pay for ub.c-cash-pay  .


  do
  on error undo, return error
  :
    find first current_c-cash-pay no-lock where
               current_c-cash-pay.cdpay-code   = p-cdpay-code
           AND current_c-cash-pay.curr-code = p-curr-code
           AND current_c-cash-pay.corr-user-db-num = p-corr-user-db-num
           AND current_c-cash-pay.chip-num = p-chip-num
           no-error .
    if not avail current_c-cash-pay then do:
       v-mess = "Неверная ссылка на c-cash-pay в таблице c-cash-pay".
       run err-mess in this-procedure ( input-output v-mess).
       return error.
    end.

define variable v-label-param as character no-undo .

&scop fields-name-list   "atr1,atr128,atr16,atr2,atr32," + ~
"atr4,atr64,atr8,cdpay-code,curr-code,is-advance," + ~
"is-all-pay,is-bar-read,is-card-swap,is-cash,is-credit,is-credit-card,is-debet-card,is-goods-pay,is-service-pay," + ~
"obj-name,pay-card-view,pay-code,pay-limit,rule-file-name,slip-file-name,status_,wth-code,register"


v-label-param =
  "atr1" + {&delim-par} + "Разрешается сдача на платеж" + {&delim-par} + "" + {&delim-flf}
 + "atr128" + {&delim-par} + "Smart карта" + {&delim-par} + "" + {&delim-flf}
 + "atr16" + {&delim-par} + "Необходима on-line авторизаци" + {&delim-par} + "" + {&delim-flf}
 + "atr2" + {&delim-par} + "Разрешается перевод оплаты на платеж" + {&delim-par} + "" + {&delim-flf}
 + "atr32" + {&delim-par} + "Обязателен ввод PIN-кода" + {&delim-par} + "" + {&delim-flf}
 + "atr4" + {&delim-par} + "Принудительная печать слипа по платежу" + {&delim-par} + "" + {&delim-flf}
 + "atr64" + {&delim-par} + "Топливный платеж" + {&delim-par} + "" + {&delim-flf}
 + "atr8" + {&delim-par} + "Принудительная печать фактуры по платежу" + {&delim-par} + "" + {&delim-flf}
 + "cdpay-code" + {&delim-par} + "Код" + {&delim-par} + "" + {&delim-flf}
 + "curr-code" + {&delim-par} + "Код валюты" + {&delim-par} + "" + {&delim-flf}
 + "is-advance" + {&delim-par} + "Учет авансового платежа" + {&delim-par} + "" + {&delim-flf}
 + "is-all-pay" + {&delim-par} + "<Общий> платеж" + {&delim-par} + "" + {&delim-flf}
 + "is-bar-read" + {&delim-par} + "Сканер бар-кодов" + {&delim-par} + "" + {&delim-flf}
 + "is-card-swap" + {&delim-par} + "<Прокатывать> карту" + {&delim-par} + "" + {&delim-flf}
 + "is-cash" + {&delim-par} + "Наличные" + {&delim-par} + "" + {&delim-flf}
 + "is-credit" + {&delim-par} + "Кредит" + {&delim-par} + "" + {&delim-flf}
 + "is-credit-card" + {&delim-par} + "Кред.карта" + {&delim-par} + "" + {&delim-flf}
 + "is-debet-card" + {&delim-par} + "Расчетн.карта" + {&delim-par} + "" + {&delim-flf}
 + "is-goods-pay" + {&delim-par} + "Платеж за товары" + {&delim-par} + "" + {&delim-flf}
 + "is-service-pay" + {&delim-par} + "Сервисный платеж" + {&delim-par} + "" + {&delim-flf}
 + "obj-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "pay-card-view" + {&delim-par} + "Виден N плат.карты" + {&delim-par} + "" + {&delim-flf}
 + "pay-code" + {&delim-par} + "Оплата" + {&delim-par} + "" + {&delim-flf}
 + "pay-limit" + {&delim-par} + "Предел без авторизации" + {&delim-par} + "" + {&delim-flf}
 + "rule-file-name" + {&delim-par} + "Файл правила обработки" + {&delim-par} + "" + {&delim-flf}
 + "slip-file-name" + {&delim-par} + "Файл слипа" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "wth-code" + {&delim-par} + "Код МЦ" + {&delim-par} + "" + {&delim-flf}
 + "register" + {&delim-par} + "Ведомость" + {&delim-par} + ""  +  {&delim-flf}
 + "is-kbo" + {&delim-par} + "КБО" + {&delim-par} + "" +  {&delim-flf}
 + "can-mix" + {&delim-par} + "Разрешена смеш.оплата" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cash-pay.action = integer({&hn-create}))
                                            ,input  (buf_c-cash-pay.action = integer({&hn-delete}))
                                            ,input  buffer current_c-cash-pay:handle
                                            ,input  {&table_cash-pay}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* cash-pay-proc */



procedure cash-pay-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-cash-pay-attr for ub.c-cash-pay-attr  .


  do
  on error undo, return error
  :
    find first current_c-cash-pay-attr no-lock where
               current_c-cash-pay-attr.cdpay-code   = p-cdpay-code
           AND current_c-cash-pay-attr.curr-code = p-curr-code
           AND current_c-cash-pay-attr.chip-num = p-chip-num
           AND current_c-cash-pay-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-cash-pay-attr.attr-code  = buf_c-cash-pay.attr-code
           no-error .
    if not avail current_c-cash-pay-attr then do:
       v-mess = "Неверная ссылка на c-cash-pay-attr в таблице c-cash-pay".
       run err-mess in this-procedure ( input-output v-mess).
       return error.
    end.
    run cp-attr-tooltip in this-procedure (
                input  current_c-cash-pay-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .

    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list  "attr-value"

define variable v-label-param as character no-undo .

&scop fields-name-list   "cdpay-code,curr-code,attr-code,obj-type,obj-code,host-code,attr-value"

v-label-param =
  "cdpay-code" + {&delim-par} + "Код" + {&delim-par} + "" + {&delim-flf}
 + "curr-code" + {&delim-par} + "Код валюты" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cash-pay.action = integer({&hn-create}))
                                            ,input  (buf_c-cash-pay.action = integer({&hn-delete}))
                                            ,input  buffer current_c-cash-pay-attr:handle
                                            ,input  {&table_cash-pay-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* cash-pay-attr-proc */

procedure dis-cp-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-cp-rule for ub.c-dis-cp-rule  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-dis-cp-rule no-lock where
               current_c-dis-cp-rule.cdpay-code = p-cdpay-code
           AND current_c-dis-cp-rule.curr-code = p-curr-code
           AND current_c-dis-cp-rule.chip-num = p-chip-num
           AND current_c-dis-cp-rule.corr-user-db-num = p-corr-user-db-num    no-error .
    run discpru-name in this-procedure (
                input  current_c-dis-cp-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .

&scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role,host-code,obj-type,obj-code"


define variable v-label-param as character no-undo .

v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Тип POS" + {&delim-par} + "" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Шаблон скидки" + {&delim-par} + "discpru-get-disc-label" + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "discpru-get-disc-role-label" + {&delim-flf}
 + "host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cash-pay.action = integer({&hn-create}))
                                            ,input  (buf_c-cash-pay.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-cp-rule:handle
                                            ,input  {&table_dis-cp-rule}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* dis-cp-rule-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История касс. платежа  код платежа &1 код валюты &2 : щепка &3 Предмет изменений &4&5&6"
                 ,p-cdpay-code
                 ,p-curr-code
                 ,p-chip-num
                 ,p-subject
                 , {&new-line}
                 , p-mess
                 ).

    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.