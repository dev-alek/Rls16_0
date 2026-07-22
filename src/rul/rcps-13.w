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

Задание и просмотр параметров вызова правил для профайла 33

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/04/10
Author: Bakhtadze Natalya
Creation date: 04/04/10

no_app_help.i

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 33".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ rul/rcps.i local-var }
{ gbl/getcntxt.i def }
{ cmp/library.i }
{ rul/ruleset_.i }
define variable v-running-mode as logical no-undo .
define variable v-gds-index as integer no-undo .
define variable v-pay-index as integer no-undo .
define variable v-subtotal-index as integer no-undo .
&scop some-rule-id  1735
&scop some-codex-id  {&dct-proc_1}
&scop some-ruleset-id  {&dct-proc_1_sale-close_1}
&scop sum-id-dtm-code 9
&scop dis-rule-templ-rl-root 59
&scop dis-gds-rule-templ-rl-root 66
&scop tot-sum-id-sgd-dtm-code 17
&scop rule-sale-in  1663
&scop rule-sale-out 1663
&scop rule-trn-in   1663
&scop rule-trn-out  1663
&scop rule-recalc   1663


define buffer gds_tt-rule-call-param for tt-rule-call-param.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-gds-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES gds_tt-rule-call-param X_dis-rule ~
X_ruledict-param X_rp-rule-param tt-rule-call-param TERM_tt-rule-call-param

/* Definitions for BROWSE br-dis-gds-rule                               */
&Scoped-define FIELDS-IN-QUERY-br-dis-gds-rule get-param-value( INPUT gds_tt-rule-call-param.param-data-type ,INPUT gds_tt-rule-call-param.param-2-data-type ,INPUT gds_tt-rule-call-param.param-3-data-type ,INPUT gds_tt-rule-call-param.p-index ,INPUT gds_tt-rule-call-param.param-value-character ,INPUT gds_tt-rule-call-param.param-value-date ,INPUT gds_tt-rule-call-param.param-value-decimal ,INPUT gds_tt-rule-call-param.param-value-integer ,INPUT gds_tt-rule-call-param.param-value-logical) X_dis-rule.des
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-gds-rule
&Scoped-define SELF-NAME br-dis-gds-rule
&Scoped-define QUERY-STRING-br-dis-gds-rule FOR EACH gds_tt-rule-call-param where              gds_tt-rule-call-param.param-name = "p-rule-nums"          and gds_tt-rule-call-param.rule_id = {&some-rule-id}          and gds_tt-rule-call-param.codex_id = {&some-codex-id}          and gds_tt-rule-call-param.ruleset_id = {&some-ruleset-id}          and gds_tt-rule-call-param.p-index > 0, ~
           FIRST X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num = gds_tt-rule-call-param.param-value-integer
&Scoped-define OPEN-QUERY-br-dis-gds-rule OPEN QUERY br-dis-gds-rule FOR EACH gds_tt-rule-call-param where              gds_tt-rule-call-param.param-name = "p-rule-nums"          and gds_tt-rule-call-param.rule_id = {&some-rule-id}          and gds_tt-rule-call-param.codex_id = {&some-codex-id}          and gds_tt-rule-call-param.ruleset_id = {&some-ruleset-id}          and gds_tt-rule-call-param.p-index > 0, ~
           FIRST X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num = gds_tt-rule-call-param.param-value-integer .
&Scoped-define TABLES-IN-QUERY-br-dis-gds-rule gds_tt-rule-call-param ~
X_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-gds-rule gds_tt-rule-call-param
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-gds-rule X_dis-rule


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

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help rs-r-b t-is-over ~
b-dis-gds-add b-dis-gds-delete br-dis-gds-rule f-rule-num b-dis-rule ~
f-sum-id b-sum-id f-tot-sum-id-sgd b-tot-sum-id-sgd E-rules T-rule-sale-out ~
T-rule-trn-out T-rule-recalc T-rule-sale-in T-rule-trn-in BR-rcp
&Scoped-Define DISPLAYED-OBJECTS rs-r-b t-is-over f-rule-num f-sum-id ~
f-tot-sum-id-sgd E-rules T-rule-sale-out T-rule-trn-out T-rule-recalc ~
T-rule-sale-in T-rule-trn-in l-r-b f-dis-rule-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-dis-gds-add
     LABEL "+"
     SIZE 3 BY 1.

DEFINE BUTTON b-dis-gds-delete
     LABEL "-"
     SIZE 3 BY 1.

DEFINE BUTTON b-dis-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.

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

DEFINE BUTTON b-sum-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.

DEFINE BUTTON b-tot-sum-id-sgd
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.

DEFINE VARIABLE E-rules AS CHARACTER INITIAL "Проставлять рассчитанную категорию в карточку ДК при:"
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31.5 BY 2.4
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-dis-rule-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-rule-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Правило зависимости СУММА НАКОПЛЕНИЙ (по выборке товаров) -> КАТЕГОРИЯ"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.

DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Идентификатор частных итогов по выборке товаров"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-tot-sum-id-sgd AS CHARACTER FORMAT "X(256)":U
     LABEL "Идентификатор категории, рассчитанной по сумме частных итогов"
     VIEW-AS FILL-IN
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE l-r-b AS CHARACTER FORMAT "X(256)":U INITIAL "Расчет вести от:"
      VIEW-AS TEXT
     SIZE 22.5 BY .67 NO-UNDO.

DEFINE VARIABLE rs-r-b AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "rubl",
"Item 1", "base"
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE t-is-over AS LOGICAL INITIAL no
     LABEL "Учет перевыпуска карт"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-rule-recalc AS LOGICAL INITIAL no
     LABEL "Принудительный пересчет"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-rule-sale-in AS LOGICAL INITIAL no
     LABEL "Касса,возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE T-rule-sale-out AS LOGICAL INITIAL no
     LABEL "Касса,продажа"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE T-rule-trn-in AS LOGICAL INITIAL no
     LABEL "Накладная,возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-rule-trn-out AS LOGICAL INITIAL no
     LABEL "Накладная,продажа"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-gds-rule FOR
      gds_tt-rule-call-param,
      X_dis-rule SCROLLING.

DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-gds-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-gds-rule Dialog-Frame _FREEFORM
  QUERY br-dis-gds-rule DISPLAY
      get-param-value( INPUT gds_tt-rule-call-param.param-data-type
                ,INPUT gds_tt-rule-call-param.param-2-data-type
                ,INPUT gds_tt-rule-call-param.param-3-data-type
                ,INPUT gds_tt-rule-call-param.p-index
                ,INPUT gds_tt-rule-call-param.param-value-character
                ,INPUT gds_tt-rule-call-param.param-value-date
                ,INPUT gds_tt-rule-call-param.param-value-decimal
                ,INPUT gds_tt-rule-call-param.param-value-integer
                ,INPUT gds_tt-rule-call-param.param-value-logical)
column-label "Правило скидки" format "X(15)"
X_dis-rule.des FORMAT "X(255)" WIDTH 80
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6.67
         TITLE "Правила скидок типа ФЛАГ УЧАСТИЯ ТОВАРА В ВЫБОРКЕ" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN TOOLTIP "Сумма по проданному товару попадает в накопления, если у него есть это правило".

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
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     rs-r-b AT ROW 2.07 COL 25.5 NO-LABEL WIDGET-ID 106
     t-is-over AT ROW 2.07 COL 41 WIDGET-ID 88
     b-dis-gds-add AT ROW 2.07 COL 88.5 WIDGET-ID 102
     b-dis-gds-delete AT ROW 2.07 COL 91.5 WIDGET-ID 104
     br-dis-gds-rule AT ROW 3.13 COL 1 WIDGET-ID 200
     f-rule-num AT ROW 10.33 COL 72.5 COLON-ALIGNED WIDGET-ID 110
     b-dis-rule AT ROW 10.33 COL 92 WIDGET-ID 112
     f-sum-id AT ROW 12.47 COL 73 COLON-ALIGNED WIDGET-ID 114
     b-sum-id AT ROW 12.47 COL 92.5 WIDGET-ID 116
     f-tot-sum-id-sgd AT ROW 13.53 COL 73 COLON-ALIGNED WIDGET-ID 118
     b-tot-sum-id-sgd AT ROW 13.53 COL 92.5 WIDGET-ID 120
     E-rules AT ROW 14.6 COL 1 NO-LABEL WIDGET-ID 136
     T-rule-sale-out AT ROW 14.87 COL 33 WIDGET-ID 126
     T-rule-trn-out AT ROW 14.87 COL 51 WIDGET-ID 130
     T-rule-recalc AT ROW 14.87 COL 73 WIDGET-ID 134
     T-rule-sale-in AT ROW 15.87 COL 33 WIDGET-ID 128
     T-rule-trn-in AT ROW 15.87 COL 51 WIDGET-ID 132
     BR-rcp AT ROW 17 COL 1 WIDGET-ID 100
     l-r-b AT ROW 2.07 COL 1.5 NO-LABEL WIDGET-ID 122
     f-dis-rule-name AT ROW 11.4 COL 1.5 NO-LABEL WIDGET-ID 124
     SPACE(0.59) SKIP(11.19)
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
/* BROWSE-TAB br-dis-gds-rule b-dis-gds-delete Dialog-Frame */
/* BROWSE-TAB BR-rcp T-rule-trn-in Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* SETTINGS FOR FILL-IN f-dis-rule-name IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN l-r-b IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN
       l-r-b:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-gds-rule
/* Query rebuild information for BROWSE br-dis-gds-rule
     _START_FREEFORM
OPEN QUERY br-dis-gds-rule FOR EACH gds_tt-rule-call-param where
             gds_tt-rule-call-param.param-name = "p-rule-nums"
         and gds_tt-rule-call-param.rule_id = {&some-rule-id}
         and gds_tt-rule-call-param.codex_id = {&some-codex-id}
         and gds_tt-rule-call-param.ruleset_id = {&some-ruleset-id}
         and gds_tt-rule-call-param.p-index > 0,
    FIRST X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num = gds_tt-rule-call-param.param-value-integer
.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-dis-gds-rule */
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


&Scoped-define SELF-NAME b-dis-gds-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-gds-add Dialog-Frame
ON CHOOSE OF b-dis-gds-add IN FRAME Dialog-Frame /* + */
DO:
run proc-b-add in this-procedure ( input "p-rule-nums"
                                  ,input "p-rule-nums"
                                  ,input {&some-codex-id}
                                  ,INPUT {&some-ruleset-id}
                                  ,INPUT {&some-rule-id}
                                  ) no-error.
if not error-status:error then do:
  {&open-query-br-dis-gds-rule}
  reposition br-dis-gds-rule to recid recid(term_tt-rule-call-param).
  apply "entry" to br-dis-gds-rule.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-gds-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-gds-delete Dialog-Frame
ON CHOOSE OF b-dis-gds-delete IN FRAME Dialog-Frame /* - */
DO:
define variable v-index as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
  if not available gds_tt-rule-call-param then do:
    bell.
    return no-apply.
  end.
  v-index = gds_tt-rule-call-param.p-index.
  for each buf_tt-rule-call-param where
          buf_tt-rule-call-param.param-name = "p-rule-nums"
     and buf_tt-rule-call-param.p-index = v-index :
    delete buf_tt-rule-call-param.
  end.
  run resort-rule-call-param in this-procedure( input "p-rule-nums"
                                                ,input {&some-rule-id}).
  {&open-query-br-dis-gds-rule}
  reposition br-dis-gds-rule to row 1.
  apply "entry" to br-dis-gds-rule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-rule Dialog-Frame
ON CHOOSE OF b-dis-rule IN FRAME Dialog-Frame /* Btn 1 */
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
  run ref/dis-ruls.w (   input  parparentproc
                        ,input 0 /*p-host-code*/
                        ,input '':U /*p-curr-obj-type*/
                        ,input 0 /*p-curr-obj-code*/
                        ,input "b-sel,b-add"
                        ,input "upper-rule-num"
                        ,input {&dis-rule-templ-rl-root}
                        ,input ? /*p-time-templ-rl-root*/
                        ,input 0 /*p-b-code*/
                        ,input-output v-sts /*p-sts*/
                        ,input-OUTPUT v-rid-list) NO-ERROR.
  if v-rid-list <> '':U then do:
    find first buf_dis-rule no-lock where
              recid(buf_dis-rule) = integer(v-rid-list) no-error.
    if not available buf_dis-rule then do:
        MESSAGE substitute("Не найдено правило скидки c recid &1", v-rid-list)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
    end.
    assign
    f-rule-num = buf_dis-rule.rule-num
    .
    DISPLAY
    f-rule-num
    buf_dis-rule.des @ f-dis-rule-name
    WITH FRAME {&FRAME-NAME}.
  end.
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


&Scoped-define SELF-NAME b-sum-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sum-id Dialog-Frame
ON CHOOSE OF b-sum-id IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
run ref/proprefs.w (   input  parparentproc
                      ,input "b-sel,b-add"
                      ,input "dtm-code"
                      ,input  {&sum-id-dtm-code}
                      ,input '':U
                      ,input '':U /*p-call-id*/
                      ,input-OUTPUT v-rid-list) NO-ERROR.
if v-rid-list = '' then return no-apply.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-rid-list) no-error.
if not available buf_prop-ref then do:
  MESSAGE
  substitute("Нет среза с recid &1", v-rid-list)
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
end.
f-sum-id = buf_prop-ref.sum-id.
display
f-sum-id
with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-tot-sum-id-sgd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-tot-sum-id-sgd Dialog-Frame
ON CHOOSE OF b-tot-sum-id-sgd IN FRAME Dialog-Frame /* Btn 1 */
DO:
define variable v-rid-list as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
run ref/proprefs.w (   input  parparentproc
                      ,input "b-sel,b-add"
                      ,input "dtm-code"
                      ,input  {&tot-sum-id-sgd-dtm-code}
                      ,input '':U
                      ,input '':U /*p-call-id*/
                      ,input-OUTPUT v-rid-list) NO-ERROR.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-rid-list) no-error.
if not available buf_prop-ref then do:
  MESSAGE
  substitute("Нет среза с recid &1", v-rid-list)
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
end.
f-tot-sum-id-sgd = buf_prop-ref.sum-id.
display
f-tot-sum-id-sgd
with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-is-over
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-is-over Dialog-Frame
ON VALUE-CHANGED OF t-is-over IN FRAME Dialog-Frame /* Учет перевыпуска карт */
DO:
   assign
   t-is-over.
   /*проверим */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-gds-rule
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-rcp IN frame {&frame-name}
DO:
  IF AVAIL tt-rule-call-param THEN DO:
    RUN rcps_set-row-color IN THIS-PROCEDURE ( INPUT term_tt-rule-call-param.param-data-type).
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

{ rul/rcps.i procedures full }
{ rul/rcps.i interface }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
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
  if p-call-id begins {&table_schedule} then do:
    v-running-mode = yes.
  end.
  RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).
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
  DISPLAY rs-r-b t-is-over f-rule-num f-sum-id f-tot-sum-id-sgd E-rules
          T-rule-sale-out T-rule-trn-out T-rule-recalc T-rule-sale-in
          T-rule-trn-in l-r-b f-dis-rule-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rs-r-b t-is-over b-dis-gds-add b-dis-gds-delete
         br-dis-gds-rule f-rule-num b-dis-rule f-sum-id b-sum-id
         f-tot-sum-id-sgd b-tot-sum-id-sgd E-rules T-rule-sale-out
         T-rule-trn-out T-rule-recalc T-rule-sale-in T-rule-trn-in BR-rcp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE move-up-down Dialog-Frame
PROCEDURE move-up-down :
define parameter buffer source_tt-rule-call-param for tt-rule-call-param.
define input parameter p-direction as character no-undo.
define input parameter p-rule-id as integer no-undo.
define output parameter p-recid as recid no-undo.

define variable v-source as integer no-undo .
define variable v-target as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.

  if not available source_tt-rule-call-param then do:
    bell.
    return no-apply.
  end.
  assign
  v-source = source_tt-rule-call-param.p-index
  p-recid = recid(source_tt-rule-call-param)
  .
  case p-direction:
    when "down" then do:
      find first buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-rule-nums"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index > v-source no-error.
    end.
    when "up" then do:
      find last buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-rule-nums"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index < v-source
       and buf_tt-rule-call-param.p-index > 0
       no-error.
    end.
  end case.
  if not available buf_tt-rule-call-param then do:
    bell.
    return no-apply.
  end.
  assign
  v-target = buf_tt-rule-call-param.p-index.
  do transaction
  on error   undo, return no-apply
  on stop    undo, return no-apply
  on end-key undo, return no-apply:
    assign
    buf_tt-rule-call-param.p-index = -99999.
    release buf_tt-rule-call-param.
    assign
    source_tt-rule-call-param.p-index = v-target.

    find first buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-rule-nums"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index = -99999.
    assign
    buf_tt-rule-call-param.p-index = v-source.
    release buf_tt-rule-call-param.
    release source_tt-rule-call-param.
  end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-list as character no-undo .
define variable glog as logical no-undo .
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-shop-code as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
run rcps_Myenable0 in this-procedure .
ASSIGN
rs-r-b:RADIO-BUTTONS IN FRAME {&FRAME-NAME} =
{&r-b-rubl-full} + {&comma-char} + {&r-b-rubl} + {&comma-char} +
{&r-b-base-full} + {&comma-char} + {&r-b-base}
.
/*здесьс делаем получение наших данных*/
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-is-over"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output t-is-over /*p-value-logical*/
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-r-b"
                                ,INPUT-output v-index-id
                                ,output rs-r-b /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-sum-id"
                                ,INPUT-output v-index-id
                                ,output f-sum-id /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-tot-sum-id-sgd"
                                ,INPUT-output v-index-id
                                ,output f-tot-sum-id-sgd /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-rule-num"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output f-rule-num /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_sale-close_1}
                                            ,input {&rule-sale-out}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-sale-out ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_sale-delete_2}
                                            ,input {&rule-sale-in}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-sale-in ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_trn-doc-close_3}
                                            ,input {&rule-trn-out}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-trn-out ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_trn-doc-delete_4}
                                            ,input {&rule-trn-in}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-trn-in ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_batch-card-recalc_5}
                                            ,input {&rule-recalc}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-recalc ).
if f-rule-num > 0 then do:
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = f-rule-num no-error.
end.
ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
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
display
t-is-over
rs-r-b
f-rule-num
f-sum-id
f-tot-sum-id-sgd
l-r-b
(if available buf_dis-rule then buf_dis-rule.des else "Не найдено правило скидки!!!") @ f-dis-rule-name
e-rules
T-rule-recalc
T-rule-sale-in
T-rule-sale-out
T-rule-trn-in
T-rule-trn-out
with frame {&frame-name} .
VIEW FRAME {&frame-name}.
e-rules:read-only in frame {&frame-name} .
ENABLE
br-dis-gds-rule
rs-r-b WHEN p-mode <> {&LOOKUP}
b-dis-rule WHEN p-mode <> {&LOOKUP}
b-sum-id WHEN p-mode <> {&LOOKUP}
b-tot-sum-id-sgd WHEN p-mode <> {&LOOKUP}
t-is-over WHEN p-mode <> {&LOOKUP}
b-dis-gds-add WHEN p-mode <> {&LOOKUP}
b-dis-gds-delete WHEN p-mode <> {&LOOKUP}
B-exit WHEN p-mode <> {&LOOKUP}
T-rule-recalc  WHEN p-mode <> {&LOOKUP}
T-rule-sale-in  WHEN p-mode <> {&LOOKUP}
T-rule-sale-out  WHEN p-mode <> {&LOOKUP}
T-rule-trn-in  WHEN p-mode <> {&LOOKUP}
T-rule-trn-out WHEN p-mode <> {&LOOKUP}
b-quit
e-rules
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
   ASSIGN
   b-quit:COLUMN = 1
   b-quit:LABEL = "&Выход".
   HIDE
   b-exit
   IN FRAME {&FRAME-NAME}.
END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры Алгоритма СУММА НАКОПЛЕНИЙ по выборке товаров -> КАТЕГОРИЯ СКИДКИ (профайл &1)", p-profile-id).
{&OPEN-QUERY-br-dis-gds-rule}
/*RUN rcps_OpenBr in THIS-PROCEDURE.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-rule-param-name as character no-undo.
define input parameter p-rp-param-name as character no-undo.
define input parameter p-codex-id as integer no-undo.
define input parameter p-ruleset-id as integer no-undo.
define input parameter p-rule-id as integer no-undo.

define buffer buf_tt-rule-call-param for tt-rule-call-param.
define variable v-ii as integer no-undo .
do v-ii = 1 to 99999:
  find first buf_tt-rule-call-param where
          buf_tt-rule-call-param.param-name = p-rule-param-name
      and buf_tt-rule-call-param.rule_id = p-rule-id
      and buf_tt-rule-call-param.codex_id = p-codex-id
      and buf_tt-rule-call-param.ruleset_id = p-ruleset-id
      and buf_tt-rule-call-param.p-index = v-ii no-error.
  if not available buf_tt-rule-call-param then do:
    v-gds-index = v-ii.
    leave.
  end.
end.
run rcps_proc-b-add in this-procedure (
                                        input p-profile-id
                                        ,INPUT p-once-more
                                        ,input p-call-id
                                        ,input p-rp-param-name
                                        ,input v-gds-index ) no-error.
if error-status:error then return error.
find first TERM_tt-rule-call-param where
          TERM_tt-rule-call-param.param-name = p-rule-param-name
    and term_tt-rule-call-param.rule_id = p-rule-id
    and term_tt-rule-call-param.codex_id = p-codex-id
    and term_tt-rule-call-param.ruleset_id = p-ruleset-id
    and term_tt-rule-call-param.p-index = v-ii .
run proc-b-chg in this-procedure ( input p-rp-param-name ) no-error.
if error-status:error then do:
  delete term_tt-rule-call-param.
  return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
define input parameter p-rp-param-name as character no-undo.
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
define buffer dbl_tt-rule-call-param for tt-rule-call-param.

assign
v-value-character = term_tt-rule-call-param.param-value-character
v-value-date = term_tt-rule-call-param.param-value-date
v-value-decimal = term_tt-rule-call-param.param-value-decimal
v-value-integer = term_tt-rule-call-param.param-value-integer
v-value-logical = term_tt-rule-call-param.param-value-logical
.
run ref/rule-dtt.p (
                     input parparentproc
                    ,input {&update}
                    ,input p-call-id
                    ,input term_tt-rule-call-param.param-data-type
                    ,input term_tt-rule-call-param.param-2-data-type
                    ,input term_tt-rule-call-param.param-3-data-type
                    ,input term_tt-rule-call-param.p-index
                    ,input-output v-value-character
                    ,input-output v-value-date
                    ,input-output v-value-decimal
                    ,input-output v-value-integer
                    ,input-output v-value-logical
                    ,output v-ok
                    ) no-error.
if not error-status:error
and v-ok then do:
  find first dbl_tt-rule-call-param where
            dbl_tt-rule-call-param.rule_id = term_tt-rule-call-param.rule_id
        and dbl_tt-rule-call-param.param-value-integer = v-value-integer
        and dbl_tt-rule-call-param.p-index <> term_tt-rule-call-param.p-index no-error.
  if available dbl_tt-rule-call-param then do:
    message
    substitute("Вы уже выбирали это правило скидки")
    view-as alert-box error .
    return error.
  end.
  define variable v-mess as character no-undo .
  RUN set-value IN THIS-PROCEDURE (
                                   INPUT term_tt-rule-call-param.profile_id
                                  ,INPUT term_tt-rule-call-param.once-more
                                  ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                         then p-rp-param-name
                                         else '':U)
                                  ,INPUT term_tt-rule-call-param.call_id
                                  ,INPUT term_tt-rule-call-param.codex_id
                                  ,INPUT term_tt-rule-call-param.ruleset_id
                                  ,INPUT term_tt-rule-call-param.order_id
                                  ,INPUT term_tt-rule-call-param.param-name
                                  ,INPUT term_tt-rule-call-param.p-index
                                   ,INPUT v-value-character
                                   ,INPUT v-value-date
                                   ,INPUT v-value-decimal
                                   ,INPUT v-value-integer
                                   ,INPUT v-value-logical).
end.
else do:
  return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*здесь делаем assig и свои свобсвтенные проверки*/
define variable v-ii as integer   no-undo .
v-ii = 0.
assign
frame {&frame-name}
t-is-over
T-rule-recalc
T-rule-sale-in
T-rule-sale-out
T-rule-trn-in
T-rule-trn-out
f-rule-num
f-sum-id
f-tot-sum-id-sgd
rs-r-b
.
run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                           ,input {&dct-proc_2_sale-close_1}
                                           ,input {&rule-sale-out}
                                           ,input p-profile-id
                                           ,input p-once-more
                                           ,input t-rule-sale-out).

run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_sale-delete_2}
                                            ,input {&rule-sale-in}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-sale-in ).

run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_trn-doc-close_3}
                                            ,input {&rule-trn-out}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-trn-out ).

run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_trn-doc-delete_4}
                                            ,input {&rule-trn-in}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-trn-in ).

run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_batch-card-recalc_5}
                                            ,input {&rule-recalc}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-recalc ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-is-over"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT t-is-over /*p-value-logical*/
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-r-b"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT rs-r-b /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-rule-num"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT f-rule-num /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-sum-id"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT f-sum-id /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-tot-sum-id-sgd"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT f-tot-sum-id-sgd /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).



run resort-rule-call-param in this-procedure ( input "p-rule-nums"
                                               ,input {&some-rule-id}).
run rcps_proc-save0 in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE resort-rule-call-param Dialog-Frame
PROCEDURE resort-rule-call-param :
define input parameter p-rule-param-name as character no-undo.
define input parameter p-rule-id as integer no-undo.
define variable v-ii as integer no-undo.
define variable v-index as integer no-undo.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
do v-ii = 1 to 99999:
  for each buf_tt-rule-call-param where
            buf_tt-rule-call-param.rule_id = p-rule-id
        and buf_tt-rule-call-param.param-name = p-rule-param-name
        and buf_tt-rule-call-param.p-index >= v-ii
   by buf_tt-rule-call-param.p-index:
    v-index = buf_tt-rule-call-param.p-index .
    leave.
  end.      .
  if not available buf_tt-rule-call-param then leave.
  if buf_tt-rule-call-param.p-index <> v-ii then do:
    for each buf2_tt-rule-call-param where
            buf2_tt-rule-call-param.param-name = p-rule-param-name
        and buf2_tt-rule-call-param.p-index = v-index:
      assign
      buf2_tt-rule-call-param.p-index = v-ii.
      release buf2_tt-rule-call-param.
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-value Dialog-Frame
PROCEDURE set-value :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-param-name AS character NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
CASE p-list-mode:
  WHEN {&TABLE_rp-rule-param} THEN DO:
      FOR EACH  buf_rp-rule-param NO-LOCK where
          buf_rp-rule-param.profile_id = p-profile-id
          AND buf_rp-rule-param.rp-param-name = p-rp-param-name
          ,EACH buf_tt-rule-call-param WHERE
             buf_tt-rule-call-param.profile_id = p-profile-id
          AND buf_tt-rule-call-param.once-more = p-once-more
          AND buf_tt-rule-call-param.call_id = p-CALL-id
          AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
          AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
          AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
          AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
          AND buf_tt-rule-call-param.p-index = p-index
        ON error undo, return error :

          assign
          buf_tt-rule-call-param.param-value-character = p-value-character
          buf_tt-rule-call-param.param-value-date      = p-value-date
          buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
          buf_tt-rule-call-param.param-value-integer   = p-value-integer
          buf_tt-rule-call-param.param-value-logical   = p-value-logical
          .

      END.
  END.
  WHEN {&TABLE_rule-call-param} THEN DO:
    FIND FIRST buf_tt-rule-call-param WHERE
        buf_tt-rule-call-param.call_id = p-call-id
    AND buf_tt-rule-call-param.codex_id = p-codex-id
    AND buf_tt-rule-call-param.ruleset_id = p-ruleset-id
    AND buf_tt-rule-call-param.order_id = p-order-id
    AND buf_tt-rule-call-param.param-name = p-param-name
    AND buf_tt-rule-call-param.p-index = p-index.
    assign
    buf_tt-rule-call-param.param-value-character = p-value-character
    buf_tt-rule-call-param.param-value-date      = p-value-date
    buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
    buf_tt-rule-call-param.param-value-integer   = p-value-integer
    buf_tt-rule-call-param.param-value-logical   = p-value-logical
    .

  END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME