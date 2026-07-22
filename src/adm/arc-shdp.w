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

Выбор параметров для авторасчета архивов

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 09/08/04

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
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help toggle-arh ~
toggle-ahsp toggle-aht toggle-hold
&Scoped-Define DISPLAYED-OBJECTS toggle-arh toggle-ahsp toggle-aht ~
toggle-hold

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

DEFINE VARIABLE toggle-ahsp AS LOGICAL INITIAL no
     LABEL "Складской архив по поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 41.13 BY .83 NO-UNDO.

DEFINE VARIABLE toggle-aht AS LOGICAL INITIAL no
     LABEL "Складской архив по типам приобретения"
     VIEW-AS TOGGLE-BOX
     SIZE 41.13 BY .83 NO-UNDO.

DEFINE VARIABLE toggle-arh AS LOGICAL INITIAL no
     LABEL "Складской архив по товару"
     VIEW-AS TOGGLE-BOX
     SIZE 42.63 BY .83 NO-UNDO.

DEFINE VARIABLE toggle-hold AS LOGICAL INITIAL no
     LABEL "Межфирменный архив"
     VIEW-AS TOGGLE-BOX
     SIZE 40.63 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     toggle-arh AT ROW 2.83 COL 5.38
     toggle-ahsp AT ROW 4.08 COL 5.38
     toggle-aht AT ROW 5.42 COL 5.38
     toggle-hold AT ROW 6.67 COL 5.38
     SPACE(4.23) SKIP(0.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры авторасчета архивов"
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
    toggle-arh
    toggle-ahsp
    toggle-aht
    toggle-hold
  .
  if  toggle-arh  = false
  and toggle-ahsp = false
  and toggle-aht  = false
  and toggle-hold = false
  then do:
    message
      "Не выбран ни один тип архивов"
      view-as alert-box information .
    undo, return no-apply.
  end.

  run attach-attr-to-schedule-line in this-procedure
    (input  toggle-arh  /* p-calc-arh  */
    ,input  toggle-ahsp /* p-calc-ahsp */
    ,input  toggle-aht  /* p-calc-aht  */
    ,input  toggle-hold /* p-calc-hold */
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
      ,output toggle-arh
      ,output toggle-ahsp
      ,output toggle-aht
      ,output toggle-hold
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

  define input parameter p-calc-arh  as logical   no-undo .
  define input parameter p-calc-ahsp as logical   no-undo .
  define input parameter p-calc-aht  as logical   no-undo .
  define input parameter p-calc-hold as logical   no-undo .

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
    and (  p-task-type   <> {&btpr-type-autoarh}
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
      v-attr-value  = ( if p-calc-arh  = yes then "yes" else "no" ) + ","
                    + ( if p-calc-ahsp = yes then "yes" else "no" ) + ","
                    + ( if p-calc-aht  = yes then "yes" else "no" ) + ","
                    + ( if p-calc-hold = yes then "yes" else "no" )
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
  DISPLAY toggle-arh toggle-ahsp toggle-aht toggle-hold
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help toggle-arh toggle-ahsp toggle-aht toggle-hold
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
  define output parameter p-calc-arh   as logical   no-undo .
  define output parameter p-calc-ahsp  as logical   no-undo .
  define output parameter p-calc-aht   as logical   no-undo .
  define output parameter p-calc-hold  as logical   no-undo .

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
        p-calc-arh  = true
        p-calc-ahsp = true
        p-calc-aht  = true
        p-calc-hold = true
      .
    end.
    else do:
      run schedule-attr-extract-logical in this-procedure
        (input  1
        ,input  v-param-list
        ,output p-calc-arh
      ).
      run schedule-attr-extract-logical in this-procedure
        (input  2
        ,input  v-param-list
        ,output p-calc-ahsp
      ).
      run schedule-attr-extract-logical in this-procedure
        (input  3
        ,input  v-param-list
        ,output p-calc-aht
      ).
      run schedule-attr-extract-logical in this-procedure
        (input  4
        ,input  v-param-list
        ,output p-calc-hold
      ).
    end.
  end.
END PROCEDURE. /* init-param-values */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME