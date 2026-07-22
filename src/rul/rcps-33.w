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
define variable v-running-mode as logical no-undo .
define variable v-gds-index as integer no-undo .
define variable v-pay-index as integer no-undo .
define variable v-subtotal-index as integer no-undo .
&scop gds-rule-id 1971
&scop subtotal-rule-id 1972
&scop pay-rule-id 1973


define buffer gds_tt-rule-call-param for tt-rule-call-param.
define buffer subtotal_tt-rule-call-param for tt-rule-call-param.
define buffer pay_tt-rule-call-param for tt-rule-call-param.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES gds_tt-rule-call-param ~
pay_tt-rule-call-param X_ruledict-param X_rp-rule-param tt-rule-call-param ~
TERM_tt-rule-call-param subtotal_tt-rule-call-param

/* Definitions for BROWSE br-gds                                        */
&Scoped-define FIELDS-IN-QUERY-br-gds get-param-value( INPUT gds_tt-rule-call-param.param-data-type ,INPUT gds_tt-rule-call-param.param-2-data-type ,INPUT gds_tt-rule-call-param.param-3-data-type ,INPUT gds_tt-rule-call-param.p-index ,INPUT gds_tt-rule-call-param.param-value-character ,INPUT gds_tt-rule-call-param.param-value-date ,INPUT gds_tt-rule-call-param.param-value-decimal ,INPUT gds_tt-rule-call-param.param-value-integer ,INPUT gds_tt-rule-call-param.param-value-logical) gds_tt-rule-call-param.p-index
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-gds
&Scoped-define SELF-NAME br-gds
&Scoped-define QUERY-STRING-br-gds FOR EACH gds_tt-rule-call-param where              gds_tt-rule-call-param.param-name = "p-discnt-roles"          and gds_tt-rule-call-param.rule_id = {&gds-rule-id}          and gds_tt-rule-call-param.p-index > 0 by gds_tt-rule-call-param.p-index
&Scoped-define OPEN-QUERY-br-gds OPEN QUERY br-gds FOR EACH gds_tt-rule-call-param where              gds_tt-rule-call-param.param-name = "p-discnt-roles"          and gds_tt-rule-call-param.rule_id = {&gds-rule-id}          and gds_tt-rule-call-param.p-index > 0 by gds_tt-rule-call-param.p-index          .
&Scoped-define TABLES-IN-QUERY-br-gds gds_tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-br-gds gds_tt-rule-call-param


/* Definitions for BROWSE br-pay                                        */
&Scoped-define FIELDS-IN-QUERY-br-pay get-param-value( INPUT pay_tt-rule-call-param.param-data-type ,INPUT pay_tt-rule-call-param.param-2-data-type ,INPUT pay_tt-rule-call-param.param-3-data-type ,INPUT pay_tt-rule-call-param.p-index ,INPUT pay_tt-rule-call-param.param-value-character ,INPUT pay_tt-rule-call-param.param-value-date ,INPUT pay_tt-rule-call-param.param-value-decimal ,INPUT pay_tt-rule-call-param.param-value-integer ,INPUT pay_tt-rule-call-param.param-value-logical)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pay
&Scoped-define SELF-NAME br-pay
&Scoped-define QUERY-STRING-br-pay FOR EACH pay_tt-rule-call-param where              pay_tt-rule-call-param.param-name = "p-discnt-roles"          and pay_tt-rule-call-param.rule_id = {&pay-rule-id}          and pay_tt-rule-call-param.p-index > 0 by pay_tt-rule-call-param.p-index
&Scoped-define OPEN-QUERY-br-pay OPEN QUERY br-pay FOR EACH pay_tt-rule-call-param where              pay_tt-rule-call-param.param-name = "p-discnt-roles"          and pay_tt-rule-call-param.rule_id = {&pay-rule-id}          and pay_tt-rule-call-param.p-index > 0 by pay_tt-rule-call-param.p-index           .
&Scoped-define TABLES-IN-QUERY-br-pay pay_tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-br-pay pay_tt-rule-call-param


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


/* Definitions for BROWSE br-subtotal                                   */
&Scoped-define FIELDS-IN-QUERY-br-subtotal get-param-value( INPUT subtotal_tt-rule-call-param.param-data-type ,INPUT subtotal_tt-rule-call-param.param-2-data-type ,INPUT subtotal_tt-rule-call-param.param-3-data-type ,INPUT subtotal_tt-rule-call-param.p-index ,INPUT subtotal_tt-rule-call-param.param-value-character ,INPUT subtotal_tt-rule-call-param.param-value-date ,INPUT subtotal_tt-rule-call-param.param-value-decimal ,INPUT subtotal_tt-rule-call-param.param-value-integer ,INPUT subtotal_tt-rule-call-param.param-value-logical)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-subtotal
&Scoped-define SELF-NAME br-subtotal
&Scoped-define QUERY-STRING-br-subtotal FOR EACH subtotal_tt-rule-call-param where              subtotal_tt-rule-call-param.param-name = "p-discnt-roles"          and subtotal_tt-rule-call-param.rule_id = {&subtotal-rule-id}          and subtotal_tt-rule-call-param.p-index > 0 by subtotal_tt-rule-call-param.p-index
&Scoped-define OPEN-QUERY-br-subtotal OPEN QUERY br-subtotal FOR EACH subtotal_tt-rule-call-param where              subtotal_tt-rule-call-param.param-name = "p-discnt-roles"          and subtotal_tt-rule-call-param.rule_id = {&subtotal-rule-id}          and subtotal_tt-rule-call-param.p-index > 0 by subtotal_tt-rule-call-param.p-index            .
&Scoped-define TABLES-IN-QUERY-br-subtotal subtotal_tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-br-subtotal subtotal_tt-rule-call-param


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-gds-add b-gds-delete B-Help ~
br-gds t-rule-gds t-add-gds-discnts B-gds-up B-gds-down b-subtotal-add ~
b-subtotal-delete t-rule-subtotal br-subtotal t-add-subtotal-discnts ~
B-subtotal-up B-subtotal-down b-pay-add b-pay-delete t-rule-pay br-pay ~
B-pay-up t-add-pay-discnts B-pay-down BR-rcp
&Scoped-Define DISPLAYED-OBJECTS t-rule-gds t-add-gds-discnts ~
t-rule-subtotal t-add-subtotal-discnts t-rule-pay t-add-pay-discnts

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-gds-add
     LABEL "+"
     SIZE 3 BY 1.

DEFINE BUTTON b-gds-delete
     LABEL "-"
     SIZE 3 BY 1.

DEFINE BUTTON B-gds-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "down"
     SIZE 3 BY 1.

DEFINE BUTTON B-gds-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL "up"
     SIZE 3 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-pay-add
     LABEL "+"
     SIZE 3 BY 1.

DEFINE BUTTON b-pay-delete
     LABEL "-"
     SIZE 3 BY 1.

DEFINE BUTTON B-pay-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "down"
     SIZE 3 BY 1.

DEFINE BUTTON B-pay-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL "up"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-subtotal-add
     LABEL "+"
     SIZE 3 BY 1.

DEFINE BUTTON b-subtotal-delete
     LABEL "-"
     SIZE 3 BY 1.

DEFINE BUTTON B-subtotal-down
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "down"
     SIZE 3 BY 1.

DEFINE BUTTON B-subtotal-up
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U
     LABEL "up"
     SIZE 3 BY 1.

DEFINE VARIABLE t-add-gds-discnts AS LOGICAL INITIAL no
     LABEL "<Складывать> скидки на строку товара"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE t-add-pay-discnts AS LOGICAL INITIAL no
     LABEL "<Складывать> скидки на строку оплат"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE t-add-subtotal-discnts AS LOGICAL INITIAL no
     LABEL "<Складывать> скидки на подитог"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE t-rule-gds AS LOGICAL INITIAL no
     LABEL "Применять скидки на строку товара"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE t-rule-pay AS LOGICAL INITIAL no
     LABEL "Применять скидки на строку оплат"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE t-rule-subtotal AS LOGICAL INITIAL no
     LABEL "Применять скидки на подитог"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-gds FOR
      gds_tt-rule-call-param SCROLLING.

DEFINE QUERY br-pay FOR
      pay_tt-rule-call-param SCROLLING.

DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.

DEFINE QUERY br-subtotal FOR
      subtotal_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gds Dialog-Frame _FREEFORM
  QUERY br-gds DISPLAY
      get-param-value( INPUT gds_tt-rule-call-param.param-data-type
                ,INPUT gds_tt-rule-call-param.param-2-data-type
                ,INPUT gds_tt-rule-call-param.param-3-data-type
                ,INPUT gds_tt-rule-call-param.p-index
                ,INPUT gds_tt-rule-call-param.param-value-character
                ,INPUT gds_tt-rule-call-param.param-value-date
                ,INPUT gds_tt-rule-call-param.param-value-decimal
                ,INPUT gds_tt-rule-call-param.param-value-integer
                ,INPUT gds_tt-rule-call-param.param-value-logical)
column-label "Тип скидки" format "X(40)"
gds_tt-rule-call-param.p-index column-label "Приоритет" format ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 55 BY 5.6
         TITLE "Скидки, применяемые к строке товара (в пор-ке убыв. приоритета)" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE br-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pay Dialog-Frame _FREEFORM
  QUERY br-pay DISPLAY
      get-param-value( INPUT pay_tt-rule-call-param.param-data-type
                ,INPUT pay_tt-rule-call-param.param-2-data-type
                ,INPUT pay_tt-rule-call-param.param-3-data-type
                ,INPUT pay_tt-rule-call-param.p-index
                ,INPUT pay_tt-rule-call-param.param-value-character
                ,INPUT pay_tt-rule-call-param.param-value-date
                ,INPUT pay_tt-rule-call-param.param-value-decimal
                ,INPUT pay_tt-rule-call-param.param-value-integer
                ,INPUT pay_tt-rule-call-param.param-value-logical)
column-label "Тип скидки" format "X(40)"
pay_tt-rule-call-param.p-index column-label "Приоритет" format ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 55 BY 5.6
         TITLE "Скидки, применяемые к строке опат (в пор-ке убыв. приоритета)" FIT-LAST-COLUMN.

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

DEFINE BROWSE br-subtotal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-subtotal Dialog-Frame _FREEFORM
  QUERY br-subtotal DISPLAY
      get-param-value( INPUT subtotal_tt-rule-call-param.param-data-type
                ,INPUT subtotal_tt-rule-call-param.param-2-data-type
                ,INPUT subtotal_tt-rule-call-param.param-3-data-type
                ,INPUT subtotal_tt-rule-call-param.p-index
                ,INPUT subtotal_tt-rule-call-param.param-value-character
                ,INPUT subtotal_tt-rule-call-param.param-value-date
                ,INPUT subtotal_tt-rule-call-param.param-value-decimal
                ,INPUT subtotal_tt-rule-call-param.param-value-integer
                ,INPUT subtotal_tt-rule-call-param.param-value-logical)
column-label "Тип скидки" format "X(40)"
subtotal_tt-rule-call-param.p-index column-label "Приоритет" format ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 55 BY 5.6
         TITLE "Скидки, применяемые к подитогу (в пор-ке убыв. приоритета)" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-gds-add AT ROW 1 COL 69 WIDGET-ID 102
     b-gds-delete AT ROW 1 COL 72 WIDGET-ID 104
     B-Help AT ROW 1 COL 95
     br-gds AT ROW 2 COL 41 WIDGET-ID 200
     t-rule-gds AT ROW 2.07 COL 1 WIDGET-ID 96
     t-add-gds-discnts AT ROW 3.13 COL 1 WIDGET-ID 88
     B-gds-up AT ROW 3.13 COL 96 WIDGET-ID 114
     B-gds-down AT ROW 4.13 COL 96 WIDGET-ID 116
     b-subtotal-add AT ROW 7.67 COL 69 WIDGET-ID 106
     b-subtotal-delete AT ROW 7.67 COL 72 WIDGET-ID 108
     t-rule-subtotal AT ROW 8.2 COL 1 WIDGET-ID 98
     br-subtotal AT ROW 8.47 COL 41 WIDGET-ID 300
     t-add-subtotal-discnts AT ROW 9.27 COL 1 WIDGET-ID 92
     B-subtotal-up AT ROW 9.53 COL 96 WIDGET-ID 120
     B-subtotal-down AT ROW 10.53 COL 96 WIDGET-ID 118
     b-pay-add AT ROW 14 COL 69 WIDGET-ID 110
     b-pay-delete AT ROW 14 COL 72 WIDGET-ID 112
     t-rule-pay AT ROW 14.8 COL 1 WIDGET-ID 100
     br-pay AT ROW 14.8 COL 41 WIDGET-ID 400
     B-pay-up AT ROW 15.6 COL 96 WIDGET-ID 124
     t-add-pay-discnts AT ROW 16.13 COL 1 WIDGET-ID 94
     B-pay-down AT ROW 16.6 COL 96 WIDGET-ID 122
     BR-rcp AT ROW 17 COL 1 WIDGET-ID 100
     SPACE(0.00) SKIP(0.25)
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
/* BROWSE-TAB br-gds B-Help Dialog-Frame */
/* BROWSE-TAB br-subtotal t-rule-subtotal Dialog-Frame */
/* BROWSE-TAB br-pay t-rule-pay Dialog-Frame */
/* BROWSE-TAB BR-rcp B-pay-down Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-gds
/* Query rebuild information for BROWSE br-gds
     _START_FREEFORM
OPEN QUERY br-gds FOR EACH gds_tt-rule-call-param where
             gds_tt-rule-call-param.param-name = "p-discnt-roles"
         and gds_tt-rule-call-param.rule_id = {&gds-rule-id}
         and gds_tt-rule-call-param.p-index > 0
by gds_tt-rule-call-param.p-index
         .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-gds */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pay
/* Query rebuild information for BROWSE br-pay
     _START_FREEFORM
OPEN QUERY br-pay FOR EACH pay_tt-rule-call-param where
             pay_tt-rule-call-param.param-name = "p-discnt-roles"
         and pay_tt-rule-call-param.rule_id = {&pay-rule-id}
         and pay_tt-rule-call-param.p-index > 0
by pay_tt-rule-call-param.p-index

         .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-pay */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-subtotal
/* Query rebuild information for BROWSE br-subtotal
     _START_FREEFORM
OPEN QUERY br-subtotal FOR EACH subtotal_tt-rule-call-param where
             subtotal_tt-rule-call-param.param-name = "p-discnt-roles"
         and subtotal_tt-rule-call-param.rule_id = {&subtotal-rule-id}
         and subtotal_tt-rule-call-param.p-index > 0
by subtotal_tt-rule-call-param.p-index


         .
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE br-subtotal */
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


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE  NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-add Dialog-Frame
ON CHOOSE OF b-gds-add IN FRAME Dialog-Frame /* + */
DO:
run proc-b-add in this-procedure ( input "p-discnt-roles"
                                  ,input "p-gds-discnt-roles"
                                  ,input {&gds-rule-id}
                                  ) no-error.
if not error-status:error then do:
  {&open-query-br-gds}
  reposition br-gds to recid recid(term_tt-rule-call-param).
  apply "entry" to br-gds.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-gds-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-gds-delete Dialog-Frame
ON CHOOSE OF b-gds-delete IN FRAME Dialog-Frame /* - */
DO:
  if not available gds_tt-rule-call-param then do:
    bell.
    return no-apply.
  end.
  delete gds_tt-rule-call-param.
  run resort-rule-call-param in this-procedure( input "p-discnt-roles"
                                                ,input {&gds-rule-id}).
  {&open-query-br-gds}
  reposition br-gds to row 1.
  apply "entry" to br-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds-down Dialog-Frame
ON CHOOSE OF B-gds-down IN FRAME Dialog-Frame /* down */
DO:
define variable v-recid as recid no-undo .
run move-up-down in this-procedure ( buffer gds_tt-rule-call-param
                                     ,input "down"
                                     ,input {&gds-rule-id}
                                     ,output v-recid) no-error.
if error-status:error then do:
message error-status:get-message(1) view-as alert-box.
end.
  {&open-query-br-gds}
  reposition br-gds to recid(v-recid) no-error.
  apply "ENTRY" to br-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-gds-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-gds-up Dialog-Frame
ON CHOOSE OF B-gds-up IN FRAME Dialog-Frame /* up */
DO:
define variable v-recid as recid no-undo .
run move-up-down in this-procedure ( buffer gds_tt-rule-call-param
                                     ,input "up"
                                     ,input {&gds-rule-id}
                                     ,output v-recid) no-error.
  {&open-query-br-gds}
  reposition br-gds to recid(v-recid) no-error.
  apply "ENTRY" to br-gds.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pay-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pay-add Dialog-Frame
ON CHOOSE OF b-pay-add IN FRAME Dialog-Frame /* + */
DO:

run proc-b-add in this-procedure ( input "p-discnt-roles"
                                  ,input "p-pay-discnt-roles"
                                  ,input {&pay-rule-id}
                                  ) no-error.
if not error-status:error then do:
  {&open-query-br-pay}
  reposition br-pay to recid recid(term_tt-rule-call-param).
  apply "entry" to br-pay.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-pay-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-pay-delete Dialog-Frame
ON CHOOSE OF b-pay-delete IN FRAME Dialog-Frame /* - */
DO:
  if not available pay_tt-rule-call-param then return no-apply.
  delete pay_tt-rule-call-param.
  run resort-rule-call-param in this-procedure( input "p-discnt-roles"
                                                ,input {&pay-rule-id}).

  {&open-query-br-pay}
  reposition br-pay to row 1.
  apply "entry" to br-pay.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pay-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pay-down Dialog-Frame
ON CHOOSE OF B-pay-down IN FRAME Dialog-Frame /* down */
DO:
define variable v-recid as recid no-undo .
run move-up-down in this-procedure ( buffer pay_tt-rule-call-param
                                     ,input "down"
                                     ,input {&pay-rule-id}
                                     ,output v-recid) no-error.
  {&open-query-br-pay}
  reposition br-pay to recid(v-recid) no-error.
  apply "ENTRY" to br-pay.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pay-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pay-up Dialog-Frame
ON CHOOSE OF B-pay-up IN FRAME Dialog-Frame /* up */
DO:
define variable v-recid as recid no-undo .
run move-up-down in this-procedure ( buffer pay_tt-rule-call-param
                                     ,input "up"
                                     ,input {&pay-rule-id}
                                     ,output v-recid) no-error.
  {&open-query-br-pay}
  reposition br-pay to recid(v-recid) no-error.
  apply "ENTRY" to br-pay.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-subtotal-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-subtotal-add Dialog-Frame
ON CHOOSE OF b-subtotal-add IN FRAME Dialog-Frame /* + */
DO:
run proc-b-add in this-procedure ( input "p-discnt-roles"
                                  ,input "p-subtotal-discnt-roles"
                                  ,input {&subtotal-rule-id}
                                  ) no-error.
if not error-status:error then do:
  {&open-query-br-subtotal}
  reposition br-subtotal to recid recid(term_tt-rule-call-param).
  apply "entry" to br-subtotal.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-subtotal-delete
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-subtotal-delete Dialog-Frame
ON CHOOSE OF b-subtotal-delete IN FRAME Dialog-Frame /* - */
DO:
  if not available subtotal_tt-rule-call-param then return no-apply.
  delete subtotal_tt-rule-call-param.
  run resort-rule-call-param in this-procedure( input "p-discnt-roles"
                                                ,input {&subtotal-rule-id}).

  {&open-query-br-subtotal}
  reposition br-subtotal to row 1.
  apply "entry" to br-subtotal.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-subtotal-down
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-subtotal-down Dialog-Frame
ON CHOOSE OF B-subtotal-down IN FRAME Dialog-Frame /* down */
DO:
define variable v-recid as recid no-undo .
run move-up-down in this-procedure ( buffer subtotal_tt-rule-call-param
                                     ,input "down"
                                     ,input {&subtotal-rule-id}
                                     ,output v-recid) no-error.
  {&open-query-br-subtotal}
  reposition br-subtotal to recid(v-recid) no-error.
  apply "ENTRY" to br-subtotal.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-subtotal-up
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-subtotal-up Dialog-Frame
ON CHOOSE OF B-subtotal-up IN FRAME Dialog-Frame /* up */
DO:
define variable v-recid as recid no-undo .
run move-up-down in this-procedure ( buffer subtotal_tt-rule-call-param
                                     ,input "up"
                                     ,input {&subtotal-rule-id}
                                     ,output v-recid) no-error.
  {&open-query-br-subtotal}
  reposition br-subtotal to recid(v-recid) no-error.
  apply "ENTRY" to br-subtotal.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rule-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rule-gds Dialog-Frame
ON VALUE-CHANGED OF t-rule-gds IN FRAME Dialog-Frame /* Применять скидки на строку товара */
DO:
  assign
  t-rule-gds.
  case t-rule-gds:
    when yes then do:
       if p-mode <> {&lookup} then do:
        enable
        t-add-gds-discnts
        b-gds-add
        b-gds-delete
        b-gds-up
        b-gds-down
        with frame {&frame-name}.
       end.
    end.
    when no then do:
      for each gds_tt-rule-call-param where
            gds_tt-rule-call-param.param-name = "p-discnt-roles"
        and gds_tt-rule-call-param.rule_id = {&gds-rule-id}
        and gds_tt-rule-call-param.p-index > 0:
          delete gds_tt-rule-call-param.
      end.
      assign
      t-add-gds-discnts = no.
      display
      t-add-gds-discnts
      with frame {&frame-name}.
      disable
      t-add-gds-discnts
      b-gds-add
      b-gds-delete
      b-gds-up
      b-gds-down
      with frame {&frame-name}.
      {&open-query-br-gds}
     end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rule-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rule-pay Dialog-Frame
ON VALUE-CHANGED OF t-rule-pay IN FRAME Dialog-Frame /* Применять скидки на строку оплат */
DO:
    assign
  t-rule-pay.
  case t-rule-pay:
    when yes then do:
       if p-mode <> {&lookup} then do:
        enable
        t-add-pay-discnts
        b-pay-add
        b-pay-delete
        b-pay-up
        b-pay-down
        with frame {&frame-name}.
       end.
    end.
    when no then do:
      for each pay_tt-rule-call-param where
            pay_tt-rule-call-param.param-name = "p-discnt-roles"
        and pay_tt-rule-call-param.rule_id = {&pay-rule-id}
        and pay_tt-rule-call-param.p-index > 0:
          delete pay_tt-rule-call-param.
      end.
      assign
      t-add-pay-discnts = no.
      display
      t-add-pay-discnts
      with frame {&frame-name}.
      disable
      t-add-pay-discnts
      b-pay-add
      b-pay-delete
      b-pay-up
      b-pay-down
      with frame {&frame-name}.
      {&open-query-br-pay}
     end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-rule-subtotal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-rule-subtotal Dialog-Frame
ON VALUE-CHANGED OF t-rule-subtotal IN FRAME Dialog-Frame /* Применять скидки на подитог */
DO:
    assign
  t-rule-subtotal.
  case t-rule-subtotal:
    when yes then do:
       if p-mode <> {&lookup} then do:
        enable
        t-add-subtotal-discnts
        b-subtotal-add
        b-subtotal-delete
        b-subtotal-up
        b-subtotal-down
        with frame {&frame-name}.
       end.
    end.
    when no then do:
      for each subtotal_tt-rule-call-param where
            subtotal_tt-rule-call-param.param-name = "p-discnt-roles"
        and subtotal_tt-rule-call-param.rule_id = {&subtotal-rule-id}
        and subtotal_tt-rule-call-param.p-index > 0:
          delete subtotal_tt-rule-call-param.
      end.
      assign
      t-add-subtotal-discnts = no.
      display
      t-add-subtotal-discnts
      with frame {&frame-name}.
      disable
      t-add-subtotal-discnts
      b-subtotal-add
      b-subtotal-delete
      b-subtotal-up
      b-subtotal-down
      with frame {&frame-name}.
      {&open-query-br-subtotal}
     end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gds
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
  DISPLAY t-rule-gds t-add-gds-discnts t-rule-subtotal t-add-subtotal-discnts
          t-rule-pay t-add-pay-discnts
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-gds-add b-gds-delete B-Help br-gds t-rule-gds
         t-add-gds-discnts B-gds-up B-gds-down b-subtotal-add b-subtotal-delete
         t-rule-subtotal br-subtotal t-add-subtotal-discnts B-subtotal-up
         B-subtotal-down b-pay-add b-pay-delete t-rule-pay br-pay B-pay-up
         t-add-pay-discnts B-pay-down BR-rcp
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
           buf_tt-rule-call-param.param-name = "p-discnt-roles"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index > v-source no-error.
    end.
    when "up" then do:
      find last buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-discnt-roles"
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
           buf_tt-rule-call-param.param-name = "p-discnt-roles"
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
define buffer buf_clob-bind for ub.clob-bind.
run rcps_Myenable0 in this-procedure .
/*здесьс делаем получение наших данных*/
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-add-gds-discnts"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output t-add-gds-discnts /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-add-subtotal-discnts"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output t-add-subtotal-discnts /*p-value-logical*/
                                ).
run rcps_get-rule-on-off in this-procedure ( input 15
                                            ,input 1
                                            ,input {&gds-rule-id}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-gds ).
run rcps_get-rule-on-off in this-procedure ( input 16
                                            ,input 1
                                            ,input {&subtotal-rule-id}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-subtotal ).
run rcps_get-rule-on-off in this-procedure ( input 17
                                            ,input 1
                                            ,input {&pay-rule-id}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-pay ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-add-pay-discnts"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output t-add-pay-discnts /*p-value-logical*/
                                ).


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
t-add-gds-discnts
t-add-subtotal-discnts
t-add-pay-discnts
t-rule-gds
t-rule-subtotal
t-rule-pay
with frame {&frame-name} .
VIEW FRAME {&frame-name}.
ENABLE
br-gds
br-subtotal
br-pay
t-add-gds-discnts          WHEN p-mode <> {&LOOKUP}
t-add-subtotal-discnts     WHEN p-mode <> {&LOOKUP}
t-add-pay-discnts          WHEN p-mode <> {&LOOKUP}
t-rule-gds                WHEN p-mode <> {&LOOKUP}
t-rule-subtotal                WHEN p-mode <> {&LOOKUP}
t-rule-pay                WHEN p-mode <> {&LOOKUP}
b-gds-add WHEN p-mode <> {&LOOKUP}
b-gds-delete WHEN p-mode <> {&LOOKUP}
b-pay-add WHEN p-mode <> {&LOOKUP}
b-pay-delete WHEN p-mode <> {&LOOKUP}
b-subtotal-add WHEN p-mode <> {&LOOKUP}
b-subtotal-delete WHEN p-mode <> {&LOOKUP}
b-gds-up WHEN p-mode <> {&LOOKUP}
b-gds-down WHEN p-mode <> {&LOOKUP}
b-pay-up WHEN p-mode <> {&LOOKUP}
b-pay-down WHEN p-mode <> {&LOOKUP}
b-subtotal-up WHEN p-mode <> {&LOOKUP}
b-subtotal-down WHEN p-mode <> {&LOOKUP}
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
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
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры стандартного расчета скидки в чеке на IBS TH POS (профайл &1)", p-profile-id).
{&OPEN-QUERY-br-gds}
{&OPEN-QUERY-br-subtotal}
{&OPEN-QUERY-br-pay}
/*RUN rcps_OpenBr in THIS-PROCEDURE.*/
APPLY "VALUE-CHANGED" to t-rule-gds.
APPLY "VALUE-CHANGED" to t-rule-subtotal.
APPLY "VALUE-CHANGED" to t-rule-pay.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define input parameter p-rule-param-name as character no-undo.
define input parameter p-rp-param-name as character no-undo.
define input parameter p-rule-id as integer no-undo.

define buffer buf_tt-rule-call-param for tt-rule-call-param.
define variable v-ii as integer no-undo .
do v-ii = 1 to 99999:
  find first buf_tt-rule-call-param where
          buf_tt-rule-call-param.param-name = p-rule-param-name
      and buf_tt-rule-call-param.rule_id = p-rule-id
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
        and dbl_tt-rule-call-param.param-value-character = v-value-character
        and dbl_tt-rule-call-param.p-index <> term_tt-rule-call-param.p-index no-error.
  if available dbl_tt-rule-call-param then do:
    message
    substitute("Вы уже выбирали этот тип скидки")
    view-as alert-box error .
    return error.
  end.
  define variable v-mess as character no-undo .
  if term_tt-rule-call-param.rule_id = {&gds-rule-id} then do:
    case v-value-character:
      when {&dgr-pcnt-kat} then do:
        find first dbl_tt-rule-call-param where
                  dbl_tt-rule-call-param.rule_id = term_tt-rule-call-param.rule_id
              and dbl_tt-rule-call-param.param-value-character = {&dthbjr-pcnt-kat-pdf}
              and dbl_tt-rule-call-param.p-index > 0 no-error.
        if available dbl_tt-rule-call-param then do:
          v-mess = substitute("Уже применяется тип скидки &1.&2" +
                              "Нельзя одновременно задавать применение типа скидки <&1>&2и типа скидки <&3>"
                              , {&dthbjr-pcnt-kat-pdf-full}
                              , {&new-line}
                              , {&dgr-pcnt-kat-full}
                              ).
        end.
      end. /*when {&dgr-pcnt-kat} then do:*/
      when {&dthbjr-pcnt-kat-pdf} then do:
        find first dbl_tt-rule-call-param where
                  dbl_tt-rule-call-param.rule_id = term_tt-rule-call-param.rule_id
              and dbl_tt-rule-call-param.param-value-character = {&dgr-pcnt-kat}
              and dbl_tt-rule-call-param.p-index > 0 no-error.
        if available dbl_tt-rule-call-param then do:
          v-mess = substitute("Уже применяется тип скидки &1.&2" +
                              "Нельзя одновременно задавать применение типа скидки <&1>&2и типа скидки <&3>"
                              , {&dgr-pcnt-kat-full}
                              , {&new-line}
                              , {&dthbjr-pcnt-kat-pdf-full}
                                         ).
        end.
      end. /*when {&dthbjr-pcnt-kat-pdf-full} t then do:*/
      when {&dthbjr-temp-disc-pdf} then do:
        find first dbl_tt-rule-call-param where
                  dbl_tt-rule-call-param.rule_id = term_tt-rule-call-param.rule_id
              and dbl_tt-rule-call-param.param-value-character = {&dgr-temp-disc}
              and dbl_tt-rule-call-param.p-index > 0 no-error.
        if available dbl_tt-rule-call-param then do:
          v-mess = substitute("Уже применяется тип скидки &1.&2" +
                              "Нельзя одновременно задавать применение типа скидки <&1>&2и типа скидки <&3>"
                              , {&dgr-temp-disc-full}
                              , {&new-line}
                              , {&dthbjr-temp-disc-pdf-full}
                              ).
        end.
      end. /*when {&dthbjr-temp-disc-pdf} then do: */
      when {&dgr-temp-disc} then do:
        find first dbl_tt-rule-call-param where
                  dbl_tt-rule-call-param.rule_id = term_tt-rule-call-param.rule_id
              and dbl_tt-rule-call-param.param-value-character = {&dthbjr-temp-disc-pdf}
              and dbl_tt-rule-call-param.p-index > 0 no-error.
        if available dbl_tt-rule-call-param then do:
          v-mess = substitute("Уже применяется тип скидки &1.&2" +
                              "Нельзя одновременно задавать применение типа скидки <&1>&2и типа скидки <&3>"
                              , {&dthbjr-temp-disc-pdf-full}
                              , {&new-line}
                              , {&dgr-temp-disc-full}
                              ).
        end.
      end. /*when {&dgr-temp-disc} then do: */
    end case.
  end.
  if v-mess <> '' then do:
    message
    v-mess
    view-as alert-box warning.
    return error.
  end.
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
if not can-find(first tt-rule-call-param where
                      tt-rule-call-param.rule_id = {&gds-rule-id}
                 and  tt-rule-call-param.p-index > 0) then do:
  t-rule-gds = no.
  display
  t-rule-gds
  with frame {&frame-name} .
  message
  "Не найдено ни одного типа скидки для расчета по строке товара!" skip(0)
  "Выключаем возможность применять скидки по строке товара!"
  view-as alert-box  warning.

end.
if not can-find(first tt-rule-call-param where
                      tt-rule-call-param.rule_id = {&subtotal-rule-id}
                 and  tt-rule-call-param.p-index > 0) then do:
  t-rule-subtotal = no.
  display
  t-rule-subtotal
  with frame {&frame-name} .
  message
  "Не найдено ни одного типа скидки для расчета на подитог!" skip(0)
  "Выключаем возможность применять скидки на подитог!"
  view-as alert-box  warning.
end.
if not can-find(first tt-rule-call-param where
                      tt-rule-call-param.rule_id = {&pay-rule-id}
                 and  tt-rule-call-param.p-index > 0) then do:
  t-rule-pay = no.
  display
  t-rule-pay
  with frame {&frame-name} .
  message
  "Не найдено ни одного типа скидки для расчета на строку оплат!" skip(0)
  "Выключаем возможность применять скидки на оплат!"
  view-as alert-box  warning.
end.
v-ii = 0.
assign
frame {&frame-name}
t-add-gds-discnts
t-add-subtotal-discnts
t-add-pay-discnts
t-rule-gds
t-rule-subtotal
t-rule-pay
.
run rcps_set-rule-on-off in this-procedure ( input 15
                                           ,input 1
                                           ,input {&gds-rule-id}
                                           ,input p-profile-id
                                           ,input p-once-more
                                           ,input t-rule-gds).
run rcps_set-rule-on-off in this-procedure ( input 16
                                           ,input 1
                                           ,input {&subtotal-rule-id}
                                           ,input p-profile-id
                                           ,input p-once-more
                                           ,input t-rule-subtotal).

run rcps_set-rule-on-off in this-procedure ( input 17
                                           ,input 1
                                           ,input {&pay-rule-id}
                                           ,input p-profile-id
                                           ,input p-once-more
                                           ,input t-rule-pay).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-add-gds-discnts"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT t-add-gds-discnts /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-add-subtotal-discnts"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT t-add-subtotal-discnts /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-add-pay-discnts"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT t-add-pay-discnts /*p-value-logical*/
                                ).
run resort-rule-call-param in this-procedure ( input "p-discnt-roles"
                                               ,input {&gds-rule-id}).
run resort-rule-call-param in this-procedure ( input "p-discnt-roles"
                                               ,input {&subtotal-rule-id}).
run resort-rule-call-param in this-procedure ( input "p-discnt-roles"
                                               ,input {&pay-rule-id}).

run rcps_proc-save0 in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE resort-rule-call-param Dialog-Frame
PROCEDURE resort-rule-call-param :
define input parameter p-rule-param-name as character no-undo.
define input parameter p-rule-id as integer no-undo.
define variable v-ii as integer no-undo.
define variable v-jj as integer no-undo.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
do v-ii = 1 to 99999:
  for each buf_tt-rule-call-param where
            buf_tt-rule-call-param.rule_id = p-rule-id
        and buf_tt-rule-call-param.param-name = p-rule-param-name
        and buf_tt-rule-call-param.p-index >= v-ii
   by buf_tt-rule-call-param.p-index:
    leave.
  end.      .
  if not available buf_tt-rule-call-param then leave.
  if buf_tt-rule-call-param.p-index <> v-ii then do:
    assign
    buf_tt-rule-call-param.p-index = v-ii.
    release buf_tt-rule-call-param.
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