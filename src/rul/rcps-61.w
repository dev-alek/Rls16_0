&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_ruledict-param FOR ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил для профайла 61

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-handle as handle no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-rule-call-param.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 61".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ rul/rcps.i local-var }
{ gbl/fileslsh.i }
{ cmp/obj-list.i  "new"  }
{ gbl/getcntxt.i def }
{ cmp/library.i }



&SCOPED-DEFINE global-int string(0)
&SCOPED-DEFINE global-int-full 'Все'
&SCOPED-DEFINE shops-int string(-1)
&SCOPED-DEFINE shops-int-full 'Выборочно'


FUNCTION display-shop returns character ( input p-obj-code as integer, input p-obj-name as character):
define variable v-string as character no-undo .
v-string = substitute("&1   &2",  string(p-obj-code, ">>>>9"), p-obj-name).
return v-string.
end function.
define variable v-save-objects as logical no-undo init yes.
define variable v-list as character no-undo .
define variable v-list-macro as character no-undo .
define variable v-running-mode as logical no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-rcp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ruledict-param X_rp-rule-param ~
tt-rule-call-param TERM_tt-rule-call-param

/* Definitions for BROWSE BR-rcp                                        */
&Scoped-define FIELDS-IN-QUERY-BR-rcp X_rp-rule-param.rp-param-name term_tt-rule-call-param.codex_id term_tt-rule-call-param.ruleset_id term_tt-rule-call-param.order_id term_tt-rule-call-param.rule_id term_tt-rule-call-param.profile_id term_tt-rule-call-param.once-more {&abl-datatype-name} term_tt-rule-call-param.param-num TERM_tt-rule-call-param.p-index term_tt-rule-call-param.param-name term_tt-rule-call-param.param-label {&script-parmode-name} get-param-value( INPUT term_tt-rule-call-param.param-data-type ,INPUT term_tt-rule-call-param.param-2-data-type ,INPUT term_tt-rule-call-param.param-3-data-type ,INPUT TERM_tt-rule-call-param.p-index ,INPUT term_tt-rule-call-param.param-value-character ,INPUT term_tt-rule-call-param.param-value-date ,INPUT term_tt-rule-call-param.param-value-decimal ,INPUT term_tt-rule-call-param.param-value-integer ,INPUT term_tt-rule-call-param.param-value-logical) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-character} THEN term_tt-rule-call-param.param-value-character ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-date} THEN STRING(term_tt-rule-call-param.param-value-date, "99/99/9999") ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-decimal} THEN STRING(term_tt-rule-call-param.param-value-decimal) ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-integer} THEN STRING(term_tt-rule-call-param.param-value-integer) ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-logical} THEN STRING(term_tt-rule-call-param.param-value-logical, "+/-") ELSE '':U) calldscr(tt-rule-call-param.call_id)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rcp
&Scoped-define SELF-NAME BR-rcp
&Scoped-define QUERY-STRING-BR-rcp FOR EACH X_ruledict-param, ~
       FIRST X_rp-rule-param, ~
       first tt-rule-call-param, ~
       EACH TERM_tt-rule-call-param BY tt-rule-call-param.call_id BY tt-rule-call-param.codex_id BY tt-rule-call-param.ruleset_id BY tt-rule-call-param.order_id BY tt-rule-call-param.param-num BY term_tt-rule-call-param
&Scoped-define OPEN-QUERY-BR-rcp OPEN QUERY {&SELF-NAME} FOR EACH X_ruledict-param, ~
       FIRST X_rp-rule-param, ~
       first tt-rule-call-param, ~
       EACH TERM_tt-rule-call-param BY tt-rule-call-param.call_id BY tt-rule-call-param.codex_id BY tt-rule-call-param.ruleset_id BY tt-rule-call-param.order_id BY tt-rule-call-param.param-num BY term_tt-rule-call-param                                  .
&Scoped-define TABLES-IN-QUERY-BR-rcp X_ruledict-param X_rp-rule-param ~
tt-rule-call-param TERM_tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rcp X_ruledict-param
&Scoped-define SECOND-TABLE-IN-QUERY-BR-rcp X_rp-rule-param
&Scoped-define THIRD-TABLE-IN-QUERY-BR-rcp tt-rule-call-param
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-rcp TERM_tt-rule-call-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help rct-obj rs-method ~
rs-action b-lob-sel SelectObject button-obj BR-rcp f-list-name
&Scoped-Define DISPLAYED-OBJECTS rs-method rs-action v-list-id e-shops ~
SelectObject f-list-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lob-sel
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON button-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE VARIABLE e-shops AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL NO-BOX
     SIZE 40.8 BY 3.37
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-list-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 60.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-list-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Список или макрос"
     VIEW-AS FILL-IN
     SIZE 12 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-action AS CHARACTER INITIAL "U"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Передача", "U",
"Удаление", "D"
     SIZE 16 BY 2.13 NO-UNDO.

DEFINE VARIABLE rs-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "файл списка товаров", "gds-list",
"файл макроса формирования списка товаров", "gds-list-macro"
     SIZE 65 BY 2 NO-UNDO.

DEFINE VARIABLE SelectObject AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "все объекты БД", 1,
"объекты выборочно", 3
     SIZE 28 BY 2.67 NO-UNDO.

DEFINE RECTANGLE rct-obj
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 79 BY 4.27.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-rcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rcp Dialog-Frame _FREEFORM
  QUERY BR-rcp DISPLAY
      X_rp-rule-param.rp-param-name COLUMN-LABEL "Название пар-ра!профайла" FORMAT "X(20)" width 16
term_tt-rule-call-param.codex_id COLUMN-LABEL "Кодекс"
term_tt-rule-call-param.ruleset_id COLUMN-LABEL "Набор"
term_tt-rule-call-param.order_id  COLUMN-LABEL "Порядок!вызова"
term_tt-rule-call-param.rule_id  COLUMN-LABEL "Правило"
term_tt-rule-call-param.profile_id  COLUMN-LABEL "Профайл"
term_tt-rule-call-param.once-more COLUMN-LABEL "№!Привязки"
{&abl-datatype-name} COLUMN-LABEL "Тип пар-ра" FORMAT "X(12)"
term_tt-rule-call-param.param-num COLUMN-LABEL "№!пар-ра" FORMAT ">9"
TERM_tt-rule-call-param.p-index COLUMN-LABEL "Инд!екс" FORMAT ">9"
term_tt-rule-call-param.param-name COLUMN-LABEL "Название пар-ра!правила" FORMAT "X(16)"
term_tt-rule-call-param.param-label COLUMN-LABEL "Название пар-ра" FORMAT "X(255)" WIDTH 30
{&script-parmode-name} COLUMN-LABEL "Вид!пар-ра"
get-param-value( INPUT term_tt-rule-call-param.param-data-type
                ,INPUT term_tt-rule-call-param.param-2-data-type
                ,INPUT term_tt-rule-call-param.param-3-data-type
                ,INPUT TERM_tt-rule-call-param.p-index
                ,INPUT term_tt-rule-call-param.param-value-character
                ,INPUT term_tt-rule-call-param.param-value-date
                ,INPUT term_tt-rule-call-param.param-value-decimal
                ,INPUT term_tt-rule-call-param.param-value-integer
                ,INPUT term_tt-rule-call-param.param-value-logical) COLUMN-LABEL {&label-clmn_14} FORMAT "X(255)" WIDTH 26

(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-character}
 THEN term_tt-rule-call-param.param-value-character
 ELSE '':U) COLUMN-LABEL {&label-clmn_8} FORMAT "X(26)"
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-date}
THEN STRING(term_tt-rule-call-param.param-value-date, "99/99/9999")
ELSE '':U)    COLUMN-LABEL {&label-clmn_9} FORMAT "X(10)" WIDTH 12
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-decimal}
THEN STRING(term_tt-rule-call-param.param-value-decimal)
ELSE '':U) COLUMN-LABEL {&label-clmn_10}   FORMAT "X(16)"
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-integer}
THEN STRING(term_tt-rule-call-param.param-value-integer)
ELSE '':U) COLUMN-LABEL {&label-clmn_11} FORMAT "X(10)"
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-logical}
THEN STRING(term_tt-rule-call-param.param-value-logical, "+/-")
ELSE '':U) COLUMN-LABEL {&label-clmn_12} FORMAT "X(2)"
calldscr(tt-rule-call-param.call_id) COLUMN-LABEL  {&label-clmn_13} FORMAT "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.27
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     rs-method AT ROW 4 COL 2 NO-LABEL WIDGET-ID 48
     rs-action AT ROW 4.2 COL 75.5 NO-LABEL WIDGET-ID 44
     v-list-id AT ROW 7.4 COL 19 COLON-ALIGNED WIDGET-ID 64
     b-lob-sel AT ROW 7.4 COL 33 WIDGET-ID 62
     e-shops AT ROW 9 COL 39 NO-LABEL WIDGET-ID 54
     SelectObject AT ROW 10.07 COL 4.5 NO-LABEL WIDGET-ID 58
     button-obj AT ROW 11.4 COL 34 WIDGET-ID 52
     BR-rcp AT ROW 16.97 COL 1 WIDGET-ID 100
     f-list-name AT ROW 7.4 COL 35 COLON-ALIGNED NO-LABEL WIDGET-ID 66
     "Объекты для пересылки" VIEW-AS TEXT
          SIZE 33.5 BY 1.07 AT ROW 9 COL 4 WIDGET-ID 72
          FGCOLOR 4
     "Метод формирования списка товаров" VIEW-AS TEXT
          SIZE 46 BY .8 AT ROW 2.87 COL 2 WIDGET-ID 68
          FGCOLOR 4
     "Действие" VIEW-AS TEXT
          SIZE 12 BY 1 AT ROW 2.6 COL 75 WIDGET-ID 70
          FGCOLOR 4
     rct-obj AT ROW 8.73 COL 2 WIDGET-ID 56
     SPACE(18.00) SKIP(10.25)
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
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_rp-rule-param B "?" ? ub rp-rule-param
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_ruledict-param B "?" ? ub ruledict-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-rcp button-obj Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* SETTINGS FOR EDITOR e-shops IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       e-shops:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-list-id IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       v-list-id:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rcp
/* Query rebuild information for BROWSE BR-rcp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_ruledict-param, FIRST X_rp-rule-param, first tt-rule-call-param, EACH TERM_tt-rule-call-param
BY tt-rule-call-param.call_id
BY tt-rule-call-param.codex_id
BY tt-rule-call-param.ruleset_id
BY tt-rule-call-param.order_id
BY tt-rule-call-param.param-num
BY term_tt-rule-call-param                                  .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-rcp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE  NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lob-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lob-sel Dialog-Frame
ON CHOOSE OF b-lob-sel IN FRAME Dialog-Frame /* ... */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_clob-bind FOR ub.clob-bind.
ASSIGN
rs-method.
run ref/clobbnds.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'b-sel,b-add,managed' /*bttns*/
                    ,input "uniq-key-rec" /*p-list-mode*/
                    ,input "" /*p-mode*/
                    ,input rs-method
                    ,input 'gds-list' /*p-unique-key-rec*/
                    ,input -1 /*p-db-num*/
                    ,input-output v-rid-list) no-error.
if v-rid-list = '' then do:
 return NO-apply.
end.
find first buf_clob-bind no-lock where
          recid(buf_clob-bind) = integer(v-rid-list) .
 v-list-id = buf_clob-bind.field-name_.
 f-list-name = buf_clob-bind.descr.
 DISPlay
 f-list-name
 v-list-id WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME button-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-obj Dialog-Frame
ON CHOOSE OF button-obj IN FRAME Dialog-Frame /* ... */
DO:
  define variable v-old-selectobject as integer no-undo .
  assign
  v-old-selectobject = SelectObject
  SelectObject.
  run select-objects-proc in this-procedure ( v-save-objects ) no-error.
  if error-status:error then do:
    assign
    selectobject = v-old-selectobject
    .
    display
    selectobject
    with frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-method Dialog-Frame
ON VALUE-CHANGED OF rs-method IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-method.
  v-list-id = ''.
  DISPLAY
  v-list-id WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectObject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectObject Dialog-Frame
ON VALUE-CHANGED OF SelectObject IN FRAME Dialog-Frame
DO:
  if selectObject <> integer(selectobject:screen-value) then do:
v-save-objects = no.
  end.
  Assign SelectObject.
run select-objects-proc in this-procedure ( input v-save-objects).
run val-obj in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rcp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-rcp IN frame {&frame-name}
DO:
  IF AVAIL tt-rule-call-param THEN DO:
    RUN rcps_set-row-color IN THIS-PROCEDURE ( INPUT term_tt-rule-call-param.param-data-type).
  END.
END.

ON f6 anywhere DO:
  ASSIGN
  br-rcp:VISIBLE IN FRAME {&FRAME-NAME} = (NOT br-rcp:VISIBLE IN FRAME {&FRAME-NAME})
  .
END.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ rul/rcps.i procedures full }
{ rul/rcps.i interface }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
   run gbl/dftempl.p ( input {&table_rp-rule-param}
                     , output v-dflt-rec) no-error.
    if error-status:error then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти recid template записи в таблице rp-rule-param"
      view-as alert-box error .
      return error.
    end.
    run gbl/dftempl.p ( input {&table_ruledict-param}
                      , output v-rp-dflt-rec) no-error.
     if error-status:error then dO:
       message
       vss-workfile vss-revision vss-description skip
       "Невозможно найти recid template записи в таблице ruledict-param"
       view-as alert-box error .
       return error.
     end.
  IF p-list-mode = {&TABLE_rp-rule-param}
  THEN DO:
    FIND FIRST buf_rule-profile NO-LOCK WHERE
              buf_rule-profile.profile_id = p-profile-id.
    run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-uniq-key-rec).

    FIND FIRST buf_ruledict NO-LOCK WHERE
              buf_ruledict.entry-type = {&rdict-etype-rule-profile}
       AND  buf_ruledict.uniq-key-rec = v-uniq-key-rec.
    v-rcps-entry-id = buf_ruledict.entry-id.
  END.
  ELSE DO:
     MESSAGE
     substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
     VIEW-AS alert-box.
  END.
  if lookup("cb_thbjrumr_is-running", this-procedure:instantiating-procedure:internal-entries) > 0 then do:
  define variable v-cbh as handle no-undo .
     v-cbh = this-procedure:instantiating-procedure .
    run cb_thbjrumr_is-running in v-cbh ( output v-running-mode) no-error.
  end.
  if p-call-id begins {&table_schedule} then do:
    v-running-mode = yes.
  end.
  RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).
  RUN Myenable in THIS-PROCEDURE.
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
  DISPLAY rs-method rs-action v-list-id e-shops SelectObject f-list-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rct-obj rs-method rs-action b-lob-sel
         SelectObject button-obj BR-rcp f-list-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-list as character no-undo .
define variable glog as logical no-undo .
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-shop-code as integer no-undo .
define buffer buf_shop for ub.shop.
define buffer buf_clob-bind for ub.clob-bind.
run rcps_Myenable0 in this-procedure .
/*здесьс делаем получение наших данных*/
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-list"
                                ,INPUT-output v-index-id
                                ,output v-list /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-list-macro"
                                ,INPUT-output v-index-id
                                ,output v-list-macro /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-method"
                                ,INPUT-output v-index-id
                                ,output rs-method /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-action"
                                ,INPUT-output v-index-id
                                ,output rs-action /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
v-index-id = 0.
do while v-index-id >= 0 :
  RUN rcps_get-value IN THIS-PROCEDURE (
                                   INPUT p-profile-id
                                  ,INPUT p-once-more
                                  ,INPUT p-call-id
                                  ,INPUT "p-shops"
                                  ,INPUT-output v-index-id
                                  ,output v-value-character /*p-value-character*/
                                  ,output v-value-date /*p-value-date*/
                                  ,output v-value-decimal /*p-value-decimal*/
                                  ,output v-shop-code /*p-value-integer*/
                                  ,output v-value-logical /*p-value-logical*/
                                  ) no-error .
  if error-status:error then v-index-id = -1.
  else do:
    { cmp/cr-objls.i  ~{&shop~} v-shop-code }
    find first obj-list where
          obj-list.obj-code = v-shop-code
        and obj-list.obj-type = {&shop} no-error.
    if available obj-list then do:
      glog = e-shops:INSERT-STRING ( display-shop(v-shop-code
                                                  ,obj-list.obj-name )) in frame {&frame-name} .
      glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .
    end.
  end.
end. /*do while v-index-id >= 0 :*/
ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
case rs-method:
  when {&lob-res-list} then do:
    if num-entries(v-list, "_") > 1 then do:
      find first buf_clob-bind no-lock where
                buf_clob-bind.resource-type = rs-method
            and buf_clob-bind.uniq-key-rec = "gds-list"
            and buf_clob-bind.field-name_ = entry(2, v-list, "_") no-error.
      if available buf_clob-bind then do:
        f-list-name = buf_clob-bind.descr.
        v-list-id = buf_clob-bind.field-name_.
      end.
    end.
    else do:
      v-list-id = ''.
    end.
  end.
  when {&lob-res-list-macro} then do:
    if num-entries(v-list-macro, "_") > 1 then do:
      find first buf_clob-bind no-lock where
                buf_clob-bind.resource-type = rs-method
            and buf_clob-bind.uniq-key-rec = "gds-list"
            and buf_clob-bind.field-name_ = entry(2, v-list-macro, "_") no-error.
      if available buf_clob-bind then do:
        f-list-name = buf_clob-bind.descr.
        v-list-id = buf_clob-bind.field-name_.
      end.
    end.
    else do:
      v-list-id = ''.
    end.
  end.
end case.
DISPlay
f-list-name
v-list-id WITH FRAME {&FRAME-NAME}.


rs-method:radio-buttons in frame {&frame-name} = {&lob-res-list-full} + {&comma-char} + {&lob-res-list} + {&comma-char} +
{&lob-res-list-macro-full} + {&comma-char} + {&lob-res-list-macro} .

DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
ASSIGN
v-ch0 = br-rcp:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_8} THEN DO:
     v-ch[1] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_9} THEN DO:
     v-ch[2] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_10} THEN DO:
     v-ch[3] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_11} THEN DO:
     v-ch[4] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_12} THEN DO:
     v-ch[5] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_13} THEN DO:
     v-ch[6] = v-ch0.
   END.
   IF v-ch0:LABEL = {&label-clmn_14} THEN
   v-ch0:RESIZABLE = YES.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
assign
X_rp-rule-param.rp-param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-label:resizable in browse br-rcp = yes
.
CASE p-list-mode:
  WHEN {&TABLE_rule-call-param} THEN DO:
     ASSIGN
     X_rp-rule-param.rp-param-name:VISIBLE IN BROWSE br-rcp = NO
     .
  END.
  WHEN {&TABLE_rp-rule-param}
  or
  when {&TABLE_rp-rule-param} + {&comma-char} + {&all}
  THEN DO:
    assign
    term_tt-rule-call-param.codex_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.ruleset_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.rule_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.order_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-name:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-num:VISIBLE IN BROWSE br-rcp = NO
    .

  END.
END CASE.
 IF p-call-id <> '':U THEN DO:
   v-ch[6]:VISIBLE = NO.
 END.
  IF p-profile-id <> 0 THEN DO:
   term_tt-rule-call-param.profile_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-rule-id <> 0 THEN DO:
   term_tt-rule-call-param.RULE_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-once-more <> 0 THEN DO:
   term_tt-rule-call-param.once-more :VISIBLE IN BROWSE br-rcp= NO.
 END.
VIEW FRAME {&frame-name}.
/*здесь делаем открытие нашего интерфейса*/
selectobject:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
    {&global-int-full} + {&comma-char} + {&global-int} + {&comma-char} +
    {&shops-int-full} + {&comma-char} + {&shops-int}.
if can-find(first obj-list) then do:
  selectobject = integer({&shops-int}).
end.
else do:
  selectobject =integer( {&global-int}).
  define variable v-obj-db-num as integer no-undo .
  if v-running-mode then do:
    for each buf_shop no-lock:
      { gbl/objdbnum.i  {&shop} buf_shop.obj-code v-obj-db-num }
      if v-obj-db-num <> v-cntxt-db-num then next.
      { cmp/cr-objls.i  {&shop} buf_shop.obj-code  }
      find first obj-list where
          obj-list.obj-code = buf_shop.obj-code
        and obj-list.obj-type = {&shop}.
      glog = e-shops:INSERT-STRING ( display-shop(buf_shop.obj-code
                                                , obj-list.obj-name )) in frame {&frame-name} .
      glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .
    end.
  end.
end.
display
selectobject
rs-action
rs-method
v-list-id
with frame {&frame-name} .
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
rs-action
rs-method
selectobject WHEN (p-mode <> {&LOOKUP} and v-running-mode)
button-obj  WHEN (p-mode <> {&LOOKUP} and v-running-mode)
b-lob-sel  WHEN p-mode <> {&LOOKUP}
e-shops
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
   ASSIGN
   b-quit:COLUMN = 1
   b-quit:LABEL = "&Выход".
   HIDE
   b-exit
   IN FRAME {&FRAME-NAME}.
END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры передачи/удаления на кассу/с кассы списка товаров по профайлу &1", p-profile-id).
APPLY "ENTRY" to e-shops.
APPLY "CTRL-HOME" to e-shops.
/*RUN rcps_OpenBr in THIS-PROCEDURE.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*здесь делаем assig и свои свобсвтенные проверки*/
define variable v-ii as integer   no-undo .
assign
frame {&frame-name}
rs-action
rs-method
v-list-id
selectobject
.
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-method"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT rs-method /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).
case rs-method:
  when {&lob-res-list} then do:
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-list"
                                    ,INPUT 0 /*p-index-id*/
                                    ,INPUT substitute("gds-list_&1", v-list-id) /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-list-macro"
                                    ,INPUT 0 /*p-index-id*/
                                    ,INPUT "_" /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).
  end.
  when {&lob-res-list-macro} then do:
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-list-macro"
                                    ,INPUT 0 /*p-index-id*/
                                    ,INPUT substitute("gds-list_&1", v-list-id) /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-list"
                                    ,INPUT 0 /*p-index-id*/
                                    ,INPUT "_" /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).

  end.
end case.
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-action"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT rs-action /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).
case selectobject:
  when integer({&shops-int}) then do:
   v-ii = 0.
   for each obj-list :
    v-ii = v-ii + 1.
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-shops"
                                    ,INPUT v-ii /*p-index-id*/
                                    ,INPUT '' /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT obj-list.obj-code /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).
   end.
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-host-code"
                                    ,INPUT 0 /*p-index-id*/
                                    ,INPUT '' /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).
  end.
  when integer({&global-int}) then do:
    for each obj-list:
      delete obj-list.
    end.
    RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-host-code"
                                    ,INPUT 0 /*p-index-id*/
                                    ,INPUT '' /*p-value-character*/
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                    ).
  end.
end case.
v-ii = v-ii + 1.
do while true:
  run rcps_proc-b-del in this-procedure  (
                                         INPUT p-profile-id
                                        ,INPUT p-once-more
                                        ,INPUT p-call-id
                                        ,input "p-shops"
                                        ,input v-ii) no-error.
  if error-status:error
  or return-value = "not-found" then leave.
  v-ii = v-ii + 1.
end.
run rcps_proc-save0 in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-objects-proc Dialog-Frame
PROCEDURE select-objects-proc :
define input parameter p-save-objects as logical no-undo .
define variable v-ii as integer   no-undo .
define variable v-rid-list as character no-undo .
define variable glog AS LOGICAL no-undo .
define variable v-obj-db-num as integer no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
ASSIGN
e-shops:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ''.
case selectobject :
  when integer({&global-int}) then   do:
    for each obj-list :
      delete obj-list.
    end.
    if v-running-mode then do:
      for each buf_shop no-lock:
        { cmp/cr-objls.i  {&shop} buf_shop.obj-code  }
        { gbl/objdbnum.i  {&shop} buf_shop.obj-code  v-obj-db-num }
        if v-obj-db-num = v-cntxt-db-num then do:
          find first obj-list where
                obj-list.obj-code = buf_shop.obj-code
              and obj-list.obj-type = {&shop}.
          glog = e-shops:INSERT-STRING ( display-shop(
                                                      buf_shop.obj-code
                                                      , obj-list.obj-name )) in frame {&frame-name} .
          glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .
        end.
      end.
    end.
  end.
  when integer({&shops-int}) then do:
    for each obj-list :
      if p-save-objects then do:
        find first buf_shop no-lock where
                  buf_shop.obj-code = obj-list.obj-code no-error.
        if available buf_shop then do:
          v-rid-list = v-rid-list + (if v-rid-list = '' then '' else {&comma-char}) + string(recID(BUF_SHOP)).
        end.
      end.
      delete obj-list.
    end.
    v-save-objects = yes.
    run adm/shops.w ( input parparentproc
                      ,input "b-sel,b-mark"
                      ,input-output v-rid-list
                      ,no ) no-error.
    if v-rid-list <> '' then do:
      do v-ii = 1 to num-entries(v-rid-list):
        find first buf_shop no-lock where
                  recid(buf_shop) = integer(entry(v-ii, v-rid-list)) no-error.
        if available buf_shop then do:
          { cmp/cr-objls.i  ~{&shop~} buf_shop.obj-code  }
          { gbl/objdbnum.i  {&shop} buf_shop.obj-code  v-obj-db-num }
          if v-obj-db-num <> v-cntxt-db-num then do:
            message
            substitute("&1&2принадлежит другой БД - пропускаю ...", {&shop}, buf_shop.obj-code)
            view-as alert-box .
            next.
          end.

          find first obj-list where
                obj-list.obj-code = buf_shop.obj-code
             and obj-list.obj-type = {&shop}.
          glog = e-shops:INSERT-STRING ( display-shop(
                                                     buf_shop.obj-code
                                                     , obj-list.obj-name )) in frame {&frame-name} .
           glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .

        end.
      end.
    end.
    else do:
      undo, return error .
    end.
  end. /*when {&choice}*/
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE val-obj Dialog-Frame
PROCEDURE val-obj :
If SelectObject:SCREEN-VALUE IN FRAME {&FRAME-NAME} = STRING({&shops-int})
 THEN  do:
  enable
  BUTTON-obj
  with frame {&FRAME-NAME} .
end.
else do:
  Disable
  BUTTON-obj
  with frame {&FRAME-NAME} .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME