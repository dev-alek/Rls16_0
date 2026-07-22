&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Методы расчета темпа, размазывание по объектам

Автор: Чернова Светлана Александровна
Дата создания: 02/11/02
Author: Svetlana Chernova
Creation date: 02/11/02

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Методы расчета темпа, размазывание по объектам" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ cus/df-zakaz.i }
{ ref/gdsoattr.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter v-mode-recid    as recid no-undo .
define input  parameter g#type          as character no-undo .
my-handle  = parParentProc .

define variable g#host-code  as integer   no-undo .
define variable g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .

define variable g#log      as logical   no-undo .
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }

DEFINE TEMP-TABLE tt-date NO-UNDO
field exch-date as date
index pi is unique primary   exch-date .
/*
&glob obj-firm       1
&glob obj-currency   2
&glob obj-choice     3
&glob all            4
*/

define variable     str-obj#  as character no-undo .
define variable     str-obj2#  as character no-undo .
define variable     str-obj3#  as character no-undo .
define variable     rec-list  as character no-undo .
define variable     temp-param-obj as char no-undo.     /* Объекты */
define variable    temp-param-obj-type as char no-undo.     /* Объекты */
define buffer cli-obj      for ub.clients .
define buffer alt-obj-list for obj-list .
define variable ii as integer no-undo .

define variable  t-ret as log no-undo.
define variable d-Mond as log no-undo.
define variable rr as recid no-undo .
&glob obj-order 'order':U
&glob obj-order-txt 'Из заказа'
&glob  start-proc do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
/*
&glob  start-proc  do on error undo : ~
  if return-value <> "" or  error-status:error then ~
  message SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) view-as alert-box TITLE "start-proc" .
*/
&glob v-c DO: ~
  assign frame ~{&frame-name}   ~{&SELF-NAME} . ~
  display ~{&SELF-NAME}  with FRAME ~{&frame-name}  .  ~
END.
&glob ll-tt t-1  t-2  t-3  t-4 t-5  t-6 t-7  t-8
run loc-init in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-date ub.tmp-sale

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt-date.exch-date
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define FIELD-PAIRS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH tt-date NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-date
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-date

 /* Definitions for BROWSE BR-obj-list                                   */
&Scoped-define FIELDS-IN-QUERY-BR-obj-list obj-list.obj-code ~
obj-list.obj-type obj-list.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-obj-list
&Scoped-define FIELD-PAIRS-IN-QUERY-BR-obj-list
&Scoped-define OPEN-QUERY-BR-obj-list OPEN QUERY BR-obj-list FOR EACH obj-list  NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-obj-list obj-list
&Scoped-define FIRST-TABLE-IN-QUERY-BR-obj-list obj-list


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame ub.tmp-sale.tmp-code ~
tmp-sale.desc_
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-obj-list}~
    ~{&OPEN-QUERY-BROWSE-1}
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.tmp-sale SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.tmp-sale
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.tmp-sale


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-11  R-algoritm t-rv ~
date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 ~
B-Help Btn_OK Btn_Cancel  FILL-IN-1 FILL-IN-3
&Scoped-Define DISPLAYED-FIELDS ub.tmp-sale.tmp-code ub.tmp-sale.desc_
&Scoped-Define DISPLAYED-OBJECTS R-algoritm t-rv date-p-1 ~
date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 ~
FILL-IN-1 FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 t-way


/* Custom List Definitions                                              */
/* all-obj,dates,List-spis,List-tt,List-5,List-6                        */
&Scoped-define all-obj R-algoritm ub.tmp-sale.tmp-code ~
ub.tmp-sale.desc_ t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp t-sppv ~
t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1 FILL-IN-3 t-1 t-2 ~
t-3 t-4 t-5 t-6 t-7
&Scoped-define dates date-p-1 date-p-2
&Scoped-define List-spis RECT-8 ub.tmp-sale.tmp-code ub.tmp-sale.desc_ B-spis
&Scoped-define List-tt RECT-11 BROWSE-1 B-1 B-2 B-3 B-4 B-5 B-6 B-7 B-8  ~
B-10 B-12 t-1 t-2 t-3 t-4 t-5 t-6 t-7

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1
     LABEL "Пн"
     SIZE 3.75 BY 1.13 TOOLTIP "Понедельник".

DEFINE BUTTON B-10
     LABEL "Очистить"
     SIZE 9.5 BY 1 TOOLTIP "Очистить список дат".


DEFINE BUTTON B-12
     LABEL "Удалить"
     SIZE 9.5 BY 1 TOOLTIP "Удалить из списка дат  по календарю".

DEFINE BUTTON B-2
     LABEL "Вт"
     SIZE 3.75 BY 1.13 TOOLTIP "Вторник".

DEFINE BUTTON B-3
     LABEL "Ср"
     SIZE 3.75 BY 1.13 TOOLTIP "Среда".

DEFINE BUTTON B-4
     LABEL "Чт"
     SIZE 3.75 BY 1.13 TOOLTIP "Четверг".

DEFINE BUTTON B-5
     LABEL "Пт"
     SIZE 3.75 BY 1.13 TOOLTIP "Пятница".

DEFINE BUTTON B-6
     LABEL "Сб"
     SIZE 3.75 BY 1.13 TOOLTIP "Суббота".

DEFINE BUTTON B-7
     LABEL "Вс"
     SIZE 3.75 BY 1.13 TOOLTIP "Воскресенье".

DEFINE BUTTON B-8
     LABEL "Сохранить"
     SIZE 9.5 BY 1 TOOLTIP "Сохранить список дат".


DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-spis
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Выбор из списка темпов продаж"
     SIZE 2.75 BY .96 TOOLTIP "Пересчитать темп продаж за указанный период".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Выполнить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE date-p-1 AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE date-p-2 AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Методы расчета Темпа продаж"
      VIEW-AS TEXT
     SIZE 28 BY .67
     FGCOLOR 4  NO-UNDO.


DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Включать в расчет объема продаж"
      VIEW-AS TEXT
     SIZE 31.88 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-1 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-2 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-3 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-4 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-5 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-6 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-7 AS LOGICAL FORMAT "+/":U INITIAL NO
      VIEW-AS TEXT
     SIZE 1.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-algoritm AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
"За период времени", 1,
"За период был в наличие", 4,
"Из списка", 2,
"Календарный метод", 3
     SIZE 27.63 BY 2.88 TOOLTIP "Методы расчета темпов продаж" NO-UNDO.


DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 57.5 BY 11.75
     BGCOLOR 8 .

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 57.5 BY 1.25.


DEFINE VARIABLE t-rv AS LOGICAL INITIAL no
     LABEL "Расход внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-rvc AS LOGICAL INITIAL no
     LABEL "Расход внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-rvz AS LOGICAL INITIAL no
     LABEL "Возврат внешний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-rvzc AS LOGICAL INITIAL no
     LABEL "Возврат внешний касса"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-sp AS LOGICAL INITIAL no
     LABEL "Списание внешнее"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-sppv AS LOGICAL INITIAL no
     LABEL "Списание пр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-sppv-2 AS LOGICAL INITIAL no
     LABEL "Расход пр-во"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-sppv-3 AS LOGICAL INITIAL no
     LABEL "Расход внутренний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.

DEFINE VARIABLE t-sppv-4 AS LOGICAL INITIAL no
     LABEL "Возврат внутренний"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .75 NO-UNDO.

DEFINE VARIABLE SelectObject AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
"Все по фирме", {&obj-firm},
"Текущий", {&obj-currency},
"Выборочно", {&obj-choice},
"Все", {&all},
{&obj-order-txt} , {&obj-order}
     SIZE 14.88 BY 3.42 NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Объекты"
     VIEW-AS TEXT
     SIZE 27.63 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj"
     SIZE 3 BY .88.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 31.13 BY 3.67.

DEFINE VARIABLE t-way AS LOGICAL INITIAL no
     LABEL "Учитывать предыдущие заказы"
     VIEW-AS TOGGLE-BOX
     SIZE 30.5 BY .75 NO-UNDO.
DEFINE VARIABLE T-clos AS LOGICAL INITIAL no
     LABEL "закрыто"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

DEFINE VARIABLE T-rcv AS LOGICAL INITIAL no
     LABEL "поставка"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.


/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-date SCROLLING.

DEFINE QUERY BR-obj-list FOR
      obj-list SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      ub.tmp-sale SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */

DEFINE BROWSE BR-obj-list
  QUERY BR-obj-list DISPLAY
      obj-list.obj-code
      obj-list.obj-type
      WITH NO-BOX NO-LABELS SIZE 15.38 BY 3.5
      BGCOLOR 8
      .

DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 DISPLAY
      tt-date.exch-date COLUMN-LABEL "Даты" FORMAT "99/99/9999"
      WITH NO-ROW-MARKERS SEPARATORS SIZE 13.63 BY 11.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     BR-obj-list  AT ROW 2.44 COL 47.13
     R-algoritm   AT ROW 2.5  COL 2.63  NO-LABEL
     SelectObject AT ROW 2.54 COL 32 NO-LABEL
     BUTTON-obj   AT ROW 3.83 COL 43.88 NO-LABEL
     ub.tmp-sale.tmp-code AT ROW 6.21 COL 4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 9 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.tmp-sale.desc_ AT ROW 6.21 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN NATIVE
          SIZE 43.13 BY 1
          BGCOLOR 8 FGCOLOR 4
     B-spis AT ROW 6.25 COL 2.75
     t-rv AT ROW 6.75 COL 66.75
     BROWSE-1 AT ROW 7.5 COL 39.63
     date-p-1 AT ROW 7.54 COL 3.63 COLON-ALIGNED
     date-p-2 AT ROW 7.54 COL 22.5 COLON-ALIGNED
     t-rvz AT ROW 7.58 COL 66.75
     t-rvc AT ROW 8.54 COL 66.75
     B-1 AT ROW 8.71 COL 2.75
     B-2 AT ROW 8.71 COL 6.63
     B-3 AT ROW 8.71 COL 10.38
     B-4 AT ROW 8.71 COL 14.25
     B-5 AT ROW 8.71 COL 18.13
     B-6 AT ROW 8.71 COL 22
     B-7 AT ROW 8.71 COL 25.63
     t-rvzc AT ROW 9.38 COL 66.75
     t-sp AT ROW 10.29 COL 66.75
     B-8 AT ROW 10.88 COL 2.25
     t-sppv AT ROW 11.21 COL 66.75
     t-sppv-2 AT ROW 12.13 COL 66.75
     t-sppv-3 AT ROW 13 COL 66.75
     B-10 AT ROW 13.21 COL 2.25
     t-sppv-4 AT ROW 13.88 COL 66.75
     B-12 AT ROW 15.5 COL 2.25
     t-way AT ROW 15.21 COL 66.63
     T-rcv AT ROW 16.75 COL 68.63
     T-clos AT ROW 17.75 COL 68.63
     B-Help AT ROW 19 COL 88.13
     Btn_OK AT ROW 19.04 COL 59.13
     Btn_Cancel AT ROW 19.04 COL 70
     FILL-IN-1 AT ROW 1.21 COL 2.75 NO-LABEL
     FILL-IN-3 AT ROW 6.08 COL 66.75 NO-LABEL
     FILL-IN-4 AT ROW 1.21 COL 32 NO-LABEL
     t-1 AT ROW 10 COL 3.88 NO-LABEL
     t-2 AT ROW 10 COL 7.75 NO-LABEL
     t-3 AT ROW 10 COL 11.38 NO-LABEL
     t-4 AT ROW 10 COL 15.13 NO-LABEL
     t-5 AT ROW 10 COL 19 NO-LABEL
     t-6 AT ROW 10 COL 23.13 NO-LABEL
     t-7 AT ROW 10 COL 26.5 NO-LABEL
     RECT-8 AT ROW 6.04 COL 1.5
     RECT-11 AT ROW 7.38 COL 1.5
     RECT-12 AT ROW 2.40 COL 31.75
     SPACE(40.99) SKIP(1.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры расчета заказа"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 t-rv Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-1 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-10 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-12 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-2 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-3 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-4 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-5 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-6 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-7 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-8 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR BUTTON B-spis IN FRAME Dialog-Frame
   NO-ENABLE 3                                                          */
/* SETTINGS FOR BROWSE BROWSE-1 IN FRAME Dialog-Frame
   NO-ENABLE 4                                                          */
/* SETTINGS FOR FILL-IN date-p-1 IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN date-p-2 IN FRAME Dialog-Frame
   1 2                                                                  */
/* SETTINGS FOR FILL-IN ub.tmp-sale.desc_ IN FRAME Dialog-Frame
   NO-ENABLE 1 3                                                        */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR RADIO-SET R-algoritm IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR RECTANGLE RECT-11 IN FRAME Dialog-Frame
   4                                                                    */
/* SETTINGS FOR RECTANGLE RECT-8 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR FILL-IN t-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR FILL-IN t-2 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR FILL-IN t-3 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR FILL-IN t-4 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR FILL-IN t-5 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR FILL-IN t-6 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR FILL-IN t-7 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 1 4                                                */
/* SETTINGS FOR TOGGLE-BOX t-rv IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-rvc IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-rvz IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-rvzc IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-sp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-sppv IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-sppv-2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-sppv-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-sppv-4 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN ub.tmp-sale.tmp-code IN FRAME Dialog-Frame
   NO-ENABLE 1 3                                                        */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-date NO-LOCK.
     _END_FREEFORM
     _TblOptList       = "OUTER"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.tmp-sale"
     _Options          = "SHARE-LOCK"
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
  run p-calc in this-procedure (input-output t-1 ,input 1) .
  display {&all-obj} with frame {&FRAME-NAME}.
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
 display {&all-obj} with frame {&FRAME-NAME}.

  {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-12 Dialog-Frame
ON CHOOSE OF B-12 IN FRAME Dialog-Frame /* Удалить */
OR MOUSE-SELECT-DBLCLICK OF {&browse-name} in frame {&frame-name}
DO:
  find current tt-date no-error.
  if error-status :error then return no-apply.
  if available    tt-date then   delete tt-date.
  {&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame /* Вт */
DO:
    run p-calc in this-procedure (input-output t-2 ,input 2) .
   display {&all-obj} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame /* Ср */
DO:
    run p-calc in this-procedure (input-output t-3 ,input 3) .
   display {&all-obj} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame /* Чт */
DO:
    run p-calc in this-procedure ( input-output t-4 ,input 4) .
   display {&all-obj} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame /* Пт */
DO:
    run p-calc in this-procedure ( input-output t-5 ,input 5) .
   display {&all-obj} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame /* Сб */
DO:
    run p-calc in this-procedure ( input-output t-6 ,input 6) .
   display {&all-obj} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame /* Вс */
DO:
    run p-calc in this-procedure ( input-output t-7 , input 0) .
   display {&all-obj} with frame {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-8 Dialog-Frame
ON CHOOSE OF B-8 IN FRAME Dialog-Frame /* Сохранить */
DO:
     message  'Режим отключен'.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-spis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-spis Dialog-Frame
ON CHOOSE OF B-spis IN FRAME Dialog-Frame /* Выбор из списка темпов продаж */
DO:
define variable t-recid as recid no-undo .
  run ref/tmp-sale.w
     ( parParentProc ,
      input "b-sel",
      output t-recid
      ).
  rr = t-recid.
  find first ub.tmp-sale  where recid( ub.tmp-sale) = int(t-recid) no-lock no-error .
     if available  ub.tmp-sale and not error-status :error  then
     display  ub.tmp-sale.tmp-code
              ub.tmp-sale.desc_
              with frame {&frame-name} .
END.

ON CHOOSE OF BUTTON-obj IN FRAME {&frame-name}  /* BUTTON-obj */
DO:
  assign SelectObject.
  my-request = false .
  run select-objects-proc in this-procedure ( e-method ) .
END.




/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выполнить */
DO:

define variable p-code as character no-undo .
define variable p-desc as character no-undo .
define variable t-type as character no-undo .
define variable loc-sum-min as decimal no-undo .
Assign frame {&frame-name} {&all-obj} SelectObject

date-p-1
date-p-2
no-error .


assign
date-p-1 = date(date-p-1:screen-value)
date-p-2 = date(date-p-2:screen-value)
SelectObject    = SelectObject:screen-value
t-way  = if t-way:screen-value  = "no" then false else true  .
t-clos = if t-clos:screen-value = "no" then false else true  .
t-rcv  = if t-rcv:screen-value  = "no" then false else true  .

.


if error-status :error then error-status :error = false  .

if t-way = false then
assign
  t-clos  = false
  t-rcv   = false
.
display t-clos
        t-rcv  with frame {&frame-name} .



if NOT ( t-way = true and  ( t-clos  = true  or  t-rcv  = true  )
         or
         t-way = false )
then do:
message "При учете предыдущих заказов надо выбрать хотя бы один статус !"
  view-as alert-box information.
   return no-apply.

end.




if R-algoritm = 3 and R-algoritm:visible and  not can-find (  first  tt-date  )  then do:
message "При календарном методе расчета должна быть заполнена таблица - даты"
  view-as alert-box information.
return no-apply.
end.
assign
    p-code = ub.tmp-sale.tmp-code
    p-desc = ub.tmp-sale.desc_
    no-error .

/* Вытащим данные по Мин остатку */
for each tmp#zakaz :
   loc-sum-min = 0 .
   tmp#zakaz.min-stock = 0 .
end.
/* сохранение выбранной информации */
e-method =  fill-in-1 + " : " + entry(R-algoritm * 2 - 1 , R-algoritm:RADIO-BUTTONS) +  ";" + {&new-line} +
           (  if R-algoritm = 2 then ( p-desc   + {&new-line}) else "" ) +
           (  if date-p-1 <> ? and R-algoritm <> 2 then "c  "  + string(date-p-1,"99/99/9999") else " " ) +
           (  if date-p-2 <> ? and R-algoritm <> 2 then " по " + string(date-p-2,"99/99/9999") else " " ) +  ";" +  {&new-line} +
           (  if t-1 then " " + b-1:label   else "") +
           (  if t-2 then " " + b-2:label   else "") +
           (  if t-3 then " " + b-3:label   else "") +
           (  if t-4 then " " + b-4:label   else "") +
           (  if t-5 then " " + b-5:label   else "") +
           (  if t-6 then " " + b-6:label   else "") +
           (  if t-7 then " " + b-7:label   else "") +
            {&new-line} +
            FILL-IN-3 + " : " .

 e-method = e-method +
         ( if  t-rv     then  " " + t-rv  :label     else "" ) +
         ( if  t-rvz    then  " " + t-rvz :label     else "" ) +
         ( if  t-rvc    then  " " + t-rvc :label     else "" ) +
         ( if  t-rvzc   then  " " + t-rvzc:label     else "" ) +
         ( if  t-sp     then  " " + t-sp  :label     else "" ) +
         ( if  t-sppv   then  " " + t-sppv:label     else "" ) +
         ( if  t-sppv-2 then  " " + t-sppv-2:label   else "" ) +
         ( if  t-sppv-3 then  " " + t-sppv-3:label   else "" ) +
         ( if  t-sppv-4 then  " " + t-sppv-4:label   else "" )
           .
 e-method = e-method +   {&new-line} +
         ( if  t-way    then  " " + t-way  :label + " : "    else "" ) +
         ( if  t-rcv    then  " " + t-rcv  :label            else "" ) +
         ( if  t-clos   then  " " + t-clos :label            else "" ) + ";"
         .

 e-method = e-method +  {&new-line} + "Объекты :&"  .
          for each obj-list :
                  e-method = e-method +  obj-list.obj-type + " " + string(obj-list.obj-code) + ","    .
          end.



    /* вызов пересчета заказа */
    define variable Ret as logical no-undo .
     t-ret =  session:SET-WAIT-STATE("GENERAL") .
     define variable obj-jj as integer no-undo .
     for each obj-list :
       obj-jj = obj-jj + 1.
     end.

        run cus/make-rcv.p
                   ( input parParentProc,
                     input v-mode-recid ,
                     input date-p-1,
                     input date-p-2,
                     input "calc":U,
                     input no,
                     input R-algoritm,
                     input p-code,
                     input t-rv,
                     input t-rvz,
                     input t-rvc ,
                     input t-rvzc ,
                     input t-sp   ,
                     input t-sppv ,
                     input t-sppv-2,
                     input t-sppv-3,
                     input t-sppv-4,
                     input t-way,
                     input t-rcv,
                     input t-clos,
                     input table tt-date     ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME R-algoritm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL R-algoritm Dialog-Frame
ON VALUE-CHANGED OF R-algoritm IN FRAME Dialog-Frame
DO:
  run v-c-alg in this-procedure .
END.

ON VALUE-CHANGED OF SelectObject IN FRAME Dialog-Frame
DO:
Assign SelectObject.
run select-objects-proc in this-procedure (e-method).
END.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rv Dialog-Frame
ON VALUE-CHANGED OF t-rv IN FRAME Dialog-Frame /* Расход внешний */
{&v-c}
ON VALUE-CHANGED OF t-way IN FRAME Dialog-Frame
run v-c-way in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rvc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rvc Dialog-Frame
ON VALUE-CHANGED OF t-rvc IN FRAME Dialog-Frame /* Расход внешний касса */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rvz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rvz Dialog-Frame
ON VALUE-CHANGED OF t-rvz IN FRAME Dialog-Frame /* Возврат внешний */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rvzc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rvzc Dialog-Frame
ON VALUE-CHANGED OF t-rvzc IN FRAME Dialog-Frame /* Возврат внешний касса */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sp Dialog-Frame
ON VALUE-CHANGED OF t-sp IN FRAME Dialog-Frame /* Списание внешнее */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sppv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sppv Dialog-Frame
ON VALUE-CHANGED OF t-sppv IN FRAME Dialog-Frame /* Списание пр-во */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sppv-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sppv-2 Dialog-Frame
ON VALUE-CHANGED OF t-sppv-2 IN FRAME Dialog-Frame /* Расход пр-во */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sppv-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sppv-3 Dialog-Frame
ON VALUE-CHANGED OF t-sppv-3 IN FRAME Dialog-Frame /* Расход внутренний */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-sppv-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-sppv-4 Dialog-Frame
ON VALUE-CHANGED OF t-sppv-4 IN FRAME Dialog-Frame /* Возврат внутренний */
{&v-c}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/ed_date.i date-p-1}
{ gbl/ed_date.i date-p-2}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_ui in this-procedure .
  hide b-12 in frame {&frame-name} .
  pay-day = date-sale-2 - date-sale-1 + 1 .

  frame {&frame-name}:title = "Параметры расчета темпов продаж на объектах для формирования поставок ".
  SelectObject = SelectObject:screen-value in frame {&frame-name} .
  run select-objects-proc in this-procedure ( e-method ).
  run v-c-alg in this-procedure .
  run v-c-way in this-procedure .
  hide t-way in frame {&frame-name} .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  reposition {&frame-name} to recid rr no-error  .
  find first ub.tmp-sale where rr = recid( ub.tmp-sale) no-lock no-error .

  DISPLAY  R-algoritm t-rv date-p-1 date-p-2 t-rvz t-rvc t-rvzc t-sp
          t-sppv t-sppv-2 t-sppv-3 t-sppv-4 FILL-IN-1
          FILL-IN-3 t-1 t-2 t-3 t-4 t-5 t-6 t-7 t-way t-clos t-rcv
      WITH FRAME Dialog-Frame.
     if g#type = {&f-p} then display   FILL-IN-4 SelectObject  br-obj-list  BUTTON-obj
        WITH FRAME Dialog-Frame.
  IF AVAILABLE ub.tmp-sale THEN
    DISPLAY ub.tmp-sale.tmp-code ub.tmp-sale.desc_
      WITH FRAME Dialog-Frame.
  ENABLE RECT-8 RECT-11  R-algoritm t-rv date-p-1 date-p-2 t-rvz
         t-rvc t-rvzc t-sp t-sppv t-sppv-2 t-sppv-3 t-sppv-4 B-Help Btn_OK
         Btn_Cancel FILL-IN-1 FILL-IN-3 t-way t-clos t-rcv
      WITH FRAME Dialog-Frame.
  if g#type = {&f-p} then ENABLE SelectObject  br-obj-list  BUTTON-obj WITH FRAME Dialog-Frame.
                     else   hide  SelectObject  br-obj-list rect-12  BUTTON-obj in frame {&frame-name} .
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  hide t-sppv-2  in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Loc-init Dialog-Frame
PROCEDURE Loc-init :
{ cmp/df-sub.i pr }
define variable i as integer no-undo .
define buffer buf-fp_ord-doc for ub.ord-doc.
find first  buf-fp_ord-doc where recid ( buf-fp_ord-doc ) = v-mode-recid no-lock no-error .
find first ubflt.usr-flt  no-lock where
         ubflt.usr-flt.user-name = buf-fp_ord-doc.doc-code and
         ubflt.usr-flt.call-point   = "ord-m":U    no-error .

if avail ubflt.usr-flt  then do:
  run init-screen in this-procedure ( ubflt.usr-flt.list_ ) .
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
end.
 rr = recid(ub.tmp-sale) .
 display {&all-obj} with frame {&frame-name}.
 run v-c-alg in this-procedure .
END PROCEDURE.



procedure v-c-alg :

 {&start-proc}
  assign frame   {&frame-name}   r-algoritm.
  case  r-algoritm:
  when 1 or when 4 then do:
         enable {&dates}
        t-rv  t-rvz t-rvc t-rvzc t-sp t-sppv
        t-sppv-2 t-sppv-3 t-sppv-4


         with frame {&frame-name} .
         disable {&List-tt} {&List-spis}  with frame {&frame-name} .
         {&browse-name}:bgcolor  in frame {&frame-name}  = 8 .
  end.
  when 2 then do:
        enable  {&List-spis} with frame {&frame-name} .
        disable  {&dates} {&List-tt}
        t-rv  t-rvz t-rvc t-rvzc t-sp t-sppv
        t-sppv-2 t-sppv-3 t-sppv-4
        with frame {&frame-name} .
        {&browse-name}:bgcolor  in frame {&frame-name}  = 8 .
  end.
  when 3 then do:
        enable   {&dates} {&List-tt}
        t-rv  t-rvz t-rvc t-rvzc t-sp t-sppv
        t-sppv-2 t-sppv-3 t-sppv-4

          with frame {&frame-name} .
        disable  {&List-spis} with frame {&frame-name} .
        {&browse-name}:bgcolor  in frame {&frame-name}  = ? .

   end.
   otherwise do:
   end.
  end case.
 display  {&List-tt} {&List-spis} {&dates} with frame {&frame-name} .
 hide t-sppv-2 in frame {&frame-name} .
 end. /* start-proc */
end procedure. /* v-c-alg */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE p-calc Dialog-Frame
PROCEDURE p-calc :
{&start-proc}
define input-output parameter n-day as logical no-undo .
define input parameter n-i as integer no-undo .
define variable p-modulo as integer no-undo .

define variable t-i as date no-undo.
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
            if p-modulo = n-i then do:
                if not can-find ( first tt-date where tt-date.exch-date =  t-i ) then do:
                    create tt-date.
                    assign tt-date.exch-date =  t-i.
                    end.
            end.
         end.
  end.
   {&OPEN-QUERY-{&BROWSE-NAME}}

  end.
 end. /* start-proc */
end procedure. /* p-calc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-proc W-Win
PROCEDURE select-objects-proc :
 do
 on error undo, return error return-value
 :
define input parameter p-m as character no-undo .
define variable n-vv as integer   no-undo .
define variable v-all-object as logical   no-undo .
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

    str-pos = index (  p-m , "&" ) .
    str-pos2 = LENGTH ( p-m ) - str-pos .

    str-1 = substring (p-m , str-pos + 1 , str-pos2 ).


    n-vv = num-entries (str-1) .

    do i = 1 to n-vv :
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



procedure verify-check :
 do
 on error undo, return error return-value
 :


 end. /* do */
end procedure. /* verify-check */



procedure sss :
  do
  on error undo, return error return-value
  :
 { cus/s-allobj.i no-initial }

  end. /* do */
end procedure. /* sss */

PROCEDURE init-screen :
 do
 on error undo, return error return-value
 :

define input parameter p-val as character no-undo .
define variable i as integer no-undo .
define variable R-algoritm2 as integer init 0 no-undo .
define variable v-nn as integer   no-undo .
v-nn = num-entries (p-val) .
/* message  p-val . */
  do i = 1 to v-nn :

     case  entry(1,(entry(i,p-val)), "=" ) :
        when string( "R-algoritm" )             then do:
              if  integer(entry(2,(entry(i,p-val)), "=" )) = 2 then
                  R-algoritm2 = 2.
              end.
        when string( "R-algoritm2" )            then do:
             case integer(entry(2,(entry(i,p-val)), "=" ))  :
                when 1 then  R-algoritm =  1  .
                when 2 then  R-algoritm =  4  .
                when 3 then  R-algoritm =  3  .
             end case.
             if R-algoritm2 = 2 then  R-algoritm = 2.
             /* message R-algoritm .*/
             end.
        when string( "tmp-sale.tmp-code" )      then do:
             find first ub.tmp-sale no-lock where ub.tmp-sale.tmp-code = entry(2,(entry(i,p-val)), "=" ) no-error.
             if available ub.tmp-sale then do:
                rr = recid( ub.tmp-sale) .
                 display  ub.tmp-sale.tmp-code
                             ub.tmp-sale.desc_   with frame {&frame-name} .
                 reposition {&frame-name} to recid rr no-error  .
                 if error-status :error then error-status :get-message(1) .
             end.
             else do:
             find first ub.tmp-sale no-lock  .
                if available ub.tmp-sale then rr = recid(ub.tmp-sale) .
             end.

        end.

        when string( "SelectObject" ) then  do:
             SelectObject = string(entry(2,(entry(i,p-val)), "=" )).
                if SelectObject = "choice":U then SelectObject = "order":U .
                run select-objects-proc in this-procedure ( input p-val ).
             end.

        when string( "date-p-1" ) then  date-p-1 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "date-p-2" ) then  date-p-2 = date(entry(2,(entry(i,p-val)), "=" )).
        when string( "t-way"   )   then  t-way    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rcv"   )   then  t-rcv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-clos"   )   then  t-clos    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rv"   )   then  t-rv    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-rvz"  )   then  t-rvz   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-rvc"  )   then  t-rvc   = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-rvzc" )   then  t-rvzc  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sp"   )   then  t-sp    = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv" )   then  t-sppv  = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false  .
        when string( "t-sppv-2")  then  t-sppv-2 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false.
        when string( "t-sppv-3")  then  t-sppv-3 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .
        when string( "t-sppv-4")  then  t-sppv-4 = if (entry(2,(entry(i,p-val)), "=" )) = "yes" then true else false .

    end case.
    g#log = SelectObject:disable(radio-label({&all} , SelectObject:radio-buttons)).
  end.


end.  /* do */
END PROCEDURE.

procedure v-c-way :

  do
  on error undo, return error return-value
  :

assign frame {&frame-name}
  t-way
  t-rcv
  t-clos
 .

        if t-way  then do:
            enable
              t-rcv
              t-clos
              with frame {&frame-name} .
            display
              t-rcv
              t-clos
              with frame {&frame-name} .

        end.
        else do:
          hide
            t-rcv
            t-clos
            in frame {&frame-name} .
        end.
  end.
end procedure. /* v-c-way */