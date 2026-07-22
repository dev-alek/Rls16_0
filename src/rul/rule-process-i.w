&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_rule-process FOR ub.rule-process.
DEFINE TEMP-TABLE tt-rule-process NO-UNDO LIKE ub.rule-process.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка rule-process

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/15/08
Author: Bakhtadze Natalya
Creation date: 07/15/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-pchain-type as character no-undo .
define input parameter p-pchain-id as character no-undo .
define input parameter p-start-from as integer no-undo .
define input parameter p-link-id as integer no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка rule-process".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/key-rec.i }
DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
define variable v-is-copy as logical no-undo .
DEFINE BUFFER buf_rule-process FOR ub.rule-process.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rule-process

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-rule-process.pchain-type ~
tt-rule-process.pchain-id tt-rule-process.start-from ~
tt-rule-process.link-id tt-rule-process.codex_id tt-rule-process.ruleset_id ~
tt-rule-process.documentation
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rule-process.pchain-type tt-rule-process.pchain-id ~
tt-rule-process.start-from tt-rule-process.link-id ~
tt-rule-process.documentation
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-rule-process
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-rule-process
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-rule-process SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-rule-process SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-rule-process
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-rule-process


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-rule-process.pchain-type ~
tt-rule-process.pchain-id tt-rule-process.start-from ~
tt-rule-process.link-id tt-rule-process.documentation
&Scoped-define ENABLED-TABLES tt-rule-process
&Scoped-define FIRST-ENABLED-TABLE tt-rule-process
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-run-db0 t-run-rdb ~
t-link-btwn-profiles t-is-export t-is-import B-codex t-needs-efile ~
t-needs-ifile T-is-routing T-is-esys-import T-main-link T-can-be-start
&Scoped-Define DISPLAYED-FIELDS tt-rule-process.pchain-type ~
tt-rule-process.pchain-id tt-rule-process.start-from ~
tt-rule-process.link-id tt-rule-process.codex_id tt-rule-process.ruleset_id ~
tt-rule-process.documentation
&Scoped-define DISPLAYED-TABLES tt-rule-process
&Scoped-define FIRST-DISPLAYED-TABLE tt-rule-process
&Scoped-Define DISPLAYED-OBJECTS t-run-db0 t-run-rdb t-link-btwn-profiles ~
t-is-export t-is-import t-needs-efile t-needs-ifile T-is-routing ~
T-is-esys-import T-main-link T-can-be-start

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-codex
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

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

DEFINE VARIABLE T-can-be-start AS LOGICAL INITIAL no
     LABEL "Может быть стартом"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-is-esys-import AS LOGICAL INITIAL no
     LABEL "Импорт из ВС"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-is-export AS LOGICAL INITIAL no
     LABEL "Экспорт"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-is-import AS LOGICAL INITIAL no
     LABEL "Импорт"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-is-routing AS LOGICAL INITIAL no
     LABEL "Маршрутизация в ВС"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-link-btwn-profiles AS LOGICAL INITIAL no
     LABEL "Связно между профайлами"
     VIEW-AS TOGGLE-BOX
     SIZE 27.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-main-link AS LOGICAL INITIAL no
     LABEL "Основное/необходимое"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-needs-efile AS LOGICAL INITIAL no
     LABEL "Нужен вых.файл"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-needs-ifile AS LOGICAL INITIAL no
     LABEL "Нужен вх.файл"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-run-db0 AS LOGICAL INITIAL no
     LABEL "Выполнимо в ГБД"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-run-rdb AS LOGICAL INITIAL no
     LABEL "Выполнимо в УБД"
     VIEW-AS TOGGLE-BOX
     SIZE 23.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-rule-process SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-rule-process.pchain-type AT ROW 2.07 COL 14 COLON-ALIGNED WIDGET-ID 14 FORMAT "x(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 34 BY 1
     t-run-db0 AT ROW 2.07 COL 71 WIDGET-ID 54
     tt-rule-process.pchain-id AT ROW 3.13 COL 14 COLON-ALIGNED WIDGET-ID 38 FORMAT "x(48)"
          VIEW-AS FILL-IN
          SIZE 53.5 BY 1
     t-run-rdb AT ROW 3.13 COL 71 WIDGET-ID 56
     t-link-btwn-profiles AT ROW 4.13 COL 71 WIDGET-ID 58
     tt-rule-process.start-from AT ROW 4.2 COL 15.5 NO-LABEL WIDGET-ID 42
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "ГБД", 0,
"УБД", 1
          SIZE 20.5 BY 1.07
     tt-rule-process.link-id AT ROW 5.27 COL 14 COLON-ALIGNED WIDGET-ID 48
          VIEW-AS FILL-IN
          SIZE 15.5 BY 1.07
     t-is-export AT ROW 5.27 COL 71 WIDGET-ID 60
     t-is-import AT ROW 6.27 COL 71 WIDGET-ID 62
     tt-rule-process.codex_id AT ROW 6.57 COL 14 COLON-ALIGNED WIDGET-ID 50
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     B-codex AT ROW 6.57 COL 26 WIDGET-ID 28
     t-needs-efile AT ROW 7.27 COL 71 WIDGET-ID 64
     tt-rule-process.ruleset_id AT ROW 7.67 COL 14 COLON-ALIGNED WIDGET-ID 52
          LABEL "Набор правил"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     t-needs-ifile AT ROW 8.27 COL 71 WIDGET-ID 66
     T-is-routing AT ROW 9.27 COL 71 WIDGET-ID 68
     T-is-esys-import AT ROW 10.27 COL 71 WIDGET-ID 70
     T-main-link AT ROW 11.27 COL 71 WIDGET-ID 72
     T-can-be-start AT ROW 12.27 COL 71 WIDGET-ID 74
     tt-rule-process.documentation AT ROW 14 COL 1 NO-LABEL WIDGET-ID 16
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 4.27
     "Старт из:" VIEW-AS TEXT
          SIZE 12.5 BY 1.07 AT ROW 4.2 COL 2 WIDGET-ID 46
     SPACE(84.99) SKIP(14.02)
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
      TABLE: locked_rule-process B "?" ? ub rule-process
      TABLE: tt-rule-process T "?" NO-UNDO ub rule-process
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-rule-process.codex_id IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-rule-process.pchain-id IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR COMBO-BOX tt-rule-process.pchain-type IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt-rule-process.ruleset_id IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-rule-process"
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


&Scoped-define SELF-NAME B-codex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-codex Dialog-Frame
ON CHOOSE OF B-codex IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
IF tt-rule-process.pchain-type = ""
OR tt-rule-process.pchain-type =? THEN DO:
   MESSAGE "Не выбран типа процесса"
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN NO-APPLY.
END.

if tt-rule-process.codex_id <> 0 then do:
  find first buf_ruleset no-lock where
          buf_ruleset.codex_id = tt-rule-process.codex_id
      and buf_ruleset.ruleset_id = tt-rule-process.ruleset_id .
  v-rid-list = string(recid(buf_ruleset)).
end.
run rul/ruleset-s.w ( INPUT parparentproc
                     ,INPUT 'b-sel':U /*bttns*/
                     ,input "profile-type" + {&delim-par} + tt-rule-process.pchain-type + {&delim-par} + "all"
                     ,input 0 /*p-codex-id*/
                     ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF v-rid-list <> '':U THEN DO:
   FIND FIRST buf_ruleset NO-LOCK WHERE
            recid(buf_ruleset) = INTEGER(v-rid-list) NO-ERROR.
  IF NOT AVAILABLE buf_RULESET THEN RETURN NO-APPLY.
  ASSIGN
  tt-rule-process.codex_id = buf_ruleset.codex_id
  tt-rule-process.ruleset_id = buf_ruleset.ruleset_id
  .
  DISPLAY
  tt-rule-process.CODEx_id
  tt-rule-process.ruleset_id
  WITH FRAME {&FRAME-NAME}.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-rule-process.pchain-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-rule-process.pchain-type Dialog-Frame
ON VALUE-CHANGED OF tt-rule-process.pchain-type IN FRAME Dialog-Frame /* Тип процесса */
DO:
  assign
  tt-rule-process.pchain-type.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
  IF p-mode = {&add-def}
  THEN DO:
    /*заблокируем*/
    CREATE tt-rule-process.
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_rule-process EXCLUSIVE-LOCK WHERE
                LOCKED_rule-process.pchain-type = p-pchain-type
           and  LOCKED_rule-process.pchain-id = p-pchain-id
           and  LOCKED_rule-process.start-from = p-start-from
           and  LOCKED_rule-process.link-id = p-link-id   .
    END.
    IF p-mode = {&LOOKUP}
    or p-mode = {&add-copy}
    THEN DO:
        FIND FIRST LOCKED_rule-process no-LOCK WHERE
                LOCKED_rule-process.pchain-type = p-pchain-type
           and  LOCKED_rule-process.pchain-id = p-pchain-id
           and  LOCKED_rule-process.start-from = p-start-from
           and  LOCKED_rule-process.link-id = p-link-id no-error .
    END.
    create tt-rule-process.
    buffer-copy locked_rule-process to tt-rule-process.
  end.
  if p-mode = {&add-copy} then do:
    assign
    p-mode = {&add-def}
    v-is-copy = yes.
  end.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY t-run-db0 t-run-rdb t-link-btwn-profiles t-is-export t-is-import
          t-needs-efile t-needs-ifile T-is-routing T-is-esys-import T-main-link
          T-can-be-start
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rule-process THEN
    DISPLAY tt-rule-process.pchain-type tt-rule-process.pchain-id
          tt-rule-process.start-from tt-rule-process.link-id
          tt-rule-process.codex_id tt-rule-process.ruleset_id
          tt-rule-process.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-rule-process.pchain-type t-run-db0
         tt-rule-process.pchain-id t-run-rdb t-link-btwn-profiles
         tt-rule-process.start-from tt-rule-process.link-id t-is-export
         t-is-import B-codex t-needs-efile t-needs-ifile T-is-routing
         T-is-esys-import T-main-link T-can-be-start
         tt-rule-process.documentation
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
tt-rule-process.pchain-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&profile-type-list} .
assign
t-run-db0 = (tt-rule-process.run-db0 > 0)
t-run-rdb = (tt-rule-process.run-rdb > 0)
t-link-btwn-profiles = (tt-rule-process.link-btwn-profiles > 0)
t-is-export = (tt-rule-process.is-export > 0)
t-is-import = (tt-rule-process.is-import > 0)
t-needs-efile = (tt-rule-process.needs-efile > 0)
t-needs-ifile = (tt-rule-process.needs-ifile > 0)
t-is-routing = (tt-rule-process.is-routing > 0)
t-is-esys-import = (tt-rule-process.is-esys-import > 0)
t-main-link = (tt-rule-process.main-link > 0)
t-can-be-start = (tt-rule-process.can-be-start > 0)
.
IF AVAILABLE tt-rule-process THEN
DISPLAY
tt-rule-process.pchain-type
tt-rule-process.pchain-id
tt-rule-process.start-from
tt-rule-process.link-id
tt-rule-process.codex_id
tt-rule-process.ruleset_id
t-run-db0
t-run-rdb
t-link-btwn-profiles
t-is-export
t-is-import
t-needs-efile
t-needs-ifile
t-is-routing
t-is-esys-import
t-main-link
t-can-be-start
tt-rule-process.documentation
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-rule-process.pchain-type  when p-mode = {&add-def}
tt-rule-process.pchain-id when p-mode = {&add-def}
tt-rule-process.start-from      when p-mode = {&add-def}
tt-rule-process.link-id when p-mode = {&add-def}
tt-rule-process.documentation when p-mode <> {&lookup}
b-codex when p-mode <> {&lookup}
t-run-db0 when p-mode <> {&lookup}
t-run-rdb when p-mode <> {&lookup}
t-link-btwn-profiles when p-mode <> {&lookup}
t-is-export when p-mode <> {&lookup}
t-is-import when p-mode <> {&lookup}
t-needs-efile when p-mode <> {&lookup}
t-needs-ifile when p-mode <> {&lookup}
t-is-routing when p-mode <> {&lookup}
t-is-esys-import when p-mode <> {&lookup}
t-main-link when p-mode <> {&lookup}
t-can-be-start when p-mode <> {&lookup}
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-rule-process.documentation:READ-ONLY = YES
  .
  hide b-exit in frame {&frame-name} .
end.
VIEW FRAME {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = {&LOOKUP} THEN DO:
    RETURN.
END.
v-rec = p-rec.
ASSIGN
FRAME {&FRAME-NAME}
tt-rule-process.pchain-type
tt-rule-process.pchain-id
tt-rule-process.start-from
tt-rule-process.link-id
tt-rule-process.codex_id
tt-rule-process.ruleset_id
t-run-db0
tt-rule-process.run-db0 = (if t-run-db0 then 1 else 0)
t-run-rdb
tt-rule-process.run-rdb = (if t-run-rdb then 1 else 0)
t-link-btwn-profiles
tt-rule-process.link-btwn-profiles = (if t-link-btwn-profiles then 1 else 0)
t-is-export
tt-rule-process.is-export = (if t-is-export then 1 else 0)
t-is-import
tt-rule-process.is-import = (if t-is-import then 1 else 0)
t-needs-efile
tt-rule-process.needs-efile = (if t-needs-efile then 1 else 0)
t-needs-ifile
tt-rule-process.needs-ifile = (if t-needs-ifile then 1 else 0)
t-is-routing
tt-rule-process.is-routing = (if t-is-routing then 1 else 0)
t-is-esys-import
tt-rule-process.is-esys-import = (if t-is-esys-import then 1 else 0)
t-main-link
tt-rule-process.main-link = (if t-main-link then 1 else 0)
t-can-be-start
tt-rule-process.can-be-start = (if t-can-be-start then 1 else 0)
.
run rul/rule-process1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-rule-process.pchain-type
                ,INPUT tt-rule-process.pchain-id
                ,INPUT tt-rule-process.start-from
                ,INPUT tt-rule-process.link-id
                ,INPUT tt-rule-process.codex_id
                ,INPUT tt-rule-process.ruleset_id
                ,INPUT tt-rule-process.run-db0
                ,INPUT tt-rule-process.run-rdb
                ,INPUT tt-rule-process.link-btwn-profiles
                ,INPUT tt-rule-process.is-export
                ,INPUT tt-rule-process.is-import
                ,INPUT tt-rule-process.needs-efile
                ,INPUT tt-rule-process.needs-ifile
                ,INPUT tt-rule-process.is-routing
                ,INPUT tt-rule-process.is-esys-import
                ,INPUT tt-rule-process.main-link
                ,INPUT tt-rule-process.can-be-start
                ,INPUT tt-rule-process.documentation:screen-value
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
