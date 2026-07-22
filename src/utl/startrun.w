&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Программа запуска утилит

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/01/04
Author: Bakhtadze Natalya
Creation date: 09/01/04

СОдрано  у Первакова


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter p-parent-handle as handle    no-undo.
/*handle запускающей процедура*/
DEFINE INPUT PARAMETER p-run-file-name AS CHARACTER NO-UNDO.
/*какую внутреннюю процедуру в p-parent-handle запускать*/
DEFINE INPUT PARAMETER p-parameters AS CHARACTER NO-UNDO.
/*параметры запуска*/
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
/*тайтл для вывода на экран*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

define stream sinp .

define variable v-running     as logical   no-undo .
define variable v-stop-run  as logical   no-undo .
define variable v-pause-run as logical   no-undo .

define variable v-run-time-start  as decimal   no-undo .
define variable v-run-time-finish as decimal   no-undo .

define variable v-run-ind      as integer   no-undo .
define variable v-need-run-ind as integer   no-undo .
define variable v-error-ind        as integer   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-run b-quit b-pause B-Help i-exit log-edit ~
fi-run fi-start-time fi-finish-time fi-need-run fi-error
&Scoped-Define DISPLAYED-OBJECTS log-edit fi-run fi-start-time ~
fi-finish-time fi-need-run fi-error

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

DEFINE BUTTON b-pause
     LABEL "&Пауза"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON b-run DEFAULT
     LABEL "_ &Выполнить"
     SIZE 13 BY 1.

DEFINE BUTTON i-exit
     IMAGE-UP FILE "cmp/i-run.bmp":U
     IMAGE-DOWN FILE "cmp/i-run.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/i-rund.bmp":U
     LABEL ""
     SIZE 2.5 BY .75.

DEFINE VARIABLE log-edit AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 76.13 BY 10.79 NO-UNDO.

DEFINE VARIABLE fi-error AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Ошибок"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE fi-finish-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Завершение"
      VIEW-AS TEXT
     SIZE 30.25 BY .67 NO-UNDO.

DEFINE VARIABLE fi-need-run AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Осталось"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE fi-run AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Выполнено"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE fi-start-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Начало"
      VIEW-AS TEXT
     SIZE 30.25 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-run AT ROW 1 COL 1
     b-quit AT ROW 1 COL 14
     b-pause AT ROW 1 COL 24
     B-Help AT ROW 1 COL 69.5
     i-exit AT ROW 1.13 COL 1.5 WIDGET-ID 4
     log-edit AT ROW 5.5 COL 2.5 NO-LABEL
     fi-run AT ROW 2.29 COL 19 COLON-ALIGNED
     fi-start-time AT ROW 2.29 COL 45.13 COLON-ALIGNED
     fi-finish-time AT ROW 3.29 COL 45.13 COLON-ALIGNED
     fi-need-run AT ROW 3.33 COL 19 COLON-ALIGNED
     fi-error AT ROW 4.33 COL 19 COLON-ALIGNED
     SPACE(45.49) SKIP(11.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>".


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
       log-edit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pause
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pause Dialog-Frame
ON CHOOSE OF b-pause IN FRAME Dialog-Frame /* Пауза */
DO:
  run pause-run in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  run stop-run in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-run
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-run Dialog-Frame
ON CHOOSE OF b-run IN FRAME Dialog-Frame /* _ Выполнить */
DO:
  run start-run in this-procedure .
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
  ASSIGN
  FRAME {&FRAME-NAME}:TITLE = p-title.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-check-stop-run Dialog-Frame
PROCEDURE callback-check-stop-run :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define output parameter p-stop-run  as logical   no-undo .
  define output parameter p-pause-run as logical   no-undo .

  assign
    p-stop-run  = v-stop-run
    p-pause-run = v-pause-run
  .
  assign
    v-stop-run  = false
    v-pause-run = false
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-display-run Dialog-Frame
PROCEDURE callback-display-run :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter  p-run-ind      as integer   no-undo .
  define input  parameter  p-need-run-ind as integer   no-undo .
  define input  parameter  p-error-ind        as integer   no-undo .


  assign
    v-run-ind      = p-run-ind
    v-need-run-ind = p-need-run-ind
    v-error-ind        = p-error-ind
  .

  define variable v-curr-time as decimal   no-undo .
  assign
    v-curr-time = integer(today) + time / 86400.0
  .
  if v-run-ind > 0
  and v-run-ind modulo 10 = 0
  then do:
    assign
      v-run-time-finish = (v-curr-time - v-run-time-start)
                            / v-run-ind
                            * v-need-run-ind
                            + v-curr-time
    .
  end.

  if  v-run-ind > 0
  and v-run-time-finish > v-run-time-start
  then do:
    define variable v-start-time-string as character no-undo .
    define variable v-finish-time-string as character no-undo .

    define variable v-ref-date        as date      no-undo .
    define variable v-start-date-ind  as integer   no-undo .
    define variable v-finish-date-ind as integer   no-undo .

    assign
      v-ref-date        = today
      v-start-date-ind  = integer(truncate(v-run-time-start, 0))
      v-finish-date-ind = integer(truncate(v-run-time-finish, 0))
    .

    assign
      v-start-time-string   = string(v-ref-date + v-start-date-ind - integer(v-ref-date), '99/99/9999':U)
                            + "  ":U
                            + string(integer(truncate((v-run-time-start - truncate(v-run-time-start, 0)) * 86400, 0)), 'HH:MM':U)
      v-finish-time-string  = string(v-ref-date + v-finish-date-ind - integer(v-ref-date), '99/99/9999':U)
                            + "  ":U
                            + string(integer(truncate((v-run-time-finish - truncate(v-run-time-finish, 0)) * 86400, 0)), 'HH:MM':U)
    .
  end.
  else do:
    assign
    v-ref-date        = today
    v-start-date-ind  = integer(truncate(v-run-time-start, 0))
    v-start-time-string   = string(v-ref-date + v-start-date-ind - integer(v-ref-date), '99/99/9999':U)
                            + "  ":U
                            + string(integer(truncate((v-run-time-start - truncate(v-run-time-start, 0)) * 86400, 0)), 'HH:MM':U)
    .
  end.

  display
    v-run-ind        @ fi-run
    v-need-run-ind   @ fi-need-run
    v-error-ind          @ fi-error
    v-start-time-string  @ fi-start-time
    v-finish-time-string @ fi-finish-time
    with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-set-start-run-time Dialog-Frame
PROCEDURE callback-set-start-run-time :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    v-run-time-start = integer(today) + time / 86400.0
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE callback-write-to-log Dialog-Frame
PROCEDURE callback-write-to-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter p-msg-str as character no-undo .

  define variable lok as logical   no-undo .

  do with frame {&frame-name}
  on error undo, return error
  :
    assign
      lok = log-edit :move-to-eof( )
      lok = log-edit :insert-string( p-msg-str )
      lok = log-edit :move-to-eof( )
    .
  end. /* do with frame */

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
  DISPLAY log-edit fi-run fi-start-time fi-finish-time fi-need-run fi-error
      WITH FRAME Dialog-Frame.
  ENABLE b-run b-quit b-pause B-Help i-exit log-edit fi-run fi-start-time
         fi-finish-time fi-need-run fi-error
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE pause-run Dialog-Frame
PROCEDURE pause-run :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 assign
    v-pause-run = true
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE start-run Dialog-Frame
PROCEDURE start-run :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    v-running     = true
    v-stop-run  = false
    v-pause-run = false
  .



  run value(p-run-file-name) in p-parent-handle
    (input this-procedure :handle /* p-handle-callback     */
     ,INPUT p-parameters
    ) .

  assign
    v-running = false
  .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE stop-run Dialog-Frame 
PROCEDURE stop-run :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  if v-running = true
  then do:
    assign
      v-stop-run = true
    .
  end.
  else do:
    apply 'close':u to this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

