&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_thbj-attr FOR thbj-attr.
DEFINE BUFFER X_shop FOR shop.
DEFINE BUFFER X_store FOR store.
DEFINE BUFFER X_sysconf FOR sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибута магазина (thbj-attr) "gds-ref"

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/16/04
Author: Bakhtadze Natalya
Creation date: 09/16/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибута магазина (thbj-attr) 'gds-ref'".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ ref/grplibfn.i }
DEFINE TEMP-TABLE tt-gdsreffi NO-UNDO
FIELD table-name AS CHARACTER
FIELD field-name AS CHARACTER
FIELD field-label AS CHARACTER
FIELD field-format AS CHARACTER
FIELD field-width AS DECIMAL
FIELD field-is-selected AS INTEGER
INDEX pi IS UNIQUE PRIMARY
table-name
field-name
INDEX iis
field-is-selected
.
DEFINE BUFFER sel_tt-gdsreffi FOR tt-gdsreffi.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
DEFINE VARIABLE v-gdsscrvw AS CHARACTER NO-UNDO.
DEFINE BUFFER cli-buf FOR ub.clients .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .

DEFINE TEMP-TABLE temp-gdsscrvw NO-UNDO
FIELD tbl-name AS CHARACTER
FIELD fld-name AS CHARACTER
FIELD custom-label AS CHARACTER
FIELD is-on AS LOGICAL
INDEX pi IS UNIQUE PRIMARY tbl-name fld-name
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-gdsscrvw

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-gdsscrvw

/* Definitions for BROWSE BR-gdsscrvw                                   */
&Scoped-define FIELDS-IN-QUERY-BR-gdsscrvw temp-gdsscrvw.custom-label temp-gdsscrvw.is-on   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gdsscrvw temp-gdsscrvw.is-on   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-gdsscrvw temp-gdsscrvw
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-gdsscrvw temp-gdsscrvw
&Scoped-define SELF-NAME BR-gdsscrvw
&Scoped-define QUERY-STRING-BR-gdsscrvw FOR EACH temp-gdsscrvw
&Scoped-define OPEN-QUERY-BR-gdsscrvw OPEN QUERY br-gdsscrvw FOR EACH temp-gdsscrvw.
&Scoped-define TABLES-IN-QUERY-BR-gdsscrvw temp-gdsscrvw
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gdsscrvw temp-gdsscrvw


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-gdsscrvw}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RECT-1 t-dif-nam1 ~
BR-gdsscrvw t-dif-nam2 t-dpl-off t-dif-pdbc t-pbc-veto t-tnvedimp ~
t-unq-artc t-is-scgb f-shema-foto B-dfltggrp rs-gdsoattr rs-gdshattr ~
rs-fgdsobj rs-s-coeff rs-gds-prop rs-gds-attr rs-add-prop l-gds-obj-attr ~
l-gds-host-attr l-fbr-gds-obj l-s-coeff l-gds-prop l-goods-attr l-add-prop 
&Scoped-Define DISPLAYED-OBJECTS t-dif-nam1 t-dif-nam2 t-dpl-off t-dif-pdbc ~
t-pbc-veto t-tnvedimp t-unq-artc t-is-scgb f-shema-foto f-dfltggrp ~
f-grp-name rs-gdsoattr rs-gdshattr rs-fgdsobj rs-s-coeff rs-gds-prop ~
rs-gds-attr rs-add-prop FILL-IN-3 l-gds-obj-attr l-gds-host-attr ~
l-fbr-gds-obj l-s-coeff l-gds-prop l-goods-attr l-add-prop 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 t-dif-nam1 t-dif-nam2 t-dpl-off t-dif-pdbc t-pbc-veto ~
t-tnvedimp t-unq-artc t-is-scgb 
&Scoped-define List-2 RECT-1 f-dfltggrp B-dfltggrp f-grp-name rs-gdsoattr ~
rs-gdshattr rs-fgdsobj rs-s-coeff rs-gds-prop rs-gds-attr rs-add-prop ~
FILL-IN-3 l-gds-obj-attr l-gds-host-attr l-fbr-gds-obj l-s-coeff l-gds-prop ~
l-goods-attr l-add-prop 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-dfltggrp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 4 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-shema-foto AS integer FORMAT "->,>>>,>>9":U INITIAL 1
     LABEL "Схема хранения фотографий" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Общая директория"," 1",
                     "По товарам"," 2"
     DROP-DOWN-LIST
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dfltggrp AS INTEGER FORMAT "->,>>>,>>9":U INITIAL -1 
     LABEL "Гр.товаров по умолч." 
     VIEW-AS FILL-IN NATIVE 
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE f-grp-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN NATIVE 
     SIZE 59 BY 1
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Опции копирования допинфо по товару ( при соз-дании товара копированием)" 
      VIEW-AS TEXT 
     SIZE 95.5 BY .67
     FGCOLOR 3  NO-UNDO.

DEFINE VARIABLE l-add-prop AS CHARACTER FORMAT "X(256)":U INITIAL "Атрибуты доп.расходов" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-fbr-gds-obj AS CHARACTER FORMAT "X(256)":U INITIAL "Атрибуты товара РЕСТОРАН" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-gds-host-attr AS CHARACTER FORMAT "X(256)":U INITIAL "Атрибуты товара по фирме" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-gds-obj-attr AS CHARACTER FORMAT "X(256)":U INITIAL "Атрибуты товара по объекту" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-gds-prop AS CHARACTER FORMAT "X(256)":U INITIAL "Индикаторы товара на объекте" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-goods-attr AS CHARACTER FORMAT "X(256)":U INITIAL "Глобальные атрибуты товара" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-s-coeff AS CHARACTER FORMAT "X(256)":U INITIAL "Сезонные коэффициенты" 
      VIEW-AS TEXT 
     SIZE 29.5 BY .67 NO-UNDO.

DEFINE VARIABLE rs-add-prop AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE rs-fgdsobj AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE rs-gds-attr AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE rs-gds-prop AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE rs-gdshattr AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE rs-gdsoattr AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE VARIABLE rs-s-coeff AS INTEGER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
     SIZE 31 BY 3.5
     FONT 4 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.5 BY 16.

DEFINE VARIABLE t-dif-nam1 AS LOGICAL INITIAL no 
     LABEL "Разрешено добавление товаров с одинаковыми именами" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-dif-nam2 AS LOGICAL INITIAL no 
     LABEL "Обязательное заведение ДопБК при добавлении товара" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-dif-pdbc AS LOGICAL INITIAL no 
     LABEL "Запрет повторных ДопБК для одного производителя" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-dpl-off AS LOGICAL INITIAL no 
     LABEL "Выключение повторных ДопБК при появлении новых" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-is-scgb AS LOGICAL INITIAL no 
     LABEL "Разрешено создавать глобальные весовые коды" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-pbc-veto AS LOGICAL INITIAL no 
     LABEL "Запрет повторных ДопБК" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-tnvedimp AS LOGICAL INITIAL no 
     LABEL "импортировать код ТНВЭД в карточку товара" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

DEFINE VARIABLE t-unq-artc AS LOGICAL INITIAL no 
     LABEL "Создание доп.БК = артикулу при создании товара" 
     VIEW-AS TOGGLE-BOX
     SIZE 55 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-gdsscrvw FOR 
      temp-gdsscrvw SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gdsscrvw
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gdsscrvw Dialog-Frame _FREEFORM
  QUERY BR-gdsscrvw DISPLAY
      temp-gdsscrvw.custom-label  COLUMN-LABEL "Поле" FORMAT "X(25)"
temp-gdsscrvw.is-on COLUMN-LABEL "Показывать" VIEW-AS TOGGLE-BOX
ENABLE
temp-gdsscrvw.is-on
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 42 BY 6.13
         TITLE "Поля в экране покупателя" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     t-dif-nam1 AT ROW 2.08 COL 2
     BR-gdsscrvw AT ROW 2.08 COL 57 WIDGET-ID 100
     t-dif-nam2 AT ROW 3.08 COL 2
     t-dpl-off AT ROW 4.08 COL 2 WIDGET-ID 116
     t-dif-pdbc AT ROW 5 COL 2 WIDGET-ID 80
     t-pbc-veto AT ROW 6 COL 2 WIDGET-ID 114
     t-tnvedimp AT ROW 7 COL 2
     t-unq-artc AT ROW 8.04 COL 2 WIDGET-ID 118
     t-is-scgb AT ROW 9.25 COL 2 WIDGET-ID 120
     f-shema-foto AT ROW 10.5 COL 27.13 COLON-ALIGNED WIDGET-ID 122
     f-dfltggrp AT ROW 12.75 COL 22.25 COLON-ALIGNED WIDGET-ID 22
     B-dfltggrp AT ROW 12.75 COL 33.5 WIDGET-ID 24
     f-grp-name AT ROW 12.75 COL 35.25 COLON-ALIGNED NO-LABEL WIDGET-ID 68
     rs-gdsoattr AT ROW 15.54 COL 2 NO-LABEL WIDGET-ID 28
     rs-gdshattr AT ROW 15.54 COL 34 NO-LABEL WIDGET-ID 34
     rs-fgdsobj AT ROW 15.54 COL 66 NO-LABEL WIDGET-ID 40
     rs-s-coeff AT ROW 19.79 COL 2 NO-LABEL WIDGET-ID 46
     rs-gds-prop AT ROW 19.79 COL 34 NO-LABEL WIDGET-ID 52
     rs-gds-attr AT ROW 19.79 COL 66 NO-LABEL WIDGET-ID 58
     rs-add-prop AT ROW 24.29 COL 2 NO-LABEL WIDGET-ID 106
     FILL-IN-3 AT ROW 14.04 COL 2 NO-LABEL WIDGET-ID 70
     l-gds-obj-attr AT ROW 14.79 COL 2.5 NO-LABEL WIDGET-ID 94
     l-gds-host-attr AT ROW 14.79 COL 35 NO-LABEL WIDGET-ID 96
     l-fbr-gds-obj AT ROW 14.79 COL 67 NO-LABEL WIDGET-ID 98
     l-s-coeff AT ROW 19.04 COL 2 NO-LABEL WIDGET-ID 100
     l-gds-prop AT ROW 19.04 COL 35 NO-LABEL WIDGET-ID 102
     l-goods-attr AT ROW 19.04 COL 67 NO-LABEL WIDGET-ID 104
     l-add-prop AT ROW 23.5 COL 2 NO-LABEL WIDGET-ID 112
     RECT-1 AT ROW 12.25 COL 1.5 WIDGET-ID 64
     SPACE(0.24) SKIP(0.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Набор опций работы со справочниками товаров"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "?" ? ub thbj-attr
      TABLE: X_shop B "?" ? ub shop
      TABLE: X_store B "?" ? ub store
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-gdsscrvw t-dif-nam1 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-dfltggrp IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN f-dfltggrp IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
ASSIGN 
       f-dfltggrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-grp-name IN FRAME Dialog-Frame
   NO-ENABLE 2                                                          */
ASSIGN 
       f-grp-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-3 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L 2                                                  */
/* SETTINGS FOR FILL-IN l-add-prop IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN l-fbr-gds-obj IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN l-gds-host-attr IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN l-gds-obj-attr IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN l-gds-prop IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN l-goods-attr IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR FILL-IN l-s-coeff IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR RECTANGLE RECT-1 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-add-prop IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-fgdsobj IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-gds-attr IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-gds-prop IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-gdshattr IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-gdsoattr IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR RADIO-SET rs-s-coeff IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-dif-nam1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-dif-nam2 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-dif-pdbc IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-dpl-off IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-is-scgb IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-pbc-veto IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-tnvedimp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX t-unq-artc IN FRAME Dialog-Frame
   1                                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gdsscrvw
/* Query rebuild information for BROWSE BR-gdsscrvw
     _START_FREEFORM
OPEN QUERY br-gdsscrvw FOR EACH temp-gdsscrvw.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-gdsscrvw */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Набор опций работы со справочниками товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dfltggrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dfltggrp Dialog-Frame
ON CHOOSE OF B-dfltggrp IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-grp AS INTEGER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define buffer buf_gds-grp for ub.gds-grp.
IF f-dfltggrp <> -1  THEN DO:
  v-grp = f-dfltggrp.
END.
find first buf_gds-grp no-lock where
         buf_gds-grp.node-code = v-grp no-error.
if available buf_gds-grp then do:
  v-rid-list = string(recid(buf_gds-grp)).
end.
    run ref/gds-grp.w (
                  input parparentproc
                , input ({&g#term} + ',b-sel')
                , input p-obj-type
                , input p-obj-code
                , input-output v-rid-list) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
and v-rid-list <> '':U
THEN DO:
  find first buf_gds-grp no-lock where
            recid(buf_gds-grp) = integer(v-rid-list) no-error.
  if available buf_gds-grp then do:
    f-dfltggrp = buf_gds-grp.node-code.
  end.
  RUN set-full-grp-name IN THIS-PROCEDURE ( INPUT f-dfltggrp) .
END.
if error-status:error
or v-rid-list = '':U then do:
  message
  "Хотите УБРАТЬ ЗАДАНИЕ ГРУППЫ ПО УМОЛЧАНИЮ?"
  view-as alert-box question buttons yes-no update glog.
  if glog then do:
    f-dfltggrp = -1.
    RUN set-full-grp-name IN THIS-PROCEDURE ( INPUT f-dfltggrp) .
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gdsscrvw
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

ON value-changed OF temp-gdsscrvw.is-on IN BROWSE br-gdsscrvw DO:
DEFINE BUFFER buf_temp-gdsscrvw FOR temp-gdsscrvw.
if not avail temp-gdsscrvw then return no-apply.

FIND FIRST buf_temp-gdsscrvw WHERE RECID(buf_temp-gdsscrvw) = RECID(temp-gdsscrvw).
ASSIGN
buf_temp-gdsscrvw.is-on = LOGICAL(temp-gdsscrvw.is-on:SCREEN-VALUE IN BROWSE br-gdsscrvw).
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF  p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
              LOCKED_thbj-attr.obj-type = p-obj-type
        AND   LOCKED_thbj-attr.obj-code = p-obj-code
        AND   LOCKED_thbj-attr.upper-prop-code = {&attr-gds-ref}
        AND LOCKED_thbj-attr.prop-code = "":U
        NO-WAIT NO-ERROR.
     if locked locked_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
        view-as alert-box error .
        undo, return error.
      end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = {&attr-gds-ref}
    AND   LOCKED_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.
  end.
  RUN FILL-WIDGETS IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

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
  DISPLAY t-dif-nam1 t-dif-nam2 t-dpl-off t-dif-pdbc t-pbc-veto t-tnvedimp 
          t-unq-artc t-is-scgb f-shema-foto f-dfltggrp f-grp-name rs-gdsoattr 
          rs-gdshattr rs-fgdsobj rs-s-coeff rs-gds-prop rs-gds-attr rs-add-prop 
          FILL-IN-3 l-gds-obj-attr l-gds-host-attr l-fbr-gds-obj l-s-coeff 
          l-gds-prop l-goods-attr l-add-prop 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RECT-1 t-dif-nam1 BR-gdsscrvw t-dif-nam2 
         t-dpl-off t-dif-pdbc t-pbc-veto t-tnvedimp t-unq-artc t-is-scgb 
         f-shema-foto B-dfltggrp rs-gdsoattr rs-gdshattr rs-fgdsobj rs-s-coeff 
         rs-gds-prop rs-gds-attr rs-add-prop l-gds-obj-attr l-gds-host-attr 
         l-fbr-gds-obj l-s-coeff l-gds-prop l-goods-attr l-add-prop 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
DEFINE VARIABLE v-gds-copy-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-gdsreffi-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.

FOR EACH thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
FOR EACH temp-thbj-attr:
  delete temp-thbj-attr.
end.
run adm/shattri.p (
              input "init":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-gds-ref}
            , input "":U
            , output v-value-character
            , output v-value-date
            , output v-value-decimal
            , output v-value-integer
            , output v-value-logical
            , output v-param-type
            , INPUT-OUTPUT table-handle v-tth
            ) no-error .
if error-status:error
and not available locked_thbj-attr then do:
  message
  "Не удалось получить начальные значения настроек" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
FOR EACH thbjattr_thbj-attr:
  ASSIGN
  v-entry = thbjattr_thbj-attr.prop-code.
  IF v-entry = {&attr-gds-ref_dif-nam1} THEN DO:
    ASSIGN
    t-dif-nam1 = thbjattr_thbj-attr.property-value-logical
    t-dif-nam1:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_dif-nam2} THEN DO:
    ASSIGN
    t-dif-nam2 = thbjattr_thbj-attr.property-value-logical
    t-dif-nam2:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_dpl-off} THEN DO:
    ASSIGN
    t-dpl-off = thbjattr_thbj-attr.property-value-logical
    t-dpl-off:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_dif-pdbc} THEN DO:
    ASSIGN
    t-dif-pdbc = thbjattr_thbj-attr.property-value-logical
    t-dif-pdbc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_pbc-veto} THEN DO:
    ASSIGN
    t-pbc-veto = thbjattr_thbj-attr.property-value-logical
    t-pbc-veto:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.

  IF v-entry = {&attr-gds-ref_tnvedimp} THEN DO:
    ASSIGN
    t-tnvedimp = thbjattr_thbj-attr.property-value-logical
    t-tnvedimp:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_shema-foto} THEN DO:
    ASSIGN
    f-shema-foto = thbjattr_thbj-attr.property-value-integer
    f-shema-foto:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  end.  
  IF v-entry = {&attr-gds-ref_unq-artc} THEN DO:
    ASSIGN
    t-unq-artc = thbjattr_thbj-attr.property-value-logical
    t-unq-artc:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_is-scgb} THEN DO:
    ASSIGN
    t-is-scgb = thbjattr_thbj-attr.property-value-logical
    t-is-scgb:private-data in frame {&frame-name} = "recid=" + string(recid(thbjattr_thbj-attr))
    .
  END.
  IF v-entry = {&attr-gds-ref_dfltggrp} THEN DO:
    ASSIGN
    f-dfltggrp = thbjattr_thbj-attr.property-value-integer
    f-dfltggrp:private-data = "recid=" + string(recid(thbjattr_thbj-attr))
    .
    RUN set-full-grp-name IN THIS-PROCEDURE ( INPUT f-dfltggrp) .
  END.
  IF v-entry = {&attr-gds-ref_gds-copy} THEN DO:
    ASSIGN
    v-gds-copy-list = thbjattr_thbj-attr.property-value-character
    .
    DO v-ii = 1 TO NUM-ENTRIES( v-gds-copy-list):
      CASE v-ii:
          WHEN 1 THEN DO:
             rs-gdsoattr = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.
          WHEN 2 THEN DO:
             rs-gdshattr = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.
          WHEN 3 THEN DO:
             rs-fgdsobj = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.
          WHEN 4 THEN DO:
             rs-s-coeff = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.
          WHEN 5 THEN DO:
             rs-gds-prop = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.
          WHEN 6 THEN DO:
             rs-gds-attr = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.
          WHEN 7 THEN DO:
             rs-add-prop = INTEGER(ENTRY(v-ii, v-gds-copy-list)) NO-ERROR.
          END.

      END CASE.
    END.

  END.
  IF v-entry = {&attr-gds-ref_gdsscrvw} THEN DO:
    ASSIGN
    v-gdsscrvw = thbjattr_thbj-attr.property-value-character
    .
  END.
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr to temp-thbj-attr.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE BUFFER buf_custom-labels FOR ub.custom-labels.
DEFINE BUFFER buf_temp-gdsscrvw FOR temp-gdsscrvw.
FOR EACH buf_custom-labels NO-LOCK WHERE
        buf_custom-labels.CALL-TYPE = "add-fields"
    AND buf_custom-labels.CALL-point = "gdsscrvw":
  CREATE buf_temp-gdsscrvw.
  ASSIGN
  buf_temp-gdsscrvw.tbl-name = buf_custom-labels.tbl-name
  buf_temp-gdsscrvw.fld-name = buf_custom-labels.fld-name
  buf_temp-gdsscrvw.custom-label = buf_custom-labels.custom-label
  buf_temp-gdsscrvw.is-on = LOOKUP(substitute("&1.&2"
                                              , buf_custom-labels.tbl-name
                                              , buf_custom-labels.fld-name
                                              )

                                    , v-gdsscrvw) > 0
  .
END.

ASSIGN
rs-gdsoattr:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
"Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
"По текущему объекту" + {&comma-char} + STRING(1) + {&comma-char} +
"Объекта той же фирмы в тек. БД" + {&comma-char} + STRING(2) + {&comma-char} +
"Все объекты тек. БД" + {&comma-char} + STRING(3)
rs-gdshattr:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
   "Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
    "По текущей фирме" + {&comma-char} + STRING(1) + {&comma-char} +
    "Все фирмы" + {&comma-char} + STRING(2)
rs-fgdsobj:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
    "Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
    "По текущему объекту" + {&comma-char} + STRING(1) + {&comma-char} +
    "Объекта той же фирмы в тек. БД" + {&comma-char} + STRING(2) + {&comma-char} +
    "Все объекты тек. БД" + {&comma-char} + STRING(3)
rs-s-coeff:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
        "Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
        "По текущему объекту и глобальные" + {&comma-char} + STRING(1) + {&comma-char} +
        "Объекта той же фирмы в тек. БД и глобальные" + {&comma-char} + STRING(2) + {&comma-char} +
        "Все объекты тек. БД и глобальные" + {&comma-char} + STRING(3)
rs-gds-prop:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
        "Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
        "По текущему объекту" + {&comma-char} + STRING(1) + {&comma-char} +
        "Объекта той же фирмы в тек. БД" + {&comma-char} + STRING(2) + {&comma-char} +
        "Все объекты тек. БД" + {&comma-char} + STRING(3)
rs-gds-attr:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
            "Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
             "Копировать" + {&comma-char} + STRING(1)
rs-add-prop:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
                "Не копировать" + {&comma-char} + STRING(0) + {&comma-char} +
                 "Копировать" + {&comma-char} + STRING(1)

.
if p-obj-type = {&shop}
or p-obj-type = {&stock} then do:
  ASSIGN
  FRAME {&FRAME-NAME}:TITLE = substitute("&1 &2&3"
                                         ,FRAME {&FRAME-NAME}:TITLE
                                         ,p-obj-type
                                         ,p-obj-code)
  .
end.

v-tab-order = "t-dif-nam1,t-dif-nam2,t-dif-pdbc,t-pbc-veto,t-tnvedimp,shema-foto,t-unq-artc,t-is-scgb" +
              "b-dfltggrp,rs-gdsoattr,rs-gdshattr,rs-fgdsobj,rs-s-coeff,rs-gds-prop,rs-gds-attr,rs-add-prop,br-gdsscrvw".
ASSIGN
temp-gdsscrvw.is-on:read-only IN BROWSE br-gdsscrvw = (p-mode = {&LOOKUP}).
DISPLAY
l-add-prop
l-fbr-gds-obj
l-gds-host-attr
l-gds-obj-attr
l-gds-prop
l-goods-attr
l-s-coeff
t-dif-nam1
t-dif-nam2
t-dpl-off
t-dif-pdbc
t-pbc-veto
t-tnvedimp
f-shema-foto
t-unq-artc
t-is-scgb
rs-add-prop
rs-fgdsobj
rs-s-coeff
rs-gds-attr
rs-gdshattr
rs-gdsoattr
rs-gds-prop
fill-in-3
rect-1
br-gdsscrvw
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode = {&UPDATE}
b-quit
B-Help
t-dif-nam1 WHEN p-mode = {&UPDATE}
t-dif-nam2 WHEN p-mode = {&UPDATE}
t-dpl-off WHEN p-mode = {&UPDATE}
t-dif-pdbc WHEN p-mode = {&UPDATE}
t-pbc-veto WHEN p-mode = {&UPDATE}
t-tnvedimp WHEN p-mode = {&UPDATE}
f-shema-foto WHEN p-mode = {&UPDATE}
t-unq-artc WHEN p-mode = {&UPDATE}
t-is-scgb  WHEN p-mode = {&UPDATE}
b-dfltggrp WHEN p-mode = {&UPDATE}
rs-add-prop  WHEN p-mode = {&UPDATE}
rs-fgdsobj WHEN p-mode = {&UPDATE}
rs-s-coeff WHEN p-mode = {&UPDATE}
rs-gds-attr WHEN p-mode = {&UPDATE}
rs-gdshattr WHEN p-mode = {&UPDATE}
rs-gdsoattr WHEN p-mode = {&UPDATE}
rs-gds-prop WHEN p-mode = {&UPDATE}
br-gdsscrvw
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    HIDE
    b-exit
    IN FRAME {&FRAME-NAME}.
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:column = 1
    .
END.
OPEN QUERY br-gdsscrvw FOR EACH temp-gdsscrvw.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-gds-copy-list as character no-undo .
define variable v-gdsreffi as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
DEFINE BUFFER buf_temp-gdsscrvw FOR temp-gdsscrvw.
IF p-mode = {&LOOKUP} THEN RETURN ERROR.
v-gdsscrvw = "".
FOR EACH buf_temp-gdsscrvw:

   IF buf_temp-gdsscrvw.is-on THEN DO:
      ASSIGN
      v-gdsscrvw =  substitute("&1,&2.&3"
                              ,v-gdsscrvw
                              , buf_temp-gdsscrvw.tbl-name
                              , buf_temp-gdsscrvw.fld-name).
   END.
END.
ASSIGN
v-gdsscrvw = TRIM(v-gdsscrvw, {&comma-char}).
ASSIGN
FRAME {&FRAME-NAME}
t-dif-nam1
t-dif-nam2
t-dpl-off
t-dif-pdbc
t-pbc-veto
t-tnvedimp
f-shema-foto
t-unq-artc
t-is-scgb
f-dfltggrp
rs-gdsoattr
rs-gdshattr
rs-fgdsobj
rs-s-coeff
rs-gds-prop
rs-gds-attr
rs-add-prop
.
 ASSIGN
v-gds-copy-list = SUBSTITUTE("&2&1&3&1&4&1&5&1&6&1&7&1&8"
                          ,{&comma-char}
                          ,rs-gdsoattr
                          ,rs-gdshattr
                          ,rs-fgdsobj
                          ,rs-s-coeff
                          ,rs-gds-prop
                          ,rs-gds-attr
                          ,rs-add-prop).
assign
fh = frame {&frame-name}:first-child
wh = fh:first-child
.
do while valid-handle(wh):
  if wh:private-data begins "recid=" then do:
    find first thbjattr_thbj-attr where
              recid(thbjattr_thbj-attr) = integer(entry(2, wh:private-data, '=')).
    assign
    buffer thbjattr_thbj-attr:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
  end.
  wh = wh:next-sibling.
end.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-gds-ref_gds-copy}.
assign
thbjattr_thbj-attr.property-value-character = v-gds-copy-list
.
release thbjattr_thbj-attr.
find first thbjattr_thbj-attr where thbjattr_thbj-attr.prop-code = {&attr-gds-ref_gdsscrvw}.
assign
thbjattr_thbj-attr.property-value-character = v-gdsscrvw
.
release thbjattr_thbj-attr.
v-same = yes.
for each thbjattr_thbj-attr,
    first temp-thbj-attr where
          temp-thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
      and temp-thbj-attr.obj-code = thbjattr_thbj-attr.obj-code
      and temp-thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
      and temp-thbj-attr.prop-code = thbjattr_thbj-attr.prop-code:
   buffer-compare
   thbjattr_thbj-attr
   to temp-thbj-attr
   save result in v-same.
   if not v-same then leave.
end.
v-same = no.
IF v-same  and not v-to-create THEN RETURN.
/*проверим корректность*/
run adm/shattri.p (
              input "check":U
            , input p-obj-type
            , input p-obj-code
            , input {&attr-gds-ref}
            , INPUT '':U
             , output v-value-character
             , output v-value-date
             , output v-value-decimal
             , output v-value-integer
             , output v-value-logical
             , output v-param-type
             , input-output table-handle v-tth
             ) no-error .

if error-status:error then do:
  message
  "Некорректное значение ПАРАМЕТРОВ" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
do TRANSACTION
on error undo, return error return-value
:

  RUN thbjattr_set-section IN THIS-PROCEDURE (
       input p-obj-type
      ,input p-obj-code
      ,input {&attr-gds-ref}
      ,INPUT table thbjattr_thbj-attr
  ) NO-ERROR.
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-full-grp-name Dialog-Frame 
PROCEDURE set-full-grp-name :
DEFINE INPUT PARAMETER p-node-code AS INTEGER NO-UNDO.
DEFINE BUFFER buf_gds-grp FOR ub.gds-grp.
if p-node-code <> -1 then do:
  find first buf_gds-grp no-lock where
            buf_gds-grp.node-code = p-node-code no-error.
  if not available buf_gds-grp then do:
    assign
    f-grp-name = '!!!!НЕВЕРНЫЙ КОД ГРУППЫ':U
    .
  END.
 else do:
   run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code, output f-grp-name) no-error.
   if error-status:error then do:
    assign
    f-grp-name = '!!!!НЕ УДАЛОСЬ НАЙТИ ПОЛНОЕ ИМЯ ГРУППЫ':U
    .
   end.
 end.
end.
else do:
  ASSIGN
  f-grp-name = '':U
  .
end.
DISPLAY
f-grp-name
f-dfltggrp
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

