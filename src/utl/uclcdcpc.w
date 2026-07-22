&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
DEFINE TEMP-TABLE sample NO-UNDO LIKE ub.dis-card-type-attr.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет скидок и категорий по картам в соответствии с алгоритмом - задание параметров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/12/05
Author: Bakhtadze Natalya
Creation date: 09/12/05

*/


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
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Пересчет скидки по картам в соответствии с алгоритмом - задание параметров" .
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cmp/dc-list.i dc-list def "new shared" }
{ gbl/waitfram.i }
{ ref/shd-attr.i }
{ gbl/cur-time.i }
{ gbl/key-rec.i }
{ gbl/updtruls.i }
{ cmp/mrk-strr.i }
{ utl/uclcdcft.i }
{ rul/calldscr.i }
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.

/*для взятия и клания в sht-attr*/
DEFINE VARIABLE v-algo-field-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-update-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-list-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type-list-mode AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dc-type-algo-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.

&scop LABEL-clmn_2 "Место вызова обсчета"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-rule-by-call

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt0-rule-by-call

/* Definitions for BROWSE BR-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-BR-rule-by-call mark-string(ROWID(tt0-rule-by-call), v-rid-list) calldscr(tt0-rule-by-call.call_id) tt0-rule-by-call.can-calc tt0-rule-by-call.is_dynamic tt0-rule-by-call.codex_id tt0-rule-by-call.ruleset_id tt0-rule-by-call.order_id tt0-rule-by-call.rule_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rule-by-call
&Scoped-define SELF-NAME BR-rule-by-call
&Scoped-define QUERY-STRING-BR-rule-by-call FOR EACH tt0-rule-by-call NO-LOCK WHERE         tt0-rule-by-call.codex_id = 2      AND tt0-rule-by-call.ruleset_id = 5      AND tt0-rule-by-call.can-calc = YES INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-rule-by-call OPEN QUERY {&SELF-NAME} FOR EACH tt0-rule-by-call NO-LOCK WHERE         tt0-rule-by-call.codex_id = 2      AND tt0-rule-by-call.ruleset_id = 5      AND tt0-rule-by-call.can-calc = YES INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-rule-by-call tt0-rule-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rule-by-call tt0-rule-by-call


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-rule-by-call}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-lst B-Help RS-dc-list-mode ~
RS-dc-type-list-mode Rs-update-mode E-dc-type B-mark BR-rule-by-call ~
editor-1 mark-num
&Scoped-Define DISPLAYED-OBJECTS RS-dc-list-mode RS-dc-type-list-mode ~
Rs-update-mode E-dc-type editor-1 f-dc-type-label mark-num

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

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lst
     LABEL "Список ДК"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE E-dc-type AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 18.5 BY 5.27 NO-UNDO.

DEFINE VARIABLE editor-1 AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.4 NO-UNDO.

DEFINE VARIABLE f-dc-type-label AS CHARACTER FORMAT "X(256)":U INITIAL "Список типов ДК"
      VIEW-AS TEXT
     SIZE 15.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 10  NO-UNDO.

DEFINE VARIABLE RS-dc-list-mode AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "По списку ДК", "LIST",
"Все карты, подлежащ.расчету", "ALL"
     SIZE 30.5 BY 2 NO-UNDO.

DEFINE VARIABLE RS-dc-type-list-mode AS CHARACTER INITIAL "*"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все типы", "*",
"Список", "list"
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-update-mode AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Проверка-0 (по итогу по ВСЕМ фирмам)", "check-0",
"Расчет (с сохранением)", "update",
"Проверка-1 (по сумме итогов по фирмам)", "check-1",
"Проверка-2 (по суммам итогов по объектам)", "check-2",
"Проверка-3 (по платежам)", "check-3",
"Проверка-4 (по документам)", "check-4"
     SIZE 43.5 BY 5.27 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rule-by-call FOR
      tt0-rule-by-call SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rule-by-call Dialog-Frame _FREEFORM
  QUERY BR-rule-by-call NO-LOCK DISPLAY
      mark-string(ROWID(tt0-rule-by-call), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U WIDTH 2
calldscr(tt0-rule-by-call.call_id) COLUMN-LABEL {&label-clmn_2} FORMAT "X(60)":U WIDTH 28
tt0-rule-by-call.can-calc COLUMN-LABEL "Включен?" FORMAT "+/":U
tt0-rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
tt0-rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>9":U WIDTH 7
tt0-rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>9":U width 7
tt0-rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
tt0-rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>>>>>>9":U WIDTH 9
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 11
         TITLE "Алгоритмы для расчета" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     b-lst AT ROW 1 COL 80
     B-Help AT ROW 1 COL 95
     RS-dc-list-mode AT ROW 2 COL 46.5 NO-LABEL
     RS-dc-type-list-mode AT ROW 2 COL 79.5 NO-LABEL
     b-dc-type AT ROW 3 COL 95.5
     Rs-update-mode AT ROW 3.07 COL 2 NO-LABEL
     E-dc-type AT ROW 4 COL 80 NO-LABEL
     B-mark AT ROW 8.5 COL 1
     BR-rule-by-call AT ROW 9.5 COL 1
     editor-1 AT ROW 20.73 COL 1 NO-LABEL WIDGET-ID 4
     f-dc-type-label AT ROW 3.27 COL 80 NO-LABEL
     mark-num AT ROW 8.5 COL 3 COLON-ALIGNED NO-LABEL
     "Отбор карт" VIEW-AS TEXT
          SIZE 15 BY 1 AT ROW 1 COL 46 WIDGET-ID 2
          FGCOLOR 4
     "Режим работы" VIEW-AS TEXT
          SIZE 35 BY 1 AT ROW 2.07 COL 2
          FGCOLOR 4
     SPACE(62.25) SKIP(20.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Пересчет скидки/категории ДК в соответствии алгоритмами, заданными для типов ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_dis-card-type B "?" ? ub dis-card-type
      TABLE: sample T "?" NO-UNDO ub dis-card-type-attr
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-rule-by-call B-mark Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-dc-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       E-dc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       editor-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-dc-type-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rule-by-call
/* Query rebuild information for BROWSE BR-rule-by-call
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt0-rule-by-call NO-LOCK WHERE
        tt0-rule-by-call.codex_id = 2
     AND tt0-rule-by-call.ruleset_id = 5
     AND tt0-rule-by-call.can-calc = YES INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-rule-by-call */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Пересчет скидки/категории ДК в соответствии алгоритмами, заданными для типов ДК */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dc-type Dialog-Frame
ON CHOOSE OF b-dc-type IN FRAME Dialog-Frame /* ... */
DO:
  define variable var-rid-str  as character no-undo.
  DEFINE VARIABLE ii AS INTEGER NO-UNDO.
  DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
  DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
    { gbl/stdbtn.i }
  run ref/dc-types.w (
               input parparentproc
              ,input "":U
              ,INPUT "b-sel,b-mark":U
              ,INPUT 0 /*emitent-host-code*/
              ,INPUT 0 /*parhost-code*/
              ,INPUT '':U /*parobj-code*/
              ,INPUT 0 /*parobj-code*/
              ,input-output var-rid-str) .
  IF var-rid-str = '':u  THEN RETURN NO-APPLY.
 e-dc-type:SCREEN-VALUE = '':U.
 v-dc-type-list = ''.
 FOR EACH buf_tt0-rule-by-call:
     DELETE buf_tt0-rule-by-call.
 END.
  DO ii = 1 TO NUM-ENTRIES(var-rid-str):
    FIND FIRST buf_dis-card-type NO-LOCK WHERE
                recid(buf_dis-card-type) = INTEGER(ENTRY(ii, var-rid-str)) NO-ERROR.
     IF NOT AVAILABLE buf_dis-card-type THEN DO:
         RETURN NO-APPLY.
     END.
     e-dc-type:SCREEN-VALUE = e-dc-type:SCREEN-VALUE + (IF ii = 1 THEN '':U ELSE {&NEW-LINE}) +
                              buf_dis-card-type.TYPE.
      v-dc-type-list = v-dc-type-list + (IF v-dc-type-list = '':U THEN '' ELSE {&comma-char}) + buf_dis-card-type.TYPE.
  END.
  RUN fill-table IN THIS-PROCEDURE (  input v-dc-type-list-mode
                                     ,input v-dc-type-list
                                     ,input yes ).
  RUN openbr IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  DEFINE VARIABLE num-rec as integer no-undo.
  define VARIABLE num-rec-ok as integer no-undo.
  DEFine VARIABLE II AS INTEGER NO-UNDO.
  define variable glog as logical no-undo .
  define variable v-curr-r-b as character no-undo .
  { gbl/curr-r-b.i
    v-curr-r-b
  }
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  IF p-mode = "run" THEN DO:
      message
        "В выбранных соглано уловиям дисконтных картах будут пересчитаны скидки/категории"
        "в соответствии с алгоритмом, заданным по типу карты" SKIP
        "Продолжать?"
        view-as alert-box QUESTION buttons YES-NO update glog.
        IF not glog then return no-apply.
        run str/diallog.w ( INPUT parparentproc
                    , INPUT this-procedure
                    , INPUT 'utl/dcpcuq1.p':U
                    , INPUT v-param-list
                    , INPUT  no /*p-auto-go*/
                    , INPUT "&Стоп"
                    , INPUT 'Пересчет скидки/категории ДК в соответствии алгоритмами, заданными для типов ДК') .


  END.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lst
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lst Dialog-Frame
ON CHOOSE OF b-lst IN FRAME Dialog-Frame /* Список ДК */
DO:
   run str/dc-list.w ( input parparentproc
                     , input v-cntxt-host-code-obj
                     , input v-cntxt-obj-type
                     , input v-cntxt-obj-code).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  define variable loc#log as logical no-undo .
  if available tt0-rule-by-call then do:
    { gbl/markstrn.i tt0-rule-by-call v-rid-list ROWID(TT0-rule-by-call) }
    loc#log = br-rule-by-call:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-rule-by-call:select-next-row ().
        apply "VALUE-CHANGED" to br-rule-by-call in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-rule-by-call in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rule-by-call
&Scoped-define SELF-NAME BR-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-rule-by-call Dialog-Frame
ON VALUE-CHANGED OF BR-rule-by-call IN FRAME Dialog-Frame /* Алгоритмы для расчета */
DO:
DEFINE VARIABLE v-dop AS CHARACTER NO-UNDO.
IF AVAILABLE tt0-rule-by-call THEN DO:
   editor-1:SCREEN-VALUE = tt0-rule-by-call.algo-des.
END.
ELSE DO:
   editor-1:SCREEN-VALUE  = '':U.
END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-dc-list-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-dc-list-mode Dialog-Frame
ON VALUE-CHANGED OF RS-dc-list-mode IN FRAME Dialog-Frame
DO:
  ASSIGN
   rs-dc-list-mode.
  CASE rs-dc-list-mode:
      WHEN 'list' THEN DO:
         ENABLE
         b-lst
         WITH FRAME {&FRAME-NAME}.
      END.
      WHEN 'all' THEN DO:
          disable
          b-lst
          WITH FRAME {&FRAME-NAME}.

      END.

  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-dc-type-list-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-dc-type-list-mode Dialog-Frame
ON VALUE-CHANGED OF RS-dc-type-list-mode IN FRAME Dialog-Frame
DO:
define BUFFER BUF_TT0-rule-by-call for tt0-rule-by-call.
  ASSIGN
  rs-dc-type-list-mode
  v-dc-type-list-mode = rs-dc-type-list-mode
  .
  CASE rs-dc-type-LIST-MODE:
      WHEN "*":U THEN DO:
        e-dc-type:SCREEN-VALUE = '':U.
        DISABLE
        b-dc-type
        WITH FRAME {&FRAME-NAME}.
        RUN fill-table IN THIS-PROCEDURE (  input v-dc-type-list-mode
                                          ,input v-dc-type-list
                                          ,input yes ).

      END.
      WHEN "list" THEN DO:
          ENABLE
          b-dc-type
          WITH FRAME {&FRAME-NAME}.
          FOR EACH buf_tt0-rule-by-call :
              DELETE buf_tt0-rule-by-call.
          END.
    END.
  END CASE.
  RUN openbr IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-update-mode
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-update-mode Dialog-Frame
ON VALUE-CHANGED OF Rs-update-mode IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-update-mode.
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
    , OUTPUT v-param-list).
  RUN init-fields in this-procedure .
  FOR EACH tt0-rule-by-call:
    DELETE tt0-rule-by-call.
  END.
  RUN fill-table IN THIS-PROCEDURE (  input v-dc-type-list-mode
                                     ,input v-dc-type-list
                                     ,input yes ).
  RUN Myenable in this-procedure .

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

CASE p-mode:
  when 'shd':U then do:
      FIND FIRST buf_schedule-attr NO-LOCK WHERE
                 buf_schedule-attr.cre-db-num = p-cre-db-num
             and buf_schedule-attr.task-type  = p-task-type
             and buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'uclcdcpc') NO-ERROR.
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
  DISPLAY RS-dc-list-mode RS-dc-type-list-mode Rs-update-mode E-dc-type editor-1
          f-dc-type-label mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-lst B-Help RS-dc-list-mode RS-dc-type-list-mode
         Rs-update-mode E-dc-type B-mark BR-rule-by-call editor-1 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
DEFINE VARIABLE v-out AS CHARACTER NO-UNDO.
define variable ii as integer no-undo .
DEFINE VARIABLE glog AS logical NO-UNDO.
define variable v-tbl-row as rowid no-undo .
ASSIGN
rs-update-mode = v-update-mode
rs-dc-list-mode = v-dc-list-mode
rs-dc-type-list-mode = v-dc-type-list-mode
e-dc-type /*:SCREEN-VALUE in frame {&frame-name}*/  = replace(v-dc-type-list, {&comma-char}, {&new-line})
.
/*в v-dc-type-algo-list лежат записи по первичным ключам - перобразуем в v-rid-list*/
DO ii = 1 TO NUM-ENTRIES(v-dc-type-algo-list):
  RUN gen-temp-row-keyr IN THIS-PROCEDURE (
                                           INPUT ENTRY(ii, v-dc-type-algo-list)
                                          ,INPUT "tt0-" /*prefix*/
                                          ,OUTPUT v-tbl-row).

  ASSIGN
  v-rid-list = v-rid-list + (IF ii = 1 THEN '':U ELSE {&comma-char}) + string(v-tbl-row).

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-param-values Dialog-Frame
PROCEDURE init-param-values :
do
on error undo, return error
:
define input parameter p-cre-db-num     as integer      no-undo .
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define output parameter p-dir                   as character    no-undo.
define variable v-param-list    as character     no-undo.
define variable v-param-type    as character     no-undo.
define variable ii as integer   no-undo .
define variable v-entry  as character no-undo .
define variable v-task-num as integer   no-undo .

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
            AND buf_schedule.task-type  = p-task-type,
            first buf_schedule-attr no-lock where
                  buf_schedule-attr.cre-db-num = p-cre-db-num
              AND buf_schedule-attr.task-type  = p-task-type
              AND buf_schedule-attr.task-num = buf_schedule.task-num
              AND buf_schedule-attr.attr-code = ({&attr-schd-free-id} + {&delim-par} + 'uclcdcpc') :
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
      assign
      v-param-list = "ALL" + {&delim-par}   +
                     "update" + {&delim-par} +
                     "*" + {&delim-par} +
                     '':U + {&delim-par} +
                     ''.
    END.
    WHEN 'run' THEN DO:
      assign
      v-param-list = "ALL" + {&delim-par}  +
                     "check-0" + {&delim-par} +
                     "LIST" + {&delim-par} +
                     '':U + {&delim-par} +
                     ''.

    END.
  END CASE.
  ASSIGN
  v-dc-list-mode = entry(1, v-param-list, {&delim-par})
  v-update-mode = entry(2, v-param-list, {&delim-par})
  v-dc-type-list-mode = entry(3, v-param-list, {&delim-par})
  v-dc-type-list = replace(entry(4, v-param-list, {&delim-par}), {&new-line}, {&comma-char})
  v-dc-type-algo-list = entry(5, v-param-list, {&delim-par})
  .
END. /*doe*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-h AS handle NO-UNDO.
v-h = br-rule-by-call:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  if v-h:LABEL = {&LABEL-clmn_2} then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
rs-update-mode:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
    "Проверка" + {&comma-char} +
  "check-0" + {&comma-char} +
  "Расчет (с сохранением)" + {&comma-char} +
  "update".
DISPLAY
RS-dc-list-mode
RS-dc-type-list-mode
Rs-update-mode
E-dc-type
mark-num
editor-1
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit
b-quit
RS-dc-list-mode when p-mode = "run"
b-lst
B-Help
RS-dc-type-list-mode
Rs-update-mode
E-dc-type
B-mark when p-mode = "run"
BR-rule-by-call
mark-num
editor-1
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
IF v-rid-list = '':U THEN DO:
    HIDE
    mark-num
    IN FRAME {&FRAME-NAME}.
END.
ELSE DO:
    DISPLAY
    NUM-ENTRIES(v-rid-list) @ mark-num
    with FRAME {&FRAME-NAME}.
END.
RUN openbr IN THIS-PROCEDURE.
APPLY "VALUE-CHANGED" TO rs-dc-list-mode.
APPLY "VALUE-CHANGED" TO br-rule-by-call.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
OPEN QUERY BR-rule-by-call FOR EACH tt0-rule-by-call.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable ii as integer   no-undo .
define variable v-exists as logical no-undo .
DEFINE VARIABLE v-key-rec AS CHARACTER NO-UNDO.
DEFINE buffer buf_tt0-rule-by-call FOR tt0-rule-by-call.
IF rs-dc-type-list-mode = "LIST"
AND e-dc-type:screen-value in frame {&frame-name} = '':u  then do:
 message
 "Не задан список типов ДК"
 view-as alert-box error .
 return error.

end.
IF rs-dc-type-list-mode = "*"
AND v-rid-list = '':u
and p-mode = "run"
then do:
 message
 "Не задан список алгоритмов для расчета"
 view-as alert-box error .
 return error.

end.
IF rs-dc-list-mode = "LIST"
AND NOT CAN-FIND(FIRST dc-list)
AND p-mode = "run" THEN DO:
  message
 "Не задан список ДК"
 view-as alert-box error .
 return error.
END.
if v-rid-list <> '':U then do:
  /*преобразуем в первичные ключи*/
  DO ii =1 TO NUM-ENTRIES(v-rid-list):

  FIND first buf_tt0-rule-by-call NO-LOCK WHERE
            rowid(buf_tt0-rule-by-call) = TO-ROWID(entry(ii, v-rid-list)) NO-ERROR.
  IF AVAILABLE buf_tt0-rule-by-call THEN DO:
  ASSIGN
  v-dc-type-algo-list = (IF ii = 1 THEN '':U ELSE {&comma-char}) +
                         buf_tt0-rule-by-call.uniq-key-rec.
  END.
  END.
end.
ASSIGN
v-param-list =  rs-dc-list-mode + {&delim-par} +
                rs-update-mode + {&delim-par} +
                rs-dc-type-list-mode + {&delim-par} +
                replace(e-dc-type:SCREEN-VALUE, {&new-line}, {&comma-char}) + {&delim-par} +
                v-dc-type-algo-list.
IF p-mode = 'shd' THEN DO:
    run attach-attr-to-schedule-line in this-procedure (
          INPUT v-param-list

    ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME