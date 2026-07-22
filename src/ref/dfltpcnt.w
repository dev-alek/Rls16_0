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

Ввод процентов скидки по умолчанию для типов ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input-output  parameter p-d-pcnt as decimal no-undo.
define input-output  parameter p-d-cash-pcnt as decimal no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввод процентов скидки по умолчанию для типов ДК".
{ cmp/vssrevis.i }
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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help l-d-cash-pcnt l-d-pcnt ~
n-d-pcnt n-d-cash-pcnt 
&Scoped-Define DISPLAYED-OBJECTS d-pcnt d-cash-pcnt n-d-pcnt n-d-cash-pcnt 

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

DEFINE VARIABLE d-cash-pcnt AS DECIMAL FORMAT "->9.99%":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE d-pcnt AS DECIMAL FORMAT "->9.99%":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE n-d-cash-pcnt AS CHARACTER FORMAT "X(256)":U INITIAL "Процент скидки:" 
      VIEW-AS TEXT 
     SIZE 14.25 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-d-pcnt AS CHARACTER FORMAT "X(256)":U INITIAL "Процент скидки:" 
      VIEW-AS TEXT 
     SIZE 14.25 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE IMAGE l-d-cash-pcnt
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.

DEFINE IMAGE l-d-pcnt
     FILENAME "adeicon\lock":U
     SIZE 2.88 BY .92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 25.5
     d-pcnt AT ROW 2.54 COL 20.5 COLON-ALIGNED NO-LABEL
     d-cash-pcnt AT ROW 4 COL 20.38 COLON-ALIGNED NO-LABEL
     n-d-pcnt AT ROW 2.54 COL 6.88 NO-LABEL
     n-d-cash-pcnt AT ROW 4.17 COL 6.88 NO-LABEL
     l-d-cash-pcnt AT ROW 4.21 COL 3.63
     l-d-pcnt AT ROW 2.63 COL 3.63
     SPACE(36.98) SKIP(2.90)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Введите проценты скидок по умолчанию"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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

/* SETTINGS FOR FILL-IN d-cash-pcnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN d-pcnt IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN n-d-cash-pcnt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-d-pcnt IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Введите проценты скидок по умолчанию */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
  d-cash-pcnt
  d-pcnt
  p-d-pcnt = (if d-pcnt:sensitive then d-pcnt else p-d-pcnt)
  p-d-cash-pcnt = (if d-cash-pcnt:sensitive then d-cash-pcnt else p-d-cash-pcnt)
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME d-cash-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-cash-pcnt Dialog-Frame
ON RIGHT-MOUSE-CLICK OF d-cash-pcnt IN FRAME Dialog-Frame
DO:
    assign
    n-d-cash-pcnt:fgcolor = 15
    l-d-cash-pcnt:visible = true.
    display d-cash-pcnt with frame {&frame-name}.
    disable d-cash-pcnt with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-pcnt Dialog-Frame
ON RIGHT-MOUSE-CLICK OF d-pcnt IN FRAME Dialog-Frame
DO:
    assign
    n-d-pcnt:fgcolor = 15
    l-d-pcnt:visible = true.
    display d-pcnt with frame {&frame-name}.
    disable d-pcnt with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-d-cash-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-d-cash-pcnt Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-d-cash-pcnt IN FRAME Dialog-Frame
DO:
   IF l-d-cash-pcnt:visible then do:
    assign
    n-d-cash-pcnt:fgcolor = ?
    l-d-cash-pcnt:visible = false.
    enable d-cash-pcnt with frame {&frame-name}.
    APPLY "ENTRY" TO d-cash-pcnt.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-d-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-d-pcnt Dialog-Frame
ON MOUSE-SELECT-CLICK OF l-d-pcnt IN FRAME Dialog-Frame
DO:
   IF l-d-pcnt:visible then do:
    assign
    n-d-pcnt:fgcolor = ?
    l-d-pcnt:visible = false.
    enable d-pcnt with frame {&frame-name}.
    APPLY "ENTRY" TO d-pcnt.

  end.

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
  RUN MYenable.
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
  DISPLAY d-pcnt d-cash-pcnt n-d-pcnt n-d-cash-pcnt 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help l-d-cash-pcnt l-d-pcnt n-d-pcnt n-d-cash-pcnt 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame 
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
d-pcnt = p-d-pcnt
d-cash-pcnt = p-d-cash-pcnt
.
DISPLAY d-pcnt d-cash-pcnt n-d-pcnt n-d-cash-pcnt
      WITH FRAME Dialog-Frame.
  ENABLE b-quit l-d-cash-pcnt l-d-pcnt B-exit B-Help n-d-pcnt n-d-cash-pcnt
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
if d-pcnt > 0 then do:
    APPLY "MOUSE-SELECT-CLICK" to l-d-pcnt.
end.
if d-cash-pcnt > 0 then do:
    APPLY "MOUSE-SELECT-CLICK" to l-d-cash-pcnt.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

