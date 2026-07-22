&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define output parameter odate as date no-undo.
define output parameter oDocumentCreator as character no-undo.
define output parameter oDocumentCreatorBase as character no-undo.
define output parameter oOperationCode as character no-undo.
define output parameter oOperationContent as character no-undo.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel mDate DocCerator DocCrBase ~
OperationCode OperationContent 
&Scoped-Define DISPLAYED-OBJECTS mDate DocCerator DocCrBase OperationCode ~
OperationContent 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Ввод" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE mDocCerator AS CHARACTER FORMAT "X(1000)":U 
     LABEL "Наим. субъекта составителя" 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1 TOOLTIP "НаимЭконСубСост" NO-UNDO.

DEFINE VARIABLE mDocCrBase AS CHARACTER FORMAT "X(256)":U 
     LABEL "Доверенность" 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1 TOOLTIP "ОснДоверОргСост" NO-UNDO.

DEFINE VARIABLE mDate AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE mOperationCode AS CHARACTER FORMAT "X(256)":U 
     LABEL "Вид операции" 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1 TOOLTIP "ВидОперации" NO-UNDO.

DEFINE VARIABLE mOperationContent AS CHARACTER FORMAT "X(256)":U INITIAL "1" 
     LABEL "Содержание операции" 
     VIEW-AS  COMBO-BOX INNER-LINES 7
     LIST-ITEM-PAIRS "Принято без разногласий","1",
                     "Принято с разногласиями","2"
     SIZE 55 BY 1 TOOLTIP "СодОпер" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 2
     Btn_Cancel AT ROW 1.25 COL 19
     mDate AT ROW 3 COL 35 COLON-ALIGNED WIDGET-ID 10
     mDocCerator AT ROW 4.5 COL 35 COLON-ALIGNED WIDGET-ID 2
     mDocCrBase AT ROW 6 COL 35 COLON-ALIGNED WIDGET-ID 4
     mOperationCode AT ROW 7.5 COL 35 COLON-ALIGNED WIDGET-ID 6
     mOperationContent AT ROW 9 COL 35 COLON-ALIGNED WIDGET-ID 8
     SPACE(2.74) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Подпись документа"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Подпись документа */
DO:
  APPLY "END-ERROR":U TO SELF.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
   assign
      mDate
      mDocCerator
      mDocCrBase
      mOperationCode
      mOperationContent
   .
   if    mDocCerator eq ""
      or mDocCerator eq ?
   then do:
      message "Наименование субъекта обязательно для заполнения" view-as alert-box.
      return no-apply.
   end.
   assign
      odate                 = mDate
      oDocumentCreator      = mDocCerator
      oDocumentCreatorBase  = mDocCrBase
      oOperationCode        = mOperationCode
      oOperationContent     = mOperationContent
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
      mDate = today.
  RUN enable_UI.
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
  DISPLAY mDate mDocCerator mDocCrBase mOperationCode mOperationContent 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel mDate mDocCerator mDocCrBase mOperationCode 
         mOperationContent 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

