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

Товары на всех весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/14/05
Author: Bakhtadze Natalya
Creation date: 09/14/05

Author: Черных В.Г.
Created: 25/03/99

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-db-num   like ub.scales.db-num    no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Товары на всех весах".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/lib-trn.i }
{ cmp/showinf.i }
{ str/get-pr.i def }
{ ref/gdsoattr.i }
{ ref/sc-price.i }
{ str/libbcrcn.i }
{ gbl/getcntxt.i def }
{ ref/sclgdsld.i }
{ gbl/waitfram.i }

/* Local Variable Definitions ---                                       */

define variable temp-code like ub.scales-gds.b-code no-undo.
define variable rid-list    as  char    no-undo .
/*переменная цены товара*/
define variable scale-price as decimal.
define buffer l-goods for ub.goods.
define buffer l-scales-gds for ub.scales-gds.
define buffer l-bar-code for ub.bar-code.
define buffer l-prod-bc for ub.prod-bc.
define buffer l-prod-bc-db for ub.prod-bc-db.
define buffer l-gds-obj-attr for ub.gds-obj-attr.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable current-db-num like ub.scales-gds.db-num.
define variable current-scales like ub.scales-gds.scales-num.
define variable current-b-code like ub.scales-gds.b-code.
define variable current-plu like ub.scales-gds.plu-code.
define variable line-rec    as recid             no-undo.
define variable glog        as logical no-undo .
define variable gds-rec     as recid             no-undo.
define variable v-doc-rec   as recid no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable db-mode as character no-undo .
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
&Scoped-define FIELDS-IN-QUERY-br-lst IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") X_prod-bc.b-str X_goods.gds-name X_goods.artic X_scales-gds.scales-num X_scales-gds.PLU-code {&sc-gds-type-name} X_scales-gds.b-code get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) X_scales-gds.wt-cart {&sc-gds-deadflag-name} scl-gds-deadvalue( X_scales-gds.deadline, X_scales-gds.deaddate, X_scales-gds.deadflag) X_goods.grp-name X_goods.unit-base X_scales-gds.to-send X_scales-gds.to-del X_scales-gds.obj-type + STRING (X_scales-gds.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-lst
&Scoped-define SELF-NAME br-lst
&Scoped-define QUERY-STRING-br-lst FOR EACH X_scales-gds NO-LOCK, ~
             EACH X_bar-code OF X_scales-gds NO-LOCK, ~
             EACH X_goods OF X_bar-code NO-LOCK, ~
             EACH X_gds-obj-attr OF X_goods NO-LOCK, ~
             EACH X_prod-bc OF X_bar-code NO-LOCK     BY X_scales-gds.b-code      BY X_scales-gds.scales-num
&Scoped-define OPEN-QUERY-br-lst OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds NO-LOCK, ~
             EACH X_bar-code OF X_scales-gds NO-LOCK, ~
             EACH X_goods OF X_bar-code NO-LOCK, ~
             EACH X_gds-obj-attr OF X_goods NO-LOCK, ~
             EACH X_prod-bc OF X_bar-code NO-LOCK     BY X_scales-gds.b-code      BY X_scales-gds.scales-num.
&Scoped-define TABLES-IN-QUERY-br-lst X_scales-gds X_bar-code X_goods ~
X_gds-obj-attr X_prod-bc
&Scoped-define FIRST-TABLE-IN-QUERY-br-lst X_scales-gds
&Scoped-define SECOND-TABLE-IN-QUERY-br-lst X_bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-br-lst X_goods
&Scoped-define FOURTH-TABLE-IN-QUERY-br-lst X_gds-obj-attr
&Scoped-define FIFTH-TABLE-IN-QUERY-br-lst X_prod-bc


/* Definitions for BROWSE br-lst-db                                     */
&Scoped-define FIELDS-IN-QUERY-br-lst-db IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") get-scl-code( INPUT X_bar-code.b-code, INPUT X_gds-obj-attr.attr-value, BUFFER X_prod-bc-db) X_goods.gds-name X_goods.artic X_scales-gds.scales-num X_scales-gds.PLU-code {&sc-gds-type-name} X_scales-gds.b-code get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) X_scales-gds.wt-cart {&sc-gds-deadflag-name} scl-gds-deadvalue( X_scales-gds.deadline, X_scales-gds.deaddate, X_scales-gds.deadflag) X_goods.grp-name X_goods.unit-base X_scales-gds.to-send X_scales-gds.to-del X_scales-gds.obj-type + STRING (X_scales-gds.obj-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-lst-db
&Scoped-define SELF-NAME br-lst-db
&Scoped-define QUERY-STRING-br-lst-db FOR EACH X_scales-gds NO-LOCK, ~
             EACH X_bar-code OF X_scales-gds NO-LOCK, ~
             EACH X_goods OF X_bar-code NO-LOCK, ~
             EACH X_gds-obj-attr OF X_goods NO-LOCK, ~
             EACH X_prod-bc-db OF X_bar-code NO-LOCK OUTER-JOIN     BY X_scales-gds.b-code      BY X_scales-gds.scales-num
&Scoped-define OPEN-QUERY-br-lst-db OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds NO-LOCK, ~
             EACH X_bar-code OF X_scales-gds NO-LOCK, ~
             EACH X_goods OF X_bar-code NO-LOCK, ~
             EACH X_gds-obj-attr OF X_goods NO-LOCK, ~
             EACH X_prod-bc-db OF X_bar-code NO-LOCK OUTER-JOIN     BY X_scales-gds.b-code      BY X_scales-gds.scales-num.
&Scoped-define TABLES-IN-QUERY-br-lst-db X_scales-gds X_bar-code X_goods ~
X_gds-obj-attr X_prod-bc-db
&Scoped-define FIRST-TABLE-IN-QUERY-br-lst-db X_scales-gds
&Scoped-define SECOND-TABLE-IN-QUERY-br-lst-db X_bar-code
&Scoped-define THIRD-TABLE-IN-QUERY-br-lst-db X_goods
&Scoped-define FOURTH-TABLE-IN-QUERY-br-lst-db X_gds-obj-attr
&Scoped-define FIFTH-TABLE-IN-QUERY-br-lst-db X_prod-bc-db


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-lst}~
    ~{&OPEN-QUERY-br-lst-db}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OUT b-mark b-ticket b-hist b-help a-n-c ~
loc-art loc-name loc-code br-lst-db br-lst mark-num
&Scoped-Define DISPLAYED-OBJECTS a-n-c loc-art loc-name loc-code mark-num

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

/* Definitions of the field level widgets                               */
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

DEFINE BUTTON b-ticket
     LABEL "&Ценники"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_OUT AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 .

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
     SIZE 4.8 BY 1.13
     FGCOLOR 10  NO-UNDO.

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
X_prod-bc.b-str COLUMN-LABEL "Вес.код" FORMAT "X(7)":U
X_goods.gds-name FORMAT "X(30)":U
X_goods.artic FORMAT "X(16)":U
X_scales-gds.scales-num COLUMN-LABEL "Весы" FORMAT ">>9":U
X_scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT "99999":U
{&sc-gds-type-name} COLUMN-LABEL "Тип" format "x(3)"
X_scales-gds.b-code FORMAT "999999999":U
get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
X_scales-gds.wt-cart COLUMN-LABEL "Вес упак-ки" FORMAT ">>>,>>9.999":U
{&sc-gds-deadflag-name} COLUMN-LABEL "Тип ср.!годности" FORMAT "X(4)"
scl-gds-deadvalue( X_scales-gds.deadline,  X_scales-gds.deaddate, X_scales-gds.deadflag) COLUMN-LABEL "Срок годн." FORMAT "X(10)":U
X_goods.grp-name FORMAT "X(40)":U
X_goods.unit-base FORMAT "X(3)":U
X_scales-gds.to-send COLUMN-LABEL "И" FORMAT "+/-":U
X_scales-gds.to-del COLUMN-LABEL "У" FORMAT "!/":U
X_scales-gds.obj-type +  STRING (X_scales-gds.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.4
         BGCOLOR 15 FGCOLOR 0 .

DEFINE BROWSE br-lst-db
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-lst-db Dialog-Frame _FREEFORM
  QUERY br-lst-db NO-LOCK DISPLAY
      IF ( CAN-DO (rid-list, STRING ( recid( X_scales-gds) ) ) ) THEN ("*") ELSE (" ") COLUMN-LABEL "*" FORMAT "X(1)":U
get-scl-code( INPUT X_bar-code.b-code, INPUT X_gds-obj-attr.attr-value, BUFFER X_prod-bc-db) COLUMN-LABEL "Вес.код" FORMAT "X(7)":U
X_goods.gds-name FORMAT "X(30)":U
X_goods.artic FORMAT "X(16)":U
X_scales-gds.scales-num COLUMN-LABEL "Весы" FORMAT ">>9":U
X_scales-gds.PLU-code COLUMN-LABEL "PLU" FORMAT "99999":U
{&sc-gds-type-name} COLUMN-LABEL "Тип" format "x(3)"
X_scales-gds.b-code FORMAT "999999999":U
get-price(buffer X_goods , input X_scales-gds.obj-type, input X_scales-gds.obj-code, input X_scales-gds.b-code) COLUMN-LABEL "Цена" FORMAT ">>>,>>9.99":U
X_scales-gds.wt-cart COLUMN-LABEL "Вес упак-ки" FORMAT ">>>,>>9.999":U
{&sc-gds-deadflag-name} COLUMN-LABEL "Тип ср.!годности" FORMAT "X(4)"
scl-gds-deadvalue( X_scales-gds.deadline,  X_scales-gds.deaddate, X_scales-gds.deadflag) COLUMN-LABEL "Срок годн." FORMAT "X(10)":U
X_goods.grp-name FORMAT "X(40)":U
X_goods.unit-base FORMAT "X(3)":U
X_scales-gds.to-send COLUMN-LABEL "И" FORMAT "+/-":U
X_scales-gds.to-del COLUMN-LABEL "У" FORMAT "!/":U
X_scales-gds.obj-type +  STRING (X_scales-gds.obj-code) COLUMN-LABEL "Объект" FORMAT "X(8)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.4
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OUT AT ROW 1 COL 1
     b-mark AT ROW 1 COL 11
     b-ticket AT ROW 1 COL 24
     b-hist AT ROW 1 COL 92
     b-help AT ROW 1 COL 95
     a-n-c AT ROW 3.17 COL 12.5 NO-LABEL
     loc-art AT ROW 3.17 COL 69.8 COLON-ALIGNED
     loc-name AT ROW 3.17 COL 69.8 COLON-ALIGNED
     loc-code AT ROW 3.17 COL 69.8 COLON-ALIGNED
     br-lst-db AT ROW 5 COL 1 WIDGET-ID 100
     br-lst AT ROW 5 COL 1
     mark-num AT ROW 1 COL 12 COLON-ALIGNED NO-LABEL
     "Поиск :" VIEW-AS TEXT
          SIZE 7.9 BY 1 AT ROW 3.17 COL 4
          BGCOLOR 8 FGCOLOR 0
     SPACE(87.29) SKIP(19.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE "ВСЕ товары на ВСЕХ весах".


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
/* BROWSE-TAB br-lst-db loc-code Dialog-Frame */
/* BROWSE-TAB br-lst br-lst-db Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-lst:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

ASSIGN
       br-lst-db:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 1.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-lst
/* Query rebuild information for BROWSE br-lst
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds NO-LOCK,
      EACH X_bar-code OF X_scales-gds NO-LOCK,
      EACH X_goods OF X_bar-code NO-LOCK,
      EACH X_gds-obj-attr OF X_goods NO-LOCK,
      EACH X_prod-bc OF X_bar-code NO-LOCK
    BY X_scales-gds.b-code
     BY X_scales-gds.scales-num.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,,,"
     _OrdList          = "ub.scales-gds.b-code|yes,ub.scales-gds.scales-num|yes"
     _JoinCode[2]      = "bar-code.b-code = scales-gds.b-code"
     _JoinCode[3]      = "goods.gds-code = bar-code.gds-code"
     _JoinCode[5]      = "prod-bc.b-str = gds-obj-attr.attr-value"
     _Query            is OPENED
*/  /* BROWSE br-lst */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-lst-db
/* Query rebuild information for BROWSE br-lst-db
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_scales-gds NO-LOCK,
      EACH X_bar-code OF X_scales-gds NO-LOCK,
      EACH X_goods OF X_bar-code NO-LOCK,
      EACH X_gds-obj-attr OF X_goods NO-LOCK,
      EACH X_prod-bc-db OF X_bar-code NO-LOCK OUTER-JOIN
    BY X_scales-gds.b-code
     BY X_scales-gds.scales-num.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _TblOptList       = ",,,,"
     _OrdList          = "ub.scales-gds.b-code|yes,ub.scales-gds.scales-num|yes"
     _JoinCode[2]      = "bar-code.b-code = scales-gds.b-code"
     _JoinCode[3]      = "goods.gds-code = bar-code.gds-code"
     _JoinCode[5]      = "prod-bc.b-str = gds-obj-attr.attr-value"
     _Query            is OPENED
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* ВСЕ товары на ВСЕХ весах */
DO:
  APPLY "END-ERROR":U TO SELF.
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
    if db-mode = "self" then do:
      glog = br-lst:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        glog = br-lst:select-next-row ().
        apply "iteration-changed" to br-lst in frame {&frame-name}.
      end.
      if num-entries( rid-list ) = 0 then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
      apply "entry" to br-lst in frame {&frame-name}.
    end.
    else do:
      glog = br-lst-db:refresh() .

      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        glog = br-lst-db:select-next-row ().
        apply "iteration-changed" to br-lst-db in frame {&frame-name}.
      end.
      if num-entries( rid-list ) = 0 then
          hide mark-num in frame {&frame-name}.
      else
          disp num-entries( rid-list ) @ mark-num with frame {&frame-name}.
      apply "entry" to br-lst-db in frame {&frame-name}.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ticket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ticket Dialog-Frame
ON CHOOSE OF b-ticket IN FRAME Dialog-Frame /* Ценники */
DO:
    if available X_scales-gds then  do:
      if rid-list = "" then
          run rep/tick-scl.p (
                         input parparentproc
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input recid( X_bar-code )
                        ,input X_scales-gds.db-num
                        ,input X_scales-gds.scales-num
                        ,input "" ) .
      else
          run rep/tick-scl.p (
                           input parparentproc
                          ,input p-obj-type
                          ,input p-obj-code
                          ,input ?
                          ,input ?
                          ,input ?
                          ,input rid-list ) .
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
DO:
 define variable v-gds-rec as recid no-undo .
    if available X_scales-gds then do:
      v-gds-rec = recid(X_goods).
      run ref/gds-form.w ( input parparentproc
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
                         , input-output gds-rec).
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
DO:
 define variable v-gds-rec as recid no-undo .
    if available X_scales-gds then do:
      v-gds-rec = recid(ub.goods).
      run ref/gds-form.w ( input parparentproc
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-lst-db Dialog-Frame
ON RETURN OF br-lst-db IN FRAME Dialog-Frame
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
                        , input-output gds-rec).
  end.
  apply "entry" to br-lst-db in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-lst
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ ref/scl-sch.i scales-gds br-lst scalegds goods X_scales-gds }
end.



/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/f2.i br-lst goods-recid gds-recid parparentproc " " THIS-PROCEDURE:HANDLE }
{ gbl/brwrepos.i
&line-num=5 }
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_scales-gds then v-doc-rec = recid(X_scales-gds). run openbr in this-procedure . ~
if db-mode = 'self' then reposition br-lst to recid(v-doc-rec). else reposition br-lst-db to recid(v-doc-rec). v-doc-rec = ? . " }

{ gbl/mv-clmn.i
&browse-name = "br-lst"
&frame-name = "{&frame-name}"
&ext-col = 17
&start-column = 6}


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
    { gbl/getcntxt.i get }
    { str/sclspref.i varscales-pref varpgscales-pref }

    IF p-db-num = v-cntxt-db-num THEN DO:
      db-mode = "self".
    END.
    ELSE DO:
       db-mode = "0".
    END.
    RUN Myenable in this-procedure .
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.

END.
RUN disable_UI in this-procedure .

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
  DISPLAY a-n-c loc-art loc-name loc-code mark-num
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OUT b-mark b-ticket b-hist b-help a-n-c loc-art loc-name loc-code
         br-lst-db br-lst mark-num
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
DISPLAY mark-num
WITH FRAME {&frame-name}.
ENABLE
b-mark
b-ticket
b-help
b-hist
Btn_OUT
br-lst  when db-mode = "self"
br-lst-db  when db-mode = "0"
mark-num
a-n-c
WITH FRAME {&frame-name}.
hide
loc-art in frame {&frame-name}
loc-name loc-code in frame {&frame-name}
mark-num in frame {&frame-name}.
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
VIEW FRAME {&frame-name}.
run Openbr IN THIS-PROCEDURE.
Assign frame {&frame-name}:title = substitute("&1 БД &2", frame {&frame-name}:title, p-db-num).
if v-cntxt-db-num <> p-db-num then do:
  disable
  b-ticket
  with frame {&frame-name} .
end.
if db-mode = "self" then do:
apply "entry" to br-lst in frame {&frame-name} .
assign
glog = br-lst:select-row( 1 )
glog = br-lst:scroll-to-selected-row( 1 ) .
end.
else do:
  apply "entry" to br-lst-db in frame {&frame-name} .
  assign
  glog = br-lst-db:select-row( 1 )
  glog = br-lst-db:scroll-to-selected-row( 1 ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define variable glog as logical no-undo .
run waitfram-show in this-procedure ( input "Ждите..." ).
if db-mode = "self" then do:
  OPEN QUERY br-lst
  FOR EACH X_scales-gds NO-LOCK where X_scales-gds.db-num = p-db-num,
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
            BY X_scales-gds.b-code
            BY X_scales-gds.scales-num.

  if num-entries( rid-list ) = 0 then
      HIDE mark-num in frame {&frame-name}.
  else
      DISPLAY num-entries( rid-list ) @ mark-num with frame {&frame-name}.
  apply "entry" to br-lst in frame {&frame-name} .
  if num-results( "br-lst" ) > 0 then
      assign
          glog = br-lst:select-row( 1 )
          glog = br-lst:scroll-to-selected-row( 1 ) .
end.
else do:
  OPEN QUERY br-lst-db
  FOR EACH X_scales-gds NO-LOCK where X_scales-gds.db-num = p-db-num,
    FIRST X_bar-code WHERE
          X_bar-code.b-code = X_scales-gds.b-code NO-LOCK,
    FIRST X_goods WHERE
          X_goods.gds-code = X_bar-code.gds-code NO-LOCK,
    FIRST X_gds-obj-attr WHERE
          X_gds-obj-attr.gds-code = X_bar-code.gds-code AND
          X_gds-obj-attr.obj-type = X_scales-gds.obj-type AND
          X_gds-obj-attr.obj-code = X_scales-gds.obj-code AND
          X_gds-obj-attr.attr-code = {&attr-scales-code-o} NO-LOCK,
    FIRST X_prod-bc-db no-lock WHERE
          X_prod-bc-db.b-str = X_gds-obj-attr.attr-value
     and  X_prod-bc-db.db-num = p-db-num OUTER-JOIN
            BY X_scales-gds.b-code
            BY X_scales-gds.scales-num.

  if num-entries( rid-list ) = 0 then
      HIDE mark-num in frame {&frame-name}.
  else
      DISPLAY num-entries( rid-list ) @ mark-num with frame {&frame-name}.
  apply "entry" to br-lst-db in frame {&frame-name} .
  if num-results( "br-lst-db" ) > 0 then
      assign
          glog = br-lst-db:select-row( 1 )
          glog = br-lst-db:scroll-to-selected-row( 1 ) .

end.
run waitfram-hide in this-procedure .
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