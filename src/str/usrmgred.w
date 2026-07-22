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

Редактирование пользовательской группы меню

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input  parameter parparentproc               as widget-handle no-undo .
define input  parameter p-db-num                    as integer   no-undo .
define input  parameter p-user-id                   as character no-undo .
define input  parameter p-menu-code                 as integer   no-undo .
define input  parameter p-menu-group-code           as integer   no-undo .
define input  parameter p-menu-group-context        as character no-undo .
define input  parameter p-host-code                 as integer   no-undo .
define input  parameter p-obj-type                  as character no-undo .
define input  parameter p-obj-code                  as integer   no-undo .
define output parameter p-update-data               as logical   no-undo .
define output parameter p-output-menu-code          as integer   no-undo .
define output parameter p-output-menu-group-code    as integer   no-undo .
define output parameter p-output-menu-group-context as character no-undo .
define output parameter p-output-host-code          as integer   no-undo .
define output parameter p-output-obj-type           as character no-undo .
define output parameter p-output-obj-code           as integer   no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование пользовательской группы меню".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }

define variable v-select-menu-group-code    as integer   no-undo .
define variable v-select-menu-group-context as character no-undo .
define variable v-select-host-code          as integer   no-undo .
define variable v-select-obj-type           as character no-undo .
define variable v-select-obj-code           as integer   no-undo .

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

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help cb-menu-group-id ~
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

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
          "Без фирмы, объекта", 1,
"Только фирма", 2,
"Фирма и объект", 3
     SIZE 22 BY 7.5
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1 WIDGET-ID 2
     b-quit AT ROW 1 COL 11 WIDGET-ID 4
     b-help AT ROW 1 COL 61
     cb-menu-group-id AT ROW 2.5 COL 1 COLON-ALIGNED NO-LABEL
     rs-cntxt-level AT ROW 4.25 COL 3 NO-LABEL
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
         TITLE "Выбор фирмы, объекта".


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

  run proc-sel-host in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-sel-obj Dialog-Frame
ON CHOOSE OF r-sel-obj IN FRAME Dialog-Frame /* Выбор объекта */
DO:
  { gbl/stdbtn.i }

  run proc-sel-obj in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-cntxt-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-cntxt-level Dialog-Frame
ON VALUE-CHANGED OF rs-cntxt-level IN FRAME Dialog-Frame
DO:
  assign
    rs-cntxt-level
  .
  run update-cntxt-level in this-procedure .
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
  v-select-menu-group-context = p-menu-group-context
  v-select-host-code          = p-host-code
  v-select-obj-type           = p-obj-type
  v-select-obj-code           = p-obj-code
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN enable_UI.

  run get-default-context in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-menu-group-id Dialog-Frame
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
      v-select-menu-group-code = integer(buf_temp-menu-group-id.menu-group-id)
    .
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
  ENABLE b-exit b-quit b-help cb-menu-group-id rs-cntxt-level r-sel-host
         r-sel-obj fi-host-label fi-host-name fi-host-description fi-obj-label
         fi-obj-name fi-obj-description
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-menu-group-list Dialog-Frame
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

    for each buf_menu-group
      where buf_menu-group.menu-code = p-menu-code
    on error undo, return error return-value
    :
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

    case v-select-menu-group-context
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
          ,input  v-select-host-code
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
          ,input  v-select-host-code
          ) .

        run set-obj-variables in this-procedure
          (input  v-select-obj-type
          ,input  v-select-obj-code
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
          "Значение контекста" v-select-menu-group-context skip
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-sel-host Dialog-Frame
PROCEDURE proc-sel-host :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-user-select      as logical   no-undo .
  define variable v-choose-host-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    /* todo выбор фирмы */

    if  v-user-select      = true
    and v-select-host-code <> v-choose-host-code
    then do:
      assign
        v-select-host-code = v-choose-host-code
        v-select-obj-type  = '':U
        v-select-obj-code  = 0
      .

      run set-host-variables in this-procedure
        (input  {&cmp}
        ,input  v-select-host-code
        ) .
      run set-obj-variables in this-procedure
        (input  v-select-obj-type
        ,input  v-select-obj-code
        ) .

      display
        fi-host-name
        fi-host-description
        fi-obj-name
        fi-obj-description
        with frame {&frame-name} .
    end.
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

  define variable v-rid-list as character no-undo .

  define buffer buf_clients for ub.clients .

  do
  on error undo, return error return-value
  :
    run ref/cli-all.w
      (input  parparentproc
      ,input  'b-sel':U
      ,input  (if v-cntxt-db-num = 0 then {&g___object} else "db":U)
      ,input  {&all}
      ,input  {&current}
      ,input  ?
      ,input  ',,,,,,NO,,'
      ,input  'lock-cli-type':U
      ,output v-rid-list
      ).
   if v-rid-list = '':U
   then do:
     return.
   end.
   else do:
    find first buf_clients no-lock
      where recid(buf_clients) = integer(entry(1, v-rid-list)).
      assign
        v-select-obj-type = buf_clients.obj-type
        v-select-obj-code = buf_clients.obj-code
      .
      { gbl/hostcode.i
        v-select-obj-type
        v-select-obj-code
        v-select-host-code
      }
      run set-host-variables in this-procedure
        (input  {&cmp}
        ,input  v-select-host-code
        ) .
      run set-obj-variables in this-procedure
        (input  v-select-obj-type
        ,input  v-select-obj-code
        ) .

      display
        fi-host-name
        fi-host-description
        fi-obj-name
        fi-obj-description
        with frame {&frame-name} .
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
    case rs-cntxt-level
    :
      when 1
      then do:
        assign
          p-output-menu-group-context  = {&cntxt-global}
          p-output-host-code           = 0
          p-output-obj-type            = '':u
          p-output-obj-code            = 0
        .
      end.
      when 2
      then do:
        if v-select-host-code = 0
        then do:
          message
            "Не задана фирма" skip
            view-as alert-box error .
          run proc-sel-host in this-procedure .
          undo, return error return-value .
        end.
        assign
          p-output-menu-group-context = {&cntxt-firm}
          p-output-host-code          = v-select-host-code
          p-output-obj-type           = '':u
          p-output-obj-code           = 0
        .
      end.
      when 3
      then do:
        if v-select-host-code = 0
        then do:
          message
            "Не задана фирма" skip
            view-as alert-box error .
          run proc-sel-host in this-procedure .
          undo, return error return-value .
        end.
        if v-select-obj-type = '':U
        or v-select-obj-code = 0
        then do:
          message
            "Не задан объект" skip
            view-as alert-box error .
          run proc-sel-obj in this-procedure .
          undo, return error return-value .
        end.
        assign
          p-output-menu-group-context = {&cntxt-object}
          p-output-host-code          = v-select-host-code
          p-output-obj-type           = v-select-obj-type
          p-output-obj-code           = v-select-obj-code
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
      p-output-menu-code       = p-menu-code
      p-output-menu-group-code = v-select-menu-group-code
    .

    assign
      p-update-data = true
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
      if p-host-show = true
      then do:
        assign
          fi-host-label       :visible   = true
          fi-host-name        :visible   = true
          fi-host-description :visible   = true
          r-sel-host          :visible   = true
          r-sel-host          :sensitive = true
        .
      end.
      else do:
        assign
          fi-host-label       :visible   = false
          fi-host-name        :visible   = false
          fi-host-description :visible   = false
          r-sel-host          :sensitive = false
          r-sel-host          :visible   = false
        .
      end.
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
  define input  parameter p-obj-show as logical   no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if p-obj-show = true
      then do:
        assign
          fi-obj-label       :visible   = true
          fi-obj-name        :visible   = true
          fi-obj-description :visible   = true
          r-sel-obj          :visible   = true
          r-sel-obj          :sensitive = true
        .
      end.
      else do:
        assign
          fi-obj-label       :visible   = false
          fi-obj-name        :visible   = false
          fi-obj-description :visible   = false
          r-sel-obj          :sensitive = false
          r-sel-obj          :visible   = false
        .
      end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cb-menu-group-id-list-items Dialog-Frame
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
          where buf_temp-menu-group-id.menu-group-id = string(p-menu-group-code)
          no-error .
        if available buf_temp-menu-group-id
        then do:
          assign
            v-select-menu-group-code = integer(buf_temp-menu-group-id.menu-group-id)
            cb-menu-group-id         = buf_temp-menu-group-id.item-value
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

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update-cntxt-level Dialog-Frame
PROCEDURE update-cntxt-level :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-host-show as logical   no-undo .
  define variable v-obj-show  as logical   no-undo .

  do
  on error undo, return error return-value
  :
    case rs-cntxt-level
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
          "rs-cntxt-level" rs-cntxt-level skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end case .

    run set-host-state in this-procedure
      (input  v-host-show
      ) .
    run set-obj-state in this-procedure
      (input  v-obj-show
      ) .

    case rs-cntxt-level
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
        if v-select-host-code = 0
        then do:
          run proc-sel-host in this-procedure .
        end.
      end.
      when 3
      then do:
        /* {&cntxt-object} */
        /* контекст объект - если фирма не задана, то открываем справочник выбора объекта */
        if v-select-obj-type = '':U
        or v-select-obj-code = 0
        then do:
          run proc-sel-obj in this-procedure .
        end.
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
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME