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

Параметры для изготовления карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/05
Author: Bakhtadze Natalya
Creation date: 06/24/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE OUTPUT PARAMETER p-first-track AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-valid-date AS DATE NO-UNDO.
DEFINE OUTPUT PARAMETER p-prefix AS character NO-UNDO.

/* Local Variable Definitions ---                                       */
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Параметры для изготовления карт".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }

 DEFINE VARIABLE v-result AS CHARACTER NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RS-codir f-valid-date ~
f-prefix
&Scoped-Define DISPLAYED-OBJECTS RS-codir f-valid-date f-prefix

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

DEFINE VARIABLE f-prefix AS CHARACTER FORMAT "X(18)":U
     LABEL "Префикс"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-valid-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Дата истечения срока действия"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE RS-codir AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Не выводить 1-ю дорожку  (имя держателя)", "",
"WINDOWS 1251", "1251",
"KOI8-R", "KOI8-R",
"DOS", "ibm866"
     SIZE 50 BY 2.63 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     RS-codir AT ROW 2.25 COL 3 NO-LABEL
     f-valid-date AT ROW 6 COL 32.5 COLON-ALIGNED
     f-prefix AT ROW 9 COL 32 COLON-ALIGNED
     "(для карт, у которых срок действия не определен)" VIEW-AS TEXT
          SIZE 48.5 BY 1 AT ROW 7 COL 3
          FGCOLOR 4
     SPACE(13.37) SKIP(2.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры для изготовления карт"
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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры для изготовления карт */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE VARIABLE ii AS integer NO-UNDO.
  ASSIGN
  rs-codir
  f-valid-date
  f-prefix
  .
  IF f-valid-date = ?
  OR f-valid-date <  TODAY THEN DO:
      MESSAGE
      "Неверно задата дата"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.

  END.
  DO ii = 1 TO LENGTH(f-prefix):
    IF INDEX("0123456789", SUBSTRING(f-prefix, ii, 1)) = 0 THEN DO:
        MESSAGE
        "Неверный (нецифровой) префикс"
        VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
  END.
  ASSIGN
  p-first-track = rs-codir
  p-valid-date = f-valid-date
  p-prefix = f-prefix
  .

  MESSAGE
  "В файле для изготовления карт" SKIP(0)
  (IF p-first-track <> '':U
  THEN substitute("1-я дорожка с именем держателя формируется в кодировке &1", p-first-track)
  ELSE "не выводится 1-я дорожка") SKIP(0)
  substitute("префикс для всех карт будет взят равным &1", p-prefix) SKIP(0)
  substitute("дата истечения срока действия для карт, у которых срок действия НЕ ОПРЕДЕЛЕН, будет взята равной &1", string(p-valid-date, "99/99/9999")) SKIP(0)
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog THEN DO:
      RETURN NO-APPLY.
  END.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
  v-result = "error".
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
  RETURN v-result.
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
  DISPLAY RS-codir f-valid-date f-prefix
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RS-codir f-valid-date f-prefix
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
