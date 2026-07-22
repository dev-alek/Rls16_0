&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ввод уникального идентификатора записи для просмотра истории

Автор: Ростовцев Александр
Дата создания: 16/04/2026
Author: 
Creation date:


------------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввод уникального идентификатора записи".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter iLabel as character no-undo.
define input  parameter iTypes as character no-undo.
define output parameter oIdent as character no-undo.

/* Local Variable Definitions ---                                       */
define temp-table ttFill no-undo
  field fLabel  as handle
  field fFill   as handle
  field fType   as character
  field fFormat as character
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 b-exit b-input 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit 
     LABEL "Выход" 
     SIZE 15 BY 1.14.

DEFINE BUTTON b-input 
     LABEL "Ввод" 
     SIZE 15 BY 1.14.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 72 BY 2.38.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.48 COL 3 WIDGET-ID 2
     b-input AT ROW 1.48 COL 19 WIDGET-ID 8
     RECT-1 AT ROW 2.91 COL 2 WIDGET-ID 10
     SPACE(1.79) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Введите значения для идентификации записи" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON RETURN OF FRAME Dialog-Frame /* Введите значения для идентификации записи */
anywhere DO:
  if focus:type = "FILL-IN" then
  do:
    find first ttFill where ttFill.fFill = focus:handle.
    
    find next ttFill no-error.
    if avail ttFill then
      apply "ENTRY":U to ttFill.fFill.
    else
      apply "CHOOSE":U to b-input. 
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Введите значения для идентификации записи */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-input
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-input Dialog-Frame
ON CHOOSE OF b-input IN FRAME Dialog-Frame /* Ввод */
DO:
  oIdent = "".
  for each ttFill:
    if (ttFill.fType = "CHARACTER" and ttFill.fFill:screen-value = "") then
    do:
      message "Не все поля заполнены." view-as alert-box.
      apply "entry":U to ttFill.fFill.
      return no-apply.
    end.
    oIdent = oIdent + "," + ttFill.fFill:screen-value.
  end.
  oIdent = substring(oIdent,2).
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  
  run buildFill in this-procedure.
  
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buildFill Dialog-Frame 
PROCEDURE buildFill :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
define variable vCount as integer no-undo.
define variable vFillIn as handle no-undo.
define variable vStep   as decimal no-undo.

&scoped-define FILL_COL    25
&scoped-define FILL_WIDTH  45
&scoped-define FILL_ROW    3.3
&scoped-define FILL_HEIGHT 1


do with frame {&frame-name}:

  do vCount = 1 to num-entries(iLabel):
    vStep = (vCount - 1) * 1.1.
    create ttFill.
    ttFill.fType = entry(vCount,iTypes).
    ttFill.fFormat = if entry(vCount,iTypes) = "integer" or entry(vCount,iTypes) = "int64" then ">>>>>>>>9" else
                     if entry(vCount,iTypes) = "decimal" then ">>>>>>>>9.9<<<<<" else "X(100)".

    CREATE TEXT ttFill.fLabel
    ASSIGN
      FRAME = FRAME {&frame-name}:HANDLE
      DATA-TYPE = "CHARACTER"
      FORMAT = "x(" + string(length(entry(vCount,iLabel)) + 2) + ")"
      SCREEN-VALUE = entry(vCount,iLabel) + ":"
      ROW = {&FILL_ROW} + vStep 
      COLUMN = {&FILL_COL} - 2 - length(entry(vCount,iLabel))
    .
    
    CREATE FILL-IN ttFill.fFill
    ASSIGN 
      ROW = {&FILL_ROW} + vStep
      COLUMN = {&FILL_COL}
      DATA-TYPE = ttFill.fType 
      FORMAT = ttFill.fFormat
      WIDTH = {&FILL_WIDTH}
      FRAME = frame {&frame-name}:HANDLE
      SENSITIVE = yes
      VISIBLE = TRUE
      SIDE-LABEL-HANDLE = ttFill.fLabel
    .
    frame {&frame-name}:height = frame {&frame-name}:height + vStep.
    rect-1:height = rect-1:height + vStep.
  end.
  
  find first ttFill.
  apply "ENTRY":U to ttFill.fFill.
end.

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
  ENABLE RECT-1 b-exit b-input 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

