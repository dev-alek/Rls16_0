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

Диалог действий при переносе файлов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER p-title         AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-old-file-path AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-old-file-size AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-old-file-date AS date NO-UNDO.
DEFINE INPUT PARAMETER p-old-file-time AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-new-file-path AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-new-file-size AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-new-file-date AS date NO-UNDO.
DEFINE INPUT PARAMETER p-new-file-time AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-default-button AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-cancel-button AS INTEGER NO-UNDO.
DEFINE output PARAMETER p-choice AS integer NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог действий при переносе файлов".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Help B-overwrite B-overwrite-all B-skip ~
b-quit B-overwrite-all-older B-skip-all f-old-file f-old-file-size ~
f-old-file-date f-old-file-time f-new-file f-new-file-size f-new-file-date ~
f-new-file-time
&Scoped-Define DISPLAYED-OBJECTS f-old-file f-old-file-size f-old-file-date ~
f-old-file-time f-new-file f-new-file-size f-new-file-date f-new-file-time

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-overwrite AUTO-GO
     LABEL "&Перезаписать"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-overwrite-all AUTO-GO
     LABEL "Перезаписать &все"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-overwrite-all-older AUTO-GO
     LABEL "Перезаписать старые"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-skip AUTO-GO
     LABEL "Ос&тавить"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-skip-all AUTO-GO
     LABEL "Ост&авить все"
     SIZE 20 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-new-file AS CHARACTER FORMAT "X(256)":U
     LABEL "Файлом"
      VIEW-AS TEXT
     SIZE 55.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-new-file-date AS DATE FORMAT "99/99/9999":U
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-new-file-size AS INTEGER FORMAT ">>>,>>>,>>9Б":U INITIAL 0
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-new-file-time AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-old-file AS CHARACTER FORMAT "X(256)":U
     LABEL "Перезаписать"
      VIEW-AS TEXT
     SIZE 55.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-old-file-date AS DATE FORMAT "99/99/9999":U
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-old-file-size AS INTEGER FORMAT ">>>,>>>,>>9Б":U INITIAL 0
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-old-file-time AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 11 BY .67
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Help AT ROW 1 COL 54.9
     B-overwrite AT ROW 6.87 COL 1.5
     B-overwrite-all AT ROW 6.87 COL 21.5
     B-skip AT ROW 6.87 COL 41.5
     b-quit AT ROW 7.93 COL 1.5
     B-overwrite-all-older AT ROW 7.93 COL 21.5
     B-skip-all AT ROW 7.93 COL 41.5
     f-old-file AT ROW 2 COL 1
     f-old-file-size AT ROW 3 COL 12 COLON-ALIGNED NO-LABEL
     f-old-file-date AT ROW 3 COL 32 NO-LABEL
     f-old-file-time AT ROW 3 COL 52 NO-LABEL
     f-new-file AT ROW 4.2 COL 7
     f-new-file-size AT ROW 5 COL 12 COLON-ALIGNED NO-LABEL
     f-new-file-date AT ROW 5 COL 32 NO-LABEL
     f-new-file-time AT ROW 5 COL 52 NO-LABEL
     SPACE(7.59) SKIP(4.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-overwrite CANCEL-BUTTON b-quit.


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

ASSIGN
       B-overwrite:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "1".

ASSIGN
       B-overwrite-all:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "2".

ASSIGN
       B-overwrite-all-older:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "5".

ASSIGN
       b-quit:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "6".

ASSIGN
       B-skip:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "3".

ASSIGN
       B-skip-all:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "4".

/* SETTINGS FOR FILL-IN f-new-file IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-new-file-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-new-file-time IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-old-file IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-old-file-date IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-old-file-time IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
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


&Scoped-define SELF-NAME B-overwrite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-overwrite Dialog-Frame
ON CHOOSE OF B-overwrite IN FRAME Dialog-Frame /* Перезаписать */
OR CHOOSE OF b-overwrite-all
OR CHOOSE OF b-overwrite-all-older
OR CHOOSE OF b-skip
OR CHOOSE OF b-skip-all
OR CHOOSE OF b-quit
DO:
  ASSIGN
  p-choice = INTEGER(SELF:PRIVATE-DATA).
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
  RUN Myenable in this-procedure .
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
  DISPLAY f-old-file f-old-file-size f-old-file-date f-old-file-time f-new-file
          f-new-file-size f-new-file-date f-new-file-time
      WITH FRAME Dialog-Frame.
  ENABLE B-Help B-overwrite B-overwrite-all B-skip b-quit B-overwrite-all-older
         B-skip-all f-old-file f-old-file-size f-old-file-date f-old-file-time
         f-new-file f-new-file-size f-new-file-date f-new-file-time
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
ASSIGN
f-old-file = p-old-file-path
f-old-file-size = p-old-file-size
f-old-file-date = p-old-file-date
f-old-file-time = string(p-old-file-time, "HH:MM:SS")
f-new-file = p-new-file-path
f-new-file-size = p-new-file-size
f-new-file-date = p-new-file-date
f-new-file-time = string(p-new-file-time, "HH:MM:SS")
.
DISPLAY
f-old-file
f-old-file-size
f-old-file-date
f-old-file-time
f-new-file
f-new-file-size
f-new-file-date
f-new-file-time
WITH FRAME {&FRAME-NAME}.
ASSIGN
B-overwrite:PRIVATE-DATA IN FRAME {&FRAME-NAME} = string(1)
B-overwrite-all :PRIVATE-DATA IN FRAME {&FRAME-NAME} = string(2)
B-skip:PRIVATE-DATA IN FRAME {&FRAME-NAME} = string(3)
b-quit:PRIVATE-DATA IN FRAME {&FRAME-NAME} = string(6)
B-overwrite-all-older:PRIVATE-DATA IN FRAME {&FRAME-NAME} = string(5)
B-skip-all:PRIVATE-DATA IN FRAME {&FRAME-NAME} = string(4)
.
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
assign
fh = frame {&frame-name}:first-child
hh = fh:first-child
.
do while valid-handle(hh):
IF hh:TYPE <> "button" THEN DO:
  hh = hh:next-sibling.
END.
if hh:private-data = string(p-cancel-button) then do:
  ASSIGN
  FRAME {&FRAME-NAME}:cancel-button = hh.
end.
if hh:private-data = string(p-default-button) then do:
  APPLY "ENTRY" to hh.
end.
hh = hh:next-sibling.
end. /*do while*/

ENABLE
B-Help
B-overwrite
B-overwrite-all
B-skip
b-quit
B-overwrite-all-older
B-skip-all
WITH FRAME {&FRAME-NAME}.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = p-title.
VIEW FRAME {&FRAME-NAME}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
