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

Выбор контекста

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc                  as widget-handle no-undo .
define input  parameter p-cntxt-db-num                 as integer   no-undo .
define input  parameter p-action-head-code             as integer   no-undo .
define input  parameter p-cntxt-user-id                as character no-undo .
define input  parameter p-cntxt-menu-code              as integer   no-undo .
define input  parameter p-cntxt-menu-group-code        as integer   no-undo .
define input  parameter p-cntxt-level                  as character no-undo .
define input  parameter p-cntxt-host-code-obj          as integer   no-undo .
define input  parameter p-cntxt-obj-type               as character no-undo .
define input  parameter p-cntxt-obj-code               as integer   no-undo .
define output parameter p-select-cntxt-menu-code       as integer   no-undo .
define output parameter p-select-cntxt-menu-group-code as integer   no-undo .
define output parameter p-select-cntxt-level           as character no-undo .
define output parameter p-select-cntxt-host-code-obj   as integer   no-undo .
define output parameter p-select-cntxt-obj-type        as character no-undo .
define output parameter p-select-cntxt-obj-code        as integer   no-undo .
define output parameter p-user-select                  as logical   no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор контекста".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ gbl/userobjs.i }
{ gbl/userhsts.i }

define variable v-select-cntxt-menu-group-code as integer   no-undo .
define variable v-select-cntxt-level           as character no-undo .
define variable v-select-cntxt-host-code-obj   as integer   no-undo .
define variable v-select-cntxt-obj-type        as character no-undo .
define variable v-select-cntxt-obj-code        as integer   no-undo .
/*
  define variable v-host-show as logical   no-undo .
  define variable v-obj-show  as logical   no-undo .
*/
define temp-table temp-menu-group-id no-undo
  field menu-group-id as character
  field item-value    as character

  index xpk is primary unique menu-group-id
  index xie1 item-value
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-sel b-help cb-menu-group-id ~
rs-cntxt-level r-sel-host r-sel-obj fi-host-label fi-host-name ~
fi-host-description fi-obj-label fi-obj-name fi-obj-description
&Scoped-Define DISPLAYED-OBJECTS cb-menu-group-id rs-cntxt-level ~
fi-host-label fi-host-name fi-host-description fi-obj-label fi-obj-name ~
fi-obj-description

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel AUTO-GO
     LABEL "&Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON r-sel-host
     LABEL "Выбор фирмы"
     SIZE 19.5 BY .88 TOOLTIP "Выбор фирмы".

DEFINE BUTTON r-sel-obj
     LABEL "Выбор объекта"
     SIZE 19.5 BY .88 TOOLTIP "Выбор объекта".

DEFINE VARIABLE cb-menu-group-id AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 52 BY 1 NO-UNDO.

DEFINE VARIABLE fi-host-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-host-label AS CHARACTER FORMAT "X(256)":U INITIAL "Фирма:"
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE fi-host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj-description AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 36.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-obj-label AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 8.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 9.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-cntxt-level AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
/*          "Без фирмы, объекта", 1,*/
"Только фирма", 2,
"Фирма и объект", 3
     SIZE 22 BY 5 /*7.5*/
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-sel AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 61
     cb-menu-group-id AT ROW 2.5 COL 1 COLON-ALIGNED NO-LABEL
     rs-cntxt-level AT ROW 7 /*4.25*/ COL 3 NO-LABEL
     r-sel-host AT ROW 7.63 COL 51.13
     r-sel-obj AT ROW 10.13 COL 51.25
     fi-host-label AT ROW 7.75 COL 24 COLON-ALIGNED NO-LABEL
     fi-host-name AT ROW 7.75 COL 32.5 COLON-ALIGNED NO-LABEL
     fi-host-description AT ROW 8.79 COL 32.5 COLON-ALIGNED NO-LABEL
     fi-obj-label AT ROW 10.25 COL 24 COLON-ALIGNED NO-LABEL
     fi-obj-name AT ROW 10.25 COL 32.5 COLON-ALIGNED NO-LABEL
     fi-obj-description AT ROW 11.29 COL 32.5 COLON-ALIGNED NO-LABEL
     SPACE(0.74) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выбор фирмы, объекта, группы меню"
         DEFAULT-BUTTON b-sel CANCEL-BUTTON b-quit.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Выбор фирмы, объекта */
DO:
  run select-context in this-procedure
    no-error .
  if error-status :error then do:
    return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Выбор фирмы, объекта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel Dialog-Frame
ON CHOOSE OF b-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-menu-group-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-menu-group-id Dialog-Frame
ON VALUE-CHANGED OF cb-menu-group-id IN FRAME Dialog-Frame
DO:
  assign
    cb-menu-group-id
    .
  run change-menu-group-id in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sel-host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sel-host Dialog-Frame
ON CHOOSE OF r-sel-host IN FRAME Dialog-Frame /* Выбор фирмы */
DO:
  { gbl/stdbtn.i }

  run proc-sel-host in this-procedure no-error.
   if error-status:error then do:
      return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sel-obj Dialog-Frame
ON CHOOSE OF r-sel-obj IN FRAME Dialog-Frame /* Выбор объекта */
DO:
  { gbl/stdbtn.i }

  run proc-sel-obj in this-procedure no-error.
  if error-status:error then do:
     return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-cntxt-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cntxt-level Dialog-Frame
ON VALUE-CHANGED OF rs-cntxt-level IN FRAME Dialog-Frame
DO:
  run update-cntxt-level in this-procedure
  (INPUT INTEGER(rs-cntxt-level:screen-value IN FRAME Dialog-Frame) )
  no-error.
  if error-status:error then do:
      display
         rs-cntxt-level
      with frame {&frame-name}.

      run update-cntxt-level in this-procedure (INPUT rs-cntxt-level).

      return no-apply.
  end.
  assign
   rs-cntxt-level
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

assign
  v-select-cntxt-level         = p-cntxt-level
  v-select-cntxt-host-code-obj = p-cntxt-host-code-obj
  v-select-cntxt-obj-type      = p-cntxt-obj-type
  v-select-cntxt-obj-code      = p-cntxt-obj-code
.

  define variable v-check-db-num        as integer   no-undo .
  define variable v-check-user-id       as character no-undo .
  define variable v-check-administrator as logical   no-undo .

    { gbl/usercred.i
      p-cntxt-db-num
      p-cntxt-user-id
      v-check-db-num
      v-check-user-id
      v-check-administrator
      no-error
    }
  IF v-check-administrator then do:
      assign
         rs-cntxt-level:RADIO-BUTTONS =  "Без фирмы объекта,1,Только фирма,2,Фирма и объект,3"
         rs-cntxt-level:ROW = 4.25
         rs-cntxt-level:HEIGHT-CHARS = 7.5
      .
  end.
  else do:
      assign
         rs-cntxt-level:RADIO-BUTTONS =  "Только фирма,2,Фирма и объект,3"
         rs-cntxt-level:ROW = 7
         rs-cntxt-level:HEIGHT-CHARS = 5
         v-select-cntxt-level = if v-select-cntxt-level = {&cntxt-global} then {&cntxt-object} else v-select-cntxt-level
      .
  end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-fields in this-procedure.

  RUN enable_UI.


  run get-default-context in this-procedure .

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
  DISPLAY cb-menu-group-id rs-cntxt-level fi-host-label fi-host-name
          fi-host-description fi-obj-label fi-obj-name fi-obj-description
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-sel b-help cb-menu-group-id rs-cntxt-level r-sel-host
         r-sel-obj fi-host-label fi-host-name fi-host-description fi-obj-label
         fi-obj-name fi-obj-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-default-context Dialog-Frame
PROCEDURE get-default-context :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define buffer buf_temp-menu-group-id for temp-menu-group-id .

  do
  on error undo, return error return-value
  :
    assign
      fi-host-name        = '':U
      fi-host-description = '':U
      fi-obj-name         = '':U
      fi-obj-description  = '':U
    .

    case v-select-cntxt-level
    :
      when {&cntxt-global}
      then do:
        assign
          rs-cntxt-level = 1
        .
        hide
          fi-host-name        in frame {&frame-name}
          fi-host-description in frame {&frame-name}
          r-sel-host          in frame {&frame-name}
          fi-obj-name         in frame {&frame-name}
          fi-obj-description  in frame {&frame-name}
          r-sel-obj           in frame {&frame-name}
          .
        display
          rs-cntxt-level
          with frame {&frame-name} .
      end.
      when {&cntxt-firm}
      then do:
        assign
          rs-cntxt-level = 2
        .
        run set-host-variables in this-procedure
          (input  {&cmp}
          ,input  v-select-cntxt-host-code-obj
          ) .

        hide
          fi-obj-name        in frame {&frame-name}
          fi-obj-description in frame {&frame-name}
          r-sel-obj          in frame {&frame-name}
          .
        display
          rs-cntxt-level
          fi-host-name fi-host-description r-sel-host
          with frame {&frame-name} .
        enable
          r-sel-host
          with frame {&frame-name} .
      end.
      when {&cntxt-object}
      then do:
        assign
          rs-cntxt-level = 3
        .
        run set-host-variables in this-procedure
          (input  {&cmp}
          ,input  v-select-cntxt-host-code-obj
          ) .

        run set-obj-variables in this-procedure
          (input  v-select-cntxt-obj-type
          ,input  v-select-cntxt-obj-code
          ).

        display
          rs-cntxt-level
          fi-host-name fi-host-description r-sel-host
          fi-obj-name fi-obj-description r-sel-obj
          with frame {&frame-name} .
        enable
          r-sel-host
          r-sel-obj
          with frame {&frame-name} .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение конектста" skip
          "Значение контекста" v-select-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .
    run update-cntxt-level in this-procedure (INPUT rs-cntxt-level).
    /*
    run fill-menu-group-list in this-procedure .

    run update-cb-menu-group-id-list-items in this-procedure .
    */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-obj Dialog-Frame
PROCEDURE proc-sel-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-user-select     as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/uobjsone.i
      parparentproc
      p-cntxt-db-num
      p-cntxt-user-id
      v-select-cntxt-host-code-obj
      v-select-cntxt-obj-type
      v-select-cntxt-obj-code
      v-user-select
      v-select-obj-type
      v-select-obj-code
    }

    if v-user-select = true
    then do:
      assign
        v-select-cntxt-obj-type = v-select-obj-type
        v-select-cntxt-obj-code = v-select-obj-code
      .
      { gbl/hostcode.i
        v-select-cntxt-obj-type
        v-select-cntxt-obj-code
        v-select-cntxt-host-code-obj
      }
      run set-host-variables in this-procedure
        (input  {&cmp}
        ,input  v-select-cntxt-host-code-obj
        ) .
      run set-obj-variables in this-procedure
        (input  v-select-cntxt-obj-type
        ,input  v-select-cntxt-obj-code
        ) .

      display
        fi-host-name
        fi-host-description
        fi-obj-name
        fi-obj-description
        with frame {&frame-name} .

      run fill-menu-group-list in this-procedure .

      run update-cb-menu-group-id-list-items in this-procedure .
    end.
    else do:
      return error "Объект не выбран" .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-context Dialog-Frame
PROCEDURE select-context :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    if v-select-cntxt-menu-group-code = 0
    then do:
      message
        "Не задана группа меню" skip
        view-as alert-box error .
      do with frame {&frame-name}
      :
        apply 'entry':u to cb-menu-group-id  .
      end.
      undo, return error return-value .
    end.

    case rs-cntxt-level
    :
      when 1
      then do:
        assign
          p-select-cntxt-level         = {&cntxt-global}
          p-select-cntxt-host-code-obj = 0
          p-select-cntxt-obj-type      = '':u
          p-select-cntxt-obj-code      = 0
        .
      end.
      when 2
      then do:
        if v-select-cntxt-host-code-obj = 0
        then do:
          message
            "Не задана фирма" skip
            view-as alert-box error .
          run proc-sel-host in this-procedure no-error.
            if error-status:error then do:
               return error return-value.
            end.
        end.
        assign
          p-select-cntxt-level         = {&cntxt-firm}
          p-select-cntxt-host-code-obj = v-select-cntxt-host-code-obj
          p-select-cntxt-obj-type      = '':u
          p-select-cntxt-obj-code      = 0
        .
      end.
      when 3
      then do:
        if v-select-cntxt-host-code-obj = 0
        then do:
          message
            "Не задана фирма" skip
            view-as alert-box error .
          run proc-sel-host in this-procedure no-error.
            if error-status:error then do:
               return error return-value.
            end.
        end.
        if v-select-cntxt-obj-type = '':U
        or v-select-cntxt-obj-code = 0
        then do:
          message
            "Не задан объект" skip
            view-as alert-box error .
          run proc-sel-obj in this-procedure no-error.
            if error-status:error then do:
               return error return-value.
            end.
        end.
        assign
          p-select-cntxt-level         = {&cntxt-object}
          p-select-cntxt-host-code-obj = v-select-cntxt-host-code-obj
          p-select-cntxt-obj-type      = v-select-cntxt-obj-type
          p-select-cntxt-obj-code      = v-select-cntxt-obj-code
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной rs-cntxt-level" skip
          "rs-cntxt-level" rs-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    assign
      p-select-cntxt-menu-code       = p-cntxt-menu-code
      p-select-cntxt-menu-group-code = v-select-cntxt-menu-group-code
    .

    define variable v-menu-group-available as logical   no-undo .

    { gbl/usmgrava.i
      p-cntxt-db-num
      p-action-head-code
      p-cntxt-user-id
      p-select-cntxt-menu-code
      p-select-cntxt-menu-group-code
      p-select-cntxt-level
      p-select-cntxt-host-code-obj
      p-select-cntxt-obj-type
      p-select-cntxt-obj-code
      v-menu-group-available
    }

    if v-menu-group-available <> true
    then do:
      /* todo - вывести более понятное для пользователей сообщение */
      message
        "Недоступно выбранная группа пунктов меню для выбранного контекста" skip
        "База данных" p-cntxt-db-num skip
        "Идентификатор пользователя" p-cntxt-user-id skip
        "Код группы пунктов меню" v-select-cntxt-menu-group-code skip
        "Уровень контекст" p-cntxt-level skip
        "Код фирмы" p-cntxt-host-code-obj skip
        "Объект" p-cntxt-obj-type p-cntxt-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    assign
      p-user-select = true
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-host-state Dialog-Frame
PROCEDURE set-host-state :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-host-show as logical   no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-host-variables Dialog-Frame
PROCEDURE set-host-variables :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-host-name        = substitute('&1 &2':U
                                        ,buf_clients.obj-type
                                        ,buf_clients.obj-code
                                        )
        fi-host-description = buf_clients.obj-name
      .
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-obj-state Dialog-Frame
PROCEDURE set-obj-state :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-context as integer   no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      case p-context
      :
      when 2
      then do:
        /* {&cntxt-firm} */
        assign
          fi-host-label       :visible   = true
          fi-host-name        :visible   = true
          fi-host-description :visible   = true
          fi-obj-label        :visible   = false
          fi-obj-name         :visible   = false
          fi-obj-description  :visible   = false
          r-sel-obj           :sensitive = false
          r-sel-obj           :visible   = false
          r-sel-host          :sensitive = true
          r-sel-host          :visible   = true
        .
      end.
      when 3
      then do:
        /* {&cntxt-object} */
        assign
          fi-host-label       :visible   = true
          fi-host-name        :visible   = true
          fi-host-description :visible   = true
          fi-obj-label        :visible   = true
          fi-obj-name         :visible   = true
          fi-obj-description  :visible   = true
          r-sel-obj           :visible   = true
          r-sel-obj           :sensitive = true
          r-sel-host          :sensitive = false
          r-sel-host          :visible   = false
        .
      end.
      otherwise do:
        assign
          fi-host-label       :visible   = false
          fi-host-name        :visible   = false
          fi-host-description :visible   = false
          fi-obj-label        :visible   = false
          fi-obj-name         :visible   = false
          fi-obj-description  :visible   = false
          r-sel-obj           :sensitive = false
          r-sel-obj           :visible   = false
          r-sel-host          :sensitive = false
          r-sel-host          :visible   = false
        .
      end.
      end case.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-obj-variables Dialog-Frame
PROCEDURE set-obj-variables :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-obj-name        = substitute('&1 &2':U
                                        ,buf_clients.obj-type
                                        ,buf_clients.obj-code
                                        )
        fi-obj-description = buf_clients.obj-name
      .
    end.
    else do:
      assign
        fi-obj-name        = '':U
        fi-obj-description = '':U
      .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cntxt-level Dialog-Frame
PROCEDURE update-cntxt-level :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-cntxt-level as integer .


  do
  on error undo, return error return-value
  :
    /*
    case p-cntxt-level
    :
      when 1
      then do:
        /* {&cntxt-global} */
        assign
          v-host-show = false
          v-obj-show  = false
        .
      end.
      when 2
      then do:
        /* {&cntxt-firm} */
        assign
          v-host-show = true
          v-obj-show  = false
        .
      end.
      when 3
      then do:
        /* {&cntxt-object} */
        assign
          v-host-show = true
          v-obj-show  = true
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной контекста" skip
          "p-cntxt-level" p-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    run set-host-state in this-procedure
      (input  v-host-show
      ) .
    */

    run set-obj-state in this-procedure
      (input p-cntxt-level
      ) .

    case p-cntxt-level
    :
      when 1
      then do:
        /* {&cntxt-global} */
        /* глобальный контекст */
        /* ничего не надо выбирать */
      end.
      when 2
      then do:
        /* {&cntxt-firm} */
        /* контекст фирма - если фирма не задана, то открываем справочник выбора фирмы */
        if v-select-cntxt-host-code-obj = 0
        then do:
          run proc-sel-host in this-procedure no-error.
            if error-status:error then do:
               return error return-value.
            end.
        end.
      end.
      when 3
      then do:
        /* {&cntxt-object} */
        /* контекст объект - если фирма не задана, то открываем справочник выбора объекта */
        if v-select-cntxt-obj-type = '':U
        or v-select-cntxt-obj-code = 0
        then do:
          run proc-sel-obj in this-procedure no-error.
            if error-status:error then do:
               return error return-value.
            end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной контекста" skip
          "p-cntxt-level" p-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    run fill-menu-group-list in this-procedure .

    run update-cb-menu-group-id-list-items in this-procedure .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-menu-group-id W-Win
PROCEDURE change-menu-group-id :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-menu-group-id for temp-menu-group-id .
    find first buf_temp-menu-group-id
      where buf_temp-menu-group-id.item-value = cb-menu-group-id
      .
    assign
      v-select-cntxt-menu-group-code = integer(buf_temp-menu-group-id.menu-group-id)
    .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-host W-Win
PROCEDURE proc-sel-host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-user-select      as logical   no-undo .
  define variable v-select-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    { gbl/uhstsone.i
      parparentproc
      p-cntxt-db-num
      p-cntxt-user-id
      v-select-cntxt-host-code-obj
      v-user-select
      v-select-host-code
    }

    if  v-user-select      = true
    and v-select-host-code <> v-select-cntxt-host-code-obj
    then do:
      assign
        v-select-cntxt-host-code-obj = v-select-host-code
        v-select-cntxt-obj-type      = '':U
        v-select-cntxt-obj-code      = 0
      .

      run set-host-variables in this-procedure
        (input  {&cmp}
        ,input  v-select-cntxt-host-code-obj
        ) .
      run set-obj-variables in this-procedure
        (input  v-select-cntxt-obj-type
        ,input  v-select-cntxt-obj-code
        ) .

      display
        fi-host-name
        fi-host-description
        fi-obj-name
        fi-obj-description
        with frame {&frame-name} .

      run fill-menu-group-list in this-procedure .

      run update-cb-menu-group-id-list-items in this-procedure .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-menu-group-list W-Win
PROCEDURE fill-menu-group-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-local-number as integer   no-undo .
  define variable v-menu-name    as character no-undo .

  define buffer buf_menu-group for ub.menu-group .
  define buffer buf_temp-menu-group-id for temp-menu-group-id .
  define buffer buf_clients      for ub.clients.

  define variable v-check-menu-group-context as character no-undo .
  define variable v-check-host-code          as integer   no-undo .
  define variable v-check-obj-type           as character no-undo .
  define variable v-check-obj-code           as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-local-number = 0
    .

    for each buf_temp-menu-group-id
    on error undo, return error return-value
    :
      delete buf_temp-menu-group-id .
    end.

    case INTEGER(rs-cntxt-level:screen-value in frame {&frame-name})
    :
      when 1
      then do:
        assign
          v-check-menu-group-context = {&cntxt-global}
          v-check-host-code          = 0
          v-check-obj-type           = '':U
          v-check-obj-code           = 0
        .
      end.
      when 2
      then do:
        assign
          v-check-menu-group-context = {&cntxt-firm}
          v-check-host-code          = v-select-cntxt-host-code-obj
          v-check-obj-type           = '':U
          v-check-obj-code           = 0
        .
      end.
      when 3
      then do:
        assign
          v-check-menu-group-context = {&cntxt-object}
          v-check-host-code          = v-select-cntxt-host-code-obj
          v-check-obj-type           = v-select-cntxt-obj-type
          v-check-obj-code           = v-select-cntxt-obj-code
        .
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестное значение переменной контекста" skip
          "rs-cntxt-level" rs-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    for each buf_menu-group
      where buf_menu-group.menu-code = p-cntxt-menu-code
    on error undo, return error return-value
    :
      define variable v-menu-group-available as logical   no-undo .
      { gbl/chkmngr.i
        buf_menu-group.menu-group-id
        v-check-menu-group-context
        v-check-obj-type
        v-check-obj-code
        p-cntxt-db-num
        v-menu-group-available
        no-error
      }
      if error-status :error
      then do:
         assign
            v-menu-group-available = false
         .
      end.
      if v-menu-group-available then do:
         { gbl/usmgrava.i
           p-cntxt-db-num
           p-action-head-code
           p-cntxt-user-id
           buf_menu-group.menu-code
           buf_menu-group.menu-group-code
           v-check-menu-group-context
           v-check-host-code
           v-check-obj-type
           v-check-obj-code
           v-menu-group-available
         }
      end.

      if v-menu-group-available = true
      then do:
        assign
          v-local-number = v-local-number + 1
        .

        assign
          v-menu-name = replace(buf_menu-group.menu-group-name, ',':U, '':U)
          v-menu-name = replace(v-menu-name, '&':U, '':U)
        .
        create buf_temp-menu-group-id .
        assign
          buf_temp-menu-group-id.menu-group-id  = string(buf_menu-group.menu-group-code)
          buf_temp-menu-group-id.item-value     = v-menu-name
        .
      end.
    end.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cb-menu-group-id-list-items W-Win
PROCEDURE update-cb-menu-group-id-list-items :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-list-items as character no-undo .

  define buffer buf_temp-menu-group-id for temp-menu-group-id .

  do
  on error undo, return error return-value
  :
    assign
      v-list-items = '':U
    .

    for each buf_temp-menu-group-id
    :
      assign
        v-list-items = v-list-items
                     + (if v-list-items <> '':U then ',':U else '':U)
                     + buf_temp-menu-group-id.item-value
      .
    end.

    do with frame {&frame-name}
    :
      assign
        cb-menu-group-id :list-items = v-list-items
      .

      if v-list-items <> '':U
      then do:
        find first buf_temp-menu-group-id
          where buf_temp-menu-group-id.menu-group-id = string(p-cntxt-menu-group-code)
          no-error .
        if available buf_temp-menu-group-id
        then do:
          assign
            v-select-cntxt-menu-group-code = integer(buf_temp-menu-group-id.menu-group-id)
            cb-menu-group-id               = buf_temp-menu-group-id.item-value
          .
        end.
        else do:
          assign
            cb-menu-group-id = entry(1, cb-menu-group-id :list-items)
          .
          run change-menu-group-id in this-procedure .
        end.

        display
          cb-menu-group-id
          with frame {&frame-name} .
      end.
    end.
  end.
END PROCEDURE.

/*==========================================================================*/
procedure init-fields :

do
on error undo, return error
:
  IF v-check-administrator then do:
      assign
         rs-cntxt-level = 1
      .
  end.
  else do:
      assign
         rs-cntxt-level = 2
      .
  end.
end.
end procedure. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME