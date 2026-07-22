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

Вопрос с автоответом через промежуток времени

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/27/05
Author: Dmitry Ukhanov
Creation date: 12/27/05

no_app_help.i

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter p-msg          as character no-undo .
define input  parameter p-default-answ as logical   no-undo .
define input  parameter p-timeout      as integer   no-undo .
define output parameter p-answer       as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вопрос с автоответом через промежуток времени".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */

define variable log-exit as logical   no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-yes b-no f-wait
&Scoped-Define DISPLAYED-OBJECTS f-msg f-wait

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-no AUTO-END-KEY DEFAULT
     LABEL "&Нет"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-yes AUTO-GO DEFAULT
     LABEL "&Да"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 39 BY .67 NO-UNDO.

DEFINE VARIABLE f-wait AS INTEGER FORMAT ">>>>>9":U INITIAL 0
     LABEL "Ожидание ответа (сек)"
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-yes AT ROW 4.25 COL 11
     b-no AT ROW 4.25 COL 22.5
     f-msg AT ROW 1.5 COL 2.5 NO-LABEL
     f-wait AT ROW 3 COL 27.5 COLON-ALIGNED
     SPACE(6.49) SKIP(2.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER NO-HELP
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Вопрос"
         CANCEL-BUTTON b-no.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN f-msg IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       f-msg:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-wait:AUTO-RESIZE IN FRAME Dialog-Frame      = TRUE
       f-wait:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Вопрос */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-no
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-no Dialog-Frame
ON CHOOSE OF b-no IN FRAME Dialog-Frame /* Нет */
DO:
  assign
    log-exit = TRUE
    p-answer = FALSE
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-yes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-yes Dialog-Frame
ON CHOOSE OF b-yes IN FRAME Dialog-Frame /* Да */
DO:
  assign
    log-exit = TRUE
    p-answer = TRUE
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

  define variable start-time as int64     no-undo .
  define variable v-length   as integer   no-undo .
  define variable lh         as handle    no-undo .
  define variable v-delta    as integer   no-undo .

  assign
    v-length = length( p-msg )
  .
  if v-length > 90 then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Сообщение должно быть не больше 90 символов!" ) skip
      substitute( "Ваше сообщение длиной &1 символов.", v-length ) skip
      view-as alert-box error .
    return error "Сообщение должно быть не больше 90 символов!".
  end.

  if v-length > 39 then do:
    assign
      v-delta                         = ( v-length - 39 ) / 2
      f-msg:width-chars               = v-length
      frame {&frame-name}:width-chars = f-msg:width-chars + 4
      b-yes:column                    = b-yes:column + v-delta
      b-no:column                     = b-no:column + v-delta
      f-wait:column                   = f-wait:column + v-delta
    .
    if valid-handle(f-wait:side-label-handle) then do:
      assign
        lh        = f-wait:side-label-handle
        lh:column = lh:column + v-delta
      .
    end.
  end.

  assign
    f-msg    = p-msg
    log-exit = false
    p-answer = p-default-answ
  .
/*  if p-default-answ = true then do:*/
/*    assign*/
/*      b-yes:default = true*/
/*      b-no:default  = false*/
/*    .*/
/*  end.*/
/*  else do:*/
/*    assign*/
/*      b-yes:default = false*/
/*      b-no:default  = true*/
/*    .*/
/*  end.*/

  RUN enable_UI.

  assign
    start-time = etime
  .
  do while not log-exit:
    display
      ( p-timeout - ( etime - start-time ) / 1000 ) @ f-wait
      with frame {&frame-name}
      no-error
    .
    wait-for
      go of frame {&frame-name}
      or close of this-procedure
      or choose of b-yes in frame {&frame-name}
      or choose of b-no in frame {&frame-name}
      focus frame {&frame-name}
      pause 1
    .
    if etime - start-time > p-timeout * 1000 then do:
      leave .
    end.
  end.
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
  DISPLAY f-msg f-wait
      WITH FRAME Dialog-Frame.
  ENABLE b-yes b-no f-wait
      WITH FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME