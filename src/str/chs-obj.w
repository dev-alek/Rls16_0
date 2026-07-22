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

Выбор объекта для экрана покупател

Автор: Перваков Михаил Сергеевич
Дата создания: 12/01/06
Author: Mikhail Pervakov
Creation date: 12/01/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter paruser-id   as character no-undo .
define input  parameter parl-type    as character no-undo .
define output parameter parobj-type  as character no-undo .
define output parameter parobj-code  as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор объекта для экрана покупателя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/userobjs.i }
{ cmp/trg-def.i new }


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-choice b-cancel b-help varobj-code ~
varobj-type r-obj
&Scoped-Define DISPLAYED-OBJECTS varobj-code varobj-type varobj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-choice AUTO-GO
     LABEL "&Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.

DEFINE VARIABLE varobj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE varobj-name AS CHARACTER FORMAT "X(30)":U
      VIEW-AS TEXT
     SIZE 31 BY .67 NO-UNDO.

DEFINE VARIABLE varobj-type AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-choice AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     varobj-code AT ROW 2.58 COL 2
     varobj-type AT ROW 2.58 COL 18.88 COLON-ALIGNED NO-LABEL
     r-obj AT ROW 2.67 COL 28.88
     varobj-name AT ROW 3.96 COL 1.5 NO-LABEL
     SPACE(0.62) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор объекта"
         DEFAULT-BUTTON b-choice CANCEL-BUTTON b-cancel.


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

/* SETTINGS FOR FILL-IN varobj-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN varobj-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор объекта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  assign
    parobj-type = ?
    parobj-code = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choice
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choice Dialog-Frame
ON CHOOSE OF b-choice IN FRAME Dialog-Frame /* Выбор */
DO:
 define buffer buf_clients for ub.clients.
 assign
   frame {&frame-name} varobj-type varobj-code.
 find first buf_clients where buf_clients.obj-type = varobj-type and
                             buf_clients.obj-code = varobj-code no-lock no-error.
 if not available buf_clients then do:
   message "Нет такого клиента." view-as alert-box.
   return no-apply.
 end.
 if lookup (varobj-type, parl-type) = 0 then do:
   message "Недопустимый тип выбранного объекта: " varobj-type skip
           "Допустимые типы: " parl-type skip
           view-as alert-box.
   return no-apply.
 end.
 assign
   parobj-type = varobj-type
   parobj-code = varobj-code
 .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-obj Dialog-Frame
ON CHOOSE OF r-obj IN FRAME Dialog-Frame
DO:
  define buffer buf_clients for ub.clients.
  define variable v-db-num as integer   no-undo .
  define variable v-current-host-code as integer   no-undo .
  define variable v-current-obj-type  as character no-undo .
  define variable v-current-obj-code  as integer   no-undo .
  define variable v-obj-type          as character no-undo .
  define variable v-obj-code          as integer   no-undo .
  define variable v-user-select       as logical   no-undo .

  { gbl/curdbnum.i
    v-db-num
  }

  assign
    frame {&frame-name}
    varobj-code
    varobj-type
  .

  find buf_clients no-lock
    where buf_clients.obj-type = varobj-type
      and buf_clients.obj-code = varobj-code
    no-error .
  if available buf_clients
  then do:
    assign
      v-current-host-code = buf_clients.host-code
      v-current-obj-type  = buf_clients.obj-type
      v-current-obj-code  = buf_clients.obj-code
    .
  end.
  else do:
    assign
      v-current-host-code = 0
      v-current-obj-type  = '':U
      v-current-obj-code  = 0
    .
  end.

  { gbl/uobjsone.i
    "this-procedure :handle"
    v-db-num
    paruser-id
    v-current-host-code
    v-current-obj-type
    v-current-obj-code
    v-user-select
    v-obj-type
    v-obj-code
  }

  if v-user-select = true
  then do:
    find buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      .
    disp buf_clients.obj-code @ varobj-code
        buf_clients.obj-type  @ varobj-type
        buf_clients.obj-name  @ varobj-name with frame {&frame-name}.
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

   /* todo - текущий объект пользователя */
/*  assign*/
/*    varobj-type = userconf.obj-type*/
/*    varobj-code = userconf.obj-code*/
/*  .*/

  run gbl/set-gbl.p
    (input false      /* p-auto        */
    ,input paruser-id /* p-user-id     */
    ,input ""         /* p-user-passwd */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при установке глобальных переменных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return .
  end.

  RUN enable_UI .
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
  DISPLAY varobj-code varobj-type varobj-name
      WITH FRAME Dialog-Frame.
  ENABLE b-choice b-cancel b-help varobj-code varobj-type r-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu_getcntxt W-Win
PROCEDURE mainmenu_getcntxt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define output parameter p-cntxt-db-num        as integer   no-undo .
  define output parameter p-cntxt-user-id       as character no-undo .
  define output parameter p-cntxt-level         as character no-undo .
  define output parameter p-cntxt-host-code-obj as integer   no-undo .
  define output parameter p-cntxt-obj-type      as character no-undo .
  define output parameter p-cntxt-obj-code      as integer   no-undo .
  define output parameter p-cntxt-db-num-obj    as integer   no-undo .
  define output parameter p-cntxt-is-admin      as logical   no-undo .

  define variable v-db-num     as integer   no-undo .
  define variable v-host-code  as integer   no-undo .
  define variable v-db-num-obj as integer   no-undo .

  do
  on error undo, return error
  :
    { gbl/curdbnum.i
      v-db-num
    }

    if  varobj-type = '':U
    and varobj-code = 0
    then do:
      assign
        p-cntxt-db-num        = v-db-num
        p-cntxt-user-id       = paruser-id
        p-cntxt-level         = {&cntxt-global}
        p-cntxt-host-code-obj = 0
        p-cntxt-obj-type      = '':U
        p-cntxt-obj-code      = 0
        p-cntxt-db-num-obj    = ?
      .
    end.
    else do:
      { gbl/hostcode.i
        varobj-type
        varobj-code
        v-host-code
      }
      { gbl/objdbnum.i
        varobj-type
        varobj-code
        v-db-num-obj
      }

      assign
        p-cntxt-db-num        = v-db-num
        p-cntxt-user-id       = paruser-id
        p-cntxt-level         = {&cntxt-object}
        p-cntxt-host-code-obj = v-host-code
        p-cntxt-obj-type      = varobj-type
        p-cntxt-obj-code      = varobj-code
        p-cntxt-db-num-obj    = v-db-num-obj
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-userid W-Win
PROCEDURE get-userid :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error
  :
    define output parameter p-userid  as character no-undo .

    assign
      p-userid = paruser-id
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME