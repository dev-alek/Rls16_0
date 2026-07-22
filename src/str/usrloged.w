&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование данных для логина пользовател

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/30/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc               as widget-handle no-undo .
define input  parameter p-input-mode                as character no-undo .
define input-output parameter p-db-num                    as integer   no-undo .
define input  parameter p-user-id                   as character no-undo .
define input  parameter p-user-login                as character no-undo .
define input  parameter p-user-administrator        as logical   no-undo .
define input  parameter p-max-discnt                as decimal   no-undo .
define input  parameter p-quest-print               as logical   no-undo .
define output parameter v-update-data               as logical   no-undo .
define output parameter v-output-user-login         as character no-undo .
define output parameter v-output-user-administrator as logical   no-undo .
define output parameter v-output-max-discnt         as decimal   no-undo .
define output parameter v-output-quest-print        as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование данных для логина пользователя".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help b-choice-bd ~
fi-db-num fi-user-name 
&Scoped-Define DISPLAYED-OBJECTS fi-db-num fi-user-id fi-user-login ~
fi-max-discnt t-quest-print fi-user-name 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-choice-bd 
     LABEL "Выбор" 
     SIZE 11 BY 1.

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

DEFINE VARIABLE fi-db-num LIKE user-login.db-num
     VIEW-AS FILL-IN 
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-max-discnt LIKE user-login.max-discnt
     VIEW-AS FILL-IN 
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE fi-user-id LIKE user-login.user-id
     VIEW-AS FILL-IN 
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-user-login LIKE user-login.user-login
     VIEW-AS FILL-IN 
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE fi-user-name AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 79 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE t-quest-print LIKE user-login.quest-print
     VIEW-AS TOGGLE-BOX
     SIZE 43.13 BY .83 NO-UNDO.

DEFINE VARIABLE t-user-administrator LIKE user-login.user-administrator
     VIEW-AS TOGGLE-BOX
     SIZE 16.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 73
     fi-db-num AT ROW 2.75 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 2
          FGCOLOR 4 
     b-choice-bd AT ROW 2.75 COL 37.5 WIDGET-ID 20
     fi-user-id AT ROW 4 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 4
          FGCOLOR 4 
     fi-user-login AT ROW 6.75 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 6
     t-user-administrator AT ROW 8 COL 27.5 HELP
          "" WIDGET-ID 14
     fi-max-discnt AT ROW 9 COL 25.5 COLON-ALIGNED HELP
          "" WIDGET-ID 10
     t-quest-print AT ROW 10.25 COL 27.5 HELP
          "" WIDGET-ID 16
     fi-user-name AT ROW 5.25 COL 1.5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     SPACE(1.62) SKIP(6.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Логин пользователя"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit WIDGET-ID 100.


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

/* SETTINGS FOR FILL-IN fi-db-num IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.user-login.db-num EXP-SIZE                       */
/* SETTINGS FOR FILL-IN fi-max-discnt IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.user-login.max-discnt EXP-SIZE                   */
/* SETTINGS FOR FILL-IN fi-user-id IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.user-login.user-id EXP-SIZE                      */
/* SETTINGS FOR FILL-IN fi-user-login IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.user-login.user-login EXP-SIZE                   */
/* SETTINGS FOR TOGGLE-BOX t-quest-print IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.user-login.quest-print EXP-SIZE                  */
/* SETTINGS FOR TOGGLE-BOX t-user-administrator IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-login.user-administrator EXP-SIZE */
ASSIGN 
       t-user-administrator:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Логин пользователя */
DO:
  run update-record in this-procedure
    no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Логин пользователя */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-choice-bd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-choice-bd Dialog-Frame
ON CHOOSE OF b-choice-bd IN FRAME Dialog-Frame /* Выбор */
DO:
  define variable ri as recid no-undo.
  define buffer buf_db for ub.db.

  run adm/dbs.w (
                input parparentproc
               ,input {&lookup}
               ,output ri) no-error.
  if ri <> ?
  then do:
    find buf_db where recid (buf_db) = ri .
    display
    buf_db.db-num @ fi-db-num
    with frame {&frame-name}.
    assign
       fi-db-num = buf_db.db-num.
  end.
  else do:
    assign
      fi-db-num = ?
      p-db-num  = ?.
    display
    ? @ fi-db-num
    with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME fi-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-db-num Dialog-Frame
ON VALUE-CHANGED OF fi-db-num IN FRAME Dialog-Frame /* Номер БД */
DO:
    assign
        fi-db-num
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME fi-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-db-num Dialog-Frame
ON LEAVE OF fi-db-num IN FRAME Dialog-Frame /* Название */
DO:
  define buffer buf_db for ub.db.
  if fi-db-num <> ? and
   not can-find (buf_db where buf_db.db-num = input frame {&frame-name} fi-db-num no-lock ) then do:
    message "Нет БД с таким номером."
            view-as alert-box error.
    assign
      fi-db-num = ?
      p-db-num  = ?.
    display
    ? @ fi-db-num
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
     

  RUN enable_UI.

  run display-data in this-procedure .

  run enable-fields in this-procedure .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-data Dialog-Frame 
PROCEDURE display-data :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_user-account for ub.user-account .

  do
  on error undo, return error return-value
  :
    /*
    find first buf_user-account no-lock
      where buf_user-account.user-id = p-user-id
      no-error .
    if not available buf_user-account
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден пользователь" skip
        "Идентификатор пользователя" p-user-id skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    */
    do with frame {&frame-name}
    :

      assign
        fi-user-id            = p-user-id
        fi-user-login         = p-user-login
        t-user-administrator  = p-user-administrator
        fi-max-discnt         = p-max-discnt
        t-quest-print         = p-quest-print
      .
      if p-db-num ne ? then do:
        fi-db-num = p-db-num .
      end.  
      display
        fi-db-num    when p-db-num ne ? 
        fi-user-id
        fi-user-login
        fi-max-discnt
        t-quest-print
        with frame {&frame-name} .
        b-choice-bd:visible = p-db-num ne ?.
        fi-db-num:visible   = p-db-num ne ?.
    end.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-fields Dialog-Frame 
PROCEDURE enable-fields :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if p-input-mode = {&update}
      then do:
        assign
          fi-user-login        :sensitive = true
          t-user-administrator :sensitive = true
          fi-max-discnt        :sensitive = true
          t-quest-print        :sensitive = true
        .
      end.
      else do:
        assign
          fi-user-login        :sensitive = false
          t-user-administrator :sensitive = false
          fi-max-discnt        :sensitive = false
          t-quest-print        :sensitive = false
          t-user-administrator :HIDDEN    = false
        .
      end.

    end.
  end.
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
  DISPLAY fi-db-num fi-user-id fi-user-login fi-max-discnt t-quest-print 
          fi-user-name 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-db-num b-choice-bd fi-user-name 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-record Dialog-Frame 
PROCEDURE update-record :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_user-login for ub.user-login .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :

      assign
        fi-user-login
/*        t-user-administrator*/
        fi-max-discnt
        t-quest-print
      .

      if fi-user-login = ?
      or fi-user-login = '':U
      then do:
        message
          "Необходимо ввести логин пользователя" skip
          view-as alert-box error .
        apply 'entry':U to fi-user-login .
        undo, return error return-value .
      end.

      if     p-db-num  ne ?
         and fi-db-num eq ?
      then do:
        message
          "Необходимо ввести номер базы данных" skip
          view-as alert-box error .
        apply 'entry':U to fi-db-num .
        undo, return error return-value .
      end.

      find first buf_user-login no-lock
        where buf_user-login.db-num = fi-db-num
          and buf_user-login.user-login = fi-user-login
          and buf_user-login.user-id <> p-user-id
        no-error .
      if available buf_user-login
      then do:
        message
          "У другого пользователя уже существует логин" fi-user-login skip
          "для БД" fi-db-num SKIP
          view-as alert-box error .
        apply 'entry':U to fi-user-login .
        undo, return error return-value .
      end.

      /*
      find first buf_user-login no-lock
        where buf_user-login.db-num = fi-db-num
          and buf_user-login.user-id = p-user-id
        no-error .

      if available buf_user-login and p-user-login =  "" or
         available buf_user-login and p-user-login <> ""  and p-db-num <> fi-db-num
      then do:
        message
          "У пользователя уже существует логин" buf_user-login.user-login skip
          "для БД" fi-db-num SKIP
          view-as alert-box error .
        apply 'entry':U to fi-user-login .
        undo, return error return-value .
      end.
      */

      assign
        v-update-data               = true
        v-output-user-login         = fi-user-login
        v-output-user-administrator = t-user-administrator
        v-output-max-discnt         = fi-max-discnt
        v-output-quest-print        = t-quest-print
        p-db-num                    = fi-db-num
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

