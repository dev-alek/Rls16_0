&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_rule-by-call FOR ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка rule-by-call


Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-call#-id as integer no-undo .
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
define input parameter p-ruleset-id as integer no-undo .
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка rule-by-call".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
DEFINE BUFFER FIRST_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-rule-by-call

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-rule-by-call.call#_id ~
tt-rule-by-call.call_id tt-rule-by-call.codex_id tt-rule-by-call.ruleset_id ~
tt-rule-by-call.order_id tt-rule-by-call.profile_id ~
tt-rule-by-call.once-more tt-rule-by-call.rule_id ~
tt-rule-by-call.is_dynamic tt-rule-by-call.can-calc ~
tt-rule-by-call.algo-des
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame ~
tt-rule-by-call.call#_id tt-rule-by-call.call_id tt-rule-by-call.codex_id ~
tt-rule-by-call.order_id tt-rule-by-call.profile_id ~
tt-rule-by-call.once-more tt-rule-by-call.rule_id tt-rule-by-call.can-calc ~
tt-rule-by-call.algo-des
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-rule-by-call
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-rule-by-call
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-rule-by-call SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-rule-by-call SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-rule-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-rule-by-call


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-rule-by-call.call#_id ~
tt-rule-by-call.call_id tt-rule-by-call.codex_id tt-rule-by-call.order_id ~
tt-rule-by-call.profile_id tt-rule-by-call.once-more ~
tt-rule-by-call.rule_id tt-rule-by-call.can-calc tt-rule-by-call.algo-des
&Scoped-define ENABLED-TABLES tt-rule-by-call
&Scoped-define FIRST-ENABLED-TABLE tt-rule-by-call
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-rule-by-call.call#_id ~
tt-rule-by-call.call_id tt-rule-by-call.codex_id tt-rule-by-call.ruleset_id ~
tt-rule-by-call.order_id tt-rule-by-call.profile_id ~
tt-rule-by-call.once-more tt-rule-by-call.rule_id ~
tt-rule-by-call.is_dynamic tt-rule-by-call.can-calc ~
tt-rule-by-call.algo-des
&Scoped-define DISPLAYED-TABLES tt-rule-by-call
&Scoped-define FIRST-DISPLAYED-TABLE tt-rule-by-call


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
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-rule-by-call SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-rule-by-call.call#_id AT ROW 1 COL 67.5 COLON-ALIGNED WIDGET-ID 16
          LABEL "Уник.идент.точки вызова"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     B-Help AT ROW 1 COL 88
     tt-rule-by-call.call_id AT ROW 2.25 COL 21 COLON-ALIGNED WIDGET-ID 18
          LABEL "Точка вызова правила" FORMAT "X(40)"
          VIEW-AS FILL-IN NATIVE
          SIZE 45 BY 1
     tt-rule-by-call.codex_id AT ROW 3.5 COL 14 COLON-ALIGNED WIDGET-ID 2
          LABEL "Кодекс правил"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-by-call.ruleset_id AT ROW 4.75 COL 14 COLON-ALIGNED WIDGET-ID 4
          LABEL "Набор правил"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-by-call.order_id AT ROW 6 COL 15 COLON-ALIGNED WIDGET-ID 20
          LABEL "Порядок вызова"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-by-call.profile_id AT ROW 7.25 COL 14 COLON-ALIGNED WIDGET-ID 26
          LABEL "Код профайла"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-by-call.once-more AT ROW 7.25 COL 41.5 COLON-ALIGNED WIDGET-ID 30
          LABEL "№ привязки"
          VIEW-AS FILL-IN
          SIZE 3 BY 1
     tt-rule-by-call.rule_id AT ROW 8.5 COL 14 COLON-ALIGNED WIDGET-ID 28
          LABEL "Код правила"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-by-call.is_dynamic AT ROW 9.75 COL 1 WIDGET-ID 22
          LABEL "Отключаемое"
          VIEW-AS TOGGLE-BOX
          SIZE 25 BY 1
     tt-rule-by-call.can-calc AT ROW 11 COL 1 WIDGET-ID 24
          LABEL "Включено"
          VIEW-AS TOGGLE-BOX
          SIZE 25 BY 1
     tt-rule-by-call.algo-des AT ROW 13 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 9.75
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .75 AT ROW 12 COL 1.5 WIDGET-ID 14
     SPACE(83.49) SKIP(10.49)
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
      TABLE: locked_rule-by-call B "?" ? ub rule-by-call
      TABLE: tt-rule-by-call T "?" NO-UNDO ub rule-by-call
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

/* SETTINGS FOR FILL-IN tt-rule-by-call.call#_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-by-call.call_id IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR TOGGLE-BOX tt-rule-by-call.can-calc IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-by-call.codex_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX tt-rule-by-call.is_dynamic IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rule-by-call.once-more IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-by-call.order_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-by-call.profile_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-rule-by-call.ruleset_id IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-rule-by-call.rule_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-rule-by-call"
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
  IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    FIND FIRST first_rule-by-call EXCLUSIVE-LOCK.
    CREATE tt-rule-by-call.
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_rule-by-call EXCLUSIVE-LOCK WHERE
                LOCKED_rule-by-call.ruleset_id = p-ruleset-id
          AND LOCKED_rule-by-call.codex_id = p-codex-id .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_rule-by-call no-LOCK WHERE
                  LOCKED_rule-by-call.ruleset_id = p-ruleset-id
            AND LOCKED_rule-by-call.codex_id = p-codex-id NO-ERROR.
    END.
    create tt-rule-by-call.
    buffer-copy locked_rule-by-call to tt-rule-by-call.
  end.

  RUN Myenable.
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
  IF AVAILABLE tt-rule-by-call THEN
    DISPLAY tt-rule-by-call.call#_id tt-rule-by-call.call_id
          tt-rule-by-call.codex_id tt-rule-by-call.ruleset_id
          tt-rule-by-call.order_id tt-rule-by-call.profile_id
          tt-rule-by-call.once-more tt-rule-by-call.rule_id
          tt-rule-by-call.is_dynamic tt-rule-by-call.can-calc
          tt-rule-by-call.algo-des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-rule-by-call.call#_id B-Help tt-rule-by-call.call_id
         tt-rule-by-call.codex_id tt-rule-by-call.order_id
         tt-rule-by-call.profile_id tt-rule-by-call.once-more
         tt-rule-by-call.rule_id tt-rule-by-call.can-calc
         tt-rule-by-call.algo-des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
IF AVAILABLE tt-rule-by-call THEN
DISPLAY
tt-rule-by-call.call#_id
tt-rule-by-call.call_id
tt-rule-by-call.codex_id
tt-rule-by-call.ruleset_id
tt-rule-by-call.order_id
tt-rule-by-call.profile_id
tt-rule-by-call.RULE_id
tt-rule-by-call.algo-des
tt-rule-by-call.can-calc
tt-rule-by-call.is_dynamic
tt-rule-by-call.once-more
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-rule-by-call.can-calc  when p-mode = {&update} AND tt-rule-by-call.IS_dynamic
tt-rule-by-call.algo-des when p-mode = {&update}
WITH FRAME {&frame-name} .
if p-mode = {&lookup} then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1.
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
ASSIGN
FRAME {&FRAME-NAME}
tt-rule-by-call.can-calc
tt-rule-by-call.algo-des.
run rul/rule-by-call1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,input ? /*p-cmd-proc-handle*/
                ,input 0 /*p-cmd-code*/
                ,INPUT tt-rule-by-call.call#_id
                ,INPUT tt-rule-by-call.codex_id
                ,INPUT tt-rule-by-call.ruleset_id
                ,INPUT tt-rule-by-call.order_id
                ,INPUT tt-rule-by-call.call_id
                ,INPUT tt-rule-by-call.RULE_id
                ,INPUT tt-rule-by-call.profile_id
                ,INPUT tt-rule-by-call.once-more
                ,INPUT tt-rule-by-call.is_dynamic
                ,INPUT tt-rule-by-call.can-calc
                ,INPUT tt-rule-by-call.algo-des
                 ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME