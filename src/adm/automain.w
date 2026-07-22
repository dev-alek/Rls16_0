&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME automain
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS automain
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Главное окно запуска автоматических процедур по расписанию

Автор: Уханов Дмитрий Юрьевич
Дата создания: 09/10/02
Author: Dmitry Ukhanov
Creation date: 09/10/02

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter i-auto-type as character no-undo .
define input parameter i-mode      as character no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Главное окно запуска автоматических процедур по расписанию".
define variable mAsyncHelper as class ibs.th.file.AsyncHelperth  no-undo.
{ cmp/vssrevis.i }
{ cmp/trg-def.i new }
{ cmp/showinf.i  }
{ adm/auto-def.i }

{ cmp/library.i  }
{utl/asuncprocauto.i &starterasunc = yes}
&global-define tab-shift 2
{ str/auto2dia.i   (this-procedure:handle) }
{ gbl/getcntxa.i }
{ gbl/mainproc.i def }
{ adm/automain.i }

define variable m-time          as integer   no-undo .
define variable mtoday         as date      no-undo .

define variable log-exit      as logical   no-undo .
define variable writelogtype  as character no-undo .

/*define stream VarStream .                        */
/*define variable v-varstr   as character no-undo .*/
/*define variable v-varfile  as character no-undo .*/
define variable mStart     as logical   no-undo .

define variable mtitle as character no-undo.
define variable mDbNum as integer no-undo.
define variable mDbInfo as character no-undo.
define variable vRun as logical no-undo.
   

define temp-table tt-proc no-undo
  field proc_id as integer
  index pi is unique primary
    proc_id ascending
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME f-amain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-help auto-log
&Scoped-Define DISPLAYED-OBJECTS auto-log curr-date curr-time

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR automain AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из автоматической системы"
     BGCOLOR 8 .

DEFINE BUTTON b-hand DEFAULT
     LABEL "&РРежим"
     SIZE 10 BY 1 TOOLTIP "Ручной режим приема и отправки новостей"
     BGCOLOR 8 .

DEFINE BUTTON b-start DEFAULT
     LABEL "&Запуск"
     SIZE 10 BY 1 TOOLTIP "Запустить один цикл"
     BGCOLOR 8 .


DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON b-prop DEFAULT
     LABEL "&Настройки"
     SIZE 10 BY 1 TOOLTIP "Настройка СПН"
     BGCOLOR 8 .

DEFINE VARIABLE auto-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 96.88 BY 19.75 NO-UNDO.

DEFINE VARIABLE curr-date AS DATE FORMAT "99/99/9999":U
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.

DEFINE VARIABLE curr-time AS CHARACTER FORMAT "X(8)":U
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.

DEFINE VARIABLE f-msg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 63 BY .67
     FGCOLOR 12  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME f-amain
     b-exit AT ROW 1.17 COL 2.25
     b-hand AT ROW 1.17 COL 12.25
     b-prop AT ROW 1.17 COL 22.25
     b-start AT ROW 1.17 COL 32.25
     b-help AT ROW 1.17 COL 89
     auto-log AT ROW 3.38 COL 2.25 NO-LABEL
     f-msg AT ROW 2.5 COL 13 COLON-ALIGNED NO-LABEL
     curr-date AT ROW 2.5 COL 79 NO-LABEL
     curr-time AT ROW 2.5 COL 90.5 NO-LABEL
     "Сообщения:" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 2.5 COL 3
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99.38 BY 22.42.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U and not session:batch-mode THEN
  CREATE WINDOW automain ASSIGN
         HIDDEN             = YES
         TITLE              = ""
         HEIGHT             = 22.75
         WIDTH              = 99.38
         MAX-HEIGHT         = 22.75
         MAX-WIDTH          = 99.38
         VIRTUAL-HEIGHT     = 22.75
         VIRTUAL-WIDTH      = 99.38
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
/* SETTINGS FOR WINDOW automain
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME f-amain
   FRAME-NAME                                                           */
ASSIGN
       auto-log:READ-ONLY IN FRAME f-amain        = TRUE.

/* SETTINGS FOR BUTTON b-hand IN FRAME f-amain
   NO-ENABLE                                                            */
ASSIGN
       b-hand:HIDDEN IN FRAME f-amain           = TRUE.

/* SETTINGS FOR BUTTON b-hand IN FRAME f-amain
   NO-ENABLE                                                            */
ASSIGN
      b-start:HIDDEN IN FRAME f-amain           = TRUE.

/* SETTINGS FOR BUTTON b-prop IN FRAME f-amain
   NO-ENABLE                                                            */
ASSIGN
       b-prop:HIDDEN IN FRAME f-amain           = TRUE.

/* SETTINGS FOR FILL-IN curr-date IN FRAME f-amain
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN curr-time IN FRAME f-amain
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-msg IN FRAME f-amain
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       f-msg:READ-ONLY IN FRAME f-amain        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE({&window-name})
THEN automain:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME f-amain
/* Query rebuild information for FRAME f-amain
     _Query            is NOT OPENED
*/  /* FRAME f-amain */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

if VALID-HANDLE({&window-name}) then
do:
&Scoped-define SELF-NAME automain
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL automain automain
ON END-ERROR OF automain
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL automain automain
ON WINDOW-CLOSE OF automain
DO:
  /* This event will close the window and terminate the procedure.  */
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
end.


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit automain
ON CHOOSE OF b-exit IN FRAME f-amain /* Выход  */
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
      run write-to-log ( substitute( "&1. Ошибка при завершении работы. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) )
                      ).
    end.
    assign
      log-exit = yes
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hand automain
ON CHOOSE OF b-start IN FRAME f-amain /* РРежим */
DO:
   mstart = yes.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hand
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hand automain
ON CHOOSE OF b-hand IN FRAME f-amain /* РРежим */
DO:
  define variable v-auto-old as logical no-undo .
  case i-auto-type
  :
    when {&btpr-type-autonws}
    then do:
        assign
            v-auto-old = g#auto
            g#auto       = FALSE
        .
        run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + {&space-char} ) else "" )
                            + "Запущен ручной режим обмена новостями."
                        ).
        run adm/autoconn.p no-error.
        if error-status :error
        then do:
          run write-to-log (  substitute( "&1. &2&3&4"
                                          ,vss-workfile
                                          ,return-value
                                          ,{&new-line}
                                          ,error-status:get-message(error-status:num-messages)
                                        )
                           ).
          message
            substitute( "&1. &2&3&4"
                        ,vss-workfile
                        ,return-value
                        ,{&new-line}
                        ,error-status:get-message(error-status:num-messages)
                      )
            view-as alert-box .
        end.
        else do:
          run nws/nws-hand.w
            ( input this-procedure:handle
            , input g#auto-user-id
            , input g#auto-user-password
            ) no-error .
          if error-status :error then do:
            run write-to-log
              ( substitute( "&1. &2&3&4"
                            ,vss-workfile
                            ,return-value
                            ,{&new-line}
                            ,error-status:get-message(error-status:num-messages)
                          )
              ).
            message
              substitute( "&1. &2&3&4"
                          ,vss-workfile
                          ,return-value
                          ,{&new-line}
                          ,error-status:get-message(error-status:num-messages)
                        )
              view-as alert-box .
          end.
        end.
        assign
          g#auto = v-auto-old
          hand-log-msg-h = ?
        .
        run write-to-log ( "Закончена работа с ручным режимом обмена новостями."
                            + (if v-auto-old then string( {&space-char} + "Запущен автоматический режим." ) else "")
                        ).

        run gbl/dbdiscon.p no-error.
        if error-status :error then do:
          run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
        end.
        apply "choose" to b-exit in frame {&frame-name}. /* Выход  */
        return no-apply.
    end.        /* when {&btpr-type-autonws} */
    when {&btpr-type-autooxml}
    then do:
        assign
            v-auto-old = g#auto
            g#auto       = FALSE
        .
        run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + {&space-char} ) else "" )
                            + "Запущен ручной режим обмена данными."
                        ).
        run adm/autoconn.p no-error.
        if error-status :error
        then do:
          run write-to-log (  substitute( "&1. &2&3&4"
                                          ,vss-workfile
                                          ,return-value
                                          ,{&new-line}
                                          ,error-status:get-message(error-status:num-messages)
                                        )
                           ).
          message
            substitute( "&1. &2&3&4"
                        ,vss-workfile
                        ,return-value
                        ,{&new-line}
                        ,error-status:get-message(error-status:num-messages)
                      )
            view-as alert-box .
        end.
        else do:
          run bge/oxmlhand.w
            (
             input this-procedure:handle /*parparentproc*/
            ,input this-procedure:handle /*p-log-handle*/
            ,input g#auto-user-id
            ,input g#auto-user-password
            ) no-error .
          if error-status :error then do:
            run write-to-log
              ( substitute( "&1. &2&3&4"
                            ,vss-workfile
                            ,return-value
                            ,{&new-line}
                            ,error-status:get-message(error-status:num-messages)
                          )
              ).
            message
              substitute( "&1. &2&3&4"
                          ,vss-workfile
                          ,return-value
                          ,{&new-line}
                          ,error-status:get-message(error-status:num-messages)
                        )
              view-as alert-box .
          end.
        end.
        assign
          g#auto = v-auto-old
          hand-log-msg-h = ?
        .
        run write-to-log ( "Закончена работа с ручным режимом обмена данными."
                            + (if v-auto-old then string( {&space-char} + "Запущен автоматический режим." ) else "")
                        ).

        run gbl/dbdiscon.p no-error.
        if error-status :error then do:
          run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
        end.
        apply "choose" to b-exit in frame {&frame-name}. /* Выход  */
        return no-apply.
    end.        /* when {&btpr-type-autooxml} */
   end case.     /* case p-auto-type */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop automain
ON CHOOSE OF b-prop IN FRAME f-amain /* Настройки */
DO:
    case i-auto-type
    :
        when {&btpr-type-autonws}
        then do:
            define variable v-auto-old as logical no-undo .

            assign
                v-auto-old = g#auto
                g#auto       = FALSE
            .
            run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + {&space-char} ) else "" )
                                + "Запущен режим настройки СПН."
                            ).
            run adm/autoconn.p no-error.
            if error-status :error
            then do:
                message vss-workfile skip return-value view-as alert-box .
                run write-to-log (  vss-workfile + {&space-char}
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.

            run adm/autoprop.w no-error.

            run nws/nws-init.p no-error.
            if error-status :error
            then do:
                run write-to-log (  vss-workfile + {&new-line}
                                    + "Ошибка инициализации переменных для системы передачи новостей" + {&new-line}
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.

            run gbl/dbdiscon.p no-error.
            if error-status :error then do:
              run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
            end.
            run write-to-log ( "Закончена работа с режимом настройки СПН."
                                + (if v-auto-old then string( {&space-char} + "Запущен автоматический режим." ) else "")
                            ).
            assign
                g#auto = v-auto-old
            .
        end.        /* when {&btpr-type-autonws} */
        when {&btpr-type-autoexp}
        then do:
            message
                "В разработке..."
                skip
            view-as alert-box information.
        end.        /* when {&btpr-type-autoexp} */
        when {&btpr-type-autooxml}
        then do:
            assign
                v-auto-old = g#auto
                g#auto       = FALSE
            .
            run write-to-log ( (if v-auto-old then string("Aвтоматический режим прерван." + {&space-char} ) else "" )
                                + "Запущен режим настройки OpenXML."
                            ).
            run adm/autoconn.p no-error.
            if error-status :error
            then do:
                message vss-workfile skip return-value view-as alert-box .
                run write-to-log (  vss-workfile + {&space-char}
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.

            run adm/autoprop.w no-error.
            run bge/oxml-ini.p no-error.
            if error-status :error
            then do:
                run write-to-log (  vss-workfile + {&new-line}
                                    + "Ошибка инициализации переменных для системы OpenXML" + {&new-line}
                                    + return-value
                                ).
                assign
                g#auto = v-auto-old
                .
                return no-apply.
            end.

            run gbl/dbdiscon.p no-error.
            if error-status :error then do:
              run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
            end.
            run write-to-log ( "Закончена работа с режимом настройки OpenXML."
                                + (if v-auto-old then string( {&space-char} + "Запущен автоматический режим." ) else "")
                            ).
            assign
                g#auto = v-auto-old
            .
        end.        /* when {&btpr-type-autooxml} */

    end case.     /* case p-auto-type */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK automain


/* ***************************  Main Block  *************************** */

/*{ gbl/app_help.i &disable-button=no }*/
{ gbl/app_help.i }

/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
if valid-handle({&window-name}) then
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
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, retry MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, retry MAIN-BLOCK:

/*  define variable v-title               as character no-undo .*/
/*  define variable v-db-info             as character no-undo .*/
/*  define variable v-interval            as integer   no-undo .*/
/*  define variable v-list-db             as character no-undo .*/
/*  define variable v-list-key-all        as character no-undo .*/
/*  define variable v-list-db-all         as character no-undo .*/
/*  define variable v-for-db              as character no-undo .*/
/*                                                              */
/*  define variable v-for-proc            as character no-undo .*/
  define variable start-time            as int64     no-undo .
/*  define variable v-session-begin       as logical   no-undo .*/
/*                                                              */
/*  define variable v-ind                 as integer   no-undo .*/
/*  define variable v-num-entries         as integer   no-undo .*/
/*  define variable v-num-entries-db-list as integer   no-undo .*/
/*  define variable v-rec-key             as character no-undo .*/
/*  define variable v-cre-db-num          as integer   no-undo .*/
/*  define variable v-task-type           as character no-undo .*/
/*  define variable v-task-num            as integer   no-undo .*/
/*  define variable v-db-num              as integer   no-undo .*/
/*  define variable v-log                 as logical   no-undo .*/
/*  define variable v-free-id             as character no-undo. */
/*                                                              */
/*  define variable v-new-hidden-mode     as logical   no-undo .*/

  run initProcMode (i-auto-type,i-mode).

  mAsyncHelper = new ibs.th.file.AsyncHelperth().
  mAsyncHelper:mProcPublish = this-procedure.
  mAsyncHelper:setCurrentUserPasswd().
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:WritelogInter = 5.
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:maxproc    = 1.

  run adm/autoconn.p no-error.
  if error-status :error then do:
    run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) ) ).
  end.
  
  run CheckUpdate no-error.
  if error-status :error then do:
     return error return-value.
  end.
  { gbl/conf-rd.i "'writelog'" "''" "''" 0 "''" "''" "''" no writelogvalue writelogtype no-error }

  run adm/chk-db.p no-error .
  if error-status :error then do:
    run write-to-log (  substitute( "&1. Проверка возможности работы сессии.&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
    run gbl/dbdiscon.p no-error.
    if error-status :error then do:
      run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
    end.
    assign
      log-exit = true
    .
  end.
  else do:
     define variable Vdbinfo as character no-undo.

    run AddUtil(i-auto-type).

    run adm/db-info.p ( output g#db-num, output Vdbinfo ) no-error.
    run gbl/dbdiscon.p no-error.
    if error-status :error then do:
      run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
    end.

    if i-auto-type = {&btpr-type-autonws}
    or i-auto-type = {&btpr-type-autooxml}
    or i-auto-type = {&btpr-type-is_motp}
    or i-auto-type = {&btpr-type-is_diadoc}
    then do:
      assign
        g#auto = false
      .
    end.
    else do:
      assign
        g#auto = true
      .
    end.


    assign
      auto-log-msg-h = auto-log:handle
      auto-window-h = this-procedure:handle
      hand-log-msg-h = ?
    .
    
    if valid-handle({&window-name}) then
      {&window-name}:title = substitute( "PID: &1 &2", g#auto-pid, {&window-name}:title ).
    
    case i-auto-type :
      when {&btpr-type-autonws}
      then do:
        if valid-handle({&window-name}) then
          {&window-name}:title = {&window-name}:title + "Система передачи новостей.".
        g#auto = FALSE.
        run write-to-log ( "Запущена система передачи новостей" ) no-error.
        if error-status:error
        then do:
          run write-to-screen (return-value).
        end.

        if mHiddenMode = false then do:
          run write-to-log ( "Через 5 секунд будет запущен автоматический режим обмена новостями" ) no-error.
          wait-for
            go of frame {&frame-name}
            or close of this-procedure
            or choose of b-hand in frame {&frame-name}
            or choose of b-help in frame {&frame-name}
            or choose of b-prop in frame {&frame-name}
            or choose of b-start in frame {&frame-name}
            focus frame {&frame-name}
            pause 5
            .
          if error-status:error
          then do:
            run write-to-screen (return-value).
          end.
        end.
        if not log-exit
        then do:
          run write-to-log ( "Запущен автоматический режим обмена новостями" ) no-error.
          if error-status:error
          then do:
            run write-to-screen (return-value).
          end.
          assign
            g#auto = TRUE
          .
        end.
      end.
      when {&btpr-type-autoarh}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматического расчета архивов."
        .
        run write-to-log ( "Запущена система автоматического расчета архивов" ).
      end.
      when {&btpr-type-autoexp}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматического экспорта."
        .
        if mHiddenMode = false then do:
          run write-to-log ( "Через 5 секунд будет запущена система автоматического экспорта" ).
          wait-for
            go of frame {&frame-name}
            or close of this-procedure
            or choose of b-hand in frame {&frame-name}
            or choose of b-help in frame {&frame-name}
            or choose of b-prop in frame {&frame-name}
            or choose of b-start in frame {&frame-name}
            focus frame {&frame-name}
            pause 5
            .
        end.
        if not log-exit
        then do:
          run write-to-log ( "Запущена система автоматического экспорта" ).
        end.
      end.
      when {&btpr-type-autooxml}
      then do:
        if valid-handle({&window-name}) then
          {&window-name}:title = {&window-name}:title + "Система OpenXML.".
        g#auto = FALSE.

        .
        run write-to-log ( "Запущена система OpenXML" ).
        if mHiddenMode = false then do:
          run write-to-log ( "Через 5 секунд будет запущен автоматический режим обмена данными" ).
          wait-for
            go of frame {&frame-name}
            or close of this-procedure
            or choose of b-hand in frame {&frame-name}
            or choose of b-help in frame {&frame-name}
            or choose of b-prop in frame {&frame-name}
            or choose of b-start in frame {&frame-name}
            focus frame {&frame-name}
            pause 5
            .
        end.
        if not log-exit
        then do:
          run write-to-log ( "Запущен автоматический режим обмена данныи" ).
          assign
            g#auto = TRUE
          .
        end.
      end.
      when {&btpr-type-is_motp}
   or when {&btpr-type-is_diadoc}
      then do:
        define variable vTitle as character no-undo.
         vTitle = if i-auto-type eq  {&btpr-type-is_diadoc}
                  then "ИС Диадок"
                  else "ИС МОТП.".
        
        assign
          {&window-name}:title = {&window-name}:title + vTitle
/*          g#auto = FALSE*/

        .
        run write-to-log ( "Запущен автоматический режим обмена данныи c " + vTitle).
        
/*        run write-to-log ( "Запущен обмен с " + vTitle ).                                         */
/*        if v-hidden-mode = false then do:                                                         */
/*          run write-to-log ( "Через 5 секунд будет запущен автоматический режим обмена данными" ).*/
/*          wait-for                                                                                */
/*            go of frame {&frame-name}                                                             */
/*            or close of this-procedure                                                            */
/*            or choose of b-hand in frame {&frame-name}                                            */
/*            or choose of b-help in frame {&frame-name}                                            */
/*            or choose of b-prop in frame {&frame-name}                                            */
/*            focus frame {&frame-name}                                                             */
/*            pause 5                                                                               */
/*            .                                                                                     */
/*        end.                                                                                      */
/*        if not log-exit                                                                           */
/*        then do:                                                                                  */
/*          run write-to-log ( "Запущен автоматический режим обмена данныи" ).                      */
/*          assign                                                                                  */
/*            g#auto = TRUE                                                                         */
/*          .                                                                                       */
/*        end.                                                                                      */
      end.
      when {&btpr-type-autogetcd}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматического приема информации с касс."
        .
        run write-to-log ( "Запущена система автоматического приема информации с касс" ).
      end.
      when {&btpr-type-autosuz}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматического запуска отчетов."
        .
        run write-to-log ( "Запущена система автоматического запуска отчетов" ).
      end.
      when {&btpr-type-autosale}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматической работы с документами продажи."
        .
        run write-to-log ( "Запущена система автоматической работы с документами продажи" ).
      end.
      when {&btpr-type-autocbnk}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматического эксп/имп в КЛИЕНТ-БАНК."
        .
        run write-to-log ( "Запущена система автоматического эксп/имп в КЛИЕНТ-БАНК" ).
      end.
      when {&btpr-type-autofree}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Система автоматического выполнения произвольных заданий."
        .
        run write-to-log ( "Запущена система автоматического выполнения произвольных заданий" ).
      end.
      when {&btpr-type-sktsrv}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Сокет-Сервер"
        .
        run write-to-log ( "Запущен Сокет-Сервер" ).
      end.
      when {&btpr-type-mercury}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "ФГИС Меркурий"
        .
        run write-to-log ( "Запущена система Меркурий" ).
      end.
      when {&btpr-type-is_motp}
   or when {&btpr-type-is_diadoc}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + vTitle
        .
        run write-to-log ( "Запущена система " + vTitle).
      end.
      when {&btpr-type-hddtest}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Мониторинг HDD"
        .
        run write-to-log ( "Запущен мониторинг состояний HDD" ).
      end.
      when {&btpr-type-is_PM}
      then do:
        if valid-handle({&window-name}) then
        assign
          {&window-name}:title = {&window-name}:title + "Выгрузка в ИС Президентский Мониторинг"
        .
        run write-to-log ( "Запущена выгрузка в ИС Президентский Мониторинг" ).
      end.
      otherwise do:
        assign
          log-exit = yes
        .
      end.
    end case.
    if valid-handle({&window-name}) then
    assign
      mtitle = {&window-name}:title
    .
    if mForDb <> "":U then do:
      if length(mForDb) > 32000
      then do :
        define variable tmp-str as character no-undo .
        tmp-str = entry(1, mForDb) + "-" + entry(num-entries(mForDb), mForDb) .
        run write-to-log ( substitute( "Сессия работает с БД &1", tmp-str ) ).
      end .
      else do :
        run write-to-log ( substitute( "Сессия работает с БД &1", mForDb ) ).
      end .
    end.
    if mForExtsys <> "":U then do:
      run write-to-log ( substitute( "Сессия работает с Внешними Системами &1", mForExtsys ) ).
    end.
    if mForProc <> "":U then do:
      run write-to-log ( substitute( "Сессия работает с Произвольными заданиями &1", mForProc ) ).
    end.
  end.
  
   main-cycl:
   do while not log-exit
   on error  undo, leave main-cycl
   on stop   undo, next
   on endkey undo, next
   :
      run cur-time( output mtoday
                   ,output m-time
                ) no-error.

      run AddCashParam(i-auto-type, mtoday, m-time).
      vRun = no.
      find first tt-BatchProcess no-lock
       where 
        /*and buf_BatchProcess.CharKey_One       = string( buf_db.db-num )
        and */ ( tt-BatchProcess.BP_ExecSysDate < mtoday
              or (tt-BatchProcess.BP_ExecSysDate = mtoday
                  and tt-BatchProcess.BP_ExecSysTimeInt < m-time
                )
            )
      no-error.
      if available tt-BatchProcess
      then
         vRun = yes.
      else do:
         find first tt-BatchProcess no-lock no-error.
         if not available tt-BatchProcess
         then 
            vRun = yes.
      end.
       
      if    vRun
         or mstart
      then do:
         for each  tt-BatchProcess :
            delete tt-BatchProcess .
         end.
         run adm/autoconn.p no-error.
         if error-status :error 
         then do:
            run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) ) ).
            if valid-handle({&window-name}) then
            assign
               {&window-name}:title = mtitle
            .
         end.
         else do:
            run checkConect (input  if valid-handle({&window-name}) then {&window-name}:title else i-auto-type, 
                             input  i-auto-type,
                             output mDbNum, 
                             output mDbInfo) no-error.
            if error-status:error
            then do:
               if return-value = "WaitOK"
               then
                  next main-cycl .
               else if return-value eq "HandMode" 
               then
                  apply "choose" to b-hand in frame {&frame-name}.
               
               log-exit = true.
               leave main-cycl .
            end.
            
            run CheckUpdate no-error.
            if error-status :error then do:
               run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) ) ).
               return error return-value.
            end.
 
           run adm/chk-sch.p
              ( input  i-auto-type
              , input  mfordb
              , output mlistdb
              , output mlistdball
              , output mlistkey
              , output mlistkeyall
              , input mforextsys
              , input mforproc
              , output table tt-BatchProcess
              ) no-error.
           if error-status :error
           then do:
              run write-to-log( vss-workfile + {&space-char}
                              + "Ошибка при чтении расписания." + {&new-line}
                              + error-status :get-message(error-status :num-messages) + {&new-line}
                              + return-value
                             ) .
              run gbl/dbdiscon.p no-error.
              if error-status :error then do:
                 run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
              end.
              assign
                 log-exit = true
              .
              leave main-cycl .
           end.
   
           
           if valid-handle({&window-name}) then
             {&window-name}:title = mtitle + {&space-char} + mdbinfo.
           
           if mstart
           then
              assign
                 mlistdb  = mlistdball
                 mlistkey = mlistkeyall
              .
           if num-entries( mlistdb ) > 0
           then do:
              run write-to-log ( "Текущая" + {&space-char} + mdbinfo ) no-error.
              if error-status:error
              then do:
                 run write-to-screen (return-value).
              end.
            
                    { gbl/mainproc.i }
              if lookup (i-auto-type , mAsyncHelper:getListTask()) eq 0
              then
                 run startproc (i-auto-type
                               ,mlistdb
                               ,mListKey
                               ,mAsyncHelper:getnowDay()
                             ).
           end.
                          
         find first tt-BatchProcess no-lock
         where 
        /*and buf_BatchProcess.CharKey_One       = string( buf_db.db-num )
        and */ ( tt-BatchProcess.BP_ExecSysDate > mtoday
              or (tt-BatchProcess.BP_ExecSysDate = mtoday
                  and tt-BatchProcess.BP_ExecSysTimeInt > mtime
                )
            )
         no-error.
         if not available tt-BatchProcess
         then do:
            run adm/wr-n-bp.p
              ( input this-procedure:handle
               ,input mSessionBegin
               ,input i-auto-type
               ,input mListDb
               ,input mForExtsys
               ,input mForProc
              ) no-error.
            if error-status :error
            then do:
               run write-to-log( vss-workfile + {&space-char}
                                + "Ошибка при анализе начала следующего сеанса" + {&new-line}
                                + error-status :get-message(error-status :num-messages) + {&new-line}
                                + return-value
                              ) no-error.
               if error-status:error
               then do:
                  run write-to-screen (return-value).
               end.
            end.
            else do:
               assign
                  mSessionBegin = false
               .
            end.
         
            run adm/chk-sch.p
               ( input  i-auto-type
               , input  mfordb
               , output mlistdb
               , output mlistdball
               , output mlistkey
               , output mlistkeyall
               , input mforextsys
               , input mforproc
               , output table tt-BatchProcess
               ) no-error.
            if error-status :error
            then do:
               run write-to-log( vss-workfile + {&space-char}
                             + "Ошибка при чтении расписания." + {&new-line}
                             + error-status :get-message(error-status :num-messages) + {&new-line}
                             + return-value
                           ) .
         
           end.
         end.
         run gbl/dbdiscon.p no-error.
         if error-status :error then do:
           run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ) no-error.
           if error-status:error
           then do:
             run write-to-screen (return-value).
           end.
         end.
         
      end.
   end.
   if mAsyncHelper:isWorkShed()
   then do:
      define variable vListTask as character no-undo.
      vListTask = mAsyncHelper:getListWorkShed().
      run write-to-log ( substitute( "Ожидаем выполнение асихронных процессов: &1.", vListTask) ).
      run waitproc("Ожидаем получение данных").
      run write-to-log ( "Асихронные процессы выполнены .").
   end.
   assign
      start-time = etime
    .
    mStart = no.
    do while not log-exit:
      if mHiddenMode = false then do:
        wait-for
          go of frame {&frame-name}
          or close of this-procedure
          or choose of b-hand in frame {&frame-name}
          or choose of b-help in frame {&frame-name}
          or choose of b-prop in frame {&frame-name}
          or choose of b-start in frame {&frame-name}
          focus frame {&frame-name}
          pause 1
        .
        display
          string( time, "HH:MM:SS" ) @ curr-time
          today @ curr-date
          with frame {&frame-name}
          no-error
        .
      end.
      else do:
        if not session:batch-mode then
          wait-for
            go of frame {&frame-name}
            or close of this-procedure
            pause 1
          .
        else
          pause 1.        
      end.
      if not session:batch-mode then
        run ReedFileContext.
      if mHiddenMode = false
        and frame {&frame-name}:visible = false
      then do:
        run myenable in this-procedure
          ( input i-auto-type
          ) .
      end.
      if mHiddenMode = true
        and frame {&frame-name}:visible = true
      then do:
        run myhide in this-procedure .
      end.
      if    mStart
         or etime - start-time > 60000
         or time mod 60 = 1
      then do:
        leave .
      end.
    end.
    if mHiddenMode = false then do:
      display
        "" @ curr-time
        "" @ curr-date
        with frame {&frame-name}
        no-error
      .
    end.
    
  end.
  delete object mAsyncHelper.
  case i-auto-type :
    when {&btpr-type-autonws}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой передачи новостей" ) no-error.
      if error-status:error
      then do:
        run write-to-screen (return-value).
      end.
    end.
    when {&btpr-type-autoarh}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического расчета архивов" ).
    end.
    when {&btpr-type-autoexp}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического экспорта" ).
    end.
    when {&btpr-type-autooxml}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой OpenXML" ).
    end.
    when {&btpr-type-autogetcd}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического приема информации с кассы" ).
    end.
    when {&btpr-type-autosuz}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматического запуска отчетов" ).
    end.
    when {&btpr-type-autosale}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматической обработки документов продаж" ).
    end.
    when {&btpr-type-autocbnk}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматической эксп/имп в КЛИЕНТ-БАНК" ).
    end.
    when {&btpr-type-sktsrv}
    then do:
      run write-to-log ( "Закончен сеанс работы Сокет-Сервера" ).
    end.
    when {&btpr-type-autofree}
    then do:
      run write-to-log ( "Закончен сеанс работы с системой автоматической выполнения произвольных заданий" ).
    end.
    when {&btpr-type-mercury}
    then do:
      run write-to-log ( "Закончен сеанс работы с ФГИС Меркурий" ).
    end.
    when {&btpr-type-is_motp}
    then do:
      run write-to-log ( "Закончен сеанс работы с ИС МОТП" ).
    end.
    when {&btpr-type-is_diadoc}
    then do:
      run write-to-log ( "Закончен сеанс работы с ИС Диадок" ).
    end.
    otherwise do:
      run write-to-log ( "Закончен сеанс работы с системой ....." ).
    end.
  end case.

  assign
    g#auto = FALSE
  .

  RUN disable_UI.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI automain  _DEFAULT-DISABLE
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
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE({&window-name})
  THEN DELETE WIDGET automain.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI automain  _DEFAULT-ENABLE
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
  DISPLAY auto-log curr-date curr-time
      WITH FRAME f-amain IN WINDOW automain.
  ENABLE b-exit b-help auto-log
      WITH FRAME f-amain IN WINDOW automain.
  {&OPEN-BROWSERS-IN-QUERY-f-amain}
  VIEW automain.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE hide-message automain
PROCEDURE hide-message :
assign
    f-msg = "":U
  .
  if not session:batch-mode then
    hide f-msg in frame {&frame-name}.
  return .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myenable automain
PROCEDURE myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter pe-auto-type as character no-undo .

  IF VALID-HANDLE({&window-name}) THEN
  DO:
  assign
    automain:HIDDEN = false
  .

  run enable_UI.

  if pe-auto-type = {&btpr-type-autonws}
    or pe-auto-type = {&btpr-type-autooxml}
  then do:
    enable b-hand b-prop with frame {&frame-name}.
  end.
  
  if session:debug-alert
  then do:
    enable b-start b-prop with frame {&frame-name}.
  end.
  /*  if    pe-auto-type = {&btpr-type-is_motp}
     or pe-auto-type = {&btpr-type-is_diadoc}
  then do:
    enable b-hand with frame {&frame-name}.
  end. */
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE myhide automain
PROCEDURE myhide :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  disable all with frame {&frame-name} .
  hide all no-pause in window {&window-name} .
  if VALID-HANDLE({&window-name}) then
  assign
    automain:HIDDEN = true
  .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-message automain
PROCEDURE write-message :
define input  parameter p-msg as character no-undo .

  assign
    f-msg = p-msg
  .
  if not session:batch-mode then
  do:
  enable f-msg with frame {&frame-name}.
  if mHiddenMode = false then
  display
    f-msg
    with frame {&frame-name}
    .
  end.
  return .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME