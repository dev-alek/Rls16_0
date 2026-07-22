&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_ruledict-param FOR ub.ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил для профайла 75

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/10
Author: Bakhtadze Natalya
Creation date: 07/14/10

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-handle as handle no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-rule-call-param.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 75".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ gbl/color.i }
{ rul/rcps.i local-var }
{ rul/rcps.i procedures  full }
{ rul/ruleset_.i }
&scop rule-text  2071
&scop rule-excel 2071


define variable v-curr-db-num like ub.db.db-num no-undo .

DEFINE VARIABLE  v-num-mandatory-fields AS INTEGER NO-UNDO.

DEFINE TEMP-TABLE conf-export NO-UNDO
FIELD table-name AS CHARACTER
FIELD field-name AS CHARACTER
FIELD full-field-name AS CHARACTER
FIELD is-mandatory AS LOGICAL
FIELD to-export AS LOGICAL
FIELD field-label AS CHARACTER
FIELD position_ AS INTEGER
INDEX pi IS UNIQUE PRIMARY
position_
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-fields

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES conf-export X_ruledict-param X_rp-rule-param ~
tt-rule-call-param TERM_tt-rule-call-param

/* Definitions for BROWSE br-fields                                     */
&Scoped-define FIELDS-IN-QUERY-br-fields conf-export.field-label conf-export.IS-MANDATORY conf-export.to-export
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-fields conf-export.to-export
&Scoped-define ENABLED-TABLES-IN-QUERY-br-fields conf-export
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-fields conf-export
&Scoped-define SELF-NAME br-fields
&Scoped-define QUERY-STRING-br-fields FOR EACH conf-export WHERE true
&Scoped-define OPEN-QUERY-br-fields OPEN QUERY {&SELF-NAME} FOR EACH conf-export WHERE true         .
&Scoped-define TABLES-IN-QUERY-br-fields conf-export
&Scoped-define FIRST-TABLE-IN-QUERY-br-fields conf-export


/* Definitions for BROWSE BR-rcp                                        */
&Scoped-define FIELDS-IN-QUERY-BR-rcp X_rp-rule-param.rp-param-name term_tt-rule-call-param.codex_id term_tt-rule-call-param.ruleset_id term_tt-rule-call-param.order_id term_tt-rule-call-param.rule_id term_tt-rule-call-param.profile_id term_tt-rule-call-param.once-more {&abl-datatype-name} term_tt-rule-call-param.param-num TERM_tt-rule-call-param.p-index term_tt-rule-call-param.param-name term_tt-rule-call-param.param-label {&script-parmode-name} get-param-value( INPUT term_tt-rule-call-param.param-data-type ,INPUT term_tt-rule-call-param.param-2-data-type ,INPUT term_tt-rule-call-param.param-3-data-type ,INPUT TERM_tt-rule-call-param.p-index ,INPUT term_tt-rule-call-param.param-value-character ,INPUT term_tt-rule-call-param.param-value-date ,INPUT term_tt-rule-call-param.param-value-decimal ,INPUT term_tt-rule-call-param.param-value-integer ,INPUT term_tt-rule-call-param.param-value-logical) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-character} THEN term_tt-rule-call-param.param-value-character ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-date} THEN STRING(term_tt-rule-call-param.param-value-date, "99/99/9999") ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-decimal} THEN STRING(term_tt-rule-call-param.param-value-decimal) ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-integer} THEN STRING(term_tt-rule-call-param.param-value-integer) ELSE '':U) (IF term_tt-rule-call-param.param-data-type = {&abl-datatype-logical} THEN STRING(term_tt-rule-call-param.param-value-logical, "+/-") ELSE '':U) calldscr(tt-rule-call-param.call_id)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-rcp
&Scoped-define SELF-NAME BR-rcp
&Scoped-define QUERY-STRING-BR-rcp FOR EACH X_ruledict-param, ~
       FIRST X_rp-rule-param, ~
       first tt-rule-call-param, ~
       EACH TERM_tt-rule-call-param BY tt-rule-call-param.call_id BY tt-rule-call-param.codex_id BY tt-rule-call-param.ruleset_id BY tt-rule-call-param.order_id BY tt-rule-call-param.param-num BY term_tt-rule-call-param
&Scoped-define OPEN-QUERY-BR-rcp OPEN QUERY {&SELF-NAME} FOR EACH X_ruledict-param, ~
       FIRST X_rp-rule-param, ~
       first tt-rule-call-param, ~
       EACH TERM_tt-rule-call-param BY tt-rule-call-param.call_id BY tt-rule-call-param.codex_id BY tt-rule-call-param.ruleset_id BY tt-rule-call-param.order_id BY tt-rule-call-param.param-num BY term_tt-rule-call-param                                  .
&Scoped-define TABLES-IN-QUERY-BR-rcp X_ruledict-param X_rp-rule-param ~
tt-rule-call-param TERM_tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-BR-rcp X_ruledict-param
&Scoped-define SECOND-TABLE-IN-QUERY-BR-rcp X_rp-rule-param
&Scoped-define THIRD-TABLE-IN-QUERY-BR-rcp tt-rule-call-param
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-rcp TERM_tt-rule-call-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-fields}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help b-up b-down f-start-row ~
br-fields delim EDITOR-delim-ps BR-rcp E-rules EDITOR-ps
&Scoped-Define DISPLAYED-OBJECTS f-start-row delim EDITOR-delim-ps E-rules ~
EDITOR-ps

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 4 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4 BY 1.

DEFINE VARIABLE E-rules AS CHARACTER INITIAL "Используется экспорт в:"
     VIEW-AS EDITOR NO-BOX
     SIZE 31.5 BY 1.07
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE EDITOR-delim-ps AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 20 BY 5.2
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE EDITOR-ps AS CHARACTER INITIAL "поля должны следовать в строчке файла импорта со строгим соблюдением задаваемой последовательности"
     VIEW-AS EDITOR NO-BOX
     SIZE 20 BY 5.2
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-start-row AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Верхняя строка диапазона данных (при экспорте в EXCEL)"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE delim AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "Точка с запятой(;)","Точка с запятой(;)",
                     "Тильда()","Тильда()",
                     "Табулятор(     )","Табулятор(     )",
                     "Пробел(     )","Пробел(     )"
     SIZE 21.8 BY 2.8 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-fields FOR
      conf-export SCROLLING.

DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-fields Dialog-Frame _FREEFORM
  QUERY br-fields DISPLAY
      conf-export.field-label COLUMN-LABEL "Поле" FORMAT "X(25)"
conf-export.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
conf-export.to-export COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
conf-export.to-export
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 72.5 BY 13
         TITLE "Экспортируемые поля" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BR-rcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-rcp Dialog-Frame _FREEFORM
  QUERY BR-rcp DISPLAY
      X_rp-rule-param.rp-param-name COLUMN-LABEL "Название пар-ра!профайла" FORMAT "X(20)" width 16
term_tt-rule-call-param.codex_id COLUMN-LABEL "Кодекс"
term_tt-rule-call-param.ruleset_id COLUMN-LABEL "Набор"
term_tt-rule-call-param.order_id  COLUMN-LABEL "Порядок!вызова"
term_tt-rule-call-param.rule_id  COLUMN-LABEL "Правило"
term_tt-rule-call-param.profile_id  COLUMN-LABEL "Профайл"
term_tt-rule-call-param.once-more COLUMN-LABEL "№!Привязки"
{&abl-datatype-name} COLUMN-LABEL "Тип пар-ра" FORMAT "X(12)"
term_tt-rule-call-param.param-num COLUMN-LABEL "№!пар-ра" FORMAT ">9"
TERM_tt-rule-call-param.p-index COLUMN-LABEL "Инд!екс" FORMAT ">9"
term_tt-rule-call-param.param-name COLUMN-LABEL "Название пар-ра!правила" FORMAT "X(16)"
term_tt-rule-call-param.param-label COLUMN-LABEL "Название пар-ра" FORMAT "X(255)" WIDTH 30
{&script-parmode-name} COLUMN-LABEL "Вид!пар-ра"
get-param-value( INPUT term_tt-rule-call-param.param-data-type
                ,INPUT term_tt-rule-call-param.param-2-data-type
                ,INPUT term_tt-rule-call-param.param-3-data-type
                ,INPUT TERM_tt-rule-call-param.p-index
                ,INPUT term_tt-rule-call-param.param-value-character
                ,INPUT term_tt-rule-call-param.param-value-date
                ,INPUT term_tt-rule-call-param.param-value-decimal
                ,INPUT term_tt-rule-call-param.param-value-integer
                ,INPUT term_tt-rule-call-param.param-value-logical) COLUMN-LABEL {&label-clmn_14} FORMAT "X(255)" WIDTH 26

(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-character}
 THEN term_tt-rule-call-param.param-value-character
 ELSE '':U) COLUMN-LABEL {&label-clmn_8} FORMAT "X(26)"
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-date}
THEN STRING(term_tt-rule-call-param.param-value-date, "99/99/9999")
ELSE '':U)    COLUMN-LABEL {&label-clmn_9} FORMAT "X(10)" WIDTH 12
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-decimal}
THEN STRING(term_tt-rule-call-param.param-value-decimal)
ELSE '':U) COLUMN-LABEL {&label-clmn_10}   FORMAT "X(16)"
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-integer}
THEN STRING(term_tt-rule-call-param.param-value-integer)
ELSE '':U) COLUMN-LABEL {&label-clmn_11} FORMAT "X(10)"
(IF term_tt-rule-call-param.param-data-type = {&abl-datatype-logical}
THEN STRING(term_tt-rule-call-param.param-value-logical, "+/-")
ELSE '':U) COLUMN-LABEL {&label-clmn_12} FORMAT "X(2)"
calldscr(tt-rule-call-param.call_id) COLUMN-LABEL  {&label-clmn_13} FORMAT "X(40)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.27
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     b-up AT ROW 2.93 COL 85 WIDGET-ID 26
     b-down AT ROW 2.93 COL 89 WIDGET-ID 22
     f-start-row AT ROW 3 COL 55 COLON-ALIGNED WIDGET-ID 140
     br-fields AT ROW 4 COL 26 WIDGET-ID 300
     delim AT ROW 6.8 COL 1.5 NO-LABEL WIDGET-ID 30
     EDITOR-delim-ps AT ROW 11.4 COL 2.5 NO-LABEL WIDGET-ID 138
     BR-rcp AT ROW 16.97 COL 1 WIDGET-ID 100
     E-rules AT ROW 17 COL 1 NO-LABEL WIDGET-ID 136
     EDITOR-ps AT ROW 19 COL 2.5 NO-LABEL WIDGET-ID 32
     "при экспорте в текст" VIEW-AS TEXT
          SIZE 21 BY .97 AT ROW 5.2 COL 2.1 WIDGET-ID 42
          FGCOLOR 4
     "Разделитель полей" VIEW-AS TEXT
          SIZE 21 BY .97 AT ROW 4.2 COL 2.1 WIDGET-ID 38
          FGCOLOR 4
     SPACE(76.90) SKIP(19.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_rp-rule-param B "?" ? ub rp-rule-param
      TABLE: X_rule B "?" ? ub rule
      TABLE: X_ruledict-param B "?" ? ub ruledict-param
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-fields f-start-row Dialog-Frame */
/* BROWSE-TAB BR-rcp EDITOR-delim-ps Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       EDITOR-delim-ps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       EDITOR-ps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-fields
/* Query rebuild information for BROWSE br-fields
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH conf-export WHERE true
    .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-fields */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-rcp
/* Query rebuild information for BROWSE BR-rcp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_ruledict-param, FIRST X_rp-rule-param, first tt-rule-call-param, EACH TERM_tt-rule-call-param
BY tt-rule-call-param.call_id
BY tt-rule-call-param.codex_id
BY tt-rule-call-param.ruleset_id
BY tt-rule-call-param.order_id
BY tt-rule-call-param.param-num
BY term_tt-rule-call-param                                  .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-rcp */
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


&Scoped-define SELF-NAME b-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down Dialog-Frame
ON CHOOSE OF b-down IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-export FOR conf-export.
DEFINE BUFFER buf2_conf-export FOR conf-export.

  IF NOT AVAILABLE conf-export  THEN RETURN NO-APPLY.
  DO TRANSACTION:
     v-rec = recid(conf-export).
     FIND FIRST buf1_conf-export WHERE
          buf1_conf-export.POSITION_ = conf-export.POSITION_.
    FIND FIRST buf2_conf-export WHERE
         buf2_conf-export.POSITION_ > conf-export.POSITION_ NO-ERROR.
    IF NOT AVAILABLE buf2_conf-export THEN DO:
        BELL.
        RETURN NO-APPLY.
    END.
     ASSIGN
     v-old = buf1_conf-export.POSITION_.
     ASSIGN
     v-new = buf2_conf-export.POSITION_.
     ASSIGN
     buf1_conf-export.POSITION_ = 999999999.
     RELEASE buf1_conf-export.
     ASSIGN
     buf2_conf-export.POSITION_ = v-old.
     RELEASE buf2_conf-export.
     FIND FIRST buf1_conf-export WHERE
            buf1_conf-export.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-export.POSITION_ = v-new.
    release buf1_conf-export.
  END.
  {&OPEN-QUERY-br-fields}
  REPOSITION br-fields TO RECID v-rec NO-ERROR.
  /*apply "entry" TO br-fields.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE  NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up Dialog-Frame
ON CHOOSE OF b-up IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-export FOR conf-export.
DEFINE BUFFER buf2_conf-export FOR conf-export.
  IF NOT AVAILABLE conf-export  THEN RETURN NO-APPLY.
  IF conf-export.POSITION_ =  1 THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  DO TRANSACTION:
     v-rec = recid(conf-export).
     FIND FIRST buf1_conf-export WHERE
           buf1_conf-export.POSITION_ = conf-export.POSITION.
    FIND LAST buf2_conf-export WHERE
         buf2_conf-export.POSITION_ < conf-export.POSITION  no-error.
    IF NOT AVAILABLE buf2_conf-export THEN DO:
        BELL.
        RETURN NO-APPLY.
    END.
     ASSIGN
     v-old = buf1_conf-export.POSITION_.
     ASSIGN
     v-new = buf2_conf-export.POSITION_.
     ASSIGN
     buf1_conf-export.POSITION_ = 999999999.
     RELEASE buf1_conf-export.
     ASSIGN
     buf2_conf-export.POSITION_ = v-old.
     RELEASE buf2_conf-export.
     FIND FIRST buf1_conf-export WHERE
            buf1_conf-export.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-export.POSITION_ = v-new.
    release buf1_conf-export.
  END.
  {&OPEN-QUERY-br-fields}
  REPOSITION br-fields TO RECID v-rec NO-ERROR.
  /*apply "entry" TO br-fields.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-fields
&Scoped-define SELF-NAME br-fields
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-fields Dialog-Frame
ON VALUE-CHANGED OF br-fields IN FRAME Dialog-Frame /* Экспортируемые поля */
DO:
  IF NOT AVAILABLE conf-export
  OR (AVAILABLE conf-export AND conf-export.is-mandatory) = YES THEN DO:
      ASSIGN
      conf-export.to-export:READ-ONLY IN BROWSE br-fields = YES.
  END.
  ELSE DO:
      ASSIGN
      conf-export.to-export:READ-ONLY IN BROWSE br-fields = NO.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME delim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL delim Dialog-Frame
ON VALUE-CHANGED OF delim IN FRAME Dialog-Frame
DO:
    ASSIGN
  delim.
  CASE delim:
    WHEN ";"
    OR
    WHEN {&tilda-char}
    OR
    WHEN {&tabulation} THEN DO:
      ASSIGN
      editor-delim-ps:SCREEN-VALUE = "При выводе символьные поля НЕ окавычены и не содержат символ-разделитель".
    END.
    WHEN "_" THEN DO:
        ASSIGN
        editor-delim-ps:SCREEN-VALUE = "Символьные поля окавычены".
    END.
  END CASE.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


{ rul/rcps.i interface }


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-rcp IN frame {&frame-name}
DO:
  IF AVAIL tt-rule-call-param THEN DO:
    RUN rcps_set-row-color IN THIS-PROCEDURE ( INPUT term_tt-rule-call-param.param-data-type).
  END.
END.


ON ROW-DISPLAY OF br-fields IN frame {&frame-name}
DO:
  IF AVAIL conf-export THEN DO:
    RUN set-row-color IN THIS-PROCEDURE (INPUT conf-export.is-mandatory).
  END.
END.

ON "leave" OF conf-export.to-export  IN BROWSE br-fields
DO:
define buffer buf1_conf-export for conf-export.
{ gbl/stdbtn.i }
if available conf-export then do:
  IF conf-export.is-mandatory = YES
  and logical(conf-export.to-export:screen-value in browse br-fields) = no
   THEN DO:
    BELL.
    assign
    conf-export.to-export = yes.
    display
    conf-export.to-export
    with browse br-fields.
  END.
  else do:
    find first buf1_conf-export where
              recid(buf1_conf-export) = recid(conf-export).
    assign
    buf1_conf-export.to-export = logical(conf-export.to-export:screen-value in browse br-fields).
    release buf1_conf-export.
    browse br-fields:refresh().
  end.
END.
END.

ON f6 anywhere DO:
  ASSIGN
  br-rcp:VISIBLE IN FRAME {&FRAME-NAME} = (NOT br-rcp:VISIBLE IN FRAME {&FRAME-NAME})
  .
END.

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrepos.i
&browse-name = "{&browse-name}"
&line-num=5
}



/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   run gbl/dftempl.p ( input {&table_rp-rule-param}
                     , output v-dflt-rec) no-error.
    if error-status:error then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти recid template записи в таблице rp-rule-param"
      view-as alert-box error .
      return error.
    end.
    run gbl/dftempl.p ( input {&table_ruledict-param}
                      , output v-rp-dflt-rec) no-error.
     if error-status:error then dO:
       message
       vss-workfile vss-revision vss-description skip
       "Невозможно найти recid template записи в таблице ruledict-param"
       view-as alert-box error .
       return error.
     end.
  IF p-list-mode = {&TABLE_rp-rule-param}
  THEN DO:
    FIND FIRST buf_rule-profile NO-LOCK WHERE
              buf_rule-profile.profile_id = p-profile-id.
    run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-uniq-key-rec).

    FIND FIRST buf_ruledict NO-LOCK WHERE
              buf_ruledict.entry-type = {&rdict-etype-rule-profile}
       AND  buf_ruledict.uniq-key-rec = v-uniq-key-rec.
    v-rcps-entry-id = buf_ruledict.entry-id.
  END.
  ELSE DO:
     MESSAGE
     substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
     VIEW-AS alert-box.
  END.
  RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).
  RUN fill-conf-export IN THIS-PROCEDURE.
  RUN Myenable in THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
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
  DISPLAY f-start-row delim EDITOR-delim-ps E-rules EDITOR-ps
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help b-up b-down f-start-row br-fields delim
         EDITOR-delim-ps BR-rcp E-rules EDITOR-ps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-conf-export Dialog-Frame
PROCEDURE fill-conf-export :
DEFINE VARIABLE v-position AS INTEGER NO-UNDO.

&SCOPED-DEFINE create-conf-export  ~
CREATE conf-export.                                               ~
ASSIGN                                                            ~
conf-export.table-name = ~{&table-name~}                          ~
conf-export.field-name = ~{&field-name~}                          ~
conf-export.full-field-name = ~{&table-name~} + "." + ~{&field-name~}    ~
conf-export.field-label = ~{&field-label~ }                       ~
conf-export.is-mandatory = ~{&is-mandatory~}                      ~
conf-export.to-export = (IF conf-export.is-mandatory = YES        ~
                         THEN  YES                                ~
                         ELSE NO)                                 ~
conf-export.POSITION_ = v-position + 1                            ~
v-position =  v-position + 1                                ~


/*------------------------------------------------------*/

&SCOPED-DEFINE table-name ~{&TAbLE_prod-bc~}
&SCOPED-DEFINE FIELD-NAME "b-str"
&SCOPED-DEFINE FIELD-LABEL "ДопБК"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE table-name ~{&table_contract-specif~}

&SCOPED-DEFINE FIELD-NAME "artic"
&SCOPED-DEFINE FIELD-LABEL "Артикул в IBS TH"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE FIELD-NAME "prod-type"
&SCOPED-DEFINE FIELD-LABEL "Тип производителя в IBS TH"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE FIELD-NAME "prod-code"
&SCOPED-DEFINE FIELD-LABEL "Код производителя в IBS TH"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE FIELD-NAME "price-cli"
&SCOPED-DEFINE FIELD-LABEL "Цена поставщика"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE FIELD-NAME "prc"
&SCOPED-DEFINE FIELD-LABEL "% отклонения в большую сторону"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE FIELD-NAME "qnty"
&SCOPED-DEFINE FIELD-LABEL "Количество"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE FIELD-NAME "cli-base-rate"
&SCOPED-DEFINE FIELD-LABEL "коэфф.ед.изм"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE FIELD-NAME "vat-type"
&SCOPED-DEFINE FIELD-LABEL "Тип НДС"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE FIELD-NAME "vat-pc"
&SCOPED-DEFINE FIELD-LABEL "НДС"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE FIELD-NAME "bonus"
&SCOPED-DEFINE FIELD-LABEL "Бонус"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE table-name ~{&table_goods~}
&SCOPED-DEFINE FIELD-NAME "gds-name"
&SCOPED-DEFINE FIELD-LABEL "Наименование в IBS TH"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE table-name ~{&table_goods~}
&SCOPED-DEFINE FIELD-NAME "qnty-cart"
&SCOPED-DEFINE FIELD-LABEL "Кол-во в упаковке"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE table-name ~{&table_ext-artic~}
&SCOPED-DEFINE FIELD-NAME "ext-artic"
&SCOPED-DEFINE FIELD-LABEL "Артикул поставщика"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE table-name ~{&table_gds-obj~}
&SCOPED-DEFINE FIELD-NAME "price-sale"
&SCOPED-DEFINE FIELD-LABEL "Текущая цена в IBS TH"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE table-name ~{&table_goods~}
&SCOPED-DEFINE FIELD-NAME "DeadLine"
&SCOPED-DEFINE FIELD-LABEL "Срок хранения (дней)"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.


&SCOPED-DEFINE table-name ~{&table_Clients~}
&SCOPED-DEFINE FIELD-NAME "Obj-name"
&SCOPED-DEFINE FIELD-LABEL "Наименование производителя"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

&SCOPED-DEFINE FIELD-NAME "prc-min"
&SCOPED-DEFINE FIELD-LABEL "% отклонения в меньшую сторону"
&SCOPED-DEFINE is-mandatory no
{&create-conf-export}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
FOR EACH tt-rule-call-param:
    DELETE tt-rule-call-param.
END.
 FOR EACH tt0-rule-call-param:
   IF p-mode <> {&add-def} THEN DO:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN NEXT.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN NEXT.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN NEXT.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN NEXT.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN NEXT.
   END.
   IF p-list-mode = {&TABLE_rp-rule-param}
   or p-list-mode = {&TABLE_rp-rule-param}  + {&comma-char} + {&all}
   THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN NEXT.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN NEXT.
   END.
   CREATE tt-rule-call-param.
   BUFFER-COPY tt0-rule-call-param TO tt-rule-call-param
   .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-index-id-next as integer no-undo .
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_term_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_conf-export FOR conf-export.
DEFINE BUFFER buf2_conf-export FOR conf-export.
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-delimiter"
                                ,INPUT-output v-index-id
                                ,output delim /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
if delim = {&space-char} then do:
  delim = "_" .
end.
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-start-row"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output f-start-row /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
do while v-index-id >= 0 :
  v-index-id-next = v-index-id-next + 1.
  RUN rcps_get-value IN THIS-PROCEDURE (
                                   INPUT p-profile-id
                                  ,INPUT p-once-more
                                  ,INPUT p-call-id
                                  ,INPUT "p-fields"
                                  ,INPUT-output v-index-id
                                  ,output v-value-character /*p-value-character*/
                                  ,output v-value-date /*p-value-date*/
                                  ,output v-value-decimal /*p-value-decimal*/
                                  ,output v-value-integer /*p-value-integer*/
                                  ,output v-value-logical /*p-value-logical*/
                                  ) no-error .
  if v-index-id > 0 then v-index-id-next = v-index-id.
  if error-status:error then v-index-id = -1.
  else do:
    IF v-value-character = ''  THEN NEXT.
    FIND FIRST buf_conf-export WHERE
              buf_conf-export.full-field-name = v-value-character NO-ERROR.
    IF AVAILABLE buf_conf-export THEN DO:
        buf_conf-export.to-export = yes.
      buf_conf-export.position_ = v-index-id-next - 1000.
    END.
  end.
end. /*do while v-index-id >= 0 :*/
v-index-id = 0.
for each buf_conf-export where buf_conf-export.to-export = no
and buf_conf-export.position_ < 1000
:
 v-index-id = v-index-id + 1.
 buf_conf-export.position = v-index-id  + 1000.
end.
v-index-id = 0.
for each buf_conf-export
by buf_conf-export.to-export descending
by buf_conf-export.position
:
 v-index-id = v-index-id + 1.
 buf_conf-export.position = v-index-id .
end.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры экспорта спецификацией по профайлу &1", p-profile-id).
assign
delim:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "Точка с запятой (;)" + {&comma-char} + ";" + {&comma-char} +
                         "Тильда (~)" + {&comma-char} + "~~" + {&comma-char} +
                          "Табулятор" + {&comma-char} + "~t" + {&comma-char} +
                          "Пробел" + {&comma-char} + "_"
.
ASSIGN
conf-export.to-export:READ-ONLY IN BROWSE br-fields = YES
.

ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
ASSIGN
v-ch0 = br-rcp:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = {&label-clmn_8} THEN DO:
     v-ch[1] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_9} THEN DO:
     v-ch[2] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_10} THEN DO:
     v-ch[3] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_11} THEN DO:
     v-ch[4] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_12} THEN DO:
     v-ch[5] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = {&label-clmn_13} THEN DO:
     v-ch[6] = v-ch0.
   END.
   IF v-ch0:LABEL = {&label-clmn_14} THEN
   v-ch0:RESIZABLE = YES.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
assign
X_rp-rule-param.rp-param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-label:resizable in browse br-rcp = yes
.
CASE p-list-mode:
  WHEN {&TABLE_rule-call-param} THEN DO:
     ASSIGN
     X_rp-rule-param.rp-param-name:VISIBLE IN BROWSE br-rcp = NO
     .
  END.
  WHEN {&TABLE_rp-rule-param}
  or
  when {&TABLE_rp-rule-param} + {&comma-char} + {&all}
  THEN DO:
    assign
    term_tt-rule-call-param.codex_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.ruleset_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.rule_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.order_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-name:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-num:VISIBLE IN BROWSE br-rcp = NO
    .

  END.
END CASE.
 IF p-call-id <> '':U THEN DO:
   v-ch[6]:VISIBLE = NO.
 END.
  IF p-profile-id <> 0 THEN DO:
   term_tt-rule-call-param.profile_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-rule-id <> 0 THEN DO:
   term_tt-rule-call-param.RULE_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-once-more <> 0 THEN DO:
   term_tt-rule-call-param.once-more :VISIBLE IN BROWSE br-rcp= NO.
 END.
VIEW FRAME {&frame-name}.
DISPLAY
EDITOR-ps
EDITOR-delim-ps
delim
f-start-row
WITH FRAME {&frame-name}.
ENABLE
b-up   WHEN p-mode <> {&LOOKUP}
b-down WHEN p-mode <> {&LOOKUP}
B-exit WHEN p-mode <> {&LOOKUP}
B-quit
B-help
br-fields
br-rcp
EDITOR-ps
EDITOR-delim-ps
delim  WHEN p-mode <> {&LOOKUP}
f-start-row WHEN p-mode <> {&LOOKUP}
WITH FRAME {&frame-name}.
RUN rcps_OpenBr in THIS-PROCEDURE.
HIDE br-rcp IN FRAME {&FRAME-NAME}.
IF p-mode = {&LOOKUP} THEN DO:
   ASSIGN
   b-quit:COLUMN = 1
   b-quit:LABEL = "&Выход".
   HIDE
   b-exit
   IN FRAME {&FRAME-NAME}.
END.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
apply "value-changed" to br-fields.
apply "value-changed" to delim.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&TABLE_rp-rule-param} THEN DO:
      OPEN QUERY br-rcp
      FOR EACH  X_ruledict-param NO-LOCK WHERE X_ruledict-param.entry-id = v-rcps-entry-id
          ,FIRST X_rp-rule-param WHERE
              X_rp-rule-param.profile_id = p-profile-id
          AND X_rp-rule-param.rp-param-name = X_ruledict-param.param-name
        , first tt-rule-call-param WHERE
           tt-rule-call-param.codex_id = X_rp-rule-param.codex_id
       AND tt-rule-call-param.ruleset_id = X_rp-rule-param.ruleset_id
       AND tt-rule-call-param.rule_id = X_rp-rule-param.rule_id
       AND tt-rule-call-param.param-name = X_rp-rule-param.rule-param-name
         ,each term_tt-rule-call-param where
               term_tt-rule-call-param.call_id = tt-rule-call-param.call_id
           and term_tt-rule-call-param.codex_id = tt-rule-call-param.codex_id
           and term_tt-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
           and term_tt-rule-call-param.order_id = tt-rule-call-param.order_id
           and term_tt-rule-call-param.param-name = tt-rule-call-param.param-name
      BY tt-rule-call-param.call_id
      BY tt-rule-call-param.codex_id
      BY tt-rule-call-param.ruleset_id
      BY tt-rule-call-param.order_id
      BY tt-rule-call-param.param-num.
  END.
END CASE.
apply "ENTRY" to br-rcp in frame {&frame-name} .
APPLy "VALUE-CHANGED" to br-rcp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg PRIVATE :
DEFINE VARIABLE v-rec1 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec2 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec3 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec4 AS Rowid NO-UNDO.
define variable v-param-data-type as character no-undo .
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE TERM_tt-rule-call-param  THEN DO:
  RETURN ERROR.
END.

ASSIGN
v-rec1 = rowid(X_ruledict-param)
v-rec2 = rowid(X_rp-rule-param)
v-rec3 = Rowid(tt-rule-call-param)
v-rec4 = Rowid(term_tt-rule-call-param)
.
run rcps_openbr in this-procedure .
REPOSITION br-rcp TO Rowid v-rec1, v-rec2,v-rec3, v-rec4 NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-rcp TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY" TO br-rcp in frame {&frame-name} .
APPLY "VALUE-CHANGED" TO br-rcp in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable mydelimiter as char no-undo.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-file-name as character no-undo .
define variable v-glog as logical no-undo .
DEFINE BUFFER buf_conf-export FOR conf-export.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
assign
FRAME {&FRAME-NAME}
delim
f-start-row
.
if delim = "" then do:
  message "Не выбран символ-разделитель колонок в файле импорта!"
  view-as alert-box.
  return no-apply.
end.
assign
mydelimiter = delim
mydelimiter = if mydelimiter = "~t":U
              then {&tabulation}
              else mydelimiter
mydelimiter = if mydelimiter = "_":U
              then {&space-char}
              else mydelimiter
.
find first buf_conf-export where
          (buf_conf-export.field-name = "b-str"
       or buf_conf-export.field-name = "artic")
        and buf_conf-export.to-export = yes
         no-error.
if not available buf_conf-export then do:
  message
  "Не выбран для экспорта ни ДопБК, ни артикул товара!" skip
  "Экспорт невозможен!"
   view-as alert-box .
   return error.
end.

RUN rcps_set-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-delimiter"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT mydelimiter
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-start-row"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT ''
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT f-start-row /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).
v-ii = 0.
FOR EACH buf_conf-export WHERE
   buf_conf-export.to-export = YES
BY buf_conf-export.POSITION_
:
    v-ii = v-ii + 1.
    RUN rcps_proc-b-add IN THIS-PROCEDURE (
                                      INPUT p-profile-id
                                     ,INPUT p-once-more
                                     ,INPUT p-call-id
                                     ,INPUT "p-fields"
                                     ,INPUT v-ii).

    RUN rcps_set-value IN THIS-PROCEDURE (
                                     INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-fields"
                                    ,INPUT v-ii /*p-index-id*/
                                    ,INPUT buf_conf-export.full-field-name
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                   ).
END.
FOR EACH buf_tt-rule-call-param:
   IF buf_tt-rule-call-param.param-name = "p-fields"
   AND buf_tt-rule-call-param.p-index > v-ii THEN DELETE buf_tt-rule-call-param.

END.

RUN rcps_proc-save0 IN THIS-PROCEDURE .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-one-parameter Dialog-Frame
PROCEDURE save-one-parameter :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-is-mandatory AS LOGICAL NO-UNDO.
DEFINE VARIABLE iFGColor AS INTEGER NO-UNDO.
DEFINE VARIABLE iBGColor AS INTEGER NO-UNDO.

  IF p-is-mandatory = YES THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = GREY_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.

ASSIGN
conf-export.field-label:FGCOLOR IN BROWSE br-fields = iFGColor
conf-export.field-label:BGCOLOR IN BROWSE br-fields = iBGColor
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME