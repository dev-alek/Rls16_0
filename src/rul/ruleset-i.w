&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_ruleset FOR ub.ruleset.
DEFINE TEMP-TABLE tt-ruleset NO-UNDO LIKE ub.ruleset.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка ruleset


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
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка ruleset".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
DEFINE BUFFER FIRST_ruleset FOR ub.ruleset.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-ruleset

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-ruleset.codex_id ~
tt-ruleset.ruleset_id tt-ruleset.name tt-ruleset.documentation
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-ruleset.codex_id ~
tt-ruleset.ruleset_id tt-ruleset.name tt-ruleset.documentation
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-ruleset
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-ruleset
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-ruleset SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-ruleset SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-ruleset
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-ruleset


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-ruleset.codex_id tt-ruleset.ruleset_id ~
tt-ruleset.name tt-ruleset.documentation
&Scoped-define ENABLED-TABLES tt-ruleset
&Scoped-define FIRST-ENABLED-TABLE tt-ruleset
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-ruleset.codex_id tt-ruleset.ruleset_id ~
tt-ruleset.name tt-ruleset.documentation
&Scoped-define DISPLAYED-TABLES tt-ruleset
&Scoped-define FIRST-DISPLAYED-TABLE tt-ruleset


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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      tt-ruleset SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     tt-ruleset.codex_id AT ROW 2.77 COL 14 COLON-ALIGNED WIDGET-ID 2
          LABEL "Кодекс правил"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-ruleset.ruleset_id AT ROW 4.27 COL 14 COLON-ALIGNED WIDGET-ID 4
          LABEL "Набор правил"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-ruleset.name AT ROW 6.77 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 4
     tt-ruleset.documentation AT ROW 12 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 10.77
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 11 COL 1.5 WIDGET-ID 14
     "Название" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 5.77 COL 2.5 WIDGET-ID 10
     SPACE(82.49) SKIP(16.70)
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
      TABLE: locked_ruleset B "?" ? ub ruleset
      TABLE: tt-ruleset T "?" NO-UNDO ub ruleset
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

/* SETTINGS FOR FILL-IN tt-ruleset.codex_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-ruleset.documentation:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.

/* SETTINGS FOR FILL-IN tt-ruleset.ruleset_id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-ruleset"
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
    FIND FIRST first_ruleset EXCLUSIVE-LOCK.
    CREATE tt-ruleset.
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_ruleset EXCLUSIVE-LOCK WHERE
                LOCKED_ruleset.ruleset_id = p-ruleset-id
          AND LOCKED_ruleset.codex_id = p-codex-id .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_ruleset no-LOCK WHERE
                  LOCKED_ruleset.ruleset_id = p-ruleset-id
            AND LOCKED_ruleset.codex_id = p-codex-id NO-ERROR.
    END.
    create tt-ruleset.
    buffer-copy locked_ruleset to tt-ruleset.
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
  IF AVAILABLE tt-ruleset THEN
    DISPLAY tt-ruleset.codex_id tt-ruleset.ruleset_id tt-ruleset.name
          tt-ruleset.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-ruleset.codex_id tt-ruleset.ruleset_id
         tt-ruleset.name tt-ruleset.documentation
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
if p-ruleset-id > 0 then do:
  assign
  frame {&frame-name}:title = "Набор правил"
  .
end.
else do:
  assign
  frame {&frame-name}:title = "Кодекс правил"
  .
end.
IF AVAILABLE tt-ruleset THEN
DISPLAY
tt-ruleset.codex_id
tt-ruleset.ruleset_id
tt-ruleset.name
tt-ruleset.documentation
WITH FRAME {&frame-name} .
ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-ruleset.codex_id  when p-mode = {&add-def}
tt-ruleset.ruleset_id when p-mode = {&add-def}
tt-ruleset.name       when p-mode <> {&lookup}
tt-ruleset.documentation when p-mode <> {&lookup}
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
IF p-mode = {&update} THEN DO:
  v-rec = p-rec.
END.
ASSIGN
FRAME {&FRAME-NAME}
tt-ruleset.codex_id
tt-ruleset.ruleset_id
tt-ruleset.NAME
tt-ruleset.documentation.
run rul/ruleset1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-ruleset.codex_id
                ,INPUT tt-ruleset.ruleset_id
                ,INPUT tt-ruleset.name
                ,INPUT tt-ruleset.documentation
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
