/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма ввода заказа

Автор: Чернова Светлана Александровна
Дата создания: 01/30/01
Author: Svetlana Chernova
Creation date: 01/30/01

*/

/* ***************************  definitions  ************************** */

define input parameter ParParentProc as widget-handle no-undo .
define input parameter t-action      as character no-undo .
define input parameter g#type        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ввода заказа" .

{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&glob start-proc do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):

&scop s-with1 98
&scop s-with2 0.1
&scop fr-row  12.08
&scop fr-col  98


&scoped-define window-name current-window
&scoped-define frame-name dialog-frame

define variable curclivalue     as character initial ? no-undo.
define variable multdtypvalue   as character initial ? no-undo.
define variable v-dayship       as integer   no-undo .
define variable is-edoc-nn      as logical   no-undo .
define variable par-is-edoc-nn  as character no-undo .
define variable is-edi          as logical   no-undo .
define variable par-is-edi      as character no-undo .
define variable is-edoc-nn-doc  as logical   no-undo .
define variable is-edi-doc      as logical   no-undo .
define variable v-err           as logical   no-undo .
define variable head-col        as character no-undo .
define variable v-order-column  as character no-undo .
define variable v-spis-size     as character no-undo .
define variable v-spis-vis      as character no-undo .
define variable hcolumn         as handle extent 100  no-undo.

define variable curclitype   as character no-undo .
define variable multdtyptype as character no-undo .
define variable loc-sum-rcv  as decimal   no-undo .

define variable var-f-prt         as logical   no-undo .
define variable v-i-doc           as character no-undo .
define variable is-error          as logical   no-undo .
define variable is-em             as character no-undo .
define variable t5                as decimal   no-undo .
define variable v-ok              as logical   no-undo .
define variable varcontract       as character no-undo .
define variable v-mastc           as logical   no-undo .
define variable varcontract-type  as character no-undo .
define variable v-dm-edi    as integer   no-undo .

define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date
.

define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ gbl/flt-def.i      }
{ cmp/r-pril.i  new  }
{ cmp/r-page1.i new  }
{ cus/df-zakaz.i new }
{ gbl/color.i        }
{ str/lib-trn.i      }
{ str/libbcrcn.i     }
{ gbl/waitfram.i     }
{ ref/grp-attr.i     }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/usr-flt.i      }
{ gbl/getsect.i  def }
{ ref/extclass.i     }
{ gbl/key-rec.i      }
{ gbl/clntattr.i     }
{ gbl/ggoattr.i      }
{ str/vrclvmd.i      }
{ ref/gdsoattr.i     }
{ cus/vcopm.i        }
{ cus/str-edi.i      }
{ str/cont-ms-def.i  }
{ str/cntrcode.i     }


define variable v-cntxt-host-name-obj  as character no-undo .

define  shared variable rep-rec   as recid     no-undo .
define  shared variable list-mode as character no-undo .
define  shared variable doc-rec   as recid     no-undo .

define variable notes                     as character no-undo . /* ? shared */
define variable v-update-price            as integer   no-undo .
define variable v-deliv-type-code         as integer   no-undo .
define variable v-point-obj-code          as integer   no-undo .
define variable v-point-cli-code          as integer   no-undo .
define variable v-point-obj-db-num        as integer   no-undo .
define variable v-point-cli-db-num        as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type      as character no-undo .
define variable v-transport-cli-code      as integer   no-undo .
define variable v-transport-contract      as integer   no-undo .
define variable v-transport-condition     as integer   no-undo .
define variable v-transport-value         as decimal   no-undo .
define variable v-transport-sum           as decimal   no-undo .
define variable v-transport-vat           as decimal   no-undo .
define variable v-num                     as integer   no-undo .
define variable v-error                   as logical   no-undo .

define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable line-rec    as recid no-undo . /* - */
define variable gds-rec     as recid no-undo . /* - */
define variable prt-rec     as recid no-undo . /* - */

define variable flt-rec      as recid     no-undo .
define variable g#report-num as integer   no-undo .
define variable next-prev    as logical   no-undo .
define variable g#log        as logical   no-undo .

define variable ref-rec      as recid     no-undo .
define variable base-code    as integer   no-undo .
define variable g#out-pay    as integer   no-undo .
define variable g#stat       as character no-undo .
define variable prt-mode     as character no-undo .


{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code  v-cntxt-host-code-obj v-cntxt-host-name-obj }
run get-report-num  in parParentProc ( output g#report-num ).

{ gbl/basecode.i v-cntxt-host-code-obj base-code }
{ cus/ord-code.i def }

define buffer l-shar_ord-line for ub.ord-line.
define buffer buf_ord-line-attr for ub.ord-line-attr.
define variable store-type as character no-undo .
define variable store-code as integer   no-undo .
assign
  store-type = v-cntxt-obj-type
  store-code = v-cntxt-obj-code
  loc-store-type = v-cntxt-obj-type
  loc-store-code = v-cntxt-obj-code
.

define shared variable x-mode as character  no-undo .

define buffer buf-units for ub.units.
define buffer for-cli   for ub.clients.
define buffer for-obj   for ub.clients.

define variable p-doc-code like ub.ord-line.doc-code no-undo .

&scop if-not-true ~
 if not g#log then return no-apply.

&scop excel-visable ~
  assign ~
    chexcelapplication:interactive = true ~
    chexcelapplication:screenupdating = true ~
    chexcelapplication:visible = true .

&scop excel-invisable ~
  assign ~
    chexcelapplication:interactive = false  ~
    chexcelapplication:screenupdating = false  ~
    chexcelapplication:visible = false  .

&glob rezalt "Результат"
define variable tmp-rec    as recid   no-undo.
define variable choice     as logical no-undo  init ? .
define variable var#import as logical no-undo  init false .
define buffer l-ord-line for ub.ord-line .
define variable last-curr-code like ub.currency.curr-abbr no-undo.
define variable cli-name       like ub.clients.obj-name   no-undo.
define variable gds-name       like ub.goods.gds-name     no-undo.
define variable unit-base      like ub.goods.unit-base    no-undo.

define stream cg-stream.
define variable date_string as character no-undo.
define variable line        as character no-undo.
define variable for-time    as character no-undo.
define variable producer    as character no-undo.

define variable filter-point as character no-undo init "cli-zakz-new" .
define variable filter-label as character no-undo init "Заказ_поставщику_new" .
define variable sort-column-name as character no-undo .
define variable t#query-was-opened as logical init false no-undo .

define variable rep-rec2 as recid   no-undo .
define variable rep-rec3 as recid   no-undo .
define variable t-ret    as logical no-undo .
define variable x-prod-type like ub.goods.prod-type no-undo .
define variable x-prod-code like ub.goods.prod-code no-undo .
define variable x-artic     like ub.goods.artic     no-undo .
define variable v-fl     as logical no-undo .
define variable jj       as integer no-undo .

define variable a-n-c as character view-as radio-set horizontal radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 12 by 1 no-undo.
define variable loc-art  as character  format "x(10)":u label "Нач.артик." view-as fill-in size 14 by 1 fgcolor red_color no-undo .
define variable loc-name as character  label "Нач.назв."  view-as fill-in size 14 by 1 fgcolor red_color  no-undo.
define variable loc-code as character  format "x(14)":u label "Бар-код" view-as fill-in  size 14 by 1 fgcolor red_color  no-undo.

define variable base-abbr as character format "x(3)":u
      view-as text
     size 4 by 1 no-undo.

define variable v-copy-doc-code as character no-undo .

/* ********************  preprocessor definitions  ******************** */

&scoped-define procedure-type dialog-box

/* name of first frame and/or browse and/or first query                 */
&scoped-define frame-name dialog-frame
&scoped-define browse-name br-docs

/* internal tables (found by frame, query & browse queries)             */
&scoped-define internal-tables shar_ord-line

/* definitions for browse br-docs                                       */

&scoped-define enabled-fields-in-query-br-docs shar_ord-line.cli-qnty shar_ord-line.cli-art
&scoped-define field-pairs-in-query-br-docs~
 ~{&fp1}cli-qnty ~{&fp2}cli-qnty ~{&fp3}~
 ~{&fp1}cli-art ~{&fp2}cli-art ~{&fp3}
&scoped-define enabled-tables-in-query-br-docs shar_ord-line tmp#zakaz
&scoped-define first-enabled-table-in-query-br-docs shar_ord-line
&scoped-define self-name br-docs
&scoped-define open-query-br-docs open query {&self-name} for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,~
each tmp#zakaz where ~
tmp#zakaz.artic = shar_ord-line.artic and ~
tmp#zakaz.prod-type = shar_ord-line.prod-type and ~
tmp#zakaz.prod-code = shar_ord-line.prod-code /*outer-join*/ .

&scoped-define open-query-br-docs-sort open query {&self-name} for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,~
each tmp#zakaz where ~
tmp#zakaz.artic = shar_ord-line.artic and ~
tmp#zakaz.prod-type = shar_ord-line.prod-type and ~
tmp#zakaz.prod-code = shar_ord-line.prod-code

&scoped-define tables-in-query-br-docs shar_ord-line tmp#zakaz
&scoped-define first-table-in-query-br-docs shar_ord-line


/* definitions for dialog-box dialog-frame                              */

/* standard list definitions                                            */
&scoped-define enabled-objects b-exit r-clients  loc-cli-code ~
wrkr  r-wrkr  agnt r-agnt loc-date-ship boss r-boss ~
br-docs b-import b-export  b-add b-way  b-main-calc b-spec ~
b-del  b-chg b-producer b-sch b-alt-post b-gds-prt    b-remove b-renum  b-mark ~
b-help loc-obj-name wrkr-name agnt-name boss-name ~
prod-name goods-name tog-type  t t-auto a-n-c b-contract B-protocol

&scoped-define displayed-objects loc-cli-type loc-cli-code wrkr  ~
agnt loc-date-ship boss  loc-obj-name wrkr-name ~
agnt-name boss-name prod-name goods-name tog-type  t t-auto

/* definitions for browse br-docs-2                                     */
&scoped-define fields-in-query-br-docs-2 ord-dtl.doc-code ord-dtl.node-code ord-dtl.cli-qnty ord-dtl.price-cli ord-dtl.sum-cli
&scoped-define enabled-fields-in-query-br-docs-2
&scoped-define field-pairs-in-query-br-docs-2
&scoped-define self-name br-docs-2
&scoped-define  open-query-br-docs-2 open query br-docs-2 for each tmp#zakaz-dtl no-lock where ~
tmp#zakaz-dtl.artic = x-artic and ~
tmp#zakaz-dtl.prod-type = x-prod-type and ~
tmp#zakaz-dtl.prod-code = x-prod-code .

&scoped-define tables-in-query-br-docs-2 ord-dtl
&scoped-define first-table-in-query-br-docs-2 ord-dtl

&scoped-define enabled-objects-all rect-4 rect-5  rect-7 rect-6 b-exit ~
doc-date fact-date paytype r-paytype r-contract b-contract B-protocol ~
wrkr tog-type  r-wrkr agnt r-agnt loc-date-ship ~
loc-service boss r-boss  loc-qnty loc-exch-code ~
r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc ~
loc-sum-rubl loc-base-rate loc-base-scale  loc-sum-base ~
loc-tot-lines  loc-sum-cli slt_type vat_type br-docs   ~
br-docs-2 b-add b-spec b-way b-del b-chg b-main-calc b-producer b-sch b-alt-post b-gds-prt b-notes  b-uf ~
b-remove  b-renum  b-mark  b-help b-itogs b-export b-import loc-obj-name wrkr-name e-method  a-n-c ~
loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2 loc-hour loc-min ~
doc-date

&scoped-define display-objects-all loc-cli-type loc-cli-code  doc-date fact-date paytype ~
wrkr tog-type  agnt r-agnt loc-date-ship ~
loc-service boss r-boss loc-qnty loc-exch-code ~
r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc ~
loc-sum-rubl loc-base-rate loc-base-scale loc-sum-base  loc-contract ~
loc-tot-lines  loc-sum-cli slt_type vat_type br-docs e-method ~
br-docs-2 loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto ~
date-sale-1 date-sale-2  loc-hour loc-min  b-contract B-protocol

&scoped-define assign-objects cycle-day loc-date-ship ~
loc-service date-sale-1 date-sale-2 loc-cli-out-doc doc-date

&scoped-define display-objects-of loc-cli-type loc-cli-code  doc-date fact-date  ~
wrkr tog-type  agnt r-agnt loc-date-ship ~
boss r-boss loc-qnty loc-cli-qnty loc-tot-lines  br-docs e-method ~
br-docs-2 loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name t-auto ~
date-sale-1 date-sale-2  loc-hour loc-min

&scoped-define enabled-objects-of rect-4 rect-5  rect-7 rect-6 b-exit ~
doc-date fact-date  B-protocol ~
wrkr tog-type  r-wrkr agnt r-agnt loc-date-ship ~
boss r-boss  loc-qnty loc-cli-qnty loc-tot-lines  br-docs ~
br-docs-2 b-add b-way b-del b-chg b-main-calc b-producer b-sch b-alt-post b-gds-prt b-notes b-uf ~
b-remove  b-renum  b-mark  b-help b-itogs b-export b-import loc-obj-name wrkr-name e-method  a-n-c ~
t agnt-name boss-name prod-name goods-name t-auto date-sale-1 date-sale-2 loc-hour loc-min

&scop label-clmn_1        tmp#zakaz.prt-ok
&scop label-clmn_2        tmp#zakaz.artic
&scop label-clmn_3        tmp#zakaz.gds-name
&scop label-clmn_4        tmp#zakaz.unit-cli
&scop label-clmn_5        tmp#zakaz.cli-qnty
&scop label-clmn_6        tmp#zakaz.price-cli
&scop label-clmn_7        tmp#zakaz.sum-cli
&scop label-clmn_8        tmp#zakaz.cli-art
&scop label-clmn_9        tmp#zakaz.unit-base
&scop label-clmn_10       tmp#zakaz.qnty
&scop label-clmn_11       tmp#zakaz.price-rubl
&scop label-clmn_12       tmp#zakaz.sum-rubl
&scop label-clmn_13       tmp#zakaz.temp-rash
&scop label-clmn_14       tmp#zakaz.qnty-sale
&scop label-clmn_15       tmp#zakaz.qnty-stk
&scop label-clmn_16       tmp#zakaz.min-stock
&scop label-clmn_17       (if tmp#zakaz.cancel-date = ? then '' else '*' )
&scop label-clmn_18       tmp#zakaz.line-num
&scop label-clmn_19       tmp#zakaz.gds-code
&scop label-clmn_20       tmp#zakaz.local-mark
&scop label-clmn_21       tmp#zakaz.order-cli-qnty
&scop label-clmn_22       tmp#zakaz.ord-dec1
&scop label-clmn_23       tmp#zakaz.initial-qnty
&scop label-clmn_24       tmp#zakaz.min-stock-old
&scop label-clmn_25       tmp#zakaz.gds-way

&scop label-clmn-lb_1   'ш! '
&scop label-clmn-lb_2   'Артикул! '
&scop label-clmn-lb_3   'Название! '
&scop label-clmn-lb_4   'Е.и.!пост'
&scop label-clmn-lb_5   'Заказ!ед.пост'
&scop label-clmn-lb_6   'Последн.цена!пост-ка'
&scop label-clmn-lb_7   'Сумма!ед.пост'
&scop label-clmn-lb_8   'Артикул!поставщика'
&scop label-clmn-lb_9   'Е.и.!баз.'
&scop label-clmn-lb_10  'Заказ! '
&scop label-clmn-lb_11  'Цена!({&abbr_rub})'
&scop label-clmn-lb_12  'Сумма!({&abbr_rub}) '
&scop label-clmn-lb_13  'Темп продаж!при расчете'
&scop label-clmn-lb_14  'Объем продаж!за период'
&scop label-clmn-lb_15  'Кол-во остатки!при расчете'
&scop label-clmn-lb_16  'Минимальный!запас'
&scop label-clmn-lb_17  'x! '
&scop label-clmn-lb_18  '№!п/п'
&scop label-clmn-lb_19  'Код!товара'
&scop label-clmn-lb_20  '*! '
&scop label-clmn-lb_21  'Запрошено!количество'
&scop label-clmn-lb_22  'Запрошена!цена'
&scop label-clmn-lb_23  'Расcчитн.!кол-во'
&scop label-clmn-lb_24  'Мин.!остаток'
&scop label-clmn-lb_25  'Тов.!в пути'
head-col =
  {&label-clmn-lb_20}     + '#' +
  {&label-clmn-lb_18}     + '#' +
  {&label-clmn-lb_1}      + '#' +
  {&label-clmn-lb_2}      + '#' +
  {&label-clmn-lb_3}      + '#' +
  {&label-clmn-lb_4}      + '#' +
  {&label-clmn-lb_5}      + '#' +
  {&label-clmn-lb_21}     + '#' +
  {&label-clmn-lb_6}      + '#' +
  {&label-clmn-lb_22}     + '#' +
  {&label-clmn-lb_7}      + '#' +
  {&label-clmn-lb_8}      + '#' +
  {&label-clmn-lb_9}      + '#' +
  {&label-clmn-lb_10}     + '#' +
  {&label-clmn-lb_11}     + '#' +
  {&label-clmn-lb_12}     + '#' +
  {&label-clmn-lb_13}     + '#' +
  {&label-clmn-lb_15}     + '#' +
  {&label-clmn-lb_17}     + '#' +
  {&label-clmn-lb_19}     + '#' +
  {&label-clmn-lb_23}     + '#' +
  {&label-clmn-lb_24}     + '#' +
  {&label-clmn-lb_25}
  .
/* ***********************  control definitions  ********************** */

define menu m-del
       menu-item m_del2         label "&1. Удалить отмеченные * товары" accelerator "alt-1"
       menu-item m_del4         label "&2. Удалить текущий товар" accelerator "alt-2"
       menu-item m_del3         label "&3. Удалить по списку товаров" accelerator "alt-3"
       menu-item m_del1         label "&4. Удалить товары с нулевым кол-вом " accelerator "alt-4" .

define menu m-export
       menu-item m_export_text  label "&1. Экспорт заказа в формат Моб.сканера" accelerator "alt-1"
       menu-item m_export_excel label "&2. Экспорт заказа в Еxcel" accelerator "alt-2"
       rule
       menu-item m_export_ras   label "&3. Экспорт предварительного расчета в Еxcel" accelerator "alt-3"  .

define menu m-import
       menu-item m_import_text  label "&1. Импорт из формата Моб.сканера" accelerator "alt-1"
       menu-item m_import_excel label "&2. Импорт из Excel" accelerator "alt-2"      .


define menu m-way
       menu-item m_way1         label "&1. Заказано до даты поставки по товару" accelerator "alt-1"
       menu-item m_way2         label "&2. Заказано на период продажи по товару" accelerator "alt-2"
       rule
       menu-item m_way3         label "&3. Заказано до даты поставки по всем товарам" accelerator "alt-2"
       menu-item m_way4         label "&4. Заказано на период продажи по всем товарам" accelerator "alt-4"       .

define menu m-spec
       menu-item m_spec1         label "&1. Добавление по спецификации"
       menu-item m_spec2         label "&2. Обновление по спецификации"  .


/* переменные шаренные  и батоны*/
DEFINE BUTTON B-protocol
     LABEL "Протокол"
     SIZE 10 BY 1 TOOLTIP "Протокол расчета заказа".

DEFINE BUTTON B-delivery
     LABEL "Доставка"
     SIZE 10 BY 1 TOOLTIP "Условия доставки".

define button b-alt-post
     label "Др&угие"
     size 8 by 1 tooltip "А что у других поставщиков?"
     bgcolor 8 .

define button b-del
     label "&Удал"
     size 8 by 1 tooltip "Удалить товары"
     bgcolor 8 .

define button b-spec
     label "Специ&фикация"
     size 16 by 1 tooltip "Добавить по спецификации договора"
     bgcolor 8 .


define button b-exit   auto-go
     label "Вы&ход"
     size 7 by 1 tooltip "Выход с сохранением"
     bgcolor 8 .

define button b-export
     label "&Экспорт"
     size 8 by 1 tooltip "Экспорт в разные форматы"
     bgcolor 8 .

define button b-gds-prt
     label "&Шкала"
     size 8 by 1 tooltip "Шкала"
     bgcolor 8 .

define button b-chg
     label "&Изм"
     size 8 by 1 tooltip "Изменить строку заказа.заявки"
     bgcolor 8 .

define button b-help
     label "Помо&щь"
     size 8 by 1 tooltip "Помощь"
     bgcolor 8 .

define button b-import
     label "Имп&орт"
     size 8 by 1 tooltip "Импорт из excel"
     bgcolor 8 .

define button b-add
     label "&Добав"
     size 8 by 1 tooltip "Добавить товары"
     bgcolor 8 .

define button b-way
     label "&В пути"
     size 8 by 1 tooltip "Список заказов товара в пути"
     bgcolor 8 .

define button b-itogs
     label "&Итоги"
     size 8 by 1 tooltip ""
     bgcolor 8 .

define button b-notes
     label "При&м":l
     size 8 by 1 tooltip "Изменить примечание к заказу.заявке".

define button b-uf
     image file "cmp/b-must.bmp":u
     tooltip "Настройка колонок в таблице для пользователя"
     SIZE 3 BY 1.


define button b-producer
     label "&Пр-ль"
     size 8 by 1 tooltip "Данные о Производителе"
     bgcolor 8 .


define button b-remove
     label "&х"
     size 3 by 1 tooltip "Проставить/снять пометку по товару, если его нет у Поставщика"
     bgcolor 8 .

define button b-mark
     label "&*":l
     size 3 by 1 tooltip "Проставить/снять пометку по товару, используется для удаления".

define button b-main-calc
     label "&Расчет"
     size 8 by 1 tooltip "Расчет заказа/заявки"
     bgcolor 8 .


define button b-sch
     label "&Фильтр"
     size 8 by 1 tooltip "Установка и снятие фильтра по записям"
     bgcolor 8 .


define button r-acc
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".

define button r-agnt
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".

define button r-boss
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".

define button r-clients
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-cli"
     size 3 by .88 tooltip "Выбор из списка".

define button r-currency
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88.

define button r-paytype
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-paytype"
     size 3 by .88 tooltip "Выбор из списка типа оплаты".

define button r-contract
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     size 3 by .88 tooltip "Выбор из списка договоров".


define button r-wrkr
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".

define button b-renum
     label "&№п/п"
     size 8 by 1 tooltip "Перенумеровать список товаров" .

define button b-contract
     image-up file "cmp/btn-fnd.bmp":u
     image-down file "cmp/btn-fnd.bmp":u
     image-insensitive file "cmp/btn-fnd.bmp":u no-convert-3d-colors
     label "b-contract"
     size 3 by 1 tooltip "Посмотреть До&говор".


define variable agnt-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.


define variable boss-name as character format "x(256)":u
     view-as text
     size 14 by 1 tooltip "Менеджер"
     fgcolor 4  no-undo.


define variable goods-name as character format "x(256)":u
     label "Наим."
      view-as text
     size 54.38 by .67 tooltip "Наименование товара"
     fgcolor 4  no-undo.

define variable loc-pay-type as character format "x(256)":u
      view-as text
     size 12.5 by .67 tooltip "Тип оплаты"
     fgcolor 4  no-undo.

define variable prod-name as character format "x(256)":u
     label "Пр.-ль"
      view-as text
     size 54.38 by .67 tooltip "Производитель товара"
     fgcolor 4  no-undo.

define variable t as character format "x(2)":u initial "дн"
      view-as text
     size 2 by 1 no-undo.


define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.

define variable t-auto as logical
     label "авто"
     view-as toggle-box
     size 7.25 by .83 tooltip "Рассчитывать заказ\заявку автоматически" no-undo.

define variable loc-obj-name-2 as character format "x(256)":u
      label "От"
      view-as text
      size 29 by .69 tooltip "От кого"
     fgcolor 4  no-undo.

/*---------------------------------------------------------------*/

define rectangle rect-4
     edge-pixels 2 graphic-edge  no-fill
     size 30.38 by 8.46.

define rectangle rect-5
     edge-pixels 2 graphic-edge  no-fill
     size 35.25 by 9.92.

define rectangle rect-6
     edge-pixels 2 graphic-edge  no-fill
     size 33.88 by 8.42.

define rectangle rect-7
     edge-pixels 2 graphic-edge  no-fill
     size 64.13 by 1.63.


/* query definitions                                                    */
define new shared query br-docs for
      shar_ord-line, tmp#zakaz  scrolling.

define query br-docs-2 for
      tmp#zakaz-dtl scrolling.
/* browse definitions                                                   */
define browse br-docs
  query br-docs no-lock display
   {&label-clmn_20}  column-label {&label-clmn-lb_20}   format "x(1)"
   {&label-clmn_18}  column-label {&label-clmn-lb_18}   format ">>>>"
   {&label-clmn_1}   column-label {&label-clmn-lb_1}    format "+/-"
   {&label-clmn_2}   column-label {&label-clmn-lb_2}
   {&label-clmn_3}   column-label {&label-clmn-lb_3}    format "x(50)"

   {&label-clmn_4}   column-label {&label-clmn-lb_4}    format "x(3)"
   {&label-clmn_5}   column-label {&label-clmn-lb_5}    format "->,>>>,>>9.999"
   {&label-clmn_21}  column-label {&label-clmn-lb_21}   format "->,>>>,>>>,>>9.999"
   {&label-clmn_6}   column-label {&label-clmn-lb_6}    format "->>>,>>>,>>9.99"
   {&label-clmn_22}  column-label {&label-clmn-lb_22}   format "->,>>>,>>>,>>9.99"
   {&label-clmn_7}   column-label {&label-clmn-lb_7}    format "->,>>>,>>>,>>9.99"
   {&label-clmn_8}   column-label {&label-clmn-lb_8}    format "x(16)"

   {&label-clmn_9}   column-label {&label-clmn-lb_9}     format "x(3)"
   {&label-clmn_10}  column-label {&label-clmn-lb_10}    format "->,>>>,>>9.999"
   {&label-clmn_11}  column-label {&label-clmn-lb_11}    format "->>>,>>>,>>9.99"
   {&label-clmn_12}  column-label {&label-clmn-lb_12}    format "->,>>>,>>>,>>9.99"
   {&label-clmn_13}  column-label {&label-clmn-lb_13}    format "->,>>>,>>>,>>9.99"
   {&label-clmn_15}  column-label {&label-clmn-lb_15}    format "->,>>>,>>>,>>9.99"
   {&label-clmn_17}  column-label {&label-clmn-lb_17}    format "x(1)"
   {&label-clmn_19}  column-label {&label-clmn-lb_19}
   {&label-clmn_23}  column-label {&label-clmn-lb_23}
   {&label-clmn_24}  column-label {&label-clmn-lb_24}
   {&label-clmn_25}  column-label {&label-clmn-lb_25}
  enable
      {&label-clmn_8}
    with no-assign  separators size-char {&s-with1}  by 8.54.

define browse br-docs-2
  query br-docs-2 no-lock display
      tmp#zakaz-dtl.prt-name   column-label "Признак! ":c8            format "x(16)"
      tmp#zakaz-dtl.cli-qnty   column-label "Заказ!ед.пост":c13       format "->>>,>>>,>>9.999"
      tmp#zakaz-dtl.price-cli  column-label "Цена!поставщика":c15     format "->>>,>>>,>>9.99"
      tmp#zakaz-dtl.sum-cli    column-label "Сумма! ":c6              format "->,>>>,>>>,>>9.99"
    with separators size-char {&s-with2} by 8.54 /* 35.25  by 8.54 */.


define frame dialog-frame
     b-exit at row 1.08 col 1
     loc-cli-type at row 1.08 col 11 colon-aligned
     loc-cli-code at row 1.08 col 15.13 colon-aligned no-label
     r-clients at row 1.08 col 27

     doc-date view-as fill-in    size 9 by 1 at row 8.5 col 8.38 colon-aligned
     fact-date at row 9.63 col 8.38 colon-aligned

     r-wrkr at row 2.21 col 31.63
     wrkr   at row 2.29 col 6 colon-aligned
     tog-type  at row 2.4 col 34.9
     cycle-day at row 2.4 col 55.5 colon-aligned
     t         at row 2.4 col 60.5 colon-aligned no-label

     loc-cli-out-doc at row 2.1 col 82.38 colon-aligned
     loc-pay-type    at row 3.1 col 82.38 colon-aligned no-label
     paytype         at row 3.1 col 73.25 colon-aligned
     r-paytype       at row 3.1 col 97

     r-agnt at row 3.13 col 31.63
     agnt at row 3.21 col 6 colon-aligned
     loc-date-ship at row 3.38 col 43 colon-aligned

     loc-service at row 4.08 col 83.63 colon-aligned
     r-boss at row 4.17 col 31.63
     boss at row 4.25 col 6 colon-aligned
     pay-day      at row 4.38 col 54.88 colon-aligned
     loc-out-code at row 5.38 col 52.75 colon-aligned
     date-sale-1  at row 4.38 col 51.25 colon-aligned
     date-sale-2  at row 5.38 col 51.25 colon-aligned
     loc-qnty at row 5.08 col 83.63 colon-aligned
     r-currency at row 5.29 col 31.63
     loc-exch-code at row 5.38 col 10.5 colon-aligned
     loc-cli-qnty at row 6.08 col 83.63 colon-aligned
     r-acc at row 6.29 col 31.63
     loc-exch-rate at row 6.42 col 10.63 colon-aligned
     loc-exch-scale at row 6.42 col 25.25 colon-aligned
     loc-sum-rubl at row 7.04 col 83.63 colon-aligned
     loc-sum-base at row 7.96 col 83.63 colon-aligned
     loc-sum-cli at row 8.92 col 83.63 colon-aligned
     loc-contract at row 9.88 col 78 colon-aligned
     r-contract   at row 9.88 col 97
     b-contract   at row 9.88 col 94
     e-method at row 7.08 col 35 no-label
     loc-base-rate at row 7.46 col 1.63
     loc-base-scale at row 7.46 col 25.25 colon-aligned

     loc-tot-lines at row 8.7 col 25 colon-aligned


     slt_type at row 10.96 col 72.75 colon-aligned
     vat_type at row 10.96 col 87.75 colon-aligned
     br-docs-2 at row {&fr-row} col {&fr-col}
     br-docs at row 12.08 col 1
     b-mark at row 20.71 col 1
     b-add at row 20.71 col 4
     b-del at row 20.71 col 12
     b-spec at row 21.71 col 12
     b-chg at row 20.71 col 20
     b-producer at row 20.71 col 28
     b-alt-post at row 20.71 col 36
     b-export at row 20.71 col 44
     b-import at row 20.71 col 52
     b-main-calc at row 20.71 col 60
     b-gds-prt at row 20.71 col 68
     b-way  at row 20.71 col 76

     b-sch at row 20.71 col 73 /* ? */
     b-notes at row 20.71 col 84
     b-uf at row 20.71 col 92
     b-help at row 20.71 col 92

     b-itogs  at row 21.71 col 1 /* ? */
     t-auto   at row 21.71 col 1
     b-delivery at row 21.71  col 28
     B-protocol at row 21.71  col 38
     loc-code at row 21.71 col 50 colon-aligned
     loc-name at row 21.71 col 50 colon-aligned
     loc-art  at row 21.71 col 50 colon-aligned
     a-n-c    at row 21.71 col 76 no-label
     b-remove at row 21.71 col 89
     b-renum  at row 21.71 col 92


     loc-obj-name at row 1.08 col 28.25 colon-aligned no-label
     loc-obj-name-2 at row 1.08 col 67.5 colon-aligned
     wrkr-name at row 2.33 col 17.63 no-label

     agnt-name at row 3.25 col 17.63 no-label
     boss-name at row 4.29 col 17.63 no-label
     ub.currency.curr-abbr at row 5.42 col 25.25 colon-aligned no-label
          view-as text
          size 4 by 1
          fgcolor 4
     prod-name at row 10.58 col 8.5 colon-aligned
     goods-name at row 11.29 col 8.5 colon-aligned
.
/* define frame statement is approaching 4k bytes.  breaking it up   */
define frame dialog-frame
     rect-6 at row 2.13  col 1
     rect-7 at row 10.46 col 1
     rect-5 at row 2.13  col 65
     rect-4 at row 2.13  col 34.75
     ":" view-as text
         size 1.25 by 1 at row 3.38 col 59.5
     loc-time-ship at row 3.38 col 54.88 colon-aligned no-label

     loc-min  at row 3.38 col 59.13 colon-aligned no-label
     loc-hour at row 3.38 col 53.88 colon-aligned no-label



     "Метод расчета заказа\заявки" view-as text
          size 27 by .67 at row 6.5 col 35.75

    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "ЗАКАЗ".

/* ***************  runtime attributes and uib settings  ************** */

assign
       frame dialog-frame:scrollable  = false
       frame dialog-frame:hidden      = true
       b-del:popup-menu in frame dialog-frame       = menu m-del:handle
       b-spec:popup-menu in frame dialog-frame      = menu m-spec:handle
       b-way:popup-menu in frame dialog-frame       = menu m-way:handle
       b-export:popup-menu in frame dialog-frame    = menu m-export:handle
       b-import:popup-menu in frame dialog-frame    = menu m-import:handle
       b-del:menu-mouse = 1
       b-spec:menu-mouse = 1
       b-way:menu-mouse = 1
       b-export:menu-mouse = 1
       b-import:menu-mouse = 1
       /*br-docs:num-locked-columns   in frame {&frame-name} = 4*/
       br-docs-2:num-locked-columns in frame {&frame-name} = 1

 .

/* &analyze-suspend _query-block browse br-docs */

/* ************************  control triggers  ************************ */

{ cus/ord-trgu.i }
{ cus/ord-lib.i last-price }
{ gbl/f2.i br-docs goods-recid init-gds-rec parParentProc }
ON CHOOSE OF b-protocol IN FRAME Dialog-Frame /* b-protocol */
DO:
  { gbl/stdbtn.i }
  run show-protocol in this-procedure .
END.

ON CHOOSE OF b-contract IN FRAME Dialog-Frame /* b-contract */
DO:
  { gbl/stdbtn.i }
  run show-contract-code in this-procedure .
END.

ON CHOOSE OF B-delivery IN FRAME Dialog-Frame /* Доставка */
DO:
  run cus/pardeliv.w
      (input        parParentproc
      ,input        if t-action = "lkp" then {&lookup} else t-action
      ,input        "ord" + g#type
      ,input        loc-store-type
      ,input        loc-store-code
      ,input        loc-cli-type
      ,input        loc-cli-code
      ,input-output v-deliv-type-code
      ,input-output v-point-obj-code
      ,input-output v-point-obj-db-num
      ,input-output v-point-cli-code
      ,input-output v-point-cli-db-num
      ,input-output v-transport-host-code
      ,input-output v-transport-cli-type
      ,input-output v-transport-cli-code
      ,input-output v-transport-contract
      ,input-output v-transport-condition
      ,input-output v-transport-value
      ,input-output v-transport-sum
      ,input-output v-transport-vat
         ) no-error  .
         if error-status :error then message
           vss-workfile vss-revision vss-description skip
           error-status :get-message(1) skip
           return-value skip
           "Ошибка"
           view-as alert-box error
         .

END.

/* Шкала ---------------------------------------------------------------------------------------------------------------*/
on choose of b-gds-prt in frame {&frame-name}
do:
run proc-gds-prt.
end.

on choose of b-renum in frame {&frame-name}
do:
run proc-renum.
end.

on choose of b-mark in frame {&frame-name}
do:
run proc-b-mark .
end.

/* Др.пост-ки ----------------------------------------------------------------------------------------------------------*/
on choose of b-alt-post in frame dialog-frame
do:
  run pp-1.
 end.


/* Удал -----------------------------------------------------------------------------------------------------------------*/
on choose of b-del in frame dialog-frame
do:
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl})   or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
    or  ( is-edi     and ( shar_ord-doc.ord-int1 = integer({&edi-ordrsp}) or shar_ord-doc.ord-int1 = integer({&edi-ordrsp-yes}))))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
    if choice = ? then do:
      run gbl/pop-up.p (self:handle, no) no-error.
      if error-status:error then return no-apply.
   end.
end.

/* Изм   ----------------------------------------------------------------------------------------------------------------*/
on choose of b-chg in frame dialog-frame
or mouse-select-dblclick of {&browse-name} in frame {&frame-name}
do:
 run proc_ch_b-chg.
end.

/* Добав ----------------------------------------------------------------------------------------------------------------*/
on choose of b-add in frame dialog-frame
do:
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
    or  ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.
   line-mode = {&add-def}.
   assign frame {&frame-name} loc-date-ship date-sale-1 date-sale-2 loc-service doc-date .
   run choose-menu-add2 in this-procedure.
end.

on choose of b-spec in frame dialog-frame
do:

end.


on choose of b-way in frame dialog-frame
do:
   if choice = ? then do:
        run gbl/pop-up.p (self:handle, no) no-error.
        if error-status:error then return no-apply.
    end.
end.

/* Произв-ль ------------------------------------------------------------------------------------------------------------*/
on choose of b-producer in frame dialog-frame
do:
run pp-2.
return no-apply.

end.
/* Фильтр ---------------------------------------------------------------------------------------------------------------*/
on choose of b-sch in frame dialog-frame
do:
   assign
        tbl = 'cli-gds,goods'
        join-tbl = 'tmp#zakaz,tmp#zakaz'
        fld = 'artic,cli-art,unit-cli,deadline,gds-name'
        lab = ',,,Срок хранения,название'
        spr = ',,unit,,'
        dim = '3,2'.
    do on stop undo, leave:
        run gbl/filter.w (input parparentproc,
        filter-point + {&delim-par} + filter-label + {&delim-par} + "yes",
        tbl, join-tbl, fld, lab, spr, dim).
        run openbr in this-procedure.
    end .
end.

/* export_excel ---------------------------------------------------------------------------------------------------------*/
on choose of menu-item m_export_excel
do:
  assign frame dialog-frame loc-date-ship date-sale-1 date-sale-2 loc-service .
  run b-export-ch  in this-procedure .
end.


/* export_text ----------------------------------------------------------------------------------------------------------*/
on choose of menu-item m_export_text
do:
   run proc_chg_m_export_text.
end.


on choose of menu-item m_export_ras
do:
run proc_export_ras.
end.

/* import_excel ---------------------------------------------------------------------------------------------------------*/
on choose of menu-item m_import_excel
do:
  run b-import-excel in this-procedure.
end.


/* import_text ----------------------------------------------------------------------------------------------------------*/
on choose of menu-item m_import_text
do:

run proc_import_text in this-procedure .
end.


/* 5. Удалить по списку товаров -----------------------------------------------------------------------------------------*/
on choose of menu-item m_del3
do:
run del-3 in this-procedure .
end.

on choose of menu-item m_del2
do:
  run del-2 in this-procedure .
end.

on choose of menu-item m_spec1
do:
  run spec1 in this-procedure .
end.

on choose of menu-item m_spec2
do:
  run spec2 in this-procedure .
end.


/* 5. Удалить по списку товаров -----------------------------------------------------------------------------------------*/
on choose of menu-item m_del4
do:
run proc-del4 in this-procedure no-error .
 if error-status :error then return no-apply.
end.



/* 5. Удалить по списку товаров -----------------------------------------------------------------------------------------*/
on choose of menu-item m_del1
do:
   run proc-menu-item-m_del1.
end.

/* Примечание -----------------------------------------------------------------------------------------------------------*/
on choose of b-notes in frame {&frame-name}
do:
 run proc-d-notes in this-procedure .
end.

ON CHOOSE OF b-uf IN FRAME {&frame-name} /* Редактирование броуса */
DO:
  run gbl/vi-coll.w ( input Parparentproc, input this-procedure , input {&uf-cli-zakz} + g#type , input  head-col ) .
END.

/* Не заказывать --------------------------------------------------------------------------------------------------------*/
on choose of b-remove in frame {&frame-name}
do:
run proc-b-remove.
end.

/* Итоги рассчитать ------------------------------------------------------------------------------------------------------*/
on choose of b-itogs in frame dialog-frame
do:
 run p-b-itogs in this-procedure no-error .
end.

/* Методы расчета -------------------------------------------------------------------------------------------------------*/
on choose of b-main-calc in frame dialog-frame
do:
 assign frame  {&frame-name} {&assign-objects} .


 run ver-date  in this-procedure .
 if return-value <> "" then return.

 if LOC-DATE-SHIP < to-day then do:
      message "Дата доставки меньше текущей !!! "
      view-as alert-box information .
      return  .
  end.

   find first tmp#zakaz no-error  .
     if avail tmp#zakaz then do:
     if e-method <> "" then do:
       message  "Заказ уже был рассчитан ! Вы хотите повторно пересчитать заказ ? "
       view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
     end.
     run cus/ord-m.w ( input PARPARENTPROC , input ? , input g#type ) .
     run openbr in this-procedure .
     enable  e-method with frame {&frame-name} .
     display e-method with frame {&frame-name} .
     end.
end.

/* ВЫХОД ----------------------------------------------------------------------------------------------------------------*/
on end-error, stop of frame {&frame-name}  do:
  apply "choose" to b-exit in frame {&frame-name} .
  return no-apply.
end.

on choose of b-exit in frame dialog-frame
do:
  t-ret =  session:set-wait-state("general") .
  run proc-b-exit no-error .
  if error-status :error then do:
     t-ret =  session:set-wait-state("") .
     if return-value = "no-calc"  then do:
        message "Заказ не был рассчитан !!! Вернитесь в режим расчета." view-as alert-box information .
        apply "choose" to b-main-calc in frame {&frame-name} .
        return no-apply .
     end.
     else do:
       return no-apply .
     end.
  end.
  else do:
      t-ret =  session:set-wait-state("") .
      apply "window-close" to self.
      return .
  end.
end.
/* ----------------------------------------------------------------------------------------------------------------------*/
on value-changed of t-auto in frame dialog-frame /* авто */
do:
  assign t-auto.
  if t-auto then apply "choose":u to b-main-calc .
end.


on choose of menu-item m_way1
do:
  run choose-menu-way1 in this-procedure.
end.

on choose of menu-item m_way2
do:
  run choose-menu-way2 in this-procedure.
end.

on choose of menu-item m_way3
do:
  run choose-menu-way3 in this-procedure.
end.

on choose of menu-item m_way4
do:
  run choose-menu-way4 in this-procedure.
end.

on window-close of frame dialog-frame /* ЗАКАЗ */
do:
  apply "end-error":u to self.
  return .
end.

on row-leave of br-docs in frame dialog-frame
do:
   run row-leave-br-doc.
end.
ON ROW-DISPLAY OF BR-DOCS  in frame dialog-frame
DO:
   run  row-display-br-doc.
end.
/* поиски по строке  */
{ str/sch-line.i shar_ord-line br-docs  line-rec  "l-shar_ord-line.doc-code = loc-ord-num and " }
end.

on value-changed of br-docs in frame dialog-frame
do:
   run select-good-scala .
end.

ON LEAVE OF date-sale-2 IN FRAME dialog-frame
DO:
 assign frame {&frame-name} loc-date-ship
                            date-sale-1
                            date-sale-2
                            doc-date
                            no-error .
  if error-status :error then
  message
    error-status :get-message(1) skip
    return-value skip
    "Не вверно введена дата"
    view-as alert-box error
  .
END.

ON LEAVE OF loc-contract IN FRAME dialog-frame
DO:
  assign
    loc-contract
  .

  run from-contract in this-procedure .
END.

ON  RETURN OF r-contract IN FRAME Dialog-Frame
DO:
    run apply-focus-next-entry in this-procedure  (input  r-contract:handle ) .
    return no-apply .
END.

ON  RETURN OF loc-cli-type IN FRAME Dialog-Frame
DO:
    run apply-focus-next-entry in this-procedure  (input  loc-cli-type:handle ) .
    return no-apply .
END.


ON MOUSE-SELECT-DBLCLICK, return, Ctrl-J OF loc-name IN FRAME {&frame-name} do:
  run my-proc-mouse-dbl-click-loc-name in this-procedure   no-error.
  return no-apply.
end.




/* ***************************  main block  *************************** */

if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.
{ gbl/app_help.i }

{ gbl/brwrefre.i "{&open-query-br-docs-sort} by tmp#zakaz.line-num ." }

{ gbl/ed_date.i loc-date-ship }
{ gbl/ed_date.i date-sale-1   }
{ gbl/ed_date.i date-sale-2   }
{ gbl/ed_date.i doc-date  }


{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &ext-col        = 25
  &start-column   = 5
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "{&label-clmn_1}"
  &sort-clmn_2    = "{&label-clmn_2}"
  &sort-clmn_3    = "{&label-clmn_3}"
  &sort-clmn_4    = "{&label-clmn_4}"
  &sort-clmn_5    = "{&label-clmn_5}"
  &sort-clmn_6    = "{&label-clmn_6}"
  &sort-clmn_7    = "{&label-clmn_7}"
  &sort-clmn_8    = "{&label-clmn_8}"
  &sort-clmn_9    = "{&label-clmn_9}"
  &sort-clmn_10   = "{&label-clmn_10}"
  &sort-clmn_11   = "{&label-clmn_11}"
  &sort-clmn_12   = "{&label-clmn_12}"
  &sort-clmn_13   = "{&label-clmn_13}"
  &sort-clmn_14   = "{&label-clmn_14}"
  &sort-clmn_15   = "{&label-clmn_15}"
  &sort-clmn_16   = "{&label-clmn_16}"
  &sort-clmn_17   = "{&label-clmn_17}"
  &sort-clmn_18   = "{&label-clmn_18}"
  &sort-clmn_19   = "{&label-clmn_19}"
  &sort-clmn_20   = "{&label-clmn_20}"
  &sort-clmn_21   = "{&label-clmn_21}"
  &sort-clmn_22   = "{&label-clmn_22}"
  &sort-clmn_23   = "{&label-clmn_23}"
  &sort-clmn_24   = "{&label-clmn_24}"
  &sort-clmn_25   = "{&label-clmn_25}"
  &label-clmn_1    = "{&label-clmn-lb_1}"
  &label-clmn_2    = "{&label-clmn-lb_2}"
  &label-clmn_3    = "{&label-clmn-lb_3}"
  &label-clmn_4    = "{&label-clmn-lb_4}"
  &label-clmn_5    = "{&label-clmn-lb_5}"
  &label-clmn_6    = "{&label-clmn-lb_6}"
  &label-clmn_7    = "{&label-clmn-lb_7}"
  &label-clmn_8    = "{&label-clmn-lb_8}"
  &label-clmn_9    = "{&label-clmn-lb_9}"
  &label-clmn_10   = "{&label-clmn-lb_10}"
  &label-clmn_11   = "{&label-clmn-lb_11}"
  &label-clmn_12   = "{&label-clmn-lb_12}"
  &label-clmn_13   = "{&label-clmn-lb_13}"
  &label-clmn_14   = "{&label-clmn-lb_14}"
  &label-clmn_15   = "{&label-clmn-lb_15}"
  &label-clmn_16   = "{&label-clmn-lb_16}"
  &label-clmn_17   = "{&label-clmn-lb_17}"
  &label-clmn_18   = "{&label-clmn-lb_18}"
  &label-clmn_19   = "{&label-clmn-lb_19}"
  &label-clmn_20   = "{&label-clmn-lb_20}"
  &label-clmn_21   = "{&label-clmn-lb_21}"
  &label-clmn_22   = "{&label-clmn-lb_22}"
  &label-clmn_23   = "{&label-clmn-lb_23}"
  &label-clmn_24   = "{&label-clmn-lb_24}"
  &label-clmn_25   = "{&label-clmn-lb_25}"
  &sort-column-name     = "sort-column-name"
  &open-query     = "{&open-query-br-docs-sort} BY ~{&sort-clmn_~{&clmn_num~}~} ."
  &open-query-otherwise = "{&open-query-br-docs-sort} by tmp#zakaz.line-num ."
  &re-move-clmn         = "no"
  &mv-brw-default       = "no" }

main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block :
  run local-conf-rd no-error.
  if error-status:error then return error.
  run make-obj-list no-error .

  if error-status:error then return error.
      tmp#zakaz.artic:RESIZABLE in browse {&browse-name} =  true .
      tmp#zakaz.gds-name:RESIZABLE in browse {&browse-name} =  true .
  if t-action <> "lkp":u then
    assign
      tmp#zakaz.cli-art   :read-only in browse {&browse-name} = /*  false */  true
      tmp#zakaz.cli-qnty  :read-only in browse {&browse-name} =  false
      tmp#zakaz.price-cli :read-only in browse {&browse-name} =  false
      no-error .
      if error-status :error then error-status :error = false .
 run mode-on in this-procedure .
  t#query-was-opened = true .
   if not (g#type = {&O-P} or g#type = {&O-F}) then do:
      tmp#zakaz.temp-rash:visible in browse {&browse-name} = false .
      tmp#zakaz.qnty-stk:visible  in browse {&browse-name} = false .
   end.


 v-fl = true .
 if t-action = "add":u  then  run enable_ui .
 if t-action <> "lkp":u then  run ui-on     .
 run edoc-edi-proc in this-procedure .

run init-browse-p  in this-procedure .
apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
{ gbl/mv-clmn.i
  &ext-col = 25
  &start-column = 1
  &frame-name = "{&frame-name}"
  &browse-name = "br-docs"
 &prev-order-column_1 = v-order-column
 &prev-order-column-condition_1 = " true = true "
 }

if tog-type = 4 then disable tog-type with frame {&frame-name} .
   else  v-ok = tog-type:disable("О") in frame {&frame-name} .

  if t-action = "add":u then do:
      if g#type = {&o-f} then do:
         frame {&frame-name}:visible = true .
           wait-for go of frame {&frame-name} focus  wrkr .
      end.
      else do:
           wait-for go of frame {&frame-name} focus loc-cli-code.
      end.
  end.
  else do:
    WAIT-FOR GO OF FRAME {&FRAME-NAME} focus {&browse-name} .
  end.
end.

run disable_ui  in this-procedure  .


/* **********************  internal procedures  *********************** */
procedure pp-1 :
 do
 on error undo, return error return-value
 :
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .

  if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.
 run cus/cli-othr.w (
 input tmp#zakaz.artic,
 input tmp#zakaz.prod-type,
 input tmp#zakaz.prod-code,
 input buf-cli.obj-type ,
 input buf-cli.obj-code ).


 end. /* do */
end procedure. /* pp-1 */


procedure pp-2 :
 do
 on error undo, return error return-value
 :
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .

  if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.

    run ref/showcli.p
    (input parparentproc
    ,input tmp#zakaz.prod-type /* p-obj-type */
    ,input tmp#zakaz.prod-code /* p-obj-code */
    ).


 end. /* do */
end procedure. /* pp-2 */

procedure proc-d-notes :
 do
 on error undo, return error return-value
 :
 find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   notes = shar_ord-doc.ps.
    /*run gbl/notes.w ( input {&update}, input-output notes ). */
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
    if shar_ord-doc.ps <> notes then do:
      do on stop undo, return error:
        find shar_ord-doc where recid (shar_ord-doc) = doc-rec exclusive-lock no-error .
        shar_ord-doc.ps = notes.
      end.
    end.
    find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.


 end. /* do */
end procedure. /* proc-d-notes */

procedure proc-del4 :
 do
 on error undo, return error return-value
 :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
    or  ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.

define variable ii as integer init 0 no-undo.
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .

  if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.

   if not avail tmp#zakaz then do:
   message "Не выбрана строка" view-as alert-box information .
   return error.
   end.

   if avail tmp#zakaz then do:
      message "Удалять товар " + tmp#zakaz.artic + ' ' +   tmp#zakaz.gds-name + " из заказа ? " skip "Продолжать?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                delete  tmp#zakaz     no-error.
            end.
      run openbr  in this-procedure  .
      end.


 end. /* do */
end procedure. /* proc-del4 */

procedure proc-menu-item-m_del1 :
 do
 on error undo, return error return-value
 :
find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
if available shar_ord-doc
and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
 or  ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
then do:
    message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
    return .
end.

define variable ii as integer init 0 no-undo.
   t-ret =  session:set-wait-state("general") .
   for each    tmp#zakaz  where
               tmp#zakaz.qnty = 0  or
               tmp#zakaz.qnty = ? :
       ii = ii + 1.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                delete  tmp#zakaz     no-error.
            end.
   end.
   t-ret =  session:set-wait-state("") .
   choice = ?.
   run openbr  in this-procedure  .
   message "Удалено " + string(ii) + " товаров".

 end. /* do */
end procedure. /* proc-menu-item m_del1 */

procedure proc-b-remove :
 do
 on error undo, return error return-value
 :
define variable tt-rec as recid no-undo .
  find current shar_ord-line  exclusive-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
   if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.

 tt-rec = recid (shar_ord-line) .

 if tmp#zakaz.cancel-date = ? then do :
  message "Товар " + tmp#zakaz.artic + ' ' +
   tmp#zakaz.gds-name
   + " больше не будет заказываться у Поставщика " + loc-obj-name + " ! " skip "  Вы уверены ?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
    tmp#zakaz.cancel-date = to-day.
    end.
  else do:
    message "Снять отметку с товара " + tmp#zakaz.artic + ' ' +
    tmp#zakaz.gds-name
    + " ? " skip "  Вы уверены ?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
    tmp#zakaz.cancel-date = ? .
  end.

 shar_ord-line.cancel-date = tmp#zakaz.cancel-date .
 find current shar_ord-line  no-lock  no-error .

  run openbr  in this-procedure  .
  reposition br-docs to recid tt-rec no-error.


 end. /* do */
end procedure. /* proc-b-remove */

procedure proc-b-exit :
 do
 on error undo, return error return-value
 :
define variable t-sum like tmp#zakaz.qnty no-undo .
define variable ord-qnty    as decimal    no-undo .
define variable ord-sum-cli as decimal    no-undo .
define variable k           as integer    no-undo .
define variable p-nabor     as logical    no-undo .
define variable v-list-new  as character  no-undo .

define buffer buf_contract for ub.contract.

next-prev = ?.

assign frame {&frame-name} tog-type cycle-day doc-date
.
if tog-type = 1 and cycle-day  = 0 then do:
   message "Внимание ! Задайте количество дней для цикличного заказа !" view-as alert-box .
   return error.
end.

run leave-loc-cli-code in this-procedure no-error .
if error-status :error then do:
    message "Документ будет удален"   view-as alert-box information .
    find first shar_ord-doc  exclusive-lock where shar_ord-doc.doc-code = loc-ord-num  no-error  .
    if available shar_ord-doc then  delete shar_ord-doc.
    return .
end.

if ( loc-cli-type = {&shop} or loc-cli-type = {&stock} ) and t-action <> "lkp":u then do:
    message "Неправильно задан КОНТРАГЕНТ !" loc-cli-type view-as alert-box.
    return error.
end.

run ver-clients  in this-procedure ( input loc-cli-type , input loc-cli-code , output v-err) .
if  v-err then return error.


define variable varcontract       as character no-undo .
define variable varcontract-type  as character no-undo .


if v-mastc = true then varcontract = "yes"  .

if v-mastc = true and loc-contract = 0 and
  ( g#type = {&o-p} or g#type = {&f-p} )
  then do:
    message "Не задан договор !" view-as alert-box.
    run r-contract-choose no-error .
    if error-status :error then return error.
end.
if loc-contract > 0 and ( g#type = {&o-p} or g#type = {&f-p} ) then do:
find first buf_contract no-lock where
           buf_contract.host-code = v-cntxt-host-code-obj and
           buf_contract.contract-code = loc-contract no-error .
    if available buf_contract  then do:
      if loc-exch-code  <> buf_contract.curr-code then do:
        message "Валюта договора не совпадает с валютой заказа !" skip loc-contract view-as alert-box error .
        return error.
      end.
      if loc-cli-code  <> buf_contract.cli-code or
        loc-cli-type  <> buf_contract.cli-type then do:
        message "Плательщик договора не совпадает с Контрагентом заказа !" skip loc-contract view-as alert-box error .
        return error.
      end.
    end.
end.



if loc-contract = 0 and ( g#type = {&o-p} or g#type = {&f-p} ) and tog-type = 4 then do:
define buffer buff_ord-doc-attr for ub.ord-doc-attr  .
define variable ev-exch-rate  as decimal   no-undo .
define variable ev-exch-scale as decimal   no-undo .
define variable ev-curr-abbr  as character no-undo .

  for each buff_ord-doc-attr no-lock where
           buff_ord-doc-attr.doc-code   begins  string( loc-ord-num + {&delim-par} ) and
           buff_ord-doc-attr.attr-code = {&orddocattr-cycle-exch-code} :
        if integer(buff_ord-doc-attr.attr-value) <> loc-exch-code then do:
          { gbl/exchrate.i
            integer(buff_ord-doc-attr.attr-value)
            today
            ev-exch-rate
            ev-exch-scale
            ev-curr-abbr
            no-error
            }
        message substitute("Валюта объединенного заказа должна совпадать с валютой заказов, вошедших в состав!&2 Валюта заказов &1.",ev-curr-abbr, {&new-line} )
                 view-as alert-box error .
        return error.
         end.
  end.
end.

define variable v-longchar as longchar no-undo .
define variable v-err-ext  as logical   no-undo .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define variable v-event-code as character no-undo .
v-err-ext  = false .

for each tmp#zakaz break by tmp#zakaz.cli-art :   /* проверки по строкам */
 /* Проверка спецификации */
  if loc-contract > 0 and  g#type  =  {&o-p}  then do:
      { str/ckcntspc.i
        v-cntxt-host-code-obj
        loc-contract
        tmp#zakaz.gds-code
        tmp#zakaz.price-cli
        VAT_type
        tmp#zakaz.VAT-pc
        no-error
      }
      if error-status :error then do:
        assign
          v-err-ext = true
          v-longchar = v-longchar + trim(return-value) + trim(error-status :get-message(1)) + {&new-line}
        .
      end.
  end.

/* проверка ИЖТ */
    if loc-doc-type <> {&p-o}  and
       loc-doc-type <> {&f-p}  then do:
       var-ok-assort-pol = true .
       v-event-code = loc-doc-type + "-" .
            { gbl/goassizt.i
              v-event-code
              tmp#zakaz.gds-code
              v-cntxt-obj-type
              v-cntxt-obj-code
              false
              var-ok-assort-pol
              var-mess-assort-pol
            }
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol + {&new-line} .
           end.
    end.

    if  loc-cli-type = {&shop} or
           loc-cli-type = {&stock} then do:
            var-ok-assort-pol = true .
            v-event-code = "cli_" + loc-doc-type + "-" .
            { gbl/goassizt.i
              v-event-code
              tmp#zakaz.gds-code
              loc-cli-type
              loc-cli-code
              false
              var-ok-assort-pol
              var-mess-assort-pol
            }
           if var-ok-assort-pol = false then do:
              v-err-ext  = true  .
              v-longchar = v-longchar + var-mess-assort-pol  + {&new-line} .
           end.
       end.

    if loc-doc-type = {&P-O}  then do:
        var-ok-assort-pol = true .
        v-event-code = loc-doc-type + "-" .
        { gbl/goassmat.i
          tmp#zakaz.gds-code
          v-cntxt-obj-type
          v-cntxt-obj-code
          false
          var-ok-assort-pol
          var-mess-assort-pol
        }
        if var-ok-assort-pol = false then do:
          v-err-ext  = true  .
          v-longchar = v-longchar + var-mess-assort-pol  + {&new-line} .
        end.
    end.


  /* проверка на букет */
   run ver-gds-flor ( input tmp#zakaz.gds-code , output p-nabor ) no-error .
   if p-nabor    = true then do:
      v-err-ext  = true  .
      v-longchar = v-longchar +
      substitute("Артикул &1 &2&3 &4 Является набором (букет) !!! Удалите его из списка товаров ! {&5} "  ,tmp#zakaz.artic, tmp#zakaz.prod-type ,tmp#zakaz.prod-code, tmp#zakaz.gds-name ,{&new-line}) .
   end.

  /* Проверка строк и признаков */
  t-sum = 0.
  for each tmp#zakaz-dtl where
      tmp#zakaz-dtl.artic     = tmp#zakaz.artic and
      tmp#zakaz-dtl.prod-type = tmp#zakaz.prod-type and
      tmp#zakaz-dtl.prod-code = tmp#zakaz.prod-code  :
      t-sum = t-sum + tmp#zakaz-dtl.qnty.
   end.

   if t-sum > tmp#zakaz.qnty then do:
      v-err-ext  = true  .
      v-longchar = v-longchar +
      substitute ("Количество по признакам больше чем по строке товара ! &1 &2&3 &4 (количества по признакам=&5 и по строке=&6)&7" ,tmp#zakaz.artic, tmp#zakaz.prod-type ,tmp#zakaz.prod-code, tmp#zakaz.gds-name ,t-sum,  tmp#zakaz.qnty, {&new-line}) .
   end.

/* Проверка внешних артикулов  */
define buffer bf2_ext-artic for ub.ext-artic  .
define buffer bf2_goods for ub.goods  .
define buffer bf3_goods for ub.goods  .
define buffer bf2_tmp#zakaz for tmp#zakaz  .

    if ( is-edoc-nn-doc = true and shar_ord-doc.ord-int1 = int({&edoc-empty}) )
    or ( is-edi-doc     = true and shar_ord-doc.ord-int1 = int({&edi-empty})  )
    then do:
      if tmp#zakaz.cli-art = ""
      or tmp#zakaz.cli-art = "0"
      or tmp#zakaz.cli-art = ?
      then do:
          v-err-ext = true .
          v-longchar = v-longchar +
          substitute( "Для данного контрагента, работающего по EDOC\EDI, для товара &1 &2&3 не указан внешний артикул"
        , tmp#zakaz.artic
        , tmp#zakaz.prod-type
        , tmp#zakaz.prod-code
        ) + {&new-line} .
      end.
    end.
    if tmp#zakaz.cli-art <> "" then do:
        for each bf2_ext-artic where
                 bf2_ext-artic.cli-type  = loc-cli-type  and
                 bf2_ext-artic.cli-code  = loc-cli-code  and
                 bf2_ext-artic.ext-artic = tmp#zakaz.cli-art   :

          if     bf2_ext-artic.gds-code     = tmp#zakaz.gds-code
          or     bf2_ext-artic.status_   = {&deleted-status} then next.
          leave.
        end.

        if available bf2_ext-artic then do:
          find first bf2_goods no-lock where
                    bf2_goods.gds-code = bf2_ext-artic.gds-code no-error .
          find first bf3_goods no-lock where
                    bf3_goods.gds-code =  tmp#zakaz.gds-code no-error .

                    v-err-ext = true .
                    v-longchar = v-longchar +
                    substitute( "Для данного контрагента уже есть товар &1 &2&3 &4 с таким же внешним артикулом &5 как у &6 &7&8 &9"
                  , bf2_goods.artic
                  , bf2_goods.prod-type
                  , bf2_goods.prod-code
                  , bf2_goods.gds-name
                  , tmp#zakaz.cli-art
                  , tmp#zakaz.artic
                  , tmp#zakaz.prod-type
                  , tmp#zakaz.prod-code
                  , bf3_goods.gds-name
                  ) +  {&new-line}.
        end.
    end.

    if last-of (tmp#zakaz.cli-art) then do:
       if tmp#zakaz.cli-art <> "" then do:
        for each bf2_tmp#zakaz where
                 bf2_tmp#zakaz.cli-art = tmp#zakaz.cli-art and
                 bf2_tmp#zakaz.gds-code <> tmp#zakaz.gds-code break by bf2_tmp#zakaz.cli-art :
                find first bf2_goods no-lock where
                          bf2_goods.gds-code = bf2_tmp#zakaz.gds-code
                          no-error .
                    v-err-ext = true .
                    if first-of(bf2_tmp#zakaz.cli-art) then do:
                        v-longchar = v-longchar +
                        substitute( "В заказе есть повторяющиеся артикулы Поставщика &1 товар &2 &3&4 &5:&6"
                      , tmp#zakaz.cli-art
                      , tmp#zakaz.artic
                      , tmp#zakaz.prod-type
                      , tmp#zakaz.prod-code
                      , tmp#zakaz.gds-name
                      ,  {&new-line}).
                    end.
                    v-longchar = v-longchar +
                    substitute( "- такой же артикул поставщика у товара &1 &2&3 &4 &5"
                  , bf2_goods.artic
                  , bf2_goods.prod-type
                  , bf2_goods.prod-code
                  , bf2_goods.gds-name
                  , {&new-line} ).
        end.
       end.
    end.
  end.

  if v-err-ext = true  then do:
      run gbl/d-longchar.w (
              ?,
              'Editor_row=2\':u
            + 'title=Проверка строк заказа\':u
            + 'Editor_col=1\':u
            + 'Editor_width=96\':u
            + 'Editor_height=21\':u
            + 'readonly=yes\':u
          ,input-output v-longchar
          ,output v-ok ) no-error .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "4"
            view-as alert-box error
          .
          assign
          v-longchar = '':U.
      define variable vq as logical   no-undo init true .
      message
      "При проверке была обнаружена ошибка!"
      "Остаться в заказе для исправления ?"
      view-as alert-box question
      button yes-no
      update vq
      .
      if vq then  return error .
    end.

  if can-find
    ( first tmp#zakaz  no-lock    where
      tmp#zakaz.qnty  =  0 or
      tmp#zakaz.qnty  =  ?
    ) 
  and not is-edi-doc
  then do:

      message "В заказе есть нерассчитанные строки . Удаляем их ? " view-as alert-box question  buttons yes-no update g#log.
       if g#log then do:
            assign
              ord-qnty = 0
              ord-sum-cli = 0
              k = 0
              .
            for each tmp#zakaz no-lock :
                    if not  (tmp#zakaz.qnty = 0  or  tmp#zakaz.qnty = ? ) then do:
                      assign
                        k = k + 1
                        ord-qnty = ord-qnty + tmp#zakaz.qnty
                        ord-sum-cli = ord-sum-cli + ( tmp#zakaz.qnty * tmp#zakaz.price-cli )
                        .
                    end.
                    else do:
                        find first shar_ord-line  exclusive-lock   where
                                    shar_ord-line.doc-code   =  loc-ord-num   and
                                    shar_ord-line.artic      =   tmp#zakaz.artic and
                                    shar_ord-line.prod-type  =   tmp#zakaz.prod-type and
                                    shar_ord-line.prod-code  =   tmp#zakaz.prod-code no-error .
                          delete shar_ord-line .
                          delete tmp#zakaz.
                    end.
            end. /* foreach*/
       end.
       else do:
         /* return no-apply. */
       end.
  end.
  if not can-find
    ( first tmp#zakaz  no-lock    where
      tmp#zakaz.qnty  <>  0 and
      tmp#zakaz.qnty  <>  ?
    )
  and is-edi-doc
  then do :
      message "В заказе все строки нерассчитанные. Такой заказ нельзя отправлять по EDI. Удаляем строки? " view-as alert-box question  buttons yes-no update g#log.
       if g#log then do:
            assign
              ord-qnty = 0
              ord-sum-cli = 0
              k = 0
              .
            for each tmp#zakaz no-lock :
                    if not  (tmp#zakaz.qnty = 0  or  tmp#zakaz.qnty = ? ) then do:
                      assign
                        k = k + 1
                        ord-qnty = ord-qnty + tmp#zakaz.qnty
                        ord-sum-cli = ord-sum-cli + ( tmp#zakaz.qnty * tmp#zakaz.price-cli )
                        .
                    end.
                    else do:
                        find first shar_ord-line  exclusive-lock   where
                                    shar_ord-line.doc-code   =  loc-ord-num   and
                                    shar_ord-line.artic      =   tmp#zakaz.artic and
                                    shar_ord-line.prod-type  =   tmp#zakaz.prod-type and
                                    shar_ord-line.prod-code  =   tmp#zakaz.prod-code no-error .
                          delete shar_ord-line .
                          delete tmp#zakaz.
                    end.
            end. /* foreach*/
       end. 
  end.  

   is-error = false  .
   is-em = "" .
   assign  frame {&frame-name} wrkr loc-exch-code
          agnt boss loc-date-ship loc-time-ship loc-service
          paytype  cycle-day tog-type pay-day loc-tot-lines
          date-sale-1 date-sale-2 loc-cli-out-doc doc-date
          no-error .
   if error-status:error then do:
     is-error = true .
     is-em = error-status :get-message(1) .
   end.
   if date-sale-1 = loc-date-ship then do:
     pay-day = date-sale-2 - date-sale-1  .
   end.
   else do:
     pay-day = date-sale-2 - date-sale-1 + 1 .
   end.
   run ver-date  in this-procedure .

   if ( is-edoc-nn-doc = false and shar_ord-doc.ord-int1 = int({&edoc-empty}) )
   or ( is-edi-doc     = false and shar_ord-doc.ord-int1 = int({&edi-empty})  )
   then do:
     find first shar_ord-line  no-lock  where
                shar_ord-line.doc-code   =  loc-ord-num   and
                shar_ord-line.artic      =   tmp#zakaz.artic and
                shar_ord-line.prod-type  =   tmp#zakaz.prod-type and
                shar_ord-line.prod-code  =   tmp#zakaz.prod-code no-error .
      if available shar_ord-line then do:
          run ver-clients-calc in this-procedure (
            input loc-cli-type
          , input loc-cli-code
          , input store-type
          , input store-code
          , input e-method
          , output v-err
          ) .
          if v-err then return error 'no-calc'.
      end.
      run ver-calc no-error .
      if error-status :error then do:
        is-error = true .
        is-em    =  substitute("Была корректировка рассчитанного заказа!&1Пересчитайте заказ  " , {&new-line}) .
        message "Документ не может быть сохранен в базу данных ! " skip
                is-em  skip
                view-as alert-box error  .
        return error return-value .
        /* не выходим из интерфейса */
      end.
   end.
   /* это проверка ошибок ввода assign */
   if is-error = true then do:
        message "Документ в базу не добавлен ! " skip
        is-em  skip
        return-value skip
        view-as alert-box information .
        error-status:error = false .
   end.
   else do:
     run full-recount in this-procedure no-error.
     run local-conf-rd in this-procedure .
     run cus/ord-save.p (
          input parParentProc ,
          input t-action ,
          input v-deliv-type-code   ,
          input v-point-obj-code    ,
          input v-point-cli-code    ,
          input v-point-obj-db-num  ,
          input v-point-cli-db-num  ,
          input v-transport-host-code    ,
          input v-transport-cli-type    ,
          input v-transport-cli-code    ,
          input v-transport-contract ,
          input v-transport-condition,
          input v-transport-value    ,
          input v-transport-sum      ,
          input v-transport-vat    ,
          input  if v-err-ext then false else is-edoc-nn-doc  , /* если были ошибки то еdoc не передается */
          input  if v-err-ext then false else is-edi-doc      , /* если были ошибки то еdoc не передается */
          input v-dm-edi                                      )
          no-error .
     if error-status :error then return error return-value .
   end.
 end. /* do */
end procedure. /* proc-b-exit */



procedure proc-b-mark :
 do
 on error undo, return error return-value
 :

define variable tt-rec as recid no-undo .
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first tmp#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
   if not avail tmp#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.

 tt-rec = recid (shar_ord-line) .

 if tmp#zakaz.local-mark = "*" then do :
    tmp#zakaz.local-mark = "".
    end.
  else do:
   tmp#zakaz.local-mark = "*" .
  end.

if {&browse-name}:refresh() in frame {&frame-name}  then.
reposition br-docs to recid tt-rec no-error.
g#log = br-docs:select-next-row () in frame {&frame-name}.
apply "entry" to br-docs in frame {&frame-name}.

 end. /* do */
end procedure. /* proc-b-mark */


procedure ver-gds-flor :
 do
 on error undo, return error return-value
 :
define input  parameter p-gds-code as integer   no-undo .
define output parameter  v-nabor   as logical   no-undo .

v-nabor = false .
   run ver-gds-grp-nabor( input p-gds-code, output v-nabor) .
end.
end procedure. /* ver-gds */


procedure chg-action :
{&start-proc}
define buffer buff_contract for ub.contract.

t-ret =  session:set-wait-state("general") .

 find first buf-cli where recid(buf-cli) = rep-rec no-lock no-error.
 find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
 p-doc-code  = shar_ord-doc.doc-code.
  if available shar_ord-doc then  do:
     find first for-obj where for-obj.obj-code = shar_ord-doc.obj-code and
                              for-obj.obj-type = shar_ord-doc.obj-type no-lock no-error .
     if error-status :error then return error.
    assign
      date-1 = shar_ord-doc.start-date
      date-2 = shar_ord-doc.end-date no-error .
      if error-status :error then
         assign
            date-1 = to-day - 7
            date-2 = to-day.
    assign
      loc-obj-name-2  = "(" + shar_ord-doc.obj-type + " " + string(shar_ord-doc.obj-code ) + ")" + for-obj.obj-name
      wrkr            = shar_ord-doc.wrkr
      agnt            = shar_ord-doc.agnt
      boss            = shar_ord-doc.boss
      loc-time-ship   = string(shar_ord-doc.ship-time,"hh:mm")
      loc-hour        = integer (entry(1,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      loc-min         = integer (entry(2,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      date-sale-1     = shar_ord-doc.date-sale-1
      date-sale-2     = shar_ord-doc.date-sale-2
      e-method        = shar_ord-doc.e-method
      temp-e-method   = e-method
      loc-date-ship   = shar_ord-doc.ship-date
      loc-status      = shar_ord-doc.status_
      paytype         = shar_ord-doc.pay-code
      loc-service     = shar_ord-doc.sum-service
      cycle-day       = shar_ord-doc.cycle-day
      pay-day         = shar_ord-doc.pay-day
      tog-type        = shar_ord-doc.order-type
      loc-base-rate   = shar_ord-doc.base-rate
      loc-base-scale  = shar_ord-doc.base-scale

      loc-cli-qnty    = shar_ord-doc.cli-qnty
      loc-qnty        = shar_ord-doc.qnty
      loc-sum-base    = shar_ord-doc.sum-base
      loc-sum-cli     = shar_ord-doc.sum-cli
      loc-sum-rubl    = shar_ord-doc.sum-rubl
      loc-tot-lines   = shar_ord-doc.tot-lines

      loc-exch-code         = shar_ord-doc.exch-code
      loc-exch-rate         = shar_ord-doc.exch-rate
      loc-exch-scale        = shar_ord-doc.exch-scale
      loc-out-code          = shar_ord-doc.out-code
      doc-date              = shar_ord-doc.doc-date
      loc-doc-type          = shar_ord-doc.doc-type
      fact-date             = shar_ord-doc.fact-date
      vat_type              = shar_ord-doc.vat-type
      slt_type              = shar_ord-doc.slt-type
      loc-print-rubl        = true
      loc-store-code        = shar_ord-doc.obj-code
      loc-store-type        = shar_ord-doc.obj-type
      v-deliv-type-code     = shar_ord-doc.deliv-type-code
      v-point-obj-code      = shar_ord-doc.obj-point-code
      v-point-cli-code      = shar_ord-doc.cli-point-code
      v-point-obj-db-num    = shar_ord-doc.obj-point-db-num
      v-point-cli-db-num    = shar_ord-doc.cli-point-db-num
      v-transport-host-code = shar_ord-doc.transport-host-code
      v-transport-cli-type  = shar_ord-doc.transport-cli-type
      v-transport-cli-code  = shar_ord-doc.transport-cli-code
      v-transport-contract  = shar_ord-doc.transport-contract
      v-transport-condition = shar_ord-doc.transport-condition
      v-transport-value     = shar_ord-doc.transport-value
      v-transport-sum       = shar_ord-doc.sum-ship
      v-transport-vat       = shar_ord-doc.transport-vat
      loc-cli-out-doc       = entry(1, shar_ord-doc.cli-out-doc, {&delim-par})
      .
      /* договор */
    find first buff_contract no-lock where buff_contract.host-code     = shar_ord-doc.host-code and
                                           buff_contract.contract-code = shar_ord-doc.contract-code no-error .
    if available buff_contract then
        assign
          loc-exch-code       = buff_contract.curr-code
          loc-contract        = buff_contract.contract-code
        .

      /* валюта поставщика */

      find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
        if available ub.currency then disp ub.currency.curr-abbr with frame {&frame-name}.
                              else disp ? @ ub.currency.curr-abbr with frame {&frame-name}.
   end.

/* оплата */
   find ub.pay-type where ub.pay-type.obj-code = shar_ord-doc.pay-code no-lock no-error.
   if available ub.pay-type then  do:
    assign
    loc-pay-type = ub.pay-type.obj-name  .
    end.

    if available buf-cli then
    assign
        loc-cli-code = buf-cli.obj-code
        loc-cli-type = buf-cli.obj-type
        loc-obj-name = buf-cli.obj-name
        .
     else
     assign
        loc-cli-code = ?
        loc-cli-type = ?
        loc-obj-name = ?
        .

    if t-action = "copy":u
       then do:

        { cus/ord-code.i
            'main'
            v-cntxt-db-num
            v-cntxt-obj-type
            v-cntxt-obj-code
            v-i-doc
            loc-ord-num
            }

       assign
          loc-status  = {&g___new}
          loc-date-ship = ?
          date-sale-2   = ?
          date-sale-1   = ?
       .
       end.
       else assign loc-ord-num = shar_ord-doc.doc-code
                   loc-status  = shar_ord-doc.status_  .

    find first clients-doc where clients-doc.obj-code = wrkr
                             and clients-doc.obj-type = {&prs} no-lock no-error.
         if  error-status :error then error-status :error = false .
        if avail clients-doc then do:
         wrkr-name = clients-doc.obj-name.
       end.

    find first clients-doc1 where clients-doc1.obj-code = agnt
                             and clients-doc1.obj-type = {&prs} no-lock no-error.
         if  error-status :error then error-status :error = false .
         if avail clients-doc1 then agnt-name = clients-doc1.obj-name.

    find first clients-doc2 where clients-doc2.obj-code = boss
                             and clients-doc2.obj-type = {&prs} no-lock no-error.
     if  error-status :error then error-status :error = false .
     if avail clients-doc2 then boss-name = clients-doc2.obj-name.
     if  error-status :error then error-status :error = false .

    /* Закрыть шапку для корректировки */
    disable loc-cli-code
            loc-cli-type
            loc-obj-name
            r-clients with frame {&frame-name}.
     display
        wrkr agnt boss
        wrkr-name agnt-name
        boss-name
        with frame {&frame-name}.
     /* создать временную таблицу */
  for each shar_ord-line where shar_ord-line.doc-code = shar_ord-doc.doc-code  no-lock :
     run create-tmp in this-procedure  (input "doc":u,"") no-error .
     if error-status :error then message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1)  skip
        "Ошибка вызова процедуры create-tmp"  skip
        .
  end.
  run create-tmp-dtl  .
  run openbr in this-procedure  .
  run enable_ui.
 t-ret =  session:set-wait-state("") .
end. /*start-proc*/
end procedure.

procedure create-tmp :
{&start-proc}
define input parameter tt as character no-undo.
define input parameter t  as character no-undo.

define variable prod-type#   like ub.ord-line.prod-type no-undo .
define variable prod-code#   like ub.ord-line.prod-code no-undo .
define variable artic#       like ub.ord-line.artic     no-undo .
define variable v-price-exel as decimal   no-undo .
define variable p-recid as recid no-undo .

define buffer buf_ord-dtl  for ub.ord-dtl.
define buffer ll-tmp#zakaz for tmp#zakaz .
define buffer bufff-units  for ub.units     .

 case tt :
    when "price":u  then do:
      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.host-code = v-cntxt-host-code-obj  and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.

            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else do:
                find first sb-cli-gds where
                      sb-cli-gds.artic     = ub.goods.artic      and
                      sb-cli-gds.prod-type = ub.goods.prod-type  and
                      sb-cli-gds.prod-code = ub.goods.prod-code  and
                      sb-cli-gds.host-code = v-cntxt-host-code-obj
                      no-lock no-error.
                      if available sb-cli-gds then p-recid = recid(sb-cli-gds).
                      else p-recid = ?.
            end.

            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                'proc-eq-tmp-price 67'
                view-as alert-box error .
            end.
       end.
    when "goods":u  then do:
      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.host-code = v-cntxt-host-code-obj  and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                232
                view-as alert-box error .
            end.
    end.

    when "gds-list":u  then do:
      find first ub.goods where
            gds-list.artic     = ub.goods.artic     and
            gds-list.prod-type = ub.goods.prod-type and
            gds-list.prod-code = ub.goods.prod-code no-lock no-error.
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! gds-list не = goods !"
                123
                view-as alert-box error .
            end.

      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = gds-list.artic      and
            sb-cli-gds.host-code = v-cntxt-host-code-obj         and
            sb-cli-gds.prod-type = gds-list.prod-type  and
            sb-cli-gds.prod-code = gds-list.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо !  Ошибка в proc-eq-tmp-price !"
                333
                view-as alert-box error .
            end.

    end.
    when "tt-gds-list":u  then do:
      find first ub.goods where
            ub.goods.artic     = tt-gds-list.artic     and
            ub.goods.prod-type = tt-gds-list.prod-type and
            ub.goods.prod-code = tt-gds-list.prod-code no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо ! tt-gds-list не = goods !"
                1
                view-as alert-box error .
            end.

      find  first sb-cli-gds  where
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = tt-gds-list.artic      and
            sb-cli-gds.host-code = v-cntxt-host-code-obj         and
            sb-cli-gds.prod-type = tt-gds-list.prod-type  and
            sb-cli-gds.prod-code = tt-gds-list.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
            run proc-eq-tmp-price ( p-recid,tt)  no-error .
            if error-status :error
            then do:
                message vss-workfile vss-revision vss-description skip
                error-status :get-message(1)
                "Плохо !  Ошибка в proc-eq-tmp-price !"
                333
                view-as alert-box error .
            end.

    end.
    when "contract-spec":u  then do:
      find first ub.goods where
            ub.goods.gds-code  = ub.contract-specif.gds-code  no-lock no-error.
            if error-status :error  then do:
                message vss-workfile vss-revision vss-description skip
                        "При добавлении товаров из спецификации по договору произошла ошибка :" skip
                        "Нет товара с кодом : " ub.contract-specif.gds-code
                        view-as alert-box error .
            end.

      find  first sb-cli-gds  where
            sb-cli-gds.host-code = v-cntxt-host-code-obj and
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.

            if not available tmp#zakaz then do:
                  run proc-eq-tmp-price ( p-recid, tt)  no-error .
            end.

            case t :
              when "only-price" then do:
                if ub.contract-specif.price-cli <> tmp#zakaz.price-cli
                or ub.contract-specif.vat-pc    <> tmp#zakaz.vat-pc
                then do:
                  assign v-update-price = v-update-price + 1 .
                end.
              end.
              when "only-qnty" then do:
                if ub.contract-specif.qnty <> tmp#zakaz.cli-qnty
                then do:
                  assign v-update-price = v-update-price + 1 .
                end.
              end.
              when "" then do:
                if ub.contract-specif.qnty      <> tmp#zakaz.cli-qnty
                or ub.contract-specif.price-cli <> tmp#zakaz.price-cli
                or ub.contract-specif.vat-pc    <> tmp#zakaz.vat-pc
                then do:
                  assign v-update-price = v-update-price + 1 .
                end.
              end.
            end case.

             if t <> "only-qnty"  then do:
                run proc-eq-tmp-price ( p-recid,tt)  no-error .
             end .

            if ub.contract-specif.cli-base-rate <> 0 then do:
              assign
                tmp#zakaz.cli-base-rate = ub.contract-specif.cli-base-rate
                tmp#zakaz.unit-cli      = ub.contract-specif.unit-base
              .
            end.

            if t <> "only-price"  then do:
                if  ub.contract-specif.qnty <> 0 then do:
                  assign
                    tmp#zakaz.cli-qnty = ub.contract-specif.qnty
                  .
                end.
            end.
            if t <> "only-qnty"  then do:
              assign
                tmp#zakaz.vat-pc     =  ub.contract-specif.vat-pc
                tmp#zakaz.price-cli  =  ub.contract-specif.price-cli
              .
            end.

          assign
              tmp#zakaz.qnty       =  tmp#zakaz.cli-qnty   * tmp#zakaz.cli-base-rate
              tmp#zakaz.price-rubl =  tmp#zakaz.price-cli  * loc-exch-rate / loc-exch-scale / tmp#zakaz.cli-base-rate
              tmp#zakaz.price-base =  tmp#zakaz.price-rubl / loc-base-rate * loc-base-scale
              tmp#zakaz.sum        =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
              tmp#zakaz.sum-rubl   =  tmp#zakaz.price-rubl * tmp#zakaz.qnty
              tmp#zakaz.sum-base   =  tmp#zakaz.price-base * tmp#zakaz.qnty
              tmp#zakaz.sum-cli    =  tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
              .
    end.
    when "doc":u  then do:
        find first ub.goods where
                ub.goods.artic     = shar_ord-line.artic     and
                ub.goods.prod-type = shar_ord-line.prod-type and
                ub.goods.prod-code = shar_ord-line.prod-code no-lock no-error.
       if not (line-mode = "" and  t-action = "chg":U  )  then do:
              if available ub.goods then do:
                    p-recid = ?.
                    find first sb-cli-gds  where
                        sb-cli-gds.cli-type  = buf-cli.obj-type and
                        sb-cli-gds.cli-code  = buf-cli.obj-code and
                        sb-cli-gds.host-code = v-cntxt-host-code-obj      and
                        sb-cli-gds.artic     = ub.goods.artic      and
                        sb-cli-gds.prod-type = ub.goods.prod-type  and
                        sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error .

                        if available sb-cli-gds then p-recid = recid(sb-cli-gds).
                        else p-recid = ?.

                    run proc-eq-tmp-price ( p-recid,tt)  no-error .
                    if error-status :error then message vss-workfile vss-revision vss-description skip
                                                        error-status :get-message(1)  skip
                                                        "Ошибка вызова процедуры proc-eq-tmp-price"  skip
                                                        .
              end.
           buffer-copy shar_ord-line to tmp#zakaz.
        end.
        else do:
           /* Если открытие документа */
           create  tmp#zakaz.
           buffer-copy shar_ord-line to tmp#zakaz
             assign
                tmp#zakaz.gds-name      = ub.goods.gds-name
                tmp#zakaz.negative-rest = ub.goods.negative-rest
                tmp#zakaz.unit-base     = ub.goods.unit-base
                tmp#zakaz.sum           = tmp#zakaz.price-rubl * tmp#zakaz.qnty
           .
           
            find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
              and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
              and buf_ord-line-attr.attr-code = {&ordlineattr-min-stock} no-error.
            if available buf_ord-line-attr then tmp#zakaz.min-stock-old = decimal(buf_ord-line-attr.attr-value). 
            find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
              and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
              and buf_ord-line-attr.attr-code = {&ordlineattr-gds-way} no-error.
            if available buf_ord-line-attr then tmp#zakaz.gds-way = decimal(buf_ord-line-attr.attr-value).
            
            find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
            if available bufff-units then
            assign
              tmp#zakaz.unit-type       = bufff-units.type .

            find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
            if available bufff-units then
            assign
              tmp#zakaz.unit-cli-type       = bufff-units.type .

        end.

    end.

    when "excel":u  then do:
       { cus/ord-lib.i excel}
       V-PRICE-EXEL = tmp#zakaz.price-cli.
       find  first sb-cli-gds  where
            sb-cli-gds.host-code = v-cntxt-host-code-obj and
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.
       run proc-eq-tmp-price ( p-recid , tt)  no-error .
       if error-status :error then message vss-workfile vss-revision vss-description skip
                                           error-status :get-message(1)  skip
                                          "Ошибка вызова процедуры proc-eq-tmp-price exel 2"  skip
                                          .
          assign
            tmp#zakaz.price-cli  = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-cli ELSE V-PRICE-EXEL * tmp#zakaz.cli-base-rate
            tmp#zakaz.price-RUBL = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-RUBL ELSE V-PRICE-EXEL
            tmp#zakaz.cli-qnty   = tmp#zakaz.qnty       / tmp#zakaz.cli-base-rate
            tmp#zakaz.sum        = tmp#zakaz.price-rubl * tmp#zakaz.qnty
            tmp#zakaz.sum-rubl   = tmp#zakaz.price-rubl * tmp#zakaz.qnty
            tmp#zakaz.sum-cli    = tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
            .
    end.
    when "excel2":u  then do:
       { cus/ord-lib.i excel 2 }
       V-PRICE-EXEL = tmp#zakaz.price-cli .
      find  first sb-cli-gds  where
            sb-cli-gds.host-code = v-cntxt-host-code-obj and
            sb-cli-gds.cli-type  = buf-cli.obj-type and
            sb-cli-gds.cli-code  = buf-cli.obj-code and
            sb-cli-gds.artic     = ub.goods.artic      and
            sb-cli-gds.prod-type = ub.goods.prod-type  and
            sb-cli-gds.prod-code = ub.goods.prod-code  no-lock no-error.
            if available sb-cli-gds then p-recid = recid(sb-cli-gds).
            else p-recid = ?.

       run proc-eq-tmp-price ( p-recid,tt)  no-error .

      if error-status :error then message vss-workfile vss-revision vss-description skip
                                          error-status :get-message(1)  skip
                                          "Ошибка вызова процедуры proc-eq-tmp-price exel2 "  skip
                                          .
      assign
        tmp#zakaz.price-cli = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-cli ELSE V-PRICE-EXEL * tmp#zakaz.cli-base-rate
        tmp#zakaz.price-RUBL = IF V-PRICE-EXEL = 0 OR V-PRICE-EXEL = ? THEN tmp#zakaz.price-RUBL ELSE V-PRICE-EXEL
        tmp#zakaz.cli-qnty  =   tmp#zakaz.qnty  / tmp#zakaz.cli-base-rate
        tmp#zakaz.sum       =   tmp#zakaz.price-rubl * tmp#zakaz.qnty
        tmp#zakaz.sum-rubl       =   tmp#zakaz.price-rubl * tmp#zakaz.qnty
        tmp#zakaz.sum-cli   =   tmp#zakaz.price-cli  * tmp#zakaz.cli-qnty
        .
    end.
 end case.

  tmp#zakaz.doc-code        = loc-ord-num   .
  find first buf_ord-dtl  no-lock where
        buf_ord-dtl.artic       = tmp#zakaz.artic     and
        buf_ord-dtl.prod-code   = tmp#zakaz.prod-code and
        buf_ord-dtl.prod-type   = tmp#zakaz.prod-type
    no-error .

    if available buf_ord-dtl
      then assign tmp#zakaz.prt-ok   =   true .
      else assign tmp#zakaz.prt-ok   =   false  .

    find first shar_ord-line exclusive-lock  where
               shar_ord-line.doc-code  = loc-ord-num    and
               shar_ord-line.prod-type = tmp#zakaz.prod-type and
               shar_ord-line.prod-code = tmp#zakaz.prod-code and
               shar_ord-line.artic     = tmp#zakaz.artic
    no-error.
    if not available shar_ord-line  then  do:
       create shar_ord-line  .
    end.

    if (lookup({&pieces}, tmp#zakaz.unit-cli-type) > 0
    or lookup({&serial}, tmp#zakaz.unit-cli-type) > 0 ) and
        tmp#zakaz.cli-qnty <> truncate(tmp#zakaz.cli-qnty, 0) then do:
        tmp#zakaz.cli-qnty = truncate(tmp#zakaz.cli-qnty, 0) + 1 .
        tmp#zakaz.sum-cli  = tmp#zakaz.cli-qnty * tmp#zakaz.price-cli .
        tmp#zakaz.qnty     = tmp#zakaz.cli-qnty * tmp#zakaz.cli-base-rate .
        tmp#zakaz.sum-rubl = tmp#zakaz.qnty * tmp#zakaz.price-rubl .
        tmp#zakaz.sum-base = tmp#zakaz.qnty * tmp#zakaz.price-base .
    end.


    buffer-copy tmp#zakaz to shar_ord-line
         assign shar_ord-line.doc-code    = loc-ord-num
      .

 /* восстановления номера по порядку */
  if tmp#zakaz.line-num = 0 or
     tmp#zakaz.line-num = ? or
     shar_ord-line.line-num = 0 then do:
       find last ll-tmp#zakaz where ll-tmp#zakaz.gds-code  <> tmp#zakaz.gds-code use-index idx-ln no-lock no-error. 
        if available ll-tmp#zakaz
            then tmp#zakaz.line-num = ll-tmp#zakaz.line-num + 1.
            else tmp#zakaz.line-num = 1.
       find current shar_ord-line  exclusive-lock  no-error .
       if not error-status :error  then
          shar_ord-line.line-num = tmp#zakaz.line-num .
  end.
end .
end procedure.

procedure disable_ui :
{&start-proc}
  hide frame dialog-frame.
end.
end procedure.

procedure enable_ui :
{&start-proc}

if g#type <> {&o-f} then do:
  display  {&display-objects-all}      with frame dialog-frame.
  enable   {&enabled-objects-all}      with frame dialog-frame.
end.
else do:
  display {&display-objects-of}      with frame dialog-frame.
  enable  {&enabled-objects-of}      with frame dialog-frame.

end.
  if t-action = "add":u  and  g#type <> {&o-f}  then do :
     enable  loc-cli-code r-clients with frame {&frame-name} .
     disable b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import with frame {&frame-name} .
  end.

hide pay-day loc-out-code loc-time-ship b-sch  b-itogs
    in frame {&frame-name} .

/* &if "{5}"  = "no-prt" &then */
 disable b-gds-prt with frame {&frame-name} .
/*&endif */

if g#type = {&o-f} then do:
  hide  loc-exch-code
        loc-exch-rate
        loc-base-rate
        ub.currency.curr-abbr
        loc-exch-scale
        loc-base-scale
        paytype
        loc-pay-type
        loc-cli-out-doc
        r-paytype
        loc-service
        loc-sum-rubl
        loc-sum-base
        loc-sum-cli
        loc-contract
        slt_type
        vat_type
        r-currency
        r-acc
        in frame {&frame-name} .
end.

view frame dialog-frame.
{&open-browsers-in-query-dialog-frame}
end.
end procedure.


procedure enable_ui_2 :
{&start-proc}
/* для lookup */

if g#type <> {&o-f} then do:
  display  {&display-objects-all}      with frame dialog-frame.
  enable   {&enabled-objects-all}      with frame dialog-frame.
end.
else do:
  display {&display-objects-of}      with frame dialog-frame.
  enable  {&enabled-objects-of}      with frame dialog-frame.

end.

disable   all      with frame dialog-frame.
  enable b-exit  b-producer b-sch b-alt-post  b-notes  b-help b-gds-prt
         br-docs b-export a-n-c
      with frame dialog-frame.
   enable e-method with frame dialog-frame.
   e-method:read-only = true .
/*&if "{5}"  = "no-prt" &then*/
 disable b-gds-prt with frame {&frame-name} .
/*&endif */


  display
   b-exit  b-producer b-sch b-alt-post  b-notes  b-help b-gds-prt
   br-docs b-export  a-n-c
  with frame dialog-frame.

  view frame dialog-frame.
  {&open-browsers-in-query-dialog-frame}
end.
end procedure.

procedure openbr :
{&start-proc}
t-ret =  session:set-wait-state("general") .
define variable l-query-was-opened as logical no-undo .

for each tmp#zakaz :
  if (lookup({&pieces}, tmp#zakaz.unit-cli-type) > 0
  or lookup({&serial}, tmp#zakaz.unit-cli-type) > 0 ) and
    tmp#zakaz.cli-qnty <> truncate(tmp#zakaz.cli-qnty, 0) then do:
    assign
      tmp#zakaz.cli-qnty = truncate(tmp#zakaz.cli-qnty, 0) + 1 .
    end.

  if (lookup({&pieces}, tmp#zakaz.unit-type) > 0
  or lookup({&serial}, tmp#zakaz.unit-type) > 0 ) and
    tmp#zakaz.qnty <> truncate(tmp#zakaz.qnty, 0) then do:
    assign
      tmp#zakaz.qnty = truncate(tmp#zakaz.qnty, 0) + 1 .
    end.

  if tmp#zakaz.cli-base-rate = 0 or tmp#zakaz.cli-base-rate = ? then   do:
  find first ub.goods where
                         tmp#zakaz.artic = ub.goods.artic and
                         tmp#zakaz.prod-type = ub.goods.prod-type and
                         tmp#zakaz.prod-code = ub.goods.prod-code no-lock no-error  .
     if error-status :error then do:
        find first shar_ord-line   where
            shar_ord-line.doc-code        = loc-ord-num    and
            shar_ord-line.prod-type       = tmp#zakaz.prod-type and
            shar_ord-line.prod-code       = tmp#zakaz.prod-code and
            shar_ord-line.artic           = tmp#zakaz.artic   exclusive-lock  no-error.
         if available shar_ord-line  then  delete shar_ord-line  .
         delete tmp#zakaz. /* удалим строки временной таблицы содержащие некоректые goods */
         next.
         end.

     tmp#zakaz.cli-base-rate  = ub.goods.cli-base-rate.
  end.
end.
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

case list-mode:
    when {&client-cmp_balance-cmp} or when {&client-cmp_stock-cmp} then do:
        assign frame {&frame-name}:title =  " по фирме :" + v-cntxt-host-name-obj +
        ( if g#type = {&o-f} then  " ЗАЯВКА № "
        else
        " ЗАКАЗ  № "  )
        + loc-ord-num
        filter-point = "Заказ_поставщику_new".
        if t-action = "add":u then  frame {&frame-name}:title = frame {&frame-name}:title + "  - " + {&add-def}.
        if t-action = "chg":u then  frame {&frame-name}:title = frame {&frame-name}:title + "  - " + {&update}.
        if t-action = "lkp":u then  frame {&frame-name}:title = frame {&frame-name}:title + "  - " + {&lookup}.
        {&open-query-br-docs-sort} by tmp#zakaz.line-num .

    end.
end case.

run select-good-scala in this-procedure .
 apply "home" to br-docs in frame {&frame-name}.

assign
      loc-cli-qnty    = 0
      loc-qnty        = 0
      loc-sum-base    = 0
      loc-sum-cli     = 0
      loc-sum-rubl    = 0
      loc-tot-lines   = 0
     .


for each tmp#zakaz :
assign
      loc-cli-qnty    = loc-cli-qnty  +  tmp#zakaz.cli-qnty
      loc-qnty        = loc-qnty      +  tmp#zakaz.qnty
      loc-sum-base    = loc-sum-base  +  tmp#zakaz.sum-base
      loc-sum-cli     = loc-sum-cli   +  tmp#zakaz.sum-cli
      loc-sum-rubl    = loc-sum-rubl  +  tmp#zakaz.sum-rubl
      loc-tot-lines   = loc-tot-lines + 1
     .
end.

display
  loc-cli-qnty
  loc-qnty
  loc-sum-base
  loc-sum-cli
  loc-sum-rubl
  loc-tot-lines
  with frame {&frame-name} .


  if t-action = "lkp":U then run enable_ui_2 .
                      /*   else run enable_ui. */
  t-ret =  session:set-wait-state("") .
  error-status :error = false .
end.
end procedure.

procedure set-filter-name :
{&start-proc}
  define input parameter p-filter-name as character no-undo .
  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.

  end. /* do with frame */
end.
end procedure.

procedure ex-file :
{&start-proc}
define input parameter ff as character no-undo .
define input parameter ex as logical no-undo .
  if ex = false then do:
      create "excel.application" chexcelapplication connect no-error.
     if error-status:error then 
     do:  
        create "excel.application" chexcelapplication no-error.
        if error-status :error then 
        do:
           message
              "Ошибка при запуске Excel" skip
              error-status :get-message(1) skip
              view-as alert-box error .
           undo, return error .
        end.
     end.
    if ff = ""  then do:
      chworkbook   = chexcelapplication:workbooks:add( ).
    end.
    else do:
      chworkbook   = chexcelapplication:workbooks:open( ff ).
    end.
  end.
  {&excel-invisable}
  chworksheet  = chexcelapplication:sheets:item (1).
end.
end procedure.

procedure export-proc :
{&start-proc}
/* load from 1 tab */
define input parameter numbersheet as integer no-undo .
define variable ii as integer init 6 no-undo.
t-ret =  session:set-wait-state("general") .
mm:
 repeat  /* on endkey undo, retry  */ :
    ii = ii  + 1.
        if numbersheet = 1 then do:
           if (chworksheet:range("a" + string(ii)):value ="" or chworksheet:range("a" + string(ii)):value = ?) then leave mm.
              run create-tmp in this-procedure  (input "excel":u , string (ii)  ).
           end.
        if numbersheet = 2 then do:
           if (chworksheet2:range("a" + string(ii)):value ="" or chworksheet2:range("a" + string(ii)):value = ?) then leave mm.
              run create-tmp in this-procedure  (input "excel2":u , string (ii)  ).
           end.
  end.

  if ii = 6 then disable  loc-cli-code loc-cli-type loc-obj-name r-clients with frame {&frame-name}.
  t-ret =  session:set-wait-state("") .

  run openbr in this-procedure  .
  message "Импортировано " + string (ii - 7) + " товаров".
  end.
end.

procedure p-b-itogs :
{&start-proc}
  g#log = true  .
  tmp-rec = recid( tmp#zakaz ).
  do while available tmp#zakaz :
        get prev br-docs.
  end.
  run cus/z-tot.p
    (input parparentproc,
     input "":u,
     input date-1,
     input date-2) .
  reposition br-docs to recid tmp-rec no-error.
end.
end procedure.


procedure  b-import-excel :
{&start-proc}
   define variable ff as character no-undo.
   define variable var-name-sheet as character no-undo .

  /* импорт может быть из открытого экселевого файла и из закрытого */
  message "Импорт из excel данных по заказу ."
  "При импорте используется работа с COM объектом Excel, поэтому не прерывайте работу Excel и не нарушайте уже законнекченную связь!"
  skip "Продолжать ?"
           view-as alert-box question
           buttons
           ok-cancel update g#log.
           {&if-not-true}
   var#import = true.
   chworkbook = chexcelapplication:activeworkbook no-error.
   g#log = false .
   if chworkbook = 0 or chworkbook = ? then  do: /* file not open */
        define variable okpressed as logical initial true no-undo.
        system-dialog get-file ff
            title      "Выберите файл ..."
            filters    "excel (*.xls)"   "*.xls"
                        use-filename
                        must-exist
                        update okpressed.
                        if okpressed = true then
                           do: run ex-file in this-procedure   (ff, false) . end.
                        else return no-apply .
   end.
   chworkbook = chexcelapplication:activeworkbook no-error.
   chworksheet  = chexcelapplication:sheets:item(1):select  no-error.
   chworksheet  = chexcelapplication:sheets:item(1) no-error.
   assign
   g#log = true  .

    var-name-sheet = chexcelapplication:sheets:item(1):name no-error.
    if   var-name-sheet = {&rezalt} then do:
    message "Начинаем экспорт  " skip
            "файл:  " chworkbook:fullname  skip
            "закладка: "  var-name-sheet  skip
            "Продолжить ? "
             view-as alert-box question buttons ok-cancel update g#log.
             if g#log = true then  run export-proc in this-procedure  (1).
        end.
   else do:
    message "Начинаем экспорт  " skip
            "Файл сделан не в системе 'ЗАКАЗЫ' !!! "
            "файл:  " chworkbook:fullname  skip
              "Продолжить ? "
             view-as alert-box question buttons ok-cancel update g#log.
             if g#log = true then  run export-proc in this-procedure  (1).
   end.
  RELEASE OBJECT chWorksheet2 NO-ERROR.
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
end.
end procedure.


procedure r-clients-ch :
{&start-proc}
define variable bttns     as   character no-undo. /* список включенных батонов */
define variable rid-list    as  character no-undo . /* список recid'ов выбранных клиентов */
  run ref/cli-all.w (input parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list) no-error .
   if error-status :error or rid-list = '' then return error return-value .
    assign
     rep-rec = integer(rid-list)
     no-error.
  find first buf-cli where recid(buf-cli) = rep-rec no-lock no-error.
  if not( buf-cli.obj-type = {&cmp} or buf-cli.obj-type = {&prs} ) then do:
    message "Заказать можно только у ОРГАНИЗАЦИЙ или Физ.лиц" view-as alert-box .
    return error return-value .
  end.
  find first ub.clients where recid(ub.clients) = rep-rec no-lock no-error.
  assign
  loc-cli-code = buf-cli.obj-code
  loc-cli-type = buf-cli.obj-type
  loc-obj-name = buf-cli.obj-name
  loc-cli-code:screen-value in frame {&frame-name} = string( buf-cli.obj-code)
  loc-cli-type:screen-value in frame {&frame-name} = buf-cli.obj-type
  loc-obj-name:screen-value in frame {&frame-name} = buf-cli.obj-name no-error.
    if avail buf-cli then do:

        enable  b-spec  b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import with frame {&frame-name}.
        disable
           loc-cli-code
           loc-cli-type
           loc-obj-name
           r-clients
           with frame {&frame-name}.
          run ver-clients  in this-procedure ( input loc-cli-type , input loc-cli-code , output v-err) .
          if  v-err then return error.
    end.
    else return error .
    display loc-cli-code loc-cli-type loc-obj-name
    with frame {&frame-name}.
end.
end procedure.

procedure b-export-ch :
{&start-proc}
  message "Экспорт в excel ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}

      run cus/z-tot1.p (PARPARENTPROC , loc-ord-num , v-cntxt-obj-type , v-cntxt-obj-code ).

end.
end procedure.


procedure leave-loc-cli-code.
{&start-proc}
 assign frame {&frame-name} loc-cli-code loc-cli-type .
 if v-fl = false  then do:
  assign frame {&frame-name} loc-cli-code  .
    if loc-cli-type = ? or loc-cli-type = "" then loc-cli-type = {&cmp} .

    find first buf-cli no-lock where  buf-cli.obj-type = loc-cli-type
                                  and buf-cli.obj-code = loc-cli-code  no-error.
    rep-rec = recid (buf-cli) no-error.

    find first ub.clients where recid(ub.clients) = rep-rec no-lock no-error.
    if avail ub.clients then do:
          loc-obj-name = ub.clients.obj-name .
          display  loc-cli-code loc-cli-type loc-obj-name with frame {&frame-name}.
          enable   b-spec b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import with frame {&frame-name}.
          disable  loc-cli-code loc-cli-type loc-obj-name r-clients  with frame {&frame-name}.
        end.
        else do:
          assign
          loc-obj-name:screen-value = ""
          loc-cli-type:screen-value = ""
          loc-cli-code:screen-value = ?
          .
          /*message "Неправильно задан код или тип Поставщика ".*/
          disable b-add b-way b-del b-chg b-producer b-alt-post b-main-calc b-export b-import with frame {&frame-name}.
          return error .
        end.
 end.
 else v-fl = false .
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .
end.
end procedure.

procedure leave-loc-cli-type :
{&start-proc}
  assign frame {&frame-name} loc-cli-type .
  if loc-cli-code <> ? or loc-cli-code <> 0 then do:
    find first buf-cli where loc-cli-type = buf-cli.obj-type  and loc-cli-code = buf-cli.obj-code  no-lock no-error.
    rep-rec = recid(buf-cli)  no-error.
    find first ub.clients where recid ( ub.clients) = rep-rec no-lock no-error.
    if available ub.clients then do:
        loc-obj-name = ub.clients.obj-name .
        display  loc-cli-code loc-cli-type loc-obj-name with frame {&frame-name}.
        enable b-spec b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame {&frame-name}.
        end.
        else do:
          assign
          loc-obj-name:screen-value = ""
          loc-cli-type:screen-value = ""
          loc-cli-code:screen-value = ?
          .
          message "Неправильно задан код или тип Поставщика !".
          disable b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame {&frame-name}.
        end.
    end.
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .

end.
end procedure.


procedure choose-menu-add1 :
{&start-proc}
if lookup( date-sale-2 :type in frame {&frame-name}
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" date-sale-2 :name  in frame {&frame-name} skip
    "Тип" date-sale-2 :type  in frame {&frame-name} skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to date-sale-2  in frame {&frame-name} .
  assign frame {&frame-name} LOC-DATE-SHIP
                             DATE-sale-1
                             DATE-sale-2
                             doc-date
                             .
  /*
  if focus :handle <> date-sale-2 :handle  in frame {&frame-name} then do:
    return error .
  end.
  */
end.


define variable ii as integer init 0 no-undo.
define variable r-tmp as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
if g#type = {&o-f} then do:
   message "Режим не доступен для Заявок."  view-as alert-box information.
   return.
   end.
t-ret =  session:set-wait-state("general") .
 line-mode = {&add-def} .
  find first buf-cli where recid(buf-cli) = rep-rec no-lock no-error.
  for each sb-cli-gds where sb-cli-gds.host-code = v-cntxt-host-code-obj
                            and sb-cli-gds.cli-type = buf-cli.obj-type
                            and sb-cli-gds.cli-code = buf-cli.obj-code
                            and ( sb-cli-gds.cancel-date = ?  or  sb-cli-gds.cancel-date > to-day ) no-lock :
     find first ub.goods  where ub.goods.prod-type = sb-cli-gds.prod-type and
                                ub.goods.prod-code = sb-cli-gds.prod-code and
                                ub.goods.artic =     sb-cli-gds.artic no-lock no-error.
     ii = ii  + 1.
     if ii > 1 then assign line-mode = "ЦИКЛ":u.
     run create-tmp in this-procedure  (input "price":u ,"") no-error .
      if not  error-status :error  and not t-auto then do:
            run cus/ord-frm.w ( input ParParentProc,  input recid ( tmp#zakaz ) , input line-mode , output r-stop , output r-exit) .

            if r-stop then do:
               run p-delete( recid ( tmp#zakaz ) ,input-output ii ) .
               leave.
               end.
            if r-exit then do:
               run p-delete( recid ( tmp#zakaz ) ,input-output ii ) .
               end.
        end.
  end.

  if ii > 0 then disable  loc-cli-code loc-cli-type loc-obj-name r-clients with frame {&frame-name}.
  t-ret =  session:set-wait-state("") .
  run openbr in this-procedure  .
  reposition br-docs to recid tmp-rec no-error.
  message "Добавлено по поставщику " + string (ii) + " товаров".
end.
end procedure.


procedure apply-focus-next-entry :
{&start-proc}
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .

  assign
    l-apply-entry = /* false */  true
  .

  do with frame dialog-frame:
  if loc-cli-type :handle = p-widget-handle then do:   if loc-cli-code :sensitive then do:  apply "entry":u to loc-cli-code. return . end. end.
  if loc-cli-code :handle = p-widget-handle then do:   if wrkr         :sensitive then do:  apply "entry":u to wrkr        . return . end. end.
  if wrkr    :handle       = p-widget-handle then do:  if agnt         :sensitive then do:  apply "entry":u to agnt        . return . end. end.
  if agnt    :handle = p-widget-handle then do:        if boss         :sensitive then do:  apply "entry":u to boss        . return . end. end.
  if boss    :handle = p-widget-handle then do:
             if paytype      :sensitive then do:
                apply "entry":u to paytype     . return .
             end.
             else do:
                apply "entry":u to  b-add  . return .
             end.
  end.
  if paytype :handle = p-widget-handle then do:      if b-add  :sensitive then do:  apply "choose":u to b-add .  return . end. end.
  if r-contract :handle = p-widget-handle then do:   if b-spec :sensitive then do:  apply "choose":u to b-spec . return . end. end.



  end. /* do with frame */
end.
end procedure.


procedure create-tmp-dtl :
{&start-proc}
  /* признаки */
  if not avail  shar_ord-doc  then return.
        for each shar_ord-dtl where shar_ord-dtl.doc-code = shar_ord-doc.doc-code no-lock :
          find first ub.gds-prt where ub.gds-prt.node-code =  shar_ord-dtl.node-code no-lock no-error .
          if avail ub.gds-prt then do :
           create tmp#zakaz-dtl no-error.
           if error-status :error then do:
              find first  tmp#zakaz-dtl where
                    tmp#zakaz-dtl.artic       = shar_ord-dtl.artic     and
                    tmp#zakaz-dtl.prod-code   = shar_ord-dtl.prod-code and
                    tmp#zakaz-dtl.prod-type   = shar_ord-dtl.prod-type and
                    tmp#zakaz-dtl.node-code   = shar_ord-dtl.node-code no-error .
              end.
           assign
              tmp#zakaz-dtl.prt-name               = ub.gds-prt.f-name
              tmp#zakaz-dtl.artic                  = shar_ord-dtl.artic
              tmp#zakaz-dtl.prod-code              = shar_ord-dtl.prod-code
              tmp#zakaz-dtl.prod-type              = shar_ord-dtl.prod-type
              tmp#zakaz-dtl.node-code              = shar_ord-dtl.node-code
              tmp#zakaz-dtl.cancel-cli-qnty        = shar_ord-dtl.cancel-cli-qnty
              tmp#zakaz-dtl.cancel-qnty            = shar_ord-dtl.cancel-qnty
              tmp#zakaz-dtl.qnty                   = shar_ord-dtl.qnty
              tmp#zakaz-dtl.cli-qnty               = shar_ord-dtl.cli-qnty
              tmp#zakaz-dtl.doc-code               = shar_ord-dtl.doc-code
              tmp#zakaz-dtl.initial-cli-qnty       = shar_ord-dtl.initial-cli-qnty
              tmp#zakaz-dtl.initial-qnty           = shar_ord-dtl.initial-qnty
              tmp#zakaz-dtl.add-cli-qnty           = shar_ord-dtl.add-cli-qnty
              tmp#zakaz-dtl.add-qnty               = shar_ord-dtl.add-qnty
              tmp#zakaz-dtl.order-cli-qnty         = shar_ord-dtl.order-cli-qnty
              tmp#zakaz-dtl.order-qnty             = shar_ord-dtl.order-qnty
              tmp#zakaz-dtl.price-base             = shar_ord-dtl.price-base
              tmp#zakaz-dtl.price-cli              = shar_ord-dtl.price-cli
              tmp#zakaz-dtl.price-rubl             = shar_ord-dtl.price-rubl
              tmp#zakaz-dtl.receive-cli-qnty       = shar_ord-dtl.receive-cli-qnty
              tmp#zakaz-dtl.receive-qnty           = shar_ord-dtl.receive-qnty
              tmp#zakaz-dtl.sum-base               = shar_ord-dtl.sum-base
              tmp#zakaz-dtl.sum-cli                = shar_ord-dtl.sum-cli
              tmp#zakaz-dtl.sum-rubl               = shar_ord-dtl.sum-rubl
              no-error  .
             if error-status :error then message 'error create tmp#zakaz-dtl'.
              find first  tmp#zakaz where
                    tmp#zakaz.artic       = shar_ord-dtl.artic     and
                    tmp#zakaz.prod-code   = shar_ord-dtl.prod-code and
                    tmp#zakaz.prod-type   = shar_ord-dtl.prod-type
                    no-error .
               if avail tmp#zakaz then
               assign tmp#zakaz.prt-ok   =   true .
           end.
  end.
end.
end procedure.


procedure select-good-scala :
{&start-proc}
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .

  if not avail TMP#zakaz   then do:
     return.
  end.

assign
    x-prod-type = tmp#zakaz.prod-type
    x-prod-code = tmp#zakaz.prod-code
    x-artic     = tmp#zakaz.artic
    .
{&open-query-br-docs-2}

  find first for-cli no-lock where for-cli.obj-type = tmp#zakaz.prod-type and
                                   for-cli.obj-code = tmp#zakaz.prod-code no-error.
  if avail for-cli then do:
      display for-cli.obj-name      @ prod-name
              tmp#zakaz.gds-name    @ goods-name
              with frame {&frame-name} .
  end.
  else do:
      display "" @ prod-name  with frame {&frame-name}.
  end.
  if error-status :error  then message "123-" error-status :error.

end.
end procedure .

procedure check-exch :
{&start-proc}
 /* -----------------------------------------------------------
    purpose:     проверка правильности валюты поставщика
  -------------------------------------------------------------*/
  find ub.currency where ub.currency.curr-code = (input frame {&frame-name} loc-exch-code   ) no-lock no-error.
  if not available ub.currency then do:
    message "Неправильная валюта поставщика - такой валюты нет.".
    apply "entry" to loc-exch-code in frame {&frame-name}.
    return error.
  end.

  if loc-exch-code <> ub.currency.curr-code then do:
    if ub.currency.curr-code = 0 then do:
      /*Если курс был задан и отличался от 1*/
      if (loc-exch-rate <> ? and loc-exch-scale <> ? and
          (loc-exch-rate <> 1 or loc-exch-scale <> 1)) then do:
        g#log = no.
        message "Пересчитать цены поставщика в {&abbr_rubli} по курсу поставщика ?"
                        view-as alert-box question buttons yes-no update g#log.
        if g#log then do:
          run waitfram-show ("Пересчет цен поставщика в {&abbr_rubli}. Ждите...").
          for each tmp#zakaz where :
            tmp#zakaz.price-cli = tmp#zakaz.price-cli * loc-exch-rate / loc-exch-scale.
          end.
          run waitfram-hide.
        end.
      end.
      loc-print-rubl = yes.
      assign
        loc-exch-rate = 1
        loc-exch-scale = 1
        .
      disable loc-exch-rate loc-exch-scale r-acc with frame {&frame-name}.
    end.
    else do:
      find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code
                          /* and ub.curr-accnt.exch-date <= input loc-exch-date */
                             use-index pi no-lock no-error.
      if available ub.curr-accnt then assign
          loc-exch-rate = ub.curr-accnt.exch-rate
          loc-exch-scale = ub.curr-accnt.exch-scale.
      else assign
          loc-exch-rate = ?
          loc-exch-scale = ?.
      if loc-exch-code = 0 and
        /*Если курс задается и отличается от 1*/
        (loc-exch-rate  <> ? and
         loc-exch-scale <> ? and
         (loc-exch-rate <> 1 or loc-exch-scale <> 1)
        ) then do:
        g#log = no.
        message "Пересчитать цены поставщика в валюту ГТД по курсу ММВБ (справочника) ?"
                        view-as alert-box question buttons yes-no update g#log.
        if g#log then do:
          run waitfram-show ("Пересчет цен поставщика в валюту ГТД. Ждите...").
            for each tmp#zakaz where  :
            tmp#zakaz.price-cli = tmp#zakaz.price-cli / loc-exch-rate * loc-exch-scale.
          end.
          run waitfram-hide.
        end.
      end.
      loc-print-rubl = no.
      enable loc-exch-rate loc-exch-scale r-acc with frame {&frame-name}.
    end.
     loc-exch-code = ub.currency.curr-code.
     run enable_Ui.
      enable b-add b-way b-main-calc b-del b-chg b-producer b-alt-post b-export b-import  with frame {&frame-name} .
      disable  loc-cli-code loc-cli-type r-clients  with frame {&frame-name} .
  end.
end.
end procedure.

procedure row-leave-br-doc :
{&start-proc}
  find current shar_ord-line  no-lock  no-error .
       if not avail shar_ord-line then return.

  find first TMP#zakaz no-lock    where
            tmp#zakaz.prod-type = shar_ord-line.prod-type       and
            tmp#zakaz.prod-code = shar_ord-line.prod-code       and
            tmp#zakaz.artic     = shar_ord-line.artic           no-error  .

  if not avail TMP#zakaz   then do:
       message  vss-workfile vss-revision vss-description skip
        error-status :get-message(1)    skip
       "Ни чего не могу найти !!!".
       return.
       end.

  if (lookup({&pieces}, tmp#zakaz.unit-cli-type) > 0
  or lookup({&serial}, tmp#zakaz.unit-cli-type) > 0 ) and
     dec(tmp#zakaz.cli-qnty:screen-value in browse br-docs) <> truncate(dec(tmp#zakaz.cli-qnty:screen-value in browse br-docs), 0) then do:
        message "Количество заказа не может быть дробным ! " view-as alert-box .
          tmp#zakaz.cli-qnty:screen-value in browse br-docs = string(truncate(dec(tmp#zakaz.cli-qnty:screen-value in browse br-docs), 0) + 1).
  end.

  if not current-changed(tmp#zakaz) then
  assign tmp#zakaz.cli-art = tmp#zakaz.cli-art:screen-value in browse br-docs
         tmp#zakaz.cli-qnty = decimal(tmp#zakaz.cli-qnty:screen-value in browse br-docs)
         tmp#zakaz.sum-cli  = tmp#zakaz.cli-qnty * tmp#zakaz.price-cli
         tmp#zakaz.sum-cli:screen-value in browse br-docs = string (tmp#zakaz.sum-cli , "->>>>>>>>>>>9.99") no-error.
end.
end procedure.

procedure make-obj-list :
{&start-proc}
    if x-mode = "obj":u then do:
          { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code no-error }
    end.
    else do:       /* по фирме */
      for each ub.shop where ub.shop.host-code   = v-cntxt-host-code-obj:
          { cmp/cr-objls.i "{&shop}"  ub.shop.obj-code no-error }
      end.
      for each ub.store where ub.store.host-code  = v-cntxt-host-code-obj:
          { cmp/cr-objls.i "{&stock}"  ub.store.obj-code no-error }

      end.
     end.
end.
end procedure.

procedure val-ch-type:
{&start-proc}
define input parameter parself-name as character no-undo.
if caps(parself-name) = "slt_type" then run val-ch-slt-type no-error.
else do:
   if caps(parself-name) = "vat_type" then run val-ch-vat-type no-error.
      else do:
          message "Неверный self:name " parself-name
                  " при передаче в процедуру val-ch-type."
          view-as alert-box error.
          return error.
      end.
end.
if error-status:error then do:
      display slt_type with frame {&frame-name}.
      display vat_type with frame {&frame-name}.
      return no-apply.
end.
end.
end procedure.

procedure r-proc-currency :
{&start-proc}
assign
ref-rec = ?.
run ref/currency.w ( input parparentproc, "b-sel", input-output ref-rec ).
if ref-rec = ? then return .
find ub.currency where recid ( ub.currency ) = ref-rec no-lock.

  if ub.currency.curr-code <> loc-exch-code then do:
    run check-update no-error.
    if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
       return error.
    end.
  end.
run exch-rate.
run full-recount.
display loc-sum-rubl
       loc-sum-base
       loc-sum-cli
       loc-exch-code
       with frame {&frame-name} .
run openbr in this-procedure  .
end.
end procedure.

procedure update-rate-doc:
{&start-proc}
if input frame {&frame-name} loc-exch-rate  <> loc-exch-rate  or
   input frame {&frame-name} loc-exch-scale <> loc-exch-scale or
   input frame {&frame-name} loc-base-rate  <> loc-base-rate  or
   input frame {&frame-name} loc-base-scale <> loc-base-scale then
   do transaction on error     undo, return error
                    on end-key undo, return error
                    on stop    undo, return error :
     run check-exch.
     run check-update.
     run check-rate.
    end.
    run ui-on .
end.
end procedure.


procedure choice-currency:
{&start-proc}
assign frame  dialog-frame cycle-day loc-date-ship  loc-service date-sale-1 date-sale-2 .
find ub.currency where ub.currency.curr-code = input frame {&frame-name} loc-exch-code no-error.
if not available ub.currency then do:
  assign
  ref-rec = ?.

  run ref/currency.w ( input parparentproc, "b-sel", input-output ref-rec ).
  if ref-rec = ? then return error.
  find ub.currency where recid ( ub.currency ) = ref-rec.
end.
run exch-rate.
end.
end procedure.

procedure exch-rate:
{&start-proc}
disp ub.currency.curr-code @ loc-exch-code with frame {&frame-name}.

do transaction on error   undo, return no-apply
               on end-key undo, return no-apply
               on stop    undo, return no-apply:
   run check-exch.
   run check-rate.
   run full-recount.
        display loc-sum-rubl
                loc-sum-base
                loc-sum-cli
                loc-exch-code
                with frame {&frame-name} .
          run openbr in this-procedure  .
end.
run ui-on .
end.
end procedure.

procedure full-recount:
{&start-proc}

define variable     varprice-cli                    like ub.doc-line.price-base no-undo .
define variable     varprice-cli-unit-base          like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax               like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp              like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp          like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs            like ub.doc-line.price-base no-undo .
define variable     varprice-slt                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt                 like ub.doc-line.price-base no-undo .
define variable     varprice-vat                    like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt             like ub.doc-line.price-base no-undo .
define variable     varprice-rubl                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-rubl          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-rubl         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-rubl     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-rubl       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-rubl            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-rubl               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-rubl        like ub.doc-line.price-base no-undo .
define variable     varprice-base                   like ub.doc-line.price-base no-undo .
define variable     varprice-road-tax-base          like ub.doc-line.price-base no-undo .
define variable     varprice-other-exp-base         like ub.doc-line.price-base no-undo .
define variable     varprice-transport-exp-base     like ub.doc-line.price-base no-undo .
define variable     varprice-without-abs-base       like ub.doc-line.price-base no-undo .
define variable     varprice-slt-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-slt-base            like ub.doc-line.price-base no-undo .
define variable     varprice-vat-base               like ub.doc-line.price-base no-undo .
define variable     varprice-no-vat-slt-base        like ub.doc-line.price-base no-undo .


   assign
      loc-sum-rubl  = 0
      loc-sum-base  = 0
      loc-sum-cli   = 0
   .

for each tmp#zakaz  :
/*todo пересчет количеств */

    if vat_type = {&without-vat} then  do:
       tmp#zakaz.vat-pc = 0.
    end.
    if slt_type = {&without-slt} then  do:
       tmp#zakaz.slt-pc = 0.
    end.

   { str/in-vat.i
    "'zakaz':u"
    loc-base-rate
    loc-base-scale
    loc-exch-rate
    loc-exch-scale
    vat_type
    slt_type
    tmp#zakaz.artic
    tmp#zakaz.prod-type
    tmp#zakaz.prod-code
    tmp#zakaz.price-cli
    tmp#zakaz.cli-base-rate
    tmp#zakaz.price-rubl
    tmp#zakaz.vat-pc
    tmp#zakaz.slt-pc
    tmp#zakaz.road-tax
    tmp#zakaz.transport-rubl
    tmp#zakaz.other-rubl
    varprice-cli
    varprice-cli-unit-base
    varprice-road-tax
    varprice-other-exp
    varprice-transport-exp
    varprice-without-abs
    varprice-slt
    varprice-no-slt
    varprice-vat
    varprice-no-vat-slt
    varprice-rubl
    varprice-road-tax-rubl
    varprice-other-exp-rubl
    varprice-transport-exp-rubl
    varprice-without-abs-rubl
    varprice-slt-rubl
    varprice-no-slt-rubl
    varprice-vat-rubl
    varprice-no-vat-slt-rubl
    varprice-base
    varprice-road-tax-base
    varprice-other-exp-base
    varprice-transport-exp-base
    varprice-without-abs-base
    varprice-slt-base
    varprice-no-slt-base
    varprice-vat-base
    varprice-no-vat-slt-base
    no-error
    }
  if error-status:error then do:
     return error substitute("Ошибка при пересчете линии ЗАКАЗА , &1" , return-value  ) .
  end.

  assign tmp#zakaz.price-cli  = round(varprice-cli,2)
         tmp#zakaz.price-rubl = round(varprice-rubl,2)
         tmp#zakaz.price-base = round(varprice-base,2)
         tmp#zakaz.sum-vat    = if var-report-r-b = "rubl" then round(varprice-vat-rubl,2)
                                                           else round(varprice-vat-base,2)
         tmp#zakaz.sum-cli    = round(varprice-cli ,2) * tmp#zakaz.cli-qnty
         tmp#zakaz.sum-rubl   = round(varprice-rubl,2) * tmp#zakaz.qnty
         tmp#zakaz.sum        = round(varprice-rubl,2) * tmp#zakaz.qnty
         tmp#zakaz.sum-base   = round(varprice-base,2) * tmp#zakaz.qnty

         .
    find first shar_ord-line  exclusive-lock   where
        shar_ord-line.doc-code   = loc-ord-num    and
        shar_ord-line.prod-type  = tmp#zakaz.prod-type and
        shar_ord-line.prod-code  = tmp#zakaz.prod-code and
        shar_ord-line.artic      = tmp#zakaz.artic
        no-error  .
    if not available shar_ord-line then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка!"
      view-as alert-box error
    .
  assign shar_ord-line.price-cli  = round(varprice-cli ,2)
         shar_ord-line.price-rubl = round(varprice-rubl,2)
         shar_ord-line.price-base = round(varprice-base,2)
         shar_ord-line.sum-vat    = if var-report-r-b = "rubl" then round(varprice-vat-rubl ,2 )
                                                               else round(varprice-vat-base ,2 )
         shar_ord-line.sum-cli    = round(varprice-cli ,2) * shar_ord-line.cli-qnty
         shar_ord-line.sum-rubl   = round(varprice-rubl,2) * shar_ord-line.qnty
         shar_ord-line.sum-base   = round(varprice-base,2) * shar_ord-line.qnty
         shar_ord-line.vat-pc     = tmp#zakaz.vat-pc
         shar_ord-line.slt-pc     = tmp#zakaz.slt-pc
         .
   assign
      loc-sum-rubl  = loc-sum-rubl + shar_ord-line.sum-rubl
      loc-sum-base  = loc-sum-base + shar_ord-line.sum-base
      loc-sum-cli   = loc-sum-cli  + shar_ord-line.sum-cli
   .
  end.
  /*
  */
 end.
end procedure.


procedure check-rate :
/* -----------------------------------------------------------
  purpose:     проверка заданности курсов и масштабов валют
-------------------------------------------------------------*/
{&start-proc}
define variable flag-recount as logical initial no no-undo.

/*Если курс изменился, то в конце пересчитаем накладную*/
if input frame {&frame-name} loc-exch-rate  <> loc-exch-rate  or
   input frame {&frame-name} loc-exch-scale <> loc-exch-scale or
   input frame {&frame-name} loc-base-rate  <> loc-base-rate  or
   input frame {&frame-name} loc-base-scale <> loc-base-scale then flag-recount = yes.

if input frame {&frame-name} loc-base-rate = ? or
   input frame {&frame-name} loc-base-rate = 0 then do:
  message "Не задан курс базовой валюты.".
  apply "entry" to loc-base-rate in frame {&frame-name}.
  return error.
end.
if input frame {&frame-name} loc-base-scale = ? or
   input frame {&frame-name} loc-base-scale = 0 then do:
  message "Не задан масштаб базовой валюты.".
  apply "entry" to loc-base-scale in frame {&frame-name}.
  return error.
end.
assign  frame {&frame-name}
  loc-base-rate
  loc-base-scale.
if input frame {&frame-name} loc-exch-rate = ? or
   input frame {&frame-name} loc-exch-rate = 0 then do:
  message "Не задан курс валюты поставщика.".
  apply "entry" to loc-exch-rate in frame {&frame-name}.
  return error.
end.
if input frame {&frame-name} loc-exch-scale = ? or
   input frame {&frame-name} loc-exch-scale = 0 then do:
  message "Не задан масштаб валюты поставщика.".
  apply "entry" to loc-exch-scale in frame {&frame-name}.
  return error.
end.
assign
  loc-exch-rate
  loc-exch-scale.
run waitfram-show ("ЖДИТЕ.  Пересчет документа ...").

if flag-recount then do:
   run full-recount.
 display loc-sum-rubl
        loc-sum-base
        loc-sum-cli
        loc-exch-code
        with frame {&frame-name} .
  run openbr in this-procedure  .

end.
run waitfram-hide.
end.
end procedure.


procedure val-ch-vat-type:
{&start-proc}
define buffer d-l-b    for tmp#zakaz.
define buffer bf-goods for ub.goods.
define variable old-vat         like ub.trn-doc.vat-type .
define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.

define variable v-host-code     like ub.sysconf.host-code  no-undo.

  run check-update no-error.
  if error-status:error then return error.
  { gbl/hostcode.i loc-store-type loc-store-code v-host-code }

  assign
    old-vat = vat_type
  .
  assign frame {&frame-name} vat_type.

  find first d-l-b no-lock no-error.
  if available d-l-b then do:
     if vat_type = {&without-vat} and
        old-vat <> {&without-vat} then do:
        message "НДС в строках устанавливаем в 0" view-as alert-box information.
        for each d-l-b :
            assign d-l-b.vat-pc = 0.
        end.
     end.
     else if vat_type <> {&without-vat} and
             old-vat  =  {&without-vat} then do:
        message "НДС в строках устанавливаем из товара " view-as alert-box information.
        for each d-l-b ,
                 first bf-goods where bf-goods.artic     = d-l-b.artic and
                                      bf-goods.prod-type = d-l-b.prod-type and
                                      bf-goods.prod-code = d-l-b.prod-code:
            { gbl/pftxvalg.i bf-goods.gds-code {&vat-tax-code} ? v-host-code loc-store-type loc-store-code v-vat-pc no-error }
            assign d-l-b.vat-pc = v-vat-pc.
        end.

     end.
    end.
    run check-rate no-error.
    if error-status:error then  message      error-status :get-message(1) skip 1 .
    run full-recount no-error.
    if error-status:error then  message      error-status :get-message(1) skip 2 .
 display loc-sum-rubl
        loc-sum-base
        loc-sum-cli
        loc-exch-code
        with frame {&frame-name} .

  run openbr in this-procedure  .

    /* if error-status:error then undo, return error. */


  run ui-on.
end.
end procedure.

procedure val-ch-slt-type:
{&start-proc}
define buffer d-l-b    for tmp#zakaz.
define buffer bf-goods for ub.goods.
define variable old-slt         like ub.trn-doc.slt-type .
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.

  run check-update no-error.
  if error-status:error then return error.
  { gbl/hostcode.i loc-store-type loc-store-code v-host-code }

  assign
    old-slt = slt_type
  .
  assign frame {&frame-name} slt_type.

  find first d-l-b no-lock no-error.
  if available d-l-b then do:
     if slt_type = {&without-slt} and
        old-slt <> {&without-slt} then do:
        message "Налог с продаж в строках устанавливаем в 0" view-as alert-box information.
        for each d-l-b :
            assign d-l-b.slt-pc = 0.
        end.
     end.
     else if slt_type <> {&without-slt} and
             old-slt = {&without-slt} then do:
        message "Налог с продаж в строках устанавливаем из товара " view-as alert-box information.
        for each d-l-b ,
                 first bf-goods where bf-goods.artic     = d-l-b.artic and
                                      bf-goods.prod-type = d-l-b.prod-type and
                                      bf-goods.prod-code = d-l-b.prod-code:
            { gbl/pftxvalg.i bf-goods.gds-code {&slt-tax-code} ? v-host-code loc-store-type loc-store-code v-slt-pc no-error }
            assign d-l-b.slt-pc = v-slt-pc.
        end.

     end.

     run check-rate no-error.
     if error-status :error then message error-status:error error-status :get-message(1)  skip 3.
     /* if error-status:error then undo, return error. */
     run full-recount no-error.
     if error-status :error then message error-status:error error-status :get-message(1)  skip 4 .
     /* if error-status:error then undo, return error. */
      display loc-sum-rubl
              loc-sum-base
              loc-sum-cli
              loc-exch-code
              with frame {&frame-name} .
        run openbr in this-procedure  .

  end.
run ui-on .
end.
end procedure.


procedure check-update:
{&start-proc}
assign frame  dialog-frame cycle-day loc-date-ship  loc-service date-sale-1 date-sale-2 loc-cli-out-doc.
  define buffer ch-ord-line for tmp#zakaz.
  define buffer ch-goods    for ub.goods.
  define buffer ch-units    for ub.units.
  define variable p-same-price as logical no-undo.
  define variable v-insalepr   as logical   no-undo .
  for each ch-ord-line :
      find first ch-goods where ch-goods.artic     = ch-ord-line.artic     and
                                ch-goods.prod-type = ch-ord-line.prod-type and
                                ch-goods.prod-code = ch-ord-line.prod-code no-lock.
      find ch-units where ch-units.unit-name = ch-goods.unit-base no-lock.
      { gbl/gdsobjat.i
        ch-ord-line.obj-type
        ch-ord-line.obj-code
        ch-ord-line.artic
        ch-ord-line.prod-type
        ch-ord-line.prod-code
        "'insalepr=request'":U
        v-insalepr
      }
      if v-insalepr = true then do:
         message "Товар " ch-goods.artic " " ch-goods.prod-type " " ch-goods.prod-code
                 " принимается по продажной цене. Смена цен недопустима."
                 view-as alert-box error.
         return error.
      end.
  end.
end.
end procedure.


procedure disp-exch:
{&start-proc}
display
 loc-exch-rate
 loc-exch-scale
 loc-base-rate
 loc-base-scale
 with frame {&frame-name}.
 end.
end procedure.


procedure r-acc-proc :
{&start-proc}
run check-update no-error.
if error-status:error then return no-apply.
run check-exch no-error.
if error-status:error then return no-apply.
g#log = yes.
message "Подставить БИРЖЕВЫЕ курсы базовой валюты :" base-abbr "и валюты поставщика :"
                 ub.currency.curr-abbr "на дату растаможивания ?"
                  view-as alert-box question buttons ok-cancel
                  update g#log.
if g#log <> true then return no-apply.
find last ub.curr-accnt where ub.curr-accnt.curr-code = base-code
        use-index pi no-lock no-error.

if not available ub.curr-accnt then do:
  message "На эту дату неизвестен курс базовой валюты.".
  apply "entry" to loc-base-rate in frame {&frame-name}.
  return no-apply.
end.
     loc-base-rate  = ub.curr-accnt.exch-rate .
     loc-base-scale = ub.curr-accnt.exch-scale.
     loc-base-rate:screen-value  = string(curr-accnt.exch-rate) .
     loc-base-scale:screen-value = string(curr-accnt.exch-scale).


display loc-base-rate
        loc-base-scale
     with frame d-in-doc.

find last ub.curr-accnt where ub.curr-accnt.curr-code = input loc-exch-code
           use-index pi no-lock no-error.
if not available ub.curr-accnt then do:
  message "На дату "  + " неизвестен курс валюты поставщика.".
  apply "entry" to loc-exch-rate.
  return no-apply.
end.
 loc-exch-rate  = ub.curr-accnt.exch-rate .
 loc-exch-scale = ub.curr-accnt.exch-scale.
 loc-exch-rate:screen-value  = string(curr-accnt.exch-rate ).
 loc-exch-scale:screen-value = string(curr-accnt.exch-scale).

disp loc-exch-rate
     loc-exch-scale with frame d-in-doc.
run check-rate.
run ui-on.
run disp-exch.
end.
end procedure.


procedure ui-on :
 {&start-proc}
run vg-TOG-type.
hide loc-art in frame {&frame-name}
 loc-name
 loc-code .

 loc-art  = "" .

 /* Использовние валюты клиента */
if g#type <> {&o-f} then do:
    if curclivalue <> "no" then do:
            if loc-exch-code <> 0 then enable r-acc loc-exch-rate loc-exch-scale with frame {&frame-name}.
            enable loc-exch-code r-currency with frame {&frame-name}.
    end.
    else do:
          hide r-acc r-currency in frame {&frame-name}.
    end.

    enable loc-base-rate loc-base-scale with frame {&frame-name}.


    if curclivalue <> "no" then do:
            find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
            if available ub.currency then disp ub.currency.curr-abbr with frame {&frame-name}.
                                  else disp ? @ ub.currency.curr-abbr with frame {&frame-name}.
    end.
    else DO:
      hide ub.currency.curr-abbr in frame {&frame-name}.
    END.

if multdtypvalue <> "no"
    then enable  vat_type slt_type with frame {&frame-name}.
    else disable  vat_type slt_type with frame {&frame-name}.

/* {&open-query-{&browse-name}} */

end.
end.
end procedure .

procedure paytype-leave-proc:
{&start-proc}
define buffer paytype-clients for ub.pay-type.
    if g#type <> {&o-f} then do:
      assign  frame {&frame-name}  paytype .
            if paytype <> ? or paytype <> 0 then do:
                    find first paytype-clients where paytype = paytype-clients.obj-code  no-lock no-error.
                    if error-status :error then error-status :error = false .

                    if avail paytype-clients then do:
                          loc-pay-type = paytype-clients.obj-name .
                          loc-pay-type:screen-value  = paytype-clients.obj-name .
                          display  paytype loc-pay-type with frame {&frame-name}.
                          enable   paytype loc-pay-type b-chg b-producer b-alt-post with frame {&frame-name}.
                    end.
                    else do:

                          find first paytype-clients where paytype = v-cntxp-in-pay no-lock no-error.
                          if available paytype-clients then do:
                            assign
                              paytype = v-cntxp-in-pay
                              loc-pay-type = paytype-clients.obj-name
                              .
                              if available shar_ord-doc then
                                 shar_ord-doc.pay-code = v-cntxp-in-pay
                            .
                            display  paytype loc-pay-type with frame {&frame-name}.
                          end.
                    end.
            end.
    end.
end.
end procedure.


procedure  r-paytype-choose :
{&start-proc}
define variable rid-list    as  character no-undo . /* список recid'ов выбранных клиентов */
define buffer paytype# for ub.pay-type.

  run ref/paytype.w (input parparentproc, input "b-sel", output  rid-list).
  assign rep-rec3 = integer(rid-list) no-error.
  find first paytype# where recid(paytype#) = rep-rec3 no-lock no-error.
  if avail paytype# then
    assign
      paytype = paytype#.obj-code
      loc-pay-type= paytype#.obj-name
      .
  enable  loc-pay-type paytype  with frame {&frame-name}.
  display loc-pay-type paytype with frame {&frame-name}.

end.
end procedure.

procedure local-conf-rd:
{&start-proc}
{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_multdtyp} then multdtypvalue = string (thbjattr_thbj-attr.property-value-logical) .
  if thbjattr_thbj-attr.prop-code = {&attr-nakl-glob_curcli}   then curclivalue   = string (thbjattr_thbj-attr.property-value-logical) .
end.

{ gbl/getsect.i run "''" 0 {&attr-ord-global} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-ord-global_ordshipd} then v-dayship = thbjattr_thbj-attr.property-value-integer .
end.

{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-contr-in} }
for each thbjattr_thbj-attr :
  if thbjattr_thbj-attr.prop-code = {&attr-contr-in_contr-in-income} then v-mastc = thbjattr_thbj-attr.property-value-logical .
end.
empty temp-table thbjattr_thbj-attr.

if v-mastc = true then varcontract = "yes"  .

{ gbl/conf-rd.i "'edoc-nn'" "''" "''" 0 "''" "''" "''"   no par-is-edoc-nn par-type no-error }
{ gbl/conf-rd.i "'is-edi'"   "''" "''" 0 "''" "''" "''"  no par-is-edi     par-type      no-error}
assign
is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
is-edi     = lookup(par-is-edi,     "true,yes":U) > 0
.
end.
end procedure.


procedure mode-on :
{&start-proc}
  define buffer buf_contract for ub.contract  .
  define buffer buf_sysconf for ub.sysconf  .
  { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code to-day }

  enable b-delivery with frame {&frame-name} .

  if g#type = {&o-f} then do:
      t-auto = true .
      display t-auto with frame  {&frame-name}.
  end.


  /*  ЕСЛИ ПРОСТО ЖИТЬ НЕ МОГУТ БЕЗ ГАЛОЧКИ АВТО НАДО РАСКОМЕНТИРОВАТЬ НИЖЕСЛЕДУЮЩИЙ КУСОК !!! */
  if g#type <> {&o-f} then do:
      t-auto = true .
      display t-auto with frame  {&frame-name}.
  end.


    if t-action = "add":u then do:  /* add */
      find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj .

          { cus/ord-code.i
            'main'
            v-cntxt-db-num
            v-cntxt-obj-type
            v-cntxt-obj-code
            v-i-doc
            loc-ord-num
            }


        assign
          loc-status    = {&g___new}
          date-1 = to-day - 7
          date-2 = to-day
          loc-obj-name = ""
          loc-obj-name:screen-value in frame {&frame-name} = ""
          doc-date = to-day
          loc-date-ship = to-day + v-dayship
          date-sale-1 = to-day + v-dayship
          date-sale-2 = to-day + 1 + v-dayship
          loc-hour = 10
          loc-time-ship = string(loc-hour,"99") + ":" + string(loc-min,"99")
          loc-store-code  = v-cntxt-obj-code
          loc-store-type  = v-cntxt-obj-type
          loc-doc-type    = g#type
          paytype         = v-cntxp-in-pay
          no-error
          .
        run paytype-leave-proc.
        /* Валюта поставщика */
        loc-exch-code = 0 .
        find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
          if available ub.currency then disp ub.currency.curr-abbr with frame {&frame-name}.
                                else disp ? @ ub.currency.curr-abbr with frame {&frame-name}.

        find last ub.curr-accnt where ub.curr-accnt.curr-code = ub.currency.curr-code  use-index pi no-lock no-error.
          if available ub.curr-accnt then assign
            loc-exch-rate = ub.curr-accnt.exch-rate
            loc-exch-scale = ub.curr-accnt.exch-scale.
          else assign
            loc-exch-rate = ?
            loc-exch-scale = ?.

        /* Базовая валюта */

        { gbl/baserate.i v-cntxt-host-code-obj
                    DOC-DATE
                    loc-base-rate
                    loc-base-scale
                    no-error   }

        vat_type = {&inc-vat} .
        slt_type = {&without-slt} .

    disable b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame {&frame-name}.

        /* Контрагент для ОФ */
    if g#type = {&o-f} then do:
      find first buf-cli where buf-cli.obj-code = v-cntxt-host-code-obj and
                                buf-cli.obj-type = {&cmp} no-lock no-error .

      if available buf-cli then
      assign
          loc-cli-code = buf-cli.obj-code
          loc-cli-type = buf-cli.obj-type
          loc-obj-name = buf-cli.obj-name
          no-error.
      else
      assign
          loc-cli-code = ?
          loc-cli-type = ?
          loc-obj-name = ?
          no-error.
      disable loc-cli-code  loc-cli-type  loc-obj-name  r-clients  with frame {&frame-name}.
      display loc-cli-code  loc-cli-type  loc-obj-name  r-clients  with frame {&frame-name}.
      enable  b-spec b-add b-way b-del b-chg b-producer b-alt-post b-main-calc with frame {&frame-name}.
      find first buf-cli where buf-cli.obj-code = v-cntxt-host-code-obj and
                              buf-cli.obj-type = {&cmp} no-lock no-error .
      rep-rec = recid(buf-cli) .
    end.
      /*  добавим */
    create shar_ord-doc .
      assign
          shar_ord-doc.doc-code     = loc-ord-num
          shar_ord-doc.start-date   = date-1
          shar_ord-doc.end-date     = date-2
          shar_ord-doc.doc-date     = doc-date
          shar_ord-doc.cli-code     = loc-cli-code
          shar_ord-doc.cli-name     = loc-obj-name
          shar_ord-doc.cli-type     = loc-cli-type
          shar_ord-doc.creid        = v-cntxt-userid
          shar_ord-doc.agnt         = agnt
          shar_ord-doc.boss         = boss
          shar_ord-doc.fact-date   = ?
          shar_ord-doc.pay-code    = paytype
          shar_ord-doc.ship-date   = loc-date-ship
          shar_ord-doc.sum-service = loc-service

          shar_ord-doc.flag_        = false
          shar_ord-doc.status_      = {&g___new}
          shar_ord-doc.wrkr         = wrkr
          shar_ord-doc.host-code    = v-cntxt-host-code-obj
          shar_ord-doc.doc-type     = loc-doc-type
          /*shar_ord-doc.tot-lines    = k    */
          shar_ord-doc.order-type   = tog-type
          shar_ord-doc.cycle-day    = cycle-day
          shar_ord-doc.pay-day      = pay-day
          shar_ord-doc.obj-type     = loc-store-type
          shar_ord-doc.obj-code     = loc-store-code
          shar_ord-doc.vat-type     = vat_type
          shar_ord-doc.slt-type     = slt_type
          shar_ord-doc.base-rate   =  loc-base-rate
          shar_ord-doc.base-scale  =  loc-base-scale
          shar_ord-doc.cli-qnty    =  loc-cli-qnty
          shar_ord-doc.exch-code   =  loc-exch-code
          /* shar_ord-doc.exch-date   =  loc-exch-date */
          shar_ord-doc.exch-rate   =  loc-exch-rate
          shar_ord-doc.exch-scale  =  loc-exch-scale
          shar_ord-doc.out-code    =  loc-out-code
          shar_ord-doc.qnty        =  loc-qnty
          shar_ord-doc.sum-base    =  loc-sum-base
          shar_ord-doc.sum-cli     =  loc-sum-cli

          shar_ord-doc.sum-rubl    =  loc-sum-rubl
          shar_ord-doc.tot-lines   =  loc-tot-lines
          shar_ord-doc.e-method    =  e-method
          shar_ord-doc.date-sale-1  = date-sale-1
          shar_ord-doc.date-sale-2  = date-sale-2
          shar_ord-doc.deliv-type-code    = v-deliv-type-code
          shar_ord-doc.obj-point-code     = v-point-obj-code
          shar_ord-doc.cli-point-code     = v-point-cli-code
          shar_ord-doc.obj-point-db-num   = v-point-obj-db-num
          shar_ord-doc.cli-point-db-num   = v-point-cli-db-num
          shar_ord-doc.transport-host-code    = v-transport-host-code
          shar_ord-doc.transport-cli-type     = v-transport-cli-type
          shar_ord-doc.transport-cli-code     = v-transport-cli-code
          shar_ord-doc.transport-contract  = v-transport-contract
          shar_ord-doc.transport-condition = v-transport-condition
          shar_ord-doc.transport-value     = v-transport-value
          shar_ord-doc.sum-ship            = v-transport-sum
          shar_ord-doc.transport-vat       = v-transport-vat
          .

          find first buf_contract where buf_contract.contract-code = loc-contract
                                    and buf_contract.host-code     = v-cntxt-host-code-obj
                                        no-lock no-error .
          if available buf_contract then do:
                       shar_ord-doc.contract-code = buf_contract.contract-code .
          end.
          else shar_ord-doc.contract-code = 0.
        .

      assign
        shar_ord-doc.ship-time   = ( loc-hour * 3600 ) +  ( loc-min * 60 )
        .
      doc-rec =  recid (shar_ord-doc).
    end.

    if t-action = "chg":u or t-action = "copy":u then do:  /* chg copy */
        run chg-action in this-procedure  .
        run enable_ui in this-procedure  .
    end.

    if t-action = "lkp":u then do:  /* lkp */
        assign
            tmp#zakaz.cli-art   :read-only in browse {&browse-name} =  true
            tmp#zakaz.cli-qnty  :read-only in browse {&browse-name} =  true
            tmp#zakaz.price-cli :read-only in browse {&browse-name} =  true  no-error .
        run chg-action  in this-procedure  .
        run enable_ui_2  in this-procedure  .
    end.
end.
if loc-cli-type <> "" and loc-cli-code <> 0  then do:
  assign
  is-edoc-nn-doc = status-is-edoc-nn ( input is-edoc-nn
                                      , input loc-cli-type
                                      , input loc-cli-code
                                      , input loc-store-type
                                      , input loc-store-code
                                      ) .
  assign
  is-edi-doc = status-is-edi ( input is-edi
                              , input loc-cli-type
                              , input loc-cli-code
                              , input loc-store-type
                              , input loc-store-code
                              , output v-dm-edi
                              ) .
end.


end procedure.


procedure proc-eq-tmp-price :
{&start-proc}
define input parameter p-recid as recid no-undo .
define input parameter tt as character no-undo  .

define buffer bufff-units  for ub.units     .
define buffer ll-tmp#zakaz for tmp#zakaz    .
define buffer buf_doc-line for ub.doc-line  .

define variable max-num as integer no-undo .
define variable t-type as character no-undo .

find first tmp#zakaz   where
           tmp#zakaz.prod-type = ub.goods.prod-type and
           tmp#zakaz.prod-code = ub.goods.prod-code and
           tmp#zakaz.artic     = ub.goods.artic
           no-error.

 if not available tmp#zakaz  then  do:
    max-num = 0.
    for each  ll-tmp#zakaz  where ll-tmp#zakaz.doc-code        = loc-ord-num and
                                  ll-tmp#zakaz.gds-code        <> ub.goods.gds-code :
        if max-num < ll-tmp#zakaz.line-num then
           max-num = ll-tmp#zakaz.line-num .
    end.

  create tmp#zakaz .
  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = ub.goods.gds-code
    tmp#zakaz.prod-type       = ub.goods.prod-type
    tmp#zakaz.prod-code       = ub.goods.prod-code
    tmp#zakaz.artic           = ub.goods.artic
    tmp#zakaz.line-num        = max-num + 1
  .
 end.
  assign
    tmp#zakaz.doc-code        = loc-ord-num
    tmp#zakaz.gds-code        = ub.goods.gds-code
    tmp#zakaz.prod-type       = ub.goods.prod-type
    tmp#zakaz.prod-code       = ub.goods.prod-code
    tmp#zakaz.artic           = ub.goods.artic
    tmp#zakaz.gds-name        = ub.goods.gds-name
    tmp#zakaz.negative-rest   = ub.goods.negative-rest
    tmp#zakaz.deadline        = ub.goods.deadline
    tmp#zakaz.unit-base       = ub.goods.unit-base
    tmp#zakaz.unit-cli        = ub.goods.unit-cli
    tmp#zakaz.cli-base-rate   = ub.goods.cli-base-rate
    tmp#zakaz.ms-cart         = ub.goods.qnty-cart
    .
   find first ub.ext-artic where ub.ext-artic.cli-type    = loc-cli-type
                          and ub.ext-artic.cli-code    = loc-cli-code
                          and ub.ext-artic.gds-code    = ub.goods.gds-code
                          and ub.ext-artic.gds-code    = ub.goods.gds-code
                          and ub.ext-artic.status_    <> {&deleted-status} no-error .
  if available ub.ext-artic then do:
     tmp#zakaz.cli-art = ub.ext-artic.ext-artic.
  end.
  else do:
     tmp#zakaz.cli-art = ''.
  end.

  { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} ? v-cntxt-host-code-obj loc-store-type loc-store-code tmp#zakaz.vat-pc no-error }
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-base no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-type       = bufff-units.type .

  find bufff-units where bufff-units.unit-name = tmp#zakaz.unit-cli no-lock no-error.
  if available bufff-units then
  assign
    tmp#zakaz.unit-cli-type       = bufff-units.type .


  find first sb-cli-gds where recid(sb-cli-gds) = p-recid no-lock no-error .
  if available sb-cli-gds then do:
        assign
          tmp#zakaz.cancel-date     = sb-cli-gds.cancel-date
          tmp#zakaz.in-qnty         = sb-cli-gds.in-qnty
          tmp#zakaz.out-qnty        = sb-cli-gds.out-qnty
          tmp#zakaz.ret-qnty        = sb-cli-gds.ret-qnty
          tmp#zakaz.in-base         = sb-cli-gds.in-base
          tmp#zakaz.in-rubl         = sb-cli-gds.in-rubl
          tmp#zakaz.out-sum         = sb-cli-gds.out-sum
          tmp#zakaz.ret-sum         = sb-cli-gds.ret-sum
          tmp#zakaz.in-code         = sb-cli-gds.in-code
          tmp#zakaz.last-curr-code  = sb-cli-gds.exch-code
          tmp#zakaz.supp-qnty       = sb-cli-gds.supp-qnty
          tmp#zakaz.supp-base       = sb-cli-gds.supp-base
          tmp#zakaz.supp-rubl       = sb-cli-gds.supp-rubl
        .
        find first buf_doc-line no-lock where
                   buf_doc-line.doc-code  = sb-cli-gds.in-code and
                   buf_doc-line.artic     = sb-cli-gds.artic and
                   buf_doc-line.prod-type = sb-cli-gds.prod-type and
                   buf_doc-line.prod-code = sb-cli-gds.prod-code
                   no-error .
        if available buf_doc-line  then do:
            assign
              tmp#zakaz.unit-cli        = buf_doc-line.unit-cli
              tmp#zakaz.cli-base-rate   = buf_doc-line.cli-base-rate
              .
        end.
  end.
  else do:
  end.
 run last-price (
      input  v-cntxt-host-code-obj ,
      input  tmp#zakaz.artic ,
      input  tmp#zakaz.prod-type ,
      input  tmp#zakaz.prod-code ,
      input  loc-cli-code  ,
      input  loc-cli-type  ,
      input  tmp#zakaz.cli-base-rate ,
      input  loc-exch-code ,
      output tmp#zakaz.price-base ,
      output tmp#zakaz.price-rubl ,
      output tmp#zakaz.price-cli   )
 no-error  .
 if error-status :error then do:
 end.


  If tt <> "doc"  then do:
      find first shar_ord-line   where
          shar_ord-line.doc-code        = loc-ord-num    and
          shar_ord-line.prod-type       = tmp#zakaz.prod-type and
          shar_ord-line.prod-code       = tmp#zakaz.prod-code and
          shar_ord-line.artic           = tmp#zakaz.artic     no-error.

          if not available shar_ord-line  then
             create shar_ord-line .
             buffer-copy tmp#zakaz to shar_ord-line
               assign shar_ord-line.doc-code    = loc-ord-num
               no-error .
  end.
  if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "ошибка"
    view-as alert-box error
  .
  end .

 end. /* start-proc */
end procedure. /* proc-eq-tmp */


procedure choose-menu-add2 :
{&start-proc}

define variable ii         as integer init 0 no-undo.
define variable r-tmp      as recid no-undo .
define variable r-stop     as logical no-undo .
define variable r-exit     as logical no-undo .
define variable l-g#type   as character no-undo .
define variable l-g#status as character no-undo .

l-g#status = g#stat.
l-g#type = g#type.

define variable varschartic  as character initial " " no-undo.
define variable v-ref-list  as character  no-undo.

    run str/chsgdsls.w (
        parParentProc ,
        input "order" + g#type ,
        input "Строка документа № "  ,
        input loc-cli-type ,
        input loc-cli-code ,
        input v-cntxt-host-code-obj,
        input-output varschartic,
        output v-ref-list,
        output table tt-gds-list,
        false
        ) no-error.


   g#type = l-g#type.
   g#stat = l-g#status.

   t-ret =  session:set-wait-state("general") .
   line-mode = {&add-def} .
 _tt:  for each tt-gds-list :
     ii = ii + 1 .
     if ii > 1 then assign line-mode = "ЦИКЛ":u.
        /* Подключаем инклудник для поиска подчиненных договоров  */
        {str/cont-slave-inc.i
             &FIND_FIRST = YES
             &BUFFER_SPECIF = contract-specif
             &P_HOST_CODE = v-cntxt-host-code-obj
             &P_CONTRACT_NUM = loc-contract
             &P_GDS_CODE = tt-gds-list.gds-code
             &NO_LOCK=YES
             &NO_ERROR=YES
        }

      /*
      find first buf_contract-specif no-lock where
                buf_contract-specif.host-code    = v-cntxt-host-code-obj and
                buf_contract-specif.contract-num = loc-contract         and
                buf_contract-specif.gds-code     = tt-gds-list.gds-code no-error .

      */

     if /*v-mastc and */ available contract-specif then do:
       
          run create-tmp in this-procedure  (input "contract-spec":u, "" ) no-error .
     end. 
     else run create-tmp in this-procedure  (input "tt-gds-list":u, "" ) no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "create-tmp"
       view-as alert-box error
     .
     release tmp#zakaz.
     find tmp#zakaz where tmp#zakaz.gds-code = tt-gds-list.gds-code no-error .
        if not  error-status :error  and not t-auto then do:

            run cus/ord-frm.w ( input ParParentProc,  input recid ( tmp#zakaz ) , input line-mode , output r-stop , output r-exit) no-error .
            if r-stop then do:
              run p-delete ( recid ( tmp#zakaz ), input-output ii) .
              leave _tt.
            end.
            if r-exit then do:
               run p-delete ( recid ( tmp#zakaz ) ,input-output ii ) .
            end.

        end.
   end.

   if ii > 0 then disable loc-cli-code loc-cli-type loc-obj-name r-clients with frame {&frame-name}.
    choice = ?.
    run openbr in this-procedure  .
    t-ret =  session:set-wait-state("") .
    message "Добавлено " + string(ii) + " товаров".
 end. /* start-proc */
end procedure. /* choose-menu-add2 */


procedure my-proc-mouse-dbl-click-loc-name :
 do
 on error undo, return error return-value
 :
  assign
  frame {&frame-name} loc-name.

    if last-event:label = "Ctrl-J" then
      find next tmp#zakaz where
                tmp#zakaz.gds-name begins loc-name no-error.
    else
      find first tmp#zakaz where
                 tmp#zakaz.gds-name begins loc-name no-error.

      if not avail tmp#zakaz then return.

      find first shar_ord-line no-lock
            where shar_ord-line.doc-code = loc-ord-num  and
                  shar_ord-line.artic      = tmp#zakaz.artic     and
                  shar_ord-line.prod-type  = tmp#zakaz.prod-type and
                  shar_ord-line.prod-code  = tmp#zakaz.prod-code no-error .



    if available tmp#zakaz and available shar_ord-line then do:
      line-rec = recid (shar_ord-line).
      reposition br-docs to recid line-rec no-error.
    end.
    else do:
      message "Строка не найдена."
              view-as alert-box error.
    end.

  apply "entry" to loc-name in frame {&frame-name}.


 end. /* do */
end procedure. /* my-proc-mouse-dbl-click-loc-name */


procedure init-gds-rec :
 do
 on error undo, return error return-value
 :
 define buffer bb_goods for ub.goods.
 gds-rec = ? .
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .

  if not available TMP#zakaz   then do:
       return.
  end.
  if available tmp#zakaz then do:
      find first bb_goods no-lock where bb_goods.gds-code = tmp#zakaz.gds-code no-error .
      gds-rec = recid (bb_goods).
   end.
 end. /* do */
end procedure. /* init-gds-rec */



procedure p-delete :
 do
 on error undo, return error return-value
 :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
    and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
     or  ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.

    define input parameter tmp-recid as recid no-undo .
    define input-output parameter ii as integer no-undo . .

    find first tmp#zakaz where recid(tmp#zakaz) = tmp-recid no-error .
    if not avail tmp#zakaz then return error.

    find first shar_ord-line   where
        shar_ord-line.doc-code        = loc-ord-num    and
        shar_ord-line.prod-type       = tmp#zakaz.prod-type and
        shar_ord-line.prod-code       = tmp#zakaz.prod-code and
        shar_ord-line.artic           = tmp#zakaz.artic     no-error.
    if not available shar_ord-line  then  return error .
    delete shar_ord-line .
    delete tmp#zakaz .
    ii = ii - 1 .

 end. /* do */
end procedure. /* p-delete */


procedure CHOOSE-MENU-way1 :
 do
 on error undo, return error return-value
 :
 assign frame {&frame-name} LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.

 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.

 run cus/ord-way.w (    pARPARENTPROC,
                    shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,

                   1,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .

 end. /* do */
end procedure. /* CHOOSE-MENU-way1 */



procedure CHOOSE-MENU-way2 :
 do
 on error undo, return error return-value
 :

 assign frame {&frame-name} LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-way.w (   pARPARENTPROC,
                   shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   2,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .




 end. /* do */
end procedure. /* CHOOSE-MENU-way2 */

procedure CHOOSE-MENU-way3 :
 do
 on error undo, return error return-value
 :

 assign frame {&frame-name} LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-waya.w (  PARPARENTPROC ,
                   shar_ord-line.doc-code  ,
                   1,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .

 end. /* do */
end procedure. /* CHOOSE-MENU-way2 */

procedure CHOOSE-MENU-way4 :
 do
 on error undo, return error return-value
 :

 assign frame {&frame-name} LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 run ver-date  in this-procedure .
 if return-value <> "" then return.
 find current shar_ord-line no-lock no-error .
 if not avail shar_ord-line then return.
 run cus/ord-waya.w (   PARPARENTPROC,
                    shar_ord-line.doc-code  ,
                   2,
                    LOC-DATE-SHIP  ,
                    DATE-sale-1    ,
                    DATE-sale-2    ,
                    loc-store-type ,
                    loc-store-code ,
                    loc-doc-type  ) .

 end. /* do */
end procedure. /* CHOOSE-MENU-way2 */



procedure ver-date :
do
on error undo, return error return-value
:
  assign frame {&frame-name}
  LOC-DATE-SHIP
  DATE-sale-1
  DATE-sale-2
  doc-date
                            .
  if date-sale-1 = ?
  and is-edi-doc
  then do:
    message
    "Не задана дата начала продажи !!!"
    view-as alert-box error .
    return error "Не задана дата начала продажи !!!".
  end.
  if date-sale-2 = ?
  and is-edi-doc
  then do:
    message
    "Не задана дата конца продажи !!!"
    view-as alert-box error .
    return error "Не задана дата конца продажи !!!".
  end.

  if t-action = "add":u then do:
    if LOC-DATE-SHIP < to-day then do:
      message "Дата доставки меньше текущей !!! "
      view-as alert-box information .
      return error "Дата доставки меньше текущей !!! "  .
    end.
  end.


  if LOC-DATE-SHIP > DATE-sale-1 then do:
    message "Дата доставки больше даты начала продажи !!! "
    view-as alert-box information .
    return error "Дата доставки больше даты начала продажи !!! ".
  end.

  if DATE-sale-1 > DATE-sale-2 then do:
    message "Не правильный интервал даты продажи !!! "
    view-as alert-box information .
    return error "Не правильный интервал даты продажи !!! ".
  end.

  return .
end. /* do */
end procedure. /* ver-date */


procedure proc_import_TEXT :
 do
 on error undo, return error return-value
 :
define variable l-ok as logical no-undo .
  message "Проводить импорт из формата мобильного сканера ? "
    view-as alert-box question
    buttons yes-no
    update l-ok .
  if l-ok = false then return.
  if shar_ord-doc.cli-code = 0 or shar_ord-doc.cli-code = ? then do:
      find first shar_ord-doc where recid(shar_ord-doc) = doc-rec exclusive-lock no-error.
        shar_ord-doc.cli-code = loc-cli-code .
        shar_ord-doc.cli-type = loc-cli-type .
   end.

 run cus/scan-n.p ( parparentproc, loc-ord-num ) .
  for each shar_ord-line where shar_ord-line.doc-code = shar_ord-doc.doc-code  no-lock :
    run create-tmp in this-procedure  (input "doc":u,"") no-error .
  end.
  run create-tmp-dtl  .
  run openbr in this-procedure  .
 end. /* do */
end procedure. /* proc_import_TEXT */



procedure proc-renum :
 do
 on error undo, return error return-value
 :
define variable g-ok as logical no-undo .
define variable g as integer no-undo .
define buffer buf_ord-line for ub.ord-line.
define buffer t-tmp#zakaz for tmp#zakaz.
 message " Перенумеровать список товаров ? "
    view-as alert-box question
    buttons yes-no
    UPDATE g-ok
    .
    if g-ok = false then return.
    g = 0 .
    for each t-tmp#zakaz by t-tmp#zakaz.line-num :
        g = g + 1.
        t-tmp#zakaz.line-num = g.
        find first buf_ord-line  exclusive-lock  where
                    buf_ord-line.doc-code        = loc-ord-num    and
                    buf_ord-line.prod-type       = t-tmp#zakaz.prod-type and
                    buf_ord-line.prod-code       = t-tmp#zakaz.prod-code and
                    buf_ord-line.artic           = t-tmp#zakaz.artic
                    no-error  .
                    if not error-status :error then
                        buf_ord-line.line-num = t-tmp#zakaz.line-num .
    end.
    run openbr.
    {&open-query-br-docs-sort} BY {&label-clmn_18} .
 end. /* do */
end procedure. /* proc-renum */

procedure proc-gds-prt:
 do
 on error undo, return error return-value
 :
  find current shar_ord-line  no-lock  no-error .
  if not avail shar_ord-line then return.
  find first TMP#zakaz no-lock    where
              shar_ord-line.prod-type       = tmp#zakaz.prod-type and
              shar_ord-line.prod-code       = tmp#zakaz.prod-code and
              shar_ord-line.artic           = tmp#zakaz.artic        no-error  .

  if not avail TMP#zakaz   then do:
       message error-status :get-message(1) .
       return.
       end.

  { cus/ord-lib.i btn-dtl }
  apply "VALUE-CHANGED":U to br-docs in frame {&frame-name}.
  {&OPEN-QUERY-BR-docs-2}
 end.
END PROCEDURE.



procedure proc_export_ras : /* Экспорт расчета в Ехс */
 do
 on error undo, return error return-value
 :
 define variable old-e-method as character no-undo .
    old-e-method = e-method.
    e-method     = temp-e-method.

 assign frame  {&frame-name} {&assign-objects} .
 run ver-date .
 if return-value <> "" then return.

find first tmp#zakaz no-error  .
  if avail tmp#zakaz then do:
    run cus/ord-m.w (input PARPARENTPROC , input "export":u , input g#type ) .
    temp-e-method = e-method.
    e-method = old-e-method.
  end.
 end. /* do */
end procedure. /* proc_export_ras */


procedure r-contract-choose :
 do
 on error undo, return error return-value
 :
define buffer buff_contract for  ub.contract .
define variable   p-rid-list   as character no-undo . /* recid выбранных договоров */

if loc-contract > 0  then do:
  find first buff_contract no-lock where
            buff_contract.host-code = v-cntxt-host-code-obj and
            buff_contract.contract-code = loc-contract no-error .
  if available buff_contract then
               p-rid-list = string(recid(buff_contract)).
end.

  run str/cont-all.w (
      input   parparentproc  ,
      input   v-cntxt-host-code-obj     ,
      input   "b-sel"         ,
      input   "firm-curr"      ,
      input   loc-cli-type    ,
      input   loc-cli-code    ,
      input   ?               ,
      input   ?               ,
      input   "current"       ,
      input   {&income}       ,
      input-output p-rid-list )
      .
    if p-rid-list > '' then do:
    find first buff_contract no-lock where recid(buff_contract) = integer(p-rid-list) no-error .
        if available buff_contract then
           loc-contract        =  buff_contract.contract-code .
           else loc-contract   = 0.
       display loc-contract with frame {&frame-name}.
    
      run from-contract no-error .
      if error-status :error then return error return-value .
    end.
 end. /* do */
end procedure. /* r-contract-choose */


procedure from-contract :
 do
 on error undo, return error return-value
 :
define buffer buf_contract for ub.contract  .
  if loc-contract <> 0 then do:
      find first buf_contract where buf_contract.contract-code = loc-contract
                            and buf_contract.host-code         = v-cntxt-host-code-obj
                            no-lock no-error .
      if not available buf_contract then do:
        message "Неверно введен Номер договора!!! " view-as alert-box .
        return error.
      end.
  end.
  if  available buf_contract then do:
      if buf_contract.status_ = {&close-contr} then do:
            loc-contract = 0 .
            message "Договор в статусе <<зкр>> !!! " view-as alert-box information .
            display loc-contract with frame {&frame-name} .
            return error.
      end.

      if  buf_contract.contract-date-end <> ? and buf_contract.contract-date-end < date(loc-date-ship:screen-value) then do:
            loc-contract = 0 .
            message "Дата закрытия Договора " buf_contract.contract-date-end
                   " меньше даты доставки заказа " loc-date-ship:screen-value  view-as alert-box information .
            display loc-contract with frame {&frame-name} .
            return error.
      end.

      /* Валюта и договора */
      loc-exch-code       = buf_contract.curr-code .
      find ub.currency where ub.currency.curr-code = loc-exch-code no-lock no-error.
      if available ub.currency then do:
          find last ub.curr-accnt where ub.curr-accnt.curr-code = loc-exch-code  use-index pi no-lock no-error.
            if available ub.curr-accnt then
                assign
                  loc-exch-rate = ub.curr-accnt.exch-rate
                  loc-exch-scale = ub.curr-accnt.exch-scale
                  .
            else
                assign
                  loc-exch-rate = ?
                  loc-exch-scale = ?
                  .

      end.
      if available currency then disp loc-exch-code loc-exch-rate loc-exch-scale currency.curr-abbr with frame {&frame-name}.
                            else disp ? @ currency.curr-abbr with frame {&frame-name}.
     /* Тип НДС */
        /* Подключаем инклудник для поиска подчиненных договоров  */
        {str/cont-slave-inc.i
             &FIND_FIRST = YES
             &BUFFER_SPECIF = ub.contract-specif
             &P_HOST_CODE = v-cntxt-host-code-obj
             &P_CONTRACT_NUM = loc-contract
             &NO_LOCK=YES
             &NO_ERROR=YES
        }

/*
        find first  ub.contract-specif no-lock where
                    ub.contract-specif.contract-num = loc-contract and
                    ub.contract-specif.host-code    = v-cntxt-host-code-obj
                    no-error .
*/
        if available ub.contract-specif then do:
        /* Если есть спецификация */
            define variable old_vat_type as character no-undo .
            define variable vat_type1 as character no-undo .
            define variable v-diff as logical   no-undo .
            v-diff = false  .
            {str/cont-slave-inc.i
                 &FIND_FIRST = YES
                 &BUFFER_SPECIF = ub.contract-specif
                 &P_HOST_CODE = v-cntxt-host-code-obj
                 &P_CONTRACT_NUM = loc-contract
                 &NO_LOCK=YES
                 &NO_ERROR=YES
            }
/*
              find first  ub.contract-specif no-lock where
                          ub.contract-specif.contract-num = loc-contract and
                          ub.contract-specif.host-code    = v-cntxt-host-code-obj
                          no-error .

*/
                if available ub.contract-specif then do:
                  vat_type1 = ub.contract-specif.vat-type .
                end.
                {str/cont-slave-inc.i
                     &FOR_ = YES
                     &EACH_ = YES
                     &BUFFER_SPECIF = ub.contract-specif
                     &P_HOST_CODE = v-cntxt-host-code-obj
                     &P_CONTRACT_NUM = loc-contract
                     &NO_LOCK=YES
                }

/*
              for each ub.contract-specif no-lock where
                      ub.contract-specif.contract-num = loc-contract and
                      ub.contract-specif.host-code    = v-cntxt-host-code-obj
                      :
*/
                if vat_type1 <> ub.contract-specif.vat-type then do:
                  v-diff = true .
                  leave.
                end.
              end.
              if v-diff = true then do:
                message "В договоре в спецификации указаны разные типы НДС. Выберите правильный тип вручную." view-as alert-box information .
              end.
              else do:
                  old_vat_type = vat_type .
                  {str/cont-slave-inc.i
                       &FOR_ = YES
                       &EACH_ = YES
                       &BUFFER_SPECIF = ub.contract-specif
                       &P_HOST_CODE = v-cntxt-host-code-obj
                       &P_CONTRACT_NUM = loc-contract
                       &NO_LOCK=YES
                  }
/*
                  for each ub.contract-specif no-lock where
                          ub.contract-specif.contract-num = loc-contract and
                          ub.contract-specif.host-code    = v-cntxt-host-code-obj
                          :
*/
                    vat_type = ub.contract-specif.VAT-type.
                    leave.
                  end.
                if old_vat_type <> vat_type then do:
                    message substitute("Изменен тип НДС c <<&1>> на <<&2>> (взято из спецификации по договору) !!! " , old_vat_type , vat_type )  view-as alert-box information .
                end.
                run full-recount in this-procedure .
                display vat_type with frame {&frame-name}.
            end.
       end.
     /* Доставка */
     assign
        v-transport-cli-code     =  buf_contract.transport-cli-code
        v-transport-cli-type     =  buf_contract.transport-cli-type
        v-transport-host-code    =  buf_contract.transport-host
        v-transport-contract     =  buf_contract.transport-contract
        v-transport-condition    =  buf_contract.transport-uslov
        v-transport-value        =  buf_contract.transport-value
        .


  end.


 end. /* do */
end procedure. /* from-contract */

procedure del-3 :
 do
 on error undo, return error return-value
 :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
    or  ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
    then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
    end.

define variable ii as integer init 0 no-undo.
   run str/gds-list.w (
    input parparentproc
   ,input v-cntxt-host-code-obj
   ,input v-cntxt-obj-type
   ,input v-cntxt-obj-code )
   .
   t-ret =  session:set-wait-state("general") .
   for each gds-list no-lock :
     find first   tmp#zakaz  where
                  tmp#zakaz.prod-type       = gds-list.prod-type and
                  tmp#zakaz.prod-code       = gds-list.prod-code and
                  tmp#zakaz.artic           = gds-list.artic  no-error.
     if avail tmp#zakaz then do:
         ii = ii + 1.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.
                delete  tmp#zakaz     no-error.
            end.

         end.
   end.
   choice = ?.
   t-ret =  session:set-wait-state("") .
   run openbr in this-procedure  .
   message "Удалено " + string(ii) + " товаров".
end.
end procedure.

procedure del-2 :
 do
 on error undo, return error return-value
 :

  find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
  if available shar_ord-doc
  and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
   or  ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
  then do:
      message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
      return .
  end.

define variable ii as integer init 0 no-undo.
   t-ret =  session:set-wait-state("general") .
   for each tmp#zakaz where tmp#zakaz.local-mark = "*" no-lock :
         ii = ii + 1.
            do transaction :
                find first shar_ord-line  exclusive-lock   where
                    shar_ord-line.doc-code        = loc-ord-num    and
                    shar_ord-line.prod-type       = tmp#zakaz.prod-type and
                    shar_ord-line.prod-code       = tmp#zakaz.prod-code and
                    shar_ord-line.artic           = tmp#zakaz.artic        no-error  .
                if not error-status :error then
                   delete  shar_ord-line  no-error.
                for each tmp#zakaz-dtl where
                    tmp#zakaz-dtl.doc-code        = loc-ord-num    and
                    tmp#zakaz-dtl.prod-type       = tmp#zakaz.prod-type and
                    tmp#zakaz-dtl.prod-code       = tmp#zakaz.prod-code and
                    tmp#zakaz-dtl.artic           = tmp#zakaz.artic   :
                    delete tmp#zakaz-dtl .
                end.

                   delete  tmp#zakaz     no-error.
            end.
   end.
   choice = ?.
   t-ret =  session:set-wait-state("") .
   run openbr in this-procedure  .
   message "Удалено " + string(ii) + " товаров".
end.
end procedure.

procedure proc_chg_m_export_text :
 do
 on error undo, return error return-value
 :

  g#log = true  .
  message "Экспорт в текстовый файл ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
      tmp-rec = recid( tmp#zakaz ).
      do while available tmp#zakaz :
            get prev br-docs.
      end.
      run cus/z-tot.p
        (input parparentproc,
         input "m":u,
         input date-1,
         input date-2) .
end.
end procedure.

procedure proc_ch_b-chg :
 do
 on error undo, return error return-value
 :
 define variable r-tmp  as recid no-undo   .
 define variable r-stop as logical no-undo  .
 define variable r-exit as logical no-undo    .
  find current shar_ord-line  no-lock  no-error .
  if not available shar_ord-line then do:
     return.
  end.
  else do:
  end.

  find first tmp#zakaz no-lock    where
             tmp#zakaz.prod-type = shar_ord-line.prod-type        and
             tmp#zakaz.prod-code = shar_ord-line.prod-code        and
             tmp#zakaz.artic     = shar_ord-line.artic            no-error  .

  if not avail tmp#zakaz   then do:
       message error-status :get-message(1)
       shar_ord-line.prod-type
       shar_ord-line.prod-code
       shar_ord-line.artic
       .
       return no-apply.
       end.

  tmp-rec =  recid ( shar_ord-line ) .
  if t-action = "lkp":u then do:
     line-mode = {&lookup} .
  end.
  else do:
    line-mode = {&update} .
    assign frame {&frame-name} loc-date-ship
                              date-sale-1
                              date-sale-2 .
    run ver-date  .
    if return-value <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
       return.
       end.
   end.
  r-tmp = recid ( shar_ord-line ) .
  run cus/ord-frm.w ( input ParParentProc , input recid ( tmp#zakaz ) , input line-mode , output r-stop , output r-exit) no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "123"
    view-as alert-box error
  .
  if t-action <> "lkp":u then do:
      run openbr in this-procedure  .
      reposition br-docs to recid tmp-rec no-error.
  end.

end.
end procedure.

procedure show-contract-code :

  do
  on error undo, return error return-value
  :
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .

  if t-action <> "add":u then do:
    if available shar_ord-doc
    then do:
      if shar_ord-doc.contract-code = 0
      then do:
        message
          "У заказа не задан договор" skip
          view-as alert-box information .
      end.
      else do:
        define variable v-recid as recid no-undo .

        { gbl/hostcode.i
          shar_ord-doc.obj-type
          shar_ord-doc.obj-code
          v-host-code
          no-error
        }
        if error-status :error then v-host-code = shar_ord-doc.host-code .

        /* показать контракт */
        find first buf_contract no-lock
          where buf_contract.host-code     = v-host-code
            and buf_contract.contract-code = shar_ord-doc.contract-code
          no-error .
        if available buf_contract
        then do:
          assign
            v-recid = recid( buf_contract )
          .
          run str/sh-contr.p
            (input  parParentProc
            ,input v-recid
            ) .
        end.
        else do:
          message
            "Договор не найден" skip
            "Код фирмы" v-host-code skip
            "Код договора" shar_ord-doc.contract-code skip
            "Объект" shar_ord-doc.obj-type shar_ord-doc.obj-code skip
            view-as alert-box error .
        end.
      end.
    end.
  end.
  else do:
      find first buf_contract no-lock
      where buf_contract.host-code     = v-cntxt-host-code-obj
        and buf_contract.contract-code = loc-contract
      no-error .
      if available buf_contract
      then do:
        assign
          v-recid = recid( buf_contract )
        .
        run str/sh-contr.p
          (input  parParentProc
          ,input v-recid
          ) .
        end.
  end.
  end.

end procedure. /* show-contract-code */

procedure show-protocol :

  do
  on error undo, return error return-value
  :
define variable v-gds-code as integer   no-undo .
define buffer buf1_goods for ub.goods  .
  find current shar_ord-line  no-lock  no-error .
  if not available shar_ord-line then return .
  v-gds-code = shar_ord-line.gds-code .
  if shar_ord-line.gds-code = 0  or shar_ord-line.gds-code = ? then do:
     find first buf1_goods no-lock where
                buf1_goods.artic = shar_ord-line.artic and
                buf1_goods.prod-type = shar_ord-line.prod-type and
                buf1_goods.prod-code = shar_ord-line.prod-code no-error .
     v-gds-code = buf1_goods.gds-code .
  end.

  run cus/ord-prot.w
      ( input loc-ord-num ,
        input v-gds-code
        ) .
  end.

end procedure. /* show-protocol */


PROCEDURE edoc-edi-proc :
if  ((is-edoc-nn and
    ( shar_ord-doc.ord-int1 = int ({&edoc-rpl-ok}) or
      shar_ord-doc.ord-int1 = int ({&edoc-rpl})  or
    ( shar_ord-doc.ord-int1 = int ({&edoc-empty})  and
      shar_ord-doc.ord-int2 = int ({&edoc-return}))
      ))
or  (is-edi and
     (shar_ord-doc.ord-int1 = int ({&edi-ordrsp})
      and
      shar_ord-doc.ord-int2 = int ({&edi-return}))
     )
     )
and   shar_ord-doc.doc-type = {&O-P}
and   shar_ord-doc.status_ = {&g___new}
then do:
      tmp#zakaz.order-cli-qnty:visible in browse {&browse-name} = true .
      tmp#zakaz.ord-dec1:visible       in browse {&browse-name} = true .
  if is-edi then do:
    disable
    loc-cli-out-doc
    with frame {&frame-name} .
  end.
end.
else do:
    tmp#zakaz.order-cli-qnty:visible in browse {&browse-name} = false .
    tmp#zakaz.ord-dec1:visible       in browse {&browse-name} = false .
end.
END PROCEDURE.

PROCEDURE row-display-br-doc :
if  ((is-edoc-nn and
    ( shar_ord-doc.ord-int1 = int ({&edoc-rpl-ok}) or
      shar_ord-doc.ord-int1 = int ({&edoc-rpl})  or
    ( shar_ord-doc.ord-int1 = int ({&edoc-empty})  and
      shar_ord-doc.ord-int2 = int ({&edoc-return}))
      ))
or  (is-edi and
    ( shar_ord-doc.ord-int1 = int ({&edi-ordrsp}) or
    ( shar_ord-doc.ord-int1 = int ({&edi-empty})  and
      shar_ord-doc.ord-int2 = int ({&edi-return}))
      )))
and   shar_ord-doc.doc-type = {&O-P}
and   shar_ord-doc.status_ = {&g___new}

  then do:
      if tmp#zakaz.order-cli-qnty <> tmp#zakaz.cli-qnty
        then tmp#zakaz.order-cli-qnty:bgcolor in browse {&browse-name} = 12 /* red */ .
        else tmp#zakaz.order-cli-qnty:bgcolor in browse {&browse-name} = ? .

      if tmp#zakaz.ord-dec1 <> tmp#zakaz.price-cli
        then tmp#zakaz.ord-dec1:bgcolor = 12.
        else tmp#zakaz.ord-dec1:bgcolor = ? .
  end.
  else do:
        tmp#zakaz.order-cli-qnty:bgcolor in browse {&browse-name} = ?      .
        tmp#zakaz.ord-dec1:bgcolor       in browse {&browse-name} = ?      .
  end.

END PROCEDURE.

procedure init-browse-p :
/* Настройки экрана по пользователю */
  do
  on error undo, return error return-value
  :

define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .


  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column   in frame {&frame-name}
    hcolumn [cur-clmn-loc] = column-handle
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      hcolumn [cur-clmn-loc] = column-handle
    .
  end.

run uf-get in this-procedure (
     input  {&uf-cli-zakz} + g#type
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
    ) no-error  .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "e"
      view-as alert-box error
    .

v-order-column  =  (entry(1, v-uf-List_ ,{&delim-par})) no-error.
v-spis-size     =  (entry(2, v-uf-List_ ,{&delim-par})) no-error.
v-spis-vis      =  (entry(3, v-uf-List_ ,{&delim-par})) no-error.

/*
message 'проверим что в uf' {&uf-cli-zakz} + g#type v-cntxt-userid skip
'v-order-column ' v-order-column skip
'v-spis-size    ' v-spis-size    skip
'v-spis-vis     ' v-spis-vis     skip
"кол-во кол" {&browse-name} :NUM-COLUMNS  in frame {&frame-name}
.
*/

case g#type :
          when  {&f-p} then do:
            if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column  =  {&cli-zakzfp-p-ord}     .
            if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size     =  {&cli-zakzfp-p-siz}     .
            if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis      =  {&cli-zakzfp-p-vis}     .
          end.
          when  {&o-p} then do:
              if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = {&cli-zakzOp-p-ord}     .
              if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = {&cli-zakzOp-p-siz}     .
              if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = {&bef-cli-zakzOp-p-vis} .
          end.
          when {&o-f} then do:
              if v-order-column  = ? or v-order-column  = "" or error-status :error  then  v-order-column = {&cli-zakzOF-p-ord}      .
              if v-spis-size     = ? or v-spis-size    = ""  or error-status :error  then  v-spis-size    = {&cli-zakzOF-p-siz}      .
              if v-spis-vis      = ? or v-spis-vis     = ""  or error-status :error  then  v-spis-vis     = {&cli-zakzOF-p-vis}      .
          end.
end case.

define variable col-h as handle no-undo .
define variable ii as integer   no-undo .

repeat ii = 1 to cur-clmn-loc   :
    col-h = hcolumn [ ii ]  .
/*    if decimal(entry(ii,v-spis-size))  = 0 and ii < 22 then message ii.*/
    col-h:width  = max (0.1, decimal(entry(ii, v-spis-size))) .
    col-h:visible  = logical(entry(ii,v-spis-vis))  .
 end.

  end.

end procedure. /* init-browse-p */

procedure ver-calc :

  do
  on error undo, return error return-value
  :
/* Проверка возможности корректирования количества по Объекту, Поставщику и группе Товаров, если был авторасчет */
  define variable v-not-corr-op as character no-undo .
  define variable p-type as character no-undo .
  define buffer buf_goods for ub.goods  .

for each tmp#zakaz :
  if tmp#zakaz.qnty <> tmp#zakaz.initial-qnty and e-method <> "" then do:
      assign v-not-corr-op = 'no' .
      run clntattr-value (
            input   loc-store-type
          , input   loc-store-code
          , input   {&attr-not-corr-op}
          , output  v-not-corr-op
          , output  p-type
          ) no-error .
      if error-status :error then v-not-corr-op  = 'no' .
      if v-not-corr-op  = 'yes' then do: /*на объекте обязателен авторасчет, проверяем клиента и товар*/
        assign v-not-corr-op  = 'no' .
        run clntattr-value (
              input   loc-cli-type
            , input   loc-cli-code
            , input   {&attr-not-corr-op}
            , output  v-not-corr-op
            , output  p-type
        ) no-error .
        if error-status :error then v-not-corr-op  = 'no' .
        if v-not-corr-op  = 'yes' then do:
          message substitute ( "Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять рассчитанные количества  по Поставщику &2&3 " ,
                  tmp#zakaz.initial-qnty ,
                  shar_ord-doc.cli-type ,
                  shar_ord-doc.cli-code ,
                  {&new-line} )
          view-as alert-box information .
          return error.
        end.
        find first  buf_goods no-lock where
                    buf_goods.artic = tmp#zakaz.artic and
                    buf_goods.prod-type = tmp#zakaz.prod-type and
                    buf_goods.prod-code = tmp#zakaz.prod-code no-error .
        assign
          tmp#zakaz.gds-code = buf_goods.gds-code
          v-not-corr-op  = 'no'
        .
        run ggoattr-value (
          input   buf_goods.grp-code
          ,input   v-cntxt-host-code-obj
          ,input   v-cntxt-obj-type
          ,input   v-cntxt-obj-code
          ,input   {&ggoattr-NotCorrOP}
          ,output  v-not-corr-op
          ,output  p-type
          ) no-error .

        if error-status :error then v-not-corr-op = 'no' .
        if v-not-corr-op = 'yes' then do:
          message substitute("Был произведен автоматический расчет заказа, количество должно быть &1&4Запрещено менять рассчитанные количества  по Группе товаров (&2) &3 " ,
                  tmp#zakaz.initial-qnty ,
                  buf_goods.grp-code ,
                  buf_goods.grp-name ,
                  {&new-line})
          view-as alert-box information .
          return error.
        end.
      end.
    end.
  end.
end.

end procedure. /* ver-calc */

procedure spec1 :

  do
  on error undo, return error return-value
  :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
   or   ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
   then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
   end.
   line-mode = {&add-def}.
   assign frame {&frame-name} loc-contract.
   run add-spec-contract in this-procedure.

  end.

end procedure. /* spec1 */


procedure spec2 :

  do
  on error undo, return error return-value
  :
   find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   if available shar_ord-doc
   and (( is-edoc-nn and ( shar_ord-doc.ord-int1 = integer({&edoc-rpl}) or shar_ord-doc.ord-int1 = integer({&edoc-rpl-ok})))
   or   ( is-edi     and   shar_ord-doc.ord-int1 = integer({&edi-ordrsp})))
   then do:
       message "Заказ по системе EDOC/EDI не должен корректироватся в этом статусе. Только НОВЫЙ желтый! " view-as alert-box information .
       return .
   end.
   line-mode = {&add-def}.
   assign frame {&frame-name} loc-contract.
   run update-spec-contract in this-procedure.

  end.

end procedure. /* spec2 */

procedure update-spec-contract :
define variable ii as integer   no-undo .
define variable v-i as integer   no-undo .
define variable t-ret as logical   no-undo .
define variable r-tmp as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-choice as integer   no-undo .

define buffer bf_contract-specif for ub.contract-specif  .
define buffer old_tmp#zakaz for tmp#zakaz  .

  do
  on error undo, return error return-value
  :

if loc-contract = 0 or loc-contract = ? then return .
/*
find first bf_contract-specif where bf_contract-specif.host-code    = v-cntxt-host-code-obj and
                                    bf_contract-specif.contract-num = loc-contract no-lock no-error.
*/
{str/cont-slave-inc.i
     &FIND_FIRST = YES
     &BUFFER_SPECIF = bf_contract-specif
     &P_HOST_CODE = v-cntxt-host-code-obj
     &P_CONTRACT_NUM = loc-contract
     &NO_LOCK=YES
     &NO_ERROR=YES
}

if not available bf_contract-specif then return .

      run gbl/d-askw.w
        (input "Обновление данных по спецификации"
        ,input "Выберите один из пунктов для обновления данных в заказе" + {&new-line}
             + "по спецификации к договору" + {&new-line}
        ,input "|"
        ,input "Все поля|Цены и НДС|Количества|Отказ"
        ,input "Обновить цены,количества и НДС из спецификации|"
             + "Обновить только цены и НДС из спецификации|"
             + "Обновить только количества из спецификации|"
             + "Отказ от выполнения операции"
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 4 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).
      if v-choice = 4 then do:
        return.
      end.


t-ret =  session:set-wait-state("general") .
ii = 0.
case v-choice :
when 1 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
/*
   find first  ub.contract-specif no-lock where
               ub.contract-specif.contract-num = loc-contract and
               ub.contract-specif.host-code    = v-cntxt-host-code-obj and
               ub.contract-specif.gds-code     = tmp#zakaz.gds-code no-error .
*/
   {str/cont-slave-inc.i
        &FIND_FIRST = YES
        &BUFFER_SPECIF = ub.contract-specif
        &P_HOST_CODE = v-cntxt-host-code-obj
        &P_CONTRACT_NUM = loc-contract
        &P_GDS_CODE = tmp#zakaz.gds-code
        &NO_LOCK=YES
        &NO_ERROR=YES
   }
   if not available contract-specif then next .
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "") no-error .
   end.
end.
when 2 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
/*
   find first  ub.contract-specif no-lock where
               ub.contract-specif.contract-num = loc-contract and
               ub.contract-specif.host-code    = v-cntxt-host-code-obj and
               ub.contract-specif.gds-code     = tmp#zakaz.gds-code no-error .
*/
   {str/cont-slave-inc.i
        &FIND_FIRST = YES
        &BUFFER_SPECIF = ub.contract-specif
        &P_HOST_CODE = v-cntxt-host-code-obj
        &P_CONTRACT_NUM = loc-contract
        &P_GDS_CODE = tmp#zakaz.gds-code
        &NO_LOCK=YES
        &NO_ERROR=YES
   }
   if not available contract-specif then next .
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "only-price") no-error .
   end.
end.
when 3 then do:
   v-update-price = 0 .
   for each tmp#zakaz :
/*
   find first  ub.contract-specif no-lock where
               ub.contract-specif.contract-num = loc-contract and
               ub.contract-specif.host-code    = v-cntxt-host-code-obj and
               ub.contract-specif.gds-code     = tmp#zakaz.gds-code no-error .
*/
   {str/cont-slave-inc.i
        &FIND_FIRST = YES
        &BUFFER_SPECIF = ub.contract-specif
        &P_HOST_CODE = v-cntxt-host-code-obj
        &P_CONTRACT_NUM = loc-contract
        &P_GDS_CODE = tmp#zakaz.gds-code
        &NO_LOCK=YES
        &NO_ERROR=YES
   }
   if not available contract-specif then next .
     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "only-qnty") no-error .
   end.

end.
end case.

run full-recount in this-procedure .
choice = ?.
run openbr in this-procedure  .
t-ret =  session:set-wait-state("") .
message
  substitute("Исправлено  &1 из &2 товаров", v-update-price, ii )
  view-as alert-box information
  .
  ii = 0.
  v-update-price = 0 .
end.
end procedure. /* update-spec-contract */

procedure add-spec-contract :
define variable ii as integer   no-undo .
define variable v-i as integer   no-undo .
define variable t-ret as logical   no-undo .
define variable r-tmp as recid no-undo .
define variable r-stop as logical no-undo .
define variable r-exit as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-choice as integer   no-undo .

define buffer bf_contract-specif for ub.contract-specif  .
define buffer old_tmp#zakaz for tmp#zakaz  .

  do
  on error undo, return error return-value
  :

if loc-contract = 0 or loc-contract = ? then return .
/*
find first bf_contract-specif where bf_contract-specif.host-code    = v-cntxt-host-code-obj and
                                    bf_contract-specif.contract-num = loc-contract no-lock no-error.
*/
{str/cont-slave-inc.i
     &FIND_FIRST = YES
     &BUFFER_SPECIF = bf_contract-specif
     &P_HOST_CODE = v-cntxt-host-code-obj
     &P_CONTRACT_NUM = loc-contract
     &NO_LOCK=YES
     &NO_ERROR=YES
}

if not available bf_contract-specif then return .

      run gbl/d-askw.w
        (input "Добавление данных из спецификации"
        ,input "Выберите один из пунктов для добавления в заказ" + {&new-line}
             + "товаров по спецификации к договору" + {&new-line}
        ,input "|"
        ,input "Все|Выборочно|Отказ"
        ,input "Все недобавленные товары по спецификации|"
             + "Выборочно товары по спецификации|"
             + "Отказ от выполнения операции"
        ,input 1 /* значение возвращаемое при нажатии enter */
        ,input 3 /* значение возвращаемое при нажатии escape */
        ,output v-choice
        ).
      if v-choice = 3 then do:
        return.
      end.


t-ret =  session:set-wait-state("general") .
ii = 0.
case v-choice :
when 1 then do:
   line-mode = {&add-def} .
/*
   for each ub.contract-specif no-lock where
            ub.contract-specif.contract-num = loc-contract and
            ub.contract-specif.host-code    = v-cntxt-host-code-obj
   :
*/
   {str/cont-slave-inc.i
        &FOR_ = YES
        &EACH_ = YES
        &BUFFER_SPECIF = ub.contract-specif
        &P_HOST_CODE = v-cntxt-host-code-obj
        &P_CONTRACT_NUM = loc-contract
        &NO_LOCK=YES
   }

     find first old_tmp#zakaz where
                old_tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
     if available old_tmp#zakaz then next .
    
    if not g#type = {&f-p} then do:
      run ver-izt ( loc-doc-type , contract-specif.gds-code , v-cntxt-obj-type , v-cntxt-obj-code , output v-error) .
      if  v-error then next.
    end.

     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "") no-error .
        find first tmp#zakaz where
                   tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
         if not  error-status :error  and not t-auto then do:
            r-tmp = recid ( tmp#zakaz   ) .
            run cus/ord-frm.w (input ParParentProc , input recid ( tmp#zakaz )  , input line-mode , output r-stop , output r-exit) .
            if r-stop then do:
              run p-delete ( r-tmp , input-output ii).
              leave.
            end.
            if r-exit then do:
               run p-delete( r-tmp ,input-output ii ) .
            end.
        end.
   end.
end.
when 2 then do:
   run str/contspec.w (input parparentproc,
                      input "b-sel,b-mark",
                      input {&lookup},
                      input v-cntxt-host-code-obj,
                      input loc-contract,
                      output v-rid-list) .
      if v-rid-list = '':u then do:
        message "Нет выбранных товаров по спецификации."
          view-as alert-box.
      end.

    /* Формируем список recid'ов товаров по выбранным строкам спецификации */
    line-mode = {&add-def} .
    do v-i = 1 to num-entries(v-rid-list) :
     find ub.contract-specif where recid(ub.contract-specif) = integer(entry(v-i, v-rid-list)) no-lock no-error.
     if error-status :error then next.
     run ver-izt ( loc-doc-type , ub.contract-specif.gds-code ,v-cntxt-obj-type , v-cntxt-obj-code , output v-error) .
     if  v-error then next.

     ii = ii + 1 .
     run create-tmp in this-procedure  (input "contract-spec":u, "") no-error .
        find first tmp#zakaz where
                   tmp#zakaz.gds-code = ub.contract-specif.gds-code no-error .
        if not  error-status :error  and not t-auto then do:
            r-tmp = recid ( tmp#zakaz   ) .
            run cus/ord-frm.w (input ParParentProc , input r-tmp  , input line-mode , output r-stop , output r-exit) .
            if r-stop then do:
              run p-delete ( r-tmp , input-output ii).
              leave.
            end.
            if r-exit then do:
               run p-delete( r-tmp ,input-output ii ) .
            end.
        end.
   end.
end.
end case.
run full-recount in this-procedure .
choice = ?.
run openbr in this-procedure  .
t-ret =  session:set-wait-state("") .
message
  'Добавлено'
  ii 'товаров'
  view-as alert-box information
  .
  ii = 0.
  v-update-price = 0 .
end.
end procedure. /* add-spec-contract */

procedure ver-izt :
define input  parameter p-event-code as character no-undo .
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .

define variable p-Ok as logical   no-undo .
define variable p-mess as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
    { gbl/goassizt.i
    p-event-code
    p-gds-code
    p-obj-type
    p-obj-code
    no
    p-Ok
    p-mess
    no-error }
     if p-mess <> "" then do:
     end.
    if p-ok = false then p-error = true  .
  end.

end procedure. /* ver-izt */

procedure choose-contract :

define variable varcontract-code like ub.contract.contract-code no-undo.
define buffer buf_contract for ub.contract.

  find first buf_contract where buf_contract.host-code = v-cntxt-host-code-obj and
                                buf_contract.cli-type  = loc-cli-type and
                                buf_contract.cli-code  = loc-cli-code no-lock no-error.
  if available buf_contract then do:
      run check-contract-code in this-procedure (input  "choose":u,
                                                 input  v-cntxt-host-code-obj,
                                                 input  loc-cli-type,
                                                 input  loc-cli-code,
                                                 input  ?,
                                                 input  parparentproc,
                                                 input  shar_ord-doc.doc-date,
                                                 input  {&income} ,
                                                 output varcontract-code) no-error.
      if error-status :error    or
         varcontract-code = ?  or
         varcontract-code = 0  then do:
/*          message "Вы не выбрали договор. "*/
/*          view-as alert-box error.*/
/*          apply "entry" to loc-cli-code in frame {&frame-name}.*/
/*          return error.*/
      end.
      else do:
        assign
          loc-contract:screen-value in frame {&frame-name}  = string(varcontract-code)
          loc-contract = varcontract-code
          shar_ord-doc.contract-code = varcontract-code
        .
      end.
  end.
end procedure. /* choose-contract */
