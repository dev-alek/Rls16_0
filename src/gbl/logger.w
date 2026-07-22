&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Журнал вызовов внешних процедур

Автор: Перваков Михаил Сергеевич
Дата создания: 03/01/06
Author: Mikhail Pervakov
Creation date: 03/01/06

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Журнал вызовов внешних процедур".
/*{ cmp/vssrevis.i } специально не включено - включение приведет к бесконечному рекурсивному вызову */
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ cmp/showinf.i  }


define new global shared variable g#vssrevis-logger as handle    no-undo .

define variable v-event-num as integer   no-undo .

define temp-table temp-event no-undo
  field event-num              as integer   label "Номер" format ">>>>>9"
  field event-date             as date      label "Дата"  format '99/99/9999':u
  field event-time             as character label "Время" format 'x(8)':u
  field event-time-int         as integer
  field event-name             as character label "Программа" format "x(12)"
  field event-call-point       as character label "Точка вызова" format "x(36)"
  field event-revision         as character label "Версия"    format "x(6)"
  field event-parameters       as character label "Параметры" format "x(32)"
  field event-extra-parameters as character label "Доп. параметры" format "x(32)"
  index xpk event-num descending
  index xie1 event-num
  index xie2 event-name event-num
  .

define stream sout .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-event

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 event-num event-name event-revision event-parameters event-extra-parameters event-call-point event-date event-time
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&Scoped-define OPEN-QUERY-BROWSE-2 /* OPEN QUERY {&SELF-NAME} FOR EACH temp-event . */ run local-open-query .
&Scoped-define TABLES-IN-QUERY-BROWSE-2 temp-event
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 temp-event


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-export b-import b-refresh b-clear ~
b-help BROWSE-2 EDITOR-1 EDITOR-2 EDITOR-3
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1 EDITOR-2 EDITOR-3

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-clear
     LABEL "О&чистить"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-import
     LABEL "&Импорт"
     SIZE 10 BY 1.

DEFINE BUTTON b-refresh
     LABEL "&Обновить"
     SIZE 10 BY 1.

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46.25 BY 2.96 NO-UNDO.

DEFINE VARIABLE EDITOR-2 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.63 BY 2.96 NO-UNDO.

DEFINE VARIABLE EDITOR-3 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.63 BY 2.96 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-2 FOR
      temp-event SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 C-Win _FREEFORM
  QUERY BROWSE-2 DISPLAY
      event-num
      event-name
      event-revision
      event-parameters
      event-extra-parameters
      event-call-point
      event-date
      event-time
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 95.75 BY 13.54.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1 COL 1
     b-export AT ROW 1 COL 11
     b-import AT ROW 1 COL 21
     b-refresh AT ROW 1 COL 31
     b-clear AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     BROWSE-2 AT ROW 2.46 COL 1
     EDITOR-1 AT ROW 16.21 COL 1.63 NO-LABEL
     EDITOR-2 AT ROW 16.21 COL 50 NO-LABEL
     EDITOR-3 AT ROW 19.46 COL 1.75 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 95.88 BY 21.54.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Журнал событий"
         HEIGHT             = 21.54
         WIDTH              = 95.88
         MAX-HEIGHT         = 21.54
         MAX-WIDTH          = 95.88
         VIRTUAL-HEIGHT     = 21.54
         VIRTUAL-WIDTH      = 95.88
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
                                                                        */
/* BROWSE-TAB BROWSE-2 b-help DEFAULT-FRAME */
ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

ASSIGN 
       EDITOR-2:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

ASSIGN 
       EDITOR-3:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-2
/* Query rebuild information for BROWSE BROWSE-2
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH temp-event . */
run local-open-query .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-2 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Журнал событий */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Журнал событий */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear C-Win
ON CHOOSE OF b-clear IN FRAME DEFAULT-FRAME /* Очистить */
DO:
  run clear-event-list in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit C-Win
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME /* Выход */
DO:
  APPLY 'CLOSE':u to this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export C-Win
ON CHOOSE OF b-export IN FRAME DEFAULT-FRAME /* Экспорт */
DO:
  run export-log-info in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-import C-Win
ON CHOOSE OF b-import IN FRAME DEFAULT-FRAME /* Импорт */
DO:
  run import-log-info in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-refresh
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-refresh C-Win
ON CHOOSE OF b-refresh IN FRAME DEFAULT-FRAME /* Обновить */
DO:
  run local-open-query in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-2
&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 C-Win
ON VALUE-CHANGED OF BROWSE-2 IN FRAME DEFAULT-FRAME
DO:
  run display-dependent in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win 


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

{ gbl/app_help.i }

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
on close of this-procedure do:
   define variable v-ok as logical   no-undo .

   message
     "Закрыть окно журнал событий" skip
     "Продолжить?"
     view-as alert-box question buttons yes-no update v-ok .
   if v-ok <> true
   then do:
     return no-apply .
   end.

   assign
     g#vssrevis-logger = ?
   .
   RUN disable_UI.
end.


if valid-handle(g#vssrevis-logger) = false
or g#vssrevis-logger :get-signature("logevent") = ""
then do:
  assign
    g#vssrevis-logger = this-procedure
  .
end.
else do:
  message
    "Попытка повторного запуска журнала событий" skip
    view-as alert-box error .
  undo, return error return-value .
end.


/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-event-list C-Win 
PROCEDURE clear-event-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define buffer buf_temp-event for temp-event .

  define variable v-ok as logical   no-undo .

  do
  on error undo, return error return-value
  :
    message
      "Очистить Журнал событий" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      undo, return error return-value .
    end.


    for each buf_temp-event
    on error undo, return error return-value
    :
      delete buf_temp-event .
    end.

    assign
      v-event-num = 0
    .

    run local-open-query in this-procedure .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-dependent C-Win 
PROCEDURE display-dependent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}:

      if available temp-event
      then do:
        assign
          editor-1 :screen-value = temp-event.event-parameters
          editor-2 :screen-value = temp-event.event-extra-parameters
          editor-3 :screen-value = temp-event.event-call-point
        .

      end.
      else do:
        assign
          editor-1 :screen-value = ""
          editor-2 :screen-value = ""
          editor-3 :screen-value = ""
        .
      end.
    end. /* do with frame */
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  DISPLAY EDITOR-1 EDITOR-2 EDITOR-3 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-exit b-export b-import b-refresh b-clear b-help BROWSE-2 EDITOR-1 
         EDITOR-2 EDITOR-3 
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-log-info C-Win 
PROCEDURE export-log-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-file-name as character no-undo .

  define buffer buf_temp-event for temp-event .

  do
  on error undo, return error return-value
  :
    assign
      v-file-name = 'logger.txt':u
    .

    run gbl/d-prompt.w (
        'title=':u + "Введите имя файла экспорта" + '\':u
      + 'text1=':u + "Введите имя файла экспорта" + '\':u
      + 'text2=':u + "куда будет выведен журнал событий" + '\':u
      + 'format=X(256)\':u
      + 'type=char\':u
      + 'boxprog=getfile.p\':u
      ,input-output v-file-name
      ).
    if return-value = 'false':u
    then do:
      return .
    end.

    output stream sout to value(v-file-name) .


    for each buf_temp-event
    by buf_temp-event.event-num
    on error undo, return error return-value
    :
      export stream sout buf_temp-event except event-num .
    end.

    output stream sout close .

    message
      "Журнал событий выведен в файл" v-file-name skip
      view-as alert-box question .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-log-info C-Win 
PROCEDURE import-log-info :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-file-name as character no-undo .

  define buffer buf_temp-event for temp-event .

  define buffer buf_import_temp-event for temp-event .

  do
  on error undo, return error return-value
  :
    assign
      v-file-name = 'logger.txt':u
    .

    run gbl/d-prompt.w (
        'title=':u + "Введите имя файла " + '\':u
      + 'text1=':u + "Введите имя файла " + '\':u
      + 'text2=':u + "с журналом событий" + '\':u
      + 'format=X(256)\':u
      + 'type=char\':u
      + 'boxprog=getfile.p\':u
      ,input-output v-file-name
      ).
    if return-value = 'false':u
    then do:
      return .
    end.

    if search(v-file-name) = ""
    or search(v-file-name) = ?
    then do:
      message
        "Файл не найден" skip
        "Файл журнала событий" v-file-name skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* todo - сохранять в формате XML с заголовком */
    input stream sout from value(v-file-name) .

    find first buf_import_temp-event
      where buf_import_temp-event.event-num = -1
      no-error .
    if not available buf_import_temp-event
    then do:
      create buf_import_temp-event .
      assign
        buf_import_temp-event.event-num = -1
      .
    end.

    repeat
    :
      import stream sout buf_import_temp-event except event-num.

      assign
        v-event-num = v-event-num + 1
      .
      create buf_temp-event .
      buffer-copy buf_import_temp-event to buf_temp-event
      assign
        buf_temp-event.event-num              = v-event-num
      .
    end.

    delete buf_import_temp-event .

    input stream sout close .

    run local-open-query in this-procedure .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE iterate-event C-Win 
PROCEDURE iterate-event :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-callback as handle    no-undo .

  define buffer buf_temp-event for temp-event .

  if valid-handle(p-callback)
  and p-callback :get-signature('process-event':u) <> ""
  then do:
    for each buf_temp-event
      by buf_temp-event.event-num
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Экспорт событий &1", buf_temp-event.event-num)
        ) .

      define variable v-call-point as character no-undo .

      assign
        v-call-point = entry(1, buf_temp-event.event-call-point, '|')
      .

      run process-event in p-callback
        (input  buf_temp-event.event-name       /* p-call-name     */
        ,input  buf_temp-event.event-revision   /* p-call-revision */
        ,input  v-call-point                    /* p-call-point    */
        ,input  buf_temp-event.event-date       /* p-call-date     */
        ,input  buf_temp-event.event-time       /* p-call-time     */
        ,input  buf_temp-event.event-time-int   /* p-call-time-int */
        ) .
    end.

    run waitfram-hide in this-procedure .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-open-query C-Win 
PROCEDURE local-open-query :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  do
  on error undo, return error return-value
  :
    open query {&browse-name} for each temp-event .

    run display-dependent in this-procedure .
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE logevent C-Win 
PROCEDURE logevent :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-workfile         as character no-undo .
  define input  parameter p-revision         as character no-undo .
  define input  parameter p-parameters       as character no-undo .
  define input  parameter p-extra-parameters as character no-undo .

  define variable v-today          as date      no-undo .
  define variable v-time           as integer   no-undo .
  define variable v-event-name     as character no-undo .
  define variable v-event-revision as character no-undo .

  define buffer buf_temp-event for temp-event .

  do
  on error undo, return error return-value
  :
    if num-entries(p-workfile, ' ':u) > 1
    then do:
      assign
        v-event-name = entry(2, p-workfile, ' ':u)
      .
    end.
    else do:
      assign
        v-event-name = entry(1, p-workfile, ' ':u)
      .
    end.

    if num-entries(p-revision, ' ':u) > 1
    then do:
      assign
        v-event-revision = entry(2, p-revision, ' ':u)
      .
    end.
    else do:
      assign
        v-event-revision = entry(1, p-revision, ' ':u)
      .
    end.

    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .

    assign
      v-event-num = v-event-num + 1
    .
    create buf_temp-event .
    assign
      buf_temp-event.event-num              = v-event-num
      buf_temp-event.event-date             = v-today
      buf_temp-event.event-time             = string(v-time, 'HH:MM:SS':u)
      buf_temp-event.event-time-int         = v-time
      buf_temp-event.event-name             = v-event-name
      buf_temp-event.event-revision         = v-event-revision
      buf_temp-event.event-parameters       = p-parameters
      buf_temp-event.event-extra-parameters = p-extra-parameters
      buf_temp-event.event-call-point       = substitute('&1|&2|&3':u
                                                        , program-name(4)
                                                        , program-name(5)
                                                        , program-name(6)
                                                        )
    .

    if v-event-name = 'adm/cur-date.w':u
    then do:
      /* оптимизация - переоткрываем окно только в случае выхода в главное меню */
      /* при этом происходит запрос даты */
      run local-open-query in this-procedure .
    end.
  end.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

