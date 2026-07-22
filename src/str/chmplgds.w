&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
       field price-sale-base as decimal
       field price-sale-rubl as decimal
       field date-1 as date
       field date-2 as date
       field shift-1 as int
       field shift-2 as int
       field time-1 as int
       field time-2 as int
       field grp-name as char
       field interv-name as char
       field pay-name as char
       field unit-cli as char
       field cli-base-rate as decimal
       index pi
       plt-priority DESCENDING
       fact-order DESCENDING
       qnty-from DESCENDING
       sum-from DESCENDING
       turnover-from DESCENDING
       date-1 DESCENDING
       time-1 DESCENDING
       date-2 DESCENDING
       time-2 DESCENDING
       type-price DESCENDING
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр цены в множественных прайс-листах по товару

Автор: Чернова Светлана Александровна
Дата создания: 03/29/06
Author: Svetlana Chernova
Creation date: 03/29/06


*/

define input  parameter parparentproc as handle    no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-fact-order  as decimal   no-undo .

define output parameter p-plt-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-sale-price-doc as decimal   no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр цены в множественных прайс-листах по товару".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/color.i    }
{ cmp/showinf.i  }
{ gbl/usr-flt.i  }
{ trg/factord.i  }
{ str/mplfacor.i }
{ gbl/cur-time.i }
{ str/adddocfn.i }
{ gbl/userobjs.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }

{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }


&scop cop-l1        tt_price-all.plt-priority
&scop cop-l2        tt_price-all.b-code
&scop cop-l3        tt_price-all.unit-cli
&scop cop-l4        buf_currency.curr-abbr
&scop cop-l5        tt_price-all.obj-code
&scop cop-l6        tt_price-all.plt-fix-cource-crc-doc
&scop cop-l7        tt_price-all.pdf-exch-rate
&scop cop-l8        tt_price-all.price-sale
&scop cop-l9        tt_price-all.plt-fix-cource-crc-base
&scop cop-l10       tt_price-all.pdf-base-rate
&scop cop-l11       tt_price-all.price-sale-base
&scop cop-l12       tt_price-all.price-sale-rubl
&scop cop-l13       tt_price-all.date-1
&scop cop-l14       tt_price-all.shift-1
&scop cop-l15       tt_price-all.time-1
&scop cop-l16       tt_price-all.date-2
&scop cop-l17       tt_price-all.shift-2
&scop cop-l18       tt_price-all.time-2
&scop cop-l19       tt_price-all.grp-name
&scop cop-l20       tt_price-all.interv-name
&scop cop-l21       tt_price-all.pay-name
&scop cop-l22       tt_price-all.plt-id
&scop cop-l23       tt_price-all.plt-db-num
&scop cop-l24       tt_price-all.pdf-id
&scop cop-l25       tt_price-all.pdf-db
&scop cop-l26       tt_price-all.out-code
&scop cop-l27       tt_price-all.status_
&scop cop-l28       tt_price-all.cli-base-rate

&scop col-l1  'Приор!итет'
&scop col-l2  'Бар-код'
&scop col-l3  'Ед!изм'
&scop col-l4  'Вал!п/л'
&scop col-l5  'Объект! '
&scop col-l6  'Ф!к'
&scop col-l7  'Курс!док-та'
&scop col-l8  'Цена в вал!прайс-листа'
&scop col-l9  'Ф!б'
&scop col-l10 'Курс!баз.вал'
&scop col-l11 'Цена в !баз.вал'
&scop col-l12 'Цена в !{&abbr_rub_allshift}'
&scop col-l13 'Действие!с '
&scop col-l14 'См!с'
&scop col-l15 'Время!c'
&scop col-l16 'Действие!по '
&scop col-l17 'См!по'
&scop col-l18 'Время!по'
&scop col-l19 'Покупатели! '
&scop col-l20 'Интервал!группы'
&scop col-l21 'Тип платежа! '
&scop col-l22 'ТПЛ! '
&scop col-l23 'БД!ТПЛ'
&scop col-l24 'ДНЦ! '
&scop col-l25 'БД!ДНЦ'
&scop col-l26 'Переоценка! '
&scop col-l27 'Статус! '
&scop col-l28 'Крат-!ность'

&scop head-col ~
 {&col-l1}  + '#' + ~
 {&col-l2}  + '#' + ~
 {&col-l3}  + '#' + ~
 {&col-l4}  + '#' + ~
 {&col-l5}  + '#' + ~
 {&col-l6}  + '#' + ~
 {&col-l7}  + '#' + ~
 {&col-l8}  + '#' + ~
 {&col-l9}  + '#' + ~
 {&col-l10} + '#' + ~
 {&col-l11} + '#' + ~
 {&col-l12} + '#' + ~
 {&col-l13} + '#' + ~
 {&col-l14} + '#' + ~
 {&col-l15} + '#' + ~
 {&col-l16} + '#' + ~
 {&col-l17} + '#' + ~
 {&col-l18} + '#' + ~
 {&col-l19} + '#' + ~
 {&col-l20} + '#' + ~
 {&col-l21} + '#' + ~
 {&col-l22} + '#' + ~
 {&col-l23} + '#' + ~
 {&col-l24} + '#' + ~
 {&col-l25} + '#' + ~
 {&col-l26} + '#' + ~
 {&col-l27} + '#' + ~
 {&col-l28}

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable stime-1 as character no-undo .
define variable stime-2 as character no-undo .
define variable is-color as logical   no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-order-col as character no-undo .
define variable v-size-col1 as decimal   no-undo .
define variable v-size-col2 as decimal   no-undo .
define variable v-size-col3 as decimal   no-undo .
define variable v-size-col4 as decimal   no-undo .
define variable v-size-col5 as decimal   no-undo .
define variable v-size-col6 as decimal   no-undo .


define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_gds-prt  for ub.gds-prt  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_cash-pay for ub.cash-pay  .
define buffer buf_pay-type for ub.pay-type  .
define buffer buf_goods    for ub.goods      .

find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
run uf-get in this-procedure(
     input  {&uf-mpl-gds}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
  if error-status :error
  then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .

  end.

if not error-status:error then do:
   v-order-col  = entry ( 1, v-uf-List_ ,{&delim-par} ) no-error.
   v-size-col1  = decimal (entry(2, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col2  = decimal (entry(3, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col3  = decimal (entry(4, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col4  = decimal (entry(5, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col5  = decimal (entry(6, v-uf-List_ ,{&delim-par})) no-error.
   v-size-col6  = decimal (entry(7, v-uf-List_ ,{&delim-par})) no-error.
   if v-size-col1 = 0 or v-size-col1 = ? then v-size-col1 = 10.
   if v-size-col2 = 0 or v-size-col2 = ? then v-size-col2 = 10.
   if v-size-col3 = 0 or v-size-col3 = ? then v-size-col3 = 10.
   if v-size-col4 = 0 or v-size-col4 = ? then v-size-col4 = 10.
   if v-size-col5 = 0 or v-size-col5 = ? then v-size-col5 = 10.
   if v-size-col6 = 0 or v-size-col6 = ? then v-size-col6 = 10.
   if v-order-col = "" or v-order-col = ? then v-order-col = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28".
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-3

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt_price-all buf_currency ~
buf_price-doc-forming

/* Definitions for BROWSE BROWSE-3                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-3 tt_price-all.plt-priority tt_price-all.b-code tt_price-all.unit-cli buf_currency.curr-abbr tt_price-all.obj-type + string(tt_price-all.obj-code) tt_price-all.plt-fix-cource-crc-doc tt_price-all.pdf-exch-rate tt_price-all.price-sale tt_price-all.plt-fix-cource-crc-base tt_price-all.pdf-base-rate tt_price-all.price-sale-base tt_price-all.price-sale-rubl tt_price-all.date-1 tt_price-all.shift-1 (if tt_price-all.time-1 = 0 then "" else string(tt_price-all.time-1,"hh:mm")) @ stime-1 tt_price-all.date-2 tt_price-all.shift-2 (if tt_price-all.time-2 = 0 then "" else string(tt_price-all.time-2,"hh:mm")) @ stime-2 tt_price-all.grp-name tt_price-all.interv-name tt_price-all.pay-name tt_price-all.plt-id tt_price-all.plt-db-num tt_price-all.pdf-id tt_price-all.pdf-db tt_price-all.out-code tt_price-all.status_ tt_price-all.last-pr tt_price-all.fact-order tt_price-all.start-date tt_price-all.end-date tt_price-all.type-price tt_price-all.fact-order-sys-from tt_price-all.fact-order-sys-to tt_price-all.type-price tt_price-all.tog-id tt_price-all.tog-db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-3 tt_price-all.status_
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-3 tt_price-all
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-3 tt_price-all
&Scoped-define SELF-NAME BROWSE-3
&Scoped-define QUERY-STRING-BROWSE-3 FOR EACH tt_price-all  NO-LOCK USE-INDEX pi, ~
             FIRST buf_currency OF tt_price-all  NO-LOCK , ~
             FIRST buf_price-doc-forming  OF tt_price-all  NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-3 OPEN QUERY {&SELF-NAME} FOR EACH tt_price-all  NO-LOCK USE-INDEX pi, ~
             FIRST buf_currency OF tt_price-all  NO-LOCK , ~
             FIRST buf_price-doc-forming  OF tt_price-all  NO-LOCK  .
&Scoped-define TABLES-IN-QUERY-BROWSE-3 tt_price-all buf_currency ~
buf_price-doc-forming
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-3 tt_price-all
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-3 buf_currency
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-3 buf_price-doc-forming


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-quit B-save B-pdf B-price-doc B-print ~
B-Help B-color R-actual R-main-code R-obj BROWSE-3 v-node-name ~
v-full-pay-name
&Scoped-Define DISPLAYED-OBJECTS R-actual R-main-code R-obj v-node-name ~
v-full-pay-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-color
     IMAGE-UP FILE "cmp/color.bmp":U
     IMAGE-DOWN FILE "cmp/color.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/color.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Цветовое выделение на экране".

DEFINE BUTTON B-Help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-pdf
     LABEL "&ДНЦ"
     SIZE 11 BY 1.

DEFINE BUTTON B-price-doc
     LABEL "Пе&реоценка"
     SIZE 11 BY 1.

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 11 BY 1 TOOLTIP "Печать списка".

DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-save AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-full-pay-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-node-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Признак"
      VIEW-AS TEXT
     SIZE 48.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE R-actual AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Актуальные", 2
     SIZE 18.38 BY .67 TOOLTIP "Цены все или актуальные на сейчас" NO-UNDO.

DEFINE VARIABLE R-main-code AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Основные", 2
     SIZE 17 BY .67 TOOLTIP "Коды все или основные" NO-UNDO.

DEFINE VARIABLE R-obj AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Текущий", 2,
"Выбор", 3
     SIZE 23 BY .67 TOOLTIP "По всем объектам или по текущему" NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-3 FOR
      tt_price-all,
      buf_currency,
      buf_price-doc-forming SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-3 Dialog-Frame _FREEFORM
  QUERY BROWSE-3 NO-LOCK DISPLAY
   tt_price-all.plt-priority COLUMN-LABEL "Приор!итет" FORMAT ">>>>9":U
   tt_price-all.b-code       FORMAT "999999999":U
   tt_price-all.unit-cli     COLUMN-LABEL "Ед!изм" FORMAT "X(3)":U
   buf_currency.curr-abbr    COLUMN-LABEL "Вал!п/л" FORMAT "X(3)":U
   tt_price-all.obj-type + string(tt_price-all.obj-code)  COLUMN-LABEL "Объект! " FORMAT "x(8)":U
   tt_price-all.plt-fix-cource-crc-doc  COLUMN-LABEL "Ф!к" FORMAT "+/-":U
   tt_price-all.pdf-exch-rate           COLUMN-LABEL "Курс!док-та" FORMAT ">>>>9.9999":U
   tt_price-all.price-sale              COLUMN-LABEL "Цена в вал!прайс-листа" FORMAT "->>,>>>,>>>,>>>,>>9.99":U LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
   tt_price-all.plt-fix-cource-crc-base COLUMN-LABEL "Ф!б" FORMAT "+/-":U
   tt_price-all.pdf-base-rate   COLUMN-LABEL "Курс!баз.вал" FORMAT ">>>>9.9999":U
   tt_price-all.price-sale-base COLUMN-LABEL "Цена в !баз.вал" FORMAT "->>,>>>,>>>,>>>,>>9.99":U
   tt_price-all.price-sale-rubl COLUMN-LABEL "Цена в !{&abbr_rub_allshift}" FORMAT "->>,>>>,>>>,>>>,>>9.99":U
   tt_price-all.date-1          COLUMN-LABEL "Действие!с " FORMAT "99/99/9999":U
   tt_price-all.shift-1         COLUMN-LABEL "См!с" FORMAT ">9":U
   (if tt_price-all.time-1 = 0 then "" else string(tt_price-all.time-1,"hh:mm")) @ stime-1 COLUMN-LABEL "Время!c" FORMAT "x(5)":U
   tt_price-all.date-2          COLUMN-LABEL "Действие!по " FORMAT "99/99/9999":U
   tt_price-all.shift-2         COLUMN-LABEL "См!по" FORMAT ">9":U
   (if tt_price-all.time-2 = 0 then "" else string(tt_price-all.time-2,"hh:mm")) @ stime-2 COLUMN-LABEL "Время!по" FORMAT "x(5)":U
   tt_price-all.grp-name        COLUMN-LABEL "Покупатели! " FORMAT "x(20)":U
   tt_price-all.interv-name     COLUMN-LABEL "Интервал!группы" FORMAT "x(25)":U
   tt_price-all.pay-name        COLUMN-LABEL "Тип платежа! " FORMAT "x(25)":U
   tt_price-all.plt-id          COLUMN-LABEL "ТПЛ! " FORMAT ">>>>>>>>9":U
   tt_price-all.plt-db-num      COLUMN-LABEL "БД!ТПЛ" FORMAT ">>>>>>9":U
   tt_price-all.pdf-id          COLUMN-LABEL "ДНЦ! " FORMAT ">>>>>>>>>9":U
   tt_price-all.pdf-db          COLUMN-LABEL "БД!ДНЦ" FORMAT ">>>>9":U
   tt_price-all.out-code        COLUMN-LABEL "Переоценка! " FORMAT "x(16)":U
   tt_price-all.status_         COLUMN-LABEL "Статус! " FORMAT "x(6)":U
   tt_price-all.cli-base-rate   COLUMN-LABEL "Крат-!ность" FORMAT ">>9.9":U


      /*
      tt_price-all.last-pr COLUMN-LABEL "А! "
      tt_price-all.pal-id
      tt_price-all.fact-order  COLUMN-LABEL "fact-order"
      tt_price-all.type-price           COLUMN-LABEL "type-price"
      tt_price-all.fact-order-sys-from COLUMN-LABEL "fact-order-sys-from" FORMAT ">>>>>>>>>9.9999999999":U
      tt_price-all.fact-order-sys-to   COLUMN-LABEL "fact-order-sys-to"   FORMAT ">>>>>>>>>9.9999999999":U
      tt_price-all.start-date
      tt_price-all.end-date
      tt_price-all.type-price
      tt_price-all.tog-id
      tt_price-all.tog-db-num
      */
 ENABLE tt_price-all.status_
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99 BY 16.04 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-quit AT ROW 1 COL 1
     B-save AT ROW 1 COL 11
     B-pdf AT ROW 1 COL 21
     B-price-doc AT ROW 1 COL 32
     B-print AT ROW 1 COL 43
     B-Help AT ROW 1 COL 90
     B-color AT ROW 1.13 COL 86.5
     R-actual AT ROW 2.21 COL 7.25 NO-LABEL
     R-main-code AT ROW 2.21 COL 34.38 NO-LABEL
     R-obj AT ROW 2.21 COL 61.5 NO-LABEL
     BROWSE-3 AT ROW 2.96 COL 1
     v-node-name AT ROW 19.25 COL 9 COLON-ALIGNED WIDGET-ID 2
     v-full-pay-name AT ROW 20.25 COL 9 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     "Объекты:" VIEW-AS TEXT
          SIZE 8.5 BY .67 AT ROW 2.21 COL 53.13
          FGCOLOR 4
     "Цены:" VIEW-AS TEXT
          SIZE 5.38 BY .67 AT ROW 2.21 COL 1.88
          FGCOLOR 4
     "БКоды:" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 2.21 COL 27.88
          FGCOLOR 4
     SPACE(65.86) SKIP(18.94)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Цены товара"
         DEFAULT-BUTTON B-save CANCEL-BUTTON B-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_currency B "?" ? ub currency
      TABLE: tt_price-all T "?" NO-UNDO ub price-all
      ADDITIONAL-FIELDS:
          field price-sale-base as decimal
          field price-sale-rubl as decimal
          field date-1 as date
          field date-2 as date
          field shift-1 as int
          field shift-2 as int
          field time-1 as int
          field time-2 as int
          field grp-name as char
          field interv-name as char
          field pay-name as char
          field unit-cli as char
          index pi
          plt-priority DESCENDING
          fact-order DESCENDING
          qnty-from DESCENDING
          sum-from DESCENDING
          turnover-from DESCENDING
          date-1 DESCENDING
          time-1 DESCENDING
          date-2 DESCENDING
          time-2 DESCENDING
          type-price DESCENDING

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-3 R-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       v-full-pay-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       v-node-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-3
/* Query rebuild information for BROWSE BROWSE-3
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt_price-all  NO-LOCK USE-INDEX pi,
      FIRST buf_currency OF tt_price-all  NO-LOCK ,
      FIRST buf_price-doc-forming  OF tt_price-all  NO-LOCK  .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BROWSE-3 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Цены товара */
DO:
  run uf-set in this-procedure(
    input  {&uf-color}
    ,input v-cntxt-userid
    ,input string(is-color)
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Цены товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-color
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-color Dialog-Frame
ON CHOOSE OF B-color IN FRAME Dialog-Frame
DO:

  if B-color:IMAGE  = "cmp/nocol.bmp" then
  do:
    B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame {&frame-name}  . /* покрасим */
    is-color = true .

    run OpenBr in this-procedure .
  end.
  else do:
     B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame {&frame-name}  . /* снимим цвет */
     is-color = false  .

     run OpenBr in this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-Help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-Help Dialog-Frame
ON CHOOSE OF B-Help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pdf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pdf Dialog-Frame
ON CHOOSE OF B-pdf IN FRAME Dialog-Frame /* ДНЦ */
DO:
/* Просмотр ДНЦ */
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .
define variable v-rec-list as character no-undo .
define variable br-handle      as handle no-undo.
define variable buffer-handle  as handle no-undo.
define variable next-prev      as logical no-undo .
define variable v-tt-recid as recid no-undo .


if not available tt_price-all then return .
if not available buf_price-doc-forming then return .

find first buf_price-doc-forming-gds where
      buf_price-doc-forming-gds.pdf-db     =  tt_price-all.pdf-db  and
      buf_price-doc-forming-gds.pdf-id     =  tt_price-all.pdf-id  and
      buf_price-doc-forming-gds.plt-db-num =  tt_price-all.plt-db-num and
      buf_price-doc-forming-gds.plt-id     =  tt_price-all.plt-id  and
      buf_price-doc-forming-gds.b-code     =  tt_price-all.b-code
      no-error .


if not available buf_price-doc-forming-gds then return .
v-rec-id = recid (buf_price-doc-forming) .

  assign
    v-rec-id      = recid (buf_price-doc-forming)
    next-prev     = yes
    br-handle     = {&browse-name}:handle
    buffer-handle = buffer buf_price-doc-forming :handle .
    .
  do while next-prev = yes :
      if not available buf_price-doc-forming then do:
        message "Неправильно выбран документ ДНЦ." view-as alert-box error.
        return no-apply.
      end.
      run str/df-price.w
        ( input parparentproc,
          input {&lookup} ,
          input buf_price-doc-forming.plt-id ,
          input buf_price-doc-forming.plt-db-num ,
          input recid(buf_price-doc-forming-gds) ,
          output v-rec-list  ,
          input-output v-rec-id  ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .
          v-tt-recid = recid(tt_price-all) .
  end.
  assign r-obj.
  run openbr in this-procedure .
  reposition {&browse-name} to recid v-tt-recid no-error .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-price-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-price-doc Dialog-Frame
ON CHOOSE OF B-price-doc IN FRAME Dialog-Frame /* Переоценка */
DO:

/* Просмотр переоценки  */
if not available tt_price-all then return .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .

define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .

if not available tt_price-all then return .
if tt_price-all.out-code = "" then return .

define variable doc-rec as recid no-undo .
define variable next-prev as logical   no-undo .
define buffer buf_price-doc for ub.price-doc  .
define buffer buf_price-list for ub.price-list  .
for each  buf_price-doc no-lock where
          buf_price-doc.doc-num     =  tt_price-all.out-code
           :
    find first buf_price-list no-lock where
              buf_price-list.doc-num = buf_price-doc.doc-num and
              buf_price-list.price-type = "" and
              buf_price-list.b-code  = tt_price-all.b-code no-error .
    if available buf_price-list then  do:
      doc-rec = recid(buf_price-doc).
    end.

  run str/pr-lkp.p
  ( input parParentProc   ,
    input doc-rec ) .
   return .
end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
/* */
  find current tt_price-all no-lock no-error .
  if not available tt_price-all then return .
  run proc-print .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit Dialog-Frame
ON CHOOSE OF B-quit IN FRAME Dialog-Frame /* Отмена */
DO:
define variable cur-clmn-loc as integer   no-undo .
define variable column-handle as handle no-undo .
define variable v-list as character no-undo .

  assign
    cur-clmn-loc  = 1
    column-handle = {&browse-name}:first-column
    v-list        = column-handle:label + "#"
  .

  do while valid-handle(column-handle) :
    if cur-clmn-loc = {&browse-name}:num-columns then do:
      leave .
    end.
    assign
      column-handle = column-handle:NEXT-COLUMN
      cur-clmn-loc  = cur-clmn-loc + 1
      v-list        = v-list + column-handle:label + "#"
    .
  end.

   v-list = trim(v-list, "#") .

   define variable v-i        as integer   no-undo .
   define variable v-pos      as integer   no-undo .
   define variable v-list-new as character no-undo .
   define variable v-elem     as character no-undo .

   repeat v-i = 1 to {&browse-name}:num-columns :
      v-elem = entry ( v-i , v-list , "#" ) .
      v-pos  = lookup ( v-elem , {&head-col} , "#") .
      v-list-new = v-list-new + string(v-pos) + "," .
   end.

   define variable v-list-str as character no-undo .
   define variable v-1 as integer   no-undo .
   v-list-str = "" .
   v-1 = num-entries(v-list-new)  .
   repeat v-i = 1 to v-1 :
      v-elem = entry(v-i , v-list-new ) .
      if int(v-elem) > 0 then
      v-list-str  = v-list-str + v-elem + "," .
   end.

   v-list-new = trim(v-list-str ,",")  +  {&delim-par}
              + string(decimal( tt_price-all.price-sale     :width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( tt_price-all.price-sale-rubl:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( tt_price-all.price-sale-base:width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( tt_price-all.grp-name       :width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( tt_price-all.interv-name    :width in browse {&browse-name})) +  {&delim-par}
              + string(decimal( tt_price-all.pay-name       :width in browse {&browse-name})) +  {&delim-par}
              .

run uf-set in this-procedure(
    input  {&uf-mpl-gds}
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

  run uf-set in this-procedure(
    input  {&uf-color}
    ,input v-cntxt-userid
    ,input string(is-color)
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
) no-error    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-3
&Scoped-define SELF-NAME BROWSE-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-3 IN FRAME Dialog-Frame
DO:
if is-color = false then return .

define variable v-color  as integer   no-undo .
define variable v-color2 as integer   no-undo .

   case tt_price-all.type-price :
        when  integer({&mpl-type-main}) then do:
            v-color = ?.
        end.
        when  integer({&mpl-type-spec}) then do:
            v-color = dark_green_color.
        end.

        when  integer({&mpl-type-nomain}) then do:
            v-color = DARK_GREY_COLOR.
        end.
        when  integer({&mpl-type-specnomain}) then do:
            v-color =  blue_color .
        end.
   end case.

   case tt_price-all.main-indication :
        when  integer({&mpl-main}) then do:
            if tt_price-all.plt-priority = 0 then v-color2 = ?.
                                             else v-color2 = 8. /* серый */
        end.
        when  integer({&mpl-qnty}) then do:
            v-color2 = 11.  /* голубой */
        end.
        when  integer({&mpl-sum}) then do:
            v-color2 = 10.   /* зеленый */
        end.
        when  integer({&mpl-tnv}) then do:
            v-color2 =  14 .    /* желтый */
        end.
   end case.

    tt_price-all.plt-priority :fgcolor in browse {&BROWSE-name} = v-color.
    tt_price-all.b-code :fgcolor in browse {&BROWSE-name} = v-color.
    buf_currency.curr-abbr :fgcolor in browse {&BROWSE-name} = v-color.
    tt_price-all.price-sale:bgcolor in browse {&BROWSE-name} = v-color2.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-3 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-3 IN FRAME Dialog-Frame
DO:
  v-node-name = "" .
  v-full-pay-name  = "" .
  if available  tt_price-all then do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = tt_price-all.b-code no-error .
        find first buf_gds-prt no-lock where
                   buf_gds-prt.node-code = buf_bar-code.node-code no-error.
        if available buf_gds-prt then
           v-node-name = buf_gds-prt.f-name.

        if num-entries (tt_price-all.pay-name,":") = 2 then do:
           case entry (1, tt_price-all.pay-name,":") :
            when {&mpl-trn-pay} then do:
                find first buf_pay-type no-lock where buf_pay-type.obj-code = int (entry (2, tt_price-all.pay-name,":")) no-error .
                if available buf_pay-type
                  then v-full-pay-name = {&mpl-trn-pay} + ": " +  buf_pay-type.obj-name.
                  else v-full-pay-name = "" .
            end.
            when {&mpl-cash-pay} then do:
                find first buf_cash-pay no-lock where
                           buf_cash-pay.cdpay-code = integer (entry (1,(entry (2, tt_price-all.pay-name,":")),"_" )) and
                           buf_cash-pay.curr-code  = integer (entry (2,(entry (2, tt_price-all.pay-name,":")),"_" ))
                           no-error .
                if available buf_cash-pay
                  then v-full-pay-name = {&mpl-cash-pay} + ": " + buf_cash-pay.obj-name.
                  else v-full-pay-name = "" .
            end.
           end case.
        end.
  end.
  DISPLAY v-node-name v-full-pay-name  WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-actual
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-actual Dialog-Frame
ON VALUE-CHANGED OF R-actual IN FRAME Dialog-Frame
DO:
    ASSIGN r-obj.
    ASSIGN r-actual.
  run OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-main-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-main-code Dialog-Frame
ON VALUE-CHANGED OF R-main-code IN FRAME Dialog-Frame
DO:
    ASSIGN r-obj.
    ASSIGN r-main-code.
  run OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-obj Dialog-Frame
ON VALUE-CHANGED OF R-obj IN FRAME Dialog-Frame
DO:
  define variable  p-user-select as logical   no-undo .
  ASSIGN r-obj.

  v-obj-type = p-obj-type .
  v-obj-code = p-obj-code .
  IF r-obj = 3 THEN DO:

  run userobjs_select-one (
  input parparentproc    ,
  input v-cntxt-db-num   ,
  input v-cntxt-userid  ,
  input v-cntxt-host-code-obj ,
  input p-obj-type ,
  input p-obj-code ,
  output p-user-select ,
  output v-obj-type ,
  output v-obj-code )
  no-error .
  if error-status :error or v-obj-type = "" or v-obj-type = ? then
    assign
      v-obj-type = p-obj-type
      v-obj-code = p-obj-code
    .
  END.
IF r-obj = 1 then do:
   frame {&frame-name}:TITLE = SUBSTITUTE( "Цены товара : &1 &2 " , buf_goods.artic , buf_goods.gds-name) .
end.
else do:
   frame {&frame-name}:TITLE = SUBSTITUTE( "Цены товара : &1 &2 на объекте &3 &4 " , buf_goods.artic , buf_goods.gds-name , v-obj-type , v-obj-code) .
end.
  run OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrefre.i  "run OpenBr in this-procedure ." }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "tt_price-all"
  &label-clmn_1     =   "{&col-l1}"
  &label-clmn_2     =   "{&col-l2}"
  &label-clmn_3     =   "{&col-l3}"
  &label-clmn_4     =   "{&col-l4}"
  &label-clmn_5     =   "{&col-l5}"
  &label-clmn_6     =   "{&col-l6}"
  &label-clmn_7     =   "{&col-l7}"
  &label-clmn_8     =   "{&col-l8}"
  &label-clmn_9     =   "{&col-l9}"
  &label-clmn_10    =   "{&col-l10}"
  &label-clmn_11    =   "{&col-l11}"
  &label-clmn_12    =   "{&col-l12}"
  &label-clmn_13    =   "{&col-l13}"
  &label-clmn_14    =   "{&col-l14}"
  &label-clmn_15    =   "{&col-l15}"
  &label-clmn_16    =   "{&col-l16}"
  &label-clmn_17    =   "{&col-l17}"
  &label-clmn_18    =   "{&col-l18}"
  &label-clmn_19    =   "{&col-l19}"
  &label-clmn_20    =   "{&col-l20}"
  &label-clmn_21    =   "{&col-l21}"
  &label-clmn_22    =   "{&col-l22}"
  &label-clmn_23    =   "{&col-l23}"
  &label-clmn_24    =   "{&col-l24}"
  &label-clmn_25    =   "{&col-l25}"
  &label-clmn_26    =   "{&col-l26}"
  &label-clmn_27    =   "{&col-l27}"
  &label-clmn_28    =   "{&col-l28}"
  &sort-clmn_1    =   "{&cop-l1}"
  &sort-clmn_2    =   "{&cop-l2}"
  &sort-clmn_3    =   "{&cop-l3}"
  &sort-clmn_4    =   "{&cop-l4}"
  &sort-clmn_5    =   "{&cop-l5}"
  &sort-clmn_6    =   "{&cop-l6}"
  &sort-clmn_7    =   "{&cop-l7}"
  &sort-clmn_8    =   "{&cop-l8}"
  &sort-clmn_9    =   "{&cop-l9}"
  &sort-clmn_10   =   "{&cop-l10}"
  &sort-clmn_11   =   "{&cop-l11}"
  &sort-clmn_12   =   "{&cop-l12}"
  &sort-clmn_13    =  "{&cop-l13}"
  &sort-clmn_14    =  "{&cop-l14}"
  &sort-clmn_15    =  "{&cop-l15}"
  &sort-clmn_16    =  "{&cop-l16}"
  &sort-clmn_17    =  "{&cop-l17}"
  &sort-clmn_18    =  "{&cop-l18}"
  &sort-clmn_19   =   "{&cop-l19}"
  &sort-clmn_20   =   "{&cop-l20}"
  &sort-clmn_21   =   "{&cop-l21}"
  &sort-clmn_22   =   "{&cop-l22}"
  &sort-clmn_23    =  "{&cop-l23}"
  &sort-clmn_24    =  "{&cop-l24}"
  &sort-clmn_25    =  "{&cop-l25}"
  &sort-clmn_26    =  "{&cop-l26}"
  &sort-clmn_27    =  "{&cop-l27}"
  &sort-clmn_28    =  "{&cop-l28}"
&open-query     = "run OpenBr ."
&open-query-otherwise = "run OpenBr ."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes" }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run init_proc in this-procedure .
  run enable_ui in this-procedure .

  run OpenBr in this-procedure .
  tt_price-all.price-sale:resizable       in browse {&browse-name} = true .
  tt_price-all.price-sale-rubl:resizable  in browse {&browse-name} = true .
  tt_price-all.price-sale-base:resizable  in browse {&browse-name} = true .
  tt_price-all.grp-name:resizable  in browse {&browse-name} = true .
  tt_price-all.interv-name:resizable  in browse {&browse-name} = true .
  tt_price-all.pay-name:resizable  in browse {&browse-name} = true .

  tt_price-all.price-sale     :width     in browse {&browse-name}   = v-size-col1 .
  tt_price-all.price-sale-rubl:width     in browse {&browse-name}   = v-size-col2 .
  tt_price-all.price-sale-base:width     in browse {&browse-name}   = v-size-col3 .
  tt_price-all.grp-name       :width     in browse {&browse-name}   = v-size-col4 .
  tt_price-all.interv-name    :width     in browse {&browse-name}   = v-size-col5 .
  tt_price-all.pay-name       :width     in browse {&browse-name}   = v-size-col6 .



{ gbl/mv-clmn.i
 &ext-col = 28
 &start-column = 1
 &frame-name = {&frame-name}
 &browse-name = {&browse-name}
 &prev-order-column_1 = v-order-col
 &prev-order-column-condition_1 = " true = true  "
}
  tt_price-all.status_:read-only in browse {&browse-name} = true .
  hide b-save in frame {&frame-name} .
  B-quit:label = "Выход"  .
  wait-for go of frame {&frame-name}.
end.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY R-actual R-main-code R-obj v-node-name v-full-pay-name
      WITH FRAME Dialog-Frame.
  ENABLE B-quit B-save B-pdf B-price-doc B-print B-Help B-color R-actual
         R-main-code R-obj BROWSE-3 v-node-name v-full-pay-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init_proc Dialog-Frame
PROCEDURE init_proc :
define variable glog as logical no-undo .
v-obj-code = p-obj-code .
v-obj-type = p-obj-type .
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_documents_all':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  false
  glog
}
if not glog then do:
  assign
  r-obj:radio-buttons in frame {&frame-name} = "Текущий" + {&comma-char} + string(2) + {&comma-char} +
                                               "Выбор" + {&comma-char} + string(3)
  .
end.
else do:
  assign
  r-obj:radio-buttons in frame {&frame-name} = "Все" + {&comma-char} + string(1) + {&comma-char} +
                                               "Текущий" + {&comma-char} + string(2) + {&comma-char} +
                                               "Выбор" + {&comma-char} + string(3)
  .
end.
run uf-get in this-procedure(
     input  {&uf-color}
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if v-uf-List_ = "yes"  then is-color = true .
if is-color = true then B-color:LOAD-IMAGE-UP("cmp/color.bmp") in frame {&frame-name}  .
if is-color = false then B-color:LOAD-IMAGE-UP("cmp/nocol.bmp") in frame {&frame-name}  .

define buffer buf_price-all          for ub.price-all  .

define buffer buf_global-state       for ub.global-state  .
define buffer buf_buyer-group        for ub.buyer-group  .
define buffer buf_turnover-group     for ub.turnover-group  .
define buffer buf_bar-code           for ub.bar-code  .


define variable to-day        as date      no-undo .
define variable v-base-rate0  as decimal   no-undo .
define variable v-base-scale0 as decimal   no-undo .
define variable v-exch-rate0  as decimal   no-undo .
define variable v-exch-scale0 as decimal   no-undo .
define variable v-base-rate   as decimal   no-undo .
define variable v-base-scale  as decimal   no-undo .
define variable v-exch-rate   as decimal   no-undo .
define variable v-exch-scale  as decimal   no-undo .
define variable v-host-code as integer   no-undo .
define variable v-curr-abbr as character no-undo .
define variable v-grp-name as character no-undo .
define variable v-date-1   as date      no-undo .
define variable v-date-2   as date      no-undo .
define variable v-interv   as character no-undo .
define variable v-pay-name as character no-undo .

find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.

if buf_global-state.pl-use-shift-date-num = false then do:
   tt_price-all.shift-1:visible in browse {&browse-name} = false .
   tt_price-all.shift-2:visible in browse {&browse-name} = false .
end.
if buf_global-state.pl-use-sys-date-time  = false then do:
   stime-1 :visible in browse {&browse-name} = false .
   stime-2 :visible in browse {&browse-name} = false .
end.

frame {&frame-name}:TITLE = SUBSTITUTE( "Цены товара : &1 &2 " , buf_goods.artic , buf_goods.gds-name) .

{ gbl/curobjdt.i p-obj-type p-obj-code to-day }
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/baserate.i v-host-code to-day v-base-rate0  v-base-scale0 }

for each buf_price-all no-lock where
         buf_price-all.gds-code = p-gds-code
         :
         v-grp-name =  "" .
         v-interv = "" .
         v-pay-name = "" .

         /* Отсекаем незакрытые переоценки */
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.

         if buf_price-all.bgr-id > 0 then do:
            v-grp-name =  "" .
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then
                         v-grp-name = buf_buyer-group.name .
         end.

         if buf_price-all.tog-id > 0 then do:
            v-grp-name = "".
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id  and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then
                         v-grp-name = buf_turnover-group.name .
         end.

         if buf_price-all.plt-fix-cource-crc-base = true then do:
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
         end.
         else do:
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         end.

         if buf_price-all.plt-fix-cource-crc-doc = true then do:
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
         end.
         else do:
              { gbl/exchrate.i
                buf_price-all.curr-code
                to-day
                v-exch-rate0
                v-exch-scale0
                v-curr-abbr
                }
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
          end.

           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?      then  v-date-1 = buf_price-all.start-date.
           end.

           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.

           if buf_price-all.qnty-from <> ? then do :
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.

           if buf_price-all.use-pay-type = 1 then do :  /* По списку видов оплат */
               v-pay-name = {&mpl-trn-pay} + ":" + string(buf_price-all.pay-code) .
           end.

           if buf_price-all.use-cash-pay = 1 then do :  /* По списку типов кассовых платежей */
              v-pay-name = {&mpl-cash-pay} + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.

          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .

          /*if buf_price-all.main-indication =  {&bef-mpl-main}   and buf_price-all.status_ = "" then next.*/
          create tt_price-all .
           /* если RB = rubl */

          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale      = buf_price-all.price-sale
            tt_price-all.price-sale-rubl = buf_price-all.price-sale       * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale

            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
            tt_price-all.cli-base-rate   = buf_bar-code.cli-base-rate
          .

end.
/* Теперь заполним поле last-pr для непереоценок. В базе этого хранить нельзя, так как определяется  момент времени   */
/* с переоценками проще , там тригере при закрытиии на Акт отмечается последняя , а старая последняя снимает отметку  */
/* Отметка мне нужна только для интерфейса , для просмотра актуальных цен */
define variable v-fact-order as decimal   no-undo .
      run fact-order-mpl in this-procedure
      ( input ?          ,
        input v-obj-type ,
        input v-obj-code ,
        output v-fact-order
      )  .

for each tt_price-all exclusive-lock where
      tt_price-all.plt-priority > 0 and
      tt_price-all.fact-order-sys-from <= v-fact-order and
      tt_price-all.fact-order-sys-to  >= v-fact-order
    break
    by tt_price-all.b-code
    by tt_price-all.plt-priority
    by tt_price-all.grp-name
    by tt_price-all.pay-name
    by tt_price-all.obj-type
    by tt_price-all.obj-code
    by tt_price-all.interv-name
    by tt_price-all.fact-order  DESCENDING
    by tt_price-all.plt-id      DESCENDING
    by tt_price-all.plt-db-num  DESCENDING
    by tt_price-all.pdf-id      DESCENDING
    by tt_price-all.pdf-db      DESCENDING
    :
    if first-of(tt_price-all.interv-name) then do:
       tt_price-all.last-pr = true .
    end.
    else tt_price-all.last-pr = false .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openBr Dialog-Frame
PROCEDURE openBr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
assign   frame {&frame-name}  r-obj r-actual r-main-code .
define variable v-fact-order as decimal   no-undo .
      run fact-order-mpl in this-procedure
      ( input ?          ,
        input v-obj-type ,
        input v-obj-code ,
        output v-fact-order
      )  .

  case r-actual :
  when 1 then do:
   case r-main-code :
        when 1 then do:
              open query browse-3 for each tt_price-all  no-lock
                  where ( r-obj = 1 or
                          tt_price-all.obj-type = v-obj-type and
                          tt_price-all.obj-code = v-obj-code ) ,
                  each buf_currency of tt_price-all  no-lock ,
                  each buf_price-doc-forming of tt_price-all  no-lock
                  indexed-reposition.
        end.
        when 2 then do:
              open query browse-3 for each tt_price-all  no-lock where
              ( r-obj = 1 OR
                tt_price-all.obj-type = v-obj-type and
                tt_price-all.obj-code = v-obj-code )
                and
               ( tt_price-all.type-price = integer ({&mpl-type-main}) or
                 tt_price-all.type-price = integer ({&mpl-type-spec})),
                each buf_currency of tt_price-all  no-lock ,
                each buf_price-doc-forming of tt_price-all  no-lock
                indexed-reposition.
        end.
   end case.
  end.
  when 2 then do:
   case r-main-code :
        when 1 then do:
            open query browse-3 for each tt_price-all no-lock use-index pi where
                ( r-obj = 1 OR
                  tt_price-all.obj-type = v-obj-type and
                  tt_price-all.obj-code = v-obj-code )
                  and
                  tt_price-all.last-pr = true
                 ,
              each buf_currency of tt_price-all  no-lock ,
              each buf_price-doc-forming of tt_price-all  no-lock
              .
        end.
        when 2 then do:
              open query browse-3 for each tt_price-all  no-lock where
            ( r-obj = 1 or
              tt_price-all.obj-type = v-obj-type and
              tt_price-all.obj-code = v-obj-code )
              and
                tt_price-all.last-pr = true
              and
            ( tt_price-all.type-price = int({&mpl-type-main}) or
              tt_price-all.type-price = int({&mpl-type-spec})  ) ,
              each buf_currency of tt_price-all  no-lock ,
              each buf_price-doc-forming of tt_price-all  no-lock
              indexed-reposition.
        end.
   end case.

  end.
  end case.
apply "VALUE-CHANGED" TO BROWSE-3 IN FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-print Dialog-Frame
PROCEDURE proc-print :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable sym1  as char format "X(1)" init ":".
define variable sym2  as char format "X(1)" init ":".
define variable sym3  as char format "X(1)" init ":".
define variable sym4  as char format "X(1)" init ":".
define variable sym5  as char format "X(1)" init ":".
define variable sym6  as char format "X(1)" init ":".
define variable sym7  as char format "X(1)" init ":".
define variable sym8  as char format "X(1)" init ":".
define variable sym9  as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable sym11 as char format "X(1)" init ":".
define variable sym12 as char format "X(1)" init ":".

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.

DEFINE FRAME prt-frame
      tt_price-all.plt-priority               COLUMN-LABEL "Приор!итет" FORMAT ">>>>9":U
      tt_price-all.b-code                     FORMAT "999999999":U
      tt_price-all.unit-cli                   COLUMN-LABEL "Ед!изм" FORMAT "X(3)":U
      buf_currency.curr-abbr                  COLUMN-LABEL "Вал!п/л" FORMAT "X(3)":U
      tt_price-all.obj-type                   COLUMN-LABEL "Объект! " FORMAT "x(13)":U
      tt_price-all.price-sale                 COLUMN-LABEL "Цена в вал!прайс-листа" FORMAT       ">>>>>>>>>>9.99":U
      tt_price-all.price-sale-base            COLUMN-LABEL "Цена в !баз.вал" FORMAT              ">>>>>>>>>>9.99":U
      tt_price-all.price-sale-rubl            COLUMN-LABEL "Цена в !{&abbr_rub_allshift}" FORMAT ">>>>>>>>>>9.99":U
      tt_price-all.date-1                     COLUMN-LABEL "Действие!с " FORMAT "99/99/99":U
      tt_price-all.date-2                     COLUMN-LABEL "Действие!по " FORMAT "99/99/99":U
      tt_price-all.grp-name                   COLUMN-LABEL "Покупатели! " FORMAT "x(20)":U
      tt_price-all.interv-name                COLUMN-LABEL "Интервал!группы" FORMAT "x(25)":U
      tt_price-all.pay-name                   COLUMN-LABEL "Тип платежа! " FORMAT "x(25)":U
 HEADER  date_string AT 5 format "X(35)"
        string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
        Line format "X(157)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure
    (  input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
      Line format "X(177)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").

    run OpenBR in this-procedure .
     DO WHILE available tt_price-all :
        Display STREAM PrnLibStream
        tt_price-all.plt-priority
        tt_price-all.b-code
        tt_price-all.unit-cli
        buf_currency.curr-abbr
        tt_price-all.obj-type + string(tt_price-all.obj-code) @ tt_price-all.obj-type
        tt_price-all.price-sale
        tt_price-all.price-sale-base
        tt_price-all.price-sale-rubl
        tt_price-all.date-1
        tt_price-all.date-2
        tt_price-all.grp-name
        tt_price-all.interv-name
        tt_price-all.pay-name
          with FRAME prt-frame .
          DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
         GET next BROWSE-3.
    END.

    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME