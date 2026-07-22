&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule
       field maria-rule-num as integer

       .


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Скидки кассы MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/11/05
Author: Bakhtadze Natalya
Creation date: 11/11/05

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.shop.obj-code NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER dr-list AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER drgrouprank AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER drcprank AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER drdcrank AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER drgdsrank AS CHARACTER NO-UNDO.


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Скидки кассы MARIA".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }

define temp-table temp-rank no-undo
field subject as character
field id as integer format "99"
field f-value AS CHARACTER
field f-label AS CHARACTER
index pi is unique
primary
subject
id
.

DEFINE BUFFER group-temp-rank FOR temp-rank.
DEFINE BUFFER gds-temp-rank FOR temp-rank.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-dis-rule gds-temp-rank group-temp-rank

/* Definitions for BROWSE BR-dis-rule                                   */
&Scoped-define FIELDS-IN-QUERY-BR-dis-rule tt-dis-rule.maria-rule-num tt-dis-rule.rule-num tt-dis-rule.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-rule
&Scoped-define SELF-NAME BR-dis-rule
&Scoped-define QUERY-STRING-BR-dis-rule FOR EACH tt-dis-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-dis-rule OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-dis-rule tt-dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-rule tt-dis-rule


/* Definitions for BROWSE BR-gds-rank                                   */
&Scoped-define FIELDS-IN-QUERY-BR-gds-rank gds-temp-rank.id gds-temp-rank.f-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds-rank
&Scoped-define SELF-NAME BR-gds-rank
&Scoped-define QUERY-STRING-BR-gds-rank FOR EACH gds-temp-rank WHERE gds-temp-rank.subject = "gds"
&Scoped-define OPEN-QUERY-BR-gds-rank OPEN QUERY {&SELF-NAME} FOR EACH gds-temp-rank WHERE gds-temp-rank.subject = "gds".
&Scoped-define TABLES-IN-QUERY-BR-gds-rank gds-temp-rank
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds-rank gds-temp-rank


/* Definitions for BROWSE BR-group-rank                                 */
&Scoped-define FIELDS-IN-QUERY-BR-group-rank group-temp-rank.id group-temp-rank.f-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-group-rank
&Scoped-define SELF-NAME BR-group-rank
&Scoped-define QUERY-STRING-BR-group-rank FOR EACH group-temp-rank WHERE group-temp-rank.subject = "group"
&Scoped-define OPEN-QUERY-BR-group-rank OPEN QUERY {&SELF-NAME} FOR EACH group-temp-rank WHERE group-temp-rank.subject = "group".
&Scoped-define TABLES-IN-QUERY-BR-group-rank group-temp-rank
&Scoped-define FIRST-TABLE-IN-QUERY-BR-group-rank group-temp-rank


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-gds-rank}~
    ~{&OPEN-QUERY-BR-group-rank}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-lookup BR-dis-rule ~
B-gds-up B-group-up B-gds-down B-group-down BR-gds-rank BR-group-rank ~
l-dcgdsrank1 l-dcgrouprank1 l-dcgdsrank2 l-dcgrouprank2 l-dcgdsrank3 ~
l-dcgrouprank3 l-dcgdsrank4 l-dcgrouprank l-dcgdsrank5 l-dcgrouprank5
&Scoped-Define DISPLAYED-OBJECTS l-dcgdsrank1 l-dcgrouprank1 l-dcgdsrank2 ~
l-dcgrouprank2 l-dcgdsrank3 l-dcgrouprank3 l-dcgdsrank4 l-dcgrouprank ~
l-dcgdsrank5 l-dcgrouprank5

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add-dr  NO-FOCUS
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del-dr
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-gds-down
     LABEL "В&низ"
     SIZE 10 BY 1.

DEFINE BUTTON B-gds-up
     LABEL "Вв&ерх"
     SIZE 10 BY 1.

DEFINE BUTTON B-group-down
     LABEL "В&низ"
     SIZE 10 BY 1.

DEFINE BUTTON B-group-up
     LABEL "Вв&ерх"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE l-dcgdsrank1 AS CHARACTER FORMAT "X(256)":U INITIAL "Приоритет скидки"
      VIEW-AS TEXT
     SIZE 16.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgdsrank2 AS CHARACTER FORMAT "X(256)":U INITIAL " на НП"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgdsrank3 AS CHARACTER FORMAT "X(256)":U INITIAL "при наличии"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgdsrank4 AS CHARACTER FORMAT "X(256)":U INITIAL "скидок"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgdsrank5 AS CHARACTER FORMAT "X(256)":U INITIAL "неск. типов:"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgrouprank AS CHARACTER FORMAT "X(256)":U INITIAL "скидок"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgrouprank1 AS CHARACTER FORMAT "X(256)":U INITIAL "Приоритет скидки"
      VIEW-AS TEXT
     SIZE 16.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgrouprank2 AS CHARACTER FORMAT "X(256)":U INITIAL " на группу"
      VIEW-AS TEXT
     SIZE 13 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgrouprank3 AS CHARACTER FORMAT "X(256)":U INITIAL "при наличии"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

DEFINE VARIABLE l-dcgrouprank5 AS CHARACTER FORMAT "X(256)":U INITIAL "неск. типов:"
      VIEW-AS TEXT
     SIZE 12.5 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-rule FOR
      tt-dis-rule SCROLLING.

DEFINE QUERY BR-gds-rank FOR
      gds-temp-rank SCROLLING.

DEFINE QUERY BR-group-rank FOR
      group-temp-rank SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-rule Dialog-Frame _FREEFORM
  QUERY BR-dis-rule NO-LOCK DISPLAY
      tt-dis-rule.maria-rule-num COLUMN-LABEL "№ модели" FORMAT ">9":U
tt-dis-rule.rule-num COLUMN-LABEL "Код скидки!IBS TH" FORMAT ">>>>>>>>9":U
tt-dis-rule.des COLUMN-LABEL "Описание" FORMAT "X(85)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10
         TITLE "Соответствие моделей скидок НА КАССЕ правилам скидок в IBS TH" ROW-HEIGHT-CHARS .67 EXPANDABLE.

DEFINE BROWSE BR-gds-rank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds-rank Dialog-Frame _FREEFORM
  QUERY BR-gds-rank DISPLAY
      gds-temp-rank.id COLUMN-LABEL "Приоритет"
gds-temp-rank.f-label COLUMN-LABEL "Тип скидки" FORMAT "X(8)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 23 BY 4.75 ROW-HEIGHT-CHARS .67.

DEFINE BROWSE BR-group-rank
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-group-rank Dialog-Frame _FREEFORM
  QUERY BR-group-rank DISPLAY
      group-temp-rank.id COLUMN-LABEL "Приоритет"
group-temp-rank.f-label COLUMN-LABEL "Тип скидки" FORMAT "X(8)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 23 BY 4.75 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     B-del-dr AT ROW 3 COL 11
     B-lookup AT ROW 3 COL 41
     B-add-dr AT ROW 3 COL 1
     BR-dis-rule AT ROW 3.92 COL 1
     B-gds-up AT ROW 15.5 COL 14
     B-group-up AT ROW 15.5 COL 39
     B-gds-down AT ROW 16.5 COL 14
     B-group-down AT ROW 16.5 COL 39
     BR-gds-rank AT ROW 17.75 COL 1
     BR-group-rank AT ROW 17.75 COL 26
     l-dcgdsrank1 AT ROW 14 COL 1.5 NO-LABEL
     l-dcgrouprank1 AT ROW 14 COL 26.5 NO-LABEL
     l-dcgdsrank2 AT ROW 14.75 COL 1.5 NO-LABEL
     l-dcgrouprank2 AT ROW 14.75 COL 26.5 NO-LABEL
     l-dcgdsrank3 AT ROW 15.5 COL 1.5 NO-LABEL
     l-dcgrouprank3 AT ROW 15.5 COL 26.5 NO-LABEL
     l-dcgdsrank4 AT ROW 16.25 COL 1.5 NO-LABEL
     l-dcgrouprank AT ROW 16.25 COL 26.5 NO-LABEL
     l-dcgdsrank5 AT ROW 17 COL 1 NO-LABEL
     l-dcgrouprank5 AT ROW 17 COL 26 NO-LABEL
     SPACE(60.50) SKIP(5.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Скидки на кассе MARIA"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-dis-rule T "?" NO-UNDO ub dis-rule
      ADDITIONAL-FIELDS:
          field maria-rule-num as integer


      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BR-dis-rule B-add-dr Dialog-Frame */
/* BROWSE-TAB BR-gds-rank B-group-down Dialog-Frame */
/* BROWSE-TAB BR-group-rank BR-gds-rank Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-add-dr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del-dr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN l-dcgdsrank1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgdsrank2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgdsrank3 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgdsrank4 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgdsrank5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgrouprank IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgrouprank1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgrouprank2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgrouprank3 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-dcgrouprank5 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-rule
/* Query rebuild information for BROWSE BR-dis-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-rule NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-dis-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds-rank
/* Query rebuild information for BROWSE BR-gds-rank
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH gds-temp-rank WHERE gds-temp-rank.subject = "gds".
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-gds-rank */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-group-rank
/* Query rebuild information for BROWSE BR-group-rank
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH group-temp-rank WHERE group-temp-rank.subject = "group".
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-group-rank */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Скидки на кассе MARIA */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-dr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-dr Dialog-Frame
ON CHOOSE OF B-add-dr IN FRAME Dialog-Frame /* Добавить */
DO:
  DEFINE VARIABLE v-value AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
  DEFINE BUFFER buf_tt-dis-rule FOR tt-dis-rule.
  DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
      run ref/dis-ruls.w (
                  input parparentproc
                  ,input 0 /*p-host-code*/
                  ,INPUT p-obj-type
                  ,INPUT  p-obj-code
                  ,input "b-sel":U
                  ,INPUT {&g___object}
                  ,INPUT 0
                  ,input ?
                  ,input 0
                  ,input-output v-sts
                  ,input-output v-rid-list ) no-error .

IF ERROR-STATUS:ERROR OR v-rid-list = "":U  THEN RETURN no-apply.
FIND FIRST buf_dis-rule NO-LOCK WHERE
        RECID(buf_dis-rule) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
IF NOT AVAILABLE buf_dis-rule  THEN RETURN NO-APPLY.
if buf_dis-rule.discnt-type = integer({&discnt-t-manual}) then do:
  message
  "Не надо задавать соответствие для скидки свободного ввода"
  view-as alert-box error .
  undo, return no-apply.
end.
FIND FIRST buf_tt-dis-rule WHERE
          buf_tt-dis-rule.rule-num = buf_Dis-rule.rule-num NO-ERROR.
if available buf_tt-dis-rule then do:
  MESSAGE
  SUBSTITUTE("Уже задано соответствие для правила &1"
            ,buf_tt-dis-rule.rule-num)
  VIEW-AS ALERT-BOX ERROR.
  RETURN NO-APPLY.
end.


    run gbl/d-prompt.w (
      'title=':u + "Введите номер модели скидки НА КАССЕ" + '\':u
    + 'text1=':u + "(1-20)" + '\':u
    + 'format=' + ">9" + '\':u
    + 'type=' + {&type-int} + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=7\':u
    + 'fillin_height=1\':u
    + 'max-chars=5\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output v-value
    ).
    if return-value = 'false':u then return NO-apply.
   IF INTEGER(v-value) > 20 OR
   integer(v-value) < 0 THEN DO:
       MESSAGE
       "Значение номера модели может быть только числом от 1 до 20"
       VIEW-AS ALERT-BOX ERROR.
       RETURN NO-APPLY.
   END.
   FIND FIRST buf_tt-dis-rule WHERE
             buf_tt-dis-rule.maria-rule-num = INTEGER(v-value) NO-ERROR.
   IF AVAILABLE buf_tt-dis-rule THEN DO:
       MESSAGE
       SUBSTITUTE("Уже задано соответствие с номером модели скидки &1"
                  ,buf_tt-dis-rule.maria-rule-num)
       VIEW-AS ALERT-BOX ERROR.
       RETURN NO-APPLY.
   END.
   CREATE tt-dis-rule.
   BUFFER-COPY buf_dis-rule
   TO tt-dis-rule
   ASSIGN
   tt-dis-rule.maria-rule-num = INTEGER(v-value)
   v-rid = RECID(tt-dis-rule)
   .
   run openbr IN THIS-PROCEDURE.
   REPOSITION br-dis-rule TO RECID v-rid.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-dr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-dr Dialog-Frame
ON CHOOSE OF B-del-dr IN FRAME Dialog-Frame /* Удалить */
DO:
  IF NOT AVAILABLE tt-dis-rule THEN RETURN NO-APPLY.
  DELETE tt-dis-rule.
  run openbr IN THIS-PROCEDURE.
  REPOSITION br-dis-rule TO ROW 1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds-down Dialog-Frame
ON CHOOSE OF B-gds-down IN FRAME Dialog-Frame /* Вниз */
DO:
{ gbl/stdbtn.i }
run proc-b-down IN THIS-PROCEDURE ( BUFFER gds-temp-rank, INPUT "gds") NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  {&OPEN-QUERY-br-gds-rank}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds-up Dialog-Frame
ON CHOOSE OF B-gds-up IN FRAME Dialog-Frame /* Вверх */
DO:
{ gbl/stdbtn.i }
 run proc-b-up IN THIS-PROCEDURE ( BUFFER gds-temp-rank, INPUT "gds") NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
 {&OPEN-QUERY-br-gds-rank}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-group-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-group-down Dialog-Frame
ON CHOOSE OF B-group-down IN FRAME Dialog-Frame /* Вниз */
DO:
{ gbl/stdbtn.i }
run proc-b-down IN THIS-PROCEDURE ( BUFFER group-temp-rank, INPUT "group") NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  {&OPEN-QUERY-br-group-rank}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-group-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-group-up Dialog-Frame
ON CHOOSE OF B-group-up IN FRAME Dialog-Frame /* Вверх */
DO:
{ gbl/stdbtn.i }
 run proc-b-up IN THIS-PROCEDURE ( BUFFER group-temp-rank, INPUT "group") NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
 {&OPEN-QUERY-br-group-rank}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
  IF AVAILABLE tt-dis-rule THEN DO:
    run ref/show-dr.p ( input parparentproc
                      ,input tt-dis-rule.rule-num) no-error.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dis-rule
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
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

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
  DISPLAY l-dcgdsrank1 l-dcgrouprank1 l-dcgdsrank2 l-dcgrouprank2 l-dcgdsrank3
          l-dcgrouprank3 l-dcgdsrank4 l-dcgrouprank l-dcgdsrank5 l-dcgrouprank5
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-lookup BR-dis-rule B-gds-up B-group-up
         B-gds-down B-group-down BR-gds-rank BR-group-rank l-dcgdsrank1
         l-dcgrouprank1 l-dcgdsrank2 l-dcgrouprank2 l-dcgdsrank3 l-dcgrouprank3
         l-dcgdsrank4 l-dcgrouprank l-dcgdsrank5 l-dcgrouprank5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-maria-rule-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num AS INTEGER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
FOR EACH tt-dis-rule:
    DELETE tt-dis-rule.
END.
DO ii = 1 TO NUM-ENTRIES(dr-list):
  ASSIGN
  v-maria-rule-num = integer(ENTRY(2, ENTRY(ii, dr-list), '-':U))
  v-rule-num = integer(ENTRY(1, ENTRY(ii, dr-list), '-':U))
  NO-ERROR
  .
  IF NOT ERROR-STATUS:ERROR THEN DO:
    FIND FIRST tt-dis-rule NO-LOCK WHERE
            tt-dis-rule.maria-rule-num = v-maria-rule-num NO-ERROR.
    IF NOT AVAILABLE tt-dis-rule THEN DO:
      FIND FIRST tt-dis-rule NO-LOCK WHERE
          tt-dis-rule.rule-num = v-rule-num NO-ERROR.
      IF NOT AVAILABLE tt-dis-rule THEN DO:
        FIND FIRST buf_dis-rule NO-LOCK WHERE
                  buf_dis-rule.rule-num = v-rule-num NO-ERROR.
        IF AVAILABLE buf_dis-rule THEN DO:
          CREATE tt-dis-rule.
          BUFFER-COPY buf_dis-rule TO tt-dis-rule
          ASSIGN
          tt-dis-rule.maria-rule-num = v-maria-rule-num.
          RELEASE tt-dis-rule.
        END.
      END.
    END.
  END.
END.
FOR EACH temp-rank:
  DELETE temp-rank.
END.
DO ii = 1 TO num-entries(drgdsrank):
 CREATE temp-rank.
 ASSIGN
 temp-rank.subject = "gds"
 temp-rank.id = ii
 temp-rank.f-value = entry(2, ENTRY(ii, drgdsrank), {&slash-char})
 temp-rank.f-label = entry(1, ENTRY(ii, drgdsrank), {&slash-char})
 .
 RELEASE temp-rank.
END.
DO ii = 1 TO num-entries(drgrouprank):
 CREATE temp-rank.
 ASSIGN
 temp-rank.subject = "group"
 temp-rank.id = ii
 temp-rank.f-value = entry(2, ENTRY(ii, drgrouprank), '-')
 temp-rank.f-label = entry(1, ENTRY(ii, drgrouprank), '-')
 .
 RELEASE temp-rank.
END.
DO ii = 1 TO num-entries(drcprank):
 CREATE temp-rank.
 ASSIGN
 temp-rank.subject = "cp"
 temp-rank.id = ii
 temp-rank.f-value = entry(2, ENTRY(ii, drcprank), {&slash-char})
 temp-rank.f-label = entry(1, ENTRY(ii, drcprank), {&slash-char})
 .
 RELEASE temp-rank.
END.
DO ii = 1 TO num-entries(drdcrank):
 CREATE temp-rank.
 ASSIGN
 temp-rank.subject = "dc"
 temp-rank.id = ii
 temp-rank.f-value = entry(2, ENTRY(ii, drdcrank), {&slash-char})
 temp-rank.f-label = entry(1, ENTRY(ii, drdcrank), {&slash-char})
 .
 RELEASE temp-rank.
END.
  DISPLAY
  l-dcgdsrank1
  l-dcgrouprank1
  l-dcgdsrank2
  l-dcgrouprank2
  l-dcgdsrank3
  l-dcgrouprank3
  l-dcgdsrank4
  l-dcgrouprank
  l-dcgdsrank5
  l-dcgrouprank5
  WITH FRAME {&frame-name}.
  ENABLE
  B-exit WHEN p-mode <> {&LOOKUP}
  b-quit
  B-Help
  B-lookup
  BR-dis-rule
  b-add-dr WHEN p-mode <> {&LOOKUP}
  b-del-dr WHEN p-mode <> {&LOOKUP}
  B-gds-up WHEN p-mode <> {&LOOKUP}
  B-group-up  WHEN p-mode <> {&LOOKUP}
  B-gds-down WHEN p-mode <> {&LOOKUP}
  B-group-down WHEN p-mode <> {&LOOKUP}
  BR-gds-rank
  BR-group-rank
  l-dcgdsrank1
  l-dcgrouprank1
  l-dcgdsrank2
  l-dcgrouprank2
  l-dcgdsrank3
  l-dcgrouprank3
  l-dcgdsrank4
  l-dcgrouprank
  l-dcgdsrank5
  l-dcgrouprank5
  WITH FRAME {&frame-name}.
  VIEW FRAME {&frame-name}.
  open query BR-dis-rule for each tt-dis-rule .
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
ASSIGN
FRAME {&frame-name}:TITLE = substitute("&1 &2&3", FRAME {&frame-name}:TITLE, p-obj-type, p-obj-code).
IF p-mode  = {&lookup} THEN DO:
    HIDE
    b-exit
    IN FRAME {&frame-name}.
    ASSIGN
    b-quit:COLUMN = 1
    b-quit:LABEL = "&Выход".
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
OPEN QUERY br-dis-rule FOR EACH tt-dis-rule SHARE-LOCK.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-down Dialog-Frame
PROCEDURE proc-b-down :
DEFINE PARAMETER BUFFER br_temp-rank FOR temp-rank.
DEFINE INPUT PARAMETER p-subject AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf_temp-rank FOR temp-rank.
IF NOT AVAILABLE br_temp-rank THEN RETURN NO-APPLY.
FIND last buf_temp-rank WHERE  buf_temp-rank.subject = p-subject
            USE-INDEX pi .
 IF br_temp-rank.id = buf_temp-rank.id THEN DO:
     BELL.
     RETURN .
 END.
 ASSIGN
 v-old = br_temp-rank.Id
 v-new = br_temp-rank.id + 1
 .
 FIND FIRST buf_temp-rank WHERE
            buf_temp-rank.subject = p-subject
        AND buf_temp-rank.id = v-new NO-ERROR.
 ASSIGN
 br_temp-rank.id = 0.
 RELEASE br_temp-rank.
 buf_temp-rank.id = v-old.
 RELEASE buf_temp-rank.
 FIND FIRST buf_temp-rank WHERE
            buf_temp-rank.subject = p-subject
        AND buf_temp-rank.id = 0.
 ASSIGN
 buf_temp-rank.id = v-new.
 RELEASE buf_temp-rank.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-up Dialog-Frame
PROCEDURE proc-b-up :
DEFINE PARAMETER BUFFER br_temp-rank FOR temp-rank.
DEFINE INPUT PARAMETER p-subject AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf_temp-rank FOR temp-rank.
 IF NOT AVAILABLE br_temp-rank THEN RETURN NO-APPLY.
 IF br_temp-rank.id = 1 THEN DO:
     BELL.
     RETURN.
 END.
 ASSIGN
 v-old = br_temp-rank.Id
 v-new = br_temp-rank.id - 1
 .
 FIND FIRST buf_temp-rank WHERE
            buf_temp-rank.subject = p-subject
        AND buf_temp-rank.id = v-new NO-ERROR.
 ASSIGN
 br_temp-rank.id = 0.
 RELEASE br_temp-rank.
 buf_temp-rank.id = v-old.
 RELEASE buf_temp-rank.
 FIND FIRST buf_temp-rank WHERE
            buf_temp-rank.subject = p-subject
        AND buf_temp-rank.id = 0.
 ASSIGN
 buf_temp-rank.id = v-new.
 RELEASE buf_temp-rank.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-dr-list AS CHARACTER NO-UNDO.
DEFINE variable v-drgdsrank AS CHARACTER NO-UNDO.
DEFINE variable v-drgrouprank AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-dis-rule FOR tt-dis-rule.
DEFINE BUFFER buf_temp-rank FOR temp-rank.

FOR EACH buf_tt-dis-rule:
  ASSIGN
  v-dr-list = v-dr-list + (IF v-dr-list = '':U THEN '':U ELSE {&comma-char}) +
              string(buf_tt-dis-rule.rule-num) + '-' + string(buf_tt-dis-rule.maria-rule-num).

END.
FOR EACH buf_temp-rank
BY buf_temp-rank.subject
BY buf_temp-rank.id:
CASE BUF_TEMP-RANK.SUBJECT:
        WHEN 'GDS' THEN DO:
            V-DRGDSRANK = V-DRGDSRANK + (IF V-drgdsrank = '':U THEN '':U ELSE {&comma-char}) +
                          buf_temp-rank.f-label + {&slash-char} + buf_temp-rank.f-value.

        END.
        WHEN 'Group' THEN DO:
            V-DRGroupRANK = V-DRGroupRANK + (IF V-drgrouprank = '':U THEN '':U ELSE {&comma-char}) +
                          buf_temp-rank.f-label + '-':U + buf_temp-rank.f-value.

        END.
  END CASE.
END.
ASSIGN
dr-list = v-dr-list
drgdsrank = v-drgdsrank
drgrouprank = v-drgrouprank
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME