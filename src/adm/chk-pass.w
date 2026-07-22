&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Проверка пароля и права

Автор: Белоусов Илья Александрович
Дата создания: 08/07/08
Author: Ilia Belousov
Creation date: 08/07/08

Input:

Output:

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter  parparentproc as handle    no-undo .
define input parameter  p-user-id     as character no-undo .
define input parameter  p-db-num      as integer   no-undo .
define input parameter  p-action      as character        no-undo.
define input parameter  p-ask         as logical          no-undo.
define output parameter p-message     as character        no-undo.
define output parameter p-ok          as logical   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка пароля".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/eventlib.i }

define buffer buf_user-login     for ub.user-login .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS v-password b-exit b-quit v-login
&Scoped-Define DISPLAYED-OBJECTS v-password v-login

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-login AS CHARACTER FORMAT "X(256)":U
     LABEL "Логин"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE v-password AS CHARACTER FORMAT "X(16)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     v-password AT ROW 2.75 COL 10.88 COLON-ALIGNED WIDGET-ID 4 AUTO-RETURN  PASSWORD-FIELD
     b-exit AT ROW 4.75 COL 10
     b-quit AT ROW 4.75 COL 21
     v-login AT ROW 1.5 COL 11 COLON-ALIGNED WIDGET-ID 2
     SPACE(11.62) SKIP(4.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите пароль"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Введите пароль */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    v-login
    v-password
  .
  RUN chk-action in this-procedure (OUTPUT p-ok)  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-password
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-password Dialog-Frame
ON ENTER OF v-password IN FRAME Dialog-Frame /* Пароль */
DO:
   APPLY "CHOOSE" TO b-exit in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
/* no_app_help */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

on "ENTRY" of b-exit do:
  if lastkey = keycode ("RETURN") then do:
    apply "CHOOSE" to b-exit in frame {&frame-name}.
  end.
end.

on "ESC" ANYWHERE do:
  if lastkey = keycode ("RETURN") then do:
    p-ok = FALSE.
    apply "CHOOSE" to b-quit in frame {&frame-name}.
  end.
end.



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   { gbl/getcntxt.i get }
   /* Проверка права */
   { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      p-action
      {&cntxt-object}
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      0
      0
      0
      false
      p-ok
   }
   IF p-ok
   AND NOT p-ask
   THEN DO:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         p-action
         0
         '':U
         0
         '':U
         '*':U
         '':U
         '':U
         '':U
         TODAY
         35
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         NO-ERROR
      }
      RETURN .
   END.
   assign
      p-ok = FALSE
   .
   /* Если у пользователя нет права,
      то предлагаем ввести логин того,
      у кого такое право есть.
   */

   FIND FIRST buf_user-login
        WHERE buf_user-login.db-num     = p-db-num
          AND buf_user-login.user-id    = p-user-id
        NO-LOCK
        NO-ERROR
        .
   IF AVAILABLE buf_user-login
   THEN DO:
      ASSIGN
         v-login = buf_user-login.user-login
      .
   END.

   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE chk-action Dialog-Frame
PROCEDURE chk-action :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-ok as logical          no-undo.

define variable v-user-password-enc    as character    no-undo.

do
on error undo, return error
:
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      p-action
      0
      '':U
      0
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      33
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-login
      NO-ERROR
   }
   FIND FIRST buf_user-login
        WHERE buf_user-login.db-num     = p-db-num
          AND buf_user-login.user-login = v-login
        NO-LOCK
        NO-ERROR
        .
   IF NOT AVAILABLE buf_user-login
   THEN DO:
      ASSIGN
         p-message = "Неправильный логин"
         p-ok      = FALSE
      .
      RETURN.
   END.

   run adm/pswd-enc.p
      (input  encode(v-password)
      ,output v-user-password-enc
      ) no-error .
   if error-status:error
   then do:
      return error substitute( "&1. Ошибка кодировки. &2", vss-workfile, return-value ).
   end.

   assign
      v-user-password-enc = encode(v-user-password-enc)
   .
   IF buf_user-login.user-password-encoded = v-user-password-enc
   THEN DO:
      IF p-action = "":U
      THEN DO:
         ASSIGN
            p-ok = TRUE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            p-action
            0
            '':U
            0
            '':U
            '*':U
            '':U
            '':U
            '':U
            TODAY
            35
            TIME
            'S':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-login
            NO-ERROR
         }
         RETURN.
      END.
      /* Проверка права */
      { gbl/chk-actg.i
         v-cntxt-db-num
         buf_user-login.user-id
         {&action-head-code-main}
         p-action
         {&cntxt-object}
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         0
         0
         0
         false
         p-ok
      }
      IF NOT p-ok
      THEN DO:
         ASSIGN
            p-message = RETURN-VALUE
         NO-ERROR.
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            p-action
            0
            '':U
            0
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            34
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-login
            NO-ERROR
         }
         RETURN .
      END.
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         p-action
         0
         '':U
         0
         '':U
         '*':U
         '':U
         '':U
         '':U
         TODAY
         35
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-login
         NO-ERROR
      }
   END.
   ELSE DO:
      ASSIGN
         p-message = "Неправильный пароль"
         p-ok      = FALSE
      .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         p-action
         0
         '':U
         0
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         34
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-login
         NO-ERROR
      }
      RETURN.
   END.
end.  /* do on error */
END PROCEDURE. /* chk-action */

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
  DISPLAY v-password v-login
      WITH FRAME Dialog-Frame.
  ENABLE v-password b-exit b-quit v-login
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME