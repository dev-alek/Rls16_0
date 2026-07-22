&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE rule-call-param.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE rule-call-param.
DEFINE BUFFER X_rp-rule-param FOR rp-rule-param.
DEFINE BUFFER X_rule FOR rule.
DEFINE BUFFER X_ruledict-param FOR ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил для профайла 46

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/03/10
Author: Bakhtadze Natalya
Creation date: 02/03/10

no_app_help.i

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 46".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ rul/rcps.i local-var }
{ gbl/getcntxt.i def }
{ cmp/library.i }
define variable v-running-mode as logical no-undo .
define variable v-tpl as character no-undo .
define variable v-templ-rl-root as integer no-undo .

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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help F-tpl button-tpl ~
tpl-name f-coeff EDITOR-1 BR-rcp
&Scoped-Define DISPLAYED-OBJECTS F-tpl tpl-name f-coeff EDITOR-1

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

DEFINE BUTTON button-tpl
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 71 BY 2.93
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-coeff AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 NO-UNDO.

DEFINE VARIABLE F-tpl AS CHARACTER FORMAT "X(256)":U
     LABEL "Код ТПЛ-БД"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE tpl-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 98 BY 1
     FGCOLOR 4  NO-UNDO.

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
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     F-tpl AT ROW 3.13 COL 11 COLON-ALIGNED WIDGET-ID 76
     button-tpl AT ROW 3.13 COL 34.5 WIDGET-ID 52
     tpl-name AT ROW 4.2 COL 1 NO-LABEL WIDGET-ID 78
     f-coeff AT ROW 5.27 COL 13.5 COLON-ALIGNED WIDGET-ID 74
     EDITOR-1 AT ROW 5.27 COL 27.5 NO-LABEL WIDGET-ID 80
     BR-rcp AT ROW 10 COL 1 WIDGET-ID 100
     SPACE(0.00) SKIP(1.99)
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
/* BROWSE-TAB BR-rcp EDITOR-1 Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

ASSIGN
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN tpl-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       tpl-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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


&Scoped-define SELF-NAME button-tpl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL button-tpl Dialog-Frame
ON CHOOSE OF button-tpl IN FRAME Dialog-Frame /* ... */
DO:
 DEFINE VARIABLE v-charkey_one AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
 DEFINE BUFFER local_price-list-type FOR ub.price-list-type.
 DEFINE BUFFER local2_price-list-type FOR ub.price-list-type.
 IF v-tpl <> '' then do:
    find first local_price-list-type no-lock where
              local_price-list-type.plt-id = integer(entry(1, v-tpl, "-") )
          and local_price-list-type.plt-db-num = integer(entry(2, v-tpl, "-") ) no-error.
    if available local_price-list-type then do:
      v-rid-list = STRING(RECID(local_price-list-type)).
      tpl-name =     local_price-list-type.NAME .
      v-templ-rl-root = local_price-list-type.ban-discnt.
      display
      v-tpl @ f-tpl
      tpl-name
      with frame {&frame-name} .
    end.
 END.
 else do:
   v-rid-list = string(v-templ-rl-root).
 end.
 run ref/typepric.w (
                      input  parParentProc
                     ,INPUT "b-sel,mode=ban-discnt"
                     ,INPUT-OUTPUT v-rid-list ) NO-ERROR.
IF error-status:error
or v-rid-list = ""
THEN RETURN NO-APPLY.
 IF (available local_price-list-type and v-rid-list <> string(v-templ-rl-root))
 or not available local_price-list-type
 THEN DO:
     FIND FIRST local2_price-list-type NO-LOCK WHERE
                recid(local2_price-list-type) = INTEGER(v-rid-list) NO-ERROR.
    IF AVAILABLE local2_price-list-type THEN DO:
        ASSIGN
        f-tpl = SUBSTITUTE("&1-&2"
                    , local2_price-list-type.plt-id
                    , local2_price-list-type.plt-db-num)
        tpl-name =     local2_price-list-type.NAME
        .

        DISPLAY
        f-tpl
        tpl-name
        WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
      MESSAGE
      substitute("Не удалось найти ТПЛ с recid=&1", v-rid-list)
      VIEW-AS ALERT-BOX ERROR.
    END.
 END.
 apply "entry" to f-tpl in FRAME {&FRAME-NAME}.
 return no-apply.
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
  DISPLAY F-tpl tpl-name f-coeff EDITOR-1
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help F-tpl button-tpl tpl-name f-coeff EDITOR-1 BR-rcp
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
run rcps_Myenable0 in this-procedure .
/*здесьс делаем получение наших данных*/
v-index-id = -1.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-tpl"
                                ,INPUT-output v-index-id
                                ,output v-tpl /*p-value-character*/
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
                                ,INPUT "p-coeff"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output f-coeff /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
if v-tpl <> '' then do:
  DEFINE BUFFER local_price-list-type FOR ub.price-list-type.
  find first local_price-list-type no-lock where
            local_price-list-type.plt-id = integer(entry(1, v-tpl, "-") )
        and local_price-list-type.plt-db-num = integer(entry(2, v-tpl, "-") ) no-error.
  if available local_price-list-type then do:
    tpl-name =     local_price-list-type.NAME .
    v-templ-rl-root = local_price-list-type.ban-discnt.
    display
    v-tpl @ f-tpl
    tpl-name
    with frame {&frame-name} .
  end.
end.
else do:
  define variable dflt-cd as character no-undo .
  define buffer buf_shop for ub.shop.
  dflt-cd = ''.
  find first buf_shop no-lock.
  { gbl/dflt-cd.i {&shop} buf_shop.obj-code dflt-cd }
  case dflt-cd:
    when {&cd-type-ibm} then do:
      v-templ-rl-root = 87.
    end.
    when {&cd-type-ibs-th} then do:
      v-templ-rl-root = 88.
    end.
    otherwise do:
      message
      substitute("Не определен ШАБЛОН правил скидки по СТПЛ для POS=&1", dflt-cd)
      view-as alert-box error .
      return error .
    end.
  end.
end.
v-templ-rl-root = 88.
ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
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
editor-1:screen-value = "Коэффициент на который на до умножить частное" +
                         " ЦЕНА НА ДОП.ЕД.ИЗМ. ПО ГТПЛ / КОЛ-ВО В УПАКОВКЕ," +
                         " чтобы получить цену на осн. ед.изм. в создаваемом ДНЦ".
display
f-coeff
with frame {&frame-name} .
VIEW FRAME {&frame-name}.
ENABLE
f-coeff WHEN p-mode <> {&LOOKUP}
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
button-tpl  WHEN p-mode <> {&LOOKUP}
editor-1
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
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры создания ДНЦ определенного типа и определенного содержания по алгоритму raimbek (профайл &1)", p-profile-id).
/*RUN rcps_OpenBr in THIS-PROCEDURE.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*здесь делаем assig и свои свобсвтенные проверки*/
assign
frame {&frame-name}
f-tpl
f-coeff
.

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-tpl"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT f-tpl /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-coeff"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT f-coeff /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).
run rcps_proc-save0 in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
