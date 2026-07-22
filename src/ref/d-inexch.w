&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
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

Ввести дату и курс валюты

Автор: Перваков Михаил Сергеевич
Дата создания: 03/01/05
Author: Mikhail Pervakov
Creation date: 03/01/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input         parameter h-callback         as handle    no-undo .
define input         parameter p-title            as character no-undo .
define input         parameter p-enable-update    as logical   no-undo .
define input         parameter p-enable-exch-date as logical   no-undo .
define input-output  parameter p-exch-date        as date      no-undo .
define input-output  parameter p-exch-rate        as decimal   no-undo .
define input-output  parameter p-exch-scale       as integer   no-undo .
define output        parameter p-data-update      as logical   no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввести дату и курс валюты".
{ cmp/vssrevis.i }
{ gbl/sel-date.i }
{ cmp/showinf.i  }
{ gbl/color.i    }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help
&Scoped-Define DISPLAYED-OBJECTS fi-exch-date fi-exch-rate fi-exch-scale

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choose-exch-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-exch-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".

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

DEFINE VARIABLE fi-exch-date AS DATE FORMAT "99/99/9999":U
     LABEL "&Дата курса"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-exch-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "&Курс валюты"
     VIEW-AS FILL-IN
     SIZE 12.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-exch-scale AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "&Масштаб"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     fi-exch-date AT ROW 2.25 COL 17.5 COLON-ALIGNED
     b-choose-exch-date AT ROW 2.25 COL 32
     fi-exch-rate AT ROW 3.5 COL 17.5 COLON-ALIGNED
     fi-exch-scale AT ROW 4.75 COL 17.5 COLON-ALIGNED
     SPACE(19.12) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Заголовок диалога"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


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
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-choose-exch-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-exch-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-exch-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-exch-scale IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Заголовок диалога */
DO:
  if p-enable-update = true
  then do:
    assign
      fi-exch-date
      fi-exch-rate
      fi-exch-scale
    .
    if p-enable-exch-date = true
    then do:
      assign
        p-exch-date = fi-exch-date
      .
    end.
    assign
      p-exch-rate  = fi-exch-rate
      p-exch-scale = fi-exch-scale
    .
    assign
      p-data-update = true
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Заголовок диалога */
DO:
  APPLY "END-ERROR":U TO SELF.
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

{ gbl/ed_date.i fi-exch-date }

on choose of b-choose-exch-date in frame {&frame-name}
do:
  run sel-date in this-procedure
    (input fi-exch-date :handle
    ,input "Дата курса &1"
    ) .
end.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  assign
    frame {&frame-name} :title = p-title
  .

  RUN enable_UI.

  display
    p-exch-date  @ fi-exch-date
    p-exch-rate  @ fi-exch-rate
    p-exch-scale @ fi-exch-scale
    with frame {&frame-name} .

  if p-enable-update = true
  then do:
    if p-enable-exch-date = true
    then do:
      enable
        fi-exch-date
        b-choose-exch-date
        with frame {&frame-name} .
    end.
    else do:
      assign
        fi-exch-date :fgcolor = BROWN_COLOR
      .
    end.
    enable
      fi-exch-rate
      fi-exch-scale
      with frame {&frame-name} .
  end.
  else do:
    assign
      fi-exch-date  :fgcolor = BROWN_COLOR
      fi-exch-rate  :fgcolor = BROWN_COLOR
      fi-exch-scale :fgcolor = BROWN_COLOR
    .
    disable
      b-quit
      with frame {&frame-name} .
    hide
      b-quit
      in frame {&frame-name} .
    assign
      b-exit :label = "&Выход"
    .

  end.


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
  DISPLAY fi-exch-date fi-exch-rate fi-exch-scale
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME