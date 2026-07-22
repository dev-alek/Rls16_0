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

Выбор фильтра для интерфейса пользователей

Автор: Белоусов Илья Александрович
Дата создания: 07/24/07
Author: Ilia Belousov
Creation date: 07/24/07

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc        as widget-handle    no-undo .
define input parameter p-name-filter        as character        no-undo.
define input parameter p-login-filter       as character        no-undo.
define output parameter p-new-name-filter   as character        no-undo.
define output parameter p-new-login-filter  as character        no-undo.
define output parameter p-filter-comment    as character        no-undo.
define output parameter p-accepted          as logical          no-undo.

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор фильтра для интерфейса пользователей".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*{ cmp/library.i  }*/

define variable v-usersf-can-exit   as logical      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-help fi-name-filter ~
fi-login-filter
&Scoped-Define DISPLAYED-OBJECTS fi-name-filter fi-login-filter

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 12 BY 1 TOOLTIP "Снять фильтр (ESC)"
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 12 BY 1 TOOLTIP "Установить фильтр (ENTER)"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fi-login-filter AS CHARACTER FORMAT "X(256)":U
     LABEL "В логине"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE fi-name-filter AS CHARACTER FORMAT "X(256)":U
     LABEL "В имени"
     VIEW-AS FILL-IN
     SIZE 26 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 13
     b-help AT ROW 1 COL 29
     fi-name-filter AT ROW 3.25 COL 11 COLON-ALIGNED WIDGET-ID 2
     fi-login-filter AT ROW 4.5 COL 11 COLON-ALIGNED WIDGET-ID 4
     SPACE(0.49) SKIP(0.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор полей фильтра"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-cancel WIDGET-ID 100.


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
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор полей фильтра */
DO:
/* Действия после нажатия кнопки Выбор */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор полей фильтра */
DO:
    if v-usersf-can-exit = no
    then do:
        undo, return no-apply.
    end.
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
    assign
        v-usersf-can-exit   = yes
        p-accepted          = no
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
    assign
        fi-name-filter
        fi-login-filter
    .
    run set-parameters in this-procedure (
        input no
    ).
    assign
        v-usersf-can-exit   = yes
        p-accepted          = yes
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
   run init-fields in this-procedure.
  RUN enable_UI.
  apply "entry":U to fi-name-filter.
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
  DISPLAY fi-name-filter fi-login-filter
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-help fi-name-filter fi-login-filter
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    assign
        fi-name-filter      = p-name-filter
        fi-login-filter     = p-login-filter
        v-usersf-can-exit   = no
    .
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-parameters Dialog-Frame
PROCEDURE set-parameters :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-cancel     as logical          no-undo.

do
on error undo, return error
:
    if p-cancel = yes
    then do:
        assign
            p-new-name-filter   = "":U
            p-new-login-filter  = "":U
            p-filter-comment    = "":U
        .
    end.
    else do:
        assign
            p-new-name-filter   = fi-name-filter
            p-new-login-filter  = fi-login-filter
        .
        if p-new-name-filter <> "":U
        then do:
            assign
                p-filter-comment    = substitute( "Имя: &1  ", fi-name-filter )
            .
        end.
        if p-new-login-filter <> "":U
        then do:
            assign
                p-filter-comment    = substitute( "&1Логин: &2", p-filter-comment, fi-login-filter )
            .
        end.
    end.
end.
END PROCEDURE. /* set-parameters */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME