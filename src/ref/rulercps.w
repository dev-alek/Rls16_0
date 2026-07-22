&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER call_rp-rule-param FOR ub.rp-rule-param.
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

Задание и просмотр параметров вызова правил

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ rul/calldscr.i }
{ gbl/key-rec.i }
{ rul/rulcalpa.i }
{ rul/rcps.i local-var }
DEFINE VARIABLE v-entry-id AS INTEGER NO-UNDO.
define variable v-current-call-id as character no-undo .
define variable v-param-form as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf2_rule-profile for ub.rule-profile.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-callee

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES call_rp-rule-param X_ruledict-param ~
X_rp-rule-param tt-rule-call-param TERM_tt-rule-call-param

/* Definitions for BROWSE BR-callee                                     */
&Scoped-define FIELDS-IN-QUERY-BR-callee CALL_tt-rule-call-param.codex_id CALL_tt-rule-call-param.ruleset_id CALL_tt-rule-call-param.order_id CALL_tt-rule-call-param.rule_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-callee
&Scoped-define SELF-NAME BR-callee
&Scoped-define QUERY-STRING-BR-callee FOR EACH call_rp-rule-param, ~
       CALL_tt-rule-call-param
&Scoped-define OPEN-QUERY-BR-callee OPEN QUERY {&SELF-NAME} FOR EACH call_rp-rule-param, ~
       each CALL_tt-rule-call-param.
&Scoped-define TABLES-IN-QUERY-BR-callee call_rp-rule-param call_tt-rule-call-param
&Scoped-define FIRST-TABLE-IN-QUERY-BR-callee call_rp-rule-param


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
    ~{&OPEN-QUERY-BR-callee}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-chg b-del b-lkp b-rule ~
b-ruleset B-Help BR-rcp BR-callee E-rule-name E-param-des
&Scoped-Define DISPLAYED-OBJECTS E-rule-name E-param-des

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Граф"          .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rule
     LABEL "Правило"
     SIZE 10 BY 1.

DEFINE BUTTON b-ruleset
     LABEL "Точка вызова"
     SIZE 14 BY 1.

DEFINE BUTTON b-set
     LABEL "~!"
     SIZE 4 BY 1.

DEFINE VARIABLE E-param-des AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2 NO-UNDO.

DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-callee FOR
      call_rp-rule-param,
      call_tt-rule-call-param SCROLLING.

DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-callee
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-callee Dialog-Frame _FREEFORM
  QUERY BR-callee DISPLAY
      CALL_tt-rule-call-param.codex_id   COLUMN-LABEL "Кодекс"
CALL_tt-rule-call-param.ruleset_id  COLUMN-LABEL "Набор"
CALL_tt-rule-call-param.order_id    COLUMN-LABEL "Порядок!вызова"
CALL_tt-rule-call-param.rule_id    COLUMN-LABEL "Правило"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7 FIT-LAST-COLUMN
    title "Правила, в которых применяются параметры"   .

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
TERM_tt-rule-call-param.p-index COLUMN-LABEL "Инд!екс" FORMAT ">>9"
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
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-add AT ROW 1 COL 28 WIDGET-ID 10
     b-chg AT ROW 1 COL 38 WIDGET-ID 6
     b-del AT ROW 1 COL 48 WIDGET-ID 12
     b-lkp AT ROW 1 COL 58 WIDGET-ID 8
     b-rule AT ROW 1 COL 68 WIDGET-ID 14
     b-ruleset AT ROW 1 COL 78 WIDGET-ID 16
     b-set AT ROW 1 COL 92 WIDGET-ID 18
     B-Help AT ROW 1 COL 95
     BR-rcp AT ROW 3 COL 1 WIDGET-ID 100
     BR-callee AT ROW 12 COL 1 WIDGET-ID 200
     E-rule-name AT ROW 19 COL 1 NO-LABEL WIDGET-ID 2
     E-param-des AT ROW 21.2 COL 1 NO-LABEL WIDGET-ID 4
     SPACE(0.00) SKIP(0.04)
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
      TABLE: call_rp-rule-param B "?" ? ub rp-rule-param
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
/* BROWSE-TAB BR-rcp B-Help Dialog-Frame */
/* BROWSE-TAB BR-callee BR-rcp Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON b-add IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE
       b-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-rule:HANDLE.

ASSIGN
       b-ruleset:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       E-param-des:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-callee
/* Query rebuild information for BROWSE BR-callee
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH call_rp-rule-param, CALL_tt-rule-call-param.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-callee */
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


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-set Dialog-Frame
ON CHOOSE OF b-set IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-set IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
  IF NOT ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
    RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN rcps_proc-save0 IN THIS-PROCEDURE  NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
 if term_tt-rule-call-param.p-index = 0
 and (lookup("LIST", term_tt-rule-call-param.param-3-data-type) > 0
 or lookup("SORTED-LIST", term_tt-rule-call-param.param-3-data-type) > 0)
 then do:
   message
   "Это шапка Параметра типа СПИСОК, не содержащая реального значения" skip
   "просмотр невозможен"
   view-as alert-box error .
   return no-apply.
 end.
 RUN proc-b-lkp IN this-procedure NO-ERROR.
 IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule Dialog-Frame
ON CHOOSE OF b-rule IN FRAME Dialog-Frame /* Правило */
DO:
    IF NOT AVAILABLE CALL_tt-rule-call-param THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:

   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                             INPUT rule-display-option
                                            ,input CALL_tt-rule-call-param.codex_id
                                            ,input CALL_tt-rule-call-param.ruleset_id
                                            ,input CALL_tt-rule-call-param.call_id
                                            ,input CALL_tt-rule-call-param.order_id
                                            ,INPUT CALL_tt-rule-call-param.rule_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    ASSIGN
    rule-display-option = "".
    RETURN NO-APPLY.
  END.
  ASSIGN
  rule-display-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ruleset Dialog-Frame
ON CHOOSE OF b-ruleset IN FRAME Dialog-Frame /* Точка вызова */
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe CALL_tt-rule-call-param THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = CALL_tt-rule-call-param.codex_id
        AND buf_ruleset.ruleset_id = CALL_tt-rule-call-param.ruleset_id.

  run rul/ruleset-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input buf_ruleset.codex_id
                       ,input buf_ruleset.ruleset_id
                       ,input-output v-rec) no-error.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rcp
&Scoped-define SELF-NAME BR-rcp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-rcp Dialog-Frame
ON VALUE-CHANGED OF BR-rcp IN FRAME Dialog-Frame
DO:

  RUN OpenbrCAllee IN THIS-PROCEDURE.
  IF NOT AVAILABLE tt-rule-call-param THEN DO:
     ASSIGN
     e-rule-name:SCREEN-VALUE = '':U
     e-param-des:SCREEN-VALUE = '':U
     .
     DISABLE
     b-add
     b-set
     b-chg
     b-del
     with FRAME {&FRAME-NAME}.
ENABLE
      b-set
      b-add
      WITH FRAME {&FRAME-NAME}.
      
  END.
  ELSE DO:
    find first X_rule no-lock where
            X_rule.rule_id = term_tt-rule-call-param.rule_id no-error.
     ASSIGN
     e-rule-name:SCREEN-VALUE = (if available X_rule then X_rule.name else "<ПРАВИЛО НЕ НАЙДЕНО>").
     ASSIGN
     e-param-des:SCREEN-VALUE = term_tt-rule-call-param.param-des.
    IF term_tt-rule-call-param.param-2-data-type <> '':U
    and not ((lookup("LIST", term_tt-rule-call-param.param-3-data-type) > 0
             or
             lookup("SORTED-LIST", term_tt-rule-call-param.param-3-data-type) > 0
             )
             and
             term_tt-rule-call-param.p-index = 0)
    THEN DO:
       ENABLE
       b-lkp WITH FRAME {&FRAME-NAME}.
    END.
    ELSE DO:
        disable
        b-lkp WITH FRAME {&FRAME-NAME}.
    END.
    IF (p-mode = {&add-def}
    OR p-mode = {&UPDATE})
    and lookup("b-chg", bttns) > 0
    AND (lookup("LIST", term_tt-rule-call-param.param-3-data-type) > 0
         or
         lookup("SORTED-LIST", term_tt-rule-call-param.param-3-data-type) > 0
         )
    AND term_tt-rule-call-param.p-index = 0 THEN DO:
      ENABLE
      b-add
      b-set
      WITH FRAME {&FRAME-NAME}.
      disable
      b-chg
      b-del
      WITH FRAME {&FRAME-NAME}.
    END.
    IF (p-mode = {&add-def}
    OR p-mode = {&UPDATE})
    and lookup("b-chg", bttns) > 0
    AND not ((lookup("LIST", term_tt-rule-call-param.param-3-data-type) > 0
              or
              lookup("SORTED-LIST", term_tt-rule-call-param.param-3-data-type) > 0
              )
    AND term_tt-rule-call-param.p-index = 0 ) THEN DO:
      disable
      b-add
      b-set
      WITH FRAME {&FRAME-NAME}.
      enable
      b-chg
      b-del
      WITH FRAME {&FRAME-NAME}.
ENABLE
      b-add
      b-set
      WITH FRAME {&FRAME-NAME}.
      
    END.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_graph /* Граф */
DO:
      IF NOT AVAILABLE CALL_tt-rule-call-param THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT CALL_tt-rule-call-param.codex_id
                                            ,INPUT CALL_tt-rule-call-param.ruleset_id
                                            ,INPUT CALL_tt-rule-call-param.call_id
                                            ,INPUT CALL_tt-rule-call-param.order_id
                                            ,INPUT CALL_tt-rule-call-param.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_text /* Текст */
DO:
    IF NOT AVAILABLE CALL_tt-rule-call-param THEN RETURN NO-APPLY.
   ASSIGN
   rule-display-option = "text".
   RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                             ,INPUT CALL_tt-rule-call-param.codex_id
                                             ,INPUT CALL_tt-rule-call-param.ruleset_id
                                             ,INPUT CALL_tt-rule-call-param.call_id
                                             ,INPUT CALL_tt-rule-call-param.order_id
                                             ,INPUT CALL_tt-rule-call-param.rule_id) NO-ERROR.
   ASSIGN
   rule-display-option = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-callee
&UNDEFINE SELF-NAME

{ rul/rcps.i procedures }
{ rul/rcps.i interface }


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON ROW-DISPLAY OF br-rcp IN frame {&frame-name}
DO:
  IF AVAIL tt-rule-call-param THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT term_tt-rule-call-param.param-data-type).
  END.
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
  or p-list-mode = {&TABLE_rp-rule-param}  + {&comma-char} + {&all}
  THEN DO:
    FIND FIRST buf_rule-profile NO-LOCK WHERE
              buf_rule-profile.profile_id = p-profile-id.
    define variable v-field-list as character no-undo .
    define variable v-value-list as character no-undo .
    run  gen-key-fv in this-procedure ( input p-call-id
                                      ,output v-field-list
                                      ,output v-value-list).
    if lookup(v-field-list, "obj-type", {&delim-key}) > 0 then do:
      assign
      v-obj-type = entry(lookup(v-field-list, "obj-type", {&delim-key}), v-value-list, {&delim-key})
      v-obj-code = integer(entry(lookup(v-field-list, "obj-code", {&delim-key}), v-value-list, {&delim-key}) )
      .
    end.
    if v-obj-type <> ''
    and lookup("obj", buf_rule-profile.short-name) = 0
    then do:
      p-mode = {&lookup}.
    end.
    if buf_rule-profile.parent-feature = integer({&rp-parentf-only-in-combo}) then do:
      if p-codex-id = 0
      and p-once-more > 0
      and p-ruleset-id = 0
      and p-order-id = ?
      and p-rule-id = 0
      and (p-mode = {&lookup}
          or
          (p-mode = {&update} and lookup("free", bttns) > 0))
      then do:
          find first buf_rp-by-call no-lock
                where buf_rp-by-call.call_id = p-call-id
                  and buf_rp-by-call.profile_id = p-profile-id
                  and buf_rp-by-call.once-more = p-once-more.
          find first buf2_rule-profile no-lock where
                    buf2_rule-profile.profile_id = buf_rp-by-call.parent-profile_id.
          frame {&frame-name}:visible = no.
          message
          substitute("Просмотр параметров для подчиненного профайла возможен только в составе комбинированного алгоритма:&1&2"
                    , {&new-line}
                    , buf2_rule-profile.name)
          view-as alert-box warning.
          v-current-call-id = p-call-id.
          entry(lookup(buf_rule-profile.profile-type, p-call-id, {&delim-key}), v-current-call-id, {&delim-key}) = {&cmb}.
          if search( substitute("rul/rcps-&1.w", buf2_rule-profile.profile_id)) <> ?
          or search( substitute("rul/rcps-&1.r", buf2_rule-profile.profile_id)) <> ?
          then do:
            v-param-form = substitute("rul/rcps-&1.w", buf2_rule-profile.profile_id).
          end.
          else do:
            message
            substitute("Не найдена форма для алгоритма &1", buf2_rule-profile.profile_id)
            view-as alert-box error .
            undo, return error .
          end.
          run value(v-param-form) (
                                input parparentproc
                                ,input bttns
                                ,input p-mode
                                ,input {&table_rp-rule-param}
                                ,input buf2_rule-profile.profile_id /*p-profile-id*/
                                ,input buf_rp-by-call.once-more /*p-once-more*/
                                ,input v-current-call-id /*p-call-id*/
                                ,input 0 /*p-codex-id*/
                                ,input 0 /*p-codex-id*/
                                ,input ? /*p-order-id*/
                                ,input 0 /*p-rule-id*/
                                ,INput substitute("Профайл &1 № привязки &2 &3"
                                                  ,buf2_rule-profile.profile_id
                                                  ,buf_rp-by-call.once-more
                                                  ,calldscr(v-current-call-id)
                                                  )  /**/
                                ,input-output table tt0-rule-call-param  ) no-error.
          return.
      end.
      else do:
        message
        "Просмотр/изменение параметров для ПОДЧИНЕННОГО профайла невозможен"
        view-as alert-box .
        RETURN.
      end.
    end.
    run gen-key-rec in this-procedure ( input {&table_rule-profile}
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-uniq-key-rec).

    FIND FIRST buf_ruledict NO-LOCK WHERE
              buf_ruledict.entry-type = {&rdict-etype-rule-profile}
       AND  buf_ruledict.uniq-key-rec = v-uniq-key-rec.
    v-entry-id = buf_ruledict.entry-id.
  END.
  RUN rcps_fill-table IN THIS-PROCEDURE ( input no).
  RUN Myenable in THIS-PROCEDURE.
  /*
  { gbl/mv-clmn.i
    &browse-name = "br-rcp"
    &frame-name = "{&frame-name}"
    &ext-col = 14
    &start-column = 1
    &prev-order-column_1 = "'5,6,7,8,9,10,11,12,13,14,1,2,3,4'"
    &prev-order-column-condition_1 = " p-call-id <> '':U"
    &prev-order-column_2 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14'"
    &prev-order-column-condition_2 = " p-call-id = '':U "
    }

  */
ENABLE
      b-add
      b-set
      WITH FRAME {&FRAME-NAME}.
      
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
  DISPLAY E-rule-name E-param-des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-chg b-del b-lkp b-rule b-ruleset B-Help BR-rcp
         BR-callee E-rule-name E-param-des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
b-rule:MENU-MOUSE in frame {&frame-name} = 1.
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
     HIDE
     br-callee
     b-rule
     b-ruleset
     IN FRAME {&FRAME-NAME}.
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
    br-rcp:height-chars = br-rcp:height-chars - br-callee:height-chars - 0.5.
    ENABLE
    br-callee
    b-rule
    b-ruleset
    WITH FRAME {&FRAME-NAME}.
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
DISPLAY
E-rule-name
E-param-des
WITH FRAME {&Frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
b-chg WHEN p-mode <> {&LOOKUP} and lookup("b-chg", bttns) > 0
B-Help
BR-rcp
E-rule-name
E-param-des
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
   ASSIGN
   b-quit:COLUMN = 1
   b-quit:LABEL = "&Выход".
   HIDE
   b-exit
   b-chg
   IN FRAME {&FRAME-NAME}.
END.
ASSIGN
FRAME {&FRAME-NAME}:TITLE = substitute("Параметры вызова правил: &1", p-title).
RUN OpenBr in THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Openbr Dialog-Frame
PROCEDURE Openbr :
CASE p-list-mode:
  WHEN {&TABLE_rule-call-param} THEN DO:
      OPEN QUERY br-rcp
      FOR EACH X_ruledict-param NO-LOCK WHERE RECID(X_ruledict-param) = v-rp-dflt-rec
         ,EACH X_rp-rule-param NO-LOCK WHERE recid(X_rp-rule-param) = v-dflt-rec
         ,first tt-rule-call-param
         ,each term_tt-rule-call-param /*where
               term_tt-rule-call-param.call_id = tt-rule-call-param.call_id
           and term_tt-rule-call-param.codex_id = tt-rule-call-param.codex_id
           and term_tt-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
           and term_tt-rule-call-param.order_id = tt-rule-call-param.order_id
           and term_tt-rule-call-param.param-name = tt-rule-call-param.param-name*/
      BY term_tt-rule-call-param.call_id
      BY term_tt-rule-call-param.codex_id
      BY term_tt-rule-call-param.ruleset_id
      BY term_tt-rule-call-param.order_id
      BY term_tt-rule-call-param.param-num
      BY term_tt-rule-call-param.p-index
      .

  END.
  WHEN {&TABLE_rp-rule-param} THEN DO:
      OPEN QUERY br-rcp
      FOR EACH  X_ruledict-param NO-LOCK WHERE X_ruledict-param.entry-id = v-entry-id
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
  WHEN {&TABLE_rp-rule-param} + {&comma-char} + {&all} THEN DO:
      OPEN QUERY br-rcp
      FOR EACH  X_ruledict-param NO-LOCK WHERE X_ruledict-param.entry-id = v-entry-id
          ,first X_rp-rule-param WHERE
              X_rp-rule-param.profile_id = p-profile-id
          AND X_rp-rule-param.rp-param-name = X_ruledict-param.param-name
        , each tt-rule-call-param WHERE
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
RUN OpenbrCAllee IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenbrCAllee Dialog-Frame
PROCEDURE OpenbrCAllee :
if p-list-mode = {&table_rp-rule-param} + {&comma-char} + {&all} then do:
  OPEN QUERY br-callee
  FOR EACH call_rp-rule-param NO-LOCK WHERE call_rp-rule-param.rp-param-name = X_rp-rule-param.rp-param-name,
      EACH CALL_tt-rule-call-param WHERE
        CALL_tt-rule-call-param.param-name = call_rp-rule-param.rule-param-name
     and CALL_tt-rule-call-param.codex_id = call_rp-rule-param.codex_id
     and CALL_tt-rule-call-param.ruleset_id = call_rp-rule-param.ruleset_id
     and CALL_tt-rule-call-param.rule_id = call_rp-rule-param.rule_id
     and CALL_tt-rule-call-param.call_id = term_tt-rule-call-param.call_id
     and CALL_tt-rule-call-param.p-index = 0.
end.
else do:
  IF AVAILABLE X_rp-rule-param THEN DO:
      OPEN QUERY br-callee
      FOR EACH call_rp-rule-param NO-LOCK WHERE
          call_rp-rule-param.rp-param-name = X_rp-rule-param.rp-param-name,
          EACH CALL_tt-rule-call-param WHERE
            CALL_tt-rule-call-param.param-name = call_rp-rule-param.rule-param-name
          and CALL_tt-rule-call-param.codex_id = call_rp-rule-param.codex_id
          and CALL_tt-rule-call-param.ruleset_id = call_rp-rule-param.ruleset_id
          and CALL_tt-rule-call-param.rule_id = call_rp-rule-param.rule_id
          and CALL_tt-rule-call-param.p-index = 0
            .

  END.
  ELSE DO:
      OPEN QUERY br-callee
      FOR EACH  call_rp-rule-param NO-LOCK WHERE false,
          EACH CALL_tt-rule-call-param WHERE false.

  END.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable v-ind as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
IF NOT AVAILABLE tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
IF lookup("LIST", tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF tt-rule-call-param.p-index <> 0 THEN DO:
  BELL.
  RETURN.
END.
find last buf_tt-rule-call-param where
         buf_tt-rule-call-param.call_id = tt-rule-call-param.call_id
     and buf_tt-rule-call-param.codex_id = tt-rule-call-param.codex_id
     and buf_tt-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
     and buf_tt-rule-call-param.order_id = tt-rule-call-param.order_id
     and buf_tt-rule-call-param.param-num = tt-rule-call-param.param-num no-error .
if available buf_tt-rule-call-param
and (lookup("LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     or
     lookup("SORTED-LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     )
and buf_tt-rule-call-param.p-index > 0 then do:
  v-ind = buf_tt-rule-call-param.p-index.
end.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = X_rp-rule-param.rp-param-name
    and buf_rp-rule-param.profile_id = X_rp-rule-param.profile_id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = tt-rule-call-param.once-more
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
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-set Dialog-Frame
PROCEDURE proc-b-set :
define variable v-ind as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
define buffer buf3_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
IF NOT AVAILABLE tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
IF lookup("LIST", tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF tt-rule-call-param.p-index <> 0 THEN DO:
  BELL.
  RETURN.
END.
for each buf3_tt-rule-call-param where
         buf3_tt-rule-call-param.call_id = tt-rule-call-param.call_id
     and buf3_tt-rule-call-param.codex_id = tt-rule-call-param.codex_id
     and buf3_tt-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
     and buf3_tt-rule-call-param.order_id = tt-rule-call-param.order_id
     and buf3_tt-rule-call-param.param-num = tt-rule-call-param.param-num 
no-lock:
   if      (lookup("LIST", buf3_tt-rule-call-param.param-3-data-type) > 0
      or
            lookup("SORTED-LIST", buf3_tt-rule-call-param.param-3-data-type) > 0
         )
      and buf3_tt-rule-call-param.p-index > 0 
   then do:
      v-ind = buf3_tt-rule-call-param.p-index.
   
      for each buf_rp-rule-param where
               buf_rp-rule-param.rp-param-name = X_rp-rule-param.rp-param-name
           and buf_rp-rule-param.profile_id = X_rp-rule-param.profile_id
      on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :
         find first buf_tt-rule-call-param where
               buf_tt-rule-call-param.call_id = tt-rule-call-param.call_id
           and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
           and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
           and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
           and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
           and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
           and buf_tt-rule-call-param.once-more = tt-rule-call-param.once-more
           and buf_tt-rule-call-param.p-index = v-ind no-error.
         if not avail buf_tt-rule-call-param
         then do:
            find first buf_tt-rule-call-param where
                     buf_tt-rule-call-param.call_id = tt-rule-call-param.call_id
                 and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
                 and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
                 and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
                 and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
                 and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
                 and buf_tt-rule-call-param.once-more = tt-rule-call-param.once-more
                 and buf_tt-rule-call-param.p-index = 0.
   
            create buf2_tt-rule-call-param.
            buffer-copy buf_tt-rule-call-param
            except p-index
            to buf2_tt-rule-call-param
            assign
            buf2_tt-rule-call-param.p-index = v-ind
            .

            RUN set-value IN THIS-PROCEDURE (
                                       INPUT buf2_tt-rule-call-param.profile_id
                                      ,INPUT buf2_tt-rule-call-param.once-more
                                      ,INPUT buf_rp-rule-param.rp-param-name
                                      ,INPUT buf2_tt-rule-call-param.call_id
                                      ,INPUT buf2_tt-rule-call-param.codex_id
                                      ,INPUT buf2_tt-rule-call-param.ruleset_id
                                      ,INPUT buf2_tt-rule-call-param.order_id
                                      ,INPUT buf2_tt-rule-call-param.param-name
                                      ,INPUT buf2_tt-rule-call-param.p-index
                                      ,INPUT buf3_tt-rule-call-param.param-value-character
                                      ,INPUT buf3_tt-rule-call-param.param-value-date
                                      ,INPUT buf3_tt-rule-call-param.param-value-decimal
                                      ,INPUT buf3_tt-rule-call-param.param-value-integer
                                      ,INPUT buf3_tt-rule-call-param.param-value-logical).
                                       
          
         end.
      end.
   end.
end.
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg PRIVATE :
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-value-integer AS integer NO-UNDO.
DEFINE VARIABLE v-value-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-value-date AS date NO-UNDO.
define variable v-ok as logical no-undo .
DEFINE VARIABLE v-rec1 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec2 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec3 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec4 AS Rowid NO-UNDO.
define variable v-param-data-type as character no-undo .
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE TERM_tt-rule-call-param  THEN DO:
  RETURN ERROR.
END.
v-param-data-type = TERM_tt-rule-call-param.param-data-type +
                    (if term_tt-rule-call-param.param-2-data-type = '':U
                     then '':U
                     else {&comma-char}) +
                    term_tt-rule-call-param.param-2-data-type
                     .
if lookup("READ-ONLY", TERM_tt-rule-call-param.param-3-data-type) > 0 then do:
  message
  "Данный параметр задан как READ-ONLY (Только для чтения)" skip
  "Изменения не допускаются"
  view-as alert-box error .
  undo, return error .
end.
CASE  v-param-data-type:
  when {&abl-datatype-integer} then do:
    assign
    v-value-integer = term_tt-rule-call-param.param-value-integer.
    run gbl/d-integer.w (
           input ?
          ,input (
          'title=':u + substitute("Изменение параметра &1", term_tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + term_tt-rule-call-param.param-label + '\':u
        + 'format=' + (if term_tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=3\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-integer
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT term_tt-rule-call-param.profile_id
                                      ,INPUT term_tt-rule-call-param.once-more
                                      ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                             then X_rp-rule-param.rp-param-name
                                             else '':U)
                                      ,INPUT term_tt-rule-call-param.call_id
                                      ,INPUT term_tt-rule-call-param.codex_id
                                      ,INPUT term_tt-rule-call-param.ruleset_id
                                      ,INPUT term_tt-rule-call-param.order_id
                                      ,INPUT term_tt-rule-call-param.param-name
                                      ,INPUT term_tt-rule-call-param.p-index
                                      ,INPUT term_tt-rule-call-param.param-value-character
                                      ,INPUT term_tt-rule-call-param.param-value-date
                                      ,INPUT term_tt-rule-call-param.param-value-decimal
                                      ,INPUT v-value-integer
                                      ,INPUT term_tt-rule-call-param.param-value-logical).


  end.
  when {&abl-datatype-decimal} then do:
    assign
    v-value-decimal = term_tt-rule-call-param.param-value-decimal.
    run gbl/d-decimal.w (
           input ?
          ,input (
          'title=':u + substitute("Изменение параметра &1", term_tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + term_tt-rule-call-param.param-label + '\':u
        + 'format=' + (if term_tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=3\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-decimal
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT term_tt-rule-call-param.profile_id
                                      ,INPUT term_tt-rule-call-param.once-more
                                      ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                             then X_rp-rule-param.rp-param-name
                                             else '':U)
                                      ,INPUT term_tt-rule-call-param.call_id
                                      ,INPUT term_tt-rule-call-param.codex_id
                                      ,INPUT term_tt-rule-call-param.ruleset_id
                                      ,INPUT term_tt-rule-call-param.order_id
                                      ,INPUT term_tt-rule-call-param.param-name
                                      ,INPUT term_tt-rule-call-param.p-index
                                      ,INPUT term_tt-rule-call-param.param-value-character
                                      ,INPUT term_tt-rule-call-param.param-value-date
                                      ,INPUT v-value-decimal
                                      ,INPUT term_tt-rule-call-param.param-value-decimal
                                      ,INPUT term_tt-rule-call-param.param-value-logical).


  end.

  when {&abl-datatype-character} then do:
    assign
    v-value-character = term_tt-rule-call-param.param-value-character.
    run gbl/d-character.w (
          input ?
         ,input (
          'title=':u + substitute("Изменение параметра &1", term_tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + term_tt-rule-call-param.param-label + '\':u
        + 'format=' + (if term_tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=4\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-character
        , output v-ok
            ).
        if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT term_tt-rule-call-param.profile_id
                                      ,INPUT term_tt-rule-call-param.once-more
                                      ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                             then X_rp-rule-param.rp-param-name
                                             else '':U)
                                      ,INPUT term_tt-rule-call-param.call_id
                                      ,INPUT term_tt-rule-call-param.codex_id
                                      ,INPUT term_tt-rule-call-param.ruleset_id
                                      ,INPUT term_tt-rule-call-param.order_id
                                      ,INPUT term_tt-rule-call-param.param-name
                                      ,INPUT term_tt-rule-call-param.p-index
                                     ,INPUT v-value-character
                                     ,INPUT term_tt-rule-call-param.param-value-date
                                     ,INPUT term_tt-rule-call-param.param-value-decimal
                                     ,INPUT term_tt-rule-call-param.param-value-integer
                                     ,INPUT term_tt-rule-call-param.param-value-logical).


  end.
  when {&abl-datatype-logical} then do:
    assign
    v-value-logical = term_tt-rule-call-param.param-value-logical.
    run gbl/d-logical.w (
          input ?
         ,input  (
          'title=':u + substitute("Изменение параметра &1", term_tt-rule-call-param.param-label) + '\':u
        + 'text1=':u + term_tt-rule-call-param.param-label + '\':u
        + 'format=' + (if term_tt-rule-call-param.param-data-type = {&type-log}
                      then "yes/no"
                      else v-format) + '\':u
        + 'fillin_row=2\':u
        + 'fillin_col=4\':u
        + 'fillin_width=20\':u
        + 'fillin_height=1\':u
        + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
        + 'readonly=' + (if p-mode <> {&update} and p-mode <> {&add-def} then 'yes':u else 'no':u) + '\':u)
        , input-output v-value-logical
        , output v-ok
            ).
    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT term_tt-rule-call-param.profile_id
                                      ,INPUT term_tt-rule-call-param.once-more
                                      ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                             then X_rp-rule-param.rp-param-name
                                             else '':U)
                                      ,INPUT term_tt-rule-call-param.call_id
                                      ,INPUT term_tt-rule-call-param.codex_id
                                      ,INPUT term_tt-rule-call-param.ruleset_id
                                      ,INPUT term_tt-rule-call-param.order_id
                                      ,INPUT term_tt-rule-call-param.param-name
                                      ,INPUT term_tt-rule-call-param.p-index
                                     ,INPUT term_tt-rule-call-param.param-value-character
                                     ,INPUT term_tt-rule-call-param.param-value-date
                                     ,INPUT term_tt-rule-call-param.param-value-decimal
                                     ,INPUT term_tt-rule-call-param.param-value-integer
                                     ,INPUT v-value-logical).

  end.
  when {&abl-datatype-date} then do:
    assign
    v-value-date = term_tt-rule-call-param.param-value-date.
      run gbl/d-inpday.w
        (input ?                  /* h-callback    */
        ,input substitute("Изменение параметра &1", term_tt-rule-call-param.param-label)        /* p-title       */
        ,input ""                 /* p-description */
        ,input ""                  /* p-mode        */
        ,input-output v-value-date /* p-date        */
        ,output v-ok              /* p-ok          */
        ) NO-ERROR.

    if not v-ok then return error.
    RUN set-value IN THIS-PROCEDURE (
                                       INPUT term_tt-rule-call-param.profile_id
                                      ,INPUT term_tt-rule-call-param.once-more
                                      ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                             then X_rp-rule-param.rp-param-name
                                             else '':U)
                                      ,INPUT term_tt-rule-call-param.call_id
                                      ,INPUT term_tt-rule-call-param.codex_id
                                      ,INPUT term_tt-rule-call-param.ruleset_id
                                      ,INPUT term_tt-rule-call-param.order_id
                                      ,INPUT term_tt-rule-call-param.param-name
                                      ,INPUT term_tt-rule-call-param.p-index
                                     ,INPUT term_tt-rule-call-param.param-value-character
                                     ,INPUT v-value-date
                                     ,INPUT term_tt-rule-call-param.param-value-decimal
                                     ,INPUT term_tt-rule-call-param.param-value-integer
                                     ,INPUT term_tt-rule-call-param.param-value-logical).
  end.
  otherwise do:
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
      RUN set-value IN THIS-PROCEDURE (
                                       INPUT term_tt-rule-call-param.profile_id
                                      ,INPUT term_tt-rule-call-param.once-more
                                      ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                             then X_rp-rule-param.rp-param-name
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
  end. /*otherwise*/
end case.

ASSIGN
v-rec1 = rowid(X_ruledict-param)
v-rec2 = rowid(X_rp-rule-param)
v-rec3 = Rowid(tt-rule-call-param)
v-rec4 = Rowid(term_tt-rule-call-param)
.
run openbr in this-procedure .
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
define variable v-ind as integer no-undo .
define variable v-once-more as integer no-undo .
define variable v-call-id as character no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
IF NOT AVAILABLE term_tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
IF lookup("LIST", term_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", term_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF lookup("READ-ONLY", term_tt-rule-call-param.param-3-data-type) > 0 THEN DO:
  BELL.
  RETURN.
END.
IF term_tt-rule-call-param.p-index  = 0 THEN DO:
  BELL.
  RETURN.
END.
assign
v-ind = term_tt-rule-call-param.p-index
v-once-more = tt-rule-call-param.once-more
v-call-id = tt-rule-call-param.call_id
.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = X_rp-rule-param.rp-param-name
    and buf_rp-rule-param.profile_id = X_rp-rule-param.profile_id,
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
run Openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lkp Dialog-Frame
PROCEDURE proc-b-lkp :
define buffer buf_dis-rule for ub.dis-rule.
define variable v-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
CASE entry(1, term_tt-rule-call-param.param-2-data-type, "_"):
  WHEN {&table_dis-rule} THEN DO:
    run ref/show-dr.p ( input parparentproc
                       ,input term_tt-rule-call-param.param-value-integer) no-error.
    if error-status:error then do:
      undo, return error .
    end.
  END.
  WHEN {&r-b} THEN DO:
  END.
  WHEN {&output-type} THEN DO:
  END.
  WHEN {&table_prop-ref} THEN DO:
    run ref/proprefs.w (   input  parparentproc
                          ,input ""
                          ,input "sum-id"
                          ,input  integer(entry(2, term_tt-rule-call-param.param-2-data-type, "_"))
                          ,input  term_tt-rule-call-param.param-value-character
                          ,input '':U /*p-call-id*/
                          ,input-OUTPUT v-rid-list) NO-ERROR.
  END.
  when {&table_ext-system} then do:
    define variable v-int as integer no-undo .
    v-int = term_tt-rule-call-param.param-value-integer.
    run bge/oxmlspci.w ( input parparentproc
                         ,input {&lookup}
                         ,input-output v-int
                         ,input 0
                         ,output v-ok) no-error.

  end.
  when "xsd" then do:
    define variable v-longchar as longchar no-undo .
    define variable v-part-num as integer no-undo init 1.
    define variable v-clob-db-num as integer no-undo .
    define variable v-int64-id as int64 no-undo .
    define buffer buf_clob-data for ub.clob-data.
    run gbl/file2clb.p ( input {&lookup}
                        ,input "" /*p-clob-mode*/
                        ,input ? /*p-bh*/
                        ,input term_tt-rule-call-param.param-value-character
                        ,input '':U /*p-field-*/
                        ,input '':U /*descr*/
                        ,input-output v-part-num
                        ,input {&lob-res-gate} /*p-resource-type*/
                        ,input-output v-clob-db-num
                        ,input-output v-int64-id
                        ,input term_tt-rule-call-param.param-value-character
                        ,input ? /*p-src-encoding*/
                        ) no-error .
    if error-status :error then do:
      return error return-value .
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = v-clob-db-num
          and buf_clob-data.int64-id = v-int64-id.
    run gbl/clbxmlvw.p (  input parparentproc
                          ,input rowid(buf_clob-data)
                          ,input substitute("tmp_&1", buf_clob-data.file-name)
                          ) no-error.
  end.
  when {&lob-res-list}
  or when {&lob-res-list-macro}
  then do:
    define variable v-res-type as character no-undo .
    v-res-type = entry(1, term_tt-rule-call-param.param-2-data-type, "_").
    run gbl/file2clb.p ( input {&lookup}
                        ,input "" /*p-clob-mode*/
                        ,input ? /*p-bh*/
                        ,input entry(1, term_tt-rule-call-param.param-value-character, "_") /*p-uniq-key-rec*/
                        ,input entry(2, term_tt-rule-call-param.param-value-character, "_") /*p-field-name*/
                        ,input '':U /*descr*/
                        ,input-output v-part-num
                        ,input v-res-type /*p-resource-type*/
                        ,input-output v-clob-db-num
                        ,input-output v-int64-id
                        ,input term_tt-rule-call-param.param-value-character
                        ,input ? /*p-src-encoding*/
                        ) no-error .
    if error-status :error then do:
      return error return-value .
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = v-clob-db-num
          and buf_clob-data.int64-id = v-int64-id.
    assign
    v-longchar = buf_clob-data.cdata.
    run gbl/d-longchar.w (
                           input ? /*r h-callback  */
                          ,input (
                                    'title=':u + "СПИСОК" + '\':u
                                  + 'Editor_row=2\':u
                                  + 'Editor_col=1\':u
                                  + 'Editor_width=96\':u
                                  + 'Editor_height=15\':u
                                  + 'readonly=yes\':u)
                          ,input-output v-longchar
                          ,output v-ok ) no-error .
    assign
    v-longchar = '':U.
  end.
  when "tpl" then do:
    define variable v-recid as recid no-undo .
    define buffer loc_price-list-type for ub.price-list-type.
    if term_tt-rule-call-param.param-value-character <> '' then do:
        find first loc_price-list-type where
                  loc_price-list-type.plt-id = integer(entry(1, term_tt-rule-call-param.param-value-character, "-"))
               and loc_price-list-type.plt-db-num = integer(entry(2, term_tt-rule-call-param.param-value-character, "-")) no-error.
        if available loc_price-list-type then do:
            v-recid = RECID(loc_price-list-type).
            run ref/tp-price.w ( input parparentproc
                              ,input NO /*p-main-price*/
                              ,INPUT {&LOOKUP}
                               ,INPUT-OUTPUT v-recid ) NO-ERROR.
        end.
        ELSE DO:
           MESSAGE
           "Тип прайс-листа не определен, возможно удален"
           VIEW-AS ALERT-BOX ERROR.
         END.

    end.
    ELSE DO:
      MESSAGE
      "Тип прайс-листа не определен"
      VIEW-AS ALERT-BOX ERROR.
    END.
  end.
  when "sel-obj" then do:
  end.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-display-rule Dialog-Frame
PROCEDURE proc-display-rule :
DEFINE INPUT PARAMETER p-display-mode AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
  run rul/disprule.p (
                       input p-DISPLAY-MODE
                      ,input p-rule-id
                      ,input p-codex-id
                      ,input p-ruleset-id
                      ,input p-call-id
                      ,input p-order-id
                       ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch[1]:FGCOLOR = GREY_COLOR
v-ch[1]:BGCOLOR = GREY_Color
v-ch[1]:PFCOLOR = GREY_Color
v-ch[2]:FGCOLOR = GREY_COLOR
v-ch[2]:BGCOLOR = GREY_Color
v-ch[2]:PFCOLOR = GREY_Color
v-ch[3]:FGCOLOR = GREY_COLOR
v-ch[3]:BGCOLOR = GREY_Color
v-ch[3]:PFCOLOR = GREY_Color
v-ch[4]:FGCOLOR = GREY_COLOR
v-ch[4]:BGCOLOR = GREY_Color
v-ch[4]:PFCOLOR = GREY_Color
v-ch[5]:FGCOLOR = GREY_COLOR
v-ch[5]:BGCOLOR = GREY_Color
v-ch[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN {&ABL-datatype-character} THEN DO:
      ASSIGN
      v-ch[1]:FGCOLOR = BLACK_COLOR
      v-ch[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-decimal} THEN DO:
      ASSIGN
      v-ch[3]:FGCOLOR = BLACK_COLOR
      v-ch[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-integer} THEN DO:
      ASSIGN
      v-ch[4]:FGCOLOR = BLACK_COLOR
      v-ch[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN {&ABL-datatype-date} THEN DO:
      ASSIGN
      v-ch[2]:FGCOLOR = BLACK_COLOR
      v-ch[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN {&ABL-datatype-logical} THEN DO:
       ASSIGN
       v-ch[5]:FGCOLOR = BLACK_COLOR
       v-ch[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.

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