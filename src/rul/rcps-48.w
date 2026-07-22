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

Задание и просмотр параметров вызова правил - профайл 48

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил - профайл 48".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ rul/rcps.i local-var }
{ cmp/obj-list.i  "new"  }
define variable v-host-code as integer no-undo .

&SCOPED-DEFINE global-int string(0)
&SCOPED-DEFINE global-int-full 'Все'
&SCOPED-DEFINE host-int string(1)
&SCOPED-DEFINE host-int-full 'Фирма'


&SCOPED-DEFINE shops-int string(-1)
&SCOPED-DEFINE shops-int-full 'Выборочно'

FUNCTION display-shop returns character ( input p-obj-code as integer, input p-obj-name as character):
define variable v-string as character no-undo .
v-string = substitute("&1   &2",  string(p-obj-code, ">>>>9"), p-obj-name).
return v-string.
end function.
define variable v-save-objects as logical no-undo .

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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help E-shops SelectObject ~
BUTTON-obj rs-period-type BR-rcp TEXT-1 TEXT-2
&Scoped-Define DISPLAYED-OBJECTS E-shops f-host-code SelectObject ~
rs-period-type TEXT-1 TEXT-2

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "BUTTON-obj"
     SIZE 3 BY .87.

DEFINE VARIABLE E-shops AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 55 BY 13.87 NO-UNDO.

DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Фирма"
     VIEW-AS FILL-IN NATIVE
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE TEXT-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор объекта"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE TEXT-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Выбор диапазона"
      VIEW-AS TEXT
     SIZE 15.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-period-type AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Вчера", "yesterday",
"Пр.неделя", "week-last",
"Пр.месяц", "month-last"
     SIZE 21 BY 8.8 NO-UNDO.

DEFINE VARIABLE SelectObject AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все по фирме", 1,
"Выборочно", 2,
"Все", 0
     SIZE 16.4 BY 2.77 NO-UNDO.

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
     E-shops AT ROW 2 COL 41 NO-LABEL WIDGET-ID 18
     f-host-code AT ROW 3.93 COL 29 COLON-ALIGNED WIDGET-ID 26
     SelectObject AT ROW 4 COL 2 NO-LABEL WIDGET-ID 8
     BUTTON-obj AT ROW 4.47 COL 19 WIDGET-ID 14
     rs-period-type AT ROW 7.93 COL 2.5 NO-LABEL WIDGET-ID 20
     BR-rcp AT ROW 16.97 COL 1 WIDGET-ID 100
     TEXT-1 AT ROW 3 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     TEXT-2 AT ROW 7.13 COL 2.5 NO-LABEL WIDGET-ID 24
     SPACE(81.00) SKIP(15.45)
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
/* BROWSE-TAB BR-rcp rs-period-type Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-host-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN TEXT-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
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


&Scoped-define SELF-NAME BUTTON-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-obj Dialog-Frame
ON CHOOSE OF BUTTON-obj IN FRAME Dialog-Frame /* BUTTON-obj */
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


&Scoped-define SELF-NAME rs-period-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-period-type Dialog-Frame
ON VALUE-CHANGED OF rs-period-type IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-period-type.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelectObject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelectObject Dialog-Frame
ON VALUE-CHANGED OF SelectObject IN FRAME Dialog-Frame
DO:
Assign SelectObject.
v-save-objects = no.
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
  or p-list-mode = {&TABLE_rp-rule-param}  + {&comma-char} + {&all}
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

  RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).
  RUN Myenable in THIS-PROCEDURE.
  /*
  { gbl/mv-clmn.i
    &browse-name = "br-rcp"
    &frame-name = "{&frame-name}"
    &ext-col = 14
    &start-column = 1
    &prev-order-column_1 = "'5,6,7,8,9,10,11,12,13,14,1,2,3,4'"
    &prev-order-column-condition_1 = " p-call-id <> '':U"
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14'"
    &prev-order-column-condition_2 = " p-call-id = '':U "
    }
  */
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
  DISPLAY E-shops f-host-code SelectObject rs-period-type TEXT-1 TEXT-2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help E-shops SelectObject BUTTON-obj rs-period-type
         BR-rcp TEXT-1 TEXT-2
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
run rcps_Myenable0 in this-procedure .
/*здесьс делаем получение наших данных*/
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-period-type"
                                ,INPUT-output v-index-id
                                ,output rs-period-type /*p-value-character*/
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
                                ,INPUT "p-host-code"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-host-code /*p-value-integer*/
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
/*здесь делаем открытие нашего интерфейса*/
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-period-type as character no-undo .
do v-ii = 1 to num-entries({&period-types}):
  v-period-type = entry(v-ii, {&period-types}).
&scop period-type-code v-period-type
  if not (v-period-type = {&period-type-yesterday}
         or
         v-period-type = {&period-type-week-last}
         or
         v-period-type = {&period-type-month-last})
  then next.
  v-jj = v-jj + 1.
  assign
  v-list = v-list + (if v-jj = 1 then '' else {&comma-char}) +
                               {&period-type-name} + {&comma-char} + v-period-type .
end.
rs-period-type:radio-buttons in frame {&frame-name} = v-list.
selectobject:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
    {&global-int-full} + {&comma-char} + {&global-int} + {&comma-char} +
    {&host-int-full} + {&comma-char} + {&host-int} + {&comma-char} +
    {&shops-int-full} + {&comma-char} + {&shops-int}.
f-host-code = v-host-code.
if can-find(first obj-list) then do:
  selectobject = integer({&shops-int}).
end.
else do:
  if v-host-code = 0 then do:
    selectobject =integer( {&global-int}).
    for each buf_shop no-lock:
      { cmp/cr-objls.i  ~{&shop~} buf_shop.obj-code  }
    find first obj-list where
          obj-list.obj-code = buf_shop.obj-code
        and obj-list.obj-type = {&shop}.
    glog = e-shops:INSERT-STRING ( display-shop(buf_shop.obj-code
                                                , obj-list.obj-name )) in frame {&frame-name} .
      glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .

    end.
  end.
  else do:
    for each buf_shop no-lock where buf_shop.host-code = v-host-code:
      { cmp/cr-objls.i  ~{&shop~} buf_shop.obj-code  }
    find first obj-list where
          obj-list.obj-code = buf_shop.obj-code
        and obj-list.obj-type = {&shop}.
      glog = e-shops:INSERT-STRING ( display-shop(
                                                buf_shop.obj-code
                                                , obj-list.obj-name )) in frame {&frame-name} .
      glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .

    end.

    selectobject = integer({&host-int}).
  end.
end.
display
rs-period-type
selectobject
f-host-code when selectobject = 1
with frame {&frame-name} .
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
selectobject WHEN p-mode <> {&LOOKUP}
rs-period-type  WHEN p-mode <> {&LOOKUP}
button-obj  WHEN p-mode <> {&LOOKUP}
br-rcp
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
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры вызова правил: &1", p-title).
RUN rcps_OpenBr in THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*здесь делаем assig и свои свобсвтенные проверки*/
define variable v-ii as integer   no-undo .
assign
frame {&frame-name}
rs-period-type
selectobject
.
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-period-type"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT rs-period-type /*p-value-character*/
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
  when integer({&host-int}) then do:
    assign
    f-host-code
    v-host-code = f-host-code.
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
                                    ,INPUT v-host-code /*p-value-integer*/
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
define buffer buf_sysconf for ub.sysconf.
define buffer buf_shop for ub.shop.
ASSIGN
e-shops:SCREEN-VALUE IN FRAME {&FRAME-NAME} = ''.
case selectobject :
  when integer({&global-int}) then   do:
    for each obj-list :
      delete obj-list.
    end.
    for each buf_shop no-lock:
      { cmp/cr-objls.i  ~{&shop~} buf_shop.obj-code  }
    find first obj-list where
          obj-list.obj-code = buf_shop.obj-code
        and obj-list.obj-type = {&shop}.
    glog = e-shops:INSERT-STRING ( display-shop(
                                                buf_shop.obj-code
                                                , obj-list.obj-name )) in frame {&frame-name} .
      glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .

    end.
  end.
  when integer({&host-int}) then   do:
    for each obj-list :
    delete obj-list.
    end.
      define variable v-firm-code as integer no-undo .
      if f-host-code > 0 then do:
        find first buf_sysconf no-lock where
                  buf_sysconf.host-code = f-host-code no-error .
       if available buf_sysconf then do:
          v-rid-list = STRING(recid(buf_sysconf)).
       end.
      end.
      run adm/sconfs.w (
            input parParentProc
          , input "b-sel":U
          , input no
          , input 0
          , output v-firm-code
          , input-output v-rid-list
      ) no-error.
    if v-rid-list <> '' then do:
      find first buf_sysconf no-lock where
                recid(buf_sysconf) = integer(v-rid-list) .
      for each buf_shop no-lock where
              buf_shop.host-code = buf_sysconf.host-code:
        { cmp/cr-objls.i  ~{&shop~} buf_shop.obj-code  }
          find first obj-list where
                obj-list.obj-code = buf_shop.obj-code
             and obj-list.obj-type = {&shop}.
          glog = e-shops:INSERT-STRING ( display-shop(
                                                      buf_shop.obj-code
                                                     , obj-list.obj-name )) in frame {&frame-name} .
           glog = e-shops:INSERT-STRING ( {&new-line} ) in frame {&frame-name} .
        f-host-code = buf_sysconf.host-code.
        display
        f-host-code
        with frame {&frame-name} .
      end.
    end.
    else do:
      undo, return error .
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
If  SelectObject:screen-value
IN FRAME {&FRAME-NAME} =  string({&host-int})
then  do:
  view
  f-host-code
  in frame {&FRAME-NAME} .
end.
else do:
  hide
  f-host-code
  in frame {&FRAME-NAME} .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
