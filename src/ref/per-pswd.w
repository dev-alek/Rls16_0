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

Форма ввода парол

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/27/06
Author: Bakhtadze Natalya
Creation date: 04/27/06

no_app_help.i

Author: Черных
Created: 30/10/98

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define output parameter per-pswd as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма ввода пароля".
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

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS PSWD Btn_OK fi-screen-pass
&Scoped-Define DISPLAYED-OBJECTS PSWD fi-screen-pass

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1.17
     BGCOLOR 8 .

DEFINE VARIABLE fi-screen-pass AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 11.5 BY .29
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE PSWD AS CHARACTER FORMAT "X(24)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 24 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     PSWD AT ROW 2 COL 13 COLON-ALIGNED BLANK
     Btn_OK AT ROW 6.33 COL 10.5
     fi-screen-pass AT ROW 1.9 COL 13.4 COLON-ALIGNED NO-LABEL
     SPACE(1.08) SKIP(7.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Подтвердите пароль"
         DEFAULT-BUTTON Btn_OK.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Подтвердите пароль */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    assign PSWD.
    per-pswd = PSWD .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME PSWD
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PSWD Dialog-Frame
ON ANY-KEY OF PSWD IN FRAME Dialog-Frame /* Пароль */
DO:
    assign
    fi-screen-pass :screen-value = fill('*':u, length(pswd :screen-value )).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PSWD Dialog-Frame
ON VALUE-CHANGED OF PSWD IN FRAME Dialog-Frame /* Пароль */
DO:
  assign
    fi-screen-pass :screen-value = fill('*':u, length(pswd :screen-value )).
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
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

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
  DISPLAY PSWD fi-screen-pass
      WITH FRAME Dialog-Frame.
  ENABLE PSWD Btn_OK fi-screen-pass
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
 fi-screen-pass:WIDTH-CHARS IN FRAME {&frame-name} = pswd:WIDTH-CHARS IN FRAME {&frame-name} - 0.5
 fi-screen-pass:HEIGHT-CHARS IN FRAME {&frame-name} = pswd:HEIGHT-CHARS IN FRAME {&frame-name} - 0.6
 fi-screen-pass:row IN FRAME {&frame-name} = pswd:row IN FRAME {&frame-name} + 0.2
 fi-screen-pass:COL IN FRAME {&frame-name} = pswd:col IN FRAME {&frame-name} + 0.2
 .

 DISPLAY
 PSWD
 fi-screen-pass
 WITH FRAME {&frame-name}.
 ENABLE
 PSWD
 Btn_OK
 fi-screen-pass
 WITH FRAME {&frame-name}.
 VIEW FRAME {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
