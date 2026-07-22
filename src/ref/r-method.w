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

Редактор атрибута < метод округления>

Автор: Бахтадзе Наталья Викторовна
Дата создания: 17/07/03
Author: Bakhtadze Natalya
Creation date: 17/07/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input-output parameter p-value as character no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактор атрибута <Метод округления>".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }

define variable v-round-method as character no-undo.
define variable v-base as decimal no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-exit B-Help S-round-method f-base
&Scoped-Define DISPLAYED-OBJECTS S-round-method f-base

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

DEFINE VARIABLE f-base AS DECIMAL FORMAT "->>>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 15.38 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE S-round-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 24.38 BY 6.42
     BGCOLOR 15  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 41
     S-round-method AT ROW 2.88 COL 2.63 NO-LABEL
     f-base AT ROW 2.88 COL 27.75 COLON-ALIGNED NO-LABEL
     SPACE(8.11) SKIP(5.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Метод наценки"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

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
ON GO OF FRAME Dialog-Frame /* Метод наценки */
DO:
define variable v-base-str as character no-undo.
  assign
  S-round-method
  f-base
  .
  if LOOKUP(S-round-method, {&pr-rounds-need-coef}) > 0 then do:
    if f-base = 0 then do:
      message
      "Введите ненулевое значение коэффициента"
      view-as alert-box error .
      return no-apply.
    end.
  END.
  assign
   v-base-str = (if f-base:visible in frame {&frame-name}
                    then string(f-base, "->>>>9.99":U)
                    else "":U)
                    .
  assign
  p-value = s-round-method + {&space-char} + v-base-str
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Метод наценки */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME S-round-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL S-round-method Dialog-Frame
ON VALUE-CHANGED OF S-round-method IN FRAME Dialog-Frame
DO:
  assign
  S-round-method
  .
  if lookup(S-round-method, {&pr-rounds-need-coef}) > 0 then do:
    display
    f-base
    with frame {&frame-name}.
    enable
    f-base
    with frame {&frame-name}.
  end.
  else do:
    hide
    f-base
    in frame {&frame-name}.
    disable
    f-base
    with frame {&frame-name}.
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
assign
v-round-method = entry(1, p-value, {&space-char})
v-base = decimal(entry(2, p-value, {&space-char}))
no-error.

if error-status:error and num-entries(p-value, {&space-char}) > 0 then do:
    message
    "Неверное значение параметра p-value" p-value
    view-as alert-box ERROR.
    return error.
end.
assign
p-value = ?
.
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY S-round-method f-base
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help S-round-method f-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
s-round-method:list-items in frame {&frame-name} = {&pr-rounds}.
DISPLAY S-round-method f-base
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-exit B-Help S-round-method f-base
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
s-round-method:screen-value in frame {&frame-name} = v-round-method.
f-base = v-base.
APPLY "VALUE-CHANGED" to S-round-method.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME