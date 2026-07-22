&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно запуска сервера

Автор: Хныкин Павел Андреевич
Дата создания: 07/22/08
Author: Pavel Khnykin
Creation date: 07/22/08

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-port          as integer   no-undo .
define input  parameter p-pos-num       as integer   no-undo .
define input  parameter p-auto-start    as logical   no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно запуска сервера".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/sys-time.i }
{ gbl/color.i    }
{ cmp/trg-def.i new }
{ gbl/cur-time.i }

define stream slog.

define temp-table tt-cli-socket no-undo
  field sock-handle     as handle
  field remote-host     as character
  field remote-port     as integer
  field conn-time       as integer
  field last-conn-time  as integer
index pi is primary unique
  sock-handle
.

define temp-table tt-log no-undo
  field id            as integer
  field log-date      as date
  field log-time      as integer
  field log-text      as character
  field remote-host   as character
  field remote-port   as integer
index pi is primary unique
  id
.


define variable v-server-socket     as handle    no-undo .
define variable v-server-running    as logical   no-undo .
define variable v-retval            as logical   no-undo .
define variable v-log-id            as integer   no-undo .
define variable v-mt-route-handle   as handle    no-undo .
define variable v-mt-route-loaded   as logical   no-undo .

define variable v-cfg-max-user-num      as integer   no-undo .
define variable v-cfg-timeout           as integer   no-undo .



define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_user-login for ub.user-login .
define buffer buf_cash-desk  for ub.cash-desk.

procedure crc32 external "crc32.dll" CDECL :
    define input    parameter p-crc    as long.
    define input    parameter p-array  as memptr.
    define input    parameter p-len    as long.
    define return   parameter p-crc32  as unsigned-long.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME
&Scoped-define BROWSE-NAME br-log

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-log

/* Definitions for BROWSE br-log                                        */
&Scoped-define FIELDS-IN-QUERY-br-log tt-log.id tt-log.log-text
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-log
&Scoped-define SELF-NAME br-log
&Scoped-define QUERY-STRING-br-log FOR EACH tt-log
&Scoped-define OPEN-QUERY-br-log OPEN QUERY {&SELF-NAME} FOR EACH tt-log.
&Scoped-define TABLES-IN-QUERY-br-log tt-log
&Scoped-define FIRST-TABLE-IN-QUERY-br-log tt-log


/* Definitions for FRAME DEFAULT-FRAME                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME ~
    ~{&OPEN-QUERY-br-log}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-start b-help r-semaphore fi-port ~
br-log fi-pos-num fi-pos-type fi-users fi-last-conn-time
&Scoped-Define DISPLAYED-OBJECTS fi-port fi-pos-num fi-pos-type fi-users ~
fi-last-conn-time

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помощь"
     SIZE 10 BY 1.

DEFINE BUTTON b-prop
     LABEL "&Настройки"
     SIZE 10 BY 1.

DEFINE BUTTON b-start
     LABEL "&Старт"
     SIZE 10 BY 1.

DEFINE BUTTON b-stop
     LABEL "&Стоп"
     SIZE 10 BY 1.

DEFINE VARIABLE fi-last-conn-time AS CHARACTER FORMAT "X(256)":U
     LABEL "Последнее соединение"
      VIEW-AS TEXT
     SIZE 58 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-port AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Порт"
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE fi-pos-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Номер кассы"
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-pos-type AS CHARACTER FORMAT "X(256)":U INITIAL "0"
     LABEL "Тип кассы"
      VIEW-AS TEXT
     SIZE 20 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fi-users AS CHARACTER FORMAT "X(256)":U
     LABEL "Пользователи"
      VIEW-AS TEXT
     SIZE 64.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE RECTANGLE r-semaphore
     EDGE-PIXELS 1 GRAPHIC-EDGE
     SIZE 80 BY 1
     BGCOLOR 12 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-log FOR
      tt-log SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-log
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-log C-Win _FREEFORM
  QUERY br-log DISPLAY
      tt-log.id FORMAT ">>>>>9" LABEL "#"
    tt-log.log-text FORMAT "X(200)" LABEL "Сообщение"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SIZE 80 BY 10 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1 COL 1 WIDGET-ID 4
     b-start AT ROW 1 COL 11 WIDGET-ID 6
     b-stop AT ROW 1 COL 21 WIDGET-ID 10
     b-prop AT ROW 1 COL 31 WIDGET-ID 28
     b-help AT ROW 1 COL 71 WIDGET-ID 14
     fi-port AT ROW 4.83 COL 9 WIDGET-ID 8
     br-log AT ROW 7 COL 1 WIDGET-ID 200
     fi-pos-num AT ROW 2 COL 13 COLON-ALIGNED WIDGET-ID 16
     fi-pos-type AT ROW 2.71 COL 13 COLON-ALIGNED WIDGET-ID 18
     fi-users AT ROW 3.42 COL 13 COLON-ALIGNED WIDGET-ID 24
     fi-last-conn-time AT ROW 4.13 COL 21 COLON-ALIGNED WIDGET-ID 26
     r-semaphore AT ROW 5.92 COL 1 WIDGET-ID 12
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 80 BY 16 WIDGET-ID 100.


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
         TITLE              = "МТ-Сервер"
         HEIGHT             = 16
         WIDTH              = 80
         MAX-HEIGHT         = 16
         MAX-WIDTH          = 80
         VIRTUAL-HEIGHT     = 16
         VIRTUAL-WIDTH      = 80
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
   FRAME-NAME                                                           */
/* BROWSE-TAB br-log fi-port DEFAULT-FRAME */
/* SETTINGS FOR BUTTON b-prop IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-stop IN FRAME DEFAULT-FRAME
   NO-ENABLE                                                            */
ASSIGN
       fi-last-conn-time:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

/* SETTINGS FOR FILL-IN fi-port IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-log
/* Query rebuild information for BROWSE br-log
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-log.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-log */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* МТ-Сервер */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* МТ-Сервер */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-MAXIMIZED OF C-Win /* МТ-Сервер */
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-RESIZED OF C-Win /* МТ-Сервер */
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit C-Win
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME /* Выход */
DO:
  { gbl/stdbtn.i }
  run proc-b-exit in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help C-Win
ON CHOOSE OF b-help IN FRAME DEFAULT-FRAME /* Помощь */
DO:
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop C-Win
ON CHOOSE OF b-prop IN FRAME DEFAULT-FRAME /* Настройки */
DO:
  { gbl/stdbtn.i }
  run proc-b-prop in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start C-Win
ON CHOOSE OF b-start IN FRAME DEFAULT-FRAME /* Старт */
DO:
  { gbl/stdbtn.i }
  run proc-b-start in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-stop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-stop C-Win
ON CHOOSE OF b-stop IN FRAME DEFAULT-FRAME /* Стоп */
DO:
  { gbl/stdbtn.i }
  run proc-b-stop in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-port
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-port C-Win
ON LEAVE OF fi-port IN FRAME DEFAULT-FRAME /* Порт */
DO:
    assign
        fi-port
    .

    run proc-check-port in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-log
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN my-disable.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

{ gbl/hot-key.i b-exit }

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  find first buf_sys-ctrl no-lock .

  find buf_user-login no-lock
    where buf_user-login.db-num     = buf_sys-ctrl.db-num
      and buf_user-login.status_    = {&uls-normal}
      and buf_user-login.user-login = p-user-login
    no-error .
  if not available buf_user-login
  then do:
    message
      "Не найден пользователь" skip
      p-user-login skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  find first buf_cash-desk no-lock
    where buf_cash-desk.db-num    = buf_sys-ctrl.db-num
      and buf_cash-desk.pos-type  = {&cd-type-IBS-TH-MOB}
      and buf_cash-desk.cash-num  = p-pos-num
  no-error.
  if not available buf_cash-desk
  then do:
    message
      substitute( "В БД &1 не найдена база типа &2 с кодом &3"
                , buf_sys-ctrl.db-num
                , {&cd-type-IBS-TH-MOB}
                , p-pos-num
                )
    view-as alert-box error.
    undo, return error return-value .
  end.

  /* указывать настоящий пароль */
  run gbl/set-gbl.p
    (input true
    ,input buf_user-login.user-id
    ,input p-user-password
    ) .

  define variable v-rtexch-chr               as character no-undo .
  define variable v-rtexch-type              as character no-undo .
  define variable v-rtusrnum-chr             as character no-undo .
  define variable v-rtusrnum-type            as character no-undo .
  define variable v-rtexpdt-chr              as character no-undo .
  define variable v-rtexpdt-type             as character no-undo .
  define variable v-rtusrnum                 as integer   no-undo .
  define variable v-rtexpdt                  as date      no-undo .

  { gbl/conf-rd.i
    "'rtexch':u"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-rtexch-chr
    v-rtexch-type
    no-error
  }
  if error-status :error
  or v-rtexch-chr <> "yes"
  then do:
    message
      "Отсутствуют права для работы с радиотерминалом" skip
      "Параметр rtexch" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  { gbl/conf-rd.i
    "'rtusrnum':u"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-rtusrnum-chr
    v-rtusrnum-type
    no-error
  }
  if error-status :error
  then do:
    message
      "Не задано количество пользователей для работы с радиотерминалом" skip
      "Параметр rtusrnum" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-cfg-max-user-num = integer(v-rtusrnum-chr) no-error
  .

  { gbl/conf-rd.i
    "'rtexpdt':u"
    0
    "''"
    0
    "''"
    "''"
    "''"
    no
    v-rtexpdt-chr
    v-rtexpdt-type
    no-error
  }
  if error-status :error
  then do:
    message
      "Не задан срок окончания лицензии для работы с радиотерминалом" skip
      "Параметр rtexpdt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    v-rtexpdt = date(v-rtexpdt-chr) no-error
  .
  if v-rtexpdt = ?
  then do:
    message
      "Не задан срок окончания лицензии для работы с радиотерминалом" skip
      "Параметр rtexpdt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    session :time-source = 'ub':U
  .

  if today > v-rtexpdt
  then do:
    message
      "Истек срок действия лицензии для работы с радиотерминалом" skip
      "Сегодня" today skip
      "Срок окончания лицензии" v-rtexpdt skip
      "Параметр rtexpdt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if v-rtexpdt - today < 15
  then do:
    message
      substitute("ВНИМАНИЕ!!! До окончания лиценизии осталось &1 дней", v-rtexpdt - today)
    view-as alert-box information.
  end.

  define buffer rtexch-lock_batchprocess for ub.batchprocess .

  /* блокировка процесса */
  run gbl/lock-prc.p
    (input {&lock-prc-mtexch}
    ,input p-pos-num
    ,input 0
    ,input 0
    ,input {&cd-type-IBS-TH-MOB}
    ,input ""
    ,input ""
    ,input ",,,,,,Обработка запросов радиотерминала"
    ,input true
    ,buffer rtexch-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Сервер обработки запросов радиотерминала уже запущен для кассы &1"
                , p-pos-num
                ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return . /* --->>>--- */
  end.


  RUN my-enable.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-crc32 C-Win
PROCEDURE check-crc32 :
  define input  parameter p-mem   as memptr   no-undo .
  define input  parameter p-len   as integer  no-undo .
  define output parameter p-crc32 as int64    no-undo .

  define variable v-message as memptr no-undo.
  set-size(v-message) = p-len .
  set-pointer-value(v-message) = get-pointer-value(p-mem).
  run crc32 ( input 0 , input v-message , input p-len , output p-crc32).
  set-size(v-message) = 0 .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE conproc C-Win
PROCEDURE conproc :
define input param clienthandle as handle.
do
on error undo, return error return-value
:
  define variable v-log as logical   no-undo .

  assign
    v-log = clienthandle :set-read-response-procedure("readproc").
  .

  if v-log <> yes then do:

  end.

  clienthandle :set-socket-option( "SO-LINGER" , "FALSE" ).
  clienthandle :set-socket-option( "TCP-NODELAY" , "TRUE" ).

  find first tt-cli-socket no-lock
    where tt-cli-socket.sock-handle = clienthandle
  no-error .
  if not available tt-cli-socket
  then do:
    create tt-cli-socket.
    assign
      tt-cli-socket.sock-handle = clienthandle
    .
  end.

  assign
    tt-cli-socket.remote-host     = clienthandle :remote-host
    tt-cli-socket.remote-port     = clienthandle :remote-port
    tt-cli-socket.conn-time       = time
    tt-cli-socket.last-conn-time  = tt-cli-socket.conn-time
  .

  run write-log in this-procedure ( substitute( "Установлено соединение. Удаленный хост: &1 , удаленный порт: &2"
                                              , tt-cli-socket.remote-host
                                              , tt-cli-socket.remote-port
                                              )
                                  ) .

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE empty-tt-cli-socket C-Win
PROCEDURE empty-tt-cli-socket :
do
on error undo, return error return-value
:
  empty temp-table tt-cli-socket .
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
  DISPLAY fi-port fi-pos-num fi-pos-type fi-users fi-last-conn-time
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-exit b-start b-help r-semaphore fi-port br-log fi-pos-num
         fi-pos-type fi-users fi-last-conn-time
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mt-serv_get-pos-num C-Win
PROCEDURE mt-serv_get-pos-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define output parameter p-cash-desk-num as integer   no-undo .
do
on error undo, return error return-value
:
  assign
    p-cash-desk-num = p-pos-num
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mt-serv_write-error-message C-Win
PROCEDURE mt-serv_write-error-message :
  define input  parameter p-message     as character no-undo .
  define output parameter p-xml-message as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-xml-message = substitute( '<?xml version="1.0"?><msg><stts>1</stts><errmsg>&1</errmsg></msg>'
                              , p-message
                              )
  .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mt-serv_write-last-conn-time C-Win
PROCEDURE mt-serv_write-last-conn-time :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-string as character no-undo .
do
on error undo, return error return-value
:
  assign
    fi-last-conn-time = p-string
  .
  display
    fi-last-conn-time
  with frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mt-serv_write-user-num C-Win
PROCEDURE mt-serv_write-user-num :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-user-num as integer   no-undo .
do
on error undo, return error return-value
:
  run mt-serv_write-user-str in this-procedure ( substitute( "&1 из &2 работает"
                                                           , p-user-num
                                                           , v-cfg-max-user-num
                                                           )
                                               ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mt-serv_write-user-str C-Win
PROCEDURE mt-serv_write-user-str :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-users as character no-undo .
do
on error undo, return error return-value
:
  assign
    fi-users = p-users
  .
  display
    fi-users
  with frame {&frame-name}.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-disable C-Win
PROCEDURE my-disable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run stop-server in this-procedure .
  run disable_UI in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable C-Win
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  assign
    fi-port            = p-port
    fi-pos-num         = p-pos-num
    fi-pos-type        = {&cd-type-IBS-TH-MOB-full}
    v-cfg-timeout      = 1000
  .


  display
    fi-port
    fi-pos-num
    fi-pos-type
  with frame {&frame-name} in window {&window-name}.

  enable
    b-exit
    b-start
    b-help
    b-prop
    fi-port
    fi-last-conn-time
    fi-users
    br-log
  with frame {&frame-name} in window {&window-name}.

  view {&window-name}.
  run mt-serv_write-user-num in this-procedure ( input 0 ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit C-Win
PROCEDURE proc-b-exit :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-answer  as logical   no-undo .

  run gbl/q-wait.w ( input substitute( "Вы хотите завершить работу ?" )
                   , input false                                         /* p-default-answ */
                   , input 5                                             /* p-timeout      */
                   , output v-answer                                     /* p-answer (сек) */
                   ) .
  if v-answer = true
  then do:
    find first tt-log no-error .
    if available tt-log
    then do:
      run gbl/q-wait.w ( input substitute( "Сохранить лог перед выходом ?" )
                       , input true                                          /* p-default-answ */
                       , input 5                                             /* p-timeout      */
                       , output v-answer                                     /* p-answer (сек) */
                       ) .

      if v-answer = true
      then do:
        run save-log in this-procedure .
      end.
    end.

    empty temp-table tt-cli-socket.
    empty temp-table tt-log.

    apply "close" to this-procedure .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-prop C-Win
PROCEDURE proc-b-prop :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  message "!" view-as alert-box.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-start C-Win
PROCEDURE proc-b-start :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable v-conn-str  as character no-undo .
  define variable v-retval    as logical   no-undo .
  define variable v-port      as integer   no-undo .

  create-block:
  do
  on error undo, return error return-value
  :

    assign
      v-port = fi-port
    .

    assign
      v-conn-str = substitute("-S &1" , v-port)
    .


    create server-socket v-server-socket no-error .
    if error-status :error or not valid-handle (v-server-socket)
    then do:
      message
        "Ошибка при создании серверного сокета!" skip
        error-status :get-message(1) skip
        error-status :get-message(2) skip
        error-status :get-message(3) skip
      view-as alert-box error.
      undo create-block, return error. /* --->>>--- */
    end.

    assign
      v-retval = v-server-socket :enable-connections( v-conn-str )
    .
    if v-retval = no
    then do:
      run write-log in this-procedure ("Ошибка при вызове процедуры enable-connections.").
      undo create-block, return error. /* --->>>--- */
    end.

    assign
      v-retval = v-server-socket :set-connect-procedure( "conproc" )
    .
    if v-retval = no
    then do:
      run write-log in this-procedure ("Ошибка при вызове процедуры set-connect-procedure.").
      undo create-block, return error. /* --->>>--- */
    end.

    run write-log in this-procedure ( substitute(  "Сервер запущен на порте &1." , v-port ) ).

  end.

  assign
    b-start :sensitive in frame {&frame-name} = no
    fi-port :sensitive in frame {&frame-name} = no
    b-stop  :sensitive in frame {&frame-name} = yes
    b-exit  :sensitive in frame {&frame-name} = no
    r-semaphore :bgcolor = GREEN_COLOR
    v-server-running     = true
  .
  run mt-serv_write-user-num ( input 0 ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-stop C-Win
PROCEDURE proc-b-stop :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  define variable v-answer as logical   no-undo .

  run gbl/q-wait.w ( input substitute( "Вы хотите остановить сервер ?" )
                   , input false                                         /* p-default-answ */
                   , input 5                                             /* p-timeout      */
                   , output v-answer                                     /* p-answer (сек) */
                   ) .
  if v-answer = true
  then do:
    run stop-server in this-procedure .
    assign
      b-stop  :sensitive in frame {&frame-name} = no
      b-start :sensitive in frame {&frame-name} = yes
      fi-port :sensitive in frame {&frame-name} = yes
      b-exit  :sensitive in frame {&frame-name} = yes
      r-semaphore :bgcolor = RED_COLOR
    .
    run mt-serv_write-user-num ( input 0 ) .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-check-port C-Win
PROCEDURE proc-check-port :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/* ! */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE readproc C-Win
PROCEDURE readproc :
define buffer buf_tt-cli-socket for tt-cli-socket.
  define variable v-size          as integer    no-undo .
  define variable v-crc32         as int64      no-undo .
  define variable v-func_num      as integer    no-undo .
  define variable v-req_num       as integer    no-undo .
  define variable v-field_num     as integer    no-undo .
  define variable v-text          as character  no-undo .
  define variable v-checked-crc32 as int64      no-undo .
  define variable v-msg-size      as integer    no-undo .
  define variable v-memptr        as memptr     no-undo .
  define variable v-memptrw       as memptr     no-undo .
  define variable v-memptrs       as memptr     no-undo .
  define variable v-msg-str       as longchar   no-undo .
  define variable v-bytes-readed  as integer    no-undo .
  define variable v-log           as logical    no-undo .
  define variable v-sendmemptr    as memptr     no-undo .
  define variable v-sendstr       as longchar   no-undo .
  define variable v-date          as date       no-undo .
  define variable v-time          as integer    no-undo .

do
on error undo, return error return-value
:

  run cur-time in this-procedure ( output v-date
                                 , output v-time
                                 ) .

    run mt-serv_write-last-conn-time in this-procedure ( input substitute( "&1 &2"
                                                                         , v-date
                                                                         , string(v-time, "hh:mm:ss")
                                                                         )
                                                       ) .
    find first buf_tt-cli-socket no-lock
      where buf_tt-cli-socket.sock-handle = self
    no-error .
    if not available buf_tt-cli-socket
    then do:
      return.
    end.

    /* проверяем что клиент не отключился */
    if not self:connected() then do:
      run write-log in this-procedure ( substitute( "Удаленный клиент отключился: &1:&2"
                                                  , buf_tt-cli-socket.remote-host
                                                  , buf_tt-cli-socket.remote-port
                                                  )
                                      ) .
      delete buf_tt-cli-socket.
      return. /* --->>>--- */
    end.

    assign
      buf_tt-cli-socket.last-conn-time  = time
      r-semaphore :bgcolor in frame {&frame-name} = YELLOW_COLOR
    .

    /* читаем шапку сообщения */
    set-size(v-memptr) = 20 .
    self:read(v-memptr,1,20) .
    assign
        v-bytes-readed = self:bytes-read
    .
    /* пока пропускаем */
    if v-bytes-readed < 20
    then do:
        return.
    end.

    /* разбираем поля сообщения */
    assign
      v-size        = get-long(v-memptr,1)
      v-crc32       = get-unsigned-long(v-memptr,5) /*int64(4294967296 + get-long(v-memptr,5))*/
      v-func_num    = get-long(v-memptr,9)
      v-req_num     = get-long(v-memptr,13)
      v-field_num   = get-long(v-memptr,17)
      v-msg-size    =  v-size - 20
    .
    put-long(v-memptr,5) = 0 .

    run check-crc32 in this-procedure ( input v-memptr , 20, output v-checked-crc32) .

    set-size(v-memptr) = 0.

    /* читаем тело сообщения */
    if v-msg-size > 0
    then do:
        set-size(v-memptrs) = v-msg-size .
        self:read(v-memptrs,1,v-msg-size) .
        assign
            v-msg-str = get-string(v-memptrs, 1, v-msg-size)
        .
        set-size(v-memptrs) = 0 .
    end.

    /* отладочные сообщения */
    assign
      v-text =   substitute( "CRC32=&1 , CHECKED=&2"
/*                           , v-size*/
/*                           , v-crc32*/
/*                           , v-func_num*/
/*                           , v-req_num*/
/*                           , v-field_num*/
                           , v-crc32
                           , v-checked-crc32
                           )
    .

    run write-log in this-procedure ( substitute( "&1:&2 &3&4&5 byte recieved : &4&6&4&7&4&6"
                                                , self :remote-host
                                                , self :remote-port
                                                , v-text
                                                , {&new-line}
                                                , self :bytes-read
                                                , fill('-',120)
                                                , v-msg-str
                                                )
                                    ) .
    if valid-handle(v-mt-route-handle) <> true
    then do:
      run gbl/mt-route.p persistent set v-mt-route-handle no-error .
      if error-status :error
      then do:
        run mt-serv_write-error-message in this-procedure ( input "Ошибка при запуске маршрутизатора сообщений mt-route.p":U
                                                          , output v-sendstr
                                                          ) .

      end.
      run mt-route_init in v-mt-route-handle ( input this-procedure
                                             , input p-pos-num
                                             , input v-cfg-max-user-num
                                             , input v-cfg-timeout
                                             ) no-error .
      if error-status :error
      then do:
        run mt-serv_write-error-message in this-procedure ( input "Ошибка установки номера кассы ":U + string(p-pos-num)
                                                          , output v-sendstr
                                                          ) .
      end.
      assign
        v-mt-route-loaded = true
      .
    end.
    if v-mt-route-loaded = true then do:
      run mt-route_process-request in v-mt-route-handle ( input this-procedure
                                                        , input v-req_num
                                                        , input '<?xml version="1.0"?>' + v-msg-str
                                                        , output v-sendstr
                                                        ) no-error .
      if error-status :error
      then do:
        run mt-serv_write-error-message in this-procedure ( input "Ошибка при обработке запроса ":U + string(v-req_num)
                                                          , output v-sendstr
                                                          ) .
      end.
    end.


    set-size(v-sendmemptr) = 20 + length(v-sendstr) + 1 .

    put-long(v-sendmemptr , 1 )   = 20 + length(v-sendstr) .
    put-long(v-sendmemptr , 5 )   = 0 .
    put-long(v-sendmemptr , 9 )   = 0 .
    put-long(v-sendmemptr , 13 )  = 0 .
    put-long(v-sendmemptr , 17 )  = 0 .
    put-string(v-sendmemptr,21)   = v-sendstr .



    v-log = self:write(v-sendmemptr, 1, 20 + length(v-sendstr) ) no-error .
    if error-status :error
    then do:
      message
        error-status :get-message(1) skip
        error-status :get-message(2) skip
        error-status :get-message(3)
      view-as alert-box error.
    end.

    set-size(v-sendmemptr) = 0 .


    run write-log in this-procedure ( substitute("&1 bytes writen: &2&3&2&4&2&3"
                                                , self:BYTES-WRITTEN
                                                , {&new-line}
                                                , fill('-',120)
                                                , v-sendstr
                                                )
                                    ).

    if v-req_num = 13
    then do:
      self:disconnect().
      run write-log in this-procedure ( substitute( "Client disconnected! &1&2&1"
                                                  , {&new-line}
                                                  , fill('*',120)
                                                  )
                                      ).
      delete buf_tt-cli-socket.
    end.

    assign
      r-semaphore :bgcolor in frame {&frame-name} = GREEN_COLOR
    .

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-log C-Win
PROCEDURE save-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
&scop log-file-name "c:\socklog.log":U

  output stream slog to value({&log-file-name}) append.

  for each tt-log :
    put stream slog unformatted tt-log.id " " tt-log.log-date " " tt-log.log-time " " tt-log.log-text skip fill('#',200) skip.
  end.

  output stream slog close.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE stop-server C-Win
PROCEDURE stop-server :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error return-value
:
  for each tt-cli-socket:
    if valid-handle( tt-cli-socket.sock-handle )
    then do:
      tt-cli-socket.sock-handle :disconnect() .
      run write-log in this-procedure ( substitute( "Отключение удаленного пользователя &1:&2"
                                                  , tt-cli-socket.remote-host
                                                  , tt-cli-socket.remote-port
                                                  )
                                      ).
    end.
  end.
  if valid-handle(v-server-socket)
  then do:
    v-server-socket :disable-connections() .
    delete object v-server-socket .
    run write-log in this-procedure ("Сервер остановлен.").
    assign
      v-server-running = false
    .
  end.

  if valid-handle(v-mt-route-handle) = true
  then do:
    delete procedure v-mt-route-handle .
    assign
      v-mt-route-loaded = false
    .

  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log C-Win
PROCEDURE write-log :
define input  parameter p-message as character no-undo .
do
on error undo, return error return-value
:


  define variable v-str as character no-undo .

  assign
    v-str     = string( time , "HH:MM:SS" ) + ">" + trim(p-message)
    v-log-id  = v-log-id + 1
  .

  create tt-log.
  assign
    tt-log.id           = v-log-id
    tt-log.log-date     = today
    tt-log.log-time     = time
    tt-log.log-text     = p-message
  .
  define buffer sch_tt-log for tt-log.

  find last sch_tt-log no-error .
  if available sch_tt-log
  then do:
    open query br-log for each tt-log /*where tt-log.id >= v-log-id - 5*/ indexed-reposition.
    reposition br-log to rowid rowid(sch_tt-log) no-error .
  end.


end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME