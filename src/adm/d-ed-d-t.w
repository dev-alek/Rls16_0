&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-ed-d-t
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-ed-d-t
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и(или) редактирование даты и времени

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input-output parameter p-date as date    no-undo .
define input-output parameter p-time as integer no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание и(или) редактирование даты и времени".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME d-ed-d-t

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help f-date f-hour f-minute ~
f-sec
&Scoped-Define DISPLAYED-OBJECTS f-date f-hour f-minute f-sec

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

DEFINE VARIABLE f-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Дата" NO-UNDO.

DEFINE VARIABLE f-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Часы" NO-UNDO.

DEFINE VARIABLE f-minute AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3.25 BY 1 TOOLTIP "Минуты" NO-UNDO.

DEFINE VARIABLE f-sec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Секунды" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-ed-d-t
     b-exit AT ROW 1.17 COL 2
     b-quit AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 32
     f-date AT ROW 3 COL 7 COLON-ALIGNED
     f-hour AT ROW 3 COL 27.75 COLON-ALIGNED
     f-minute AT ROW 3 COL 30.75 COLON-ALIGNED NO-LABEL
     f-sec AT ROW 3 COL 33.75 COLON-ALIGNED NO-LABEL
     SPACE(4.24) SKIP(0.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Задайте дату и время"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-ed-d-t
                                                                        */
ASSIGN
       FRAME d-ed-d-t:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-ed-d-t
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-ed-d-t d-ed-d-t
ON WINDOW-CLOSE OF FRAME d-ed-d-t /* Задайте дату и время */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-ed-d-t
ON CHOOSE OF b-exit IN FRAME d-ed-d-t /* Ввод */
DO:
  define variable v-time as integer no-undo .

  assign
    f-hour
    f-minute
    f-sec
    f-date
  .
  if f-hour > 23
    or f-hour < 0
  then do:
    message "Часы могут быть в пределах от 0 до 23 !" view-as alert-box error.
    apply "entry" to f-hour in frame {&frame-name}.
    return no-apply.
  end.
  if f-minute > 59
    or f-minute < 0
  then do:
    message "Минуты могут быть в пределах от 0 до 59 !" view-as alert-box error.
    apply "entry" to f-minute in frame {&frame-name}.
    return no-apply.
  end.
  if f-sec > 59
    or f-sec < 0
  then do:
    message "Секунды могут быть в пределах от 0 до 59 !" view-as alert-box error.
    apply "entry" to f-sec in frame {&frame-name}.
    return no-apply.
  end.
  assign
    p-date = f-date
    p-time = f-hour * 3600 + f-minute * 60 + f-sec
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-ed-d-t
ON CHOOSE OF b-quit IN FRAME d-ed-d-t /* Отказ */
DO:
  assign
    p-date = ?
    p-time = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-ed-d-t


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

{ gbl/ed_date.i f-date }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  define variable v-time-str as character no-undo .

  assign
    v-time-str = string( p-time, "HH:MM:SS":U )
    f-hour   = integer( entry( 1, v-time-str, ":":U ) )
    f-minute = integer( entry( 2, v-time-str, ":":U ) )
    f-sec    = integer( entry( 3, v-time-str, ":":U ) )
    f-date   = p-date
  .

  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-ed-d-t _DEFAULT-DISABLE
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
  HIDE FRAME d-ed-d-t.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-ed-d-t _DEFAULT-ENABLE
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
  DISPLAY f-date f-hour f-minute f-sec
      WITH FRAME d-ed-d-t.
  ENABLE b-exit b-quit b-help f-date f-hour f-minute f-sec
      WITH FRAME d-ed-d-t.
  {&OPEN-BROWSERS-IN-QUERY-d-ed-d-t}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
