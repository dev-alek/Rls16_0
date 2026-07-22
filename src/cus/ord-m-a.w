&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI ADM2
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Методы расчета заказа для Автозаказов

Автор: Чернова Светлана Александровна
Дата создания: 02/11/02
Author: Svetlana Chernova
Creation date: 02/11/02

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter v-mode         as character     no-undo .
define input  parameter G#type         as character     no-undo .
define input-output parameter p-return as character     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Методы расчета заказа " .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/trg-def.i  }
{ cus/df-zakaz.i }
{ ref/gdsoattr.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/thbjattr.i }


define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable is-abc       as character no-undo .
define variable par-type     as character no-undo .
define variable v-p-code as integer   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).



&glob v-c DO: ~
  assign frame ~{&frame-name}   ~{&SELF-NAME} . ~
  display ~{&SELF-NAME}  with FRAME ~{&frame-name}  .  ~
END.



&glob ll-tt t-1  t-2  t-3  t-4 t-5  t-6 t-7  t-8
&glob  start-proc do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
&glob obj-order        'order':U
&glob obj-order-txt    'Из заказа'
&glob r-min-res-txt    'На фирме'
&glob obj-firm-txt     'Все по фирме'
&glob obj-currency-txt 'Текущий'
&glob obj-choice-txt   'Выборочно'
&glob obj-all-txt      'Все'

&scop list-from-max-stock p-neg-sale r-min-rest3 T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7

define temp-table tt-date no-undo
field exch-date as date
index pi is unique primary   exch-date .
define buffer alt-obj-list for obj-list .

define temp-table temp-abc-day no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.
define temp-table temp-abc-day-empty no-undo
field abc-type as character
field gar-day  as decimal
index pi abc-type
.


define variable     str-obj#  as character no-undo .
define variable     str-obj2#  as character no-undo .
define variable     str-obj3#  as character no-undo .
define variable     rec-list  as character no-undo .
define var temp-param-obj as char no-undo.     /* Объекты */
define var temp-param-obj-type as char no-undo.     /* Объекты */
define buffer cli-obj  for clients .
define variable ii as integer no-undo .

define variable  t-ret as log no-undo.
define variable d-Mond as log no-undo.
define variable rr as recid no-undo .

define buffer buf_usr-flt for ubflt.usr-flt .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-obj-list

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES obj-list tt-date temp-abc-day tmp-sale

/* Definitions for BROWSE BR-obj-list                                   */
&Scoped-define FIELDS-IN-QUERY-BR-obj-list obj-list.obj-code obj-list.obj-type
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-obj-list
&Scoped-define SELF-NAME BR-obj-list
&Scoped-define QUERY-STRING-BR-obj-list FOR EACH obj-list
&Scoped-define OPEN-QUERY-BR-obj-list OPEN QUERY br-obj-list  FOR EACH obj-list .
&Scoped-define TABLES-IN-QUERY-BR-obj-list obj-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-obj-list obj-list


/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt-date.exch-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-date
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY browse-1 FOR EACH tt-date .
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-date
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-date


/* Definitions for BROWSE BROWSE-abc-day                                */
&Scoped-define FIELDS-IN-QUERY-BROWSE-abc-day temp-abc-day.abc-type temp-abc-day.gar-day
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-abc-day
&Scoped-define SELF-NAME BROWSE-abc-day
&Scoped-define QUERY-STRING-BROWSE-abc-day FOR EACH temp-abc-day
&Scoped-define OPEN-QUERY-BROWSE-abc-day OPEN QUERY {&SELF-NAME} FOR EACH temp-abc-day .
&Scoped-define TABLES-IN-QUERY-BROWSE-abc-day temp-abc-day
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-abc-day temp-abc-day


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tmp-sale.desc_ ~
tmp-sale.tmp-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tmp-sale.desc_ ~
tmp-sale.tmp-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tmp-sale
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tmp-sale
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-obj-list}~
    ~{&OPEN-QUERY-BROWSE-1}~
    ~{&OPEN-QUERY-BROWSE-abc-day}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tmp-sale NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tmp-sale NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tmp-sale
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tmp-sale


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tmp-sale.desc_ tmp-sale.tmp-code
&Scoped-define ENABLED-TABLES tmp-sale
&Scoped-define FIRST-ENABLED-TABLE tmp-sale
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 RECT-8 ~
R-algoritm p-neg-sale R-min-rest T-gar r-min-rest3 T-min-ost R-algoritm2 ~
SelectObject BR-obj-list T-min-zapas BUTTON-obj /* date-p-1 date-p-2 */ t-way ~
BROWSE-1 BROWSE-abc-day B-10 B-1 B-2 T-clos B-3 t-rv t-rvc T-rcv B-4 t-rvz ~
T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m v-round-base ~
B-spis p-prt-art Btn_OK Btn_Cancel B-Help i-exit FILL-IN-17 FILL-IN-3 ~
t-gar-1 t-gar-2 FILL-IN-15 FILL-IN-13 t-min-ost-1 t-min-ost-2 FILL-IN-5 ~
FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7 FILL-IN-16
&Scoped-Define DISPLAYED-FIELDS tmp-sale.desc_ tmp-sale.tmp-code
&Scoped-define DISPLAYED-TABLES tmp-sale
&Scoped-define FIRST-DISPLAYED-TABLE tmp-sale
&Scoped-Define DISPLAYED-OBJECTS R-algoritm p-neg-sale R-min-rest T-gar ~
r-min-rest3 T-min-ost R-algoritm2 SelectObject T-min-zapas /* date-p-1 ~
date-p-2 */ t-way T-clos t-rv t-rvc T-rcv t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 ~
t-sppv-3 v-round-m v-round-base v-name p-prt-art FILL-IN-2 FILL-IN-17 ~
FILL-IN-3 t-gar-1 t-gar-2 FILL-IN-15 FILL-IN-13 t-min-ost-1 t-min-ost-2 ~
FILL-IN-5 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7 ~
FILL-IN-16

/* Custom List Definitions                                              */
/* dates,List-spis,List-tt,all-obj,garant,all-obj-entry                 */
&Scoped-define dates RECT-3 RECT-8 R-algoritm2 /* date-p-1 date-p-2 */ t-rv t-rvc ~
t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 FILL-IN-15 FILL-IN-14
&Scoped-define List-spis BROWSE-abc-day B-spis FILL-IN-16 tmp-sale.desc_ ~
tmp-sale.tmp-code
&Scoped-define List-tt BROWSE-1 B-10 B-1 B-2 B-3 B-4 B-5 B-6 B-7 t-1 t-2 ~
t-3 t-4 t-5 t-6 t-7
&Scoped-define all-obj R-algoritm p-neg-sale R-min-rest T-gar r-min-rest3 ~
T-min-ost R-algoritm2 SelectObject BR-obj-list T-min-zapas BUTTON-obj ~
/* date-p-1 date-p-2 */ t-way BROWSE-1 B-10 B-1 B-2 T-clos B-3 t-rv t-rvc T-rcv ~
B-4 t-rvz T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m ~
p-prt-art Btn_OK Btn_Cancel B-Help i-exit FILL-IN-2 FILL-IN-17 FILL-IN-3 ~
t-gar-1 t-gar-2 FILL-IN-15 FILL-IN-13 t-min-ost-1 t-min-ost-2 FILL-IN-5 ~
FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7 FILL-IN-16
&Scoped-define garant T-gar t-gar-1 t-gar-2
&Scoped-define all-obj-entry R-algoritm p-neg-sale R-min-rest T-gar ~
r-min-rest3 T-min-ost R-algoritm2 T-min-zapas /* date-p-1 date-p-2 */ t-way ~
T-clos t-rv t-rvc T-rcv t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3 ~
v-round-m p-prt-art FILL-IN-2 FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 ~
FILL-IN-15 FILL-IN-13 t-min-ost-1 t-min-ost-2 FILL-IN-5 FILL-IN-7 FILL-IN-8 ~
FILL-IN-16

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1
     LABEL "Пн"
     SIZE 3 BY 1 TOOLTIP "Понедельник".

DEFINE BUTTON B-10
     LABEL "Очистить"
     SIZE 10.75 BY 1 TOOLTIP "Очистить список дат".

DEFINE BUTTON B-2
     LABEL "Вт"
     SIZE 3 BY 1 TOOLTIP "Вторник".

DEFINE BUTTON B-3
     LABEL "Ср"
     SIZE 3 BY 1 TOOLTIP "Среда".

DEFINE BUTTON B-4
     LABEL "Чт"
     SIZE 3 BY 1 TOOLTIP "Четверг".

DEFINE BUTTON B-5
     LABEL "Пт"
     SIZE 3 BY 1 TOOLTIP "Пятница".

DEFINE BUTTON B-6
     LABEL "Сб"
     SIZE 3 BY 1 TOOLTIP "Суббота".

DEFINE BUTTON B-7
     LABEL "Вс"
     SIZE 3 BY 1 TOOLTIP "Воскресенье".

DEFINE BUTTON B-Help
     LABEL "&Помощь"
     SIZE 3 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON B-save
     LABEL "Сохранить"
     SIZE 15 BY 1.13.

DEFINE BUTTON B-spis
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Выбор из списка темпов продаж"
     SIZE 3 BY .88 TOOLTIP "Выбор из списка темпов продаж".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "список объектов".

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.

DEFINE VARIABLE v-round-m AS CHARACTER FORMAT "X(256)":U
     LABEL "Метод округления заказа"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE v-name AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 47 BY 2 NO-UNDO.

DEFINE VARIABLE date-p-1 AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-p-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 10.75 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-13 AS CHARACTER FORMAT "X(256)":C32 INITIAL "Объекты"
      VIEW-AS TEXT
     SIZE 32.13 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-14 AS CHARACTER FORMAT "X(256)":C21 INITIAL "Объем продаж включает"
      VIEW-AS TEXT
     SIZE 43.63 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-15 AS CHARACTER FORMAT "X(256)":C17 INITIAL "Количество дней"
      VIEW-AS TEXT
     SIZE 30.88 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-16 AS CHARACTER FORMAT "X(256)":U INITIAL "Список:"
      VIEW-AS TEXT
     SIZE 8 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-17 AS CHARACTER FORMAT "X(256)":C20 INITIAL "Методы расчета темпа продаж"
      VIEW-AS TEXT
     SIZE 39.38 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":C12 INITIAL "Параметры товара"
      VIEW-AS TEXT
     SIZE 23 BY .67
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL " до привоза товара"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL " заказ которого меньше"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-7 AS CHARACTER FORMAT "X(256)":U INITIAL " минимального заказа"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "в статусах:"
      VIEW-AS TEXT
     SIZE 12.13 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE t-1 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-2 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-3 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-4 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-5 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-6 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-7 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-gar-1 AS CHARACTER FORMAT "X(256)":U INITIAL "остаток которого больше"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-gar-2 AS CHARACTER FORMAT "X(256)":U INITIAL " гарантийного запаса"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-min-ost-1 AS CHARACTER FORMAT "X(256)":U INITIAL "остаток которого больше"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE t-min-ost-2 AS CHARACTER FORMAT "X(256)":U INITIAL "минимального остатка"
      VIEW-AS TEXT
     SIZE 30.63 BY .67 NO-UNDO.

DEFINE VARIABLE v-round-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE R-algoritm AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Среднесуточный", 1,
"Из списка", 2,
"Вероятностный по гарантийному запасу", 3,
"По максимуму объема продаж", 4,
"Заказ до максимального остатка", 5,
"По ABC-анализу", 6
     SIZE 39.25 BY 3.75 NO-UNDO.

DEFINE VARIABLE R-algoritm2 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все за период", 1,
"Без дней без товара", 2
/*"Выбранные по календарю", 3*/
     SIZE 30 BY 2 NO-UNDO.

DEFINE VARIABLE R-min-rest AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "На объекте", 1,
"На фирме", 2
     SIZE 23 BY 1.54 TOOLTIP "Используемый в расчете параметр товара со склада или с фирмы в целом" NO-UNDO.

DEFINE VARIABLE SelectObject AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все по фирме", "firm":U,
"Текущий", "currency":U,
"Выборочно", "choice":U,
"Все", "all":U,
"Из заказа", "order":U
     SIZE 15.13 BY 3.88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 41.13 BY 4.79.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.88 BY 11.88.

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 24 BY 4.79.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.63 BY 10.13.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.63 BY 5.29.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 5.33.

DEFINE VARIABLE p-neg-sale AS LOGICAL INITIAL no
     LABEL "Запрет на продажу в минус"
     VIEW-AS TOGGLE-BOX
     SIZE 32.13 BY .83 TOOLTIP "Запрет на продажу в минус до привоза товара" NO-UNDO.

DEFINE VARIABLE p-prt-art AS LOGICAL INITIAL no
     LABEL "Печать артикула на всех строках"
     VIEW-AS TOGGLE-BOX
     SIZE 34.13 BY .83 TOOLTIP "Печать артикула на всех строках отчета"
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE r-min-rest3 AS LOGICAL INITIAL no
     LABEL "Сезонный мин.остаток"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY .83 TOOLTIP "использовать параметр товара мин.остаток = сезонный" NO-UNDO.

DEFINE VARIABLE T-clos AS LOGICAL INITIAL no
     LABEL "закрыто"
     VIEW-AS TOGGLE-BOX
     SIZE 12.13 BY .83 NO-UNDO.

DEFINE VARIABLE T-gar AS LOGICAL INITIAL no
     LABEL "Не заказывать товар,"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .83 TOOLTIP "Не заказывать товар, остаток которого больше гарантийного запаса" NO-UNDO.

DEFINE VARIABLE T-min-ost AS LOGICAL INITIAL no
     LABEL "Не заказывать товар,"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY .83 TOOLTIP "Не заказывать товар, остаток которого больше минимального запаса" NO-UNDO.

DEFINE VARIABLE T-min-zapas AS LOGICAL INITIAL no
     LABEL "Не заказывать товар,"
     VIEW-AS TOGGLE-BOX
     SIZE 31.88 BY .83 TOOLTIP "Не заказывать товар, заказ которого меньше минимального заказа" NO-UNDO.

DEFINE VARIABLE T-rcv AS LOGICAL INITIAL no
     LABEL "поставка"
     VIEW-AS TOGGLE-BOX
     SIZE 12.13 BY .83 NO-UNDO.

DEFINE VARIABLE t-rv AS LOGICAL INITIAL no
     LABEL "Расход внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.

DEFINE VARIABLE t-rvc AS LOGICAL INITIAL no
     LABEL "Расход внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-rvz AS LOGICAL INITIAL no
     LABEL "Возврат внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-rvzc AS LOGICAL INITIAL no
     LABEL "Возврат внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE T-sp AS LOGICAL INITIAL no
     LABEL "Списание внешнее"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.

DEFINE VARIABLE T-sppv-2 AS LOGICAL INITIAL no
     LABEL "Списание пр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 18.88 BY .83 NO-UNDO.

DEFINE VARIABLE t-sppv-3 AS LOGICAL INITIAL no
     LABEL "Расход внутренний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE T-sppv-4 AS LOGICAL INITIAL no
     LABEL "Возврат внутр."
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-way AS LOGICAL INITIAL no
     LABEL "Учитывать предыдущие заказы"
     VIEW-AS TOGGLE-BOX
     SIZE 31.88 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-obj-list FOR
      obj-list SCROLLING.

DEFINE QUERY BROWSE-1 FOR
      tt-date SCROLLING.

DEFINE QUERY BROWSE-abc-day FOR
      temp-abc-day SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tmp-sale SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-obj-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-obj-list Dialog-Frame _FREEFORM
  QUERY BR-obj-list DISPLAY
      obj-list.obj-code
      obj-list.obj-type
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-BOX NO-LABELS NO-ROW-MARKERS SIZE 17.38 BY 3.88
         BGCOLOR 8 .

DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      tt-date.exch-date column-label "Даты":C10 format "99/99/9999"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 13.25 BY 7.29.

DEFINE BROWSE BROWSE-abc-day
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-abc-day Dialog-Frame _FREEFORM
  QUERY BROWSE-abc-day DISPLAY
      temp-abc-day.abc-type COLUMN-LABEL "ABC" FORMAT "x(3)"
temp-abc-day.gar-day  COLUMN-LABEL "Гарант.запас!в днях  " FORMAT ">>>>>>>>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 21.5 BY 7.33 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     R-algoritm AT ROW 2 COL 2 NO-LABEL
     p-neg-sale AT ROW 2 COL 67.75
     R-min-rest AT ROW 2.21 COL 43.13 NO-LABEL
     T-gar AT ROW 3.54 COL 67.75
     r-min-rest3 AT ROW 3.92 COL 43.13
     T-min-ost AT ROW 5.75 COL 67.75 WIDGET-ID 2
     R-algoritm2 AT ROW 7.25 COL 2 NO-LABEL
     SelectObject AT ROW 7.29 COL 34.13 NO-LABEL
     BR-obj-list AT ROW 7.29 COL 49.13
     T-min-zapas AT ROW 7.96 COL 67.75
     BUTTON-obj AT ROW 8.75 COL 45.88
     date-p-1 AT ROW 9.33 COL 3.63 COLON-ALIGNED
     date-p-2 AT ROW 9.33 COL 19.25 COLON-ALIGNED
     t-way AT ROW 10.21 COL 67.75
     BROWSE-1 AT ROW 10.38 COL 6.88
     BROWSE-abc-day AT ROW 10.42 COL 1.5
     B-10 AT ROW 10.42 COL 21.25
     B-1 AT ROW 10.5 COL 1.5
     B-2 AT ROW 11.5 COL 1.5
     T-clos AT ROW 12.33 COL 87
     B-3 AT ROW 12.5 COL 1.5
     t-rv AT ROW 12.75 COL 34.13
     t-rvc AT ROW 12.79 COL 53.25
     T-rcv AT ROW 13.17 COL 87
     B-4 AT ROW 13.5 COL 1.5
     t-rvz AT ROW 13.67 COL 34.13
     T-rvzc AT ROW 13.67 COL 53.25
     B-5 AT ROW 14.5 COL 1.5
     T-sppv-4 AT ROW 14.5 COL 53.25
     T-sp AT ROW 14.54 COL 34.13
     T-sppv-2 AT ROW 15.42 COL 34.13
     t-sppv-3 AT ROW 15.42 COL 53.25
     B-6 AT ROW 15.5 COL 1.5
     B-7 AT ROW 16.5 COL 1.5
     v-round-m AT ROW 17 COL 58 COLON-ALIGNED
     v-round-base AT ROW 17 COL 84 COLON-ALIGNED NO-LABEL
     B-spis AT ROW 18.42 COL 9.75
     v-name AT ROW 19.5 COL 1 NO-LABEL
     p-prt-art AT ROW 19.67 COL 66 WIDGET-ID 8
     B-save AT ROW 20.5 COL 51.63
     Btn_OK AT ROW 20.5 COL 66.75
     Btn_Cancel AT ROW 20.5 COL 82
     B-Help AT ROW 20.5 COL 97.5
     i-exit AT ROW 20.71 COL 66.88 WIDGET-ID 10
     FILL-IN-2 AT ROW 1.21 COL 41.13 COLON-ALIGNED NO-LABEL
     FILL-IN-17 AT ROW 1.25 COL 1.88 NO-LABEL
     FILL-IN-3 AT ROW 2.67 COL 67 COLON-ALIGNED NO-LABEL
     t-gar-1 AT ROW 4.21 COL 67 COLON-ALIGNED NO-LABEL
     t-gar-2 AT ROW 4.83 COL 66.88 COLON-ALIGNED NO-LABEL
     FILL-IN-15 AT ROW 6.25 COL 1.63 NO-LABEL
     FILL-IN-13 AT ROW 6.33 COL 32.25 COLON-ALIGNED NO-LABEL
     t-min-ost-1 AT ROW 6.42 COL 66.88 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     t-min-ost-2 AT ROW 7.04 COL 66.88 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     FILL-IN-5 AT ROW 8.67 COL 67.13 COLON-ALIGNED NO-LABEL
     FILL-IN-7 AT ROW 9.29 COL 67.13 COLON-ALIGNED NO-LABEL
     t-1 AT ROW 10.58 COL 2.63 COLON-ALIGNED NO-LABEL
     FILL-IN-8 AT ROW 11.42 COL 85 COLON-ALIGNED NO-LABEL
     FILL-IN-14 AT ROW 11.54 COL 32.5 COLON-ALIGNED NO-LABEL
     t-2 AT ROW 11.67 COL 2.63 COLON-ALIGNED NO-LABEL
     t-3 AT ROW 12.54 COL 2.63 COLON-ALIGNED NO-LABEL
     t-4 AT ROW 13.67 COL 2.63 COLON-ALIGNED NO-LABEL
     t-5 AT ROW 14.71 COL 2.63 COLON-ALIGNED NO-LABEL
     t-6 AT ROW 15.67 COL 2.63 COLON-ALIGNED NO-LABEL
     t-7 AT ROW 16.58 COL 2.63 COLON-ALIGNED NO-LABEL
     FILL-IN-16 AT ROW 18.04 COL 1.75 NO-LABEL
     tmp-sale.desc_ AT ROW 18.21 COL 11 COLON-ALIGNED NO-LABEL FORMAT "X(120)"
           VIEW-AS TEXT
          SIZE 59.88 BY .67
          FGCOLOR 1
     tmp-sale.tmp-code AT ROW 19.04 COL 11 COLON-ALIGNED NO-LABEL FORMAT "X(120)"
           VIEW-AS TEXT
          SIZE 59.75 BY .67
     "Дополнительные условия расчета":C32 VIEW-AS TEXT
          SIZE 32 BY .67 AT ROW 1.25 COL 67.25
          BGCOLOR 8 FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         FGCOLOR 0
         CANCEL-BUTTON Btn_Cancel.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     RECT-1 AT ROW 1.08 COL 1
     RECT-3 AT ROW 6 COL 1.13
     RECT-5 AT ROW 1.08 COL 42.38
     RECT-6 AT ROW 1.13 COL 66.88
     RECT-7 AT ROW 6 COL 33.5
     RECT-8 AT ROW 11.42 COL 33.5
     SPACE(22.01) SKIP(4.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         FGCOLOR 0
         TITLE "Параметры расчета заказа"
         CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-obj-list SelectObject Dialog-Frame */
/* BROWSE-TAB BROWSE-1 t-way Dialog-Frame */
/* BROWSE-TAB BROWSE-abc-day BROWSE-1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-1 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-10 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-2 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-3 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-4 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-5 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-6 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-7 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BUTTON B-Help IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR BUTTON B-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       B-save:HIDDEN IN FRAME Dialog-Frame           = TRUE.
       date-p-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
       date-p-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR BUTTON B-spis IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BROWSE BR-obj-list IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR BROWSE BROWSE-1 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR BROWSE BROWSE-abc-day IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON Btn_Cancel IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR BUTTON Btn_OK IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR BUTTON BUTTON-obj IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR FILL-IN date-p-1 IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR FILL-IN date-p-2 IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR FILL-IN tmp-sale.desc_ IN FRAME Dialog-Frame
   2 EXP-FORMAT                                                         */
/* SETTINGS FOR FILL-IN FILL-IN-13 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN FILL-IN-14 IN FRAME Dialog-Frame
   1 4                                                                  */
/* SETTINGS FOR FILL-IN FILL-IN-15 IN FRAME Dialog-Frame
   ALIGN-L 1 4 6                                                        */
/* SETTINGS FOR FILL-IN FILL-IN-16 IN FRAME Dialog-Frame
   ALIGN-L 2 4 6                                                        */
/* SETTINGS FOR FILL-IN FILL-IN-17 IN FRAME Dialog-Frame
   ALIGN-L 4 6                                                          */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   NO-ENABLE 4 6                                                        */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN FILL-IN-5 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN FILL-IN-7 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN FILL-IN-8 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR BUTTON i-exit IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR TOGGLE-BOX p-neg-sale IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR TOGGLE-BOX p-prt-art IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR RADIO-SET R-algoritm IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR RADIO-SET R-algoritm2 IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR RADIO-SET R-min-rest IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR TOGGLE-BOX r-min-rest3 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR RECTANGLE RECT-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-8 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RADIO-SET SelectObject IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR FILL-IN t-1 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR FILL-IN t-2 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR FILL-IN t-3 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR FILL-IN t-4 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR FILL-IN t-5 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR FILL-IN t-6 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR FILL-IN t-7 IN FRAME Dialog-Frame
   3 4                                                                  */
/* SETTINGS FOR TOGGLE-BOX T-clos IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR TOGGLE-BOX T-gar IN FRAME Dialog-Frame
   4 5 6                                                                */
/* SETTINGS FOR FILL-IN t-gar-1 IN FRAME Dialog-Frame
   4 5 6                                                                */
/* SETTINGS FOR FILL-IN t-gar-2 IN FRAME Dialog-Frame
   4 5 6                                                                */
/* SETTINGS FOR TOGGLE-BOX T-min-ost IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN t-min-ost-1 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN t-min-ost-2 IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR TOGGLE-BOX T-min-zapas IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR TOGGLE-BOX T-rcv IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR TOGGLE-BOX t-rv IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX t-rvc IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX t-rvz IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX T-rvzc IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX T-sp IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX T-sppv-2 IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX t-sppv-3 IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX T-sppv-4 IN FRAME Dialog-Frame
   1 4 6                                                                */
/* SETTINGS FOR TOGGLE-BOX t-way IN FRAME Dialog-Frame
   4 6                                                                  */
/* SETTINGS FOR FILL-IN tmp-sale.tmp-code IN FRAME Dialog-Frame
   2 EXP-FORMAT                                                         */
/* SETTINGS FOR EDITOR v-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       v-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR COMBO-BOX v-round-m IN FRAME Dialog-Frame
   4 6                                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-obj-list
/* Query rebuild information for BROWSE BR-obj-list
     _START_FREEFORM
OPEN QUERY br-obj-list  FOR EACH obj-list .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-obj-list */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY browse-1 FOR EACH tt-date .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-abc-day
/* Query rebuild information for BROWSE BROWSE-abc-day
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-abc-day .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-abc-day */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.tmp-sale"
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры расчета заказа */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame /* Пн */
DO:
  run p-calc in this-procedure ( input-output t-1 , input 1) .
  display  {&List-tt} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-10
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-10 Dialog-Frame
ON CHOOSE OF B-10 IN FRAME Dialog-Frame /* Очистить */
DO:
     for each tt-date :
         delete tt-date.
   end.
   assign
    t-1 = false
    t-2 = false
    t-3 = false
    t-4 = false
    t-5 = false
    t-6 = false
    t-7 = false
 .
 display  {&List-tt}  with frame {&FRAME-NAME}.

  {&OPEN-QUERY-BROWSE-1}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame /* Вт */
DO:
  run p-calc in this-procedure (input-output t-2 ,input 2) .
  display  {&List-tt}  with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame /* Ср */
DO:
  run p-calc in this-procedure  (input-output t-3 ,input 3) .
  display  {&List-tt}  with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame /* Чт */
DO:
  run p-calc in this-procedure (input-output t-4 ,input 4) .
  display  {&List-tt}  with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame /* Пт */
DO:
  run p-calc in this-procedure (input-output t-5 ,input 5) .
  display  {&List-tt}  with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame /* Сб */
DO:
  run p-calc in this-procedure (input-output t-6 ,input 6) .
  display  {&List-tt}  with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame /* Вс */
DO:
  run p-calc in this-procedure (input-output t-7 ,input 7) .
  display {&List-tt} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-save Dialog-Frame
ON CHOOSE OF B-save IN FRAME Dialog-Frame /* Сохранить */
DO:

apply "choose" to btn_ok  in frame {&frame-name} .

/* запомним для пользователя */

 find first buf_usr-flt  exclusive-lock  where
         buf_usr-flt.user-name    = g#userid and
         buf_usr-flt.call-point   = "all-ord":U   no-error .
     if NOT available buf_usr-flt then  create buf_usr-flt.
     find first ub.tmp-sale where recid(ub.tmp-sale) = rr  no-lock no-error .
       Assign
         buf_usr-flt.user-name    = g#userid
         buf_usr-flt.call-point   = "all-ord":U
         buf_usr-flt.list_ = "".
         run remember-screen ( input-output buf_usr-flt.list_ ).

t-ret =  session:SET-WAIT-STATE("") .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-spis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-spis Dialog-Frame
ON CHOOSE OF B-spis IN FRAME Dialog-Frame /* Выбор из списка темпов продаж */
DO:

define variable t-recid as recid no-undo .
define variable s-recid as character no-undo .

    if r-algoritm = 6 then do:
      define buffer buf_abc-analysis for abc-analysis  .
      run cus/abc-run.p (input parparentproc, output s-recid ).
      if num-entries(s-recid) <> 2 THEN DO:
        message "Для данного метода расчета надо выбрать 2 анализа" view-as alert-box information .
        return no-apply.
      END.
      find first abc-analysis  where recid(abc-analysis) = int(entry(1,s-recid)) no-lock no-error .
      if available abc-analysis and not error-status :error  then do:
        v-p-code = abc-analysis.abc-id .
        display ( abc-analysis.abc-name  + " от " +  string(abc-analysis.abc-date-create, "99/99/9999")) @ ub.tmp-sale.desc_
                  with frame {&frame-name} .
                  v-name = "1." + ( abc-analysis.abc-name + " от " + string(abc-analysis.abc-date-create, "99/99/9999")) .

       end.

      if num-entries(s-recid) > 1 then do:
          find first buf_abc-analysis  where recid(buf_abc-analysis) = int(entry(2,s-recid)) no-lock no-error .
          rr = ? .
          if available buf_abc-analysis and not error-status :error  then do:
            display ( buf_abc-analysis.abc-name  + " от " +  string(buf_abc-analysis.abc-date-create, "99/99/9999")) @  ub.tmp-sale.tmp-code
                      with frame {&frame-name} .
                      v-name = v-name + " 2." + ( buf_abc-analysis.abc-name  + " от " +  string(buf_abc-analysis.abc-date-create, "99/99/9999")) .
            end.
      end.
  end.
  else do:
      run ref/tmp-sale.w
        (input parparentproc
        ,input "b-sel"
        ,output t-recid
        ).
      find first ub.tmp-sale  where recid(ub.tmp-sale) = int(t-recid) no-lock no-error .
      rr = t-recid.
      if available  ub.tmp-sale and not error-status :error  then
        display  ub.tmp-sale.tmp-code
                 ub.tmp-sale.desc_
                 with frame {&frame-name} .

        else do:
        display "" @ ub.tmp-sale.tmp-code
                "" @ ub.tmp-sale.desc_
                 with frame {&frame-name} .
        end.
      end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выполнить */
DO:
define variable p-code as character no-undo .
define variable p-desc as character no-undo .
define variable obj-jj as integer no-undo .
define variable Ret as logical no-undo .
define variable t-type as character no-undo .
define variable loc-sum-min as decimal no-undo .


Assign frame {&frame-name} {&all-obj-entry}  no-error .
Assign frame {&frame-name} v-round-base no-error .


if date-p-1 <> ? and date-p-2 <> ? then do:
   if date-p-1 >  date-p-2 then do:
                                 message "Не верно задан интервал дат для расчета обьема продаж !"
                                 view-as alert-box information.
                                 return no-apply .
                                end.
end.
/*
message
"t-rv     "    t-rv        skip
"t-rvz    "    t-rvz       skip
"t-rvc    "    t-rvc       skip
"t-rvzc   "    t-rvzc      skip
"t-sp     "    t-sp        skip
"t-sppv-2 "    t-sppv-2    skip
"t-sppv-3 "    t-sppv-3    skip
"t-sppv-4 "    t-sppv-4    skip
R-algoritm
.
*/

if (t-rv      = false  and
    t-rvz     = false  and
    t-rvc     = false  and
    t-rvzc    = false  and
    t-sp      = false  and
    t-sppv-2  = false  and
    t-sppv-3  = false  and
    t-sppv-4  = false ) and
    ( R-algoritm <> 2  and R-algoritm <> 6  and  R-algoritm <> 5)  then do:
     message  " Не выбран ни один тип документа, по которым рассчитывается обьем продаж !"
     view-as alert-box information.
     return no-apply .
end.
if v-round-m = {&ord-round-qnty-card} then do:
   for each  tmp#zakaz :
       if tmp#zakaz.cli-base-rate <> 1 then do:
        message
          substitute("При методе округления до числа в упаковке не учитывается ед.измерения Поставщика.
          &3Измените ед.изм. поставщика в заказе у товара
          &3артикул &1 код &2
          &3на &4"
          , tmp#zakaz.artic, tmp#zakaz.gds-code, {&new-line} , tmp#zakaz.unit-base)
          view-as alert-box information.
          return no-apply.
       end.
   end.
end.

if t-way:visible = false then t-way = false .
if t-way = false then
assign
  t-clos  = false
  t-rcv   = false
.

if NOT ( t-way = true and  ( t-clos  = true  or  t-rcv  = true  )
         or
         t-way = false )
then do:
message "При учете предыдущих заказов надо выбрать хотя бы один статус !"
  view-as alert-box information.
   return no-apply.

end.

if t-way:visible = false then t-way = false .

if R-algoritm2 = 3 and R-algoritm2:visible  and not can-find (  first  tt-date  )  then do:
message "При календарном методе расчета должна быть заполнена таблица - даты"
  view-as alert-box information.
return no-apply.
end.


if  R-algoritm = 2 then do:
if not available ub.tmp-sale then
   find ub.tmp-sale  where recid(ub.tmp-sale) = rr no-lock no-error  .
    if available ub.tmp-sale then
        assign
            p-code = ub.tmp-sale.tmp-code
            p-desc = ub.tmp-sale.desc_
            .
end.

if  R-algoritm = 2  and ( ub.tmp-sale.tmp-code:screen-value in frame {&frame-name} = ? OR ub.tmp-sale.tmp-code:screen-value in frame {&frame-name} = "" ) then do:
    message "Не выбран список темпов продаж!!!"
    view-as alert-box information.
    return no-apply.
end.

if  R-algoritm = 6  then do:
    assign
        p-code = ?
        p-desc = v-name
    .
end.

/* Вытащим данные по Мин остатку */
if v-mode <> "all-ord":U then dO:
   run ord-mm in this-procedure .
end.


/* сохранение выбранной информации */
e-method =  FILL-IN-17 + " : " + entry(R-algoritm * 2 - 1 , R-algoritm:RADIO-BUTTONS)   +
           (  if R-algoritm = 2 or R-algoritm = 6 then ( " : " +  p-desc   + {&new-line}) else "" ) +  ";" .

if R-algoritm <> 2  and R-algoritm <> 5 and  R-algoritm <> 6 then
e-method =  e-method  +  FILL-IN-15 + " : " + entry(R-algoritm2 * 2 - 1 , R-algoritm2:RADIO-BUTTONS) +  ";" + {&new-line} +
           (  if date-p-1 <> ? and R-algoritm <> 2 and R-algoritm <> 6 and R-algoritm <> 5 then "c  "  + string(date-p-1,"99/99/9999") else " " ) +
           (  if date-p-2 <> ? and R-algoritm <> 2 and R-algoritm <> 6 and R-algoritm <> 5 then " по " + string(date-p-2,"99/99/9999") else " " ) +  ";" +  {&new-line} +
           (  if t-1 then " " + b-1:label   else "" ) +
           (  if t-2 then " " + b-2:label   else "" ) +
           (  if t-3 then " " + b-3:label   else "" ) +
           (  if t-4 then " " + b-4:label   else "" ) +
           (  if t-5 then " " + b-5:label   else "" ) +
           (  if t-6 then " " + b-6:label   else "" ) +
           (  if t-7 then " " + b-7:label   else "" ) .

e-method =  e-method  +      ";" +  {&new-line} +
           FILL-IN-2 + " : " + entry(R-min-rest * 2 - 1 , R-min-rest:RADIO-BUTTONS)  .
 e-method = e-method +   {&new-line} +
         ( if  r-min-rest3    then  " : " + r-min-rest3:label  else "" ) + ";" .


 e-method = e-method +   {&new-line}   +
         ( if  FILL-IN-14:visible             then  FILL-IN-14 + " : "     else "" ) +
         ( if  t-rv     and t-rv:visible      then  " " + t-rv  :label     else "" ) +
         ( if  t-rvz    and t-rvz:visible     then  " " + t-rvz :label     else "" ) +
         ( if  t-rvc    and t-rvc:visible     then  " " + t-rvc :label     else "" ) +
         ( if  t-rvzc   and t-rvzc:visible    then  " " + t-rvzc:label     else "" ) +
         ( if  t-sp     and t-sp:visible      then  " " + t-sp  :label     else "" ) +
         ( if  t-sppv-2 and t-sppv-2:visible  then  " " + t-sppv-2:label   else "" ) +
         ( if  t-sppv-3 and t-sppv-3:visible  then  " " + t-sppv-3:label   else "" ) +
         ( if  t-sppv-4 and t-sppv-4:visible  then  " " + t-sppv-4:label   else "" )
           .
 e-method = e-method +   {&new-line} +
         ( if  t-way    and t-way:visible   then  " " + t-way  :label + " : "    else "" ) +
         ( if  t-rcv    and t-rcv:visible   then  " " + t-rcv  :label            else "" ) +
         ( if  t-clos   and t-clos:visible  then  " " + t-clos :label            else "" ) + ";"
         .

 e-method = e-method +   {&new-line} +
         ( if  p-neg-sale  and  p-neg-sale:visible   then  " " + p-neg-sale  :tooltip + " : "    else "" ) +
         ( if  t-gar       and  t-gar:visible        then  " " + t-gar  :tooltip            else "" ) +
         ( if  t-min-ost   and  t-min-ost:visible    then  " " + t-min-ost  :tooltip + " : "    else "" ) +
         ( if  t-min-zapas and  t-min-zapas:visible  then  " " + t-min-zapas :tooltip            else "" ) + ";"
         .

 e-method = e-method +  {&new-line} + "Объекты :&"  .
          for each obj-list :
                  e-method = e-method +  obj-list.obj-type + " " + string(obj-list.obj-code) + ","    .
          end.

/* запомним для пользователя и для документа */
 if v-mode <> "all-ord":U and v-mode <> "auto-ord" then dO:
      find first buf_usr-flt  exclusive-lock  where
              buf_usr-flt.user-name    = loc-ord-num and
              buf_usr-flt.call-point   = "ord-m":U + ( if v-mode <> ? then v-mode else "" )  no-error .
          if NOT available buf_usr-flt then  create buf_usr-flt.
          find first ub.tmp-sale where recid(ub.tmp-sale) = rr  no-lock no-error .
            Assign
              buf_usr-flt.user-name    = loc-ord-num
              buf_usr-flt.call-point   = "ord-m":U + ( if v-mode <> ? then v-mode else "" )
              buf_usr-flt.list_ = "".
              run remember-screen ( input-output buf_usr-flt.list_ ).

      find first buf_usr-flt  exclusive-lock  where
              buf_usr-flt.user-name    = g#userid and
              buf_usr-flt.call-point   = "ord-m":U  no-error .
          if NOT available buf_usr-flt then  create buf_usr-flt.
            Assign
              buf_usr-flt.user-name    = g#userid
              buf_usr-flt.call-point   = "ord-m":U
              buf_usr-flt.list_ = "".
              run remember-screen ( input-output buf_usr-flt.list_ ).


      /* вызов пересчета заказа */
      t-ret =  session:SET-WAIT-STATE("GENERAL") .
          for each obj-list :
            obj-jj = obj-jj + 1.
          end.

          if g#type = {&f-p} and R-min-rest = 1 then  do:
             if R-algoritm = 6 /* ABC */ then do:
                run cus/qnty-obj.p
                (     input parParentProc,
                      input v-round-m ,
                      input v-round-base ,
                      input e-method ,
                      input v-mode,
                      input loc-ord-num ,
                      input date-p-1,
                      input date-p-2,
                      input "calc":U,
                      input no,
                      input 2  ,
                      input R-algoritm2,
                      input R-min-rest ,
                      input R-min-rest3,
                      input p-code     ,
                      input t-rv       ,
                      input t-rvz      ,
                      input t-rvc      ,
                      input t-rvzc  ,
                      input t-sp    ,
                      input t-sppv-2  ,
                      input t-sppv-2,
                      input t-sppv-3,
                      input t-sppv-4,
                      input t-way   ,
                      input t-rcv   ,
                      input t-clos  ,
                      input table tt-date ,
                      input table temp-abc-day ,
                      input p-neg-sale  ,
                      input t-gar       ,
                      input t-min-zapas ,
                      input t-min-ost   ,
                      input store-type  ,
                      input store-code  ,
                      input g#type      ,
                      input no
                      ) no-error .
             end.
             else do:
                run cus/qnty-obj.p
                (     input parParentProc,
                      input v-round-m ,
                      input v-round-base ,
                      input e-method ,
                      input v-mode,
                      input loc-ord-num ,
                      input date-p-1,
                      input date-p-2,
                      input "calc":U,
                      input no,
                      input R-algoritm  ,
                      input R-algoritm2,
                      input R-min-rest ,
                      input R-min-rest3,
                      input p-code     ,
                      input t-rv       ,
                      input t-rvz      ,
                      input t-rvc      ,
                      input t-rvzc  ,
                      input t-sp    ,
                      input t-sppv-2  ,
                      input t-sppv-2,
                      input t-sppv-3,
                      input t-sppv-4,
                      input t-way   ,
                      input t-rcv   ,
                      input t-clos  ,
                      input table tt-date ,
                      input table temp-abc-day-empty ,
                      input p-neg-sale    ,
                      input t-gar         ,
                      input t-min-zapas ,
                      input t-min-ost ,
                      input store-type  ,
                      input store-code  ,
                      input g#type     ,
                      input no
                      ) no-error .
             end.
              if error-status :error then do:
                message  error-status :get-message(1) .
                error-status :error = false.
              end.
          end.
          else  do:  /* ОРЦ ОО ОП ОФ */
             if R-algoritm = 6 /* ABC */ then do:
                run cus/qntysale.p
                  ( input parParentProc,
                    input v-round-m ,
                    input v-round-base ,
                    input e-method ,
                    input v-mode,
                    input loc-ord-num ,
                    input date-p-1,
                    input date-p-2,
                    input "calc":U,
                    input no,
                    input 2 ,
                    input R-algoritm2,
                    input R-min-rest,
                    input R-min-rest3,
                    input p-code,
                    input t-rv,
                    input t-rvz,
                    input t-rvc ,
                    input t-rvzc ,
                    input t-sp   ,
                    input t-sppv-2 ,
                    input t-sppv-2,
                    input t-sppv-3,
                    input t-sppv-4,
                    input t-way,
                    input t-rcv,
                    input t-clos,
                    input table tt-date ,
                    input table temp-abc-day ,
                    input p-neg-sale,
                    input t-gar,
                    input t-min-zapas ,
                    input t-min-ost ,
                    input store-type  ,
                    input store-code  ,
                    input g#type    ,
                    input no
                    ) no-error .
             end.
             else do:
                run cus/qntysale.p
                  ( input parParentProc,
                    input v-round-m ,
                    input v-round-base ,
                    input e-method ,
                    input v-mode,
                    input loc-ord-num ,
                    input date-p-1,
                    input date-p-2,
                    input "calc":U,
                    input no,
                    input R-algoritm ,
                    input R-algoritm2,
                    input R-min-rest,
                    input R-min-rest3,
                    input p-code,
                    input t-rv,
                    input t-rvz,
                    input t-rvc ,
                    input t-rvzc ,
                    input t-sp   ,
                    input t-sppv-2 ,
                    input t-sppv-2,
                    input t-sppv-3,
                    input t-sppv-4,
                    input t-way,
                    input t-rcv,
                    input t-clos,
                    input table tt-date ,
                    input table temp-abc-day-empty ,
                    input p-neg-sale,
                    input t-gar,
                    input t-min-zapas ,
                    input t-min-ost ,
                    input store-type  ,
                    input store-code  ,
                    input g#type  ,
                    input no
                    ) no-error .
             end.
              if error-status :error then do:
                message error-status :get-message(1) .
                error-status :error = false   .
              end.
          end.

          if  G#type <> {&o-o} and
              G#type <> {&o-r}
          then run calc-sum-vat in this-procedure .

          if v-mode = ? then do:
              for each tmp#zakaz:
                  find first shar_ord-line  exclusive-lock  where
                        shar_ord-line.doc-code  = loc-ord-num and
                        shar_ord-line.artic     = tmp#zakaz.artic and
                        shar_ord-line.prod-type = tmp#zakaz.prod-type and
                        shar_ord-line.prod-code = tmp#zakaz.prod-code no-error  .
                  if available shar_ord-line then do:
                    BUFFER-COPY tmp#zakaz /* EXCEPT tmp#zakaz.doc-num */ to  shar_ord-line .
                  end.
              end.
          end.
 end.
 if v-mode = "auto-ord" then do:
   run remember-screen ( input-output p-return ).
 end.
t-ret =  session:SET-WAIT-STATE("") .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-obj Dialog-Frame
ON CHOOSE OF BUTTON-obj IN FRAME Dialog-Frame
DO:
  assign SelectObject.
  my-request = false .
  run select-objects-proc in this-procedure (input e-method).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME p-prt-art
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-prt-art Dialog-Frame
ON VALUE-CHANGED OF p-prt-art IN FRAME Dialog-Frame /* Печать артикула на всех строках */
DO:
assign
  p-prt-art
.
 v-show-all-goods = p-prt-art .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-algoritm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-algoritm Dialog-Frame
ON VALUE-CHANGED OF R-algoritm IN FRAME Dialog-Frame
DO:
    run v-c-alg in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-algoritm2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-algoritm2 Dialog-Frame
ON VALUE-CHANGED OF R-algoritm2 IN FRAME Dialog-Frame
DO:
run v-c-2 in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectObject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectObject Dialog-Frame
ON VALUE-CHANGED OF SelectObject IN FRAME Dialog-Frame
DO:
  Assign SelectObject.
run select-objects-proc in this-procedure (input e-method).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rv Dialog-Frame
ON VALUE-CHANGED OF t-rv IN FRAME Dialog-Frame /* Расход внешний */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rvc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rvc Dialog-Frame
ON VALUE-CHANGED OF t-rvc IN FRAME Dialog-Frame /* Расход внешний касса */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rvz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rvz Dialog-Frame
ON VALUE-CHANGED OF t-rvz IN FRAME Dialog-Frame /* Возврат внешний */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-rvzc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-rvzc Dialog-Frame
ON VALUE-CHANGED OF T-rvzc IN FRAME Dialog-Frame /* Возврат внешний касса */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sp Dialog-Frame
ON VALUE-CHANGED OF T-sp IN FRAME Dialog-Frame /* Списание внешнее */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sppv-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sppv-2 Dialog-Frame
ON VALUE-CHANGED OF T-sppv-2 IN FRAME Dialog-Frame /* Списание пр-во */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sppv-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sppv-3 Dialog-Frame
ON VALUE-CHANGED OF t-sppv-3 IN FRAME Dialog-Frame /* Расход внутренний */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-sppv-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-sppv-4 Dialog-Frame
ON VALUE-CHANGED OF T-sppv-4 IN FRAME Dialog-Frame /* Возврат внутр. */
DO:
  {&v-c}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-way
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-way Dialog-Frame
ON VALUE-CHANGED OF t-way IN FRAME Dialog-Frame /* Учитывать предыдущие заказы */
DO:
  run v-c-way in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-round-m
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-round-m Dialog-Frame
ON VALUE-CHANGED OF v-round-m IN FRAME Dialog-Frame /* Метод округления заказа */
DO:
  ASSIGN v-round-m .
  if lookup ( v-round-m , {&ord-rounds-need-coef} ) > 0 then do:
     enable  v-round-base with frame {&frame-name} .
     display v-round-base with frame {&frame-name} .
     end.
     else hide v-round-base in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-obj-list
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exitObject condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

{ gbl/app_help.i }
{ gbl/ed_date.i date-p-1 }
{ gbl/ed_date.i date-p-2 }
{ cus/ord-mm.i   }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/conf-rd.i "'is-abc'"  "''" "''" 0 "''" "''" "''" no  is-abc  par-type no-error }
    if error-status :error then is-abc = "no" .
    run loc-enable-ui in this-procedure .
    v-round-m:list-items = {&ord-rounds} .

    if G#type = {&o-r} then do:
    end.
    else do:
       pay-day = date-sale-2 - date-sale-1 + 1 .
    end.


    if pay-day = 0 or pay-day = ? then pay-day = 1 .
    /* расчет заказа */

    g#log = SelectObject:disable( {&obj-order-txt } ) .
    SelectObject = SelectObject:screen-value in frame {&frame-name} .
    run select-objects-proc in this-procedure  (input e-method).
    run loc-init in this-procedure .
    IF  v-mode <> ? then do:
      g#log = SelectObject:enable( {&obj-order-txt } ) .
      case v-mode :
        when "auto-ord":U THEN DO:
            assign frame {&frame-name}:title = "Параметры для расчета автозаказа ".
            ENABLE b-save WITH FRAME {&FRAME-NAME}.
            DISPLAY b-save WITH FRAME {&FRAME-NAME}.
            HIDE btn_ok IN FRAME {&FRAME-NAME}.
            HIDE i-exit IN FRAME {&FRAME-NAME}.
        END.
        when "all-ord":U THEN DO:
            assign frame {&frame-name}:title = "Параметры для расчета заказа " + loc-ord-num + " /Расчет потребности/" .
            ENABLE b-save WITH FRAME {&FRAME-NAME}.
            DISPLAY b-save WITH FRAME {&FRAME-NAME}.
            HIDE btn_ok IN FRAME {&FRAME-NAME}.
            HIDE i-exit IN FRAME {&FRAME-NAME}.
        END.
        otherwise DO:
            assign frame {&frame-name}:title = "Параметры для расчета заказа " + loc-ord-num + " /Экспорт/" .
        END.
      end.
    end.

    /*if date-sale-1 = ? and date-sale-2 = ? then do:
       t-way = false .
       hide t-way FILL-IN-8 T-clos T-rcv r-min-rest3 in frame {&frame-name} .
    end.*/


  if is-abc <> "yes" then do:
     g#log = R-algoritm:disable(radio-label("6", R-algoritm:radio-buttons)).
   end.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-sum-vat Dialog-Frame
PROCEDURE calc-sum-vat :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define variable varprice-cli-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-dt          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-dt             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-dt                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-dt         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-dt               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-dt      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-dt     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-dt like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-dt   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-dt        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-dt           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-dt    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-dt               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-dt      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-dt     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-dt like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-dt   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-dt        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-dt           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-dt    like ub.doc-line.price-base no-undo.

for each  tmp#zakaz
    on error undo, return error :
  /*Расчет поля <<сумма НДС>>*/
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
    varprice-cli-dt
    varprice-cli-unit-base-dt
    varprice-road-tax-dt
    varprice-other-exp-dt
    varprice-transport-exp-dt
    varprice-without-abs-dt
    varprice-slt-dt
    varprice-no-slt-dt
    varprice-vat-dt
    varprice-no-vat-slt-dt
    varprice-rubl-dt
    varprice-road-tax-rubl-dt
    varprice-other-exp-rubl-dt
    varprice-transport-exp-rubl-dt
    varprice-without-abs-rubl-dt
    varprice-slt-rubl-dt
    varprice-no-slt-rubl-dt
    varprice-vat-rubl-dt
    varprice-no-vat-slt-rubl-dt
    varprice-base-dt
    varprice-road-tax-base-dt
    varprice-other-exp-base-dt
    varprice-transport-exp-base-dt
    varprice-without-abs-base-dt
    varprice-slt-base-dt
    varprice-no-slt-base-dt
    varprice-vat-base-dt
    varprice-no-vat-slt-base-dt
    no-error
    }
    if error-status:error then do:
      return error "Ошибка при пересчете НДС".
    end.

   assign
    tmp#zakaz.sum-vat    = varprice-vat-dt  * tmp#zakaz.cli-qnty
    tmp#zakaz.sum-slt    = varprice-slt-dt
    tmp#zakaz.road-tax   = if var-report-r-b = "rubl" then   varprice-road-tax-rubl-dt else varprice-road-tax-base-dt
    tmp#zakaz.other-base = varprice-other-exp-base-dt
    tmp#zakaz.other-rubl = varprice-other-exp-rubl-dt
    tmp#zakaz.price-rubl = varprice-rubl-dt
    tmp#zakaz.price-base = varprice-base-dt
    tmp#zakaz.price-cli  = varprice-cli-dt
     .

  end.
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY R-algoritm p-neg-sale R-min-rest T-gar r-min-rest3 T-min-ost
          R-algoritm2 SelectObject T-min-zapas date-p-1 date-p-2 t-way T-clos
          t-rv t-rvc T-rcv t-rvz T-rvzc T-sppv-4 T-sp T-sppv-2 t-sppv-3
          v-round-m v-round-base v-name p-prt-art FILL-IN-2 FILL-IN-17 FILL-IN-3
          t-gar-1 t-gar-2 FILL-IN-15 FILL-IN-13 t-min-ost-1 t-min-ost-2
          FILL-IN-5 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4 t-5 t-6 t-7
          FILL-IN-16
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tmp-sale THEN
    DISPLAY tmp-sale.desc_ tmp-sale.tmp-code
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 RECT-8 R-algoritm p-neg-sale
         R-min-rest T-gar r-min-rest3 T-min-ost R-algoritm2 SelectObject
         BR-obj-list T-min-zapas BUTTON-obj date-p-1 date-p-2 t-way BROWSE-1
         BROWSE-abc-day B-10 B-1 B-2 T-clos B-3 t-rv t-rvc T-rcv B-4 t-rvz
         T-rvzc B-5 T-sppv-4 T-sp T-sppv-2 t-sppv-3 B-6 B-7 v-round-m
         v-round-base B-spis p-prt-art Btn_OK Btn_Cancel B-Help i-exit
         FILL-IN-17 FILL-IN-3 t-gar-1 t-gar-2 FILL-IN-15 FILL-IN-13 t-min-ost-1
         t-min-ost-2 FILL-IN-5 FILL-IN-7 t-1 FILL-IN-8 FILL-IN-14 t-2 t-3 t-4
         t-5 t-6 t-7 FILL-IN-16 tmp-sale.desc_ tmp-sale.tmp-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-screen Dialog-Frame
PROCEDURE init-screen :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define input parameter p-val as character no-undo .
define variable i as integer no-undo .
  if g#type <> {&f-p} then do:
      for each  obj-list : delete obj-list . end.
      { cmp/cr-objls.i store-type store-code }
  end.

define variable v-nn as integer   no-undo .
  v-nn = num-entries(p-val) .
  do i = 1 to v-nn :

     case  entry(1,(entry(i,p-val)), "=" ) :
        when string( "v-round-m" )              then v-round-m =          entry(2,(entry(i,p-val)), "=" ).
        when string( "v-round-base" )           then v-round-base = decimal( entry(2,(entry(i,p-val)), "=" )).
        when string( "R-min-rest" )             then R-min-rest = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm" )             then R-algoritm = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "R-algoritm2" )            then R-algoritm2 = integer(entry(2,(entry(i,p-val)), "=" )).
        when string( "tmp-sale.tmp-code" )      then do:
             find first ub.tmp-sale no-lock where ub.tmp-sale.tmp-code = entry(2,(entry(i,p-val)), "=" ) no-error.
             if available ub.tmp-sale then do:
                rr = recid(ub.tmp-sale) .
                 display  ub.tmp-sale.tmp-code
                             ub.tmp-sale.desc_   with frame {&frame-name} .
                 reposition {&frame-name} to recid rr no-error  .
                 if error-status :error then error-status :get-message(1) .
             end.
             else do:
             find first ub.tmp-sale no-lock no-error .
                if available ub.tmp-sale then rr = recid(ub.tmp-sale) .
             end.

        end.

        when string( "SelectObject" ) then  do:
                SelectObject = string(entry(2,(entry(i,p-val)), "=" )) no-error .
                if error-status :error then SelectObject = "firm":U  .
                if SelectObject = "choice":U then SelectObject = "order":U .
                run select-objects-proc in this-procedure (input p-val).

             end.

        when string( "date-p-1" ) then  date-p-1 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "date-p-2" ) then  date-p-2 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "t-way"    )   then  t-way    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rcv"    )   then  t-rcv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-clos"   )   then  t-clos    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rv"   )   then  t-rv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rvz"  )   then  t-rvz   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvc"  )   then  t-rvc   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-rvzc" )   then  t-rvzc  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sp"   )   then  t-sp    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .

        when string( "t-sppv-2")  then  t-sppv-2 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-sppv-3")  then  t-sppv-3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4")  then  t-sppv-4 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "p-neg-sale")   then  p-neg-sale = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-gar")         then  t-gar = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-zapas") then  t-min-zapas = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-min-ost") then  t-min-ost = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "R-min-rest3")  then  R-min-rest3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
    end case.
   g#log = SelectObject:disable(radio-label("all":U , SelectObject:radio-buttons)).
  end.
  if lookup ( v-round-m , {&ord-rounds-need-coef} ) > 0 then do:
        enable  v-round-base with frame {&frame-name} .
        display v-round-base with frame {&frame-name} .
     end.

end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loc-enable-UI Dialog-Frame
PROCEDURE loc-enable-UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
------------------------------------------------------------------------------*/
  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.

  reposition {&frame-name} to recid rr no-error  .
  find first ub.tmp-sale where rr = recid(ub.tmp-sale) no-lock no-error .

  DISPLAY {&all-obj}
      WITH FRAME Dialog-Frame.

  IF AVAILABLE ub.tmp-sale THEN do:
     DISPLAY  {&List-spis}    WITH FRAME Dialog-Frame.
     ENABLE  {&List-spis}  WITH FRAME Dialog-Frame.
     end.

  ENABLE RECT-1 RECT-3 RECT-5 RECT-6 RECT-7 RECT-8  {&all-obj}
         WITH FRAME Dialog-Frame.
.

  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loc-init Dialog-Frame
PROCEDURE loc-init :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

{ cmp/df-sub.i pr }
define variable i as integer no-undo .
if v-mode = ? then  do:
find first buf_usr-flt  no-lock where
         buf_usr-flt.user-name = loc-ord-num and
         buf_usr-flt.call-point   = "ord-m":U    no-error .
end.
else do:
   if v-mode = "all-ord":U then do:
        find first buf_usr-flt  no-lock where
                buf_usr-flt.user-name   = g#userid and
                buf_usr-flt.call-point  = "all-ord":U    no-error .
   end.
   else do:
          find first buf_usr-flt  no-lock where
                buf_usr-flt.user-name = loc-ord-num and
                buf_usr-flt.call-point   = "ord-m":U  + v-mode   no-error .
                if not available buf_usr-flt  then do:
                  find first buf_usr-flt  no-lock where
                          buf_usr-flt.user-name = loc-ord-num and
                          buf_usr-flt.call-point   = "ord-m":U  no-error .
                end.

   end.

end.
/* а если не нашли ни чего то берем по юсеру */
if not available buf_usr-flt  then do:
   find first buf_usr-flt  no-lock where
         buf_usr-flt.user-name    = g#userid and
         buf_usr-flt.call-point   = "ord-m":U    no-error .
end.



if available buf_usr-flt  then do:
  run init-screen ( buf_usr-flt.list_ ) .
end.

else do:
    assign
        date-p-1  = to-day - 30
        date-p-2  = to-day
        t-rv   = true
        t-rvz  = true
        t-rvc  = true
        t-rvzc = true
        r-algoritm = 1

    .
  if v-round-m = "" or v-round-m = ? then v-round-m = {&ord-round-off} .
  display v-round-m with frame {&frame-name} .

    find first ub.tmp-sale no-lock no-error .
    if error-status :error then do:
          create  ub.tmp-sale.
          assign  ub.tmp-sale.tmp-code = "1"
                  ub.tmp-sale.desc_    = "Пустой"
                  .
    end.
    find current ub.tmp-sale no-lock no-error .
    if available ub.tmp-sale then
        display  ub.tmp-sale.tmp-code
                  ub.tmp-sale.desc_   with frame {&frame-name} .
    if available ub.tmp-sale then  rr = recid(ub.tmp-sale) .

end.
if v-mode = "auto-ord" then do:
  run init-screen ( p-return ) .
end.

 display {&all-obj} with frame {&frame-name}.


  if g#type = {&f-p} then do:
        ENABLE
          SelectObject
          br-obj-list
          BUTTON-obj
          FILL-IN-13
          rect-7
          WITH FRAME Dialog-Frame.
  end.
  else do:
      hide  SelectObject  br-obj-list  BUTTON-obj  FILL-IN-13 rect-7            in frame {&frame-name} .
      for each obj-list
          on error undo, return error :
          delete obj-list.
      end. /* for each */
      { cmp/cr-objls.i store-type store-code }
  end.

define variable v-value  as character no-undo .
define variable v-i      as integer   no-undo .
define variable v-dec as integer   no-undo .

define variable p-prop-code as character no-undo .
define variable v-value-character like ub.thbj-attr.property-value-character no-undo .
define variable v-value-date    like ub.thbj-attr.property-value-date no-undo .
define variable v-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define variable v-value-logical like ub.thbj-attr.property-value-logical no-undo .
define variable v-value-integer like ub.thbj-attr.property-value-integer no-undo .
define variable v-type     as character no-undo .
define variable v-found as decimal no-undo .

 empty TEMP-TABLE  thbjattr_thbj-attr .
 empty TEMP-TABLE temp-abc-day .
 repeat v-i = 1 to 6:
    run adm/shattri.p (
      input "get":U
      ,input store-type
      ,input store-code
      ,input {&attr-abc-sale-day}
      ,input  chr ( 64 + v-i )
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output par-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .

        v-dec = v-value-integer no-error .
        if v-dec = ? then v-dec = 0 .
        create temp-abc-day.
        assign
          temp-abc-day.abc-type = chr ( 64 + v-i )
          temp-abc-day.gar-day  = v-dec
        .
 end.



 run v-c-alg in this-procedure .
 run v-c-way in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-calc Dialog-Frame
PROCEDURE p-calc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{&start-proc}

define input-output parameter n-day as logical no-undo .
define input parameter n-i as integer no-undo .
define variable t-i as date no-undo.
define variable p-modulo as integer no-undo .

assign frame {&frame-name}
   date-p-1 date-p-2.
  if date-p-1 = ? or  date-p-2 = ? then
  apply "entry " to date-p-1 .
if date-p-1 <> ? and  date-p-2 <> ? then do:
  if n-day = true then do:
        n-day = false.
        /* Удалим  */
         repeat t-i = date-p-1 To date-p-2 :
            p-modulo = if (integer(t-i) MODULO 7 ) = 0 then 7 else (integer(t-i) MODULO 7 ).
            if p-modulo = n-i then do:
                 find first tt-date where  tt-date.exch-date =  t-i no-error.
                    if available  tt-date then delete tt-date.
            end.
         end.
  end.
  else do:
        n-day = true.
        /* Добавим */
         repeat t-i = date-p-1 To date-p-2 :
           p-modulo = if (integer(t-i) MODULO 7 ) = 0 then 7 else (integer(t-i) MODULO 7 ).
            if p-modulo = n-i
            then do:
                if not can-find ( first tt-date where tt-date.exch-date =  t-i ) then do:
                    create tt-date.
                    assign tt-date.exch-date =  t-i.
                    end.
            end.
         end.
  end.
   {&OPEN-QUERY-BROWSE-1}

  end.
 end. /* start-proc */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE remember-screen Dialog-Frame
PROCEDURE remember-screen :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define input-output parameter p-val as character no-undo .
         p-val =
            string( "v-round-m=" )  + string( v-round-m ) + "," +
            string( "v-round-base=" )  + string( v-round-base,">>>>>>>>>9.99" ) + "," +
            string( "R-algoritm=" )  + string( R-algoritm ) + "," +
            string( "R-algoritm2=" ) + string( R-algoritm2 ) + "," +
            string( "tmp-sale.tmp-code=" ) + (
            if available ub.tmp-sale and R-algoritm = 2
                  then   string( ub.tmp-sale.tmp-code )
                              else ( " " ) )                          + "," +
            string( "R-min-rest3=" ) + string( R-min-rest3,"yes/no" ) + "," +
            string( "R-min-rest=" )  + string( R-min-rest ) + "," +
            ( if date-p-1 = ?  then ""
                               else string( "date-p-1=" )    + string( date-p-1,"99/99/9999" )
                               )
                             + "," +
            ( if date-p-2 = ?  then ""
                               else string( "date-p-2=" )    + string( date-p-2,"99/99/9999" )
                               )
                             + "," +
            string( "t-way="    )    + string( t-way   ,"yes/no" ) + "," +
            string( "t-rcv="    )    + string( t-rcv   ,"yes/no" ) + "," +
            string( "t-clos="   )    + string( t-clos  ,"yes/no" ) + "," +
            string( "t-rv="     )    + string( t-rv    ,"yes/no" ) + "," +
            string( "t-rvz="    )    + string( t-rvz   ,"yes/no" ) + "," +
            string( "t-rvc="    )    + string( t-rvc   ,"yes/no" ) + "," +
            string( "t-rvzc="   )    + string( t-rvzc  ,"yes/no" ) + "," +
            string( "t-sp="     )    + string( t-sp    ,"yes/no" ) + "," +
            string( "t-sppv-2=" )    + string( t-sppv-2,"yes/no" ) + "," +
            string( "t-sppv-3=" )    + string( t-sppv-3,"yes/no" ) + "," +
            string( "t-sppv-4=" )    + string( t-sppv-4,"yes/no" ) + "," +
            string( "p-neg-sale=" )  + string( p-neg-sale,"yes/no" ) + "," +
            string( "t-gar=" )       + string( t-gar,"yes/no" ) + "," +
            string( "t-min-zapas=" ) + string( t-min-zapas,"yes/no" ) + "," +
            string( "t-min-ost=" ) + string( t-min-ost,"yes/no" ) + "," +
            string( "SelectObject=" ) + string( SelectObject )
            .


  if g#type <> {&f-p} then do:
      for each  obj-list : delete obj-list . end.
      { cmp/cr-objls.i store-type store-code }
  end.

  p-val = p-val +  "," + "Объекты :&"  .
      for each obj-list :
              p-val = p-val +  obj-list.obj-type + " " + string(obj-list.obj-code) + ","    .
      end.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-proc Dialog-Frame
PROCEDURE select-objects-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
  define input parameter p-e-m as character no-undo .
  define variable v-all-object as logical   no-undo .
  my-handle = parparentproc .
 { rep/s-selobj.i }

if SelectObject = "currency":U  or g#type <> {&f-p} then do:
    for each  obj-list : delete obj-list . end.
    { cmp/cr-objls.i store-type store-code }
end.

if SelectObject = {&obj-order} then do:
    for each  obj-list : delete obj-list . end.
    define variable str-pos as integer no-undo .
    define variable str-pos2 as integer no-undo .
    define variable str-1 as character no-undo .
    define variable i as integer no-undo .
    define variable e1 as character no-undo .
    define variable e2 as integer no-undo .
    define variable v-nn as integer   no-undo .

    str-pos = index (  p-e-m , "&" ) .
    str-pos2 = LENGTH ( p-e-m ) - str-pos .

    str-1 = substring (p-e-m , str-pos + 1 , str-pos2 ).
    v-nn = num-entries (str-1) .
    do i = 1 to v-nn :
        assign
          e1 = entry(1, (entry( i , str-1, "," )) , " ")
          e2 = integer(entry(2, (entry( i , str-1, "," )), " " ))
          no-error .
          if error-status :error then next.
          { cmp/cr-objls.i e1 e2  }
    end.
end.

{&OPEN-QUERY-BR-obj-list}

  end.  /* do */


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sss Dialog-Frame
PROCEDURE sss :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
  { cus/s-allobj.i no-initial }

  end. /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE v-c-2 Dialog-Frame
PROCEDURE v-c-2 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign frame   {&frame-name}   r-algoritm2.

  case  r-algoritm2:
  when 1 then do: /* по всем датам */
         enable  {&dates}      with frame {&frame-name} .
         disable {&List-tt}    with frame {&frame-name} .
         hide    {&List-tt}    in   frame {&frame-name} .
         browse-1:bgcolor      in   frame {&frame-name}  = 8 .
  end.
  when 2 then do: /* без нулевых */
        enable  {&dates}    with frame {&frame-name} .
        disable {&List-tt}  with frame {&frame-name} .
        hide    {&List-tt}  in   frame {&frame-name} .
        browse-1:bgcolor    in   frame {&frame-name}  = 8 .
  end.
  when 3 then do: /* по календарю  */
        enable   {&dates}  {&List-tt}   with frame {&frame-name} .
        browse-1:bgcolor  in frame {&frame-name}  = ? .
   end.

   otherwise do:
      message "Нет!!! " .
   end.
  end case.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE v-c-alg Dialog-Frame
PROCEDURE v-c-alg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 {&start-proc}
 define variable g#log  as logical   no-undo .
  assign frame   {&frame-name}   r-algoritm.
  g#log = R-algoritm2:enable(radio-label("2", R-algoritm2:radio-buttons)) .
  case  r-algoritm:
  when 1 then do: /* СРЕДНЕСУТОЧНЫЙ */
         enable  {&dates} {&list-from-max-stock} with frame {&frame-name} .
         disable {&List-tt} {&List-spis}  {&garant} with frame {&frame-name} .
         hide    {&List-tt} {&List-spis}  {&garant} in frame {&frame-name} .
         g#log = R-min-rest:enable( {&r-min-res-txt} ) .
         browse-1:bgcolor  in frame {&frame-name}  = 8 .

  end.
  when 2 then do: /* ИЗ СПИСКА*/
        enable  {&List-spis} {&list-from-max-stock} with frame {&frame-name} .
        disable {&dates} {&List-tt}  {&garant}  with frame {&frame-name} .
        hide    {&dates} {&List-tt}  {&garant} browse-abc-day  in frame {&frame-name} .
        browse-1:bgcolor  in frame {&frame-name}  = 8 .
        g#log = R-min-rest:enable( {&r-min-res-txt} ) .

  end.
  when 3 then do: /* ВЕРОЯТНОСТНЫЙ */
        enable   {&dates}  {&list-from-max-stock}   {&garant}   with frame {&frame-name} .
        disable  {&List-spis} {&List-tt} with frame {&frame-name} .
        hide     {&List-spis} {&List-tt}   in  frame {&frame-name} .
        browse-1:bgcolor  in frame {&frame-name}  = ? .
        g#log = R-min-rest:enable( {&r-min-res-txt} ) .
   end.
   when 4 then do: /* ПО MAX */
        enable   {&dates} {&list-from-max-stock}   with frame {&frame-name} .
        disable  {&List-spis} {&List-tt} {&garant}  with frame {&frame-name} .
        hide     {&List-spis} {&List-tt} {&garant}  in frame {&frame-name} .
        g#log = R-min-rest:enable( {&r-min-res-txt} ) .
        browse-1:bgcolor  in frame {&frame-name}  = ? .
        g#log = R-algoritm2:disable(radio-label("2", R-algoritm2:radio-buttons)) .
   end.
   when 5 then do: /* до  MAX зап */
        R-min-rest = 1.
        r-min-rest3 = false .
        g#log = R-min-rest:disable( {&r-min-res-txt} ) .

        display R-min-rest r-min-rest3 with frame {&frame-name} .
        disable {&dates} {&List-spis} {&List-tt} {&garant} r-min-rest3 /*T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7*/ with frame {&frame-name} .
        hide    {&dates} {&List-spis} {&List-tt} {&garant} r-min-rest3 /*T-min-zapas FILL-IN-3 FILL-IN-5 FILL-IN-7*/ in frame {&frame-name} .
        browse-1:bgcolor  in frame {&frame-name}  = 8 .
   end.
      when 6 then do: /* ИЗ ABC-analis */
        enable  {&List-spis} {&list-from-max-stock} with frame {&frame-name} .
        disable {&dates} {&List-tt}  {&garant}  with frame {&frame-name} .
        hide    {&dates} {&List-tt}  {&garant}  in frame {&frame-name} .
        browse-1:bgcolor  in frame {&frame-name}  = 8 .
        g#log = R-min-rest:enable( {&r-min-res-txt} ) .
            {&OPEN-QUERY-BROWSE-abc-day}
  end.


   otherwise do:
      message "Нет!!! " .
   end.
  end case.

  /*if date-sale-1 = ? and date-sale-2 = ? then do:
      t-way = false .
      hide t-way FILL-IN-8 T-clos T-rcv r-min-rest3 in frame {&frame-name} .
  end.*/


  if r-algoritm <>  2 and
     r-algoritm <>  5 and
     r-algoritm <>  6
     then do:
     run v-c-2 in this-procedure . /* проверка дат */
     end.

 end. /* start-proc */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE v-c-way Dialog-Frame
PROCEDURE v-c-way :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign frame   {&frame-name}   t-way.

  if  t-way then do:
      if loc-doc-type = {&o-o} then do:
         T-rcv:label = {&ord-req}      .
         hide T-clos  in frame {&frame-name} .
      end.

      display T-clos when loc-doc-type <> {&o-o}
              T-rcv
              FILL-IN-8  with frame {&frame-name} .
      enable T-clos  when loc-doc-type <> {&o-o}
             T-rcv
             FILL-IN-8 with frame {&frame-name} .


      end.
  else do:
        disable T-clos T-rcv FILL-IN-8 with frame {&frame-name} .
        hide T-clos T-rcv FILL-IN-8 in frame {&frame-name} .
        end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-check Dialog-Frame
PROCEDURE verify-check :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME