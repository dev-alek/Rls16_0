&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER tt0-rp-by-call FOR ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры экспорта данных продаж по ДК в тест файл

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

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
/*вызывается для задания параметров или перед непосредственнно выполнением*/
/*может быть 'shd' или 'run' */
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.

/*при p-mode = 'run'*/
define input parameter p-action         as character    no-undo.
/**/
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Параметры экспорта данных продаж по ДК в текст файл".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ ref/shd-attr.i }
{ gbl/cur-time.i }
{ cmp/ini-lib.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
DEFINE VARIABLE v-dir AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-file-rule AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-file-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type AS CHARACTER NO-UNDO.
define variable v-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo .
/*
ЛАНТАБ
rule-profile.profile_id = 12
ruleset.codex_id = 5
ruleset.ruleset_id = 1

ЭКСПОРТ XML
rule-profile.profile_id = 20
ruleset.codex_id = 5
ruleset.ruleset_id = 2

*/

define variable v-rule-profile-id as integer no-undo init 12.
define variable v-codex-id as integer no-undo init 5.
define variable v-ruleset-id as integer no-undo init 1.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rule-profile ub.rule X_dis-card-type

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.name ~
X_dis-card-type.type X_dis-card-type.emitent-host-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame X_rule-profile.name ~
X_dis-card-type.emitent-host-code
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame X_rule-profile ~
X_dis-card-type
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define SECOND-ENABLED-TABLE-IN-QUERY-Dialog-Frame X_dis-card-type
&Scoped-define BUFFER-FIELDS-IN-QUERY-Dialog-Frame X_rule.name
&Scoped-define ENABLED-BUFFER-FIELDS-IN-QUERY-Dialog-Frame X_rule.name ~

&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK, ~
      EACH ub.rule WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK, ~
      EACH X_dis-card-type WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK, ~
      EACH ub.rule WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK, ~
      EACH X_dis-card-type WHERE TRUE /* Join to X_rule-profile incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_rule-profile ub.rule ~
X_dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_rule-profile
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.rule
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame X_dis-card-type


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS X_rule-profile.name ub.X_rule.name ~
X_dis-card-type.emitent-host-code
&Scoped-define ENABLED-TABLES X_rule-profile ub.X_rule X_dis-card-type
&Scoped-define FIRST-ENABLED-TABLE X_rule-profile
&Scoped-define SECOND-ENABLED-TABLE ub.X_rule
&Scoped-define THIRD-ENABLED-TABLE X_dis-card-type
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help rs-dir b-dir-sel ~
RS-file-rule b-rule-profile b-param b-dc-type
&Scoped-Define DISPLAYED-FIELDS X_rule-profile.name ub.X_rule.name ~
X_dis-card-type.type X_dis-card-type.emitent-host-code
&Scoped-define DISPLAYED-TABLES X_rule-profile ub.X_rule X_dis-card-type
&Scoped-define FIRST-DISPLAYED-TABLE X_rule-profile
&Scoped-define SECOND-DISPLAYED-TABLE ub.X_rule
&Scoped-define THIRD-DISPLAYED-TABLE X_dis-card-type
&Scoped-Define DISPLAYED-OBJECTS rs-dir v-dir-name RS-file-rule file-name-1 ~
file-seq file-name-2 f-rs-dir-label f-rs-file-rule-label f-seq-label ~
f-file-seq-label-2 f-dc-type-label

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON b-dir-sel
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-param
     LABEL "&Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rule-profile
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.

DEFINE VARIABLE f-dc-type-label AS CHARACTER FORMAT "X(256)":U INITIAL "Тип ДК для экспорта"
      VIEW-AS TEXT
     SIZE 29 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-file-seq-label-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Местоположение счетчика в имени файла"
      VIEW-AS TEXT
     SIZE 38.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-rs-dir-label AS CHARACTER FORMAT "X(256)":U INITIAL "Настройка директории экспорта данных"
      VIEW-AS TEXT
     SIZE 40 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-rs-file-rule-label AS CHARACTER FORMAT "X(256)":U INITIAL "Настройка формирования имени файла экспорта"
      VIEW-AS TEXT
     SIZE 45.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-seq-label AS CHARACTER FORMAT "X(256)":U INITIAL "|"
      VIEW-AS TEXT
     SIZE 2 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE file-name-1 AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя файла"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE file-name-2 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE file-seq AS CHARACTER FORMAT "X(256)":U INITIAL "?"
     VIEW-AS FILL-IN
     SIZE 2 BY 1
     BGCOLOR 8  NO-UNDO.

DEFINE VARIABLE v-dir-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN
     SIZE 82.5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-dir AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "берется из Ini-файла ([schedule-free] dctxt-e_out=)", "ini",
"привязана к строке расписания", "other"
     SIZE 55 BY 2 NO-UNDO.

DEFINE VARIABLE RS-file-rule AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "С помощью наращиваемого счетчика", "seq",
"Постоянное имя", "const"
     SIZE 38 BY 2.27 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      X_rule-profile,
      ub.rule,
      X_dis-card-type SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 94.8
     rs-dir AT ROW 4 COL 2 NO-LABEL
     b-dir-sel AT ROW 5 COL 60
     v-dir-name AT ROW 6.27 COL 13 COLON-ALIGNED
     RS-file-rule AT ROW 8.77 COL 2 NO-LABEL
     file-name-1 AT ROW 8.77 COL 43
     file-seq AT ROW 8.77 COL 66 COLON-ALIGNED NO-LABEL
     file-name-2 AT ROW 8.77 COL 68 COLON-ALIGNED NO-LABEL
     X_rule-profile.name AT ROW 12.2 COL 8 COLON-ALIGNED WIDGET-ID 10
          LABEL "Профайл"
          VIEW-AS FILL-IN
          SIZE 79 BY 1
     b-rule-profile AT ROW 12.27 COL 90 WIDGET-ID 26
     ub.X_rule.name AT ROW 13.27 COL 10 NO-LABEL WIDGET-ID 18
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 79.5 BY 2
     b-param AT ROW 17.53 COL 36 WIDGET-ID 14
     X_dis-card-type.type AT ROW 17.8 COL 2.5 NO-LABEL WIDGET-ID 24
          VIEW-AS FILL-IN
          SIZE 10 BY 1
          BGCOLOR 8
     b-dc-type AT ROW 17.8 COL 13.5 WIDGET-ID 2
     f-rs-dir-label AT ROW 2.77 COL 2.5 COLON-ALIGNED NO-LABEL
     f-rs-file-rule-label AT ROW 7.77 COL 1 COLON-ALIGNED NO-LABEL
     f-seq-label AT ROW 10 COL 68 NO-LABEL
     f-file-seq-label-2 AT ROW 11 COL 50 COLON-ALIGNED NO-LABEL
     f-dc-type-label AT ROW 16.77 COL 2 NO-LABEL WIDGET-ID 6
     X_dis-card-type.emitent-host-code AT ROW 17.8 COL 24.5 COLON-ALIGNED WIDGET-ID 22
          LABEL "Эмитент"
           VIEW-AS TEXT
          SIZE 6 BY .67
     SPACE(65.30) SKIP(3.48)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры экспорта данных по продажам по ДК в текстовый файл"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt0-rp-by-call B "?" NO-UNDO ub rp-by-call
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_dis-card-type B "?" ? ub dis-card-type
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_rule-by-profile B "?" ? ub rule-by-profile
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN X_dis-card-type.emitent-host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-dc-type-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-file-seq-label-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rs-dir-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rs-file-rule-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-seq-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN file-name-1 IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN file-name-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN file-seq IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN X_rule-profile.name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN X_dis-card-type.type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN v-dir-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_rule-profile,ub.rule WHERE Temp-Tables.X_rule-profile ...,Temp-Tables.X_dis-card-type WHERE Temp-Tables.X_rule-profile ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры экспорта данных по продажам по ДК в текстовый файл */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dc-type Dialog-Frame
ON CHOOSE OF b-dc-type IN FRAME Dialog-Frame /* ... */
DO:
  run proc-b-type in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dir-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dir-sel Dialog-Frame
ON CHOOSE OF b-dir-sel IN FRAME Dialog-Frame /* ... */
DO:
  define variable c-dir-name  as character no-undo.
  define variable c-dir-type  as character no-undo.
  define variable l-can-write as logical   no-undo.

  { gbl/stdbtn.i }
  run gbl/dir-sel.p ( output c-dir-name, output c-dir-type, output l-can-write ).
  if c-dir-name = '':U or c-dir-name = ? or
     c-dir-type = '':U or c-dir-type = ? then do:
    return no-apply.
  end.
  if l-can-write <> yes then do:
    message 'Вы не имеете права писать в выбранную директорию:' c-dir-name view-as alert-box error.
    return no-apply.
  end.
  assign  v-dir-name = c-dir-name.
  display v-dir-name with frame {&FRAME-NAME}.

    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-param
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-param Dialog-Frame
ON CHOOSE OF b-param IN FRAME Dialog-Frame /* Параметры */
DO:

    RUN proc-b-param IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
      assign
        p-cancel = yes
    .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule-profile Dialog-Frame
ON CHOOSE OF b-rule-profile IN FRAME Dialog-Frame /* ... */
DO:
  run proc-rule-profile in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-dir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-dir Dialog-Frame
ON VALUE-CHANGED OF rs-dir IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-dir.
  CASE rs-dir:
      WHEN 'ini' THEN DO:
         HIDE
         b-dir-sel
         IN FRAME {&FRAME-NAME}.
      END.
      OTHERWISE DO:
          DISPLAY
          b-dir-sel
          with FRAME {&FRAME-NAME}.
          ENABLE
          b-dir-sel
          with FRAME {&FRAME-NAME}.
     END.
  END CASE.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-file-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-file-rule Dialog-Frame
ON VALUE-CHANGED OF RS-file-rule IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-file-rule.
  CASE rs-file-rule:
      WHEN "seq" THEN DO:
         DISPLAY
         file-name-1
         file-name-2
         file-seq
         f-seq-label
         f-file-seq-label-2
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         file-name-1
         file-name-2
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN "const" THEN DO:
        HIDE
        file-seq
        file-name-2
        f-seq-label
        f-file-seq-label-2
        in FRAME {&FRAME-NAME}.
     END.
  END CASE.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  IF NOT g#db-num = 0  THEN DO:
    MESSAGE
    "Импорт данных по ДК не может быть вызван в УБД"
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  if p-mode = 'shd':U then do:
    assign
    frame {&frame-name} :title = frame {&frame-name} :title +
                      substitute(". &1: Задача номер &2"
                      , p-task-type
                      , p-task-num )
    .
  end.
  run init-param-values in this-procedure (
      input p-cre-db-num
    , input p-task-type
    , input p-task-num
    , output v-rule-profile-id
    , OUTPUT v-dir-name
    ) no-error.
  if error-status :error then undo, return error .
  RUN init-fields in this-procedure no-error.
  if error-status :error then undo, return error .

  RUN Myenable.
  apply "value-changed" to rs-dir.
  apply "value-changed" to rs-file-rule.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE attach-attr-to-schedule-line Dialog-Frame
PROCEDURE attach-attr-to-schedule-line :
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
define buffer buf_schedule      for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.
define buffer lock-batchprocess for ub.batchprocess.

CASE p-mode:
  when 'shd':U then do:
    /*данная конкретная задача может быть ТОЛЬКО ОДНА в одной БД - отследим*/
      /*заблокируем*/
      run gbl/lock-prc.p
          (input {&lock-prc-schd-free}
          ,input 'dctxt-e':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
                  "Экспорт данных продаж по ДК в текстовый файл"
                )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .

      FIND FIRST buf_schedule-attr NO-LOCK WHERE
                 buf_schedule-attr.cre-db-num = p-cre-db-num
             and buf_schedule-attr.task-type  = p-task-type
             and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'dctxt-e') NO-ERROR.
      IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN DO:
        MESSAGE
        substitute("Уже есть расписание для экспорта данных продаж по ДК номер расписания &1"
                   ,buf_schedule-attr.task-num
                  )
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
      find first buf_schedule no-lock
           where buf_schedule.cre-db-num = p-cre-db-num
             and buf_schedule.task-type  = p-task-type
             and buf_schedule.task-num   = p-task-num
      no-error.
      if not available buf_schedule
      and (  p-task-type   <> {&btpr-type-autofree}
          or p-task-num    <> -1 )
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Не найдена строка расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.

    run schedule-attr-write in this-procedure (
          input p-cre-db-num
        , input p-task-type
        , input p-task-num
        , input {&attr-schedule-param-list-h}
        , input p-param-list
    ).
  end.
  when 'run':U then do:
    p-params = p-param-list.
  end.
END CASE.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY rs-dir v-dir-name RS-file-rule file-name-1 file-seq file-name-2
          f-rs-dir-label f-rs-file-rule-label f-seq-label f-file-seq-label-2
          f-dc-type-label
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_dis-card-type THEN
    DISPLAY X_dis-card-type.type X_dis-card-type.emitent-host-code
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule THEN
    DISPLAY X_rule.name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule-profile THEN
    DISPLAY X_rule-profile.name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rs-dir b-dir-sel RS-file-rule X_rule-profile.name
         b-rule-profile X_rule.name b-param b-dc-type
         X_dis-card-type.emitent-host-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
DEFINE VARIABLE v-out AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS logical NO-UNDO.
ASSIGN
rs-dir = (if v-dir = 'ini' then v-dir else 'other').
IF rs-dir = "ini":u THEN DO:
    run verify-ini-entry in this-procedure (
                                         INPUT  'dctxt-e_out'
                                        ,INPUT  'schedule-free'
                                        ,INPUT substitute("отсутствует параметр &1 секция &2 в ini-файле"
                                                          , 'dctxt-e_out'
                                                          , 'schedule-free')
                                        ,INPUT no
                                        ,output v-out) no-error .
    if error-status:error or v-out = ? then return error return-value .
    RUN verify-file in this-procedure
                                      (input v-out
                                      ,input substitute("Не найден каталог &1 параметр &2, секция &3 ini-файла"
                                                    , v-out
                                                    , 'schedule-free'
                                                   , 'dctxt-e_out')
                                      ,input no
                                      ,output glog) no-error.
    if error-status:error or not glog then return error return-value .
  v-dir-name = v-out.
END.
ELSE DO:
    RUN verify-file in this-procedure
                                      (input v-dir
                                      ,input substitute("Не найден каталог &1"
                                                    , v-dir
                                                    )
                                      ,input no
                                      ,output glog) no-error.
    if error-status:error or not glog then do:
      v-dir-name = "".
    end.
    else do:
      v-dir-name = v-dir.
   end.
END.
ASSIGN
rs-file-rule = v-file-rule
file-name-1 = ENTRY(1, v-file-name, {&question-mark})
file-name-2 = (IF NUM-ENTRIES(v-file-name, {&question-mark}) > 1
               AND rs-file-rule = "seq"
               THEN ENTRY(2, v-file-name, {&question-mark})
               ELSE '':U)
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
do
on error undo, return error
:
define input parameter p-cre-db-num as integer   no-undo .
define input parameter p-task-type  as character    no-undo.
define input parameter p-task-num   as integer      no-undo.
define output parameter p-profile-id as integer  no-undo.
define output parameter p-dir       as character    no-undo.
define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable ii as integer   no-undo .
define variable v-entry  as character no-undo .
define variable v-task-num as integer   no-undo .
define variable v-other-params as character no-undo .
define variable v-local-rule-profile-id as integer no-undo.
define buffer buf_schedule for ub.schedule.
define buffer buf_schedule-attr for ub.schedule-attr.

  CASE p-mode:
    when 'shd':U then do:
      if p-task-num > 0 then do:
        v-task-num = p-task-num.
      end.
      else do:
        for each buf_schedule no-lock where
                buf_schedule.cre-db-num = p-cre-db-num
            AND buf_schedule.task-type = p-task-type,
            first buf_schedule-attr no-lock where
                  buf_schedule-attr.cre-db-num = p-cre-db-num
              AND buf_schedule-attr.task-type = p-task-type
              AND buf_schedule-attr.task-num = buf_schedule.task-num
              AND buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'dctxt-e') :
           v-task-num = buf_schedule.task-num.
           leave .
        end.
      end.
      if v-task-num > 0 then do:
        run schedule-attr-value in this-procedure (
              input p-cre-db-num
            , input p-task-type
            , input v-task-num
            , input {&attr-schedule-param-list-h}
            , output v-param-list
            , output v-param-type
        ) NO-ERROR.
      end.
      if v-param-list = '':U then
      v-param-list = string(12) + {&delim-par} + 'ini' + {&delim-par} + "seq" + {&delim-par} + "f?.txt" + {&delim-par}.
    END.
    WHEN 'run' THEN DO:
      assign
      v-param-list = string(12) + {&delim-par} + 'ini' + {&delim-par} + "seq" + {&delim-par} + "f?.txt" + {&delim-par}.
    END.
  END CASE.
  ASSIGN
  v-local-rule-profile-id = integer(entry(1, v-param-list, {&delim-par}))
  v-dir = entry(2, v-param-list, {&delim-par})
  v-file-rule = entry(3, v-param-list, {&delim-par})
  v-file-name = entry(4, v-param-list, {&delim-par})
  v-emitent-host-code = 0
  v-dc-type = entry(1, entry(5, v-param-list, {&delim-par}))
  v-other-params = v-param-list
  .
  ENTRY(1, v-other-params, {&delim-par}) = '':U.
  ENTRY(2, v-other-params, {&delim-par}) = '':U.
  ENTRY(3, v-other-params, {&delim-par}) = '':U.
  ENTRY(4, v-other-params, {&delim-par}) = '':U.
  v-other-params = substring(v-other-params, 5).
  run set-rule-profile in this-procedure ( input v-local-rule-profile-id) no-error.
  if error-status:error then undo, return error.
  p-profile-id = v-local-rule-profile-id.
  IF v-dc-type <> '':U THEN DO:
    run set-dc-type in this-procedure ( input v-other-params
                                       ,input v-dc-type
                                       ,input v-emitent-host-code).

  END.

END. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
CASE p-mode:
    WHEN 'run':U THEN DO:
        ASSIGN
        rs-dir:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                             = "берется из Ini-файла ([schedule-free] dctxt-e_out=)" + {&comma-char} +
                               "ini":U + {&comma-char} +
                               "задать директорию экспорта" + {&comma-char} +
                               "other".
    END.
    WHEN 'shd':U THEN DO:
        ASSIGN
        rs-dir:RADIO-BUTTONS = "берется из Ini-файла ([schedule-free] dctxt-e_out=)" + {&comma-char} +
                               "ini":U + {&comma-char} +
                               "привязываются  к строке расписания" + {&comma-char} +
                               "other".

    END.
END CASE.

DISPLAY
rs-dir
f-rs-dir-label
v-dir-name
rs-file-rule
file-name-1
f-rs-file-rule-label
(if available X_rule-profile then X_rule-profile.name else '') @ X_rule-profile.name
(if available X_dis-card-type then X_Dis-card-type.type else '') @ X_dis-card-type.type
X_rule.name when available X_rule
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
B-Help
rs-dir
b-dir-sel WHEN rs-dir <> 'Ini':U
RS-file-rule
b-dc-type
b-rule-profile
b-param
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
{&OPEN-QUERY-br-salelist}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-param Dialog-Frame
PROCEDURE proc-b-param :
/*вызываем интерфейс */
define variable v-param-form as character no-undo .
define variable v-list-mode as character no-undo .
define buffer buf_rule-profile for ub.rule-profile.
find first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = X_rp-by-call.profile_id.
assign
v-param-form = (if buf_rule-profile.custom-param-form > 0
                then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                else "ref/rulercps.w")
v-list-mode = (if buf_rule-profile.custom-param-form > 0
               then {&table_rp-by-call}
               else {&table_rule-call-param})
.
run value(v-param-form) (
                     input parparentproc
                    ,input this-procedure:handle
                    ,input "b-chg":U
                    ,input {&update} /*p-mode*/
                    ,input v-list-mode
                    ,input 0 /*profile_id */
                    ,input ? /*once-more*/
                    ,input X_rp-by-call.call_id /*p-call-id*/
                    ,input X_rule-by-profile.codex_id /*p-codex-id*/
                    ,input X_rule-by-profile.ruleset_id /*p-codex-id*/
                    ,input ? /*p-order-id*/
                    ,input X_rule-by-profile.RULE_id /*p-rule-id*/
                    ,INput substitute("Правило &1 &2", X_rule-by-profile.RULE_id, calldscr(X_rp-by-call.call_id))  /**/
                    ,input-output table tt0-rule-call-param  ) no-error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-type Dialog-Frame
PROCEDURE proc-b-type :
define variable v-rid-list as character no-undo.
DEFINE BUFFER buf_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
define buffer buf_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.

IF AVAILABLE X_rp-by-call THEN DO:
   ASSIGN
   v-rid-list = STRING(RECID(X_rp-by-call)).
END.
/*выводим список привязок к данному профайлу*/
run rul/rp-by-call-s.w ( INPUT parparentproc
                        ,INPUT "b-sel":U
                        ,INPUT "profile-id"
                        ,INPUT X_rule-by-profile.profile_id
                        ,INPUT '':U /*p-profile-type*/
                        ,input '' /*p-uniq-key-rec*/
                        ,input 0 /*p-codex-id*/
                        ,input 0 /*p-ruleset-id*/
                        ,INPUT-OUTPUT v-rid-list
                        ) NO-ERROR.

if v-rid-list = "" then return error.
find first buf_rp-by-call no-lock where
          recid(buf_rp-by-call) = integer(v-rid-list) no-error.
if not available buf_rp-by-call then do:
  message
  substitute("Не найдена привязка правила rp-by-call с recid &1" , v-rid-list)
  view-as alert-box error .
  return.
end.
FIND FIRST X_rp-by-call WHERE RECID(X_rp-by-call) = RECID(buf_rp-by-call).
/*надо найти все rule-call-param для данного типа ДК и показать в БРОУЗЕ  с возможностью изменения*/
FIND FIRST X_dis-card-type WHERE
        X_dis-card-type.uniq-key-rec = buf_rp-by-call.call_id.
display
X_dis-card-type.type
X_dis-card-type.emitent-host-code
with frame {&frame-name}.
FOR EACH buf_tt0-rule-call-param:
  DELETE buf_tt0-rule-call-param.
END.
for each buf_Rule-call-param no-lock where
      buf_rule-call-param.call#_id = X_rp-by-call.call#_id
 and  buf_rule-call-param.codex_id = X_rule-by-profile.codex_id
 and  buf_rule-call-param.ruleset_id = X_rule-by-profile.ruleset_id
 and  buf_rule-call-param.rule_id = X_rule-by-profile.rule_id:
create buf_tt0-rule-call-param.
buffer-copy buf_rule-call-param to buf_tt0-rule-call-param.
end.
RUN proc-b-param IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-rule-profile Dialog-Frame
PROCEDURE proc-rule-profile :
define variable v-rid-list as character no-undo .
 define buffer buf_rule-profile for ub.rule-profile.

  do
  on error undo, return error return-value
  :
   find first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = v-rule-profile-id no-error.
   if available buf_rule-profile then do:
      assign
      v-rid-list = string(recid(buf_rule-profile)).
   end.
   run rul/rule-profile-s.w (
                          input parparentproc
                        , input 'b-sel' /*bttns*/
                        , input "general-view"
                        , input {&table_dis-card-type}
                        , input-output v-rid-list ) no-error.
    if v-rid-list <> '':U
    and v-rid-list <> string(recid(buf_rule-profile)) then do:
      find first buf_rule-profile no-lock where
               recid(buf_rule-profile) = integer(v-rid-list) no-error.
      if available buf_rule-profile then do:
        run set-rule-profile in this-procedure ( input buf_rule-profile.profile_id).
      end.

    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-file-name AS CHARACTER NO-UNDO.
define variable v-dop-file-name as character no-undo .
define variable ii as integer   no-undo .
define variable v-exists as logical no-undo .
DEFINE VARIABLE v-other-param AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
ASSIGN
FRAME {&frame-name}
rs-dir
rs-file-rule
file-name-1
file-name-2 WHEN file-name-2:VISIBLE IN FRAME {&FRAME-NAME}
.
if X_dis-card-type.type:screen-value  = '':u  then do:
 message
 "Не задан тип ДК для экспорта"
 view-as alert-box error .
 return error.

end.

IF rs-dir <> 'ini' THEN DO:
    ASSIGN
    v-dir-name.
    RUN verify-file in this-procedure
                                      ( input v-dir-name
                                      , input substitute("Не найден каталог &1"
                                                    , v-dir-name)
                                      ,input no
                                      ,output glog) no-error.
   if error-status:error or not glog then do:
       v-dir-name = '':U.
    end.
    else
    v-dir-name = v-dir.
END.
    /*здесь же пишем в параметры для вызова из системы */
CASE rs-file-rule:
    WHEN "seq":U THEN DO:
      ASSIGN
      v-file-name = file-name-1 + {&question-mark} + file-name-2.
    END.
    WHEN "const":U THEN DO:
      ASSIGN
      v-file-name = file-name-1.
    END.
END CASE.
v-dop-file-name = replace(v-file-name, {&question-mark}, '':U).
/*проверим имя на валидность*/
do ii = 1 to length({&file-name-invalid-char}):
  if index(v-dop-file-name, substring({&file-name-invalid-char}, ii, 1)) > 0 then do:
    message
    substitute("Введенное имя файла содержит недопустимый символ &1", substring({&file-name-invalid-char}, ii, 1))
    view-as alert-box error .
    return error.
  end.
end.
if trim(v-dop-file-name) = '':U then do:
 message
 "Не задано имя файла для экспорта"
 view-as alert-box error .
 return error.
end.
FOR EACH buf_tt0-rule-call-param
BY buf_tt0-rule-call-param.param-num:
  ASSIGN
  v-other-param = v-other-param + (IF buf_tt0-rule-call-param.param-num = 1
                                   THEN '':U
                                   ELSE {&delim-par}) +
  SUBSTITUTE("&1",  BUFFER buf_tt0-rule-call-param:HANDLE:BUFFER-FIELD(SUBSTITUTE("param-value-&1"
                                                                                  , buf_tt0-rule-call-param.param-data-type)):BUFFER-VALUE).
END.
ASSIGN
v-param-list = ( string(v-rule-profile-id) + {&delim-par} +
                IF rs-dir = 'ini' THEN 'ini' ELSE v-dir-name) + {&delim-par} +
               rs-file-rule + {&delim-par} +
                v-file-name + {&delim-par} +
                X_dis-card-type.type:SCREEN-VALUE + {&delim-par} +
                v-other-param.
IF p-mode = 'shd' THEN DO:
    run attach-attr-to-schedule-line in this-procedure (
                                                         INPUT v-param-list
    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-dc-type Dialog-Frame
PROCEDURE set-dc-type :
define input parameter p-other-params as character no-undo.
define input parameter p-dc-type as character no-undo.
define input parameter p-emitent-host-code as integer no-undo.
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-local-rule-profile-id as integer no-undo.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define buffer buf_rule-call-param for ub.rule-call-param.



      FIND FIRST X_dis-card-type NO-LOCK WHERE
                X_dis-card-type.emitent-host-code = p-emitent-host-code
          AND   X_dis-card-type.type = p-dc-type
          AND X_dis-card-type.host-code = 0
          AND X_dis-card-type.obj-type = '':U
          AND X_dis-card-type.obj-code = 0 NO-ERROR.
    IF NOT AVAILABLE X_dis-card-type  THEN DO:
      MESSAGE
      substitute("Неизвестный тип ДК &1 эмитент &2"
                 , v-dc-type
                 , v-emitent-host-code)
      VIEW-AS ALERT-BOX ERROR.
      return.
    END.
    FIND FIRST X_rp-by-call NO-LOCK WHERE
              X_rp-by-call.profile_id = v-rule-profile-id
        AND   X_rp-by-call.call_id = X_dis-card-type.uniq-key-rec NO-ERROR.
    IF NOT AVAILABLE X_rp-by-call THEN DO:
        MESSAGE
        substitute("Тип ДК &1 эмитент &2 не привязан к профайлу импорта-экспорта в текстовый файл"
                   , p-dc-type
                   , p-emitent-host-code)
        VIEW-AS ALERT-BOX ERROR.
        RETURN .
    END.
    find X_rule-by-call where
        X_rule-by-call.call#_id = X_rp-by-call.call#_id
     and X_rule-by-call.rule_id = X_rule-by-profile.rule_id
     and X_rule-by-call.profile_id = X_rule-by-profile.profile_id no-error .
    if ambiguous X_rule-by-call then do:
      /*надо выбрать какой*/
      message
      "Выберите какой вызов правила Вас необходим"
      view-as alert-box .
      run rul/rule-by-call-s.w ( input parparentproc
                                ,input "b-sel"
                                ,input "call_id"
                                ,input X_rp-by-call.call_id
                                ,input X_rule-by-profile.codex_id
                                ,input X_rule-by-profile.ruleset_id
                                ,input X_rule-by-profile.rule_id
                                ,input-output v-rid-list) no-error .
      if v-rid-list = '':u then do:
        UNDO, RETURN ERROR.
      end.
      find first X_rule-by-call no-lock where
                recid(X_rule-by-call) = integer(v-rid-list) no-error .
      if not available X_rule-by-call then do:
        UNDO, RETURN ERROR.
      end.
    end.
    FOR each buf_Rule-call-param no-lock where
          buf_rule-call-param.call#_id = X_rp-by-call.call#_id
     and  buf_rule-call-param.codex_id = X_rule-by-profile.codex_id
     and  buf_rule-call-param.ruleset_id = X_rule-by-profile.ruleset_id
     and  buf_rule-call-param.order_id = X_rule-by-call.order_id :
      create buf_tt0-rule-call-param.
      buffer-copy buf_rule-call-param to buf_tt0-rule-call-param.
      CASE buf_rule-call-param.param-data-type:
        WHEN {&abl-datatype-character} THEN DO:
           ASSIGN
           buf_tt0-rule-call-param.param-value-character = ENTRY(buf_tt0-rule-call-param.param-num, p-other-params, {&delim-par})
           NO-ERROR.
        END.
        WHEN {&abl-datatype-date} THEN DO:
           ASSIGN
           buf_tt0-rule-call-param.param-value-date = IF entry(buf_tt0-rule-call-param.param-num, p-other-params, {&delim-par}) = {&question-mark}
                                                      THEN ?
                                                      ELSE DATE(ENTRY(buf_tt0-rule-call-param.param-num, p-other-params, {&delim-par}))
           NO-ERROR.
        END.
        WHEN {&abl-datatype-decimal} THEN DO:
           ASSIGN
           buf_tt0-rule-call-param.param-value-decimal = decimal(ENTRY(buf_tt0-rule-call-param.param-num, p-other-params, {&delim-par}))
           NO-ERROR.
        END.
        WHEN {&abl-datatype-integer} THEN DO:
           ASSIGN
           buf_tt0-rule-call-param.param-value-integer = integer(ENTRY(buf_tt0-rule-call-param.param-num, p-other-params, {&delim-par}))
           NO-ERROR.
        END.
        WHEN {&abl-datatype-logical} THEN DO:
           ASSIGN
           buf_tt0-rule-call-param.param-value-logical = logical(ENTRY(buf_tt0-rule-call-param.param-num, p-other-params, {&delim-par}))
           NO-ERROR.
        END.
      END CASE.
      IF ERROR-STATUS:ERROR THEN DO:
         MESSAGE
         substitute("Некорректное значение параметра &1=&2"
                    ,buf_tt0-rule-call-param.param-label
                    ,BUFFER buf_tt0-rule-call-param:HANDLE:BUFFER-FIELD(substitute("param-value-&1", buf_tt0-rule-call-param.param-data-type)):buffer-value)
         VIEW-AS ALERT-BOX ERROR.
         UNDO, RETURN .
      END.
      if buf_tt0-rule-call-param.param-2-data-type <> '':U then do:
        assign
        v-ok = no
        v-value-character = buf_tt0-rule-call-param.param-value-character
        v-value-date = buf_tt0-rule-call-param.param-value-date
        v-value-decimal = buf_tt0-rule-call-param.param-value-decimal
        v-value-integer = buf_tt0-rule-call-param.param-value-integer
        v-value-logical = buf_tt0-rule-call-param.param-value-logical
        .

        run ref/rule-dtt.p (
                            input ? /*parparentproc для verify не должен быть нужен*/
                            ,input {&verify}
                            ,input {&table_dis-card-type}
                            ,input buf_tt0-rule-call-param.param-data-type
                            ,input buf_tt0-rule-call-param.param-2-data-type
                            ,input buf_tt0-rule-call-param.param-3-data-type
                            ,input buf_tt0-rule-call-param.p-index
                            ,input-output v-value-character
                            ,input-output v-value-date
                            ,input-output v-value-decimal
                            ,input-output v-value-integer
                            ,input-output v-value-logical
                            ,output v-ok
                            ) no-error.
        if error-status:error
        or not v-ok then do:
          undo,  return error substitute("Неверное значение параметра № &1(&8) для вызова правила &2:&3" +
                                              "точка вызова &4, кодекс &5, набор правил &6, порядок вызова &7"
                                              , buf_tt0-rule-call-param.param-num
                                              , tt0-rule-call-param.rule_id
                                              , {&new-line}
                                              , X_dis-card-type.uniq-key-rec
                                              , tt0-rule-call-param.codex_id
                                              , tt0-rule-call-param.ruleset_id
                                              , tt0-rule-call-param.order_id
                                              , buf_tt0-rule-call-param.param-name
                                              ).
        end.
      end. /*if buf_tt0-rule-call-param.param-2-data-type <>  '':U then do:*/
    end.
    assign
    v-dc-type = p-dc-type
    v-emitent-host-code = p-emitent-host-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-rule-profile Dialog-Frame
PROCEDURE set-rule-profile :
define input parameter p-profile-id as integer no-undo.
define buffer buf_rule-profile for ub.rule-profile.
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rule for ub.rule.
  FIND FIRST buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile_id = p-profile-id NO-ERROR.
  IF NOT AVAILABLE buf_rule-profile THEN DO:
     MESSAGE
     "Не найден профайл для работы экспорта в текстовый файл"
      VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  FIND FIRST buf_rule-by-profile NO-LOCK WHERE
          buf_rule-by-profile.profile_id = p-profile-id
      AND buf_rule-by-profile.codex_id = v-codex-id
      AND buf_rule-by-profile.ruleset_id = v-ruleset-id NO-ERROR.
  IF NOT AVAILABLE buf_rule-by-profile THEN DO:
     MESSAGE
     "Не найдено или неопределено правило для импорта из текстового файла"
      VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
  FIND FIRST buf_rule NO-LOCK WHERE
        buf_rule.rule_id = buf_rule-by-profile.rule_id no-error.
  IF NOT AVAILABLE buf_rule THEN DO:
     MESSAGE
     substitute("Не найдено правило &1 для импорта из текстового файла", buf_rule-by-profile.rule_id)
      VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
find first X_rule-profile no-lock where
        recid(X_rule-profile) = recid(buf_rule-profile).
find first X_rule-by-profile no-lock where
        recid(X_rule-by-profile) = recid(buf_rule-by-profile).
find first X_rule no-lock where
        recid(X_rule) = recid(buf_rule).
v-rule-profile-id = p-profile-id.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
