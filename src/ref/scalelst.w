&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_gds-obj-attr FOR ub.gds-obj-attr.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_prod-bc FOR ub.prod-bc.
DEFINE BUFFER X_prod-bc-db FOR ub.prod-bc-db.
DEFINE BUFFER X_scales-gds FOR ub.scales-gds.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары на одних весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

Author: Черных В.Г.
Created: 06/11/98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-db-num   like ub.scales.db-num no-undo.
define input parameter scalenum   like ub.scales.scales-num no-undo.
define input parameter bttns     as character no-undo.
define input parameter p-mode as character no-undo .
define input-output param  p-rid-list    as character no-undo . /* список recid'ов выбранных товаров */

/* Local Variable Definitions ---                                       */
define variable  vss-revision    as character no-undo init "$Revision$":U .
define variable  vss-author      as character no-undo init "$Author$":U .
define variable  vss-date        as character no-undo init "$Date$":U .
define variable  vss-workfile    as character no-undo init "$Workfile$":U .
define variable  vss-archive     as character no-undo init "$Archive$":U .
define variable  vss-description as character no-undo init "Товары на одних весах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ str/get-pr.i def }
{ cmp/gds-list.i gds-list def "new shared" }
{ ref/gdsoattr.i }
{ ref/sc-price.i }
{ str/libbcrcn.i }
&undefine gds-list_i_def
{ cmp/gds-list.i save-list def }
{ gbl/getcntxt.i def}
{ ref/sclgdsld.i }

define variable  temp-code like ub.scales-gds.b-code no-undo.
define variable send-rid-list as character no-undo .

/*define buffer b-scales for scales .*/
define buffer b-scales-gds for ub.scales-gds .
define buffer l-goods for ub.goods.
define buffer l-scales-gds for ub.scales-gds.
define buffer l-bar-code for ub.bar-code.
define buffer l-prod-bc for ub.prod-bc.
define buffer l-prod-bc-db for ub.prod-bc-db.
define buffer l-gds-obj-attr for ub.gds-obj-attr.
define buffer buf_gds-obj for ub.gds-obj .
define buffer buf_parts for ub.parts .

define variable rid-list as character no-undo .
define variable v-last-date as date no-undo .
/*счетчики кол-ва невесового товара, которые пытались добавить на весы*/
define variable  ves-err as integer init 0.
/*переменная цены товара*/
define variable  scale-price as decimal.
/*переменная весового кода*/
define variable  pbc-b-str like ub.prod-bc.b-str no-undo.
define variable  current-db-num like ub.scales-gds.db-num.
define variable  current-scales like ub.scales-gds.scales-num.
define variable  current-plu like ub.scales-gds.plu-code.
define variable  current-b-code like ub.scales-gds.b-code.
define variable  PrintOption as char no-undo.
define variable  ChangeOption as char no-undo.
define variable  SendOption as char no-undo.
define variable  from-card as logical no-undo.
define variable  from-parts as logical no-undo.
define variable v-doc-rec as recid no-undo .
define variable v-mess		as character no-undo .
define variable line-rec    as recid             no-undo.
define variable gds-rec     as recid             no-undo.
define variable glog       as logical no-undo .
DEFINE VARIABLE sclin-ld AS INTEGER NO-UNDO.
define variable par-type as character no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type as character no-undo.
define buffer locked_scales for ub.scales.
DEFINE VARIABLE db-mode AS CHARACTER NO-UNDO.
/*может быть "self"*/
{ ref/scale-pr.i }
{ ref/scale-pr.i -db }
&SCOPED-DEFINE sc-gds-type string(X_scales-gds.plu-type)
&SCOPED-DEFINE sc-gds-deadflag STRING(X_scales-gds.deadflag)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-lst

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_scales-gds X_bar-code X_goods ~
X_gds-obj-attr X_prod-bc X_prod-bc-db

/* Definitions for BROWSE br-lst                                        */
&Scoped-define FIELDS-IN-QUERY-br-lst IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") X_scales-gds.PLU-code X_prod-bc.b-str {&sc-gds-type-name} X_scales-gds.to-del X_scales-gds.to-send X_goods.gds-name X_scales-gds.wt-cart {&sc-gds-deadflag-name} scl-gds-deadvalue( X_scales-gds.deadline, X_scales-gds.deaddate, X_scales-gds.deadflag) X_bar-code.b-code X_scales-gds.obj-code X_goods.grp-name get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) X_goods.artic X_goods.unit-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-lst
&Scoped-define SELF-NAME br-lst
&Scoped-define QUERY-STRING-br-lst FOR EACH X_scales-gds       WHERE X_scales-gds.db-num = p-db-num AND X_scales-gds.scales-num = scalenum NO-LOCK, ~
             EACH X_bar-code WHERE X_bar-code.b-code = X_scales-gds.b-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_bar-code.gds-code NO-LOCK, ~
             EACH X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_bar-code.gds-code AND  X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND  X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK, ~
             EACH X_prod-bc WHERE X_prod-bc.b-str = X_gds-obj-attr.attr-value NO-LOCK     BY X_scales-gds.PLU-code
&Scoped-define OPEN-QUERY-br-lst OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds       WHERE X_scales-gds.db-num = p-db-num AND X_scales-gds.scales-num = scalenum NO-LOCK, ~
             EACH X_bar-code WHERE X_bar-code.b-code = X_scales-gds.b-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_bar-code.gds-code NO-LOCK, ~
             EACH X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_bar-code.gds-code AND  X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND  X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK, ~
             EACH X_prod-bc WHERE X_prod-bc.b-str = X_gds-obj-attr.attr-value NO-LOCK     BY X_scales-gds.PLU-code.
&Scoped-define TABLES-IN-QUERY-br-lst X_scales-gds X_bar-code X_goods ~
X_gds-obj-attr X_prod-bc
&Scoped-define FIRST-TABLE-IN-QUERY-br-lst X_scales-gds
&Scoped-define SECOND-TABLE-IN-QUERY-br-lst X_bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-br-lst X_goods
&Scoped-define FOURTH-TABLE-IN-QUERY-br-lst X_gds-obj-attr
&Scoped-define FIFTH-TABLE-IN-QUERY-br-lst X_prod-bc


/* Definitions for BROWSE br-lst-db                                     */
&Scoped-define FIELDS-IN-QUERY-br-lst-db IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") X_scales-gds.PLU-code get-scl-code( INPUT X_bar-code.b-code, INPUT X_gds-obj-attr.attr-value, BUFFER X_prod-bc-db) {&sc-gds-type-name} X_scales-gds.to-del X_scales-gds.to-send X_goods.gds-name X_scales-gds.wt-cart {&sc-gds-deadflag-name} scl-gds-deadvalue( X_scales-gds.deadline, X_scales-gds.deaddate, X_scales-gds.deadflag) X_bar-code.b-code X_scales-gds.obj-code X_goods.grp-name get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) X_goods.artic X_goods.unit-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-lst-db
&Scoped-define SELF-NAME br-lst-db
&Scoped-define QUERY-STRING-br-lst-db FOR EACH X_scales-gds       WHERE X_scales-gds.db-num = p-db-num AND X_scales-gds.scales-num = scalenum NO-LOCK, ~
             EACH X_bar-code WHERE X_bar-code.b-code = X_scales-gds.b-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_bar-code.gds-code NO-LOCK, ~
             EACH X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_bar-code.gds-code AND  X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND  X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK, ~
             EACH X_prod-bc-db NO-LOCK WHERE X_prod-bc-db.b-str = X_gds-obj-attr.attr-value     AND X_prop-bc-db.db-num = p-db-num OUTER-JOIN     BY X_scales-gds.PLU-code
&Scoped-define OPEN-QUERY-br-lst-db OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds       WHERE X_scales-gds.db-num = p-db-num AND X_scales-gds.scales-num = scalenum NO-LOCK, ~
             EACH X_bar-code WHERE X_bar-code.b-code = X_scales-gds.b-code NO-LOCK, ~
             EACH X_goods WHERE X_goods.gds-code = X_bar-code.gds-code NO-LOCK, ~
             EACH X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_bar-code.gds-code AND  X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND  X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK, ~
             EACH X_prod-bc-db NO-LOCK WHERE X_prod-bc-db.b-str = X_gds-obj-attr.attr-value     AND X_prop-bc-db.db-num = p-db-num OUTER-JOIN     BY X_scales-gds.PLU-code.
&Scoped-define TABLES-IN-QUERY-br-lst-db X_scales-gds X_bar-code X_goods ~
X_gds-obj-attr X_prod-bc-db
&Scoped-define FIRST-TABLE-IN-QUERY-br-lst-db X_scales-gds
&Scoped-define SECOND-TABLE-IN-QUERY-br-lst-db X_bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-br-lst-db X_goods
&Scoped-define FOURTH-TABLE-IN-QUERY-br-lst-db X_gds-obj-attr
&Scoped-define FIFTH-TABLE-IN-QUERY-br-lst-db X_prod-bc-db


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-mark b-ticket b-chg ~
PricePrint B-send b-hist b-help a-n-c loc-code loc-name loc-art DeadValueRS ~
WeightValue DeadValue DeadValueDate br-lst-db br-lst mark-num
&Scoped-Define DISPLAYED-OBJECTS a-n-c loc-code loc-name loc-art ~
DeadValueRS WeightValue DeadValue DeadValueDate mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-scl-code Dialog-Frame
FUNCTION get-scl-code RETURNS CHARACTER
   (    INPUT p-b-code AS INTEGER
     , INPUT p-b-str AS CHARACTER
     , BUFFER buf_prod-bc-db FOR ub.prod-bc-db )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-chg
       MENU-ITEM m_gds-list     LABEL "Список товаров"
       MENU-ITEM m_WeightValue  LABEL "Вес упаковки товара"
       MENU-ITEM m_WeightValueList LABEL "Вес упаковки списком"
       MENU-ITEM m_DeadValue    LABEL "Срок годности товара"
       MENU-ITEM m_DeadValueList LABEL "Срок годности списком"
       RULE
       MENU-ITEM m_from-card    LABEL "Из карточки товара"
              TOGGLE-BOX
       MENU-ITEM m_from-parts   LABEL "С.Г. <---из последнего прихода"
              TOGGLE-BOX.

DEFINE MENU MENU-b-price
       MENU-ITEM m_scalesman    LABEL "Для весовщика"
       MENU-ITEM m_normal       LABEL "Обычный"       .

DEFINE MENU MENU-B-send
       MENU-ITEM m_send_all     LABEL "Все"
       MENU-ITEM m_send_changed LABEL "Измененные"
       MENU-ITEM m_send_current LABEL "Текущий товар"
       RULE
       MENU-ITEM m_send_resend  LABEL "Повторно"      .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.

DEFINE BUTTON B-send
     LABEL "Пере&слать"
     SIZE 10 BY 1.

DEFINE BUTTON b-ticket
     LABEL "&Ценники"
     SIZE 10 BY 1.

DEFINE BUTTON PricePrint
     LABEL "Пра&йслист"
     SIZE 10 BY 1.

DEFINE VARIABLE DeadValue AS INTEGER FORMAT ">>>>>9":U INITIAL 30
     LABEL "Срок(дней)"
     VIEW-AS FILL-IN
     SIZE 7.3 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE DeadValueDate AS DATE FORMAT "99/99/9999":U
     LABEL "Срок(до)"
     VIEW-AS FILL-IN
     SIZE 13.8 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     LABEL "Начало артикула"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(13)"
     LABEL "Бар-код (весь)"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(40)"
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     SIZE 20 BY 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4.8 BY 1
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE WeightValue AS DECIMAL FORMAT "->>>>9.999":U INITIAL 30
     LABEL "Вес"
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code",
"Вес.код", "ves",
"PLU", "plu",
"Штрих-код", "shtrih"
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE DeadValueRS AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Дне&й", 0,
"Да&та", 1
     SIZE 20 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-lst FOR
      X_scales-gds,
      X_bar-code,
      X_goods,
      X_gds-obj-attr,
      X_prod-bc SCROLLING.

DEFINE QUERY br-lst-db FOR
      X_scales-gds,
      X_bar-code,
      X_goods,
      X_gds-obj-attr,
      X_prod-bc-db SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-lst Dialog-Frame _FREEFORM
  QUERY br-lst NO-LOCK DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL "*" FORMAT "X(1)":U
X_scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT "99999":U
X_prod-bc.b-str COLUMN-LABEL "Вес.код" FORMAT "X(7)":U
{&sc-gds-type-name} COLUMN-LABEL "Тип" FORMAT "X(3)":U
X_scales-gds.to-del COLUMN-LABEL "У" FORMAT "!/":U
X_scales-gds.to-send COLUMN-LABEL "И" FORMAT "+/-":U
X_goods.gds-name FORMAT "X(30)":U
X_scales-gds.wt-cart COLUMN-LABEL "Вес упак-ки" FORMAT "->>>>9.999":U
{&sc-gds-deadflag-name} COLUMN-LABEL "Тип ср.!годности" FORMAT "X(4)"
scl-gds-deadvalue( X_scales-gds.deadline,  X_scales-gds.deaddate, X_scales-gds.deadflag) COLUMN-LABEL "Срок годн." FORMAT "X(10)":U
X_bar-code.b-code FORMAT "999999999":U
X_scales-gds.obj-code FORMAT "99999":U COLUMN-LABEL "Маг"
X_goods.grp-name FORMAT "X(40)":U
get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
X_goods.artic FORMAT "X(16)":U
X_goods.unit-base FORMAT "X(3)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.5
         BGCOLOR 15 FGCOLOR 0 .

DEFINE BROWSE br-lst-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-lst-db Dialog-Frame _FREEFORM
  QUERY br-lst-db NO-LOCK DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL "*" FORMAT "X(1)":U
X_scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT "99999":U
get-scl-code( INPUT X_bar-code.b-code, INPUT X_gds-obj-attr.attr-value, BUFFER X_prod-bc-db) COLUMN-LABEL "Вес.код" FORMAT "X(7)":U
{&sc-gds-type-name} COLUMN-LABEL "Тип" FORMAT "X(3)":U
X_scales-gds.to-del COLUMN-LABEL "У" FORMAT "!/":U
X_scales-gds.to-send COLUMN-LABEL "И" FORMAT "+/-":U
X_goods.gds-name FORMAT "X(30)":U
X_scales-gds.wt-cart COLUMN-LABEL "Вес упак-ки" FORMAT "->>>>9.999":U
{&sc-gds-deadflag-name} COLUMN-LABEL "Тип ср.!годности" FORMAT "X(4)"
scl-gds-deadvalue( X_scales-gds.deadline,  X_scales-gds.deaddate, X_scales-gds.deadflag) COLUMN-LABEL "Срок годн." FORMAT "X(10)":U
X_bar-code.b-code FORMAT "999999999":U
X_scales-gds.obj-code FORMAT "99999":U COLUMN-LABEL "Маг"
X_goods.grp-name FORMAT "X(40)":U
get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
X_goods.artic FORMAT "X(16)":U
X_goods.unit-base FORMAT "X(3)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.5
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     b-mark AT ROW 1 COL 21
     b-ticket AT ROW 1 COL 34
     b-chg AT ROW 1 COL 44
     PricePrint AT ROW 1 COL 54
     B-send AT ROW 1 COL 64
     b-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     a-n-c AT ROW 2.77 COL 14 NO-LABEL
     loc-code AT ROW 3.93 COL 21 COLON-ALIGNED
     loc-name AT ROW 3.93 COL 21 COLON-ALIGNED
     loc-art AT ROW 3.93 COL 21 COLON-ALIGNED
     DeadValueRS AT ROW 3.93 COL 28 NO-LABEL
     WeightValue AT ROW 3.93 COL 40.6 COLON-ALIGNED
     DeadValue AT ROW 3.93 COL 61.1 COLON-ALIGNED
     DeadValueDate AT ROW 3.93 COL 78.5 COLON-ALIGNED
     br-lst-db AT ROW 5 COL 1 WIDGET-ID 100
     br-lst AT ROW 5 COL 1
     mark-num AT ROW 1.27 COL 25.3 COLON-ALIGNED NO-LABEL
     "Поиск :" VIEW-AS TEXT
          SIZE 7.9 BY 1 AT ROW 2.77 COL 4.8
          BGCOLOR 8 FGCOLOR 0
     SPACE(86.30) SKIP(19.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE "Товары на весах"
         DEFAULT-BUTTON b-chg.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_bar-code B "?" ? ub bar-code
      TABLE: X_gds-obj-attr B "?" ? ub gds-obj-attr
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_prod-bc B "?" ? ub prod-bc
      TABLE: X_prod-bc-db B "?" ? ub prod-bc-db
      TABLE: X_scales-gds B "?" ? ub scales-gds
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-lst-db DeadValueDate Dialog-Frame */
/* BROWSE-TAB br-lst br-lst-db Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-chg:HANDLE.

ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-send:HANDLE.

ASSIGN
       br-lst:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN
       br-lst-db:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

ASSIGN
       PricePrint:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-price:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-lst
/* Query rebuild information for BROWSE br-lst
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds
      WHERE X_scales-gds.db-num = p-db-num
AND X_scales-gds.scales-num = scalenum NO-LOCK,
      EACH X_bar-code WHERE X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
      EACH X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_bar-code.gds-code
AND  X_gds-obj-attr.obj-type = X_scales-gds.obj-type
AND  X_gds-obj-attr.obj-code = X_scales-gds.obj-code
AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK,
      EACH X_prod-bc WHERE X_prod-bc.b-str = X_gds-obj-attr.attr-value NO-LOCK
    BY X_scales-gds.PLU-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,,,"
     _OrdList          = "ub.scales-gds.PLU-code|yes"
     _Where[1]         = "scales-gds.db-num = p-db-num
AND scales-gds.scales-num = scalenum"
     _JoinCode[2]      = "bar-code.b-code = scales-gds.b-code"
     _JoinCode[3]      = "goods.gds-code = bar-code.gds-code"
     _JoinCode[4]      = "gds-obj-attr.gds-code = bar-code.gds-code
AND  gds-obj-attr.obj-type = scales-gds.obj-type
AND  gds-obj-attr.obj-code = scales-gds.obj-code
AND gds-obj-attr.attr-code = {&attr-scales-code-o}"
     _JoinCode[5]      = "prod-bc.b-str = gds-obj-attr.attr-value"
     _Query            is NOT OPENED
*/  /* BROWSE br-lst */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-lst-db
/* Query rebuild information for BROWSE br-lst-db
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds
      WHERE X_scales-gds.db-num = p-db-num
AND X_scales-gds.scales-num = scalenum NO-LOCK,
      EACH X_bar-code WHERE X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
      EACH X_goods WHERE X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
      EACH X_gds-obj-attr WHERE X_gds-obj-attr.gds-code = X_bar-code.gds-code
AND  X_gds-obj-attr.obj-type = X_scales-gds.obj-type
AND  X_gds-obj-attr.obj-code = X_scales-gds.obj-code
AND X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK,
      EACH X_prod-bc-db NO-LOCK WHERE X_prod-bc-db.b-str = X_gds-obj-attr.attr-value
    AND X_prop-bc-db.db-num = p-db-num OUTER-JOIN
    BY X_scales-gds.PLU-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,,,"
     _OrdList          = "ub.scales-gds.PLU-code|yes"
     _Where[1]         = "scales-gds.db-num = p-db-num
AND scales-gds.scales-num = scalenum"
     _JoinCode[2]      = "bar-code.b-code = scales-gds.b-code"
     _JoinCode[3]      = "goods.gds-code = bar-code.gds-code"
     _JoinCode[4]      = "gds-obj-attr.gds-code = bar-code.gds-code
AND  gds-obj-attr.obj-type = scales-gds.obj-type
AND  gds-obj-attr.obj-code = scales-gds.obj-code
AND gds-obj-attr.attr-code = {&attr-scales-code-o}"
     _JoinCode[5]      = "prod-bc-db.b-str = gds-obj-attr.attr-value"
     _Query            is NOT OPENED
*/  /* BROWSE br-lst-db */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "NO-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары на весах */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if ChangeOption = "" then dO:
  run gbl/pop-up.p ( input self:handle, input yes).
end.
if ChangeOption = "" then return no-apply.
if can-do( "GDS-LIST":U, ChangeOption )  then do:
  run b-chg-proc in this-procedure no-error.
  ChangeOption = "".
end.
else do:
  if (not from-card and not from-parts) then
  run ChangeOption-Proc in this-procedure no-error.
  else do:
    CASE ChangeOption:
        when "DeadValue":U then do:
            run DeadValue-proc in this-procedure no-error.
        end.
        when "WeightValue":U then do:
            run WeightValue-proc in this-procedure no-error.
        end.
        when "DeadValuelist":U OR when "WeightValueList":U then do:
            run b-chg-proc in this-procedure no-error.
            ChangeOption = "".
        end.
    END CASE.
  end.
end.
run ChangeOption-Proc in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hist Dialog-Frame
ON CHOOSE OF b-hist IN FRAME Dialog-Frame /* История */
DO:
define variable rid-list as character no-undo .
if available X_scales-gds THEN
run ref/cscalgds.w (
                      input parparentproc
                    , INPUT "":U /*bttns*/
                    , INPUT "one":U /*parref-mode*/
                    , OUTPUT  rid-list
                    , INPUT X_scales-gds.db-num
                    , input X_scales-gds.scales-num
                    , input X_scales-gds.plu-code
                    ).
if db-mode = "self" then do:
  apply "entry" to br-lst.
end.
else do:
  apply "entry" to br-lst-db.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
define variable glog as logical no-undo .
 if available X_scales-gds then  do:
   { gbl/markstrn.i X_scales-gds rid-list }
    IF db-mode = "self" THEN DO:
        glog = br-lst:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
                glog = br-lst:select-next-row ().
                apply "iteration-changed" to br-lst in frame {&frame-name}.
        end.
        if num-entries( rid-list ) = 0 then
            hide mark-num in frame {&frame-name}.
        else
            disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
        apply "entry" to br-lst in frame {&frame-name}.

    END.
    ELSE DO:
        glog = br-lst-db:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
                glog = br-lst-db:select-next-row ().
                apply "iteration-changed" to br-lst-db in frame {&frame-name}.
        end.
        if num-entries( rid-list ) = 0 then
            hide mark-num in frame {&frame-name}.
        else
            disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
        apply "entry" to br-lst-db in frame {&frame-name}.

    END.

end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор  */
DO:
  if ( available X_scales-gds ) then do:
    if  ( rid-list = "" ) or b-mark:sensitive = no
    then
    assign
    rid-list = string( recid( X_scales-gds ) ).
    p-rid-list = rid-list.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-send Dialog-Frame
ON CHOOSE OF B-send IN FRAME Dialog-Frame /* Переслать */
DO:
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
define variable object-option as character no-undo .
define variable choice as integer no-undo .
if SendOption = "" then
run gbl/pop-up.p ( input self:handle, input yes) no-error.
if SendOption = "" then return no-apply.
rep-rec = recid(X_scales-gds).
if locked_scales.master > 0 then do:
  message
  "Пересылка товаров на подчиненные весы осуществляется при пересылке товаров на главные весы"
  view-as alert-box.
  SendOption = "".
  return no-apply.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scales_sending':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
}
if NOT glog then do:
    SendOption = "".
    return no-apply.
end.
/*при вызове general-send из интерфейса - спросим на все объекты или текущий -
третий параметр вызова = ""*/
glog = yes.
if sendoption = "current" then do:
  OBJECT-option = {&current}.
end.
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_scales_another_obj':U
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
  if not glog then do :
    run gbl/d-askw.w (
                input "Выбор типа пересылки товаров"
                ,input substitute("Выберите товары на весах на весы №&1 &2 для пересылки"
                                  ,locked_scales.scales-num
                                  ,locked_scales.scales-name
                                  )
                ,input "|"
                ,input substitute("&1&2|Отказ"
                                  , p-obj-type
                                  , p-obj-code)
                ,input "По текущему объекту|Отказ от пересылки"
                ,input 1
                ,input 2
                ,output choice).
    if choice = 2 then do:
      assign
      sendoption = '':U.
      return no-apply.
    end.
    IF choice = 1 THEN OBJECT-option = {&current}.
  end.
  else do :
    run gbl/d-askw.w (
                input "Выбор типа пересылки товаров"
                ,input substitute("Выберите товары на весах на весы №&1 &2 для пересылки"
                                  ,locked_scales.scales-num
                                  ,locked_scales.scales-name
                                  )
                ,input "|"
                ,input substitute("&1&2|Все|Отказ"
                                  , p-obj-type
                                  , p-obj-code)
                ,input "По текущему объекту|Полный список|Отказ от пересылки"
                ,input 1
                ,input 3
                ,output choice).
    if choice = 3 then do:
      assign
      sendoption = '':U.
      return no-apply.
    end.
    IF choice = 1 THEN OBJECT-option = {&current}.
    IF choice = 2 THEN OBJECT-option = {&all}.
  end.
end.
run str/diallog.w (
      input parparentproc
    , input this-procedure
    , input "ref/sendscal.p":U
    , input (p-obj-type + {&delim-par} + string(p-obj-code) + {&delim-par} + string(recid(locked_scales)) + {&delim-par} +
              sendoption + {&delim-par} + send-rid-list + {&delim-par} + object-option + {&delim-par} +
              string(0))
    , input no /*p-auto-go*/
    , input "":U
    , input substitute("Отсылка данных на весы")
) no-error.
if error-status:error then do:
    Sendoption = "".
    return no-apply.
end.
SendOption = "".
RUN OpenBr in this-procedure .
reposition br-lst to recid rep-rec no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ticket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ticket Dialog-Frame
ON CHOOSE OF b-ticket IN FRAME Dialog-Frame /* Ценники */
DO:
  if available X_scales-gds then  do:
    if rid-list = "" then do:
          run rep/tick-scl.p (
                          input parparentproc
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input recid( X_bar-code )
                        ,input X_scales-gds.db-num
                        ,input X_scales-gds.scales-num
                        ,input "" ) .
    end.
    else do:
      run rep/tick-scl.p (
                      input parparentproc
                    ,input p-obj-type
                    ,input p-obj-code
                    ,input ?
                    ,input X_scales-gds.db-num
                    ,input ?
                    ,input rid-list ) .
    end.
    rid-list = "" .
    RUN OpenBr  in this-procedure .
  end.
  if db-mode = "self" then do:
    apply "entry" to br-lst in frame {&frame-name}.
  end.
  else do:
    apply "entry" to br-lst-db in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-lst
&Scoped-define SELF-NAME br-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-lst Dialog-Frame
ON INSERT OF br-lst IN FRAME Dialog-Frame
DO:
    apply "CHOOSE" to b-mark in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-lst Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-lst IN FRAME Dialog-Frame
OR RETURN OF br-lst DO:
define variable v-gds-rec as recid no-undo .
if available X_scales-gds then  do:
  v-gds-rec = recid(X_goods).
  run ref/gds-form.w (
                      input parparentproc
                    , input {&lookup}
                    , input X_scales-gds.obj-type
                    , input X_scales-gds.obj-code
                    , input this-procedure:handle
                    , input-output v-gds-rec).
end.
apply "entry" to br-lst in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-lst Dialog-Frame
ON RETURN OF br-lst IN FRAME Dialog-Frame
DO:
define variable v-gds-rec as recid no-undo .
if available X_scales-gds then do:
  v-gds-rec = recid(X_goods).
  run ref/gds-form.w (
                      input parparentproc
                    , input {&lookup}
                    , input X_scales-gds.obj-type
                    , input X_scales-gds.obj-code
                    , input this-procedure:handle
                    , input-output v-gds-rec).
end.
 apply "entry" to br-lst in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-lst-db
&Scoped-define SELF-NAME br-lst-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-lst-db Dialog-Frame
ON INSERT OF br-lst-db IN FRAME Dialog-Frame
DO:
    apply "CHOOSE" to b-mark in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-lst-db Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-lst-db IN FRAME Dialog-Frame
OR RETURN OF br-lst-db DO:
define variable v-gds-rec as recid no-undo .
if available X_scales-gds then  do:
  v-gds-rec = recid(X_goods).
  run ref/gds-form.w (
                      input parparentproc
                    , input {&lookup}
                    , input X_scales-gds.obj-type
                    , input X_scales-gds.obj-code
                    , input this-procedure:handle
                    , input-output v-gds-rec).
end.
apply "entry" to br-lst-db in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME DeadValue
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadValue Dialog-Frame
ON ESCAPE OF DeadValue IN FRAME Dialog-Frame /* Срок(дней) */
DO:
    ChangeOption = "".
    run ChangeOption-Proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadValue Dialog-Frame
ON LEAVE OF DeadValue IN FRAME Dialog-Frame /* Срок(дней) */
DO:
  if DeadvalueRs = integer({&sc-gds-deadflag-days}) then
  APPLY "RETURN" to DeadValue.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadValue Dialog-Frame
ON RETURN OF DeadValue IN FRAME Dialog-Frame /* Срок(дней) */
DO:
    assign
    DeadValue
    DeadValueDate
    .
    CAse deadValueRS:
      when integer({&sc-gds-deadflag-days}) then do:
      end.
      when integer({&sc-gds-deadflag-date}) then do:
        assign
        Deadvalue = DeadValueDAte - today
        .
        if DeadValue < 0 then do:
          message
          "Неверный срок годности"
          view-as alert-box error .
          APPLY "ENTRY" to DeadValueDate.
          return no-apply.
        end.
        display
        deadvalue
        with frame {&frame-name}.
      end.
    END CASE.
    run deadvalue-proc in this-procedure no-error.
    if error-status:error then do:
        ChangeOption = "".
        return no-apply.
    end.
    run ChangeOption-Proc no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME DeadValueDate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadValueDate Dialog-Frame
ON LEAVE OF DeadValueDate IN FRAME Dialog-Frame /* Срок(до) */
DO:
  if DeadvalueRs = integer({&sc-gds-deadflag-date}) then
  APPLY "RETURN" to DeadValue.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadValueDate Dialog-Frame
ON RETURN OF DeadValueDate IN FRAME Dialog-Frame /* Срок(до) */
DO:
  APPLY "RETURN" to Deadvalue.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME DeadValueRS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL DeadValueRS Dialog-Frame
ON VALUE-CHANGED OF DeadValueRS IN FRAME Dialog-Frame
DO:
  assign
  DeadValueRS.
  CASE DeadValueRS:
    when integer({&sc-gds-deadflag-days}) then do:
      DISABLE
      DeadValueDAte
      with frame {&frame-name}.
      Enable
      DeadValue
      with frame {&frame-name}.
    end.
    when integer({&sc-gds-deadflag-date}) then do:
      DISABLE
      DeadValue
      with frame {&frame-name}.
      Enable
      DeadValueDate
      with frame {&frame-name}.
    end.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-b-chg Dialog-Frame
ON MENU-DROP OF MENU MENU-b-chg
DO:
  ChangeOption = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-b-price
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-b-price Dialog-Frame
ON MENU-DROP OF MENU MENU-b-price
DO:
  PrintOption = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME MENU-B-send
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL MENU-B-send Dialog-Frame
ON MENU-DROP OF MENU MENU-B-send
DO:
  assign
  SendOption = ""
  send-rid-list  = '':U
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_DeadValue
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_DeadValue Dialog-Frame
ON CHOOSE OF MENU-ITEM m_DeadValue /* Срок годности товара */
DO:
  if avail X_scales-gds and X_scales-gds.to-del = yes then do:
    BELL.
    return no-apply.
  end.
  assign
  ChangeOption = "DeadValue":U.
  APPLY "CHOOSE" to b-chg in frame {&frame-name}.
END.


&Scoped-define SELF-NAME m_DeadValueList
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_DeadValueList Dialog-Frame
ON CHOOSE OF MENU-ITEM m_DeadValueList
DO:
  assign
  ChangeOption = "DeadValueList":U.
  APPLY "CHOOSE" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_from-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_from-card Dialog-Frame
ON VALUE-CHANGED OF MENU-ITEM m_from-card /* Из карточки товара */
DO:
if avail X_scales-gds
and X_scales-gds.to-del = yes
then do:
    BELL.
    return no-apply.
end.

  from-card = not from-card.
  if from-card then do:
      CASE ChangeOption:
          when "DeadValue" then do:
              deadValue =  X_goods.deadline.
              display deadvalue with frame {&frame-name}.
          end.
          when "DeadValueList" then do:
              deadValue = ?.
              display deadvalue with frame {&frame-name}.
          end.
          when "WeightValue" then do:
              WeightValue = X_goods.wt-cart.
              display Weightvalue with frame {&frame-name}.
          end.
          when "WeightValueList" then do:
              WeightValue = ?.
              display Weightvalue with frame {&frame-name}.
          end.
      END CASE.
  end.
  else do:
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_from-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_from-parts Dialog-Frame
ON VALUE-CHANGED OF MENU-ITEM m_from-parts /* С.Г. <---из последнего прихода */
DO:
  if avail X_scales-gds and X_scales-gds.to-del = yes then do:
    BELL.
    return no-apply.
  end.
  from-parts = not from-parts.
  if from-parts then do:
    CASE ChangeOption:
      when "DeadValue" then do:
        assign
        deadvalue =  scl-gds-ld-parts ( buffer X_scales-gds , input sclin-ld ).
        display deadvalue with frame {&frame-name}.
      end.
      when "DeadValueList" then do:
        deadValue = ?.
        display deadvalue with frame {&frame-name}.
      end.
    END CASE.
  end.
  else do:
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_gds-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_gds-list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_gds-list /* Список товаров */
DO:
  assign
  ChangeOption = "GDS-LIST":U.
  APPLY "CHOOSE" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_normal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_normal Dialog-Frame
ON CHOOSE OF MENU-ITEM m_normal /* Обычный */
DO:
  assign
  PrintOption = "NORMAL":U.
  APPLY "CHOOSE" to PricePrint in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_scalesman
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_scalesman Dialog-Frame
ON CHOOSE OF MENU-ITEM m_scalesman /* Для весовщика */
DO:
  assign
  PrintOption = "scalesman":U.
  APPLY "CHOOSE" to PricePrint in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_all Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_all /* Все */
DO:
  assign
  SendOption = "ALL":U
  send-rid-list  = '':U
  .
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_changed
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_changed Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_changed /* Измененные */
DO:
  assign
  SendOption = "CHANGED":U
  send-rid-list  = '':U
  .
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_current
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_current Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_current /* Текущий товар */
DO:
  assign
  SendOption = "current":U
  send-rid-list = (if available X_scales-gds then string(recid(X_scales-gds)) else '':U)
  .
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_send_resend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_send_resend Dialog-Frame
ON CHOOSE OF MENU-ITEM m_send_resend /* Повторно */
DO:
  assign
  SendOption = "RESEND":U
  send-rid-list  = '':U
  .
  APPLY "CHOOSE" to b-send  in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_WeightValue
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_WeightValue Dialog-Frame
ON CHOOSE OF MENU-ITEM m_WeightValue /* Вес упаковки товара */
DO:
  if avail X_scales-gds and X_scales-gds.to-del = yes then do:
    BELL.
    return no-apply.
  end.
  assign
  ChangeOption = "WeightValue":U.
  APPLY "CHOOSE" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_WeightValueList
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_WeightValueList Dialog-Frame
ON CHOOSE OF MENU-ITEM m_WeightValueList /* Вес упаковки списком */
DO:
  assign
  ChangeOption = "WeightValueList":U.
  APPLY "CHOOSE" to b-chg in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME PricePrint
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PricePrint Dialog-Frame
ON CHOOSE OF PricePrint IN FRAME Dialog-Frame /* Прайс-лист */
DO:
define variable g#report-num as integer no-undo .
define variable glog as logical no-undo .
    if PrintOption = "" then do:
        run gbl/pop-up.p (self:handle, yes) no-error .
    end.
    if PrintOption = "" then return no-apply.
    if v-cntxt-db-num = p-db-num then do:
    RUN ProcPricePrint in this-procedure ( input PrintOption
                                          ,buffer locked_scales) No-ERROR.
    end.
    else do:
      RUN ProcPricePrint-db in this-procedure ( input PrintOption
                                            ,buffer locked_scales) No-ERROR.
    end.
    IF ERROR-status:error then do:
      PrintOption = "":U.
      return No-APPLY.
    end.
    if PrintOption = "scalesman":U then do:
        run get-report-num  in parParentProc(output g#report-num).
        run adecomm/_osprint.p ( INPUT  ?,
                                  INPUT  string( session:temp-directory + {&DF_Name} + string( g#report-num ) ),
                                  INPUT  8,
                                  INPUT  2,
                                  INPUT  0,
                                  INPUT  0,
                                  OUTPUT glog ).
    end.
    else do:
        run prn-lib-prn-file in this-procedure (parparentproc,  0 ) .
    end.
    PrintOption = "".
if db-mode = "self" then do:
  apply "entry" to br-lst in frame {&frame-name} .
end.
else do:
  apply "entry" to br-lst-db in frame {&frame-name} .
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME WeightValue
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WeightValue Dialog-Frame
ON ESCAPE OF WeightValue IN FRAME Dialog-Frame /* Вес */
DO:
    ChangeOption = "".
    run ChangeOption-Proc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WeightValue Dialog-Frame
ON LEAVE OF WeightValue IN FRAME Dialog-Frame /* Вес */
DO:
    APPLY "RETURN" TO WeightValue.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL WeightValue Dialog-Frame
ON RETURN OF WeightValue IN FRAME Dialog-Frame /* Вес */
DO:
    assign WeightValue.
    run Weightvalue-proc no-error.
    if error-status:error then do:
        ChangeOption = "".
        return no-apply.
    end.
    run ChangeOption-Proc no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-lst
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ ref/scl-sch.i scales-gds br-lst scalelst goods X_scales-gds }
end.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/*перемещение колонок*/
{ gbl/mv-clmn.i
&browse-name = "br-lst"
&frame-name = "{&frame-name}"
&ext-col = 14
&start-column = 3}

{ gbl/mv-clmn.i
&browse-name = "br-lst-db"
&frame-name = "{&frame-name}"
&ext-col = 14
&start-column = 3}

{ gbl/app_help.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }


{ gbl/brwrepos.i
&browse-name = "br-lst"
&line-num=5
}
{ gbl/brwrepos.i
&browse-name = "br-lst-db"
&line-num=5
}
{ gbl/f2.i br-lst goods-recid gds-recid parparentproc " " THIS-PROCEDURE:HANDLE }
{ gbl/brwrefre.i "v-doc-rec = recid(X_scales-gds). run openbr in this-procedure. if db-mode = 'self' then reposition br-lst to recid(v-doc-rec). ~
    else reposition br-lst-db to recid(v-doc-rec). v-doc-rec = ? . " }

ON END-ERROR OF FRAME {&frame-name}
OR ENDKEY OF FRAME {&frame-name} DO:
   run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input rid-list) no-error.
    if error-status:error then return no-apply.

END.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
    { gbl/getcntxt.i get }

    { str/sclspref.i varscales-pref varpgscales-pref }
    { ref/sclin-ld.i p-obj-type p-obj-code sclin-ld }
    IF p-db-num = v-cntxt-db-num THEN DO:
      db-mode = "self".
    END.
    ELSE DO:
       db-mode = "0".
    END.
    RUN ENABLE_ui IN THIS-PROCEDURE.
    RUN Myenable in this-procedure.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE b-chg-proc Dialog-Frame
PROCEDURE b-chg-proc :
define variable  ii as integer no-undo.
define variable  dd as decimal no-undo.
define variable  old-mode as char no-undo.
define variable  old-handle as handle no-undo.
define variable  old-type as char no-undo.
define variable  old-stat as char no-undo.
define variable  old-flag as logical no-undo.
define variable  old-internal as logical no-undo.
DEFINE VARIABLE v-skip-next as logical no-undo .
DEFINE VARIABLE v-update as logical no-undo .
define variable glog as logical no-undo .
define variable  is-pgweight as logical no-undo.
define variable  v-on as logical no-undo.
define variable  v-b-str as character no-undo.
define variable lns-cnt as integer no-undo .
define variable v-rep-rec as recid no-undo .
define variable obj-list as logical no-undo .
define variable choice as integer no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer buf_gds-prt for ub.gds-prt.
define buffer b-scales for ub.scales.
define buffer buf_scales-gds for ub.scales-gds.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_units for ub.units.
define buffer buf2_scales-gds for ub.scales-gds.

if not available locked_scales then do:
  message "Весы не выбраны." view-as alert-box ERROR .
  ChangeOption = "".
  return error.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scales_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
}
if NOT glog then do:
    ChangeOption = "".
    return no-apply.
end.
FOR EACH gds-list : /* Когда все ОК - цикл не вып-ся ни разу */
    delete gds-list.
END.
FOR EACH save-list:
  delete save-list.
end.

if can-do( "GDS-LIST":U, ChangeOption ) then do :
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_scales_another_obj':U
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
  if not glog then do :
    run gbl/d-askw.w ( input substitute("Формирование списка товаров на весах №&1", locked_scales.scales-num)
                  ,input substitute("Редактировать список товаров на весах №&1 &2"
                                    ,locked_scales.scales-num
                                    ,locked_scales.scales-name
                                    )
                  ,input "|"
                  ,input substitute("&1&2|Отказ"
                                    , p-obj-type
                                    , p-obj-code)
                  ,input "По текущему объекту|Отказ от редактирования"
                  ,input 1
                  ,input 2
                  ,output choice).
      if choice = 2 then do:
        return.
      end.
      if choice = 1 then obj-list = yes.
  end.
  else do :
    run gbl/d-askw.w ( input substitute("Формирование списка товаров на весах №&1", locked_scales.scales-num)
                  ,input substitute("Редактировать список товаров на весах №&1 &2"
                                    ,locked_scales.scales-num
                                    ,locked_scales.scales-name
                                    )
                  ,input "|"
                  ,input substitute("&1&2|Все|Отказ"
                                    , p-obj-type
                                    , p-obj-code)
                  ,input "По текущему объекту|Полный список|Отказ от редактирования"
                  ,input 1
                  ,input 3
                  ,output choice).
      if choice = 3 then do:
        return.
      end.
      if choice = 1 then obj-list = yes.
      if choice = 2 then obj-list = no.
  end.
end.
else  do:
  if NOT can-find( first ub.scales-gds where
                          ub.scales-gds.db-num = locked_scales.db-num
                      AND ub.scales-gds.scales-num = locked_scales.scales-num ) then  do:
    message
    substitute("НЕТ товаров на весах с номером &1 (БД &2)!"
                , locked_scales.scales-num
                , locked_scales.db-num )
    view-as alert-box information .
    ChangeOption = "".
    return no-apply.
  end.
  assign
  frame {&frame-name} DeadValue
  frame {&frame-name} DeadValueDate
  frame {&frame-name} WeightValue .
end.

run waitfram-show in this-procedure ("ЖДИТЕ.  Заполняется список...").

DO ON stop UNDO, return error :
  if can-do( "GDS-LIST":U, ChangeOption ) then do:
    FOR EACH buf_scales-gds WHERE
              buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num AND
              buf_scales-gds.to-del <> yes,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code NO-LOCK:
        if obj-list and ( buf_scales-gds.obj-type <> p-obj-type OR
                          buf_scales-gds.obj-code <> p-obj-code ) then
            NEXT .
        { cmp/gds-list.i gds-list assign " " buf_goods }
        { cmp/gds-list.i save-list assign " " buf_goods }
        save-list.to-del = yes.
    END.
  end.
  else if can-do("WeightValueList":U, ChangeOption) OR can-do("DeadValueList":U, ChangeOption) then do:
    FOR EACH buf_scales-gds WHERE
             buf_scales-gds.db-num = locked_scales.db-num AND
              buf_scales-gds.scales-num = locked_scales.scales-num AND
              buf_scales-gds.to-del <> yes,
        FIRST buf_bar-code WHERE
              buf_bar-code.b-code = buf_scales-gds.b-code NO-LOCK,
        FIRST buf_goods WHERE
              buf_goods.gds-code = buf_bar-code.gds-code
        NO-LOCK :
        { cmp/gds-list.i gds-list assign " " buf_goods}
        { cmp/gds-list.i save-list assign " " buf_goods}
    END.
  end.
END.

run waitfram-hide in this-procedure .
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
run str/gds-list.w (input parparentproc, input v-host-code, input p-obj-type, input p-obj-code).
message
"Вы действительно хотите изменить список товаров на весах"
"в соответствии с данным списком товаров?"
view-as alert-box QUESTION buttons YES-NO update v-update.
  if not v-update then do:
    FOR EACH gds-list:
      delete gds-list.
    END.
    FOR EACH save-list:
      delete save-list.
    END.
    return .
  end.
  run waitfram-show in this-procedure ("ЖДИТЕ.  Началось изменение справочника.").
  CASE ChangeOption :
    when "WeightValueList":U then do:
      Wvl:
      DO ON ERROR undo Wvl, return error :
        v-rep-rec = recid (locked_scales).
        /* чтоб не столкнуться при заполнении дыр */
        FIND FIRST b-scales WHERE recid (b-scales) = v-rep-rec exclusive-lock no-wait no-error.
        if locked(b-scales) then do:
          run waitfram-hide in this-procedure .
          message "В настоящий момент запись весов занята!" view-as alert-box ERROR.
          undo WVL, return error.
        end.
        FOR EACH gds-list,
            FIRST buf_goods WHERE
                  buf_goods.gds-code = gds-list.gds-code NO-LOCK,
            FIRST buf_gds-prt No-LOCK WHERE
                  buf_gds-prt.upper-code = buf_goods.prt-root,
            FIRST buf_bar-code No-LOCK WHERE
                  buf_bar-code.gds-code = buf_goods.gds-code AND
                  buf_bar-code.in-code = "":U and
                  buf_bar-code.part-code = "":U and
                  buf_bar-code.node-code = buf_gds-prt.node-code and
                  buf_bar-code.unit-cli = buf_goods.unit-base,
            FIRST buf_scales-gds WHERE
                  buf_scales-gds.db-num = locked_scales.db-num AND
                  buf_scales-gds.scales-num = locked_scales.scales-num AND
                  buf_scales-gds.b-code = buf_bar-code.b-code
         on error  undo wvl, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
         on stop   undo wvl, return error substitute( "&1. stop", vss-workfile )
         on endkey undo wvl, return error substitute( "&1. endkey", vss-workfile )
         :
            ACCUMULATE gds-list.artic ( count ).
            if ( accum count gds-list.artic ) modulo 10 = 0 then
              run waitfram-show in this-procedure ("Обработано товаров : " +
                                            string ( accum count gds-list.artic ) ) .
            if buf_scales-gds.plu-type <> integer({&sc-gds-weight}) then next.
            assign
            buf_scales-gds.to-send = TRUE
            buf_scales-gds.to-del = no
            buf_scales-gds.wt-cart = if from-card then buf_goods.wt-cart else WeightValue .
            b-scales.to-send = yes.
        END .
        release b-scales.
      END .
    end. /*when "WeightValueList":U then do:*/
    when "DeadValueList":U then do:
      DVL:
      DO ON error undo Dvl, return error :
        v-rep-rec = recid (locked_scales).
        /* чтоб не столкнуться при заполнении дыр */
        FIND FIRST b-scales WHERE recid (b-scales) = v-rep-rec exclusive-lock no-wait no-error.
        if locked(b-scales) then do:
          run waitfram-hide in this-procedure .
          message "В настоящий момент запись весов занята!" view-as alert-box ERROR.
          undo DVL, return error.
        end.
        FOR EACH gds-list,
          FIRST buf_goods WHERE
                buf_goods.gds-code = gds-list.gds-code NO-LOCK,
          FIRST buf_gds-prt No-LOCK WHERE
                buf_gds-prt.upper-code = buf_goods.prt-root,
          FIRST buf_bar-code No-LOCK WHERE
                buf_bar-code.gds-code = buf_goods.gds-code AND
                buf_bar-code.in-code = "":U and
                buf_bar-code.part-code = "":U and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.unit-cli = buf_goods.unit-base,
          FIRST buf_scales-gds WHERE
                buf_scales-gds.db-num = locked_scales.db-num AND
                buf_scales-gds.scales-num = locked_scales.scales-num AND
                buf_scales-gds.b-code = buf_bar-code.b-code
       on error  undo dvl, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
       on stop   undo dvl, return error substitute( "&1. stop", vss-workfile )
       on endkey undo dvl, return error substitute( "&1. endkey", vss-workfile )
       :
          ACCUMULATE gds-list.artic ( count ).
          if ( accum count gds-list.artic ) modulo 10 = 0 then
            run waitfram-show in this-procedure ("Обработано товаров : " +
                                          string ( accum count gds-list.artic ) ) .
          assign
          buf_scales-gds.to-send = TRUE
          buf_scales-gds.to-del = no
          b-scales.to-send = yes
          buf_scales-gds.deadflag = DeadValueRS
          .
          if buf_scales-gds.deadflag = integer({&sc-gds-deadflag-days}) then do:
            assign
            buf_scales-gds.deadline = if from-card
                                      then buf_goods.deadline
                                      else deadvalue
           .
          end.
          else do:
            assign
            buf_scales-gds.deaddate = if from-parts
                                      then scl-gds-ld-parts-date  ( buffer buf_scales-gds, input sclin-ld )
                                      else scl-gds-ld-to-date  ( input deadvalue)
            .
          end.

      END .
      release b-scales.
    end.
  END . /*when "DeadValueList":U then do:*/
  when "GDS-LIST":U then  do:
    v-rep-rec = recid (locked_scales).
    /* чтоб не столкнуться при заполнении дыр */
    _gds-list:
    do transaction:
      FIND FIRST b-scales WHERE recid (b-scales) = v-rep-rec exclusive-lock no-wait no-error.
      if locked(b-scales) then do:
        run waitfram-hide in this-procedure .
        message "В настоящий момент запись весов занята!" view-as alert-box ERROR.
        return error.
      end.
      ves-err = 0.
      _TO-GDS:
      FOR EACH gds-list,
        FIRST buf_goods WHERE
              buf_goods.gds-code = gds-list.gds-code NO-LOCK,
        FIRST buf_gds-prt No-LOCK WHERE
              buf_gds-prt.upper-code = buf_goods.prt-root,
        FIRST buf_bar-code No-LOCK WHERE
              buf_bar-code.gds-code = buf_goods.gds-code AND
              buf_bar-code.in-code = "":U and
              buf_bar-code.part-code = "":U and
              buf_bar-code.node-code = buf_gds-prt.node-code and
              buf_bar-code.unit-cli = buf_goods.unit-base
      on error  undo _gds-list, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _gds-list, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _gds-list, return error substitute( "&1. endkey", vss-workfile )
      :

        ACCUMULATE gds-list.artic ( count ).
        if ( accum count gds-list.artic ) modulo 100 = 0 then
        run waitfram-show in this-procedure ("ЖДИТЕ.  Обработано строк списка : " +
                                      string ( accum count gds-list.artic ) ) .
        if can-do( {&gds-office}, buf_goods.gds-type ) then
          NEXT _To-gds.
        FIND FIRST buf_units WHERE
                  buf_units.unit-name = buf_goods.unit-base NO-LOCK NO-ERROR.
        if buf_goods.unit-base <> b-scales.unit-base
        and lookup({&weight}, buf_units.type) > 0
        then do:
          ves-err = ves-err + 1.
          NEXT _to-gds.
        end.
        if lookup({&weight}, buf_units.type) = 0 then  do:
          if lookup(b-scales.scales-type, {&pg-scales-list}) = 0 then do:
            ves-err = ves-err + 1.
            NEXT _to-gds.
          end.
          if lookup({&pieces}, buf_units.type) > 0 then do:
            run trg/ispgwcod.p (input buf_bar-code.b-code
                              ,input yes /*p-question-pgweight*/
                              ,input no /*p-question-global*/
                              ,input yes /*p-question-on*/
                              ,input ""
                              ,output is-pgweight
                              ,output v-on
                              ,output v-b-str ) no-error.
            if error-status:error
            or not (is-pgweight and v-on) then do:
              ves-err = ves-err + 1.
              NEXT _to-gds.
            end.
          end. /*if lookup({&pieces}, buf_units.type) > 0 then do:*/
          else do:
            ves-err = ves-err + 1.
            NEXT _to-gds.
          end.
        end.
        do on stop undo, retry:
          if retry then do:
            ves-err = ves-err + 1.
            next _TO-GDS.
          end. /*do on stop undo, retry:*/
          FIND FIRST buf_scales-gds share-lock WHERE
                      buf_scales-gds.scales-num = b-scales.scales-num
                  AND buf_scales-gds.db-num = b-scales.db-num
                  and buf_scales-gds.b-code = buf_bar-code.b-code  NO-ERROR.
          if available buf_scales-gds then do:
            find first save-list where
                      save-list.gds-code = gds-list.gds-code no-error.
            if available save-list then do:
              save-list.to-del = no.
            end.
            buf_scales-gds.to-del = no.
          end. /*if available scales-gds then do:*/
          else do:
            if v-skip-next then do:
              delete gds-list.
            end.
            else do:
      _parts:
            for each buf_gds-obj no-lock where 
                buf_gds-obj.obj-type  = p-obj-type
            and buf_gds-obj.obj-code  = p-obj-code
            and buf_gds-obj.artic     = buf_goods.artic
            and buf_gds-obj.prod-type = buf_goods.prod-type
            and buf_gds-obj.prod-code = buf_goods.prod-code:
            for each buf_parts no-lock where
            buf_parts.artic     = buf_gds-obj.artic
            and buf_parts.prod-type = buf_gds-obj.prod-type
            and buf_parts.prod-code = buf_gds-obj.prod-code
            and buf_parts.out-code  = buf_gds-obj.in-code :

          if v-last-date = ? then next _parts.

          assign
          v-last-date = (if v-last-date = ?
                                          or (v-last-date <> ?
                                              and sclin-ld = 1
                                              and v-last-date > buf_parts.last-date)
                                          or (v-last-date <> ?
                                              and sclin-ld = 2
                                              and v-last-date < buf_parts.last-date)
                                              then buf_parts.last-date
                                              else v-last-date)
          .
        end. /*for each buf_parts*/
        end.
              run ref/ves-pbc.p (
                              input parparentproc
                            , input {&add-def}
                            , input p-obj-type
                            , input p-obj-code
                            , input (if sclin-ld > 0 then ? else buf_goods.deadline) /*p-deadline*/
                            , input (if sclin-ld > 0 then (v-last-date - 01/01/2000 + 1) * 24 else ?) /*p-deaddate*/
                            , input (if sclin-ld > 0 then integer({&sc-gds-deadflag-date}) else integer({&sc-gds-deadflag-days}))  /*p-deadflag*/
                            , input (if from-card then ? else 0) /*p-wt-cart*/
                            , buffer buf_bar-code
                            , buffer b-scales) no-error.
              if error-status:error then do:
                if return-value = "max-gds":U or return-value = "code-range":U then dO:
                  assign
                  v-skip-next = yes
                  ves-err = ves-err + 1.
                  NEXT _to-gds.
                end.
                else do:
				v-mess =  return-value .                  
				ves-err = ves-err + 1.
                  next _TO-GDS.
                end.
              end. /*if error-status:error then do*/
              else do:
                delete gds-list.
              end.
              if sclin-ld > 0 then do:
                find first buf2_scales-gds where
                          buf2_scales-gds.scales-num = b-scales.scales-num
                        and buf2_scales-gds.b-code = buf_bar-code.b-code
                        and buf2_scales-gds.db-num = b-scales.db-num no-error.
                if available buf2_scales-gds then do:
                  buf2_scales-gds.deaddate = scl-gds-ld-parts-date ( buffer buf2_scales-gds, input sclin-ld ).
                end.
              end. /*if sclin-ld > 0 then do:*/
            end. /*else if skip next*/
          end. /*else if available */
        end. /*do on stop*/
      END . /*FOR EACH gds-list*/
      if ves-err > 0 then do:
        message
        substitute("При добавления товаров на весы №&1 встретилось &2 НЕВЕСОВЫХ товаров&3" +
                    "или товаров, у которых ЕД. ИЗМ. НЕ СОВПАДАЕТ с ЕД. ИЗМ. ВЕСОВ&3" +
                    "или товаров, для которых не удалось создать весовой код&3" +
                    "или товаров, при добавлении которых было превышено количество товаров на весах&3&3" +
                    "или штучных товаров, которые не могут быть добавлены на весы данного типа&3&3" +
                    "                  Эти товары на весы НЕ ДОБАВЛЕНЫ !!!!"
                  ,b-scales.scales-num
                  ,ves-err
                  ,{&new-line}
				  ,v-mess)
        view-as alert-box warning.
      end. /*if ves-err > 0 then do:*/
      /* уничтожение лишних записей */
      _scales-gds:
      FOR EACH save-list WHERE
            save-list.to-del = yes,
         FIRST buf_goods WHERE
            buf_goods.gds-code = save-list.gds-code NO-LOCK,
          FIRST buf_gds-prt No-LOCK WHERE
                buf_gds-prt.upper-code = buf_goods.prt-root,
          FIRST buf_bar-code No-LOCK WHERE
                buf_bar-code.gds-code = buf_goods.gds-code AND
                buf_bar-code.in-code = "":U and
                buf_bar-code.part-code = "":U and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.unit-cli = buf_goods.unit-base,
          first buf_scales-gds share-lock where
                buf_scales-gds.db-num = b-scales.db-num
            AND buf_scales-gds.scales-num = b-scales.scales-num
            AND buf_scales-gds.b-code = buf_bar-code.b-code
        on error  undo _gds-list, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo _gds-list, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _gds-list, return error substitute( "&1. endkey", vss-workfile )
        :

        if obj-list and ( buf_scales-gds.obj-type <> p-obj-type or
                          buf_scales-gds.obj-code <> p-obj-code ) then
            NEXT _SCALES-GDS.
        find first gds-list where
                  gds-list.gds-code = save-list.gds-code no-error.
        if not available gds-list then do:
          assign
          buf_scales-gds.to-del = yes
          buf_scales-gds.to-send = no
          .
        end. /*if not available gds-list then do:*/
      END . /*FOR EACH save-list WHERE*/

      if b-scales.tot-gds <> 0 then  do:
        FIND LAST buf_scales-gds WHERE
                  buf_scales-gds.db-num = b-scales.db-num AND
                  buf_scales-gds.scales-num = b-scales.scales-num NO-LOCK use-index pi.
        if b-scales.max-plu < buf_scales-gds.PLU-code then
            b-scales.max-plu = buf_scales-gds.PLU-code .
        IF CAN-FIND(FIRST ub.scales-gds where
                        ub.scales-gds.db-num = b-scales.db-num AND
                        ub.scales-gds.scales-num = b-scales.scales-num AND
                        ub.scales-gds.to-send = yes) OR
          CAN-FIND(FIRST ub.scales-gds where
                        ub.scales-gds.db-num = b-scales.db-num AND
                        ub.scales-gds.scales-num = b-scales.scales-num AND
                        ub.scales-gds.to-del = yes)  then do:
          assign
          b-scales.to-send = yes.
        end.
      end.
      else b-scales.to-send = no.
      release b-scales.
    end. /*do transac*/
  end. /*when*/
END CASE .
run waitfram-hide in this-procedure .
RUN OpenBr .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ChangeOption-proc Dialog-Frame
PROCEDURE ChangeOption-proc :
CASE ChangeOption :
  when "GDS-LIST":U or when "":U then
    HIDE
    DeadValue in frame {&frame-name}
    WeightValue in FRAME {&FRAME-NAME}
    DeadValueDate in frame {&frame-name}
    DeadValueRS
    .
  when "WeightValue":U or when "WeightValueList" then  do:
    HIDE
    DeadValue
    DeadValueDAte
    DeadValueRS
    in FRAME {&FRAME-NAME}.
    if available X_scales-gds then assign
    WeightValue = X_scales-gds.wt-cart .
    VIEW WeightValue         in FRAME {&FRAME-NAME}.
    DISPLAY WeightValue with FRAME {&FRAME-NAME}.
    apply "entry" to WeightValue in FRAME {&FRAME-NAME}.
  end.
  when "DEadValue":U or when "DeadValueList" then  do:
    HIDE WeightValue in FRAME {&FRAME-NAME}.
    if available X_scales-gds then
    assign
    DeadValue = scl-gds-ld2(X_scales-gds.deadline, X_scales-gds.deaddate,  X_scales-gds.deadflag).
    VIEW
    DeadValue
    DeadValueDAte
    DeadValueRS
    in FRAME {&FRAME-NAME}.
    APPLY "VALUE-CHANGED" to DEadValueRS.
    DISPLAY
    DeadValue
    (TOday + DeadValue) @ DeadValueDate
    with FRAME {&FRAME-NAME}.
    apply "entry" to DeadValueRS in FRAME {&FRAME-NAME}.
  end.
END CASE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE DeadValue-Proc Dialog-Frame
PROCEDURE DeadValue-Proc :
define variable  src as recid no-undo.
define variable  dv as integer no-undo.
define variable dv-date as date no-undo .
define variable v-rep-rec as recid no-undo .
define buffer b-scales for ub.scales.
if CHangeOption = "DeadValue":U then do:
if available X_scales-gds then do:
    assign
    v-rep-rec = recid( X_scales-gds )
    src = recid(locked_scales)
    .
    if deadvaluers = integer({&sc-gds-deadflag-date}) then do:
      dv-date = scl-gds-ld-parts-date ( buffer X_scales-gds, input sclin-ld ).
    end.
    else do:
      dv = X_goods.deadline.
    end.
    DO on stop UNDO, return error :
      FIND FIRST b-scales-gds WHERE recid( b-scales-gds ) = v-rep-rec .
      FIND FIRST b-scales WHERE recid( b-scales ) = src Exclusive-lock no-wait no-error.
      if locked(b-scales) then do:
          run waitfram-hide in this-procedure .
          message
          "В настоящий момент запись весов занята!" view-as alert-box ERROR.
          undo , return no-apply.
      end.
      assign
      b-scales-gds.to-send = TRUE
      b-scales.to-send = TRUE
      b-scales-gds.deadflag = deadvaluers
      .
      if b-scales-gds.deadflag = integer({&sc-gds-deadflag-days}) then do:
        b-scales-gds.deadline = if from-card
                                then dv
                                else deadvalue.

      end.
      else do:
        b-scales-gds.deaddate = scl-gds-ld-to-date (deadvalue).
      end.
    END.
    RUN OpenBr IN THIS-PROCEDURE.
    reposition br-lst to recid v-rep-rec .
end.
end.
else do:
    run b-chg-proc no-error.
end.
ChangeOption = "".
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
  DISPLAY a-n-c loc-code loc-name loc-art DeadValueRS WeightValue DeadValue
          DeadValueDate mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel b-mark b-ticket b-chg PricePrint B-send b-hist b-help
         a-n-c loc-code loc-name loc-art DeadValueRS WeightValue DeadValue
         DeadValueDate br-lst-db br-lst mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gds-recid Dialog-Frame
PROCEDURE gds-recid :
DEFINE variable glog as logical no-undo .
if available X_goods then do:
  gds-rec = recid(X_goods).
end.
else do:
  gds-rec = ?.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-ii as integer no-undo .
define variable v-list-items as character no-undo .
FIND FIRST locked_scales no-lock WHERE
         locked_scales.db-num = p-db-num
     AND  locked_scales.scales-num = scalenum .
WeightValue:label IN FRAME {&FRAME-NAME} = substitute("&1(&2)"
                                                      ,WeightValue:label
                                                      ,locked_scales.unit-base ) .
if db-mode = "self" then do:
  hide
  br-lst-db
  in frame {&frame-name} .
end.
else do:
  hide
  br-lst
  in frame {&frame-name} .
end.
hide
loc-art in frame {&frame-name}
loc-name
loc-code in frame {&frame-name}.
do v-ii = 1 to num-entries ({&sc-gds-deadflags}):
  v-list-items = v-list-items  + (if v-ii = 1 then "" else {&comma-char}) +
                 entry(v-ii, {&sc-gds-deadflags-full}) + {&comma-char} +
                 entry(v-ii, {&sc-gds-deadflags}).

end.
assign
deadvaluers:radio-buttons in frame {&frame-name} = v-list-items.
assign
deadvaluers = if sclin-ld > 0
              then integer({&sc-gds-deadflag-date})
              else integer({&sc-gds-deadflag-days})
.
HIDE
mark-num
DeadValue
DeadValueDAte
DeadValueRS
WeightValue in FRAME {&FRAME-NAME}.
rid-list = p-rid-list.

DISABLE
b-mark WHEN lookup("b-mark", bttns ) = 0
b-sel WHEN lookup("b-sel", bttns ) = 0
b-chg WHEN lookup("b-chg", bttns ) = 0 or v-cntxt-db-num <> p-db-num
b-send WHEN lookup("b-chg", bttns ) = 0 or v-cntxt-db-num <> p-db-num
b-ticket when v-cntxt-db-num <> p-db-num
with FRAME {&FRAME-NAME}.
if db-mode = "self" then do:
  apply "entry" to br-lst in frame {&frame-name}.
end.
else do:
  apply "entry" to br-lst-db in frame {&frame-name}.
end.
if sclin-ld > 0 then do:
  assign
  menu-item m_from-parts:sensitive in menu menu-b-chg = yes
  menu-item m_from-card:label in menu menu-b-chg = "Вес <----из карточки товара"
  .
end.
else do:
  assign
  menu-item m_from-parts:sensitive in menu menu-b-chg = no
  menu-item m_from-card:label in menu menu-b-chg = "Вес и С.Г. <----из карточки товара"
  .
end.
FRAME {&FRAME-NAME}:title = substitute("&1  N &2 (&3 БД &4)"
                                      , FRAME {&FRAME-NAME}:title
                                      , string( scalenum )
                                      , locked_scales.scales-name
                                      , locked_scales.db-num).
run OpenBr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
DEFINE variable glog as logical no-undo .

IF db-mode = "self" THEN DO:
  OPEN QUERY br-lst
    FOR EACH X_scales-gds WHERE
            X_scales-gds.db-num = p-db-num  AND
            X_scales-gds.scales-num = scalenum NO-LOCK,
      FIRST X_bar-code WHERE
            X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
      FIRST X_goods WHERE
            X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
      FIRST X_gds-obj-attr WHERE
            X_gds-obj-attr.gds-code = X_bar-code.gds-code AND
            X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND
            X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND
            X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK,
      FIRST X_prod-bc WHERE
            X_prod-bc.b-str = X_gds-obj-attr.attr-value NO-LOCK
      BY X_scales-gds.PLU-code.

    if num-entries( rid-list ) = 0 then
        HIDE mark-num in frame Dialog-Frame.
    else
        DISPLAY num-entries( rid-list ) @ mark-num with frame {&frame-name}.
    apply "entry" to br-lst in frame {&frame-name} .
    if num-results( "br-lst" ) > 0 then
        assign
            glog = br-lst:select-row( 1 )
            glog = br-lst:scroll-to-selected-row( 1 ) .
    if rid-list <> '':U then do:
      REPOSITION br-lst to recid integer(entry(1, rid-list)) No-ERROR.
    end.

END.
else DO:
    OPEN QUERY br-lst-db
    FOR EACH X_scales-gds WHERE
            X_scales-gds.db-num = p-db-num  AND
            X_scales-gds.scales-num = scalenum NO-LOCK,
      FIRST X_bar-code WHERE
            X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
      FIRST X_goods WHERE
            X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
      FIRST X_gds-obj-attr WHERE
            X_gds-obj-attr.gds-code = X_bar-code.gds-code AND
            X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND
            X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND
            X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK,
      FIRST X_prod-bc-db NO-LOCK WHERE
            X_prod-bc-db.b-str = X_gds-obj-attr.attr-value
        AND X_prod-bc-db.db-num = p-db-num OUTER-JOIN
      BY X_scales-gds.PLU-code.

    if num-entries( rid-list ) = 0 then
        HIDE mark-num in frame Dialog-Frame.
    else
        DISPLAY num-entries( rid-list ) @ mark-num with frame {&frame-name}.
    apply "entry" to br-lst-db in frame {&frame-name} .
    if num-results( "br-lst-db" ) > 0 then
        assign
            glog = br-lst-db:select-row( 1 )
            glog = br-lst-db:scroll-to-selected-row( 1 ) .
    if rid-list <> '':U then do:
      REPOSITION br-lst-db to recid integer(entry(1, rid-list)) No-ERROR.
    end.

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-goods Dialog-Frame
PROCEDURE reposition-goods :
define input  parameter p-direction   as character no-undo .
define output parameter p-recid as recid no-undo .
/* перемещение на первую, последнюю, предыдущую, следующую */
case db-mode:
  when "self" then do:
    case p-direction :
      when "first":U
      then do:
        get first br-lst.
      end.
      when "last":U
      then do:
        get last br-lst.
      end.
      when "prev":U
      then do:
        get prev br-lst.
        if not available X_scales-gds then do:
          message
          "Это первый товар списка"
          view-as alert-box.
        end.
      end.
      when "next":U
      then do:
        get next br-lst.
        if not available X_scales-gds then do:
          message
          "Это последний товар списка"
          view-as alert-box.
        end.
      end.
    end case . /* p-direction */

  end.
  otherwise  do:
    case p-direction :
      when "first":U
      then do:
        get first br-lst-db.
      end.
      when "last":U
      then do:
        get last br-lst-db.
      end.
      when "prev":U
      then do:
        get prev br-lst-db.
        if not available X_scales-gds then do:
          message
          "Это первый товар списка"
          view-as alert-box.
        end.
      end.
      when "next":U
      then do:
        get next br-lst-db.
        if not available X_scales-gds then do:
          message
          "Это последний товар списка"
          view-as alert-box.
        end.
      end.
    end case . /* p-direction */
  end.
end case.
assign
p-recid = recid(X_goods)
.
if db-mode = "self" then do:
  run reposition-query in this-procedure
    (input recid(X_scales-gds)
    ).
end.
else do:
  run reposition-query-db in this-procedure
    (input recid(X_scales-gds)
    ).

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query Dialog-Frame
PROCEDURE reposition-query :
define input parameter p-recid as recid no-undo .

if p-recid <> ?
then do:
  reposition br-lst to recid p-recid no-error.
end.

do with frame {&frame-name}:
  apply "entry":u to browse {&browse-name} .
  apply "VALUE-CHANGED":u to browse {&browse-name} .
end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-query-db Dialog-Frame
PROCEDURE reposition-query-db :
define input parameter p-recid as recid no-undo .

if p-recid <> ?
then do:
  reposition br-lst-db to recid p-recid no-error.
end.

do with frame {&frame-name}:
  apply "entry":u to browse {&browse-name} .
  apply "VALUE-CHANGED":u to browse {&browse-name} .
end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE WeightValue-proc Dialog-Frame
PROCEDURE WeightValue-proc :
define variable  src as recid no-undo.
define variable  wv as decimal no-undo.
define variable v-rep-rec as recid no-undo .
define buffer b-scales for ub.scales.
if CHangeOption = "WeightValue":U then do:
  if available X_scales-gds then do:
    if X_scales-gds.plu-type <> integer({&sc-gds-weight}) then do:
      bell.
      message
      "Нельзя установить вес тары для PLU этого типа"
      view-as alert-box error  .
      undo, return error .
    end.
    assign
    v-rep-rec = recid( X_scales-gds )
    src = recid(locked_scales)
    wv = X_goods.wt-cart
    .
    DO on stop UNDO, return error :
        FIND FIRST b-scales-gds WHERE recid( b-scales-gds ) = v-rep-rec .
        FIND FIRST b-scales WHERE recid( b-scales ) = src Exclusive-lock No-WAit No-ERROR.
        if locked(b-scales) then do:
            run waitfram-hide in this-procedure .
            message
            "В настоящий момент запись весов занята!" view-as alert-box ERROR.
            undo , return no-apply.
        end.
        if b-scales-gds.plu-type <> integer({&sc-gds-weight}) then next.
        assign
            b-scales-gds.to-send = TRUE
            b-scales-gds.wt-cart = IF from-card then wv else WeightValue
            locked_scales.to-send = TRUE .
    END.
    RUN OpenBr IN THIS-PROCEDURE .
    reposition br-lst to recid v-rep-rec .
  end.
end.
else do:
            run b-chg-proc no-error.
end.
  ChangeOption = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-scl-code Dialog-Frame
FUNCTION get-scl-code RETURNS CHARACTER
   (    INPUT p-b-code AS INTEGER
     , INPUT p-b-str AS CHARACTER
     , BUFFER buf_prod-bc-db FOR ub.prod-bc-db ) :
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
IF AVAILABLE buf_prod-bc-db  THEN RETURN buf_prod-bc-db.b-str.
FIND FIRST buf_prod-bc NO-LOCK WHERE buf_prod-bc.b-code = p-b-code AND buf_prod-bc.b-str = p-b-str NO-ERROR.
IF AVAILABLE buf_prod-bc  THEN RETURN p-b-str.
RETURN {&question-mark}.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME