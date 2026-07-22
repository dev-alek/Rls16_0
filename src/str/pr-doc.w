/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формирование приказа переоценки

Автор: Чернова Светлана Александровна
Дата создания: 30.01.95
Author: Svetlana Chernova
Creation date: 30.01.95


1author: Исаков Андрей Валерьевич

*/


&scop window-name d-pr-doc
&scop frame-name d-pr-doc

/* ***************************  definitions  ************************** */
define input        parameter parParentProc    as widget-handle no-undo.
define input-output parameter doc-rec          as recid     no-undo .
define input        parameter doc-mode         as character no-undo .
define input-output parameter next-prev        as logical   no-undo .


define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Формирование приказа переоценки".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }

define variable g#log     as logical   no-undo .
define variable gds-rec   as recid     no-undo .
define variable line-rec  as recid     no-undo .
define variable line-mode as character no-undo .
define variable notes     as character no-undo .
define variable rep-rec   as recid     no-undo .
define variable ref-rec   as recid     no-undo .
define variable list-mode as character no-undo .
define variable lns-cnt   as integer   no-undo .
define variable g#stat    as character no-undo .
define variable v-qqq     as logical   no-undo .
define variable v-str     as character no-undo .
{ cmp/library.i  }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }
{ cmp/gds-list.i gds-list def "new shared" }

{ gbl/color.i    }
{ cmp/croslist.i }
{ gbl/clntattr.i }
{ str/hvrdtax.i  }
{ str/in-vatp.i  def }
{ str/out-vatp.i def }
{ ref/grpobj.i   }
{ ref/gdsoattr.i }
{ trg/check-bc.i }
{ str/alt-calc.i func-befor }
{ str/alt-calc.i "ver-modificator-price-is-null" }
{ str/doc-code.i }
{ str/libbcrcn.i }
{ str/pr-lattr.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i get  }
{ str/getctxtp.i get  }

{ str/alt-calc.i func }
{ str/alt-calc.i proc }
{ str/lvldsc.i       }
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.

define variable view-text as character no-undo .

define buffer prev-list         for ub.price-list.     /* для расчета процентов и вывода в список старой цены  */
define buffer buff-price-list-a for ub.price-list.     /* для поиска пред переоценки и вызова prl-vat */
define buffer cli-buf           for ub.clients.        /* для gds-list.i */

define variable arg-price  like ub.price-list.price-sale no-undo. /* для вывода в список исходной цены  */
define variable arg-pc     as decimal                    no-undo. /* для вывода в список % новой к исходной цене  */
define variable old-price  like ub.price-list.price-sale no-undo. /* для вывода в список старой цены  */
define variable old-pc     as decimal                    no-undo. /* для вывода в список % новой к старой цене  */
define variable f-cost-pc  as decimal                    no-undo. /* для вывода в список % новой к старой цене  */
define variable f-pr-pc    as decimal                    no-undo. /* для вывода в список % новой к старой цене  */
define variable f-cost     like ub.price-list.price-sale no-undo. /* для вывода в список учетной к новой  */
define variable f-pr       like ub.price-list.price-sale no-undo. /* для вывода в список приходной к новой */

define variable calc-dtl   as character                  no-undo. /* для вывода в список детализации */
define variable calc-name  as character format "x(48)"   no-undo. /* для вывода в список названия */
define variable root-price like ub.price-list.price-sale no-undo. /* для передачи цены в шкалу */
define variable ref-list   as character                  no-undo.
define variable sort-clmn-name as character              no-undo.
define variable p-list     as character                  no-undo.

define new shared temp-table temp-gds-list no-undo
field gds-code  like ub.goods.gds-code
field node-code like ub.gds-prt.node-code
field n-n as decimal
index pi is unique primary gds-code node-code .

define variable new-pr-recid as recid no-undo .
define variable v-n-n as decimal no-undo .


define variable cost-base     as decimal no-undo.   /* для вызова g d savrg . p */
define variable cost-rubl     as decimal no-undo.   /* для вызова g d savrg . p */
define variable v-price-base  as decimal no-undo.   /* для вызова g d snova t . p */
define variable v-price-rubl  as decimal no-undo.   /* для вызова g d snova t . p */
define variable tt-price-sale as decimal no-undo.   /* для вызова g d snova t . p */
define variable cur-rt-base   as decimal no-undo.   /* для вызова g d snova t . p */
define variable cur-rt-rubl   as decimal no-undo.   /* для вызова g d snova t . p */
define variable tt-price-prodwihvat as decimal no-undo.   /* для вызова g d s n o v a t . p */
define variable tt-prod-vat         as decimal no-undo.   /* для вызова g d s n o v a t . p */


define variable obj-in-code  like ub.gds-obj.in-code   no-undo.   /* последний приход по фирме */
define variable obj-in-date  like ub.gds-obj.in-date   no-undo.   /* последний приход по фирме */

define variable varschartic  like ub.price-list.artic initial " " no-undo.

define shared variable br-handle as handle no-undo.
define shared buffer  p-doc for ub.price-doc.
define shared query br-docs for p-doc scrolling.
define variable tt-col as logical no-undo .

/* для дор налога */
define variable   rdtaxcdvalue  as character initial ? no-undo.
define variable   rdtaxcdtype   as character initial ? no-undo.
define variable   dor-nal       as character           no-undo.

define buffer buff-goods    for ub.goods.           /* для поиска  */
define buffer l-price-list  for ub.price-list.      /* для поиска  */
define buffer price-list-tt for ub.price-list.      /* для поиска  */
define query br-list for ub.price-list except, ub.bar-code, ub.goods, ub.gds-prt scrolling.

&scop label-clmn_1-br-list  'Тип'
&scop clmn_1-br-list ~
      if ub.gds-prt.upper-code = ub.goods.prt-root then ~
        if ub.bar-code.in-code = '' then ~
          {&goods} ~
        else ~
          {&part} ~
      else ~
        {&property}
&scop label-clmn_2-br-list  'Код'
&scop clmn_2-br-list ub.bar-code.b-code 
&scop label-clmn_3-br-list  'Артикул'
&scop clmn_3-br-list ub.price-list.artic
&scop label-clmn_4-br-list  'Название'
&scop clmn_4-br-list ~
      if ub.gds-prt.upper-code = ub.goods.prt-root then ~
        if ub.bar-code.in-code = '' then ~
          ub.goods.gds-name ~
        else ~
           ub.bar-code.part-code  + '  ПН ' + ub.bar-code.in-code ~
      else ~
        '    ' + ub.gds-prt.f-name
&scop label-clmn_5-br-list  'Новая цена'
&scop clmn_5-br-list        ub.price-list.price-sale
&scop label-clmn_6-br-list  'Старая'
&scop clmn_6-br-list        fnc-old-price (buffer ub.price-list)
&scop label-clmn_7-br-list  '%.'
&scop clmn_7-br-list        fnc-old-pc  (buffer ub.price-list)
&scop label-clmn_8-br-list  'Исходная'
&scop clmn_8-br-list        fnc-arg-price (buffer ub.price-list)
&scop label-clmn_9-br-list  '%'
&scop clmn_9-br-list        fnc-arg-pc (buffer ub.price-list)
&scop label-clmn_10-br-list 'Расчет'
&scop clmn_10-br-list       ub.price-list.calc-method
&scop label-clmn_11-br-list 'Количество'
&scop clmn_11-br-list       ub.price-list.doc-qnty
&scop label-clmn_12-br-list 'Изм'
&scop clmn_12-br-list       ub.goods.unit-base

&scop clmn_13-br-list       ub.price-list.road-tax
&scop label-clmn_14-br-list 'Акциз'
&scop clmn_14-br-list       ub.price-list.excise
&scop label-clmn_15-br-list 'Н'
&scop clmn_15-br-list       fnc-alt-pr (buffer ub.price-list)

&scop label-clmn_16-br-list  'Учетная'
&scop clmn_16-br-list        fnc-cost (buffer ub.price-list)
&scop label-clmn_17-br-list  '%'
&scop clmn_17-br-list        fnc-cost-pc (buffer ub.price-list)
&scop label-clmn_18-br-list  'Приходная'
&scop clmn_18-br-list        fnc-pr (buffer ub.price-list)
&scop label-clmn_19-br-list  '%'
&scop clmn_19-br-list        fnc-pr-pc (buffer ub.price-list)
&scop label-clmn_20-br-list  '№п/п'
&scop clmn_20-br-list        ub.price-list.line-num


&scop num-locked-columns-br-list 5
&scop disp-list ~
{&clmn_15-br-list}  @ tt-col     column-label {&label-clmn_15-br-list} format "*/" ~
{&clmn_1-br-list}   @ calc-dtl   column-label {&label-clmn_1-br-list}  format "x(3)" ~
{&clmn_2-br-list}                column-label {&label-clmn_2-br-list}  format ">>>>>>>>>>>>>>>>9" ~
{&clmn_3-br-list}                column-label {&label-clmn_3-br-list}  format "x(16)" ~
{&clmn_4-br-list}   @ calc-name  column-label {&label-clmn_4-br-list}  format "x(47)" ~
{&clmn_5-br-list}                column-label {&label-clmn_5-br-list}  ~
{&clmn_6-br-list}   @ old-price  column-label {&label-clmn_6-br-list}  ~
{&clmn_7-br-list}   @ old-pc     column-label {&label-clmn_7-br-list}  format "->,>>9.<<" ~
{&clmn_8-br-list}   @ arg-price  column-label {&label-clmn_8-br-list}  ~
{&clmn_9-br-list}   @ arg-pc     column-label {&label-clmn_9-br-list}  format "->,>>9.<<" ~
{&clmn_16-br-list}  @ f-cost     column-label {&label-clmn_16-br-list} ~
{&clmn_17-br-list}  @ f-cost-pc  column-label {&label-clmn_17-br-list} format "->,>>9.<<" ~
{&clmn_18-br-list}  @ f-pr       column-label {&label-clmn_18-br-list} ~
{&clmn_19-br-list}  @ f-pr-pc    column-label {&label-clmn_19-br-list} format "->,>>9.<<" ~
{&clmn_10-br-list}               column-label {&label-clmn_10-br-list} format "x(20)" ~
{&clmn_11-br-list}               column-label {&label-clmn_11-br-list} format "->>,>>>,>>9.<<<" ~
{&clmn_12-br-list}               column-label {&label-clmn_12-br-list} format "x(3)" ~
{&clmn_13-br-list} ~
{&clmn_14-br-list}               column-label {&label-clmn_14-br-list} ~
{&clmn_20-br-list}               column-label {&label-clmn_20-br-list}



&scop enable-list ~
{&clmn_5-br-list} ~
{&clmn_14-br-list}

/*----------------------------functions---------------------------------*/
/* Учетная цена фактическая */
 function func-cost-price return decimal ( input  p-b-code  as integer ,
                                           input  p-gds-code as integer ,
                                           input  p-status_  as character ,
                                           input  p-r-b      as character) .
define variable f-price as decimal no-undo .
run proc-cost-price-fact in this-procedure (
      input  p-b-code   ,
      input  p-gds-code ,
      input  p-status_  ,
      input  p-r-b      ,
      output f-price    )
      .
return (f-price).
end function.


/* Неосновные цена */
function fnc-alt-pr return logical (buffer local-price-list for ub.price-list).
define variable f-log as logical no-undo .
define buffer o-price-list for ub.price-list.
define buffer o-goods      for ub.goods.
define buffer o-bar-code   for ub.bar-code.
define buffer b-bar-code   for ub.bar-code.

 f-log = false .

case local-price-list.main-price :
  when true  then do:
      for each o-price-list no-lock where
                o-price-list.doc-num    = local-price-list.doc-num and
                o-price-list.artic      = local-price-list.artic and
                o-price-list.prod-type  = local-price-list.prod-type and
                o-price-list.prod-code  = local-price-list.prod-code and
                o-price-list.price-type = '',
          each o-bar-code no-lock where
                o-bar-code.b-code = o-price-list.b-code,
          each o-goods no-lock where
                o-goods.gds-code = o-bar-code.gds-code and
                o-goods.unit-base <> o-bar-code.unit-cli :
                  f-log = true .
                  leave.
      end.
  end.
  otherwise  do:
      find first b-bar-code no-lock where
                  b-bar-code.b-code  = local-price-list.b-code  no-error .

      for each o-price-list no-lock where
                o-price-list.doc-num    = local-price-list.doc-num   and
                o-price-list.artic      = local-price-list.artic     and
                o-price-list.prod-type  = local-price-list.prod-type and
                o-price-list.prod-code  = local-price-list.prod-code and
                o-price-list.price-type = '',
          each o-bar-code no-lock where
                o-bar-code.b-code     = o-price-list.b-code and
                o-bar-code.node-code  = b-bar-code.node-code ,
          each o-goods no-lock where
                o-goods.gds-code   = o-bar-code.gds-code  and
                o-goods.unit-base <> o-bar-code.unit-cli  :
                  f-log = true .
                  leave.
      end.
  end.
end case.

return (f-log).

end function.

/* Исходная цена */
function fnc-arg-price return decimal (buffer local-price-list for ub.price-list).
  arg-price = local-price-list.price-calc.
  return (arg-price).
end function.

/* Процент Новой к Исходной  */
function fnc-arg-pc return decimal (buffer local-price-list for ub.price-list).
  arg-pc = (local-price-list.price-sale / local-price-list.price-calc - 1) * 100.
  if arg-pc > 9999 then
    arg-pc = ?. /* чтоб влезало в формат */
  return (arg-pc).
end function.
/* Цена Прошлой переоценки СТАРАЯ */
function fnc-old-price return decimal (buffer local-price-list for ub.price-list).
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
  { gbl/bcodeprc.i
    local-price-list.obj-type
    local-price-list.obj-code
    local-price-list.b-code
    0
    local-price-list.fact-order
    cur-dn
    cur-pr
    cur-rt
    cur-ex
    no-error }
  old-price = cur-pr.
  return (old-price).
end function.

/* Процент Новой к Старой  */

function fnc-old-pc return decimal (buffer local-price-list for ub.price-list).
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
  { gbl/bcodeprc.i
    local-price-list.obj-type
    local-price-list.obj-code
    local-price-list.b-code
    0
    local-price-list.fact-order
    cur-dn
    cur-pr
    cur-rt
    cur-ex
    no-error }
  old-pc = (local-price-list.price-sale / cur-pr - 1) * 100.
  if old-pc > 9999 then
    old-pc = ?. /* чтоб влезало в формат */

  return (old-pc).
end function.



/* ***********************  control definitions  ********************** */
define variable text-i as character   init "" no-undo .

define button b-exit auto-go
     label "&Выход":l
     size 6 by 1 tooltip "Выход из документа с сохранением состояния".


define button b-add
     label "&Добав":l
     size 8 by 1 tooltip "Добавление в переоценку цен на главные коды".


define button b-special
     label "&Осн.":l
     size 8 by 1 tooltip "Добавление в переоценку спеццен на основные коды (шкала, партии)".

define menu m-chg
       menu-item m-one-chg      label "Текущая строка -<<ctrl-o>>"
       menu-item m-lst-chg      label "Список товаров"
       .

define button b-chg
     label "Рас&чет":l
     size 8 by 1 tooltip "Пересчет цен в строке (строках)".

define menu m-del
       menu-item m-one-del      label "Текущая строка"
       menu-item m-lst-del      label "Список товаров"
       .

define button b-del
     label "&Удал":l
     size 8 by 1 tooltip "Удаление строк из переоценки".


define button b-alt
     label "Н&еосн.":l
     size 8 by 1 tooltip "Добавление скидок и цен на неосновные коды".

define button b-notes
     label "П&рим":l
     size 8 by 1 tooltip "Просмотр примечания к переоценке".

define button b-arch
     label "Учет":l
     size 8 by 1 tooltip "Просмотр учетной информации".

define button b-help
     label "Помо&щь":l
     size 8 by 1 tooltip "Помощь".

define button b-quest
     label "&?":l
     size 2 by .9 tooltip "Описание метода расчета".


define button b-history
     label "Ис&тор":l
     size 8 by 1 tooltip "История изменения переоценки".

define button b-calc
     label "Ит&оги":l
     size 14.88 by 1 tooltip "Расчет итогов по переоценке".

define button b-next auto-go
     label "&>>":l
     size 3 by 1 tooltip "Переход к просмотру следующей переоценки списка".

define button b-prev auto-go
     label "&<<":l
     size 3 by 1 tooltip "Переход к просмотру предыдущей переоценки списка".

/* --------------------- Суммы по строке -------------------------------------- */
define variable p-avrg as decimal format "->>,>>>,>>>,>>9.99" label "Цена учет."
view-as text size 12 by 0.79
tooltip "Текущая средняя учетная цена на объекте"
no-undo.

define variable p-avrg-fact as decimal format "->>,>>>,>>>,>>9.99" label "Цена Ср.Уч."
view-as text size 12 by 0.79
tooltip "Средняя учетная цена до момента закрытия переоценки на факт"
FGCOLOR 3
no-undo.


define variable p-last as decimal format "->>,>>>,>>>,>>9.99" label "Цена прих."
view-as text size 12 by 0.79
tooltip "Цена последней внешней ПН "
no-undo.


define variable p-new as decimal format "->>,>>>,>>>,>>9.99" label "Цена новая"
view-as text size 15 by 0.79
tooltip "Цена после переоценки"
fgcolor 4
no-undo.

define variable p-old as decimal format "->>,>>>,>>>,>>9.99" label "Цена старая"
view-as text size 12 by 0.79
tooltip "Цена до переоценки (Цена предыдущей переоценки)"
no-undo.

define variable p-pc-prev as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "На сколько изменилась цена после переоценки в процентах"
no-undo.

define variable p-pc-avrg as decimal format "->,>>9.<<<%":u label "Новая/Учет"
view-as text size 15 by 0.79
tooltip "Новая цена по отношению к учетной цене в процентах"
no-undo.

define variable p-pc-avrg-fact as decimal format "->,>>9.<<<%":u label "Новая/Ср.Уч"
view-as text size 15 by 0.79
tooltip "Новая цена по отношению к учетной цене(факт) в процентах"
FGCOLOR 3
no-undo.


define variable p-pc-last as decimal format "->,>>9.<<<%":u label "Новая/Прих"
view-as text size 15 by 0.79
tooltip "Новая цена по отношению к цене последнего прихода в процентах"
no-undo.

define variable p-op-avrg as decimal format "->,>>9.<<<%":u label "Старая/Учет"
view-as text size 12 by 0.79
tooltip "Старая цена по отношению к учетной цене в процентах"
no-undo.

define variable p-op-avrg-fact as decimal format "->,>>9.<<<%":u label "Старая/Ср.Уч"
view-as text size 11 by 0.79
tooltip "Старая цена по отношению к учетной цене(факт) в процентах"
FGCOLOR 3
no-undo.


define variable p-op-last as decimal format "->,>>9.<<<%":u label "Старая/Прих"
view-as text size 12 by 0.79
tooltip "Старая цена по отношению к цене последнего прихода в процентах"
no-undo.

define variable p-pc-op-avrg as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "Разница процентов (по отношению к учетной цене)"
no-undo.

define variable p-pc-op-avrg-fact as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "Разница процентов (по отношению к учетной цене(факт))"
FGCOLOR 3
no-undo.


define variable p-pc-op-last as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "Разница процентов (по отношению к цене последнего прихода)"
no-undo.

define variable p-calc-metod as char format  "x(17)"
view-as text size 17 by 1
tooltip "Метод расчета новой продажной цены товара"
no-undo.

/* --------------------- Итоги ------------------------------------------------ */
define variable s-new as decimal format "->>,>>>,>>>,>>9.99" label "Сумма новая"
view-as text size 15 by 0.79
tooltip "Сумма остатка после переоценки"
no-undo.

define variable s-old as decimal format "->>,>>>,>>>,>>9.99" label "Сумма старая"
view-as text size 13 by 0.79
tooltip "Сумма остатка до переоценки"
no-undo.

define variable s-new-old as decimal format "->>,>>>,>>>,>>9.99" label "Разница"
view-as text size 15 by 0.79
tooltip "Сумма документа (После переоценки - До переоценки)"
no-undo.

define variable pc-prev as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 8 by 0.79
tooltip "На сколько изменилась сумма остатка после переоценки в процентах"
no-undo.

define variable pc-avrg as decimal format "->,>>9.<<<%":u label "Новая/Учет"
view-as text size 15 by 0.79
tooltip "Новая сумма остатка по отношению к сумме в учетных ценах в процентах"
no-undo.

define variable pc-last as decimal format "->,>>9.<<<%":u label "Новая/Прих"
view-as text size 15 by 0.79
tooltip "Новая сумма остатка по отношению к сумме в ценах последнего прихода в процентах"
no-undo.

define variable op-avrg as decimal format "->,>>9.<<<%":u label "Старая/Учет"
view-as text size 14 by 0.79
tooltip "Старая сумма остатка по отношению к сумме в учетных ценах в процентах"
no-undo.

define variable op-last as decimal format "->,>>9.<<<%":u label "Старая/Прих"
view-as text size 14 by 0.79
tooltip "Старая сумма остатка по отношению к сумме в ценах последнего прихода в процентах"
no-undo.

define variable pc-op-avrg as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 15 by 0.79
tooltip "Разница процентов (по отношению к учетным ценам)"
no-undo.

define variable pc-op-last as decimal format "->,>>9.<<<%":u label "Разница"
view-as text size 15 by 0.79
tooltip "Разница процентов (по отношению к ценам последнего прихода)"
no-undo.

define button r-copy
     image-up file "btn-down-arrow"
     image-down file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88 tooltip " ".

define rectangle rect-line  edge-pixels 2 graphic-edge  no-fill    size 98.63 by 5.83.
define rectangle rect-tot  edge-pixels 2 graphic-edge  no-fill   size 98.63 by 3.08     fgcolor 0 .


define variable copy-type    as char
     view-as fill-in
     size 7 by 1 no-undo. /* тип и код объекта для копирования цены */
define variable copy-code    as integer
     view-as fill-in
     size 7 by 1 no-undo. /* тип и код объекта для копирования цены */
define variable doc-code     like ub.price-doc.doc-num       no-undo. /* код документа для копирования цены */
define variable common-price like ub.price-list.price-sale   no-undo. /* код документа для копирования цены */

define variable calc-method  as char
        format "x(12)" view-as combo-box inner-lines 18 list-items
        {&pr-calc-methods-inf}
        size 14 by 1

        /* label "Ис&ходная" */
        no-undo. /* способ расчета цены - исходная цена */
define variable increase-pc  as decimal
        label "На&ценка"
        format "->>>9.<<<%" view-as fill-in size 10.25 by 1  no-undo. /* процент наценки (с минусом - скидки)*/
define variable round-base   as decimal no-undo. /* база для округления / коэффициент */
define variable round-method as char
        format "x(15)" view-as combo-box inner-lines 7 list-items
        {&pr-round-9end},
        {&pr-round-9-99end},
        {&pr-round-integer},
        {&pr-round-select},
        {&pr-round-up},
        {&pr-round-coef},
        {&pr-round-off} size 15 by 1 bgcolor white_color
        label "Окру&гление"
        no-undo. /* способ округления */

define variable loc-art  as char  label "Нач.артик" format "x(16)" view-as fill-in size 14 by 1 fgcolor red_color no-undo .
define variable loc-name as char  label "Нач.назв." format "x(40)" view-as fill-in size 14 by 1 fgcolor red_color  no-undo.
define variable loc-code as char  label "Бар-код"   format "x(14)" view-as fill-in  size 14 by 1 fgcolor red_color  no-undo.
define variable conf-par     as char no-undo.    /* для чтения параметра конфигурации */
define variable par-type     as char no-undo.    /* тип параметра конфигурации */

define variable a-n-c as char view-as radio-set horizontal radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 10 by 1 no-undo.

define browse br-list query br-list no-lock
    display {&disp-list}
    enable {&enable-list}
    with
    size 98.38 by 12
    bgcolor white_color
    separators.


{&clmn_5-br-list} :label-fgcolor in browse br-list = blue_color .
{&clmn_14-br-list}:label-fgcolor in browse br-list = blue_color .

/*группа 1 */
old-price :label-fgcolor in browse br-list = 1 .
old-pc    :label-fgcolor in browse br-list = 1 .
/*группа 2 */
arg-price :label-fgcolor in browse br-list = 4 .
arg-pc    :label-fgcolor in browse br-list = 4 .
/*группа 3 */
f-cost    :label-fgcolor in browse br-list = 2 .
f-cost-pc :label-fgcolor in browse br-list = 2 .
/*группа 4 */
f-pr      :label-fgcolor in browse br-list = 5 .
f-pr-pc   :label-fgcolor in browse br-list = 5 .


&scop open-query-br-list ~
      open query br-list ~
        for each ub.price-list no-lock where ~
                 ub.price-list.doc-num = p-doc.doc-num and ~
                 ub.price-list.price-type = '', ~
            each ub.bar-code no-lock where ~
                 ub.bar-code.b-code = ub.price-list.b-code, ~
            each ub.goods no-lock where ~
                 ub.goods.gds-code = ub.bar-code.gds-code and ~
                 ub.goods.unit-base = ub.bar-code.unit-cli, ~
            each ub.gds-prt no-lock where ~
                 ub.gds-prt.node-code = ub.bar-code.node-code
/* ************************  frame definitions  *********************** */

define frame {&frame-name}
     b-exit at row 1 col 1
     b-prev at row 1 col 7
     b-next at row 1 col 10
     b-add at row 1 col 13
     b-del at row 1 col 21
     b-chg at row 1 col 29
     b-special at row 1 col 37
     b-alt at row 1 col 45
     b-history at row 1 col 53
     b-arch at row 1 col 61
     b-notes at row 1 col 69
     b-help at row 1 col 77
     a-n-c at row 1 col 85 no-label
     text-i view-as text size 8 by 1
          at row 2 col 1 no-label
     calc-method at row 2 col 7 colon-aligned no-label
     b-quest at row 2 col 23
     common-price at row 2 col 23 colon-aligned no-label
     doc-code at row 2 col 23 colon-aligned no-label
     copy-type at row 2 col 23 colon-aligned no-label
     copy-code at row 2 col 30 colon-aligned no-label
     r-copy at row 2 col 39
     increase-pc at row 2 col 50 colon-aligned
     round-method at row 2 col 73 colon-aligned
     round-base at row 2 col 87.63 colon-aligned no-label
     br-list at row 3.08 col 1
     loc-code at row 15.21 col 10 colon-aligned
     loc-name at row 15.21 col 10 colon-aligned
     loc-art  at row 15.21 col 10 colon-aligned

     b-calc at row 22.96 col 83.88
     p-old at row 16 col 39.75 colon-aligned
     p-new at row 16 col 63.75 colon-aligned
     p-pc-prev at row 16 col 87.75 colon-aligned

     p-avrg-fact       at row 17.42 col 13.88 colon-aligned
     p-op-avrg-fact    at row 17.42 col 39.88 colon-aligned
     p-pc-avrg-fact    at row 17.42 col 63.88 colon-aligned
     p-pc-op-avrg-fact at row 17.42 col 87.88 colon-aligned


     p-avrg at row 18.17 col 13.88 colon-aligned
     p-op-avrg at row 18.17 col 39.88 colon-aligned
     p-pc-avrg at row 18.17 col 63.88 colon-aligned
     p-pc-op-avrg at row 18.17 col 87.88 colon-aligned

     p-last at row 18.96 col 13.63 colon-aligned
     p-op-last at row 18.96 col 39.63 colon-aligned
     p-pc-last at row 18.96 col 63.63 colon-aligned
     p-pc-op-last at row 18.96 col 87.63 colon-aligned
     p-calc-metod at row 19.75 col 79   colon-aligned no-label
     obj-in-code at row 19.79 col 13.88 colon-aligned
     obj-in-date at row 19.79 col 39.88 colon-aligned
     prev-list.doc-num at row 19.79 col 63.88 colon-aligned
           label "Переоценка"
           view-as text
          size 13 by .67 tooltip "Номер переоценки, из которой была взята старая цена продажи"
     s-old at row 21.46 col 13.75 colon-aligned
     s-new at row 21.46 col 39.75 colon-aligned
     s-new-old at row 21.46 col 63.75 colon-aligned
     pc-prev at row 21.46 col 87.75 colon-aligned
     op-avrg at row 22.21 col 13.75 colon-aligned
     pc-avrg at row 22.21 col 39.75 colon-aligned
     pc-op-avrg at row 22.21 col 63.75 colon-aligned
     op-last at row 23.13 col 13.75 colon-aligned
     pc-last at row 23.13 col 39.75 colon-aligned
     pc-op-last at row 23.13 col 63.75 colon-aligned
     " Информация по строке" view-as text
          size 22 by .67 at row 15.29 col 37.5
          fgcolor 4
     rect-line AT ROW 15.13 COL 1
     rect-tot AT ROW 21.04 COL 1

     " Итоги по переоценке" view-as text
          size 20.63 by .67 at row 20.6 col 37.75
          fgcolor 4
     space(41.24) skip(2.91)
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "Приказ переоценки".

/* ***************  runtime attributes and uib settings  ************** */
assign
  frame {&frame-name}:scrollable = false
  br-list   :num-locked-columns in frame {&frame-name} = {&num-locked-columns-br-list}
  b-chg     :popup-menu in frame {&frame-name}         = menu m-chg  :handle
  b-chg     :menu-mouse                                = 1
  b-del     :popup-menu in frame {&frame-name}         = menu m-del  :handle
  b-del     :menu-mouse                                = 1
  .

br-list :set-repositioned-row (5, "always").
run str/pr-listv.p
    (input {&pr-calc-methods-inf-list} ,
     input {&pr-calc-fix},
     output p-list
     ) .
calc-method:list-items in frame {&frame-name}  = p-list .

/* ************************  control triggers  ************************ */

{ gbl/srt-clmn.i
&browse-name          = br-list
&frame-name           = {&frame-name}
&table-name           = "ub.price-list"
&ext-col              = 20
&start-column         = "{&num-locked-columns-br-list} + 1"
&label-clmn_1         = "{&label-clmn_1-br-list}"
&sort-clmn_1          = "{&clmn_1-br-list}"
&label-clmn_2         = "{&label-clmn_2-br-list}"
&sort-clmn_2          = "{&clmn_2-br-list}"
&label-clmn_3         = "{&label-clmn_3-br-list}"
&sort-clmn_3          = "{&clmn_3-br-list}"
&label-clmn_4         = "{&label-clmn_4-br-list}"
&sort-clmn_4          = "{&clmn_4-br-list}"
&label-clmn_5         = "{&label-clmn_5-br-list}"
&sort-clmn_5          = "{&clmn_5-br-list}"
&label-clmn_6         = "{&label-clmn_6-br-list}"
&sort-clmn_6          = "{&clmn_6-br-list}"
&label-clmn_7         = "{&label-clmn_7-br-list}"
&sort-clmn_7          = "{&clmn_7-br-list}"
&label-clmn_8         = "{&label-clmn_8-br-list}"
&sort-clmn_8          = "{&clmn_8-br-list}"
&label-clmn_9         = "{&label-clmn_9-br-list}"
&sort-clmn_9          = "{&clmn_9-br-list}"
&label-clmn_10        = "{&label-clmn_10-br-list}"
&sort-clmn_10         = "{&clmn_10-br-list}"
&label-clmn_11        = "{&label-clmn_11-br-list}"
&sort-clmn_11         = "{&clmn_11-br-list}"
&label-clmn_12        = "{&label-clmn_12-br-list}"
&sort-clmn_12         = "{&clmn_12-br-list}"
&label-clmn_13        = "dor-nal"
&sort-clmn_13         = "{&clmn_13-br-list}"
&label-clmn_14        = "{&label-clmn_14-br-list}"
&sort-clmn_14         = "{&clmn_14-br-list}"
&label-clmn_15        = "{&label-clmn_15-br-list}"
&sort-clmn_15         = "{&clmn_15-br-list} descending"
&label-clmn_16        = "{&label-clmn_16-br-list}"
&sort-clmn_16         = "{&clmn_16-br-list}"
&label-clmn_17        = "{&label-clmn_17-br-list}"
&sort-clmn_17         = "{&clmn_17-br-list}"
&label-clmn_18        = "{&label-clmn_18-br-list}"
&sort-clmn_18         = "{&clmn_18-br-list}"
&label-clmn_19        = "{&label-clmn_19-br-list}"
&sort-clmn_19         = "{&clmn_19-br-list}"
&label-clmn_20        = "{&label-clmn_20-br-list}"
&sort-clmn_20         = "{&clmn_20-br-list}"
&before-sort          = " "
&open-query           = "{&open-query-br-list} by ~{&sort-clmn_~{&clmn_num~}~}."
&open-query-otherwise = "{&open-query-br-list} by ub.price-list.artic by ub.gds-prt.node-code ."
&re-move-clmn         = "yes"
&mv-brw-default       = "no"
&sort-column-name     = "sort-clmn-name"
}

{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-calc }
{ gbl/hot-key.i b-del }

{ gbl/f2.i br-list br-list  ub.goods  parParentProc }

&global-define store-type    v-cntxt-obj-type
&global-define store-code    v-cntxt-obj-code
&global-define parparentproc parParentProc

{ str/sch-line.i price-list br-list }
end.

/* отключаем ненужные триггеры */
on find of ub.goods do: end.
on find of ub.gds-obj do: end.

on mouse-select-dblclick of br-list in frame {&frame-name}
do:
define variable stp-cycl as logical no-undo .
define variable t-r as recid no-undo .
line-mode = {&update} .
  if avail ub.price-list then do:
     t-r = recid( ub.price-list).
     if calc-method =  {&pr-calc-no} then do:
        g#log =  session:SET-WAIT-STATE("") .
        run str/pr-form.w (
                      input  parParentProc ,
                      input  line-mode   ,
                      input  doc-rec    ,
                      input t-r,
                      input increase-pc ,
                      input round-method,
                      input round-base,
                      input calc-method,
                      output stp-cycl ) .
         g#log = br-list:REFRESH( )  in frame {&frame-name}.
         apply "value-changed" to br-list in frame {&frame-name}.
         reposition br-list to recid t-r no-error.
     end.
  end.
end.

on end-error of ub.price-list.price-sale, ub.price-list.road-tax, ub.price-list.excise in browse br-list do:
  display {&disp-list} with browse br-list no-error .
  return no-apply.
end.

/* вывод строки в список */
on row-display of br-list do:
  if sort-clmn-name <> "calc-dtl" /*:handle in browse br-list*/ then
    /* сортировка по 1 столбцу не включена - раскрашиваем */
    if ub.gds-prt.upper-code = ub.goods.prt-root then
      if ub.bar-code.in-code = '' then
        calc-dtl :fgcolor in browse br-list = black_color.
      else
        calc-dtl :fgcolor in browse br-list = blue_color.
    else
      calc-dtl :fgcolor in browse br-list = dark_green_color.

end.
on entry of br-list in frame {&frame-name} do:
  run value-changed-br-list in this-procedure .
end.
on value-changed of br-list in frame {&frame-name} do:
  run value-changed-br-list in this-procedure .
end.

on leave of ub.price-list.price-sale in browse br-list or
   leave of ub.price-list.road-tax   in browse br-list or
   leave of ub.price-list.excise     in browse br-list do:
  if not available ub.price-list then
    return.
  if decimal  (ub.price-list.price-sale :screen-value in browse br-list) <> round(ub.price-list.price-sale,2)   or
     decimal  (ub.price-list.road-tax   :screen-value in browse br-list) <> round(ub.price-list.road-tax,2)    or
     decimal  (ub.price-list.excise     :screen-value in browse br-list) <> round(ub.price-list.excise,2) then do :
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons yes-no update g#log.
    if g#log then
      run upd-br-field in this-procedure .
  end.
  /* в случае, если подтвердили, перевыводится уже новое значение;
     если нет - выводится старое и последующий assign (внутренний) перезапишет старое */
  display {&disp-list} with browse br-list no-error .
  apply "value-changed" to br-list in frame {&frame-name}.
end.

on ctrl-o of br-list in frame {&frame-name}
or  ctrl-j of br-list in frame {&frame-name}
do:
      if b-chg :sensitive then
      if input frame {&frame-name} increase-pc < - 100 then do:
        message "Наценка не может быть меньше - 100 % !"
                view-as alert-box error.
        apply "entry" to br-list in frame {&frame-name}.
        return no-apply.
      end.
      if not available ub.price-list then do:
        message "Неправильно выбрана строка."
                view-as alert-box error.
        return no-apply.
      end.
      line-rec = recid (ub.price-list).
      run calc-pr-list in this-procedure
                       (input ub.price-list.b-code,
                        input p-doc.doc-num,
                        input calc-method,
                        input increase-pc,
                        input round-method,
                        input round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output line-rec) no-error.
      if error-status:error then
        next.
      if line-rec = recid (ub.price-list) then do:
        /* ни одна цена, кроме текущей, не пересчитывалась - можно выводить 1 строку */
        display {&disp-list} with browse br-list no-error .
        end.
      else do:
        run open-br in this-procedure .
        run upd-br-field in this-procedure .
        /* пересчитывались еще и спеццены - нужно выводить весь browse */
      end.

        g#log = br-list:select-next-row ().
        run upd-disp-tot in this-procedure ("clear"). /* показываем итоги с вопросительными знаками */
end.



on return of ub.price-list.price-sale in browse br-list or
   return of ub.price-list.road-tax   in browse br-list or
   return of ub.price-list.excise     in browse br-list do:
  if decimal  (ub.price-list.price-sale :screen-value in browse br-list) <> ub.price-list.price-sale or
     decimal  (ub.price-list.road-tax   :screen-value in browse br-list) <> ub.price-list.road-tax or
     decimal  (ub.price-list.excise     :screen-value in browse br-list) <> ub.price-list.excise then
    run upd-br-field in this-procedure .
  /* перевыводится уже новое значение */
  display {&disp-list} with browse br-list no-error .
  apply "value-changed" to br-list in frame {&frame-name}.
end.

on return of increase-pc, round-base, doc-code,common-price, copy-type, copy-code in frame {&frame-name} do:
  apply "entry" to br-list in frame {&frame-name}.
  return no-apply.
end.

on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
end.

on choose of b-arch in frame {&frame-name} do:
{ gbl/stdbtn.i }
/*run str/pr-oldd.p (input p-doc.doc-num ) .
run str/pr-tot.p ( input p-doc.doc-num ) .   */
run str/doc-prc.w .
end.

on choose of b-quest in frame {&frame-name} do:
  /* { gbl/stdbtn.i } */
  run run-help in this-procedure .

end.

on choose of b-calc in frame {&frame-name} do:
{ gbl/stdbtn.i }
run str/pr-tot.p ( input p-doc.doc-num ) no-error.
run upd-disp-tot in this-procedure ( "disp" ).
end.

on choose of b-exit in frame {&frame-name} do:
 { gbl/stdbtn.i }
   define variable p-err as logical no-undo .
   if doc-mode <> {&lookup} then do:
     run str/pr-tot.p ( input p-doc.doc-num ) no-error.
     run upd-disp-tot in this-procedure ("disp").
   end.
   run ch-b-exit in this-procedure (output p-err) .
   if p-err = true then return no-apply.
end.

on choose of b-notes in frame {&frame-name} do:
{ gbl/stdbtn.i }
notes = p-doc.ps.
if doc-mode = {&lookup} then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
  if return-value = 'false':u
  then do:
    return .
  end.
  if p-doc.PS <> notes then do:
    do transaction on error undo, return no-apply :
      find p-doc where recid (p-doc) = doc-rec exclusive.
      assign
        p-doc.PS = notes.
    end.
  end.
end.

end.

on choose of b-history in frame {&frame-name} do: /*Истори */
{ gbl/stdbtn.i }
run str/pr-cdoc.w ( parParentProc, p-doc.host-code, p-doc.doc-num ).
end.

on choose of b-add do:
run pro-list in this-procedure ("b-add").
run add-price-line in this-procedure .
doc-rec = recid(p-doc) .
run open-br in this-procedure .
end.



on choose of b-special do:
{ gbl/stdbtn.i b-special }
run add-spec-proc in this-procedure ("gds-all") no-error.
doc-rec = recid(p-doc) .

if error-status :error then
  return no-apply.
end.

on choose of menu-item m-lst-chg do:
{ gbl/stdbtn.i b-chg }
if input frame {&frame-name} increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to br-list in frame {&frame-name}.
  return no-apply.
end.
if not available ub.price-list then do:
  message "Задайте товары клавишей 'ДОБАВИТЬ' ! "
          view-as alert-box error.
  return no-apply.
end.

run pro-list in this-procedure ("b-chg").
/* никуда не делать reposition */
line-rec = ?.
doc-mode = {&update}.
run open-br in this-procedure .
run upd-disp-tot in this-procedure ("clear"). /* показываем итоги с вопросительными знаками */
end.

on choose of menu-item m-one-chg do:
{ gbl/stdbtn.i b-chg }
if input frame {&frame-name} increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to br-list in frame {&frame-name}.
  return no-apply.
end.
if not available ub.price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
line-rec = recid (ub.price-list).
define variable p-line-mode as character no-undo .
p-line-mode = line-mode .
line-mode = "calc":u.
run calc-pr-list in this-procedure
                 (input ub.price-list.b-code,
                  input p-doc.doc-num,
                  input calc-method,
                  input increase-pc,
                  input round-method,
                  input round-base,
                  input ?,
                  input ?,
                  input ?,
                  input ?,
                  output line-rec) no-error.
if error-status:error then do:
   line-mode = p-line-mode.
   next.
   end.

line-mode = p-line-mode.
if line-rec = recid (ub.price-list) then do:
  /* ни одна цена, кроме текущей, не пересчитывалась - можно выводить 1 строку */
  display {&disp-list} with browse br-list no-error .
  end.
else do:
  run open-br in this-procedure .
  run upd-br-field in this-procedure .
  /* пересчитывались еще и спеццены - нужно выводить весь browse */
  end.
run upd-disp-tot in this-procedure ("clear"). /* показываем итоги с вопросительными знаками */
apply "value-changed" to br-list in frame {&frame-name} .
end.

on choose of menu-item m-lst-del do:
{ gbl/stdbtn.i b-del }
run pro-list in this-procedure ("b-del").
line-rec = ?.
run upd-disp-tot in this-procedure ("clear"). /* показываем итоги с вопросительными знаками */
doc-mode = {&update}.
run open-br in this-procedure .
end.

on choose of menu-item m-one-del do:
{ gbl/stdbtn.i b-del }
if not available ub.price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
assign
  line-rec = recid (ub.price-list)
  g#log = no
  .
message "Удалить строку документа" ub.goods.artic ub.goods.gds-name "?   Вы уверены?"
        view-as alert-box question buttons ok-cancel update g#log.
if not g#log then
  return no-apply.
get next br-list.
if available ub.price-list then
  rep-rec = recid (ub.price-list).
else do:
  reposition br-list to recid line-rec no-error.
  get prev br-list.
  if available ub.price-list then
    rep-rec = recid (ub.price-list).
end.
reposition br-list to recid line-rec no-error.
find ub.price-list where recid (ub.price-list) = line-rec.
find first price-list-tt where
          price-list-tt.artic      = ub.price-list.artic
      and price-list-tt.doc-num    = ub.price-list.doc-num
      and price-list-tt.prod-code  = ub.price-list.prod-code
      and price-list-tt.prod-type  = ub.price-list.prod-type
      and price-list-tt.prod-type  = ub.price-list.prod-type
      no-error .


 if string({&clmn_1-br-list} ) = {&property} then do :
     if not avail price-list-tt then  return no-apply.

     message "При удаление из переоценки спеццены признака  удаляются.  Цена товара"
     ub.goods.gds-name {&clmn_4-br-list}  " = " price-list-tt.price-sale
     skip
     "Вы уверены?"
    view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then  return no-apply.
end.

run del-pr-list in this-procedure ( input ub.price-list.b-code,
                   input p-doc.doc-num,
                   input round-method,
                   input round-base) no-error.
if error-status :error then
  return no-apply.
line-rec = rep-rec.
run upd-disp-tot in this-procedure ("clear"). /* показываем итоги с вопросительными знаками */
doc-mode = {&update}.

get next br-list .
if available ub.price-list then   g#log = br-list:select-next-row () in frame {&frame-name}.
g#log = br-list:REFRESH( )  in frame {&frame-name}.
end.

on choose of b-alt do:
{ gbl/stdbtn.i b-alt }
if not available ub.price-list then do:
  message "Неправильно выбрана строка."
          view-as alert-box error.
  return no-apply.
end.
doc-rec = recid(p-doc) .
if ub.price-list.main-price = true then
   run str/pr-alt.w (
              input parParentProc ,
              input doc-rec ,
              input doc-mode ,
              input "code",
              input ub.bar-code.b-code,
              input-output round-method,
              input-output round-base).
else
  run str/pr-alt.w (
              input parParentProc ,
              input doc-rec ,
              input doc-mode ,
              input "scl-gds",
              input ub.bar-code.b-code,
              input-output round-method,
              input-output round-base).
doc-rec = recid(p-doc) .

run ui-on in this-procedure . /* чтобы вывелись значения round-method, round-base */
end.

on choose of r-copy in frame {&frame-name} do:
{ gbl/stdbtn.i }
define variable loc-ref-list as character no-undo .
case calc-method:
  when {&pr-calc-obj} then do:
    run ref/cli-all.w ( parParentProc
                   , "b-sel"
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                   , ?
                   , output ref-list) .
    apply "entry" to copy-type in frame {&frame-name}.
    if ref-list = "" then
      return no-apply.
    ref-rec = integer (ref-list).
    find ub.clients where recid (ub.clients) = ref-rec no-lock.
    if not ( ub.clients.obj-type = {&stock} or
             ub.clients.obj-type = {&shop} ) then do:
      message "Объектом для копирования цены может быть только склад или магазин."
              view-as alert-box error.
      return no-apply.
    end.
    assign
      copy-code = ub.clients.obj-code
      copy-type = ub.clients.obj-type
      .
    display copy-type copy-code with frame {&frame-name}.
  end.
  when {&pr-calc-wbill}  or
  when {&pr-calc-slt-wbill} or
  when {&pr-calc-wbill-novat}
       then do:
    assign
      doc-rec = ?  .
    run str/all-docs.w (input parparentproc, input ?, input ?, input ?, input {&work}, input ?, input ?, input ?, input ?, input "b-sel":u, input ?, input ?, input ?, output loc-ref-list).
    find ub.trn-doc where recid (ub.trn-doc) = int(loc-ref-list) no-lock no-error .
    g#stat = p-doc.status_ .
    if not available ub.trn-doc then do:
      message "Накладная не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    doc-code = ub.trn-doc.doc-code.
    display doc-code with frame {&frame-name}.
  end.
  when {&pr-common} then do:
    display common-price with frame {&frame-name}.
  end.

  when {&pr-calc-ov} then do:
    /* Список всех переоценок */
    run str/pr-docs.w (
        input parParentProc ,
        input "b-sel":U ,
        input {&work} ,
        input "" ,
        input v-cntxt-obj-type ,
        input v-cntxt-obj-code ,
        input "" ,
        output loc-ref-list ).
    doc-rec = integer ( loc-ref-list ) .
    find ub.price-doc where recid (ub.price-doc) = doc-rec no-lock no-error.
    if not available ub.price-doc then do:
      message "Переоценка не выбрана."
              view-as alert-box error.
      return no-apply.
    end.

    /* выбрана переоценка */
    doc-code = ub.price-doc.doc-num.
    display doc-code with frame {&frame-name}.
  end.
end case.
end.

on value-changed of calc-method in frame {&frame-name} do:
assign
  calc-method
  doc-code = ""
  .
run ui-on in this-procedure .
end.

on leave of increase-pc in frame {&frame-name} do:
assign
  increase-pc.
end.

on value-changed of round-method in frame {&frame-name} do:
assign
  round-method.
run ui-on in this-procedure .
end.

on leave of copy-type in frame {&frame-name} do:
define variable v-type as character no-undo .
    v-type =  input frame {&frame-name} copy-type .
    if (v-type = {&stock} or v-type = {&shop} ) then
      assign copy-type.
    else
      message "Объектом для копирования цены может быть только склад или магазин."
              view-as alert-box error.
    disp copy-type with frame {&frame-name}.
end.

on leave of copy-code in frame {&frame-name} do:
if can-find (ub.clients where ub.clients.obj-type = copy-type
                       and ub.clients.obj-code = input frame {&frame-name} copy-code no-lock) then
  assign
    copy-code.
else
  message "Нет такого объекта!"
          view-as alert-box error.
disp copy-code with frame {&frame-name}.
end.

on leave of doc-code in frame {&frame-name} do:
/* буфер документа нужен в   p r - c a l c . i , поэтому can-find недостаточно */
if calc-method = {&pr-calc-wbill} or
   calc-method = {&pr-calc-slt-wbill} or
   calc-method = {&pr-calc-wbill-novat}
  then do:
  find ub.trn-doc where ub.trn-doc.doc-code = input frame {&frame-name} doc-code no-lock no-error.
  g#log = available ub.trn-doc.
end.
if calc-method = {&pr-calc-ov} then do:
  find ub.price-doc where ub.price-doc.doc-num = input frame {&frame-name} doc-code no-lock no-error.
  g#log = available ub.price-doc.
end.
if g#log then
  assign doc-code.
else
  if input doc-code <> "" then
    message "Нет такого документа!"
            view-as alert-box error.
disp doc-code with frame {&frame-name}.
end.

on leave of round-base in frame {&frame-name} do:
if input frame {&frame-name} round-base = 0 then do:
  if input frame {&frame-name} round-method = {&pr-round-select} then
    message "Такое округление невозможно - деление на 0."
            view-as alert-box error.
  else
    message "Пересчет по нулевому коэффициенту невозможен - получится 0."
            view-as alert-box error.
end.
else
  assign
    round-base.
disp round-base with frame {&frame-name}.
end.

on leave of common-price in frame {&frame-name} do:
   assign common-price.
disp common-price with frame {&frame-name}.
end.

{ str/n-p-doc.i p-doc }  /* next, prev */



/* ***************************  main block  *************************** */

if valid-handle(active-window) and frame {&frame-name}:parent eq ? then
  frame {&frame-name}:parent = active-window.

on window-close of frame {&frame-name} apply "end-error":u to self.

{ gbl/app_help.i }

/* зацикливание формы */
next-prev = yes.
n-p:
do while next-prev :
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block:

  run ver-conf in this-procedure no-error .
  run mode-on in this-procedure no-error.
  if error-status:error    then do: undo, return error. end.
  if doc-mode <> {&lookup} then do:
     line-rec = ?.
     text-i = "Исходная" .
     enable b-quest with frame {&frame-name} .
     display text-i with frame {&frame-name} .
     end.
  hide b-quest in frame {&frame-name} .
  run open-br in this-procedure .
  run ui-on in this-procedure .

  run cr-button in this-procedure .

  run tax-name in this-procedure ( input {&road-tax}, output  dor-nal) .
  assign {&clmn_13-br-list} :label = dor-nal .
   calc-name:RESIZABLE  in browse br-list  = true .


  { gbl/mv-clmn.i
  &ext-col = 15
  &frame-name = "{&frame-name}"
  &browse-name = "br-list"
  &start-column = "6"
  &num-group = "4"
  &mem-gr_1 = "7,8"
  &mem-gr_2 = "9,10"
  &mem-gr_3 = "11,12"
  &mem-gr_4 = "13,14"
  }
    wait-for go of frame {&frame-name} focus br-list.
end.
end. /* do while */
run disable_ui in this-procedure .

/* **********************  internal procedures  *********************** */
FUNCTION fnc-base-code RETURN integer (local-bc as integer).
define variable local-base-code like ub.bar-code.b-code no-undo.
run prc-base-code in this-procedure ( input local-bc, output local-base-code ).
return (local-base-code).
END FUNCTION.

{ str/alt-calc.i pr-list pr-doc }
{ str/alt-calc.i "main-road-tax" }
{ str/alt-calc.i "ver-pr-equ-dq" }
{ str/alt-calc.i "ver-pr-discn" }
{ str/alt-calc.i "exp-prt" }

procedure disable_ui :
  hide frame {&frame-name}.
end procedure.


procedure mode-on :
/* ------------------------------------------------------------------------------------------------------------------------*/
define variable v-today as date      no-undo.
define variable new-doc-rec as recid no-undo .

define buffer old-doc for ub.price-doc.                      /* для проверки на незакрыт. при создании */

if doc-mode = {&add-def} then do:
  find last old-doc where old-doc.obj-type = v-cntxt-obj-type
                      and old-doc.obj-code = v-cntxt-obj-code
                      and old-doc.status_ = {&g___new} no-lock no-error.
  if available old-doc then do:
    g#log = yes.
    message "По" v-cntxt-obj-type v-cntxt-obj-code "имеется незакрытый приказ №" old-doc.doc-num "от" old-doc.doc-date
            ". Вы уверены, что Вы хотите создать новый приказ ? ОТКАЗ от создания - cancel."
            view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then   do:
        undo, return error.
        end.
  end.

  run prcreate-new-price-doc in this-procedure
    ( input v-cntxt-db-num ,
      input v-cntxt-obj-type ,
      input v-cntxt-obj-code ,
      ?,?,?,?,
      output new-doc-rec ) no-error .
      if error-status :error then
          message vss-workfile vss-revision vss-description skip
          error-status :get-message(1)
          "Ошибка при создании документа переоценки "
          view-as alert-box error .
   doc-rec = new-doc-rec .
   find first p-doc where recid(p-doc) = doc-rec  exclusive-lock  .

end.
else do:
  if doc-mode = {&update} then do:
    find p-doc where recid (p-doc) = doc-rec no-error.
    if available p-doc then do:
       if lookup ( p-doc.status_ , {&order_permitted_act-overvalue})  > 0 then do:
         message "Приказ/Акт переоценки №" p-doc.doc-num
                 "для" p-doc.obj-type p-doc.obj-code "от"
                 p-doc.doc-date "закрыт. Изменение невозможно."
                 view-as alert-box error.
         undo, return error.
       end.
     end.
  end.
  if not available p-doc then do:
    message "Неправильный выбор документа."
            view-as alert-box error.
    undo, return error.
  end.
end.
end procedure.


procedure cre-line:
/* ---------------------------------------------------------------------------------------------------------------------------------
   Создает новую запись ub.price-list (если такой нет) по заданному ub.bar-code
   если главная цена, разворачивает неосновные и спец, если есть настройки
   ничего не рассчитывает
------------------------------------------------------------------------------------------------------------------------------------- */
def input param bc    like ub.price-list.b-code no-undo.
define variable v-ret as logical no-undo .

define buffer buf-bar-code  for ub.bar-code.
define buffer buf-goods     for ub.goods.
define buffer buf-gds-prt   for ub.gds-prt.
find  buf-bar-code no-lock where
      buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo, return error.
  end.


find  buf-goods no-lock where
      buf-goods.gds-code = buf-bar-code.gds-code.
find  buf-gds-prt no-lock where
      buf-gds-prt.node-code = buf-bar-code.node-code.

    run ver-modificator-price-is-null in this-procedure (
        input    buf-goods.artic        ,
        input    buf-goods.prod-type    ,
        input    buf-goods.prod-code    ,
        input    p-doc.obj-type   ,
        input    p-doc.obj-code   ,
        output   v-ret ).
    if v-ret = false then do:
    message
      "На модификатор : " skip
      "Артикул : "buf-goods.artic skip
      buf-goods.gds-name skip
      "не должно быть цены! "
      view-as alert-box information .
      undo, return error.
  end.



if par-pr-dpl-q = "yes" then do:
  /* проверяем, нет ли этой строки в другом ПРИКАЗЕ по ЭТОМУ ЖЕ объекту */
  find first ub.price-list where
             ub.price-list.b-code   = bc and
             ub.price-list.obj-type = p-doc.obj-type and
             ub.price-list.obj-code = p-doc.obj-code and
             ub.price-list.doc-num <> p-doc.doc-num and
             ub.price-list.fact-order = 0
             no-lock /* use-index fact-close*/  no-error.
  if available ub.price-list then do:
    g#log = yes.
    message "Строка :" ub.price-list.artic buf-goods.gds-name /* buf-gds-prt.node-name */
            "ЕСТЬ в Приказе №" ub.price-list.doc-num
            "для" p-doc.obj-type p-doc.obj-code skip
            "Продолжать?"
            view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then
      undo, return error.
  end.
end.

/* проверяем, нет ли такой строки в ЭТОМ ЖЕ документе */
find  ub.price-list where
      ub.price-list.b-code  = bc and
      ub.price-list.price-type = "" and
      ub.price-list.doc-num = p-doc.doc-num  no-error.



if available ub.price-list then do:
  line-rec = recid (ub.price-list).
  new-pr-recid = line-rec.
  if ub.price-list.calc-method <> "" and
     buf-gds-prt.upper-code = buf-goods.prt-root then do:
        if par-pr-clt-q = "yes" then do:
          g#log = yes.
          message "Строка :" ub.price-list.artic buf-goods.gds-name /* buf-gds-prt.node-name */
                  "уже ЕСТЬ в заполняемом Приказе, цена =" ub.price-list.price-sale skip
                  "Продолжать?"
                  view-as alert-box question buttons ok-cancel update g#log.
          if not g#log then  do:
             undo, return error.
             end.
        end.
  end.
end.
else do:
  run cre-pr-list in this-procedure (input  bc,
                   input  p-doc.doc-num,
                   output line-rec) no-error.
  if error-status :error then do:
    undo, return error.
    end.
   new-pr-recid = line-rec.
end.

end procedure.

procedure pro-list :
/* ------------------------------------------------------------------------------------------------------------------------ */
def input param fnc as char no-undo.
define variable l-c as integer no-undo.
run waitfram-show in this-procedure ("ЖДИТЕ.  Заполняется список...").
l-c = 0.

if fnc = "b-add" then do: /* ДОбавление */
/* по накладной------------------ */
  if calc-method = {&pr-calc-wbill} or
     calc-method = {&pr-calc-slt-wbill} or
     calc-method = {&pr-calc-wbill-novat} then do:
    for each ub.doc-line no-lock where
             ub.doc-line.doc-code = doc-code,
        each ub.goods no-lock where
             ub.goods.artic = ub.doc-line.artic and
             ub.goods.prod-type = ub.doc-line.prod-type and
             ub.goods.prod-code = ub.doc-line.prod-code:
      l-c = l-c + 1.
      if l-c modulo 25 = 0 then
        run waitfram-show in this-procedure ("Заполнено строк по накладной : " + string (l-c)).
        { cmp/gds-list.i gds-list assign }
      process events.
    end.
  end.

  /* end  по накладной------------------ */
  /*  по переоценкам------------------ */
  if calc-method = {&pr-calc-ov} then do:
    for  each prev-list no-lock where
              prev-list.doc-num = doc-code,
         each ub.goods no-lock where
              ub.goods.artic = prev-list.artic and
              ub.goods.prod-type = prev-list.prod-type and
              ub.goods.prod-code = prev-list.prod-code:
      l-c = l-c + 1.
      if l-c modulo 25 = 0 then
        run waitfram-show in this-procedure ( "Заполнено строк по переоценке : " + string (l-c) ).
      { cmp/gds-list.i gds-list assign }
      process events.
    end.
  end.
  /* end по переоценкам------------------ */
end.
else do:
  for each ub.price-list where
           ub.price-list.doc-num    = p-doc.doc-num and
           ub.price-list.main-price = yes,
      each ub.goods no-lock where
           ub.goods.artic     = ub.price-list.artic and
           ub.goods.prod-type = ub.price-list.prod-type and
           ub.goods.prod-code = ub.price-list.prod-code:
    l-c = l-c + 1.
    if l-c modulo 25 = 0 then
      run waitfram-show in this-procedure ("ЖДИТЕ.  Документ переносится в список : " + string (l-c)).
    { cmp/gds-list.i gds-list assign }
    ub.price-list.doc-qnty = 0.  /* пометка - потенциально лишняя запись */
    process events.
  end.
end. /*else*/

/* уничтожение лишних записей */
for each gds-list where gds-list.to-del = yes:
  delete gds-list.
end.
run waitfram-hide in this-procedure .
if fnc <> "b-add" then
   run str/gds-list.w
       ( parParentProc, p-doc.host-code, p-doc.obj-type, p-doc.obj-code).
doc-rec = recid (p-doc).   /* ломается в gds-list.w */
g#log = yes.

case fnc :
  when "b-chg" then
    message "Рассчитать цены по всем строкам списка ?"
            "Вы уверены ?"
            view-as alert-box question buttons ok-cancel update g#log.
  when "b-del" then
    message "В документе будут только те строки, которые оставлены в списке."
            "Вы уверены ?"
            view-as alert-box question buttons ok-cancel update g#log.
end.
if not g#log then
  return.

run waitfram-show in this-procedure ("ЖДИТЕ.  Список переносится в документ...").
lns-cnt = 0.
for each  gds-list,
    first ub.gds-prt no-lock where
          ub.gds-prt.upper-code = gds-list.prt-root,
    first ub.bar-code no-lock where
          ub.bar-code.gds-code  = gds-list.gds-code and
          ub.bar-code.node-code = ub.gds-prt.node-code and
          ub.bar-code.in-code   = "" and
          ub.bar-code.part-code = "" and
          ub.bar-code.unit-cli  = gds-list.unit-base:
  lns-cnt = lns-cnt + 1.
  if lns-cnt modulo 25 = 0 then
    run waitfram-show in this-procedure ("ЖДИТЕ.  Переписано строк : " + string (lns-cnt)).

  if ( calc-method = {&pr-calc-wbill} or
       calc-method = {&pr-calc-slt-wbill} or
       calc-method = {&pr-calc-wbill-novat} or
       calc-method = {&pr-calc-ov} )
        and  fnc = "b-add" then do:
    run cre-line in this-procedure (ub.bar-code.b-code) no-error.
    if error-status:error then do:  next.  end.

  end.


  find ub.price-list where
       ub.price-list.doc-num    = p-doc.doc-num and
       ub.price-list.b-code     = ub.bar-code.b-code and
       ub.price-list.price-type = "" no-error .

  if available  ub.price-list then do:
    ub.price-list.doc-qnty = ?.
    if lookup (fnc, "b-chg,b-add") > 0 then do:

      define variable p-line-mode as character no-undo .
      p-line-mode = line-mode .
      line-mode = "calc":u.
      run calc-pr-list in this-procedure
                       (input ub.bar-code.b-code,
                        input p-doc.doc-num,
                        input calc-method,
                        input increase-pc,
                        input round-method,
                        input round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output line-rec) no-error.
      if error-status:error then do:
        line-mode = p-line-mode .
        next.
        end.
      line-mode = p-line-mode .
    end.
  end.
  gds-list.to-del = yes.  /* пометка - потенциально лишняя запись - отмечаем как начальное значение все записи */
  process events.
end.

if fnc = "b-del" then do:
  /* уничтожение лишних записей */
  for each ub.price-list no-lock where
           ub.price-list.doc-num = p-doc.doc-num and
           ub.price-list.main-price = yes and
           ub.price-list.doc-qnty = 0:
    run del-pr-list in this-procedure
                     (input ub.price-list.b-code,
                      input p-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      next.
  end.
end.
run open-br in this-procedure .
doc-rec = recid(p-doc) .
run waitfram-hide in this-procedure .
end procedure.

procedure ui-on :
/* ------------------------------------------------------------------------------------------------------------------------*/
doc-rec = recid (p-doc). /* может быть поломан вызываемыми программами */
/* disable all with frame {&frame-name}. */
hide loc-art  in frame {&frame-name}.
hide loc-art loc-name loc-code in frame {&frame-name}.
loc-art = "".
enable a-n-c b-exit b-help br-list b-history b-notes b-arch b-alt with frame {&frame-name}.
frame {&frame-name}:title = if p-doc.status_ = {&act-overvalue} then "Акт" else "Приказ".
frame {&frame-name}:title = frame {&frame-name}:title + " переоценки № " + p-doc.doc-num +
                            "  для " + p-doc.obj-type + " " + string (p-doc.obj-code) + "  от " +
                            string (p-doc.doc-date) + "      " + doc-mode.
run upd-disp-tot in this-procedure ("disp").
if doc-mode = {&lookup} then do:
  assign
    ub.price-list.price-sale:read-only in browse br-list = yes
    ub.price-list.excise:read-only in browse br-list = yes
    .
  enable b-prev b-next with frame {&frame-name}.
  hide increase-pc calc-method round-method copy-type copy-code doc-code common-price  r-copy in frame {&frame-name}.
end.
else do:
  assign
    ub.price-list.price-sale:read-only in browse br-list = no
    ub.price-list.excise:read-only in browse br-list = no
    .
  if v-cntxp-doc-prt then
    enable b-special with frame {&frame-name}.
  display round-method increase-pc round-base with frame {&frame-name}.
  if input round-method = "" then do:
    round-method = {&pr-round-off}.
    display round-method with frame {&frame-name}.
  end.
  if input calc-method = "" then do:
    calc-method = {&pr-calc-no}.
    display calc-method with frame {&frame-name}.
  end.
  enable b-add b-chg b-del round-method increase-pc calc-method b-calc with frame {&frame-name}.
  if lookup( input frame {&frame-name} round-method, {&pr-rounds-need-coef} ) > 0 then do:
    enable round-base with frame {&frame-name}.
    display round-base with frame {&frame-name}.
  end.
  else
    hide round-base in frame {&frame-name}.
  hide copy-type copy-code doc-code common-price r-copy in frame {&frame-name}.
  case calc-method :
    when {&pr-calc-obj} then do:
      enable copy-type copy-code r-copy with frame {&frame-name}.
      display copy-type copy-code with frame {&frame-name}.
    end.
    when {&pr-calc-wbill} or
    when {&pr-calc-wbill-novat} or
    when {&pr-calc-slt-wbill} or
    when {&pr-calc-ov} then do:
      enable doc-code r-copy with frame {&frame-name}.
      display doc-code with frame {&frame-name}.
    end.
    when {&pr-common} then do:
      enable common-price with frame {&frame-name}.
      display common-price with frame {&frame-name}.
    end.

  end case.
end.
if (calc-method = {&pr-calc-wbill} or
    calc-method = {&pr-calc-wbill-novat} or
    calc-method = {&pr-calc-slt-wbill} or
    calc-method = {&pr-calc-ov}) and
   doc-code = "" then
  /* после выбора одной из этих опций встаем на поле номера документа */
  apply "entry" to doc-code in frame {&frame-name}.
else do:
   if (calc-method = {&pr-common} ) then apply "entry" to common-price in frame {&frame-name}.
   else
      apply "entry" to br-list in frame {&frame-name}.
end.
end procedure.

procedure open-br :
/* ------------------------------------------------------------------------------------------------------------------------*/
define variable t-ret as logical no-undo .
define variable t1 as decimal no-undo .
  t1 = time.
 t-ret =  session:SET-WAIT-STATE("GENERAL") .
&scop dif-cond

 {&open-query-br-list} by ub.price-list.artic by ub.gds-prt.node-code .
      run value-changed-br-list in this-procedure .
      t-ret =  session:SET-WAIT-STATE("") .


end procedure.

procedure upd-disp-tot :
/* ------------------------------------------------------------------------------------------------------------------------*/
def input param mode as char no-undo.

if mode = "clear" then
  if s-new = ? then
    /* чтоб не терять время при вызовах из цикла на перерисовку '?' */
    return.
  else
    p-doc.sale-base = ?.
assign
  s-new = p-doc.rest-sale + p-doc.sale-base
  s-old = p-doc.rest-sale
  pc-prev = (s-new / s-old - 1) * 100
  s-new-old = s-new - s-old
  pc-avrg = (s-new / p-doc.rest-base - 1) * 100
  op-avrg = (s-old / p-doc.rest-base - 1) * 100
  pc-op-avrg = pc-avrg - op-avrg
  pc-last = (s-new / p-doc.rest-last - 1) * 100
  op-last = (s-old / p-doc.rest-last - 1) * 100
  pc-op-last = pc-last - op-last
  .
  if pc-prev > 9999 then
    pc-prev = ?. /* чтоб влезало в формат */

  if pc-avrg > 9999 then
    pc-avrg = ?. /* чтоб влезало в формат */
  if op-avrg > 9999 then
   op-avrg = ?. /* чтоб влезало в формат */

  if pc-op-avrg > 9999 then
   pc-op-avrg = ?. /* чтоб влезало в формат */

  if pc-last > 9999 then
    pc-last = ?. /* чтоб влезало в формат */
  if op-last > 9999 then
   op-last = ?. /* чтоб влезало в формат */

  if pc-op-last > 9999 then
   pc-op-last = ?. /* чтоб влезало в формат */

  if s-new-old > 9999999999 then
   s-new-old = ?. /* чтоб влезало в формат */


disp s-new s-old s-new-old pc-prev pc-avrg op-avrg pc-op-avrg pc-last op-last pc-op-last
     with frame {&frame-name} no-error .
end procedure.

procedure upd-br-field:
define variable ff as logical no-undo .
define variable ff1 as logical init true no-undo .
define variable cur-dn as decimal no-undo .
define variable cur-pr as decimal no-undo .
define variable cur-rt as decimal no-undo .
define variable cur-ex as decimal no-undo .



define variable calc-rec as recid no-undo.  /* последняя посчитанная запись - не используется */
  /* no-lock !!! */
  find current ub.price-list.
  if decimal  (ub.price-list.price-sale :screen-value in browse br-list) <> ub.price-list.price-sale then do:
    /* изменилась цена - записываем, что она была изменена вручную */
    assign
      ub.price-list.calc-method = {&pr-calc-no}
      ub.price-list.price-calc = ub.price-list.price-sale
      ub.price-list.price-sale = decimal  (ub.price-list.price-sale :screen-value in browse br-list)
      .
    /* пересчитываем цены по неосновным для этого кода */
    run calc-pr-sub in this-procedure
                     (input  ub.price-list.b-code,
                      input  p-doc.doc-num,
                      input  calc-method,
                      input  increase-pc,
                      input  round-method,
                      input  round-base,
                      output calc-rec) no-error.
    if error-status :error then do:
      undo, return error.
      end.
    /* показываем итоги с вопросительными знаками */
    run upd-disp-tot in this-procedure ("clear").
  end.

if decimal  (ub.price-list.excise :screen-value in browse br-list) <> ub.price-list.excise then do:
    /* изменены налоги */
    assign
    ub.price-list.excise     = decimal  (ub.price-list.excise     :screen-value in browse br-list)
    .
end.

if decimal  (ub.price-list.road-tax :screen-value in browse br-list) <> ub.price-list.road-tax then do:
/* Проверочка наличия Третьего налога */
       find first buff-goods no-lock where
            buff-goods.artic     = ub.price-list.artic and
            buff-goods.prod-type = ub.price-list.prod-type and
            buff-goods.prod-code = ub.price-list.prod-code
            no-error .

      if avail buff-goods then do:
              if hvrdtax( recid(buff-goods)) = false  then  do :
                  /*нет стеклопосуды */
                 message "В товаре нет компонента цены '"   ub.price-list.road-tax:label  "' ,  изменять нельзя ! " .
                 ub.price-list.road-tax   = ub.price-list.road-tax.
              end.
              /* есть стеклопосуда */
              else do:
                /* изменение стеклопосуды права */
                  define variable v-chk-act-host-code as integer   no-undo .
                  { gbl/hostcode.i
                    ub.price-list.obj-type
                    ub.price-list.obj-code
                    v-chk-act-host-code
                  }
                  { gbl/chk-actg.i
                    v-cntxt-db-num
                    v-cntxt-userid
                    {&action-head-code-main}
                    'actn_overvalue_update':U
                    {&cntxt-object}
                    v-chk-act-host-code
                    ub.price-list.obj-type
                    ub.price-list.obj-code
                    0
                    0
                    0
                    true
                    ff
                  }
                    if not ff
                    then do:
                      /* Если прав нет то ..... */
                      assign
                        ub.price-list.road-tax   = ub.price-list.road-tax
                      .
                    end.
                    else do :
                      assign
                        ub.price-list.road-tax = dec(ub.price-list.road-tax:screen-value in browse br-list)
                      .
                    end.
              end.
            end.
       end.
end procedure.

procedure add-spec-proc:
def input param bas-mode as char no-undo.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_properties':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .


define variable rec-list as char no-undo.
define variable num-rec as integer no-undo.

if input frame {&frame-name} increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to br-list in frame {&frame-name}.
  return no-apply.
end.
if not available ub.price-list or
   ub.gds-prt.upper-code <> ub.goods.prt-root then do:
  message "Неправильно выбрана строка. Должна быть указана главная цена."
          view-as alert-box error.
  return no-apply.
end.
run ref/bas-cds.w (parParentProc, v-cntxt-obj-type, v-cntxt-obj-code, bas-mode, ub.bar-code.gds-code, output rec-list).
apply "entry" to br-list in frame {&frame-name}.
if rec-list = '' then
  return no-apply.

define variable v-11 as integer   no-undo .
v-11 = num-entries (rec-list) .
do num-rec = 1 to v-11 :
  ref-rec = integer (entry (num-rec, rec-list)).
  find ub.bar-code where
       recid (ub.bar-code) = ref-rec no-lock.

  if avail ub.bar-code  and ub.bar-code.part-code = "" and  ub.bar-code.in-code = "" then do:
     run cre-line in this-procedure  (ub.bar-code.b-code) no-error .
      if error-status:error then   next.

  run calc-pr-list in this-procedure
                   (input ub.bar-code.b-code,
                    input p-doc.doc-num,
                    input calc-method,
                    input increase-pc,
                    input round-method,
                    input round-base,
                    input ? ,
                    input ? ,
                    input ? ,
                    input ? ,
                    output line-rec) no-error.
  if error-status:error then do:   next. end.
  /* отказ пользователя от зацикленной формы */
    if calc-method = {&pr-calc-no} and
      line-mode = {&lookup} then
    leave.
end.
end.
run upd-disp-tot in this-procedure ("clear"). /* показываем итоги с вопросительными знаками */
doc-mode = {&update}.
run open-br in this-procedure .
end procedure.

procedure value-changed-br-list :
define variable rt-old like ub.price-list.road-tax no-undo.
define variable ex-old like ub.price-list.excise   no-undo.
define variable dn-old like ub.price-list.doc-num  no-undo.

if not available ub.price-list then
  return.
if p-doc.status_ = {&act-overvalue} then do:
  /* ищем предыдущую цену товара по текущему объекту */
  { gbl/bcodeprc.i
    ub.price-list.obj-type
    ub.price-list.obj-code
    ub.price-list.b-code
    0
    ub.price-list.fact-order
    dn-old
    p-old
    rt-old
    ex-old }
end.
else do:
  /* ищем последнюю цену товара по текущему объекту */
  { gbl/bcodeprc.i
    ub.price-list.obj-type
    ub.price-list.obj-code
    ub.price-list.b-code
    0
    0
    dn-old
    p-old
    rt-old
    ex-old }
end.
disp dn-old @ prev-list.doc-num
     with frame {&frame-name}.
/* находим среднюю и последнюю цену по объекту */
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = p-doc.obj-type and
     ub.gds-obj.obj-code = p-doc.obj-code no-error.
if available ub.gds-obj then
  if ub.goods.gds-type = {&gds-goods} then
    assign
      p-avrg-fact = func-cost-price (ub.price-list.b-code , ub.gds-obj.gds-code , p-doc.status_ , var-pr-r-b)
      p-avrg = if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      p-last = if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
      obj-in-code = ub.gds-obj.in-code
      obj-in-date = ub.gds-obj.in-date
      .
  else
    assign
      p-avrg-fact = func-cost-price (ub.price-list.b-code , ub.gds-obj.gds-code , p-doc.status_ , var-pr-r-b)
      p-avrg = if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      p-last = ?
      obj-in-code = ?
      obj-in-date = ?
      .
else
  assign
    p-avrg-fact = ?
    p-avrg      = ?
    p-last      = ?
    obj-in-code = ?
    obj-in-date = ?
    .
assign
  p-new = ub.price-list.price-sale
  p-pc-prev = (p-new / p-old  - 1) * 100
  p-op-avrg = (p-old / p-avrg - 1) * 100
  p-pc-avrg = (p-new / p-avrg - 1) * 100
  p-op-avrg-fact = (p-old / p-avrg-fact - 1) * 100
  p-pc-avrg-fact = (p-new / p-avrg-fact - 1) * 100
  p-op-last = (p-old / p-last - 1) * 100
  p-pc-last = (p-new / p-last - 1) * 100
  p-pc-op-avrg-fact = p-pc-avrg-fact - p-op-avrg-fact
  p-pc-op-avrg = p-pc-avrg - p-op-avrg
  p-pc-op-last = p-pc-last - p-op-last
  p-calc-metod = ub.price-list.calc-method
  .
  if p-pc-prev > 9999 then
    p-pc-prev = ?. /* чтоб влезало в формат */

  if p-pc-avrg > 9999 then
    p-pc-avrg = ?. /* чтоб влезало в формат */

  if p-op-avrg > 9999 then
    p-op-avrg = ?. /* чтоб влезало в формат */

  if p-pc-avrg-fact > 9999 then
    p-pc-avrg-fact = ?. /* чтоб влезало в формат */

  if p-op-avrg-fact > 9999 then
    p-op-avrg-fact = ?. /* чтоб влезало в формат */


  if p-pc-last > 9999 then
    p-pc-last = ?. /* чтоб влезало в формат */

  if p-op-last > 9999 then
    p-op-last = ?. /* чтоб влезало в формат */

  if   p-pc-op-avrg > 9999 then
    p-pc-op-avrg = ?. /* чтоб влезало в формат */

  if   p-pc-op-avrg-fact > 9999 then
    p-pc-op-avrg-fact = ?. /* чтоб влезало в формат */


  if p-pc-op-last > 9999 then
    p-pc-op-last = ?. /* чтоб влезало в формат */


disp p-new p-old
    p-last obj-in-code obj-in-date    p-pc-op-last p-calc-metod
     p-pc-prev   p-op-last p-pc-last
     p-avrg
     p-op-avrg
     p-pc-avrg
     p-pc-op-avrg
     p-avrg-fact
     p-op-avrg-fact
     p-pc-avrg-fact
     p-pc-op-avrg-fact
     with frame {&frame-name} no-error .

 if not available ub.price-list or recid (ub.price-list) <> line-rec then do:
    hide loc-art in frame {&frame-name}.
    loc-art = "".
  end.

end procedure.

procedure ch-b-exit.
define output parameter p-err as logical no-undo .
p-err = false .
if doc-mode <> {&lookup} then do:
doc-rec = recid(p-doc) no-error .
if error-status :error then  doc-rec =  ? .

/* проверка на нерассчитанные строки */
  if can-find (first ub.price-list where ub.price-list.doc-num = p-doc.doc-num
                                  and ub.price-list.price-sale = ? no-lock) then do:
    g#log = no.
    message "В документе есть нерассчитанные строки. Удалить их ?"
            view-as alert-box question buttons yes-no update g#log.
            if g#log then do:
                      for each ub.price-list no-lock  where
                               ub.price-list.doc-num = p-doc.doc-num and
                               ub.price-list.price-sale = ? :
                        run del-pr-list in this-procedure
                                       (input ub.price-list.b-code,
                                        input p-doc.doc-num,
                                        input round-method,
                                        input round-base) no-error.
                        if error-status :error then do:
                          message  vss-workfile vss-revision vss-description skip
                          "Ошибка при удалении строки переоценки " skip
                          p-doc.doc-num
                          ub.price-list.b-code
                          skip
                          error-status :get-message(1) view-as alert-box error  .
                          undo, return error .
                          end.
                      end.
              p-doc.rest-qnty = ?.
            end.
  end.

/*  проверка параметра pr-equ-dq */
  run ver-pr-equ-dq in this-procedure ( input p-doc.doc-num, input 1, input "" ) no-error .
  if error-status :error then do:
        message  vss-workfile vss-revision vss-description skip
            "Ошибка при удалении строки переоценки " skip
            p-doc.doc-num  skip
            error-status :get-message(1) view-as alert-box information .
            undo, return error .
  end.

    /* проверка на превышение процента наценки */
    /* по номеру накладной указанной в интерфейсе */
  if doc-code <> "" and par-pr-discm = 'sale-' then do:
     p-doc.out-code = doc-code .
  end.

  run ver-pr-discn in this-procedure ( input "",  input p-doc.doc-num ,input p-doc.out-code , output p-err ) no-error .
  if error-status :error then
     message "Ошибка при проверки процента наценки!"
     view-as alert-box question
     buttons yes-no
     update v-qqq
     .
     if v-qqq then p-err = true .
     else  p-err = false .
  /* проверка на пустой документ */
  if not can-find (first ub.price-list where ub.price-list.doc-num = p-doc.doc-num no-lock) then do:
    message "В документе нет ни одной строки. Удалять его ?"
            view-as alert-box question buttons yes-no update g#log.
    if g#log then do:
       delete p-doc.
       doc-rec = ? .
    end.
  end.

end.
next-prev = ?.
end procedure.


 procedure ver-conf :
/* Получим из секции переоценок нужные переменные */
 define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
      ) no-error .

  assign
    increase-pc  = decimal (par-pr-incpc)
    round-method = par-pr-rndmt
    round-base   = decimal (par-pr-rndbs)
    no-error.
  case par-pr-rndmt:
    when "pr-round-9end" then
      round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      round-method = {&pr-round-integer}.
    when "pr-round-select" then
      round-method = {&pr-round-select}.
    when "pr-round-up" then
      round-method = {&pr-round-up}.
    when "pr-round-coef" then
      round-method = {&pr-round-coef}.
    when "pr-round-off" then
      round-method = {&pr-round-off}.
    otherwise
      round-method = {&pr-round-off}.
  end case.
  end procedure.

procedure  cre-line-temp :
define input parameter p-mode as character no-undo .
define input parameter p-gds-code  like ub.bar-code.gds-code    no-undo .
define input parameter p-node-code like ub.bar-code.node-code   no-undo .

if p-mode = "gds-list":u then do:
  for each temp-gds-list : delete temp-gds-list. end.

  for each gds-list no-lock where by  recid(gds-list) :
      find  first ub.gds-prt no-lock where
                ub.gds-prt.upper-code = gds-list.prt-root no-error .
      find  first ub.bar-code no-lock where
                ub.bar-code.gds-code  = gds-list.gds-code and
                ub.bar-code.node-code = ub.gds-prt.node-code and
                ub.bar-code.in-code   = "" and
                ub.bar-code.part-code = "" and
                ub.bar-code.unit-cli  = gds-list.unit-base
                no-error .
    if avail ub.bar-code  and avail ub.gds-prt then do :
        create temp-gds-list.
        assign
            v-n-n = v-n-n + 1
            temp-gds-list.gds-code  = ub.bar-code.gds-code
            temp-gds-list.node-code = ub.bar-code.node-code
            temp-gds-list.n-n = v-n-n.
    end.
  end.
end.
if p-mode = "one":u then do:
    create temp-gds-list.
    assign
        v-n-n = v-n-n + 1
        temp-gds-list.gds-code  = p-gds-code
        temp-gds-list.node-code = p-node-code
        temp-gds-list.n-n = v-n-n.
end.
end procedure.
{ gbl/tax-name.i }

procedure add-price-line :

find current p-doc no-error .
if error-status:error then return no-apply.
assign
  line-mode = {&add-def}
  notes = ''
  lns-cnt = 1.

for each gds-list :
   delete gds-list.
end.

if NOT ( calc-method = {&pr-calc-wbill} or
      calc-method = {&pr-calc-wbill-novat} or
      calc-method = {&pr-calc-slt-wbill} or
      calc-method = {&pr-calc-ov} )
Then do:
    run str/chsgdsls.w (
        parParentProc ,
        input "price-list" ,
        input "Строка пер. № " + p-doc.doc-num + " " + p-doc.status_  , ? , ? ,
        input p-doc.host-code,
        input-output varschartic,
        output ref-list,
        output table tt-gds-list, false ) no-error.
end.

assign lns-cnt = 0.
run cycle-add in this-procedure .
run ui-on in this-procedure .
end procedure. /* add-price-line */


procedure cycle-add:
define buffer ggg_price-list  for ub.price-list .
define variable stp-cycl as logical no-undo .

stp-cycl = false .
for each tt-gds-list no-lock  by tt-gds-list.nn :
  lns-cnt  =  lns-cnt + 1 .
  if lns-cnt > 1 then assign line-mode = "ЦИКЛ":u.
  find ub.goods where ub.goods.gds-code = tt-gds-list.gds-code no-lock.
  find ub.gds-prt where ub.gds-prt.upper-code = ub.goods.prt-root no-lock.

  find ub.bar-code no-lock where
       ub.bar-code.gds-code  = ub.goods.gds-code and
       ub.bar-code.node-code = ub.gds-prt.node-code and
       ub.bar-code.part-code = "" and
       ub.bar-code.in-code   = "" and
       ub.bar-code.unit-cli  = ub.goods.unit-base.
  run cre-line in this-procedure (ub.bar-code.b-code) no-error.
  if error-status:error then do:   next.     end.

  doc-rec = recid(p-doc) .
  find first ggg_price-list where recid(GGG_price-list) =  new-pr-recid  no-lock no-error .
   /* корректировка созданных */
   if error-status :error then next .
  if avail ggg_price-list then do :
  run calc-pr-list in this-procedure (input ub.bar-code.b-code,
                    input p-doc.doc-num,
                    input calc-method,
                    input increase-pc,
                    input round-method,
                    input round-base,
                    input ? ,
                    input ? ,
                    input ? ,
                    input ? ,
                    output line-rec) no-error.
             if error-status:error then   next.
  end.
  if  ( calc-method = {&pr-calc-no}
        or
      ( calc-method <> {&pr-calc-no}
        and ggg_price-list.price-sale = ?
        and calc-method <> {&pr-calc-fix}  ))
      then do:
        run str/pr-form.w (
                      input  parParentProc ,
                      input  line-mode   ,
                      input  doc-rec    ,
                      input  new-pr-recid ,
                      input increase-pc ,
                      input round-method,
                      input round-base,
                      input calc-method,
                      output stp-cycl ) no-error .

                      if error-status :error then message error-status :error error-status :get-message(1) 111.
                      if return-value = "error" then do:
                                  find first ggg_price-list where recid(ggg_price-list) = new-pr-recid no-error .
                                  if avail ggg_price-list then
                                     run del-pr-list in this-procedure ( input ggg_price-list.b-code,
                                                        input ggg_price-list.doc-num,
                                                        input round-method,
                                                        input round-base) no-error.
                      end.
        find p-doc where recid(p-doc) = doc-rec no-error .
        if  stp-cycl = true then leave.
  end.
  assign lns-cnt = lns-cnt + 1 .
end.
end procedure.

procedure cr-button :
 do
 on error undo, return error return-value
 :
define variable  but1  as widget-handle.
   create button but1
   assign
      row = 1
      column = 53
      HEIGHT-CHARS = 1
      WIDTH-CHARS = 8
      label = "СортПН"
      tooltip = "Сортировка по порядку ввода накладной"
      frame = frame {&frame-name}:handle
      sensitive = true
      visible = true
        triggers:
          on choose persistent run op.
        end triggers.
 end. /* do */
end procedure. /* cr-button */



procedure op :
 do
 on error undo, return error return-value
 :
define buffer temp-doc-line   for ub.doc-line .
define buffer temp-price-list for ub.price-list .
define variable number-trn-doc as character no-undo .
define variable t-ok as logical no-undo .

 number-trn-doc  = p-doc.out-code .
 if number-trn-doc = "" or number-trn-doc = ? then do:
    message "Невозможно определить номер ПН для сортировки товаров !!! " .
    return.
    end.


 t-ok = true .

 message "Хотите отсортировать переоценку по порядку ввода накладной № " number-trn-doc
         " ?" view-as alert-box question  buttons yes-no update t-ok .
 if t-ok = false then return.

define variable n-num as integer no-undo .
n-num = 0 .
for each temp-doc-line no-lock where temp-doc-line.doc-code = number-trn-doc by temp-doc-line.line-num :
    for each  temp-price-list  exclusive-lock
                    where temp-price-list.doc-num    = p-doc.doc-num and
                          temp-price-list.price-type = "" and
                          temp-price-list.artic = temp-doc-line.artic and
                          temp-price-list.prod-type = temp-doc-line.prod-type and
                          temp-price-list.prod-code = temp-doc-line.prod-code
                          by temp-price-list.main-price DESCENDIN
                          by temp-price-list.b-code
                          :
        n-num = n-num + 1 .
        assign
          temp-price-list.line-num  = n-num
        .
    end.
end.


&scop dif-cond
 {&open-query-br-list}
            by ub.price-list.line-num .
run value-changed-br-list.


 end. /* do */
end procedure. /* op */



procedure run-help :
 do
 on error undo, return error return-value
 :
 define variable v-message-text as character no-undo .
 define variable t-m  as character no-undo .
/* Схемы реализованные на данный момент: */
/*
'Товар':U,            {&pr-calc-goods},
'Учетная':U,          {&pr-calc-cost},
'Учет-объект':U,      {&pr-calc-costobj},
'Учет-резерв':U,      {&pr-calc-rsrv},
'Приходная':U,        {&pr-calc-last},
'Прих-объект':U,      {&pr-calc-lastobj},
'Старая':U,           {&pr-calc-old},
'Новая':U,            {&pr-calc-new},
'Объект':U,           {&pr-calc-obj},
'Накладная':U,        {&pr-calc-wbill},
'Переоценка':U,       {&pr-calc-ov},
'Накл-безНДС':U,      {&pr-calc-wbill-novat},
'Учет-безНДС':U,      {&pr-calc-cost-novat},
'Стар-безНДС':U,      {&pr-calc-old-novat},
'Единая':U,           {&pr-common},
'Отсутствует':U,      {&pr-calc-no},
'Не-считать':U        {&pr-calc-fix}
*/
case calc-method :
  when {&pr-calc-cost} then  assign  t-m =
   {&new-line} + "для товара: средняя учетная цена товара на фирме                                " +
   {&new-line} + "            (с учетом товара зарезервированного за незакрытыми документами)     " +
   {&new-line} + "для услуги: учетная цена услуги на фирме неопределена                           "
  .
  when  {&pr-calc-costobj}  then  assign  t-m =
   {&new-line} + "для товара: средняя учетная цена товара на объекте                               " +
   {&new-line} + "            (c учетом товара зарезервированного                                  " +
   {&new-line} + "            за незакрытыми документами -                                         " +
   {&new-line} + "             и партии свободной зоны, и резерв документов)                       " +
   {&new-line} + "для услуги: возвращается учетная цена по объекту                                 "
  .
  when {&pr-calc-rsrv}     then  assign  t-m =
   {&new-line} + "для товара: средняя учетная цена товара на объекте                                " +
   {&new-line} + "            (без учета товара зарезервированного                                  " +
   {&new-line} + "            за незакрытыми документами - только партии свободной зоны)            " +
   {&new-line} + "для услуги: возвращается учетная цена по объекту                                  "
  .
  when {&pr-calc-last}     then  assign  t-m =
   {&new-line} + "для товара: цену последнего прихода по фирме                                       " +
   {&new-line} + "для услуги: цена последнего прихода услуги по фирме не определена                  "
  .
  when {&pr-calc-lastobj}  then  assign  t-m =
   {&new-line} + "для товара: цену последнего прихода по объекту                                     " +
   {&new-line} + "для услуги: цена последнего прихода услуги по объекту не определена                "
  .

     otherwise do:
        assign  t-m =  "МЕТОД НЕ ОПИСАН !!!!"       .

     end.

end case.

 v-message-text ="Название метода :  -" + calc-method + "-" + {&new-line} +
 "Описание : " + {&new-line}   + t-m
   .
 run gbl/d-prompt.w (
    'title=Описание метода расчета\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + 'readonly=yes\'
  , input-output v-message-text).


 end. /* do */
end procedure. /* run-help */



procedure proc-cost-price-fact :
 do
 on error undo, return error return-value
 :

define input parameter  p-bar-code as integer   no-undo .
define input parameter  p-gds-code as integer   no-undo .
define input parameter  p-status_  as character no-undo .
define input parameter  p-r-b      as character no-undo .
define output parameter par-summa  as decimal   no-undo .

define variable v-total-avrg-base  as decimal no-undo .
define variable v-total-avrg-rubl  as decimal no-undo .
define variable v-total-avrg-qnty  as decimal no-undo .

define buffer buf_goods for ub.goods.
define buffer buf_parts for ub.parts.

define variable p-price-base as decimal no-undo .
define variable p-price-rubl as decimal no-undo .

find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .


 if p-status_ <> {&act-overvalue} then do:
      for each buf_parts no-lock
        where  buf_parts.obj-type  = p-doc.obj-type
          and buf_parts.obj-code   = p-doc.obj-code
          and buf_parts.artic      = buf_goods.artic
          and buf_parts.prod-type  = buf_goods.prod-type
          and buf_parts.prod-code  = buf_goods.prod-code
          and buf_parts.status_    = no
          and ( buf_parts.out-code  = {&free-code} )
      on error undo, return error
      :
        assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.
      if v-total-avrg-qnty > 0 then do:
        assign
          p-price-base = ( v-total-avrg-base / v-total-avrg-qnty )
          p-price-rubl = ( v-total-avrg-rubl / v-total-avrg-qnty )
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
 end.

 else do:

 define variable p-attr-value as character no-undo .
       run view-price-list-attr in this-procedure (
            input   {&cost-price-fact}  ,
            input   p-bar-code          ,
            input   p-doc.doc-num       ,
            input   ""                  ,
            output  p-attr-value   )
            .

           if not ( p-attr-value = ? or p-attr-value = "" )  then
              assign
                p-price-rubl = decimal(p-attr-value)
                p-price-base = decimal(p-attr-value)
              .
 end.


 if p-r-b = "rubl":u then
    par-summa = p-price-rubl.
    else
    par-summa = p-price-base.

 end. /* do */
end procedure. /* proc-cost-price-fact */