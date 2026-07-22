&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
DEFINE TEMP-TABLE tt-ruledict NO-UNDO LIKE ub.ruledict.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка ruledict


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
DEFINE INPUT PARAMETER p-entry-type as character no-undo .
DEFINE INPUT PARAMETER p-entry-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка ruledict".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
define variable v-is-copy as logical no-undo .
DEFINE BUFFER FIRST_ruledict FOR dictdb.ruledict.
DEFINE BUFFER buf_ruledict FOR dictdb.ruledict.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-ruledict

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-ruledict.entry-id ~
tt-ruledict.entry-type tt-ruledict.script-al tt-ruledict.script-nl ~
tt-ruledict.documentation
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-ruledict.entry-id ~
tt-ruledict.entry-type tt-ruledict.script-al tt-ruledict.script-nl ~
tt-ruledict.documentation
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-ruledict
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-ruledict
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-ruledict SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-ruledict SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-ruledict
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-ruledict


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-ruledict.entry-id tt-ruledict.entry-type ~
tt-ruledict.script-al tt-ruledict.script-nl tt-ruledict.documentation
&Scoped-define ENABLED-TABLES tt-ruledict
&Scoped-define FIRST-ENABLED-TABLE tt-ruledict
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help
&Scoped-Define DISPLAYED-FIELDS tt-ruledict.entry-id tt-ruledict.entry-type ~
tt-ruledict.script-al tt-ruledict.script-nl tt-ruledict.documentation
&Scoped-define DISPLAYED-TABLES tt-ruledict
&Scoped-define FIRST-DISPLAYED-TABLE tt-ruledict


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
      tt-ruledict SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     tt-ruledict.entry-id AT ROW 2.6 COL 12.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Id термина"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-ruledict.entry-type AT ROW 2.6 COL 36.5 COLON-ALIGNED WIDGET-ID 20
          LABEL "Тип термина"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 22.5 BY 1
     tt-ruledict.script-al AT ROW 6.77 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3
     tt-ruledict.script-nl AT ROW 10.8 COL 1 NO-LABEL WIDGET-ID 18
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3
     tt-ruledict.documentation AT ROW 15.13 COL 1 NO-LABEL WIDGET-ID 12
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 7.63
     "Описание" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 14.07 COL 1 WIDGET-ID 14
     "Название" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 5.77 COL 2.5 WIDGET-ID 10
     "Перевод" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 9.8 COL 1 WIDGET-ID 16
     SPACE(83.99) SKIP(12.67)
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
      TABLE: locked_ruledict B "?" ? ub ruledict
      TABLE: tt-ruledict T "?" NO-UNDO ub ruledict
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

/* SETTINGS FOR FILL-IN tt-ruledict.entry-id IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX tt-ruledict.entry-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-ruledict"
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-name}:PARENT eq ?
THEN FRAME {&FRAME-name}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode = {&add-copy} THEN DO:
    v-is-copy = yes.
    p-mode = {&add-def}.
  end.
  IF p-mode = {&add-def} THEN DO:
    /*заблокируем*/
    FIND FIRST first_ruledict EXCLUSIVE-LOCK.
    if v-is-copy then do:
      FIND FIRST LOCKED_ruledict EXCLUSIVE-LOCK WHERE
                LOCKED_ruledict.entry-id = p-entry-id .
      create tt-ruledict.
      buffer-copy locked_ruledict except entry-id
      to tt-ruledict.
      release locked_ruledict.
    end.
    else do:
      CREATE tt-ruledict.
      if p-entry-type <> '':U then do:
        tt-ruledict.entry-type = p-entry-type.
      end.
    end.
  END.
  else do:
    IF p-mode = {&UPDATE} THEN DO:
      FIND FIRST LOCKED_ruledict EXCLUSIVE-LOCK WHERE
                LOCKED_ruledict.entry-id = p-entry-id .
    END.
    IF p-mode = {&LOOKUP} THEN DO:
        FIND FIRST LOCKED_ruledict no-LOCK WHERE
                  LOCKED_ruledict.entry-id = p-entry-id  NO-ERROR.
    END.
    create tt-ruledict.
    buffer-copy locked_ruledict to tt-ruledict.
  end.

  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-name}.
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
  IF AVAILABLE tt-ruledict THEN
    DISPLAY tt-ruledict.entry-id tt-ruledict.entry-type tt-ruledict.script-al
          tt-ruledict.script-nl tt-ruledict.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-ruledict.entry-id tt-ruledict.entry-type
         tt-ruledict.script-al tt-ruledict.script-nl tt-ruledict.documentation
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
tt-ruledict.entry-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&rdict-etype-list}.
IF AVAILABLE tt-ruledict THEN
DISPLAY
tt-ruledict.entry-type
tt-ruledict.entry-id
tt-ruledict.script-al
tt-ruledict.script-nl
tt-ruledict.documentation
WITH FRAME {&frame-name} .
assign
tt-ruledict.script-al:read-only in frame {&frame-name} = (p-mode = {&lookup})
tt-ruledict.script-nl:read-only in frame {&frame-name} = (p-mode = {&lookup})
.

ENABLE
B-exit  when p-mode <> {&lookup}
b-quit
B-Help
tt-ruledict.entry-type  when (p-mode = {&add-def} and p-entry-type = '':U)
tt-ruledict.entry-id when p-mode = {&add-def}
tt-ruledict.documentation when p-mode <> {&lookup}
tt-ruledict.script-al
tt-ruledict.script-nl
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
if p-mode = {&update} then do:
  v-rec = p-rec.
end.
ASSIGN
FRAME {&FRAME-name}
tt-ruledict.entry-type
tt-ruledict.entry-id
tt-ruledict.script-al
tt-ruledict.script-nl
tt-ruledict.documentation.
run rul/ruledict1.p ( INPUT p-mode
                ,INPUT NO /*p-silent*/
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-ruledict.entry-id
                ,INPUT tt-ruledict.entry-type
                ,INPUT tt-ruledict.script-al
                ,INPUT tt-ruledict.script-nl
                ,INPUT tt-ruledict.documentation
                ) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME