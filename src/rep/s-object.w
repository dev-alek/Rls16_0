&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главная закладка № 1

Автор: Чернова Светлана Александровна
Дата создания: 16/10/00
Author: Svetlana Chernova
Creation date: 16/10/00


"Все по фирме", {&obj-firm},
"Текущий", {&obj-currency},
"Выборочно", {&obj-choice},
"Все", {&all}

no_app_help.i
*/

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---      */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно для вызова отчетов (Главная закладка № 1)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/operlist.i }
{ ref/grplibfn.i }
{ cmp/cli-list.i cli-list def "new shared" }
{ rep/rep-bt.i   }
{ gbl/userobjs.i }
{str/lib-trn.i}
{ str/listhprc.i "gds-list"  }
&glob max-len-str 6000

define shared variable lns-cnt as integer no-undo .
define shared variable s-notes   as character no-undo .
define variable proba1 as integer no-undo .

define variable list-mode                 as character no-undo .
define variable doc-mode                  as character no-undo .
define variable doc-rec                   as recid     no-undo .
define variable line-rec                  as recid     no-undo .
define variable gds-rec                   as recid     no-undo .
define variable prt-rec                   as recid     no-undo .
define variable line-mode                 as character no-undo .
define variable v-ok                      as logical   no-undo .
define variable state-source              as widget-handle no-undo . /*inc !!!!*/
define variable temp-str                  as character no-undo .
define variable temp-param-date           as integer   no-undo .
define variable temp-param-date-type-period  as character no-undo .
define variable temp-param-goods          as character no-undo . /* Товары */
define variable temp-param-obj            as character no-undo . /* Объекты */
define variable temp-param-Pay            as character no-undo . /* Цены */
define variable temp-param-Pay-hide       as character no-undo . /* Цены */
define variable temp-param-obj-type       as character no-undo . /* Типы объектов - all stock shop */
define variable temp-param-alon           as logical   no-undo . /* 1 закладка */
define variable temp-param-customer       as character no-undo . /* Контрагенты */
define variable temp-param-customer-type  as character no-undo . /* фильтр для справочника Контрагентов */
define variable temp-param-schet          as character no-undo . /* Счета */
define variable temp-param-schet-hide     as character no-undo . /* что дисаблить в СЧЕТАХ */
define variable temp-param-schet-init     as character no-undo . /* начальное  значение */
define variable temp-param-schet-mode     as character no-undo . /* для счетов - выборка только нашей фирмы "company-host":U или всех {&company} */
define variable v-all-object              as logical   no-undo .
define variable t-str                     as character no-undo .
define variable str-obj#                  as character no-undo .
define variable str-obj2#                 as character no-undo .
define variable str-obj3#                 as character no-undo .
define variable v-curr-code               as integer   no-undo .
define variable schet-list                as character no-undo .
define variable init-shet-init            as character no-undo .
define variable v-curr-abbr               as character no-undo .
define variable mi-ed_date-alone-handle   as handle    no-undo .
define variable mi-ed_date-start-handle   as handle    no-undo .
define variable mi-ed_date-end-handle     as handle    no-undo .
define variable menu-ed_date-alone-handle   as handle    no-undo .
define variable menu-ed_date-start-handle   as handle    no-undo .
define variable menu-ed_date-end-handle     as handle    no-undo .
define variable keep-spis as character no-undo .
define variable choose-shift as logical no-undo init no .
define variable temp-param-goods-choose as character no-undo .
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 RECT-3 RECT-4 RECT-7 RECT-node ~
RECT-node-2 Radio-Period TOG-Shift SET_PAY_TYPE Date-Alone TOG-Shift-2 ~
ShowCrsa RADIO-task ShowCost Shift-Alone BUTTON-shift Shift-Start ~
BUTTON-Shift-Start Shift-End BUTTON-Shift-end ShowSale Date-Start Date-End ~
SET_val_TYPE SelectGood SelectObject Radio-customer BUTTON-node ~
customer-name BUTTON-obj BUTTON-prod BUTTON-gds BUTTON-one BUTTON-keep-spis ~
Radio-schet BUTTON-node-2 BUTTON-prod-2 Goods-Editor lkp-schet TOG-Excel ~
TOG-list-hist TEXT-3 TEXT-4 TEXT-2 text-5 TEXT-1 Obj-count text-6 ~
Goods-count
&Scoped-Define DISPLAYED-OBJECTS Radio-Period TOG-Shift SET_PAY_TYPE ~
Date-Alone TOG-Shift-2 ShowCrsa RADIO-task ShowCost Shift-Alone Shift-Start ~
Shift-End ShowSale Date-Start Date-End SET_val_TYPE SelectGood SelectObject ~
Radio-customer customer-name Radio-schet Goods-Editor lkp-schet TOG-Excel ~
TOG-list-hist TEXT-3 TEXT-4 TEXT-2 text-5 TEXT-1 Obj-count text-6 ~
Goods-count

/* Custom List Definitions                                              */
/* List-schet,List-2,List-3,List-4,List-5,List-6                        */
&Scoped-define List-schet Radio-schet BUTTON-schet BUTTON-schet-one ~
BUTTON-schet-val lkp-schet text-6
&Scoped-define List-6 Shift-Alone Date-Start Date-End

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-gds 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-gds" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-keep-spis 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-node 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-node" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-node-2 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button node 2" 
     SIZE 3 BY .86
     BGCOLOR 3 .

DEFINE BUTTON BUTTON-obj 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-one 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button one" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-prod 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-prod" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-prod-2 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button prod 2" 
     SIZE 3 BY .86
     BGCOLOR 4 .

DEFINE BUTTON BUTTON-schet 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-schet-one 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-schet-val 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86.

DEFINE BUTTON BUTTON-shift 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на объекте"
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-Shift-end 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на объекте"
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-Shift-Start 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на объекте"
     BGCOLOR 8 .

DEFINE VARIABLE Radio-Period AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS COMBO-BOX INNER-LINES 14
     LIST-ITEM-PAIRS "За квартал (текущий)","1",
                     "За квартал (прошлый)","3"
     DROP-DOWN-LIST
     SIZE 52.6 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE customer-name AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 28.6 BY 2.52 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE Goods-Editor AS CHARACTER 
     VIEW-AS EDITOR MAX-CHARS 32000 SCROLLBAR-VERTICAL
     SIZE 33.4 BY 1.95
     FONT 4 NO-UNDO.

DEFINE VARIABLE lkp-schet AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 26 BY 1.95 TOOLTIP "Что выбрали"
     FONT 4 NO-UNDO.

DEFINE VARIABLE Date-Alone AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Date-End AS DATE FORMAT "99/99/9999":U 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Date-Start AS DATE FORMAT "99/99/9999":U 
     LABEL "с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Goods-count AS CHARACTER FORMAT "X(30)":U 
      VIEW-AS TEXT 
     SIZE 33.2 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE Obj-count AS CHARACTER FORMAT "X(30)":U 
      VIEW-AS TEXT 
     SIZE 24 BY .81
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE Shift-Alone AS INTEGER FORMAT ">9":U INITIAL 1 
     LABEL "смена" 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Shift-End AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "по" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE Shift-Start AS INTEGER FORMAT ">9":U INITIAL 0 
     LABEL "с" 
     VIEW-AS FILL-IN NATIVE 
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор объекта" 
      VIEW-AS TEXT 
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TEXT-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор товара" 
      VIEW-AS TEXT 
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TEXT-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Задание даты" 
      VIEW-AS TEXT 
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TEXT-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор цен" 
      VIEW-AS TEXT 
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE text-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор поставщика" 
      VIEW-AS TEXT 
     SIZE 29.6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE text-6 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор счета" 
      VIEW-AS TEXT 
     SIZE 15.6 BY .76
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Radio-customer AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "все", 1,
"Выборочно", 2
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE Radio-schet AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все по фирме", 1,
"Своей фирмы", 2,
"Выборочно", 3,
"Один", 4,
"Все abbr_rublevye", 5,
"Все валютные", 6,
"По валюте", 7
     SIZE 15 BY 5.24 TOOLTIP "Выбор банковского счета" NO-UNDO.

DEFINE VARIABLE RADIO-task AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Календарные даты", 1,
"Сменные сутки", 2,
"Сменные сутки и порядок", 3,
"По сменам", 4
     SIZE 26 BY 3 NO-UNDO.

DEFINE VARIABLE SelectGood AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Группы товаров", 2,
"Производители", 3,
"Выборочно", 4,
"Один", 5,
"Хранимый список", 6,
"Гр. товаров + Производители", 7
     SIZE 29.8 BY 5.29
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE SelectObject AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все по фирме", "obj-firm",
"Текущий", "obj-currency",
"Выборочно", "obj-choice",
"Все", "all"
     SIZE 16.4 BY 2.76 NO-UNDO.

DEFINE VARIABLE SET_PAY_TYPE AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Продажные цены", 1,
"Учетные цены", 2,
"Цены документа", 3
     SIZE 19.2 BY 2.33 NO-UNDO.

DEFINE VARIABLE SET_val_TYPE AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "abbr_rub", 1,
"вал", 2,
"обе валюты", 3
     SIZE 26.2 BY 1.14 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 59.8 BY 4.52.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28.8 BY 4.52.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 25.8 BY 4.71.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 34.2 BY 10.29
     BGCOLOR 8 FGCOLOR 0 .

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 28.6 BY 4.71.

DEFINE RECTANGLE RECT-node
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 4 BY 1.19
     FGCOLOR 8 .

DEFINE RECTANGLE RECT-node-2
     EDGE-PIXELS 1 GRAPHIC-EDGE    
     SIZE 4 BY 1.19
     BGCOLOR 8 FGCOLOR 8 .

DEFINE VARIABLE ShowCost AS LOGICAL INITIAL no 
     LABEL "Учетные цены" 
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .81 TOOLTIP "Показать суммы  в учетных ценах" NO-UNDO.

DEFINE VARIABLE ShowCrsa AS LOGICAL INITIAL no 
     LABEL "Продажные цены" 
     VIEW-AS TOGGLE-BOX
     SIZE 18.2 BY .81 TOOLTIP "Показать суммы  в продажных ценах" NO-UNDO.

DEFINE VARIABLE ShowSale AS LOGICAL INITIAL no 
     LABEL "Цены документа" 
     VIEW-AS TOGGLE-BOX
     SIZE 18.2 BY .81 TOOLTIP "Показать суммы  в ценах документа" NO-UNDO.

DEFINE VARIABLE TOG-Excel AS LOGICAL INITIAL yes 
     LABEL "Есть экспорт в Excel" 
     VIEW-AS TOGGLE-BOX
     SIZE 22.2 BY .81
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TOG-list-hist AS LOGICAL INITIAL yes 
     LABEL "Печать истории формир. списков" 
     VIEW-AS TOGGLE-BOX
     SIZE 33.6 BY .81
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TOG-Shift AS LOGICAL INITIAL yes 
     LABEL "Смены" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.

DEFINE VARIABLE TOG-Shift-2 AS LOGICAL INITIAL no 
     LABEL "Одна смена" 
     VIEW-AS TOGGLE-BOX
     SIZE 14.8 BY .81 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Radio-Period AT ROW 2 COL 4 NO-LABEL WIDGET-ID 8
     TOG-Shift AT ROW 2 COL 32.2
     SET_PAY_TYPE AT ROW 2 COL 64.6 NO-LABEL
     Date-Alone AT ROW 2.05 COL 17.8 COLON-ALIGNED
     TOG-Shift-2 AT ROW 2.05 COL 44.8
     ShowCrsa AT ROW 2.1 COL 64.6
     RADIO-task AT ROW 2.24 COL 2 NO-LABEL
     ShowCost AT ROW 2.76 COL 64.6
     Shift-Alone AT ROW 2.95 COL 48.2 COLON-ALIGNED
     BUTTON-shift AT ROW 2.95 COL 53.4
     Shift-Start AT ROW 3.19 COL 30.6 COLON-ALIGNED
     BUTTON-Shift-Start AT ROW 3.24 COL 36 WIDGET-ID 2
     Shift-End AT ROW 3.24 COL 46.8 COLON-ALIGNED
     BUTTON-Shift-end AT ROW 3.24 COL 52 WIDGET-ID 6
     ShowSale AT ROW 3.43 COL 64.6
     Date-Start AT ROW 4.24 COL 30.6 COLON-ALIGNED
     Date-End AT ROW 4.24 COL 47 COLON-ALIGNED
     SET_val_TYPE AT ROW 4.24 COL 61.6 NO-LABEL
     SelectGood AT ROW 6.33 COL 1.8 NO-LABEL
     SelectObject AT ROW 6.52 COL 38.6 NO-LABEL
     Radio-customer AT ROW 6.52 COL 61.6 NO-LABEL
     BUTTON-node AT ROW 7.24 COL 31.6
     customer-name AT ROW 7.52 COL 61 NO-LABEL
     BUTTON-obj AT ROW 7.67 COL 56
     BUTTON-prod AT ROW 7.91 COL 31.6
     BUTTON-gds AT ROW 8.67 COL 31.6
     BUTTON-one AT ROW 9.48 COL 31.6
     BUTTON-keep-spis AT ROW 10.19 COL 31.6 WIDGET-ID 12
     Radio-schet AT ROW 11 COL 36 NO-LABEL
     BUTTON-node-2 AT ROW 11.81 COL 3.6
     BUTTON-prod-2 AT ROW 11.81 COL 7.6
     BUTTON-schet AT ROW 12.52 COL 55.2
     BUTTON-schet-one AT ROW 13.24 COL 55.2
     Goods-Editor AT ROW 13.62 COL 1 NO-LABEL
     BUTTON-schet-val AT ROW 15.52 COL 55.2
     lkp-schet AT ROW 16.52 COL 35.6 NO-LABEL
     TOG-Excel AT ROW 16.76 COL 1
     TOG-list-hist AT ROW 17.76 COL 1
     TEXT-3 AT ROW 1.29 COL 17.2 COLON-ALIGNED NO-LABEL
     TEXT-4 AT ROW 1.29 COL 68 COLON-ALIGNED NO-LABEL
     TEXT-2 AT ROW 5.67 COL 9 COLON-ALIGNED NO-LABEL
     text-5 AT ROW 5.76 COL 59.4 COLON-ALIGNED NO-LABEL
     TEXT-1 AT ROW 5.81 COL 39.6 COLON-ALIGNED NO-LABEL
     Obj-count AT ROW 9.24 COL 34.6 COLON-ALIGNED NO-LABEL
     text-6 AT ROW 10.24 COL 35 COLON-ALIGNED NO-LABEL
     Goods-count AT ROW 12.91 COL 1 NO-LABEL
     RECT-1 AT ROW 1 COL 1
     RECT-2 AT ROW 1 COL 60.8
     RECT-3 AT ROW 5.52 COL 35.2
     RECT-4 AT ROW 5.52 COL 1
     RECT-7 AT ROW 5.52 COL 61
     RECT-node AT ROW 11.05 COL 4.2
     RECT-node-2 AT ROW 11.05 COL 8.6
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 FGCOLOR 0 .


/* *********************** Procedure Settings ************************ */
FUNCTION stat-line RETURNS CHARACTER
  (input p-status-chr as character )  FORWARD.
&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 17.57
         WIDTH              = 90.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN 
       BUTTON-gds:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       BUTTON-keep-spis:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       BUTTON-node:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       BUTTON-node-2:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       BUTTON-one:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       BUTTON-prod:HIDDEN IN FRAME F-Main           = TRUE.

ASSIGN 
       BUTTON-prod-2:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR BUTTON BUTTON-schet IN FRAME F-Main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR BUTTON BUTTON-schet-one IN FRAME F-Main
   NO-ENABLE 1                                                          */
/* SETTINGS FOR BUTTON BUTTON-schet-val IN FRAME F-Main
   NO-ENABLE 1                                                          */
ASSIGN
  customer-name:READ-ONLY IN FRAME F-Main = TRUE.

/* SETTINGS FOR FILL-IN Date-End IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR FILL-IN Date-Start IN FRAME F-Main
   6                                                                    */
/* SETTINGS FOR FILL-IN Goods-count IN FRAME F-Main
   ALIGN-L                                                              */
ASSIGN
  Goods-Editor:READ-ONLY IN FRAME F-Main = TRUE.

/* SETTINGS FOR EDITOR lkp-schet IN FRAME F-Main
   1                                                                    */
ASSIGN
  lkp-schet:READ-ONLY IN FRAME F-Main = TRUE.

/* SETTINGS FOR COMBO-BOX Radio-Period IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR RADIO-SET Radio-schet IN FRAME F-Main
   1                                                                    */
/* SETTINGS FOR FILL-IN Shift-Alone IN FRAME F-Main
   6                                                                    */
ASSIGN
  ShowCost:HIDDEN IN FRAME F-Main = TRUE.

ASSIGN
  ShowCrsa:HIDDEN IN FRAME F-Main = TRUE.

ASSIGN
  ShowSale:HIDDEN IN FRAME F-Main = TRUE.

/* SETTINGS FOR FILL-IN text-6 IN FRAME F-Main
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME BUTTON-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-gds s-object
ON CHOOSE OF BUTTON-gds IN FRAME F-Main /* BUTTON-gds */
DO:
  define variable ref-list       as character no-undo.
  define variable vRecId         as recid     no-undo.
  define variable vAnswer        as logical   no-undo.
  define variable vI             as integer   no-undo.
  define variable v-seq          as integer   no-undo .
  define variable num-rec        as integer   init 0 no-undo.
  define variable v-bh           as handle    no-undo .
  define variable v-recs         as integer   no-undo .
  define variable v-temp-seq     as integer   no-undo .
  define variable v-line         as integer   no-undo .
  define variable v-item         as character no-undo .
  define variable v-tot-lns      as integer   no-undo .
  define variable v-ref-rec      as recid     no-undo .
  define variable dsp-rs         as character no-undo .
  define variable rs-status      as character no-undo init {&current}.
  define variable v-tbl-name     as character no-undo .
  define variable rs-list-method as character no-undo init "goods".
  define variable tot-lns        as integer   init ? no-undo.
  define variable v-no-hist      as integer   no-undo init -1.
  if not params-only then 
  do:
    for each gds-list :
      delete gds-list.
    end.
  end.
  if temp-param-goods-choose <> "" then 
  do:
    run ref/gds-ref.p (
      input my-handle
      ,input "b-mark,b-sel"
      ,input {&all}           /*p-stat */
      ,input "ptrlsug"        /*p-list  */
      ,input ?                /*p-cond  */
      ,input ?                /*p-rec   */
      ,input ?                /*p-grp   */
      ,input ?                /*p-cli-type */
      ,input ?                /*p-cli-code  */
      ,input v-cntxt-obj-type /*p-obj-type  */
      ,input v-cntxt-obj-code /*p-obj-code  */
      ,input ?                /*p-other     */
      ,output ref-list).
    if ref-list = "" and can-find(first gds-list) then 
    do:
      message
        "Не было выбрано ни одного товара. Очистить список ранее выбранных товаров?"
        view-as alert-box QUESTION buttons YES-NO update vAnswer.
      if not vAnswer then return.
    end.

    if ref-list <> "" then 
    do:
      v-recs = num-entries (ref-list).
      do num-rec = 0 to v-recs:

        if v-recs = 1 then 
        do:
          num-rec = 1 .
        end.
        if num-rec > 0 then 
        do:
          v-ref-rec = integer (entry (num-rec, ref-list)).
          find goods where recid (goods) = v-ref-rec no-lock.
          create gds-list .
          buffer-copy goods to gds-list .
        end.
        if v-recs = 1 then 
        do:
          assign
            v-temp-seq = v-seq
            v-line     = 0
            dsp-rs     = substitute("Товар :&1 &2", goods.gds-name, stat-line(rs-status))
            v-item     = '':U
            v-tbl-name = {&table_goods}
            v-bh       = buffer goods:handle
            v-tot-lns  = tot-lns
            .
        end.
        else 
        do:
          if num-rec = 0 then 
          do:
            assign
              v-temp-seq = v-seq
              v-line     = 0
              dsp-rs     = substitute("Товары : &1", stat-line(rs-status))
              v-item     = '':U
              v-tbl-name = '':U
              v-bh       = ?
              v-tot-lns  = tot-lns
              .
          end.
          else 
          do:
            assign
              v-temp-seq = v-seq - 1
              v-line     = num-rec
              dsp-rs     = substitute("код &1 &2 &3&4 &5", goods.gds-code, goods.artic, goods.prod-type, goods.prod-code, goods.gds-name)
              v-item     = '':U
              v-tbl-name = {&table_goods}
              v-bh       = buffer goods:handle
              v-tot-lns  = tot-lns + num-rec
              .
          end.
        end.
        v-no-hist = (if num-rec = 1 then 0 else num-rec).
        run create-gds-list-hist in this-procedure(input {&add-def}
          , input-output v-temp-seq
          , input v-line
          , input '':U
          , input dsp-rs
          , input v-tot-lns
          , input rs-list-method
          , input rs-status
          , input v-item
          , input v-tbl-name
          , input v-bh
          ).
        if num-rec = 0 or v-recs = 1 then v-seq  = v-temp-seq.
      end.
    end.     
  end.

  else 
  do:
    run str/gds-list.w ( input my-handle, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ).
  end.
    lns-cnt = 0 .
    for each gds-list :
      lns-cnt = lns-cnt + 1 .
    end.

  define variable v-i as integer no-undo .
  s-notes =  "" .
    for each gds-list-hist :
      v-i = v-i + 1 .
      s-notes = s-notes + {&new-line} + gds-list-hist.hist-mode +  gds-list-hist.des .
      if v-i > 10 then 
      do:
        s-notes = s-notes + " ... " .
        leave.
      end.
    end.
    run display-count-other in this-procedure .
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-keep-spis
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-keep-spis s-object
ON CHOOSE OF BUTTON-keep-spis IN FRAME F-Main
  DO:
    for each gds-list :
      delete gds-list.
    end.
    keep-spis = "".

    define buffer buf_clob-bind for ub.clob-bind  .
    define variable v-rid-list as character no-undo .

run ref/clobbnds.w ( input my-handle
                    ,input this-procedure:handle
                    ,input 'b-sel' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input ""
                    ,input {&lob-res-list}
                    ,input 'gds-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
  find first buf_clob-bind no-lock where
            recid(buf_clob-bind) = integer(v-rid-list) no-error .
  if available buf_clob-bind then do:
    keep-spis = buf_clob-bind.field-name_ .
    lns-cnt = 1 .
    s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
  end.
  else do:
    keep-spis = "".
    lns-cnt = 0 .
    s-notes = " " .
  end.

    run new-state ("KEEP-SPIS="  + string(keep-spis)).
    run display-count in this-procedure .
    run display-count-other in this-procedure .

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-node
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-node s-object
ON CHOOSE OF BUTTON-node IN FRAME F-Main /* BUTTON-node */
DO:
/*  gdsgrp_recids = "". */
  run ref/gds-grp.w
   (             input my-handle
                ,input "b-sel,b-mark"
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input-output gdsgrp_recids ).
  run display-count-other in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-node-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-node-2 s-object
ON CHOOSE OF BUTTON-node-2 IN FRAME F-Main /* Button node 2 */
DO:
  run ref/gds-grp.w
  (              input my-handle
                ,input "b-sel,b-mark"
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input-output gdsgrp_recids ).
  if num-entries(gdsgrp_recids) > 0
         then do:
            rect-node:bgcolor = 3 .
         end.
         else do:
            rect-node:bgcolor = 8 .
         end.

  run display-count-other in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-obj s-object
ON CHOOSE OF BUTTON-obj IN FRAME F-Main /* BUTTON-obj */
DO:
  assign SelectObject.
  my-request = false .
  run select-objects-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-one s-object
ON CHOOSE OF BUTTON-one IN FRAME F-Main /* Button one */
DO:
  define variable ri-list         as char no-undo .
  define buffer buf_goods for ub.goods .
  run ref/gds-ref.p
    ( my-handle
      ,'b-sel'
      ,?             /*p-stat */
      ,?             /*p-list  */
      ,?             /*p-cond  */
      ,?             /*p-rec   */
      ,?             /*p-grp   */
      ,?             /*p-cli-type */
      ,?             /*p-cli-code  */
      ,v-cntxt-obj-type    /*p-obj-type  */
      ,v-cntxt-obj-code     /*p-obj-code  */
      ,?             /*p-other     */
      , output ri-list) .
  for each gds-list :
     delete gds-list.
  End.
  If ri-list <> "" then DO:
     find first buf_goods where recid(buf_goods) = integer (ri-list) no-lock.
     buffer-copy buf_goods TO gds-list no-error.
     run display-count-other in this-procedure .
  End.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-prod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-prod s-object
ON CHOOSE OF BUTTON-prod IN FRAME F-Main /* BUTTON-prod */
DO:
  define variable v-ind as integer   no-undo .
  define buffer cli-prod for ub.clients .
  define variable cli-grp_recids as character no-undo .

  /* может и не надо??? */
          FOR EACH g#cli :
            delete g#cli .
           END .

     if SelectGood:screen-value = "{&g-prod}" then
        do:
            run ref/cli-all.w
                ( my-handle
                , "b-sel,b-mark"
                , {&pro}
                , {&all}
                , {&current}
                , ?
                , ",,,,,,NO,,"
                , ?
              , output cli-grp_recids ) no-error .
             if error-status :error then
                message vss-workfile vss-revision vss-description skip
                        error-status :get-message(1) skip
                        "Ошибка вызова cli-all.w"
                        view-as alert-box error .

            if cli-grp_recids = "" then do:
                 Assign goods-count = '' Goods-Editor = ''.
                 Display goods-count Goods-Editor with frame {&FRAME-NAME} .
            end.
            else do:
                DO v-ind = 1 TO num-entries( cli-grp_recids )
                :
                    FIND cli-prod WHERE recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) NO-LOCK.
                    create g#cli.
                    assign
                    g#cli.obj-type = cli-prod.obj-type
                    g#cli.obj-code = cli-prod.obj-code
                    g#cli.obj-name = cli-prod.obj-name.
                END.
            end.
        end.
    else do:
       FOR EACH g#cli :
            delete g#cli .
        END .
        cli-grp_recids = "" .
    end.
run display-count-other in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-prod-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-prod-2 s-object
ON CHOOSE OF BUTTON-prod-2 IN FRAME F-Main /* Button prod 2 */
DO  :
  define variable v-ind as integer   no-undo .
  define buffer cli-prod for ub.clients .
  define variable cli-grp_recids as character no-undo .

          FOR EACH g#cli :
            delete g#cli .
           END .

     if SelectGood:screen-value = "{&g-grp-prod}" then
        do with frame {&FRAME-NAME}:
          run ref/cli-all.w
            (  my-handle
            ,  "b-sel,b-mark"
            ,  {&pro}
            ,  {&all}
            ,  {&current}
            ,  ?
            ,  ",,,,,,NO,,"
            , ?
            , output cli-grp_recids ) .

            if cli-grp_recids = "" then do:
                 Assign goods-count = '' Goods-Editor = ''.
                 Display goods-count Goods-Editor with frame {&FRAME-NAME} .
            end.
            else do:
                DO v-ind = 1 TO num-entries( cli-grp_recids ) :
                    FIND cli-prod WHERE recid( cli-prod ) = int( entry(v-ind, cli-grp_recids ) ) NO-LOCK.
                    create g#cli.
                    assign
                    g#cli.obj-type = cli-prod.obj-type
                    g#cli.obj-code = cli-prod.obj-code
                    g#cli.obj-name = cli-prod.obj-name.
                END.
            end.

            RECT-node-2:bgcolor = 3 .
        end.
    else do:
       FOR EACH g#cli :
            delete g#cli .
        END .
        cli-grp_recids = "" .
        RECT-node-2:bgcolor = 8 .
    end.
 if not can-find (first g#cli no-lock )  then  RECT-node-2:bgcolor = 8 .
run display-count-other in this-procedure  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-schet s-object
ON CHOOSE OF BUTTON-schet IN FRAME F-Main
DO:
define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
 /* выборочно  */
 schet-list = "" .
  assign radio-schet.
       run ref/finschts.w
       (   input my-handle,
           input v-cntxt-host-code-obj,
           input "b-mark,b-sel",
           input temp-param-schet-mode,
           input ?,
           input ?,
           input 0,
           input v-cntxt-host-code-obj ,
           input 0,
           input-output v-status_,
           input-output schet-list).

      if  schet-list = "" then do:
         define variable var-ll as integer no-undo .
         repeat var-ll = 7 to 1 by -1 :
            if lookup( string(var-ll) , temp-param-schet-hide) <> 0 then next.
            radio-schet = var-ll .
         end.
         display RADIO-schet with frame {&frame-name} .
         run select-radio-schet-no-apply in this-procedure .
     end.
 fin-schet-recid =  schet-list .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-schet-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-schet-one s-object
ON CHOOSE OF BUTTON-schet-one IN FRAME F-Main
DO:
 /*  один   */
 define variable v-status_ like ub.fin-schet.status_ no-undo init {&current-status}.
 define buffer buf_fin-schet for ub.fin-schet.
  schet-list          = "" .
 if temp-param-schet-init <> "" and temp-param-schet-init <> ? then do:
      find first buf_fin-schet no-lock where
        buf_fin-schet.code-schet = integer (temp-param-schet-init) and
        buf_fin-schet.host-code  = v-cntxt-host-code-obj no-error .
      if available buf_fin-schet then
        assign
          schet-list = string(recid(buf_fin-schet))
          v-status_  = buf_fin-schet.status_
          .
    end.
    run ref/finschts.w
      (   input my-handle,
      input v-cntxt-host-code-obj,
      input "b-sel",
      input temp-param-schet-mode,
      input ?,
      input ?,
      input 0,
      input v-cntxt-host-code-obj ,
      input 0,
      input-output v-status_,
      input-output schet-list).

    fin-schet-recid =  schet-list .

    if num-entries(schet-list) > 1 then 
    do:
      message "Можно выбрать только один счет !!!" view-as alert-box .
      return no-apply.
    end.
    find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (schet-list)   no-error .
    if not available buf_fin-schet
      then 
    do :
      define variable var-ll as integer no-undo .
      repeat var-ll = 7 to 1 by -1 :
        if lookup( string(var-ll) , temp-param-schet-hide) <> 0 then next.
        radio-schet = var-ll .
      end.

    display RADIO-schet with frame {&frame-name} .
    run select-radio-schet-no-apply in this-procedure .
  end.
  else do:
    lkp-schet = "Выбран счет  " +  string( buf_fin-schet.code-schet) .
    display lkp-schet with frame {&frame-name} .
  end.
  if radio-schet = {&schet-one} then do:
    define variable v-code-schet as integer no-undo .
    if available buf_Fin-schet then do:
      assign
      v-code-schet = buf_fin-schet.code-schet.
    end.
    if ref_date-start <> '':u
    and entry(2, ref_date-start, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-start, {&delim-par}) = "code-schet-start".
      entry(4, ref_date-start, {&delim-par}) = string(v-code-schet).
    end.
    if ref_date-end <> '':u
    and entry(2, ref_date-end, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-end, {&delim-par}) = "code-schet-end".
      entry(4, ref_date-end, {&delim-par}) = string(v-code-schet).
    end.
    if ref_date-alone <> '':u
    and entry(2, ref_date-alone, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-alone, {&delim-par}) = "code-schet-end1".
      entry(4, ref_date-alone, {&delim-par}) = string(v-code-schet).
    end.
  end.


  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-schet-val
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-schet-val s-object
ON CHOOSE OF BUTTON-schet-val IN FRAME F-Main
DO:
  define variable ref-rec as recid no-undo.
  define buffer buf_currency for ub.currency .
  v-curr-abbr =  "" .

    run ref/currency.w ( my-handle, "b-sel", input-output ref-rec ).
    if ref-rec = ? then 
    do:

      define variable var-ll as integer no-undo .
      repeat var-ll = 7 to 1 by -1 :
        if lookup( string(var-ll) , temp-param-schet-hide) <> 0 then next.
        radio-schet = var-ll .
      end.
      display RADIO-schet with frame {&frame-name} .
      run select-radio-schet-no-apply in this-procedure .
    end.
    else 
    do:
      find currency where recid ( currency ) = ref-rec no-lock.
      assign
        v-curr-code = currency.curr-code
        schet-list  = "curr-code=" + string(currency.curr-code)
        v-curr-abbr = currency.curr-abbr
        lkp-schet   = temp-param-schet + " по : " + currency.curr-abbr
        .
      display lkp-schet with frame {&frame-name} .
    end.

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-shift s-object
ON CHOOSE OF BUTTON-shift IN FRAME F-Main
DO:
  define variable v-doc-rec as recid no-undo.
  define variable rec-list-2 as character no-undo.
  define buffer buf_shift-obj for ub.shift-obj .

  IF  SelectObject:screen-value = {&obj-currency} then do:
    find first buf_shift-obj No-LOCK WHERE
              buf_shift-obj.shift-date = date-start AND
              buf_shift-obj.shift-num = shift-alone AND
              buf_shift-obj.obj-type = v-cntxt-obj-type AND
              buf_shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if available buf_shift-obj then
      rec-list-2 = string(recid(buf_shift-obj)).
  end.
  IF  SelectObject:screen-value = {&obj-currency}
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type   /*p-obj-type*/
                   ,input v-cntxt-obj-code   /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "all":U
                   ,input '':U  /*p-obj-type*/
                   ,input 0     /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
    end.

    find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if available buf_shift-obj then DO:
       Assign
        date-start  = buf_shift-obj.shift-date
        shift-alone = buf_shift-obj.shift-num.
         enable date-start  shift-alone with frame {&frame-name}.
       Display date-start  shift-alone with frame {&frame-name}.

        apply "leave" to shift-alone .
        apply "leave" to date-start .

    End.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-Shift-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-Shift-end s-object
ON CHOOSE OF BUTTON-Shift-end IN FRAME F-Main
DO:
  define variable v-doc-rec as recid no-undo .
  define variable rec-list-2      as char no-undo.
  define buffer buf_shift-obj for ub.shift-obj .

  IF  SelectObject:screen-value = {&obj-currency} then do:
    find first buf_shift-obj No-LOCK WHERE
              buf_shift-obj.shift-date = date-end AND
              buf_shift-obj.shift-num = shift-end AND
              buf_shift-obj.obj-type = v-cntxt-obj-type AND
              buf_shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if available buf_shift-obj then
    rec-list-2 = string(recid(buf_shift-obj)).
  end.
  IF  SelectObject:screen-value = {&obj-currency}
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type   /*p-obj-type*/
                   ,input v-cntxt-obj-code   /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "all":U
                   ,input '':U  /*p-obj-type*/
                   ,input 0     /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
    end.

    find first buf_shift-obj where recid (buf_shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if available buf_shift-obj then DO:
       Assign
        date-end  = buf_shift-obj.shift-date
        shift-end = buf_shift-obj.shift-num.
       enable date-end  shift-end with frame {&frame-name}.
       Display date-end  shift-end with frame {&frame-name}.

        apply "leave" to shift-end .
        apply "leave" to date-end .

    End.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-Shift-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-Shift-Start s-object
ON CHOOSE OF BUTTON-Shift-Start IN FRAME F-Main
DO:
  define variable v-doc-rec as recid no-undo .
  define variable rec-list-2      as char no-undo.
  define buffer buf_shift-obj for ub.shift-obj .
  IF  SelectObject:screen-value = {&obj-currency} then do:
    find first buf_shift-obj No-LOCK WHERE
              buf_shift-obj.shift-date = date-start AND
              buf_shift-obj.shift-num = shift-start AND
              buf_shift-obj.obj-type = v-cntxt-obj-type AND
              buf_shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if available buf_shift-obj then
    rec-list-2 = string(recid(buf_shift-obj)).
  end.
  IF  SelectObject:screen-value = {&obj-currency}
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type   /*p-obj-type*/
                   ,input v-cntxt-obj-code   /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
        (             input my-handle
        ,input v-cntxt-obj-type /*p-curr-obj-type*/
        ,input v-cntxt-obj-code /*p-curr-obj-code*/
        ,input  "b-sel"
        ,input "all":U
        ,input '':U  /*p-obj-type*/
        ,input 0     /*p-obj-code*/
        ,input ReportProc
        ,input-output rec-list-2 ).
    end.

    find shift-obj where recid (shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if AVAILABLE  shift-obj then 
    DO:
      Assign
        date-start  = shift-obj.shift-date
        shift-start = shift-obj.shift-num.
      enable date-start  shift-start with frame {&frame-name}.
      Display date-start  shift-start with frame {&frame-name}.
        if TOG-Shift-2 then do:
            assign
             Date-End = Date-Start
             Shift-End = Shift-Start
             Date-End:SCREEN-VALUE = string(Date-Start)
             Shift-End:SCREEN-VALUE = string(Shift-Start)
             x-Date-End  = Date-End
             x-Shift-End = Shift-End
            .   
    Display date-end  shift-end with frame {&frame-name}.              
        end.    
      apply "leave" to shift-start .
      apply "leave" to date-start .

    End.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-Alone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Alone s-object
ON LEAVE OF Date-Alone IN FRAME F-Main /* Дата */
DO:
  Assign Date-Alone no-error.
  x-date-start = Date-Alone.
  x-date-end = Date-Alone.
  x-date-alone = Date-Alone.
  run new-state ("DATE-ALONE="  + String(DATE-ALONE:screen-value)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-End s-object
ON LEAVE OF Date-End IN FRAME F-Main /* по */
DO:
    Assign  Date-End no-error.
    X-Date-End       = Date-End.
    run verify-date in this-procedure .
    run new-state ("DATE-END="  + String(DATE-END:screen-value)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Date-Start s-object
ON LEAVE OF Date-Start IN FRAME F-Main /* с */
DO:
    Assign  Date-Start no-error.
    X-Date-Start     = Date-Start.
    run new-state ("DATE-START="  + String(DATE-START:screen-value)).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Radio-customer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Radio-customer s-object
ON VALUE-CHANGED OF Radio-customer IN FRAME F-Main
DO:
    Assign
      Radio-customer
    .

DEFINE VARIABLE customer-recids AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS integer NO-UNDO.
define buffer buf_clients for ub.clients.

for each g#customer : delete g#customer. end.


  Case Radio-customer :
  when 1 then DO:
          Assign  customer-name = {&all}.
          Display customer-name with frame {&FRAME-NAME} .
       END.
  when 2 then
        do:
            if temp-param-customer-type  = "" then temp-param-customer-type = {&all}.
            /* message temp-param-customer-type . */
            run str/cli-list.w
                         ( my-handle
                         , v-cntxt-host-code-obj
                         , v-cntxt-obj-type
                         , v-cntxt-obj-code
                            ) .
            if not can-find (first cli-list no-lock ) then do:
                 Assign  customer-name = {&all} Radio-customer = 1.
                 Display customer-name Radio-customer with frame {&FRAME-NAME} .
            end.
            else do:
                Assign  customer-name = ''.
                for each cli-list  :
                    create g#customer.
                    assign
                    g#customer.obj-type = cli-list.obj-type
                    g#customer.obj-code = cli-list.obj-code
                    g#customer.obj-name = cli-list.obj-name.
                    if LENGTH (customer-name) >= 10000 then do:
                       customer-name = trim(customer-name , '...') .
                       customer-name = customer-name + '...' .
                    end.
                    else customer-name = customer-name + cli-list.obj-name + {&new-line}.
                END.
                 Display customer-name with frame {&FRAME-NAME} .
            end.
        end.
  End case.
  run new-state ("RADIO-CUSTOMER="  + string(Radio-customer)).
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Radio-Period
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Radio-Period s-object
ON VALUE-CHANGED OF Radio-Period IN FRAME F-Main
DO:
  assign radio-period.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Radio-schet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Radio-schet s-object
ON VALUE-CHANGED OF Radio-schet IN FRAME F-Main
DO:
 Assign Radio-schet.
 display Radio-schet with frame {&frame-name} .
 run select-radio-schet in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-task
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-task s-object
ON VALUE-CHANGED OF RADIO-task IN FRAME F-Main
DO:
Assign RADIO-task Date-End Date-Start shift-end shift-start.
x-RADIO-task  = RADIO-task.
x-Date-End    = Date-End .
x-Date-Start  = Date-Start.
x-shift-End   = shift-End .
x-shift-Start = shift-Start.
x-shift-alone = shift-alone.


run display-radio-task in this-procedure .
run new-state ( "RADIO-TASK="  + String(RADIO-TASK:screen-value)).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectGood
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectGood s-object
ON VALUE-CHANGED OF SelectGood IN FRAME F-Main
DO:
  run val-goods in this-procedure .
  RUN new-state ("SELECTGOOD="  + String(SelectGood:screen-value)).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectObject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectObject s-object
ON VALUE-CHANGED OF SelectObject IN FRAME F-Main
DO:
Assign SelectObject.
run select-objects-proc in this-procedure .
run val-obj in this-procedure .
run new-state ("SELECTOBJECT="  + SelectObject).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SET_PAY_TYPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SET_PAY_TYPE s-object
ON VALUE-CHANGED OF SET_PAY_TYPE IN FRAME F-Main
DO:
    Assign SET_PAY_TYPE.
            X-SET_PAY_TYPE   = SET_PAY_TYPE.

   run set_val in this-procedure .
   run new-state ( "SET_PAY_TYPE ="  + String(SET_PAY_TYPE:screen-value)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SET_val_TYPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SET_val_TYPE s-object
ON VALUE-CHANGED OF SET_val_TYPE IN FRAME F-Main
DO:
  assign
    SET_val_TYPE
  .
  x-SET_val_TYPE = SET_val_TYPE.
  /* Проверка цен остатков */
    if Verify-Arc-stk then do:
      If var-report-r-b = "base" then do:
        if X-SET_val_TYPE = 1 and base-code <> 0
        /* выбрали  р у б л и ,  а базовая валюта не  р у б л и */
        then message
            "В валютной версии программы при базовой валюте, не равной {&abbr_rubl}. - " skip
            "в колонках остатки по товару и автоматическая переоценка не будет учтена курсовая" skip
            "разница при печати отчета в продажных ценах и {&abbr_rublyah}. "
            view-as alert-box information Title "В н и м а н и е".
      end.
      else do:
       /*r-b = "rubl"*/
      end.
    end.

  run new-state ("SET_VAL_TYPE="  + String(SET_VAL_TYPE:screen-value)).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Shift-Alone
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Shift-Alone s-object
ON LEAVE OF Shift-Alone IN FRAME F-Main /* смена */
  DO:
    Assign Shift-Alone Shift-End Shift-start.
    X-Shift-Alone   = Shift-Alone.
    X-Shift-End     = Shift-Alone.
    X-Shift-start   = Shift-alone.
    Shift-End       = Shift-Alone.
    Shift-start     = Shift-alone.

    if Shift-End:visible in frame {&frame-name}    then   display Shift-end with frame {&frame-name} .
    if Shift-start:visible in frame {&frame-name}  then   display Shift-start with frame {&frame-name} .
    display Shift-Alone with frame {&frame-name} .
    run new-state ("SHIFT-ALONE="  + String(SHIFT-Alone:screen-value)).
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Shift-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Shift-End s-object
ON LEAVE OF Shift-End IN FRAME F-Main /* по */
  DO:
    Assign Shift-End.
    X-Shift-End  = Shift-End.
    run new-state ( "SHIFT-END="  + String(SHIFT-END:screen-value)).

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Shift-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Shift-Start s-object
ON LEAVE OF Shift-Start IN FRAME F-Main /* с */
  DO:
    Assign Shift-Start.
    X-Shift-Start = Shift-Start.
    run new-state ( "SHIFT-START="  + String(SHIFT-START:screen-value)).
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-Excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-Excel s-object
ON VALUE-CHANGED OF TOG-Excel IN FRAME F-Main /* Есть экспорт в Excel */
  DO:
    Assign Tog-Excel.

    If Tog-Excel Then Make-Excel = True.
    Else Make-Excel = False.

    run new-state ( "TOG-EXCEL ="  + String(Tog-Excel)).

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-list-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-list-hist s-object
ON VALUE-CHANGED OF TOG-list-hist IN FRAME F-Main /* Печать истории формир. списков */
  DO:
    Assign Tog-list-hist.

    If Tog-list-hist Then print-list-hist = True.
    Else print-list-hist = False.

    run new-state ("TOG-list-hist ="  + String(Tog-list-hist)).

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-Shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-Shift s-object
ON VALUE-CHANGED OF TOG-Shift IN FRAME F-Main /* Смены */
  DO:
    assign TOG-Shift .
    run val-shift  in this-procedure .

    if tog-shift:screen-value = string(true) then tog-shift = true .
    else tog-shift = false .
    if tog-shift = false  then x-tog-shift   = false .
    else x-tog-shift   = true .

    RUN new-state ("TOG-SHIFT ="  + String(Tog-SHIFT:screen-value)).

  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME TOG-Shift-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL TOG-Shift-2 s-object
ON VALUE-CHANGED OF TOG-Shift-2 IN FRAME F-Main /* Одна смена */
DO:
  define buffer buf_shift-obj for ub.shift-obj .
Assign TOG-Shift-2.
Date-End:screen-value IN frame {&frame-name}  = Date-Start:screen-value IN frame {&frame-name}.
Shift-End:screen-value IN frame {&frame-name} = Shift-Start:screen-value IN frame {&frame-name}.
Date-End  = date (Date-Start:screen-value IN frame {&frame-name}).
Shift-End = integer(Shift-Start:screen-value IN frame {&frame-name}).
x-Date-End  = DAte(Date-Start:screen-value IN frame {&frame-name}).
x-Shift-End = integer(Shift-Start:screen-value IN frame {&frame-name}).


if TOG-Shift-2 then
    do:
        disable
            Date-End
            shift-end
        with frame {&frame-name}.
    end.
else
    do:
        enable
            Date-End
            shift-end
        with frame {&frame-name}.
    end.

Display Date-End shift-end with frame {&frame-name}.

if can-find(first buf_shift-obj where buf_shift-obj.obj-code = v-cntxt-obj-code and
    buf_shift-obj.obj-type = v-cntxt-obj-type no-lock) then
        do:
            if tog-shift-2 then
                do:
                    disable button-shift-end with frame {&frame-name} .
                end.
            else
                do:
                    enable button-shift-end with frame {&frame-name} .
                end.
            display button-shift-end with frame {&frame-name} .
        end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

  define variable v-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-r-b
  }

{ gbl/ed_date.i date-Alone  " " " " " " menu-ed_date-alone-handle }
{ gbl/ed_date.i date-End    " " " " " " menu-ed_date-end-handle   }
{ gbl/ed_date.i date-Start  " " " " " " menu-ed_date-start-handle   }

/*триггер для вызова динамически рождаемого пункта меню соответствующего ed_date */
procedure proc-mi-ed_date :
    define variable v-widget-ref as character no-undo .
    if (can-query (self, "sensitive")
        and
        self :sensitive = true
        )
        or (can-query (self, "read-only")
        and
        self :read-only = false
        )
        then 
    do:
        if self :handle <> focus :handle
            then 
        do:
            apply "entry":u to self .
        end.

    define variable v-curr-sv-date  as date      no-undo .

        assign
            v-curr-sv-date = date(self :screen-value) no-error
            .
        case self:handle:
            when mi-ed_date-alone-handle then 
                do:
                    v-widget-ref = ref_date-alone.
                end.
            when mi-ed_date-start-handle then 
                do:
                    v-widget-ref = ref_date-start.
                end.
            when mi-ed_date-end-handle then 
                do:
                    v-widget-ref = ref_date-end.
                end.
        end case.
        assign
            v-widget-ref = substring(v-widget-ref, index(v-widget-ref, {&delim-par}) + 1).
        run gbl/getrefdt.p
            ( input my-handle
            ,input v-widget-ref
            ,input-output v-curr-sv-date
            ) no-error .
    end.
    return.
end procedure. /* proc-mi-ed-date */
assign
  Radio-period :LIST-ITEM-PAIRS in frame F-Main = {&radio-period-list-scr}
  Radio-schet  :radio-buttons   in frame F-Main = "Все по фирме,1,Своей фирмы,2,Выборочно,3,Один,4,Все {&abbr_rublevye},5,Все валютные,6,По валюте,7"
  SET_val_TYPE :radio-buttons in frame F-Main   = "{&abbr_rub},1,вал,2,обе валюты,3"
  .
if v-r-b = {&r-b-base}
  then 
do:
  assign
    SET_val_TYPE = 2 .
  display  set_val_type with frame F-Main .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Assign-frame s-object
PROCEDURE Assign-frame :
  define variable L#obj-code like obj-list.obj-code no-undo.
  define variable l#obj-type like obj-list.obj-type no-undo.

    define buffer cli-obj   for ub.clients .
    define buffer o-clients for ub.clients.
    /*вызвать процедуру если нужно получить данные что было нажато*/
    Assign frame {&FRAME-NAME}
        Date-Alone Date-End Date-Start Goods-count
        Goods-Editor Obj-count SelectGood SelectObject
        SET_PAY_TYPE SET_val_TYPE Shift-Alone
        Shift-End Shift-Start TEXT-1 TEXT-2 TEXT-3 TEXT-4 TOG-Shift
        RADIO-task Tog-Excel tog-list-hist tog-shift-2 showcost showcrsa showsale
        RADIO-period
  no-error.
  
  if  temp-param-date = 8  or temp-param-date = 7 then  tog-shift = true .
  if  tog-shift AND tog-shift-2 THEN
    Assign
      Date-End  = Date-start
      Shift-End = Shift-Start.


  If Tog-Excel Then Make-Excel = True.
  Else Make-Excel = False.

  If Tog-list-hist Then Print-List-Hist = True.
  Else Print-List-Hist = False.



Assign
  X-Date-Alone     = Date-Alone
  X-Date-End       = Date-End
  X-Date-Start     = Date-Start
  X-Goods-Editor   = Goods-Editor
  X-SelectGood     = SelectGood
  X-SelectObject   = SelectObject
  X-SET_PAY_TYPE   = SET_PAY_TYPE
  X-SET_val_TYPE   = SET_val_TYPE
  X-Shift-Alone    = Shift-Alone
  X-Shift-End      = Shift-End
  X-Shift-Start    = Shift-Start
  X-TEXT-1         = TEXT-1
  X-TEXT-2         = TEXT-2
  X-TEXT-3         = TEXT-3
  X-TEXT-4         = TEXT-4
  X-TOG-Shift      = TOG-Shift
  x-RADIO-task     = RADIO-task
  show-cost  = showcost
  show-crsa  = showcrsa
  show-sale  = showsale
  fin-schet-recid =  schet-list
    .

if Date-Alone:visible and date-end:visible = false then do:
   x-date-start = Date-Alone .
   x-date-end   = Date-Alone   .
end.

if RADIO-task = 4 then
assign
  X-Shift-End      = X-Shift-Alone
  X-Shift-Start    = X-Shift-Alone
  .

/* Проверка нет ли двойных записей в obj-list */
 Assign
 L#obj-code=0
 l#obj-type="".

  for each obj-list  by obj-list.obj-code by obj-list.obj-type :
      find first  o-clients where
      o-clients.obj-code = obj-list.obj-code and
      o-clients.obj-type = obj-list.obj-type  no-lock no-error .
      Assign obj-list.obj-name = if avail o-clients then  o-clients.obj-name else "".

     if obj-list.obj-code = L#obj-code and
        obj-list.obj-type = l#obj-type then  do:
        delete obj-list.
     end.
     else do:
        assign l#obj-code = obj-list.obj-code
               l#obj-type = obj-list.obj-type   .
     end.
  End.
    /*!!!!! МЕНЯЯ ЗДЕСЬ НАДО МЕНЯТЬ В ОТЧЕТАХ ЗАПУСКАЮЩИХСЯ ПО РАСПИСАНИЮ!!!*/
    Case temp-param-date :
      When 0 then t-str = "" .
      When 1 then t-str = " На " + string(X-Date-Alone,"99/99/9999").
      When 2 then t-str = " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
      When 3 then t-str = " По смене № " + string(X-Shift-Alone) + "  за период с " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
      When 4 then DO:
          if  tog-shift AND tog-shift-2 THEN
                t-str =
                " По смене № "  + string(X-Shift-Start)   +
                " на  " + string(X-Date-Start,"99/99/9999") .

          Else
                t-str =  (If X-TOG-Shift Then
                "Смены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)  Else "" ) +
                " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .

                End.
      When 5 OR when 6 then DO:
       CASE RAdio-TAsk:
            When 1 then  t-str = "Календарные сутки , За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
            when 2  then  t-str = "Сменные сутки , За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .

            When 3 then  t-str = "Сменные сутки,  За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") +
                                  " Смены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)   .
            When 4 then  t-str = " По смене № " + string(X-Shift-Alone) + " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .


       End case.
              End.
      When 7 then t-str = " По смене № " + string(X-Shift-Alone) + "  дата открытия " + string(X-Date-Start,"99/99/9999") .
      When 8 then DO:
                t-str =
                "Смены с "  + string(X-Shift-Start)   + " по "  + string(X-Shift-End)  +
                " За период с  " + string(X-Date-Start,"99/99/9999") + "  по " + string(X-Date-End,"99/99/9999") .
      End.
      When 9 then DO:
                t-str =
                "Период : за " +  string (entry ( (lookup(radio-period,{&radio-period-list-scr}) - 1)  , {&radio-period-list-scr} ) ) .
      End.


    End case.
    /*даты*/

     str1 = t-str.

    t-str = '' .
    if temp-param-goods = ""   Then str2 =" ".
    Else DO:
         run sel-x-selectgood  in this-procedure .
         str2 = Text-2 + ": "  + t-str .        /*товар*/.
         End.

    if temp-param-pay = ""   Then str3 =''.
       Else DO:
          If ( x-SET_val_TYPE = 0 and base-code=0)  Or x-SET_val_TYPE=1
            then  DO:
                  case X-SET_PAY_TYPE :
                    when 1 then str3 = Text-4 + ": "    +  "в {&abbr_rublevyh} ценах РЕАЛИЗАЦИИ".
                    when 2 then str3 = Text-4 + ": "    +  "в УЧЕТНЫХ {&abbr_rublevyh} ценах".
                    when 3 then str3 = Text-4 + ": "    +  "в {&abbr_rublevyh} ценах ДОКУМЕНТА".
                  end case.
                  End.
            else  DO:
                  case X-SET_PAY_TYPE :
                    when 1 then str3 = Text-4 + ": "    +  "в валютных ценах РЕАЛИЗАЦИИ".
                    when 2 then str3 = Text-4 + ": "    +  "в УЧЕТНЫХ валютных ценах".
                    when 3 then str3 = Text-4 + ": "    +  "в валютных ценах ДОКУМЕНТА".
                  end case.
                  End.
        End.

       /*цены*/
    if temp-param-obj = ""   Then str4 =''.
    Else do:
      t-str=''.
        /* снова формируем если 1 закладка */
        if temp-param-Alon then do:

        if SelectObject = {&all} THEN run sss in this-procedure .
        if SelectObject = {&obj-firm} THEN run sss in this-procedure .
        if SelectObject = {&obj-currency} then  run select-objects-proc in this-procedure .
        end.

        CAse SelectObject:
          When {&all} then t-str = " По всем объектам ".
          OTHERWISE DO:
              FOR each Obj-list :
                  FIND cli-obj WHERE cli-obj.obj-type = obj-list.obj-type  AND
                                     cli-obj.obj-code = obj-list.obj-code NO-LOCK .
              if LENGTH(t-str) <= {&max-len-str} then
                 t-str = t-str + {&new-line} + "     " + cli-obj.obj-name  + ' ' + obj-list.obj-type.
              End.
          End.
       End case.
       str4 = TEXT-1 + ": " + t-str.        /*объекты*/
       IF str-obj# <> "" Then
          str4 = str4  + {&new-line} + "Не включены в список : " + str-obj# .        /*объекты которые не попали*/
       IF str-obj2# <> "" Then
          str4 = str4   + {&new-line} +  "Нет информации о чеках на объектах : " + str-obj2# .        /*объекты которые не попали*/
       IF str-obj3# <> "" Then do:
          if not SelectObject = {&obj-firm} then do:
             str4 = str4   + {&new-line} +  "Не текущая фирма : " + str-obj3# .        /*объекты которые не попали*/
          end.
       end.
     End.

     /* Контрагенты */
     if temp-param-customer <> "" then do:
        t-str = "" .
              t-str = t-str + {&new-line} + text-5 + ": " .
                for each g#customer:
                    if LENGTH (t-str) >= 10000 then do:
                       t-str = trim( t-str , '...') .
                       t-str = t-str + '...' .
                    end.
                    else t-str = t-str + {&new-line} + "     " + g#customer.obj-name .
                End.
        if Radio-customer = 0 then Radio-customer = 1.
        if Radio-customer = 1 then t-str = t-str + {&new-line} + "все" .

        str4 = str4 + t-str .

     end.
     /* Счета */
     if temp-param-schet <> "" then do:
        t-str = "" .
              t-str = t-str + {&new-line} .
        if Radio-schet = 0 then Radio-schet = 1.

        t-str = t-str + {&new-line} + lkp-schet .

        str4 = str4 + t-str .

     end.

run set-attribute-list IN THIS-PROCEDURE (
{&KEEP-spis}  + "=" + string(keep-spis) + "," +
{&RADIO-CUSTOMER}  + "=" + string(RADIO-CUSTOMER) + "," +
{&RADIO-SCHET}     + "=" + string(RADIO-SCHET)    + "," +
{&EX-CURR-CODE}     + "=" + string(v-curr-code)
 ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Display-count s-object 
PROCEDURE Display-count :
if SelectGood = {&g-spis} then do:
        Assign
          goods-count = '(Выбрано ' + string(lns-cnt) + ' список)'
          Goods-Editor= s-notes
          .
end.
else do:
If can-find (First gds-list no-lock)
     then
        Assign
          goods-count = '(Выбрано ' + string(lns-cnt) + ' товаров)'
          Goods-Editor= s-notes
          .

     else
       Assign
       goods-count = ''
       Goods-Editor = ''
       .
 end.
  Display goods-count Goods-Editor with frame {&FRAME-NAME} .
  x-Goods-Editor = Goods-Editor.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Display-count-OTHER s-object 
PROCEDURE Display-count-OTHER :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 x-SelectGood = Integer(SelectGood:screen-value IN frame {&FRAME-NAME}).
   run sel-x-selectgood in this-procedure .
        if LENGTH (t-str) > {&max-len-str} then do:
          Assign  Goods-Editor = substring(T-str ,1, {&max-len-str}) + {&new-line} + "выборка для просмотра обрезана - слишком много записей " .
      end.
      else Assign  Goods-Editor = T-str  .

      Display goods-count Goods-Editor with frame {&FRAME-NAME} .
              x-Goods-Editor = Goods-Editor.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-date s-object 
PROCEDURE display-date :
/*Обработка первого параметра - DATE - как показывать блок с датами */
define buffer buf_shift-obj for ub.shift-obj .

case temp-param-date:
    when 0 then do: /*блок пустой*/
         disable Radio-task TEXT-3 Date-Alone BUTTON-shift Shift-Alone Date-End Date-Start  Shift-End Shift-Start TOG-Shift Radio-Period with frame {&FRAME-NAME} .
         hide RADIO-task TEXT-3  Date-Alone BUTTON-shift  Shift-Alone Date-End Date-Start Shift-End Shift-Start TOG-Shift BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame {&FRAME-NAME} .
         End.

    when 1 then do: /*1 дата*/
         enable TEXT-3  Date-Alone with frame {&FRAME-NAME} .
         display TEXT-3  Date-Alone with frame {&FRAME-NAME} .
         disable Radio-task Date-End Date-Start Shift-Alone  BUTTON-shift  Shift-End Shift-Start TOG-Shift  Radio-Period with frame {&FRAME-NAME} .
         hide  RADIO-task   Date-End Date-Start Shift-Alone  BUTTON-shift Shift-End Shift-Start TOG-Shift BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame {&FRAME-NAME} .
         End.

    when 2 then do: /*2 датЫ - период*/
         TEXT-3 = 'Выбор периода'.
         enable TEXT-3  Date-End Date-Start  with frame {&FRAME-NAME} .
         display TEXT-3  Date-End Date-Start  with frame {&FRAME-NAME} .
         disable Radio-task Date-Alone Shift-Alone  BUTTON-shift  Shift-End Shift-Start TOG-Shift  Radio-Period with frame {&FRAME-NAME} .
         hide   RADIO-task Date-Alone  Shift-Alone  BUTTON-shift Shift-End Shift-Start TOG-Shift BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame {&FRAME-NAME} .
         End.

    when 3 then do: /*2 даты и 1 смена*/
        TEXT-3 = 'Выбор смены'.
         enable  TEXT-3  Date-End Date-Start Shift-Start   Shift-Alone with frame {&FRAME-NAME} .
         disable Date-Alone Shift-End shift-start TOG-Shift RADIO-task  Radio-Period with frame {&FRAME-NAME} .
         hide    Date-Alone Shift-End shift-start  BUTTON-shift TOG-Shift RADIO-task BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period  in   frame {&FRAME-NAME} .
         display   TEXT-3  Date-End Date-Start Shift-Alone with frame {&FRAME-NAME} .

         End.

    when 4 then do: /*2 даты и 2 смены*/
         if TOG-Shift-2 THEN DO:
            disable Date-End  shift-end  with frame {&frame-name} .
         End.
         ELSE DO:
             enable Date-End shift-end  with frame {&frame-name}   .
         End.

         enable  TEXT-3   Date-Start  Shift-Start TOG-Shift with frame {&FRAME-NAME} .

         if not tog-shift then do:
            disable Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period with frame {&FRAME-NAME} .
            hide Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start  Radio-Period in frame {&FRAME-NAME} .
         end .
         else do:
            if tog-shift-2 then
                do:
                    disable shift-end BUTTON-Shift-end Date-End with frame {&FRAME-NAME} .
                    enable  Shift-start BUTTON-Shift-Start with frame {&FRAME-NAME} .
                    display Shift-start BUTTON-Shift-Start with frame {&FRAME-NAME} .
                    display TEXT-3 Date-Start Date-End Shift-Start Shift-End TOG-Shift with frame {&FRAME-NAME} .
                end.
            else
                do:
                    enable  Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start with frame {&FRAME-NAME} .
                    display Shift-start shift-end BUTTON-Shift-end BUTTON-Shift-Start with frame {&FRAME-NAME} .
                    display TEXT-3 Date-Start Date-End Shift-Start Shift-End TOG-Shift with frame {&FRAME-NAME} .
                end.
         end.
         display Date-Start Date-End TOG-Shift with frame {&FRAME-NAME} .

         disable Date-Alone BUTTON-shift Shift-Alone Radio-task  Radio-Period with frame {&FRAME-NAME} .
         hide    RADIO-task BUTTON-shift Date-Alone Shift-Alone   Radio-Period in frame {&FRAME-NAME} .

         /* проверка если смен нет на текущем объекте смены только там где по текущему объекту */
         if temp-param-obj = "" then do:
            if NOT can-find(first buf_shift-obj where buf_shift-obj.obj-code = v-cntxt-obj-code and
                                                  buf_shift-obj.obj-type = v-cntxt-obj-type no-lock ) then  DO:
                hide  Shift-Start TOG-Shift Shift-End TOG-Shift-2 BUTTON-Shift-end BUTTON-Shift-Start in frame {&FRAME-NAME} .
            end.
            else do:
              if tog-shift then do:
                 enable BUTTON-Shift-Start with frame {&frame-name} .
                  if not tog-shift-2 then
                    enable BUTTON-Shift-end  with frame {&frame-name} .
              end.
            end.
         End.
    End.
    when 5 then do: /*выбор задания*/
         enable  TEXT-3  Date-End Date-Start  RADIO-task  with frame {&FRAME-NAME} .
         display TEXT-3  Date-End Date-Start  RADIO-task  with frame {&FRAME-NAME} .
         disable Date-Alone BUTTON-shift  TOG-Shift   Radio-Period  with frame {&FRAME-NAME} .
         hide Date-Alone BUTTON-shift  Shift-Alone TOG-Shift  Radio-Period  in frame {&FRAME-NAME} .
         End.
    when 6 then do: /*календарные сутки сменные сутки задания*/

         enable  TEXT-3  Date-End Date-Start  RADIO-task  with frame {&FRAME-NAME} .
         display TEXT-3  Date-End Date-Start  RADIO-task  with frame {&FRAME-NAME} .
         disable Date-Alone TOG-Shift   Radio-Period with frame {&FRAME-NAME} .
         hide Date-Alone BUTTON-shift  Shift-Alone TOG-Shift  Radio-Period  in frame {&FRAME-NAME} .
         v-ok = RADIO-TASK:disable(radio-label("3", RADIO-TASK:radio-buttons)).
         v-ok = RADIO-TASK:disable(radio-label("4", RADIO-TASK:radio-buttons)).

         End.

    when 7 then do: /*1 даты и 1 смена*/
        TEXT-3 = 'Выбор смены'.
         enable  TEXT-3   Date-Start Shift-Start Shift-Alone with frame {&FRAME-NAME} .
         disable Date-Alone date-end Shift-End shift-start TOG-Shift RADIO-task  Radio-Period  with frame {&FRAME-NAME} .
         hide    Date-Alone date-end Shift-End shift-start TOG-Shift RADIO-task  Radio-Period  in   frame {&FRAME-NAME} .
         display   TEXT-3  Date-Start Shift-Alone  BUTTON-shift  with frame {&FRAME-NAME} .

         End.
    when 8 then do: /*2 даты и 2 смены смены по умолчанию */
         tog-shift = true .
         tog-shift-2 = false  .
         x-tog-shift = true .
         enable   Date-Start  Shift-Start
                  Date-End  shift-end
                  BUTTON-Shift-end BUTTON-Shift-Start  with frame {&FRAME-NAME} .
          display Shift-start shift-end
                  TEXT-3   Date-Start  Shift-Start Date-End Shift-End   with frame {&FRAME-NAME} .

         hide  Date-Alone BUTTON-shift  Shift-Alone Radio-task   tog-shift tog-shift-2    Radio-Period
                RADIO-task   BUTTON-shift Date-Alone Shift-Alone in frame {&FRAME-NAME} .
    End.
    when 9 then do: /* Относительные периоды*/
         TEXT-3 ='Выбор периода'.
         enable  RADIO-period  with frame {&FRAME-NAME} .
         display TEXT-3  RADIO-period  with frame {&FRAME-NAME} .
         disable Date-Alone BUTTON-shift  TOG-Shift   Radio-task  with frame {&FRAME-NAME} .
         hide Date-Alone BUTTON-shift  Shift-Alone TOG-Shift  Radio-task
              Date-Start  Date-End
              in frame {&FRAME-NAME} .
   End.
End case.

if choose-shift
and TOG-Shift:sensitive
then do :
/* почему-то на некоторых трейдах при попадение в тригер переменная сбрасывается поэтому положим сразу в 2 места */
  TOG-Shift:screen-value in frame F-Main = "yes" .
  TOG-Shift = yes.
  
  apply "value-changed" to TOG-Shift in frame F-Main .
end .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-goods s-object 
PROCEDURE display-goods :
    /*Обработка 2 параметра - ТОВАРЫ - как показывать блок с выбором товаров */
    define buffer buf_clob-bind for ub.clob-bind  .
    define variable v-temp-str as character no-undo .
    define variable J#         as integer   no-undo .
    define variable L#         as integer   no-undo .
    define variable RET#       as logical   no-undo .
    define variable R#         as integer   no-undo .

    IF  temp-param-goods = ""
        then 
    DO:
        disable TEXT-2 SelectGood BUTTON-gds button-keep-spis BUTTON-node BUTTON-prod BUTTON-node-2 BUTTON-prod-2 BUTTON-one Goods-count Goods-Editor  with frame {&FRAME-NAME} .
        hide TEXT-2 SelectGood  BUTTON-gds button-keep-spis  BUTTON-node BUTTON-prod  BUTTON-node-2 BUTTON-prod-2  BUTTON-one Goods-count Goods-Editor   in frame {&FRAME-NAME} .
    End.
    Else 
    DO:  
        enable TEXT-2 with frame {&FRAME-NAME} .
        display TEXT-2 SelectGood with frame {&FRAME-NAME} .
        { rep/radiohid.i temp-param-goods SelectGood}    /*disable radio-set по номеру */
        lns-cnt = 0 .
        for each gds-list :
            lns-cnt = lns-cnt + 1 .
        end.

        define variable v-i as integer no-undo .
        s-notes =  "" .
        for each gds-list-hist :
            v-i = v-i + 1 .
            s-notes = s-notes + {&new-line} + gds-list-hist.hist-mode +  gds-list-hist.des .
            if v-i > 10 then 
            do:
                s-notes = s-notes + " ... " .
                leave.
            end.
        end.

        if keep-spis <> "" then 
        do:
            find first buf_clob-bind no-lock where
                buf_clob-bind.field-name_ = keep-spis no-error .
            if available buf_clob-bind then 
            do:
                keep-spis = buf_clob-bind.field-name_ .
                s-notes =  substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
            end.
        end.

    run display-count-other in this-procedure .

  End.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-obj s-object 
PROCEDURE display-obj :
/*Обработка 3 параметра - ОБЬЕКТЫ - как показывать блок с выбором объектов */

define variable v-temp-str  as character no-undo .
define variable J#          as integer   no-undo .
define variable L#          as integer   no-undo .
define variable RET#        as logical   no-undo .
define variable R#          as integer   no-undo .

 IF temp-param-obj = ""
    then DO:
       disable TEXT-1 BUTTON-obj SelectObject Obj-count   with frame {&FRAME-NAME} .
       hide    TEXT-1  BUTTON-obj SelectObject Obj-count   in frame {&FRAME-NAME} .
    End.
    Else DO:  enable TEXT-1 with frame {&FRAME-NAME} .
              display TEXT-1  SelectObject Obj-count  with frame {&FRAME-NAME} .
/* disable radio-set по номеру */
    { rep/radiohid.i temp-param-obj SelectObject}
    if SelectObject = {&obj-choice} then do:
        if not can-find (first userobjs_temp-user-obj) then do:
         /*
         message 'заполняем из X-init_obj-list ' skip 'qqq' .
         */
          for each X-init_obj-list:
                create userobjs_temp-user-obj.
                assign
                  userobjs_temp-user-obj.obj-code = X-init_obj-list.obj-code
                  userobjs_temp-user-obj.obj-type = X-init_obj-list.obj-type
                .
          end.
         end.
    end.

     if (v-cntxt-obj-type = {&stock} and temp-param-obj-type = 'shop')
     or (v-cntxt-obj-type = {&shop}  and temp-param-obj-type = 'stock')
     then do:
        ret# = selectobject:disable(entry(3,selectobject:radio-buttons)).
        apply "value-changed" to selectobject in frame f-main.
        end.
     end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-pay s-object 
PROCEDURE display-pay :
/*Обработка 4 параметра - цены - как показывать блок  */

define variable v-temp-str  as character no-undo .
define variable J#          as integer   no-undo .
define variable L#          as integer   no-undo .
define variable RET#        as logical   no-undo .
define variable R#          as integer   no-undo .

IF temp-param-pay = "" then DO:
         disable   SET_PAY_TYPE   with frame {&FRAME-NAME} .
         hide  SET_PAy_TYPE  in frame {&FRAME-NAME} .
         SET_PAY_TYPE:screen-value IN frame {&FRAME-NAME} = "2".
         SET_PAY_TYPE = 2.
                        end.

   Else do:
         enable TEXT-4  SET_PAY_TYPE SET_val_TYPE with frame {&FRAME-NAME} .
         display TEXT-4 SET_PAY_TYPE with frame {&FRAME-NAME} .
         { rep/radiohid.i temp-param-pay SET_pay_TYPE}
         if Lookup(temp-param-pay, "{&p-cost}" ) > 0 Then
         Assign SET_PAY_TYPE:screen-value IN frame {&FRAME-NAME} = "2"
                SET_PAY_TYPE = 2.
         End.

IF temp-param-pay-hide = "" then DO:
         disable   SET_val_TYPE  with frame {&FRAME-NAME} .
         hide  SET_val_TYPE  in frame {&FRAME-NAME} .
                        end.

   Else do:
         enable  SET_val_TYPE with frame {&FRAME-NAME} .
         display TEXT-4  with frame {&FRAME-NAME} .
   /*disable radio-set по номеру */
    { rep/radiohid.i temp-param-pay-hide SET_val_TYPE}

         End.

 IF temp-param-pay = ""  And  temp-param-pay-hide = "" then DO:
         disable  TEXT-4 SET_PAY_TYPE SET_val_TYPE  with frame {&FRAME-NAME} .
         hide TEXT-4  SET_PAY_TYPE SET_val_TYPE  in frame {&FRAME-NAME} .
                        end.
   Else do:
         enable  TEXT-4   with frame {&FRAME-NAME} .
         display TEXT-4   with frame {&FRAME-NAME} .
         end.




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-RAdio-task s-object 
PROCEDURE display-RAdio-task :
Case RAdio-task:screen-value in frame {&FRAME-NAME} :
  When '1' then DO:
    TOG-Shift = False.
    Hide   Date-Alone Shift-Alone  BUTTON-shift   Shift-End Shift-Start  TOG-Shift in frame {&FRAME-NAME} .
    Display Date-End Date-Start with frame {&FRAME-NAME} .
    x-TOG-Shift = False.
                End.
  When '2' then DO:
    TOG-Shift=true.
    Hide    Date-Alone Shift-Alone  BUTTON-shift Shift-End Shift-Start  TOG-Shift in frame {&FRAME-NAME} .
    Display Date-End Date-Start with frame {&FRAME-NAME} .
    x-TOG-Shift = True.
                End.

  When '3' then DO:
      TOG-Shift=true.
      enable Date-End Date-Start  Shift-End Shift-Start with frame {&FRAME-NAME} .
      Hide   Date-Alone Shift-Alone    BUTTON-shift   TOG-Shift in frame {&FRAME-NAME} .
      Display Date-End Date-Start Shift-End Shift-Start with frame {&FRAME-NAME} .
      assign
      x-TOG-Shift = True.
                End.

  When '4' then DO:
       TOG-Shift=true.
       enable Date-End Date-Start  Shift-Alone with frame {&FRAME-NAME} .
       Hide   Date-Alone   Shift-End  BUTTON-shift  Shift-Start TOG-Shift in frame {&FRAME-NAME} .
       Display Date-End Date-Start  Shift-Alone  with frame {&FRAME-NAME} .
       assign Date-End Date-Start  Shift-Alone.
       assign Shift-End   = Shift-Alone
              Shift-Start = Shift-Alone
              x-Shift-End   = Shift-Alone
              x-Shift-Start = Shift-Alone
              Shift-start:screen-value = string(Shift-Alone)
              Shift-End:screen-value = string(Shift-Alone)
              .

       x-TOG-Shift = True.
                End.
  End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-radio-schet s-object 
PROCEDURE init-radio-schet :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define variable ll as integer no-undo .
define buffer buf_fin-schet for ub.fin-schet.

  if temp-param-schet = "" then do:
     hide Radio-schet in frame {&frame-name}
     {&List-schet} in frame {&frame-name} .
  end.
  else do:
    text-6 = temp-param-schet .
    display text-6 with frame {&frame-name} .
      if temp-param-schet-init <> "" then do:
         radio-schet = {&schet-one} .
      end.
      if temp-param-schet-hide <> "" then do:
         repeat ll = 1 to num-entries(temp-param-schet-hide) - 1 :
           if radio-schet = {&schet-one}  and entry(ll,temp-param-schet-hide) =  string( {&schet-one} )
              then message "Не верно заданы параметры для блока ВЫБОР СЧЕТА в вызывающей процедуре g- " view-as alert-box error .
           v-ok = radio-schet:disable ( radio-label(entry(ll,temp-param-schet-hide), radio-schet:radio-buttons)) .

           case integer (entry(ll,temp-param-schet-hide)) :
              when {&schet-one} then do:
                hide button-schet-one in frame {&frame-name} .
              end.
              when {&schet-choice} then do:
                hide button-schet in frame {&frame-name} .
              end.
              when {&schet-choice-val} then do:
                hide button-schet-val in frame {&frame-name} .
              end.
           end case.
         end.
         /* выставить на незадисаблиную строчку */
         repeat ll = 7 to 1 by -1 :
              if radio-schet <> {&schet-one} then do:
                  if lookup( string(ll) , temp-param-schet-hide) <> 0 then next.
                  radio-schet = ll .
              end.
         end.
                /* */

                case radio-schet :
                      when {&schet-choice} then do:
                          enable button-schet with frame {&frame-name} .
                          disable button-schet-one button-schet-val with frame {&frame-name} .
                      end.
                      when {&schet-one} then do:
                          enable button-schet-one with frame {&frame-name} .
                          disable button-schet button-schet-val with frame {&frame-name} .
                            if temp-param-schet-init <> "" and temp-param-schet-init <> ? then do:
                                  find first buf_fin-schet no-lock where
                                      buf_fin-schet.code-schet = integer (temp-param-schet-init) and
                                      buf_fin-schet.host-code  = v-cntxt-host-code-obj no-error .
                                      if available buf_fin-schet then
                                      assign
                                        schet-list = string(recid(buf_fin-schet))
                                      .
                            end.
                      end.
                      when {&schet-choice-val} then do:
                          enable button-schet-val with frame {&frame-name} .
                          disable button-schet-one button-schet with frame {&frame-name} .
                      end.

                end case.

                lkp-schet = temp-param-schet + " по : " +
                            radio-label(string(RADIO-schet) , radio-schet:radio-buttons)
                            + {&new-line} .

                define variable v-iii as integer no-undo .
                if schet-list <> ""
                   then do:
                      repeat v-iii = 1 to num-entries(schet-list) :
                        find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (entry(v-iii,schet-list))   no-error .
                        if available buf_fin-schet then
                           lkp-schet  = lkp-schet  + string( buf_fin-schet.code-schet) + ", " .
                      end.
                end .

                display lkp-schet with frame {&frame-name} .

      end.

      display radio-schet with frame {&frame-name} .
  end.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object 
PROCEDURE local-apply-layout :
define buffer buf_shift-obj for ub.shift-obj .

RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .
run take-var in this-procedure .
if temp-param-date = 10
then do :
  temp-param-date = 4 .
end .
Assign
 Date-Alone   = X-Date-Alone
 Date-End     = X-Date-End
 Date-Start   = X-Date-Start
 Goods-Editor = X-Goods-Editor
 SelectGood   = X-SelectGood
 SelectObject = X-SelectObject
 SET_PAY_TYPE = X-SET_PAY_TYPE
 SET_val_TYPE = X-SET_val_TYPE

 Shift-Alone  = X-Shift-Alone
 Shift-End    = X-Shift-End
 Shift-Start  = X-Shift-Start
 TOG-Shift    = X-TOG-Shift
 RADIO-task   = x-RADIO-task      .


 if (init-SET_PAY_TYPE <> 0 or init-SET_PAY_TYPE <> ?)  and (x-SET_PAY_TYPE = ? or x-SET_PAY_TYPE = 0) then do:
    SET_PAY_TYPE = init-SET_PAY_TYPE.
 end.
If NOT can-find (First gds-list no-lock)
     then lns-cnt = 0.


    If x-Date-Alone = date('') then  Date-Alone   = init-Date-Alone.
    If x-Date-End   = date('') then  Date-End     = init-Date-End  .
    If x-Date-Start = date('') then  Date-Start   = init-Date-Start.
    If x-Shift-alone = 0 then        Shift-alone  = init-shift-alone.
    If x-Shift-start = 0 then        Shift-start  = init-shift-start.
    If x-Shift-end = 0 then          Shift-end    = init-shift-end  .

    if  temp-param-date  = 9  and ( radio-period = ? or radio-period = "" ) then do:
        if temp-param-date-type-period <> ? then radio-period = temp-param-date-type-period.
    end.

   Assign
      RADIO-task = x-RADIO-task
      .
     if can-find(first buf_shift-obj where buf_shift-obj.obj-code = v-cntxt-obj-code and
                                       buf_shift-obj.obj-type = v-cntxt-obj-type no-lock ) then  DO:
        If temp-param-date = 4 then  tog-shift = true .
        If temp-param-date = 8 or temp-param-date = 7 then  assign
                                        tog-shift = true
                                        x-tog-shift = true
                                        .
     end.

      If temp-param-date < 5 OR
         temp-param-date = 7 Then
        Assign
        RAdio-task = 0
        RAdio-task:screen-value in frame {&frame-name}="".

      run val-shift    in this-procedure .
      run display-date in this-procedure .
      run verify-date  in this-procedure .
      If temp-param-date = 5  OR
         temp-param-date = 6
           Then   run display-radio-task in this-procedure .


      run display-goods in this-procedure .
      run val-goods in this-procedure .
      if temp-param-goods <> "" then do:
         run display-count-other in this-procedure .
      end.
      else
        hide goods-editor in frame {&frame-name}.

  run display-obj in this-procedure .
  run val-obj in this-procedure .

  run display-pay in this-procedure .
  run set_val in this-procedure .
  if selectobject = {&all} then run sss in this-procedure .
  if selectobject = {&obj-firm} then run sss in this-procedure .
  run verify-check-currency in this-procedure .
  run sel-customer in this-procedure  .
  if ref_date-end <> '':U then do:
    if not valid-handle(mi-ed_date-end-handle) then do:
      create menu-item mi-ed_date-end-handle
      assign
      label = entry(1, ref_date-end, {&delim-par})
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-end-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.

  if ref_date-alone <> '':U then do:
    if not valid-handle(mi-ed_date-alone-handle) then do:
      create menu-item mi-ed_date-alone-handle
      assign
      label = entry(1, ref_date-alone, {&delim-par})
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-alone-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.
  if ref_date-start <> '':U then do:
    if not valid-handle(mi-ed_date-start-handle) then do:
      create menu-item mi-ed_date-start-handle
      assign
      label = entry(1, ref_date-start, {&delim-par})
      name = 'mi-ed_date-alone'
      parent = menu-ed_date-start-handle
      triggers:
        on choose
          persistent run proc-mi-ed_date in this-procedure .
      end triggers.
    end.
  end.

 if params-only-mode  = {&lookup} then do:
    /* 1 page read-only */
    /*
    assign
      radio-task:read-only  = true
      date-alone:read-only  = true
      tog-shift-2:read-only = true
      tog-shift:read-only = true
      showcrsa:read-only  = true
      showcost:read-only  = true
      showsale:read-only  = true
      shift-alone:read-only = true
      shift-end:read-only   = true
      date-start:read-only  = true
      date-end:read-only     = true
      set_pay_type:read-only = true
      set_val_type:read-only = true
      selectgood:read-only   = true
      selectobject:read-only = true
      radio-customer:read-only = true
      radio-schet:read-only    = true
      tog-excel:read-only      = true
      tog-list-hist:read-only  = true
      .
      */
      disable
      radio-task
      date-alone
      tog-shift-2
      tog-shift
      showcrsa
      showcost
      showsale
      shift-alone
      shift-end
      date-start
      date-end
      set_pay_type
      set_val_type
      selectgood
      selectobject
      radio-customer
      radio-schet
      radio-period
      tog-excel
      tog-list-hist
      with frame {&frame-name} .

 end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable s-object 
PROCEDURE local-enable :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'enable':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:       Первый заход в форму
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc = my-handle.
 do with frame {&frame-name}:
      if not (v-cntxt-level = {&cntxt-firm}  or
              v-cntxt-level = {&cntxt-global} )  then do:
        assign
          SelectObject :radio-buttons =
              "Все по фирме" + {&comma-char} + {&obj-firm}
            + {&comma-char} + "Текущий" + {&comma-char} + {&obj-currency}
            + {&comma-char} + "Выборочно" + {&comma-char} + {&obj-choice}
            + {&comma-char} + "Все" + {&comma-char} + {&all}
        .
    end.
    else do:
        assign
          SelectObject :radio-buttons =
              "Все по фирме" + {&comma-char} + {&obj-firm}
            + {&comma-char} + "Выборочно" + {&comma-char} + {&obj-choice}
            + {&comma-char} + "Все" + {&comma-char} + {&all}
        .
        BUTTON-obj:ROW = 7.92 .
    end.
  end. /* do with frame */
{ gbl/basecode.i   v-cntxt-host-code-obj base-code }
run take-var in this-procedure .
run init-radio-schet in this-procedure  .
If temp-param-date = 10 then 
  tog-shift:screen-value in frame {&frame-name} = string(true) .

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
   if temp-param-obj <> ""  then do:
      if not (v-cntxt-level = {&cntxt-firm}  or
              v-cntxt-level = {&cntxt-global} )
              then    SelectObject =  {&obj-currency} .

      Display SelectObject with frame {&frame-name}.
      if SelectObject =  {&obj-choice} then do:
         empty temp-table userobjs_temp-user-obj.
      end.
      else do:
         { cmp/cr-objls.i v-cntxt-obj-type v-cntxt-obj-code  }
      end.

  end.
  If Make-Excel then DO:
     TOG-Excel = tRUE .
     Disable TOG-Excel  with frame {&frame-name}.
     DISPLAY TOG-Excel  with frame {&frame-name}.
     End.
     Else DO:
          Disable TOG-Excel  with frame {&frame-name}.
          Hide    TOG-Excel  in frame {&frame-name}.
          End.

  If Print-List-Hist then DO:
    TOG-List-hist = tRUE .
    ENABLE TOG-List-hist  with frame {&frame-name}.
    DISPLAY TOG-List-hist  with frame {&frame-name}.
  End.
  Else DO:
    Disable TOG-List-hist  with frame {&frame-name}.
    Hide    TOG-List-hist  in frame {&frame-name}.
  End.

  If Show-Cost then DO:
    Showcost = Show-cost.
     enable showcost  with frame {&frame-name}.
     DISPLAY showcost  with frame {&frame-name}.
     End.
  If Show-Crsa then DO:
    Showcrsa = Show-crsa.
     enable showcrsa  with frame {&frame-name}.
     DISPLAY showcrsa  with frame {&frame-name}.
     End.
  If Show-sale then DO:
    Showsale = Show-sale.
     enable showsale  with frame {&frame-name}.
     DISPLAY showsale  with frame {&frame-name}.
     End.

    IF Name-Sale-price <> "" THEN DO :
       define variable str as character no-undo .
       str = SET_PAY_TYPE:radio-buttons IN frame {&FRAME-NAME}.
       str = entry(1,str) + ","  + entry(2,str) + "," + entry(3,str) + ","+ entry(4,str) + "," + Name-Sale-price + "," + entry(6,str).
       SET_PAY_TYPE:radio-buttons IN frame {&FRAME-NAME} = str.
       showsale:label = Name-Sale-price .
     end.
      if (init-SET_val_type <> 0)
      and set_val_type:sensitive in frame {&frame-name}
      and set_val_type:visible in frame {&frame-name}
      then do:
        assign
        set_val_type:screen-value = string(init-SET_val_type)
        no-error .
      end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE make-6-gds-list s-object 
PROCEDURE make-6-gds-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 define buffer buf-goods for ub.goods.
 if X-SelectGood = {&g-grp-prod} Then do:
  run set-cursor IN adm-broker-hdl ("WAIT").
  /* создание списка */
  for each gds-list  :
    delete gds-list.
  End.

      for each g#cli no-lock :
        for each tmp#grp no-lock :
          for each buf-goods where
              buf-goods.prod-type = g#cli.obj-type and
              buf-goods.prod-code = g#cli.obj-code and
              ( trim(buf-goods.grp-name)  begins trim(tmp#grp.grp-name) )
              no-lock :
                 if not can-find(first gds-list where gds-list.gds-code= buf-goods.gds-code) then  do:
                    create gds-list.
                    BUFFER-copy buf-goods TO gds-list  no-error  .
                 End.
           End.
        End.
      End.
    RUN set-cursor IN adm-broker-hdl ("").
 End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE return-var s-object 
PROCEDURE return-var :
/*------------------------------------------------------------------------------
  Purpose:    передать введенные параметры во внешний фрайм
 4 Строки которые идут в  preview и в шапку отчета как параметры выбора
------------------------------------------------------------------------------*/
def output parameter param-1 as char.
/*------------------------------------------------------------------------------*/
param-1 = 'qqqq'.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-customer s-object 
PROCEDURE sel-customer :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
  if temp-param-customer = "" then do:
     hide Radio-customer in frame {&frame-name}
     customer-name text-5 rect-7 in frame {&frame-name} .
  end.
  else do:
    text-5 = temp-param-customer .
    display text-5 with frame {&frame-name} .
  end.
  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-x-SelectGood s-object 
PROCEDURE sel-x-SelectGood :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define variable grp_name    as char. /*inc*/
define buffer buf_gds-grp for ub.gds-grp .

define variable my-c as int no-undo.
IF temp-param-goods <> "" THEN DO:
        Case x-SelectGood :
          When {&g-all} then t-str = " По всем товарам ".
          When {&g-grp} then DO:
              t-str = " По группам "  .
                        For each  tmp#grp :
                             delete tmp#grp.
                        End.

                        define variable v-ind as integer   no-undo .
                        Repeat v-ind = 1 To num-entries( gdsgrp_recids )
                        :

                              find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                              RUN grplib-get-full-name in this-procedure( input buf_gds-grp.node-code, output Grp_Name ).
                                if Grp_Name <> ? Then  if LENGTH(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + Grp_Name .
                                Create tmp#grp.
                                Assign tmp#grp.node-code = buf_gds-grp.node-code
                                       tmp#grp.grp-name = Grp_Name
                                       tmp#grp.is-term = buf_gds-grp.is-term
                                       tmp#grp.lvl-num = buf_gds-grp.lvl-num
                                       .
                            end.
                if num-entries( gdsgrp_recids ) > 0 THEN
                   goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп " .
                   ELSE goods-count = "НЕ выбрано !!!".
              End.
          When {&g-prod} then DO:
              t-str = ''.
              t-str = " По производителям " .
               my-c = 0.
                for each g#cli no-lock:
                    if LENGTH(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + g#cli.obj-name .
                    my-c =  my-c + 1 .
                End.
                if my-c > 0 THEN
                   goods-count = "выбрано " + String(my-c) .
                   ELSE goods-count = "НЕ выбрано !!!".
              END.
          When {&g-choice} then DO:
                        if can-find (first gds-list no-lock ) then DO:
                            t-str = " По списку товаров " +  s-Notes.
                            goods-count = "выбрано " + String(lns-cnt) .
                            End.
                         Else Assign goods-count = "НЕ выбрано !!!" t-str = "" lns-cnt = 0 .

                       End.
          When  {&g-spis}  then DO:

              if  keep-spis <> "" then DO:
                  t-str = s-Notes.
                  goods-count = "выбрано списков : " + String(lns-cnt) .
                  End.
                Else Assign goods-count = "НЕ выбрано !!!" t-str = "" lns-cnt = 0 .

              End.

          When {&g-one} then DO:
                  find first gds-list no-lock no-error.
                   if available gds-list THEN  Assign t-str = " " +  gds-list.gds-name goods-count = "выбран 1 товар".
                                          ELSE Assign t-str = "" goods-count = "НЕ выбрано !!!" lns-cnt = 0 .
                 END.
          When {&g-grp-prod} then DO:
              t-str = " По группам "  .
                        For each  tmp#grp :
                             delete tmp#grp.
                        End.
                        Repeat v-ind = 1 To num-entries( gdsgrp_recids ):
                            find first buf_gds-grp WHERE recid ( buf_gds-grp ) = integer ( Entry(v-ind,gdsgrp_recids )) NO-LOCK.
                              run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output Grp_Name ).
                                if Grp_Name <> ? Then if LENGTH(t-str) <= {&max-len-str} then t-str = t-str + {&new-line} + "     " + Grp_Name .
                                Create tmp#grp.
                                Assign tmp#grp.node-code = buf_gds-grp.node-code
                                       tmp#grp.grp-name = Grp_Name
                                       tmp#grp.is-term = buf_gds-grp.is-term
                                       tmp#grp.lvl-num = buf_gds-grp.lvl-num
                                       .
                            end.

              t-str = t-str + {&new-line} +  " По производителям " .
               my-c = 0.
                for each g#cli no-lock:
                    t-str = t-str + {&new-line} + "     " + g#cli.obj-name no-error .
                    my-c =  my-c + 1 .
                End.


                if num-entries( gdsgrp_recids ) > 0  and my-c > 0 THEN DO:
                   goods-count = "выбрано " + string(num-entries( gdsgrp_recids )) + " групп "
                     + string(my-c) + " производителей " .


                   End.

                   ELSE goods-count = "НЕ выбрано !!!".
              End.

        End case.
 END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-keep-spis s-object 
PROCEDURE select-keep-spis :
/* -----------------------------------------------------------
  Purpose: можно запустить принудительно со второй закладки

  Пример :
      { rep/get-link.i 'State':U }
       run select-keep-spis in State-source ("ttt") .



  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-keep-spis as character no-undo .

define buffer buf_clob-bind for ub.clob-bind  .
keep-spis = p-keep-spis.
find first buf_clob-bind no-lock where
          buf_clob-bind.field-name_ = keep-spis no-error .

  if available buf_clob-bind then do:
    keep-spis = buf_clob-bind.field-name_ .
    lns-cnt = 1 .
    s-notes = substitute("Хранимый Файл списка : &1 &2", buf_clob-bind.field-name, buf_clob-bind.descr ).
  end.
  else do:
    keep-spis = "".
    lns-cnt = 0 .
    s-notes = " " .
  end.
  run display-count       in this-procedure .
  run display-count-other in this-procedure .
  selectgood    = {&g-spis} .
  x-selectgood  = {&g-spis} .
  run val-goods in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-proc s-object 
PROCEDURE select-objects-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-ii as integer   no-undo .
  def buffer cli-obj  for ub.clients .

  { rep/s-selobj.i }

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-radio-period s-object 
PROCEDURE select-radio-period :
/* -----------------------------------------------------------
  Purpose: можно запустить принудительно со второй закладки

  Пример :
      { rep/get-link.i 'State':U }
       run select-radio-period in State-source ({&period-type-quarter}) .

  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-radio-period as character no-undo .
  radio-period = p-radio-period .
display radio-period with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-Radio-schet s-object 
PROCEDURE select-Radio-schet :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define buffer buf_fin-schet for ub.fin-schet.
assign frame {&frame-name}
  RADIO-schet
.
lkp-schet = temp-param-schet + " по : " +
            radio-label(string(RADIO-schet  ) , radio-schet:radio-buttons)
            .

define variable v-iii as integer no-undo .

case radio-schet :
    when {&schet-choice} then do:
      enable button-schet with frame {&frame-name} .
      disable button-schet-one button-schet-val with frame {&frame-name} .
      apply "CHOOSE" to button-schet IN  frame {&frame-name} .
      lkp-schet = lkp-schet + {&new-line}  .
          repeat v-iii = 1 to num-entries(schet-list) :
            find first buf_fin-schet no-lock where    recid(buf_fin-schet) = integer (entry(v-iii,schet-list))   no-error .
            if available buf_fin-schet then
                lkp-schet = lkp-schet  + string( buf_fin-schet.code-schet) + ", ".
          end.
    end.
    when {&schet-one} then do:
      enable button-schet-one with frame {&frame-name} .
      disable button-schet button-schet-val with frame {&frame-name} .
      apply "CHOOSE" to button-schet-one IN  frame {&frame-name} .

    end.
    when {&schet-choice-val} then do:
      enable button-schet-val with frame {&frame-name} .
      disable button-schet-one button-schet with frame {&frame-name} .
      apply "CHOOSE" to button-schet-val IN  frame {&frame-name} .

    end.
    otherwise do:
    if button-schet-val:visible then  disable button-schet-val with frame {&frame-name} .
    if button-schet-one:visible then  disable button-schet-one with frame {&frame-name} .
    if button-schet    :visible then  disable button-schet with frame {&frame-name} .
    end.

end case.

display lkp-schet with frame {&frame-name} .
run new-state("RADIO-SCHET="  + string(Radio-schet)) .
case radio-schet:
  when {&schet-all-firm}
  or
  when {&schet-firm}
  or
  when {&schet-choice}
  or
  when {&schet-no-rubl}
  or
   /*пока еще не нажата клавиша выбора счета*/
  when {&schet-one}
  then do:
    if ref_date-start <> '':u
    and entry(2, ref_date-start, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-start, {&delim-par}) = "ext-type-stat-start".
      entry(4, ref_date-start, {&delim-par}) = "".
    end.
    if ref_date-end <> '':u
    and entry(2, ref_date-end, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-end, {&delim-par}) = "ext-type-stat-end".
      entry(4, ref_date-end, {&delim-par}) = "".
    end.
    if ref_date-alone <> '':u
    and entry(2, ref_date-alone, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-alone, {&delim-par}) = "ext-type-stat-start".
      entry(4, ref_date-alone, {&delim-par}) = "".
    end.
  end.
  when {&schet-one}
  then do:
  end.
  when {&schet-rubl}
  or when {&schet-choice-val}
  then do:
    if ref_date-start <> '':u
    and entry(2, ref_date-start, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-start, {&delim-par}) = "currency-start".
      if radio-schet = {&schet-rubl} then  do:
        entry(4, ref_date-start, {&delim-par}) = "0".
      end.
      else do:
        entry(4, ref_date-start, {&delim-par}) = entry(2, schet-list, "=").
      end.
    end.
    if ref_date-end <> '':u
    and entry(2, ref_date-end, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-end, {&delim-par}) = "currency-end".
      if radio-schet = {&schet-rubl} then  do:
        entry(4, ref_date-end, {&delim-par}) = "0".
      end.
      else do:
        entry(4, ref_date-end, {&delim-par}) = entry(2, schet-list, "=").
      end.
    end.
    if ref_date-alone <> '':u
    and entry(2, ref_date-alone, {&delim-par}) = "finsttms":U then do:
      entry(3, ref_date-alone, {&delim-par}) = "currency-end1".
      if radio-schet = {&schet-rubl} then  do:
        entry(4, ref_date-alone, {&delim-par}) = "0".
      end.
      else do:
        entry(4, ref_date-alone, {&delim-par}) = entry(2, schet-list, "=").
      end.
    end.
  end.
end case.


end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-radio-schet-no-apply s-object 
PROCEDURE select-radio-schet-no-apply :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

define buffer buf_fin-schet for ub.fin-schet.
assign frame {&frame-name}
  RADIO-schet
.
lkp-schet = temp-param-schet + " по : " +
            radio-label(string(RADIO-schet  ) , radio-schet:radio-buttons)
            .

define variable v-iii as integer no-undo .

    case radio-schet :
       when {&schet-choice} then do:
          enable button-schet with frame {&frame-name} .
          disable button-schet-one button-schet-val with frame {&frame-name} .
       end.
       when {&schet-one} then do:
          enable button-schet-one with frame {&frame-name} .
          disable button-schet button-schet-val with frame {&frame-name} .

       end.
       when {&schet-choice-val} then do:
          enable button-schet-val with frame {&frame-name} .
          disable button-schet-one button-schet with frame {&frame-name} .
       end.
       otherwise do:
        if button-schet-val:visible then  disable button-schet-val with frame {&frame-name} .
        if button-schet-one:visible then  disable button-schet-one with frame {&frame-name} .
        if button-schet    :visible then  disable button-schet with frame {&frame-name} .
       end.

    end case.

    display lkp-schet with frame {&frame-name} .
    run new-state ( "RADIO-SCHET="  + string(Radio-schet) ) .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select1 s-object 
PROCEDURE select1 :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
Link# = true.
  run select-page in state-source ( 1 ).
  run local-apply-layout in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Set_VAl s-object 
PROCEDURE Set_VAl :
/*------------------------------------------------------------------------------
  Purpose: Перемаргивание параметром SET_VAL_TYPE
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   IF SET_PAY_TYPE:screen-value IN frame {&FRAME-NAME} = "3"  /*sale*/
       then   enable SET_VAL_TYPE with frame {&FRAME-NAME} .

   IF SET_PAY_TYPE:screen-value IN frame {&FRAME-NAME} = "2"  /*cost*/
       then   enable SET_VAL_TYPE with frame {&FRAME-NAME} .

   IF SET_PAY_TYPE:screen-value IN frame {&FRAME-NAME} = "1"  /*crsa*/
       THEN   disable SET_VAL_TYPE with frame {&FRAME-NAME} .

   IF temp-param-pay = "" AND  temp-param-pay-hide = ""   THEN DO:
      disable SET_VAL_TYPE with frame {&FRAME-NAME} .
      hide  SET_val_TYPE  in frame {&FRAME-NAME} .
      End.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sss s-object 
PROCEDURE sss :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 /* SelectObject */

define buffer buf_clients for ub.clients .
define buffer cli-obj      for ub.clients .
define buffer buf_user-obj for ub.user-obj .
define buffer buf_db for ub.db .
define buffer buf_store for ub.store .
define buffer buf_shop for ub.shop .
define buffer buf_sysconf for ub.sysconf .

 If NOT (temp-param-obj = '*'
    OR Lookup(string({&o-all}),replace(temp-param-obj,"!","")) > 0
    OR Lookup(string({&o-firm}),replace(temp-param-obj,"!","")) > 0  ) then DO:
   message "Выполнить невозможно, смените текущий объект !" view-as alert-box error .
  return error.
 End.
  FOR EACH obj-list :  delete obj-list.  END.
  assign
    str-obj#  = ''
    str-obj2# = ''
    str-obj3# = ''
  .

  for each buf_user-obj no-lock
    where buf_user-obj.db-num  = v-cntxt-db-num
      and buf_user-obj.user-id = v-cntxt-userid ,
   each cli-obj no-lock
    where cli-obj.obj-type = buf_user-obj.obj-type
      and cli-obj.obj-code = buf_user-obj.obj-code
      and ( ( cli-obj.db-num = v-cntxt-db-num ) or v-cntxt-db-num = 0 )
  :

          find first buf_clients no-lock
            where buf_clients.obj-type = buf_user-obj.obj-type
              and buf_clients.obj-code = buf_user-obj.obj-code
            .
          if buf_clients.stts <> 0 then next. /* удаленным здесь не место */

          if verify-send-check and buf_clients.db-num <> v-cntxt-db-num  and v-all-object = false  then do:
             find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
             if buf_db.send-check = false then do:
              str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
              next.
            end.
          end.


          if temp-param-obj-type = 'shop':U and v-all-object = false  then do:
              if buf_user-obj.obj-type = {&stock} then DO:
                str-obj# = str-obj#  +  " " + buf_clients.obj-name + ",".
                NEXT.
              End.
          End.

          if temp-param-obj-type = 'stock':U and v-all-object = false then do:
              if buf_user-obj.obj-type = {&shop} then DO:
                str-obj# = str-obj#  +  " " +  buf_clients.obj-name + "," .
                next.
              end.
          end.

        CASE buf_user-obj.obj-type:
            when {&stock} then do:
                    find first buf_store WHERE buf_store.obj-code = buf_user-obj.obj-code NO-LOCK.
                    if SelectObject = {&obj-firm} and v-all-object = false then do:
                      if buf_store.host-code <> v-cntxt-host-code-obj then do:
                          str-obj3# = str-obj3#  + " " + buf_clients.obj-name + ",".
                          next.
                      end.
                    end.

                    FIND FIRST buf_sysconf No-LOCK where buf_sysconf.host-code = buf_store.host-code No-ERROR.
                    Find first buf_clients no-lock where
                                buf_clients.obj-type = buf_user-obj.obj-type AND
                                buf_clients.obj-code = buf_user-obj.obj-code No-ERROR.

                    if buf_sysconf.base-code = base-code then
                        do:
                          { cmp/cr-objls.i buf_user-obj.obj-type buf_user-obj.obj-code  }
                        end.
                        else do :
                        if v-all-object = false then  str-obj# = str-obj#  +  " "  +  buf_clients.obj-name +  "," .
                            else do:
                              { cmp/cr-objls.i buf_user-obj.obj-type buf_user-obj.obj-code  }
                            end.
                        end.

            end.
            when {&shop} then  do:
                    find first buf_shop where buf_shop.obj-code = buf_user-obj.obj-code no-lock.
                    if selectobject = {&obj-firm} and v-all-object = false then do:
                      if buf_shop.host-code <> v-cntxt-host-code-obj then do:
                          str-obj3# = str-obj3#  + " " + buf_clients.obj-name + "," .
                          next.
                      end.
                    end.
                    find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                    find first buf_clients no-lock where
                                buf_clients.obj-type = buf_user-obj.obj-type and
                                buf_clients.obj-code = buf_user-obj.obj-code no-error.
                    if buf_sysconf.base-code = base-code then
                        do:
                            { cmp/cr-objls.i buf_user-obj.obj-type buf_user-obj.obj-code  }
                        end.
                        else do:
                            if v-all-object = false then   str-obj# = str-obj#  +  " " +  buf_clients.obj-name +  "," .
                                else do:
                                  { cmp/cr-objls.i buf_user-obj.obj-type buf_user-obj.obj-code  }
                                end.
                        end.
                end.
        END CASE.

 END.
 END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  define variable fl as integer   no-undo .

   /* Date-Start:screen-value in frame {&frame-name}  = String(x-Date-Start).*/
 /* { rep/get-link.i 'Record':U } */

  assign
    fl = 0
  .
  /*Это безобразие нужно для обработки изменений на 2 закладке */
  RUN get-attribute IN THIS-PROCEDURE ('UIB-MODE').
  IF RETURN-VALUE NE "DESIGN" THEN DO:
    DEFINE VARIABLE source-str AS CHARACTER.
    RUN get-link-handle IN adm-broker-hdl ( THIS-PROCEDURE, 'Record':U , OUTPUT source-str ) no-error.

    assign
      State-source = WIDGET-HANDLE ( source-str )
    .

    if valid-handle ( state-source ) then do:
      run return-var in state-source no-error.

    end.

    if date-start <> x-date-start
    or date-end <> x-date-end
    then do:
      assign
        FL = 1
      .
    end.
  END.


  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
    when "link-changed":U then  DO:
        IF FL = 0 Then DO:
            run assign-frame in this-procedure  .
            run local-apply-layout in this-procedure .
            end.
         else do:
            run local-apply-layout in this-procedure .
            run assign-frame in this-procedure  .
            end.
         run take-var in this-procedure .
    end.


  END CASE.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE take-var s-object 
PROCEDURE take-var :
{ rep/get-link.i 'Record':U }
   Run get-var in State-source (OUTPUT temp-str,
    OUTPUT temp-param-date,
    OUTPUT temp-param-date-type-period,
    OUTPUT temp-param-goods,
    OUTPUT temp-param-obj,
    OUTPUT temp-param-pay,
    OUTPUT temp-param-pay-hide,
    OUTPUT temp-param-obj-type,
    OUTPUT temp-param-Alon  ,
    OUTPUT temp-param-customer,
    OUTPUT temp-param-customer-type,
    OUTPUT temp-param-schet        ,
    OUTPUT temp-param-schet-hide   ,
    OUTPUT temp-param-schet-init   ,
    OUTPUT temp-param-schet-mode ,
    output v-all-object
    ).

  define variable temp-param-time   as character no-undo .
  define variable temp-param-goods1 as character no-undo .
  
  define variable ii                as integer   no-undo .
  temp-param-goods-choose = "" .
  
  if temp-param-goods <> "" then 
  do:
    if num-entries(temp-param-goods,":") > 1 then 
    do:
      do ii = 1 to num-entries (temp-param-goods,","):
        temp-param-time = entry (ii,temp-param-goods,",") .
        if num-entries(temp-param-time,":") > 1 then 
        do:
          temp-param-goods1 = temp-param-goods1 + "," + entry(1,temp-param-time,":") .
          temp-param-goods-choose = temp-param-goods-choose + "," + entry(2,temp-param-time,":") .
        end.
        else 
        do:
          temp-param-goods1 = temp-param-goods1 + "," + temp-param-time .
        end.
      end.
    end.
  end.
  if temp-param-goods1 <> "" then temp-param-goods = trim(temp-param-goods1,",") .
  temp-param-goods-choose = trim(temp-param-goods-choose,",") .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-goods s-object 
PROCEDURE val-goods :
If temp-param-goods <> "" THEN DO:
 assign
  goods-count  = ''
  Goods-Editor = ''
  .
Case Integer(SelectGood:screen-value IN frame {&FRAME-NAME}):
    When {&g-all} then DO:
       Disable RECT-node RECT-node-2 BUTTON-gds button-keep-spis BUTTON-node BUTTON-prod BUTTON-one BUTTON-prod-2 BUTTON-node-2 with frame {&FRAME-NAME} .
       Goods-Editor = " По всем товарам ".
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.

       End.
    When {&g-grp} then DO:
       Disable RECT-node RECT-node-2 BUTTON-gds button-keep-spis BUTTON-prod  BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame {&FRAME-NAME} .
       enable BUTTON-node  with frame {&FRAME-NAME} .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.

       End.
    When {&g-prod} then DO:
       Disable RECT-node RECT-node-2 BUTTON-gds button-keep-spis BUTTON-node   BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame {&FRAME-NAME} .
       enable BUTTON-prod  with frame {&FRAME-NAME} .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.

       End.
    When {&g-choice} then DO:
       Disable RECT-node RECT-node-2 BUTTON-node BUTTON-prod button-keep-spis BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame {&FRAME-NAME} .
       enable BUTTON-gds with frame {&FRAME-NAME} .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.

        END.
    When {&g-spis} then DO:
       Disable RECT-node RECT-node-2 BUTTON-node button-gds BUTTON-prod BUTTON-one BUTTON-prod-2 BUTTON-node-2  with frame {&FRAME-NAME} .
       enable button-keep-spis with frame {&FRAME-NAME} .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.

       END.
    When {&g-one} then DO:
       Disable RECT-node RECT-node-2  BUTTON-node BUTTON-prod  BUTTON-gds button-keep-spis BUTTON-prod-2 BUTTON-node-2 with frame {&FRAME-NAME} .
       enable BUTTON-one with frame {&FRAME-NAME} .
       RECT-node:bgcolor = 8.
       RECT-node-2:bgcolor = 8.
       End.
    When {&g-grp-prod} then DO:
       Disable RECT-node RECT-node-2 BUTTON-one BUTTON-node BUTTON-prod  BUTTON-gds button-keep-spis with frame {&FRAME-NAME} .
       enable BUTTON-prod-2 BUTTON-node-2  with frame {&FRAME-NAME} .

       End.

  End case.
  enable goods-count   Goods-Editor  with frame {&FRAME-NAME}.
  display goods-count   Goods-Editor with frame {&FRAME-NAME}.
End.
  Else  hide goods-count Goods-Editor in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-obj s-object 
PROCEDURE val-obj :
If SelectObject:screen-value IN FRAME {&FRAME-NAME} = {&obj-choice}
    then  enable BUTTON-obj with frame {&FRAME-NAME} .
    Else Disable BUTTON-obj with frame {&FRAME-NAME} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-shift s-object 
PROCEDURE val-shift :
define buffer buf_shift-obj for ub.shift-obj .
if TOG-Shift:screen-value IN frame {&FRAME-NAME} = string(true)  Then DO:

    TOG-Shift = true .
    if tog-shift-2 then do:
      enable  shift-start tog-shift-2 with frame {&frame-name} .
      display shift-start tog-shift-2 with frame {&frame-name} .
      disable button-shift-end with frame {&frame-name} .
    end.
    else do:
      enable shift-end shift-start tog-shift-2 with frame {&frame-name} .
      display shift-end shift-start tog-shift-2 with frame {&frame-name} .
    end.

    if  can-find(first buf_shift-obj where
                       buf_shift-obj.obj-code = v-cntxt-obj-code and
                       buf_shift-obj.obj-type = v-cntxt-obj-type no-lock )
        then do:
          enable  button-shift-start button-shift-end  with frame {&frame-name} .
          display button-shift-start button-shift-end  with frame {&frame-name} .

           if tog-shift-2 then do:
              disable  button-shift-end with frame {&frame-name} .
           end.
           else do:
              enable  button-shift-end with frame {&frame-name} .
           end.
              display button-shift-end with frame {&frame-name} .
        end.
 End.

 Else DO:
  Tog-Shift-2 = False.
  Tog-Shift   = False.
  enable date-end with frame {&FRAME-NAME} .
  disable Shift-End Shift-Start Tog-Shift-2 button-shift-end button-shift-start with frame {&FRAME-NAME} .
  display Shift-End Shift-Start Tog-Shift-2 date-end with frame {&FRAME-NAME} .
  hide Shift-End Shift-Start Tog-Shift-2 button-shift-start button-shift-end in frame {&FRAME-NAME} .
 End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-check s-object 
PROCEDURE verify-check :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_clients for ub.clients .
define buffer buf_db for ub.db .
/*--проверка чеков на текущем ----------------------------------------------------------------------------------------- */
    Find first buf_clients no-lock where
                                                buf_clients.obj-type = v-cntxt-obj-TYPE AND
                                                buf_clients.obj-code = v-cntxt-obj-CODE No-ERROR.

             If Verify-send-check and buf_Clients.db-num <> v-cntxt-db-num  THEN DO:
                Find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                    if buf_db.send-check = false then DO:
                                                MESSAGE 'Нельзя выбрать текущий объект !' view-as alert-box error.
                                                run verify-check-currency in this-procedure .
                                                End.
                    else do:
                      { cmp/cr-objls.i buf_clients.obj-type buf_clients.obj-code  }

                    end.
                END.
                else do:
                  { cmp/cr-objls.i buf_clients.obj-type buf_clients.obj-code  }
                end.
/*---------------------------------------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-check-currency s-object 
PROCEDURE verify-check-currency :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_clients for ub.clients .
define buffer buf_db for ub.db .
if selectobject = {&obj-currency} then do:
    find first buf_clients no-lock where  buf_clients.obj-type = v-cntxt-obj-type and
                                      buf_clients.obj-code = v-cntxt-obj-code no-error.
             if verify-send-check and buf_clients.db-num <> v-cntxt-db-num  then do:
                find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                    if buf_db.send-check = false then do:
                      str-obj2# = str-obj2#  + " " + buf_clients.obj-name + ",".
                      assign selectobject = {&all} .
                      display selectobject with frame {&frame-name} .
                      disable button-obj   with frame {&frame-name} .
                      run sss in this-procedure .
                      return error.
                      end.
             end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-date s-object 
PROCEDURE verify-date :
if Date(Date-End:screen-value In frame {&frame-name}) < DATE(Date-Start:screen-value In frame {&frame-name}) then DO:
   message "Интервал дат введен неверно !" view-as alert-box error TITLE "О Ш И Б К А !!!".
   Return error.
End.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-obj s-object 
PROCEDURE verify-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
if temp-param-obj <> "" Then DO:
   if selectobject = {&obj-choice} then do:
      my-request = true .
      run select-objects-proc.
   end.
  if not can-find (first obj-list no-lock) then do:
      message "Не выбран объект !" skip
              "Объекты не включенные в список" str-obj#    skip
              str-obj2#   skip
              str-obj3#   skip
              view-as alert-box error.
  return error.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-shift s-object 
PROCEDURE verify-shift :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
/* в 8 версии нет shift-obj */

def input parameter date1 as date no-undo.
def input parameter Shift1 as int no-undo.

define buffer buf_shift-obj for ub.shift-obj .

if NOT can-find
(first buf_Shift-obj where  buf_Shift-obj.shift-num = Shift1
                    AND buf_Shift-obj.shift-date = date1
                    AND can-find (first obj-list where obj-list.obj-code = buf_shift-obj.obj-code
                                                   AND obj-list.obj-type = buf_shift-obj.obj-type)=true)
  THEN DO:
   Bell.
   message "Нет смены " shift1 date1 " !" view-as alert-box error TITLE "О Ш И Б К А !!!".
   Return error.
   End.
   else do:
     x-tog-shift = true .
   end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


FUNCTION stat-line RETURNS CHARACTER(input p-status-chr as character):
/*функция возвращает строку для message и для dsp-rs*/
DEFINE VARIABLE var-stat-line as character no-undo .

CASE p-status-chr:
  when {&all} then do:
    assign
    var-stat-line = "(текущие и неактивные товары)"
    .
  end.
  when {&current} then do:
    assign
    var-stat-line = "(текущие товары)"
    .
  end.
  when {&deleted} then do:
    assign
    var-stat-line = "(неактивные товары)"
    .
  end.
END CASE.
return var-stat-line .
END.

