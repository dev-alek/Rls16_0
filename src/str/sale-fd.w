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

Окно выбора выбора даты закрытия продажи
Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input parameter p-sys-today as date no-undo .
define input-output parameter p-date as date no-undo.
define input parameter p-shift-on as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно выбора выбора даты закрытия продажи".
{ cmp/vssrevis.i }
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
&Scoped-Define ENABLED-OBJECTS RECT-1 B-help Btn_OK Btn_Cancel v-date ~
f-sys-today
&Scoped-Define DISPLAYED-OBJECTS v-date f-sys-today

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Закрыть ТЕКУЩЕЙ датой"
     SIZE 27 BY 1.17
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Закрыть ВЫБРАННОЙ датой"
     SIZE 27 BY 1.17
     BGCOLOR 8 .

DEFINE VARIABLE f-sys-today AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Текущая дата на объекте"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-date AS DATE FORMAT "99/99/9999":U
     LABEL "Выбрать дату"
     VIEW-AS FILL-IN
     SIZE 14.3 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 76.9 BY 7.67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-help AT ROW 1 COL 61
     Btn_OK AT ROW 11 COL 5
     Btn_Cancel AT ROW 11 COL 44.5
     v-date AT ROW 12.67 COL 16 COLON-ALIGNED
     f-sys-today AT ROW 12.77 COL 65 COLON-ALIGNED WIDGET-ID 2
     "Внимание !!!" VIEW-AS TEXT
          SIZE 13 BY 1 AT ROW 5 COL 25.6
          BGCOLOR 8 FGCOLOR 4
     "В этом случае укажите более позднюю дату закрытия документа продажи" VIEW-AS TEXT
          SIZE 74.9 BY 1 AT ROW 9 COL 2.6
          BGCOLOR 8 FGCOLOR 4
     "Дата отчета не сегодняшняя." VIEW-AS TEXT
          SIZE 28 BY 1 AT ROW 3.67 COL 19.1
          BGCOLOR 8 FGCOLOR 4
     "Документ продажи не закроется, если по любому из товаров документа продажи" VIEW-AS TEXT
          SIZE 74.4 BY 1 AT ROW 6.33 COL 2.5
          BGCOLOR 8 FGCOLOR 4
     "более поздней датой был проведен документ инвентаризации" VIEW-AS TEXT
          SIZE 75 BY 1 AT ROW 7.67 COL 2.3
          BGCOLOR 8 FGCOLOR 4
     RECT-1 AT ROW 3 COL 1.5
     SPACE(0.97) SKIP(3.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Определить дату закрытия"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Определить дату закрытия */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Закрыть ТЕКУЩЕЙ датой */
DO:
    assign
    p-date  = p-sys-today
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Закрыть ВЫБРАННОЙ датой */
DO:
    assign
    v-date
    .
  if v-date < p-date then do:
        message
        "Неверно выбрана дата - дата закрытия документа меньше даты, чеков входящих в документ продажи"
        view-as alert-box ERROR.
        return no-apply.
    end.
    if v-date > p-sys-today then do:
        message
        "Неверно выбрана дата - дата закрытия документа больше даты на объекте"
        view-as alert-box ERROR.
        return no-apply.
    end.
  if p-shift-on then do:
    if v-date <> p-date and v-date <> p-sys-today then do:
      message
      "Неверно выбрана дата - для сменного объекта можно закрыть документ либо текущей датой"
      "либо датой чеков, входящих в документ продажи"
      view-as alert-box error .
      return no-apply.
    end.
  end.
    assign
    p-date = v-date
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
  assign
  v-date = (IF p-sys-today < TODAY THEN p-sys-today ELSE p-date)
  f-sys-today = p-sys-today
  .
  RUN enable_UI.
  if p-shift-on then DISABLE v-date.
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
  DISPLAY v-date f-sys-today
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 B-help Btn_OK Btn_Cancel v-date f-sys-today
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
