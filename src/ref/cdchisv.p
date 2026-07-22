block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cdchisv.p $
$Archive: ref/cdchisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/

define input parameter p-d-card  like ub.c-dc-hist.d-card no-undo .
define input parameter p-chip-num like ub.c-dc-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-dc-hist.corr-user-db-num no-undo .
define input parameter p-obj-type like ub.c-dc-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-dc-hist.obj-code no-undo .
define input parameter p-host-code like ub.c-dc-hist.host-code no-undo .
define input parameter p-subject like ub.c-dc-hist.subject no-undo .
define input parameter p-action   like ub.c-dc-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cdchisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cdchisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории ДК".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i }
{ ref/discprop.i }
{ gbl/dct-algo.i }
{ ref/disdcrul.i }


define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-dc-hist for ub.c-dc-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-dc-hist no-lock where
          buf_c-dc-hist.d-card = p-d-card
      AND buf_c-dc-hist.chip-num = p-chip-num
      AND buf_c-dc-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-dc-hist.subject  = p-subject no-error .
if not available buf_c-dc-hist then do:
  return error .
end.

CASE p-subject:
  when {&table_dis-card} then do:
    run dis-card-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-obj} then do:
    run dis-obj-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-host} then do:
    run dis-host-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_dis-card-property} then do:
    run dis-card-property-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_dis-dc-rule} then do:
    run dis-dc-rule-proc in this-procedure(output p-description) no-error .
  end.

END CASE.
if error-status:error then do:
  return error .
end.

procedure dis-card-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-card for ub.c-dis-card.

  do
  on error undo, return error return-value
  :
    find first current_c-dis-card no-lock where
               current_c-dis-card.d-card = p-d-card
           AND current_c-dis-card.chip-num = p-chip-num
           AND current_c-dis-card.corr-user-db-num = p-corr-user-db-num no-error .
    if not avail current_c-dis-card then do:
       v-mess = "Неверная ссылка на c-dis-card в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .

&scop fieldS-name-LIST  "card-num,cash-d-pcnt,category,cli-code,cli-message,cli-type,credit-card,d-card,d-pcnt,d-pcnt-method,~
debet-card,emitent-host-code,issue-code,issue-date,lim-kr,saldo-base,saldo-rubl,sourced-card,staff-card,status_,~
type,valid-date,first-card,first-main-card,main-card,is-subsid,overissue-num,service-db-num"



v-label-param =
  "card-num" + {&delim-par} + "Вн № карты" + {&delim-par} + "" + {&delim-flf}
 + "cash-d-pcnt" + {&delim-par} + "% скидки на итог" + {&delim-par} + "" + {&delim-flf}
 + "category" + {&delim-par} + "Категория" + {&delim-par} + "" + {&delim-flf}
 + "cli-code" + {&delim-par} + "Код клиента" + {&delim-par} + "" + {&delim-flf}
 + "cli-message" + {&delim-par} + "Сообщ. для клиента" + {&delim-par} + "" + {&delim-flf}
 + "cli-type" + {&delim-par} + "Тип клиента" + {&delim-par} + "" + {&delim-flf}
 + "credit-card" + {&delim-par} + "Кредитная карта" + {&delim-par} + "" + {&delim-flf}
 + "d-card" + {&delim-par} + "№ карты" + {&delim-par} + "" + {&delim-flf}
 + "d-pcnt" + {&delim-par} + "Процент скидки" + {&delim-par} + "" + {&delim-flf}
 + "d-pcnt-method" + {&delim-par} + "Тип скидки" + {&delim-par} + "" + {&delim-flf}
 + "debet-card" + {&delim-par} + "Дебетовая карта" + {&delim-par} + "" + {&delim-flf}
 + "emitent-host-code" + {&delim-par} + "Код эмитента" + {&delim-par} + "" + {&delim-flf}
 + "issue-code" + {&delim-par} + "Выдал магазин" + {&delim-par} + "" + {&delim-flf}
 + "issue-date" + {&delim-par} + "Выдано (дата)" + {&delim-par} + "" + {&delim-flf}
 + "lim-kr" + {&delim-par} + "Лимит кредита" + {&delim-par} + "" + {&delim-flf}
 + "saldo-base" + {&delim-par} + "Баланс баз вал" + {&delim-par} + "" + {&delim-flf}
 + "saldo-rubl" + {&delim-par} + "Баланс нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "sourced-card" + {&delim-par} + "Выдано к карте" + {&delim-par} + "" + {&delim-flf}
 + "staff-card" + {&delim-par} + "Карта персонала" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "valid-from" + {&delim-par} + "Начало действия" + {&delim-par} + "" + {&delim-flf}
 + "valid-date" + {&delim-par} + "Оконч действия" + {&delim-par} + "" + {&delim-flf}
 + "first-card" + {&delim-par} + "Первичная" + {&delim-par} + "" + {&delim-flf}
 + "first-main-card" + {&delim-par} + "Первичная основная" + {&delim-par} + "" + {&delim-flf}
 + "main-card" + {&delim-par} + "Основная" + {&delim-par} + "" + {&delim-flf}
 + "is-subsid" + {&delim-par} + "Дополн?" + {&delim-par} + "" + {&delim-flf}
 + "overissue-num" + {&delim-par} + "Пор-к в цепочке перевыпуска" + {&delim-par} + "" + {&delim-flf}
 + "service-db-num" + {&delim-par} + "Обслуживающая БД" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-dc-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-card:handle
                                            ,input  {&table_dis-card}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.
end procedure. /* dis-card-proc */


procedure dis-card-property-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-mess as character no-undo .
define buffer current_c-dis-card-property for ub.c-dis-card-property  .

do
on error undo, return error return-value
:
    find first current_c-dis-card-property no-lock where
               current_c-dis-card-property.d-card = p-d-card
           AND current_c-dis-card-property.chip-num = p-chip-num
           AND current_c-dis-card-property.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-dis-card-property then do:
       v-mess = "Неверная ссылка на c-dis-card-property в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
    end.
    run discprop-node-name in this-procedure ( input substitute("&1&2&3"
                                                                ,current_c-dis-card-property.dtm-code
                                                                , {&delim-par}
                                                                ,current_c-dis-card-property.node-code)
                                          ,output v-tooltip
                                          ,output v-label
                                          ) no-error .
    assign
    p-description = "Свойство" + {&space-char} + v-label
    .
&scop fields-name-list "d-card,dt-code,sum-id,host-code,obj-type,obj-code,property-value-character,property-value-date,~
property-value-decimal,property-value-integer,property-value-logical,dtm-code"
define variable v-label-param as character no-undo .

v-label-param =
  "d-card" + {&delim-par} + "№ карты" + {&delim-par} + "" + {&delim-flf}
 + "dt-code" + {&delim-par} + "Код среза" + {&delim-par} + "" + {&delim-flf}
 + "sum-id" + {&delim-par} + "ID среза" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "property-value-character" + {&delim-par} + "Значение(строковое)" + {&delim-par} + "" + {&delim-flf}
 + "property-value-date" + {&delim-par} + "Значение(дата)" + {&delim-par} + "" + {&delim-flf}
 + "property-value-decimal" + {&delim-par} + "Значение(десятичное)" + {&delim-par} + "" + {&delim-flf}
 + "property-value-integer" + {&delim-par} + "Значение(целое)" + {&delim-par} + "" + {&delim-flf}
 + "property-value-logical" + {&delim-par} + "Значение(логическое)" + {&delim-par} + "" + {&delim-flf}
 + "dtm-code" + {&delim-par} + "Код объекта-операнда" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-dc-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-card-property:handle
                                            ,input  {&table_dis-card-property}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* dis-card-property-proc */



procedure dis-obj-proc :
define output parameter p-description as character no-undo .
define buffer current_c-dis-obj for ub.c-dis-obj  .
  do
  on error undo, return error return-value
  :

    find first current_c-dis-obj no-lock where
              current_c-dis-obj.d-card  = p-d-card
          and current_c-dis-obj.corr-user-db-num = p-corr-user-db-num
          and current_c-dis-obj.chip-num = p-chip-num no-error.
    if not available current_c-dis-obj then do:
      v-mess = "Неверная ссылка на c-dis-obj в таблице c-dc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.

    if current_C-DIS-OBJ.dt-code > 0  THEN
    assign
    p-description = substitute("Частные итоги: &1", dct-algo-get-description-sum-id(current_c-dis-obj.dt-code))
    .
define variable v-label-param as character no-undo .

&scop fieldS-name-LIST "card-num,gds-dis-base,gds-dis-rubl,gds-tot-b0,gds-tot-base,gds-tot-r0,gds-tot-rubl,sum-dis-base,~
sum-dis-rubl,sum-tot-base,sum-tot-rubl,num-chk,pay-tot-base,pay-tot-rubl,dt-code"


v-label-param =
  "card-num" + {&delim-par} + "Вн № карты" + {&delim-par} + "" + {&delim-flf}
 + "gds-dis-base" + {&delim-par} + "Скидка тов. - баз вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-dis-rubl" + {&delim-par} + "Скидка тов. - нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-tot-b0" + {&delim-par} + "Сум. тов. в учет. ценах баз вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-tot-base" + {&delim-par} + "Сум. тов. в ценах продажи баз вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-tot-r0" + {&delim-par} + "Сум. тов. в учет. ценах нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-tot-rubl" + {&delim-par} + "Сум. тов. в ценах продажи нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-dis-base" + {&delim-par} + "Скидка итоговая в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-dis-rubl" + {&delim-par} + "Скидка итоговая в нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-tot-base" + {&delim-par} + "Суммовые строки" + {&delim-par} + "" + {&delim-flf}
 + "sum-tot-rubl" + {&delim-par} + "Суммовые строки" + {&delim-par} + "" + {&delim-flf}
 + "num-chk" + {&delim-par} + "Число чеков" + {&delim-par} + "" + {&delim-flf}
 + "pay-tot-base" + {&delim-par} + "Сум. плат. баз вал." + {&delim-par} + "" + {&delim-flf}
 + "pay-tot-rubl" + {&delim-par} + "Сум. плат. нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "dt-code" + {&delim-par} + "№ частного итога" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-dc-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-obj:handle
                                            ,input  {&table_dis-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* dis-obj-proc */


procedure dis-host-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-dis-host for ub.c-dis-host  .


  do
  on error undo, return error return-value
  :

    find first current_c-dis-host no-lock where
              current_c-dis-host.d-card  = p-d-card
          and current_c-dis-host.corr-user-db-num = p-corr-user-db-num
          and current_c-dis-host.chip-num = p-chip-num no-error.

    if not available current_c-dis-host then do:
      v-mess = "Неверная ссылка на c-dis-host в таблице c-dc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.

    if current_C-DIS-host.dt-code > 0  THEN
    assign
    p-description = substitute("Частные итоги: &1", dct-algo-get-description-sum-id(current_c-dis-host.dt-code))
    .

define variable v-label-param as character no-undo .
&scop fieldS-name-LIST "card-num,gds-dis-base,gds-dis-rubl,gds-tot-base,gds-tot-rubl,sum-dis-base,~
sum-dis-rubl,sum-tot-base,sum-tot-rubl,num-chk,pay-tot-base,pay-tot-rubl,dt-code"


v-label-param =
  "card-num" + {&delim-par} + "Вн № карты" + {&delim-par} + "" + {&delim-flf}
 + "gds-dis-base" + {&delim-par} + "Скидка тов. - баз вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-dis-rubl" + {&delim-par} + "Скидка тов. - нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-tot-base" + {&delim-par} + "Сум. тов. в ценах продажи баз вал." + {&delim-par} + "" + {&delim-flf}
 + "gds-tot-rubl" + {&delim-par} + "Сум. тов. в ценах продажи нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-dis-base" + {&delim-par} + "Скидка итоговая в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-dis-rubl" + {&delim-par} + "Скидка итоговая в баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "sum-tot-base" + {&delim-par} + "Суммовые строки" + {&delim-par} + "" + {&delim-flf}
 + "sum-tot-rubl" + {&delim-par} + "Суммовые строки" + {&delim-par} + "" + {&delim-flf}
 + "num-chk" + {&delim-par} + "Число чеков" + {&delim-par} + "" + {&delim-flf}
 + "pay-tot-base" + {&delim-par} + "Сум. плат. баз.вал." + {&delim-par} + "" + {&delim-flf}
 + "pay-tot-rubl" + {&delim-par} + "Сум. плат. нац.вал." + {&delim-par} + "" + {&delim-flf}
 + "dt-code" + {&delim-par} + "№ частного итога" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-dc-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-host:handle
                                            ,input  {&table_dis-host}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

  end.

end procedure. /* dis-host-proc */


procedure dis-dc-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .

define buffer current_c-dis-dc-rule for ub.c-dis-dc-rule  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-dis-dc-rule no-lock where
               current_c-dis-dc-rule.d-card = p-d-card
           AND current_c-dis-dc-rule.chip-num = p-chip-num
           AND current_c-dis-dc-rule.corr-user-db-num = p-corr-user-db-num    no-error .
    if not avail current_c-dis-dc-rule then do:
       v-mess = "Неверная ссылка на c-dis-dc-rule в таблице c-dc-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    run disdcrul-name in this-procedure (
                input  current_c-dis-dc-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .

&scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role"

define variable v-label-param as character no-undo .

v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Место использ." + {&delim-par} + "" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Шаблон скидки" + {&delim-par} + "disdcrul-get-disc-label"  + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disdcrul-get-disc-role-label"  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-dc-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-dc-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-dc-rule:handle
                                            ,input  {&table_dis-dc-rule}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* dis-dc-rule-proc */



PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess = substitute("История контрагента  &1&2: щепка &3 БД:&4 фирма: &5  Предмет изменений &6&7&8"
                          ,p-obj-type
                          , p-obj-code
                          , p-chip-num
                          , p-corr-user-db-num
                          , p-host-code
                          , p-subject
                          ,{&new-line}
                          ,p-mess
                          ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.