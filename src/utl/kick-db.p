block-level on error undo, throw.
/*

$Revision: f0ae80db3135, 3548, rls $
$Author: DRuban $
$Date: 2023/11/27 08:31:17 $
$Workfile: kick-db.p $
$Archive: utl/kick-db.p $

закачка в ГДБ р_у_блей и их курсов, основных единиц измерения, стран и т.п.

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

   !!! Должно распространяться по всем УБД через СПН !!!

*/
define input parameter p-sys-key  as character no-undo . /* системный ключ */

define variable vss-revision    as character no-undo init "$Revision: f0ae80db3135, 3548, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:17 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: kick-db.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/kick-db.p $":U .
define variable vss-description as character no-undo init "Закачка валют, едизм, стран, налогов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ cmp/library.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cmp/tblfname.i }
{ ref/cgrplbfn.i }
{ trg/new-bcod.i }
{ gbl/attr-lib.i }  /* для &run_proc_attr-lib */


/* kick-db.p вызывается из adm/init-db.p и из gbl/menuload.p;
   чтобы не менять параметры вызова из menuload.p - получаем входные параметры через указатель на вызывающую процедуру */
define /* input parameter */ variable p-extra-to as integer no-undo . /* раскрутка под: 0=ниподкого, 1="1С", 2= */ 
define variable v-call-proc as handle no-undo.
define variable v-func-list as character no-undo.
v-call-proc = this-procedure:instantiating-procedure.
if valid-handle(v-call-proc) then do:
  /* if r-index(v-call-proc:file-name, "init-db.p") > 0 then do: */
  v-func-list = v-call-proc:INTERNAL-ENTRIES.
  if can-do(v-func-list, "get-param") then do:
    run value("get-param") in v-call-proc (output p-extra-to).
  end.
end.  
   

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable glog as logical no-undo .
define variable v-cntxt-db-num         like ub.sys-ctrl.db-num   no-undo. /*текущая БД*/
define variable v-cntxt-userid         as   character            no-undo. /*текущий пользователь*/
define buffer buf_sys-ctrl for DICTDB.sys-ctrl.

define variable v-is-1c-erp  as logical no-undo. /* true: если в качестве ERP используется 1C */  
define variable country-path as char no-undo.
define variable menu-grp-path as character no-undo .

define temp-table for-country      no-undo like ub.country .
define temp-table temp_fbr-gds-grp no-undo like ub.fbr-gds-grp.

define buffer buf_currency          for DICTDB.currency .
define buffer buf_curr-accnt        for DICTDB.curr-accnt .
define buffer buf_curr-bank         for DICTDB.curr-bank .
define buffer buf_units             for DICTDB.units .
define buffer buf_cli-grp           for DICTDB.cli-grp .
define buffer buf_clients           for DICTDB.clients .
define buffer buf_clients-attr      for DICTDB.clients-attr .
define buffer buf_firm              for DICTDB.firm .
define buffer buf_cash-pay          for DICTDB.cash-pay .
define buffer buf_wealth            for DICTDB.wealth .
define buffer buf_pay-type          for DICTDB.pay-type .
define buffer buf_global-state      for DICTDB.global-state .
define buffer buf_trn-reason        for DICTDB.trn-reason .

disable triggers for load of DICTDB.country .
disable triggers for load of DICTDB.currency .
disable triggers for load of DICTDB.curr-accnt .
disable triggers for load of DICTDB.curr-bank .
disable triggers for load of DICTDB.units .
disable triggers for load of DICTDB.tax .
disable triggers for load of DICTDB.tax-rate .
disable triggers for load of DICTDB.tax-rate-attr .
disable triggers for load of DICTDB.tax-rate-value .
disable triggers for load of DICTDB.tax-units .
disable triggers for load of DICTDB.tax-rate-gds-grp .
disable triggers for load of DICTDB.fbr-gds-grp .
disable triggers for load of DICTDB.hist-nws-option .
disable triggers for load of DICTDB.cli-grp .
disable triggers for load of DICTDB.clients .
disable triggers for load of DICTDB.clients-attr .
disable triggers for load of DICTDB.firm .
disable triggers for load of DICTDB.cash-pay .
disable triggers for load of DICTDB.wealth .
disable triggers for load of DICTDB.pay-type .
disable triggers for load of DICTDB.criterion-analysis .
disable triggers for load of DICTDB.global-state .
disable triggers for load of DICTDB.trn-reason .
disable triggers for load of DICTDB.CashBook .

define stream errstream.
find first buf_sys-ctrl.
if buf_sys-ctrl.db-num <> 0 then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.
assign
v-cntxt-db-num = buf_sys-ctrl.db-num
v-cntxt-userid = userid("ub")
.
glog = no.
message
"Инициализация рублей в справочнике и курсов для них," skip
"единиц измерения, ставок налогов и др. информации ?   Вы уверены ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.

v-is-1c-erp = (p-extra-to = 1).

run waitfram-show in this-procedure ("Инициализация валют").

find buf_currency where buf_currency.curr-code = 0 no-error.
if not available buf_currency then do:
  create buf_currency.
  assign
    buf_currency.curr-code = 0
  .
end.
assign
  buf_currency.curr-name = "Рубль России"
  buf_currency.curr-abbr = "руб"
  buf_currency.part-name = "копейка"
  buf_currency.part-abbr = "коп"
  buf_currency.okv-code  = 643
  buf_currency.curr-name-one =  "рубль":U
  buf_currency.curr-name-three = "рубля":U
  buf_currency.curr-name-five = "рублей":U
  buf_currency.part-name-one  = "копейка":U
  buf_currency.part-name-three = "копейки":U
  buf_currency.part-name-five = "копеек":U
.

run waitfram-show in this-procedure ("Инициализация курсов валют").

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).

find buf_curr-accnt where buf_curr-accnt.curr-code = 0 no-error.
if not available buf_curr-accnt then do:
  create buf_curr-accnt.
  assign
    buf_curr-accnt.curr-code = 0
    buf_curr-accnt.exch-date = v-today
  .
end.
assign
  buf_curr-accnt.exch-rate = 1
  buf_curr-accnt.exch-scale = 1
.
find buf_curr-bank where buf_curr-bank.curr-code = 0 no-error.
if not available buf_curr-bank then do:
  create buf_curr-bank.
   assign
     buf_curr-bank.curr-code = 0
     buf_curr-bank.exch-date = v-today
   .
end.
assign
  buf_curr-bank.exch-rate = 1
  buf_curr-bank.exch-scale = 1
no-error. /* чтобы сбросить error-status после find first */


if not v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация справочника стран").
  country-path = search("cmp/countris.txt").
  if country-path = ? then do:
    message "Нет найден файл импорта для справочника стран countris.txt"
                    "Справочник стран не будет заполнен!"
                    view-as alert-box.
  end.
  else do:
    run import-countries in this-procedure (input country-path) .
  end.
end.

menu-grp-PATH = search("cmp/menu-grp.txt").
if menu-grp-path = ? then do:
    message
    "Отсутствует файл для импорта справочника глобальных групп меню menu-grp.txt" skip
    "Справочник глобальных групп меню не будет заполнен."
    view-as alert-box.
end.
else do:
  run waitfram-show in this-procedure ("Инициализация справочника глобальных групп меню").
  run import-menu-grps in this-procedure .
  /* оставляет после себя error-status */
end.

if not v-is-1c-erp then do:
  if p-sys-key <> "raimbek":U then do:

  run waitfram-show in this-procedure ("Инициализация единиц измерения").

  run cre-unit in this-procedure ("шт", "штука", {&pieces}).
  run cre-unit in this-procedure ("пар", "пара", {&pieces}).
  run cre-unit in this-procedure ("кг", "килограмм", {&weight}).
  run cre-unit in this-procedure ("м", "метр", {&divisional}).
  run cre-unit in this-procedure ("уп", "упаковка", {&pieces}).
  end.
end.


run waitfram-show in this-procedure ("Инициализация категорий налогов").

/* 01/XI-2018 для налога НДС проставлять флаг, что налог отправляется на кассы */
run cre-tax in this-procedure (1, "НДС", {&percentive}, yes, ({&pieces} + {&comma-char} + {&weight} + {&comma-char} + {&serial} + {&comma-char} + {&divisional} + {&comma-char} + {&petrolium}), no).
run cre-tax in this-procedure (2, "НП", {&percentive}, no, ({&pieces} + {&comma-char} + {&weight} + {&comma-char} + {&serial} + {&comma-char} + {&divisional} + {&comma-char} + {&petrolium}), no).
run cre-tax in this-procedure (3, "Доп.компонента", {&absolute}, no, {&bottle}, yes).
run cre-tax in this-procedure (4, "Акциз", {&absolute}, no, {&petrolium}, yes).

run waitfram-show in this-procedure ("Инициализация ставок налогов").

if p-sys-key <> "raimbek":U then do:
  run cre-tax-rate in this-procedure (1, 1, "НДС 1").
  run cre-tax-rate in this-procedure (1, 2, "НДС 2").
  run cre-tax-rate in this-procedure (1, 3, "НДС 3").
  run cre-tax-rate in this-procedure (1, 4, "НДС 4").

  run cre-tax-rate-value in this-procedure (1, 1, 20, v-today, v-time).
  run cre-tax-rate-value in this-procedure (1, 2, 10, v-today, v-time).
  run cre-tax-rate-value in this-procedure (1, 3, 0,  v-today, v-time).
  run cre-tax-rate-value in this-procedure (1, 4, 0,  v-today, v-time).
end.

run cre-tax-rate in this-procedure (2, 22, "НП 22").
run cre-tax-rate-value in this-procedure (2, 22, 0, v-today, v-time).

run cre-tax-rate-attr in this-procedure (1, 4).

run waitfram-show in this-procedure ("Заполнение налогов на группу товаров").
run add-tax-gds-grp in this-procedure  no-error .


if p-sys-key <> "raimbek":U then do:
  if not v-is-1c-erp then do:
    /* согласованные с техносерв группы клиентов добавляются в initftbl.p */
  run waitfram-show in this-procedure ("Инициализация групп клиентов" ) .
  run cre-cli-grp in this-procedure ( "Свои объекты, фирмы" ) .
  run cre-cli-grp in this-procedure ( "Производители и поставщики" ) .
  run cre-cli-grp in this-procedure ( "Покупатели" ) .
  run cre-cli-grp in this-procedure ( "Персонал" ) .
  end.

  run waitfram-show in this-procedure ("Инициализация клиентов").
  if v-is-1c-erp then do:
    /* контрагент создаётся после установки calc-range для gbl-fm-code */
    run cre-cli2 in this-procedure .
  end.
  else do:
    run cre-cli in this-procedure ( "Реализация в магазине", "Покупатели" ) .
  end.

end.
else do:
  if not v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация групп клиентов" ) .
  run cre-cli-grp in this-procedure ( "Группа по умолчанию" ) .
  end.
end.

  /* 23/X-2018 для 1с
При раскрутке БД создавать следующие виды оплаты:
1 - Наличные (они сейчас вроде создаются)
2 - Безналичные
3 - Возврат поставщику
4 - Оплата по консигнации  
  */
if v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Инициализация видов оплаты").
  run cre-pay-type in this-procedure ( 1, "Наличные" ) .
  run cre-pay-type in this-procedure ( 2, "Безналичные" ) .
  run cre-pay-type in this-procedure ( 3, "Возврат поставщику" ) .
  run cre-pay-type in this-procedure ( 4, "Оплата по консигнации" ) .
end .
else do :
  if p-sys-key <> "raimbek":U then do:
  /* для типов кассовых платежей должны быть созданы: валюта, вид оплаты, МЦ */
  run waitfram-show in this-procedure ("Инициализация видов оплаты").
  run cre-pay-type in this-procedure ( 1, "Наличные" ) .
  run cre-pay-type in this-procedure ( 2, "Безналичные" ) .
  run cre-pay-type in this-procedure ( 3, "Возврат поставщику" ) .
  run cre-pay-type in this-procedure ( 4, "Кредит" ) .

  run waitfram-show in this-procedure ("Инициализация МЦ").
  run cre-wth in this-procedure ( 1, 0, YES, "Наличные", {&wth-qnty-sum} ) .

  run waitfram-show in this-procedure ("Инициализация типов кассовых платежей").
  run cre-cash-pay in this-procedure (  1, 0, 1, 1, "Наличные",          TRUE, FALSE ) .
  run cre-cash-pay in this-procedure ( 20, 0, 1, 0, "Оплата по кредиту", FALSE, TRUE ).
  end.
  else do:
  run waitfram-show in this-procedure ("Инициализация видов оплаты").
  run cre-pay-type in this-procedure ( 4, "Наличные" ) .
  run cre-pay-type in this-procedure ( 5, "Безналичные" ) .
  end.
end .
  

  /* 23/X-2018 для 1с
Следующие причины создания документов:
19 - Истечение срока годности (кафе)
20 - Потеря товарного вида актуальности (товары)
22 - Зачистка резервуара (топлива)
23 - Возврат товара поставщику
24- Ввод первоначальных остатков
  */
if v-is-1c-erp then do:
  run waitfram-show in this-procedure ("Причины создания документов").
  run cre-trn-reason in this-procedure (19, "Истечение срока годности (кафе)") .  
  run cre-trn-reason in this-procedure (20, "Потеря товарного вида актуальности (товары)") .  
  run cre-trn-reason in this-procedure (22, "Зачистка резервуара (топлива)") .  
  run cre-trn-reason in this-procedure (23, "Возврат товара поставщику") .  
  run cre-trn-reason in this-procedure (24, "Ввод первоначальных остатков") .  
  dynamic-current-value( "s-trn-reason":U, LDBNAME("DICTDB":U) ) = 24 .
end .


run waitfram-show in this-procedure ("Инициализация критериев анализа ABC и XYZ").
  run utl/abc-utl.p  .

run waitfram-show in this-procedure ("Инициализация глобальных настроек ценообразования").
for each buf_global-state exclusive-lock :
    delete buf_global-state.
end.
    create buf_global-state.
    assign
      buf_global-state.db-num-chg = 1
    .

run waitfram-show in this-procedure ("Инициализация настроек опций истории и маршрутизации").
do:
define variable v-codes1 as character no-undo .
define variable v-labels1 as character no-undo .
define variable v-groups1 as character no-undo .
assign
v-codes1 = {&table_goods} + {&DELIM-PAR} + {&table_gds-obj-attr} + {&DELIM-PAR} +
          {&table_gds-host-attr} + {&DELIM-PAR} + {&table_goods-attr} + {&DELIM-PAR} +
          {&table_fbr-gds-obj} + {&DELIM-PAR} + {&table_s-coeff} + {&DELIM-PAR} +
          {&table_prod-bc} + {&DELIM-PAR} + {&table_bar-code} + {&DELIM-PAR} +
          {&table_varianty-delivery-gds-obj} + {&DELIM-PAR} + {&table_gds-season} + {&DELIM-PAR} +
          {&table_dis-gds-rule} + {&DELIM-PAR} + {&table_assortment-matrix-goods} + {&DELIM-PAR} +
          {&table_gds-obj-prop} + {&DELIM-PAR} + {&table_ext-artic}
v-labels1 = {&table_goods-full} + {&DELIM-PAR} + {&table_gds-obj-attr-full} + {&DELIM-PAR} +
        {&table_gds-host-attr-full} + {&DELIM-PAR} + {&table_goods-attr-full} + {&DELIM-PAR} +
        {&table_fbr-gds-obj-full} + {&DELIM-PAR} + {&table_s-coeff-full} + {&DELIM-PAR} +
        {&table_prod-bc-full} + {&DELIM-PAR} + {&table_bar-code-full} + {&DELIM-PAR} +
        {&table_varianty-delivery-gds-obj-full} + {&DELIM-PAR} + {&table_gds-season-full} + {&DELIM-PAR} +
        {&table_dis-gds-rule-full} + {&DELIM-PAR} + {&table_assortment-matrix-goods-full} + {&DELIM-PAR} +
        {&table_gds-obj-prop-full} + {&DELIM-PAR} + {&table_ext-artic-full}
v-groups1 = fill(({&table_goods} + {&delim-par}), num-entries(v-codes1, {&delim-par} ) )
.

run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .

assign
v-codes1 = {&table_cash-pay} + {&delim-par} + {&table_cash-pay-attr} + {&delim-par} + {&table_dis-cp-rule}
v-labels1 = {&table_cash-pay-full} + {&DELIM-PAR} + {&table_cash-pay-attr-full} + {&DELIM-PAR} + {&table_dis-cp-rule-full}
v-groups1 = fill(({&table_cash-pay} + {&delim-par}), num-entries(v-codes1, {&delim-par} ) )
v-groups1 = right-trim(v-groups1, {&delim-par} )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .

assign
v-codes1 = {&table_cash-desk} + {&delim-par} + {&table_cash-desk-attr}
v-labels1 = {&table_cash-desk-full} + {&DELIM-PAR} + {&table_cash-desk-attr-full}
v-groups1 = fill(({&table_cash-desk} + {&delim-par}), num-entries(v-codes1, {&delim-par} ) )
v-groups1 = right-trim(v-groups1, {&delim-par} )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .

assign
v-codes1 = {&table_ext-classif}
v-labels1 = {&table_ext-classif-full}
v-groups1 = fill(({&table_ext-classif} + {&delim-par}), num-entries(v-codes1, {&delim-par} ) )
v-groups1 = right-trim(v-groups1, {&delim-par} )
.
run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .

/* спецификации к договорам */
assign
v-codes1 = {&table_contract-specif}
v-labels1 = {&table_contract-specif-full}
v-groups1 = fill(({&table_contract-specif} + {&delim-par}), num-entries(v-codes1, {&delim-par} ) )
v-groups1 = right-trim(v-groups1, {&delim-par} )
.

run create-hist-nws-option in this-procedure ( input v-codes1
                                              ,input v-labels1
                                              ,input v-groups1) .
end.

if not v-is-1c-erp then do:
run waitfram-show in this-procedure ("Заполнение справочника регионов РФ").
run utl/reg-cre.p.

run waitfram-show in this-procedure ("Создание кассовой книги по основному виду деятельности.").
run cre-CashBook in this-procedure .

end.
run waitfram-hide in this-procedure .
message "Инициализация закончена.".

procedure cre-unit:
def input param u-n as char no-undo.
def input param l-n as char no-undo.
def input param tp as char no-undo.

  find buf_units where buf_units.unit-name = u-n no-error.
  if not avail buf_units then do:
      find buf_units where buf_units.unit-name = (u-n + ".") no-error.
  end.
  if available buf_units then do:
    if buf_units.type = "" then do:
      message
      "Для единицы измерения:" buf_units.unit-name "тип не задан." "Подставляем:" tp skip (2)
      "Внимание!!! Проверьте все остальные единицы измерения. Возможно, Вы забыли запустить утилиту:"
      "Администратор / Утилиты / Смена версии / Типы единиц измерения. Это может привести к серьезным ошибкам в работе системы!".
      buf_units.type = tp.
    end.
    if buf_units.type <> tp then do:
      message
      "Для единицы измерения:" buf_units.unit-name "тип:" buf_units.type "не совпадает с рекомендуемым:" tp skip (2)
      "Это может привести к серьезным ошибкам в работе системы! Тип заменяется на рекомендуемый"
      view-as alert-box WARNING.
      buf_units.type = tp.
    end.
  end.
  else do:
    create buf_units.
    assign
      buf_units.unit-name = u-n
      buf_units.long-name = l-n
      buf_units.type = tp
      buf_units.stts = 0.
  end.

end procedure.

procedure import-countries private:
define input parameter p-country-path as character no-undo .
define buffer buf_country for DICTDB.country .

  input from value(p-country-path).
  empty temp-table for-country.
  
  _repeat:
  REPEAT:
      CREATE for-country.
      IMPORT for-country NO-ERROR.
      if error-status:error then next _repeat.
      if for-country.alpha1 = '':U then do:
        delete for-country.
        next _repeat.
      end.
      IF NOT (CAN-FIND(FIRST DICTDB.country where DICTDB.country.num-code = for-country.num-code) OR
              CAN-FIND(FIRST DICTDB.country where DICTDB.country.alpha1   = for-country.alpha1))
                  and for-country.num-code > 0
      then do:
          create buf_country.
          ASSIGN
            buf_country.alpha1     = for-country.alpha1
            buf_country.alpha2     = for-country.alpha2
            buf_country.long-name  = for-country.long-name
            buf_country.num-code   = for-country.num-code
            buf_country.short-name = for-country.short-name
          .
      end.
      delete for-country.
  END.
  
  empty temp-table for-country.
  INPUT CLOSE.
end procedure. /* end_of import-countries */

procedure cre-tax:
def input param taxcode like DICTDB.tax.tax-code no-undo.
def input param l-n as char no-undo.
def input param tp as char no-undo.
def input param tocashdesk as logical no-undo.
def input param unittypes as char no-undo.
def input param individ like DICTDB.tax.individual no-undo.

DEFINE VARIABLE jj         as integer no-undo .
DEFINE VARIABLE vunit-type like DICTDB.units.type no-undo .
DEFINE VARIABLE p1         as logical no-undo .
DEFINE VARIABLE p2         as logical no-undo .

define buffer buf_tax               for DICTDB.tax .
define buffer b_tax-unit for DICTDB.tax-units.

  find buf_tax where buf_tax.tax-code = taxcode no-error.
  if available buf_tax then do:
    if buf_tax.tax-type = "" then do:
      message "Для налога:" buf_tax.tax-name "тип не задан." "Подставляем:" tp
                      .
      buf_tax.tax-type = tp.
    end.
    if buf_tax.tax-type <> tp then do:
      message
      "Для налога:" buf_tax.tax-name "тип:" buf_tax.tax-type "не совпадает с рекомендуемым:" tp skip (2)
      "Это может привести к серьезным ошибкам в работе системы! Тип заменяется на рекомендуемый"
      view-as alert-box WARNING.
      buf_tax.tax-type = tp.
    end.
    if buf_tax.to-cashdesk <> tocashdesk then do:
      message
      "Для налога:" buf_tax.tax-name "флаг ~"отправлять на кассу~":" buf_tax.to-cashdesk "не совпадает с рекомендуемым:" tocashdesk skip (2)
      "Значение флага ~"отправлять на кассу~" заменено на:" tocashdesk
      view-as alert-box WARNING.
      buf_tax.to-cashdesk = tocashdesk .
    end.
    
    do jj = 1 to num-entries(unittypes):
      assign
      vunit-type =entry(jj, unittypes)
      p1 = no
      p2 = no
      .
      find first b_tax-unit No-LOCK WHERE
                          b_tax-unit.tax-code = taxcode AND
                          b_tax-unit.type = vunit-type AND
                          unittypes <> {&bottle} no-error.
      /*нет нужной связи тип товара налог*/
      if not avail b_tax-unit then p1 = yes.

      IF can-find(first b_tax-unit No-LOCK WHERE
                        b_tax-unit.tax-code = taxcode AND
                        LOOKUP(b_tax-unit.type, unittypes) = 0 )
                  AND
      unittypes <> {&bottle} then do:
        /*лишняя запись*/
        p2 = yes.
      end.
     glog = yes.
     if p1 or p2 then do:
        message
        "Для налога:" buf_tax.tax-name "типы единиц измерения: не совпадают с рекомендуемыми:" unittypes skip (2)
        "Это может привести к серьезным ошибкам в работе системы! Тип заменяется на рекомендуемый"
        view-as alert-box WARNING.
        if p1 then do:
            run add-tax-units in this-procedure (taxcode, vunit-type).
        end.
        if p2 then do:
          FOr each b_tax-unit where
                  b_tax-unit.tax-code = taxcode AND
                  LOOKUP(b_tax-unit.type, unittypes) = 0:
            delete b_tax-unit.
          end. /*for each b_tax-unit*/
        end. /*if p2*/
      end. /*if p1 or p2*/
    end. /*_jj*/
  end.
  else do:
    create buf_tax.
    assign
      buf_tax.tax-code = taxcode
      buf_tax.tax-name = l-n
      buf_tax.tax-type = tp
      buf_tax.to-cashdesk = tocashdesk
      buf_tax.individual = individ
      buf_tax.status_ = {&current-status}
      .
    _jj:
    do jj = 1 to num-entries(unittypes):
      vunit-type =entry(jj, unittypes).
      if not (vunit-type = {&pieces}  OR
              vunit-type = {&divisional} OR
              vunit-type = {&serial} OR
              vunit-type = {&weight} OR
              vunit-type = {&petrolium}
                  )  then do:
          NEXT _JJ.
        end.
      run add-tax-units in this-procedure (taxcode, vunit-type).
    END. /*_jj:*/
  end.

end procedure.


procedure cre-tax-rate:
def input param taxcode  like DICTDB.tax.tax-code       no-undo.
def input param ratecode like DICTDB.tax-rate.rate-code no-undo.
def input param ratename like DICTDB.tax-rate.rate-name no-undo.
define buffer buf_tax-rate          for DICTDB.tax-rate .

  find buf_tax-rate where buf_tax-rate.rate-code = ratecode no-error.
  if available buf_tax-rate then do:
    if NOT buf_tax-rate.tax-code = taxcode then do:
      message "Для ставки налога с кодом " buf_tax-rate.rate-code "код категории налога не совпадает с рекомендуемым." skip
      "Подставляем:" taxcode
      view-as alert-box.
                      .
      buf_tax-rate.tax-code = taxcode.
    end.
  end.
  else do:
    create buf_tax-rate.
    assign
      buf_tax-rate.tax-code = taxcode
      buf_tax-rate.rate-code = ratecode
      buf_tax-rate.rate-name = ratename
      buf_tax-rate.status_ = {&current-status}
      .
  end.

end procedure.


procedure cre-tax-rate-value:
def input param taxcode   like DICTDB.tax.tax-code              no-undo.
def input param ratecode  like DICTDB.tax-rate.rate-code        no-undo.
def input param ratevalue like DICTDB.tax-rate-value.rate-value no-undo.
def input param p-today   as date no-undo .
def input param p-time    as integer no-undo .
DEFINE VARIABLE var-day-end-fact-order as decimal no-undo .
define buffer buf_tax-rate-value    for DICTDB.tax-rate-value .

  run factord-end-day in this-procedure (input p-today, output var-day-end-fact-order).

  find LAST  buf_tax-rate-value where
             buf_tax-rate-value.rate-code   = ratecode  AND
             buf_tax-rate-value.tax-code    = taxcode AND
             buf_tax-rate-value.host-code   = 0 AND
             buf_tax-rate-value.obj-type    = "" AND
             buf_tax-rate-value.obj-code    = 0 AND
             buf_tax-rate-value.fact-order <= var-day-end-fact-order
             no-error.
  if not avail buf_tax-rate-value then do:

    create buf_tax-rate-value.
    assign
      buf_tax-rate-value.tax-code = taxcode
      buf_tax-rate-value.rate-code = ratecode
      buf_tax-rate-value.rate-value = ratevalue
      buf_tax-rate-value.fact-date  = p-today
      buf_tax-rate-value.fact-order = var-day-end-fact-order
      buf_tax-rate-value.status_ = {&current-status}
      buf_tax-rate-value.host-code = 0
      buf_tax-rate-value.obj-type = "":U
      buf_tax-rate-value.obj-code = 0
      buf_tax-rate-value.corr-date = p-today
      buf_tax-rate-value.corr-time = p-time
      buf_tax-rate-value.corr-user-db-num = v-cntxt-db-num
      buf_tax-rate-value.corr-user-name = v-cntxt-userid
      .
  end.


end procedure.

procedure cre-tax-rate-attr:
def input param taxcode  like DICTDB.tax.tax-code       no-undo.
def input param ratecode like DICTDB.tax-rate.rate-code no-undo.
define buffer buf_tax-rate-attr          for DICTDB.tax-rate-attr .

  find buf_tax-rate-attr where buf_tax-rate-attr.rate-code = ratecode no-error.
  if available buf_tax-rate-attr then do:
    if NOT buf_tax-rate-attr.tax-code = taxcode then do:
      message "Для ставки налога с кодом " buf_tax-rate-attr.rate-code "уже есть атрибут ЕНВД." skip
      "Подставляем:" taxcode
      view-as alert-box.
                      .
      buf_tax-rate-attr.tax-code = taxcode.
    end.
  end.
  else do:
    create buf_tax-rate-attr.
    assign
      buf_tax-rate-attr.tax-code = taxcode
      buf_tax-rate-attr.rate-code = ratecode
      buf_tax-rate-attr.attr-code = "envd"
      .
  end.

end procedure.

PROCEDURE add-tax-units:
define input parameter partax-code  like DICTDB.tax.tax-code no-undo .
define input parameter parunit-type like DICTDB.units.type   no-undo .
define buffer buf_tax-units         for DICTDB.tax-units .

  if not can-find(first buf_tax-units No-LOCK WHERE
                        buf_tax-units.tax-code = partax-code AND
                        buf_tax-units.type = parunit-type) then do:

    create buf_tax-units.
    assign
      buf_tax-units.tax-code = partax-code
      buf_tax-units.type = parunit-type
    .
  END.

END PROCEDURE.


procedure add-tax-gds-grp :
/*  
 define variable start-time     as integer   no-undo .
 define variable current-time   as integer   no-undo .
 define variable v-err-count    as integer no-undo .
*/ 
DEFINE VARIABLE var-vat-code as character no-undo .
DEFINE VARIABLE var-SLT-code as character no-undo .
/*
 DEFINE VARIABLE rc as recid no-undo.
*/ 
DEFINE VARIABLE vattr-labels as character no-undo .
DEFINE VARIABLE vattr-codes as character no-undo .
DEFINE VARIABLE vartax-value like DICTDB.tax-rate-value.rate-value no-undo . /* dec-10 */
define variable VATtaxcd as integer no-undo.
define variable SLTtaxcd as integer no-undo.
define buffer buf_tax-rate-gds-grp  for DICTDB.tax-rate-gds-grp .


/*вспомогат*/
/*
define variable taxvalue like DICTDB.tax-rate-value.rate-value no-undo.
*/

/*определим какие налоги по сути являются НДС и НП*/
vattaxcd = integer({&vat-tax-code}).
slttaxcd = integer({&slt-tax-code}).


if p-sys-key <> "raimbek":U then do:
  
  assign
  vattr-codes = "":U
  vattr-labels = "":U
  .
  for each DICTDB.tax-rate no-lock where
           DICTDB.tax-rate.tax-code = vattaxcd:

    { gbl/pftaxval.i recid(DICTDB.tax-rate) DICTDB.tax-rate.tax-code DICTDB.tax-rate.rate-code ? 0 '':U 0 vartax-value no-error }
    if error-status:error then do:
      message return-value view-as alert-box error .
      return error return-value.
    end.
    if vartax-value = ? then NEXT.
    
    /* 15/XI-2017 - ставку налога по-умолчанию для 1С выбираем без участия пользователя */
    if v-is-1c-erp then do:
      var-vat-code = string(tax-rate.rate-code) .
      leave .
    end.
    else assign
    vattr-labels = vattr-labels +
                  (if vattr-labels = "":U then "" else {&comma-char}) +
                  string(string(tax-rate.rate-code) + " - " + replace(tax-rate.rate-name, {&comma-char}, "":U), "X(25)") +
                  fill({&space-char}, 5) + string(vartax-value, "99.99%":U)
    vattr-codes = vattr-codes +
                  (if vattr-codes = "":U then "" else {&comma-char}) +
                  string(tax-rate.rate-code)
    .
  end.

  /* 15/XI-2017 - ставку налога по-умолчанию для 1С выбираем без участия пользователя */
  if not v-is-1c-erp then do:
    run gbl/d-list.w (
                INPUT "b-sel":U
                ,INPUT "Выберите ставку НДС для групп (по умолчанию)"
                ,INPUT vattr-codes
                ,INPUT vattr-labels
                ,INPUT {&comma-char}
                ,INPUT "":U
                ,output var-vat-code).
    IF var-vat-code = "":u THEN do:
    message
    "Вы не выбрали ставку НДС для групп!" skip
    "Это может привести к непредсказуемым результатам"
    view-as alert-box error .
    RETURN ERROR.
    end.
  end.
end.


assign
vattr-codes = "":U
vattr-labels = "":U
.

for each tax-rate no-lock where
         tax-rate.tax-code = slttaxcd:

  { gbl/pftaxval.i recid(tax-rate) tax-rate.tax-code tax-rate.rate-code ? 0 '':U 0 vartax-value no-error }
  if error-status:error then do:
    message
    return-value view-as alert-box error .
    return error.
  end.
  if vartax-value = ? then NEXT.
  
  /* 15/XI-2017 - ставку налога по-умолчанию для 1С выбираем без участия пользователя */
  if v-is-1c-erp then do:
    var-slt-code = string(tax-rate.rate-code) .
    leave .
  end.
  else assign
  vattr-labels = vattr-labels +
                (if vattr-labels = "":U then "" else {&comma-char}) +
                string(string(tax-rate.rate-code) + " - " + replace(tax-rate.rate-name, {&comma-char}, "":U), "X(25)") +
                fill({&space-char}, 5) + string(vartax-value, "99.99%":U)
  vattr-codes = vattr-codes +
                (if vattr-codes = "":U then "" else {&comma-char}) +
                string(tax-rate.rate-code)
  .
end.

/* 15/XI-2017 - ставку налога по-умолчанию для 1С выбираем без участия пользователя */
if not v-is-1c-erp then do:
  run gbl/d-list.w (
              INPUT "b-sel":U
              ,INPUT "Выберите ставку НП для групп (по умолчанию)(если НП не действует, выберите знач=0)"
              ,INPUT vattr-codes
              ,INPUT vattr-labels
              ,INPUT {&comma-char}
              ,INPUT "":U
              ,output var-slt-code).
  IF var-slt-code = "":u THEN do:
  message
  "Вы не выбрали ставку НП для групп!" skip
  "Это может привести к непредсказуемым результатам"
  view-as alert-box error .
  RETURN ERROR.
  end.
end .


do on error undo, return error :
  FOR EACH DICTDB.gds-grp No-LOCK:

    if p-sys-key <> "raimbek":U then do:
      if not can-find(first buf_tax-rate-gds-grp where
                            buf_tax-rate-gds-grp.tax-code = vattaxcd AND
                            buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code AND
                            buf_tax-rate-gds-grp.host-code = 0 AND
                            buf_tax-rate-gds-grp.obj-type = "":U AND
                            buf_tax-rate-gds-grp.obj-code = 0
                            ) then do:
        create buf_tax-rate-gds-grp.
        assign
          buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code
          buf_tax-rate-gds-grp.tax-code = vattaxcd
          buf_tax-rate-gds-grp.rate-code = integer(var-vat-code)
       .
      end.
    end.
    
    if not can-find(first buf_tax-rate-gds-grp where
                          buf_tax-rate-gds-grp.tax-code = slttaxcd AND
                          buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code AND
                          buf_tax-rate-gds-grp.host-code = 0 AND
                          buf_tax-rate-gds-grp.obj-type = "":U AND
                          buf_tax-rate-gds-grp.obj-code = 0
                          ) then do:
      create buf_tax-rate-gds-grp.
      assign
         buf_tax-rate-gds-grp.node-code = DICTDB.gds-grp.node-code
         buf_tax-rate-gds-grp.tax-code = slttaxcd
         buf_tax-rate-gds-grp.rate-code = integer(var-slt-code)
      .
    end.
    
  end. /*for each DICTDB.gds-gpr*/
end.

END PROCEDURE. /*add-tax-gds-grp*/


PROCEDURE get-rate-value:
define input parameter partax-code like DICTDB.tax.tax-code no-undo .
define input parameter parrate-code like DICTDB.tax-rate.rate-code no-undo .
define output parameter parrate-value like DICTDB.tax-rate-value.rate-value no-undo .
DEFINE VARIABLE var-fact-order as decimal no-undo .

define buffer buf_tax-rate-value    for DICTDB.tax-rate-value .

   var-fact-order = integer(today) + 0.99.

   FIND LAST buf_tax-rate-value No-LOCK WHERE
            buf_tax-rate-value.tax-code = partax-code AND
            buf_tax-rate-value.rate-code = parrate-code AND
            buf_tax-rate-value.host-code = 0 AND
            buf_tax-rate-value.obj-type = "" AND
            buf_tax-rate-value.host-code = 0 AND
            buf_tax-rate-value.fact-order <= var-fact-order No-ERROR.
   if available buf_tax-rate-value then do:
      assign
         parrate-value = buf_tax-rate-value.rate-value
      .
   end.
END PROCEDURE.

procedure import-menu-grps :
define variable v-shift-node-code like DICTDB.fbr-gds-grp.node-code no-undo .
define buffer buf_fbr-gds-grp for DICTDB.fbr-gds-grp.

  do
  on error undo, return error
  :
    for each buf_fbr-gds-grp  where buf_fbr-gds-grp.node-code <> 1 no-lock:
      assign
      v-shift-node-code =  buf_fbr-gds-grp.node-code
      .
    end.

    input from value(menu-grp-path).
    for each temp_fbr-gds-grp:
      delete temp_fbr-gds-grp.
    end.
    _repeat2:
    REPEAT:
        CREATE temp_fbr-gds-grp.
        IMPORT temp_fbr-gds-grp.node-name temp_fbr-gds-grp.node-code temp_fbr-gds-grp.upper-code temp_fbr-gds-grp.lvl-num NO-ERROR.
        if error-status:error then do:
          delete temP_fbr-gds-grp.
          next  _repeat2.
        end.
        if not error-status:error then do:
          IF NOT CAN-FIND(FIRST buf_fbr-gds-grp where buf_fbr-gds-grp.node-code = (temp_fbr-gds-grp.node-code + v-shift-node-code)
                              and buF_fbr-gds-grp.obj-type      = "":U
                              AND buF_fbr-gds-grp.obj-code      = 0        )
            AND ( temp_fbr-gds-grp.upper-code  = 1
                or
                CAN-FIND(FIRST buf_fbr-gds-grp where buf_fbr-gds-grp.NODE-code = temp_fbr-gds-grp.upper-code +  v-shift-node-code
                              and buF_fbr-gds-grp.obj-type      = "":U
                              AND buF_fbr-gds-grp.obj-code      = 0           )
                  )
          and not can-find(first buf_fbr-gds-grp where
                                 buF_fbr-gds-grp.obj-type = "":U
                             AND buF_fbr-gds-grp.obj-code      = 0
                             and buF_fbr-gds-grp.upper-code = (if temp_fbr-gds-grp.upper-code  = 1
                                                              then 1
                                                              else  (temp_fbr-gds-grp.upper-code +  v-shift-node-code))
                           and buf_fbr-gds-grp.node-name = temp_fbr-gds-grp.node-name)

          then do:
              create buf_Fbr-gds-grp.
              ASSIGN
              buF_fbr-gds-grp.node-code     = temp_fbr-gds-grp.node-code  +  v-shift-node-code
              buf_fbr-gds-grp.upper-code    = (if temp_fbr-gds-grp.upper-code  = 1 then 1 else  (temp_fbr-gds-grp.upper-code +  v-shift-node-code))
              buF_fbr-gds-grp.node-name     = temp_fbr-gds-grp.node-name
              buF_fbr-gds-grp.obj-type      = "":U
              buF_fbr-gds-grp.obj-code      = 0
              buF_fbr-gds-grp.out-code      = temp_fbr-gds-grp.node-code
              buF_fbr-gds-grp.global-code   = temp_fbr-gds-grp.node-code
              buF_fbr-gds-grp.lvl-num       = temp_fbr-gds-grp.lvl-num
              .
          end.
        end.
        delete temp_fbr-gds-grp.
    END.
    for each temp_fbr-gds-grp:
      delete temp_fbr-gds-grp.
    end.
    INPUT CLOSE.
  end.

end procedure. /* import menu-grps */

define temp-table tt-db-hn like DICTDB.db
field hn-id as integer
index pi is unique primary
db-num
hn-id
.

procedure create-hist-nws-option :
define input parameter p-codes as character no-undo .
define input parameter p-labels as character no-undo .
define input parameter p-groups as character no-undo .

define variable v-ii as integer no-undo .
define buffer buf_hist-nws-option for DICTDB.hist-nws-option.

do
on error undo, return error
:

  do v-ii = 1 to num-entries(p-codes, {&delim-par} ):
    find first buf_hist-nws-option where
          buf_hist-nws-option.db-num = buf_sys-ctrl.db-num
      and buf_hist-nws-option.table-name = entry(v-ii, p-codes, {&delim-par} )  no-error.
    if not available buf_hist-nws-option
    then do:
      find last tt-db-hn  where
              tt-db-hn.db-num = buf_sys-ctrl.db-num no-error.
      create buf_hist-nws-option.
      assign
      buf_hist-nws-option.db-num =  buf_sys-ctrl.db-num
      buf_hist-nws-option.hn-id  =  (if available tt-db-hn then tt-db-hn.hn-id + 1 else 1)
      buf_hist-nws-option.table-name =  entry(v-ii, p-codes, {&delim-par} )
      buf_hist-nws-option.option-descr = entry(v-ii, p-labels, {&delim-par} )
      buf_hist-nws-option.subject-group = entry( v-ii, p-groups, {&delim-par})
      buf_hist-nws-option.host-code = 0
      buf_hist-nws-option.obj-type = '':U
      buf_hist-nws-option.obj-code = 0
      buf_hist-nws-option.hist-to-nws = 0
      buf_hist-nws-option.nws-to-hist = 0
      buf_hist-nws-option.hist-from-prim = 0
      buf_hist-nws-option.get-hist-from-nws = 0
      .
      if current-value(s-hn-id, ub) < buf_hist-nws-option.hn-id
      then do:
        current-value(s-hn-id, ub) = buf_hist-nws-option.hn-id.
      end.
      create tt-db-hn.
      assign
      tt-db-hn.db-num = buf_hist-nws-option.db-num
      tt-db-hn.hn-id = buf_hist-nws-option.hn-id
      .
      release tt-db-hn.
    end.
  end. /*  do v-ii = 1 to num-entries(v-codes):*/
end.

end procedure. /* create-hist-nws-option */

procedure cre-cli-grp :
define input parameter p-grp-name as character        no-undo.

do
on error undo, return error
:

  if not can-find(first buf_cli-grp No-LOCK
                  WHERE buf_cli-grp.node-name = p-grp-name
                  )
  then do:
      create buf_cli-grp.
      ASSIGN
         buf_cli-grp.node-code  = dynamic-next-value( "s-cli-grp":U, LDBNAME("DICTDB":U) )
         buf_cli-grp.lvl-num    = 1
         buf_cli-grp.node-name  = p-grp-name
         buf_cli-grp.upper-code = 1
         buf_cli-grp.is-term    = TRUE
      .
  end.

end. /* do on error */
end procedure. /* cre-cli-grp */




/*==========================================================================*/
procedure cre-cli :
define input parameter p-obj-name as character        no-undo.
define input parameter p-grp-name as character        no-undo.

define variable v-name    as character    no-undo.
define variable v-obj-code    as integer      no-undo.

do
on error undo, return error
:

  /* !!! индекса нет, но записей мало */
  find first buf_cli-grp
       WHERE buf_cli-grp.node-name = p-grp-name
       NO-LOCK
       NO-ERROR
       .
   if NOT AVAILABLE buf_cli-grp
   then do:
      undo, return error SUBSTITUTE("cre-cli: Ошибка клиента. Не найдена группа клиентов &1", p-grp-name).
   end.


   if not can-find(first buf_clients
                     WHERE buf_clients.obj-name = p-obj-name
                     NO-LOCK
                     )
   then do:
      assign
         v-name = ""
      .

      run cli-grplib-get-full-name in this-procedure
         (input  buf_cli-grp.node-code
         ,output v-name
         ).

      run gen-b-code in this-procedure ( input {&gbl-fm-code}, output v-obj-code) no-error .
      if error-status :error
      then do:
         undo, return error "cre-cli: Ошибка генерации уникального кода для фирмы поставщика." + {&new-line} + return-value.
      end.
      create buf_firm.
      assign
         buf_firm.firm-code      = v-obj-code
      .
      create buf_clients.
      ASSIGN
         buf_clients.obj-type    = {&cmp}
         buf_clients.obj-code    = v-obj-code
         buf_clients.obj-name    = p-obj-name
         buf_clients.grp-code    = buf_cli-grp.node-code
         buf_clients.grp-name    = v-name
      .
  end.

end. /* do on error */
end procedure. /* cre-cli */

procedure cre-cli2 private:
define variable v-name as character no-undo .
/* классами импорта создавать нельзя:
   Ошибка при проверке ИНН на уникальность.
   trg/inn-uniq.p Shared variable g#news has not yet been created. (392) */

    /* для технологических клиентов применяется серия кодов 800 000 000 */
    /* для технологических контрагентов согласована привязка к группе 5 */
    run cli-grplib-get-full-name in this-procedure (input 5 /* cli-grp.node-code */, output v-name) .
         
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000001 /* для контрагента РЕАЛИЗАЦИЯ согласован код 800 000 001 */
      buf_clients.obj-name = "Реализация розничная"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5 
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000001
      buf_firm.ind       = 0 /* firm.ind на тестовом сервере 0 в формате "6-знаков" */
    .

    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000002
      buf_clients.obj-name = "Технологический пролив"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000002
      buf_firm.ind       = 0
    .

    /* Выставить атрибут Расходы отдельной строкой в yes */
    &scop proc-name clntattr-write
    {&run_proc_attr-lib}
      (input  {&cmp}
      ,input  800000002
      ,input  {&attr-shftrep2}
      ,input  "yes":U
      ) no-error .
    if error-status:error then do:
      message return-value view-as alert-box error .
      return error return-value.
    end.
    
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000003
      buf_clients.obj-name = "Отбор проб"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000003
      buf_firm.ind       = 0
    .
    
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000004
      buf_clients.obj-name = "Программа лояльности"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000004
      buf_firm.ind       = 0
    .
    
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000005
      buf_clients.obj-name = "Ввод первоначальных остатков"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000005
      buf_firm.ind       = 0
    .
    
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000006
      buf_clients.obj-name = 'Банк "ВБРР" АО'
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000006
      buf_firm.ind       = 0
    .
    
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000007
      buf_clients.obj-name = "Банк ВБРР (агентская выручка)"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000007
      buf_firm.ind       = 0
    .
    create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000008
      buf_clients.obj-name = "Перемещение денежных средств"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000008
      buf_firm.ind       = 0
    .
    
     create buf_clients.
    assign
      buf_clients.obj-type = {&cmp}
      buf_clients.obj-code = 800000009
      buf_clients.obj-name = "Выдача наличных денежных средств"
      buf_clients.stts     = 0
      buf_clients.grp-code = 5
      buf_clients.grp-name = v-name
    .
    create buf_firm.
    assign
      buf_firm.firm-code = 800000009
      buf_firm.ind       = 0
    .

end procedure . /* end_of cre-cli2 */
/*==========================================================================*/
procedure cre-pay-type :
define input parameter p-code as integer        no-undo.
define input parameter p-name as character        no-undo.

do
on error undo, return error
:
   if not can-find(first buf_pay-type
                   WHERE buf_pay-type.obj-code = p-code
                   NO-LOCK
                  )
   then do:
      create buf_pay-type.
      ASSIGN
         buf_pay-type.obj-code = p-code
         buf_pay-type.obj-name = p-name
      .
   END.
end. /* do on error */
end procedure. /* cre-pay-type */




/*==========================================================================*/
procedure cre-wth :
define input parameter p-code as integer          no-undo.
define input parameter p-curr-code as integer          no-undo.
define input parameter p-is-money as logical          no-undo.
define input parameter p-name as character        no-undo.
define input parameter p-get-qnty-method as character        no-undo.

do
on error undo, return error
:
   FIND FIRST buf_currency
        WHERE buf_currency.curr-code = p-curr-code
        NO-LOCK
        NO-ERROR
        .
   if NOT AVAILABLE buf_currency
   then do:
      undo, return error SUBSTITUTE("cre-wth: Ошибка создания МЦ. Не найдена валюта &1", p-curr-code).
   end.

   if not can-find(first buf_wealth
                   WHERE buf_wealth.wth-code = p-code
                   NO-LOCK
                  )
   then do:
      CREATE buf_wealth.
      ASSIGN
         buf_wealth.wth-code  = p-code
         buf_wealth.wth-name  = p-name
         buf_wealth.is-money  = p-is-money
         buf_wealth.curr-code = p-curr-code
         buf_wealth.get-qnty-method = p-get-qnty-method
      .
   END.

end. /* do on error */
end procedure. /* cre-wth */




/*==========================================================================*/
procedure cre-cash-pay :
define input parameter p-code       as integer          no-undo.
define input parameter p-curr-code  as integer          no-undo.
define input parameter p-type       as integer          no-undo.
define input parameter p-wth        as integer          no-undo.
define input parameter p-name       as character        no-undo.
define input parameter p-is-cash    as logical          no-undo.
define input parameter p-is-credit  as logical          no-undo.

do
on error undo, return error
:
   FIND FIRST buf_currency
        WHERE buf_currency.curr-code = p-curr-code
        NO-LOCK
        NO-ERROR
        .
   if NOT AVAILABLE buf_currency
   then do:
      undo, return error SUBSTITUTE("cre-cash-pay: Ошибка создания типа кассового платежа. Не найдена валюта &1", p-curr-code).
   end.

   FIND FIRST buf_pay-type
        WHERE buf_pay-type.obj-code = p-type
        NO-LOCK
        NO-ERROR
        .
   if NOT AVAILABLE buf_pay-type
   then do:
      undo, return error SUBSTITUTE("cre-cash-pay: Ошибка создания типа кассового платежа. Не найден тип платежа &1", p-type).
   end.

   IF p-wth <> 0
   THEN DO:
      FIND FIRST buf_wealth
         WHERE buf_wealth.wth-code   = p-wth
         NO-LOCK
         NO-ERROR
         .
      if NOT AVAILABLE buf_wealth
      then do:
         undo, return error SUBSTITUTE("cre-cash-pay: Ошибка создания типа кассового платежа. Не найдена МЦ &1", p-wth).
      end.
   end.

   if not can-find(first buf_cash-pay
                   WHERE buf_cash-pay.cdpay-code = p-code
                     AND buf_cash-pay.curr-code  = p-curr-code
                   NO-LOCK
                  )
   then do:
      CREATE buf_cash-pay.
      ASSIGN
         buf_cash-pay.cdpay-code  = p-code
         buf_cash-pay.curr-code   = p-curr-code
         buf_cash-pay.pay-code    = p-type
         buf_cash-pay.wth-code    = p-wth
         buf_cash-pay.is-credit   = p-is-credit
         buf_cash-pay.is-cash     = p-is-cash
         buf_cash-pay.atr1        = TRUE
         buf_cash-pay.atr2        = TRUE
         buf_cash-pay.status_     = {&current-status}
         buf_cash-pay.is-all-pay  = p-is-cash
         buf_cash-pay.can-mix     = INTEGER(p-is-cash)
         buf_cash-pay.has-overpay = INTEGER(p-is-credit)
      .
   END.

end. /* do on error */
end procedure. /* cre-cash-pay */

procedure cre-trn-reason private :
/* скопировано из str/trn-rsna.w - Карточка основания (причины) создания документа */
define input parameter p-reason-code as integer no-undo .
define input parameter p-reason-name as character no-undo .
define variable v-rid as recid initial ? no-undo .

  run ref/trn-rsn1.p
    ( input-output v-rid
    , input {&add-def}
    , input true /* p-silent */
    , input p-reason-code
    , input p-reason-name
    , input ""
  ) .
  
  return .
end procedure . /* end _of cre-trn-reason */

procedure cre-CashBook private :
define buffer buf_CashBook     for DICTDB.CashBook .
define buffer buf_CashBookRule for DICTDB.CashBookRule .

  create buf_CashBook .
  assign
    buf_CashBook.id           = 0
    buf_CashBook.ext-code     = "0" /* Код/номер типа кассовой книги 0 */
    buf_CashBook.CashBookName = "Основная деятельность" /* Наименование типа кассовой книги */  
    buf_CashBook.RuleOsnPko   = "0" /* Значение для заполнения графы "Основание" (перечень cb-by-osnovanie в rul/rcps-67.w) */
    buf_CashBook.RulePril     = "0"      /* Значение для заполнения графы "Приложение" (перечень cb-by-osnovanie в rul/rcps-67.w) */ 
    buf_CashBook.FlagSepCash  = true /* Флаг «Отдельный ПКО для каждой кассы» */
    buf_CashBook.FlagSepFull  = true /* Флаг «Раздельно НП и ТНП» */
    buf_CashBook.CorrPko      = "90.01" /* Значение для заполнения поля «кредит» 90.01 */
    buf_CashBook.OsnAcct      = "50.02" /* Значение для заполнения поля «дебит» 50.02 */
  .

end procedure . /* end_of cre-CashBook */
