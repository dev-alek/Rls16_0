&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Окно запуска сервера обработки запросов

Автор: Хныкин Павел Андреевич
Дата создания:
Author: Pavel Khnykin
Creation date:

create: Перваков Михаил Сергеевич
Дата создания: 08/22/05

no_app_help.i
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
define input  parameter p-auto-start    as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно запуска сервера обработки запросов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/sys-time.i }
{ gbl/color.i    }
{ cmp/trg-def.i new }

define variable v-rtusrnum as integer   no-undo .
define variable v-rtexpdt  as date      no-undo .

/* Local Variable Definitions ---                                       */

define stream sinp .
define stream sout .

define variable v-server-running     as logical   no-undo .
define variable v-rt-reply-handle    as handle    no-undo .
define variable v-stop-server        as logical   no-undo .
define variable v-full-dir-name      as character no-undo .
define variable v-directory-in       as character no-undo .
define variable v-directory-out      as character no-undo .
define variable v-description-number as integer   no-undo .

define variable v-cntxt-db-num        as integer   no-undo .
define variable v-cntxt-user-id       as character no-undo .
define variable v-cntxt-level         as character no-undo .
define variable v-cntxt-host-code-obj as integer   no-undo .
define variable v-cntxt-obj-type      as character no-undo .
define variable v-cntxt-obj-code      as integer   no-undo .
define variable v-cntxt-db-num-obj    as integer   no-undo .
define variable v-cntxt-is-admin      as logical   no-undo .
define variable v-cntxt-report-num    as integer   no-undo .

define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_user-login for ub.user-login .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-start b-stop fi-directory b-sel-dir ~
fi-description-01 fi-description-02 fi-description-03 fi-description-04
&Scoped-Define DISPLAYED-OBJECTS fi-directory fi-description-01 ~
fi-description-02 fi-description-03 fi-description-04 fi-message-01 ~
fi-message-02 fi-message-03 fi-message-04 fi-message-05 fi-message-06 ~
fi-message-07 fi-message-08 fi-message-09 fi-message-10 fi-message-11 ~
fi-message-12

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

DEFINE BUTTON b-sel-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-start DEFAULT
     LABEL "Ста&рт"
     SIZE 10 BY 1.

DEFINE BUTTON b-stop
     LABEL "Сто&п"
     SIZE 10 BY 1.

DEFINE VARIABLE fi-description-01 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-description-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 85.5 BY .67 NO-UNDO.

DEFINE VARIABLE fi-directory AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория обмена запросами"
     VIEW-AS FILL-IN
     SIZE 56 BY 1 NO-UNDO.

DEFINE VARIABLE fi-message-01 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-02 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-03 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-04 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-05 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-06 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-07 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-08 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-09 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-10 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-11 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.

DEFINE VARIABLE fi-message-12 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89 BY .67 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     b-exit AT ROW 1 COL 1
     b-start AT ROW 1 COL 11
     b-stop AT ROW 1 COL 21
     fi-directory AT ROW 2 COL 30 COLON-ALIGNED
     b-sel-dir AT ROW 2 COL 88
     fi-description-01 AT ROW 3.5 COL 2 NO-LABEL
     fi-description-02 AT ROW 4.5 COL 2 NO-LABEL
     fi-description-03 AT ROW 5.5 COL 2 NO-LABEL
     fi-description-04 AT ROW 6.5 COL 2 NO-LABEL
     fi-message-01 AT ROW 9.5 COL 2 NO-LABEL
     fi-message-02 AT ROW 10.5 COL 2 NO-LABEL
     fi-message-03 AT ROW 11.5 COL 2 NO-LABEL
     fi-message-04 AT ROW 12.5 COL 2 NO-LABEL
     fi-message-05 AT ROW 13.5 COL 2 NO-LABEL
     fi-message-06 AT ROW 14.5 COL 2 NO-LABEL
     fi-message-07 AT ROW 15.5 COL 2 NO-LABEL
     fi-message-08 AT ROW 16.5 COL 2 NO-LABEL
     fi-message-09 AT ROW 17.5 COL 2 NO-LABEL
     fi-message-10 AT ROW 18.5 COL 2 NO-LABEL
     fi-message-11 AT ROW 19.5 COL 2 NO-LABEL
     fi-message-12 AT ROW 20.5 COL 2 NO-LABEL
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 97.13 BY 20.21
         DEFAULT-BUTTON b-start.


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
         TITLE              = "Сервер обработки запросов"
         HEIGHT             = 20.21
         WIDTH              = 97.13
         MAX-HEIGHT         = 20.21
         MAX-WIDTH          = 97.13
         VIRTUAL-HEIGHT     = 20.21
         VIRTUAL-WIDTH      = 97.13
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
/* SETTINGS FOR FILL-IN fi-description-01 IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-02 IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-03 IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-description-04 IN FRAME DEFAULT-FRAME
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN fi-message-01 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-02 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-03 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-04 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-05 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-06 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-07 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-08 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-09 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-10 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-11 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-message-12 IN FRAME DEFAULT-FRAME
   NO-ENABLE ALIGN-L                                                    */
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = no.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Сервер обработки запросов */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Сервер обработки запросов */
DO:
  /* This event will close the window and terminate the procedure.  */
  if v-server-running <> true
  then do:
    apply "close":u to this-procedure.
  end.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit C-Win
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME /* Выход */
DO:
  if v-server-running <> true
  then do:
    apply 'close':u to this-procedure .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-dir C-Win
ON CHOOSE OF b-sel-dir IN FRAME DEFAULT-FRAME
DO:
  define variable v-dir-name  as character no-undo .
  define variable v-dir-type  as character no-undo .
  define variable v-can-write as logical   no-undo .

  run gbl/dir-sel.p
    (output v-dir-name
    ,output v-dir-type
    ,output v-can-write
    ) .

  if v-dir-name <> ""
  then do:
    assign
      fi-directory :screen-value = v-dir-name
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-start C-Win
ON CHOOSE OF b-start IN FRAME DEFAULT-FRAME /* Старт */
DO:

  if v-server-running <> true
  then do:
    if fi-directory :screen-value = ""
    then do:
      message
        "Задайте директорию обмена запросами" skip
        view-as alert-box information .
      apply 'entry':u to fi-directory .
      return no-apply .
    end.

    assign
      file-info :file-name = fi-directory :screen-value
    .
    assign
      v-full-dir-name = file-info :full-pathname
    .

    if v-full-dir-name = ?
    or v-full-dir-name = ""
    then do:
      message
        "Ошибка задания директории" skip
        "" fi-directory :screen-value skip
        view-as alert-box error .
      apply 'entry':u to fi-directory .
      return no-apply .
    end.

    assign
      v-directory-in  = v-full-dir-name + '/' + 'in':u
      v-directory-out = v-full-dir-name + '/' + 'out':u
    .

    run gbl/dir-cre.p
      (input  v-directory-in
      ) .
    run gbl/dir-cre.p
      (input  v-directory-out
      ) .

    assign
      v-server-running = true
      v-stop-server    = false
    .

    assign
      b-exit  :sensitive      = false
      b-start :sensitive      = false
      b-stop  :sensitive      = true
      b-sel-dir :sensitive    = false
      fi-directory :read-only = true
    .
    assign
      fi-description-01 :screen-value = "Сервер запускается"
    .

    run gbl/req-serv.p
      (input this-procedure :handle
      ,input v-directory-in
      ,input v-directory-out
      ) no-error .
    if error-status :error
    then do:
      message
        "Ошибка при запуске программы req-serv.p" skip
        error-status :get-message(1) skip
        return-value
        view-as alert-box error .
    end.

    if valid-handle(v-rt-reply-handle) = true
    then do:
      delete procedure v-rt-reply-handle .
    end.

    assign
      fi-description-01 :screen-value = ""
    .

    assign
      b-exit  :sensitive      = true
      b-start :sensitive      = true
      b-stop  :sensitive      = false
      b-sel-dir :sensitive    = true
      fi-directory :read-only = false
    .

    assign
      v-server-running = false
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-stop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-stop C-Win
ON CHOOSE OF b-stop IN FRAME DEFAULT-FRAME /* Стоп */
DO:
  define variable v-ok as logical   no-undo .

  if v-server-running = true
  then do:
    if v-stop-server = false
    then do:
      message
        "Остановить сервер обработки запросов" skip
        "Продолжить?" skip
        view-as alert-box question buttons yes-no update v-ok .
      if v-ok = true
      then do:
        assign
          v-stop-server = true
        .
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win


/* ***************************  Main Block  *************************** */

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:


  RUN enable_UI.

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
    v-rtusrnum = integer(v-rtusrnum-chr) no-error
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
    assign
      v-rtexpdt = date(01/01/5000)
    .
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

  assign
    fi-description-02 :screen-value = substitute("Максимальное количество пользователей &1", v-rtusrnum )
    fi-description-03 :screen-value = substitute("Срок окончания лицензии &1", string(v-rtexpdt, '99/99/9999'))
  .

  if v-rtexpdt - today < 15
  then do:
    assign
      fi-description-04 :screen-value = substitute("ВНИМАНИЕ!!! До окончания лиценизии осталось &1 дней", v-rtexpdt - today)
    .
  end.

  define buffer rtexch-lock_batchprocess for ub.batchprocess .

  /* блокировка процедуры восстановления складского архива */
  run gbl/lock-prc.p
    (input {&lock-prc-rtexch}
    ,input 0
    ,input 0
    ,input 0
    ,input ""
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
      "Сервер обработки запросов радиотерминала уже запущен" skip
      "Невозможно запустить второй сервер обработки запросов для той-же базы данных" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return . /* --->>>--- */
  end.

  assign
    v-cntxt-report-num = dynamic-next-value( "next-report":U, "ubflt":U) .
  .

  do with frame {&frame-name}
  :
    assign
      b-stop  :sensitive = false
    .

    define variable v-exch-dir as character no-undo .

    get-key-value section 'radio-terminal' key 'exch-dir' value v-exch-dir .
    if v-exch-dir = ?
    then do:
      message
        'Отсутствует ключ exch-dir в секции radio-terminal в progress.ini'
        view-as alert-box error .
    end.
    else do:
      assign
        fi-directory :screen-value = v-exch-dir
      .
    end.

    apply 'entry':u to fi-directory .

    assign
      v-description-number = 0
    .

    if p-auto-start = true
    then do:
      apply 'choose':u to b-start .
    end.
  end.

  IF NOT THIS-PROCEDURE:PERSISTENT THEN
    WAIT-FOR CLOSE OF THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY fi-directory fi-description-01 fi-description-02 fi-description-03
          fi-description-04 fi-message-01 fi-message-02 fi-message-03
          fi-message-04 fi-message-05 fi-message-06 fi-message-07 fi-message-08
          fi-message-09 fi-message-10 fi-message-11 fi-message-12
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-exit b-start b-stop fi-directory b-sel-dir fi-description-01
         fi-description-02 fi-description-03 fi-description-04
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-utc-time-string C-Win
PROCEDURE get-utc-time-string :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-utc-time as character no-undo .

  define variable v-year         as integer   no-undo .
  define variable v-month        as integer   no-undo .
  define variable v-day          as integer   no-undo .
  define variable v-hour         as integer   no-undo .
  define variable v-minute       as integer   no-undo .
  define variable v-second       as integer   no-undo .
  define variable v-milliseconds as integer   no-undo .

  do
  on error undo, return error return-value
  :
    run sys-time_get-sys in this-procedure
      (output v-year
      ,output v-month
      ,output v-day
      ,output v-hour
      ,output v-minute
      ,output v-second
      ,output v-milliseconds
      ) .

    assign
      p-utc-time  = 'UTC ':u
                  + string(v-year,         '9999':u)
                  + '/':u
                  + string(v-month,        '99':u)
                  + '/':u
                  + string(v-day,          '99':u)
                  + ' ':u
                  + string(v-hour,         '99':u)
                  + ':':u
                  + string(v-minute,       '99':u)
                  + ':':u
                  + string(v-second,       '99':u)
                  + ' ':u
                  + string(v-milliseconds, '999':u)
    .

  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_check-stop C-Win
PROCEDURE w-reqsrv_check-stop :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-stop-server as logical   no-undo .

  do
  on error undo, return error return-value
  :
    process events .
    assign
      p-stop-server = v-stop-server
    .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_process-request C-Win
PROCEDURE w-reqsrv_process-request :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-file-name as character no-undo .

  do
  on error undo, return error return-value
  :
    if valid-handle(v-rt-reply-handle) <> true
    then do:
      run gbl/rt-reply.p persistent set v-rt-reply-handle
        (input v-rtusrnum
        ,input v-rtexpdt
        ).
    end.

    run rt-reply_process-request in v-rt-reply-handle
      (input  this-procedure
      ,input  v-directory-in
      ,input  v-directory-out
      ,input  p-file-name
      ) no-error .
    if error-status :error
    then do:
      define variable v-utc-time as character no-undo .
      run get-utc-time-string in this-procedure
        (output v-utc-time
        ) .

      run w-reqsrv_show-request in this-procedure
        (input substitute('&1 error &2':u
                         ,p-file-name
                         ,return-value
                         )
        ) .

      output stream sout to value(v-full-dir-name + '/':u + 'w-reqsrv.err':u ) append .
      put stream sout unformatted v-utc-time + ' ' + p-file-name .
      put stream sout unformatted "Ошибка при обработке запроса" + {&new-line} .
      put stream sout unformatted error-status :get-message(1) + {&new-line} .
      put stream sout unformatted return-value + {&new-line} .

      define variable v-read-string as character no-undo .
      input stream sinp from value(v-directory-in + '/' + p-file-name) .
      repeat
      :
        assign
          v-read-string = '':u
        .
        import stream sinp unformatted v-read-string .
        put stream sout unformatted v-read-string + {&new-line} .
      end.
      input stream sinp close .

      output stream sout close .

      define variable v-temp-file-name  as character no-undo .
      define variable v-error-file-name as character no-undo .

      assign
        v-temp-file-name  = entry(1, p-file-name, '.':u) + '.tmp':u
        v-error-file-name = entry(1, p-file-name, '.':u) + '.err':u
      .

      output stream sout to value(v-directory-out + '/':u + v-temp-file-name) .
      put stream sout "error" .
      output stream sout close .

      os-delete value(v-directory-out + '/':u + v-error-file-name) .
      os-rename value(v-directory-out + '/':u + v-temp-file-name)
                value(v-directory-out + '/':u + v-error-file-name)
                .
    end.

    os-delete value(v-directory-in + '/' + p-file-name) .

    view frame DEFAULT-FRAME
      .
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_show-description C-Win
PROCEDURE w-reqsrv_show-description :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-description as character no-undo .

  do with frame {&frame-name}
  :
    assign
      fi-description-01 :screen-value = p-description
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_show-request C-Win
PROCEDURE w-reqsrv_show-request :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-request-data as character no-undo .

  define variable v-ok as logical   no-undo .


  define variable v-utc-time as character no-undo .
  define variable v-message  as character no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      run get-utc-time-string in this-procedure
        (output v-utc-time
        ) .

      assign
        v-message = v-utc-time
                  + " "
                  + p-request-data
      .

      assign
        v-description-number = v-description-number + 1
      .
      if v-description-number < 1
      or v-description-number > 12
      then do:
        assign
          v-description-number = 1
        .
      end.

      define variable v-display-handle as widget-handle no-undo .
      define variable v-hide-handle    as widget-handle no-undo .

      case v-description-number
      :
        when 1
        then do:
          assign
            v-display-handle = fi-message-01 :handle
            v-hide-handle    = fi-message-12 :handle
          .
        end.
        when 2
        then do:
          assign
            v-display-handle = fi-message-02 :handle
            v-hide-handle    = fi-message-01 :handle
          .
        end.
        when 3
        then do:
          assign
            v-display-handle = fi-message-03 :handle
            v-hide-handle    = fi-message-02 :handle
          .
        end.
        when 4
        then do:
          assign
            v-display-handle = fi-message-04 :handle
            v-hide-handle    = fi-message-03 :handle
          .
        end.
        when 5
        then do:
          assign
            v-display-handle = fi-message-05 :handle
            v-hide-handle    = fi-message-04 :handle
          .
        end.
        when 6
        then do:
          assign
            v-display-handle = fi-message-06 :handle
            v-hide-handle    = fi-message-05 :handle
          .
        end.
        when 7
        then do:
          assign
            v-display-handle = fi-message-07 :handle
            v-hide-handle    = fi-message-06 :handle
          .
        end.
        when 8
        then do:
          assign
            v-display-handle = fi-message-08 :handle
            v-hide-handle    = fi-message-07 :handle
          .
        end.
        when 9
        then do:
          assign
            v-display-handle = fi-message-09 :handle
            v-hide-handle    = fi-message-08 :handle
          .
        end.
        when 10
        then do:
          assign
            v-display-handle = fi-message-10 :handle
            v-hide-handle    = fi-message-09 :handle
          .
        end.
        when 11
        then do:
          assign
            v-display-handle = fi-message-11 :handle
            v-hide-handle    = fi-message-10 :handle
          .
        end.
        when 12
        then do:
          assign
            v-display-handle = fi-message-12 :handle
            v-hide-handle    = fi-message-11 :handle
          .
        end.

      end case .

      assign
        v-display-handle :screen-value = v-message
        v-display-handle :fgcolor      = WHITE_COLOR
        v-display-handle :bgcolor      = BLUE_COLOR
        v-hide-handle    :fgcolor      = BROWN_COLOR
        v-hide-handle    :bgcolor      = GREY_COLOR
      .
    end.
    process events .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mainmenu_getcntxt C-Win
PROCEDURE mainmenu_getcntxt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:

  хук
-------------------------------------------------------------*/
  define output parameter p-cntxt-db-num        as integer   no-undo .
  define output parameter p-cntxt-user-id       as character no-undo .
  define output parameter p-cntxt-level         as character no-undo .
  define output parameter p-cntxt-host-code-obj as integer   no-undo .
  define output parameter p-cntxt-obj-type      as character no-undo .
  define output parameter p-cntxt-obj-code      as integer   no-undo .
  define output parameter p-cntxt-db-num-obj    as integer   no-undo .
  define output parameter p-cntxt-is-admin      as logical   no-undo .

  do on error undo, return error return-value
  :
    assign
      p-cntxt-db-num         = v-cntxt-db-num
      p-cntxt-user-id        = v-cntxt-user-id
      p-cntxt-level          = v-cntxt-level
      p-cntxt-host-code-obj  = v-cntxt-host-code-obj
      p-cntxt-obj-type       = v-cntxt-obj-type
      p-cntxt-obj-code       = v-cntxt-obj-code
      p-cntxt-db-num-obj     = v-cntxt-db-num-obj
      p-cntxt-is-admin       = v-cntxt-is-admin
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-report-num C-Win
PROCEDURE get-report-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-report-num as integer no-undo .

  do
  on error undo, return error
  :
    assign
      p-report-num = v-cntxt-report-num

    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_setcntxt C-Win
PROCEDURE w-reqsrv_setcntxt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input parameter p-cntxt-db-num        as integer   no-undo .
  define input parameter p-cntxt-user-id       as character no-undo .
  define input parameter p-cntxt-level         as character no-undo .
  define input parameter p-cntxt-host-code-obj as integer   no-undo .
  define input parameter p-cntxt-obj-type      as character no-undo .
  define input parameter p-cntxt-obj-code      as integer   no-undo .
  define input parameter p-cntxt-db-num-obj    as integer   no-undo .
  define input parameter p-cntxt-is-admin      as logical   no-undo .

  do on error undo, return error return-value
  :
    /* разрешаем выставлять только контекст объекта! */
    if p-cntxt-level <> {&cntxt-object} then do:
      run w-reqsrv_clrcntxt in this-procedure .
      return .
    end.
    assign
      v-cntxt-db-num         = p-cntxt-db-num
      v-cntxt-user-id        = p-cntxt-user-id
      v-cntxt-level          = p-cntxt-level
      v-cntxt-host-code-obj  = p-cntxt-host-code-obj
      v-cntxt-obj-type       = p-cntxt-obj-type
      v-cntxt-obj-code       = p-cntxt-obj-code
      v-cntxt-db-num-obj     = p-cntxt-db-num-obj
      v-cntxt-is-admin       = p-cntxt-is-admin
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_clrcntxt C-Win
PROCEDURE w-reqsrv_clrcntxt :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  do on error undo, return error return-value
  :
    assign
      v-cntxt-db-num         = buf_sys-ctrl.db-num
      v-cntxt-user-id        = buf_user-login.user-id
      v-cntxt-level          = {&cntxt-global}
      v-cntxt-host-code-obj  = 0
      v-cntxt-obj-type       = ''
      v-cntxt-obj-code       = 0
      v-cntxt-db-num-obj     = 0
      v-cntxt-is-admin       = no
    .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-userid C-Win
PROCEDURE get-userid :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-user-id as character    no-undo .

  do
  on error undo, return error
  :
    assign
      p-user-id = v-cntxt-user-id
    .
  end.

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE w-reqsrv_print-log C-Win
PROCEDURE w-reqsrv_print-log :
/* Callback процедура печати лога */
  define input  parameter p-msg as character no-undo .

  define variable v-message   as character no-undo .
  define variable v-utc-time  as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-message = trim(p-msg)
  .
  if v-message <> ? and v-message <> ''
  then do:
    run get-utc-time-string in this-procedure ( output v-utc-time ) .
    output stream sout to value(v-full-dir-name + '/':u + 'w-reqsrv.err':u ) append .
    put stream sout unformatted substitute("&1 &2" , v-utc-time , v-message ) .
    output stream sout close.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-db-num C-Win
PROCEDURE get-db-num :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define output parameter p-cntxt-db-num as integer   no-undo .
  do

  on error undo, return error return-value
  :
    assign
      p-cntxt-db-num = buf_sys-ctrl.db-num
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE is-radioterminal C-Win
PROCEDURE is-radioterminal :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
  Это Радио-Терминал или другая штука требующая работы без messageй и контекста
-------------------------------------------------------------*/
  define output parameter p-ask as logical   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-ask = true
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME