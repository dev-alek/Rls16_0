&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_layout FOR ub.layout.
DEFINE TEMP-TABLE tt-layout NO-UNDO LIKE ub.layout.
DEFINE TEMP-TABLE tt-layout-elem NO-UNDO LIKE ub.layout-elem
       field is-defined as logical.
DEFINE TEMP-TABLE tt-layout-elem-rule NO-UNDO LIKE ub.layout-elem-rule.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_layout-elem FOR ub.layout-elem.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER x_ruledict-param FOR ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма Редактирования Раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-layout-id as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма Редактирования Раскладки".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/key-rec.i }
{ gbl/cd-mode1.i }
{ adm/cd-mode2.i  def }
{ cmp/titlmode.i }
{ rul/rulcalpa.i }

DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
define variable v-admin as logical no-undo .
define variable v-is-copy as logical no-undo .
define variable V-IS-DEFAULT as integer no-undo .
define variable GLOG as logical no-undo .
DEFINE BUFFER buf_layout FOR ub.layout.
DEFINE BUFFER FIRST_layout FOR ub.layout.

DEFINE VARIABLE v-gl-call#-id AS INTEGER NO-UNDO init -100000.
&scop br-rule-call-param-label1 "Значение"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-available

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-layout-elem tt-layout-elem-rule X_rule ~
tt-rule-call-param tt-layout

/* Definitions for BROWSE BR-available                                  */
&Scoped-define FIELDS-IN-QUERY-BR-available tt-layout-elem.mode-id tt-layout-elem.widget-id tt-layout-elem.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-available
&Scoped-define SELF-NAME BR-available
&Scoped-define QUERY-STRING-BR-available FOR EACH tt-layout-elem WHERE tt-layout-elem.is-define = no INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-available OPEN QUERY {&SELF-NAME} FOR EACH tt-layout-elem WHERE tt-layout-elem.is-define = no INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-available tt-layout-elem
&Scoped-define FIRST-TABLE-IN-QUERY-BR-available tt-layout-elem


/* Definitions for BROWSE BR-layout-elem-rule                           */
&Scoped-define FIELDS-IN-QUERY-BR-layout-elem-rule tt-layout-elem-rule.widget-id tt-layout-elem-rule.is-mandatory = INTEGER({&layout-elem-rule-mandatory}) tt-layout-elem-rule.mode-id tt-layout-elem-rule.rule_id tt-layout-elem-rule.elem-label X_rule.name (IF tt-layout-elem-rule.sts = INTEGER({&deleted-status-int}) THEN "+" ELSE "")
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-layout-elem-rule
&Scoped-define SELF-NAME BR-layout-elem-rule
&Scoped-define QUERY-STRING-BR-layout-elem-rule FOR EACH tt-layout-elem-rule NO-LOCK  where tt-layout-elem-rule.layout-id = tt-layout.layout-id, ~
       first X_rule OUTER-JOIN NO-LOCK where X_rule.rule_id = tt-layout-elem-rule.rule_id INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-layout-elem-rule OPEN QUERY {&SELF-NAME} FOR EACH tt-layout-elem-rule NO-LOCK  where tt-layout-elem-rule.layout-id = tt-layout.layout-id, ~
       first X_rule OUTER-JOIN NO-LOCK where X_rule.rule_id = tt-layout-elem-rule.rule_id INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-layout-elem-rule tt-layout-elem-rule ~
X_rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-layout-elem-rule tt-layout-elem-rule
&Scoped-define SECOND-TABLE-IN-QUERY-BR-layout-elem-rule X_rule


/* Definitions for BROWSE BR-rule-call-params                           */
&Scoped-define FIELDS-IN-QUERY-BR-rule-call-params tt-rule-call-param.param-name tt-rule-call-param.param-label tt-rule-call-param.param-data-type get-param-value( INPUT tt-rule-call-param.param-data-type ,INPUT tt-rule-call-param.param-2-data-type ,INPUT tt-rule-call-param.param-3-data-type ,INPUT tt-rule-call-param.p-index ,INPUT tt-rule-call-param.param-value-character ,INPUT tt-rule-call-param.param-value-date ,INPUT tt-rule-call-param.param-value-decimal ,INPUT tt-rule-call-param.param-value-integer ,INPUT tt-rule-call-param.param-value-logical)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rule-call-params
&Scoped-define SELF-NAME BR-rule-call-params
&Scoped-define QUERY-STRING-BR-rule-call-params FOR EACH tt-rule-call-param WHERE TRUE /* Join to tt-layout incomplete */ NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-rule-call-params OPEN QUERY {&SELF-NAME} FOR EACH tt-rule-call-param WHERE TRUE /* Join to tt-layout incomplete */ NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-rule-call-params tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rule-call-params tt-rule-call-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define SELF-NAME Dialog-Frame
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-layout SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY {&SELF-NAME} FOR EACH tt-layout SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-layout
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-layout


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-layout.layout-id tt-layout.is-default ~
tt-layout.layout-name tt-layout.des
&Scoped-define ENABLED-TABLES tt-layout
&Scoped-define FIRST-ENABLED-TABLE tt-layout
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-chg b-lkp CB-mode-id ~
BR-layout-elem-rule b-br-available BR-available f-elem-label e-elem-tooltip ~
B-add B-del BR-rule-call-params
&Scoped-Define DISPLAYED-FIELDS tt-layout.layout-id tt-layout.layout-type ~
tt-layout.is-default tt-layout.device-type tt-layout.layout-name ~
tt-layout.des
&Scoped-define DISPLAYED-TABLES tt-layout
&Scoped-define FIRST-DISPLAYED-TABLE tt-layout
&Scoped-Define DISPLAYED-OBJECTS CB-mode-id f-elem-label e-elem-tooltip ~
f-image-id-up f-image-id-down f-image-id-insen l-elem-tooltip

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-call#-id Dialog-Frame
FUNCTION get-call#-id RETURNS INTEGER
  ( INPUT p-call-id AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "<-"
     SIZE 3 BY 1.

DEFINE BUTTON b-br-available
     LABEL "Элементы, доступные для определения"
     SIZE 37 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "->"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 11 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE CB-mode-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Режим"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 44 BY 1 NO-UNDO.

DEFINE VARIABLE e-elem-tooltip AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL
     SIZE 37 BY 2 NO-UNDO.

DEFINE VARIABLE f-elem-label AS CHARACTER FORMAT "X(256)":U
     LABEL "Лейбл"
     VIEW-AS FILL-IN NATIVE
     SIZE 29.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-image-id-down AS CHARACTER FORMAT "X(256)":U
     LABEL "DOWN"
     VIEW-AS FILL-IN NATIVE
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE f-image-id-insen AS CHARACTER FORMAT "X(256)":U
     LABEL "INSEN"
     VIEW-AS FILL-IN NATIVE
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE f-image-id-up AS CHARACTER FORMAT "X(256)":U
     LABEL "UP"
     VIEW-AS FILL-IN NATIVE
     SIZE 31 BY 1 NO-UNDO.

DEFINE VARIABLE l-elem-tooltip AS CHARACTER FORMAT "X(256)":U INITIAL "Тултип"
      VIEW-AS TEXT
     SIZE 31 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-available FOR
      tt-layout-elem SCROLLING.

DEFINE QUERY BR-layout-elem-rule FOR
      tt-layout-elem-rule,
      X_rule SCROLLING.

DEFINE QUERY BR-rule-call-params FOR
      tt-rule-call-param SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-layout SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-available
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-available Dialog-Frame _FREEFORM
  QUERY BR-available NO-LOCK DISPLAY
      tt-layout-elem.mode-id column-label "Режим"
tt-layout-elem.widget-id column-label "ID Элемента"
tt-layout-elem.des column-label ""
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 34 BY 16.27
         TITLE "Элементы, доступные для определения" FIT-LAST-COLUMN.

DEFINE BROWSE BR-layout-elem-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-layout-elem-rule Dialog-Frame _FREEFORM
  QUERY BR-layout-elem-rule NO-LOCK DISPLAY
      tt-layout-elem-rule.widget-id FORMAT "x(8)":U column-label "Элемент"
tt-layout-elem-rule.is-mandatory = INTEGER({&layout-elem-rule-mandatory}) FORMAT "+/" COLUMN-LABEL "Обяз"
tt-layout-elem-rule.mode-id FORMAT "x(5)":U column-label "Режим"
tt-layout-elem-rule.rule_id FORMAT ">>>>>>>>9":U column-label "Правило"
tt-layout-elem-rule.elem-label FORMAT "X(8)" column-label "Лейбл"
X_rule.name column-label "Функция" FORMAT "X(255)":U width 70
(IF tt-layout-elem-rule.sts = INTEGER({&deleted-status-int}) THEN "+" ELSE "") COLUMN-LABEL "уд" WIDTH 4
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61 BY 11
         TITLE "Функции, определенные для элементов раскладки" FIT-LAST-COLUMN.

DEFINE BROWSE BR-rule-call-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rule-call-params Dialog-Frame _FREEFORM
  QUERY BR-rule-call-params NO-LOCK DISPLAY
      tt-rule-call-param.param-name column-label "Название"
tt-rule-call-param.param-label column-label "Название"
tt-rule-call-param.param-data-type column-label  "Тип!данных"
get-param-value( INPUT tt-rule-call-param.param-data-type
                ,INPUT tt-rule-call-param.param-2-data-type
                ,INPUT tt-rule-call-param.param-3-data-type
                ,INPUT tt-rule-call-param.p-index
                ,INPUT tt-rule-call-param.param-value-character
                ,INPUT tt-rule-call-param.param-value-date
                ,INPUT tt-rule-call-param.param-value-decimal
                ,INPUT tt-rule-call-param.param-value-integer
                ,INPUT tt-rule-call-param.param-value-logical) column-label {&br-rule-call-param-label1}
format "X(255)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64 BY 5.27
         TITLE "Параметры" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-layout.layout-id AT ROW 1 COL 45 COLON-ALIGNED WIDGET-ID 38 FORMAT "x(48)"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     B-Help AT ROW 1 COL 95
     tt-layout.layout-type AT ROW 2 COL 15 COLON-ALIGNED WIDGET-ID 14 FORMAT "x(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     tt-layout.is-default AT ROW 2 COL 66 COLON-ALIGNED NO-LABEL WIDGET-ID 108 FORMAT "->>9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "0",1
          DROP-DOWN-LIST
          SIZE 26.5 BY 1
     tt-layout.device-type AT ROW 3 COL 15 COLON-ALIGNED WIDGET-ID 62
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     tt-layout.layout-name AT ROW 4 COL 7 WIDGET-ID 64
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 35 BY 1
     tt-layout.des AT ROW 5 COL 15 COLON-ALIGNED WIDGET-ID 110
          LABEL "Описание" FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 81.5 BY 1
     B-chg AT ROW 6 COL 1 WIDGET-ID 68
     b-lkp AT ROW 6 COL 11 WIDGET-ID 98
     CB-mode-id AT ROW 6 COL 30 WIDGET-ID 20
     BR-layout-elem-rule AT ROW 7 COL 1 WIDGET-ID 100
     b-br-available AT ROW 7 COL 62.5 WIDGET-ID 96
     BR-available AT ROW 7 COL 65.5 WIDGET-ID 200
     f-elem-label AT ROW 8 COL 68 COLON-ALIGNED WIDGET-ID 74
     e-elem-tooltip AT ROW 10 COL 62 NO-LABEL WIDGET-ID 76
     B-add AT ROW 10 COL 62.5 WIDGET-ID 66
     B-del AT ROW 11 COL 62.5 WIDGET-ID 70
     f-image-id-up AT ROW 13 COL 66 COLON-ALIGNED WIDGET-ID 78
     f-image-id-down AT ROW 14 COL 66 COLON-ALIGNED WIDGET-ID 82
     f-image-id-insen AT ROW 15 COL 66 COLON-ALIGNED WIDGET-ID 84
     BR-rule-call-params AT ROW 18 COL 1 WIDGET-ID 300
     l-elem-tooltip AT ROW 9 COL 64.5 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     SPACE(2.00) SKIP(13.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_layout B "?" ? ub layout
      TABLE: tt-layout T "?" NO-UNDO ub layout
      TABLE: tt-layout-elem T "?" NO-UNDO ub layout-elem
      ADDITIONAL-FIELDS:
          field is-defined as logical
      END-FIELDS.
      TABLE: tt-layout-elem-rule T "?" NO-UNDO ub layout-elem-rule
      TABLE: tt-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_layout-elem B "?" ? ub layout-elem
      TABLE: X_rule B "?" ? ub rule
      TABLE: x_ruledict-param B "?" ? ub ruledict-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-layout-elem-rule CB-mode-id Dialog-Frame */
/* BROWSE-TAB BR-available b-br-available Dialog-Frame */
/* BROWSE-TAB BR-rule-call-params f-image-id-insen Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-br-available:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       b-quit:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX CB-mode-id IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-layout.des IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR COMBO-BOX tt-layout.device-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       e-elem-tooltip:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-elem-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-image-id-down IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-image-id-down:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-image-id-insen IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-image-id-insen:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-image-id-up IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-image-id-up:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX tt-layout.is-default IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN l-elem-tooltip IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       l-elem-tooltip:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-layout.layout-id IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt-layout.layout-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR COMBO-BOX tt-layout.layout-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-FORMAT                                                 */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-available
/* Query rebuild information for BROWSE BR-available
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt-layout-elem WHERE
tt-layout-elem.is-define = no INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-available */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-layout-elem-rule
/* Query rebuild information for BROWSE BR-layout-elem-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt-layout-elem-rule NO-LOCK  where
tt-layout-elem-rule.layout-id = tt-layout.layout-id,
first X_rule OUTER-JOIN NO-LOCK where X_rule.rule_id = tt-layout-elem-rule.rule_id INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-layout-elem-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rule-call-params
/* Query rebuild information for BROWSE BR-rule-call-params
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-rule-call-param WHERE TRUE /* Join to tt-layout incomplete */ NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-rule-call-params */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-layout SHARE-LOCK.
     _END_FREEFORM
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* <- */
DO:
  if not available tt-layout-elem then do:
     bell.
     return no-apply.
  end.
  run proc-b-add in this-procedure ( input tt-layout-elem.mode-id
                                    ,input tt-layout-elem.widget-id).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-br-available
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-br-available Dialog-Frame
ON CHOOSE OF b-br-available IN FRAME Dialog-Frame /* Элементы, доступные для определения */
DO:

  run proc-view-br-available in this-procedure no-error.
  if not error-status:error then do:
    hide
    b-br-available
    in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE BUFFER buf_tt-layout-elem-rule FOR tt-layout-elem-rule.
  DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
  define variable v-mode-id as character no-undo .
  define variable v-rule-id as integer no-undo .
  define variable v-recid as recid no-undo .
  IF NOT AVAILABLE tt-layout-elem-rule THEN RETURN NO-APPLY.
  assign
  v-mode-id = tt-layout-elem-rule.mode-id.
  v-rule-id = tt-layout-elem-rule.rule_id
  .
  run adm/layeruli.w ( input parparentproc
                    ,input ({&UPDATE} + (if v-admin then ({&comma-char} + "admin") else ''))
                    ,input tt-layout-elem-rule.uniq-key-rec
                    ,input tt-layout.device-type
                    ,input-output table buf_tt-layout-elem-rule
                    ,input-output table tt-rule-call-param
                    ,output v-ok
                    ) no-error.

  run openbr in this-procedure no-error.
  find first buf_tt-layout-elem-rule where
          buf_tt-layout-elem-rule.mode-id = v-mode-id
      and buf_tt-layout-elem-rule.rule_id = v-rule-id.
  v-recid = recid(buf_tt-layout-elem-rule).
  reposition br-layout-elem-rule to recid v-recid no-error.
  apply "entry" to br-layout-elem-rule in frame {&frame-name} .
  apply "value-changed" to br-layout-elem-rule in frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* -> */
DO:
  if not available tt-layout-elem-rule then do:
     bell.
     return no-apply.
  end.
  run proc-b-del in this-procedure ( input tt-layout-elem-rule.mode-id
                                    ,input tt-layout-elem-rule.widget-id).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
  if not available tt-layout-elem-rule then do:
    bell.
    return no-apply.
  end.
  run proc-layout-elem-rule-i in this-procedure ( buffer tt-layout-elem-rule) no-error.
  if not error-status:error then do:
     hide
     b-lkp
     in frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-layout-elem-rule
&Scoped-define SELF-NAME BR-layout-elem-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-layout-elem-rule Dialog-Frame
ON VALUE-CHANGED OF BR-layout-elem-rule IN FRAME Dialog-Frame /* Функции, определенные для элементов раскладки */
DO:
  run Openbr3 in this-procedure no-error.
  if f-elem-label:visible in  frame {&frame-name} then do:
    if available tt-layout-elem-rule then do:
      display
      tt-layout-elem-rule.elem-label @ f-elem-label
      tt-layout-elem-rule.image-id-up @ f-image-id-up
      tt-layout-elem-rule.image-id-down @ f-image-id-down
      tt-layout-elem-rule.image-id-insen @ f-image-id-insen
      with frame {&frame-name}.
      assign
      e-elem-tooltip:screen-value = tt-layout-elem-rule.elem-tooltip.
    end.
    else do:
      display
      '' @ f-elem-label
      '' @ f-image-id-up
      '' @ f-image-id-down
      '' @ f-image-id-insen
      with frame {&frame-name}.
      assign
      e-elem-tooltip:screen-value = ''.

    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME CB-mode-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL CB-mode-id Dialog-Frame
ON VALUE-CHANGED OF CB-mode-id IN FRAME Dialog-Frame /* Режим */
DO:
  assign
  cb-mode-id.
  run openbr in this-procedure no-error.
  run openbr2 in this-procedure no-error.
  reposition br-layout-elem-rule to row 1 no-error.
  apply "entry" to br-layout-elem-rule in frame {&frame-name} .
  apply "value-changed" to br-layout-elem-rule in frame {&frame-name} .
  run process-add-del in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-layout.device-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-layout.device-type Dialog-Frame
ON VALUE-CHANGED OF tt-layout.device-type IN FRAME Dialog-Frame /* Тип устройства */
DO:
  RUN proc-value-change-device-type IN THIS-PROCEDURE ( INPUT YES) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-layout.layout-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-layout.layout-type Dialog-Frame
ON VALUE-CHANGED OF tt-layout.layout-type IN FRAME Dialog-Frame /* Тип раскладки */
DO:
  RUN proc-value-change-layout-type IN THIS-PROCEDURE ( INPUT YES).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-available
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), {&comma-char}).
  end.
  if lookup(p-mode, {&add-def} + {&comma-char} +
                    {&add-copy} + {&comma-char} +
                    {&update} + {&comma-char} +
                    {&lookup}) = 0 then  do:
    message
    substitute("Неверное значение параметра p-mode = &1", p-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if p-mode = {&add-copy} then do:
    assign
    v-is-copy = yes
    p-mode = {&add-def}
    .
  end.
  IF p-mode = {&add-def}
  THEN DO:
    /*заблокируем*/
    FIND FIRST FIRST_layout EXCLUSIVE-LOCK WHERE FIRST_layout.layout-id = '_'.
    CREATE tt-layout.
  END.
  if v-is-copy
  or p-mode <> {&add-def}
  then do:
    if (p-mode = {&add-def} and v-is-copy)
    then do:
      FIND FIRST LOCKED_layout share-LOCK WHERE
                LOCKED_layout.layout-id = p-layout-id.
      IF locked_layout.is-default = integer({&layout-default})
      then do:
        if v-admin then do:
          &scop layout-kind-code    string(locked_layout.is-default)
          message
          substitute("Копируемая раскладка является &1&2" +
                    "Новая раскладка тоже должна быть &1?"
                    ,{&layout-kind-name}
                    ,{&new-line})
          view-as alert-box  question buttons yes-no update glog.
          if glog then do:
            v-is-default = integer({&layout-default}).
          end.
          ELSE DO:
            v-is-default = integer({&layout-ORDINAL}).
          END.
        end. /*if v-admin then do:*/
        else do:
          v-is-default = integer({&layout-ORDINAL}).
        end. /**/
      end. /*      IF locked_layout.is-default = integer({&layout-default})*/
    end.
    IF p-mode = {&UPDATE}
    THEN DO:
      FIND FIRST LOCKED_layout EXCLUSIVE-LOCK WHERE
                LOCKED_layout.layout-id = p-layout-id.
      if locked_layout.is-default = integer({&layout-default})
      and not v-admin then do:
       &scop layout-kind-code    string(locked_layout.is-default)
        message
        substitute("Нельзя редактировать &1", {&layout-kind-name})
        view-as alert-box error .
        undo, return error .
      end.
      create tt-layout.
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_layout no-LOCK WHERE
                LOCKED_layout.layout-id = p-layout-id no-error .
      create tt-layout.
    END.
    buffer-copy locked_layout to tt-layout.
    if tt-layout.layout-id <> '_' then do:
      if v-is-copy then do:
        tt-layout.is-default = v-is-default.
      end.
      RUN fill-tt IN THIS-PROCEDURE.
      if v-is-copy then do:
        assign
        tt-layout.layout-id = ''
        .
      end.
      run fill-elem in this-procedure .
      if p-mode = {&add-def} and v-is-copy then do:
        release locked_layout.
      end.
    end.
  end.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb_rule-by-set-s_is-used Dialog-Frame
PROCEDURE cb_rule-by-set-s_is-used :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define output parameter p-is-used as logical no-undo .
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
for each buf_wi-mode no-lock where
          buf_wi-mode.codex_id = p-codex-id
      and buf_wi-mode.ruleset_id = p-ruleset-id
      and buf_wi-mode.mode-type = {&wi-mode-IBS-th-pos},
   each buf_tt-layout-elem-rule where
       buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
   and buf_tt-layout-elem-rule.mode-id = buf_wi-mode.mode-id
   and buf_tt-layout-elem-rule.rule_id = p-rule-id
   :
  p-is-used = yes.
  leave.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-tt-layout-elem-rule Dialog-Frame
PROCEDURE check-tt-layout-elem-rule :
define input parameter p-old-layout-type as character no-undo.
define input parameter p-new-layout-type as character no-undo.
define input parameter p-old-device-type as character no-undo.
define input parameter p-new-device-type as character no-undo.
/*пока не используем*/
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
  DISPLAY CB-mode-id f-elem-label e-elem-tooltip f-image-id-up f-image-id-down
          f-image-id-insen l-elem-tooltip
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-layout THEN
    DISPLAY tt-layout.layout-id tt-layout.layout-type tt-layout.is-default
          tt-layout.device-type tt-layout.layout-name tt-layout.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-layout.layout-id B-Help tt-layout.is-default
         tt-layout.layout-name tt-layout.des B-chg b-lkp CB-mode-id
         BR-layout-elem-rule b-br-available BR-available f-elem-label
         e-elem-tooltip B-add B-del BR-rule-call-params
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-cb-mode-id Dialog-Frame
PROCEDURE fill-cb-mode-id :
define input parameter p-layout-type as character no-undo.
define variable v-list-items as character no-undo.
define buffer buf_wi-mode for ub.wi-mode.

case p-layout-type:
  when {&th-pos-screen} then do:
    v-list-items = {&comma-char}.
    assign
    cb-mode-id:list-item-pairs in frame {&frame-name} = v-list-items.
    for each buf_wi-mode NO-LOCK WHERE buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
    and buf_wi-mode.mode-id < "_"
    :
      cb-mode-id:add-last ( substitute("&1 (&2)", string(buf_wi-mode.mode-name, "X(32)"), buf_wi-mode.mode-id), buf_wi-mode.mode-id).
    end.
    assign
    cb-mode-id = "".
    display
    cb-mode-id
    with frame {&frame-name}.
    enable cb-mode-id
    with frame {&frame-name}.
  end.
  when {&th-pos-keyboard} then do:

    find first buf_wi-mode NO-LOCK WHERE buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
    and buf_wi-mode.mode-id = "_".

    cb-mode-id:list-item-pairs in frame {&frame-name} = substitute("&1,&2"
                                                                   ,string(buf_wi-mode.mode-name, "X(32)")
                                                                   ,buf_wi-mode.mode-id).
   assign
   cb-mode-id = "_".
    display
    cb-mode-id
    with frame {&frame-name}.
    disable cb-mode-id
    with frame {&frame-name}.

  end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-elem Dialog-Frame
PROCEDURE fill-elem :
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.

if tt-layout.device-type = ''
or tt-layout.layout-type = '' then do:
  undo, return error .
end.

for each buf_tt-layout-elem:
  delete buf_tt-layout-elem.
end.
for each buf_layout-elem no-lock where
        buf_layout-elem.layout-type = tt-layout.layout-type
    and buf_layout-elem.device-type = tt-layout.device-type
    AND buf_layout-elem.elem-type = INTEGER({&lelem-type-programmable}):
    create buf_tt-layout-elem.
    buffer-copy buf_layout-elem to buf_tt-layout-elem.
end.
for each buf_tt-layout-elem,
      first buf_tt-layout-elem-rule no-lock where
            buf_tt-layout-elem-rule.mode-id = buf_tt-layout-elem.mode-id
         and buf_tt-layout-elem-rule.widget-id = buf_tt-layout-elem.widget-id:

    assign
    buf_tt-layout-elem.is-defined = yes.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt Dialog-Frame
PROCEDURE fill-tt :
define variable v-call#_id as integer no-undo .
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
define buffer buf_tt-rule-call-param for tt-rule-call-param.


for each buf_tt-layout-elem-rule:
  delete buf_tt-layout-elem-rule.
end.
for each buf_layout-elem-rule no-lock where
        buf_layout-elem-rule.layout-id = tt-layout.layout-id:
  find first buf_tt-layout-elem-rule where
           buf_tt-layout-elem-rule.layout-id = (if v-is-copy then '' else buf_layout-elem-rule.layout-id)
       and buf_tt-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
       and buf_tt-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
   if not available buf_tt-layout-elem-rule then do:
      create buf_tt-layout-elem-rule.
      buffer-copy buf_layout-elem-rule to buf_tt-layout-elem-rule
      assign
      buf_tt-layout-elem-rule.layout-id = (if v-is-copy then '' else buf_layout-elem-rule.layout-id )
      .
    if v-is-copy then do:
      run gen-key-rec in this-procedure ( input {&table_layout-elem-rule}
                                         ,input (buffer buf_tt-layout-elem-rule:handle)
                                         , output buf_tt-layout-elem-rule.uniq-key-rec).
    end.
    if v-is-copy then do:
      v-call#_id = get-call#-id( input buf_tt-layout-elem-rule.uniq-key-rec).
    end.
    for each buf_rule-by-call no-lock where
            buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec:
        create buf_tt-rule-by-call.
        buffer-copy buf_rule-by-call
        except call_id call#_id
        to buf_tt-rule-by-call
        assign
        buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
        buf_tt-rule-by-call.call#_id = (if v-is-copy then v-call#_id else buf_rule-by-call.call#_id)
        .
    end.
    for each buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec:

        create buf_tt-rule-call-param.
        buffer-copy buf_rule-call-param
        except call_id call#_id
        to buf_tt-rule-call-param
        assign
        buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
        buf_tt-rule-call-param.call#_id = (if v-is-copy then v-call#_id else buf_rule-call-param.call#_id)
        .
    end.

  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE VARIABLE v-h AS handle NO-UNDO.
define variable glog as logical no-undo .
ASSIGN
v-h = br-rule-call-params:FIRST-COLUMN IN FRAME {&FRAME-NAME}
.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&br-rule-call-param-label1} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.


assign
frame {&frame-name}:title = substitute("Ракладка &1 &2 &3"
                                     , (if p-mode = {&add-def} then '' else tt-layout.layout-id)
                                     , title-mode(p-mode)
                                     ,( if v-admin then  "Режим IBS" else ''))
.
DO v-ii = 1 TO NUM-ENTRIES({&layout-kind-codes}):
   v-list-items = v-list-items + (if v-ii = 1 THEN '' ELSE {&comma-char}) +
                 entry(v-ii, {&layout-kind-codes-full}) + {&comma-char} +
                 ENTRY(v-ii, {&layout-kind-codes}).
END.
ASSIGN
tt-layout.is-default:list-item-pairs IN FRAME {&FRAME-NAME} = v-list-items.
v-list-items = ''.
DO v-ii = 1 TO NUM-ENTRIES({&layout-type-list}):
   v-list-items = v-list-items  + (IF v-ii = 1 THEN '' ELSE {&comma-char}) +
                  ENTRY(v-ii, {&layout-type-list-full}) + {&comma-char} +
                  ENTRY(v-ii, {&layout-type-list}).
END.
ASSIGN
tt-layout.layout-type:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = v-list-items .
assign
X_rule.name:resizable in browse br-layout-elem-rule = yes
tt-layout-elem-rule.rule_id:visible in browse br-layout-elem-rule = (v-admin = yes)
tt-rule-call-param.param-data-type:visible in browse br-rule-call-params = (v-admin = yes)
tt-rule-call-param.param-name:visible in browse br-rule-call-params = (v-admin = yes)
tt-rule-call-param.param-name:resizable in browse br-rule-call-params = yes
tt-rule-call-param.param-label:resizable in browse br-rule-call-params = yes
X_rule.name:resizable in browse br-layout-elem-rule = yes
.
if tt-layout.sts = integer({&blocked-status-int}) then do:
  glog = browse br-layout-elem-rule:move-column( 7, 5).
end.
IF AVAILABLE tt-layout THEN
DISPLAY
tt-layout.layout-type
tt-layout.layout-id WHEN p-mode <> {&add-def}
tt-layout.layout-name
tt-layout.is-default
WITH FRAME {&frame-name} .
RUN proc-value-change-layout-type IN THIS-PROCEDURE ( INPUT NO).
IF AVAILABLE tt-layout THEN
DISPLAY
tt-layout.device-type
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
b-lkp
b-chg when p-mode <> {&lookup}
b-del when p-mode <> {&lookup}
b-add when p-mode <> {&lookup}
cb-mode-id
tt-layout.layout-type  when p-mode = {&add-def}
tt-layout.device-type  when p-mode = {&add-def}
tt-layout.layout-name when p-mode <> {&lookup}
tt-layout.is-default when (p-mode <> {&lookup} and v-admin)
br-available
br-layout-elem-rule
tt-layout.des  when p-mode <> {&lookup}
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide b-exit in frame {&frame-name} .
end.
IF p-mode = {&add-def} THEN DO:
   HIDE
   tt-layout.layout-id
   IN FRAME {&FRAME-NAME}.
END.
run Openbr in this-procedure.
run Openbr2 in this-procedure.
run proc-view-br-available in this-procedure .
VIEW FRAME {&frame-name} .
run process-add-del in this-procedure.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
OPEN QUERY br-layout-elem-rule
FOR EACH tt-layout-elem-rule NO-LOCK where
tt-layout-elem-rule.layout-id = tt-layout.layout-id
and (cb-mode-id = ''
or tt-layout-elem-rule.mode-id = cb-mode-id),
first X_rule OUTER-JOIN NO-LOCK where X_rule.rule_id = tt-layout-elem-rule.rule_id
INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr2 Dialog-Frame
PROCEDURE Openbr2 :
OPEN QUERY br-available
FOR EACH tt-layout-elem NO-LOCK where
tt-layout-elem.layout-type = tt-layout.layout-type
and
tt-layout-elem.device-type = tt-layout.device-type
and (cb-mode-id = ''
or tt-layout-elem.mode-id = cb-mode-id)
and tt-layout-elem.is-define = no
INDEXED-REPOSITION.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr3 Dialog-Frame
PROCEDURE Openbr3 :
if not available tt-layout-elem-rule then do:
    OPEN QUERY br-rule-call-params
    FOR EACH tt-rule-call-param WHERE false.
end.
else do:
    OPEN QUERY br-rule-call-params
    FOR EACH tt-rule-call-param WHERE
             tt-rule-call-param.rule_id = tt-layout-elem-rule.rule_id
         and tt-rule-call-param.call_id = tt-layout-elem-rule.uniq-key-rec.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-mandatory Dialog-Frame
PROCEDURE proc-add-mandatory :
DEFINE input PARAMETER p-layout-type AS CHARACTER NO-UNDO.
DEFINE input PARAMETER p-device-type AS CHARACTER NO-UNDO.
                 DEFINE BUFFER buf_layout FOR ub.layout.
DEFINE BUFFER buf_layout-elem-rule FOR ub.layout-elem-rule.
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_tt-rule-by-call FOR tt-rule-by-call.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_tt-layout-elem-rule FOR tt-layout-elem-rule.
DEFINE BUFFER buf_tt-layout-elem FOR tt-layout-elem.
if p-device-type = ''
or p-layout-type = '' then do:
  undo, return ''.
end.
IF tt-layout.is-default = INTEGER({&layout-mandatory})
or p-mode = {&lookup}
or can-find(first buf_tt-layout-elem-rule where buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id) then do:
  return ''.
end.
FIND FIRST buf_layout SHARE-LOCK WHERE
          buf_layout.layout-type = p-layout-type
      AND buf_layout.device-type = p-device-type
    AND buf_layout.is-default = INTEGER({&layout-mandatory}) NO-ERROR.
IF AVAILABLe buf_layout THEN DO:
   FOR EACH buf_layout-elem-rule NO-LOCK WHERE
            buf_layout-elem-rule.layout-id = buf_layout.layout-id:
    FIND FIRST buf_wi-mode NO-LOCK WHERE
              buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
          AND buf_wi-mode.mode-id = buf_layout-elem-rule.mode-id.
     find first buf_rule no-lock where
                buf_rule.rule_id = buf_layout-elem-rule.rule_id.
     find first buf_rule-by-call no-lock where
              buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec.

     CREATE buf_tt-layout-elem-rule.
     BUFFER-COPY
     buf_layout-elem-rule
     EXCEPT layout-id uniq-key-rec
     TO buf_tt-layout-elem-rule
     ASSIGN
     buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
     buf_tt-layout-elem-rule.is-mandatory = integer({&layout-elem-rule-mandatory})
     .
     run gen-key-rec in this-procedure ( input {&table_layout-elem-rule}
                                         ,input (buffer buf_tt-layout-elem-rule:handle)
                                         ,output buf_tt-layout-elem-rule.uniq-key-rec).
     CREATE buf_tt-rule-by-call.
     BUFFER-copy buf_rule-by-call
     EXCEPT CALL_id  uniq-key-rec TO buf_tt-rule-by-call
     ASSIGN
     buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
     .
     run gen-key-rec in this-procedure ( input {&table_rule-by-call}
                                         ,input (buffer buf_tt-rule-by-call:handle)
                                         ,output buf_tt-rule-by-call.uniq-key-rec).
     /*теперь надо определить значения параметров*/
     for each buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_rule-by-call.call_id
         AND buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
         AND buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
         AND buf_rule-call-param.order_id = buf_rule-by-call.order_id:
       create buf_tt-rule-call-param.
       buffer-copy buf_rule-call-param
       EXCEPT CALL_id call#_id
       to buf_tt-rule-call-param
       assign
       buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
       .
     end.
  run openbr in this-procedure.
  run openbr2 in this-procedure.
  reposition br-layout-elem-rule to row 1 no-error.
  apply "entry" to br-layout-elem-rule in frame {&frame-name} .

END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-mode-id as character no-undo.
define input parameter p-widget-id as character no-undo.

define variable v-recid as recid no-undo.
define variable v-recid2 as recid no-undo .
define variable v-rid-list as character no-undo.
define variable glog as logical no-undo.
define variable v-ok as logical no-undo .
define variable v-call#-id as integer no-undo .
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_rule-by-set for ub.rule-by-set.
define buffer buf_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.



define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-by-call for tt-rule-by-call.


if tt-layout.layout-type = ""
or tt-layout.device-type = "" then do:
  message
  substitute("Вы не определили тип раскладки и/или тип устройства")
  view-as alert-box error.
  undo, return error.
end.
if not available tt-layout-elem then do:
  message
  "Неопределен элемент для добавления"
  view-as alert-box error.
  undo, return error.
end.
find first buf_wi-mode no-lock where
          buf_wi-mode.mode-type = {&wi-mode-ibs-th-pos}
      and buf_wi-mode.mode-id = tt-layout-elem.mode-id no-error.
if not available buf_wi-mode then do:
   message
   substitute("Не найдена запись Режима работы c типом &1 и ID &2"
               , {&wi-mode-ibs-th-pos}
               , tt-layout-elem.mode-id)
   view-as alert-box error.
   undo, return error.
end.
run rul/rule-by-set-s.w ( INPUT parparentproc
                  ,INPUT "b-sel":U /*bttns*/
                  ,INPUT "wi-mode-available" + (if v-admin then {&comma-char} + "admin" else '')
                  ,INPUT buf_wi-mode.codex_id
                  ,input buf_wi-mode.ruleset_id
                  ,INPUT 0 /*p-rule-id*/
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.
if v-rid-list = '' then do:
  undo, return ''.
end.
find first buf_rule-by-set no-lock where
          recid(buf_rule-by-set) = integer(v-rid-list) .
find first buf_rule no-lock where
           buf_rule.rule_id = buf_rule-by-set.rule_id.
/*теперь надо определить значения параметров*/
find first buf_ruledict where
          buf_ruledict.entry-type = {&rdict-etype-rule}
      and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.

find first buf_tt-layout-elem-rule where
          buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
      and buf_tt-layout-elem-rule.mode-id = tt-layout-elem.mode-id
      and buf_tt-layout-elem-rule.widget-id = tt-layout-elem.widget-id
      and buf_tt-layout-elem-rule.rule_id = buf_rule-by-set.rule_id no-error.
if available buf_tt-layout-elem-rule
and not can-find(first ub.ruledict-param  no-lock where ub.ruledict-param.entry-id = buf_ruledict.entry-id)
then do:
  message
  substitute("Вы уже подключали функцию &1?, хотите подключить ее еще раз?")
  view-as alert-box question buttons yes-no  update glog.
  if not glog then undo, return error.
end.

find first buf_tt-layout-elem where
        recid(buf_tt-layout-elem) = recid(tt-layout-elem).
create buf_tt-layout-elem-rule.
assign
buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
buf_tt-layout-elem-rule.mode-id = tt-layout-elem.mode-id
buf_tt-layout-elem-rule.widget-id = tt-layout-elem.widget-id
buf_tt-layout-elem-rule.rule_id = buf_rule-by-set.rule_id
buf_tt-layout-elem-rule.image-id-down = buf_rule.image-file-name
buf_tt-layout-elem-rule.image-id-up = buf_rule.image-file-name
buf_tt-layout-elem-rule.image-id-insen = buf_rule.image-file-name
buf_tt-layout-elem.is-define = yes
buf_tt-layout-elem-rule.is-mandatory = INTEGER({&layout-elem-rule-ordinal})
v-recid = recid(buf_tt-layout-elem-rule)
v-recid2 = recid(buf_tt-layout-elem)
.
run gen-key-rec in this-procedure ( input {&table_layout-elem-rule}
                                    ,input (buffer buf_tt-layout-elem-rule:handle)
                                    ,output buf_tt-layout-elem-rule.uniq-key-rec).

v-call#-id = get-call#-id ( input buf_tt-layout-elem-rule.uniq-key-rec).
CREATE buf_tt-rule-by-call.
ASSIGN
buf_tt-rule-by-call.profile_id = 0
buf_tt-rule-by-call.codex_id = buf_wi-mode.codex_id
buf_tt-rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
buf_tt-rule-by-call.rule_id = buf_rule.rule_id
buf_tt-rule-by-call.order_id = 0
buf_tt-rule-by-call.algo-des = buf_rule.NAME
buf_tt-rule-by-call.is_dynamic = yes
buf_tt-rule-by-call.can-calc = yes
buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
buf_tt-rule-by-call.call#_id = v-call#-id
buf_tt-rule-by-call.once-more = 1
buf_tt-rule-by-call.can-run = yes
.
 run gen-key-rec in this-procedure ( input {&table_rule-by-call}
                                     ,input (buffer buf_tt-rule-by-call:handle)
                                     ,output buf_tt-rule-by-call.uniq-key-rec).
for each buf_ruledict-param no-lock where
        buf_ruledict-param.entry-i = buf_ruledict.entry-id:
  create buf_tt-rule-call-param.
  buffer-copy buf_ruledict-param
  to buf_tt-rule-call-param
  assign
  buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
  buf_tt-rule-call-param.call#_id = v-call#-id
  buf_tt-rule-call-param.codex_id = buf_wi-mode.codex_id
  buf_tt-rule-call-param.ruleset_id = buf_wi-mode.ruleset_id
  buf_tt-rule-call-param.rule_id = buf_rule.rule_id
  buf_tt-rule-call-param.order_id = 0
  buf_tt-rule-call-param.profile_id = 0
  buf_tt-rule-call-param.once-more = 1
  .
end.
/*задание свойств элемента в раскладке*/
run adm/layeruli.w ( input parparentproc
                    ,input ({&add-def} + (if v-admin then ({&comma-char} + "admin") else ''))
                    ,input buf_tt-layout-elem-rule.uniq-key-rec
                    ,input tt-layout.device-type
                    ,input-output table buf_tt-layout-elem-rule
                    ,input-output table tt-rule-call-param
                    ,output v-ok
                    ) no-error.
if error-status:error
or not v-ok
then do:
  find first buf_tt-layout-elem-rule where
            recid(buf_tt-layout-elem-rule) = v-recid no-error.
  if available buf_tt-layout-elem-rule then do:
    for each buf_tt-rule-call-param where
           buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
       and buf_tt-rule-call-param.codex_id = buf_wi-mode.codex_id
       and buf_tt-rule-call-param.ruleset_id = buf_wi-mode.ruleset_id
       and buf_tt-rule-call-param.order_id = 0:
      delete buf_tt-rule-call-param.
    end.
    delete buf_tt-layout-elem-rule.
  end.
  find first buf_tt-layout-elem where
             recid(buf_tt-layout-elem) = v-recid2 no-error.
  if available buf_tt-layout-elem then do:
     buf_tt-layout-elem.is-define = no.
  end.
  run openbr in this-procedure.
  run openbr2 in this-procedure.
  reposition br-layout-elem-rule to row 1 no-error.
  apply "entry" to br-layout-elem-rule in frame {&frame-name} .
end.
else do:
    run openbr in this-procedure.
    run openbr2 in this-procedure.
    reposition br-layout-elem-rule to recid v-recid no-error.
    apply "entry" to br-layout-elem-rule in frame {&frame-name} .
    apply "value-changed" to br-layout-elem-rule in frame {&frame-name} .
    run process-add-del in this-procedure .
end.
run proc-view-br-available in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define input parameter p-mode-id as character no-undo.
define input parameter p-widget-id as character no-undo.
define variable glog as logical no-undo.
define variable v-recid as recid no-undo.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
message
"Вы действительно хотите удалить привязку к этой функции?"
view-as alert-box question button yes-no update glog.
if not glog then do:
  undo, return error.
end.
find first buf_tt-layout-elem-rule where
recid(buf_tt-layout-elem-rule) = recid(tt-layout-elem-rule).
IF buf_tt-layout-elem-rule.is-mandatory =INTEGER({&layout-elem-rule-mandatory}) THEN DO:
   MESSAGE
   "Нельзя удалять обязательный элемент раскладки!"
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
glog = br-layout-elem-rule:select-next-row() in frame {&frame-name}.
if not glog then glog = br-layout-elem-rule:select-prev-row().
if glog then v-recid = recid(tt-layout-elem-rule).
find first buf_tt-rule-by-call where
         buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec.
for each buf_tt-rule-call-param where
    buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec:
  delete buf_tt-rule-call-param.
end.
FIND FIRST buf_tt-layout-elem WHERE
           buf_tt-layout-elem.layout-type = tt-layout.layout-type
    AND    buf_tt-layout-elem.device-type = tt-layout.device-type
    AND    buf_tt-layout-elem.mode-id = buf_tt-layout-elem-rule.mode-id
    AND    buf_tt-layout-elem.widget-id = buf_tt-layout-elem-rule.WIDGET-ID NO-ERROR.
IF AVAILABLE buf_tt-layout-elem THEN DO:
    buf_tt-layout-elem.is-DEFINe = NO.
END.
delete buf_tt-layout-elem-rule.
delete buf_tt-rule-by-call.
run openbr in this-procedure.
run openbr2 in this-procedure.
reposition br-layout-elem-rule to recid v-recid no-error.
apply "entry" to br-layout-elem-rule in frame {&frame-name} .
apply "value-changed" to br-layout-elem-rule in frame {&frame-name} .
run process-add-del in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-layout-elem-rule-i Dialog-Frame
PROCEDURE proc-layout-elem-rule-i :
define parameter buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
assign
f-elem-label = buf_tt-layout-elem-rule.elem-label
f-image-id-up = buf_tt-layout-elem-rule.image-id-up
f-image-id-down = buf_tt-layout-elem-rule.image-id-down
f-image-id-insen = buf_tt-layout-elem-rule.image-id-insen
.
hide
br-available in frame {&frame-name}
b-add
b-del
in frame {&frame-name}.
disable
b-add
b-del
with frame {&frame-name}.
display
f-elem-label
e-elem-tooltip
l-elem-tooltip
f-image-id-up
f-image-id-down
f-image-id-insen
with frame {&frame-name}.
e-elem-tooltip:screen-value in frame {&frame-name} = buf_tt-layout-elem-rule.elem-tooltip.
display
b-br-available
with frame {&frame-name}.
enable
b-br-available
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
v-rec = recid(locked_layout).
ASSIGN
FRAME {&FRAME-NAME}
tt-layout.layout-type
tt-layout.layout-id
tt-layout.device-type
tt-layout.layout-name
tt-layout.is-default
tt-layout.des
.
run adm/layout1.p ( INPUT (p-mode + (if v-admin then ({&comma-char} + "admin") else ''))
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-layout.layout-id
                ,INPUT tt-layout.layout-type
                ,INPUT tt-layout.device-type
                ,INPUT tt-layout.layout-name
                ,INPUT tt-layout.is-default
                ,input tt-layout.des
                ,input table tt-rule-by-call
                ,input table tt-layout-elem-rule
                ,input table tt-rule-call-param
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-change-device-type Dialog-Frame
PROCEDURE proc-value-change-device-type :
DEFINE INPUT PARAMETER p-option AS LOGICAL NO-UNDO.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
IF p-option THEN DO:
  find first buf_tt-layout-elem-rule no-error.
  if available buf_tt-layout-elem-rule then do:
    message
    substitute("Вы уже определили функции для элементов раскладки,&1" +
                "поэтому сменить тип устройства невозможно.&1" +
              "Для смены типа устройства сначала удалите все определения или определите новую раскладку"
              , {&new-line})
    view-as alert-box error.
    display
    tt-layout.device-type
    with frame {&frame-name}.
    return no-apply.
  end.
END.
assign
tt-layout.device-type.
run proc-add-mandatory IN THIS-PROCEDURE ( INPUT tt-layout.layout-type
                                          ,INPUT tt-layout.device-type).
run fill-elem in this-procedure .
run openbr in this-procedure.
run openbr2 in this-procedure.
reposition br-layout-elem-rule to row 1 no-error.
apply "entry" to br-layout-elem-rule in frame {&frame-name} .
apply "value-changed" to br-layout-elem-rule in frame {&frame-name} .
run process-add-del in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-change-layout-type Dialog-Frame
PROCEDURE proc-value-change-layout-type :
DEFINE INPUT PARAMETER p-option AS LOGICAL NO-UNDO.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
IF p-option THEN DO:

    find first buf_tt-layout-elem-rule no-error.
    if available buf_tt-layout-elem-rule then do:
      message
      substitute("Вы уже определили функции для элементов раскладки,&1" +
                  "поэтому сменить тип раскладки невозможно.&1" +
                 "Для смены типа раскладки сначала удалите все определения или определите новую раскладку")
      view-as alert-box error.
      display
      tt-layout.layout-type
      with frame {&frame-name}.
      return no-apply.
    end.
END.
assign
tt-layout.layout-type.
CASE tt-layout.layout-type:
  WHEN {&th-pos-keyboard}  THEN DO:
      ASSIGN
      tt-layout.device-type:LIST-ITEMS = {&th-pos-device-keyboard-list}.
      tt-layout-elem-rule.mode-id:visible in browse br-layout-elem-rule = no.
      tt-layout-elem.mode-id:visible in browse br-available = no.

  END.
  WHEN {&th-pos-screen}  THEN DO:
      ASSIGN
      tt-layout.device-type:LIST-ITEMS = {&th-pos-device-screen-list}.
      tt-layout-elem-rule.mode-id:visible in browse br-layout-elem-rule = yes.
      tt-layout-elem.mode-id:visible in browse br-available = yes.


  END.
END CASE.
run fill-cb-mode-id in this-procedure ( input tt-layout.layout-type).
run proc-add-mandatory IN THIS-PROCEDURE ( INPUT tt-layout.layout-type
                                          ,INPUT tt-layout.device-type).
run fill-elem in this-procedure .
run openbr in this-procedure.
run openbr2 in this-procedure.
reposition br-layout-elem-rule to row 1 no-error.
apply "entry" to br-layout-elem-rule in frame {&frame-name} .
apply "value-changed" to br-layout-elem-rule in frame {&frame-name} .
run process-add-del in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-view-br-available Dialog-Frame
PROCEDURE proc-view-br-available :
hide
f-elem-label in frame {&frame-name}
l-elem-tooltip
e-elem-tooltip
f-image-id-up
f-image-id-down
f-image-id-insen
in frame {&frame-name}.
display
b-lkp
with frame {&frame-name}.
enable
b-lkp
with frame {&frame-name}.
enable
br-available
b-add when p-mode <> {&lookup}
b-del when p-mode <> {&lookup}
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-add-del Dialog-Frame
PROCEDURE process-add-del :
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
find first buf_tt-layout-elem-rule  no-error.
if available buf_tt-layout-elem-rule then do:
  disable
  tt-layout.layout-type
  tt-layout.device-type
  tt-layout.is-default
  with frame {&frame-name}.
end.
else do:
  if p-mode <> {&lookup} then do:
    enable
    tt-layout.layout-type
    tt-layout.device-type
    tt-layout.is-default WHEN (v-admin and p-mode <> {&lookup})
    with frame {&frame-name}.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-call#-id Dialog-Frame
FUNCTION get-call#-id RETURNS INTEGER
  ( INPUT p-call-id AS CHARACTER ) :
DEFINE VARIABLE v-call#-id AS INTEGER NO-UNDO.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_c-rule-by-call for ub.c-rule-by-call .
find first buf_rule-by-call no-lock where
          buf_rule-by-call.call_id = p-call-id no-error .
if available buf_rule-by-call then do:
  v-call#-id = buf_rule-by-call.call#_id.
  return v-call#-id.
end.
find first buf_c-rule-by-call no-lock where
          buf_c-rule-by-call.call_id = p-call-id no-error .
if available buf_c-rule-by-call then do:
  v-call#-id = buf_c-rule-by-call.call#_id.
  return v-call#-id.
end.
IF v-call#-id = 0 THEN DO:
   /*с минумос - потому что они пока нереальные - так их будет отличать при сохранении*/
   assign
   v-call#-id = v-gl-call#-id - 1
   v-gl-call#-id = v-gl-call#-id - 1
   .

END.
RETURN v-call#-id.   /* Function return value. */
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME