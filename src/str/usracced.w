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

Редактирование записи пользователь (user-account)

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/19/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-user-id      as character no-undo .
define input  parameter p-mode         as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/color.i    }
{ gbl/getcntxt.i def }

/* Local Variable Definitions ---                                       */
define variable v-user-id as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help fi-user-id
&Scoped-Define DISPLAYED-OBJECTS fi-user-id

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

DEFINE VARIABLE fi-company LIKE ub.user-account.company
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-department LIKE ub.user-account.department
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-e-mail LIKE ub.user-account.e-mail
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-first-name LIKE ub.user-account.first-name
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-internal-phone-number LIKE ub.user-account.internal-phone-number
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-last-name LIKE ub.user-account.last-name
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-mobile-phone-number LIKE ub.user-account.mobile-phone-number
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-phone-number LIKE ub.user-account.phone-number
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-position LIKE ub.user-account.position
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-room LIKE ub.user-account.room
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-second-name LIKE ub.user-account.second-name
     VIEW-AS FILL-IN
     SIZE 33 BY 1 NO-UNDO.

DEFINE VARIABLE fi-user-id AS CHARACTER FORMAT "X(15)":U
     LABEL "Пользователь"
      VIEW-AS TEXT
     SIZE 16.5 BY .67
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 81
     fi-last-name AT ROW 4 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 4
     fi-first-name AT ROW 5.27 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 10
     fi-second-name AT ROW 6.77 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 8
     fi-position AT ROW 8.27 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 12
     fi-room AT ROW 9.77 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 14
     fi-company AT ROW 11 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 16
     fi-department AT ROW 12.27 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 18
     fi-e-mail AT ROW 13.5 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 20
     fi-phone-number AT ROW 14.77 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 22
     fi-internal-phone-number AT ROW 16 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 24
     fi-mobile-phone-number AT ROW 17.5 COL 22 COLON-ALIGNED HELP
          "" WIDGET-ID 26
     fi-user-id AT ROW 2.77 COL 22 COLON-ALIGNED WIDGET-ID 2
     SPACE(59.37) SKIP(16.38)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Редактирование пользователя"
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

/* SETTINGS FOR FILL-IN fi-company IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.company EXP-SIZE         */
/* SETTINGS FOR FILL-IN fi-department IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.department EXP-SIZE      */
/* SETTINGS FOR FILL-IN fi-e-mail IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.e-mail EXP-SIZE          */
/* SETTINGS FOR FILL-IN fi-first-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.first-name EXP-SIZE      */
/* SETTINGS FOR FILL-IN fi-internal-phone-number IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.internal-phone-number EXP-SIZE */
/* SETTINGS FOR FILL-IN fi-last-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.last-name EXP-SIZE       */
/* SETTINGS FOR FILL-IN fi-mobile-phone-number IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.mobile-phone-number      */
/* SETTINGS FOR FILL-IN fi-phone-number IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.phone-number EXP-SIZE    */
/* SETTINGS FOR FILL-IN fi-position IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.position EXP-SIZE        */
/* SETTINGS FOR FILL-IN fi-room IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.room EXP-SIZE            */
/* SETTINGS FOR FILL-IN fi-second-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE LIKE = ub.user-account.second-name EXP-SIZE     */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Редактирование пользователя */
DO:
  /*
  IF fi-last-name :SCREEN-VALUE = "":U
  OR fi-last-name :SCREEN-VALUE = ?
  THEN DO:
       MESSAGE "Введите фамилию"
       VIEW-AS ALERT-BOX.
       RETURN NO-APPLY.
  END.
  */
  IF v-user-id = "":U THEN DO
  ON ERROR UNDO, RETURN NO-APPLY
  :
     /*
     r u n str/usracccr.p ( input  v-cntxt-db-num
                        , output v-user-id
                        ) no-error.
     */
     if error-status :error
     then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при вызове процедуры" 'str/usracccr.p':U skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
       undo, return no-apply .
     end.

  END.
  run update-info in this-procedure
    no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Редактирование пользователя */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME fi-last-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-last-name Dialog-Frame
ON LEAVE OF fi-last-name IN FRAME Dialog-Frame /* Фамилия */
DO:
  IF fi-last-name :SCREEN-VALUE = "":U
  OR fi-last-name :SCREEN-VALUE = ?
  THEN DO:
     MESSAGE "Введите фамилию"
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
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

  { gbl/getcntxt.i get }
  ASSIGN
     v-user-id = p-user-id
  .

  define buffer buf_lock_user-account for ub.user-account .

  case p-mode :
    when {&update}
    then do:
      /* блокировка пользователя */
      do transaction
      on error undo, return error return-value
      :
         IF v-user-id <> "":U THEN DO:
            find first buf_lock_user-account exclusive-lock
            where buf_lock_user-account.user-id = v-user-id
            no-error
            no-wait
            .
            if not available buf_lock_user-account
            then do:
            if locked(buf_lock_user-account)
            then do:
               message
                  "Редактирование пользователя" skip
                  "" skip
                  "Запись захвачена другим пользователем или процессом" skip
                  "Невозможно редактировать запись" skip
                  "Идентификатор пользователя" v-user-id skip
                  view-as alert-box error .
               undo, return error return-value .
            end.
            else do:
               message
                  vss-workfile vss-revision vss-description skip
                  "Ошибка задания входных параметров" skip
                  "Не найдена запись пользователя" skip
                  "Идентификатор пользователя" v-user-id skip
                  view-as alert-box error .
               undo, return error return-value .
            end.
            end.
         end.
      end.
    end.
    when {&lookup}
    then do:
      find first buf_lock_user-account no-lock
        where buf_lock_user-account.user-id = v-user-id
        no-error .
      if not available buf_lock_user-account
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найдена запись пользователя" skip
          "Идентификатор пользователя" v-user-id skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестное значение переменной" 'p-mode':U skip
        'p-mode':U p-mode skip
        view-as alert-box error .
      undo, return error return-value .
    end.

  end case .

  RUN enable_UI.
  IF AVAILABLE buf_lock_user-account THEN DO:
     run display-info in this-procedure
        (buffer buf_lock_user-account
        ) .
  END.

  run configure-view in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE configure-view Dialog-Frame
PROCEDURE configure-view :
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
      case p-mode
      :
        when {&update}
        then do:
          assign
            fi-last-name             :sensitive = true
            fi-last-name             :fgcolor   = black_color
            fi-first-name            :sensitive = true
            fi-first-name            :fgcolor   = black_color
            fi-second-name           :sensitive = true
            fi-second-name           :fgcolor   = black_color
            fi-position              :sensitive = true
            fi-position              :fgcolor   = black_color
            fi-room                  :sensitive = true
            fi-room                  :fgcolor   = black_color
            fi-company               :sensitive = true
            fi-company               :fgcolor   = black_color
            fi-department            :sensitive = true
            fi-department            :fgcolor   = black_color
            fi-e-mail                :sensitive = true
            fi-e-mail                :fgcolor   = black_color
            fi-phone-number          :sensitive = true
            fi-phone-number          :fgcolor   = black_color
            fi-internal-phone-number :sensitive = true
            fi-internal-phone-number :fgcolor   = black_color
            fi-mobile-phone-number   :sensitive = true
            fi-mobile-phone-number   :fgcolor   = black_color
          .
          apply 'entry':u to fi-last-name .
        end.
        when {&lookup}
        then do:
          assign
            fi-last-name             :sensitive = false
            fi-last-name             :fgcolor   = brown_color
            fi-first-name            :sensitive = false
            fi-first-name            :fgcolor   = brown_color
            fi-second-name           :sensitive = false
            fi-second-name           :fgcolor   = brown_color
            fi-position              :sensitive = false
            fi-position              :fgcolor   = brown_color
            fi-room                  :sensitive = false
            fi-room                  :fgcolor   = brown_color
            fi-company               :sensitive = false
            fi-company               :fgcolor   = brown_color
            fi-department            :sensitive = false
            fi-department            :fgcolor   = brown_color
            fi-e-mail                :sensitive = false
            fi-e-mail                :fgcolor   = brown_color
            fi-phone-number          :sensitive = false
            fi-phone-number          :fgcolor   = brown_color
            fi-internal-phone-number :sensitive = false
            fi-internal-phone-number :fgcolor   = brown_color
            fi-mobile-phone-number   :sensitive = false
            fi-mobile-phone-number   :fgcolor   = brown_color
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестное значение переменной" 'p-mode':U skip
            'p-mode':U p-mode skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
  end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-info Dialog-Frame
PROCEDURE display-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define parameter buffer buf_user-account for ub.user-account .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      assign
        fi-user-id :screen-value = v-user-id
      .
      assign
        fi-user-id :modified = false
      .

      assign
        fi-last-name :screen-value = string(buf_user-account.last-name
                                           ,fi-last-name :format
                                           )
        fi-last-name :modified     = false
      .
      assign
        fi-first-name :screen-value = string(buf_user-account.first-name
                                           ,fi-first-name :format
                                           )
        fi-first-name :modified     = false
      .
      assign
        fi-second-name :screen-value = string(buf_user-account.second-name
                                           ,fi-second-name :format
                                           )
        fi-second-name :modified     = false
      .
      assign
        fi-position :screen-value = string(buf_user-account.position
                                           ,fi-position :format
                                           )
        fi-position :modified     = false
      .
      assign
        fi-room :screen-value = string(buf_user-account.room
                                           ,fi-room :format
                                           )
        fi-room :modified     = false
      .
      assign
        fi-company :screen-value = string(buf_user-account.company
                                           ,fi-company :format
                                           )
        fi-company :modified     = false
      .
      assign
        fi-department :screen-value = string(buf_user-account.department
                                           ,fi-department :format
                                           )
        fi-department :modified     = false
      .
      assign
        fi-e-mail :screen-value = string(buf_user-account.e-mail
                                           ,fi-e-mail :format
                                           )
        fi-e-mail :modified     = false
      .
      assign
        fi-phone-number :screen-value = string(buf_user-account.phone-number
                                           ,fi-phone-number :format
                                           )
        fi-phone-number :modified     = false
      .
      assign
        fi-internal-phone-number :screen-value = string(buf_user-account.internal-phone-number
                                           ,fi-internal-phone-number :format
                                           )
        fi-internal-phone-number :modified     = false
      .
      assign
        fi-mobile-phone-number :screen-value = string(buf_user-account.mobile-phone-number
                                           ,fi-mobile-phone-number :format
                                           )
        fi-mobile-phone-number :modified     = false
      .
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
  DISPLAY fi-user-id
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help fi-user-id
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-info Dialog-Frame
PROCEDURE update-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_user-account for ub.user-account .

  do
  on error undo, return error return-value
  :
    if p-mode = {&update}
    then do:

      do transaction
      on error undo, return error return-value
      :
        find first buf_user-account exclusive-lock
          where buf_user-account.user-id = v-user-id
          no-error .
        if not available buf_user-account
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись пользователь (user-account)" skip
            "Идентификатор пользователя" v-user-id skip
            view-as alert-box error .
          undo, return error return-value .
        end.

        do with frame {&frame-name}
        :
          if fi-last-name :modified = true
          then do:
            assign
              buf_user-account.last-name  = fi-last-name :screen-value
            .
          end.

          if fi-first-name :modified = true
          then do:
            assign
              buf_user-account.first-name  = fi-first-name :screen-value
            .
          end.

          if fi-second-name :modified = true
          then do:
            assign
              buf_user-account.second-name  = fi-second-name :screen-value
            .
          end.

          if fi-position :modified = true
          then do:
            assign
              buf_user-account.position = fi-position :screen-value
            .
          end.

          if fi-room :modified = true
          then do:
            assign
              buf_user-account.room = fi-room :screen-value
            .
          end.

          if fi-company :modified = true
          then do:
            assign
              buf_user-account.company = fi-company :screen-value
            .
          end.

          if fi-department :modified = true
          then do:
            assign
              buf_user-account.department = fi-department :screen-value
            .
          end.

          if fi-e-mail :modified = true
          then do:
            assign
              buf_user-account.e-mail = fi-e-mail :screen-value
            .
          end.

          if fi-phone-number :modified = true
          then do:
            assign
              buf_user-account.phone-number = fi-phone-number :screen-value
            .
          end.

          if fi-internal-phone-number :modified = true
          then do:
            assign
              buf_user-account.internal-phone-number = fi-internal-phone-number :screen-value
            .
          end.

          if fi-mobile-phone-number :modified = true
          then do:
            assign
              buf_user-account.mobile-phone-number = fi-mobile-phone-number :screen-value
            .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
