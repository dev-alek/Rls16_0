&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt2-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Привязки RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/05
Author: Bakhtadze Natalya
Creation date: 12/09/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter p-profile-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Привязки RUM" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/operlist.i }
{ gbl/getcntxt.i  def }
{ gbl/thbjattr.i }
{ gbl/color.i }

define variable v-r-b-code like ub.currency.curr-code no-undo .
define variable v-curr-r-b  as character no-undo .

{ gbl/key-rec.i }
{ rul/calldscr.i }
{ adm/thbj-rum.i }

&scop label-name "Название алгоритма"

define variable add-option as character no-undo.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO EXTENT 3.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
define variable v-start as logical no-undo .
define variable v-h-name as handle no-undo .
define variable v-is-copy as logical no-undo .
define variable v-orig-uniq-key-rec as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-profile

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt0-rp-by-call tt0-rule-by-call ~
X_rule-profile

/* Definitions for BROWSE br-profile                                    */
&Scoped-define FIELDS-IN-QUERY-br-profile tt0-rp-by-call.profile_id get-profile-name ( INPUT tt0-rp-by-call.profile_id) get-profile-dynamic ( INPUT tt0-rp-by-call.profile_id) tt0-rp-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-profile
&Scoped-define SELF-NAME br-profile
&Scoped-define QUERY-STRING-br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-profile OPEN QUERY {&SELF-NAME} FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-profile tt0-rp-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-br-profile tt0-rp-by-call


/* Definitions for BROWSE br-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-call tt0-rule-by-call.can-calc tt0-rule-by-call.algo-des tt0-rule-by-call.is_dynamic tt0-rule-by-call.codex_id tt0-rule-by-call.ruleset_id tt0-rule-by-call.order_id tt0-rule-by-call.rule_id tt0-rule-by-call.profile_id tt0-rule-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&Scoped-define QUERY-STRING-br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-by-call OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-by-call tt0-rule-by-call ~
X_rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-call tt0-rule-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-call X_rule-profile


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-profile}~
    ~{&OPEN-QUERY-br-rule-by-call}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help Rs-algo-profile ~
rs-algo-types b-addalgo b-delalgo b-params B-rule B-ruleset b-rule-on-off ~
br-rule-by-call br-profile E-rule-name
&Scoped-Define DISPLAYED-OBJECTS Rs-algo-profile rs-algo-types E-rule-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-documentation Dialog-Frame
FUNCTION get-profile-documentation RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-dynamic Dialog-Frame
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-name Dialog-Frame
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-region Dialog-Frame*/
/*FUNCTION get-region RETURNS CHARACTER*/
/*  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer )  FORWARD.*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Граф"          .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-addalgo
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-delalgo
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rule
     LABEL "Правило"
     SIZE 10 BY 1.

DEFINE BUTTON b-rule-on-off
     LABEL "Вкл"
     SIZE 5 BY 1.

DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.

DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 4.17
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE Rs-algo-profile AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-algo-types AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Настраив.", 2
     SIZE 18 BY .77 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-profile FOR
      tt0-rp-by-call SCROLLING.

DEFINE QUERY br-rule-by-call FOR
      tt0-rule-by-call,
      X_rule-profile SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-profile Dialog-Frame _FREEFORM
  QUERY br-profile NO-LOCK DISPLAY
      tt0-rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9":U
get-profile-name ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL {&label-name} FORMAT "X(255)"
get-profile-dynamic ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
tt0-rp-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.77
         FONT 4 ROW-HEIGHT-CHARS .67.

DEFINE BROWSE br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-by-call Dialog-Frame _FREEFORM
  QUERY br-rule-by-call NO-LOCK DISPLAY
      tt0-rule-by-call.can-calc COLUMN-LABEL "Вкл." FORMAT "+/":U
tt0-rule-by-call.algo-des COLUMN-LABEL "Описание алгоритма/правила" FORMAT "X(255)":U WIDTH 40
tt0-rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое?" FORMAT "+/":U
tt0-rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
tt0-rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>,>>>,>>9":U WIDTH 9
tt0-rule-by-call.profile_id COLUMN-LABEL "Алгоритм" FORMAT ">>9":U WIDTH 8
tt0-rule-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.77
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     B-Help AT ROW 1 COL 95
     Rs-algo-profile AT ROW 2 COL 1 NO-LABEL WIDGET-ID 2
     rs-algo-types AT ROW 2 COL 22 NO-LABEL
     b-addalgo AT ROW 2 COL 40
     b-delalgo AT ROW 2 COL 50
     b-params AT ROW 2 COL 60 WIDGET-ID 6
     B-rule AT ROW 2 COL 70
     B-ruleset AT ROW 2 COL 80 WIDGET-ID 26
     b-rule-on-off AT ROW 2 COL 94
     br-rule-by-call AT ROW 3 COL 1
     br-profile AT ROW 3 COL 1 WIDGET-ID 100
     E-rule-name AT ROW 18.77 COL 1 NO-LABEL
     SPACE(0.00) SKIP(0.34)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязки RUM"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt0-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt2-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-by-call b-rule-on-off Dialog-Frame */
/* BROWSE-TAB br-profile br-rule-by-call Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rule:HANDLE.

ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-profile
/* Query rebuild information for BROWSE br-profile
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt0-rp-by-call WHERE
         tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_rule-by-call.call_id = dis-card-type.uniq-key-rec"
     _Query            is OPENED
*/  /* BROWSE br-profile */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-call
/* Query rebuild information for BROWSE br-rule-by-call
     _START_FREEFORM
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE
    tt0-rule-by-call.call_id = p-uniq-key-rec,
    FIRST X_rule-profile NO-LOCK WHERE
        X_rule-profile.profile_id = tt0-rule-by-call.profile_id
  AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)
 BY tt0-rule-by-call.codex_id
 BY tt0-rule-by-call.ruleset_id
 BY tt0-rule-by-call.order_id
 INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Temp-Tables.tt-rule-by-call.emitent-host-code = 0
 AND Temp-Tables.tt-rule-by-call.type = ""66"""
     _Query            is OPENED
*/  /* BROWSE br-rule-by-call */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязки RUM */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-addalgo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-addalgo Dialog-Frame
ON CHOOSE OF b-addalgo IN FRAME Dialog-Frame /* Добавить */
DO:
DEFINE VARIABLE v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
run ref/rulprofs.w (
                     INPUT parparentproc
                    ,INPUT "b-sel"
                    ,INPUT (p-profile-type + (if parobj-type <> "" then ({&delim-par} + parobj-type) else ""))
                    ,INPUT-OUTPUT v-ref-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-apply.
END.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          recid(buf_rule-profile) = INTEGER(v-ref-list) NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN NO-APPLY.
if buf_rule-profile.parent-feature = integer({&rp-parentf-only-in-combo}) then do:
  message
  "Данный алгоритм можно добавлять ТОЛЬКО В СОСТАВЕ КОМБИНИРОВАННЫХ АЛГОРИТМОВ!"
  view-as alert-box error.
  undo, return no-apply.
end.
if lookup(buf_rule-profile.short-name, "obj") = 0
and v-obj-type <> ''
then do:
  message
  "Данный алгоритм НЕЛЬЗЯ добавлять в контексте объекта!"
  view-as alert-box error.
  undo, return no-apply.
end.

  RUN proc-b-addalgo IN THIS-PROCEDURE ( BUFFER buf_rule-profile) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-delalgo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-delalgo Dialog-Frame
ON CHOOSE OF b-delalgo IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
  run proc-b-delalgo IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "value-changed" TO br-rule-by-call.
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


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Параметры */
DO:
  CASE Rs-algo-profile:
    when {&table_rule-by-call} then do:
      IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
      run ref/rulercps.w (
                             input parparentproc
                            ,input this-procedure:handle
                            ,input '':U
                            ,input {&lookup}
                            ,input {&table_rule-call-param}
                            ,input 0 /*p-profile-id*/
                            ,input ? /*p-once-more*/
                            ,input tt0-rule-by-call.call_id /*p-call-id*/
                            ,input tt0-rule-by-call.codex_id /*p-codex-id*/
                            ,input tt0-rule-by-call.ruleset_id /*p-codex-id*/
                            ,input tt0-rule-by-call.order_id /*p-order-id*/
                            ,input tt0-rule-by-call.RULE_id /*p-rule-id*/
                            ,INput substitute("Правило &1 &2"
                                             , tt0-rule-by-call.RULE_id
                                             , calldscr(tt0-rule-by-call.call_id)
                                             )  /**/
                            ,input-output table tt0-rule-call-param  ) no-error.

     end.
     when {&table_rp-by-call} then do:
      IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
      define variable v-param-form as character no-undo .
      define buffer buf_rule-profile for ub.rule-profile.
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
      assign
      v-param-form = (if buf_rule-profile.custom-param-form > 0
                      then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                      else "ref/rulercps.w")
      .
      if v-obj-type <> ''
      and lookup("obj", buf_rule-profile.short-name) = 0
      then do:
        define variable v-mode as character no-undo .
        v-mode = {&lookup}.
      end.
      else do:
        v-mode = p-mode.
      end.
      run value(v-param-form) (
                            input parparentproc
                            ,input this-procedure:handle
                            ,input 'b-chg':U
                            ,input v-mode
                            ,input {&table_rp-rule-param}
                            ,input tt0-rp-by-call.profile_id /*p-profile-id*/
                            ,input tt0-rp-by-call.once-more /*p-once-more*/
                            ,input tt0-rp-by-call.call_id /*p-call-id*/
                            ,input 0 /*p-codex-id*/
                            ,input 0 /*p-codex-id*/
                            ,input ? /*p-order-id*/
                            ,input 0 /*p-rule-id*/
                            ,INput substitute("Профайл &1 № привязки &2 &3"
                                              ,tt0-rp-by-call.profile
                                              ,tt0-rp-by-call.once-more
                                              ,calldscr(tt0-rp-by-call.call_id)
                                              )  /**/
                            ,input-output table tt0-rule-call-param  ) no-error.

     end.
   end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rule Dialog-Frame
ON CHOOSE OF B-rule IN FRAME Dialog-Frame /* Правило */
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                             INPUT rule-display-option
                                            ,input tt0-rule-by-call.codex_id
                                            ,input tt0-rule-by-call.ruleset_id
                                            ,input tt0-rule-by-call.call_id
                                            ,input tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    ASSIGN
    rule-display-option = "".
    RETURN NO-APPLY.
  END.
  ASSIGN
  rule-display-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule-on-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule-on-off Dialog-Frame
ON CHOOSE OF b-rule-on-off IN FRAME Dialog-Frame /* Вкл */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF X_rule-profile.IS_dynamic = NO  THEN DO:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "так как принадлежит алгоритму ПО УМОЛЧАНИЮ!"
                , {&NEW-LINE})
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  if tt0-rule-by-call.is_dynamic = no then do:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "согласно определенной профайлом логике!"
                , {&NEW-LINE})
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.

  end.
  IF tt0-rule-by-call.can-calc THEN DO:
    MESSAGE
    "Вы уверены, что хотите выключить правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
    IF NOT glog THEN RETURN NO-APPLY.
  END.
  ELSE DO:
      MESSAGE
      "Вы уверены, что хотите включить правило?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
      IF NOT glog THEN RETURN NO-APPLY.
  END.
  ASSIGN
  tt0-rule-by-call.can-calc = NOT (tt0-rule-by-call.can-calc).
  glog = br-rule-by-call:REFRESH() IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ruleset Dialog-Frame
ON CHOOSE OF B-ruleset IN FRAME Dialog-Frame /* Т-ка вызова */
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe tt0-rule-by-call THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = tt0-rule-by-call.codex_id
        AND buf_ruleset.ruleset_id = tt0-rule-by-call.ruleset_id.

  run rul/ruleset-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input buf_ruleset.codex_id
                       ,input buf_ruleset.ruleset_id
                       ,input-output v-rec) no-error.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-profile
&Scoped-define SELF-NAME br-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-profile Dialog-Frame
ON VALUE-CHANGED OF br-profile IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt0-rp-by-call THEN DO:
     e-rule-name:SCREEN-VALUE = ''.
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = get-profile-documentation(tt0-rp-by-call.profile_id).
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-by-call Dialog-Frame
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = tt0-rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", tt0-rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = buf_rule.name + {&NEW-LINE} + buf_rule.documentation.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_graph /* Граф */
DO:
    IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_text /* Текст */
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "text".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-algo-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-algo-profile Dialog-Frame
ON VALUE-CHANGED OF Rs-algo-profile IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-profile.
  CASE rs-algo-profile:
    WHEN {&TABLE_rule-by-call} THEN DO:
      HIDE
      br-profile
      b-addalgo
      b-delalgo

      IN FRAME {&FRAME-NAME}.
      .
      DISPLAY
      rs-algo-types
      br-rule-by-call
      b-rule
      b-ruleset
      b-rule-on-off
      WITH FRAME {&FRAME-NAME}.
      APPLY "VALUE-CHANGED" to br-rule-by-call.
    END.
    WHEN {&TABLE_rp-by-call} THEN DO:
      HIDE
      br-rule-by-call
      rs-algo-types
      b-rule
      b-ruleset
      b-rule-on-off
      IN FRAME {&FRAME-NAME}.
      DISPLAY
      br-profile
      b-addalgo
      b-delalgo
      WITH FRAME {&FRAME-NAME}.
      APPLY "VALUE-CHANGED" to br-profile.
    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-algo-types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-algo-types Dialog-Frame
ON VALUE-CHANGED OF rs-algo-types IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-types.
  {&OPEN-QUERY-br-rule-by-call}
  APPLY "VALUE-CHANGED" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-profile
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

ON ROW-DISPLAY OF br-profile IN frame {&frame-name}
DO:
  IF AVAIL tt0-rp-by-call THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT tt0-rp-by-call.parent-profile_id).
  END.
END.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ rul/rcpscont.i tt0-rule-by-call ~{&open-QUERY-br-rule-by-call~} }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i  get }
  { gbl/curr-r-b.i v-curr-r-b   }
  if p-mode <> {&update}
  and p-mode <> {&add-def}
  AND p-mode <> {&lookup}
  and p-mode <> {&add-copy}
  then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова p-mode"
        view-as alert-box ERROR.
        return error.
    end.
  if p-mode = {&add-copy} then do:
    v-is-copy = yes.
    p-mode = {&update}.
  end.
  if p-mode = {&update} or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      do transaction
      on error undo, return error
      on stop undo, return error
      :
      run gen-row-keyr in this-procedure (
                                           input  p-uniq-key-rec
                                          ,input  ? /* p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                          ,input  "ub"
                                          ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                          ,input  EXCLUSIVE-LOCK
                                          ,output v-tbl-row
                                          ,output v-tbl-name
                                          ).
        find first buf_thbj-attr EXclusive-lock where
                 rowid(buf_thbj-attr) = v-tbl-row no-wait no-error.
        if locked buf_thbj-attr then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись занята"
          view-as alert-box error .
          return error.
        end.
        if not available buf_thbj-attr then do:
        end.
      end.
    end.
    else do:
      run gen-row-keyr in this-procedure (
                                           input  p-uniq-key-rec
                                          ,input  ? /* p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                          ,input  "ub"
                                          ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                          ,input  NO-LOCK
                                          ,output v-tbl-row
                                          ,output v-tbl-name
                                          ).
      find first buf_thbj-attr no-lock where
                rowid(buf_thbj-attr) = v-tbl-row .
    end.
    if not available buf_thbj-attr then do:

      message vss-workfile vss-revision vss-description skip
              "Не найдена запись"
      view-as alert-box error .
    end.
    assign
    v-obj-type = buf_thbj-attr.obj-type
    v-obj-code = buf_thbj-attr.obj-code
    .
  end.
  ELSE DO:
  END.
  if v-is-copy
  or ( not (buf_thbj-attr.obj-type = ''
            and
            buf_thbj-attr.obj-code = 0)
       and buf_thbj-attr.property-value-logical = no
          )
  then do:
    define variable v-field-list as character no-undo .
    define variable v-value-list as character no-undo .
    run gen-key-fv in this-procedure ( input p-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
    assign
    v-orig-uniq-key-rec = p-uniq-key-rec.
    assign
    entry(lookup("obj-type", v-field-list, {&delim-key}) + 1, v-orig-uniq-key-rec, {&delim-key}) = ''
    entry(lookup("obj-code", v-field-list, {&delim-key}) + 1, v-orig-uniq-key-rec, {&delim-key}) = string(0)
    entry(lookup("upper-prop-code", v-field-list, {&delim-key}) + 1, v-orig-uniq-key-rec, {&delim-key}) = {&attr-rum}
    .
    run thbj-rum_fill-table in this-procedure (
                                               input p-profile-type
                                              ,input p-mode + {&delim-par} + "obj"
                                              ,input yes
                                              ,input v-orig-uniq-key-rec).
   run thbj-rum_rename-call-id in this-procedure (
                                                   input v-orig-uniq-key-rec
                                                  ,input p-uniq-key-rec
                                                  ) no-error.
  end.
  else do:
  RUN thbj-rum_FILL-table IN THIS-PROCEDURE (
                                              input p-profile-type
                                             ,input p-mode
                                             ,input no /*p-silent*/
                                             ,input p-uniq-key-rec)
                                             no-error .
  end.
  if error-status:error then do:
    message
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo main-block, return error .
  end.
  {&OPEN-QUERY-br-profile}
  APPLY "VALUE-CHANGED" to br-profile IN FRAME {&FRAME-NAME}.
  {&OPEN-QUERY-br-rule-by-call}
  APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buttons Dialog-Frame
PROCEDURE buttons :
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
  DISPLAY Rs-algo-profile rs-algo-types E-rule-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help Rs-algo-profile rs-algo-types b-addalgo b-delalgo
         b-params B-rule B-ruleset b-rule-on-off br-rule-by-call br-profile
         E-rule-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-check-by-mask AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
define variable v-label as character no-undo .
define variable v-tooltip-code as character no-undo .

DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.

ASSIGN
rs-algo-profile:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "Алгоритмы" + {&comma-char} +
                                 {&TABLE_rp-by-call} + {&comma-char} +
                                "Правила" + {&comma-char} + {&TABLE_rule-by-call}.
rs-algo-profile = {&TABLE_rp-by-call}.
ASSIGN
tt0-rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES .
DO ii = 1 TO br-profile:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    clh = BROWSE br-profile:get-browse-column(ii).
  IF clh:LABEL BEGINS {&label-name} THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
      clh:width = 72
    v-h-name = clh
      .
    END.
END.
  assign
  b-rule:MENU-MOUSE in frame {&frame-name} = 1
  .
run thbjattr_tooltip in this-procedure (
                                           input  buf_thbj-attr.upper-prop-code
                                          ,input  buf_thbj-attr.prop-code
                                          ,output v-tooltip
                                          ,output v-label
                                          ,output v-tooltip-code ).
frame {&frame-name}:title = v-label.

DISPLAY
rs-algo-types
rs-algo-profile
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit when p-mode <> {&lookup}
b-quit
B-Help
rs-algo-profile
b-rule
b-ruleset
b-addalgo when p-mode <> {&lookup}
b-delalgo when p-mode <> {&lookup}
b-rule-on-off when p-mode <> {&lookup}
b-params
br-rule-by-call
br-profile
rs-algo-types
e-rule-name
WITH FRAME {&frame-name}.
if p-mode = {&lookup} then do:
    HIDE
    b-exit in frame {&frame-name}.
    assign
    b-quit:label in frame {&frame-name} = "&Выход"
    b-quit:column in frame {&frame-name} = 1
    e-rule-name:read-only in frame {&frame-name} = yes
    .
end.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "VALUE-CHANGED" TO rs-algo-profile.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-addalgo Dialog-Frame
PROCEDURE proc-b-addalgo :
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
run thbj-rum_proc-b-addalgo in this-procedure (  input no /*p-silent*/
                                        ,input v-start /*v-start*/
                                        ,input p-uniq-key-rec
                                        ,buffer buf_rule-profile
                                        ) no-error .
    if error-status:error then do:
      message
  return-value
  view-as alert-box .
  return.
end.
{&OPEN-QUERY-br-profile}
APPLY "VALUE-CHANGED" to br-profile IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-rule-by-call}
APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-delalgo Dialog-Frame
PROCEDURE proc-b-delalgo :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-rule-nums AS INTEGER NO-UNDO.
DEFINE VARIABLE v-profile-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
IF NOT AVAILABLE tt0-rp-by-call THEN RETURN ERROR.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN DO:
   MESSAGE
   substitute("Не найден алгоритм с кодом &1", tt0-rp-by-call.profile_id)
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
IF buf_rule-profile.IS_dynamic = NO THEN DO:
   MESSAGE
   "Привязку к данному алгоритм НЕЛЬЗЯ удалить!"
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
if buf_rule-profile.parent-feature = integer({&rp-parentf-only-in-combo})
or tt0-rp-by-call.parent-profile_id > 0
then do:
  message
  "Данный алгоритм можно удалять ТОЛЬКО В СОСТАВЕ КОМБИНИРОВАННЫХ АЛГОРИТМОВ!"
  view-as alert-box error.
  undo, return no-apply.
end.
MESSAGE
"Вы уверены, что хотите удалить привязку к данному алгоритму?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
/*заблокируем*/
define variable v-ii as integer no-undo .
define variable v-current-uniq-key-rec as character no-undo .
define variable v-current-profile-id as integer no-undo .
define variable v-profile-id-list as character no-undo .
define variable v-call-id-list as character no-undo .
define variable v-once-more-list as character no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
assign
v-call-id-list = p-uniq-key-rec
v-profile-id-list = string(tt0-rp-by-call.profile_id)
v-once-more-list = string(tt0-rp-by-call.once-more)
.
FIND FIRST buf_rule-profile EXCLUSIVE-LOCK WHERE buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
if buf_rule-profile.profile-type = {&cmb} then do:
  do v-ii = 1 to num-entries({&profile-type-list}):
    v-current-uniq-key-rec = p-uniq-key-rec.
    entry(lookup({&cmb}, p-uniq-key-rec, {&delim-key}), v-current-uniq-key-rec, {&delim-key}) = entry(v-ii, {&profile-type-list}).
    for each buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = v-current-uniq-key-rec
        and buf_rp-by-call.parent-profile_id = buf_rule-profile.profile_id
        :
      v-current-profile-id = buf_rp-by-call.profile_id.
      assign
      v-call-id-list = v-call-id-list +  {&delim-par}  +  v-current-uniq-key-rec
      v-profile-id-list = v-profile-id-list + {&comma-char} + string(v-current-profile-id)
      v-once-more-list = v-once-more-list +  {&comma-char}  +  string(buf_rp-by-call.once-more)
      .
    end.
  end.
end.
do v-ii = 1 to num-entries(v-call-id-list, {&delim-par} ):
  find first tt0-rp-by-call where
            tt0-rp-by-call.call_id = entry(v-ii, v-call-id-list, {&delim-par} )
        and tt0-rp-by-call.profile_id = integer(entry(v-ii, v-profile-id-list ))
       and tt0-rp-by-call.once-more = integer(entry(v-ii, v-once-more-list )).
  FOR EACH buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.call_id = entry(v-ii, v-call-id-list, {&delim-par} )
      and   buf_tt0-rule-by-call.profile_id = integer(entry(v-ii, v-profile-id-list))
      and buf_tt0-rule-by-call.once-more = integer(entry(v-ii, v-once-more-list))
  ON error UNDO, RETURN ERROR:
    for each buf_tt0-rule-call-param where
            buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
      and buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
      and buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
      and buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
      ON error UNDO, RETURN ERROR:
      delete buf_tt0-rule-call-param.
    end.
    DELETE buf_tt0-rule-by-call.
  END.
  DELETE tt0-rp-by-call.
end.
{&OPEN-QUERY-br-profile}
APPLY "VALUE-CHANGED" to br-profile IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-rule-by-call}
APPLY "value-changed" TO br-rule-by-call  IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-display-rule Dialog-Frame
PROCEDURE proc-display-rule :
DEFINE INPUT PARAMETER p-DISPLAY-MODE AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
run rul/disprule.p (
                       input p-DISPLAY-MODE
                      ,input p-rule-id
                      ,input p-codex-id
                      ,input p-ruleset-id
                      ,input p-call-id
                      ,input p-order-id
                       ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-old-call-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new-call-id AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable choice as integer no-undo .
define variable v-found-new as logical no-undo .
define variable v-logical-value as logical no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
define buffer buf_rule-profile for ub.rule-profile.
if parobj-code > 0 then do:
  find first buf_tt0-rp-by-call no-error.
  if not available buf_tt0-rp-by-call then do:
    run gbl/d-askw.w (input "Вопрос"
                    ,input  substitute("Вы не определили ни одно профайла&1"+
                          "Предполагается, что должны работать профайлы, определенные в ГЛОБАЛЬНОМ контесте,&1" +
                          "или работа по профайлам ВООБЩЕ не требуется?"
                          , {&new-line})
                    ,input "|"
                    ,input "ГЛОБАЛЬНЫЕ ПРОФАЙЛЫ|БЕЗ ПРОФАЙЛОВ|Отменить"
                    ,input "||"
                    ,input 1
                    ,input 3
                    ,output choice).
    if choice = 3
    then do:
        undo, return error ''.
    end.
    if choice = 1 then v-logical-value = no.
    if choice = 2 then v-logical-value = yes. /*объектный активен*/

  end.
  else do:
    v-logical-value = yes.
  end.
end.
else do:
  v-logical-value = yes.
end.


/*проверка - не удален ли какой нибудь профайл*/
for each buf_rp-by-call where
          buf_rp-by-call.call_id = p-uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = buf_rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_tt0-rp-by-call where
            buf_tt0-rp-by-call.call_id = buf_rp-by-call.call_id
        and buf_tt0-rp-by-call.profile_id =  buf_rp-by-call.profile_id
        and buf_tt0-rp-by-call.once-more =  buf_rp-by-call.once-more no-error.
  if not available buf_tt0-rp-by-call then do:
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь удалить профайл(ы)" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к РАССИНХРОНИЗАЦИИ данных"  skip(0)
     "2. Даже если Вы передумаете и вновь добавите удаленные профайл(ы)," skip(0)
     "данные по изменениям за этот период будут отсутствовать" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
/*проверка - не добавлен ли какой нибудь профайл*/
for each tt0-rp-by-call where
          tt0-rp-by-call.call_id = p-uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_rp-by-call where
            buf_rp-by-call.call_id = buf_tt0-rp-by-call.call_id
        and buf_rp-by-call.profile_id =  buf_tt0-rp-by-call.profile_id
        and buf_rp-by-call.once-more =  buf_tt0-rp-by-call.once-more no-error.
  if not available buf_rp-by-call then do:
     v-found-new = yes.
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь добавить профайл(ы)" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к неполноте данных по некоторым БД и т.д." skip(0)
     "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
     "несвоевременное включение/выключение любого из этих правил МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
if not v-found-new  then do:
  message
  "ВНИМАНИЕ!!!" skip(0)
  "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
  "1. Изменения в работе системы" skip(0)
  "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
  "Это может привести к неполноте данных по некоторым БД и т.д." skip(0)
  "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
  "несвоевременное включение/выключение любого правил из этих МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
   view-as alert-box WARNING buttons yes-no update v-ok.
  if not v-ok then do:
    undo, return .
  end.
end.
run rul/thbjrum1.p (
                 input p-mode
                ,input p-profile-type
                ,input p-uniq-key-rec
                ,input 0
                ,input "":U
                ,input 0
                ,input v-logical-value
                ,INPUT TABLE tt0-rp-by-call
                ,INPUT TABLE tt0-rule-by-call
                ,INPUT TABLE tt0-rule-call-param) no-error .
if error-status:error then do:
{ gbl/reterhnd.i error }
if return-value <> '':U then do:
  message
  error-status:get-message(1)
  return-value
  view-as alert-box .
end.
return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-parent-profile-id AS integer NO-UNDO.
if p-parent-profile-id > 0 then do:
  if valid-handle(v-h-name) then
  assign
  v-h-name:BGCOLOR = GRAY_COLOR
    .
end.
else do:
  if valid-handle(v-h-name) then
  assign
  v-h-name:BGCOLOR = ?
    .
end.

END PROCEDURE.

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-documentation Dialog-Frame
FUNCTION get-profile-documentation RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ''.   /* Function return value. */
RETURN buf_rule-profile.documentation.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-dynamic Dialog-Frame
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ?.   /* Function return value. */
RETURN buf_rule-profile.is_dynamic.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-name Dialog-Frame
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN {&question-mark}.   /* Function return value. */
RETURN buf_rule-profile.NAME.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-region Dialog-Frame*/
/*FUNCTION get-region RETURNS CHARACTER*/
/*  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :*/
/*/*------------------------------------------------------------------------------*/
/*  Purpose:*/
/*    Notes:*/
/*------------------------------------------------------------------------------*/*/

/*  define variable par-region as character no-undo.*/
/*  if parhost-code = 0 and*/
/*       parobj-type = "":U and*/
/*       parobj-code = 0 then do:*/
/*       par-region = "Глобально".*/
/*       return par-region.*/
/*    end.*/
/*    if parobj-type = "" and*/
/*       parobj-code = 0 then do:*/
/*       par-region = fill({&space-char}, 2) + "Фирма" + {&space-char} + string(parhost-code).*/
/*       return par-region.*/
/*    end.*/
/*    par-region = fill({&space-char}, 4) + parobj-type + {&space-char} + string(parobj-code).*/
/*    return par-region.*/

/*END FUNCTION.*/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME