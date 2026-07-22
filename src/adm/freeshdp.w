&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Процедура вызова редактирования параметров произвольной задачи выполняющейся по расписанию

Автор: Бахтадзе Наталья Викторовна
Дата создания: 14/11/05
Author: Bakhtadze Natalya
Creation date: 14/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
/*вызывается для задания параметров или переде непосредственнно выполнением*/
/*может быть 'shd' или 'run' или {&add-def}*/
define input  parameter p-cre-db-num as integer   no-undo .
define input  parameter p-task-type  as character no-undo .
define input  parameter p-task-num   as integer   no-undo .

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define input-output parameter p-free-id        as character no-undo .
/*идентификатор произвольного задания*/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура вызова редактирования параметров произвольной задачи выполняющейся по расписанию".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

{ ref/shd-attr.i }

define variable v-free-id as character no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-cntxt-db-num like ub.db.db-num no-undo.
define variable v-proc-name as character no-undo .
define variable v-is-rum as logical no-undo .
define variable v-cancel as logical no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-free-tasks

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_temp-schedule-free

/* Definitions for BROWSE BR-free-tasks                                 */
&Scoped-define FIELDS-IN-QUERY-BR-free-tasks buf_temp-schedule-free.free-id buf_temp-schedule-free.free-task-name buf_temp-schedule-free.proc-run-name buf_temp-schedule-free.proc-param-edit-name buf_temp-schedule-free.conf-param buf_temp-schedule-free.is-gbd buf_temp-schedule-free.is-ubd buf_temp-schedule-free.enable-concurrent-0 buf_temp-schedule-free.enable-concurrent-db
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-free-tasks
&Scoped-define SELF-NAME BR-free-tasks
&Scoped-define QUERY-STRING-BR-free-tasks FOR EACH buf_temp-schedule-free
&Scoped-define OPEN-QUERY-BR-free-tasks OPEN QUERY {&SELF-NAME} FOR EACH buf_temp-schedule-free.
&Scoped-define TABLES-IN-QUERY-BR-free-tasks buf_temp-schedule-free
&Scoped-define FIRST-TABLE-IN-QUERY-BR-free-tasks buf_temp-schedule-free


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-free-tasks}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-sel B-Help BR-free-tasks

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "&Выбор"
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-free-tasks FOR
      buf_temp-schedule-free SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-free-tasks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-free-tasks Dialog-Frame _FREEFORM
  QUERY BR-free-tasks DISPLAY
      buf_temp-schedule-free.free-task-name COLUMN-LABEL "Название задачи" FORMAT "X(255)" WIDTH 30
buf_temp-schedule-free.proc-run-name  COLUMN-LABEL "Исполняющая!процедура" FORMAT "X(14)"
buf_temp-schedule-free.proc-param-edit-name COLUMN-LABEL "Процедура!редактирования!параметров" FORMAT "X(14)"
buf_temp-schedule-free.conf-param COLUMN-LABEL  "Кодир.!конфиг.!пар-тр" FORMAT "X(8)"
buf_temp-schedule-free.is-gbd COLUMN-LABEL  "Возможность!запуска!в ГБД" FORMAT "да/нет"
buf_temp-schedule-free.is-ubd COLUMN-LABEL "Возможность!запуска!в УБД" FORMAT "да/нет"
buf_temp-schedule-free.enable-concurrent-0 COLUMN-LABEL  "Возможность!одноврем.!запуска" FORMAT "да/нет"
buf_temp-schedule-free.enable-concurrent-db COLUMN-LABEL "Возможность!одноврем.!запуска!в одной БД" FORMAT "да/нет"
buf_temp-schedule-free.free-id COLUMN-LABEL "ID задачи" FORMAT "X(100)" WIDTH 11
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11.5 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     BR-free-tasks AT ROW 3 COL 1
     SPACE(0.49) SKIP(0.91)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.


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
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-free-tasks B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-free-tasks
/* Query rebuild information for BROWSE BR-free-tasks
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_temp-schedule-free.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-free-tasks */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
  p-cancel = YES.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  IF NOT AVAILABLE buf_temp-schedule-free THEN RETURN NO-APPLY.
  if available buf_temp-schedule-free then do:
    assign
    v-free-id = buf_temp-schedule-free.free-id
    p-free-id = v-free-id
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-free-tasks
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i
&disable_diasize_init = "yes"
}
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run get-db-num in parparentproc(output v-cntxt-db-num).
  if p-free-id = '':u then do:
    for each buf_temp-schedule-free:
      delete buf_temp-schedule-free.
    end.
    run schedule-attr-fill-free-props in this-procedure .
    /*проверм и в это БД можно?*/
    if p-mode = 'shd' then do:
      for each buf_temp-schedule-free:
        if (v-cntxt-db-num = 0
        and not  buf_temp-schedule-free.is-gbd)
        or (v-cntxt-db-num <> 0
        and not buf_temp-schedule-free.is-ubd)
        or buf_temp-schedule-free.is-rum
        then do:
          delete buf_temp-schedule-free.
        end.
      end.
    end.
    if p-mode = {&update} then do:
      run schedule-attr-get-free-id  in this-procedure (
                                                         input p-cre-db-num
                                                        ,input p-task-type
                                                        ,input p-task-num
                                                        ,output v-free-id) no-error .
      if error-status:error then do:
        message
        "Невозможно получить название  произвольного задания по строке расписания"
        view-as alert-box error .
        undo, return no-apply.
      end.
      p-free-id = v-free-id.
    end.
    else do:
      run diasize_init in this-procedure .
      RUN Myenable.
      WAIT-FOR GO OF FRAME {&FRAME-NAME}.
    end.
  end.
  else do:
    v-free-id = p-free-id.
  end.
  run schedule-attr-is-rum-free-id in this-procedure ( input v-free-id
                                                      ,output v-is-rum) no-error.
  if error-status:error then do:
    message
    "Невозможно получить свойство RUM  произвольного задания по строке расписания"
    view-as alert-box error .
    undo, return error.
  end.
  /*проверм и в это БД можно?*/
  run schedule-attr-value in this-procedure (
                                                input p-cre-db-num
                                                ,input p-task-type
                                                ,input  p-task-num
                                                ,input  ({&attr-schd-free-id} + {&delim-par} + v-free-id)
                                                ,output v-value
                                                ,output v-type          ).
  CASE p-mode:
    when {&add-def} then do:

    end.
    when 'shd' then do:
      if v-is-rum then do:
        run str/freerump.w (
              input parparentproc
            , input p-cre-db-num
            , input p-task-type
            , input p-task-num
            , output v-cancel
        ) no-error.

      end. /*if v-is-rum then do:*/
      else do:
      if v-value <> '':u then do:
        v-proc-name = entry(buffer buf_temp-schedule-free:buffer-field("proc-param-edit-name"):POSITION - 2
                                  , v-value, {&delim-par} ) .
        if v-proc-name <> '':U  then do:
          if search(replace(v-proc-name, ".w":U, ".r":U)) <> ?
          or
          search(v-proc-name) <> ?   then do:
            run value(v-proc-name) (
                                                                input parparentproc
                                                                ,input p-curr-host-code
                                                                ,input p-curr-obj-type
                                                                ,input p-curr-obj-code
                                                                ,input 'shd':U
                                                                ,input p-cre-db-num
                                                                ,input p-task-type
                                                                ,input p-task-num
                                                                ,input ?
                                                                ,output p-cancel
                                                                ,output p-params
                                                            ) no-error .
            if error-status:error then do:
              undo, return error .
            end.
            RETURN.
          end.
          else do:
            message
            substitute("Не определена или не найдена процедура редактирования параметров для произвольной задачи по расписанию &1"
                      , v-proc-name)
            view-as alert-box error .
            undo, return error .
          end.
        end. /*if v-proc-name <> '':U  then do:*/
        else do:
          if p-task-num >= 0 then do:
            message
            "Данная произвольная процедура не требует параметров"
            view-as alert-box .
            undo, return  .
          end. /*if p-task-num >= 0 then do:*/
        end.
      end. /*if v-value <> '':U*/
      end. /*else if v-is-rum */
    end. /*shd*/
  END CASE.
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
  ENABLE b-quit B-sel B-Help BR-free-tasks
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
assign
frame {&frame-name}:title = "Произвольные задания"
buf_temp-schedule-free.free-task-name:RESIZABLE IN BROWSE br-free-tasks = YES
buf_temp-schedule-free.free-id:RESIZABLE IN BROWSE br-free-tasks = YES
.
  ENABLE
  b-quit
  B-sel
  B-Help
  BR-free-tasks
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME