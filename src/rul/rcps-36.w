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

Задание и просмотр параметров вызова правил для профайла 36

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/28/07
Author: Bakhtadze Natalya
Creation date: 01/28/07

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 36".
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

define variable cli-grp-code like ub.cli-grp.node-code no-undo.
define variable v-curr-db-num like ub.db.db-num no-undo .

DEFINE VARIABLE  v-num-mandatory-fields AS INTEGER NO-UNDO.

DEFINE TEMP-TABLE conf-import NO-UNDO
FIELD subject AS CHARACTER
FIELD table-name AS CHARACTER
FIELD field-name AS CHARACTER
FIELD full-field-name AS CHARACTER
FIELD is-mandatory AS LOGICAL
FIELD to-import AS LOGICAL
FIELD field-label AS CHARACTER
FIELD position_ AS INTEGER
INDEX pi IS UNIQUE PRIMARY
subject
position_
.
DEFINE BUFFER firm_conf-import FOR conf-import.
DEFINE BUFFER person_conf-import FOR conf-import.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-firm

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES firm_conf-import person_conf-import ~
X_ruledict-param X_rp-rule-param tt-rule-call-param TERM_tt-rule-call-param

/* Definitions for BROWSE BR-firm                                       */
&Scoped-define FIELDS-IN-QUERY-BR-firm firm_conf-import.field-label firm_conf-import.IS-MANDATORY firm_conf-import.to-import VIEW-AS TOGGLE-BOX
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-firm firm_conf-import.to-import
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-firm firm_conf-import
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-firm firm_conf-import
&Scoped-define SELF-NAME BR-firm
&Scoped-define QUERY-STRING-BR-firm FOR EACH firm_conf-import WHERE firm_conf-import.subject = {&table_firm}
&Scoped-define OPEN-QUERY-BR-firm OPEN QUERY {&SELF-NAME} FOR EACH firm_conf-import WHERE firm_conf-import.subject = {&table_firm}.
&Scoped-define TABLES-IN-QUERY-BR-firm firm_conf-import
&Scoped-define FIRST-TABLE-IN-QUERY-BR-firm firm_conf-import


/* Definitions for BROWSE BR-person                                     */
&Scoped-define FIELDS-IN-QUERY-BR-person person_conf-import.field-label person_conf-import.IS-MANDATORY person_conf-import.to-import VIEW-AS TOGGLE-BOX
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-person person_conf-import.to-import
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-person person_conf-import
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-person person_conf-import
&Scoped-define SELF-NAME BR-person
&Scoped-define QUERY-STRING-BR-person FOR EACH person_conf-import WHERE person_conf-import.subject = {&table_person}
&Scoped-define OPEN-QUERY-BR-person OPEN QUERY {&SELF-NAME} FOR EACH person_conf-import WHERE person_conf-import.subject = {&table_person}.
&Scoped-define TABLES-IN-QUERY-BR-person person_conf-import
&Scoped-define FIRST-TABLE-IN-QUERY-BR-person person_conf-import


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
    ~{&OPEN-QUERY-BR-firm}~
    ~{&OPEN-QUERY-BR-person}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-cli-grp b-up-firm ~
b-down-firm b-up-person b-down-person BR-firm BR-person delim EDITOR-1 ~
Rs-uniq-method BR-rcp cli-grp-name
&Scoped-Define DISPLAYED-OBJECTS delim EDITOR-1 Rs-uniq-method cli-grp-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-cli-grp
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-down-firm
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 4 BY 1.

DEFINE BUTTON b-down-person
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

DEFINE BUTTON b-up-firm
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4 BY 1.

DEFINE BUTTON b-up-person
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL ""
     SIZE 4 BY 1.

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Необязательные поля следуют в строчке файла импорта за обязательными со строгим соблюдением задаваемой последовательности"
     VIEW-AS EDITOR NO-BOX
     SIZE 20 BY 5.2
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE cli-grp-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 64.4 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-uniq-method AS CHARACTER INITIAL "obj-name"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Название", "obj-name",
"INN+KPP", "inn+kpp"
     SIZE 21 BY 2.4 NO-UNDO.

DEFINE VARIABLE delim AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "Точка с запятой(;)","Точка с запятой(;)",
                     "Тильда()","Тильда()",
                     "Табулятор(     )","Табулятор(     )"
     SIZE 21.8 BY 2.8 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-firm FOR
      firm_conf-import SCROLLING.

DEFINE QUERY BR-person FOR
      person_conf-import SCROLLING.

DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-firm Dialog-Frame _FREEFORM
  QUERY BR-firm DISPLAY
      firm_conf-import.field-label FORMAT "X(25)" COLUMN-LABEL "Поле"
firm_conf-import.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
firm_conf-import.to-import COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
firm_conf-import.to-import
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 39 BY 19
         TITLE "Поля при импорте клиента типа ОРГАНИЗАЦИЯ" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BR-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-person Dialog-Frame _FREEFORM
  QUERY BR-person DISPLAY
      person_conf-import.field-label COLUMN-LABEL "Поле" FORMAT "X(25)"
person_conf-import.IS-MANDATORY COLUMN-LABEL "Обяз":U FORMAT "+/"
person_conf-import.to-import COLUMN-LABEL "":U VIEW-AS TOGGLE-BOX
ENABLE
person_conf-import.to-import
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 35.5 BY 19
         TITLE "Поля при импорте клиента типа ФИЗ.ЛИЦО" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

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
     B-cli-grp AT ROW 2.07 COL 94.3 WIDGET-ID 18
     b-up-firm AT ROW 2.93 COL 31.5 WIDGET-ID 24
     b-down-firm AT ROW 2.93 COL 35.5 WIDGET-ID 20
     b-up-person AT ROW 2.93 COL 65 WIDGET-ID 26
     b-down-person AT ROW 2.93 COL 69 WIDGET-ID 22
     BR-firm AT ROW 4 COL 23.5 WIDGET-ID 200
     BR-person AT ROW 4 COL 63 WIDGET-ID 300
     delim AT ROW 6.8 COL 1.5 NO-LABEL WIDGET-ID 30
     EDITOR-1 AT ROW 9.93 COL 2.4 NO-LABEL WIDGET-ID 32
     Rs-uniq-method AT ROW 16.47 COL 1.5 NO-LABEL WIDGET-ID 34
     BR-rcp AT ROW 16.97 COL 1 WIDGET-ID 100
     cli-grp-name AT ROW 2 COL 29.5 NO-LABEL WIDGET-ID 28
     "Символ-разделитель" VIEW-AS TEXT
          SIZE 20 BY .97 AT ROW 4.2 COL 2.1 WIDGET-ID 38
          FGCOLOR 4
     "Группа клиента по умолчанию" VIEW-AS TEXT
          SIZE 28 BY .77 AT ROW 2 COL 1 WIDGET-ID 40
          FGCOLOR 4
     "колонок" VIEW-AS TEXT
          SIZE 19 BY .97 AT ROW 5.2 COL 2.1 WIDGET-ID 42
          FGCOLOR 4
     SPACE(77.90) SKIP(17.08)
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
/* BROWSE-TAB BR-firm b-down-person Dialog-Frame */
/* BROWSE-TAB BR-person BR-firm Dialog-Frame */
/* BROWSE-TAB BR-rcp Rs-uniq-method Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cli-grp-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-firm
/* Query rebuild information for BROWSE BR-firm
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH firm_conf-import WHERE firm_conf-import.subject = {&table_firm}.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-firm */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-person
/* Query rebuild information for BROWSE BR-person
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH person_conf-import WHERE person_conf-import.subject = {&table_person}.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-person */
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


&Scoped-define SELF-NAME B-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cli-grp Dialog-Frame
ON CHOOSE OF B-cli-grp IN FRAME Dialog-Frame
DO:
define variable rid-list as char no-undo.
DEFINE BUFFER buf_cli-grp FOR ub.cli-grp.
    run ref/cli-grps.w ( input parparentproc
                        ,input ({&g#term} + {&comma-char} + "b-sel")
                        ,input-output rid-list).
    if rid-list <> "" then do:
        FIND FIRST buf_cli-grp NO-LOCK WHERE
            recid(buf_cli-grp) = integer(rid-list) NO-ERROR.
        IF NOT AVAIL buf_cli-grp then return no-apply.
        assign
        cli-grp-code = buf_cli-grp.node-code
        cli-grp-name = buf_cli-grp.node-name
        .
        DISPLAY
        cli-grp-name
        WITH FRAME {&frame-name}.

    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down-firm Dialog-Frame
ON CHOOSE OF b-down-firm IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.

  IF NOT AVAILABLE firm_conf-import  THEN RETURN NO-APPLY.
  DO TRANSACTION:
     v-rec = recid(firm_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = {&TABLE_firm}
          AND buf1_conf-import.POSITION_ = firm_conf-import.POSITION_.
    FIND FIRST buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_firm}
         AND buf2_conf-import.POSITION_ > firm_conf-import.POSITION_ NO-ERROR.
    IF NOT AVAILABLE buf2_conf-import THEN DO:
        BELL.
        RETURN NO-APPLY.
    END.
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = {&table_firm}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
  {&OPEN-QUERY-br-firm}
  REPOSITION br-firm TO RECID v-rec NO-ERROR.
  apply "entry" TO br-firm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-down-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-down-person Dialog-Frame
ON CHOOSE OF b-down-person IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.

  IF NOT AVAILABLE person_conf-import  THEN RETURN NO-APPLY.
  DO TRANSACTION:
     v-rec = recid(person_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = {&TABLE_person}
          AND buf1_conf-import.POSITION_ = person_conf-import.POSITION_.
    FIND FIRST buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_person}
         AND buf2_conf-import.POSITION_ > person_conf-import.POSITION_ NO-ERROR.
    IF NOT AVAILABLE buf2_conf-import THEN DO:
        BELL.
        RETURN NO-APPLY.
    END.
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = {&table_person}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
  {&OPEN-QUERY-br-person}
  REPOSITION br-person TO RECID v-rec NO-ERROR.
  apply "entry" TO br-person.
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


&Scoped-define SELF-NAME b-up-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up-firm Dialog-Frame
ON CHOOSE OF b-up-firm IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.

  IF NOT AVAILABLE firm_conf-import  THEN RETURN NO-APPLY.
  IF firm_conf-import.POSITION_ =  1 THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  DO TRANSACTION:
     v-rec = recid(firm_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = {&TABLE_firm}
          AND buf1_conf-import.POSITION_ = firm_conf-import.POSITION.
    FIND last buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_firm}
         AND buf2_conf-import.POSITION_ < firm_conf-import.POSITION .
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = {&table_firm}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
{&OPEN-QUERY-br-firm}
  REPOSITION br-firm TO RECID v-rec NO-ERROR.
  apply "entry" TO br-firm.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-up-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-up-person Dialog-Frame
ON CHOOSE OF b-up-person IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-new AS INTEGER NO-UNDO.
DEFINE VARIABLE v-old AS INTEGER NO-UNDO.
DEFINE BUFFER buf1_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.

  IF NOT AVAILABLE person_conf-import  THEN RETURN NO-APPLY.
  IF person_conf-import.POSITION_ =  1 THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  DO TRANSACTION:
     v-rec = recid(person_conf-import).
     FIND FIRST buf1_conf-import WHERE
              buf1_conf-import.subject = {&TABLE_person}
          AND buf1_conf-import.POSITION_ = person_conf-import.POSITION.
    FIND LAST buf2_conf-import WHERE
             buf2_conf-import.subject = {&TABLE_person}
         AND buf2_conf-import.POSITION_ < person_conf-import.POSITION .
     ASSIGN
     v-old = buf1_conf-import.POSITION_.
     ASSIGN
     v-new = buf2_conf-import.POSITION_.
     ASSIGN
     buf1_conf-import.POSITION_ = 999999999.
     RELEASE buf1_conf-import.
     ASSIGN
     buf2_conf-import.POSITION_ = v-old.
     RELEASE buf2_conf-import.
     FIND FIRST buf1_conf-import WHERE
                buf1_conf-import.subject = {&table_person}
            AND buf1_conf-import.POSITION_ = 999999999.
     ASSIGN
     buf1_conf-import.POSITION_ = v-new.

  END.
  {&OPEN-QUERY-br-person}
  REPOSITION br-person TO RECID v-rec NO-ERROR.
  apply "entry" TO br-person.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-firm
&Scoped-define SELF-NAME BR-firm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-firm Dialog-Frame
ON VALUE-CHANGED OF BR-firm IN FRAME Dialog-Frame /* Поля при импорте клиента типа ОРГАНИЗАЦИЯ */
DO:
  IF NOT AVAILABLE firm_conf-import
  OR (AVAILABLE firm_conf-import AND firm_conf-import.is-mandatory) = YES THEN DO:
      ASSIGN
      firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = YES.
  END.
  ELSE DO:
      ASSIGN
      firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = NO.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-person
&Scoped-define SELF-NAME BR-person
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-person Dialog-Frame
ON VALUE-CHANGED OF BR-person IN FRAME Dialog-Frame /* Поля при импорте клиента типа ФИЗ.ЛИЦО */
DO:
  IF NOT AVAILABLE person_conf-import
  OR (AVAILABLE person_conf-import AND person_conf-import.is-mandatory) = YES THEN DO:
      ASSIGN
      person_conf-import.to-import:READ-ONLY IN BROWSE br-person = YES.
  END.
  ELSE DO:
      ASSIGN
      person_conf-import.to-import:READ-ONLY IN BROWSE br-person = NO.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-firm
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame

{ rul/rcps.i procedures full }
{ rul/rcps.i interface }


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-rcp IN frame {&frame-name}
DO:
  IF AVAIL tt-rule-call-param THEN DO:
    RUN rcps_set-row-color IN THIS-PROCEDURE ( INPUT term_tt-rule-call-param.param-data-type).
  END.
END.

ON ROW-DISPLAY OF br-firm IN frame {&frame-name}
DO:
  IF AVAIL firm_conf-import THEN DO:
    RUN set-row-color-firm IN THIS-PROCEDURE ( INPUT firm_conf-import.is-mandatory).
  END.
END.

ON ROW-DISPLAY OF br-person IN frame {&frame-name}
DO:
  IF AVAIL person_conf-import THEN DO:
    RUN set-row-color-person IN THIS-PROCEDURE (INPUT person_conf-import.is-mandatory).
  END.
END.

ON "leave" OF firm_conf-import.to-import  IN BROWSE br-firm
DO:
define buffer buf1_conf-import for firm_conf-import.
if available conf-import then do:
  find first buf1_conf-import where
            recid(buf1_conf-import) = recid(conf-import).
  IF conf-import.is-mandatory = YES
  and logical(firm_conf-import.to-import:screen-value in browse br-firm) = no
  THEN DO:
    BELL.
    assign
    firm_conf-import.to-import = yes.
    display
    firm_conf-import.to-import
    with browse br-firm.
  END.
  else do:
    assign
    buf1_conf-import.to-import = logical(firm_conf-import.to-import:screen-value in browse br-firm).
    release buf1_conf-import.
    browse br-firm:refresh().
  end.
  end.
END.
ON "leave" OF person_conf-import.to-import  IN BROWSE br-person
DO:
define buffer buf1_conf-import for person_conf-import.
if available conf-import then do:
  find first buf1_conf-import where
            recid(buf1_conf-import) = recid(conf-import).
  IF conf-import.is-mandatory = YES
  and logical(person_conf-import.to-import:screen-value in browse br-person) = no
  THEN DO:
    BELL.
    assign
    person_conf-import.to-import = yes.
    display
    person_conf-import.to-import
    with browse br-person.
  END.
  else do:
    assign
    buf1_conf-import.to-import = logical(person_conf-import.to-import:screen-value in browse br-person).
    release buf1_conf-import.
    browse br-person:refresh().
  end.
  end.
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
  RUN fill-conf-import IN THIS-PROCEDURE.
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
  DISPLAY delim EDITOR-1 Rs-uniq-method cli-grp-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-cli-grp b-up-firm b-down-firm b-up-person
         b-down-person BR-firm BR-person delim EDITOR-1 Rs-uniq-method BR-rcp
         cli-grp-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-conf-import Dialog-Frame
PROCEDURE fill-conf-import :
DEFINE VARIABLE v-position-firm AS INTEGER NO-UNDO.
DEFINE VARIABLE v-position-person AS INTEGER NO-UNDO.

&SCOPED-DEFINE create-conf-import  ~
CREATE conf-import.                                               ~
ASSIGN                                                            ~
conf-import.subject = ~{&subject~}                                ~
conf-import.table-name = ~{&table-name~}                          ~
conf-import.field-name = ~{&field-name~}                          ~
conf-import.full-field-name = ~{&table-name~} + "." + ~{&field-name~}    ~
conf-import.field-label = ~{&field-label~ }                       ~
conf-import.is-mandatory = ~{&is-mandatory~}                      ~
conf-import.to-import = (IF conf-import.is-mandatory = YES        ~
                         THEN  YES                                ~
                         ELSE NO)                                 ~
conf-import.POSITION_ = (IF conf-import.subject = ~{&table_firm~}  ~
                         THEN v-position-firm + 1                  ~
                         ELSE v-position-person + 1)                   ~
v-position-firm =  (IF conf-import.subject = ~{&TABLE_firm~}  ~
             THEN v-position-firm + 1                                ~
             ELSE v-position-firm)                                   ~
v-position-person =  (IF conf-import.subject = ~{&TABLE_person~}  ~
           THEN v-position-person + 1                                ~
           ELSE v-position-person)



&SCOPED-DEFINE table-name ~{&TAbLE_CLIENTS~}

&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE FIELD-NAME "OBJ-TYPE"
&SCOPED-DEFINE FIELD-LABEL "Тип клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE FIELD-NAME "OBJ-TYPE"
&SCOPED-DEFINE FIELD-LABEL "Тип клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE FIELD-NAME "OBJ-code"
&SCOPED-DEFINE FIELD-LABEL "Код клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE FIELD-NAME "OBJ-code"
&SCOPED-DEFINE FIELD-LABEL "Код клиента"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE FIELD-NAME "OBJ-name"
&SCOPED-DEFINE FIELD-LABEL "Название"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.

&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE FIELD-NAME "OBJ-name"
&SCOPED-DEFINE FIELD-LABEL "Название"
&SCOPED-DEFINE is-mandatory YES
{&create-conf-import}.


/*------------------------------------------------------*/

&SCOPED-DEFINE table-name ~{&TAbLE_firm~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE is-mandatory NO

&SCOPED-DEFINE FIELD-NAME "inn"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_inn_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "okpo"
&SCOPED-DEFINE FIELD-LABEL "ОКПО"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "okonh"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_okonh_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "kpp"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_kpp_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone"
&SCOPED-DEFINE FIELD-LABEL "№ телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone-note"
&SCOPED-DEFINE FIELD-LABEL "Примеч. к № телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "fax"
&SCOPED-DEFINE FIELD-LABEL "№ факса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "e-mail"
&SCOPED-DEFINE FIELD-LABEL "E-mail"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "city"
&SCOPED-DEFINE FIELD-LABEL "Город"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "ind"
&SCOPED-DEFINE FIELD-LABEL "Почтовый индекс"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "addres1"
&SCOPED-DEFINE FIELD-LABEL "Юридический адрес 1"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "addres2"
&SCOPED-DEFINE FIELD-LABEL "Юридический адрес 2"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-addr1"
&SCOPED-DEFINE FIELD-LABEL "Почтовый адрес 1"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-addr2"
&SCOPED-DEFINE FIELD-LABEL "Почтовый адрес 2"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-city"
&SCOPED-DEFINE FIELD-LABEL "Город (для почтового адреса)"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-ind"
&SCOPED-DEFINE FIELD-LABEL "Индекс (для почтового адреса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "telex"
&SCOPED-DEFINE FIELD-LABEL "Телекс"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "engl-name"
&SCOPED-DEFINE FIELD-LABEL "Английское название"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "director"
&SCOPED-DEFINE FIELD-LABEL "Руководитель"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "contact-psn"
&SCOPED-DEFINE FIELD-LABEL "Контактное лицо"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "is-pboul"
&SCOPED-DEFINE FIELD-LABEL "ПБОЮЛ"
{&create-conf-import}.


&SCOPED-DEFINE FIELD-NAME "tobj-code"
&SCOPED-DEFINE FIELD-LABEL "Код торгового представителя"
{&create-conf-import}.

/*------------------------------------------------------*/
&SCOPED-DEFINE table-name ~{&TAbLE_CLIENTS~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_firm~}
&SCOPED-DEFINE is-mandatory NO


&SCOPED-DEFINE FIELD-NAME "reg-code"
&SCOPED-DEFINE FIELD-LABEL "Код региона"
{&create-conf-import}.

&SCOPED-DEFINE table-name ''
&SCOPED-DEFINE FIELD-NAME "parus-2-code"
&SCOPED-DEFINE FIELD-LABEL "Код во классиф.ПАРУС-2"
{&create-conf-import}.



/*------------------------------------------------------*/
&SCOPED-DEFINE table-name ~{&TAbLE_PERSON~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE is-mandatory NO

&SCOPED-DEFINE FIELD-NAME "inn"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_inn_allshift}"
{&create-conf-import}.


&SCOPED-DEFINE FIELD-NAME "okpo"
&SCOPED-DEFINE FIELD-LABEL "ОКПО"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "okonh"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_okonh_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "kpp"
&SCOPED-DEFINE FIELD-LABEL "{&abbr_kpp_allshift}"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone1"
&SCOPED-DEFINE FIELD-LABEL "№ телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "phone1-note"
&SCOPED-DEFINE FIELD-LABEL "Примеч. к № телефона"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "fax"
&SCOPED-DEFINE FIELD-LABEL "№ факса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "e-mail"
&SCOPED-DEFINE FIELD-LABEL "E-mail"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "city"
&SCOPED-DEFINE FIELD-LABEL "Город по месту рег."
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "ind"
&SCOPED-DEFINE FIELD-LABEL "Индекс по месту рег."
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "address"
&SCOPED-DEFINE FIELD-LABEL "Адрес по месту рег."
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-city"
&SCOPED-DEFINE FIELD-LABEL "Город для почт.адреса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-ind"
&SCOPED-DEFINE FIELD-LABEL "Индекс для почт.адреса"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-address"
&SCOPED-DEFINE FIELD-LABEL "Почтовый адрес"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "name1"
&SCOPED-DEFINE FIELD-LABEL "Имя"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "name2"
&SCOPED-DEFINE FIELD-LABEL "Отчество"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "passp-ser"
&SCOPED-DEFINE FIELD-LABEL "Серия паспорта"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "passp-num"
&SCOPED-DEFINE FIELD-LABEL "№ паспорта"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "given-by"
&SCOPED-DEFINE FIELD-LABEL "Паспорт выдан"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "position"
&SCOPED-DEFINE FIELD-LABEL "Должность"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "firm-name"
&SCOPED-DEFINE FIELD-LABEL "Организация"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "firm-code"
&SCOPED-DEFINE FIELD-LABEL "Код организации"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "post-box"
&SCOPED-DEFINE FIELD-LABEL "Абонентский п/я"
{&create-conf-import}.

&SCOPED-DEFINE FIELD-NAME "is-pboul"
&SCOPED-DEFINE FIELD-LABEL "ПБОЮЛ"
{&create-conf-import}.


/*------------------------------------------------------*/
&SCOPED-DEFINE TABLE-NAME ~{&TAbLE_CLIENTS~}
&SCOPED-DEFINE SUBJECT ~{&TAbLE_person~}
&SCOPED-DEFINE is-mandatory NO


&SCOPED-DEFINE FIELD-NAME "reg-code"
&SCOPED-DEFINE FIELD-LABEL "Код региона"
{&create-conf-import}.

&SCOPED-DEFINE TABLE-NAME '.'
&SCOPED-DEFINE FIELD-NAME "parus-2-code"
&SCOPED-DEFINE FIELD-LABEL "Код во классиф.ПАРУС-2"
{&create-conf-import}.

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
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_cli-grp FOR ub.cli-grp.
DEFINE BUFFER buf_term_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_conf-import FOR conf-import.
DEFINE BUFFER buf2_conf-import FOR conf-import.
FOR EACH  buf_ruledict-param NO-LOCK WHERE
    buf_ruledict-param.entry-id = v-rcps-entry-id
  ,FIRST buf_rp-rule-param WHERE
      buf_rp-rule-param.profile_id = p-profile-id
  AND buf_rp-rule-param.rp-param-name = buf_ruledict-param.param-name
, first buf_tt-rule-call-param WHERE
   buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
 ,each buf_term_tt-rule-call-param where
       buf_term_tt-rule-call-param.call_id = buf_tt-rule-call-param.call_id
   and buf_term_tt-rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
   and buf_term_tt-rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
   and buf_term_tt-rule-call-param.order_id = buf_tt-rule-call-param.order_id
   and buf_term_tt-rule-call-param.param-name = buf_tt-rule-call-param.param-name
  :
  CASE buf_term_tt-rule-call-param.param-name:
      WHEN "p-delimiter" THEN DO:
          delim = buf_tt-rule-call-param.param-value-character.
      END.
      WHEN "p-uniq-method" THEN DO:
          rs-uniq-method = buf_tt-rule-call-param.param-value-character.
      END.
      WHEN "p-default-cli-grp" THEN DO:
          cli-grp-code = buf_tt-rule-call-param.param-value-integer.
      END.
      WHEN "p-firm-fields" THEN DO:
          IF buf_term_tt-rule-call-param.p-index = 0  THEN NEXT.
          FIND FIRST buf_conf-import WHERE
                    buf_conf-import.subject = {&table_firm}
                AND buf_conf-import.full-field-name = buf_term_tt-rule-call-param.param-value-character NO-ERROR.
          IF AVAILABLE buf_conf-import THEN DO:
             buf_conf-import.to-import = yes.
             buf_conf-import.position_ = buf_term_tt-rule-call-param.p-index - 1000.
          END.

      END.
      WHEN "p-person-fields" THEN DO:
          IF buf_term_tt-rule-call-param.p-index = 0  THEN NEXT.
          FIND FIRST buf_conf-import WHERE
                    buf_conf-import.subject = {&table_person}
                AND buf_conf-import.full-field-name = buf_term_tt-rule-call-param.param-value-character NO-ERROR.
          IF AVAILABLE buf_conf-import THEN DO:
             buf_conf-import.to-import = yes.
             buf_conf-import.position_ = buf_term_tt-rule-call-param.p-index - 1000.
          END.
      END.
  END CASE.
END.
define variable v-index-id as integer no-undo .
v-index-id = 0.
for each buf_conf-import where buf_conf-import.subject = {&table_firm}
and buf_conf-import.to-import = no
and buf_conf-import.position_ < 1000
:
 v-index-id = v-index-id + 1.
 buf_conf-import.position = v-index-id  + 1000.
end.
v-index-id = 0.
for each buf_conf-import where buf_conf-import.subject = {&table_firm}
by buf_conf-import.to-import descending
by buf_conf-import.position
:
 v-index-id = v-index-id + 1.
 buf_conf-import.position = v-index-id .
end.
v-index-id = 0.
for each buf_conf-import where buf_conf-import.subject = {&table_person}
and buf_conf-import.to-import = no
and buf_conf-import.position_ < 1000
:
 v-index-id = v-index-id + 1.
 buf_conf-import.position = v-index-id  + 1000.
end.
v-index-id = 0.
for each buf_conf-import where buf_conf-import.subject = {&table_person}
by buf_conf-import.to-import descending
by buf_conf-import.position
:
 v-index-id = v-index-id + 1.
 buf_conf-import.position = v-index-id .
end.



ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры импорта клиентов по профайлу &1", p-profile-id).
assign
delim:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = "Точка с запятой (;)" + {&comma-char} + ";" + {&comma-char} +
                         "Тильда (~)" + {&comma-char} + "~~" + {&comma-char} +
                          "Табулятор" + {&comma-char} + "~t"
.
ASSIGN
firm_conf-import.to-import:READ-ONLY IN BROWSE br-firm = YES
person_conf-import.to-import:READ-ONLY IN BROWSE br-person = YES
rs-uniq-method:radio-buttons = "Название" + {&comma-char} + "obj-name" + {&comma-char} +
                               "{&abbr_inn_allshift}" + "+" + "{&abbr_kpp_allshift}" + {&comma-char} + "inn+kpp".
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
 FIND FIRST buf_cli-grp NO-LOCK WHERE
     buf_cli-grp.node-code = cli-grp-code NO-ERROR.

VIEW FRAME {&frame-name}.
IF AVAILABLE buf_cli-grp THEN DO:
     assign
     cli-grp-name = buf_cli-grp.node-name
     .
     DISPLAY
     cli-grp-name
     WITH FRAME {&frame-name}.
 END.
DISPLAY
EDITOR-1
delim
cli-grp-name
rs-uniq-method
WITH FRAME {&frame-name}.
ENABLE
b-up-firm
b-down-firm
b-up-person
b-down-person
B-exit WHEN p-mode <> {&LOOKUP}
B-quit
B-help
B-cli-grp
BR-firm
BR-person
br-rcp
EDITOR-1
delim
cli-grp-name
rs-uniq-method
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
apply "value-changed" to br-firm.
apply "value-changed" to br-person.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
define variable v-ind as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  LEAVE.
END.

IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = p-index:
  RETURN. /*уже есть*/
END.

IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF buf0_tt-rule-call-param.p-index <> 0 THEN DO:
  BELL.
  RETURN.
END.
find last buf_tt-rule-call-param where
         buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
     and buf_tt-rule-call-param.codex_id = buf0_tt-rule-call-param.codex_id
     and buf_tt-rule-call-param.ruleset_id = buf0_tt-rule-call-param.ruleset_id
     and buf_tt-rule-call-param.order_id = buf0_tt-rule-call-param.order_id
     and buf_tt-rule-call-param.param-name = buf0_tt-rule-call-param.param-name no-error .
if available buf_tt-rule-call-param
and (lookup("LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     or
     lookup("SORTED-LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     )
and buf_tt-rule-call-param.p-index > 0 then do:
  v-ind = buf_tt-rule-call-param.p-index.
end.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = 0
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  create buf2_tt-rule-call-param.
  buffer-copy buf_tt-rule-call-param
  except p-index
  to buf2_tt-rule-call-param
  assign
  buf2_tt-rule-call-param.p-index = v-ind + 1
  .
end.
run rcps_Openbr in this-procedure .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.

define variable v-ind as integer no-undo .
define variable v-once-more as integer no-undo .
define variable v-call-id as character no-undo .
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  LEAVE.
END.
IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF lookup("READ-ONLY", buf0_tt-rule-call-param.param-3-data-type) > 0 THEN DO:
  BELL.
  RETURN.
END.
IF buf0_tt-rule-call-param.p-index  = 0 THEN DO:
  BELL.
  RETURN.
END.
assign
v-ind = buf0_tt-rule-call-param.p-index
v-once-more = tt-rule-call-param.once-more
v-call-id = tt-rule-call-param.call_id
.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = buf_rp-rule-param.rp-param-name
    and buf_rp-rule-param.profile_id = buf_rp-rule-param.profile_id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = v-call-id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = v-once-more
    and buf_tt-rule-call-param.p-index = v-ind
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile ):
    DELETE buf_tt-rule-call-param.

end.
run rcps_Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
define variable mydelimiter as char no-undo.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-file-name as character no-undo .
define variable v-glog as logical no-undo .
DEFINE BUFFER buf_conf-import FOR conf-import.
DEFINE BUFFER buf_cli-grp FOR ub.cli-grp.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
assign
FRAME {&FRAME-NAME}
delim
rs-uniq-method
.
if delim = "" then do:
  message "Не выбран символ-разделитель колонок в файле импорта!"
  view-as alert-box.
  return no-apply.
end.
FIND FIRST buf_cli-grp No-LOCK WHERE buf_cli-grp.node-code = cli-grp-code No-ERROR.
IF NOT avail buf_cli-grp then do:
  message "Не выбрана группа клиентов или группа клиентов неверна!"
  view-as alert-box error.
    return no-APPLY.
end.
assign
mydelimiter = delim
mydelimiter = if mydelimiter = "~t":U
              then {&tabulation}
              else mydelimiter
.

RUN rcps_set-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-default-cli-grp"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT cli-grp-code /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).

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
                                ,INPUT "p-uniq-method"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT rs-uniq-method
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT NO /*p-value-logical*/
                                ).

v-ii = 0.
FOR EACH buf_conf-import WHERE
   buf_conf-import.subject = {&table_firm}
AND buf_conf-import.to-import = YES
BY buf_conf-import.subject
BY buf_conf-import.POSITION_
:

    v-ii = v-ii + 1.
   RUN rcps_proc-b-add IN THIS-PROCEDURE (
                                     INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-firm-fields"
                                               ,INPUT v-ii).

   RUN rcps_set-value IN THIS-PROCEDURE (
                                    INPUT p-profile-id
                                   ,INPUT p-once-more
                                                              ,INPUT p-call-id
                                   ,INPUT "p-firm-fields"

                                   ,INPUT v-ii /*p-index-id*/
                                   ,INPUT buf_conf-import.full-field-name
                                   ,INPUT ? /*p-value-date*/
                                   ,INPUT 0.0 /*p-value-decimal*/
                                   ,INPUT 0 /*p-value-integer*/
                                   ,INPUT NO /*p-value-logical*/
                                   ).

END.
FOR EACH buf_tt-rule-call-param:
   IF buf_tt-rule-call-param.param-name = "p-firm-fields"
   AND buf_tt-rule-call-param.p-index > v-ii THEN DELETE buf_tt-rule-call-param.

END.

v-ii = 0.
FOR EACH buf_conf-import WHERE
   buf_conf-import.subject = {&table_person}
AND buf_conf-import.to-import = YES
BY buf_conf-import.subject
BY buf_conf-import.POSITION_
:
    v-ii = v-ii + 1.
    RUN rcps_proc-b-add IN THIS-PROCEDURE (
                                      INPUT p-profile-id
                                     ,INPUT p-once-more
                                     ,INPUT p-call-id
                                     ,INPUT "p-person-fields"
                                     ,INPUT v-ii).

    RUN rcps_set-value IN THIS-PROCEDURE (
                                     INPUT p-profile-id
                                    ,INPUT p-once-more
                                    ,INPUT p-call-id
                                    ,INPUT "p-person-fields"
                                    ,INPUT v-ii /*p-index-id*/
                                    ,INPUT buf_conf-import.full-field-name
                                    ,INPUT ? /*p-value-date*/
                                    ,INPUT 0.0 /*p-value-decimal*/
                                    ,INPUT 0 /*p-value-integer*/
                                    ,INPUT NO /*p-value-logical*/
                                   ).
END.
FOR EACH buf_tt-rule-call-param:
   IF buf_tt-rule-call-param.param-name = "p-person-fields"
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color-firm Dialog-Frame
PROCEDURE set-row-color-firm :
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
firm_conf-import.field-label:FGCOLOR IN BROWSE br-firm = iFGColor
firm_conf-import.field-label:BGCOLOR IN BROWSE br-firm = iBGColor
.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color-person Dialog-Frame
PROCEDURE set-row-color-person :
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
person_conf-import.field-label:FGCOLOR IN BROWSE br-person = iFGColor
person_conf-import.field-label:BGCOLOR IN BROWSE br-person = iBGColor
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME