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

Выбор параметров для выгрузки в Президентский Мониторинг


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-cre-db-num as integer   no-undo .
define input  parameter p-task-type  as character no-undo .
define input  parameter p-task-num   as integer   no-undo .
define output parameter p-cancel     as logical   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для авторасчета архивов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ ref/shd-attr.i }

define variable v-param-type         as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help f-timezone-diff ~
f-rvs-doc-exist-diff f-rvs-doc-create-diff
&Scoped-Define DISPLAYED-OBJECTS f-timezone-diff ~
f-rvs-doc-exist-diff f-rvs-doc-create-diff

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-timezone-diff AS integer INITIAL ? format "->>>9"
     LABEL "Разница с московским часовым поясом, ч"
     VIEW-AS fill-in
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-doc-exist-diff AS integer INITIAL ? format ">>>9"
     LABEL "Допустимое временное отклонение документов сверки, мин"
     VIEW-AS fill-in
     tooltip "Допустимое временное отклонение документов сверки от времени актуальности на конец суток, мин"
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE f-rvs-doc-create-diff AS integer INITIAL ? format ">>>9"
     LABEL "Допустимое временное отклонение создания сверки процессом, мин"
     VIEW-AS fill-in
     SIZE 10 BY 1 NO-UNDO.



/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     f-timezone-diff AT ROW 2.5 COL 3
     f-rvs-doc-exist-diff AT ROW 4 COL 3
     f-rvs-doc-create-diff AT ROW 5.5 COL 3
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры выгрузки в ИС Президентский Мониторинг"
         CANCEL-BUTTON Btn_Cancel.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры авторасчета архивов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    assign
        p-cancel = yes
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
  assign
    f-timezone-diff
    f-rvs-doc-exist-diff
    f-rvs-doc-create-diff
  .
  
  if  f-timezone-diff = ?
  then do:
    message
      "Введите разницу с часовым поясом Москвы"
      view-as alert-box information .
    undo, return no-apply.
  end.
  
  if  f-rvs-doc-exist-diff >= 10
  then do: end .
  else do:
    message
      "Введите допустимое временное отклонение документов сверки от времени актуальности на конец суток" skip
      "Минимальное значение - 10 мин."
      view-as alert-box information .
    undo, return no-apply.
  end.
  
  if  f-rvs-doc-create-diff >= 10
  then do: end .
  else do:
    message
      "Введите допустимое временное отклонение создания сверки процессом" skip
      "Минимальное значение - 10 мин."
      view-as alert-box information .
    undo, return no-apply.
  end.

  run attach-attr-to-schedule-line in this-procedure
    (input  f-timezone-diff
    ,input  f-rvs-doc-exist-diff
    ,input  f-rvs-doc-create-diff
    ).
  apply "go" to frame {&frame-name}.

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
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    assign
        frame {&frame-name} :title = frame {&frame-name} :title
                    + ". " + p-task-type + ": Задача номер " + string( p-task-num )
    .

    run init-param-values in this-procedure
      (input  p-cre-db-num
      ,input  p-task-type
      ,input  p-task-num
      ,output f-timezone-diff
      ,output f-rvs-doc-exist-diff
      ,output f-rvs-doc-create-diff
      ).

    run enable_UI.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame
PROCEDURE attach-attr-to-schedule-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define input parameter p-timezone-diff as integer   no-undo .
  define input parameter p-rvs-doc-exist-diff as integer   no-undo .
  define input parameter p-rvs-doc-create-diff as integer   no-undo .

  define variable v-attr-value as character no-undo .

  define buffer buf_schedule      for ub.schedule .
  define buffer buf_schedule-attr for ub.schedule-attr .

  do
  on error undo, return error
  :
    find first buf_schedule no-lock
      where buf_schedule.cre-db-num = p-cre-db-num
        and buf_schedule.task-type  = p-task-type
        and buf_schedule.task-num   = p-task-num
      no-error.
    if not available buf_schedule
    and (  p-task-type   <> {&btpr-type-is_PM}
        or p-task-num    <> -1 )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена строка расписания." skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.

    assign
      v-attr-value  = string(p-timezone-diff) + ","
                    + string(p-rvs-doc-exist-diff) + ","
                    + string(p-rvs-doc-create-diff)
    .
    run schedule-attr-write in this-procedure
      (input p-cre-db-num
      ,input p-task-type
      ,input p-task-num
      ,input {&attr-schedule-param-list-h}
      ,input v-attr-value
      ).
end.
END PROCEDURE. /* attach-attr-to-schedule-line */

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
  DISPLAY f-timezone-diff f-rvs-doc-exist-diff f-rvs-doc-create-diff
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help f-timezone-diff f-rvs-doc-exist-diff f-rvs-doc-create-diff
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define input  parameter p-cre-db-num as character no-undo .
  define input  parameter p-task-type  as character no-undo .
  define input  parameter p-task-num   as integer   no-undo .
  define output parameter p-timezone-diff   as integer   no-undo .
  define output parameter p-rvs-doc-exist-diff  as integer   no-undo .
  define output parameter p-rvs-doc-create-diff   as integer   no-undo .

  do
  on error undo, return error
  :

    define variable v-counter       as integer       no-undo.
    define variable v-param-list    as character     no-undo.

    run schedule-attr-value in this-procedure
      (input  p-cre-db-num
      ,input  p-task-type
      ,input  p-task-num
      ,input  {&attr-schedule-param-list-h}
      ,output v-param-list
      ,output v-param-type
      ) .
    if v-param-list = ""
    then do:
      assign
        p-timezone-diff  = ?
        p-rvs-doc-exist-diff = 15
        p-rvs-doc-create-diff  = 15
      .
    end.
    else do:
      p-timezone-diff = integer(entry(1, v-param-list)) no-error .
      p-rvs-doc-exist-diff = integer(entry(2, v-param-list)) no-error .
      p-rvs-doc-create-diff = integer(entry(3, v-param-list)) no-error .
    end.
  end.
END PROCEDURE. /* init-param-values */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME