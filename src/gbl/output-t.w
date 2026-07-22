&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно выбора типов вывода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/09
Author: Bakhtadze Natalya
Creation date: 06/24/09

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
define input parameter p-mode as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-output-type AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS LOGICAL NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-text t-excel t-xml ~
t-screen t-pdf 
&Scoped-Define DISPLAYED-OBJECTS t-text t-excel t-xml t-screen t-pdf 

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

DEFINE BUTTON b-quit AUTO-GO 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE t-excel AS LOGICAL INITIAL no 
     LABEL "Excel" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE t-pdf AS LOGICAL INITIAL no 
     LABEL "PDF" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE t-screen AS LOGICAL INITIAL no 
     LABEL "Экран" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE t-text AS LOGICAL INITIAL no 
     LABEL "Текст" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE t-xml AS LOGICAL INITIAL no 
     LABEL "XML" 
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 55
     t-text AT ROW 3 COL 10.5 WIDGET-ID 4
     t-excel AT ROW 4 COL 10.5 WIDGET-ID 6
     t-xml AT ROW 5 COL 10.5 WIDGET-ID 8
     t-screen AT ROW 6 COL 10.5 WIDGET-ID 12
     t-pdf AT ROW 7 COL 10.5 WIDGET-ID 10
     SPACE(28.99) SKIP(0.86)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE ""
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       t-excel:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       t-pdf:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       t-screen:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       t-text:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN 
       t-xml:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
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
DEFINE VARIABLE  v-output-type AS CHARACTER NO-UNDO.
  IF t-text:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:  
    ASSIGN
    t-text.
    IF t-text THEN DO:
        v-output-type = v-output-type + 
                         (IF v-output-type = '' THEN '' ELSE {&comma-char}) + 
                        {&output-type-plain-text}.
    END.
    

  END.
  IF t-excel:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:  
    ASSIGN
    t-excel.
    IF t-excel THEN DO:
        v-output-type = v-output-type + 
                         (IF v-output-type = '' THEN '' ELSE {&comma-char}) + 
                        {&output-type-excel}.
    END.

  END.
  IF t-xml:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:  
    ASSIGN
    t-xml.
    IF t-xml THEN DO:
        v-output-type = v-output-type + 
                         (IF v-output-type = '' THEN '' ELSE {&comma-char}) + 
                        {&output-type-xml}.
    END.

  END.
  IF t-screen:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:  
    ASSIGN
    t-screen.
    IF t-screen THEN DO:
        v-output-type = v-output-type + 
                         (IF v-output-type = '' THEN '' ELSE {&comma-char}) + 
                        {&output-type-screen}.
    END.

  END.
  IF t-pdf:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:  
    ASSIGN
    t-pdf.
    IF t-pdf THEN DO:
        v-output-type = v-output-type + 
                         (IF v-output-type = '' THEN '' ELSE {&comma-char}) + 
                        {&output-type-pdf}.
    END.

  END.

  ASSIGN
  p-output-type = v-output-type
  p-ok = YES                   
  .
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  DISPLAY t-text t-excel t-xml t-screen t-pdf 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-text t-excel t-xml t-screen t-pdf 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-entry AS character NO-UNDO.
DO v-ii = 1 TO NUM-ENTRIES(p-mode):
   v-entry = ENTRY(v-ii, p-mode).
   CASE v-entry:
     WHEN {&output-type-plain-text} THEN DO:
       t-text:VISIBLE IN FRAME {&FRAME-NAME} = YES.
       t-text = LOOKUP({&output-type-plain-text}, p-output-type) > 0.
       ENABLE t-text 
       WITH FRAME {&FRAME-NAME}.
     END.
     WHEN {&output-type-excel} THEN DO:
       t-excel:VISIBLE IN FRAME {&FRAME-NAME} = YES.
       t-excel = LOOKUP({&output-type-excel}, p-output-type) > 0.
       ENABLE t-excel 
       WITH FRAME {&FRAME-NAME}.
     END.
     WHEN {&output-type-xml} THEN DO:
       t-xml:VISIBLE IN FRAME {&FRAME-NAME} = YES.
       t-xml = LOOKUP({&output-type-xml}, p-output-type) > 0.
       ENABLE t-xml 
       WITH FRAME {&FRAME-NAME}.
     END.
     WHEN {&output-type-screen} THEN DO:
       t-screen:VISIBLE IN FRAME {&FRAME-NAME} = YES.
       t-screen = LOOKUP({&output-type-screen}, p-output-type) > 0.
       ENABLE t-screen 
       WITH FRAME {&FRAME-NAME}.
     END.
     WHEN {&output-type-pdf} THEN DO:
       t-pdf:VISIBLE IN FRAME {&FRAME-NAME} = YES.
       t-pdf = LOOKUP({&output-type-pdf}, p-output-type) > 0.
       ENABLE t-pdf 
       WITH FRAME {&FRAME-NAME}.
     END.
  END CASE.
END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = p-title.
ENABLE
B-exit
b-quit
B-Help
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

