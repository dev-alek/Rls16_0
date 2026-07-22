/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма просмотра заказа

Автор: Чернова Светлана Александровна
Дата создания: 30/01/01
Author: Svetlana Chernova
Creation date: 30/01/01

*/
/* ***************************  definitions  ************************** */

define input  parameter parparentproc  as widget-handle no-undo.
define input-output  parameter br-handle as handle no-undo.
define input-output  parameter bf-handle as handle no-undo.
define input-output  parameter next-prev as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма просмотра заказа" .
{ cmp/vssrevis.i     }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE SHARED BUFFER   SHAR-BUF_ORD-DOC FOR UB.ORD-DOC.

define buffer   buf_ord-line-attr for ub.ord-line-attr.

define variable head-col        as character no-undo .
define variable v-order-column  as character no-undo .
define variable v-spis-size     as character no-undo .
define variable v-spis-vis      as character no-undo .
define variable hcolumn         as handle extent 100  no-undo.


define variable v-fact-qnty as decimal   no-undo .
define variable t-action as char no-undo.
define variable v-min-stock as decimal   no-undo .
define variable v-gds-way as decimal   no-undo .
t-action = "lkp":u.
define buffer b-goods   for ub.goods .
define buffer b-gds-prt for ub.gds-prt .



define variable x-mode as character  no-undo .
define variable doc-rec as recid no-undo .
&scop s-with1 98.75
&scop s-with2 0.1
&scop fr-row  12.08
&scop fr-col   99
&scop v-prt    no-prt

&scoped-define window-name current-window
&scoped-define frame-name dialog-frame

define variable curclivalue   as char initial ? no-undo.
define variable curclitype   as character no-undo .
define variable v-loc-contract as character format "x(15)" label "№ дог-ра" fgcolor 1 no-undo .

define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date .


{ cmp/trg-def.i      }
{ cmp/showinf.i      }
{ gbl/flt-def.i      }
{ cmp/r-pril.i  new  }
{ cmp/r-page1.i new  }
{ cus/df-zakaz.i new }
{ gbl/color.i        }
{ cmp/croslist.i     }
{ str/lib-trn.i      }
{ gbl/getcntxt.i def }
{ gbl/usr-flt.i }
&glob  start-proc do on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):

define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable base-code as integer   no-undo .
define variable gds-rec as recid no-undo .
define variable g#type as character no-undo .
define variable rep-rec2 as recid no-undo .
define variable v-deliv-type-code    as integer   no-undo .
define variable v-point-obj-code     as integer   no-undo .
define variable v-point-cli-code     as integer   no-undo .
define variable v-point-obj-db-num   as integer   no-undo .
define variable v-point-cli-db-num   as integer   no-undo .
define variable v-transport-host-code     as integer   no-undo .
define variable v-transport-cli-type     as character no-undo .
define variable v-transport-cli-code     as integer   no-undo .
define variable v-transport-contract   as integer   no-undo .
define variable v-transport-condition  as integer   no-undo .
define variable v-transport-value      as decimal   no-undo .
define variable v-transport-sum        as decimal   no-undo .
define variable v-transport-vat        as decimal   no-undo .

/*define variable rep-rec3 as recid no-undo .*/
/*define variable prt-rec as recid no-undo .*/
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#host-code   = v-cntxt-host-code-obj
   .

run get-report-num  in parParentProc ( output g#report-num ).
{ gbl/basecode.i g#host-code base-code }


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
define variable tmp-rec as recid no-undo.
define variable choice   as      logical no-undo    init ?.
define variable var#import as logical init false no-undo .
define var last-curr-code like ub.currency.curr-abbr no-undo.
define var cli-name       like ub.clients.obj-name   no-undo.
define var gds-name       like ub.goods.gds-name     no-undo.
define var unit-base      like ub.goods.unit-base    no-undo.

define stream cg-stream.
define variable date_string     as      char    no-undo.
define variable line            as      char    no-undo.
define variable for-time as char.
define variable producer as char.

define variable f-artic     like ub.goods.artic     no-undo.
define variable f-gds-name  like ub.goods.gds-name  no-undo.
define variable f-unit-base like ub.goods.unit-base no-undo.
define variable f-qnty      like   ub.ord-dtl.qnty  no-undo.
define variable f-price-rubl like  ub.ord-dtl.price-rubl  no-undo.
define variable f-sum-rubl   like  ub.ord-dtl.sum-rubl    no-undo.
define variable f-cli-qnty   like  ub.ord-dtl.cli-qnty    no-undo.
define variable f-price-cli  like  ub.ord-dtl.price-cli   no-undo.
define variable f-sum-cli    like  ub.ord-dtl.sum-cli     no-undo.
define variable f-prt-name   like  ub.gds-prt.f-name      no-undo.

define variable filter-point as character no-undo init "Заказ_поставщику_new" .
define variable sort-column-name as character no-undo .
define variable t#query-was-opened as log init false no-undo .

define variable t-ret as logical no-undo  .
define variable x-prod-type like ub.goods.prod-type no-undo .
define variable x-prod-code like ub.goods.prod-code no-undo .
define variable x-artic     like ub.goods.artic no-undo .
define variable v-fl as logical no-undo .
define variable jj as integer no-undo .

define variable base-abbr as character format "x(3)":u
      view-as text
     size 4 by 1 no-undo.

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
&scoped-define enabled-tables-in-query-br-docs shar_ord-line buf-goods
&scoped-define first-enabled-table-in-query-br-docs shar_ord-line
&scoped-define self-name br-docs
&scoped-define open-query-br-docs open query {&self-name} for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,~
each buf-goods no-lock where ~
 buf-goods.artic = shar_ord-line.artic and ~
 buf-goods.prod-type = shar_ord-line.prod-type and ~
 buf-goods.prod-code = shar_ord-line.prod-code .

&scoped-define tables-in-query-br-docs shar_ord-line  buf-goods
&scoped-define first-table-in-query-br-docs shar_ord-line

&scoped-define open-query-br-docs-2 open query br-docs-2 for ~
each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,~
each b-goods no-lock where ~
 b-goods.artic     = shar_ord-line.artic and ~
 b-goods.prod-type = shar_ord-line.prod-type and ~
 b-goods.prod-code = shar_ord-line.prod-code , ~
each ub.ord-dtl no-lock where ub.ord-dtl.doc-code = shar_ord-line.doc-code and ~
 ub.ord-dtl.artic     = shar_ord-line.artic and ~
 ub.ord-dtl.prod-type = shar_ord-line.prod-type and ~
 ub.ord-dtl.prod-code = shar_ord-line.prod-code LEFT OUTER-JOIN , ~
each buf-goods no-lock where ~
 buf-goods.artic     = ub.ord-dtl.artic and ~
 buf-goods.prod-type = ub.ord-dtl.prod-type and ~
 buf-goods.prod-code = ub.ord-dtl.prod-code , ~
each ub.gds-prt no-lock where ~
 ub.gds-prt.node-code = ub.ord-dtl.node-code .

&scoped-define open-query-br-docs-sort open query {&self-name} for each shar_ord-line no-lock where shar_ord-line.doc-code = p-doc-code ,~
each buf-goods no-lock where ~
 buf-goods.artic = shar_ord-line.artic and ~
 buf-goods.prod-type = shar_ord-line.prod-type and ~
 buf-goods.prod-code = shar_ord-line.prod-code



/* definitions for dialog-box dialog-frame                              */

/* standard list definitions                                            */
&scoped-define enabled-objects b-exit r-clients loc-cli-type loc-cli-code ~
wrkr  r-wrkr  agnt r-agnt loc-date-ship boss r-boss ~
br-docs b-import b-export  b-ins  b-main-calc~
b-del  b-chg b-producer  b-alt-post   b-remove ~
b-help loc-obj-name wrkr-name agnt-name boss-name ~
prod-name goods-name tog-type tog-prt cycle-day t  b-way b-contract b-protocol

&scoped-define displayed-objects loc-cli-type loc-cli-code wrkr  ~
agnt loc-date-ship boss  loc-obj-name wrkr-name ~
agnt-name boss-name prod-name goods-name tog-type  tog-prt  cycle-day t


&scoped-define enabled-objects-all rect-4 rect-5  rect-7 rect-6 b-exit ~
loc-cli-type loc-cli-code r-clients doc-date fact-date paytype r-paytype ~
wrkr tog-type  tog-prt  cycle-day r-wrkr  agnt r-agnt loc-date-ship ~
 loc-service boss r-boss  loc-qnty loc-exch-code ~
 r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc ~
loc-sum-rubl loc-base-rate loc-base-scale  loc-sum-base ~
loc-tot-lines  loc-sum-cli slt_type vat_type br-docs b-contract b-protocol~
b-ins b-del b-chg b-main-calc b-producer  b-alt-post b-notes ~
b-remove b-help b-export  b-way  b-import loc-obj-name wrkr-name e-method ~
loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name  date-sale-1 date-sale-2 loc-hour loc-min v-loc-contract

&scoped-define display-objects-all loc-cli-type loc-cli-code  doc-date fact-date paytype ~
wrkr tog-type  tog-prt  cycle-day  agnt r-agnt loc-date-ship ~
 loc-service boss r-boss loc-qnty loc-exch-code ~
 r-currency loc-cli-qnty loc-exch-rate loc-exch-scale r-acc ~
loc-sum-rubl loc-base-rate loc-base-scale loc-sum-base ~
loc-tot-lines  loc-sum-cli slt_type vat_type br-docs e-method ~
loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name  ~
date-sale-1 date-sale-2  loc-hour loc-min  b-way v-loc-contract b-contract b-protocol

&scoped-define assign-objects cycle-day loc-date-ship ~
 loc-service date-sale-1 date-sale-2

&scoped-define display-objects-of loc-cli-type loc-cli-code  doc-date fact-date  ~
wrkr tog-type  tog-prt  cycle-day  agnt r-agnt loc-date-ship ~
boss r-boss loc-qnty loc-cli-qnty loc-tot-lines  br-docs e-method ~
loc-obj-name loc-obj-name-2 loc-pay-type loc-cli-out-doc t agnt-name boss-name prod-name goods-name  ~
date-sale-1 date-sale-2  loc-hour loc-min  b-way

&scoped-define enabled-objects-of rect-4 rect-5  rect-7 rect-6 b-exit ~
doc-date fact-date  ~
wrkr tog-type  tog-prt  cycle-day r-wrkr  agnt r-agnt loc-date-ship ~
boss r-boss  loc-qnty loc-cli-qnty loc-tot-lines  br-docs ~
b-ins b-del b-chg b-main-calc b-producer  b-alt-post  b-notes ~
b-remove b-help b-export b-import loc-obj-name wrkr-name e-method ~
t agnt-name boss-name prod-name goods-name  date-sale-1 date-sale-2 loc-hour loc-min  b-way

/* _uib-preprocessor-block-end */
&analyze-resume

/* ***********************  control definitions  ********************** */

define menu m-export

       menu-item m_export_text  label "&1. Экспорт в формат Моб.сканера" accelerator "alt-7"
       menu-item m_export_excel label "&2. Экспорт в Excel" accelerator "alt-8"
       .
define menu m-way
       menu-item m_way1         label "&9. Заказано до даты поставки" accelerator "alt-9"
       menu-item m_way2         label "&0. Заказано на период продажи" accelerator "alt-0".

/* переменные шаренные  и батоны*/
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

define button b-exit   auto-go
     label "&Выход"
     size 6 by 1 tooltip "Выход с сохранением"
     bgcolor 8 .

define button b-export
     label "&Экспорт"
     size 8 by 1 tooltip "Экспорт в формат моб.сканера"
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

define button b-ins
     label "&Добав"
     size 8 by 1 tooltip "Добавить товары"
     bgcolor 8 .

define button b-notes
     label "При&м":l
     size 8 by 1 tooltip "Изменить примечание к заказу.заявке".


define button b-producer
     label "&Пр-ль"
     size 8 by 1 tooltip "Данные о Производителе"
     bgcolor 8 .


define button b-remove
     label "&х"
     size 3 by 1 tooltip "Проставить/снять пометку по товару, если его нет у Поставщика"
     bgcolor 8 .

define button b-main-calc
     label "&Расчет"
     size 8 by 1 tooltip "Расчет заказа/заявки"
     bgcolor 8 .

define button b-inf
     label "&Инф"
     size 8 by 1 tooltip "Информация по статусам EDI"
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

define button r-wrkr
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     label "r-acc"
     size 3 by .88 tooltip "Выбор из списка".

define button b-way
     label "&В пути"
     size 8 by 1 tooltip "Список заказов товара в пути"
     bgcolor 8 .


DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру предыдущего документа списка".

DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру следующего документа списка".

DEFINE BUTTON b-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "b-contract"
     SIZE 3 BY 1 TOOLTIP "Посмотреть До&говор".

DEFINE BUTTON B-protocol
     LABEL "Протокол"
     SIZE 10 BY 1 TOOLTIP "Протокол расчета заказа".


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

define variable t as character format "x(3)":u initial "дн."
      view-as text
     size 3.13 by .67 no-undo.


define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14 by 1 tooltip "Исполнитель"
     fgcolor 4  no-undo.


define variable loc-obj-name-2 as character format "x(256)":u
     label "От"
     view-as text
     size 30.88 by .69 tooltip "От кого"
     fgcolor 4  no-undo.


DEFINE VARIABLE Tog-prt AS LOGICAL INITIAL no
     LABEL "шкала"
     VIEW-AS TOGGLE-BOX
     SIZE 7.25 BY .83 TOOLTIP "Просмотр вместе с признаками" NO-UNDO.

define button r-contract
     image-up file "btn-down-arrow":u
     image-down file "btn-down-arrow":u
     image-insensitive file "btn-down-arrow":u
     size 3 by .88 tooltip "Выбор из списка договоров".

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

define variable loc-sum-rcv as decimal no-undo .
define variable loc-err-rcv as character no-undo .

define variable f-loc-sum-rcv as decimal no-undo .
define variable f-loc-err-rcv as character no-undo .

/* query definitions                                                    */
define new shared query br-docs for
      shar_ord-line,  buf-goods  scrolling.

define query br-docs-2 for
      shar_ord-line, b-goods, ub.ord-dtl, buf-goods , ub.gds-prt scrolling.
function roundordline return decimal (buffer local-ord-line for shar_ord-line):
  find first ub.goods where ub.goods.artic     = local-ord-line.artic     and
                         ub.goods.prod-type = local-ord-line.prod-type and
                         ub.goods.prod-code = local-ord-line.prod-code no-lock.
  find first ub.units where ub.units.unit-name = ub.goods.unit-cli.
  if (lookup({&pieces}, ub.units.type) > 0
  or lookup({&serial}, ub.units.type) > 0 ) and
    local-ord-line.cli-qnty <> truncate(local-ord-line.cli-qnty, 0) then do:
      return truncate(local-ord-line.cli-qnty, 0) + 1 .
  end.
  else do:
    return local-ord-line.cli-qnty.
  end.
end function.
define variable varroundordline as decimal no-undo.
/* browse definitions                                                   */
define browse br-docs
  query br-docs no-lock display
      loc-err-rcv                   column-label "~!!":c1  format "x(1)"
      shar_ord-line.line-num        column-label '№!п/п'   format ">>>>"
      shar_ord-line.prt-ok          column-label 'ш! '    format "+/-"
      shar_ord-line.artic           column-label "Артикул! ":c8
      buf-goods.gds-name            column-label "Название! ":c9
      shar_ord-line.unit-cli        column-label "Е.и.!пост" format "x(3)"                            /* label-bgcolor 1 label-fgcolor 15                        */
      shar_ord-line.cli-qnty        column-label "Заказ!ед.пост":c13 format "->,>>>,>>9.999"          /* label-bgcolor 1 label-fgcolor 15                        */
      shar_ord-line.order-cli-qnty  column-label "Запрошено!количество"   format "->,>>>,>>>,>>9.999"
      shar_ord-line.price-cli       column-label "Последн.цена!пост-ка":c20 format "->>>,>>>,>>9.99"  /* label-bgcolor 1 label-fgcolor 15                        */
      shar_ord-line.ord-dec1        column-label 'Запрошена!цена'   format "->,>>>,>>>,>>9.99"
      shar_ord-line.sum-cli         column-label "Сумма!ед.пост":c13 format "->,>>>,>>>,>>9.99"       /* label-bgcolor 1 label-fgcolor 15                        */
      shar_ord-line.cli-art         column-label "Артикул!поставщика":c18                             /* label-bgcolor 1 label-fgcolor 15                        */
      buf-goods.unit-base           column-label "Е.и.!баз." format "x(3)"                            /* label-bgcolor 3 label-fgcolor 15                        */
      shar_ord-line.qnty            column-label "Заказ! ":c6 format "->,>>>,>>9.999"                 /* label-bgcolor 3 label-fgcolor 15                        */
      shar_ord-line.price-rubl      column-label "Цена!({&abbr_rub}.)" format "->>>,>>>,>>9.99"      /* label-bgcolor 3 label-fgcolor 15                        */
      shar_ord-line.sum-rubl        column-label "Сумма!({&abbr_rub}.) ":c12 format "->,>>>,>>>,>>9.99"       /* label-bgcolor 3 label-fgcolor 15                        */
      shar_ord-line.qnty-stk        column-label "Остаток на !момент расчета" format "->,>>>,>>9.999"
      v-fact-qnty                   column-label "Текущий!остаток" format "->,>>>,>>9.999"                 /* label-bgcolor 3 label-fgcolor 15                        */
      loc-sum-rcv                   column-label "Поставлено! ":c11 format "->>>,>>>,>>9.999"
      shar_ord-line.gds-code        column-label "Код!товара"
      shar_ord-line.initial-qnty    column-label "Расcчитн.!кол-во"
      v-min-stock                   column-label "Мин!остаток" format "->,>>>,>>9.999"                 /* label-bgcolor 3 label-fgcolor 15                        */
      v-gds-way                     column-label "Товары!в пути" format "->,>>>,>>9.999"                 /* label-bgcolor 3 label-fgcolor 15                        */

      /*(if shar_ord-line.cancel-date = ? then "" else "*" ) column-label "x! " format "x(1)" */
  enable
      shar_ord-line.cli-art
    with no-assign  separators size-char {&s-with1}  by 9.

define browse br-docs-2
  query br-docs-2 no-lock display
      f-loc-err-rcv           column-label "~!!":c1  format "x(1)"
      f-artic                 column-label "Артикул! ":c8
      f-gds-name              column-label "Название! ":c9  format "x(40)"
      f-prt-name              column-label "Признак! ":c9   format "x(20)"

      f-unit-base             column-label "Е.и.!баз." format "x(3)"                           /*  label-bgcolor 3 label-fgcolor 15 */
      shar_ord-line.qnty      column-label "Заказано!всего по товару"                          /*  label-bgcolor 3 label-fgcolor 15 */
      v-fact-qnty             column-label "Текущий!остаток" format "->,>>>,>>9.999"                 /* label-bgcolor 3 label-fgcolor 15                        */
      f-qnty                  column-label "Заказ! ":c6 format "->,>>>,>>9.999"                /*  label-bgcolor 3 label-fgcolor 15 */
      f-price-rubl            column-label "Цена!({&abbr_rub}.)":c17 format "->>>,>>>,>>9.99"     /*  label-bgcolor 3 label-fgcolor 15 */
      f-sum-rubl              column-label "Сумма!({&abbr_rub}.) ":c11 format "->,>>>,>>>,>>9.99"      /*  label-bgcolor 3 label-fgcolor 15 */

      shar_ord-line.unit-cli   column-label "Е.и.!пос." format "x(3)"                           /*  label-bgcolor 1 label-fgcolor 15 */
      shar_ord-line.cli-qnty   column-label "Заказано!всего по товару"                          /*  label-bgcolor 1 label-fgcolor 15 */
      f-cli-qnty              column-label "Заказ!ед.пост":c13 format "->,>>>,>>9.999"         /*  label-bgcolor 1 label-fgcolor 15 */
      f-price-cli             column-label "Последн.цена!пост-ка":c20 format "->>>,>>>,>>9.99" /*  label-bgcolor 1 label-fgcolor 15 */
      f-sum-cli               column-label "Сумма!ед.пост":c13 format "->,>>>,>>>,>>9.99"      /*  label-bgcolor 1 label-fgcolor 15 */
      shar_ord-line.cli-art    column-label "Артикул!поставщика":c18                            /*  label-bgcolor 1 label-fgcolor 15 */
      f-loc-sum-rcv             column-label "Поставлено! ":c11 format "->>>,>>>,>>9.999"
  enable
      shar_ord-line.qnty
      with no-assign  separators size-char {&s-with1}  by 9.


define frame dialog-frame
     b-exit at row 1.08 col 1
     b-prev AT ROW 1.08 COL 7
     b-next AT ROW 1.08 COL 10
     loc-cli-type at row 1.08 col 11.5  colon-aligned    no-label
     loc-cli-code at row 1.08 col 15.13 colon-aligned no-label
     r-clients at row 1.08 col 27

     doc-date at row 8.88 col 8.38 colon-aligned
     fact-date at row 9.63 col 8.38 colon-aligned

     r-wrkr at row 2.21 col 31.63
     paytype at row 2.25 col 73.25 colon-aligned
     r-paytype at row 2.25 col 97
     wrkr at row 2.29 col 6 colon-aligned
     cycle-day at row 2.33 col 56 colon-aligned
     tog-type  at row 2.42 col 35

     r-agnt at row 3.13 col 31.63
     agnt at row 3.21 col 6 colon-aligned
     loc-date-ship at row 3.38 col 44.5 colon-aligned
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
     e-method at row 7.08 col 35 no-label
     loc-base-rate at row 7.46 col 1.63
     loc-base-scale at row 7.46 col 25.25 colon-aligned
     loc-sum-base at row 7.96 col 83.63 colon-aligned
     loc-tot-lines at row 8.88 col 25 colon-aligned
     loc-sum-cli at row 8.92 col 83.63 colon-aligned
     slt_type at row 10.96 col 72.75 colon-aligned
     vat_type at row 10.96 col 87.75 colon-aligned
     br-docs at row 12.08 col 1
     b-ins at row 21.71 col 1
     b-way at row 21.71 col 1
     b-del at row 21.71 col 9
     b-chg at row 21.71 col 17
     b-producer at row 21.71 col 25
     b-alt-post at row 21.71 col 33
     b-export at row 21.71 col 41
     b-import at row 21.71 col 49
     b-main-calc at row 21.71 col 57
     b-notes at row 21.71 col 81
     b-remove at row 21.71 col 89
     b-help at row 21.71 col 92
     b-inf    at row 21.71 col 65
     tog-prt  at row 21.71 col 73
     loc-obj-name at row 1.08 col 28.25 colon-aligned no-label
     loc-obj-name-2 at row 1.08 col 67.5 colon-aligned
     wrkr-name at row 2.33 col 17.63 no-label
     loc-pay-type at row 2.38 col 82.38 colon-aligned no-label
     loc-cli-out-doc at row 3.38 col 82.38 colon-aligned
     t at row 2.58 col 59.63 colon-aligned no-label
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
     b-delivery at row  21.71 col 9
     b-protocol at row 21.71 col 49
     rect-6 at row 2.13  col 1
     rect-7 at row 10.46 col 1
     rect-5 at row 2.13  col 65
     rect-4 at row 2.13  col 34.75
     loc-time-ship at row 3.38 col 54.88 colon-aligned no-label
     v-loc-contract at row 9.88 col 73.25 colon-aligned
     b-contract   at row 9.88 col 94
     r-contract   at row 9.88 col 97
     loc-hour at row 3.38 col 54.88 colon-aligned no-label
     loc-min  at row 3.38 col 59.13 colon-aligned no-label
     ":" view-as text
         size 1.25 by 1 at row 3.38 col 59.5


     "Метод расчета заказа\заявки" view-as text
          size 27 by .67 at row 6.5 col 35.75

     /* space(41.25) skip(15.65) */
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "ЗАКАЗ".



DEFINE FRAME FRAME-A
 br-docs-2 at row 1 col 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 12.08
         SIZE 99.1 BY 9.5
          .

/* ***************  runtime attributes and uib settings  ************** */
ASSIGN
       FRAME FRAME-A:FRAME            = FRAME Dialog-Frame:HANDLE
       FRAME FRAME-A:HIDDEN           = TRUE
       FRAME DIALOG-FRAME:SCROLLABLE  = FALSE
       FRAME DIALOG-FRAME:HIDDEN      = TRUE
       b-way:popup-menu in frame dialog-frame       = menu m-way:handle
       b-export:popup-menu in frame dialog-frame    = menu m-export:handle
       B-way:MENU-MOUSE = 1
       BR-DOCS:NUM-LOCKED-COLUMNS   IN FRAME {&FRAME-NAME} = 1
       b-export:menu-mouse = 1
       .

&analyze-suspend _query-block browse br-docs

/* ************************  control triggers  ************************ */

{ ref/gdsoattr.i }
{ cus/ord-lib.i last-price }
{ gbl/f2.i br-docs goods-recid init-gds-rec PARPARENTPROC }

on window-close of frame dialog-frame /* ЗАКАЗ */
do:
  apply "CHOOSE":u to b-exit.
end.

ON ROW-DISPLAY OF BR-DOCS IN FRAME {&frame-name}
DO:
  define buffer buf_gds-obj for ub.gds-obj  .

  loc-sum-rcv = 0 .
  loc-err-rcv = "" .
  for each ub.ord-line-rcv where
           ub.ord-line-rcv.doc-code  = shar_ord-line.doc-code  and
           ub.ord-line-rcv.artic     = shar_ord-line.artic     and
           ub.ord-line-rcv.prod-type = shar_ord-line.prod-type and
           ub.ord-line-rcv.prod-code = shar_ord-line.prod-code no-lock  :

       loc-sum-rcv = loc-sum-rcv  + ub.ord-line-rcv.qnty .

  end.

    if loc-sum-rcv   >  shar_ord-line.qnty then do:
       loc-sum-rcv:fgcolor in browse  br-docs  =  12 . /* error */
       loc-err-rcv:fgcolor in browse  br-docs  =  12 . /* error */
       loc-err-rcv = ">" .
       end.
    if loc-sum-rcv   <  shar_ord-line.qnty then do:
       loc-sum-rcv:fgcolor in browse  br-docs  =  4 . /* error */
       loc-err-rcv:fgcolor in browse  br-docs  =  4 . /* error */
       loc-err-rcv = "<" .
       end.

  find first buf_gds-obj no-lock where
             buf_gds-obj.artic     = shar_ord-line.artic     and
             buf_gds-obj.prod-type = shar_ord-line.prod-type and
             buf_gds-obj.prod-code = shar_ord-line.prod-code and
             buf_gds-obj.obj-type  = shar_ord-doc.obj-type   and
             buf_gds-obj.obj-code  = shar_ord-doc.obj-code   no-error .
   if available buf_gds-obj then
           v-fact-qnty = buf_gds-obj.fact-qnty.
      else v-fact-qnty = 0 .
      
  find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
    and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
    and buf_ord-line-attr.attr-code = {&ordlineattr-min-stock} no-error.
  if available buf_ord-line-attr then v-min-stock = decimal(buf_ord-line-attr.attr-value). 
  find first buf_ord-line-attr where buf_ord-line-attr.doc-code = shar_ord-line.doc-code
    and buf_ord-line-attr.gds-code = shar_ord-line.gds-code
    and buf_ord-line-attr.attr-code = {&ordlineattr-gds-way} no-error.
  if available buf_ord-line-attr then v-gds-way = decimal(buf_ord-line-attr.attr-value).      

end.

ON ROW-DISPLAY OF BR-DOCS-2 IN FRAME FRAME-A /* Список поставщиков */
DO:
     if ub.ord-dtl.artic = ? then do:
        f-artic = shar_ord-line.artic  .
    end.
    else do:
      f-artic = ub.ord-dtl.artic  .
      shar_ord-line.qnty:bgcolor in browse  br-docs-2  = 7.
    end.

     assign
        f-prt-name  =  if ub.gds-prt.f-name = ?    then ""                  else ub.gds-prt.f-name
        f-gds-name  =  if b-goods.gds-name = ?  then buf-goods.gds-name  else b-goods.gds-name
        f-unit-base =  if b-goods.unit-base = ? then buf-goods.unit-base else b-goods.unit-base
        f-qnty        =  if ub.ord-dtl.qnty        = ? then shar_ord-line.qnty        else ub.ord-dtl.qnty
        f-price-rubl  =  if ub.ord-dtl.price-rubl  = ? then shar_ord-line.price-rubl  else ub.ord-dtl.price-rubl
        f-sum-rubl    =  if ub.ord-dtl.sum-rubl    = ? then shar_ord-line.sum-rubl    else ub.ord-dtl.sum-rubl
        f-cli-qnty    =  if ub.ord-dtl.cli-qnty    = ? then shar_ord-line.cli-qnty    else ub.ord-dtl.cli-qnty
        f-price-cli   =  if ub.ord-dtl.price-cli   = ? then shar_ord-line.price-cli   else ub.ord-dtl.price-cli
        f-sum-cli     =  if ub.ord-dtl.sum-cli     = ? then shar_ord-line.sum-cli     else ub.ord-dtl.sum-cli
  .
  f-loc-sum-rcv = 0 .
  f-loc-err-rcv = "" .
  for each ub.ord-dtl-rcv where
           ub.ord-dtl-rcv.doc-code  = ub.ord-dtl.doc-code  and
           ub.ord-dtl-rcv.node-code = ub.ord-dtl.node-code and
           ub.ord-dtl-rcv.artic     = ub.ord-dtl.artic     and
           ub.ord-dtl-rcv.prod-type = ub.ord-dtl.prod-type and
           ub.ord-dtl-rcv.prod-code = ub.ord-dtl.prod-code no-lock  :

       f-loc-sum-rcv = f-loc-sum-rcv  + ub.ord-dtl.qnty .
  end.

    if f-loc-sum-rcv   >  ub.ord-dtl.qnty then do:
       f-loc-sum-rcv:fgcolor in browse  br-docs-2  =  12 . /* error */
       f-loc-err-rcv:fgcolor in browse  br-docs-2  =  12 . /* error */
       f-loc-err-rcv = ">" .
    end.
    if f-loc-sum-rcv   <  ub.ord-dtl.qnty then do:
       f-loc-sum-rcv:fgcolor in browse  br-docs-2  =  4 . /* error */
       f-loc-err-rcv:fgcolor in browse  br-docs-2  =  4 . /* error */
       f-loc-err-rcv = "<" .
    end.
end.

on value-changed of br-docs in frame dialog-frame
do:
   run select-good-scala no-error .
end.

on value-changed of br-docs-2 in frame frame-a
do:
   run select-good-scala-2 no-error .
end.

on value-changed of tog-prt in frame dialog-frame
do:
   run pr-tog-prt no-error .
   if error-status :error then return no-apply.
end.

ON CHOOSE OF B-delivery IN FRAME Dialog-Frame /* Доставка */
DO:
  run cus/pardeliv.w
     ( input        parParentproc
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
      ) no-error.

    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка"
      view-as alert-box error
    .

END.

ON CHOOSE OF b-next IN FRAME {&frame-name}
DO:
 RUN step-next in this-procedure .
END.

ON CHOOSE OF b-prev IN FRAME {&frame-name}
DO:
 run step-prev in this-procedure .
END.
ON CHOOSE OF b-protocol IN FRAME Dialog-Frame /* b-contract */
DO:
  { gbl/stdbtn.i }
  run show-protocol in this-procedure .
END.

ON CHOOSE OF b-contract IN FRAME Dialog-Frame /* b-contract */
DO:
{ gbl/stdbtn.i }
  run show-contract-code in this-procedure .
END.

ON CHOOSE OF b-inf IN FRAME Dialog-Frame
DO:
  run cus/edi-inf.w ( p-doc-code ) .
END.

ON CHOOSE OF b-producer IN FRAME Dialog-Frame
DO:
  find current shar_ord-line no-lock  .
  if not available shar_ord-line  then  return.
  run ref/showcli.p
  (input parParentProc
  ,input shar_ord-line.prod-type /* p-obj-type */
  ,input shar_ord-line.prod-code /* p-obj-code */
  ).
  return no-apply.
END.


ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  next-prev = ?.
/*
define variable v-list-new as character no-undo .
   v-list-new = string(decimal( shar_ord-line.artic:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( buf-goods.gds-name:width  in browse {&browse-name})) +  {&delim-par}
              .

run uf-set in this-procedure(
    input  {&uf-cli-zakz}
    ,input v-cntxt-userid
    ,input v-list-new
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "uf-set"
      view-as alert-box error
    .
  */

  /*apply "WINDOW-CLOSE" TO SELF. */
  apply "end-error":u to self.
  return .
END.

on choose of b-notes in frame dialog-frame
do:
 run proc-d-notes in this-procedure .
end.

/* Export_TEXT ----------------------------------------------------------------------------------------------------------*/
ON CHOOSE OF MENU-ITEM m_Export_TEXT
DO:
  run cus/z-tot2.p ( parparentproc , "order" , shar_ord-doc.doc-type ,  p-doc-code) .
END.

ON CHOOSE OF B-Alt-post IN FRAME Dialog-Frame
DO:
  find current shar_ord-line no-lock no-error  .
  if  not avail shar_ord-line  then do:
        return.
  end.
 run cus/cli-othr.w
   (input shar_ord-line.artic,
    input shar_ord-line.prod-type,
    input shar_ord-line.prod-code,
    input buf-cli.obj-type ,
    input buf-cli.obj-code
    ).

END.

ON CHOOSE OF MENU-ITEM m_way1
DO:
  run CHOOSE-MENU-way1 in this-procedure.
END.

ON CHOOSE OF MENU-ITEM m_way2
DO:
  run CHOOSE-MENU-way2 in this-procedure.
END.

on choose of menu-item m_export_excel
do:
  run b-export-ch  in this-procedure .
end.


/* ***************************  main block  *************************** */

if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.
{ gbl/app_help.i }
{ gbl/ed_date.i loc-date-ship}
{ gbl/ed_date.i date-sale-1}
{ gbl/ed_date.i date-sale-2}
{ gbl/srt-clmn.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    =  loc-err-rcv
  &sort-clmn_2    =  shar_ord-line.line-num
  &sort-clmn_3    =  shar_ord-line.prt-ok
  &sort-clmn_4    =  shar_ord-line.artic
  &sort-clmn_5    =  buf-goods.gds-name
  &sort-clmn_6    =  shar_ord-line.unit-cli
  &sort-clmn_7    =  shar_ord-line.cli-qnty
  &sort-clmn_8    =  shar_ord-line.order-cli-qnty
  &sort-clmn_9    =  shar_ord-line.price-cli
  &sort-clmn_10   =  shar_ord-line.ord-dec1
  &sort-clmn_14   =  shar_ord-line.sum-cli
  &sort-clmn_15   =  shar_ord-line.cli-art
  &sort-clmn_16   =  buf-goods.unit-base
  &sort-clmn_17   =  shar_ord-line.qnty
  &sort-clmn_18   =  shar_ord-line.price-rubl
  &sort-clmn_19   =  shar_ord-line.sum-rubl
  &sort-clmn_20   =  loc-sum-rcv
  &sort-clmn_21   =  shar_ord-line.qnty-stk
  &sort-clmn_22   =  v-fact-qnty
  &sort-clmn_23   =  shar_ord-line.gds-code
  &sort-clmn_24   =  v-min-stock
  &sort-clmn_25   =  v-gds-way
  &open-query     = "{&open-query-br-docs-sort} BY ~{&sort-clmn_~{&clmn_num~}~} ."
  &open-query-otherwise = "run openbr."
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "no"
  &mv-brw-default       = "no" }


{ gbl/srt-clmn.i
  &browse-name    = "br-docs-2"
  &frame-name     = "frame-a"
  &table-name     = "shar_ord-line"
  &sort-clmn_1    = "f-artic"
  &sort-clmn_2    = "f-gds-name"
  &sort-clmn_3    = "f-prt-name"
  &sort-clmn_4    = "f-unit-base"
  &sort-clmn_5    = "shar_ord-line.qnty"
  &sort-clmn_6    = "f-qnty"
  &sort-clmn_7    = "f-price-rubl"
  &sort-clmn_8    = "f-sum-rubl"
  &sort-clmn_9    = "shar_ord-line.unit-cli"
  &sort-clmn_10   = "shar_ord-line.cli-qnty"
  &sort-clmn_11   = "f-cli-qnty"
  &sort-clmn_12   = "f-price-cli"
  &sort-clmn_13   = "f-sum-cli"
  &sort-clmn_14   = "shar_ord-line.cli-art"
  &sort-clmn_15   = "f-loc-sum-rcv"
  &sort-clmn_16   = "f-loc-err-rcv"
  &open-query     = "{&open-query-br-docs-2}"
  &open-query-otherwise = "{&open-query-br-docs-2}"
  &sort-column-name     = "sort-column-name"
  &re-move-clmn         = "yes"
  &mv-brw-default       = "no" }

define variable t5 as decimal no-undo .

g#type = shar-buf_ord-doc.doc-type .
doc-rec = recid(shar-buf_ord-doc)  .

define variable firstr as logical   no-undo .
firstr = true .
/* зацикливание формы */
next-prev = yes.
n-p: do while next-prev :

main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block:
   run mode-on in this-procedure.


  if not ( shar_ord-doc.doc-type = {&O-P} or shar_ord-doc.doc-type = {&O-F}) then do:
      shar_ord-line.qnty-stk:visible in browse br-docs = false .
      v-fact-qnty:visible in browse br-docs = false .
  end.

  t#query-was-opened = true.

  v-fl = true .
  run select-good-scala .
  run pr-tog-prt in this-procedure.

  run openbr.
  if firstr then do:
  run init-browse-p  in this-procedure .

 { gbl/mv-clmn.i
  &ext-col = 25
  &frame-name = "{&frame-name}"
  &browse-name = "br-docs"
  &start-column = "1"
 &prev-order-column_1 = v-order-column
 &prev-order-column-condition_1 = " true = true "

  }

  { gbl/mv-clmn.i
  &ext-col = 16
  &frame-name = "frame-a"
  &browse-name = "br-docs-2"
  &start-column = "1"
  }
  firstr = false  .
 end.
 wait-for go of frame {&frame-name} focus {&browse-name} .
end.
end.
run disable_ui  in this-procedure  .


/* **********************  internal procedures  *********************** */

procedure chg-action :
{&start-proc}
define buffer buff_contract for ub.contract .
t-ret =  session:set-wait-state("general") .


 find first shar_ord-doc no-lock  where recid(shar_ord-doc) = doc-rec  no-error.
 if not available shar_ord-doc then  do:
    t-ret =  session:set-wait-state("") .
    return.
 end.

 find first buf-cli      no-lock  where buf-cli.obj-code    = shar_ord-doc.cli-code
                                    and buf-cli.obj-type    = shar_ord-doc.cli-type no-error .


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
      /* договор */
    find first buff_contract no-lock where buff_contract.host-code     = shar_ord-doc.host-code and
                                           buff_contract.contract-code = shar_ord-doc.contract-code no-error .
    if available buff_contract then
       v-loc-contract        =  buff_contract.contract-prn-code + "(" + string(buff_contract.contract-code) + ")" .
       else v-loc-contract   = "".

    assign
      loc-obj-name-2 = "(" + shar_ord-doc.obj-type + " " + string(shar_ord-doc.obj-code ) + ")" + for-obj.obj-name
      wrkr          = shar_ord-doc.wrkr
      agnt          = shar_ord-doc.agnt
      boss          = shar_ord-doc.boss
      loc-time-ship = string(shar_ord-doc.ship-time,"hh:mm")
      loc-hour      = integer (entry(1,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      loc-min       = integer (entry(2,string(shar_ord-doc.ship-time,"hh:mm"),":"))
      date-sale-1   = shar_ord-doc.date-sale-1
      date-sale-2   = shar_ord-doc.date-sale-2
      e-method      = shar_ord-doc.e-method
      loc-date-ship = shar_ord-doc.ship-date
      loc-status    = shar_ord-doc.status_
      paytype       = shar_ord-doc.pay-code

      loc-service   = shar_ord-doc.sum-service
      cycle-day     = shar_ord-doc.cycle-day
      pay-day       = shar_ord-doc.pay-day
      tog-type      = shar_ord-doc.order-type
      loc-base-rate   = shar_ord-doc.base-rate
      loc-base-scale  = shar_ord-doc.base-scale

      loc-cli-qnty    = shar_ord-doc.cli-qnty
      loc-qnty        = shar_ord-doc.qnty
      loc-sum-base    = shar_ord-doc.sum-base
      loc-sum-cli     = shar_ord-doc.sum-cli
      loc-sum-rubl    = shar_ord-doc.sum-rubl
      loc-tot-lines   = shar_ord-doc.tot-lines

      loc-exch-code   = shar_ord-doc.exch-code
      loc-exch-rate   = shar_ord-doc.exch-rate
      loc-exch-scale  = shar_ord-doc.exch-scale
      loc-out-code    = shar_ord-doc.out-code
      doc-date        = shar_ord-doc.doc-date
      loc-doc-type    = shar_ord-doc.doc-type
      fact-date       = shar_ord-doc.fact-date
      vat_type        = shar_ord-doc.vat-type
      slt_type        = shar_ord-doc.slt-type
      loc-print-rubl  = true
      loc-store-code  = shar_ord-doc.obj-code
      loc-store-type  = shar_ord-doc.obj-type
      v-deliv-type-code     =  shar_ord-doc.deliv-type-code
      v-point-obj-code      =  shar_ord-doc.obj-point-code
      v-point-cli-code      =  shar_ord-doc.cli-point-code
      v-point-obj-db-num    =  shar_ord-doc.obj-point-db-num
      v-point-cli-db-num    =  shar_ord-doc.cli-point-db-num
      v-transport-host-code =  shar_ord-doc.transport-host-code
      v-transport-cli-type  =  shar_ord-doc.transport-cli-type
      v-transport-cli-code  =  shar_ord-doc.transport-cli-code
      v-transport-contract  =  shar_ord-doc.transport-contract
      v-transport-condition =  shar_ord-doc.transport-condition
      v-transport-value     =  shar_ord-doc.transport-value
      v-transport-sum       =  shar_ord-doc.sum-ship
      v-transport-vat       =  shar_ord-doc.transport-vat
      loc-cli-out-doc       =  entry(1, shar_ord-doc.cli-out-doc, {&delim-par})
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
    find first buf-cli where shar_ord-doc.cli-type = buf-cli.obj-type  and shar_ord-doc.cli-code = buf-cli.obj-code  no-lock no-error.
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

     assign loc-ord-num = shar_ord-doc.doc-code
            loc-status  = shar_ord-doc.status_  no-error.

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

    /* Закрыть шапку для корректи{1} sharedровки */
    disable loc-cli-code
            loc-cli-type
            loc-obj-name
            r-clients with frame {&frame-name}.
     display
            wrkr agnt boss wrkr-name agnt-name boss-name
            loc-cli-code
            loc-cli-type
            loc-obj-name

            with frame {&frame-name}.

  run openbr in this-procedure  .
/*  run enable_ui. */
 t-ret =  session:set-wait-state("") .
end. /*start-proc*/
end procedure.




procedure disable_ui :
{&start-proc}
  hide frame dialog-frame.
  hide frame a-frame.
end.
end procedure.


procedure enable_ui_2 :
{&start-proc}
/* для lookup */

if g#type <> {&o-f} then do:
  display  {&display-objects-all}      with frame dialog-frame.
end.
else do:
  display {&display-objects-of}      with frame dialog-frame.

end.

disable   all      with frame dialog-frame.
  enable b-exit  b-producer  b-alt-post  b-notes  b-help
         br-docs b-export /*tog-prt*/
         b-next b-prev  b-way
         b-inf b-delivery
         b-contract
         b-protocol
      with frame dialog-frame.
   display
         b-next b-prev
      with frame dialog-frame.

   enable e-method with frame dialog-frame.
   e-method:read-only = true .


  display
   b-exit  b-producer  b-alt-post  b-notes  b-help
   br-docs b-export  b-way
  with frame dialog-frame.

  hide b-chg b-main-calc in frame {&frame-name} .
  view frame dialog-frame.
  {&open-browsers-in-query-dialog-frame}
end.
end procedure.

procedure openbr :

{&start-proc}

t-ret =  session:set-wait-state("general") .
define variable l-query-was-opened as logical no-undo .

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

        assign frame {&frame-name}:title =  ( if g#type = {&o-f} then  " ЗАЯВКА № "
                                                                 else  " ЗАКАЗ  № "  )
                                                                 + loc-ord-num .

        if t-action = "lkp":u then  frame {&frame-name}:title = frame {&frame-name}:title + " (" + shar_ord-doc.doc-type + ") - " + {&lookup}.
        {&open-query-br-docs-sort} by shar_ord-line.line-num.

   run enable_ui_2 .
  t-ret =  session:set-wait-state("") .
  error-status :error = false .
end.
end procedure.

procedure ex-file :
{&start-proc}
define input parameter ff as character no-undo .
define input parameter ex as logical no-undo . .
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


procedure b-export-ch :
{&start-proc}
  g#log = true  .
  message "Экспорт в excel ." skip "Продолжать ?"
           view-as alert-box question buttons ok-cancel update g#log.
           {&if-not-true}
      /*
      for each shar_ord-line where shar_ord-line.doc-code = p-doc-code no-lock :
          create tmp#zakaz .
          buffer-copy shar_ord-line to tmp#zakaz .
      end.
      */
      run cus/z-tot1.p (PARPARENTPROC , p-doc-code , shar_ord-doc.obj-type , shar_ord-doc.obj-code ).
end.
end procedure.



procedure select-good-scala :
{&start-proc}

hide pay-day  in frame {&frame-name}.
hide loc-out-code  in frame {&frame-name}.

find  current shar_ord-line no-lock  no-error .
if not avail  shar_ord-line then do: /* message "tmp#zakaz нет еще"*/ . return. end.
assign
    x-prod-type = shar_ord-line.prod-type
    x-prod-code = shar_ord-line.prod-code
    x-artic     = shar_ord-line.artic
    .

  find first for-cli no-lock where for-cli.obj-type = shar_ord-line.prod-type and
                                   for-cli.obj-code = shar_ord-line.prod-code no-error.
  if avail for-cli then do:
      display for-cli.obj-name      @ prod-name
              buf-goods.gds-name    @ goods-name
              with frame {&frame-name} .
  end.
  else do:
      display "" @ prod-name  with frame {&frame-name}.
  end.
  if error-status :error  then message "123-" error-status :error.

end.
end procedure .

procedure select-good-scala-2 :
{&start-proc}
define buffer bb_goods for ub.goods .
find  current shar_ord-line no-lock  no-error .
if not avail  shar_ord-line then do:
      find  current ub.ord-dtl no-lock  no-error .
      if not avail  ub.ord-dtl then do: return.  end.
      assign
        x-prod-type = ub.ord-dtl.prod-type
        x-prod-code = ub.ord-dtl.prod-code
        x-artic     = ub.ord-dtl.artic
        .

  end.
else
assign
  x-prod-type = shar_ord-line.prod-type
  x-prod-code = shar_ord-line.prod-code
  x-artic     = shar_ord-line.artic
  .
  find first bb_goods no-lock where bb_goods.prod-type = x-prod-type and
                                    bb_goods.prod-code  = x-prod-code  and
                                    bb_goods.artic      = x-artic
                                    no-error.

  find first for-cli no-lock where for-cli.obj-type = x-prod-type and
                                   for-cli.obj-code = x-prod-code no-error.
  if avail for-cli then do:
      display for-cli.obj-name      @ prod-name
              bb_goods.gds-name    @ goods-name
              with frame  {&frame-name} .
  end.
  else do:
      display "" @ prod-name  with frame {&frame-name}.
  end.
  if error-status :error  then message "123-" error-status :error.

end.
end procedure .




procedure mode-on :
{&start-proc }
  assign
    shar_ord-line.cli-art   :read-only in browse {&browse-name} =  true
    shar_ord-line.price-cli :read-only in browse {&browse-name} =  true  no-error .
  run chg-action  in this-procedure  .
  run enable_ui_2  in this-procedure  .
end.
end procedure.



procedure pr-tog-prt :
{&start-proc}

    assign frame dialog-frame tog-prt
    .
    if tog-prt = true then do:
       FRAME FRAME-A:HIDDEN           = false .
       view frame a-frame.
       enable br-docs-2 with frame frame-a.
       {&open-query-br-docs-2}

    end.
    else do:
       FRAME FRAME-A:HIDDEN           = TRUE.
       hide frame a-frame.
    end.

 end. /* do */
end procedure. /* pr-tog-prt */


procedure step-next :
{&start-proc}

define variable cur-form as char no-undo.
define variable new-form as char no-undo.
if valid-handle (br-handle) then do:

  g#log = br-handle:select-next-row() no-error .
  find first shar-buf_ord-doc no-lock where
              recid(shar-buf_ord-doc) = bf-handle:recid
              no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
     end.

  if not g#log then message "Это последний документ списка.".
end.
    doc-rec = recid ( shar-buf_ord-doc ).
    next-prev = ( cur-form = new-form ).

 end. /* do */
end procedure. /* step-next */

procedure step-prev :
{&start-proc}

define variable cur-form as char no-undo.
define variable new-form as char no-undo.
if valid-handle (br-handle) then do:
  g#log = br-handle:select-prev-row() no-error .
  find first shar-buf_ord-doc no-lock where
              recid(shar-buf_ord-doc) = bf-handle:recid
              no-error .
  if error-status :error then do:
     message "Это режим просмотра одного документа." .
     g#log = false .
  end.
  if not g#log then message "Это первый документ списка.".
end.
doc-rec = recid (shar-buf_ord-doc).
next-prev = (cur-form = new-form).

 end. /* do */
end procedure. /* step-prev */

procedure init-gds-rec :
{&start-proc}

 define buffer bb_goods for ub.goods.
 gds-rec = ? .
 find current shar_ord-line no-lock  no-error .
   if avail shar_ord-line then do:
      find first bb_goods no-lock where
          bb_goods.artic     = shar_ord-line.artic
      and bb_goods.prod-type = shar_ord-line.prod-type
      and bb_goods.prod-code = shar_ord-line.prod-code  no-error .
      gds-rec = recid (bb_goods).
   end.

 end. /* do */
end procedure. /* init-gds-rec */



procedure CHOOSE-MENU-way1 :
 do
 on error undo, return error return-value
 :
 assign frame {&frame-name} LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 find current shar_ord-line no-lock  .

 run cus/ord-way.w (   PARPARENTPROC ,
                   shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   1,
                    LOC-DATE-SHIP ,
                    DATE-sale-1,
                    DATE-sale-2,
                    loc-store-type,
                    loc-store-code ,
                    loc-doc-type
                       ) .

 end. /* do */
end procedure. /* CHOOSE-MENU-way1 */



procedure CHOOSE-MENU-way2 :
 do
 on error undo, return error return-value
 :

 assign frame {&frame-name} LOC-DATE-SHIP
                            DATE-sale-1
                            DATE-sale-2 .
 find current shar_ord-line no-lock no-error .

  run cus/ord-way.w (  PARPARENTPROC ,
                   shar_ord-line.artic     ,
                   shar_ord-line.prod-type ,
                   shar_ord-line.prod-code ,
                   2,
                  loc-date-ship  ,
                  date-sale-1    ,
                  date-sale-2    ,
                  loc-store-type ,
                  loc-store-code ,
                  loc-doc-type   ) .

 end. /* do */
end procedure. /* CHOOSE-MENU-way2 */

procedure proc-d-notes :
 do
 on error undo, return error return-value
 :
 define variable notes as character no-undo .
 find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.
   notes = shar_ord-doc.ps.
    run gbl/notes.w ( input {&lookup} , input-output notes).
    if shar_ord-doc.ps <> notes then do:
      do on stop undo, return error:
        find shar_ord-doc where recid (shar_ord-doc) = doc-rec exclusive no-error .
        shar_ord-doc.ps = notes.
      end.
    end.
    find first shar_ord-doc where recid(shar_ord-doc) = doc-rec no-lock no-error.


 end. /* do */
end procedure. /* proc-d-notes */
procedure show-contract-code :

  do
  on error undo, return error return-value
  :
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .

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

procedure init-browse-p :
/* Настройки экрана по пользователю */
  do
  on error undo, return error return-value
  :
if firstr = false then return .
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
    if decimal(entry(ii,v-spis-size))  = 0 then message ii.
    col-h:width  = decimal(entry(ii,v-spis-size))   .
    col-h:visible  = logical(entry(ii,v-spis-vis))  .
 end.

  v-fact-qnty:width in browse {&browse-name}  = 10 .
  loc-sum-rcv:width in browse {&browse-name}  = 10 .
  shar_ord-line.qnty-stk:width  in browse {&browse-name}  = 15 .
  shar_ord-line.gds-code:width  in browse {&browse-name}  = 13 .
  firstr = false  .
  end.

end procedure. /* init-browse-p */