&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME auto-st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS auto-st
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск авто сессий и отслеживание их работы

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/17/08
Author: Dmitry Ukhanov
Creation date: 09/17/08

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-db-info            as character no-undo .
define input  parameter p-hidden-mode        as logical   no-undo .
define input  parameter p-no-message         as logical   no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск авто сессий и отслеживание их работы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/mrk-strf.i }
{ adm/auto-def.i }
{ gbl/windows.i  }
{ gbl/runrepid.i }
{ gbl/mutex.i    }

define temp-table tt_auto-session no-undo
  field session-pid  as integer   initial 0
  field session-type as character
  field session-name as character
  field proc-name    as character
  field add-mode     as character
  index pi is unique primary session-pid session-type
  index i_proc proc-name
  index i_type session-type
  .

define buffer X_auto-session for tt_auto-session .

define variable v-rid-list as character no-undo .
define variable v-start-mode as character no-undo .

define variable v-exefile  as character no-undo .
define variable v-inifile  as character no-undo .
define variable v-work-dir as character no-undo .

define variable log-exit as logical   no-undo .

define stream VarStream .
define variable v-varstr   as character no-undo .
define variable v-varfile  as character no-undo .

define variable v-task-name as character no-undo .
define variable vDopParamSession as character no-undo .

get-key-value section "THAutoSessions"
                key "DopParamSession"
              value vDopParamSession.
if vDopParamSession = ? then
  vDopParamSession = "".

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-auto-start
&Scoped-define BROWSE-NAME br-auto-sessions

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_auto-session

/* Definitions for BROWSE br-auto-sessions                              */
&Scoped-define FIELDS-IN-QUERY-br-auto-sessions mark-string( input recid(X_auto-session), input v-rid-list) X_auto-session.session-pid X_auto-session.session-name X_auto-session.add-mode X_auto-session.session-type X_auto-session.proc-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-auto-sessions
&Scoped-define SELF-NAME br-auto-sessions
&Scoped-define QUERY-STRING-br-auto-sessions FOR EACH X_auto-session
&Scoped-define OPEN-QUERY-br-auto-sessions OPEN QUERY {&SELF-NAME} FOR EACH X_auto-session .
&Scoped-define TABLES-IN-QUERY-br-auto-sessions X_auto-session
&Scoped-define FIRST-TABLE-IN-QUERY-br-auto-sessions X_auto-session


/* Definitions for FRAME f-auto-start                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-f-auto-start ~
    ~{&OPEN-QUERY-br-auto-sessions}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-mark b-start b-stop b-view-hide ~
b-help br-auto-sessions mark-num
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD ATH-var-name auto-st
FUNCTION ATH-var-name RETURNS CHARACTER
  ( INPUT p-pid AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR auto-st AS WIDGET-HANDLE NO-UNDO.

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-start
       MENU-ITEM m_b-start-view LABEL "Сессия видна"
       MENU-ITEM m_b-start-hidden LABEL "Сессия не видна".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из автоматической системы"
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-start
     LABEL "&Выполнить"
     SIZE 10 BY 1.

DEFINE BUTTON b-stop
     LABEL "&Останов"
     SIZE 10 BY 1.

DEFINE BUTTON b-view-hide
     LABEL "По&казать/Скрыть"
     SIZE 16 BY 1.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">,>>>,>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 10.5 BY .67
     FGCOLOR 7  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-auto-sessions FOR
      X_auto-session SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-auto-sessions
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-auto-sessions auto-st _FREEFORM
  QUERY br-auto-sessions DISPLAY
      mark-string( input recid(X_auto-session), input v-rid-list) column-label "*" format "X(1)":U
X_auto-session.session-pid  column-label "PID"                    format ">>>>>>>>>9":U
X_auto-session.session-name column-label "Название задания"       format "X(40)":U
X_auto-session.add-mode     column-label "Доп. установки"         format "X(50)":U width-chars 14
X_auto-session.session-type column-label "Тип"                    format "X(10)":U
X_auto-session.proc-name    column-label "Запускающая процедура"  format "X(20)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 20.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-auto-start
     b-exit AT ROW 1 COL 2.5
     b-mark AT ROW 1 COL 17 WIDGET-ID 4
     b-start AT ROW 1 COL 20 WIDGET-ID 6
     b-stop AT ROW 1 COL 30 WIDGET-ID 10
     b-view-hide AT ROW 1 COL 40 WIDGET-ID 12
     B-Help AT ROW 1 COL 95 WIDGET-ID 2
     br-auto-sessions AT ROW 2.75 COL 2.5 WIDGET-ID 100
     mark-num AT ROW 2 COL 2 NO-LABEL WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.38 BY 22.54.


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
  CREATE WINDOW auto-st ASSIGN
         HIDDEN             = YES
         TITLE              = "Запуск автопроцессов и поддержание их работы"
         HEIGHT             = 22.88
         WIDTH              = 99.25
         MAX-HEIGHT         = 41.58
         MAX-WIDTH          = 160
         VIRTUAL-HEIGHT     = 41.58
         VIRTUAL-WIDTH      = 160
         RESIZE             = no
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
/* SETTINGS FOR WINDOW auto-st
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-auto-start
   FRAME-NAME                                                           */
/* BROWSE-TAB br-auto-sessions b-help f-auto-start */
ASSIGN
       b-start:POPUP-MENU IN FRAME f-auto-start       = MENU POPUP-MENU-b-start:HANDLE.

ASSIGN
       br-auto-sessions:ALLOW-COLUMN-SEARCHING IN FRAME f-auto-start = TRUE
       br-auto-sessions:COLUMN-RESIZABLE IN FRAME f-auto-start       = TRUE
       br-auto-sessions:COLUMN-MOVABLE IN FRAME f-auto-start         = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME f-auto-start
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(auto-st)
THEN auto-st:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-auto-sessions
/* Query rebuild information for BROWSE br-auto-sessions
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_auto-session .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-auto-sessions */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME auto-st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL auto-st auto-st
ON END-ERROR OF auto-st /* Запуск автопроцессов и поддержание их работы */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL auto-st auto-st
ON WINDOW-CLOSE OF auto-st /* Запуск автопроцессов и поддержание их работы */
DO:
  /* This event will close the window and terminate the procedure.  */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit auto-st
ON CHOOSE OF b-exit IN FRAME f-auto-start /* Выход  */
DO:

  define variable v-answer as logical   no-undo .

  run gbl/q-wait.w
    ( input substitute( "Вы хотите завершить работу авторежима?" )
     ,input false                                         /* p-default-answ */
     ,input 20                                            /* p-timeout      */
     ,output v-answer                                     /* p-answer (сек) */
    ) no-error .

  if error-status :error
    or v-answer = true
  then do:
    if error-status :error then do:
/*      run write-to-log ( substitute( "&1. Ошибка при завершении работы. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) )*/
/*                      ).*/
    end.
    for each tt_auto-session
    :
      if lookup( "H":U, tt_auto-session.add-mode, "+":U ) > 0 then do:
        { gbl/markstrn.i tt_auto-session v-rid-list }
      end.
    end.

    run stop-sessions in this-procedure
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при остановке сессий.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.

    for each tt_auto-session
    :
      delete tt_auto-session .
    end.

    assign
      log-exit = yes
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark auto-st
ON CHOOSE OF b-mark IN FRAME f-auto-start /* * */
DO:

  define variable loc#log as logical no-undo .

  if available X_auto-session then do:
    { gbl/markstrn.i X_auto-session v-rid-list }
    loc#log = {&browse-name}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&browse-name}:select-next-row ().
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0 then do:
      hide mark-num in frame {&frame-name}.
    end.
    else do:
      display
        num-entries( v-rid-list ) @ mark-num
        with frame {&frame-name}.
    end.
  end.
  apply "entry" to {&browse-name} in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start auto-st
ON CHOOSE OF b-start IN FRAME f-auto-start /* Выполнить */
DO:

  define variable v-recid as recid no-undo initial ? .

  if trim( v-rid-list ) = "":U
    and available X_auto-session
    and X_auto-session.session-pid = 0
  then do:
    assign
      v-rid-list = string( recid ( X_auto-session ) )
    .
  end.

  if available X_auto-session then do:
    assign
      v-recid = recid( X_auto-session )
    .
  end.

  run start-sessions in this-procedure
    ( input v-start-mode
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске сессий.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  run my_refresh in this-procedure
    ( input v-recid
    ).

  apply "entry" to {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-stop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-stop auto-st
ON CHOOSE OF b-stop IN FRAME f-auto-start /* Останов */
DO:

  if trim( v-rid-list ) = "":U
    and available X_auto-session
    and X_auto-session.session-pid > 0
  then do:
    assign
      v-rid-list = string( recid ( X_auto-session ) )
    .
  end.

  run stop-sessions in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при остановке сессий.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  run my_refresh in this-procedure
    ( input ?
    ).

  apply "entry" to {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-view-hide
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-view-hide auto-st
ON CHOOSE OF b-view-hide IN FRAME f-auto-start /* Показать/Скрыть */
DO:

  define variable v-recid as recid no-undo initial ? .

  if available X_auto-session then do:
    assign
      v-recid = recid( X_auto-session )
    .
  end.

  if trim( v-rid-list ) = "":U
    and available X_auto-session
    and X_auto-session.session-pid > 0
  then do:
    assign
      v-rid-list = string( recid ( X_auto-session ) )
    .
  end.

  run view-hide-sessions in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute("Ошибка при запуске сессий.") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.

  run my_refresh in this-procedure
    ( input v-recid
    ).

  apply "entry" to {&browse-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-start-hidden
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-start-hidden auto-st
ON CHOOSE OF MENU-ITEM m_b-start-hidden /* Сессия не видна */
DO:
  assign
    v-start-mode = "H":U
  .
  apply "choose" to b-start in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_b-start-view
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_b-start-view auto-st
ON CHOOSE OF MENU-ITEM m_b-start-view /* Сессия видна */
DO:
  if index(vDopParamSession,"-b") <> 0 then
  do:
    message "Запуск в режиме ~"Сессия видна~" не допустим с параметром -b" skip
            "в настройках ini-файла в параметра DopParamSession секции [THAutoSessions]."
            view-as alert-box.
    return no-apply.  
  end.
  
  assign
    v-start-mode = "":U
  .
  apply "choose" to b-start in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-auto-sessions
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK auto-st


/* ***************************  Main Block  *************************** */
/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
      THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
on close of this-procedure
do:
  apply "choose" to b-exit in frame {&frame-name}. /* Выход  */
  return no-apply.
end.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

{ gbl/app_help.i &disable_diasize=yes }

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-exit }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, retry MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, retry MAIN-BLOCK:


  define variable v-start-time      as int64     no-undo .
  define variable v-read-ini        as character no-undo .
  define variable v-num-sessions    as integer   no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-start-proc      as character no-undo .
  define variable v-add-mode        as character no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable v-ind1            as integer   no-undo .
  define variable v-curr-mode       as character no-undo .
  define variable v-curr-mode-name  as character no-undo .
  define variable v-new-add-mode    as character no-undo .
  define variable v-new-hidden-mode as logical   no-undo .
  define variable v-msg                as character no-undo .

  assign
    {&window-name}:title = substitute( "PID: &1. &2 для &3", g#auto-pid, {&window-name}:title, p-db-info )
    file-info:file-name = ".":U
    v-work-dir = file-info:full-pathname
    log-file-name = v-work-dir + {&back-slash-char} + "auto-st.log":U
  .
  run write-to-log in this-procedure
    ( substitute( "Запуск диспетчера автопроцессов." )
    ) .

  assign
    v-task-name = substitute( "OEApp TH 16_0 AutoTaskМanager &1", p-db-info )
  .
  if IsAppAlreadyRunning(true, v-task-name ) then do:
    assign
      v-msg = substitute("Диспетчер задач для &1 уже запущен!", p-db-info )
    .
    if p-no-message = false then do:
      message
        v-msg
        view-as alert-box information .
    end.
    else do:
      run write-to-log in this-procedure
        ( input v-msg
        ) .
    end.

    return .
  end.
  run gbl/getexini.p
    ( output v-exefile
     ,output v-inifile
    ) no-error .
  if error-status :error then do:
    assign
      v-msg = substitute( "&1. Ошибка при определении имени выполняемого файла и *.ini файла &2&3&2&4"
                          , vss-workfile
                          , {&new-line}
                          , error-status :get-message(1)
                          , return-value
                        ) .
    if p-no-message = false then do:
      message
        v-msg
        view-as alert-box error .
    end.
    else do:
      run write-to-log in this-procedure
        ( input v-msg
        ) .
    end.
    undo, return error .
  end.

/*{ gbl/setfltnm.i }*/
/*{ gbl/srt-clmd.i*/
/*  &browse-name    = "{&browse-name}"*/
/*  &frame-name     = "{&frame-name}"*/
/*  &table-name     = "{&first-table-in-query-{&browse-name}}"*/
/*  &label-clmn_1  = "{&label-clmn_3}"*/
/*  &sort-clmn_1   = "{&sort-clmn_3}"*/
/*  &sort-clmn_2    = "X_auto-session.file-name"*/
/*  &sort-clmn_3    = "X_auto-session.file-num"*/
/*  &open-query     = "run OpenBr in this-procedure ( input yes, input no, input no) ."*/
/*  &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input no)."*/
/*  &sort-column-name = "sort-column-name"*/
/*  &re-move-clmn   = "no"*/
/*  &mv-brw-default = "no"*/
/*}*/

/*{ gbl/brwrepos.i*/
/*  &line-num=5*/
/*}*/


/*{ gbl/brwrefre.i " assign v-doc-rec = ?. if available X_auto-session then v-doc-rec = recid(X_auto-session). ~*/
/*             run OpenBr in this-procedure (input yes, input no, input no) no-error. reposition {&browse-name} to recid v-doc-rec no-error. ~*/
/*             APPLY 'Entry' TO {&browse-name}.  " }*/

  assign
    b-start:menu-mouse in frame {&frame-name} = 1
  .

  run init-session in this-procedure .

  get-key-value
    section "THAutoSessions"
    key "NumAutoSessions"
    value v-read-ini
  .

  assign
    v-num-sessions = integer( v-read-ini ) no-error
  .
  if v-num-sessions = ?
    or error-status :error
  then do:
    assign
      v-msg = substitute( "Не задано или задано неверно кол-во обрабатываемых автосессий.&1"
                         + "(секция THSessions ключ NumSession в .ini файле).&1"
                         + "NumSession в ini: &2&1"
                         , v-read-ini
                        ) .
    if p-no-message = false then do:
      message
        v-msg
        view-as alert-box information .
    end.
    else do:
      run write-to-log in this-procedure
        ( input v-msg
        ) .
    end.
  end.
  else do:
    do v-ind = 1 to v-num-sessions
    :
      v-msg = "".
      get-key-value
        section "THAutoSessions"
        key substitute( "AutoSession&1", v-ind )
        value v-read-ini
      .
      if v-read-ini <> ?
        and v-read-ini <> "":U
      then do:
        assign
          v-read-ini   = caps( v-read-ini )
          v-add-mode   = "":U
        .
        if num-entries( v-read-ini, "+":U ) > 1 then do:
          assign
            v-num-entries  = num-entries( v-read-ini, "+":U )
            v-new-add-mode = "":U
          .
          do v-ind1 = 1 to v-num-entries
          :
            assign
              v-curr-mode      = entry( v-ind1, v-read-ini, "+":U )
              v-curr-mode-name = entry( 1, v-curr-mode, ":":U )
            .

            if trim( v-curr-mode-name ) <> "":U then do:
              case v-curr-mode-name :
                when "SN" then do:
                  assign
                    v-start-proc = lc( entry( 2, v-curr-mode, ":":U ) )
                  .
                end.
                when "H":U
                or when "R":U
                or when "DB":U
                or when "ExtSys":U
                or when "Sock":U
                or when "ProcName":U
                then do:
                  assign
                    v-new-add-mode = v-new-add-mode + "+":U + v-curr-mode
                  .
                end.
                otherwise do:
                  run write-to-log ( substitute( "&1. Неизвестный ключ (&2) запуска автопроцесса (&3)! Ключ игнорируется", vss-workfile, v-curr-mode, v-start-proc ) ).
                end.
              end case.
            end.
          end.
          assign
            v-add-mode = left-trim( v-new-add-mode, "+":U )
          .
        end.

        if index(vDopParamSession,"-b") <> 0 and 
           lookup( "H":U, v-add-mode, "+":U ) = 0 then
        do: /* если в настройках ini-файла в параметре DopParamSession секции [THAutoSessions] стоит -b, то не запускаем */
          v-msg = "Автопроцесс с ключом -b в параметре DopParamSession может быть запущен только в скрытом режиме".
          if p-no-message = false then do:
            message
              v-msg
              view-as alert-box error .
          end.
          else do:
            run write-to-log in this-procedure
              ( input v-msg
              ) .
          end.
          next.
        end.

        find first X_auto-session
          where X_auto-session.session-type = v-start-proc
            and X_auto-session.session-pid  = 0
          no-error .
        if available X_auto-session then do:
          assign
            v-rid-list = string( recid( X_auto-session ) )
          .
          run start-sessions in this-procedure
            ( input v-add-mode
            ) no-error .
          if error-status :error then do:
            assign
              v-msg = substitute( "&1. Ошибка при запуске автопроцесса с типом '&2' &3&4&3&5"
                                  , vss-workfile
                                  , v-start-proc
                                  , {&new-line}
                                  , error-status :get-message(1)
                                  , return-value
                                ) .
            if p-no-message = false then do:
              message
                v-msg
                view-as alert-box error .
            end.
            else do:
              run write-to-log in this-procedure
                ( input v-msg
                ) .
            end.
          end.
        end.
        else do:
          assign
            v-msg = substitute( "&1. Отсутствует автопроцесс с типом '&2'"
                                , vss-workfile
                                , v-start-proc
                              ) .
          if p-no-message = false then do:
            message
              v-msg
              view-as alert-box error .
          end.
          else do:
            run write-to-log in this-procedure
              ( input v-msg
              ) .
          end.
        end.
      end.
    end.
  end.

  if p-hidden-mode = false then do:
    run myenable in this-procedure .
  end.

  main-cycl:
  do while not log-exit
  on error  undo, leave main-cycl
  on stop   undo, next
  on endkey undo, next
  :
    if p-hidden-mode = false then do:
      run my_refresh in this-procedure
        ( input (if available X_auto-session then recid( X_auto-session ) else ? )
        ).
    end.
    assign
      v-start-time = etime
    .
    do while not log-exit:
      if p-hidden-mode = false then do:
        wait-for
          go of frame {&frame-name}
          or close of this-procedure
          or choose of b-start in frame {&frame-name}
          or choose of b-help in frame {&frame-name}
          focus frame {&frame-name}
          pause 1
        .
      end.
      else do:
        wait-for
          go of frame {&frame-name}
          or close of this-procedure
          pause 1
          .
      end.

      assign
        file-info:file-name = ATH-var-name( g#auto-pid )
        v-varfile           = file-info:full-pathname
      .

      if v-varfile <> ? then do:
        assign
          v-varstr = "":U
        .
        input stream VarStream from value( v-varfile ) .
        block_read-var:
        repeat :
          import stream VarStream unformatted v-varstr no-error .
          leave block_read-var .
        end.
        input stream VarStream close.
        if lookup( "H":U, v-varstr, "+":U ) = 0 then do:
          assign
            v-new-hidden-mode = false
          .
        end.
        else do:
          assign
            v-new-hidden-mode = true
          .
        end.
        os-delete value( v-varfile ) .
        if v-new-hidden-mode <> p-hidden-mode then do:
          assign
            p-hidden-mode = v-new-hidden-mode
          .
          run write-to-log ( substitute( "Смена статуса 'видимости' сессии. Теперь сессия &1видна.", (if p-hidden-mode = true then "не":U else "") ) ).
        end.
      end.

      if p-hidden-mode = false
        and frame {&frame-name}:visible = false
      then do:
        run myenable in this-procedure .
      end.
      if p-hidden-mode = true
        and frame {&frame-name}:visible = true
      then do:
        run myhide in this-procedure .
      end.

      if etime - v-start-time > 60000
      then do:
        leave .
      end.
    end.

    run restart-sessions in this-procedure .

  end.

  for each tt_auto-session
  :
    delete tt_auto-session .
  end.

  RUN disable_UI in this-procedure .

  run LetAnotherInstanceRun( v-task-name ) .

  run write-to-log in this-procedure
    ( substitute( "Завершение работы диспетчера автопроцессов." )
    ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI auto-st  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(auto-st)
  THEN DELETE WIDGET auto-st.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI auto-st  _DEFAULT-ENABLE
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
  DISPLAY mark-num
      WITH FRAME f-auto-start IN WINDOW auto-st.
  ENABLE b-exit b-mark b-start b-stop b-view-hide b-help br-auto-sessions
         mark-num
      WITH FRAME f-auto-start IN WINDOW auto-st.
  {&OPEN-BROWSERS-IN-QUERY-f-auto-start}
  VIEW auto-st.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-session auto-st
PROCEDURE init-session :
create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autonws}
    X_auto-session.session-name = "Новости"
    X_auto-session.proc-name    = "adm/l-i-nws.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autoarh}
    X_auto-session.session-name = "Архивы"
    X_auto-session.proc-name    = "adm/l-i-arc.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autoexp}
    X_auto-session.session-name = "Экспорт"
    X_auto-session.proc-name    = "adm/l-i-exp.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autooxml}
    X_auto-session.session-name = "OpenXML"
    X_auto-session.proc-name    = "adm/l-i-oxml.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autogetcd}
    X_auto-session.session-name = "Прием инф. с касс"
    X_auto-session.proc-name    = "adm/l-igetcd.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autosale}
    X_auto-session.session-name = "Обработка продаж"
    X_auto-session.proc-name    = "adm/l-iasale.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autosuz}
    X_auto-session.session-name = "Отчеты"
    X_auto-session.proc-name    = "adm/l-i-suz.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autocbnk}
    X_auto-session.session-name = "Эксп/имп в КЛИЕНТ-БАНК"
    X_auto-session.proc-name    = "adm/l-iacbnk.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-autofree}
    X_auto-session.session-name = "Произвольные задания"
    X_auto-session.proc-name    = "adm/l-i-free.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-sktsrv}
    X_auto-session.session-name = "Сокет Сервер"
    X_auto-session.proc-name    = "adm/l-i-skt.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-mercury}
    X_auto-session.session-name = "Меркурий"
    X_auto-session.proc-name    = "adm/l-i-merc.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-is_motp}
    X_auto-session.session-name = "ИС МОТП"
    X_auto-session.proc-name    = "adm/l-i-motp.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-is_diadoc}
    X_auto-session.session-name = "ИС Diadoc"
    X_auto-session.proc-name    = "adm/l-i-diadoc.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-hddtest}
    X_auto-session.session-name = "Мониторинг HDD"
    X_auto-session.proc-name    = "adm/l-i-hddtest.w":U
  .
  create X_auto-session .
  assign
    X_auto-session.session-type = {&btpr-type-is_PM}
    X_auto-session.session-name = "Выгрузка в ИС Президентский Мониторинг"
    X_auto-session.proc-name    = "adm/l-i-is_PM.w":U
  .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable auto-st
PROCEDURE myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    auto-st:HIDDEN = false
  .

  run enable_UI .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myhide auto-st
PROCEDURE myhide :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  disable all with frame {&frame-name} .
  hide all no-pause in window {&window-name} .
  assign
    auto-st:HIDDEN = true
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my_refresh auto-st
PROCEDURE my_refresh :
define input  parameter p-recid as recid     no-undo .

  define variable v-ok as logical   no-undo .

  assign
    v-ok = browse br-auto-sessions :set-repositioned-row( browse br-auto-sessions :focused-row, 'CONDITIONAL':U)
  .
  {&OPEN-QUERY-br-auto-sessions}
  reposition br-auto-sessions to recid p-recid no-error.

  if num-entries( v-rid-list ) = 0 then do:
    hide mark-num in frame {&frame-name}.
  end.
  else do:
    display
      num-entries( v-rid-list ) @ mark-num
      with frame {&frame-name}.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE restart-sessions auto-st
PROCEDURE restart-sessions :
define buffer buf_auto-session for tt_auto-session .
  define buffer et_auto-session  for tt_auto-session .
  define buffer new_auto-session for tt_auto-session .

  define variable v-restart   as logical   no-undo .
  define variable v-pid       as integer   no-undo .
  define variable v-mode      as character no-undo .
  define variable v-proc-name as character no-undo .
  define variable v-sess-name as character no-undo .

  for each buf_auto-session
    where buf_auto-session.session-pid > 0
  on error undo, next
  :
    assign
      v-proc-name = buf_auto-session.proc-name
      v-mode      = buf_auto-session.add-mode
      v-sess-name = buf_auto-session.session-name
      v-restart   = false
      file-info:file-name = substitute( "./ATH&1.pid", buf_auto-session.session-pid )
    .
      
    if file-info:full-pathname <> ?
      and ( ( file-info:file-create-date = today
              and file-info:file-create-time < time + 60
            )
            or file-info:file-create-date < today
          )
    then do:
      os-delete value( file-info:full-pathname ) .
      assign
        v-restart = true
      .
    end.
    else do:
      if IsProcessRunning( buf_auto-session.session-pid ) <> -1 then do:
        if lookup( "H":U, v-mode, "+":U ) > 0
          or lookup( "R":U, v-mode, "+":U ) > 0
        then do:
          assign
            v-restart = true
          .
        end.
        else do:
          run write-to-log in this-procedure
            ( substitute( "Сессия '&1' (PID &2) завершила работу.", buf_auto-session.session-name, buf_auto-session.session-pid )
            ) .
          os-delete value( ATH-var-name( buf_auto-session.session-pid ) ) no-error .
          delete buf_auto-session .
        end.
      end.
    end.


    if v-restart = true then do:
      run gbl/termprc.p
        ( input buf_auto-session.session-pid
        ) .
      run write-to-log in this-procedure
        ( substitute( "Остановка сессии '&1' (PID &2) для перезапуска. ", buf_auto-session.session-name, buf_auto-session.session-pid )
        ) .
      os-delete value( ATH-var-name( buf_auto-session.session-pid ) ) no-error .
      delete buf_auto-session .
      run run-session in this-procedure
        ( input  v-sess-name
        , input  v-proc-name
        , input  v-mode
        , output v-pid
        ) no-error .
      if error-status :error
        or v-pid = 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при запуске сессии." skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        next .
      end.

      find first et_auto-session
        where et_auto-session.proc-name   = v-proc-name
          and et_auto-session.session-pid = 0
        no-error .
      if available et_auto-session then do:
        create new_auto-session .
        buffer-copy et_auto-session to new_auto-session
          assign
            new_auto-session.session-pid = v-pid
            new_auto-session.add-mode    = v-mode
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE run-session auto-st
PROCEDURE run-session :
define input  parameter p-sess-name as character no-undo .
  define input  parameter p-proc-name as character no-undo .
  define input  parameter p-mode      as character no-undo .
  define output parameter p-pid       as integer   no-undo .

  do
  on error undo, return error return-value
  :
    define variable vDopParamSessionRandom     as int no-undo .
    define variable vDopParam                  as character no-undo .
    
    if vDopParamSession eq ?
    then
       vDopParam = "".
    else do:
       vDopParamSessionRandom = random(1,9999999).
       vDopParam = substitute (vDopParamSession,vDopParamSessionRandom).
    end.
    define variable v-command-line     as character no-undo .
    define variable v-command-line-log as character no-undo .
    assign
      /* ковычки одинарные и двойные должны быть именно такими!!! иначе не увидит ini-файла!!! */
      v-command-line = substitute( '&1 -ininame &2 -basekey "INI" -p &3 -param "U:&4,P:&5,M:&6" &7'
                                   , v-exefile
                                   , v-inifile
                                   , p-proc-name
                                   , g#auto-user-login
                                   , g#auto-user-password
                                   , replace( p-mode, ",":U, {&delim-par} )
                                   , vDopParam 
                                 )
      v-command-line-log = substitute( '&1 -ininame &2 -basekey "INI" -p &3 -param "U:&4,P:&5,M:&6" &7'
                                   , v-exefile
                                   , v-inifile
                                   , p-proc-name
                                   , g#auto-user-login
                                   , "***"
                                   , replace( p-mode, ",":U, {&delim-par} )
                                   , vDopParam
                                 )
    .
    run gbl/run-gpid.p
      ( input v-command-line
       ,input v-work-dir
       ,output p-pid
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1&2&3&2Параметры запуска сессии: &4", error-status :get-message(1), {&new-line}, return-value, v-command-line-log ) .
    end.

    run write-to-log in this-procedure
      ( substitute( "Запуск сессии '&1' (PID &2). Cтрока запуска: &3", p-sess-name, p-pid, v-command-line-log )
      ) .
 end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE start-sessions auto-st
PROCEDURE start-sessions :
define input  parameter p-mode as character no-undo .

  define buffer new_auto-session for tt_auto-session .
  define buffer buf_auto-session for tt_auto-session .

  define variable v-ok           as logical   no-undo .
  define variable v-pid          as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-recid        as recid     no-undo .
  define variable v-rid-list-new as character no-undo .

  assign
    v-rid-list-new = v-rid-list
    v-rid-list     = "":U
    v-num-entries  = num-entries( v-rid-list-new )
  .
  block_cycl:
  do v-ind = 1 to v-num-entries
  on error undo, next block_cycl
  :
    assign
      v-ok    = false
      v-recid = integer( entry( v-ind, v-rid-list-new ) )
    .
    find first buf_auto-session
      where recid( buf_auto-session ) = v-recid
      no-error
    .
    if available buf_auto-session then do:
      if buf_auto-session.session-pid = 0 then do:
        run run-session in this-procedure
          ( input buf_auto-session.session-name
          , input buf_auto-session.proc-name
          , input p-mode
          , output v-pid
          ) no-error .
        if error-status :error
          or v-pid = 0
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запуске сессии." skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          next block_cycl .
        end.
        create new_auto-session .
        buffer-copy buf_auto-session to new_auto-session
          assign
            new_auto-session.session-pid = v-pid
            new_auto-session.add-mode    = p-mode
        .
        assign
          v-ok = true
        .
      end.
      if v-ok <> true then do:
        assign
          v-rid-list = (if v-rid-list = "":U then "":U else {&comma-char}) + string( v-recid )
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE stop-sessions auto-st
PROCEDURE stop-sessions :
define buffer new_auto-session for tt_auto-session .
  define buffer buf_auto-session for tt_auto-session .

  define variable v-ok           as logical   no-undo .
  define variable v-pid          as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-recid        as recid     no-undo .
  define variable v-rid-list-new as character no-undo .

  assign
    v-rid-list-new = v-rid-list
    v-rid-list     = "":U
    v-num-entries  = num-entries( v-rid-list-new )
  .
  block_cycl:
  do v-ind = 1 to v-num-entries
  on error undo, next block_cycl
  :
    assign
      v-ok    = false
      v-recid = integer( entry( v-ind, v-rid-list-new ) )
    .
    find first buf_auto-session
      where recid( buf_auto-session ) = v-recid
      no-error
    .
    if available buf_auto-session then do:
      if buf_auto-session.session-pid > 0 then do:
        run gbl/termprc.p
          ( input buf_auto-session.session-pid
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Ошибка при остановке сессии : &1", buf_auto-session.session-pid ) skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          next block_cycl .
        end.
        run write-to-log in this-procedure
          ( substitute( "Остановка сессии '&1' (PID &2) пользователем. ", buf_auto-session.session-name, buf_auto-session.session-pid )
          ) .
        os-delete value( ATH-var-name( buf_auto-session.session-pid ) ) no-error .
        delete buf_auto-session .
        assign
          v-ok = true
        .
      end.
      if v-ok <> true then do:
        assign
          v-rid-list = (if v-rid-list = "":U then "":U else {&comma-char}) + string( v-recid )
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE view-hide-sessions auto-st
PROCEDURE view-hide-sessions :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  do
  on error undo, return error return-value
  :

    define buffer buf_auto-session for tt_auto-session .

    define variable v-ok           as logical   no-undo .
    define variable v-ind          as integer   no-undo .
    define variable v-num-entries  as integer   no-undo .
    define variable v-recid        as recid     no-undo .
    define variable v-rid-list-new as character no-undo .
    define variable v-ind1         as integer   no-undo .
    define variable v-num-entries1 as integer   no-undo .
    define variable v-add-mode     as character no-undo .
    define variable v-new-add-mode as character no-undo .

    assign
      v-rid-list-new = v-rid-list
      v-rid-list     = "":U
      v-num-entries  = num-entries( v-rid-list-new )
    .
    block_cycl:
    do v-ind = 1 to v-num-entries
    on error undo, next block_cycl
    :
      assign
        v-ok    = false
        v-recid = integer( entry( v-ind, v-rid-list-new ) )
      .
      find first buf_auto-session
        where recid( buf_auto-session ) = v-recid
        no-error
      .
      if available buf_auto-session then do:
        if buf_auto-session.session-pid > 0 then do:
          if lookup( "H":U, buf_auto-session.add-mode, "+":U ) = 0 then do:
            assign
              buf_auto-session.add-mode = buf_auto-session.add-mode + "+H":U
            .
          end.
          else do:
            assign
              v-num-entries1 = num-entries( buf_auto-session.add-mode, "+":U )
              v-new-add-mode = "":U
            .
            do v-ind1 = 1 to v-num-entries1
            on error undo, next block_cycl
            :
              assign
                v-add-mode = entry( v-ind1, buf_auto-session.add-mode, "+":U )
              .
              if v-add-mode <> "H":U then do:
                assign
                  v-new-add-mode = v-new-add-mode + "+":U + v-add-mode
                .
              end.
            end.
            assign
              buf_auto-session.add-mode = left-trim( v-new-add-mode, "+":U )
            .
          end.
          output stream VarStream to value( ATH-var-name( buf_auto-session.session-pid ) ) .
          put stream VarStream unformatted buf_auto-session.add-mode skip.
          output stream VarStream close.
          assign
            v-ok = true
          .
          run write-to-log in this-procedure
            ( substitute( "Сессия '&1' (PID &2) переведена в &3видимый режим ."
                          ,buf_auto-session.session-name
                          ,buf_auto-session.session-pid
                          ,( if lookup( "H":U, buf_auto-session.add-mode, "+":U ) = 0 then "" else "не" )
                        )
            ) .
          pause 2 no-message .
          assign
            file-info:file-name = ATH-var-name( buf_auto-session.session-pid )
          .
          if file-info:full-pathname <> ? then do:
            message
              substitute("Режим будет изменен как только сессия освободится.") skip
              view-as alert-box information .
          end.
        end.
        if v-ok <> true then do:
          assign
            v-rid-list = (if v-rid-list = "":U then "":U else {&comma-char}) + string( v-recid )
          .
        end.
      end.
    end.
 end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION ATH-var-name auto-st
FUNCTION ATH-var-name RETURNS CHARACTER
  ( INPUT p-pid AS INTEGER ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  RETURN substitute( "./ATH&1.var", p-pid ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME