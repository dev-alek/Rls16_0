block-level on error undo, throw.
/*

$Revision: 06e9119eead9, 1245, rls $
$Author: EShklyar $
$Date: Mon Feb 26 19:39:45 2018 +0300 $
$Workfile: cgdshisvh.p $
$Archive: ref/cgdshisvh.p $

Заполнение временной таблицы для показа изменений по таблицам истории товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/22/04
Author: Bakhtadze Natalya
Creation date: 01/22/04

*/


define input parameter p-gds-code like ub.c-gds-hist.gds-code no-undo .
define input parameter p-chip-num like ub.c-gds-hist.chip-num no-undo .
define input parameter p-subject like ub.c-gds-hist.subject no-undo .
define input parameter p-action   like ub.c-gds-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define input parameter p-log-file as character no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 06e9119eead9, 1245, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 26 19:39:45 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cgdshisvh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cgdshisvh.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории товара".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ ref/gdsoattr.i }
{ ref/gdshattr.i }
{ ref/gds-attr.i }
{ ref/gdspoatr.i }
{ ref/bc-attr.i }
{ ref/disgdsru.i }
{ gbl/plgdattr.i }
{ trg/factord.i }
{ ref/extclass.i }
{ gbl/key-rec.i }

define variable v-chg-fields as character no-undo.
define variable v-chg-fields-name as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-gds-hist for ub.c-gds-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-gds-hist no-lock where
          buf_c-gds-hist.gds-code = p-gds-code
      AND buf_c-gds-hist.chip-num = p-chip-num
      AND buf_c-gds-hist.subject  = p-subject no-error .
if not available buf_c-gds-hist then do:
  return error .
end.
CASE p-subject:
  when {&table_goods} then do:
    run goods-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_gds-obj-attr} then do:
    run gds-obj-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_gds-host-attr} then do:
    run gds-host-attr-proc in this-procedure(output p-description) no-error .
  end.
  when {&table_goods-attr} then do:
    run goods-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_fbr-gds-obj} then do:
    run fbr-gds-obj-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_s-coeff} then do:
    run s-coeff-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_prod-bc} then do:
    run prod-bc-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_bar-code} then do:
    run bar-code-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_bar-code-attr} then do:
    run bar-code-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_varianty-delivery-gds-obj} then do:
    run varianty-delivery-gds-obj-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_gds-season} then do:
    run gds-season-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_tax-rate-gds} then do:
    run tax-rate-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_assortment-matrix-goods} then do:
    run ass-matr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_gds-obj-prop} then do:
    run izt-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-gds} then do:
    run pl-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-gds-attr} then do:
    run pl-gds-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_pl-gds-pump} then do:
    run pl-gds-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_dis-gds-rule} then do:
    run dis-gds-rule-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_ext-artic} then do:
    run ext-artic-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_sert-join} then do:
    run sert-join-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_recipe} then do:
    run recipe-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_recipe-gds} then do:
    run recipe-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_ext-classif} then do:
    run ext-classif-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_gds-obj-prop-attr} then do:
    run gds-obj-prop-attr-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.

procedure goods-proc :
define output parameter p-description as character no-undo .
define buffer current_c-goods for ub.c-goods  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  find first current_c-goods no-lock where
              current_c-goods.gds-code = p-gds-code
          AND current_c-goods.chip-num = p-chip-num
no-error .
  if not avail current_c-goods then do:
    v-mess = "Неверная ссылка на c-goods в таблице c-gds-hist".
    run err-mess in this-procedure ( input-output v-mess).
    return error v-mess.
  end.

&scop fields-name-list "prod-type,prod-code,artic,gds-name,unit-base,prt-root,"  + ~
"grp-code,unit-cli,cli-base-rate,calc-method,increase-pc,stts,qnty-cart,wt-cart,ms-cart," + ~
"engl-name,grp-name,gds-type,PS.okdp,destin,attrib,user-rule,sert,struct," + ~
"sort,deadline,negative-rest,cost-calc,unit-cst,cst-base-rate,TNVED,min-stock,nationality,label-name," + ~
"alpha1,normal-wastage,normal-waste,chk-name,min-rate,max-rate,cr-db-num,cond-keep-code,wt-cart,ms-cart"

define variable v-label-param as character no-undo .

v-label-param =
  "prod-type" + {&delim-par} + "Тип производителя" + {&delim-par} + "" + {&delim-flf}
 + "prod-code" + {&delim-par} + "Производитель" + {&delim-par} + "" + {&delim-flf}
 + "artic" + {&delim-par} + "Артикул" + {&delim-par} + "" + {&delim-flf}
 + "gds-name" + {&delim-par} + "Название товара" + {&delim-par} + "" + {&delim-flf}
 + "unit-base" + {&delim-par} + "Основная единица измер" + {&delim-par} + "" + {&delim-flf}
 + "prt-root" + {&delim-par} + "Корень шкалы" + {&delim-par} + "" + {&delim-flf}
 + "grp-code" + {&delim-par} + "Код группы" + {&delim-par} + "" + {&delim-flf}
 + "unit-cli" + {&delim-par} + "Единица измерения пост" + {&delim-par} + "" + {&delim-flf}
 + "cli-base-rate" + {&delim-par} + "Коэффициент" + {&delim-par} + "" + {&delim-flf}
 + "calc-method" + {&delim-par} + "Способ расчета" + {&delim-par} + "" + {&delim-flf}
 + "increase-pc" + {&delim-par} + "Процент наценки" + {&delim-par} + "" + {&delim-flf}
 + "stts" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "qnty-cart" + {&delim-par} + "Кол. в упак." + {&delim-par} + "" + {&delim-flf}
 + "wt-cart" + {&delim-par} + "Вес упаковки" + {&delim-par} + "" + {&delim-flf}
 + "ms-cart" + {&delim-par} + "Объем упаковки" + {&delim-par} + "" + {&delim-flf}
 + "engl-name" + {&delim-par} + "Название англ." + {&delim-par} + "" + {&delim-flf}
 + "grp-name" + {&delim-par} + "Название группы" + {&delim-par} + "" + {&delim-flf}
 + "gds-type" + {&delim-par} + "Тип" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "okdp" + {&delim-par} + "ОКДП" + {&delim-par} + "" + {&delim-flf}
 + "destin" + {&delim-par} + "Назначение" + {&delim-par} + "" + {&delim-flf}
 + "attrib" + {&delim-par} + "Характеристики" + {&delim-par} + "" + {&delim-flf}
 + "user-rule" + {&delim-par} + "Правила эксплутации" + {&delim-par} + "" + {&delim-flf}
 + "sert" + {&delim-par} + "Сертификация" + {&delim-par} + "" + {&delim-flf}
 + "struct" + {&delim-par} + "Состав (комплектность)" + {&delim-par} + "" + {&delim-flf}
 + "sort" + {&delim-par} + "Сорт" + {&delim-par} + "" + {&delim-flf}
 + "deadline" + {&delim-par} + "Срок хранения" + {&delim-par} + "" + {&delim-flf}
 + "negative-rest" + {&delim-par} + "Разр. отриц.остатки" + {&delim-par} + "" + {&delim-flf}
 + "cost-calc" + {&delim-par} + "Расчет учетных цен" + {&delim-par} + "" + {&delim-flf}
 + "unit-cst" + {&delim-par} + "Таможенная единица изм" + {&delim-par} + "" + {&delim-flf}
 + "cst-base-rate" + {&delim-par} + "Коэффициент" + {&delim-par} + "" + {&delim-flf}
 + "TNVED" + {&delim-par} + "Код ТНВЭД" + {&delim-par} + "" + {&delim-flf}
 + "min-stock" + {&delim-par} + "Мин. остаток" + {&delim-par} + "" + {&delim-flf}
 + "nationality" + {&delim-par} + "Национальность" + {&delim-par} + "" + {&delim-flf}
 + "label-name" + {&delim-par} + "Название на ценнике" + {&delim-par} + "" + {&delim-flf}
 + "alpha1" + {&delim-par} + "Код страны" + {&delim-par} + "" + {&delim-flf}
 + "normal-wastage" + {&delim-par} + "Норма естественной убыли" + {&delim-par} + "" + {&delim-flf}
 + "normal-waste" + {&delim-par} + "Норма отходов" + {&delim-par} + "" + {&delim-flf}
 + "chk-name" + {&delim-par} + "Название на чеке" + {&delim-par} + "" + {&delim-flf}
 + "min-rate" + {&delim-par} + "Мин. кол-во дробн./шт" + {&delim-par} + "" + {&delim-flf}
 + "max-rate" + {&delim-par} + "Макс. кол-во дробн./шт" + {&delim-par} + "" + {&delim-flf}
 + "cr-db-num" + {&delim-par} + "Номер БД где создан" + {&delim-par} + "" + {&delim-flf}
 + "cond-keep-code" + {&delim-par} + "Код условий хранения" + {&delim-par} + "" + {&delim-flf}
 + "wt-cart" + {&delim-par} + "Вес штуки" + {&delim-par} + "" + {&delim-flf}
 + "ms-cart" + {&delim-par} + "Объем штуки" + {&delim-par} + ""  .

 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-goods:handle
                                            ,input  {&table_goods}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.
end procedure. /* goods-proc */


procedure gds-obj-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-obj-attr for ub.c-gds-obj-attr  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

find first current_c-gds-obj-attr no-lock where
            current_c-gds-obj-attr.gds-code = p-gds-code
        AND current_c-gds-obj-attr.chip-num = p-chip-num
        AND current_c-gds-obj-attr.attr-code = buf_c-gds-hist.attr-code
        no-error .

define variable v-label-param as character no-undo .

&scop fields-name-list "obj-type,obj-code,attr-code,gds-code,attr-value"

v-label-param =
  "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-gds-obj-attr:handle
                                            ,input  {&table_gds-obj-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

    run gdsoattr-tooltip in this-procedure (
                input  current_c-gds-obj-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
end.

end procedure. /* gds-obj-attr-proc */

procedure gds-host-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-host-attr for ub.c-gds-host-attr  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-gds-host-attr no-lock where
               current_c-gds-host-attr.gds-code = p-gds-code
           AND current_c-gds-host-attr.chip-num = p-chip-num
           no-error .
    if not avail current_c-gds-host-attr then do:
      v-mess = "Неверная ссылка на c-gds-host-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run gdshattr-tooltip in this-procedure (
                input  string(current_c-gds-host-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list "host-code,attr-code,gds-code,attr-value"

define variable v-label-param as character no-undo .

v-label-param =
  "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-gds-host-attr:handle
                                            ,input  {&table_gds-host-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.
end procedure. /* gds-host-attr-proc */


procedure goods-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-goods-attr for ub.c-goods-attr  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-goods-attr no-lock where
               current_c-goods-attr.gds-code = p-gds-code
           AND current_c-goods-attr.chip-num = p-chip-num
           no-error .
    if not avail current_c-goods-attr then do:
      v-mess = "Неверная ссылка на c-goods-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run gds-attr-tooltip in this-procedure (
                input  string(current_c-goods-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list "attr-code,gds-code,attr-value"
    define variable v-label-param as character no-undo .
v-label-param =
  "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-goods-attr:handle
                                            ,input  {&table_goods-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* goods-attr-proc */


procedure fbr-gds-obj-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable jj as integer no-undo .


define buffer current_c-fbr-gds-obj for ub.c-fbr-gds-obj  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-fbr-gds-obj no-lock where
               current_c-fbr-gds-obj.gds-code = p-gds-code
           AND current_c-fbr-gds-obj.chip-num = p-chip-num
           no-error .
    if not avail current_c-fbr-gds-obj then do:
      v-mess  = "Неверная ссылка на c-fbr-gds-obj в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list "is-menu,is-cd,is-season,calc-code,cfact-date,is-semi-finished,is-modificator,is-modified,"  + ~
"is-null-price,is-tarified,fbr-grp-code,fbr-obj-type,fbr-obj-code,mand-modif-code,non-mand-modif-code,modif-qnty"

define variable v-label-param as character no-undo .

v-label-param =
  "is-menu" + {&delim-par} + "Блюдо меню" + {&delim-par} + "" + {&delim-flf}
 + "is-cd" + {&delim-par} + "На кассу" + {&delim-par} + "" + {&delim-flf}
 + "is-season" + {&delim-par} + "Использ.Сезон.коэф." + {&delim-par} + "" + {&delim-flf}
 + "calc-code" + {&delim-par} + "Номер калк.карты" + {&delim-par} + "" + {&delim-flf}
 + "cfact-date" + {&delim-par} + "Факт-дата" + {&delim-par} + "" + {&delim-flf}
 + "is-semi-finished" + {&delim-par} + "Полуфабрикат" + {&delim-par} + "" + {&delim-flf}
 + "is-modificator" + {&delim-par} + "Модификатор блюда" + {&delim-par} + "" + {&delim-flf}
 + "is-modified" + {&delim-par} + "Модифицируемое блюдо" + {&delim-par} + "" + {&delim-flf}
 + "is-null-price" + {&delim-par} + "Без цены" + {&delim-par} + "" + {&delim-flf}
 + "is-tarified" + {&delim-par} + "Тарифицируемое блюдо" + {&delim-par} + "" + {&delim-flf}
 + "fbr-grp-code" + {&delim-par} + "Код группы меню" + {&delim-par} + "" + {&delim-flf}
 + "fbr-obj-type" + {&delim-par} + "Тип объекта-кухни" + {&delim-par} + "" + {&delim-flf}
 + "fbr-obj-code" + {&delim-par} + "Код объекта-кухни" + {&delim-par} + "" + {&delim-flf}
 + "mand-modif-code" + {&delim-par} + "Группа обяз. модиф-ров" + {&delim-par} + "" + {&delim-flf}
 + "non-mand-modif-code" + {&delim-par} + "Группа необяз. модиф-ров" + {&delim-par} + "" + {&delim-flf}
 + "modif-qnty" + {&delim-par} + "Кол-ов обяза. модиф-ров" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-fbr-gds-obj:handle
                                            ,input  {&table_fbr-gds-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* fbr-gds-obj-proc */


procedure s-coeff-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-s-coeff for ub.c-s-coeff  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-s-coeff no-lock where
               current_c-s-coeff.gds-code = p-gds-code
           AND current_c-s-coeff.chip-num = p-chip-num
           no-error .
    if not avail current_c-s-coeff then do:
      v-mess = "Неверная ссылка на c-s-coeff в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    assign
    p-description = "Начало действия" + {&space-char} +
                    entry(1, string(current_c-s-coeff.s-date, "99/99/9999":U), {&slash-char}) + {&slash-char} +
                    entry(2, string(current_c-s-coeff.s-date, "99/99/9999":U), {&slash-char})
    .
&scop fields-name-list "coeff-value,credate,creid"

define variable v-label-param as character no-undo .

v-label-param =
  "coeff-value" + {&delim-par} + "Значение коэфф" + {&delim-par} + "" + {&delim-flf}
 + "credate" + {&delim-par} + "Дата создания" + {&delim-par} + "" + {&delim-flf}
 + "creid" + {&delim-par} + "Создал" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-s-coeff:handle
                                            ,input  {&table_s-coeff}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* s-coeff-proc */

function get-node-code-name returns character ( input p-node-code as integer):
define variable v-prt-name as character no-undo .
v-prt-name = "(":U + string(p-node-code) + ")".
define buffer buf_gds-prt for ub.gds-prt.
find first buf_gds-prt no-lock where
          buf_gds-prt.node-code = p-node-code no-error.
if available buf_gds-prt then do:
  assign
  v-prt-name =  (if buf_gds-prt.f-name <> "":U
                then buf_gds-prt.f-name
                else buf_gds-prt.node-name) + "(":U + string(p-node-code) + ")"
  .

end.
return v-prt-name.
end function.


procedure bar-code-proc :
define output parameter p-description as character no-undo .
define buffer current_c-bar-code for ub.c-bar-code  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-bar-code no-lock where
               current_c-bar-code.gds-code = p-gds-code
           AND current_c-bar-code.b-code   = buf_c-gds-hist.b-code
           AND current_c-bar-code.chip-num = p-chip-num
           no-error .
    if not avail current_c-bar-code
    and buf_c-gds-hist.action = integer({&hn-rename})
    then do:
      find first current_c-bar-code no-lock where
                current_c-bar-code.gds-code = p-gds-code
            AND current_c-bar-code.chip-num = p-chip-num
            no-error .
    end.
    if not avail current_c-bar-code then do:
      v-mess = "Неверная ссылка на c-bar-code в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
&scop fields-name-list "b-code,cli-base-rate,cr-db-num,in-code,node-code,part-code,stts_,unit-cli"

define variable v-label-param as character no-undo .

v-label-param =
  "b-code" + {&delim-par} + "Баркод" + {&delim-par} + "" + {&delim-flf}
 + "cli-base-rate" + {&delim-par} + "Коэффициент" + {&delim-par} + "" + {&delim-flf}
 + "cr-db-num" + {&delim-par} + "Создан в БД №" + {&delim-par} + "" + {&delim-flf}
 + "in-code" + {&delim-par} + "ПН" + {&delim-par} + "" + {&delim-flf}
 + "node-code" + {&delim-par} + "узел шкалы (вн.№)" + {&delim-par} + "get-node-code-name" + {&delim-flf}
 + "part-code" + {&delim-par} + "№ партии" + {&delim-par} + "" + {&delim-flf}
 + "stts_" + {&delim-par} + "Статус" + {&delim-par} + "" + {&delim-flf}
 + "unit-cli" + {&delim-par} + "Ед.изм" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-bar-code:handle
                                            ,input  {&table_bar-code}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* bar-code-proc */

procedure bar-code-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-bar-code-attr for ub.c-bar-code-attr  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-bar-code-attr no-lock where
               current_c-bar-code-attr.gds-code = p-gds-code
           AND current_c-bar-code-attr.b-code   = buf_c-gds-hist.b-code
           AND current_c-bar-code-attr.chip-num = p-chip-num
           no-error .
    if not avail current_c-bar-code-attr
    and buf_c-gds-hist.action = integer({&hn-rename})
    then do:
      find first current_c-bar-code-attr no-lock where
                current_c-bar-code-attr.gds-code = p-gds-code
            AND current_c-bar-code-attr.chip-num = p-chip-num
            no-error .
    end.
    if not avail current_c-bar-code-attr then do:
      v-mess = "Неверная ссылка на c-bar-code-attr в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
&scop fields-name-list "b-code,attr-code,attr-value,gds-code"

run bc-attr_tooltip in this-procedure (
            input  string(current_c-bar-code-attr.attr-code)
            ,output v-tooltip
            ,output v-label
            ) no-error .
assign
p-description = "Атрибут" + {&space-char} + v-label
.

define variable v-label-param as character no-undo .

v-label-param =
  "b-code" + {&delim-par} + "Баркод" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Знач.атр-та" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + ""
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-bar-code-attr:handle
                                            ,input  {&table_bar-code-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* bar-code-attr-proc */


procedure prod-bc-proc :
define output parameter p-description as character no-undo .
define buffer current_c-prod-bc for ub.c-prod-bc  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-prod-bc no-lock where
               current_c-prod-bc.b-code   = buf_c-gds-hist.b-code
           AND current_c-prod-bc.b-str   = buf_c-gds-hist.b-str
           AND current_c-prod-bc.chip-num = p-chip-num
           no-error .
    if not avail current_c-prod-bc then do:
      v-mess = "Неверная ссылка на c-prod-bc в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    assign
    p-description = substitute("Баркод &1", current_c-prod-bc.b-str)
    .

&scop fields-name-list "b-str,bc-on,cr-db-num,bc-on-type"

define variable v-label-param as character no-undo .

v-label-param =
  "b-str" + {&delim-par} + "ДопБК" + {&delim-par} + "" + {&delim-flf}
 + "bc-on" + {&delim-par} + "Включен" + {&delim-par} + "" + {&delim-flf}
 + "cr-db-num" + {&delim-par} + "Создан в БД №" + {&delim-par} + "" + {&delim-flf}
 + "bc-on-type" + {&delim-par} + "Тип активности" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-prod-bc:handle
                                            ,input  {&table_prod-bc}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.
end procedure. /* prod-bc-proc */

procedure varianty-delivery-gds-obj-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-varianty-delivery-gds-obj for ub.c-varianty-delivery-gds-obj  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first curr_c-varianty-delivery-gds-obj no-lock where
               curr_c-varianty-delivery-gds-obj.gds-code = p-gds-code
           AND curr_c-varianty-delivery-gds-obj.chip-num = p-chip-num
           no-error .
    if not avail curr_c-varianty-delivery-gds-obj then do:
       v-mess = "Неверная ссылка на c-varianty-delivery-gds-obj в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.

&scop fields-name-list "cond-keep-code,deliv-subj-code,deliv-type-code,des,gr-per-val-code,sts"

define variable v-label-param as character no-undo .

v-label-param =
  "cond-keep-code" + {&delim-par} + "Код условия хранения" + {&delim-par} + "" + {&delim-flf}
 + "deliv-subj-code" + {&delim-par} + "Код субъекта доставки" + {&delim-par} + "" + {&delim-flf}
 + "deliv-type-code" + {&delim-par} + "Код типа доставки" + {&delim-par} + "" + {&delim-flf}
 + "des" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "gr-per-val-code" + {&delim-par} + "Код группы сроков хранения" + {&delim-par} + "" + {&delim-flf}
 + "sts" + {&delim-par} + "Статус" + {&delim-par} + ""  .

 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-varianty-delivery-gds-obj:handle
                                            ,input  {&table_varianty-delivery-gds-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* varianty-delivery-gds-obj-proc */

procedure gds-season-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-gds-season for ub.c-gds-season  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first curr_c-gds-season no-lock where
               curr_c-gds-season.gds-code = p-gds-code
           AND curr_c-gds-season.chip-num = p-chip-num
           no-error .
    if not avail curr_c-gds-season then do:
       v-mess = "Неверная ссылка на c-gds-season в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.

&scop fields-name-list "sea-code,min-stock"

define variable v-label-param as character no-undo .

v-label-param =
  "sea-code" + {&delim-par} + "Код сезона" + {&delim-par} + "" + {&delim-flf}
 + "min-stock" + {&delim-par} + "Минимальный запас" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-gds-season:handle
                                            ,input  {&table_gds-season}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* gds-season-proc */


procedure tax-rate-gds-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-old-rate-code like ub.tax-rate-gds.rate-code no-undo .
define variable v-old-fact-order like ub.tax-rate-gds.fact-order no-undo .
define variable v-old-fact-date as date no-undo .
define variable v-new-rate-code like ub.tax-rate-gds.rate-code no-undo .
define variable v-new-fact-order like ub.tax-rate-gds.fact-order no-undo .
define variable v-new-fact-date as date no-undo .
define buffer buf_next_tax-rate-gds for ub.tax-rate-gds.


define buffer buf_tax for ub.tax.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:


    find first buf_tax no-lock where
              buf_tax.tax-code = buf_c-gds-hist.tax-code no-error .
    if available buf_tax then do:
      assign
      p-description = buf_tax.tax-name.

    end.
    assign
    v-old-rate-code = buf_c-gds-hist.rate-code
    v-old-fact-order = buf_c-gds-hist.fact-order
    .
    run factord-to-date in this-procedure (
                                            input v-old-fact-order
                                           ,output v-old-fact-date) no-error .
    assign
    v-chg-fields = "rate-code,fact-date"
    .
    find first buf_next_tax-rate-gds no-lock where
            buf_next_tax-rate-gds.gds-code = p-gds-code
        AND buf_next_tax-rate-gds.host-code        = 0
        AND buf_next_tax-rate-gds.obj-type         = "":U
        AND buf_next_tax-rate-gds.obj-code         = 0
        AND buf_next_tax-rate-gds.tax-code         = buf_c-gds-hist.tax-code
        AND buf_next_tax-rate-gds.fact-order       > buf_c-gds-hist.fact-order no-error .
    if available buf_next_tax-rate-gds then do:
      assign
      v-new-rate-code = buf_next_tax-rate-gds.rate-code
      v-new-fact-order = buf_next_tax-rate-gds.fact-order
      .
      run factord-to-date in this-procedure (
                                              input v-new-fact-order
                                            ,output v-new-fact-date) no-error .
    end.

&scop fields-name-list "rate-code,fact-date"

&scop fields-label-list  "Код ставки,Начало действия"


  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, {&fields-name-list}).
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, {&fields-label-list})
    .

    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old = (if temp-changes.f_name = "rate-code"
                          then string(v-old-rate-code)
                          else string(v-old-fact-date, "99/99/9999")
                          )
    temp-changes.v_new = (if temp-changes.f_name = "rate-code"
                          then string(v-new-rate-code)
                          else string(v-new-fact-date, "99/99/9999")
                          )
    .
  end.
end.

end procedure. /* tax-rate-gds-proc */

procedure ass-matr-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-assortment-matrix-goods for ub.c-assortment-matrix-goods  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:


  find first curr_c-assortment-matrix-goods no-lock where
              curr_c-assortment-matrix-goods.gds-code        = p-gds-code
          AND curr_c-assortment-matrix-goods.chip-num        = p-chip-num
          no-error .
  if not avail curr_c-assortment-matrix-goods then do:
    v-mess = "Неверная ссылка на c-assortment-matrix-goods в таблице c-gds-hist".
    run err-mess in this-procedure ( input-output v-mess).
    return error v-mess.
  end.

&scop fields-name-list "asmg-status,asmg-des,asmt-id,db-num"

define variable v-label-param as character no-undo .

v-label-param =
  "asmg-status" + {&delim-par} + "Статус в а.матрице" + {&delim-par} + "" + {&delim-flf}
 + "asmg-des" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "asmt-id" + {&delim-par} + "Код матрицы" + {&delim-par} + "" + {&delim-flf}
 + "db-num" + {&delim-par} + "БД" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-assortment-matrix-goods:handle
                                            ,input  {&table_assortment-matrix-goods}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.
end procedure. /* assortment-matrix-goods-proc */

procedure izt-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-gds-obj-prop for ub.c-gds-obj-prop  .

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first curr_c-gds-obj-prop no-lock where
               curr_c-gds-obj-prop.gds-code        = p-gds-code
           AND curr_c-gds-obj-prop.chip-num        = p-chip-num
           no-error .
    if not avail curr_c-gds-obj-prop then do:
       v-mess = "Неверная ссылка на c-gds-obj-prop в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.

&scop fields-name-list "obj-type,obj-code,gdop-assort-min,gdop-igt,gdop-min-stock,grop-level-always-presence,grop-max-stock,grop-min-order"

define variable v-label-param as character no-undo .

v-label-param =
  "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "gdop-assort-min" + {&delim-par} + "Асс.минимум" + {&delim-par} + "" + {&delim-flf}
 + "gdop-igt" + {&delim-par} + "ИЖТ" + {&delim-par} + "" + {&delim-flf}
 + "gdop-min-stock" + {&delim-par} + "Мин.остаток" + {&delim-par} + "" + {&delim-flf}
 + "grop-level-always-presence" + {&delim-par} + "Уровень постоян.присут." + {&delim-par} + "" + {&delim-flf}
 + "grop-max-stock" + {&delim-par} + "Макс.остаток" + {&delim-par} + "" + {&delim-flf}
 + "grop-min-order" + {&delim-par} + "Мин.заказ" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-gds-obj-prop:handle
                                            ,input  {&table_gds-obj-prop}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* gds-obj-prop-proc */

procedure pl-gds-proc :
define output parameter p-description as character no-undo .
define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_c-pl-gds for ub.c-pl-gds  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-pl-gds no-lock where
               curr_c-pl-gds.gds-code = p-gds-code
           AND curr_c-pl-gds.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-pl-gds.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-pl-gds then do:
      v-mess = "Неверная ссылка на c-pl-gds в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
&scop fields-name-list "max-qnty,obj-code,obj-type,pl-code,PS,status_,tolerance"

&scop fields-label-list  "Максимальное количество,Код объекта учета,Тип объекта,Код складского места,Примечание,Статус,Допустимое отклонение"

define variable v-label-param as character no-undo .

v-label-param =
  "gdop-assort-min" + {&delim-par} + "Асс.минимум" + {&delim-par} + "" + {&delim-flf}
 + "gdop-igt" + {&delim-par} + "ИЖТ" + {&delim-par} + "" + {&delim-flf}
 + "gdop-min-stock" + {&delim-par} + "Мин.остаток" + {&delim-par} + "" + {&delim-flf}
 + "grop-level-always-presence" + {&delim-par} + "Уровень постоян.присут." + {&delim-par} + "" + {&delim-flf}
 + "grop-max-stock" + {&delim-par} + "Макс.остаток" + {&delim-par} + "" + {&delim-flf}
 + "grop-min-order" + {&delim-par} + "Мин.заказ" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pl-gds:handle
                                            ,input  {&table_pl-gds}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* pl-gds-proc */


procedure pl-gds-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-pl-gds-attr for ub.c-pl-gds-attr  .
define buffer buf_c-table-bind for ub.c-table-bind.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first current_c-pl-gds-attr no-lock where
               current_c-pl-gds-attr.gds-code = p-gds-code
           AND current_c-pl-gds-attr.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND current_c-pl-gds-attr.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail current_c-pl-gds-attr then do:
      v-mess = "Неверная ссылка на c-pl-gds-attr в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

    run plgdattr-tooltip in this-procedure (
                input  current_c-pl-gds-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
&scop fields-name-list "attr-code,attr-value"

define variable v-label-param as character no-undo .

v-label-param =
  "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-pl-gds-attr:handle
                                            ,input  {&table_pl-gds-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.
end procedure. /* pl-gds-attr-proc */


procedure pl-gds-pump-proc :
define output parameter p-description as character no-undo .

define buffer buf_c-table-bind for ub.c-table-bind.

define buffer curr_c-pl-gds-pump for ub.c-pl-gds-pump  .



do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
       v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    find first curr_c-pl-gds-pump no-lock where
               curr_c-pl-gds-pump.gds-code = p-gds-code
           AND curr_c-pl-gds-pump.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-pl-gds-pump.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-pl-gds-pump then do:
       v-mess = "Неверная ссылка на c-pl-gds-pump в таблице c-table-bind".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
&scop fields-name-list "obj-code,obj-type,pl-code,PS,pump-code,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-code" + {&delim-par} + "Код скласдкого места" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par} + "" + {&delim-flf}
 + "pump-code" + {&delim-par} + "Номер ТРК" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-pl-gds-pump:handle
                                            ,input  {&table_pl-gds-pump}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).
end.

end procedure. /* pl-gds-pump-proc */

procedure dis-gds-rule-proc :
define output parameter p-description as character no-undo .
define variable v-label as character no-undo .

define buffer current_c-dis-gds-rule for ub.c-dis-gds-rule  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first current_c-dis-gds-rule no-lock where
               current_c-dis-gds-rule.gds-code = p-gds-code
           AND current_c-dis-gds-rule.chip-num = p-chip-num 
           no-error .
    if not avail current_c-dis-gds-rule then do:
       v-mess = "Неверная ссылка на c-dis-gds-rule в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    run disgdsru-name in this-procedure (
                input  current_c-dis-gds-rule.templ-rl-root
                ,output v-label
                ) no-error .
    assign
    p-description = substitute("Тип скидки &1", v-label)
    .

&scop fields-name-list "rule-num,pos-type,templ-rl-root,discnt-role,time-templ-rl-root"

define variable v-label-param as character no-undo .

v-label-param =
  "rule-num" + {&delim-par} + "Номер правила скидки" + {&delim-par} + "" + {&delim-flf}
 + "pos-type" + {&delim-par} + "Место использ." + {&delim-par} + "" + {&delim-flf}
 + "templ-rl-root" + {&delim-par} + "Шаблон скидки" + {&delim-par} + "disgdsru-get-disc-label" + {&delim-flf}
 + "discnt-role" + {&delim-par} + "Тип скидки" + {&delim-par} + "disgdsru-get-disc-role-label" + {&delim-flf}
 + "time-templ-rl-root" + {&delim-par} +  "Тип расписания" + {&delim-par} +  "":U
 .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-dis-gds-rule:handle
                                            ,input  {&table_dis-gds-rule}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


end.

end procedure. /* dis-gds-rule-proc */

procedure ext-artic-proc :
define output parameter p-description as character no-undo .
define buffer current_c-ext-artic for ub.c-ext-artic.
define buffer buf_clients         for ub.clients.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:


  if buf_c-gds-hist.action <> integer({&hn-delete}) then do:

    find first current_c-ext-artic no-lock  where
           current_c-ext-artic.gds-code = buf_c-gds-hist.gds-code
        and current_c-ext-artic.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
        and current_c-ext-artic.chip-num = buf_c-gds-hist.chip-num
    no-error .
    if not available current_c-ext-artic then do:
      v-mess = "Неверная ссылка на c-ext-artic в таблице c-gds-hist"  .
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .

&scop fields-name-list "ext-artic,ps,status_"

v-label-param =
  "ext-artic" + {&delim-par} + "Внешний артикул" + {&delim-par} + "" + {&delim-flf}
 + "ps" + {&delim-par} + "Описание" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .

 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-ext-artic:handle
                                            ,input  {&table_ext-artic}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

    find first buf_clients no-lock
      where buf_clients.obj-type = current_c-ext-artic.cli-type
        and buf_clients.obj-code = current_c-ext-artic.cli-code
    no-error .
    assign
      p-description = substitute( "Внешний артикул &1/&2 '&3'"
                                , current_c-ext-artic.cli-code
                                , current_c-ext-artic.cli-type
                                , if available buf_clients then
                                    buf_clients.obj-name
                                  else
                                    "":U
                                )
    .
  end.

end.

end procedure. /* ext-artic-proc */

procedure sert-join-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .
define variable v-field-list as character no-undo .

define buffer curr_sert-join   for ub.sert-join  .
define buffer curr_c-sert for ub.c-sert  .
define buffer new_c-sert  for ub.c-sert  .
define buffer buf_c-table-bind for ub.c-table-bind.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
  find first curr_c-sert no-lock where
            curr_c-sert.b-code        = buf_c-gds-hist.b-code
        AND curr_c-sert.corr-user-db-num = buf_c-table-bind.corr-user-db-num
        AND curr_c-sert.chip-num        = buf_c-table-bind.chip-num-src   no-error .
  if not avail curr_c-sert then do:
    v-mess = "Неверная ссылка на c-sert-join в таблице c-gds-hist".
    run err-mess in this-procedure ( input-output v-mess).
    return error v-mess.
  end.
  find first new_c-sert no-lock where
              new_c-sert.b-code = buf_c-gds-hist.b-code
          AND new_c-sert.cli-type = curr_c-sert.cli-type
          AND new_c-sert.cli-code = curr_c-sert.cli-code
          AND new_c-sert.sert-code = curr_c-sert.sert-code
          AND new_c-sert.chip-num > p-chip-num
          no-error.
  if not available new_c-sert then do:
    find first curr_sert-join no-lock where
                curr_sert-join.b-code = buf_c-gds-hist.b-code
            AND curr_sert-join.cli-type  = curr_c-sert.cli-type
            AND curr_sert-join.cli-code  = curr_c-sert.cli-code
            AND curr_sert-join.sert-code = curr_c-sert.sert-code
            no-error.
    if not available curr_sert-join then do:
        return error.
    end.
    buffer-compare curr_sert-join to curr_c-sert
    case-sensitive
    save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_c-sert
    except chip-num corr-date corr-user-name corr-user-db-num corr-time
    to curr_c-sert
    case-sensitive
    save result in v-chg-fields.
  end.

&scop fields-name-list "b-code,cli-code,cli-type,sert-code"

&scop fields-label-list  "Бар-код,Код контрагента,Тип контрагента,№ сертификата"

&scop fields-function-list ",,,"


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
    temp-changes.v_old = (if buf_c-gds-hist.action = integer({&hn-create})
                          then "":U
                          else string(buffer curr_c-sert:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new =  (if available new_c-sert
                                then string(buffer new_c-sert:buffer-field(v-field-name):buffer-value)
                                else string(buffer curr_sert-join:buffer-field(v-field-name):buffer-value)
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

end procedure. /* sert-join-proc */


procedure recipe-gds-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .


define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_recipe-gds for ub.recipe-gds  .
define buffer curr_c-recipe-gds for ub.c-recipe-gds  .
define buffer new_c-recipe-gds for ub.c-recipe-gds  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-recipe-gds no-lock where
               curr_c-recipe-gds.gds-code = p-gds-code
           AND curr_c-recipe-gds.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-recipe-gds.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-recipe-gds then do:
      v-mess = "Неверная ссылка на c-recipe-gds в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first new_c-recipe-gds no-lock where
                new_c-recipe-gds.gds-code = buf_c-gds-hist.gds-code
            AND new_c-recipe-gds.chip-num > buf_c-table-bind.chip-num-src
            AND new_c-recipe-gds.corr-user-db-num = buf_c-table-bind.corr-user-db-num  no-error.
    if not available new_c-recipe-gds then do:
        find first curr_recipe-gds no-lock where
                    curr_recipe-gds.gds-code = buf_c-gds-hist.gds-code
                no-error.
        if not available curr_recipe-gds then do:
            return error.
        end.
        buffer-compare curr_recipe-gds to curr_c-recipe-gds
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-recipe-gds except chip-num corr-date corr-user-name corr-user-db-num corr-time
        to curr_c-recipe-gds
        case-sensitive
        save result in v-chg-fields.
    end.

&scop fields-name-list "artic,brutto-qnty,calc-method,coeff-waste,is-waste,proc-number,prod-code,prod-type,qnty,recipe-code"


&scop fields-label-list  "Артикул,Кол-во брутто,Метод расчета брутто,Коэфф.отходов,Флаг ОТХОДЫ,Пор.№ при обработке,Код пр-ля,Тип пр-ля,Кол-во по рецепту,Номер рецепта"

&scop fields-function-list ",,,,,,,,,"


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
    temp-changes.v_old = (if v-is-created
                          then "":U
                          else string(buffer curr_c-recipe-gds:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-recipe-gds
                          then string(buffer new_c-recipe-gds:buffer-field(v-field-name):buffer-value)
                          else string(buffer curr_recipe-gds:buffer-field(v-field-name):buffer-value)
                          )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.

end procedure. /* recipe-gds-proc */

procedure recipe-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-function as character no-undo .
define variable jj as integer no-undo .
define variable v-field-label  as character no-undo .


define buffer buf_c-table-bind for ub.c-table-bind.
define buffer curr_recipe for ub.recipe  .
define buffer curr_c-recipe for ub.c-recipe  .
define buffer new_c-recipe for ub.c-recipe  .


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

    find first buf_c-table-bind no-lock where
              buf_c-table-bind.corr-user-db-num = buf_c-gds-hist.corr-user-db-num
          AND buf_c-table-bind.tbl-name-rec     = {&table_c-gds-hist}
          AND buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num no-error .
    if not available buf_c-table-bind then do:
      v-mess = "Неверная ссылка на c-table-bind в таблице c-gds-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first curr_c-recipe no-lock where
               curr_c-recipe.gds-code = p-gds-code
           AND curr_c-recipe.corr-user-db-num = buf_c-table-bind.corr-user-db-num
           AND curr_c-recipe.chip-num = buf_c-table-bind.chip-num-src  no-error .
    if not avail curr_c-recipe then do:
      v-mess = "Неверная ссылка на c-recipe в таблице c-table-bind".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    find first new_c-recipe no-lock where
                new_c-recipe.gds-code = buf_c-gds-hist.gds-code
            AND new_c-recipe.chip-num > buf_c-table-bind.chip-num-src
            AND new_c-recipe.corr-user-db-num = buf_c-table-bind.corr-user-db-num  no-error.
    if not available new_c-recipe then do:
        find first curr_recipe no-lock where
                    curr_recipe.gds-code = buf_c-gds-hist.gds-code
                no-error.
        if not available curr_recipe then do:
            return error.
        end.
        buffer-compare curr_recipe to curr_c-recipe
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-recipe except chip-num corr-date corr-user-name corr-user-db-num corr-time
        to curr_c-recipe
        case-sensitive
        save result in v-chg-fields.
    end.

&scop fields-name-list "host-code,obj-code,obj-type,portion-qnty,portion-weight,recipe-design,recipe-name,recipe-order,~
recipe-quality,recipe-ref-num,recipe-technique,recipe-template,recipe-type,sale-factor,artic,brutto-qnty,prod-code,~
prod-type,qnty,recipe-code"


&scop fields-label-list  "Фирма,Код объекта,Тип объекта,Кол-во порций,Вес порции,Способ оформления,Название,Порядок при обработке,~
Показатели качества,Номер в справочнике рецептур,Технология,Ссылка на спр.рецептур,Тип рецепта,Кратность при продаже,~
Артикул,Кол-во брутто,Код пр-ля,Тип пр-ля,Кол-во по рецепту,Номер рецепта"

&scop fields-function-list ",,,,,,,,,,,,,,,,,,,"


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
    temp-changes.v_old = (if v-is-created
                          then "":U
                          else string(buffer curr_c-recipe:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-recipe
                          then string(buffer new_c-recipe:buffer-field(v-field-name):buffer-value)
                          else string(buffer curr_recipe:buffer-field(v-field-name):buffer-value)
                          )
    .
    if v-field-function <> '':U then do:
      assign
      temp-changes.v_old = DYNAMIC-function(v-field-function, temp-changes.v_old)
      temp-changes.v_new = DYNAMIC-function(v-field-function, temp-changes.v_new)
      .
    end.
  end.
end.

end procedure. /* recipe-proc */


define temp-table temp-goods no-undo like ub.goods.
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

    create temp-goods.
    buffer-copy buf_c-gds-hist to temp-goods.
    run gen-key-rec in this-procedure ( input {&table_goods}
                                       ,input (buffer temp-goods:handle)
                                       ,output v-uniq-key-rec).
    delete temp-goods.
    find first curr_c-ext-classif no-lock where
               curr_c-ext-classif.classif-subject = {&table_ext-classif}
           and curr_c-ext-classif.uniq-key-rec = v-uniq-key-rec
           AND curr_c-ext-classif.chip-num = p-chip-num
           no-error .
    if not avail curr_c-ext-classif then do:
       v-mess = "Неверная ссылка на c-ext-classif в таблице c-gds-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.

case curr_c-ext-classif.classif-name:
   when {&extclass_goods_accor} then do:
&scop fields-name-list "key#_one"
   assign
   v-label-param = "key#_one" + {&delim-par} + "Код топлива " + {&delim-par} + ""
   p-description = "Классификатор АККОР"
   .
  end.
end case.
MESSAGE 
VIEW-AS ALERT-BOX.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-ext-classif:handle
                                            ,input  {&table_ext-classif}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).




end.

end procedure. /* ext-classif */
procedure gds-obj-prop-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-gds-obj-prop-attr for ub.c-gds-obj-attr . /*!!!!!!
это не ошибка - там таблицы истории нет - пишем в чужую!!!
*/


do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

find first current_c-gds-obj-prop-attr no-lock where
            current_c-gds-obj-prop-attr.gds-code = p-gds-code
        AND current_c-gds-obj-prop-attr.chip-num = p-chip-num
        AND current_c-gds-obj-prop-attr.attr-code = buf_c-gds-hist.attr-code
        no-error .

define variable v-label-param as character no-undo .

&scop fields-name-list "obj-type,obj-code,attr-code,gds-code,attr-value"

v-label-param =
  "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "attr-code" + {&delim-par} + "Атрибут" + {&delim-par} + "" + {&delim-flf}
 + "gds-code" + {&delim-par} + "Код товара" + {&delim-par} + "" + {&delim-flf}
 + "attr-value" + {&delim-par} + "Значение атрибута" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-gds-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-gds-hist.action = integer({&hn-delete}))
                                            ,input  buffer current_c-gds-obj-prop-attr:handle
                                            ,input  {&table_gds-obj-prop-attr}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

    run gdspoatr-tooltip in this-procedure (
                input  current_c-gds-obj-prop-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + {&space-char} + v-label
    .
end.

end procedure. /* gds-obj-prop-attr-proc */


PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =  substitute("История товара с кодом &1: щепка &2 Предмет изменений &3&4&5"
                            ,p-gds-code
                            ,p-chip-num
                            ,p-subject
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
