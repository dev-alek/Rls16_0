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

Порядок сортировки при печати на весы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Created: 24/11/98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define output parameter Pri-Mode as char no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Порядок сортировки при печати на весы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit RECT-23 b-help ByBar ByPlu ByName ~
ByGroup ByGroup-Name
&Scoped-Define DISPLAYED-OBJECTS ByBar ByPlu ByName ByGroup ByGroup-Name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 27.8 BY 8.77.

DEFINE VARIABLE ByBar AS LOGICAL INITIAL no
     LABEL "по ВЕСОВОМУ коду"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE ByGroup AS LOGICAL INITIAL no
     LABEL "по ГРУППЕ + АРТИКУЛ"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE ByGroup-Name AS LOGICAL INITIAL no
     LABEL "по ГРУППЕ + НАЗВ."
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE ByName AS LOGICAL INITIAL no
     LABEL "по НАЗВАНИЮ товара"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE ByPlu AS LOGICAL INITIAL no
     LABEL "по PLU-коду"
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1
     BGCOLOR 8 FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-help AT ROW 1 COL 28 WIDGET-ID 2
     ByBar AT ROW 3.83 COL 8
     ByPlu AT ROW 5.33 COL 8
     ByName AT ROW 6.93 COL 8
     ByGroup AT ROW 8.5 COL 8
     ByGroup-Name AT ROW 10.23 COL 7.8
     RECT-23 AT ROW 3.13 COL 5.5
     SPACE(5.06) SKIP(2.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE "КАК УПОРЯДОЧИТЬ СПИСОК"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* КАК УПОРЯДОЧИТЬ СПИСОК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
    Pri-mode = "отказ".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ByBar
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByBar Dialog-Frame
ON VALUE-CHANGED OF ByBar IN FRAME Dialog-Frame /* по ВЕСОВОМУ коду */
DO:
  assign ByBar.
  if ByBar then
    do:
        Pri-Mode = "bar" .
        apply "GO" to frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ByGroup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByGroup Dialog-Frame
ON VALUE-CHANGED OF ByGroup IN FRAME Dialog-Frame /* по ГРУППЕ + АРТИКУЛ */
DO:
  assign ByGroup.
  if ByGroup then
    do:
        Pri-Mode = "group" .
        apply "GO" to frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ByGroup-Name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByGroup-Name Dialog-Frame
ON VALUE-CHANGED OF ByGroup-Name IN FRAME Dialog-Frame /* по ГРУППЕ + НАЗВ. */
DO:
  assign ByGroup-NAME.
  if ByGroup-NAME then
    do:
        Pri-Mode = "group-name" .
        apply "GO" to frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ByName
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByName Dialog-Frame
ON VALUE-CHANGED OF ByName IN FRAME Dialog-Frame /* по НАЗВАНИЮ товара */
DO:
  assign ByName.
  if ByName then
    do:
        Pri-Mode = "name" .
        apply "GO" to frame {&frame-name} .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ByPlu
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByPlu Dialog-Frame
ON VALUE-CHANGED OF ByPlu IN FRAME Dialog-Frame /* по PLU-коду */
DO:
  assign ByPlu.
  if ByPlu then
    do:
        Pri-Mode = "plu" .
        apply "GO" to frame {&frame-name} .
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
  DISPLAY ByBar ByPlu ByName ByGroup ByGroup-Name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RECT-23 b-help ByBar ByPlu ByName ByGroup ByGroup-Name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME