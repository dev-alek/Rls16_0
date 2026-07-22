/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка РН (заведение, редактирование) флористов

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/

/* Parameters Definitions ---                                           */

define input parameter parParentProc   as widget-handle no-undo.
define input parameter doc-mode        as character no-undo    .
define input parameter g#stat          as character no-undo    .
define input parameter br-handle       as   handle                  no-undo.
define input parameter bf-handle       as   handle                  no-undo.


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка РН (заведение, редактирование)":U .

define variable  paris-hold      as   logical   no-undo .
define variable  g#type          as   character no-undo .
define variable  parext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define variable  parext-doc-mode as character no-undo .

define variable parstat           as character no-undo .
define variable partype           as character no-undo .
define variable parinternal       as logical   no-undo .
define variable g#mainmenu-handle as handle no-undo .
define variable varlog as logical   no-undo .
define variable rep-rec as recid no-undo .
define variable prt-mode as character no-undo .
define variable v-cntxp-cash-pay as integer   no-undo .
define variable is-doc-hold as logical   no-undo init false .
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
parext-doc-mode = doc-mode.
parstat = g#stat .

&global-define is-fuel 1
&global-define is-lgas 2
&global-define is-lgas-corr 3
&global-define is-gds 0

{ cmp/vssrevis.i "substitute('&1|&2':u,parext-doc-type,paris-hold)" }
{ cmp/str-glbl.i     }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ str/in-vatp.i def  }
{ str/get-pr.i  def  }
{ str/lib-trn.i  }
{ str/doc-code.i }
{ str/trdcalib.i }
{ gbl/lineattr.i }
{ str/libbcrcn.i }
{ str/lib-calc.i }
{ str/prescan.i  }
{ str/lib-def.i  }
{ str/scr-neb.i  }
{ gbl/waitfram.i noprocess }
{ str/cntrcode.i }
{ str/attrlist.i }
{ ref/cgrplib.i  }
{ cmp/showinf.i  }
{ gbl/getsect.i def }
{ str/cont-ms.i  }
define variable list-mode          as character no-undo .
define variable line-mode          as character no-undo .
define variable varline-mode          as character no-undo .
define variable gds-rec            as recid no-undo .
define variable line-rec           as recid no-undo .
define variable doc-rec            as recid no-undo .
define variable pardoc-rec         as recid no-undo .
define variable prt-rec            as recid no-undo .
define variable ref-rec            as recid no-undo .
define variable g#internal         as logical   no-undo .
define variable base-type as character no-undo .
define variable base-code as integer   no-undo .

define shared variable next-prev   as logical no-undo .
define variable parnext-prev   as logical no-undo .
define variable pardoc-mode as character no-undo .
define variable parline-mode          as character no-undo .
define new shared buffer gds-dtl  for ub.gds-dtl.
define new shared buffer gds-prt  for ub.gds-prt.
define new shared buffer goods    for ub.goods.
define new shared buffer bar-code for ub.bar-code.

define variable  notes       as   character no-undo .
define variable  lns-cnt     as   integer   no-undo .
define variable trn-type as integer no-undo init 0.

define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .

{ gbl/getcntxt.i get }
{ str/getctxtp.i get }

assign
  store-type        = v-cntxt-obj-type
  store-code        = v-cntxt-obj-code
  g#mainmenu-handle = parParentProc
.

{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).
{ gbl/basecode.i v-cntxt-host-code-obj base-code }

define buffer buf_rep_currency for ub.currency  .

find first buf_rep_currency no-lock
     where buf_rep_currency.curr-code = base-code
     no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

parext-doc-type =  {&TDEDT_Ras_Vnesh} .
g#type = {&expense} .
paris-hold = false .
g#internal = false .
partype = {&expense} .
parinternal = false .


&scop window-name    d-out-doc
&scop frame-name     d-out-doc
&scop browse-name    br-dtl

&scop label-clmn_1-br-dtl   '*'
&scop sort-clmn_1-br-dtl    get-mark  (BUFFER gds-dtl)
&scop label-clmn_2-br-dtl   'Бар-код'
&scop sort-clmn_2-br-dtl    bar-code.b-code
&scop label-clmn_3-br-dtl   'Артикул'
&scop sort-clmn_3-br-dtl    gds-dtl.artic
&scop label-clmn_4-br-dtl   'Имя '
&scop sort-clmn_4-br-dtl    (if gds-prt.node-name <> {&empty-scale} and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name)
&scop label-clmn_6-br-dtl   'Количество'
&scop sort-clmn_6-br-dtl    buf_tt-flor.fact-qnty
&scop label-clmn_7-br-dtl   'Изм'
&scop sort-clmn_7-br-dtl    goods.unit-base
&scop label-clmn_8-br-dtl   'Цена (вал.)'
&scop sort-clmn_8-br-dtl    gds-dtl.price-base
&scop label-clmn_9-br-dtl   ''
&scop sort-clmn_9-br-dtl    gds-dtl.ov
&scop label-clmn_10-br-dtl  'Сумма (вал.)'
&scop sort-clmn_10-br-dtl   (gds-dtl.price-base * buf_tt-flor.fact-qnty)
&scop label-clmn_11-br-dtl  'Скидка (вал.)'
&scop sort-clmn_11-br-dtl   (gds-dtl.discnt-base * buf_tt-flor.fact-qnty)
&scop label-clmn_12-br-dtl  'Итого (вал.).'
&scop sort-clmn_12-br-dtl   ((gds-dtl.price-base - gds-dtl.discnt-base) * buf_tt-flor.fact-qnty)
&scop label-clmn_13-br-dtl  'Скидка %'
&scop sort-clmn_13-br-dtl   gds-dtl.discnt-pc
&scop label-clmn_14-br-dtl  'Цена ({&abbr_rub}.)'
&scop sort-clmn_14-br-dtl   gds-dtl.price-rubl
&scop label-clmn_15-br-dtl  'Сумма ({&abbr_rub}.)'
&scop sort-clmn_15-br-dtl   (gds-dtl.price-rubl * buf_tt-flor.fact-qnty)
&scop label-clmn_16-br-dtl  'Скидка ({&abbr_rub}.)'
&scop sort-clmn_16-br-dtl   (gds-dtl.discnt-rubl * buf_tt-flor.fact-qnty)
&scop label-clmn_17-br-dtl  'Итого ({&abbr_rub}.)'
&scop sort-clmn_17-br-dtl   ((gds-dtl.price-rubl - gds-dtl.discnt-rubl) * buf_tt-flor.fact-qnty)
&scop label-clmn_18-br-dtl  'Признак'
&scop sort-clmn_18-br-dtl   (if gds-prt.node-name = {&empty-scale} then '-' else if gds-prt.upper-code = goods.prt-root then '-------------------' else gds-prt.f-name)
&scop label-clmn_5-br-dtl   'Всего По документу'
&scop sort-clmn_5-br-dtl     gds-dtl.doc-qnty


define variable bar-str like ub.prod-bc.b-str  no-undo. /* строка для чтения бар-кода из файла       */
{ cmp/gds-list.i gds-list def "new shared" }

define buffer cli-buf   for ub.clients. /* чтоб не поломать покупателя */
define buffer t-d-b     for ub.trn-doc. /* при возврате */
define buffer old-line  for ub.doc-line.
define buffer d-l-b     for ub.doc-line.
define buffer l-gds-dtl for ub.gds-dtl. /* для поиска  */

define shared buffer t-doc for  ub.trn-doc.
define query br-docs for t-doc scrolling.

define temp-table tt-1 no-undo
field gds-code  as integer
field prt-code as integer
field fact-qnty as decimal
index code is primary
gds-code
prt-code
.


define temp-table tt-posy no-undo
field gds-code       as integer
field gds-name       as character
field gds-dopinf     as character
field sum-rubl       as decimal
field sum-base       as decimal
index pi is primary gds-code
.

define new shared temp-table tt-flor no-undo
field gds-code-posy  as integer
field gds-code       as integer
field prt-code       as integer
field fact-qnty      as decimal
index pi             is primary gds-code-posy gds-code prt-code
.

{ cmp/titlmode.i }

define variable mark      as character                 no-undo.
define variable del-list  as character                 no-undo.
define variable ref-list  as character                 no-undo.
define variable chg-qnty  like ub.gds-dtl.doc-qnty init ? no-undo.
define variable add-sens  as logical                   no-undo. /* активна ли кнопка добавить в документе : yes / no - вызов из документа*/
define variable b-c       as integer                   no-undo. /* обрабатываемый бар-код */
define variable b-c-char  as character                 no-undo.
define variable rate      as decimal                   no-undo. /* коэффициент для единиц из бар-кода */
define variable ret-mode  as character                 no-undo. /*режим обработки бар-кода*/
define variable add-scan  as logical initial no        no-undo.
define variable work-mode like line-mode               no-undo.
define variable varhold   as character                 no-undo.
define variable varhold-type  as character             no-undo.
define variable bcvalue       as character initial ?   no-undo.
define variable bctype        as character initial ?   no-undo.
define variable prtvalue      as character initial ?   no-undo.
define variable prttype       as character initial ?   no-undo.
define variable conf-par      as character             no-undo. /* для чтения параметра конфигурации */
define variable varartic      like ub.doc-line.artic      initial " " no-undo.
define variable is-pieces     as logical               no-undo.
define variable v-cond        as character initial ?   no-undo. /*режим вызова справочника товаров*/
define variable is-repay      as logical               no-undo.
define variable is-cons       as logical               no-undo.
define variable is-storage    as logical               no-undo.
define variable is-oldcons    as logical               no-undo.
define variable varr-b        as character             no-undo.
define variable v-is-tsd      as character             no-undo.
define variable v-is-tsd-type as character             no-undo.
define variable v-exist       as logical               no-undo.
define variable v-buket-gds-code as integer            no-undo.
define variable v-param       as character             no-undo.
define variable v-gds-name    as character             no-undo.

define variable pr-wrk as character no-undo .
define variable pr-srk as character no-undo .
define variable v-pr-wrk as decimal   no-undo .
define variable v-pr-srk as decimal   no-undo .
define variable p-type as character no-undo .

define variable ii-sum-rubl as decimal   no-undo .
define variable ii-sum-base as decimal   no-undo .

DEFINE VARIABLE i-sum-rubl AS CHARACTER FORMAT "X(256)"
     VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.

DEFINE VARIABLE i-sum-base AS CHARACTER FORMAT "X(256)"
     VIEW-AS TEXT
     SIZE 14 BY 1
     FGCOLOR 4 FONT 4 NO-UNDO.


function get-mark return character (buffer local-gds-dtl for gds-dtl ).
   if lookup (string (recid (local-gds-dtl)), del-list) > 0  then return "*".
                                                             else return  "".
end function.

/* br по букетам */
&scop open-query-br-posy open query br-posy  for each tt-posy

/* browse по признакам */
&scop open-query-br-dtl open query br-dtl ~
  for each buf_tt-flor where buf_tt-flor.gds-code-posy = tt-posy.gds-code , ~
      each gds-dtl where     gds-dtl.doc-code = t-doc.doc-code    and ~
                             gds-dtl.prt-code = buf_tt-flor.prt-code    no-lock, ~
          each gds-prt where gds-prt.node-code = gds-dtl.prt-code no-lock, ~
          each goods where goods.artic = gds-dtl.artic ~
                       and goods.prod-code = gds-dtl.prod-code ~
                       and goods.prod-type = gds-dtl.prod-type ~
                       and goods.gds-code  = buf_tt-flor.gds-code no-lock, ~
          each bar-code where bar-code.gds-code = goods.gds-code ~
                          and bar-code.node-code = gds-dtl.prt-code ~
                          and bar-code.part-code = '' ~
                          and bar-code.in-code = '' ~
                          and bar-code.unit-cli = goods.unit-base no-lock

define            query br-posy for tt-posy scrolling.

define new shared buffer buf_tt-flor for tt-flor.
define new shared query br-dtl  for buf_tt-flor, gds-dtl, gds-prt, goods, bar-code scrolling.

define browse br-posy query br-posy no-lock display
tt-posy.gds-code column-label "Бар-код"  format "999999999"
tt-posy.gds-name column-label "Нетоварная позиция" format "x(38)"
tt-posy.sum-base column-label "Итого (баз.вал)"        format  "->>>>>>>>>>>>>>>>>>>9.99"
tt-posy.sum-rubl column-label "Итого ({&abbr_rub})"    format  "->>>>>>>>>>>>>9.99"

    WITH NO-ROW-MARKERS SEPARATORS SIZE 80 BY 3
         FONT 4 ROW-HEIGHT-CHARS .49 EXPANDABLE.
.

define new shared browse br-dtl query br-dtl no-lock display
  {&sort-clmn_1-br-dtl}  column-label {&label-clmn_1-br-dtl}  format "x(1)"
  {&sort-clmn_2-br-dtl}  column-label {&label-clmn_2-br-dtl}
  {&sort-clmn_3-br-dtl}  column-label {&label-clmn_3-br-dtl}
  {&sort-clmn_4-br-dtl} @ v-gds-name column-label {&label-clmn_4-br-dtl}  format "x(38)"
  {&sort-clmn_6-br-dtl}  column-label {&label-clmn_6-br-dtl}  format ">>>>>>>>9.999"
  {&sort-clmn_7-br-dtl}  column-label {&label-clmn_7-br-dtl}  format "x(3)"
  {&sort-clmn_8-br-dtl}  column-label {&label-clmn_8-br-dtl}
  {&sort-clmn_9-br-dtl}  column-label {&label-clmn_9-br-dtl}  format "+/-"
  {&sort-clmn_10-br-dtl} column-label {&label-clmn_10-br-dtl} format "->>>>>>>>>>9.99"
  {&sort-clmn_11-br-dtl} column-label {&label-clmn_11-br-dtl} format "->>>>>>>>>>9.99"
  {&sort-clmn_12-br-dtl} column-label {&label-clmn_12-br-dtl} format "->>>>>>>>>>9.99"
  {&sort-clmn_13-br-dtl} column-label {&label-clmn_13-br-dtl} format "->>>9.99"
  {&sort-clmn_14-br-dtl} column-label {&label-clmn_14-br-dtl}
  {&sort-clmn_15-br-dtl} column-label {&label-clmn_15-br-dtl} format "->>>>>>>>>>>>9.99"
  {&sort-clmn_16-br-dtl} column-label {&label-clmn_16-br-dtl} format "->>>>>>>>>>>>9.99"
  {&sort-clmn_17-br-dtl} column-label {&label-clmn_17-br-dtl} format "->>>>>>>>>>>>9.99"
  {&sort-clmn_18-br-dtl} column-label {&label-clmn_18-br-dtl} format "x(30)"
  {&sort-clmn_5-br-dtl}  column-label {&label-clmn_5-br-dtl}  format ">>>>>>>>9.999"
  gds-dtl.fact-qnty                                           format ">>>>>>>>9.999"
  enable gds-dtl.doc-qnty  gds-dtl.fact-qnty
  with size 98 by 5 separators.
/* ***********************  control definitions  ********************** */

define variable agnt-name as character format "x(256)":u
      view-as text
     size 10.5 by 1 no-undo.

define variable wrkr-name as character format "x(256)":u
      view-as text
     size 10.5 by 1 no-undo.

define variable boss-name as character format "x(256)":u
      view-as text
     size 10.5 by 1 no-undo.

define variable flora-PS as character format "x(256)":u
      view-as editor SCROLLBAR-VERTICAL
     size 89 by 2 fgcolor 9 no-undo.


define button b-mark
     label "&*":l
     size 3 by 1.


define button b-prt
     label "&Шкала":l
     size 7 by 1.

define button b-parts
     label "Па&рт":l
     size 7 by 1.

define button b-lkp
     label "&Просм":l
     size 7 by 1.

define button b-chg
     label "&Изм":l
     size 1 by 1.

define button b-del
     label "&Удал":l
     size 1 by 1.

define button b-notes
     label "При&м":l
     TOOLTIP "Дополнительная информация по документу в целом"
     size 7 by 1.

define button b-notes-line
     label "О наборе":l
     TOOLTIP "Дополнительная информация по набору"
     size 9 by 1.


define button b-arch
     label "Уч&ет":l
     size 7 by 1.

define button b-cnt
     label "&ДогП":l
     size 7 by 1.

define button b-history
     label "&Истор"
     size 7 by 1.
define button b-cur
    label  "У&Цена"
    size 7 by 1.

define button b-help
     label "Помо&щь":l
     size 7 by 1.

define button b-dopinf
     label "Параметры заказа":l
     TOOLTIP "Дополнительная информация для заказа на исполнение"
     size 17 by 1.

define button b-nabor
    label "Состав набора":l
    TOOLTIP "Корректировка товаров , входящий в набор"
    size 17 by 1.

define button b-dopl
     label "Оплата":l
     TOOLTIP "Окончательная оплата заказа на исполнение"
     size 7 by 1.




define button b-exit auto-go
     label "&Выход":l
     size 8 by 1.

define button b-next auto-go
     label "&>>":l
     size 4 by 1.

define button b-prev auto-go
     label "&<<":l
     size 4 by 1.

define button b-dov
    label "&Довер"
    size 7 by 1.

define button b-attr
    label "А&тр"
    size 7 by 1.


define button b-fixprice
    label "&ФиксЦ"
    size 7 by 1.


define button b-nabor2
    label "Наборы"
    TOOLTIP "В какие наборы входит товар"
    size 7 by 1.


define menu m-acc_price
    menu-item m-ap-1 label "без НДС"              accelerator "alt-1"
    menu-item m-ap-2 label "с НДС"                accelerator "alt-2"
    menu-item m-ap-3 label "без НДС (НДС 0 НП 0)" accelerator "alt-3"
.
define menu m-fixprice
    menu-item m-fp-1 label "Фиксировать цены"     accelerator "alt-1"
    menu-item m-fp-2 label "Расфиксировать цены"  accelerator "alt-2".

define variable fact-rubl as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1 no-undo.

define variable fact-base as decimal format "->>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 17 by 1 no-undo.

define variable sum-base-n as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.
define variable sum-rubl-n as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.

define variable d-sum-rubl as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1

     no-undo.

define variable d-sum-base as decimal format "->,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1
     no-undo.




define variable sum-base as decimal format "->>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 17 by 1 no-undo.

define variable sum-rubl as decimal format "->>,>>>,>>>,>>>,>>9.99" initial 0
     view-as fill-in
     size 20 by 1 no-undo.

define button r-acc
     image-up file "btn-down-arrow"
     image-down file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.

define button b-add  /*накл-*/
    label ""
    size 1 by 1.
define button r-agnt    like r-acc.
define button r-boss    like r-acc.
define button r-clients like r-acc.
define button r-outs    like r-acc.
define button r-pay     like r-acc.
define button r-wrkr    like r-acc.
define button r-sht     like r-acc.



define variable loc-art  as char format "x(16)" view-as fill-in size 14 by 1 fgcolor 12 no-undo.
define variable loc-name as char view-as fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-code as char view-as fill-in size 20 by 1 fgcolor 12 no-undo.

define variable a-n-c as char view-as radio-set horizontal /* vertical */ radio-buttons
"&А","art",
"&Н","name",
"&К","code"
size 10 by 1 no-undo.

define variable varpurch-chs as integer view-as radio-set vertical radio-buttons
"&Все", 0,
"&Выборочно", 1
size 12 by 1 bgcolor 8 no-undo.

define rectangle rect-tot edge-pixels 2 graphic-edge size 47 by 5.9  bgcolor 8 .
define rectangle rect-prc edge-pixels 2 graphic-edge size 17 by 5.9  bgcolor 8 .

/* ************************  frame definitions  *********************** */

define frame {&frame-name}
     t-doc.cli-code    at row 2   col 8 colon-aligned label "Контр." view-as fill-in size 10 by 1 format ">>>>>>>>9"
     t-doc.cli-type    at row 2   col 19 colon-aligned no-label view-as fill-in size 7.13 by 1
     r-clients         at row 2   col 28 no-label
     ub.clients.obj-name  at row 2   col 29 colon-aligned no-label view-as fill-in size 35 by 1 fgcolor 4
     t-doc.hold-obj-code at row 2 col 79 colon-aligned no-label view-as fill-in size 10 by 1 format ">>>>>>>>9"
     t-doc.hold-obj-type at row 2 col 90 colon-aligned no-label
     t-doc.out-code    at row 3   col 14 colon-aligned label "Ист&-к" format "x(21)" view-as fill-in size 15 by 1
     t-doc.doc-qnty    at row 3   col 42 colon-aligned label "Кол-во" view-as fill-in size 17 by 1 fgcolor 4
     t-doc.fact-qnty   at row 3   col 59 colon-aligned label "Факт" view-as fill-in size 17 by 1 fgcolor 4
     t-doc.discnt-pc   at row 3   col 58 colon-aligned label "&Скидка" format "->>>9.99%" view-as fill-in size 10 by 1 fgcolor 4
     t-doc.discnt-type at row 3   col 68 colon-aligned no-label view-as combo-box {&inner-lines} size 10.5 by 1
     t-doc.d-card      at row 3   col 75 colon-aligned label "Карта" format "x(19)"
     t-doc.print-rubl  at row 4   col 85 label "{&abbr_rubli_firstshift}" view-as toggle-box size 8 by .77 fgcolor 4
     "Баз.в."                  view-as text size 6 by 0.7 at row 5.1 col 50 fgcolor 4   bgcolor 8
     "{&abbr_rub_allshift}"    view-as text size 6 by 0.7 at row 5.1 col 69 fgcolor 4   bgcolor 8
     sum-base          at row 6 col 52 colon-aligned label "Сумма без наценки"  bgcolor 8
     sum-rubl          at row 6 col 64 colon-aligned no-label
     sum-base-n        at row 6.8 col 52 colon-aligned label "Сумма с наценкой"  bgcolor 8
     sum-rubl-n        at row 6.8 col 64 colon-aligned no-label
     t-doc.tot-calc    at row 7.6 col 52 colon-aligned label "Скидка клиента" view-as fill-in size 17 by 1 bgcolor 8
     t-doc.discnt-rubl at row 7.6 col 64 colon-aligned no-label view-as fill-in size 20       by 1
     fact-base         at row 8.4 col 52 colon-aligned label "С нац и скидкой" fgcolor 4       bgcolor 8
     fact-rubl         at row 8.4 col 64 colon-aligned no-label fgcolor 4
     d-sum-base        at row 9.7 col 52 colon-aligned label "Итого с доставкой" view-as fill-in size 17 by 1
     d-sum-rubl        at row 9.7 col 64 colon-aligned no-label
     "Тип приобретения" view-as text size 16 by 0.7 at row 4.7 col 82.5 fgcolor 4
     varpurch-chs at row 5.5 col 83 no-label
     is-repay at row 6.7 col 83 label "выкуп"          view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     is-cons at row 7.7 col 83 label "консигнация"     view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     is-storage at row 8.7 col 83 label "отв.хран."    view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     is-oldcons at row 9.7 col 83 label "ст. консигн." view-as toggle-box size 15 by .77 fgcolor 4  bgcolor 8
     rect-tot at row 5 col 34.5
     rect-prc at row 5 col 82
.
define frame {&frame-name}
     t-doc.base-rate   at row 5 col 8 colon-aligned label "Кур&с" view-as fill-in size 10 by 1 fgcolor 4
     t-doc.base-scale  at row 5 col 23 colon-aligned label "М&-б" view-as fill-in size 3.5 by 1 fgcolor 4
     r-acc             at row 5 col 31 no-label
     t-doc.pay-code    at row 6 col 8 colon-aligned label "&Опл" view-as fill-in size 6.25 by 1
     ub.pay-type.obj-name at row 6 col 14 colon-aligned no-label view-as text size 14.5 by 1 fgcolor 4
     r-pay             at row 6 col 31 no-label
     t-doc.wrkr        format "999999999" at row 7 col 8  colon-aligned view-as fill-in size 10 by 1
     wrkr-name         at row 7 col 18 colon-aligned no-label  fgcolor 4
     r-wrkr            at row 7 col 31 no-label
     t-doc.agnt        format "999999999" at row 8 col 8 colon-aligned view-as fill-in size 10 by 1
     agnt-name         at row 8 col 18 colon-aligned no-label fgcolor 4
     r-agnt            at row 8 col 31 no-label
     t-doc.boss        format "999999999" at row 9 col 8 colon-aligned view-as fill-in size 10 by 1
     boss-name         at row 9 col 18 colon-aligned no-label fgcolor 4
     r-boss            at row 9 col 31 no-label
     a-n-c             at row 10 col 1 no-label
     t-doc.doc-date    at row 4 col 5  colon-aligned label "&Дата" view-as fill-in size 9 by 1 fgcolor 4
     t-doc.fact-date   at row 4 col 20 colon-aligned label "&Факт" view-as fill-in size 9 by 1 fgcolor 4
     t-doc.shift-date  at row 4 col 36 colon-aligned label "&Смена" view-as fill-in size 9 by 1 fgcolor 4
     t-doc.shift-name     at row 4 col 48.3 colon-aligned label "№" view-as fill-in size 3 by 1 fgcolor 4
     t-doc.shift-num   at row 4 col 54.6 colon-aligned label "П" view-as fill-in size 3 by 1 fgcolor 4
     r-sht             at row 4 col 57.6 colon-aligned
     b-exit         at row 1 col 1
     b-prev         at row 1 col 9
     b-next         at row 1 col 13
     b-dopinf       at row 1 col 17
     b-dov          at row 1 col 34
     b-notes        at row 1 col 41
     b-cnt          at row 1 col 48

     b-dopl          at row 1 col 55
     b-attr          at row 1 col 62
     b-history           at row 1 col 69
     b-help          at row 1 col 76

     loc-art       at row 10   col 30  colon-aligned label "Начало артикула"
     loc-name      at row 10   col 30  colon-aligned label  "Начало названия" format "x(40)"
     loc-code      at row 10   col 30  colon-aligned label  "Бар-код (весь)" format "x(13)"

     i-sum-base    at row 11.3  col 44  no-label
     i-sum-rubl    at row 11.3  col 61  no-label

     b-nabor       at row 11 col 1
     br-posy       at row 12 col 1
     flora-PS      at row 15 col 1   no-label

     b-mark     at row 17 col 1
     b-lkp      at row 17 col 4
     b-prt      at row 17 col 11
     b-parts    at row 17 col 18
     b-cur      at row 17 col 25
     b-arch     at row 17 col 32
     b-fixprice      at row 17 col 39
     b-nabor2        at row 17 col 46
     b-notes-line    at row 17 col 74

     br-dtl        at row 18  col 1

     b-add         at row 21  col 1   no-label
     b-chg         at row 21  col 1   no-label
     b-del         at row 21  col 1   no-label

     space(0) skip(0) with view-as dialog-box side-labels three-d scrollable keep-tab-order.

/* ***************  runtime attributes and uib settings  ************** */

assign
       br-dtl:num-locked-columns in frame {&frame-name} = 3
       frame {&frame-name}:scrollable       = false
       b-cur:POPUP-MENU IN FRAME {&frame-name} = MENU m-acc_price:HANDLE
       b-cur:MENU-MOUSE = 1
       b-fixprice:POPUP-MENU IN FRAME {&frame-name} = MENU m-fixprice:HANDLE
       b-fixprice:MENU-MOUSE = 1
       .
/* ************************  control triggers  ************************ */
{ gbl/mv-clmn.i
 &ext-col = 18
 &frame-name = "{&frame-name}"
 &browse-name = "{&browse-name}"
 &table-name = "doc-line"
 &start-column = 4
}

{ gbl/srt-clmn.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "gds-dtl"
&ext-col = 18
&start-column  = 4
&label-clmn_1  = "{&label-clmn_1-br-dtl}"
&sort-clmn_1   = "{&sort-clmn_1-br-dtl}"
&label-clmn_2  = "{&label-clmn_2-br-dtl}"
&sort-clmn_2   = "{&sort-clmn_2-br-dtl}"
&label-clmn_3  = "{&label-clmn_3-br-dtl}"
&sort-clmn_3   = "{&sort-clmn_3-br-dtl}"
&label-clmn_4  = "{&label-clmn_4-br-dtl}"
&sort-clmn_4   = "{&sort-clmn_4-br-dtl}"
&label-clmn_5  = "{&label-clmn_5-br-dtl}"
&sort-clmn_5   = "{&sort-clmn_5-br-dtl}"
&label-clmn_6  = "{&label-clmn_6-br-dtl}"
&sort-clmn_6   = "{&sort-clmn_6-br-dtl}"
&label-clmn_7  = "{&label-clmn_7-br-dtl}"
&sort-clmn_7   = "{&sort-clmn_7-br-dtl}"
&label-clmn_8  = "{&label-clmn_8-br-dtl}"
&sort-clmn_8   = "{&sort-clmn_8-br-dtl}"
&label-clmn_9  = "{&label-clmn_9-br-dtl}"
&sort-clmn_9   = "{&sort-clmn_9-br-dtl}"
&label-clmn_10 = "{&label-clmn_10-br-dtl}"
&sort-clmn_10  = "{&sort-clmn_10-br-dtl}"
&label-clmn_11 = "{&label-clmn_11-br-dtl}"
&sort-clmn_11  = "{&sort-clmn_11-br-dtl}"
&label-clmn_12 = "{&label-clmn_12-br-dtl}"
&sort-clmn_12  = "{&sort-clmn_12-br-dtl}"
&label-clmn_13 = "{&label-clmn_13-br-dtl}"
&sort-clmn_13  = "{&sort-clmn_13-br-dtl}"
&label-clmn_14 = "{&label-clmn_14-br-dtl}"
&sort-clmn_14  = "{&sort-clmn_14-br-dtl}"
&label-clmn_15 = "{&label-clmn_15-br-dtl}"
&sort-clmn_15  = "{&sort-clmn_15-br-dtl}"
&label-clmn_16 = "{&label-clmn_16-br-dtl}"
&sort-clmn_16  = "{&sort-clmn_16-br-dtl}"
&label-clmn_17 = "{&label-clmn_17-br-dtl}"
&sort-clmn_17  = "{&sort-clmn_17-br-dtl}"
&label-clmn_18 = "{&label-clmn_18-br-dtl}"
&sort-clmn_18  = "{&sort-clmn_18-br-dtl}"

&open-query = "{&open-query-{&browse-name}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name}}."
&re-move-clmn = "yes"
&mv-brw-default = "yes"
}

{ gbl/f2.i br-dtl  " "  " " parParentProc }

{ str/sch-line.i gds-dtl br-dtl}
end.

on end-error of gds-dtl.doc-qnty in browse {&browse-name} do:
   disp gds-dtl.doc-qnty with browse {&browse-name}.
   return no-apply.
end.

on end-error of gds-dtl.fact-qnty in browse {&browse-name} do:
   disp gds-dtl.fact-qnty with browse {&browse-name}.
   return no-apply.
end.
/* общие триггеры и процедуры для РН и ПН */
{ str/trn-tr.i out }

on row-leave of browse {&browse-name} do:
if available gds-dtl then do:
   find first goods where goods.artic     = gds-dtl.artic     and
                          goods.prod-type = gds-dtl.prod-type and
                          goods.prod-code = gds-dtl.prod-code no-lock.
   find first ub.units where ub.units.unit-name = goods.unit-base no-lock.
   if dec(gds-dtl.doc-qnty:screen-value in browse {&browse-name}) <> gds-dtl.doc-qnty and
      lookup({&twounit}, ub.units.type) > 0 then do:
      message "Товар с двумя единицами измерения резервируется через партии." view-as alert-box.
      return no-apply.
   end.
   if dec(gds-dtl.doc-qnty:screen-value in browse {&browse-name}) <> gds-dtl.doc-qnty then do:
      { str/chg-qnty.i doc}
   end.
   if dec(gds-dtl.fact-qnty:screen-value in browse {&browse-name}) <> gds-dtl.fact-qnty then do:
      { str/chg-qnty.i fact}
   end.
end.
end.
on choose of b-arch in frame {&frame-name} /* Просмотр в учетных ценах */
do:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_archive_cost':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  g#log
}


if not g#log then return no-apply.
run str/docsuppn.w
  (input  parparentproc
  ,input  recid(t-doc)
  ).
end.

on choose of b-cnt in frame {&frame-name} /* Просмотр разбивку по дог. пост. */
do:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_archive_cost':U
  {&cntxt-object}
  t-doc.host-code
  t-doc.obj-type
  t-doc.obj-code
  0
  0
  0
  true
  g#log
}
if not g#log then return no-apply.
run str/scntdoc.w (t-doc.doc-code, v-cntxt-db-num = ub.sysconf.firm-db-num).
end.

on leave of t-doc.fact-date in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.fact-date <> t-doc.fact-date then do:
    run chk-upd-date no-error.
    if error-status:error then return no-apply.
    assign frame {&frame-name} t-doc.fact-date.
  end.
end.
/* Секция триггеров обработки смены */
on return of t-doc.shift-date in frame {&frame-name} do:
  apply "entry" to t-doc.shift-name in frame {&frame-name}.
  return no-apply.
end.
on return of t-doc.shift-name in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.

on return of t-doc.shift-num in frame {&frame-name} do:
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
end.
on choose of r-sht in frame {&frame-name} do:
  run proc-sht in this-procedure .
end.
on leave of t-doc.shift-num  in frame {&frame-name} do:
  run proc-shift-num no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-name in frame {&frame-name} do:
  run proc-shift-name no-error.
  if error-status:error then do:
    return no-apply.
  end.
end.
on leave of t-doc.shift-date in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.shift-date <> t-doc.shift-date then do:
    assign
      t-doc.shift-name   = ""
      t-doc.shift-num = 0.
    display t-doc.shift-name t-doc.shift-num with frame {&frame-name}.
    apply "entry" to t-doc.shift-name in frame {&frame-name}.
    return no-apply.
  end.
end.

on choose of b-dopinf in frame {&frame-name} do:

  run init-attr-flora in this-procedure .
  if doc-mode <> {&lookup} then do:
        run str/fl-atu.w (input {&update}, input t-doc.doc-code) no-error.
  end.
  else do:
     run str/fl-atu.w (input {&lookup}, input t-doc.doc-code) no-error.
  end.

end.

on choose of b-nabor in frame {&frame-name} do:
define variable v-make as logical   no-undo .
if not available t-doc then return .
if not available tt-posy then return .
define variable v1 as decimal   no-undo .
define variable v2 as decimal   no-undo .

define variable l-g#stat  like g#stat    no-undo .
define variable dost-rubl as   decimal   no-undo .
define variable dost-base as   decimal   no-undo .
define variable p-type    as   character no-undo .
define variable v-dost    as   character no-undo .

{ str/tdat-val.i
    t-doc.doc-code
    {&trdcattr-deliv}
    v-dost
    p-type
}
     dost-rubl = decimal(v-dost).
     if dost-rubl = ? then dost-rubl = 0.
     dost-base = dost-rubl  * t-doc.base-scale / t-doc.base-rate.


assign
l-g#stat     = g#stat
g#stat       = t-doc.status_ .

if doc-mode <> {&lookup} then do:
   run str/fl-nabor.w (
        input parParentProc,
        input doc-mode         ,
        input t-doc.doc-code   ,
        input tt-posy.gds-code ,
        output v-make,
        output tt-posy.sum-rubl ,
        output tt-posy.sum-base
        ) .
     g#stat = l-g#stat .
      assign
        ii-sum-base = 0
        ii-sum-rubl = 0
      .
      for each tt-posy :
          assign
            ii-sum-base = tt-posy.sum-base + ii-sum-base
            ii-sum-rubl = tt-posy.sum-rubl + ii-sum-rubl
          .
      end.

      if t-doc.status_ = {&fact} then do:
          display string(ii-sum-rubl , ">>>,>>>,>>9.99")  @ i-sum-rubl
                  string(ii-sum-base , ">>>,>>>,>>9.99")  @ i-sum-base
                 with frame {&frame-name} .
      end.
      else DO:
         display string(ii-sum-rubl , ">>>,>>>,>>9.99")  @ i-sum-rubl
              string(ii-sum-base , ">>>,>>>,>>9.99")  @ i-sum-base
              with frame {&frame-name} .
       end.


  if v-make then do:
      run cr-tt-flor in this-procedure .
      run re-disp in this-procedure  .
      run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
      {&browse-name}:refresh() in frame {&frame-name} no-error .
      br-posy:refresh() in frame {&frame-name} no-error .
      run ui-on ("line").
      apply "entry" to br-posy in frame {&frame-name} .
      reposition br-dtl to recid prt-rec no-error.
  end.
 end.
else
   run str/fl-nabor.w (
        input parParentProc,
        input doc-mode         ,
        input t-doc.doc-code   ,
        input tt-posy.gds-code ,
        output v-make,
        output v1 ,
        output v2  ) .
        run re-disp in this-procedure  .
define buffer bb_gds-dtl for ub.gds-dtl.
end.

on choose of b-nabor2 in frame {&frame-name} do:
define variable v-make as logical   no-undo .
if not available t-doc then return .
if not available goods then return .

   run str/fl-nabo2.w (
        input parParentProc,
        input doc-mode  ,
        input t-doc.doc-code ,
        input goods.gds-code ,
        input gds-dtl.prt-code ,
        output v-make)
   .
  if v-make then do:
      run cr-tt-flor in this-procedure .
      run re-disp in this-procedure  .
      run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
      {&browse-name}:refresh() in frame {&frame-name} no-error .
      run ui-on ("line").
  end.
end.


on choose of b-dopl in frame {&frame-name} do:
  define variable p-return-attribute as character no-undo .
  define variable p-db-num as integer   no-undo .
  define buffer nn_trn-doc for ub.trn-doc.
  case t-doc.status_
  :
  when {&fact}
  then do:
     run str/fl-dopl.w (parParentProc , input {&lookup}, input t-doc.doc-code) no-error.
  end.
  when {&ready}
  then do:
     find first nn_trn-doc no-lock where nn_trn-doc.out-code = t-doc.doc-code no-error .
     if available nn_trn-doc then do:
        run str/fl-dopl.w (parParentProc , input {&lookup}, input nn_trn-doc.doc-code) no-error.
     end.
   end.
  otherwise do:
      { gbl/objat.i    t-doc.obj-type t-doc.obj-code "'active=request'"  p-return-attribute}
      { gbl/objdbnum.i t-doc.obj-type t-doc.obj-code p-db-num }
      if p-return-attribute = "no" or  p-db-num <> v-cntxt-db-num then
           run str/fl-dopl.w (parParentProc , input {&lookup}, input t-doc.doc-code) no-error.
      else run str/fl-dopl.w (parParentProc , input doc-mode , input t-doc.doc-code) no-error.
      if doc-mode <> {&lookup} then do:
         run re-disp in this-procedure  .
      end.

  end.
  end case.


end.


on choose of menu-item m-fp-1 in menu m-fixprice
do:

 if available gds-dtl then do:
   assign prt-rec = recid(gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign g#log = no.
 message "Если Вы зафиксируете цены, то при изменении цены в прайс-листе до закрытия документа она не проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update g#log.
 if g#log = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = yes.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ? then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.
on choose of menu-item m-fp-2 in menu m-fixprice
do:
 if available gds-dtl then do:
   assign prt-rec = recid(gds-dtl).
 end.
 else do:
   assign prt-rec = ?.
 end.
 define buffer bf_gds-dtl for ub.gds-dtl.
 assign g#log = no.
 message "Если Вы расфиксируете цены, то при изменении цены в прайс-листе до закрытия документа она проставится в документ." skip
         "Вы уверены?" view-as alert-box buttons yes-no update g#log.
 if g#log = yes then do:
   for each bf_gds-dtl where bf_gds-dtl.doc-code = t-doc.doc-code on error undo, return no-apply :
     assign
       bf_gds-dtl.ov = no.
   end.
 end.
 run ui-on ("line").
 if prt-rec <> ?  then do:
   reposition br-dtl to recid prt-rec no-error.
 end.
end.

on choose of b-mark in frame {&frame-name} do:
 run mark-list in this-procedure .
end.

on choose of b-del in frame {&frame-name} /* Удал */ do:
run local-del in this-procedure  no-error.
if error-status:error then return no-apply.
run ui-on ("enable":u).
apply "entry" to br-dtl in frame {&frame-name} .
prt-rec = rep-rec.
if prt-rec <> ? then reposition br-dtl to recid prt-rec no-error.
end.

on choose of b-lkp in frame {&frame-name} /* Просм */
do:
if not available gds-dtl then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
run local-lookup in this-procedure .
end.

on choose of b-prt in frame {&frame-name} /* Шкала */
do:
if not available gds-dtl then do:
  message "Неправильный выбор строки - шкала недоступна.".
  return no-apply.
end.
if doc-mode <> {&lookup} then do:
  run check-rate in this-procedure  no-error.
  if error-status:error then return no-apply.
end.
run set-work-mode-prt in this-procedure  no-error.
if error-status:error then return no-apply.
if pardoc-mode = {&lookup} then do:
  find first ub.doc-line where ub.doc-line.doc-code  = gds-dtl.doc-code  and
                            ub.doc-line.artic     = gds-dtl.artic     and
                            ub.doc-line.prod-type = gds-dtl.prod-type and
                            ub.doc-line.prod-code = gds-dtl.prod-code no-lock.
end.
else do:
  find first ub.doc-line where ub.doc-line.doc-code  = gds-dtl.doc-code  and
                            ub.doc-line.artic     = gds-dtl.artic     and
                            ub.doc-line.prod-type = gds-dtl.prod-type and
                            ub.doc-line.prod-code = gds-dtl.prod-code .
end.
find first goods where goods.artic     = gds-dtl.artic     and
                       goods.prod-type = gds-dtl.prod-type and
                       goods.prod-code = gds-dtl.prod-code no-lock.

run str/out-add.p
  (input parparentproc,
    input recid(t-doc),
    input recid(doc-line),
    input recid(gds-dtl),
    input recid(goods),
    input work-mode,
    input ?
    ) no-error.
if error-status:error then return no-apply.
if prt-mode = {&prt-def} then
   run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name} .
reposition br-dtl to recid prt-rec no-error.
end.

ON CHOOSE OF b-exit IN FRAME {&frame-name}
DO:
  next-prev = ?.
  apply "WINDOW-CLOSE" TO SELF.
  Return .
END.

on choose of b-parts in frame {&frame-name} /* Партии */
do:
define variable varloc-prt-rec as recid no-undo.
if not available gds-dtl then do:
  message "Неправильный выбор строки - партии недоступны.".
  return no-apply.
end.
assign
  varloc-prt-rec = recid(gds-dtl).
run local-parts in this-procedure  no-error.
if error-status:error then return no-apply.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name} .
reposition br-dtl to recid varloc-prt-rec no-error.
end.

on choose of menu-item m-ap-1 in menu m-acc_price  /*Простановка учетных цен без налогов*/
do:
run local-cur in this-procedure (input 1) no-error.
if error-status:error then return no-apply.
run UI-on ("enable").
end.

on choose of menu-item m-ap-2 in menu m-acc_price  /*Простановка учетных цен с налогами*/
do:
run local-cur in this-procedure (input 2) no-error.
if error-status:error then return no-apply.
run UI-on ("enable").
end.

on choose of menu-item m-ap-3 in menu m-acc_price  /*Простановка учетных цен с нулевыми налогами*/
do:
run local-cur in this-procedure (input 3) no-error.
if error-status:error then return no-apply.
run UI-on ("enable").
end.

on value-changed of br-posy in frame {&frame-name}
do:
   {&open-query-br-dtl}.
if available tt-posy then flora-ps = tt-posy.gds-dopinf .
                     else flora-ps = "".
  display flora-ps with frame {&frame-name} .
end.

on value-changed of t-doc.discnt-type in frame {&frame-name}
do:
g#log = no.
run check-discnt no-error.
if error-status:error then return no-apply.
do transaction:
   run ch-discnt no-error.
   if return-value = "error" then do:
      if t-doc.discnt-type = {&percent} then do:
         run ui-on ("enable").
         apply "entry" to t-doc.discnt-pc in frame {&frame-name}.
         return no-apply.
      end.
      else undo, leave.
   end.
end. /*transaction*/
/*Чтобы в случае отката транзакции вернуть истинное значение в экранной форме*/
disp t-doc.discnt-type with frame {&frame-name}.
run ui-on ("enable").
end.

on leave of t-doc.discnt-pc in frame {&frame-name} do:
if input frame {&frame-name} t-doc.discnt-pc <> t-doc.discnt-pc then do:
if input frame {&frame-name} t-doc.discnt-pc = ? then do:
  message "Ошибка. Установлен неизвестный процент скидки."
  view-as alert-box error.
  display t-doc.discnt-pc with frame {&frame-name}.
  return no-apply.
end.
if available t-doc then do transaction:
  assign
    t-doc.discnt-pc = input frame {&frame-name} t-doc.discnt-pc.
  run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
  if error-status:error then do:
    undo, return no-apply.
  end.
  run ui-on ("line").
end.
end.
end.

on return, leave of t-doc.tot-calc in frame {&frame-name} do:
if input frame {&frame-name} t-doc.tot-calc <> t-doc.tot-calc then do:
  assign t-doc.tot-calc = input frame {&frame-name} t-doc.tot-calc.
  run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
  if error-status:error then undo, return no-apply.
  run ui-on ("line").
end.
end.
on return, leave of t-doc.discnt-rubl in frame {&frame-name} do:
  if input frame {&frame-name} t-doc.discnt-rubl <> t-doc.discnt-rubl then do:
    assign
      frame {&frame-name} t-doc.discnt-rubl.
    run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
    if error-status:error then do:
      undo, return no-apply.
    end.
    run ui-on ("line").
  end.
end.

define temp-table t-d-b-doc-line no-undo like lib-trn_ret-line.
define temp-table t-d-b-gds-dtl  no-undo like ub.gds-dtl.
define temp-table t-d-b-parts    no-undo like ub.parts.

on mouse-select-dblclick, return of t-doc.out-code in frame {&frame-name}
do:
define buffer tdb_doc-line for ub.doc-line.
define buffer tdb_gds-dtl  for ub.gds-dtl.
find t-d-b where t-d-b.doc-code = input frame {&frame-name} t-doc.out-code no-lock no-error.
if not available t-d-b then do:
  /* apply "choose" to r-outs in frame {&frame-name}. */
  return no-apply.
end.
for each t-d-b-doc-line :
  delete t-d-b-doc-line.
end.
for each t-d-b-gds-dtl :
  delete t-d-b-gds-dtl.
end.
for each t-d-b-parts :
  delete t-d-b-parts.
end.
for each tdb_doc-line where tdb_doc-line.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-doc-line.
  buffer-copy tdb_doc-line to t-d-b-doc-line.
end.
for each tdb_gds-dtl where tdb_gds-dtl.doc-code = t-d-b.doc-code on error undo, return no-apply :
  create t-d-b-gds-dtl.
  buffer-copy tdb_gds-dtl to t-d-b-gds-dtl.
end.

do transaction on error undo, return no-apply :
  define variable v-num as integer initial 1 no-undo.
  run gbl/d-askw.w
    (input "Вопрос"
    ,input "По каким количествам будем производить копирование?"
           + {&new-line} + (if t-d-b.status_ <> {&inquiry} then "Внимание ! Если добавляемое количество какого-либо товара недоступно, оно будет уменьшено." else "":U)
    ,input "|^"
    ,input "Фактическим|"
         + "Документарным|"
         + "Отмена"
    ,input "Исходя из фактических количеств в признаках.|"
         + "Исходя из документарных количеств в признаках.|"
         + "Отменить копирование."
    ,input 1
    ,input 3
    ,output v-num
    ).
    if v-num = 3 then do:
      return no-apply.
    end.

   { str/copy-ret.i
     parParentProc
     t-d-b.doc-code
     t-d-b.doc-type
     t-d-b.status_
     t-d-b.internal
     t-d-b.cli-type
     t-d-b.cli-code
     t-d-b.discnt-type
     t-d-b.tot-calc
     t-d-b.discnt-pc
     t-d-b.agnt
     t-d-b.boss
     t-d-b.wrkr
     t-d-b.base-rate
     t-d-b.base-scale
     t-d-b.exch-code
     t-d-b.vat-type
     t-doc.doc-code
     "t-doc.discnt-type:sensitive in frame {&frame-name}"
     "input frame {&frame-name} t-doc.discnt-pc"
     "input frame {&frame-name} t-doc.agnt"
     "input frame {&frame-name} t-doc.boss"
     "input frame {&frame-name} t-doc.wrkr"
     "input frame {&frame-name} t-doc.base-rate"
     "input frame {&frame-name} t-doc.base-scale"
     v-cntxp-cash-pay
     base-code
     t-d-b-doc-line
     t-d-b-gds-dtl
     t-d-b-parts
     no
     no
     no
     "(if v-num = 1 then yes else no)"
     no-error }
   if error-status:error then do:
     message "Ошибка при копировании документа." skip
             return-value skip
             error-status:get-message(1) skip
             error-status:get-message(2) skip
             error-status:get-message(3) skip
     view-as alert-box error.
     return no-apply.
   end.
   doc-mode = {&update}.
   run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
   if error-status:error then do:
     undo, return no-apply.
   end.
end.
run ui-on ("line").
apply "entry" to br-dtl in frame {&frame-name}.
return no-apply.
end.


on choose of b-attr do:
  run init-attr-general .
  if doc-mode <> {&lookup} then do:
     run str/doc-attr.w (input ParParentProc , input "b-lkp,b-chg,b-add,b-del", input t-doc.doc-code, input table tt-upd-attr) no-error.
  end.
  else do:
     run str/doc-attr.w (input ParParentProc , input "b-lkp", input t-doc.doc-code, input table tt-upd-attr) no-error.
  end.
end.

on choose of b-dov do:
define variable vardov as character no-undo.
find first ub.doc-attr  where ub.doc-attr.doc-code  = t-doc.doc-code and
                          ub.doc-attr.attr-code = {&trdcattr-dov}         no-lock no-error.
if available ub.doc-attr then do:
  assign vardov = ub.doc-attr.attr-value.
end.
run gbl/d-prompt.w (
        'title=':u + "Изменение атрибутов документа" + '\':u
      + 'text1=':u + "Доверенность" + '\':u
      + 'format=' + "x(300)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=3\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=' + (if doc-mode = {&update} then 'no':u else 'yes':u) + '\':u
      , input-output vardov
      ) no-error.
if doc-mode = {&update} and caps(return-value) = "TRUE"  then do:
  if not error-status:error then do:
    find first ub.doc-attr where ub.doc-attr.doc-code  = t-doc.doc-code and
                              ub.doc-attr.attr-code = {&trdcattr-dov}          no-error.
    if not available ub.doc-attr then do:
      create ub.doc-attr.
      assign
      ub.doc-attr.doc-code  = t-doc.doc-code
      ub.doc-attr.attr-code = {&trdcattr-dov}.
    end.
    assign
    ub.doc-attr.attr-value = vardov.
  end.
end.
run ui-on ("line").
end.

on choose of b-notes-line do:
define variable v-ps as character no-undo.

if not available t-doc then return .
if not available goods then return .
    run lineattr-value (
      input   t-doc.doc-code ,
      input   goods.gds-code ,
      input   {&lineattr-flora_ps},
      output  v-ps ,
      output  p-type      )
    .

run gbl/d-prompt.w (
        'title=':u + "Изменение атрибутов строки документа" + '\':u
      + 'text1=':u + "Примечание по позиции: " + goods.gds-name + '\':u
      + 'format=' + "x(1000)" + '\':u
      + 'type=' + "edit" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=60\':u
      + 'fillin_height=5\':u
      + 'max-chars=1000\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=' + (if doc-mode = {&update} then 'no':u else 'yes':u) + '\':u
      , input-output v-ps
      ) no-error.
  if caps(return-value) = "TRUE"  then do:
  if doc-mode = {&update} then do:
    if not error-status:error then do:

      run lineattr-write (
        input   t-doc.doc-code ,
        input   goods.gds-code ,
        input   {&lineattr-flora_ps},
        input   v-ps )
      .
    end.
  end.
end.
apply "value-changed" to br-dtl in frame {&frame-name}.

end.

on return of t-doc.fact-date in frame {&frame-name} do:
  if t-doc.fact-date:sensitive in frame {&frame-name} then do:
    apply "entry" to t-doc.shift-date in frame {&frame-name}.
  end.
  return no-apply.
end.

on value-changed of varpurch-chs in frame {&frame-name} do:
  define variable varchs-tg as logical no-undo.
  if varpurch-chs <> input frame {&frame-name} varpurch-chs then do:
    assign
      frame {&frame-name} varpurch-chs.
    if varpurch-chs = 0 then do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchlimit}
          "'no':U"
      }
      assign
        varchs-tg = no.
      if is-repay = no then do:
        assign
          is-repay  = yes
          varchs-tg = yes.
      end.
      if is-cons = no then do:
        assign
          is-cons   = yes
          varchs-tg = yes.
      end.
      if is-storage = no then do:
        assign
          is-storage  = yes
          varchs-tg = yes.
      end.
      if is-oldcons = no then do:
        assign
          is-oldcons  = yes
          varchs-tg = yes.
      end.
      if varchs-tg = yes then do:
        { str/tdat-wrt.i
            t-doc.doc-code
            {&trdcattr-purchcodelist}
            {&purchase-codes}
        }
        display is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
      end.
      disable is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
    end.
    else do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchlimit}
          "'yes':U"
      }
      enable is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
    end.
    display varpurch-chs with frame {&frame-name}.
  end.
end.

on value-changed of is-repay in frame {&frame-name} do:
  run val-chg-is-repay.
end.
on value-changed of is-cons in frame {&frame-name} do:
  run val-chg-is-cons.
end.
on value-changed of is-storage in frame {&frame-name} do:
  run val-chg-is-storage.
end.
on value-changed of is-oldcons in frame {&frame-name} do:
  run val-chg-is-oldcons.
end.


/* ***************************  main block  *************************** */

if valid-handle(active-window) and frame {&frame-name}:parent eq ?
then frame {&frame-name}:parent = active-window.

on window-close of frame {&frame-name} apply "end-error":u to self.

{ gbl/app_help.i }
{ gbl/ed_date.i "t-doc.doc-date,t-doc.fact-date,t-doc.shift-date" " " "disable" }
/* зацикливание формы */
next-prev = yes.
n-p: do while next-prev :
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop undo main-block, leave main-block:
find ub.sysconf where ub.sysconf.host-code = v-cntxt-host-code-obj no-lock.
v-cntxp-cash-pay = ub.sysconf.cash-pay.
{ gbl/conf-rd.i "'is-prt'"   0  "''" 0 "''" "''" "''" yes  prtvalue        prttype        no-error }
{ gbl/conf-rd.i "'holding'"  0  "''" 0 "''" "''" "''" no   varhold         varhold-type   no-error }
{ gbl/conf-rd.i "'is-tsd'"  0  "''" 0 "''" "''" "''" no   v-is-tsd       v-is-tsd-type no-error }
{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'is-bcdoc' then bcvalue = string(thbjattr_thbj-attr.property-value-logical) .
end.

{ gbl/curr-r-b.i varr-b }
hide b-add b-chg b-del t-doc.out-code in frame {&frame-name} .
if doc-mode <> {&lookup} then do:
    { str/delnabor.i parParentProc t-doc.doc-code no-error }
    if error-status:error then return error.
    run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error. if error-status:error then return error.
end.
run cr-tt-posy no-error . if error-status:error then return error.
run cr-tt-flor no-error . if error-status :error then return error.
run mode-on no-error. if error-status:error then return error.
run re-disp .
run ui-on ("enable").
if prt-rec <> ? and doc-mode = {&lookup} then reposition br-dtl to recid prt-rec no-error.
if doc-mode = {&add-def} then wait-for go of frame {&frame-name} focus t-doc.cli-code.
else wait-for go of frame {&frame-name} focus br-dtl.
end.
end. /* do while */
run disable_ui.

/* **********************  internal procedures  *********************** */

procedure disable_ui :
  hide frame {&frame-name}.
end procedure.

procedure ui-on :
define input param fnc as char no-undo.
/* -----------------------------------------------------------
  purpose:     включение интерфейса в нужном режиме
------------------------------------------------------------- */
define variable varexist                  as logical   no-undo.
define variable varpurch-limit            as character no-undo.
define variable varpurch-limit-type       as character no-undo.
define variable varpurch-code-string      as character no-undo.
define variable varpurch-code-string-type as character no-undo.
define buffer bf_doc-line for ub.doc-line.
del-list = "" .
loc-art = ""  .


if fnc = "enable" then do:
  disable all with frame {&frame-name}.
  hide loc-art in frame {&frame-name} loc-name loc-code in frame {&frame-name}.
  enable b-exit b-lkp b-help br-dtl br-posy b-arch b-history a-n-c b-notes b-cnt b-attr with frame {&frame-name}.

   define variable v-flor as logical   no-undo .
   { str/flornakl.i t-doc.doc-code v-flor }
   if v-flor = false   then do:
    message "Ошибка !!! Не верный документ " .
   end.

enable  b-dopl b-dopinf b-nabor2 b-nabor flora-PS with frame {&frame-name}.
flora-PS:READ-ONLY = true .
hide  b-notes-line in frame {&frame-name} .
  enable b-parts with frame {&frame-name}.

  if prtvalue = "yes" and  v-cntxp-doc-prt then enable b-prt with frame {&frame-name}.
  if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then enable b-parts with frame {&frame-name}.
  if doc-mode = {&add-def} then do:
    { str/tdat-xst.i
        t-doc.doc-code
        {&trdcattr-purchlimit}
        varexist
    }
    if varexist = no then do:
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchlimit}
          "'no':U"
      }
      { str/tdat-wrt.i
          t-doc.doc-code
          {&trdcattr-purchcodelist}
          {&purchase-codes}
      }
    end.
  end.
  { str/tdat-val.i
      t-doc.doc-code
      {&trdcattr-purchlimit}
      varpurch-limit
      varpurch-limit-type
  }
  if varpurch-limit = "no":u then do:
    assign
      varpurch-chs = 0.
    assign
      is-repay   = yes
      is-cons    = yes
      is-storage = yes
      is-oldcons = yes.
  end.
  else do:
    assign
      varpurch-chs = 1.
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varpurch-code-string
        varpurch-code-string-type
    }
    if lookup ({&repayment-code}, varpurch-code-string) > 0 then do:
      assign
        is-repay = yes.
    end.
    if lookup ({&consignation-code}, varpurch-code-string) > 0 then do:
      assign
        is-cons = yes.
    end.
    if lookup ({&responsible-storage-code}, varpurch-code-string) > 0 then do:
      assign
        is-storage = yes.
    end.
    if lookup ({&old-consignation-code}, varpurch-code-string) > 0 then do:
      assign
        is-oldcons = yes.
    end.
  end.
  case t-doc.status_ :
       when {&wayb} then do:
           assign gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes.
           assign gds-dtl.fact-qnty:read-only  in browse {&browse-name} = yes.
       end.
       when {&permitted} then assign
            gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
            gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes
       .
       otherwise   assign gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
                          gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes.
  end case.

  case doc-mode :
    when {&lookup} then do:
         assign gds-dtl.doc-qnty:read-only  in browse {&browse-name} = yes
                gds-dtl.fact-qnty:read-only in browse {&browse-name} = yes.
         enable b-prev b-next with frame {&frame-name}.
    end.
    when {&add-def} then enable t-doc.cli-code t-doc.cli-type r-clients with frame {&frame-name}.
    when {&update} then do:
      g#log = no.
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_price':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        false
        g#log
      }
      if t-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP}      and
         t-doc.status_  = {&wayb}                         and
         not t-doc.flag_                                  and
         g#log = yes
         then enable b-cur with frame {&frame-name}.
      enable t-doc.wrkr
             t-doc.agnt t-doc.boss r-wrkr r-agnt r-boss
             t-doc.pay-code r-pay  t-doc.doc-date with frame {&frame-name}.
      g#log = no.
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_add-back-date':U
        {&cntxt-object}
        t-doc.host-code
        t-doc.obj-type
        t-doc.obj-code
        0
        0
        0
        false
        g#log
      }
      if g#log then do:
          enable t-doc.fact-date with frame {&frame-name}.
         { gbl/objat.i
           t-doc.obj-type
           t-doc.obj-code
           "'shift-on=request'"
           g#log
           no-error
          }
         if error-status :error then do:
           message
           vss-workfile vss-revision vss-description skip
           "Ошибка при запуске процедуры objat" skip
           error-status :get-message(1) skip
           return-value skip
           view-as alert-box error .
           return error.
         end.
         if g#log then do:
          enable t-doc.shift-date t-doc.shift-num t-doc.shift-name r-sht with frame {&frame-name}.
         end.
      end.
      if not t-doc.internal then enable t-doc.print-rubl with frame {&frame-name}.
      if t-doc.status_ = {&wayb} and
         t-doc.flag_   = no      then do:
        find first bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code no-lock no-error.
        if varpurch-limit = "no":u then do:
          if not available bf_doc-line then do:
            enable varpurch-chs with frame {&frame-name}.
          end.
        end.
        else do:
          if not available bf_doc-line then do:
            enable varpurch-chs is-repay is-cons is-storage is-oldcons with frame {&frame-name}.
          end.
        end.
      end.
      if not t-doc.flag_ and t-doc.status_ <> {&permitted} then do:

        if not t-doc.internal or t-doc.doc-type = {&expense} or t-doc.status_ = {&inquiry} then
          enable  b-mark b-fixprice with frame {&frame-name}.
        if not t-doc.internal then do:
           enable t-doc.discnt-type with frame {&frame-name}.
           if t-doc.discnt-type = {&percent} then
              enable t-doc.discnt-pc with frame {&frame-name}.
           if t-doc.discnt-type = {&amount} then do:
             if varr-b = "base":u then do:
               enable  t-doc.tot-calc with frame {&frame-name}.
             end.
             else do:
               enable t-doc.discnt-rubl with frame {&frame-name}.
             end.
           end.
        end.
        enable t-doc.cli-code r-clients with frame {&frame-name}.
            if v-cntxp-out-rate then
              enable t-doc.base-rate t-doc.base-scale r-acc with frame {&frame-name}.
      end.
    end.
  end.
end.

  if t-doc.discnt-type <> {&cash-desk} then disp t-doc.discnt-type with frame {&frame-name}.
  disp t-doc.discnt-pc t-doc.d-card t-doc.discnt-rubl t-doc.tot-calc with frame {&frame-name}.

enable b-dov with frame {&frame-name}.



disp t-doc.cli-code t-doc.cli-type t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name t-doc.doc-qnty
     t-doc.base-rate t-doc.base-scale t-doc.pay-code varpurch-chs is-repay is-cons is-storage is-oldcons with frame {&frame-name}.

display t-doc.print-rubl with frame {&frame-name}.
find ub.clients where ub.clients.obj-type = t-doc.cli-type and ub.clients.obj-code = t-doc.cli-code no-lock no-error.
if available ub.clients then
  disp ub.clients.obj-name with frame {&frame-name}.

frame {&frame-name}:title = t-doc.obj-type + " " + string (t-doc.obj-code, ">>>>9") + "  : ЗАКАЗ на ИСПОЛНЕНИЕ ".
if t-doc.office then frame {&frame-name}:title = frame {&frame-name}:title + "УСЛУГ ".
frame {&frame-name}:title = frame {&frame-name}:title
  + if t-doc.internal then "внутр - " else "внеш - ".
frame {&frame-name}:title = frame {&frame-name}:title
  + t-doc.status_ + " " + string (t-doc.flag_, "+/-") + " № " + t-doc.doc-code + "   - " + title-mode(doc-mode).
display t-doc.wrkr t-doc.agnt t-doc.boss with frame {&frame-name}.
{ str/psn-chk.i wrkr on t-doc ref-rec }
{ str/psn-chk.i agnt on t-doc ref-rec }
{ str/psn-chk.i boss on t-doc ref-rec }
if t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then do:
  disable t-doc.pay-code r-pay with frame {&frame-name}.
  if t-doc.discnt-pc = 0 then hide t-doc.discnt-type t-doc.discnt-pc t-doc.tot-calc t-doc.discnt-rubl in frame {&frame-name}.
end.
find ub.pay-type where ub.pay-type.obj-code = input frame {&frame-name} t-doc.pay-code no-lock no-error.
if available ub.pay-type then disp ub.pay-type.obj-name with frame {&frame-name}.
else disp ? @ ub.pay-type.obj-name with frame {&frame-name}.
release ub.pay-type no-error.
run re-disp .


{&open-query-br-posy}.
apply "value-changed" to br-posy in frame {&frame-name}.
apply "value-changed" to br-dtl in frame {&frame-name}.
end procedure.

procedure ch-discnt:
define variable hist-list as character no-undo.
define buffer buf_c-dis-card for ub.c-dis-card.
define buffer buf_c-dc-hist for ub.c-dc-hist.
if input frame {&frame-name} t-doc.discnt-type = {&card} then do:
  run ref/discards.w ( input parParentProc
                      ,input "b-sel"
                      ,input "client":U
                      ,input t-doc.host-code
                      ,input t-doc.obj-type
                      ,input t-doc.obj-code
                      ,input '':U
                      ,input recid (ub.clients)
                      ,output ref-list).
  if ref-list = "" then do:
    disp t-doc.discnt-type with frame {&frame-name}.
    return error.
  end.
  find ub.dis-card where recid (ub.dis-card) = integer (ref-list) no-lock.
  if ub.dis-card.status_ = {&nonused-status}
  or ub.dis-card.status_ = {&chown-status}
  then do:
    message
    substitute("Нельзя создать докуиент с картой &1&2" +
                "Карта имеет статус &3, &4"
                , ub.dis-card.d-card
                , {&new-line}
                , ub.dis-card.status_
                , (if ub.dis-card.status_ = {&nonused-status}
                    then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
                    else "карта будет доступна по окончании процесса смены владельца")
                )
    view-as alert-box error .
    return error.
  end.
  assign
    t-doc.d-card    = ub.dis-card.d-card.
  assign g#log = yes.
  message "Текущий процент по дисконтной карте " ub.dis-card.d-card " равен " ub.dis-card.d-pcnt " ." skip
          "Будем оформлять накладную, исходя из данного процента?" view-as alert-box question buttons yes-no update g#log.
  if g#log then do:
    assign
      t-doc.discnt-pc = ub.dis-card.d-pcnt
      t-doc.d-card    = ub.dis-card.d-card.
  end.
  else do:
    run ref/cdchist.w
               (     input parparentproc
                    ,input t-doc.host-code
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input "b-sel":U
                    ,input "subject":U
                    ,input ub.dis-card.d-card
                    ,input ub.dis-card.card-num
                    ,input t-doc.obj-type
                    ,input t-doc.obj-code
                    ,input t-doc.host-code
                    ,input v-cntxt-db-num
                    ,input "":U /*p-corr-user-name */
                    ,input {&table_dis-card} /*p-subject*/
                    ,input v-cntxt-db-num
                    /*записи в выборке*/
                    ,input-output hist-list
                 ) no-error .
    if error-status:error or
       hist-list = "" then do:
       message "Не смог взять процент из истории. Берем текущий процент."
       view-as alert-box information.
       assign
         t-doc.discnt-pc = ub.dis-card.d-pcnt
         t-doc.d-card    = ub.dis-card.d-card.
    end.
    else do:
      find first buf_c-dc-hist where
              recid(buf_c-dc-hist) = integer(hist-list) no-lock no-error.
      if available buf_c-dc-hist then do:
        find first buf_c-dis-card no-lock where
                  buf_c-dis-card.d-card           = buf_c-dc-hist.d-card
              AND buf_c-dis-card.chip-num         = buf_c-dc-hist.chip-num
              AND buf_c-dis-card.corr-user-db-num = buf_c-dc-hist.corr-user-db-num  no-error .
      end.
      if not available buf_c-dc-hist
      or not available buf_c-dis-card
      then do:
         message "Не смог взять процент из истории. Берем текущий процент."
         view-as alert-box information.
         assign
         t-doc.discnt-pc = ub.dis-card.d-pcnt
         t-doc.d-card    = ub.dis-card.d-card.
      end.
      else do:
        assign
        t-doc.discnt-pc = decimal(buf_c-dis-card.d-pcnt)
        t-doc.d-card    = ub.dis-card.d-card.   /* правильно ??? */
      end.
    end.
  end.
end.
else do:
  assign
    t-doc.d-card = ?.
end.
display t-doc.d-card t-doc.discnt-pc with frame {&frame-name}.
if input frame {&frame-name} t-doc.discnt-type = {&group} then do:
  define variable v-d-pcnt as decimal no-undo .
  run cgrplib-get-pcnt-value in this-procedure ( input ub.clients.grp-code , output v-d-pcnt) no-error .
  if error-status:error then do:
    message
    "Ошибка при установлениее скидки для группы клиентов."
    error-status:get-message(1) skip
    return-value
    view-as alert-box.
    display t-doc.discnt-type with frame {&frame-name}.
    return error.
  end.
  else do:
    if v-d-pcnt = ?
    or v-d-pcnt = 0 then do:
      message "Скидка для группы клиентов не установлена." view-as alert-box.
      display t-doc.discnt-type with frame {&frame-name}.
      return error.
    end.
  end.
  t-doc.discnt-pc = v-d-pcnt.
end.
assign t-doc.discnt-type.
run gbl/calc-trn.p (input parParentProc, input recid(t-doc)) no-error.
if error-status:error then return "error".
end procedure.

procedure mark-list:
  if not available gds-dtl then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i gds-dtl del-list }
  {&browse-name}:refresh() in frame {&frame-name} no-error .
  g#log = br-dtl:select-next-row () in frame {&frame-name}.
  apply "entry" to br-dtl in frame {&frame-name}.
end procedure.
procedure local-del:
do on stop undo, return error:
  if del-list = "" then do:
    /* удаление 1 строки */
    if not available gds-dtl then do:
      message "Неправильный выбор строки.".
      return error.
    end.
    g#log = no.
    message "Удалить строку накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then return error.
    assign
      prt-rec = recid (gds-dtl)
      del-list = string (recid (gds-dtl)).
    get next br-dtl.
    if available gds-dtl then rep-rec = recid (gds-dtl).
    else do:
      reposition br-dtl to recid prt-rec no-error.
      get prev br-dtl.
      rep-rec = recid (gds-dtl).
    end.
  end.
  else do:
    /* удаление отмеченных строк */
    g#log = no.
    message "УДАЛИТЬ  ВСЕ  ОТМЕЧЕННЫЕ  строки накладной ?   Вы уверены ?"
                    view-as alert-box question buttons ok-cancel update g#log.
    if not g#log then return error.
    rep-rec = ?.
  end.
  lns-cnt = 1.
  do while lns-cnt <= num-entries (del-list):
    assign
      prt-rec = integer (entry (lns-cnt, del-list))
      lns-cnt = lns-cnt + 1.
    find gds-dtl where recid (gds-dtl) = prt-rec exclusive.
    find ub.doc-line where ub.doc-line.doc-code = gds-dtl.doc-code
                          and ub.doc-line.prod-code = gds-dtl.prod-code
                          and ub.doc-line.prod-type = gds-dtl.prod-type
                          and ub.doc-line.artic     = gds-dtl.artic exclusive.

    define variable l-inv-on as logical no-undo .

    { gbl/gdsobjat.i
      ub.doc-line.obj-type
      ub.doc-line.obj-code
      ub.doc-line.artic
      ub.doc-line.prod-type
      ub.doc-line.prod-code
      "'inv-on=request'"
      l-inv-on
      no-error
    }
    if error-status :error then do:
      message
        "Ошибка получения признака товара на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    if l-inv-on then do:
      message
        "Товар в инвентаризации." skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        "Операция невозможна.".
      undo, return error.
    end.
    find goods where goods.prod-code = gds-dtl.prod-code
                 and goods.prod-type = gds-dtl.prod-type
                 and goods.artic     = gds-dtl.artic no-lock.
    run str/out-add.p
      (input parparentproc,
        input recid(t-doc),
        input recid(doc-line),
        input recid(gds-dtl),
        input recid(goods),
        input "delete",
        input ?
        ) no-error.
    if error-status:error then return error.
  end.
end. /* on stop */
end procedure.
procedure local-lookup:
assign
line-mode = {&lookup}
prt-mode  = {&lookup}.
find ub.doc-line where ub.doc-line.doc-code = t-doc.doc-code
                        and ub.doc-line.prod-code = gds-dtl.prod-code
                        and ub.doc-line.prod-type = gds-dtl.prod-type
                        and ub.doc-line.artic         = gds-dtl.artic no-lock.
find goods where goods.prod-code = gds-dtl.prod-code
                     and goods.prod-type = gds-dtl.prod-type
                     and goods.artic         = gds-dtl.artic no-lock.
run str/out-add.p (
    input parparentproc,
    input recid(t-doc),
    input recid(doc-line),
    input recid(gds-dtl),
    input recid(goods),
    input varline-mode,
    input ?
    )no-error.
    if error-status :error then return error return-value .
apply "entry" to br-dtl in frame {&frame-name}.
end procedure.


procedure set-work-mode-prt:
prt-rec = recid(gds-dtl).
find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                and ub.doc-line.prod-code = gds-dtl.prod-code
                and ub.doc-line.prod-type = gds-dtl.prod-type
                and ub.doc-line.artic     = gds-dtl.artic no-lock.
line-rec = recid (doc-line).
find goods where goods.prod-code = gds-dtl.prod-code
             and goods.prod-type = gds-dtl.prod-type
             and goods.artic     = gds-dtl.artic no-lock.
gds-rec = recid (goods).
find gds-prt where gds-prt.upper-code = goods.prt-root no-lock.
if gds-prt.node-name = {&empty-scale} then do:
  message "Товар :" goods.artic goods.gds-name "не делится на признаки - шкала недoступна.".
  return error.
end.
if doc-mode = {&lookup} then
  assign
    prt-mode  = {&lookup}
    line-mode = {&lookup}
    work-mode = "lookup-scale".
else do:
  define variable l-inv-on as logical no-undo .

  { gbl/gdsobjat.i
     ub.doc-line.obj-type
     ub.doc-line.obj-code
     ub.doc-line.artic
     ub.doc-line.prod-type
     ub.doc-line.prod-code
     "'inv-on=request'"
     l-inv-on
     no-error }
  if error-status :error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.

  if l-inv-on then do:
    message "Артикул :" ub.doc-line.artic goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  assign
    prt-mode  = {&prt-def}
    line-mode = {&update}
    work-mode = "update-scale".
end.
end procedure.

procedure local-check-gds:
  define variable l-inv-on as logical no-undo .

  { gbl/gdsobjat.i
    ub.doc-line.obj-type
    ub.doc-line.obj-code
    ub.doc-line.artic
    ub.doc-line.prod-type
    ub.doc-line.prod-code
    "'inv-on=request'"
    l-inv-on
    no-error }
  if error-status :error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return no-apply .
  end.

  if l-inv-on then do:
    message "Артикул :" ub.doc-line.artic goods.gds-name
                    "- товар в инвентаризации."
                    skip (2) "Операция невозможна.".
    return error.
  end.
  if t-doc.status_ = {&inquiry} then do:
    message "Документ имеет статус ЗАПРОС. Изменение партий невозможно.".
    return error.
  end.
end procedure.
procedure find-gds:
find bar-code where bar-code.b-code = b-c no-lock.
find goods where goods.gds-code = bar-code.gds-code no-lock.
assign gds-rec = recid(goods).
find first gds-dtl where
     gds-dtl.doc-code  = t-doc.doc-code     and
     gds-dtl.artic     = goods.artic     and
     gds-dtl.prod-type = goods.prod-type and
     gds-dtl.prod-code = goods.prod-code and
     gds-dtl.prt-code  = bar-code.node-code no-lock no-error.
if not available gds-dtl then do:
   message "В накладной не найден товар по данному бар-коду."
    view-as alert-box error buttons ok.
    return error.
end.
end procedure.
procedure add-rate:
reposition {&browse-name} to recid recid(gds-dtl).
display gds-dtl.fact-qnty + rate @ gds-dtl.fact-qnty with browse {&browse-name}.
end procedure.
procedure check-inv:
find ub.doc-line where ub.doc-line.doc-code         = t-doc.doc-code
                       and ub.doc-line.prod-code = gds-dtl.prod-code
                       and ub.doc-line.prod-type = gds-dtl.prod-type
                       and ub.doc-line.artic     = gds-dtl.artic no-lock.
line-rec = recid (doc-line).
find goods where goods.prod-code = gds-dtl.prod-code
             and goods.prod-type = gds-dtl.prod-type
             and goods.artic     = gds-dtl.artic no-lock.
define variable l-inv-on as logical no-undo .

 { gbl/gdsobjat.i
   ub.doc-line.obj-type
   ub.doc-line.obj-code
   ub.doc-line.artic
   ub.doc-line.prod-type
   ub.doc-line.prod-code
   "'inv-on=request'"
   l-inv-on
   no-error }
if error-status :error then do:
  message
    "Ошибка получения признака товара на объекте" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return no-apply .
end.

if l-inv-on then do:
  message "Артикул :" ub.doc-line.artic goods.gds-name
                  "- товар в инвентаризации."
                  skip (2) "Операция невозможна.".
  return error.
end.
end procedure.
procedure check-discnt:
g#log = no.
if input frame {&frame-name} t-doc.discnt-type = {&row} then
  if not v-cntxp-out-line-discnt then message "Скидки по строкам запрещены.".
  else message "Включение разных скидок по строкам. Вы уверены ?"
                          view-as alert-box question buttons ok-cancel update g#log.
  else message "Включение общей скидки для всего документа."
                        "Все скидки по строкам будут пересчитаны. Вы уверены ?"
                        view-as alert-box question buttons ok-cancel update g#log.
if g#log <> true then do:
  disp t-doc.discnt-type with frame {&frame-name}.
  return error.
end.
end procedure.
procedure local-parts:
do on error undo, return error return-value :
if doc-mode <> {&lookup} then do:
  run check-rate.
end.
find ub.doc-line where ub.doc-line.doc-code  = t-doc.doc-code
                and ub.doc-line.prod-code = gds-dtl.prod-code
                and ub.doc-line.prod-type = gds-dtl.prod-type
                and ub.doc-line.artic     = gds-dtl.artic .
find goods where goods.prod-code = gds-dtl.prod-code
             and goods.prod-type = gds-dtl.prod-type
             and goods.artic     = gds-dtl.artic      no-lock.
if doc-mode = {&lookup} then do:
  assign
    work-mode = "lookup-parts".
end.
else do:
  run local-check-gds.
  assign
    work-mode = "update-parts".
end.
run str/out-add.p
    (input parparentproc,
      input recid(t-doc),
      input recid(doc-line),
      input recid(gds-dtl),
      input recid(goods),
      input work-mode,
      input ?
      ).
end.
end procedure.

procedure chk-upd-date:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
{ gbl/curobjdt.i store-type store-code v-today }
if input frame {&frame-name} t-doc.fact-date > v-today then do:
   message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
   display t-doc.fact-date with frame {&frame-name}.
   return error.
end.
if input frame {&frame-name} t-doc.fact-date < v-today - 7 then do:
   g#log = yes.
   message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
           "Отказаться от заведения даты?" view-as alert-box question
           buttons yes-no update g#log.
   if g#log then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
end.
if input frame {&frame-name} t-doc.fact-date <> t-doc.fact-date then do:
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .

      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input {&attr-nakl_par}
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame {&frame-name}.
      return error.
    end.


   g#log = no.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_expense_add-back-date':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      true
      g#log
    }
   if g#log = no then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
   g#log = no.
   message "Вы хотите изменить фактическую дату?" skip
           "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
   view-as alert-box question buttons yes-no update g#log.
   if not g#log then do:
      display t-doc.fact-date with frame {&frame-name}.
      return error.
   end.
   assign t-doc.fact-time = (24 * 60 * 60).
end.

end procedure.

procedure local-cur:
define input parameter parwith-tax as integer no-undo.
define buffer cur-doc-line  for ub.doc-line.
define buffer cur-goods     for ub.goods.
define buffer cur-gds-dtl   for ub.gds-dtl.
define variable varpc       as decimal no-undo.
define variable varflag-ret as logical no-undo.
define variable round-base   as decimal no-undo. /* база для округления / коэффициент */
define variable round-method as char    no-undo. /* способ округления */
define variable varnew-price like ub.doc-line.price-base no-undo.

define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
/*define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.*/
/*define variable v-have-slt-pc   as logical              no-undo.*/
define variable v-host-code     like ub.sysconf.host-code  no-undo.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_expense_price':U
      {&cntxt-object}
      t-doc.host-code
      t-doc.obj-type
      t-doc.obj-code
      0
      0
      0
      true
      g#log
    }
   if g#log = no then return error.

   assign varpc       = 0.00
          varflag-ret = no
          .
   if parwith-tax <> 3 then do:
     run str/pc-ov.w (input  parwith-tax,
                  output varpc,
                  output varflag-ret,
                  output round-base,
                  output round-method) no-error.
     if error-status:error or
        varflag-ret <> yes then return error.
   end.
   run waitfram-show in this-procedure  ("Простановка учетных цен").
   tr:
   do transaction:
   for each  cur-doc-line where cur-doc-line.doc-code   = t-doc.doc-code         ,
       first cur-goods    where cur-goods.artic         = cur-doc-line.artic     and
                                cur-goods.prod-type     = cur-doc-line.prod-type and
                                cur-goods.prod-code     = cur-doc-line.prod-code no-lock,
       each  cur-gds-dtl  where cur-gds-dtl.doc-code    = cur-doc-line.doc-code  and
                                cur-gds-dtl.artic       = cur-doc-line.artic     and
                                cur-gds-dtl.prod-type   = cur-doc-line.prod-type and
                                cur-gds-dtl.prod-code   = cur-doc-line.prod-code no-lock:

       assign
       line-rec = recid(cur-doc-line)
       gds-rec  = recid(cur-goods)
       prt-rec  = recid(cur-gds-dtl).
       { str/in-vatp.i calc cur-doc-line. t-doc. g }

       { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-host-code }
       { gbl/pftxvalg.i cur-goods.gds-code {&vat-tax-code} ? v-host-code t-doc.obj-type t-doc.obj-code v-vat-pc no-error }
       case parwith-tax:
       when 1 then do:
         assign varnew-price = (if t-doc.print-rubl then ((price-rubl-with-tax-loc - road-tax-rubl-loc - vat-rubl-loc) * (100 + varpc) / 100 * (100 + v-vat-pc) / 100 + road-tax-rubl-loc)
                                                    else ((price-base-with-tax-loc - road-tax-base-loc - vat-base-loc) * (100 + varpc) / 100 * (100 + v-vat-pc) / 100 + road-tax-base-loc)).
       end.
       when 2 then do:
         assign varnew-price = (if t-doc.print-rubl then price-rubl-with-tax-loc * (100 + varpc) / 100
                                                    else price-base-with-tax-loc * (100 + varpc) / 100).
       end.
       when 3 then do:
         assign varnew-price = (if t-doc.print-rubl then (price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc)
                                                    else (price-base-with-tax-loc - vat-base-loc - slt-base-loc)).
       end.
       end case.
       /*округление*/
       if parwith-tax <> 3 then do:
         { str/pr-99.i varnew-price round-method round-base}
       end.
       run str/out-add.p
            (input parparentproc,
            input recid(t-doc),
            input recid(cur-doc-line),
            input recid(cur-gds-dtl),
            input recid(cur-goods),
            input "update-sale-price",
            input string(varnew-price)
            ) no-error.
       if error-status:error then do:
          message "Ошибка при вызове программы out-add.p" view-as alert-box.
          run waitfram-hide in this-procedure  .
          undo tr, return error.
       end.
       if parwith-tax = 3 then do:
         assign
           cur-doc-line.vat-pc = 0
           cur-doc-line.slt-pc = 0.
       end.

       run waitfram-show in this-procedure  ("Простановка учетных цен по товару " + string(cur-goods.artic) + " " +
                        string(cur-goods.prod-type) + " " + string(cur-goods.prod-code)).
   end.
   if parwith-tax = 3 then do:
     run gbl/calc-trn.p (input parParentProc, input recid (t-doc)).
     run ui-on ("line").
   end.
   end.
   run waitfram-hide .

end procedure.

&undefine gds-list_i_def
{ cmp/gds-list.i tt-gds-list def  }
procedure copy-lst :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define input parameter parcash-pay like ub.sysconf.cash-pay no-undo.
define input parameter pardoc-prt  as   logical             no-undo.
define input parameter table for tt-gds-list.

define variable chg-qnty     like ub.gds-dtl.doc-qnty  no-undo.
define variable legal-node   like ub.gds-prt.node-code no-undo.
define buffer cpl_goods    for ub.goods.
define buffer cpl_gds-obj  for ub.gds-obj.
define buffer cpl_prt-obj  for ub.prt-obj.
define buffer cpl_trn-doc  for ub.trn-doc.
define buffer cpl_gds-prt  for ub.gds-prt.
define buffer cpl_gds-dtl  for ub.gds-dtl.
define buffer cpl_doc-line for ub.doc-line.
define variable varcount    as integer no-undo.
define variable varchg-qnty like ub.gds-dtl.doc-qnty no-undo.
define variable vardoc-qnty like ub.gds-dtl.doc-qnty no-undo.
c-l:
do on error undo c-l, return error :
find first cpl_trn-doc where cpl_trn-doc.doc-code = pardoc-code.
r-l:
for each tt-gds-list,
     each cpl_goods where cpl_goods.prod-type = tt-gds-list.prod-type
                      and cpl_goods.prod-code = tt-gds-list.prod-code
                      and cpl_goods.artic     = tt-gds-list.artic     no-lock :
  assign varcount = varcount + 1.
  if varcount modulo 100 = 0 then do:
    run waitfram-show in this-procedure  ("ЖДИТЕ.  Обработано строк списка : " + string (varcount)).
  end.
  find cpl_gds-obj where cpl_gds-obj.obj-type  = cpl_trn-doc.obj-type
                     and cpl_gds-obj.obj-code  = cpl_trn-doc.obj-code
                     and cpl_gds-obj.prod-type = cpl_goods.prod-type
                     and cpl_gds-obj.prod-code = cpl_goods.prod-code
                     and cpl_gds-obj.artic     = cpl_goods.artic    no-lock no-error.
  if not available cpl_gds-obj or cpl_gds-obj.fact-qnty = 0 then next r-l.
  { str/crdoclno.i
   cpl_trn-doc.doc-code
   cpl_trn-doc.obj-type
   cpl_trn-doc.obj-code
   cpl_goods.artic
   cpl_goods.prod-type
   cpl_goods.prod-code
   cpl_goods.gds-name
   cpl_goods.prt-root
   ?
   ?
   parcash-pay
   no-error }
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании строки." skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first cpl_doc-line where cpl_doc-line.doc-code  = cpl_trn-doc.doc-code and
                                cpl_doc-line.artic     = cpl_goods.artic      and
                                cpl_doc-line.prod-type = cpl_goods.prod-type  and
                                cpl_doc-line.prod-code = cpl_goods.prod-code .
  find first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_goods.prt-root no-lock.
  for each cpl_prt-obj where cpl_prt-obj.obj-type  = cpl_trn-doc.obj-type
                         and cpl_prt-obj.obj-code  = cpl_trn-doc.obj-code
                         and cpl_prt-obj.artic     = cpl_goods.artic
                         and cpl_prt-obj.prod-type = cpl_goods.prod-type
                         and cpl_prt-obj.prod-code = cpl_goods.prod-code
                         and cpl_prt-obj.fact-qnty > 0              no-lock :
    if (pardoc-prt and not can-find (first cpl_gds-prt where cpl_gds-prt.upper-code = cpl_prt-obj.prt-code no-lock))
       /* узел терминальный и признаки включены */ or
       (not pardoc-prt and cpl_prt-obj.prt-code = cpl_gds-prt.node-code)
       /* узел корневой и признаки выключены */ then do:
      assign legal-node = cpl_prt-obj.prt-code.
      { str/crgdsdtl.i
        cpl_trn-doc.obj-code
        cpl_trn-doc.obj-type
        cpl_trn-doc.doc-code
        cpl_goods.artic
        cpl_goods.prod-code
        cpl_goods.prod-type
        legal-node
        yes
        no-error }
      if error-status:error then do:
         return error substitute("Ошибка при создании признака &1.", return-value).
      end.
      find first cpl_gds-dtl where cpl_gds-dtl.doc-code  = cpl_trn-doc.doc-code and
                                   cpl_gds-dtl.artic     = cpl_goods.artic      and
                                   cpl_gds-dtl.prod-code = cpl_goods.prod-code  and
                                   cpl_gds-dtl.prod-type = cpl_goods.prod-type  and
                                   cpl_gds-dtl.prt-code  = legal-node.
      assign
        cpl_gds-dtl.ov  = no.
      /* подстановка цены, в т.ч. возврат поставщику или перемещение по цене магазина */
      /* если ошибка при установке цены переходим к следующему товару                 */
      { str/set-pr.i recid(cpl_gds-dtl) no ? no-error }
      if error-status:error then undo, next r-l.
      assign
        chg-qnty = cpl_prt-obj.fact-qnty.
      run trg/rsrv-dtl.p (input parParentProc, {&rsrv-dtl_action_reserv}, buffer cpl_gds-dtl, input-output chg-qnty, input-output cpl_doc-line.price-base, input-output cpl_doc-line.price-rubl, -1, "") no-error.
      if error-status:error then undo c-l, return error.
      assign
        cpl_doc-line.doc-qnty  = cpl_doc-line.doc-qnty + chg-qnty
        cpl_gds-dtl.doc-qnty   = cpl_gds-dtl.doc-qnty  + chg-qnty
        cpl_gds-dtl.fact-qnty  = cpl_gds-dtl.doc-qnty
        cpl_doc-line.fact-qnty = cpl_doc-line.doc-qnty.
      /* считаем суммарное количество, которое удалось скопировать */
      assign
        varchg-qnty = varchg-qnty + chg-qnty
        vardoc-qnty = vardoc-qnty + cpl_gds-dtl.doc-qnty.
      if cpl_gds-dtl.doc-qnty = 0 then delete cpl_gds-dtl.
    end.
  end.
end.
end.

if varchg-qnty > 0 then do:
  if varchg-qnty = vardoc-qnty then do:
    message "Все ФАКТ количества по списку товаров добавлены в документ успешно !".
  end.
  else do:
    message "Внимание !!!" skip (2)
                    "НЕ ВСЕ ФАКТ количество УДАЛОСЬ добавить в заполняемый документ !" skip (2)
                    "Общее количество в по списку на объекте : " varchg-qnty skip
                    "Удалось добавить в документ : " vardoc-qnty.
  end.
end.
end procedure.
procedure local-add :
define buffer bf_contract-specif for ub.contract-specif.
define buffer bf-hv_doc-line     for ub.doc-line.
define buffer bf_goods           for ub.goods.
define variable varlog      as   logical                    no-undo.
do on error undo, return error return-value
:
run check-rate no-error.
if error-status:error then do:
  message "Ошибка при проверке курса валют." skip
          return-value
  view-as alert-box error.
  return error return-value.
end.
v-cond       = {&free}
.
if t-doc.contract-code <> 0 then do:
  find first bf_contract-specif where bf_contract-specif.host-code    = t-doc.cli-code      and
                                      bf_contract-specif.contract-num = t-doc.contract-code no-lock no-error.
end.
if t-doc.contract-code <> 0     and
   available bf_contract-specif then do:
   assign
     varlog = yes.
   message "Вы хотите добавить все недобавленые товары по спецификации?"
   view-as alert-box question buttons yes-no update varlog.
end.
if t-doc.contract-code <> 0     and
   available bf_contract-specif and
   varlog                       then do:
  for each bf_contract-specif where bf_contract-specif.host-code    = t-doc.cli-code      and
                                    bf_contract-specif.contract-num = t-doc.contract-code no-lock on error undo, return error return-value :
    find first bf_goods where bf_goods.gds-code = bf_contract-specif.gds-code no-lock.
    find first bf-hv_doc-line where bf-hv_doc-line.doc-code  = t-doc.doc-code     and
                                    bf-hv_doc-line.artic     = bf_goods.artic     and
                                    bf-hv_doc-line.prod-type = bf_goods.prod-type and
                                    bf-hv_doc-line.prod-code = bf_goods.prod-code no-lock no-error.
    if not available bf-hv_doc-line then do:
      assign
        notes = notes + (if notes = '':u then '':u else ',':u) + string(recid(bf_goods)).
    end.
  end.
  if notes = '':u then do:
    message "Вы добавили уже все товары по спецификации."
    view-as alert-box.
    return error.
  end.
end.
else do:
  run str/flornakl.p (input parParentProc ,  input "", input t-doc.doc-code , output v-exist , output v-buket-gds-code ) .
  run str/chs-gds.w ( input parparentproc
                 ,input t-doc.obj-type
                 ,input t-doc.obj-code
                 ,input '':U /*если флористы нужнос вставить {&is-flor}*/
                 ,input '':U /*если флористы нужнос вставить {&is-flor}*/
                 ,input (if v-exist
                  then "Для нетоварной позиции"
                  else "Строка накладной № " + t-doc.doc-code)
                 ,input v-cond            /* режим вызова справочника */
                 ,input t-doc.cli-type
                 ,input t-doc.cli-code
                 ,input t-doc.host-code
                 ,input t-doc.ext-doc-type
                 ,input-output varartic
                 ,output notes).
end.
if notes = '' then return.
assign
  line-mode = {&add-def}
  lns-cnt = 1.
do while lns-cnt <= num-entries (notes):
  assign
    gds-rec = integer (entry (lns-cnt, notes))
    lns-cnt = lns-cnt + 1.

  v-param = if v-exist then string(v-buket-gds-code)
              else ? .
  run str/out-add.p
     (input parparentproc,
      input recid(t-doc),
      input ?,
      input ?,
      input gds-rec,
      input {&add-def},
      input v-param
      ) no-error.
  if error-status:error then do:
    next.
  end.

end.
/* в ui-on давятся пустые ub.doc-line */
run ui-on ("line").
if prt-rec <> ? then do:
  reposition br-dtl to recid prt-rec no-error.
end.
end.
end procedure.
procedure val-chg-is-repay :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-repay <> input frame {&frame-name} is-repay then do:
    if input frame {&frame-name} is-repay = no and
       is-cons    = no and
       is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-repay with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-repay.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.
end procedure.

procedure val-chg-is-cons :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-cons <> input frame {&frame-name} is-cons then do:
    if is-repay = no and
       input frame {&frame-name} is-cons = no and
       is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-cons with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-cons.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.
end procedure.

procedure val-chg-is-storage :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-storage <> input frame {&frame-name} is-storage then do:
    if is-repay = no and
       is-cons = no and
       input frame {&frame-name} is-storage = no and
       is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-storage with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-storage.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.
end procedure.

procedure val-chg-is-oldcons :
define variable varstring as character no-undo.
do on error undo, return error return-value :
  if is-oldcons <> input frame {&frame-name} is-oldcons then do:
    if is-repay = no and
       is-cons = no and
       is-storage = no and
       input frame {&frame-name} is-oldcons = no then do:
       message "Не выбран ни один тип приобретения." view-as alert-box.
       display is-oldcons with frame {&frame-name}.
    end.
    assign
      frame {&frame-name} is-oldcons.

    assign
      varstring = "":u
    .
    if is-repay = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&repayment-code}.
    end.
    if is-cons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&consignation-code}.
    end.
    if is-storage = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&responsible-storage-code}.
    end.
    if is-oldcons = yes then do:
      assign
        varstring = varstring + (if varstring = "":u then "":u else ",":u) + {&old-consignation-code}.
    end.

    { str/tdat-wrt.i
        t-doc.doc-code
        {&trdcattr-purchcodelist}
        varstring
    }
  end.
end.
end procedure.

procedure cr-tt-upd:
do on error undo, return error return-value :
define variable v-other as character   no-undo.

for each tt-upd-attr : delete tt-upd-attr . end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
run attr-property in this-procedure ( ~
 input  tt-upd-attr.code          ,   ~
 output tt-upd-attr.type-attr     ,   ~
 output tt-upd-attr.format-attr   ,   ~
 output tt-upd-attr.fillin_width  ,   ~
 output tt-upd-attr.fillin_height ,   ~
 output tt-upd-attr.label-attr    ,   ~
 output tt-upd-attr.user-can-edit ,   ~
 output tt-upd-attr.output-display,   ~
 output v-other                   ,   ~
 output tt-upd-attr.proc-attr         ~
 ) no-error.                          ~
 if error-status :error then do:      ~
   return error. ~
 end.

&scop attr-code trdcattr-ord_time
{&create-record}
&scop attr-code trdcattr-frsrv-date
{&create-record}
&scop attr-code trdcattr-befpay
{&create-record}
&scop attr-code trdcattr-ord_Nchek
{&create-record}
&scop attr-code trdcattr-dchek
{&create-record}
&scop attr-code trdcattr-deliv
{&create-record}
&scop attr-code trdcattr-sumwrk
{&create-record}
/*
&scop attr-code trdcattr-sumsrk
{&create-record}
*/
&scop attr-code trdcattr-ord_adr
{&create-record}
&scop attr-code trdcattr-ord_hwo
{&create-record}
&scop attr-code trdcattr-ord_contact
{&create-record}
&scop attr-code trdcattr-ord_phone
{&create-record}
&scop attr-code trdcattr-ord_dl
{&create-record}
&scop attr-code trdcattr-print-num
{&create-record}
&scop attr-code trdcattr-idCountryContr
{&create-record}
&scop attr-code trdcattr-auto
{&create-record}
&scop attr-code trdcattr-cargo-desc
{&create-record}
&scop attr-code trdcattr-carry-type
{&create-record}
&scop attr-code trdcattr-cargo-mass
{&create-record}
&scop attr-code trdcattr-exp-trans
{&create-record}
&scop attr-code trdcattr-zakaz-number
{&create-record}


end.
end procedure.

procedure init-attr-flora:
do on error undo, return error return-value :

run cr-tt-upd in this-procedure no-error.

define variable varexist                  as logical   no-undo.

&scop create-record run create-record in this-procedure (  input t-doc.doc-code ~
                                                        ,  input ~{&~{&attr-code~}~} ~
                                                        ,  input ~{&attr-val~} ~
                                                        , output varexist ). ~


&scop attr-val  ""
&scop attr-code trdcattr-frsrv-date
{&create-record}
&scop attr-code trdcattr-ord_time
{&create-record}
&scop attr-code trdcattr-befpay
{&create-record}
&scop attr-code trdcattr-ord_Nchek
{&create-record}
&scop attr-code trdcattr-deliv
{&create-record}
&scop attr-code trdcattr-sumwrk
{&create-record}
/*
&scop attr-code trdcattr-sumsrk
{&create-record}
*/
&scop attr-code trdcattr-ord_contact
{&create-record}
&scop attr-code trdcattr-ord_phone
{&create-record}
&scop attr-code trdcattr-ord_dl
{&create-record}
&scop attr-code trdcattr-print-num
{&create-record}    
&scop attr-code trdcattr-idCountryContr
{&create-record}
&scop attr-code trdcattr-auto
{&create-record}
&scop attr-code trdcattr-cargo-desc
{&create-record}
&scop attr-code trdcattr-carry-type
{&create-record}
&scop attr-code trdcattr-cargo-mass
{&create-record}
&scop attr-code trdcattr-exp-trans
{&create-record}
&scop attr-code trdcattr-zakaz-number
{&create-record}


define buffer buf_clients for ub.clients.
define buffer buf_person  for ub.person.
define buffer buf_firm    for ub.firm.
define variable v-adr as character no-undo init "" .
define variable v-h   as character no-undo init "" .
find first buf_clients no-lock where
           buf_clients.obj-code =  t-doc.cli-code  and
           buf_clients.obj-type =  t-doc.cli-type    no-error .
if  available buf_clients then do:
  v-h = buf_clients.obj-name .
  if t-doc.cli-type = {&cmp} then do:
    find first buf_firm no-lock where buf_firm.firm-code = t-doc.cli-code no-error .

     v-adr = buf_firm.post-addr1 + " " + buf_firm.contact-psn.
    end.
    else do:
    find first buf_person no-lock where buf_person.psn-code = t-doc.cli-code no-error .
    v-adr = string(buf_person.ind) + " " + buf_person.city + " " + buf_person.address .
    end.
end.

&scop attr-val  string(t-doc.doc-date)
&scop attr-code trdcattr-dchek
{&create-record}


&scop attr-val  v-adr
&scop attr-code trdcattr-ord_adr
{&create-record}

&scop attr-val  v-h
&scop attr-code trdcattr-ord_hwo
{&create-record}

end.
end procedure.

procedure init-attr-general:
/* Атрибуты расходного документа */
do on error undo, return error return-value :
run cr-tt-upd-general .
define variable varexist                  as logical   no-undo.

&scop create-record run create-record in this-procedure (  input t-doc.doc-code ~
                                                        ,  input ~{&~{&attr-code~}~} ~
                                                        ,  input ~{&attr-val~} ~
                                                        , output varexist ). ~


&scop attr-val  ""
&scop attr-code trdcattr-qntyplace
{&create-record}
&scop attr-code trdcattr-auto
{&create-record}
&scop attr-code trdcattr-cargo-desc
{&create-record}
&scop attr-code trdcattr-carry-type
{&create-record}
&scop attr-code trdcattr-cargo-mass
{&create-record}
&scop attr-code trdcattr-exp-trans
{&create-record}
&scop attr-code trdcattr-zakaz-number
{&create-record}

end.
end procedure.

procedure cr-tt-upd-general:
do on error undo, return error return-value :
define variable v-other as character   no-undo.

for each tt-upd-attr : delete tt-upd-attr . end.

&scop create-record create tt-upd-attr. ~
 assign~
  tt-upd-attr.code =  ~{&~{&attr-code~}~}  . ~
                                        ~
run attr-property in this-procedure ( ~
  input tt-upd-attr.code          ,   ~
 output tt-upd-attr.type-attr     ,   ~
 output tt-upd-attr.format-attr   ,   ~
 output tt-upd-attr.fillin_width  ,   ~
 output tt-upd-attr.fillin_height ,   ~
 output tt-upd-attr.label-attr    ,   ~
 output tt-upd-attr.user-can-edit ,   ~
 output tt-upd-attr.output-display,   ~
 output v-other                   ,   ~
 output tt-upd-attr.proc-attr         ~
 ) no-error.                          ~
 if error-status :error then do:      ~
   return error. ~
 end.

&scop attr-code trdcattr-qntyplace
{&create-record}
&scop attr-code trdcattr-auto
{&create-record}
&scop attr-code trdcattr-cargo-desc
{&create-record}
&scop attr-code trdcattr-carry-type
{&create-record}
&scop attr-code trdcattr-cargo-mass
{&create-record}
&scop attr-code trdcattr-exp-trans
{&create-record}
&scop attr-code trdcattr-zakaz-number
{&create-record}


end.
end procedure.

procedure cr-tt-posy:
do on error undo, return error return-value :

for each tt-posy : delete tt-posy . end.

define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_goods         for ub.goods.

 for each buf_doc-line-attr no-lock where
          buf_doc-line-attr.doc-code = t-doc.doc-code and
          buf_doc-line-attr.attr-code = {&lineattr-flora_ps} :
          find first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code no-error .
     if available buf_goods then do:
          create tt-posy.
          assign
            tt-posy.gds-code   = buf_doc-line-attr.gds-code
            tt-posy.gds-name   = buf_goods.gds-name
            tt-posy.gds-dopinf = buf_doc-line-attr.attr-value
          .

     end.
 end.

    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-sumwrk}
        pr-wrk
        p-type
    }
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-sumsrk}
        pr-srk
        p-type
    }
assign
v-pr-wrk = decimal(pr-wrk)
v-pr-srk = decimal(pr-srk)
.

end.
end procedure.

procedure cr-tt-flor:
do on error undo, return error return-value :
define buffer buf_doc-line-attr for ub.doc-line-attr.

for each tt-flor : delete tt-flor . end.
 for each buf_doc-line-attr no-lock where
          buf_doc-line-attr.doc-code = t-doc.doc-code and
          buf_doc-line-attr.gds-code > 0 and
          entry ( 1 , buf_doc-line-attr.attr-code) = {&lineattr-flora_gds-code}
          :
          if int(entry ( 3 , buf_doc-line-attr.attr-code)) > 0 then do:
              create tt-flor.
              assign
                tt-flor.gds-code-posy = int(entry ( 3 , buf_doc-line-attr.attr-code))
                tt-flor.gds-code      = buf_doc-line-attr.gds-code
                tt-flor.prt-code      = int(entry ( 2 , buf_doc-line-attr.attr-code))
                tt-flor.fact-qnty     = decimal(buf_doc-line-attr.attr-value)
              .

          end.
 end.


end.
end procedure.

procedure re-disp :

  do
  on error undo, return error return-value
  :

define variable v-itogo-base as decimal   no-undo .
define variable v-itogo-rubl as decimal   no-undo .
define variable v-itogo-base2 as decimal   no-undo .
define variable v-itogo-rubl2 as decimal   no-undo .
define variable v-sum-with-disc-rubl as decimal   no-undo .
define variable v-sum-with-disc-base as decimal   no-undo .
define buffer tt2-goods   for ub.goods   .
define buffer tt2-gds-dtl for ub.gds-dtl .

define variable pr-srk     as character no-undo .
define variable dost-rubl  as decimal   no-undo .
define variable dost-base  as decimal   no-undo .
define variable p-type     as character no-undo   .
define variable v-dost     as character no-undo .

{ str/tdat-val.i
    t-doc.doc-code
    {&trdcattr-deliv}
    v-dost
    p-type
}
     dost-rubl = decimal(v-dost).
     if dost-rubl = ? then dost-rubl = 0.
     dost-base = dost-rubl  * t-doc.base-scale / t-doc.base-rate.


define variable v-pr as decimal   no-undo .
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-sumwrk}
        pr-srk
        p-type
    }
v-pr-wrk = decimal(pr-srk).

v-pr = v-pr-wrk + v-pr-srk .

  assign
    ii-sum-rubl = 0
    ii-sum-base = 0
  .

for each  tt-posy :

assign
  v-itogo-base = 0
  v-itogo-rubl = 0
.

define buffer buf_gds-dtl for ub.gds-dtl.
define buffer b_doc-line for ub.doc-line.

   for each  b_doc-line  where b_doc-line.doc-code         = t-doc.doc-code :
    find first  buf_gds-dtl  where buf_gds-dtl.doc-code  = t-doc.doc-code
                              and b_doc-line.prod-code = buf_gds-dtl.prod-code
                              and b_doc-line.prod-type = buf_gds-dtl.prod-type
                              and b_doc-line.artic     = buf_gds-dtl.artic no-lock no-error .

              if not available  buf_gds-dtl then do:
                  message 123 "bed".
                  delete b_doc-line .
              end.
   end.



   for each tt-flor where tt-flor.gds-code-posy  = tt-posy.gds-code :
       find first tt2-goods no-lock where tt2-goods.gds-code = tt-flor.gds-code no-error .
       find first tt2-gds-dtl no-lock where
                  tt2-gds-dtl.doc-code  = t-doc.doc-code and
                  tt2-gds-dtl.artic     = tt2-goods.artic and
                  tt2-gds-dtl.prod-type = tt2-goods.prod-type and
                  tt2-gds-dtl.prod-code = tt2-goods.prod-code and
                  tt2-gds-dtl.prt-code  = tt-flor.prt-code  no-error .
    IF t-doc.status_ = {&fact} THEN DO:
      if  available tt2-gds-dtl then
      assign
        v-itogo-base = ((tt2-gds-dtl.price-base  - tt2-gds-dtl.discnt-base) * tt-flor.fact-qnty )  + v-itogo-base
        v-itogo-rubl = ((tt2-gds-dtl.price-rubl  - tt2-gds-dtl.discnt-rubl) * tt-flor.fact-qnty )  + v-itogo-rubl
    .
    end.
    else do:
      if  available tt2-gds-dtl then
      assign
        v-itogo-base = (tt2-gds-dtl.price-base      * tt-flor.fact-qnty)  + v-itogo-base
        v-itogo-rubl = (tt2-gds-dtl.price-rubl      * tt-flor.fact-qnty)  + v-itogo-rubl
    .
    end.
   end.

    assign
      v-itogo-base2 = v-itogo-base - (v-itogo-base * t-doc.discnt-pc / 100 )
      v-itogo-rubl2 = v-itogo-rubl - (v-itogo-rubl * t-doc.discnt-pc / 100 )
    .

    IF t-doc.status_ = {&fact} THEN DO:
      assign
        v-sum-with-disc-base = v-itogo-base
        v-sum-with-disc-rubl = v-itogo-rubl
      .
    END.
    ELSE DO:
      assign
        v-sum-with-disc-base = v-itogo-base2 +  ( v-pr * v-itogo-base2 / 100 )
        v-sum-with-disc-rubl = v-itogo-rubl2 +  ( v-pr * v-itogo-rubl2 / 100 )
      .
    END.
    assign
      tt-posy.sum-base = v-sum-with-disc-base
      tt-posy.sum-rubl = v-sum-with-disc-rubl
      ii-sum-base = tt-posy.sum-base + ii-sum-base
      ii-sum-rubl = tt-posy.sum-rubl + ii-sum-rubl
    .
end.
{&open-query-br-posy}.
apply "value-changed" to br-posy in frame {&frame-name}.

define variable var-sym-i-s-dost-rubl as decimal   no-undo .
define variable var-sym-i-s-dost-base as decimal   no-undo .


 if t-doc.status_ = {&fact} then do:
    display
      string(t-doc.tot-fact - (t-doc.discnt-rubl * t-doc.base-scale / t-doc.base-rate) , ">>>,>>>,>>9.99")  @ i-sum-base
      string(t-doc.tot-sale - t-doc.discnt-rubl                                        , ">>>,>>>,>>9.99")  @ i-sum-rubl
      with frame {&frame-name} .
      var-sym-i-s-dost-base = t-doc.tot-fact - (t-doc.discnt-rubl * t-doc.base-scale / t-doc.base-rate) .
      var-sym-i-s-dost-rubl = t-doc.tot-sale - t-doc.discnt-rubl .
      end.
else  do:
      display
      string(ii-sum-rubl , ">>>,>>>,>>9.99") @ i-sum-rubl
      string(ii-sum-base, ">>>,>>>,>>9.99") @ i-sum-base
      with frame {&frame-name} .
      var-sym-i-s-dost-base = (ii-sum-base) + dost-base .
      var-sym-i-s-dost-rubl = (ii-sum-rubl) + dost-rubl .

  if doc-mode <> {&lookup} then do:
     define variable vv1 as character no-undo .
     define variable vv2 as character no-undo .
     { str/tdat-val.i
         t-doc.doc-code
         {&trdcattr-discnt-stop}
         vv1
         vv2
     }
     { str/tdat-wrt.i
         t-doc.doc-code
         {&trdcattr-discnt-stop}
         "string( ii-sum-rubl + dost-rubl )"
     }
     { str/tdat-val.i
         t-doc.doc-code
         {&trdcattr-discnt-stop}
         vv1
         vv2
     }
  end.
end.

define variable v-var-t1 as decimal   no-undo .
define variable v-var-t2 as decimal   no-undo .
v-var-t1 = var-sym-i-s-dost-base - dost-base         .
v-var-t2 = var-sym-i-s-dost-rubl - dost-rubl         .

define variable v-var-s1 as decimal   no-undo .
define variable v-var-s2 as decimal   no-undo .
v-var-s1 = t-doc.discnt-pc * v-var-t1 / ( 100 - t-doc.discnt-pc ).
v-var-s2 = t-doc.discnt-pc * v-var-t2 / ( 100 - t-doc.discnt-pc ) .

display
(v-var-s1 + v-var-t1) * 100 / ( 100 + v-pr )   @  sum-base
(v-var-s2 + v-var-t2) * 100 / ( 100 + v-pr )   @  sum-rubl

v-var-s1 + v-var-t1  @  sum-base-n
v-var-s2 + v-var-t2  @  sum-rubl-n

v-var-s1  @  t-doc.tot-calc
v-var-s2  @  t-doc.discnt-rubl

v-var-t1  @  fact-base
v-var-t2  @  fact-rubl

var-sym-i-s-dost-base   @  d-sum-base
var-sym-i-s-dost-rubl   @  d-sum-rubl

with frame {&frame-name} .

run re-ver in this-procedure .

end.
end procedure. /* re-disp */

procedure re-ver :

  do
  on error undo, return error return-value
  :
  if doc-mode = {&lookup} then return .
    define buffer buf_line-attr for ub.doc-line-attr.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer buf_gds-dtl   for ub.gds-dtl.
    define buffer buf_goods     for ub.goods.

    for each tt-1 : delete tt-1. end.

    for each buf_line-attr no-lock where
             buf_line-attr.doc-code  = t-doc.doc-code    and
             buf_line-attr.attr-code begins {&lineattr-flora_gds-code} + {&comma-char}
             :
    if  entry ( 1 , buf_line-attr.attr-code ) <> {&lineattr-flora_gds-code}  then next.

    find first tt-1 where
       tt-1.gds-code = buf_line-attr.gds-code and
       tt-1.prt-code = int(entry ( 2 , buf_line-attr.attr-code )  )     no-error .

       if available tt-1 then do:
        assign
          tt-1.gds-code = buf_line-attr.gds-code
          tt-1.prt-code = int(entry ( 2 , buf_line-attr.attr-code ))
          tt-1.fact-qnty = tt-1.fact-qnty + decimal(buf_line-attr.attr-value )
        .

       end.
       else do:
        create tt-1.
          assign
            tt-1.gds-code  = buf_line-attr.gds-code
            tt-1.prt-code  =int( entry ( 2 , buf_line-attr.attr-code ))
            tt-1.fact-qnty = decimal(buf_line-attr.attr-value )
          .
       end.
    end.

for each  buf_doc-line exclusive-lock where
          buf_doc-line.doc-code = t-doc.doc-code :
          find first buf_gds-dtl no-lock  where
                    buf_gds-dtl.artic      = buf_doc-line.artic
                and buf_gds-dtl.prod-code  = buf_doc-line.prod-code
                and buf_gds-dtl.prod-type  = buf_doc-line.prod-type
                and buf_gds-dtl.doc-code  = t-doc.doc-code no-error .

  if not available buf_gds-dtl then message "bed" .

end.


for each  buf_gds-dtl exclusive-lock where
          buf_gds-dtl.doc-code = t-doc.doc-code :


     find first buf_goods no-lock  where
                buf_goods.artic       = buf_gds-dtl.artic
            and buf_goods.prod-code  = buf_gds-dtl.prod-code
            and buf_goods.prod-type  = buf_gds-dtl.prod-type no-error .
    if buf_gds-dtl.fact-qnty > buf_gds-dtl.doc-qnty and t-doc.status_ = {&permitted} then do:
       message "Фактическое количество товара не может быть больше количества по накладной."skip
                "Артикул :" buf_goods.artic    skip
                "Товар   :" buf_goods.gds-name   skip
                "Количество Фактическое  :" buf_gds-dtl.fact-qnty skip
                "Количество по документу :" buf_gds-dtl.doc-qnty skip
                view-as alert-box error .
    end.

       find first buf_doc-line no-lock  where
                              buf_goods.artic   = buf_doc-line.artic
                       and buf_goods.prod-code  = buf_doc-line.prod-code
                       and buf_goods.prod-type  = buf_doc-line.prod-type
                       and buf_doc-line.doc-code = t-doc.doc-code no-error .

      find first tt-1 where
                 tt-1.gds-code = buf_goods.gds-code no-error .
      if not available tt-1 then do:
            assign prt-rec   = recid(buf_gds-dtl)
                   line-mode = {&update}
                   line-rec  = recid(buf_doc-line)
                   gds-rec   = recid(buf_goods).
            run str/out-add.p
             (input parparentproc,
              input recid(t-doc),
              input recid(buf_doc-line),
              input recid(buf_gds-dtl),
              input recid(buf_goods),
              input "delete",
              input ?
              ) no-error.
              if error-status :error then return error return-value .
      end.
end.


   for each tt-1 ,
       first buf_goods no-lock where buf_goods.gds-code = tt-1.gds-code :
       find first buf_doc-line no-lock  where
                              buf_goods.artic   = buf_doc-line.artic
                       and buf_goods.prod-code  = buf_doc-line.prod-code
                       and buf_goods.prod-type  = buf_doc-line.prod-type
                       and buf_doc-line.doc-code = t-doc.doc-code no-error .

       find first buf_gds-dtl no-lock  where
                           buf_gds-dtl.prt-code = tt-1.prt-code
                       and buf_goods.artic      = buf_gds-dtl.artic
                       and buf_goods.prod-code  = buf_gds-dtl.prod-code
                       and buf_goods.prod-type  = buf_gds-dtl.prod-type
                       and buf_gds-dtl.doc-code = t-doc.doc-code no-error .
        if available buf_gds-dtl then do:
            if buf_gds-dtl.fact-qnty <> tt-1.fact-qnty then do:
               /*изменить buf_gds-dtl и ub.doc-line */
            assign prt-rec   = recid(buf_gds-dtl)
                  line-mode = {&update}
                  line-rec  = recid(buf_doc-line)
                  gds-rec   = recid(buf_goods).
            run str/out-add.p
             (input parparentproc,
              input recid(t-doc),
              input recid(buf_doc-line),
              input recid(buf_gds-dtl),
              input recid(buf_goods),
              input "ch-doc-qnty",
              input string(tt-1.fact-qnty)
             ) no-error.
            if error-status :error then next.
            if tt-1.fact-qnty > buf_gds-dtl.fact-qnty then message
             "По товару " buf_goods.gds-name "возможно расходывать только " buf_gds-dtl.fact-qnty skip
             "Введено" tt-1.fact-qnty
             view-as alert-box information .
            if tt-1.fact-qnty < buf_gds-dtl.fact-qnty then message
             "По товару " buf_goods.gds-name "несовпадение количеств" buf_gds-dtl.fact-qnty skip
             "Введено" tt-1.fact-qnty
             view-as alert-box information .
             if tt-1.fact-qnty <> buf_gds-dtl.fact-qnty then
                run pr-corr-flor in this-procedure (
                 buf_goods.gds-code ,
                 buf_gds-dtl.prt-code ,
                 tt-1.fact-qnty - buf_gds-dtl.fact-qnty
                 ) .

           end.
        end.
   end.

  end.

end procedure. /* re-ver */

procedure pr-corr-flor :

  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code as integer   no-undo .
define input  parameter p-prt-code as integer   no-undo .
define input  parameter p-delta as decimal   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr.
define variable v-i as integer   no-undo init 0 .
define variable v-buket as character no-undo .
define variable v-sum as decimal   no-undo .

      for each buf_doc-line-attr no-lock  where
               buf_doc-line-attr.doc-code = t-doc.doc-code and
               buf_doc-line-attr.gds-code = p-gds-code and
               buf_doc-line-attr.attr-code  begins {&lineattr-flora_gds-code} + {&comma-char} + string(p-prt-code)  + {&comma-char}
      :
        v-i = v-i + 1 .
        v-buket = entry (3, buf_doc-line-attr.attr-code ) .
        v-sum = decimal(buf_doc-line-attr.attr-value) .
      end.

   if v-i > 1 then do:
      message "Товар находится в нескольких наборах (" v-i ") Уменьшите количество на = " p-delta  .
      return.
   end.


run lineattr-write-flora-gds in this-procedure (
     t-doc.doc-code  ,
     p-gds-code      ,
     p-prt-code      ,
     v-buket         ,
     {&lineattr-flora_gds-code}  ,
     string( v-sum - p-delta)
     ).

    run cr-tt-flor in this-procedure .
    run re-disp in this-procedure  .

  end.
end procedure. /* pr-corr-flor */
procedure ver-qnty :

  do
  on error undo, return error return-value
  :
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_goods   for ub.goods.

if not  t-doc.status_ = {&permitted} then return .

for each  buf_gds-dtl  no-lock  where
          buf_gds-dtl.doc-code = t-doc.doc-code :
     find first buf_goods no-lock  where
                buf_goods.artic       = buf_gds-dtl.artic
            and buf_goods.prod-code  = buf_gds-dtl.prod-code
            and buf_goods.prod-type  = buf_gds-dtl.prod-type no-error .
    if buf_gds-dtl.fact-qnty > buf_gds-dtl.doc-qnty  then do:
       message "Фактическое количество товара не может быть больше количества по накладной."skip
                "Артикул :" buf_goods.artic    skip
                "Товар   :" buf_goods.gds-name   skip
                "Количество Фактическое  :" buf_gds-dtl.fact-qnty skip
                "Количество по документу :" buf_gds-dtl.doc-qnty skip
                view-as alert-box error .
    end.
end.

  end.

end procedure. /* ver-qnty */
procedure proc-sht:
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varrid-list as character no-undo.
  define variable varrecid    as recid     no-undo.
  assign
    varrid-list = "".
  run str/sht-all.w (parparentproc, t-doc.obj-type, t-doc.obj-code, 'b-sel', 'obj', t-doc.obj-type, t-doc.obj-code, '':u, input-output varrid-list) no-error.
  if error-status:error or varrid-list = "":u then do:
    return error.
  end.
  else do:
    assign
      varrecid = integer (entry(1, varrid-list)).
    find first bf_shift-obj where recid(bf_shift-obj) = varrecid no-lock no-error.
    if available bf_shift-obj then do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date.
        display t-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.
end procedure.

procedure proc-shift-num :
  define buffer bf_shift-obj   for ub.shift-obj.
  if input frame {&frame-name} t-doc.shift-date <> ? then do:
    find first bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                  bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                  bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                  bf_shift-obj.shift-num  = input frame {&frame-name} t-doc.shift-num  no-lock no-error.
    if not available bf_shift-obj then do:
      message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
              " Дата " input frame {&frame-name} t-doc.shift-date " Порядок смены " input frame {&frame-name} t-doc.shift-num " ."
      view-as alert-box error.
      display t-doc.shift-num with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do:
        return error.
      end.
    end.
    else do:
      assign
        t-doc.shift-date = bf_shift-obj.shift-date
        t-doc.shift-num  = bf_shift-obj.shift-num
        t-doc.shift-name = bf_shift-obj.shift-name.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do:
        assign
          t-doc.fact-date = t-doc.shift-date.
        display t-doc.fact-date with frame {&frame-name}.
      end.
    end.
  end.
end procedure.

procedure proc-shift-name :
  define buffer bf_shift-obj   for ub.shift-obj.
  define variable varfind-shift as integer initial 0.
  define variable varshift-date like ub.shift-obj.shift-date no-undo.
  define variable varshift-num  like ub.shift-obj.shift-num  no-undo.

  if input frame {&frame-name} t-doc.shift-date <> ? then do:
    for each  bf_shift-obj where bf_shift-obj.obj-type   = t-doc.obj-type                             and
                                 bf_shift-obj.obj-code   = t-doc.obj-code                             and
                                 bf_shift-obj.shift-date = input frame {&frame-name} t-doc.shift-date and
                                 bf_shift-obj.shift-name = input frame {&frame-name} t-doc.shift-name no-lock on error undo, return error return-value :
      assign
        varfind-shift = varfind-shift + 1
        varshift-date = bf_shift-obj.shift-date
        varshift-num  = bf_shift-obj.shift-num.
    end.

    if varfind-shift = 0 or varfind-shift > 1 then do:
      if varfind-shift = 0 then do:
        message "Не найдена смена: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
        view-as alert-box error.
      end.
      else do:
        message "Найдено более одной смены с одним номером в сменном дне. Объект: " t-doc.obj-type " " t-doc.obj-code
                " Дата " input frame {&frame-name} t-doc.shift-date " Номер смены " input frame {&frame-name} t-doc.shift-name " ."
        view-as alert-box error.
      end.
      display t-doc.shift-name with frame {&frame-name}.
      run proc-sht no-error.
      if error-status:error then do: return error. end.
    end.
    else do:
      assign frame {&frame-name}
        t-doc.shift-name.
      assign
        t-doc.shift-date = varshift-date
        t-doc.shift-num  = varshift-num.
      display t-doc.shift-date t-doc.shift-num t-doc.shift-name with frame {&frame-name}.
      if t-doc.fact-date = ? then do: assign t-doc.fact-date = t-doc.shift-date. display t-doc.fact-date with frame {&frame-name}. end.
    end.
  end.
end procedure.


{ str/fact-bc.i }

procedure create-record :
  define  input parameter p-doc-code   like ub.trn-doc.doc-code    no-undo.
  define  input parameter p-attr-code  like ub.doc-attr.attr-code  no-undo.
  define  input parameter p-attr-value like ub.doc-attr.attr-value no-undo.
  define output parameter p-exist      as   logical                no-undo.

  { str/tdat-xst.i
      p-doc-code
      p-attr-code
      p-exist }
  if p-exist = no then do:
    { str/tdat-wrt.i
        p-doc-code
        p-attr-code
        p-attr-value
        no-error     }
    if error-status :error then do:
      message error-status :error error-status :get-message( 1 ) '"' + p-attr-code + '"'
      view-as alert-box error.
    end.
  end.
end procedure. /* create-record */

procedure attr-property :
  define  input parameter p-code           as character no-undo. /* код атрибута    */
  define output parameter p-type           as character no-undo. /* тип атрибута    */
  define output parameter p-format         as character no-undo. /* формат атрибута */
  define output parameter p-fillin_width   as integer   no-undo. /* ширина          */
  define output parameter p-fillin_height  as integer   no-undo. /* высота          */
  define output parameter p-label          as character no-undo. /* лабел атрибута */
  define output parameter p-user-can-edit  as logical   no-undo. /* пользователь может изменять в броусе */
  define output parameter p-output-display as logical   no-undo. /* виден в броусе */
  define output parameter p-other          as character no-undo. /* еще чего - нибудь */
  define output parameter p-proc-attr      as character no-undo. /* внешняя процедура */

  define variable v-full-screen-val as character no-undo .
  define variable v-sort as integer   no-undo .


  do on error undo, return error return-value :
    { str/tdat-cod.i
        p-code
        p-type
        p-format
        p-fillin_width
        p-fillin_height
        p-label
        p-user-can-edit
        p-output-display
        p-other
        p-proc-attr
        v-full-screen-val
        v-sort
        no-error
    }
    if error-status :error then do:
      message "Ошибка при установке атрибутов-флористов документа." skip
              error-status :get-message( 1 ) skip
              return-value
      view-as alert-box error.
      return error.
    end.
  end. /* on error */
end procedure. /* attr-property */

procedure chg-purch-contract :
  message  "Проверка договора ?"  view-as alert-box .
end procedure.