block-level on error undo, throw.
/*

$Revision: 9263cff4388a, 1753, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:50:10 2019 +0300 $
$Workfile: cclihisv.p $
$Archive: ref/cclihisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/

define input parameter p-obj-type like ub.c-cli-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-cli-hist.obj-code no-undo .
define input parameter p-chip-num like ub.c-cli-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-cli-hist.corr-user-db-num no-undo .
define input parameter p-host-code like ub.c-cli-hist.host-code no-undo .
define input parameter p-subject like ub.c-cli-hist.subject no-undo .
define input parameter p-action   like ub.c-cli-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cclihisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cclihisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории клиента".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/clntattr.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */
{ gbl/key-rec.i }
{ gbl/thbjattr.i }
{ ref/extclass.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
{ ref/cthbjatv.i }


define buffer buf_c-cli-hist for ub.c-cli-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action"}

define temp-table temp-thbj-attr no-undo
like ub.thbj-attr.



function display-int-status returns character(input p-stts-char as character):
if p-stts-char = {&current-status-int} then return {&current-status-int-full}.
else return {&deleted-status-int-full}.
END FUNCTION.

function display-gender returns character(input p-gender as character):
case p-gender:
  when "no"
  or when "false"
  then do:
    return "м".
  end.
  when "yes"
  or when "true"
  then do:
    return "ж".
  end.
  when ?
  or when {&question-mark}
  then do:
    return {&question-mark}.
  end.
end case.
END FUNCTION.


/*if p-action = integer({&hn-delete}) then return.*/
find first buf_c-cli-hist no-lock where
          buf_c-cli-hist.obj-type = p-obj-type
      AND buf_c-cli-hist.obj-code = p-obj-code
      AND buf_c-cli-hist.chip-num = p-chip-num
      AND buf_c-cli-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-cli-hist.subject  = p-subject no-error .
if not available buf_c-cli-hist then do:
  return error .
end.

CASE p-subject:
  when {&table_clients} then do:
    run clients-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_clients-attr} then do:
    run clients-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_sysconf} then do:
    run sysconf-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_person} then do:
    run person-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_firm} then do:
    run firm-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_shop} then do:
    run shop-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_store} then do:
    run store-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_staff} then do:
    run staff-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_dis-thbj-rule} then do:
    run dis-thbj-rule-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_thbj-attr} then do:
    run thbj-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_ext-classif} then do:
    run ext-classif-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error .
end.

procedure clients-proc :
define output parameter p-description as character no-undo .
define buffer current_c-clients for ub.c-clients  .

do
on error undo, return error return-value
:
  find first current_c-clients no-lock where
              current_c-clients.obj-type = p-obj-type
          AND current_c-clients.obj-code = p-obj-code
          AND current_c-clients.chip-num = p-chip-num
          AND current_c-clients.corr-user-db-num = p-corr-user-db-num no-error .
  if not avail current_c-clients then do:
      v-mess = "Неверная ссылка на c-clients в таблице c-cli-hist".
      run err-mess ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
  end.

&scop fields-name-list "PS,buy-cons,buy-gds,buy-serv,Покупатель услуг,db-num,host-code,grp-code,grp-name,is-prod,~
lim-kr,num_podr,obj-name,sup-cons,sup-gds,sup-serv,stts,reg-code"

define variable v-label-param as character no-undo .
  v-label-param =
    "PS" + {&delim-par} + "Примечания" + {&delim-par} + "" + {&delim-flf}
 + "buy-cons" + {&delim-par} + "Покупатель конс.товаров" + {&delim-par} + "" + {&delim-flf}
 + "buy-gds" + {&delim-par} + "Покупатель товаров" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "№ БД" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код своей фирмы" + {&delim-par} + "" + {&delim-flf}
 + "buy-serv" + {&delim-par} + "Покупатель услуг" + {&delim-par} + "" + {&delim-flf}
 + "grp-code" + {&delim-par} + "Вн.Код группы" + {&delim-par} + "" + {&delim-flf}
 + "grp-name" + {&delim-par} + "Название группы" + {&delim-par} + "" + {&delim-flf}
 + "is-prod" + {&delim-par} + "Производитель" + {&delim-par} + "" + {&delim-flf}
 + "lim-kr" + {&delim-par} + "Лимит кредита" + {&delim-par} + "" + {&delim-flf}
 + "num_podr" + {&delim-par} + "№ подразделения" + {&delim-par} + "" + {&delim-flf}
 + "obj-name" + {&delim-par} + "Название" + {&delim-par} + "" + {&delim-flf}
 + "sup-cons" + {&delim-par} + "Поставщик конс.товара" + {&delim-par} + "" + {&delim-flf}
 + "sup-gds" + {&delim-par} + "Поставщик товаров" + {&delim-par} + "" + {&delim-flf}
 + "sup-serv" + {&delim-par} + "Поставщик услуг" + {&delim-par} + "" + {&delim-flf}
 + "stts" + {&delim-par} + "Статус" + {&delim-par} + "display-int-status" + {&delim-flf}
 + "reg-code" + {&delim-par} + "Регион" + {&delim-par} + "" .

  run proc-full-temp-changes in this-procedure (
                                               input buf_c-cli-hist.action = integer({&hn-create})
                                              ,input buf_c-cli-hist.action = integer({&hn-delete})
                                              ,input  buffer current_c-clients:handle
                                              ,input  {&table_clients}
                                              ,input  {&fields-name-list}
                                              ,input  v-label-param).

end. /*doe*/
end procedure. /* clients-proc */


procedure clients-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-clients-attr for ub.c-clients-attr  .


do
on error undo, return error return-value
:
  find first current_c-clients-attr no-lock where
              current_c-clients-attr.obj-type = p-obj-type
          AND current_c-clients-attr.obj-code = p-obj-code
          AND current_c-clients-attr.chip-num = p-chip-num
          AND current_c-clients-attr.corr-user-db-num = p-corr-user-db-num
          AND current_c-clients-attr.attr-code = buf_c-cli-hist.attr-code
          no-error .
  if not avail current_c-clients-attr then do:
      v-mess = "Неверная ссылка на c-clients-attr в таблице c-cli-hist".
      run err-mess ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
  end.
  &scop fields-name-list "attr-value"

  run clntattr-tooltip in this-procedure (
                input current_c-clients-attr.attr-code
              ,output v-tooltip
              ,output v-label
              ) no-error .
  assign
  p-description = "Атрибут" + {&space-char} + v-label
  .

  define variable v-label-param as character no-undo .

v-label-param =
 "attr-value" + {&delim-par} + "Значение" + {&delim-par} + "" .
 run proc-full-temp-changes in this-procedure (
                                               input buf_c-cli-hist.action = integer({&hn-create})
                                              ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-clients-attr:handle
                                            ,input  {&table_clients-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* clients-attr-proc */

procedure sysconf-proc :
define output parameter p-description as character no-undo .
define buffer current_c-sysconf for ub.c-sysconf  .


  do
  on error undo, return error return-value
  :
    find first current_c-sysconf no-lock where
               current_c-sysconf.host-code = p-obj-code
           AND current_c-sysconf.chip-num = p-chip-num
           AND current_c-sysconf.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-sysconf then do:
       v-mess = "Неверная ссылка на c-sysconf в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

define variable v-label-param as character no-undo .

&scop fields-name-list "accnt-type,all-prt,an-uchet-code-in,artic-disable,avrg-price,auto-pay,base-code,bclose-date,branch,~
cash-pay,cashier,cd-bc-alt,cd-bc-base,cd-loc-alt,cd-loc-base,cd-parts-all,cd-parts-not-blank,cd-parts-ser,cd-pb-alt,cd-pb-base,~
cd-sc-base,cel-nazn-code-in,chk-pay,cons-vat-pc,contract-city,contract-type,cor-acc-in,cor-acc1-in,cost-calc,credit-pay,down-pay,~
fbr-pay,fin-SLT-pc,fin-VAT-pc,firm-db-num,head-position,holidays,in-ov,in-pay,in-perm,inout-price,inv-pay,is-an-uchet,is-cassa-acc,~
is-code-cel-nazn,is-corr-acc,fin-calc,KOPF,load-time,negative-rest,no-eq,ord-prt,osn-base,out-line-discnt,out-pay,out-rate,~
pay-code-schet-base,pay-code-schet-rubl,pay-sign,pay-sign-post,price-calc,property,purch-code,ret-credit-pay,ret-pay,ret-sup-pay,~
rsrv-time,sale-code,sale-type,snr-accnt,SOEI,srok-opl,unit-cli-perm,usl-opl,VAT-sp,xd-an-code,xd-grp-code,xdn-an-code,xdn-grp-code"

v-label-param =
  "accnt-type" + {&delim-par} + "Учетная политика" + {&delim-par} + "" + {&delim-flf}
 + "all-prt" + {&delim-par} + "Перес. на кассу все признаков товара" + {&delim-par} + "" + {&delim-flf}
 + "an-uchet-code-in" + {&delim-par} + "Код аналит. учет по умолч" + {&delim-par} + "" + {&delim-flf}
 + "artic-disable" + {&delim-par} + "Автомат. артикул" + {&delim-par} + "" + {&delim-flf}
 + "avrg-price" + {&delim-par} + "Средние учетные цены" + {&delim-par} + "" + {&delim-flf}
 + "auto-pay" + {&delim-par} + "Авто создание ф.о. и плат." + {&delim-par} + "" + {&delim-flf}
 + "base-code" + {&delim-par} + "Код базовой валюты" + {&delim-par} + "" + {&delim-flf}
 + "bclose-date" + {&delim-par} + "Дата последнего закрытия баланса" + {&delim-par} + "" + {&delim-flf}
 + "branch" + {&delim-par} + "Отрасль (вид деятельности)" + {&delim-par} + "" + {&delim-flf}
 + "cash-pay" + {&delim-par} + "Оплата наличными" + {&delim-par} + "" + {&delim-flf}
 + "cashier" + {&delim-par} + "Кассир" + {&delim-par} + "" + {&delim-flf}
 + "cd-bc-alt" + {&delim-par} + "На кассу бар-код доп. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-bc-base" + {&delim-par} + "На кассу бар-код осн. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-loc-alt" + {&delim-par} + "На кассу лок. код доп. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-loc-base" + {&delim-par} + "На кассу лок. код осн. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-parts-all" + {&delim-par} + "На кассу код партии для всех товаров" + {&delim-par} + "" + {&delim-flf}
 + "cd-parts-not-blank" + {&delim-par} + "На кассу коды партий с непустыми номерами" + {&delim-par} + "" + {&delim-flf}
 + "cd-parts-ser" + {&delim-par} + "На кассу партии для сер.тов." + {&delim-par} + "" + {&delim-flf}
 + "cd-pb-alt" + {&delim-par} + "На кассу Доп. БК доп. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-pb-base" + {&delim-par} + "На кассу доп. БК осн. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-sc-base" + {&delim-par} + "На кассу вес. код" + {&delim-par} + "" + {&delim-flf}
 + "cel-nazn-code-in" + {&delim-par} + "Код целев. назн. по умолч" + {&delim-par} + "" + {&delim-flf}
 + "chk-pay" + {&delim-par} + "Код оплаты продажи" + {&delim-par} + "" + {&delim-flf}
 + "cons-vat-pc" + {&delim-par} + "Консигнационный НДС" + {&delim-par} + "" + {&delim-flf}
 + "contract-city" + {&delim-par} + "Город" + {&delim-par} + "" + {&delim-flf}
 + "contract-type" + {&delim-par} + "Тип контракта" + {&delim-par} + "" + {&delim-flf}
 + "cor-acc-in" + {&delim-par} + "Корр. счет по умолч" + {&delim-par} + "" + {&delim-flf}
 + "cor-acc1-in" + {&delim-par} + "Корр. счет1 по умолч" + {&delim-par} + "" + {&delim-flf}
 + "cost-calc" + {&delim-par} + "Расчет учетных цен" + {&delim-par} + "" + {&delim-flf}
 + "credit-pay" + {&delim-par} + "Платеж в кредит на кассе" + {&delim-par} + "" + {&delim-flf}
 + "down-pay" + {&delim-par} + "Оплата списания" + {&delim-par} + "" + {&delim-flf}
 + "fbr-pay" + {&delim-par} + "Код Оплаты пр-ва" + {&delim-par} + "" + {&delim-flf}
 + "fin-SLT-pc" + {&delim-par} + "Налог с продаж" + {&delim-par} + "" + {&delim-flf}
 + "fin-VAT-pc" + {&delim-par} + "НДС" + {&delim-par} + "" + {&delim-flf}
 + "firm-db-num" + {&delim-par} + "Номер БД фирмы" + {&delim-par} + "" + {&delim-flf}
 + "head-position" + {&delim-par} + "Должность рук-ля" + {&delim-par} + "" + {&delim-flf}
 + "holidays" + {&delim-par} + "Выходные" + {&delim-par} + "" + {&delim-flf}
 + "in-ov" + {&delim-par} + "Переоценка после ПН" + {&delim-par} + "" + {&delim-flf}
 + "in-pay" + {&delim-par} + "Оплата прихода" + {&delim-par} + "" + {&delim-flf}
 + "in-perm" + {&delim-par} + "Добавление ПН на пассивном складе" + {&delim-par} + "" + {&delim-flf}
 + "inout-price" + {&delim-par} + "Изменение налогов поставщика в ПН" + {&delim-par} + "" + {&delim-flf}
 + "inv-pay" + {&delim-par} + "Оплата инвентар." + {&delim-par} + "" + {&delim-flf}
 + "is-an-uchet" + {&delim-par} + "Обязателен код анал. учета в платежах" + {&delim-par} + "" + {&delim-flf}
 + "is-cassa-acc" + {&delim-par} + "Обязателен касс. счет в наличн. платежах" + {&delim-par} + "" + {&delim-flf}
 + "is-code-cel-nazn" + {&delim-par} + "Обязателен код цел.назн. в платежах" + {&delim-par} + "" + {&delim-flf}
 + "is-corr-acc" + {&delim-par} + "Обязателен корр.счет в платежах" + {&delim-par} + "" + {&delim-flf}
 + "fin-calc" + {&delim-par} + "Способ учета фин.документов" + {&delim-par} + "" + {&delim-flf}
 + "KOPF" + {&delim-par} + "КОПФ" + {&delim-par} + "" + {&delim-flf}
 + "load-time" + {&delim-par} + "Срок отгрузки (дней)" + {&delim-par} + "" + {&delim-flf}
 + "negative-rest" + {&delim-par} + "Отрицательные остатки" + {&delim-par} + "" + {&delim-flf}
 + "no-eq" + {&delim-par} + "Акт несоотв. в ед. изм. поставщика" + {&delim-par} + "" + {&delim-flf}
 + "ord-prt" + {&delim-par} + "Детальный заказ (по признакам)" + {&delim-par} + "" + {&delim-flf}
 + "osn-base" + {&delim-par} + "Учет ОС в баз. вал." + {&delim-par} + "" + {&delim-flf}
 + "out-line-discnt" + {&delim-par} + "Скидка по строке РН" + {&delim-par} + "" + {&delim-flf}
 + "out-pay" + {&delim-par} + "Оплата расхода" + {&delim-par} + "" + {&delim-flf}
 + "out-rate" + {&delim-par} + "Изменение курса РН" + {&delim-par} + "" + {&delim-flf}
 + "pay-code-schet-base" + {&delim-par} + "Вн№ счета в нац.вал.по умолч" + {&delim-par} + "" + {&delim-flf}
 + "pay-code-schet-rubl" + {&delim-par} + "Вн№ счета в баз по умолч" + {&delim-par} + "" + {&delim-flf}
 + "pay-sign" + {&delim-par} + "Подпись по умолч." + {&delim-par} + "" + {&delim-flf}
 + "pay-sign-post" + {&delim-par} + "Должность по умолч." + {&delim-par} + "" + {&delim-flf}
 + "price-calc" + {&delim-par} + "Запрещен приход при неравенстве цен" + {&delim-par} + "" + {&delim-flf}
 + "property" + {&delim-par} + "Организационно-правовая форма" + {&delim-par} + "" + {&delim-flf}
 + "purch-code" + {&delim-par} + "Тип приобретения" + {&delim-par} + "" + {&delim-flf}
 + "ret-credit-pay" + {&delim-par} + "Оплата задолженности по кредиту" + {&delim-par} + "" + {&delim-flf}
 + "ret-pay" + {&delim-par} + "Оплата возврата" + {&delim-par} + "" + {&delim-flf}
 + "ret-sup-pay" + {&delim-par} + "Оплата возврата пост." + {&delim-par} + "" + {&delim-flf}
 + "rsrv-time" + {&delim-par} + "Период резервирования (дней)" + {&delim-par} + "" + {&delim-flf}
 + "sale-code" + {&delim-par} + "Тип контрагента-РЕАЛИЗАЦИЯ В МАГ" + {&delim-par} + "" + {&delim-flf}
 + "sale-type" + {&delim-par} + "Код контрагента-РЕАЛИЗАЦИЯ В МАГ" + {&delim-par} + "" + {&delim-flf}
 + "snr-accnt" + {&delim-par} + "Главный бухгалтер" + {&delim-par} + "" + {&delim-flf}
 + "SOEI" + {&delim-par} + "СОЕИ" + {&delim-par} + "" + {&delim-flf}.

v-label-param = v-label-param
 + "srok-opl" + {&delim-par} + "СРок оплаты" + {&delim-par} + "" + {&delim-flf}
 + "unit-cli-perm" + {&delim-par} + "Изменение ед. изм. поставщика" + {&delim-par} + "" + {&delim-flf}
 + "usl-opl" + {&delim-par} + "Условия оплаты" + {&delim-par} + "" + {&delim-flf}
 + "VAT-sp" + {&delim-par} + "Спецналог" + {&delim-par} + "" + {&delim-flf}
 + "xd-an-code" + {&delim-par} + "Код статьи для курсовых разниц" + {&delim-par} + "" + {&delim-flf}
 + "xd-grp-code" + {&delim-par} + "Код группы для генерации проводок по К.Р." + {&delim-par} + "" + {&delim-flf}
 + "xdn-an-code" + {&delim-par} + "Код статьи для отрицательных курсовых разниц" + {&delim-par} + "" + {&delim-flf}
 /* 28/VIII-2018 Возьмем старое неиспользующеся поле для того, чтобы хранить в нем код БД,
                 с которой система будет копировать права и расписания при создании новой БД */
 + "xdn-grp-code" + {&delim-par} + "Номер БД для копирования прав и расписания при импорте из 1С" + {&delim-par} + ""  .
 
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer({&hn-create})
                                            ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-sysconf:handle
                                            ,input  {&table_sysconf}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* sysconf-proc */


procedure firm-proc :
define output parameter p-description as character no-undo .
define buffer current_c-firm for ub.c-firm  .

do
on error undo, return error return-value
:
    find first current_c-firm no-lock where
               current_c-firm.firm-code = p-obj-code
           AND current_c-firm.chip-num = p-chip-num
           AND current_c-firm.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-firm then do:
       v-mess = "Неверная ссылка на c-firm в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list  "addres1,addres2,city,contact-psn,director,e-mail,engl-name,fax,firm-code,gen-acct,ind,inn,kpp,main-obj-code,main-obj-type,~
okonh,okpo,phone,phone1-note,post-addr1,post-addr2,telex,tobj-code,is-pboul"


define variable v-label-param as character no-undo .

v-label-param =
  "addres1" + {&delim-par} + "Адрес" + {&delim-par} + "" + {&delim-flf}
 + "addres2" + {&delim-par} + "Адрес1" + {&delim-par} + "" + {&delim-flf}
 + "city" + {&delim-par} + "Страна город" + {&delim-par} + "" + {&delim-flf}
 + "contact-psn" + {&delim-par} + "Контактное лицо" + {&delim-par} + "" + {&delim-flf}
 + "director" + {&delim-par} + "Руководитель" + {&delim-par} + "" + {&delim-flf}
 + "e-mail" + {&delim-par} + "e-mail" + {&delim-par} + "" + {&delim-flf}
 + "engl-name" + {&delim-par} + "Английское название" + {&delim-par} + "" + {&delim-flf}
 + "fax" + {&delim-par} + "Факс" + {&delim-par} + "" + {&delim-flf}
 + "firm-code" + {&delim-par} + "Код организации" + {&delim-par} + "" + {&delim-flf}
 + "gen-acct" + {&delim-par} + "Главный бухгалтер" + {&delim-par} + "" + {&delim-flf}
 + "ind" + {&delim-par} + "Индекс" + {&delim-par} + "" + {&delim-flf}
 + "inn" + {&delim-par} + "{&abbr_inn_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "kpp" + {&delim-par} + "{&abbr_kpp_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "main-obj-code" + {&delim-par} + "Код гл. объект межфирм пермещения" + {&delim-par} + "" + {&delim-flf}
 + "main-obj-type" + {&delim-par} + "Тип гл. объект межфирм пермещения" + {&delim-par} + "" + {&delim-flf}
 + "okonh" + {&delim-par} + "{&abbr_okonh_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "okpo" + {&delim-par} + "ОКПО" + {&delim-par} + "" + {&delim-flf}
 + "phone" + {&delim-par} + "Телефон" + {&delim-par} + "" + {&delim-flf}
 + "phone1-note" + {&delim-par} + "Прим." + {&delim-par} + "" + {&delim-flf}
 + "post-addr1" + {&delim-par} + "Почт.адрес" + {&delim-par} + "" + {&delim-flf}
 + "post-addr2" + {&delim-par} + "Почт.адрес2" + {&delim-par} + "" + {&delim-flf}
 + "post-city" + {&delim-par} + "Страна город (почт.адр.)" + {&delim-par} + "" + {&delim-flf}
 + "post-ind" + {&delim-par} + "Индекс (почт.адр.)" + {&delim-par} + "" + {&delim-flf}
 + "telex" + {&delim-par} + "Телекс" + {&delim-par} + "" + {&delim-flf}
 + "tobj-code" + {&delim-par} + "Код торгового представителя" + {&delim-par} + "" + {&delim-flf}
 + "is-pboul" + {&delim-par} + "ПБОЮЛ" + {&delim-par} + ""  .
  run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer({&hn-create})
                                            ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-firm:handle
                                            ,input  {&table_firm}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* firm-proc */


procedure person-proc :
define output parameter p-description as character no-undo .
define buffer current_c-person for ub.c-person  .

do
on error undo, return error return-value
:
    find first current_c-person no-lock where
               current_c-person.psn-code = p-obj-code
           AND current_c-person.chip-num = p-chip-num
           AND current_c-person.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-person then do:
       v-mess = "Неверная ссылка на c-person в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.
define variable v-label-param as character no-undo .
&scop fields-name-list  "address,city,e-mail,fax,firm-code,firm-name,given-by,ind,inn,kpp,name1,name2,okonh,okpo,passp-num,passp-ser,phone1,~
phone1-note,position,post-box,is-pboul,gender,date-birth"


v-label-param =
  "address" + {&delim-par} + "Адрес" + {&delim-par} + "" + {&delim-flf}
 + "city" + {&delim-par} + "Город" + {&delim-par} + "" + {&delim-flf}
 + "e-mail" + {&delim-par} + "e-mail" + {&delim-par} + "" + {&delim-flf}
 + "fax" + {&delim-par} + "Факс" + {&delim-par} + "" + {&delim-flf}
 + "firm-code" + {&delim-par} + "Код организации" + {&delim-par} + "" + {&delim-flf}
 + "firm-name" + {&delim-par} + "Организация" + {&delim-par} + "" + {&delim-flf}
 + "given-by" + {&delim-par} + "Паспорт выдан" + {&delim-par} + "" + {&delim-flf}
 + "ind" + {&delim-par} + "Индекс" + {&delim-par} + "" + {&delim-flf}
 + "inn" + {&delim-par} + "{&abbr_inn_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "kpp" + {&delim-par} + "{&abbr_kpp_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "name1" + {&delim-par} + "Имя" + {&delim-par} + "" + {&delim-flf}
 + "name2" + {&delim-par} + "Отчество" + {&delim-par} + "" + {&delim-flf}
 + "okonh" + {&delim-par} + "{&abbr_okonh_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "okpo" + {&delim-par} + "{&abbr_okpo_allshift}" + {&delim-par} + "" + {&delim-flf}
 + "passp-num" + {&delim-par} + "Паспорт: номер" + {&delim-par} + "" + {&delim-flf}
 + "passp-ser" + {&delim-par} + "Паспорт: серия" + {&delim-par} + "" + {&delim-flf}
 + "phone1" + {&delim-par} + "Телефон" + {&delim-par} + "" + {&delim-flf}
 + "phone1-note" + {&delim-par} + "Прим." + {&delim-par} + "" + {&delim-flf}
 + "position" + {&delim-par} + "Должность" + {&delim-par} + "" + {&delim-flf}
 + "post-box" + {&delim-par} + "а/я" + {&delim-par} + "" + {&delim-flf}
 + "address" + {&delim-par} + "Адрес почтовый" + {&delim-par} + "" + {&delim-flf}
 + "post-city" + {&delim-par} + "Город (почт.адр.)" + {&delim-par} + "" + {&delim-flf}
 + "post-ind" + {&delim-par} + "Индекс (почт.адр.)" + {&delim-par} + "" + {&delim-flf}
 + "is-pboul" + {&delim-par} + "ПБОЮЛ" + {&delim-par} + "" + {&delim-flf}  
 + "gender" + {&delim-par} + "пол" + {&delim-par} + "display-gender" + {&delim-flf}
 + "date-birth" + {&delim-par} + "ДР" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer({&hn-create})
                                            ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-person:handle
                                            ,input  {&table_person}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* person-proc */


procedure shop-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .

define buffer current_shop for ub.shop  .
define buffer current_c-shop for ub.c-shop  .
define buffer new_c-shop for ub.c-shop  .


  do
  on error undo, return error return-value
  :
    find first current_c-shop no-lock where
               current_c-shop.obj-code = p-obj-code
           AND current_c-shop.chip-num = p-chip-num
           AND current_c-shop.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-shop then do:
       v-mess = "Неверная ссылка на c-shop в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error (if p-silent then v-mess else '':U).
    end.

&scop fields-name-list  "acct,addres1,addres2,all-prt,buy-goods,kitchen-store-code,kitchen-store-type,cd-bc-alt,cd-bc-base,cd-loc-alt,cd-loc-base,~
cd-parts-all,cd-parts-not-blank,cd-parts-ser,cd-pb-alt,cd-pb-base,cd-sc-base,chk-pay,day-only,director,discaloc,doc-prt,down-pay,~
dst-price,fax,fbr-pay,goods-man,holidays,host-code,in-ov,in-pay,in-perm,inout-price,inv-pay,is-catering,is-kitchen,is-kitchen-store,~
load-time,no-eq,no-short-code,out-line-discnt,out-pay,out-rate,phone,pr-cash,price-calc,purch-code,ret-pay,rsrv-time,shift-on,~
store-boss,store-man,sub-store-code,sub-store-on,sub-store-type,unit-cli-perm,with-serv,work-hours"

define variable v-label-param as character no-undo .

v-label-param =
  "acct" + {&delim-par} + "Бухгалтер" + {&delim-par} + "" + {&delim-flf}
 + "addres1" + {&delim-par} + "Адрес" + {&delim-par} + "" + {&delim-flf}
 + "addres2" + {&delim-par} + "Адрес1" + {&delim-par} + "" + {&delim-flf}
 + "all-prt" + {&delim-par} + "На кассу все признаки тов" + {&delim-par} + "" + {&delim-flf}
 + "buy-goods" + {&delim-par} + "Выкуп" + {&delim-par} + "" + {&delim-flf}
 + "kitchen-store-code" + {&delim-par} + "Код Склада Кухни" + {&delim-par} + "" + {&delim-flf}
 + "kitchen-store-type" + {&delim-par} + "Тип Склада кухни" + {&delim-par} + "" + {&delim-flf}
 + "cd-bc-alt" + {&delim-par} + "На кассу бар-код доп. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-bc-base" + {&delim-par} + "На кассу бар-код осн. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-loc-alt" + {&delim-par} + "На кассу лок. код доп. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-loc-base" + {&delim-par} + "На кассу лок. код осн. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-parts-all" + {&delim-par} + "На кассу коды партии для всех тов" + {&delim-par} + "" + {&delim-flf}
 + "cd-parts-not-blank" + {&delim-par} + "На кассу партии с непустыми кодами" + {&delim-par} + "" + {&delim-flf}
 + "cd-parts-ser" + {&delim-par} + "На кассу партии для сер тов" + {&delim-par} + "" + {&delim-flf}
 + "cd-pb-alt" + {&delim-par} + "На кассу доп. БК доп. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-pb-base" + {&delim-par} + "На кассу доп. БК осн. ед. изм." + {&delim-par} + "" + {&delim-flf}
 + "cd-sc-base" + {&delim-par} + "На кассу вес. код" + {&delim-par} + "" + {&delim-flf}
 + "chk-pay" + {&delim-par} + "Оплата продажи" + {&delim-par} + "" + {&delim-flf}
 + "day-only" + {&delim-par} + "В продажи чеки одного дня" + {&delim-par} + "" + {&delim-flf}
 + "director" + {&delim-par} + "Директор" + {&delim-par} + "" + {&delim-flf}
 + "discaloc" + {&delim-par} + "Размазывать скидку на итог" + {&delim-par} + "" + {&delim-flf}
 + "doc-prt" + {&delim-par} + "Учет по шкалам" + {&delim-par} + "" + {&delim-flf}
 + "down-pay" + {&delim-par} + "Оплата списания" + {&delim-par} + "" + {&delim-flf}
 + "dst-price" + {&delim-par} + "Перемещение по ценам объекта" + {&delim-par} + "" + {&delim-flf}
 + "fax" + {&delim-par} + "Факс" + {&delim-par} + "" + {&delim-flf}
 + "fbr-pay" + {&delim-par} + "Код Оплаты пр-ва" + {&delim-par} + "" + {&delim-flf}
 + "goods-man" + {&delim-par} + "Товаровед" + {&delim-par} + "" + {&delim-flf}
 + "holidays" + {&delim-par} + "Выходные" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "in-ov" + {&delim-par} + "Переоценка после ПН" + {&delim-par} + "" + {&delim-flf}
 + "in-pay" + {&delim-par} + "Оплата прихода" + {&delim-par} + "" + {&delim-flf}
 + "in-perm" + {&delim-par} + "Перемещение по цене магазина" + {&delim-par} + "" + {&delim-flf}
 + "inout-price" + {&delim-par} + "Изменение налогов поставщика в ПН" + {&delim-par} + "" + {&delim-flf}
 + "inv-pay" + {&delim-par} + "Оплата инвентар." + {&delim-par} + "" + {&delim-flf}
 + "is-catering" + {&delim-par} + "Объект-РЕСТОРАН" + {&delim-par} + "" + {&delim-flf}
 + "is-kitchen" + {&delim-par} + "Объект-КУХНЯ" + {&delim-par} + "" + {&delim-flf}
 + "is-kitchen-store" + {&delim-par} + "Объект-склад КУХНИ" + {&delim-par} + "" + {&delim-flf}
 + "load-time" + {&delim-par} + "Срок отгрузки (дней)" + {&delim-par} + "" + {&delim-flf}
 + "no-eq" + {&delim-par} + "Запрещен приход при отсутствии цен" + {&delim-par} + "" + {&delim-flf}
 + "no-short-code" + {&delim-par} + "?" + {&delim-par} + "" + {&delim-flf}
 + "out-line-discnt" + {&delim-par} + "Скидка по строке РН" + {&delim-par} + "" + {&delim-flf}
 + "out-pay" + {&delim-par} + "Оплата расхода" + {&delim-par} + "" + {&delim-flf}
 + "out-rate" + {&delim-par} + "Изменение курса РН" + {&delim-par} + "" + {&delim-flf}
 + "phone" + {&delim-par} + "Телефон" + {&delim-par} + "" + {&delim-flf}
 + "pr-cash" + {&delim-par} + "Разрешить переоценку без блокировки касс" + {&delim-par} + "" + {&delim-flf}
 + "price-calc" + {&delim-par} + "Запрещен приход при неравенстве цен" + {&delim-par} + "" + {&delim-flf}
 + "purch-code" + {&delim-par} + "Тип приобретения" + {&delim-par} + "" + {&delim-flf}
 + "ret-pay" + {&delim-par} + "Оплата возврата" + {&delim-par} + "" + {&delim-flf}
 + "ret-sup-pay" + {&delim-par} + "Оплата возврата пост." + {&delim-par} + "" + {&delim-flf}
 + "rsrv-time" + {&delim-par} + "Период резервирования (дней)" + {&delim-par} + "" + {&delim-flf}
 + "shift-on" + {&delim-par} + "Включены смены" + {&delim-par} + "" + {&delim-flf}
 + "store-boss" + {&delim-par} + "Зав. складом" + {&delim-par} + "" + {&delim-flf}
 + "store-man" + {&delim-par} + "Кладовщик" + {&delim-par} + "" + {&delim-flf}
 + "sub-store-code" + {&delim-par} + "Код объекта-подсобки" + {&delim-par} + "" + {&delim-flf}
 + "sub-store-on" + {&delim-par} + "Есть подсобка" + {&delim-par} + "" + {&delim-flf}
 + "sub-store-type" + {&delim-par} + "Тип объекта-подсобки" + {&delim-par} + "" + {&delim-flf}
 + "unit-cli-perm" + {&delim-par} + "Изменение ед. изм. поставщика" + {&delim-par} + "" + {&delim-flf}
 + "with-serv" + {&delim-par} + "Торгует услугами" + {&delim-par} + "" + {&delim-flf}
 + "work-hours" + {&delim-par} + "Часы работы" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer({&hn-create})
                                            ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-shop:handle
                                            ,input  {&table_shop}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* shop-proc */

procedure store-proc :
define output parameter p-description as character no-undo .
define buffer current_c-store for ub.c-store  .


do
on error undo, return error return-value
:
find first current_c-store no-lock where
            current_c-store.obj-code = p-obj-code
        AND current_c-store.chip-num = p-chip-num
        AND current_c-store.corr-user-db-num = p-corr-user-db-num
        no-error .
if not avail current_c-store then do:
    v-mess = "Неверная ссылка на c-store в таблице c-cli-hist".
    run err-mess ( input-output v-mess).
    return error (if p-silent then v-mess else '':U).
end.

&scop fields-name-list  "active,addres1,addres2,chk-pay,doc-prt,down-pay,dst-price,fax,fbr-pay,holidays,host-code,in-ov,in-pay,in-perm,inout-price,~
inv-pay,load-time,no-eq,out-line-discnt,out-pay,out-rate,phone,price-calc,purch-code,ret-pay,ret-sup-pay,rsrv-time,shift-on,~
store-boss,store-man,unit-cli-perm,work-hours"


define variable v-label-param as character no-undo .

v-label-param =
  "active" + {&delim-par} + "Активный склад" + {&delim-par} + "" + {&delim-flf}
 + "addres1" + {&delim-par} + "Адрес" + {&delim-par} + "" + {&delim-flf}
 + "addres2" + {&delim-par} + "Адрес1" + {&delim-par} + "" + {&delim-flf}
 + "chk-pay" + {&delim-par} + "Оплата продажи" + {&delim-par} + "" + {&delim-flf}
 + "doc-prt" + {&delim-par} + "Учет по шкалам" + {&delim-par} + "" + {&delim-flf}
 + "down-pay" + {&delim-par} + "Оплата списания" + {&delim-par} + "" + {&delim-flf}
 + "dst-price" + {&delim-par} + "Перемещение по ценам объекта" + {&delim-par} + "" + {&delim-flf}
 + "fax" + {&delim-par} + "Факс" + {&delim-par} + "" + {&delim-flf}
 + "fbr-pay" + {&delim-par} + "Код Оплаты пр-ва" + {&delim-par} + "" + {&delim-flf}
 + "holidays" + {&delim-par} + "Выходные" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "in-ov" + {&delim-par} + "Переоценка после ПН" + {&delim-par} + "" + {&delim-flf}
 + "in-pay" + {&delim-par} + "Оплата прихода" + {&delim-par} + "" + {&delim-flf}
 + "in-perm" + {&delim-par} + "Добавление ПН на пассивном складе" + {&delim-par} + "" + {&delim-flf}
 + "inout-price" + {&delim-par} + "Изменение налогов поставщика в ПН" + {&delim-par} + "" + {&delim-flf}
 + "inv-pay" + {&delim-par} + "Оплата инвентар." + {&delim-par} + "" + {&delim-flf}
 + "load-time" + {&delim-par} + "Срок отгрузки (дней)" + {&delim-par} + "" + {&delim-flf}
 + "no-eq" + {&delim-par} + "Запрещен приход при отсутствии цен" + {&delim-par} + "" + {&delim-flf}
 + "out-line-discnt" + {&delim-par} + "Скидка по строке РН" + {&delim-par} + "" + {&delim-flf}
 + "out-pay" + {&delim-par} + "Оплата расхода" + {&delim-par} + "" + {&delim-flf}
 + "out-rate" + {&delim-par} + "Изменение курса РН" + {&delim-par} + "" + {&delim-flf}
 + "phone" + {&delim-par} + "Телефон" + {&delim-par} + "" + {&delim-flf}
 + "price-calc" + {&delim-par} + "Запрещен приход при неравенстве цен" + {&delim-par} + "" + {&delim-flf}
 + "purch-code" + {&delim-par} + "Тип приобретения" + {&delim-par} + "" + {&delim-flf}
 + "ret-pay" + {&delim-par} + "Оплата возврата" + {&delim-par} + "" + {&delim-flf}
 + "ret-sup-pay" + {&delim-par} + "Оплата возврата пост." + {&delim-par} + "" + {&delim-flf}
 + "rsrv-time" + {&delim-par} + "Период резервирования (дней)" + {&delim-par} + "" + {&delim-flf}
 + "shift-on" + {&delim-par} + "Включены смены" + {&delim-par} + "" + {&delim-flf}
 + "store-boss" + {&delim-par} + "Зав. складом" + {&delim-par} + "" + {&delim-flf}
 + "store-man" + {&delim-par} + "Кладовщик" + {&delim-par} + "" + {&delim-flf}
 + "unit-cli-perm" + {&delim-par} + "Изменение ед. изм. поставщика" + {&delim-par} + "" + {&delim-flf}
 + "work-hours" + {&delim-par} + "Часы работы" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer({&hn-create})
                                            ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-store:handle
                                            ,input  {&table_store}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* store-proc */

procedure staff-proc :
define output parameter p-description as character no-undo .
define buffer current_c-staff for ub.c-staff  .

do
on error undo, return error return-value  :

find first current_c-staff no-lock where
            current_c-staff.psn-code = p-obj-code
        AND current_c-staff.chip-num = p-chip-num
        AND current_c-staff.corr-user-db-num = p-corr-user-db-num
        no-error .
if not avail current_c-staff then do:
    v-mess = "Неверная ссылка на c-staff в таблице c-cli-hist".
    run err-mess ( input-output v-mess).
    return error  (if p-silent then v-mess else '':U).
end.
&scop fields-name-list  "date-start,date-end,db-num,host-code,obj-type,obj-code"

define variable v-label-param as character no-undo .

v-label-param =
  "date-start" + {&delim-par} + "Начало работы" + {&delim-par} + "" + {&delim-flf}
 + "date-end" + {&delim-par} + "Окончание работы" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Фирма" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-cli-hist.action = integer({&hn-create})
                                            ,input buf_c-cli-hist.action = integer({&hn-delete})
                                            ,input  buffer current_c-staff:handle
                                            ,input  {&table_staff}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end. /*doe*/

end procedure. /* staff-proc */

FUNCTION get-dis-thbj-rule-name returns character ( input p-dis-thbj-rule-code as character):
define variable v-name as character no-undo .
&scop dis-thbj-rule-code p-dis-thbj-rule-code
v-name =  {&dis-thbj-rule-name}.
return v-name.
end FUNCTION.

procedure dis-thbj-rule-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-old-position as character no-undo .
define variable v-new-position as character no-undo .
define variable v-last as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .

define buffer current_dis-thbj-rule for ub.dis-thbj-rule  .
define buffer current_c-dis-thbj-rule for ub.c-dis-thbj-rule  .
define buffer new_c-dis-thbj-rule for ub.c-dis-thbj-rule  .
define buffer new_c-cli-hist for ub.c-cli-hist  .

  do
  on error undo, return error return-value
  :
    if p-obj-type = {&cmp} then do:
      find first current_c-dis-thbj-rule no-lock where
                current_c-dis-thbj-rule.obj-type = '':U
            and current_c-dis-thbj-rule.obj-code = 0
            AND current_c-dis-thbj-rule.chip-num = p-chip-num
            AND current_c-dis-thbj-rule.corr-user-db-num = p-corr-user-db-num
            no-error .
    end.
    else do:
      find first current_c-dis-thbj-rule no-lock where
                current_c-dis-thbj-rule.obj-type = p-obj-type
            AND current_c-dis-thbj-rule.obj-code = p-obj-code
            AND current_c-dis-thbj-rule.chip-num = p-chip-num
            AND current_c-dis-thbj-rule.corr-user-db-num = p-corr-user-db-num
            no-error .
    end.
    if not avail current_c-dis-thbj-rule then do:
       v-mess = "Неверная ссылка на c-dis-thbj-rule в таблице c-cli-hist".
       run err-mess ( input-output v-mess).
       return error  (if p-silent then v-mess else '':U).
    end.
    find first new_c-dis-thbj-rule no-lock where
              new_c-dis-thbj-rule.host-code = current_c-dis-thbj-rule.host-code
          and new_c-dis-thbj-rule.obj-type = current_c-dis-thbj-rule.obj-type
          and new_c-dis-thbj-rule.obj-code = current_c-dis-thbj-rule.obj-code
          and new_c-dis-thbj-rule.pos-type = current_c-dis-thbj-rule.pos-type
          and new_c-dis-thbj-rule.discnt-role = current_c-dis-thbj-rule.discnt-role
          and new_c-dis-thbj-rule.nonunique = current_c-dis-thbj-rule.nonunique
          AND new_c-dis-thbj-rule.chip-num > p-chip-num
          AND new_c-dis-thbj-rule.corr-user-db-num = p-corr-user-db-num no-error.
    if not available new_c-dis-thbj-rule then do:
    find first current_dis-thbj-rule no-lock where
              current_dis-thbj-rule.host-code = current_c-dis-thbj-rule.host-code
          and current_dis-thbj-rule.obj-type = current_c-dis-thbj-rule.obj-type
          and current_dis-thbj-rule.obj-code = current_c-dis-thbj-rule.obj-code
          and current_dis-thbj-rule.pos-type = current_c-dis-thbj-rule.pos-type
          and current_dis-thbj-rule.discnt-role = current_c-dis-thbj-rule.discnt-role
          and current_dis-thbj-rule.nonunique = current_c-dis-thbj-rule.nonunique no-error.
      if not available current_dis-thbj-rule then do:
        return error.
      end.
      buffer-compare current_dis-thbj-rule to current_c-dis-thbj-rule
      case-sensitive
      save result in v-chg-fields.
    end.
    else do:
      buffer-compare new_c-dis-thbj-rule except chip-num corr-date corr-time corr-user-name corr-user-db-num
      to current_c-dis-thbj-rule
      case-sensitive
      save result in v-chg-fields.
    end.

&scop fields-name-list  "pos-type,disnct-role,templ-rl-root,rule-num,key#_one,Key#_two,key#_three,CHarkey_one,Charkey_two,Charkey_three"
&scop fields-label-list  "Место использ.,Тип скидки,Тип шаблона,№ правила,Код 1,Код 2,Код 3,Скод 1,Скод 2,Скод 3"
&scop fields-function-list ",get-dis-thbj-rule-name,,,,,"
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
    temp-changes.v_old = string(buffer current_c-dis-thbj-rule:buffer-field(v-field-name):buffer-value)
    temp-changes.v_new =  (if available new_c-dis-thbj-rule
                                then string(buffer new_c-dis-thbj-rule:buffer-field(v-field-name):buffer-value)
                                else string(buffer current_dis-thbj-rule:buffer-field(v-field-name):buffer-value)
                           )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
   end. /*  do ii = 1 to num-entries(v-chg-fields):*/
 end. /*doe*/

end procedure. /* dis-thbj-rule-proc */

procedure thbj-attr-proc :
define output parameter p-description as character no-undo .

do
on error undo, return error return-value
:
  find first current_c-thbj-attr no-lock where
              current_c-thbj-attr.obj-type = p-obj-type
          AND current_c-thbj-attr.obj-code = p-obj-code
          AND current_c-thbj-attr.chip-num = p-chip-num
          AND current_c-thbj-attr.corr-user-db-num = p-corr-user-db-num
          no-error .
  if not avail current_c-thbj-attr then do:
      v-mess = "Неверная ссылка на c-thbj-attr в таблице c-cli-hist".
      run err-mess ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
  end.
  create temp-thbj-attr.
  assign
  temp-thbj-attr.upper-prop-code       = current_c-thbj-attr.upper-prop-code
  temp-thbj-attr.prop-code             = current_c-thbj-attr.prop-code
  temp-thbj-attr.obj-type              = current_c-thbj-attr.obj-type
  temp-thbj-attr.obj-code              = current_c-thbj-attr.obj-code
  .
  run gen-key-rec in this-procedure ( input {&table_thbj-attr}
                                    ,input (buffer temp-thbj-attr:handle)
                                    ,output v-thbj-attr-uniq-key-rec) .

  if current_c-thbj-attr.subject = ''
  or current_c-thbj-attr.subject = {&table_thbj-attr} then do:
    run thbj-attr-self-proc in this-procedure (input buf_c-cli-hist.action, output p-description) no-error.
  end.
  else do:
    case current_c-thbj-attr.subject:
      when {&table_rp-by-call} then do:
        run rp-by-call-proc in this-procedure(output p-description) no-error .
      end.
      when {&table_rule-by-call} then do:
        run rule-by-call-proc in this-procedure(output p-description) no-error .
      end.
      when {&table_rule-call-param} then do:
        run rule-call-param-proc in this-procedure(output p-description) no-error .
      end.
    end case.
  end.
end.

end procedure. /* thbj-attr-proc */

define temp-table temp-clients no-undo like ub.clients.
procedure ext-classif-proc :
define output parameter p-description as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-label-param as character no-undo .
define buffer curr_c-ext-classif for ub.c-ext-classif  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    create temp-clients.
    buffer-copy buf_c-cli-hist to temp-clients.
    run gen-key-rec in this-procedure ( input {&table_clients}
                                       ,input (buffer temp-clients:handle)
                                       ,output v-uniq-key-rec).
    delete temp-clients.
    find first curr_c-ext-classif no-lock where
               curr_c-ext-classif.classif-subject = {&table_clients}
           and curr_c-ext-classif.uniq-key-rec = v-uniq-key-rec
           AND curr_c-ext-classif.chip-num = p-chip-num
           AND curr_c-ext-classif.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-ext-classif then do:
       v-mess = "Неверная ссылка на c-ext-classif в таблице c-cli-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-cli-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-cli-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-ext-classif:handle
                                            ,input  {&table_ext-classif}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* gds-season-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История контрагента  &1&2: щепка &3 БД:&4 фирма: &5  Предмет изменений &6&7&8"
                 ,p-obj-type
                 , p-obj-code
                 , p-chip-num
                 , p-corr-user-db-num
                 , p-host-code
                 , p-subject
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