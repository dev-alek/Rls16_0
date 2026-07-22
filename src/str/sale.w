&Scoped-define WINDOW-NAME    d-sale
&Scoped-define FRAME-NAME     d-sale

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главная форма интерфейса продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

Author:   Исаков Андрей Валерьевич, модификатор Черных Виктор Георгиевич .
Created: 02/09/95

*/

/* ***************************  Definitions  ************************** */
DEFINE INPUT PARAMETER PARPARENTPROC AS WIDGET-HANDLE NO-UNDO .
define input parameter p-mode        as character no-undo .
define input-output parameter p-doc-rec     as recid no-undo .
define input-output parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .
define parameter buffer ink-doc for ub.inkas.


define variable vss-revision    as character no-undo initial "$Revision$":u .
define variable vss-author      as character no-undo initial "$Author$":u .
define variable vss-date        as character no-undo initial "$Date$":u .
define variable vss-workfile    as character no-undo initial "$Workfile$":u .
define variable vss-archive     as character no-undo initial "$Archive$":u .
define variable vss-description as character no-undo initial "Главная форма интерфейса продаж" .
{ gbl/objsrv.i }
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ str/salttemp.i }
{ ref/gds-attr.i }
{ str/salersrv.i def }
{ str/libbcrcn.i }
{ gbl/waitfram.i }
{ gbl/cur-time.i }
{ str/trdcalib.i }
{ str/lib-def.i }
{ gbl/clntattr.i }
{ str/tpsidoc.i "NEW SHARED" proc }
{ ref/gdsoattr.i }
{ gbl/tpsi-gds.i }
{ cmp/showinf.i }
{ str/lib-trn.i }
{ gbl/color.i }
{ str/shftnmef.i inkas shift-name }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }

{ str/writelog.i def "'fbr-rsrv-errors-sale.txt'" }

{ gbl/key-rec.i }
{ cmp/ini-lib.i }
os-delete value (search ('fbr-rsrv-errors-sale.txt')) no-error.

DEFINE NEW SHARED BUFFER t-doc     FOR ub.trn-doc. /* можно было бы обойтись буфером по умолчанию t-doc, но t-doc зашито в sch-line.i */
DEFINE NEW SHARED BUFFER ret-doc   FOR ub.trn-doc. /* возвратный документ */
DEFINE BUFFER l-out-dtl FOR ub.gds-dtl. /* для поиска  */
DEFINE BUFFER l-goods   FOR ub.goods. /* для поиска  */
DEFINE NEW SHARED BUFFER out-dtl   FOR ub.gds-dtl. /* расходный документ */
DEFINE NEW SHARED BUFFER ret-dtl   FOR ub.gds-dtl.
DEFINE NEW SHARED BUFFER out-prt   FOR ub.gds-prt. /* расходный  документ */
DEFINE NEW SHARED BUFFER ret-prt   FOR ub.gds-prt.
DEFINE NEW SHARED BUFFER out-goods FOR ub.goods.   /* расходный  документ */
DEFINE NEW SHARED BUFFER ret-goods FOR ub.goods.
DEFINE NEW SHARED BUFFER out-bar   FOR ub.bar-code.  /* расходный  документ */
DEFINE NEW SHARED BUFFER ret-bar   FOR ub.bar-code.
DEFINE NEW SHARED BUFFER out-tt0-dtl   FOR tt0-gds-dtl. /* расходный документ */
DEFINE NEW SHARED BUFFER ret-tt0-dtl   FOR tt0-gds-dtl.

define variable sort-column-name-out as character no-undo .
define variable sort-column-name-ret as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable bh-out-dtl as handle no-undo .
define variable bh-ret-dtl as handle no-undo .
define variable bh-out-goods as handle no-undo .
define variable bh-ret-goods as handle no-undo .
define variable brwh-out-dtl as widget-handle no-undo .
define variable brwh-ret-dtl as widget-handle no-undo .
/*handle for out-dtl ret-dtl*/
define variable bh as handle no-undo .
/*handle for out-goods ret-goods*/
define variable bhg as handle no-undo .
/*handle for out-bar ret-bar*/
define variable bhb as handle no-undo .
define variable brwh as widget-handle no-undo .
define variable qh as handle no-undo .
/*используются для поиска и т.д.*/
define variable v-doc-code as character no-undo .
define variable v-artic as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-recid as recid no-undo .
define variable v-b-code as integer no-undo .
define variable v-node-code as integer no-undo .

/*внтури продажи режим закрытия равен 0*/
define variable p-auto  as integer no-undo init 0.
define variable v-parameter as character no-undo .
define variable p-parent-handle as handle no-undo .
define variable p-log-handle as handle no-undo .
/*для сравнения кол-в по факту и доку - разрешить ли кнопку закрыть*/
define variable b-close-enabled as logical no-undo initial no.
define variable BadTrans as logical no-undo .
define variable t-code like ub.trn-doc.out-code no-undo.
define variable ret-code like ub.trn-doc.out-code no-undo.
/*recid doc-line с которой надо снять - поставить резервы */
define variable rdoc-line as recid.
/*какой документ показывает нижниый броуз - возврат списание техпролив - значение cb-doc-kind*/
define variable br-2-mode as character no-undo .
/*номер документа, который показывает нижниый броуз - возврат списание техпролив*/
define variable br-2-doc-code as character no-undo .
define variable v-list-item-pairs as character no-undo .
/*какую единичную запись резервируем расход или возврат или списание или техпролив - kind документа*/
define variable r-or-v as character no-undo.
/*тип товара для резервирования*/
define variable r-office as character no-undo .
define variable num_resv as integer no-undo.
/*количество зарезервированных позиций*/
define variable num_resv_res as integer no-undo.
/*закрывать ли продажу автоматически */
define variable autoclose as logical no-undo initial no.
/*автоматически считать шапку*/
define variable autocalc as logical no-undo initial no.
/*только ли зашли*/
define variable just-entered as logical no-undo initial yes.
/*нстройки ТПСИ*/
/*объект участник ТПСИ*/
define variable v-is-tpsi-obj as logical no-undo .
/*учитывать остатки чужих товаров в ТСПИ*/
define variable resttpsi as logical no-undo .
/*уводить чужой весовой товар в отриц остатки*/
define variable neg-tpsi-weight as logical no-undo .
/*уводить чужой товар в отриц остатки по отметке оператора*/
define variable neg-tpsi-oper as logical no-undo .
/*уводить чужой товар в отриц остатки если недостает меньше чем*/
define variable neg-tpsi-qnty as decimal no-undo .
/*закрывать приход по техпроливу*/
define variable close-in-rfsl as integer no-undo .
/*список алгоритмов для размазывания chk-gds-pay*/
define variable pay-gds-algo as character no-undo .
/*настройки производства*/
/*автоматическое производство*/
define variable autofbr as logical no-undo initial no.
/*учитывать остатки блюд*/
define variable restdish as logical no-undo initial no.
/*учитывать остатки ингридиентов*/
define variable restingr as logical no-undo initial no.
define variable conf-attr as character no-undo.                  /* для чтения параметра конфигурации */
define variable conf-par as character no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as character no-undo.
/*использовать смены на кассе для данного объекта*/
define variable cas-shft as logical no-undo initial no.
/*в продажу закачано по одному курсу?*/
define variable one-curs as logical no-undo initial no.
/*рзервирование началось с выбора пункта поп-ап меню*/
define variable from-menu as logical initial no.
/*нажималась ли кнопка b-mail*/
define variable b-mail-pressed as logical initial no.
/*настроечный параметр - после захода в почту*/
define variable auto-mail as logical no-undo.
/*настроечный параметр - после почты резервировать*/
define variable auto-get-res as logical no-undo.
/*настроечный параметр - компенсировать ли в продаже расход-возврат*/
define variable auto-comp as logical no-undo.
/*откуда брать цены в накладную - из чека или из прайс-листа*/
define variable prcl-spl as logical no-undo initial no.
define variable ptwounit as logical no-undo initial yes.

define variable v-to-reserv as logical no-undo initial no.  /* надо ли резервировать после распределения по местам хранения */

define variable compensed as logical no-undo.
define variable from-compense as logical no-undo.
define variable p-obj-type like ub.clients.obj-type no-undo.
define variable p-obj-code like ub.clients.obj-code no-undo.
define variable current-browser as widget-handle no-undo.
/*есть неучтенные чеки*/
define variable not-all-saled-chk as logical initial no.
/*есть неуправильные чеки */
define variable not-all-normal-chk as logical initial no.
/*есть незакрытые продажи*/
define variable not-all-inkas-closed as logical no-undo initial no.
define variable glog as logical no-undo .
define variable g#log as logical no-undo .
define variable v-base-type like ub.currency.curr-abbr no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-db-num  like ub.db.db-num no-undo .
define variable v-gds-dtl-prop-doc-qnty like ub.gds-dtl.doc-qnty no-undo .
define variable v-ret-dtl-prop-doc-qnty like ub.gds-dtl.doc-qnty no-undo .
define variable v-gds-proprietor as character no-undo .
define variable v-ret-gds-proprietor as character no-undo .
define variable line-rec as recid no-undo .
define variable gds-rec as recid no-undo .
define variable v-empty as character no-undo .
define variable v-prt-name as character no-undo .
define variable v-is-inquiry as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-log-handle as handle no-undo . /* для логирования резервирования*/

define variable v-sys-key as character no-undo .
define variable varpar-type as character no-undo .
{ gbl/thbj-def.i }
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

define temp-table wh no-undo
field mi-reserv as widget-handle
field mi-unreserv as widget-handle
field mi-parts as widget-handle
field mi-arch as widget-handle
field doc-kind like ub.sale-doc.doc-kind
field chr-office like ub.sale-doc.chr-office
field doc-code like ub.sale-doc.doc-code
index pi is unique primary
doc-code doc-kind.



define buffer buf_currency for ub.currency.
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
{ str/dtlrestm.i "new shared" }
{ str/dtl-rest.i new }
{ cmp/r-page1.i new }
{ str/lib-farh.i }
{ str/saleq.i }

{ref/imagelist.i}
&scop artic-field 'artic':U
&scop doc-code-field 'doc-code':U
&scop prod-type-field 'prod-type':U
&scop prod-code-field 'prod-code':U
&scop b-code-field 'b-code':U
&scop prt-code-field 'prt-code':U
&scop gds-code-field 'gds-code':U
&scop buffer-gds-dtl 1
&scop buffer-goods 3
&scop buffer-bar-code 4


&SCOPED-DEFINE sort-clmn_1-out get-ok(input v-is-tpsi-obj, out-dtl.artic, out-dtl.prod-type, out-dtl.prod-code, out-dtl.prt-code, out-dtl.doc-qnty, out-dtl.fact-qnty)
&SCOPED-DEFINE dyn_sort-clmn_1-out substitute('dynamic-function(&1get-ok&1, &1&2&1, out-dtl.artic, out-dtl.prod-type, out-dtl.prod-code, out-dtl.prt-code, out-dtl.doc-qnty, out-dtl.fact-qnty)', ~{&double-quote~}, v-is-tpsi-obj)
&scoped-define label-clmn_1-out 'OK'
&SCOPED-DEFINE sort-clmn_2-out out-bar.b-code
&scoped-define label-clmn_2-out 'Бар-код'
&SCOPED-DEFINE sort-clmn_3-out out-dtl.artic
&scoped-define label-clmn_3-out 'Артикул'
&SCOPED-DEFINE sort-clmn_4-out ( get-name (input out-prt.node-name, input out-prt.upper-code, input out-goods.prt-root, input out-goods.gds-name))
&SCOPED-DEFINE DYN_sort-clmn_4-out substitute('dynamic-function(&1GET-NAME&1, out-prt.node-name, out-prt.upper-code, out-goods.prt-root, out-goods.gds-name)', ~{&double-quote~})
&scoped-define label-clmn_4-out 'Название'
&SCOPED-DEFINE sort-clmn_5-out out-dtl.fact-qnty
&scoped-define label-clmn_5-out 'Продано'
&SCOPED-DEFINE sort-clmn_6-out out-dtl.doc-qnty
&scoped-define label-clmn_6-out 'Зарезерв.'
&SCOPED-DEFINE sort-clmn_7-out  out-tt0-dtl.doc-qnty
&scoped-define label-clmn_7-out 'Чужих'
&scoped-define num-clmn_7-out 7
&SCOPED-DEFINE sort-clmn_8-out   (out-tt0-dtl.obj-type + string(out-tt0-dtl.obj-code))
&scoped-define label-clmn_8-out 'Хозяин'
&scoped-define num-clmn_8-out 8
&SCOPED-DEFINE sort-clmn_9-out (if v-curr-r-b = ~{&r-b-base~} then out-dtl.price-base else out-dtl.price-rubl)
&SCOPED-DEFINE dyn_sort-clmn_9-out substitute('(if &1&2&1 = &1&3&1 then out-dtl.price-base else out-dtl.price-rubl)', ~{&double-quote~}, v-curr-r-b,  ~{&r-b-base~})
&scoped-define label-clmn_9-out 'Цена'
&SCOPED-DEFINE sort-clmn_10-out (if v-curr-r-b = ~{&r-b-base~} then out-dtl.discnt-base else out-dtl.discnt-rubl)
&SCOPED-DEFINE dyn_sort-clmn_10-out substitute('(if &1&2&1 = &1&3&1 then out-dtl.discnt-base else out-dtl.discnt-rubl)', ~{&double-quote~}, v-curr-r-b, ~{&r-b-base~})
&scoped-define label-clmn_10-out 'Скидка'
&SCOPED-DEFINE sort-clmn_11-out  (get-pcnt(input out-dtl.price-base,input out-dtl.price-rubl,input out-dtl.discnt-base,input out-dtl.discnt-rubl))
&SCOPED-DEFINE dyn_sort-clmn_11-out substitute('dynamic-function(&1get-pcnt&1, out-dtl.price-base, out-dtl.price-rubl, out-dtl.discnt-base, out-dtl.discnt-rubl)', ~{&double-quote~})
&scoped-define label-clmn_11-out '%'
&SCOPED-DEFINE sort-clmn_12-out  out-goods.unit-base
&scoped-define label-clmn_12-out 'Изм'
&SCOPED-DEFINE sort-clmn_13-out  out-goods.grp-name
&scoped-define label-clmn_13-out 'Название группы'
&SCOPED-DEFINE sort-clmn_14-out  (get-prt-name (input out-prt.node-name, input out-prt.upper-code, input out-goods.prt-root, input out-prt.f-name ))
&SCOPED-DEFINE dyn_sort-clmn_14-out substitute('dynamic-function(&1get-prt-name&1, input out-prt.node-name, input out-prt.upper-code, input out-goods.prt-root, input out-prt.f-name)', ~{&double-quote~})
&scoped-define label-clmn_14-out 'Признак'
&SCOPED-DEFINE sort-clmn_15-out  out-goods.engl-name
&scoped-define label-clmn_15-out 'Название англ.'

&SCOPED-DEFINE sort-clmn_21-ret get-ok(input v-is-tpsi-obj, ret-dtl.artic, ret-dtl.prod-type, ret-dtl.prod-code, ret-dtl.prt-code, ret-dtl.doc-qnty, ret-dtl.fact-qnty)
&SCOPED-DEFINE dyn_sort-clmn_21-ret substitute('dynamic-function(&1get-ok&1, &1&2&1, ret-dtl.artic, ret-dtl.prod-type, ret-dtl.prod-code, ret-dtl.prt-code, ret-dtl.doc-qnty, ret-dtl.fact-qnty)', ~{&double-quote~}, v-is-tpsi-obj)
&scoped-define label-clmn_21-ret 'OK'
&SCOPED-DEFINE sort-clmn_22-ret ret-bar.b-code
&scoped-define label-clmn_22-ret 'Бар-код'
&SCOPED-DEFINE sort-clmn_23-ret ret-dtl.artic
&scoped-define label-clmn_23-ret 'Артикул'
&SCOPED-DEFINE sort-clmn_24-ret ( get-name ( input ret-prt.node-name, input ret-prt.upper-code, input ret-goods.prt-root, input ret-goods.gds-name ))
&SCOPED-DEFINE dyn_sort-clmn_24-ret substitute('dynamic-function(&1get-name&1, ret-prt.node-name, ret-prt.upper-code, ret-goods.prt-root, ret-goods.gds-name)', ~{&double-quote~})
&scoped-define label-clmn_24-ret 'Название'
&SCOPED-DEFINE sort-clmn_25-ret ret-dtl.fact-qnty
&scoped-define label-clmn_25-ret 'По чекам'
&SCOPED-DEFINE sort-clmn_26-ret ret-dtl.doc-qnty
&scoped-define label-clmn_26-ret 'Зарезерв.'
&SCOPED-DEFINE sort-clmn_27-ret v-empty
&scoped-define label-clmn_27-ret 'Зарезерв.'
&SCOPED-DEFINE sort-clmn_28-ret (if v-curr-r-b = ~{&r-b-base~} then ret-dtl.price-base else ret-dtl.price-rubl)
&SCOPED-DEFINE dyn_sort-clmn_28-ret substitute('(if &1&2&1 = &1&3&1 then ret-dtl.price-base else ret-dtl.price-rubl)',  ~{&double-quote~}, v-curr-r-b, ~{&r-b-base~})
&scoped-define label-clmn_28-ret 'Цена'
&SCOPED-DEFINE sort-clmn_29-ret (if v-curr-r-b = ~{&r-b-base~} then ret-dtl.discnt-base else ret-dtl.discnt-rubl)
&SCOPED-DEFINE dyn_sort-clmn_29-ret substitute('(if &1&2&1 = &1&3&1 then ret-dtl.discnt-base else ret-dtl.discnt-rubl)', ~{&double-quote~}, v-curr-r-b, ~{&r-b-base~})
&scoped-define label-clmn_29-ret 'Скидка'
&SCOPED-DEFINE sort-clmn_30-ret  ( get-pcnt(input ret-dtl.price-base,input ret-dtl.price-rubl,input ret-dtl.discnt-base,input ret-dtl.discnt-rubl))
&SCOPED-DEFINE dyn_sort-clmn_30-ret substitute('dynamic-function(&1get-pcnt&1, input ret-dtl.price-base, input ret-dtl.price-rubl, input ret-dtl.discnt-base, input ret-dtl.discnt-rubl)', ~{&double-quote~})
&scoped-define label-clmn_30-ret '%'
&SCOPED-DEFINE sort-clmn_31-ret  ret-goods.unit-base
&scoped-define label-clmn_31-ret 'Изм'
&SCOPED-DEFINE sort-clmn_32-ret  ret-goods.grp-name
&scoped-define label-clmn_32-ret 'Название группы'
&SCOPED-DEFINE sort-clmn_33-ret  (get-prt-name ( input ret-prt.node-name, input ret-prt.upper-code, input ret-goods.prt-root, input ret-prt.f-name ))
&SCOPED-DEFINE dyn_sort-clmn_33-ret substitute('dynamic-function(&1get-prt-name&1, ret-prt.node-name, ret-prt.upper-code, ret-goods.prt-root, ret-prt.f-name)', ~{&double-quote~})
&scoped-define label-clmn_33-ret 'Признак'
&SCOPED-DEFINE sort-clmn_34-ret  ret-goods.engl-name
&scoped-define label-clmn_34-ret 'Название англ.'


/* ***********************  Control Definitions  ********************** */

DEFINE NEW SHARED QUERY br-out FOR out-dtl, out-prt, out-goods, out-bar, out-tt0-dtl SCROLLING.
DEFINE NEW SHARED QUERY br-ret FOR ret-dtl, ret-prt, ret-goods, ret-bar, ret-tt0-dtl SCROLLING.

DEFINE IMAGE g-image
     /*FILENAME "adeicon/blank":U*/
     STRETCH-TO-FIT RETAIN-SHAPE
     SIZE 11.00 BY 2.
DEFINE BUTTON b-notes
     LABEL "П&рим":L
     SIZE 8.5 BY 1.

DEFINE BUTTON b-arch
     LABEL "&Учет":L
     SIZE 8.5 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-close AUTO-GO
     LABEL "&Закрыть":L
     SIZE 10 BY 1.

DEFINE BUTTON b-res
     LABEL "Резервы&+":L
     SIZE 10 BY 1.

DEFINE BUTTON b-unres
     LABEL "Резервы&-":L
     SIZE 10 BY 1.

DEFINE BUTTON b-cash
     LABEL "В&ыручка":L
     SIZE 10 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-chk
     LABEL "Ч&еки  ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-mail
     LABEL "Прием чек&ов":L
     SIZE 12 BY 1.

DEFINE BUTTON b-troubl
     LABEL "-остатки":L
     SIZE 8.5 BY 1.

DEFINE BUTTON b-troublp
     LABEL "-партии":L
     SIZE 8.5 BY 1.

DEFINE BUTTON b-troublc
     LABEL "-чеки":L
     SIZE 8.5 BY 1.

DEFINE BUTTON b-parts
     LABEL "&Партии(товар)":L
     SIZE 14 BY 1.

DEFINE BUTTON r-trn
     LABEL "Чеки(&товар)":L
     SIZE 14 BY 1.
     
DEFINE BUTTON b-places
     LABEL "&Места хранения":L
     SIZE 15 BY 1.     

DEFINE BUTTON b-next AUTO-GO
     LABEL ">&>":L
     SIZE 3 BY 1.

DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1.

DEFINE VARIABLE auto-close AS LOGICAL INITIAL no
     LABEL "Авто"
     VIEW-AS TOGGLE-BOX
     SIZE 12 BY 1 NO-UNDO.

/*настроечный параметр - производить блюда*/
DEFINE VARIABLE auto-fbr AS LOGICAL INITIAL no
     LABEL "Автопр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE rest-dish AS LOGICAL INITIAL no
     LABEL "Ост-ки блюд"
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE rest-ingr AS LOGICAL INITIAL no
     LABEL "Ост-ки ингр."
     VIEW-AS TOGGLE-BOX
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE rest-tpsi AS LOGICAL INITIAL no
     LABEL "Остатки ЧУЖИХ товаров"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY 1 NO-UNDO.

DEFINE VARIABLE s-pc AS DECIMAL FORMAT "->>9.<%"
     VIEW-AS FILL-IN
     SIZE 8 BY 1
     NO-UNDO.

DEFINE VARIABLE s-netto AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99"
     LABEL "Нетто"
     VIEW-AS FILL-IN
     SIZE 19 BY 1
     FGCOLOR 4  NO-UNDO.

define variable rs-sort AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"Выкл&юч.","off":U,
"Ко&лич.","quantity":U,
"&Цена","price":U,
"Ск&идка","discount":U,
"&Сумма","summa":U
SIZE 43 BY 1 NO-UNDO.

DEFINE VARIABLE prod-name-r LIKE ub.clients.obj-name
      VIEW-AS TEXT
     SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE prod-name-v LIKE ub.clients.obj-name
      VIEW-AS TEXT
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE for-discnt-chr as character
      VIEW-AS TEXT
     SIZE 19 BY 1 NO-UNDO FORMAT "X(42)".

DEFINE VARIABLE Cb-doc-kind AS CHARACTER FORMAT "X(256)":U
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEM-PAIRS "Item 1","Item 2",
                    "Item 2","Item 3"
    DROP-DOWN-LIST
    SIZE 20 BY 1
    BGCOLOR 15  NO-UNDO.

DEFINE MENU m-recs
       MENU-ITEM m-recs-1  LABEL "Все товары"                ACCELERATOR "ALT-1".


DEFINE MENU m-unrecs
       MENU-ITEM m-unrecs-1  LABEL "Все товары"                ACCELERATOR "ALT-1".

DEFINE MENU m-arch
      MENU-ITEM m-arch-i LABEL "Все документы" ACCELERATOR "ALT-1".

DEFINE MENU m-parts
      MENU-ITEM m-parts-i LABEL "По всем документам" ACCELERATOR "ALT-1".

define variable loc-art AS CHARACTER VIEW-AS fill-in size 14 by 1 fgcolor 12 no-undo.
define variable loc-name AS CHARACTER VIEW-AS fill-in size 20 by 1 fgcolor 12 no-undo.
define variable loc-code AS CHARACTER VIEW-AS fill-in size 20 by 1 fgcolor 12 no-undo.

define variable a-n-c AS CHARACTER VIEW-AS RADIO-SET HORIZONTAL RADIO-BUTTONS
"&А","art",
"&Н","name",
"&К","code"
SIZE 12 BY 1 NO-UNDO.

DEFINE BROWSE br-out QUERY br-out NO-LOCK DISPLAY
{&sort-clmn_1-out} column-label {&label-clmn_1-out} format "X(2)"
{&sort-clmn_2-out} column-label {&label-clmn_2-out} format ">>>>>>>>>9"
{&sort-clmn_3-out} column-label {&label-clmn_3-out}
{&sort-clmn_4-out} column-label {&label-clmn_4-out} format "x(35)"
{&sort-clmn_5-out} column-label {&label-clmn_5-out} format "->>>,>>9.<<<"
{&sort-clmn_6-out} column-label {&label-clmn_6-out} format "->>>,>>9.<<<"
{&sort-clmn_7-out} column-label {&label-clmn_7-out} format "->>>,>>9.<<<"
{&sort-clmn_8-out} column-label {&label-clmn_8-out} format "X(8)"
{&sort-clmn_9-out} column-label {&label-clmn_9-out} format "->>>,>>>,>>9.<<"
{&sort-clmn_10-out} column-label {&label-clmn_10-out}
{&sort-clmn_11-out} column-label {&label-clmn_11-out} FORMAT "->>>>>9.<%"
{&sort-clmn_12-out} column-label {&label-clmn_12-out}
{&sort-clmn_13-out} @ v-prt-name column-label {&label-clmn_13-out}
{&sort-clmn_14-out} column-label {&label-clmn_14-out} FORMAT "x(80)" width 10
{&sort-clmn_15-out} column-label {&label-clmn_15-out}
ENABLE {&sort-clmn_15-out}
WITH SIZE 98 BY 11 SEPARATORS TITLE "Продажи".

DEFINE BROWSE br-ret QUERY br-ret NO-LOCK DISPLAY
{&sort-clmn_21-ret} column-label {&label-clmn_21-ret} format "X(2)"
{&sort-clmn_22-ret} column-label {&label-clmn_22-ret} format ">>>>>>>>>9"
{&sort-clmn_23-ret} column-label {&label-clmn_23-ret}
{&sort-clmn_24-ret} column-label {&label-clmn_24-ret} format "x(35)"
{&sort-clmn_25-ret} column-label {&label-clmn_25-ret} format "->>>,>>9.<<<"
{&sort-clmn_26-ret} column-label {&label-clmn_26-ret} format "->>>,>>9.<<<"
{&sort-clmn_27-ret} column-label {&label-clmn_27-ret} format "X(12)"
{&sort-clmn_28-ret} column-label {&label-clmn_28-ret} format "->>>,>>>,>>9.<<"
{&sort-clmn_29-ret} column-label {&label-clmn_29-ret}
{&sort-clmn_30-ret} column-label {&label-clmn_30-ret} FORMAT "->>>>>9.<%"
{&sort-clmn_31-ret} column-label {&label-clmn_31-ret}
{&sort-clmn_32-ret} @ v-prt-name column-label {&label-clmn_32-ret}
{&sort-clmn_33-ret} column-label {&label-clmn_33-ret} FORMAT "x(80)" width 10
{&sort-clmn_34-ret} column-label {&label-clmn_34-ret}
ENABLE {&sort-clmn_34-ret}
WITH SIZE 98 BY 5.5 SEPARATORS TITLE "Возвраты".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-sale
b-exit at row 1 col 1
b-prev at row 1 col 11
b-next at row 1 col 14
b-mail at row 1 col 17
b-res     at row 1 col 29
b-unres     at row 1 col 39
b-close at row 1 col 49
b-chk at row 1 col 59
b-cash at row 1 col 69
b-print at row 1 col 79
b-help at row 1 col 89
"Поиск :" view-as text SIZE 8 BY 1 at row 2 col 2
a-n-c at row 2 col 10 no-label
auto-close AT ROW 2 COL 64  FGCOLOR 4
ink-doc.qnty AT ROW 2 COL 84 COLON-ALIGNED label "Кол-во"
ink-doc.num-chk AT ROW 3 COL 84 COLON-ALIGNED label "Чеков"
ink-doc.tot-doc AT ROW 3 COL 13 COLON-ALIGNED label "Сумма тов."
ink-doc.discnt AT ROW 3 COL 44 COLON-ALIGNED label "Общая скидка"
s-pc AT ROW 3 COL 65 COLON-ALIGNED no-label
g-image AT ROW 4 COL 88.1
for-discnt-chr AT ROW 4 COL 65 COLON-ALIGNED no-label
FGCOLOR 4
ink-doc.sub-discnt  AT ROW 4 COL 13 COLON-ALIGNED label "Списания"
s-netto AT ROW 4 COL 44 COLON-ALIGNED
rest-tpsi AT ROW 4 COL 64  FGCOLOR 4
auto-fbr AT ROW 5 COL 58  FGCOLOR 4
rest-dish AT ROW 5 COL 70  FGCOLOR 4
rest-ingr AT ROW 5 COL 84  FGCOLOR 4
br-out AT ROW 6 COL 1
b-places at row 17 col 56
r-trn at row 17 col 71
b-parts at row 17 col 85
prod-name-r AT ROW 5 COL 1  NO-LABEL
prod-name-v AT ROW 17 COL 1 NO-LABEL
cb-doc-kind at row 17 col 36 NO-LABEL
br-ret AT ROW 18 COL 1
rs-sort at row 23.5 col 1 label "Сортировка" fgcolor 4 bgcolor 8
b-troubl AT ROW 23.5 COL 55 COLON-ALIGNED
b-troublp AT ROW 23.5 COL 63.5 COLON-ALIGNED
b-troublc AT ROW 23.5 COL 72 COLON-ALIGNED
b-arch at row 23.5 col 82.5
b-notes at row 23.5 col 91
loc-art AT ROW 2 COL 37 COLON-ALIGNED label "Начало артикула"
loc-name AT ROW 2 COL 37 COLON-ALIGNED label "Начало названия" format "x(40)"
loc-code AT ROW 2 COL 37 COLON-ALIGNED label "Бар-код (весь)" format "x(13)"
SPACE(0) SKIP(0)
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE "ПРОДАЖИ и ВОЗВРАТЫ".

{ gbl/srt-clmd.i
&browse-name = "br-out"
&frame-name  = {&frame-name}
&table-name = "out-dtl"
&ext-col = 15
&start-column  = 4
&label-clmn_1  = "{&label-clmn_1-out}"
&sort-clmn_1   = "{&sort-clmn_1-out}"
&dyn_sort-clmn_1   = "{&dyn_sort-clmn_1-out}"
&label-clmn_2  = "{&label-clmn_2-out}"
&sort-clmn_2   = "{&sort-clmn_2-out}"
&label-clmn_3  = "{&label-clmn_3-out}"
&sort-clmn_3   = "{&sort-clmn_3-out}"
&label-clmn_4  = "{&label-clmn_4-out}"
&sort-clmn_4   = "{&sort-clmn_4-out}"
&DYN_sort-clmn_4   = "{&DYN_sort-clmn_4-out}"
&label-clmn_5  = "{&label-clmn_5-out}"
&sort-clmn_5   = "{&sort-clmn_5-out}"
&label-clmn_6  = "{&label-clmn_6-out}"
&sort-clmn_6   = "{&sort-clmn_6-out}"
&label-clmn_7  = "{&label-clmn_7-out}"
&sort-clmn_7   = "{&sort-clmn_7-out}"
&label-clmn_8  = "{&label-clmn_8-out}"
&sort-clmn_8   = "{&sort-clmn_8-out}"
&label-clmn_9  = "{&label-clmn_9-out}"
&sort-clmn_9   = "{&sort-clmn_9-out}"
&dyn_sort-clmn_9   = "{&dyn_sort-clmn_9-out}"
&label-clmn_10 = "{&label-clmn_10-out}"
&sort-clmn_10  = "{&sort-clmn_10-out}"
&dyn_sort-clmn_10  = "{&dyn_sort-clmn_10-out}"
&label-clmn_11 = "{&label-clmn_11-out}"
&sort-clmn_11  = "{&sort-clmn_11-out}"
&dyn_sort-clmn_11  = "{&dyn_sort-clmn_11-out}"
&label-clmn_12 = "{&label-clmn_12-out}"
&sort-clmn_12  = "{&sort-clmn_12-out}"
&label-clmn_13 = "{&label-clmn_13-out}"
&sort-clmn_13  = "{&sort-clmn_13-out}"
&label-clmn_14 = "{&label-clmn_14-out}"
&sort-clmn_14  = "{&sort-clmn_14-out}"
&dyn_sort-clmn_14  = "{&dyn_sort-clmn_14-out}"
&label-clmn_15 = "{&label-clmn_15-out}"
&sort-clmn_15  = "{&sort-clmn_15-out}"
&open-query = "run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'out')."
&open-query-otherwise = "run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input '':U)."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name-out"
}

{ gbl/srt-clmd.i
&browse-name = "br-ret"
&frame-name  = {&frame-name}
&table-name = "ret-dtl"
&ext-col = 14
&start-column  = 4
&label-clmn_21  = "{&label-clmn_21-ret}"
&sort-clmn_21   = "{&sort-clmn_21-ret}"
&dyn_sort-clmn_21   = "{&dyn_sort-clmn_21-ret}"
&label-clmn_22  = "{&label-clmn_22-ret}"
&sort-clmn_22   = "{&sort-clmn_22-ret}"
&label-clmn_23  = "{&label-clmn_23-ret}"
&sort-clmn_23   = "{&sort-clmn_23-ret}"
&label-clmn_24  = "{&label-clmn_24-ret}"
&sort-clmn_24   = "{&sort-clmn_24-ret}"
&dyn_sort-clmn_24   = "{&dyn_sort-clmn_24-ret}"
&label-clmn_25  = "{&label-clmn_25-ret}"
&sort-clmn_25   = "{&sort-clmn_25-ret}"
&label-clmn_26  = "{&label-clmn_26-ret}"
&sort-clmn_26   = "{&sort-clmn_26-ret}"
&label-clmn_27  = "{&label-clmn_27-ret}"
&sort-clmn_27   = "{&sort-clmn_27-ret}"
&label-clmn_28  = "{&label-clmn_28-ret}"
&sort-clmn_28   = "{&sort-clmn_28-ret}"
&dyn_sort-clmn_28   = "{&dyn_sort-clmn_28-ret}"
&label-clmn_29  = "{&label-clmn_29-ret}"
&sort-clmn_29   = "{&sort-clmn_29-ret}"
&dyn_sort-clmn_29   = "{&dyn_sort-clmn_29-ret}"
&label-clmn_30 = "{&label-clmn_30-ret}"
&sort-clmn_30  = "{&sort-clmn_30-ret}"
&dyn_sort-clmn_30  = "{&dyn_sort-clmn_30-ret}"
&label-clmn_31 = "{&label-clmn_31-ret}"
&sort-clmn_31  = "{&sort-clmn_31-ret}"
&label-clmn_32 = "{&label-clmn_32-ret}"
&sort-clmn_32  = "{&sort-clmn_32-ret}"
&label-clmn_33 = "{&label-clmn_33-ret}"
&sort-clmn_33  = "{&sort-clmn_33-ret}"
&dyn_sort-clmn_33  = "{&dyn_sort-clmn_33-ret}"
&label-clmn_34 = "{&label-clmn_34-ret}"
&sort-clmn_34  = "{&sort-clmn_34-ret}"
&open-query = "run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input 'ret':U)."
&open-query-otherwise = "run OpenBr in this-procedure (input ink-doc.inkas-code, input br-2-doc-code, input yes, input no, input '':U, input '':U)."
&re-move-clmn = "no"
&mv-brw-default = "no"
&sort-column-name     = "sort-column-name-ret"
}


/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN FRAME d-sale:SCROLLABLE       = FALSE
             br-out:NUM-LOCKED-COLUMNS IN FRAME d-sale = 2
             br-ret:NUM-LOCKED-COLUMNS IN FRAME d-sale = 2.

ASSIGN b-res:POPUP-MENU IN FRAME {&frame-name} = MENU m-recs:HANDLE.
ASSIGN b-res:MENU-MOUSE = 1.

ASSIGN b-unres:POPUP-MENU IN FRAME {&frame-name} = MENU m-unrecs:HANDLE.
ASSIGN b-unres:MENU-MOUSE = 1.

ASSIGN b-arch:POPUP-MENU IN FRAME {&frame-name} = MENU m-arch:HANDLE.
ASSIGN b-arch:MENU-MOUSE = 1.

ASSIGN b-troublp:POPUP-MENU IN FRAME {&frame-name} = MENU m-parts:HANDLE.
ASSIGN b-troublp:MENU-MOUSE = 1.

/* ************************  Control Triggers  ************************ */

ON MOUSE-SELECT-DBLCLICK OF g-image IN FRAME {&FRAME-NAME}
DO:
   
    RUN ref/imagelist.w (PARPARENTPROC, "":U, v-gds-code,{&lookup}).
END.
ON ENTRY OF
br-out,
BR-RET
IN FRAME d-sale DO:
  assign
  current-browser = self
  qh = current-browser:query
  bh = qh:get-buffer-handle({&buffer-gds-dtl})
  brwh = self
  .
END.

ON choose OF MENU-ITEM m-arch-i in menu m-arch DO:
    apply "choose" to b-arch in frame {&frame-name}.
END.

ON choose OF MENU-ITEM m-parts-i in menu m-parts DO:
    apply "choose" to b-troublp in frame {&frame-name}.
END.

ON choose OF MENU-ITEM m-recs-1 in menu m-recs DO:
assign
rdoc-line = ?
rgds-dtl = ?
r-or-v = ?
r-office = ?
r-qnty = ?
r-b-code = ?
r-pl-code = ?
r-doc-prts-qnty = ?
from-menu = yes.
assign
auto-close = input frame {&frame-name} auto-close
auto-fbr
rest-dish
rest-ingr
rest-tpsi
.

if auto-close then do:
  glog = no.
  message
  (IF not b-mail-pressed then "В течение данного сеанса работы с продажей вы не докачивали новые чеки!"
                          else "")
  "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
  skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
  buttons YES-NO update glog.
  if not glog then return no-apply.
end.
    run b-res-proc in this-procedure (
                                       buffer ink-doc
                                     , buffer t-doc
                                     , buffer ret-doc
                                     , input no
                                     , input auto-close
                                     , input no
                                     , input rest-dish
                                     , input "":U
                                     , input v-is-tpsi-obj
                                     , input rest-tpsi) no-error .
    if error-status:error  or return-value = "error" then do:
      run waitfram-hide in this-procedure .
      return no-apply.
    end.
    if auto-close and b-close:sensitive in frame {&frame-name} then do:
      assign
      v-parameter =     v-curr-r-b                     + {&delim-par} +
                        ink-doc.inkas-code             + {&delim-par} +
                      string(0) /*p-auto*/             + {&delim-par} +
                      string(auto-close)               + {&delim-par} +
                      string(b-mail-pressed)           + {&delim-par} +
                      string(auto-comp)                + {&delim-par} +
                      string(auto-fbr)                 + {&delim-par} +
                      string(one-curs)                 + {&delim-par} +
                      string(ub.shop.is-catering)      + {&delim-par} +
                      string(v-is-tpsi-obj)            + {&delim-par} +
                      string(rest-dish)                + {&delim-par} +
                      string(rest-ingr)                + {&delim-par} +
                      string(rest-tpsi)                + {&delim-par} +
                      string(neg-tpsi-weight)          + {&delim-par} +
                      string(neg-tpsi-qnty)            + {&delim-par} +
                      string(neg-tpsi-oper)            + {&delim-par} +
                      string(close-in-rfsl)            + {&delim-par} +
                      pay-gds-algo
     .
        run str/diallog.w (
              input parParentProc
            , input this-procedure
            , input ("str/saleclos.p":U + {&delim-par} + "1":U +
                    "1":U  + {&delim-par} +  /*error-message-option*/
                    "1":U + {&delim-par} +  /*auto-go-option*/
                    "1":U)                  /*return-value-option*/
            , input v-parameter
            , input no /*p-auto-go*/
            , input "":U
            , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
        ) no-error.
        if error-status:error
        or return-value = "error":U
        then do:
            run close-error-processing in this-procedure.
            return no-apply.
        end.
        else do:
          assign
          p-next-prev = ?.
          APPLY "CHOOSE" to b-exit.
        end.
    end.
    APPLY "ENTRY" to br-out.
END.

ON choose OF MENU-ITEM m-unrecs-1 in menu m-unrecs DO:
assign
rdoc-line = ?
rgds-dtl = ?
r-or-v = ?
r-office = ?
r-qnty = ?
r-b-code = ?
r-pl-code = ?
r-doc-prts-qnty = ?
from-menu = yes.
apply "choose" to b-unres in frame {&frame-name}.
APPLY "ENTRY" to br-out.
END.

{ str/sch-line.i out-dtl br-out " " " (l-out-dtl.doc-code = ink-doc.inkas-code) and " sale }
end.

on choose of b-cash in frame {&frame-name}
do:
    run str/ink-oth.w ( input parparentproc, ink-doc.inkas-code).
    apply "entry" to br-out in frame {&frame-name}.
end.

on choose of b-print in frame {&frame-name}
do:
DEFINE VARIABLE v-frame-width as integer no-undo .
define buffer t-clients for ub.clients.
    run rep/sale-prn.p (
                     input parparentproc
                    ,input recid(ink-doc)
                    ,input yes).
    apply "entry" to br-out in frame {&frame-name}.
end.

ON RIGHT-MOUSE-CLICK OF br-out
or RIGHT-MOUSE-CLICK OF BR-ret
IN FRAME {&frame-name}
DO:
define buffer buf_tt0-info for tt0-info.
assign
current-browser = self.
qh = current-browser:query.
bh = qh:get-buffer-handle({&buffer-gds-dtl}).
brwh = self .
if not bh:available then return no-apply.
assign
v-artic    = bh:buffer-field({&artic-field}):buffer-value
v-prod-type  = bh:buffer-field({&prod-type-field}):buffer-value
v-node-code  = bh:buffer-field({&prt-code-field}):buffer-value
.
FIND FIRST buf_tt0-info WHERE
          buf_tt0-info.artic = v-artic
      and buf_tt0-info.prod-type = v-prod-type
      and buf_tt0-info.prod-code = v-prod-code
      and buf_tt0-info.prt-code = v-node-code no-error .
 if available buf_tt0-info then do:
   message
   buf_tt0-info.error-message
   view-as alert-box .
 end.
END.

on choose of b-troubl in frame {&frame-name}
do:
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
define buffer buf_tt0-doc-line for tt0-doc-line.

    RUN neg-rests in this-procedure (
                   input no
                  , input ink-doc.status_
                  , input ink-doc.inkas-code
                  , input (if ink-doc.status_ = {&fact}
                          or ink-doc.status_ = {&inquiry}
                          then {&lookup} else {&update})
                  , input ub.shop.is-catering
                  , input v-is-tpsi-obj
                  , input neg-tpsi-weight
                  , input neg-tpsi-qnty
                  , input neg-tpsi-oper
                  ).
    IF can-find (first dtl-rests) then do:
        run str/badsale.w (
              input parparentproc
            , input p-mode
            , input ink-doc.inkas-code
            , input shop.is-catering
            , input v-is-tpsi-obj
            , input neg-tpsi-oper
          ).
apply "entry" to br-out in frame {&frame-name}.
for each dtl-rests:
    if t-doc.status_ <> {&fact}
    and t-doc.status_ <> {&inquiry}
    and p-mode = {&update}
    and v-is-tpsi-obj
    and dtl-rests.is-neg-tpsi-oper then do:
      find first dtl-rests-mark where
                dtl-rests-mark.artic = dtl-rests.artic
            and dtl-rests-mark.prod-type = dtl-rests.prod-type
            and dtl-rests-mark.prod-code = dtl-rests.prod-code no-error .
      if not available dtl-rests-mark then do:
        create dtl-rests-mark.
        buffer-copy dtl-rests to dtl-rests-mark.
        release dtl-rests-mark.
      end.
    end.
    delete dtl-rests.
  end. /*for each dtl-rests*/
  if can-do( {&update}, p-mode ) then do:
    disable b-close
    with frame {&frame-name} .
    b-close-enabled = no.
    RUN button-close in this-procedure (
                                            buffer t-doc
                                            ,buffer ret-doc
                                            ,input v-is-tpsi-obj
                                            ,input auto-fbr
                                            ,input neg-tpsi-weight
                                            ,input neg-tpsi-qnty
                                            ,input neg-tpsi-oper
                                            ,Output b-close-enabled).
    ENABLE
    b-close when ((auto-comp
                  and can-find(first ub.sale-doc where
                                    ub.sale-doc.inkas-code = ink-doc.inkas-code
                                and ub.sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass})
                  )
                  OR b-close-enabled)
    with frame {&frame-name} .
  end.
end.
else do:
    message "Не найдено ошибок для товаров, по которым недопустимы отрицательные остатки!"
    view-as alert-box.
    apply "entry" to br-out in frame {&frame-name}.
end.
end.

on choose of b-troublp in frame {&frame-name}
do:
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc where
       buf_Sale-doc.inkas-code = ink-doc.inkas-code:
  if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then NEXT.
  FIND FIRST ub.parts where
          ub.parts.out-code = buf_sale-doc.doc-code
      AND ub.parts.out-code = ub.parts.in-code NO-LOCK NO-ERROR.
  if available parts then do:
    LEAVE.
  end.
end.
if not available parts then do:
  message
  "Нет отрицательных партий, порожденных данной продажей!"
  view-as alert-box .
  return no-apply.
end.
run str/badsalp.w ( input parparentproc
                  , input recid(ink-doc)
                  , input recid(ub.goods)).
apply "entry" to br-out in frame {&frame-name}.
end.


on choose of b-parts in frame {&frame-name}
do:
    run proc-parts-tovar in this-procedure no-error.
    if error-status:error then return no-apply.
end.


on choose of b-chk in frame {&frame-name} do:
define variable r-rec as recid.
define variable v-rec as recid.
DEFINE VARIABLE varrid-list as character no-undo .
define buffer t-clients for ub.clients.
    { str/snd-chkp.i ink-doc.obj-code ink-doc.obj-type t-clients g#db-num ub.db  glog YES}
    if NOT glog then return no-apply.
    assign
    r-rec = bh-out-dtl:recid
    v-rec = bh-ret-dtl:recid
    .
    run str/chk-docs.w (
                     input parparentproc
                    ,input  (if p-mode = {&lookup} then '':U else "b-del":U)
                    ,input {&sale}
                    ,input ?
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input '':U
                    ,input 0 /*p-pay-desk*/
                    ,input  ?
                    ,input  ?
                    ,input 0
                    ,output varrid-list) no-error.
  if p-mode = {&update} and return-value = "deleted" then do:
    /*  пока воздержимс
    run str/inc-sale.w ( input parparentproc
                    , {&deletion}
                    , input ink-doc.host-code
                    , input ink-doc.obj-type
                    , input ink-doc.obj-code
                    , input auto-get-res
                    , input no
                    , buffer ink-doc
                    ) NO-ERROR.
      */
    run reget-br-2 in this-procedure .
    run UI-on in this-procedure .
  end.
  apply "entry" to br-out in frame {&frame-name}.
  
end.

on end-error, stop of frame {&frame-name}
do:
  run waitfram-hide in this-procedure .
  apply "CHOOSE" to b-exit in frame {&frame-name}.
  return no-apply.
end.

ON CHOOSE OF b-exit IN FRAME {&frame-name} /* Вых */
DO:
    p-next-prev = ?.
END.

ON CHOOSE OF b-close IN FRAME {&frame-name} /* Закр */
DO:
    assign
    auto-close
    auto-fbr
    rest-dish
    rest-ingr
    rest-tpsi
    .
    assign
    v-parameter =     v-curr-r-b                     + {&delim-par} +
                      ink-doc.inkas-code             + {&delim-par} +
                    string(0) /*p-auto*/             + {&delim-par} +
                    string(auto-close)               + {&delim-par} +
                    string(b-mail-pressed)           + {&delim-par} +
                    string(auto-comp)                + {&delim-par} +
                    string(auto-fbr)                 + {&delim-par} +
                    string(one-curs)                 + {&delim-par} +
                    string(ub.shop.is-catering)      + {&delim-par} +
                    string(v-is-tpsi-obj)            + {&delim-par} +
                    string(rest-dish)                + {&delim-par} +
                    string(rest-ingr)                + {&delim-par} +
                    string(rest-tpsi)                + {&delim-par} +
                    string(neg-tpsi-weight)          + {&delim-par} +
                    string(neg-tpsi-qnty)            + {&delim-par} +
                    string(neg-tpsi-oper)            + {&delim-par} +
                    string(close-in-rfsl)            + {&delim-par} +
                    pay-gds-algo

    .
    run str/diallog.w (
          input parParentProc
        , input this-procedure
        , input ("str/saleclos.p":U + {&delim-par} + "1":U +
                "1":U  + {&delim-par} +  /*error-message-option*/
                "1":U + {&delim-par} +  /*auto-go-option*/
                "1":U)                  /*return-value-option*/
        , input v-parameter
        , input no /*p-auto-go*/
        , input "":U
        , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
    ) no-error.
    if error-status:error
    or return-value = "error":U
    then do:
       run close-error-processing in this-procedure.
       return no-apply.
    end.
    else do:
      assign
      p-next-prev = ?.
    end.
END. /*choose b-close*/

ON CHOOSE OF b-res IN FRAME {&frame-name} /* Резервировать */
DO:
    assign
    auto-close
    auto-fbr
    rest-dish
    rest-ingr
    rest-tpsi
    .
    if auto-close then do:
        glog = no.
        message
        (IF not b-mail-pressed then "В течение данного сеанса работы с продажей вы не докачивали новые чеки!"
                            else "")
        "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
        skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
        buttons YES-NO update glog.
        if not glog then return no-apply.
    end.
    run b-res-proc in this-procedure (
                                      buffer ink-doc
                                     , buffer t-doc
                                     , buffer ret-doc
                                    , input no
                                    , input auto-close
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input v-is-tpsi-obj
                                    , input rest-tpsi) no-error.
    if error-status:error or return-value = "error" then do:
      run waitfram-hide in this-procedure .
      return no-apply.
    end.
    if auto-close and b-close:sensitive then do:
      assign
      v-parameter =     v-curr-r-b                     + {&delim-par} +
                        ink-doc.inkas-code             + {&delim-par} +
                      string(0) /*p-auto*/             + {&delim-par} +
                      string(auto-close)               + {&delim-par} +
                      string(b-mail-pressed)           + {&delim-par} +
                      string(auto-comp)                + {&delim-par} +
                      string(auto-fbr)                 + {&delim-par} +
                      string(one-curs)                 + {&delim-par} +
                      string(ub.shop.is-catering)      + {&delim-par} +
                      string(v-is-tpsi-obj)            + {&delim-par} +
                      string(rest-dish)                + {&delim-par} +
                      string(rest-ingr)                + {&delim-par} +
                      string(rest-tpsi)                + {&delim-par} +
                      string(neg-tpsi-weight)          + {&delim-par} +
                      string(neg-tpsi-qnty)            + {&delim-par} +
                      string(neg-tpsi-oper)            + {&delim-par} +
                      string(close-in-rfsl)            + {&delim-par} +
                      pay-gds-algo
      .
      run str/diallog.w (
            input parParentProc
          , input this-procedure
          , input ("str/saleclos.p":U + {&delim-par} + "1":U +
                  "1":U  + {&delim-par} +  /*error-message-option*/
                  "1":U + {&delim-par} +  /*auto-go-option*/
                  "1":U)                  /*return-value-option*/
          , input v-parameter
          , input no /*p-auto-go*/
          , input "":U
          , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
      ) no-error.
        if error-status:error
        or return-value = "error":U
        then do:
            run close-error-processing in this-procedure.
            return no-apply.
        end.
        else do:
          assign
          p-next-prev = ?.
          APPLY "CHOOSE" to b-exit.
        end.
    end.
END.


ON CHOOSE OF b-unres IN FRAME {&frame-name} /* Резервировать */
DO:
assign
rest-tpsi
.
run b-unres-proc (
                    buffer ink-doc
                  , buffer t-doc
                  , buffer ret-doc
                  , input v-is-tpsi-obj
                  , input no /*form-compense*/ ) No-error.

if error-status:error then do:
   run waitfram-hide in this-procedure .
   return no-apply.
 end.
END.



ON return, MOUSE-SELECT-DBLCLICK OF br-out
or return, MOUSE-SELECT-DBLCLICK OF br-ret IN FRAME {&frame-name}
DO:
  if self:sensitive then do:
    apply "choose" to r-trn in frame {&frame-name}.
  end.
  return no-apply.
END.

ON choose OF r-trn IN FRAME {&frame-name}
DO:
define buffer t-clients for ub.clients.
{ str/snd-chkp.i ink-doc.obj-code ink-doc.obj-type t-clients g#db-num ub.db  glog YES}
    if NOT glog then return no-apply.
    run proc-chek-tovar in this-procedure no-error.
    IF error-status:error then return no-apply.
END.

ON choose OF b-places IN FRAME {&frame-name}
DO:
    run proc-places in this-procedure no-error.
    IF error-status:error then return no-apply.
    if v-to-reserv then do :
        assign
            auto-close
            auto-fbr
            rest-dish
            rest-ingr
            rest-tpsi
        .
        if auto-close then do:
            glog = no.
            message
            (IF not b-mail-pressed then "В течение данного сеанса работы с продажей вы не докачивали новые чеки!"
                                else "")
            "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
            skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
            buttons YES-NO update glog.
            if not glog then return no-apply.
        end.
        run b-res-proc in this-procedure (
                                          buffer ink-doc
                                         , buffer t-doc
                                         , buffer ret-doc
                                        , input no
                                        , input auto-close
                                        , input no
                                        , input rest-dish
                                        , input "":U
                                        , input v-is-tpsi-obj
                                        , input rest-tpsi) no-error.
        if error-status:error or return-value = "error" then do:
          run waitfram-hide in this-procedure .
          return no-apply.
        end.
        if auto-close and b-close:sensitive then do:
          assign
          v-parameter =     v-curr-r-b                     + {&delim-par} +
                            ink-doc.inkas-code             + {&delim-par} +
                          string(0) /*p-auto*/             + {&delim-par} +
                          string(auto-close)               + {&delim-par} +
                          string(b-mail-pressed)           + {&delim-par} +
                          string(auto-comp)                + {&delim-par} +
                          string(auto-fbr)                 + {&delim-par} +
                          string(one-curs)                 + {&delim-par} +
                          string(ub.shop.is-catering)      + {&delim-par} +
                          string(v-is-tpsi-obj)            + {&delim-par} +
                          string(rest-dish)                + {&delim-par} +
                          string(rest-ingr)                + {&delim-par} +
                          string(rest-tpsi)                + {&delim-par} +
                          string(neg-tpsi-weight)          + {&delim-par} +
                          string(neg-tpsi-qnty)            + {&delim-par} +
                          string(neg-tpsi-oper)            + {&delim-par} +
                          string(close-in-rfsl)            + {&delim-par} +
                          pay-gds-algo
          .
          run str/diallog.w (
                input parParentProc
              , input this-procedure
              , input ("str/saleclos.p":U + {&delim-par} + "1":U +
                      "1":U  + {&delim-par} +  /*error-message-option*/
                      "1":U + {&delim-par} +  /*auto-go-option*/
                      "1":U)                  /*return-value-option*/
              , input v-parameter
              , input no /*p-auto-go*/
              , input "":U
              , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
          ) no-error.
            if error-status:error
            or return-value = "error":U
            then do:
                run close-error-processing in this-procedure.
                return no-apply.
            end.
            else do:
              assign
              p-next-prev = ?.
              APPLY "CHOOSE" to b-exit.
            end.
        end.    
    end.       
END.

ON choose OF b-notes IN FRAME {&frame-name}
DO:
define variable notes as character no-undo .
define variable v-recid as recid no-undo .
notes = substr(ink-doc.PS, index(ink-doc.PS, "@") + 1).
v-recid = recid(ink-doc).
run gbl/notes.w ( input p-mode, input-output notes ).
if ink-doc.PS <> notes then  do:
    do on stop undo, return no-apply:
        FIND FIRST ink-doc WHERE recid (ink-doc) = p-doc-rec exclusive.
        ink-doc.PS = substr(ink-doc.PS, 1, index(ink-doc.PS, "@")) +  notes.
    end.
end.
END.

ON choose OF b-troublc IN FRAME {&frame-name}
DO:
define variable r-rec as recid.
define variable v-rec as recid.
define variable glog as logical no-undo .
define buffer t-clients for ub.clients.
  { str/snd-chkp.i ink-doc.obj-code ink-doc.obj-type t-clients g#db-num ub.db  glog YES}
  if NOT glog then return no-apply.
  assign
  r-rec = recid(out-dtl)
  v-rec= recid(ret-dtl)
  .
  run str/badcheck.w (
                    input parparentproc
                  , input p-mode
                  , buffer ink-doc
                  , input prcl-spl
                  , input v-curr-r-b) no-error .
  if return-value = "yes" then do:
      run UI-on in this-procedure .
      apply "entry" to br-out in frame {&frame-name}.
      reposition br-out to recid r-rec no-error.
  end.
  apply "entry" to br-out in frame {&frame-name}.
END.

ON CHOOSE OF b-mail IN FRAME {&frame-name}
or Right-Mouse-CLICK OF b-mail IN FRAME {&frame-name}
DO:
  if last-event:lABEL = "CHOOSE"
  or last-event:lABEL = "ENTER"
  then do:
    run str/diallog.w (
                  input parparentproc
                , input this-procedure
                , input 'str/get-chkf.p':U
                , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(0))
                , input (if auto-get-res then yes else no) /*p-auto-go*/
                , input '':U
                , input 'Прием чеков с касс') no-error .

    if error-status:error then return no-apply.
  end.
  p-doc-rec = recid (ink-doc).
  DO TRANSACTION on ERROR undo, return no-apply
                        on STOP undo, return no-apply :
    run str/inc-sale.w (
                      input parparentproc
                    , input {&update}
                    , input ink-doc.host-code
                    , input ink-doc.obj-type
                    , input ink-doc.obj-code
                    , input auto-get-res
                    , input no /*v-is-tpsi-obj*/
                    , buffer ink-doc
                    ) NO-ERROR.
    if return-value = "cancell":U then undo, return no-apply .
    run reget-br-2 in this-procedure .
  END.
  RUN UI-on in this-procedure .
  b-mail-pressed = yes.
  if auto-get-res then do:
    assign
    auto-close
    auto-fbr
    rest-dish
    rest-ingr
    rest-tpsi
    .
    if auto-close then do:
            glog = no.
        message
        "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
        skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
        buttons YES-NO update glog.
        if not glog then return no-apply.
    end.    /*auto-close*/
    run b-res-proc in this-procedure (
                                      buffer ink-doc
                                    , buffer t-doc
                                    , buffer ret-doc
                                    , input no
                                    , input auto-close
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input v-is-tpsi-obj
                                    , input rest-tpsi) no-error.
    if error-status:error or return-value = "error" then do:
      run waitfram-hide in this-procedure .
      return no-apply.
    end.
    if auto-close and b-close:sensitive then do:
      assign
      v-parameter =     v-curr-r-b                     + {&delim-par} +
                        ink-doc.inkas-code             + {&delim-par} +
                      string(0) /*p-auto*/             + {&delim-par} +
                      string(auto-close)               + {&delim-par} +
                      string(b-mail-pressed)           + {&delim-par} +
                      string(auto-comp)                + {&delim-par} +
                      string(auto-fbr)                 + {&delim-par} +
                      string(one-curs)                 + {&delim-par} +
                      string(ub.shop.is-catering)      + {&delim-par} +
                      string(v-is-tpsi-obj)            + {&delim-par} +
                      string(rest-dish)                + {&delim-par} +
                      string(rest-ingr)                + {&delim-par} +
                      string(rest-tpsi)                + {&delim-par} +
                      string(neg-tpsi-weight)          + {&delim-par} +
                      string(neg-tpsi-qnty)            + {&delim-par} +
                      string(neg-tpsi-oper)            + {&delim-par} +
                      string(close-in-rfsl)            + {&delim-par} +
                      pay-gds-algo
      .
      run str/diallog.w (
            input parParentProc
          , input this-procedure
          , input ("str/saleclos.p":U + {&delim-par} + "1":U +
                  "1":U  + {&delim-par} +  /*error-message-option*/
                  "1":U + {&delim-par} +  /*auto-go-option*/
                  "1":U)                  /*return-value-option*/
          , input v-parameter
          , input no /*p-auto-go*/
          , input "":U
          , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
      ) no-error.
      if error-status:error
      or return-value = "error":U
        then do:
          run close-error-processing in this-procedure.
          return no-apply.
      end.
      else do:
        assign
        p-next-prev = ?.
        APPLY "CHOOSE" to b-exit.
      end.
    end.
  end. /*auto-get-res*/
END.

ON VALUE-CHANGED OF Cb-doc-kind IN FRAME {&frame-name}
DO:

define buffer buf_sale-doc for ub.sale-doc.

ASSIGN
CB-doc-kind
br-2-mode = CB-doc-kind
.
find first buf_sale-doc where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
      and buf_sale-doc.doc-kind = entry(1, br-2-mode, {&delim-par})
      and buf_sale-doc.chr-office = entry(2, br-2-mode, {&delim-par}).
br-2-doc-code = buf_sale-doc.doc-code.
run openbr in this-procedure ( input ink-doc.inkas-code,  input br-2-doc-code, input yes, input no, input '':U, input '':U).
APPLY "value-changed" to br-out.
APPLY "value-changed" to br-ret.
run enable-menu-items in this-procedure .
END.
ON value-changed OF rs-sort IN FRAME {&frame-name}
DO:
  rs-sort = input frame {&frame-name} rs-sort.
  assign
  sort-column-name-out = '':U
  sort-column-name-ret = '':U
  .
  RUN UI-on in this-procedure .
END.

ON value-changed OF auto-fbr IN FRAME {&frame-name}
DO:
  assign
  auto-fbr.
  case auto-fbr:
    when yes then do:
      display
      rest-dish
      rest-ingr
      with frame {&frame-name} .
      enable
      rest-dish
      rest-ingr
      with frame {&frame-name} .
    end.
    when no then do:
      disable
      rest-dish
      rest-ingr
      with frame {&frame-name} .
      hide
      rest-dish
      rest-ingr
      in frame {&frame-name} .
    end.
  END.
END.

ON value-changed OF rest-tpsi IN FRAME {&frame-name}
DO:
    assign rest-tpsi.
END.


ON value-changed OF
br-out,
br-ret IN FRAME {&frame-name} DO:
qh = self:query.
bhg = qh:get-buffer-handle({&buffer-goods}).
gds-rec = bhg:recid.
if not bhg:available then return no-apply.
assign
v-prod-type = bhg:buffer-field({&prod-type-field}):buffer-value
v-prod-code = bhg:buffer-field({&prod-code-field}):buffer-value
v-gds-code = bhg:buffer-field({&gds-code-field}):buffer-value
.
 FIND FIRST ub.clients where
          ub.clients.obj-type = v-prod-type
      AND ub.clients.obj-code = v-prod-code NO-LOCK NO-ERROR.
if self = brwh-out-dtl then do:
    assign
    prod-name-r = (if available ub.clients
                   then substitute("Пр-ль: &1", ub.clients.obj-name)
                   else '':U).
end.
if self = brwh-ret-dtl then do:
    assign
    prod-name-v = (if available ub.clients
                   then substitute("Пр-ль: &1", ub.clients.obj-name)
                   else '':U).
end.
display
prod-name-r
prod-name-v
with frame {&frame-name}.
IF mImagePh THEN
DO:
    DEFINE VARIABLE vImageList AS LONGCHAR    NO-UNDO.
    DEFINE VARIABLE vCh        AS CHARACTER   NO-UNDO.
    RUN gds-attr-value ( v-gds-code, "image-list":U, OUTPUT vImageList, OUTPUT vCh).
    RUN imagelist_decode IN THIS-PROCEDURE (INPUT vImageList, v-gds-code, OUTPUT vImageList).
    vCh = ENTRY (1, vImageList, {&ImageDelimiter}).
    g-image:LOAD-IMAGE (ENTRY (1, vCh)) NO-ERROR.
    ASSIGN
        g-image:HIDDEN     = NO
        g-image:VISIBLE    = YES
        g-image:SENSITIVE  = YES
        .
END.
ELSE
    ASSIGN
        g-image:HIDDEN     = YES
        g-image:VISIBLE    = NO
        g-image:SENSITIVE  = NO
        .
END.

ON CHOOSE OF b-arch IN FRAME {&frame-name} /* Просмотр в учетных ценах */
DO:
/*todo!!!*/
define variable v-notes as character no-undo .
define variable v-inkas-base as decimal no-undo .
define variable v-cost-sum as decimal no-undo .
define buffer buf_inkas-pay for ub.inkas-pay.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
if t-doc.status_ = {&fact}
or ink-doc.status_ = {&inquiry}
then do:
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_archive_cost':U
  {&cntxt-object}
  ink-doc.host-code
  ink-doc.obj-type
  ink-doc.obj-code
  0
  0
  0
  true
  glog
}
if NOT glog then return no-apply.
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-inkas-base = ink-doc.netto
  .
end.
else do:
  for each buf_inkas-pay no-lock where
          buf_inkas-pay.inkas-code = ink-doc.inkas-code:
    assign
    v-inkas-base = v-inkas-base + buf_inkas-pay.tot-base
    .
  end.
end.
 for each buf_sale-doc no-lock where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
      and buf_sale-doc.in-inkas = yes,
         first buf_trn-doc no-lock where
              buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    v-cost-sum = v-cost-sum + buf_trn-doc.fact-base  * buf_sale-doc.dir
    .
  end.
  message
  "Оборот товара в учетных ценах:" skip
  string(v-cost-sum , "->>,>>>,>>9.99") v-base-type skip (2)


  "Оборот товара в продажных ценах с учетом скидки:" skip
  string (v-inkas-base, "->>,>>>,>>9.99") v-base-type skip (2)
  "Разница:" skip
  string (v-inkas-base - v-cost-sum, "->>,>>>,>>9.99") v-base-type skip (2)

  "Наценка:"
  string ((v-inkas-base - v-cost-sum) / v-cost-sum * 100, "->>9.9<%")

  view-as alert-box title "Док-т №: " + string (t-doc.doc-code) + "  от: " + string (t-doc.doc-date)
    + (IF cas-shft then (" смена N " + shift-name-no-err(buffer ink-doc)) else "")
    + (IF one-curs then (" чеки по курсу " + string(t-doc.base-rate / t-doc.base-scale)) else "") .


end.
else do:
    run str/chk-inf.p (
                      input parparentproc
                    ,input v-host-code
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input yes
                    ,input yes
                    ,recid (ink-doc)
                    ,output v-notes
                    ,output not-all-saled-chk
                    ,output not-all-normal-chk
                    ,output not-all-inkas-closed
                    ).
  end.
END.

ON CHOOSE OF b-next IN FRAME {&frame-name}
DO:
run reposition-inkas in this-procedure
  (input 'next':U
  ).
END.

ON CHOOSE OF b-prev IN FRAME {&frame-name}
DO:
run reposition-inkas in this-procedure
  (input 'prev':U
  ).
END.

/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ? THEN
FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i &disable_diasize_init=true &browse-name="br-out"}
{ gbl/hot-key.i b-exit }
{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-close }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
rs-sort = "off":U.
/* зацикливание формы */
p-next-prev = '':U.

assign
p-obj-type = ink-doc.obj-type
p-obj-code = ink-doc.obj-code
.
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-autosale}
    ,input  "":U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF error-status:error then do:
  message
  substitute("Ошибка при получении опций продажи НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-obj-type
            , p-obj-code
            , {&new-line}
            , error-status:get-message(1)
            , return-value )
  view-as alert-box error .
  return error.
end.
for each  thbjattr_thbj-attr where
          thbjattr_thbj-attr.obj-type = p-obj-type
      and thbjattr_thbj-attr.obj-code = p-obj-code
      and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)):
  case thbjattr_thbj-attr.prop-code:
    when {&attr-autosale_autoclos} then do:
      autoclose = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_autocalc} then do:
      autocalc = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_automail} then do:
      auto-mail = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_augetres} then do:
      auto-get-res = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_autocomp} then do:
      auto-comp = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_autofbr} then do:
      autofbr = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_one-curs} then do:
      one-curs = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_restdish} then do:
      restdish = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_restingr} then do:
      restingr = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_resttpsi} then do:
      resttpsi = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_prcl-spl} then do:
      prcl-spl = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_neg-tpsi-weight} then do:
      neg-tpsi-weight = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_neg-tpsi-oper} then do:
      neg-tpsi-oper = thbjattr_thbj-attr.property-value-logical.
    end.
    when {&attr-autosale_neg-tpsi-qnty} then do:
      neg-tpsi-qnty = thbjattr_thbj-attr.property-value-decimal.
    end.
    when {&attr-autosale_close-in-rfsl} then do:
      close-in-rfsl = thbjattr_thbj-attr.property-value-integer.
    end.
    when {&attr-autosale_pay-gds-algo} then do:
      pay-gds-algo = thbjattr_thbj-attr.property-value-character.
    end.
  end case.
  assign
  restdish = restdish and autofbr
  restingr = restingr and autofbr
  resttpsi = resttpsi and v-is-tpsi-obj
  .
end.
btltaxcd = integer({&road-tax-code}).
if btltaxcd > 0 then do:
    FIND FIRST ub.tax No-LOCK WHERE ub.tax.tax-code = btltaxcd No-ERROR.
    if not available ub.tax then do:
        message "Не найден налог (доп.компонента для цены) стеклопосуды!" view-as alert-box ERROR.
        return error.
    end.
end.

on f6 anywhere do:
  run str/inc-sale.w (
                  input parparentproc
                , input {&lookup}
                , input ink-doc.host-code
                , input ink-doc.obj-type
                , input ink-doc.obj-code
                , input auto-get-res
                , input yes /*v-is-tpsi-obj*/
                , buffer ink-doc
                ) NO-ERROR.

end.

/*
{ gbl/mv-clmn.i
 &ext-col = 4
 &frame-name = "{&frame-name}"
 &browse-name = "br-out"
 &table-name = "out-dtl"
 &start-column = 5
 &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15'"
 &prev-order-column-condition_1 = " yes "
}
{ gbl/mv-clmn.i
 &ext-col = 4
 &frame-name = "{&frame-name}"
 &browse-name = "br-ret"
 &table-name = "ret-dtl"
 &start-column = 5
 &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14'"
 &prev-order-column-condition_1 = " yes "
}
*/



n-p: do while p-next-prev = '':U:
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }
  
    run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-ret :handle
    ) .

    run diasize_init in this-procedure .
    
    { gbl/f2.i br-out goods-recid get-gds-rec  parparentproc }
    p-doc-rec = recid (ink-doc).  /* подстраховка на время перехода со старого варианта,
                                                т.к. эта переменная исп-ся при закрытии.
                                              Вообще она должна инициироваться перед вызовом sale.w */
    { gbl/curr-r-b.i
      v-curr-r-b
    }
    find first ub.shop no-lock where
               ub.shop.obj-code = ink-doc.obj-code.
    FIND FIRST t-doc WHERE t-doc.doc-code = ink-doc.inkas-code NO-LOCK.
    FIND FIRST ret-doc WHERE ret-doc.doc-code = t-doc.out-code NO-LOCK no-error.
    assign
    t-code = t-doc.doc-code
    ret-code = (if available ret-doc then ret-doc.doc-code else '':U)
    bh-out-dtl = buffer out-dtl:handle
    bh-ret-dtl = buffer ret-dtl:handle
    bh-out-goods = buffer out-goods:handle
    bh-ret-goods = buffer ret-goods:handle
    brwh-out-dtl = browse br-out:handle
    brwh-ret-dtl = browse br-ret:handle
    v-is-inquiry = (t-doc.status_ = {&inquiry})
    v-log-handle = this-procedure.
    .
    /* проверка "закольцованности" ссылок */
    if available ret-doc and ret-doc.out-code <> t-doc.doc-code then   do:
      message
      "Данный расходный документ не является отчетом о продаже."
      view-as alert-box INFORMATION .
      p-next-prev = ?.
      return error.
    end.
    { gbl/basecode.i v-host-code v-base-code }
    { gbl/objdbnum.i {&shop}  ub.shop.obj-code v-db-num }
    find first buf_currency no-lock where
              buf_currency.curr-code = v-base-code.
    assign
    v-base-type = buf_currency.curr-abbr
    .
    define variable v-h as handle no-undo .
    define variable v-h-out as handle no-undo extent 30.
    define variable v-ii as integer no-undo init 1.
    v-h = br-out:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
    v-ii = 1.
    DO while valid-handle(v-h) :
       v-h-out[v-ii] = v-h.
       v-h = v-h:NEXT-COLUMN.
       v-ii = v-ii + 1.
    END.
    if (can-do( {&update}, p-mode )
    or ink-doc.status_ = {&g___new})
    then do:
      run gbl/tpsi-obj.p (
                           input p-obj-type
                         , input p-obj-code
                         , output v-is-tpsi-obj) no-error .
      if v-is-tpsi-obj then
      br-out:num-locked-columns = 3.
      else do:
        assign
        v-h-out[{&num-clmn_7-out}]:visible = no
        v-h-out[{&num-clmn_8-out}]:visible = no
        .
      end.
    end.
    else do:
      assign
      v-h-out[{&num-clmn_7-out}]:visible = no
      v-h-out[{&num-clmn_8-out}]:visible = no
      .
       assign
       neg-tpsi-weight = no
       neg-tpsi-qnty = 0
       neg-tpsi-oper = no
       resttpsi = no
       .
    end.
    run reget-br-2 in this-procedure .
    if can-find(first tpsi_sale-doc where
                     tpsi_sale-doc.inkas-code = ink-doc.inkas-code
                 and tpsi_sale-doc.tpsidoc = yes)
    then v-is-tpsi-obj = yes.
    if v-is-tpsi-obj then do:
      run tpsi-gds-fill-tpsi-obj-table in this-procedure ( input v-db-num) no-error .
      if error-status:error then do:
        message
        substitute("Ошибки при заполнении врем. таблицы объектов-членов ТПСИ на БД &1", v-db-num) skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    if (v-is-tpsi-obj)
    and can-do( {&update}, p-mode )
    or ink-doc.status_ = {&g___new}
    then do:
      if not v-is-inquiry then do:
        run waitfram-show in this-procedure ("Ждите.. получение информации по резервированию ЧУЖИХ товаров" ).
        run fill-tt-tpsi-table  in this-procedure ( input ink-doc.inkas-code
                                                  , input ink-doc.host-code
                                                  , input ink-doc.obj-type
                                                  , input ink-doc.obj-code).
        run waitfram-hide in this-procedure .
      end.
    end.
        /*найдем параметр - использовать смены на кассе или нет*/
    { gbl/cas-shft.i p-obj-type p-obj-code cas-shft }
    RUN UI-on in this-procedure .
    APPLY "ENTRY" to br-out.
    if can-do( {&update}, p-mode ) and not auto-mail then do:
        message "Докачка чеков в продажу осуществляется нажатием" skip
        "              на кнопку ПРИЕМ ЧЕКОВ!"
        view-as alert-box WARNING.
    END.
    if can-do( {&update}, p-mode ) AND auto-mail then do:
      run str/diallog.w (
                    input parparentproc
                  , input this-procedure
                  , input 'str/get-chkf.p':U
                  , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(0))
                  , input yes /*p-auto-go*/
                  , input '':U
                  , input 'Прием чеков с касс') no-error .
      if error-status:error then return error.
      p-doc-rec = recid (ink-doc).
      DO TRANSACTION on ERROR undo, leave
                            on STOP undo, leave:
          run str/inc-sale.w (
                          input parparentproc
                        , input {&update}
                        , input ink-doc.host-code
                        , input ink-doc.obj-type
                        , input ink-doc.obj-code
                        , input auto-get-res
                        , input no /*v-is-tpsi-obj*/
                        , buffer ink-doc
                        ) NO-ERROR.
      END.
      if (auto-get-res
      or auto-mail)
      and not return-value = "cancell":U
      and not v-is-inquiry then do:
        run reget-br-2 in this-procedure .
        run openbr in this-procedure ( input ink-doc.inkas-code,  input br-2-doc-code, input yes, input no, input '':U, input '':U).
      END.
      if auto-get-res
      and not return-value = "cancell":U then do:
        assign
        auto-close
        auto-fbr
        rest-dish
        rest-ingr
        rest-tpsi
        .
        if auto-close then do:
            glog = no.
            message
            "ВНИМАНИЕ!!! Включен режим автоматического закрытия продажи по результатам резервирования!"
            skip "Вы уверены, что хотите закрыть продажу?" view-as alert-box WARNING
            buttons YES-NO update glog.
            if not glog then return no-apply.
        end.
      /*перечитаем буфер возврата - так как в начале его может не быть*/
      FIND FIRST ret-doc WHERE ret-doc.doc-code = t-doc.out-code NO-LOCK no-error.
      run b-res-proc in this-procedure (
                                          buffer ink-doc
                                        , buffer t-doc
                                        , buffer ret-doc
                                        , input no
                                        , input auto-close
                                        , input no
                                        , input rest-dish
                                        , input "":U
                                        , input v-is-tpsi-obj
                                        , input rest-tpsi) no-error.
      if not error-status:error then do:
        if auto-close and b-close:sensitive then do:
        assign
        v-parameter =     v-curr-r-b                     + {&delim-par} +
                          ink-doc.inkas-code             + {&delim-par} +
                        string(0) /*p-auto*/             + {&delim-par} +
                        string(auto-close)               + {&delim-par} +
                        string(b-mail-pressed)           + {&delim-par} +
                        string(auto-comp)                + {&delim-par} +
                        string(auto-fbr)                 + {&delim-par} +
                        string(one-curs)                 + {&delim-par} +
                        string(ub.shop.is-catering)      + {&delim-par} +
                        string(v-is-tpsi-obj)            + {&delim-par} +
                        string(rest-dish)                + {&delim-par} +
                        string(rest-ingr)                + {&delim-par} +
                        string(rest-tpsi)                + {&delim-par} +
                        string(neg-tpsi-weight)          + {&delim-par} +
                        string(neg-tpsi-qnty)            + {&delim-par} +
                        string(neg-tpsi-oper)            + {&delim-par} +
                        string(close-in-rfsl)            + {&delim-par} +
                        pay-gds-algo
        .
        run str/diallog.w (
              input parParentProc
            , input this-procedure
            , input ("str/saleclos.p":U + {&delim-par} + "1":U +
                    "1":U  + {&delim-par} +  /*error-message-option*/
                    "1":U + {&delim-par} +  /*auto-go-option*/
                    "1":U)                  /*return-value-option*/
            , input v-parameter
            , input no /*p-auto-go*/
            , input "":U
            , input substitute("Закрытие продажи &1", Ink-doc.inkas-code)
        ) no-error.
        if error-status:error
        or return-value = "error":U
        then do:
            run close-error-processing in this-procedure.
            return no-apply.
        end.
        else do:
          assign
          p-next-prev = ? .
          leave n-p.
        end.
      end.
    end.
    else do:
      run waitfram-hide in this-procedure .
    end.
  end. /*if auto-clos*/
  RUN UI-on in this-procedure .
  b-mail-pressed = yes.
end. /*if auto-mail*/

WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-out.
END.
end. /* do while */

RUN disable_UI.

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME d-sale.
END PROCEDURE.

PROCEDURE UI-on :
/* --------------------------------------------------------------------------*/
assign
v-prt-name:resizable in browse br-out = yes
v-prt-name:resizable in browse br-ret = yes
{&sort-clmn_15-out}:read-only in browse br-out = yes
{&sort-clmn_34-ret}:read-only in browse br-ret = yes
.
disable all with frame {&frame-name}.
assign
auto-close
auto-fbr
rest-dish
rest-ingr
rest-tpsi
.
run enable-menu-items in this-procedure .
if v-list-item-pairs <> '':U then do:
assign
cb-doc-kind:list-item-pairs in frame {&frame-name} =  trim(v-list-item-pairs).
cb-doc-kind = br-2-mode.
display
cb-doc-kind
with frame {&frame-name} .
end.
run frame-title in this-procedure .
assign
s-pc = ink-doc.discnt / ink-doc.tot-doc * 100
loc-art = ""
auto-close = if just-entered then autoclose else auto-close
auto-fbr =  if just-entered and ub.shop.is-catering then autofbr else auto-fbr
rest-dish =  if just-entered and autofbr then restdish else rest-dish
rest-ingr =  if just-entered and autofbr then restingr else rest-ingr
rest-tpsi =  if just-entered and v-is-tpsi-obj then resttpsi else rest-tpsi
just-entered = no.
hide loc-art in frame {&frame-name} loc-name loc-code in frame {&frame-name}.
DISPLAY
auto-close
auto-fbr when shop.is-catering and can-do( {&update}, p-mode )
rest-tpsi
with frame {&frame-name}.
ENABLE b-exit
              b-prev WHEN NOT can-do( {&update}, p-mode )
              b-next WHEN NOT can-do( {&update}, p-mode )
              b-cash b-arch
              b-notes b-help a-n-c br-out br-ret
              b-chk r-trn
              b-troubl when (NOT t-doc.status_ = {&fact}  and not v-is-inquiry)
              b-troublp  when not v-is-inquiry
              b-troublc
              b-places when (NOT t-doc.status_ = {&fact} and can-do( {&update}, p-mode ))
              b-parts when NOT v-is-inquiry
              prod-name-r
              cb-doc-kind when v-list-item-pairs <> '':U and num-entries(cb-doc-kind:list-item-pairs) > 2
              prod-name-v
              b-print
              with frame {&frame-name}.
  if can-do( {&update}, p-mode ) then do:
    disable b-close
    with frame {&frame-name} .
    b-close-enabled = no.
    RUN button-close in this-procedure (
                                            buffer t-doc
                                           ,buffer ret-doc
                                           ,input v-is-tpsi-obj
                                           ,input auto-fbr
                                           ,input neg-tpsi-weight
                                           ,input neg-tpsi-qnty
                                           ,input neg-tpsi-oper
                                           ,Output b-close-enabled).
    ENABLE
    b-close when ((auto-comp
                and can-find(first ub.sale-doc where
                                  ub.sale-doc.inkas-code = ink-doc.inkas-code
                              and ub.sale-doc.doc-kind = {&TDEDT_Vozvrat_Vnesh_Kass})
                )
                OR b-close-enabled)
    b-res when not v-is-inquiry
    b-unres when not v-is-inquiry
    b-mail
    auto-close when not v-is-inquiry
    auto-fbr when (shop.is-catering and not v-is-inquiry)
    rest-tpsi when (v-is-tpsi-obj and not v-is-inquiry)
    with frame {&frame-name}.
    if not shop.is-catering then do:
      hide
      auto-fbr
      in frame {&frame-name} .
    end.
    apply "VALUE-CHANGED" to auto-fbr.
end.
if can-do( {&lookup}, p-mode ) then do:
    ENABLE rs-sort with frame {&frame-name}.
    hide
    auto-fbr rest-dish rest-ingr rest-tpsi
    in frame {&frame-name} .
end.
apply "VALUE-CHANGED" to br-out.
apply "VALUE-CHANGED" to br-ret.
IF NOT (t-doc.status_ = {&fact}
or ink-doc.status_ = {&inquiry})
then do:
    assign
    menu-item m-arch-i:label in menu m-arch = "Чеки-продажи"
    b-arch:label = "Ин&фор."
    .
end.
display
ink-doc.qnty ink-doc.num-chk rs-sort ink-doc.tot-doc ink-doc.discnt
ink-doc.netto @ s-netto
s-pc WHEN abs( s-pc ) < 1000
ink-doc.sub-discnt
        with frame {&frame-name}.
if s-pc = ? or s-pc > 1000 and s-pc:visible in frame {&frame-name} then do:
hide s-pc.
end.
run shapka in this-procedure .
FIND FIRST t-doc WHERE t-doc.doc-code= ink-doc.inkas-code NO-LOCK.
FIND FIRST ret-doc WHERE ret-doc.doc-code = t-doc.out-code NO-LOCK no-error.
run openbr in this-procedure ( input t-doc.doc-code, input br-2-doc-code, input yes, input no, input '':U, input '':U).
APPLY "value-changed" to br-out.
APPLY "value-changed" to br-ret.
{ gbl/currsysk.i
  v-sys-key
  no-error
}                      
if v-sys-key begins "Rosneft-" or v-sys-key eq "ibs" or v-sys-key eq "yukos"  then hide b-places in frame {&frame-name}.
    
run waitfram-hide in this-procedure .
END PROCEDURE.

procedure OpenBr :
define input parameter p-br1-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-br2-doc-code like ub.trn-doc.doc-code no-undo .
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define input parameter p-caller as character no-undo .

define variable sort-column-phrase as character no-undo .
define variable l-open-query as logical   no-undo .
define variable l-query-was-opened as logical no-undo .
define variable v-sort-phrase1 as character no-undo .
define variable v-sort-phrase2 as character no-undo .

&scop sale-doc-kind  entry(1, br-2-mode, {&delim-par})
if br-2-mode = {&delim-par} then browse br-ret:title  = "[Нет второго документа по продаже для просмотра]" no-error .
else
assign
browse br-ret:title  = substitute("&1 &2 &3", {&sale-doc-name}, entry(2, br-2-mode, {&delim-par}), br-2-doc-code) no-error .
run waitfram-show in this-procedure ( input "Ждите...").

&scop flt-open-call-point 'sale'

&scop flt-open-debug-file


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

/*
&scop flt-open-call-point filter-point

 &scop flt-open-set-filter-name set-filter-name
*/

&scop flt-open-indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-def define buffer l-out-dtl for ub.gds-dtl.

&Scop flt-open-waitfram yes

&scop use-ind

if lookup( 'ИЗМЕНЕНИЕ':U, p-mode ) > 0 then  do:
  assign
  v-sort-phrase1 = " by ( out-dtl.doc-qnty = out-dtl.fact-qnty ) "
  v-sort-phrase2 = " by ( ret-dtl.doc-qnty = ret-dtl.fact-qnty ) "
  .
end.
else do:
  CASE rs-sort :
    when "discount":U then  do:      /* при просмотре - сортировку по скидке */
      assign
      v-sort-phrase1 = " by ( out-dtl.discnt-base / out-dtl.price-base ) "
      v-sort-phrase2 = " by ( ret-dtl.discnt-base / ret-dtl.price-base ) "
      .
    end.
    when "quantity":U then do:      /* при просмотре - сортировку по количеству */
      assign
      v-sort-phrase1 = " by ( out-dtl.fact-qnty ) "
      v-sort-phrase2 = " by ( ret-dtl.fact-qnty ) "
      .
    end.
    when "price":U then do:      /* при просмотре - сортировку по цене */
      assign
      v-sort-phrase1 = " by ( out-dtl.price-base ) "
      v-sort-phrase2 = " by ( ret-dtl.price-base ) "
      .
    end.
    when "summa":U then do:      /* при просмотре - сортировку по сумме */
      assign
      v-sort-phrase1 = " by ( out-dtl.fact-qnty * out-dtl.price-base ) "
      v-sort-phrase2 = " by ( ret-dtl.fact-qnty * ret-dtl.price-base ) "
      .
    end.
    when "off":U then do:      /* сортировка выключена */
      assign
      v-sort-phrase1 = "  "
      v-sort-phrase2 = "  "
      .
    end.
  END CASE .
end.

&scop flt-open-open-query   OPEN QUERY br-out FOR EACH out-dtl NO-LOCK

&scop flt-open-dyn_open-query   FOR EACH out-dtl NO-LOCK

&scop flt-open-query-handle  query br-out:handle

&scop flt-open-open-query-tail      FIRST out-prt NO-LOCK WHERE out-prt.node-code = out-dtl.prt-code , FIRST ~
out-goods NO-LOCK WHERE out-goods.artic = out-dtl.artic ~
AND out-goods.prod-code = out-dtl.prod-code ~
AND out-goods.prod-type = out-dtl.prod-type ,  FIRST out-bar ~
NO-LOCK WHERE out-bar.gds-code = out-goods.gds-code ~
AND out-bar.node-code = out-dtl.prt-code ~
AND out-bar.in-code = v-empty ~
AND out-bar.part-code = v-empty ~
AND out-bar.unit-cli = out-goods.unit-base, first out-tt0-dtl where ~
out-tt0-dtl.artic = out-dtl.artic ~
and out-tt0-dtl.prod-type = out-dtl.prod-type ~
and out-tt0-dtl.prod-code = out-dtl.prod-code ~
and out-tt0-dtl.prt-code = out-dtl.prt-code outer-join


&scop flt-open-dyn_open-query-tail   substitute('   FIRST out-prt NO-LOCK WHERE out-prt.node-code = out-dtl.prt-code , FIRST ~
out-goods NO-LOCK WHERE out-goods.artic = out-dtl.artic ~
AND out-goods.prod-code = out-dtl.prod-code ~
AND out-goods.prod-type = out-dtl.prod-type ,  FIRST out-bar ~
NO-LOCK WHERE out-bar.gds-code = out-goods.gds-code ~
AND out-bar.node-code = out-dtl.prt-code ~
AND out-bar.in-code = &1&1 ~
AND out-bar.part-code = &1&1 ~
AND out-bar.unit-cli = out-goods.unit-base, first out-tt0-dtl where ~
out-tt0-dtl.artic = out-dtl.artic ~
and out-tt0-dtl.prod-type = out-dtl.prod-type ~
and out-tt0-dtl.prod-code = out-dtl.prod-code ~
and out-tt0-dtl.prt-code = out-dtl.prt-code outer-join ', ~{&double-quote~})


&scop flt-open-table-name out-dtl

case sort-column-name-out :
  when "" then do:
  assign
    sort-column-phrase = v-sort-phrase1
  .
  end.
  otherwise do:
  assign
    sort-column-phrase = " by " + sort-column-name-out
  .
  end.
end case.

if p-caller <> 'ret':U then do:
  { gbl/fltopend.i
  &where-cond = " out-dtl.doc-code = p-br1-doc-code , "
  &dyn_where-cond = " substitute('out-dtl.doc-code = &1&2&1 , ', ~{&double-quote~}, p-br1-doc-code) "
  }
end.


&scop flt-open-table-name ret-dtl

&scop flt-open-open-query   OPEN QUERY br-ret FOR EACH ret-dtl NO-LOCK

&scop flt-open-dyn_open-query   FOR EACH ret-dtl NO-LOCK

&scop flt-open-query-handle   QUERY br-ret:handle


&scop flt-open-open-query-tail     FIRST ret-prt NO-LOCK WHERE ret-prt.node-code = ret-dtl.prt-code, FIRST ~
ret-goods NO-LOCK WHERE ret-goods.artic = ret-dtl.artic ~
AND ret-goods.prod-code = ret-dtl.prod-code ~
AND ret-goods.prod-type = ret-dtl.prod-type , FIRST ~
ret-bar NO-LOCK WHERE ret-bar.gds-code = ret-goods.gds-code ~
AND ret-bar.node-code = ret-dtl.prt-code ~
AND ret-bar.in-code = v-empty ~
AND ret-bar.part-code = v-empty ~
AND ret-bar.unit-cli = ret-goods.unit-base, first ret-tt0-dtl where ~
ret-tt0-dtl.artic = ret-dtl.artic ~
and ret-tt0-dtl.prod-type = ret-dtl.prod-type ~
and ret-tt0-dtl.prod-code = ret-dtl.prod-code ~
and ret-tt0-dtl.prt-code = ret-dtl.prt-code outer-join


&scop flt-open-dyn_open-query-tail   substitute('  FIRST ret-prt NO-LOCK WHERE ret-prt.node-code = ret-dtl.prt-code, FIRST ~
ret-goods NO-LOCK WHERE ret-goods.artic = ret-dtl.artic ~
AND ret-goods.prod-code = ret-dtl.prod-code ~
AND ret-goods.prod-type = ret-dtl.prod-type , FIRST ~
ret-bar NO-LOCK WHERE ret-bar.gds-code = ret-goods.gds-code ~
AND ret-bar.node-code = ret-dtl.prt-code ~
AND ret-bar.in-code = &1&1 ~
AND ret-bar.part-code = &1&1 ~
AND ret-bar.unit-cli = ret-goods.unit-base , first ret-tt0-dtl where ~
ret-tt0-dtl.artic = ret-dtl.artic ~
and ret-tt0-dtl.prod-type = ret-dtl.prod-type ~
and ret-tt0-dtl.prod-code = ret-dtl.prod-code ~
and ret-tt0-dtl.prt-code = ret-dtl.prt-code outer-join ', ~{&double-quote~})



case sort-column-name-ret :
  when "" then do:
  assign
    sort-column-phrase = v-sort-phrase2
  .
  end.
  otherwise do:
  assign
    sort-column-phrase = "by " + sort-column-name-ret
  .
  end.
end case.

if p-caller <> 'out' then do:
{ gbl/fltopend.i
  &where-cond = " ret-dtl.doc-code = p-br2-doc-code , "
  &dyn_where-cond = " substitute('ret-dtl.doc-code = &1&2&1 , ', ~{&double-quote~}, p-br2-doc-code)"
  }
end.
if entry(1, br-2-mode, {&delim-par}) = {&sale-add-return-write-off} then do:
  /*засерим колонку резерв*/
  assign
  v-empty:column-fgcolor = GREY_COLOR
  v-empty:column-bgcolor = GREY_COLOR
  v-empty:visible = yes
  ret-dtl.doc-qnty:visible = no
  v-empty:width = out-dtl.doc-qnty:width in browse br-out
  .
end.
else do:
  assign
  v-empty:visible = no
  ret-dtl.doc-qnty:visible = yes
  .
end.
APPLY "value-changed" to br-out in frame {&frame-name} .
APPLY "value-changed" to br-ret in frame {&frame-name} .
run waitfram-hide in this-procedure .
END PROCEDURE.

PROCEDURE shapka:
define variable for-discnt as  decimal no-undo.
if NOT (autocalc AND prcl-spl AND can-do( {&update}, p-mode ) ) then return.
IF NOT (t-doc.status_ = {&fact}
and ink-doc.status_ = {&inquiry})
then do:
    run waitfram-show in this-procedure ("Ждите...").
    run gbl/calc-trn.p ( input parparentproc, input recid(t-doc)).
    if available ret-doc then
    run gbl/calc-trn.p ( input parparentproc, input recid(ret-doc)).
    run waitfram-hide in this-procedure .
end.
for-discnt = (if v-curr-r-b = {&r-b-rubl}
                then t-doc.discnt-rubl
                else t-doc.tot-calc
                - (if available ret-doc
                    then (if v-curr-r-b = {&r-b-rubl}
                          then ret-doc.discnt-rubl
                          else  ret-doc.tot-calc)
                    ELSE 0)
                )
    .
if ABS(for-discnt - ink-doc.discnt) > 0.015 then do:
  assign
  for-discnt-chr = "Скидка по док-там: " + string(for-discnt, "->>>,>>9.99")
  for-discnt-chr:BGCOLOR IN FRAME {&frame-name} = 10
  .
  DISPLAY
  for-discnt-chr
  WITH FRAME {&frame-name}.
end.
else do:
  assign
  for-discnt-chr = ""
  for-discnt-chr:BGCOLOR IN FRAME {&frame-name} = ?
  .
  HIDE
  for-discnt-chr
  IN FRAME {&frame-name}.
end.
END PROCEDURE.

PROCEDURE close-error-processing.
if NOT return-value = ""
and NOT return-value = "error"
then
message
return-value
view-as alert-box ERROR.
if compensed then  run UI-on in this-procedure .
run frame-title in this-procedure .
END PROCEDURE.

/*определение процедуры резервирования/снятия резервов*/

&glob display-message  run waitfram-show in this-procedure (~{&MY-MESSAGE~} )

&glob display-message-laud  MESSAGE ~{&MY-MESSAGE~} view-as alert-box

&glob display-count-message run waitfram-show in this-procedure (input ~{&MY-count-MESSAGE~} )

&glob hide-count-message  run waitfram-hide in this-procedure


{ str/salersrv.i sale }
{ str/sale-oth.i interface }
/*определение процедуры UNRESERV*/
{ str/unressal.i sale interface }

PROCEDURE get-gds-rec:
  CASE CURRENT-BROWSER:
      WHEN br-out:handle IN FRAME {&FRAME-NAME}  then do:
          IF AVAILABLE out-goods then
          gds-rec = recid(out-goods).
          ELSE IF AVAILABLE ret-goods then
          gds-rec = recid(ret-goods).
          ELSE BELL.
      END.
      WHEN br-ret:handle  IN FRAME {&FRAME-NAME} then do:
          IF AVAILABLE ret-goods then
          gds-rec = recid(ret-goods).
          ELSE IF AVAILABLE out-goods then
          gds-rec = recid(out-goods).
          ELSE BELL.
      END.
  END CASE.
END PROCEDURE.

PROCEDURE proc-places :
    define variable v-is-petrol as logical no-undo.
    define variable v-is-pieces as logical no-undo.
    
    IF error-status:error then return no-apply.
    IF (CURRENT-BROWSER = brwh-out-dtl
    and bh-out-dtl:available )
    or (CURRENT-BROWSER = brwh-ret-dtl
    and bh-ret-dtl:available )
    then do:
      /*там где фоку запись есть*/
    end.
    else do:
      /*значит пользователь имел в виду другой броуз*/
      case current-browser:
        when brwh-out-dtl then do:
          if bh-ret-dtl:available then
          assign
          current-browser = brwh-ret-dtl.
          else  do:
            bell.
            APPLY "ENTRY" to brwh-out-dtl.
            return error.
          end.
        end.
        when brwh-ret-dtl then do:
          if bh-out-dtl:available then
          assign
          current-browser = brwh-out-dtl.
          else  do:
            bell.
            APPLY "ENTRY" to brwh-ret-dtl.
            return error.
          end.
        end.
      END CASE.
    end.
    assign
        bhg = current-browser:query:get-buffer-handle({&buffer-goods})
        bhb = current-browser:query:get-buffer-handle({&buffer-bar-code})        
    .
    assign
        v-gds-code  = bhg:buffer-field({&gds-code-field}):buffer-value
        v-artic     = bhg:buffer-field({&artic-field}):buffer-value
        v-prod-type = bhg:buffer-field({&prod-type-field}):buffer-value
        v-prod-code = bhg:buffer-field({&prod-code-field}):buffer-value
        v-b-code    = bhb:buffer-field({&b-code-field}):buffer-value
    .
    { str/is-petrl.i v-artic v-prod-type v-prod-code v-is-petrol v-is-pieces no-error }
    if not v-is-petrol then do :
        message "Выбран нетопливный товар!" view-as alert-box.
        return no-apply.
    end. 
    assign v-to-reserv = no .
    DO TRANSACTION on ERROR undo, return no-apply
                        on STOP undo, return no-apply :
        run  str/sale-plc.w (input parparentproc,
                             input v-gds-code,
                             input v-b-code,
                             buffer ink-doc,
                             output v-to-reserv) .
        if return-value = "cancell":U then undo, return no-apply .    
    END.           
        
END PROCEDURE. /* proc-places */    

PROCEDURE proc-chek-tovar:
DEFINE VARIABLE rid-list as character no-undo .
IF (CURRENT-BROWSER = brwh-out-dtl
and bh-out-dtl:available )
or (CURRENT-BROWSER = brwh-ret-dtl
and bh-ret-dtl:available )
then do:
  /*там где фоку запись есть*/
end.
else do:
  /*значит пользователь имел в виду другой броуз*/
  case current-browser:
    when brwh-out-dtl then do:
      if bh-ret-dtl:available then
      assign
      current-browser = brwh-ret-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-out-dtl.
        return error.
      end.
    end.
    when brwh-ret-dtl then do:
      if bh-out-dtl:available then
      assign
      current-browser = brwh-out-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-ret-dtl.
        return error.
      end.
    end.
  END CASE.
end.
assign
bh = current-browser:query:get-buffer-handle({&buffer-gds-dtl})
bhg = current-browser:query:get-buffer-handle({&buffer-goods})
bhb = current-browser:query:get-buffer-handle({&buffer-bar-code})
.
assign
v-doc-code = bh:buffer-field ({&doc-code-field}):buffer-value
v-gds-code = bhg:buffer-field({&gds-code-field}):buffer-value
v-recid = bhg:recid
v-b-code = bhb:buffer-field({&b-code-field}):buffer-value
.
FIND FIRST ub.doc-prts No-LOCK WHERE
          ub.doc-prts.out-code = v-doc-code
      AND ub.doc-prts.gds-code = v-gds-code No-ERROR.
IF AVAILABLE ub.doc-prts then cashparts = yes.
else cashparts = no.
if cashparts
then   run ref/gds-chks.w (
                      input parparentproc
                    ,input v-recid
                    ,input (if p-mode = {&lookup} then "":U else "b-del":U) /*bttns*/
                    ,input {&sale}
                    ,input ? /*pardoc-rec*/
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input "":U /*d-card*/
                    ,output rid-list
                      ).
ELSE run ref/gds-chk.w (
                      input parparentproc
                    ,input v-b-code
                    ,input (if p-mode = {&lookup} then "":U else "b-del":U)  /*bttns*/
                    ,input {&sale}
                    ,input ? /*pardoc-rec*/
                    ,input ink-doc.obj-type
                    ,input ink-doc.obj-code
                    ,input ink-doc.inkas-code
                    ,input "":U /*d-card*/
                    ,output rid-list
                    ).
if return-value = "deleted" then run ui-on in this-procedure .
apply "entry" to current-browser .


END PROCEDURE.

PROCEDURE proc-parts-tovar:
define buffer b-doc-line for ub.doc-line.
define variable what-mode as logical no-undo initial yes.
define variable v-doc-qnty like ub.doc-line.doc-qnty no-undo .
define variable v-prt-rec as recid no-undo .
define variable rgds-dtl as rowid no-undo .
if v-is-inquiry then return .
IF (CURRENT-BROWSER = brwh-out-dtl
and bh-out-dtl:available )
or (CURRENT-BROWSER = brwh-ret-dtl
and bh-ret-dtl:available )
then do:
  /*там где фоку запись есть*/
end.
else do:
  /*значит пользователь имел в виду другой броуз*/
  case current-browser:
    when brwh-out-dtl then do:
      if bh-ret-dtl:available then
      assign
      current-browser = brwh-ret-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-out-dtl.
        return error.
      end.
    end.
    when brwh-ret-dtl then do:
      if bh-out-dtl:available then
      assign
      current-browser = brwh-out-dtl.
      else  do:
        bell.
        APPLY "ENTRY" to brwh-ret-dtl.
        return error.
      end.
    end.
  END CASE.
end.
bh = current-browser:query:get-buffer-handle({&buffer-gds-dtl}).
bhg = current-browser:query:get-buffer-handle({&buffer-goods}).
assign
rgds-dtl = bh:rowid
v-doc-code = bh:buffer-field({&doc-code-field}):buffer-value
v-artic = bh:buffer-field({&artic-field}):buffer-value
v-prod-type = bh:buffer-field({&prod-type-field}):buffer-value
v-prod-code = bh:buffer-field({&prod-code-field}):buffer-value
v-gds-code = bhg:buffer-field({&gds-code-field}):buffer-value
.

FIND FIRST b-doc-line No-LOCK WHERE
            b-doc-line.doc-code = v-doc-code
       AND  b-doc-line.artic = v-artic
       AND  b-doc-line.prod-type = v-prod-type
       AND  b-doc-line.prod-code = v-prod-code No-ERROR.
assign
v-doc-qnty = b-doc-line.doc-qnty
.
if can-find(first ub.doc-prts where
                  ub.doc-prts.gds-code = v-gds-code
              AND ub.doc-prts.out-code = v-doc-code)
OR
can-find(first ub.doc-pl where
              ub.doc-pl.gds-code = v-gds-code
         AND  ub.doc-pl.out-code = v-doc-code)
OR
can-find(first ub.doc-pl-pump where
              ub.doc-pl-pump.gds-code = v-gds-code
        AND   ub.doc-pl-pump.out-code = v-doc-code)
or
can-find(first ub.doc-fbr-gds where
              ub.doc-fbr-gds.gds-code = v-gds-code
          AND ub.doc-fbr-gds.out-code = v-doc-code)
then
what-mode = no.
apply "Value-CHAnged" to current-browser.
run str/parts-l.w (
              input parparentproc
              ,input ink-doc.obj-type          /* v-obj-type   */
              ,input ink-doc.obj-code          /* v-obj-code   */
              ,input v-gds-code                /* p-gds-code   */
              ,input v-doc-code       /* p-doc-code   */
              ,input (if  (p-mode = {&update} /* p-edit-mode  */
                            and what-mode
                            )
                      then {&update}
                      else {&lookup}
                      )
              ,input (if ink-doc.status_ = {&fact} /* p-r-parts    */
                      then {&parts-l_parts-all}
                      else {&parts-l_parts-document}
                      )
              ,input {&parts-l_object-current} /* p-one-all    */
              ,input {&parts-l_call-document}  /* p-call-point */
              ,output v-prt-rec                  /* part-recid   */
              ).
apply "entry" to current-browser.
FIND FIRST b-doc-line No-LOCK WHERE
          b-doc-line.doc-code = v-doc-code
      AND b-doc-line.artic = v-artic
      AND b-doc-line.prod-type = v-prod-type
      AND b-doc-line.prod-code = v-prod-code No-ERROR.


if b-doc-line.doc-qnty <> v-doc-qnty then do:
  run UI-on in this-procedure .
  if rgds-dtl <> ? then qh:reposition-to-rowid( rgds-dtl) no-error.
  apply "entry" to current-browser.
end.
END PROCEDURE.

procedure frame-title :

  do
  on error undo, return error
  :
    assign
    frame {&frame-name}:title = (if t-doc.status_ = {&inquiry}
                                 then t-doc.status_
                                 else '':U) + {&space-char} +
                                  substitute("&1 №&2  Дата: &3  Факт&4: &5 &6 &7"
                                            , (t-doc.obj-type + string(t-doc.obj-code))
                                            , t-doc.doc-code
                                            , string (t-doc.doc-date, "99/99/9999")
                                            , (if ink-doc.status_ <> {&fact}
                                             and
                                             ink-doc.status_ <> {&inquiry}
                                             then "(ожидается)" else "":U)
                                            , string ( t-doc.fact-date, "99/99/9999" )
                                            , (IF cas-shft then (" смена N " + shift-name-no-err(buffer ink-doc)) else "" )
                                            , (IF one-curs then (" чеки по курсу " + string(t-doc.base-rate / t-doc.base-scale)) else "")
                                          ).
   browse br-out:title = substitute("Продажи &1 &2", {&gds-goods}, t-doc.doc-code)
  .
  end.

end procedure. /* frame-title */

procedure ui-2 :

  do
  on error undo, return error
  :
    apply "entry" to br-out in frame d-sale.
    reposition br-out to row 1 no-error.

  end.

end procedure. /* ui-2 */

procedure enable-menu-items :
define variable v-chr-office as character no-undo .
define variable v-doc-kind as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.

do
on error undo, return error
:

assign
v-doc-kind = entry(1, br-2-mode, {&delim-par} )
v-chr-office = entry(2, br-2-mode, {&delim-par} )
.
for each wh:
  if valid-handle(wh.mi-reserv) then do:
    delete widget wh.mi-reserv.
  end.
  if valid-handle(wh.mi-unreserv) then do:
    delete widget wh.mi-unreserv.
  end.
  if valid-handle(wh.mi-parts) then do:
    delete widget wh.mi-parts.
  end.
  if valid-handle(wh.mi-arch) then do:
    delete widget wh.mi-arch.
  end.
  delete wh.
end.
_sale-doc:
for each buf_sale-doc no-lock where
        buf_Sale-doc.inkas-code = ink-doc.inkas-code:

  create wh.
  buffer-copy buf_sale-doc to wh
  .
&scop  sale-doc-kind buf_sale-doc.doc-kind
  if buf_sale-doc.order <= 0 then next _sale-doc.
  create menu-item wh.mi-reserv
  assign
  name = substitute("m-res-&1", buf_sale-doc.doc-kind, buf_sale-doc.chr-office)
  label = substitute("&1 &2 - Выбранный товар", {&sale-doc-name}, buf_sale-doc.chr-office)
  parent = menu m-recs:handle
  triggers:
    on choose
      persistent run mi-res ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  create menu-item wh.mi-unreserv
  assign
  name = substitute("m-unres-&1", buf_sale-doc.doc-kin, buf_sale-doc.chr-office)
  label = substitute("&1 &2 - Выбранный товар", {&sale-doc-name}, buf_sale-doc.chr-office)
  parent = menu m-unrecs:handle
  triggers:
    on choose
      persistent run mi-unres ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  create menu-item wh.mi-parts
  assign
  name = substitute("m-parts-&1", buf_sale-doc.doc-kin, buf_sale-doc.chr-office)
  label = substitute("&1 &2", {&sale-doc-name}, buf_sale-doc.chr-office)
  parent = menu m-parts:handle
  triggers:
    on choose
      persistent run mi-parts ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.
  create menu-item wh.mi-arch
  assign
  name = substitute("m-arch-&1", buf_sale-doc.doc-kin, buf_sale-doc.chr-office)
  label = substitute("&1 &2", {&sale-doc-name}, buf_sale-doc.chr-office)
  parent = menu m-arch:handle
  triggers:
    on choose
      persistent run mi-arch ( input  wh.doc-kind, input wh.chr-office) .
  end triggers.

  assign
  wh.mi-reserv:sensitive = (if wh.doc-kind = v-doc-kind
                      and wh.chr-office = v-chr-office
                      and wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-reserv:sensitive)
  wh.mi-unreserv:sensitive = (if wh.doc-kind = v-doc-kind
                      and wh.chr-office = v-chr-office
                      and wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-unreserv:sensitive)
  wh.mi-arch:sensitive = (if wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-arch:sensitive)
  wh.mi-parts:sensitive = (if wh.doc-kind = buf_sale-doc.doc-kind
                      and wh.chr-office = buf_sale-doc.chr-office
                      then yes
                      else wh.mi-arch:sensitive)
 .
 if wh.mi-parts:name =  "m-parts-rw" then do:
   if buf_sale-doc.doc-kind = {&sale-add-return-write-off}
   and (ink-doc.status_ = {&fact} or ink-doc.status_ = {&inquiry}) then
   wh.mi-parts:sensitive = yes.
   else wh.mi-parts:sensitive = no.
 end.

end. /*for each*/
end.

end procedure. /* enable-menu-items */

procedure reget-br-2 :
define variable v-found as logical no-undo .
define variable old-br-2-mode as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.

do
on error undo, return error
:
assign
old-br-2-mode = br-2-mode
br-2-doc-code = '':U
br-2-mode = {&delim-par}
v-found = no
v-list-item-pairs = '':U
.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = ink-doc.inkas-code
    and buf_sale-doc.order > 0:
  if (buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_Kass}
      and buf_sale-doc.chr-office = {&gds-goods})
  or buf_sale-doc.order <= 0
  then next.
  assign
  br-2-mode = (if br-2-mode = {&delim-par}
               then (buf_sale-doc.doc-kind  + {&delim-par} + buf_sale-doc.chr-office)
               else br-2-mode)
  br-2-doc-code  = (if entry(1, br-2-mode, {&delim-par}) = buf_sale-doc.doc-kind
                    and entry(2, br-2-mode, {&delim-par}) = buf_sale-doc.chr-office
                    then buf_sale-doc.doc-code
                    else br-2-doc-code)
  .
  if buf_sale-doc.doc-kind = old-br-2-mode then do:
    assign
    v-found = yes
    br-2-doc-code = buf_sale-doc.doc-code + {&delim-par} + buf_sale-doc.chr-office
    .
  end.
&scop sale-doc-kind buf_sale-doc.doc-kind
  v-list-item-pairs = v-list-item-pairs + (if v-list-item-pairs = '':U then '':U else {&comma-char}) +
                    {&sale-doc-name} + {&space-char} + buf_sale-doc.chr-office + {&comma-char} +
                    buf_sale-doc.doc-kind  + {&delim-par} + buf_sale-doc.chr-office.
end.
br-2-mode = (if old-br-2-mode = {&delim-par}
              or not v-found
              then br-2-mode else old-br-2-mode)
.

end.

end procedure. /* reget-br-2 */



procedure set-compensed :
define input parameter p-compensed as logical no-undo .

  do
  on error undo, return error
  :
     assign
     compensed = p-compensed.
  end.

end procedure. /* set-compensed */

procedure reposition-inkas :
define input parameter p-direction as character no-undo .
define variable v-new-inkas-recid as recid no-undo .


do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-inkas in p-call-prog
      (input  p-direction
      ,output v-new-inkas-recid
      ).

    if v-new-inkas-recid <> ?
    then do:
      define buffer buf_inkas for ub.inkas .
      find first buf_inkas no-lock
        where recid(buf_inkas) = v-new-inkas-recid
        no-error .
      assign
      p-doc-rec = v-new-inkas-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.

end.

end procedure. /* reposition-inkas */

procedure mi-arch :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
do
on error undo, return error
:
  find first buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-chr-office  no-error .
  if not available buf_sale-doc then return error.
  find first buf_trn-doc no-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code no-error.
  if not available buf_trn-doc then do:
  &scop sale-doc-kind buf_sale-doc.doc-kind
    message
    substitute("Не найдено: &1 &2", {&sale-doc-name}, buf_sale-doc.doc-code).
  end.
    run str/docisupp.p
      (input  parparentproc
      ,input  recid(buf_trn-doc)
      ).
end.
end procedure. /* mi-arch */

procedure mi-parts :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define variable v-recid as recid no-undo .
define buffer buf_trn-doc for ub.trn-doc.

do
on error undo, return error
:
  find first buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-chr-office no-error .
  if not available buf_sale-doc
  then do:
    return error.
  end.
  find first buf_trn-doc no-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code no-error.
  if not available buf_trn-doc then do:
  &scop sale-doc-kind buf_sale-doc.doc-kind
    message
    substitute("Не найдено: &1 &2", {&sale-doc-name}, buf_sale-doc.doc-code).
  end.
    run str/partsneg.w (
      input parParentProc
      ,input buf_sale-doc.doc-code
      ,input (if p-mode = {&update}
              and ink-doc.status_ = {&g___new}
              then {&update}
              else {&lookup})
      ,input-output v-recid
      ).

end.
end procedure. /* mi-parts */

procedure mi-res :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.

do
on error undo, return error
:
  if p-doc-kind = {&TDEDT_Ras_Vnesh_kass}
  and p-chr-office = {&gds-goods} then do:
    assign
    bh = bh-out-dtl
    brwh = brwh-out-dtl
    .
  end.
  else do:
    if entry(1, br-2-mode, {&delim-par}) = {&sale-add-return-write-off}  then return error.
    assign
    bh = bh-ret-dtl
    brwh = brwh-ret-dtl
    .
  end.
  if not bh:available then return no-apply.
  assign
  v-doc-code = (bh:buffer-field({&doc-code-field}):buffer-value)
  v-artic = (bh:buffer-field({&artic-field}):buffer-value)
  v-prod-type = (bh:buffer-field({&prod-type-field}):buffer-value)
  v-prod-code = (bh:buffer-field({&prod-code-field}):buffer-value)
  .
  FIND FIRST ub.doc-line NO-LOCK WHERE
          ub.doc-line.doc-code  =  v-doc-code
      and ub.doc-line.artic     =  v-artic
      and ub.doc-line.prod-type =  v-prod-type
      and ub.doc-line.prod-code =  v-prod-code  No-ERROR.
  IF NOT available ub.doc-line then return no-apply.
  assign
  rdoc-line = recid (ub.doc-line)
  rgds-dtl = bh:recid
  r-or-v = p-doc-kind
  r-office = p-chr-office
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  from-menu = yes.
  run b-res-proc in this-procedure (
                                      buffer ink-doc
                                    , buffer t-doc
                                    , buffer ret-doc
                                    , input no
                                    , input auto-close
                                    , input no
                                    , input rest-dish
                                    , input "":U
                                    , input v-is-tpsi-obj
                                    , input rest-tpsi) no-error.
  if error-status:error or return-value = "error" then do:
    run waitfram-hide in this-procedure .
    return no-apply.
  end.
  APPLY "ENTRY" to brwh  .
end.
end procedure. /* mi-res */

procedure mi-unres :
define input parameter p-doc-kind as character no-undo .
define input parameter p-chr-office as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
do
on error undo, return error
:
  if p-doc-kind = {&TDEDT_Ras_Vnesh_Kass}
  and p-chr-office = {&gds-goods}
  then do:
    assign
    bh = bh-out-dtl
    brwh = brwh-out-dtl
    .
  end.
  else do:
    if entry(1, br-2-mode, {&delim-par}) = {&sale-add-return-write-off} then return error.
    assign
    bh = bh-ret-dtl
    brwh = brwh-ret-dtl
    .
  end.
  if not bh:available then return error.
  assign
  v-doc-code = (bh:buffer-field({&doc-code-field}):buffer-value)
  v-artic = (bh:buffer-field({&artic-field}):buffer-value)
  v-prod-type = (bh:buffer-field({&prod-type-field}):buffer-value)
  v-prod-code = (bh:buffer-field({&prod-code-field}):buffer-value)
  .
  FIND FIRST ub.doc-line NO-LOCK WHERE
          ub.doc-line.doc-code = v-doc-code
      and ub.doc-line.artic    =  v-artic
      and ub.doc-line.prod-type = v-prod-type
      and ub.doc-line.prod-code = v-prod-code  No-ERROR.
  IF NOT available ub.doc-line then return no-apply.
  assign
  rdoc-line = recid (ub.doc-line)
  rgds-dtl = bh:recid
  r-or-v = p-doc-kind
  r-office = p-chr-office
  r-qnty = ?
  r-b-code = ?
  r-pl-code = ?
  r-doc-prts-qnty = ?
  from-menu = yes
  .
  apply "choose" to b-unres in frame d-sale.
  APPLY "ENTRY" to brwh.
end.
end procedure. /* mi-unres */

PROCEDURE write-log-and-file :
define input parameter p-tab-position as integer   no-undo.
define input parameter p-file-name    as character no-undo .
define input parameter p-log-level    as integer   no-undo .
define input parameter p-log-string   as character no-undo .

    run writelog in this-procedure (
          input log-file-name
        , input p-log-level
        , input p-log-string 
    ).

END PROCEDURE.

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME