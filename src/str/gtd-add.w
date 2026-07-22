&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Изменение дополнения к ГТД

Автор: Чернова Светлана Александровна
Дата создания: 03/04/08
Author: Svetlana Chernova
Creation date: 03/04/08


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-artic as character no-undo .
define input  parameter p-prod  as character no-undo .
define input  parameter p-NAME  as character no-undo .
define input  parameter p-gtd as character   no-undo .
define input-output parameter p-add-gtd   as character   no-undo .
define output parameter p-res   as logical   no-undo .

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":u .
def var vss-author      as character no-undo init "$Author$":u .
def var vss-date        as character no-undo init "$Date$":u .
def var vss-workfile    as character no-undo init "$Workfile$":u .
def var vss-archive     as character no-undo init "$Archive$":u .
def var vss-description as character no-undo init "Изменение дополнения к ГТД" .
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

assign p-res = no .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help FILL-5 FILL-1 FILL-2 ~
FILL-3 FILL-4
&Scoped-Define DISPLAYED-OBJECTS FILL-5 FILL-1 FILL-2 FILL-3 FILL-4

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE FILL-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Артикул"
      VIEW-AS TEXT
     SIZE 13 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
      VIEW-AS TEXT
     SIZE 17 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-3 AS CHARACTER FORMAT "X(256)":U
     LABEL "Наименование"
      VIEW-AS TEXT
     SIZE 41 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-4 AS CHARACTER FORMAT "X(256)":U
     LABEL "ГТД накладной"
      VIEW-AS TEXT
     SIZE 37.5 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-5 AS CHARACTER FORMAT "X(15)":U
     LABEL "Дополнение к ГТД товара"
     VIEW-AS FILL-IN
     SIZE 28.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 41
     FILL-5 AT ROW 5.5 COL 1.5
     FILL-1 AT ROW 2.21 COL 9 COLON-ALIGNED
     FILL-2 AT ROW 2.21 COL 25
     FILL-3 AT ROW 3.42 COL 14 COLON-ALIGNED
     FILL-4 AT ROW 4.5 COL 15 COLON-ALIGNED
     SPACE(2.50) SKIP(1.63)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнение к ГТД товара"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Дополнение к ГТД товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:  /* отказ - выход  */
  assign FILL-5 .
  assign
    p-add-gtd = FILL-5
    p-res   = yes .
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame

/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
     FILL-1     = p-artic
     FILL-2     = p-prod
     FILL-3     = p-NAME
     FILL-4     = p-gtd
     FILL-5     = p-add-gtd
  .

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME} FOCUS FILL-5 .
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
  DISPLAY FILL-5 FILL-1 FILL-2 FILL-3 FILL-4
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help FILL-5 FILL-1 FILL-2 FILL-3 FILL-4
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME