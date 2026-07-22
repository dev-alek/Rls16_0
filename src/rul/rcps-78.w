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
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
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

Задание и просмотр параметров вызова правил для профайла 2

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/31/10
Author: Bakhtadze Natalya
Creation date: 05/31/10

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 2".
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
{ rul/propreft.i }
{ gbl/cur-time.i }
define variable v-running-mode as logical no-undo .
&scop dis-rule-templ-rl-root 57
DEFINE VARIABLE add-option AS CHARACTER NO-UNDO.

&scop some-rule-id-obj  2080
&scop some-rule-id-host  2081
&scop some-codex-id-obj  {&dct-proc_1}
&scop some-ruleset-id-obj  {&dct-proc_1_sale-close_1}
&scop some-codex-id-host  {&dct-proc_2}
&scop some-ruleset-id-host  {&dct-proc_2_sale-close_1}

DEFINE TEMP-TABLE dr-obj no-undo like ub.rule-call-param
FIELD host-code AS INTEGER
FIELD obj-type AS CHARACTER
FIELD obj-code AS INTEGER
INDEX pi IS UNIQUE PRIMARY
host-code
obj-type
obj-code
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dis-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES dr-obj X_dis-rule X_ruledict-param ~
X_rp-rule-param tt-rule-call-param TERM_tt-rule-call-param

/* Definitions for BROWSE BR-dis-rule                                   */
&Scoped-define FIELDS-IN-QUERY-BR-dis-rule dr-obj.param-value-integer X_dis-rule.host-code (X_dis-rule.obj-type + (IF X_dis-rule.obj-code > 0 THEN string(X_dis-rule.obj-code) ELSE '')) X_dis-rule.des   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dis-rule   
&Scoped-define SELF-NAME BR-dis-rule
&Scoped-define QUERY-STRING-BR-dis-rule FOR EACH dr-obj         , ~
               FIRST X_dis-rule no-lock WHERE         X_dis-rule.rule-num = dr-obj.param-value-integer BY X_dis-rule.host-code BY X_dis-rule.obj-type BY X_dis-rule.obj-code
&Scoped-define OPEN-QUERY-BR-dis-rule OPEN QUERY {&SELF-NAME}     FOR EACH dr-obj         , ~
               FIRST X_dis-rule no-lock WHERE         X_dis-rule.rule-num = dr-obj.param-value-integer BY X_dis-rule.host-code BY X_dis-rule.obj-type BY X_dis-rule.obj-code .
&Scoped-define TABLES-IN-QUERY-BR-dis-rule dr-obj X_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dis-rule dr-obj
&Scoped-define SECOND-TABLE-IN-QUERY-BR-dis-rule X_dis-rule


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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help t-is-over rs-r-b b-add ~
b-del b-chg b-lkp BR-dis-rule BR-rcp 
&Scoped-Define DISPLAYED-OBJECTS t-is-over rs-r-b l-r-b 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-add 
       MENU-ITEM m_host         LABEL "Правило в контексте фирмы"
       MENU-ITEM m_obj          LABEL "Правило в контексте объекта".


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

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dis-rule FOR 
      dr-obj, 
      X_dis-rule SCROLLING.

DEFINE QUERY BR-rcp FOR 
      X_ruledict-param, 
      X_rp-rule-param, 
      tt-rule-call-param, 
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dis-rule Dialog-Frame _FREEFORM
  QUERY BR-dis-rule DISPLAY
      dr-obj.param-value-integer COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9"
X_dis-rule.host-code COLUMN-LABEL "Фирма" FORMAT ">>>>9"
(X_dis-rule.obj-type + (IF X_dis-rule.obj-code > 0 THEN string(X_dis-rule.obj-code) ELSE '')) COLUMN-LABEL "Объект" FORMAT "X(8)"
X_dis-rule.des COLUMN-LABEL "Описание" FORMAT "X(255)" width 50
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13
         TITLE "Правила зависимости СУММА НАКОПЛЕНИЙ -> % скидки на ДК по фирмам и объектам" FIT-LAST-COLUMN.

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
     t-is-over AT ROW 2 COL 61.5 WIDGET-ID 88
     rs-r-b AT ROW 2.08 COL 25.5 NO-LABEL WIDGET-ID 106
     b-add AT ROW 3 COL 1 WIDGET-ID 150
     b-del AT ROW 3 COL 11 WIDGET-ID 152
     b-chg AT ROW 3 COL 21 WIDGET-ID 154
     b-lkp AT ROW 3 COL 31 WIDGET-ID 156
     BR-dis-rule AT ROW 4 COL 1 WIDGET-ID 200
     BR-rcp AT ROW 17 COL 1 WIDGET-ID 100
     l-r-b AT ROW 2.08 COL 1.5 NO-LABEL WIDGET-ID 122
     SPACE(76.09) SKIP(20.51)
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
      TABLE: X_dis-rule B "?" ? ub dis-rule
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
/* BROWSE-TAB BR-dis-rule b-lkp Dialog-Frame */
/* BROWSE-TAB BR-rcp BR-dis-rule Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.

ASSIGN 
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* SETTINGS FOR FILL-IN l-r-b IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
ASSIGN 
       l-r-b:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dis-rule
/* Query rebuild information for BROWSE BR-dis-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
    FOR EACH dr-obj
        ,
        FIRST X_dis-rule no-lock WHERE
        X_dis-rule.rule-num = dr-obj.param-value-integer
BY X_dis-rule.host-code
BY X_dis-rule.obj-type
BY X_dis-rule.obj-code
.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-dis-rule */
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
     
  if add-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if add-option = "":U then do:
      return no-apply.
  end.
  
  
RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    add-option = ''.
    RETURN NO-APPLY.
END.
add-option = ''.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  IF NOT AVAILABLE dr-obj THEN RETURN NO-APPLY.
  RUN proc-b-chg IN THIS-PROCEDURE ( INPUT no, INPUT dr-obj.param-name) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  define variable v-index as integer no-undo .
  define variable v-rule-id as integer   no-undo .
  define variable v-param-name as character no-undo .
  define buffer buf_tt-rule-call-param for tt-rule-call-param.
  IF NOT AVAILABLE dr-obj THEN RETURN NO-APPLY.
  MESSAGE
  "Вы уверены?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF not glog THEN DO:
    RETURN NO-APPLY.
  END.
  v-index = dr-obj.p-index.
  v-param-name = dr-obj.param-name.
  v-rule-id = dr-obj.rule_id.
  DO TRANSACTION:
    for each buf_tt-rule-call-param where
            buf_tt-rule-call-param.param-name = v-param-name
        and buf_tt-rule-call-param.p-index = v-index
    ON error UNDO, RETURN NO-APPLY
    ON stop UNDO, RETURN NO-APPLY
    ON END-key UNDO, RETURN NO-APPLY
    :
      delete buf_tt-rule-call-param.
    end.
    RUN del-dr-obj IN THIS-PROCEDURE ( INPUT dr-obj.host-code
                                      ,INPUT dr-obj.obj-type
                                      ,INPUT dr-obj.obj-code).
  END.
  run resort-rule-call-param in this-procedure( input v-param-name
                                                ,input v-rule-id).
  {&open-query-br-dis-rule}
  reposition br-dis-rule to row 1.
  apply "entry" to br-dis-rule.
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


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
   { gbl/stdbtn.i }
   IF AVAILABLE dr-obj  THEN DO:
   run ref/show-dr.p ( INPUT parparentproc
                      ,INPUT dr-obj.param-value-integer) NO-ERROR.

   END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host /* Правило в контексте фирмы */
DO:
  assign
  add-option = "host":U
  .
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      add-option = ''.
      RETURN NO-APPLY.

  END.
  add-option = ''.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_obj Dialog-Frame
ON CHOOSE OF MENU-ITEM m_obj /* Правило в контексте объекта */
DO:
  assign
  add-option = "obj":U
  .
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT add-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      add-option = ''.
      RETURN NO-APPLY.

  END.
  add-option = ''.

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


&Scoped-define BROWSE-NAME BR-dis-rule
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
              buf_rule-profile.profile_id = p-profile-id .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-dr-obj Dialog-Frame 
PROCEDURE cr-dr-obj :
define input parameter p-add-mode as logical no-undo .
DEFINE INPUT PARAMETER p-host-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS INTEGER NO-UNDO.
define input parameter p-bh as handle no-undo.
define variable v-bh as handle no-undo .
define buffer buf_dr-obj for dr-obj.
v-bh = buffer buf_dr-obj:handle.
FIND FIRST buf_dr-obj WHERE
          buf_dr-obj.host-code = p-host-code
    AND buf_dr-obj.obj-type = p-obj-type
    AND buf_dr-obj.obj-code = p-obj-code
    NO-ERROR.
IF NOT AVAILABLE buf_dr-obj THEN DO:
  CREATE buf_dr-obj.
  v-bh:buffer-copy( p-bh).
  ASSIGN
  buf_dr-obj.host-code = p-host-code
  buf_dr-obj.obj-type = p-obj-type
  buf_dr-obj.obj-code = p-obj-code
  .

  RELEASE buf_dr-obj.
END.
else do:
  if p-add-mode = yes then do:
    message
    substitute("Уже задано правило скидки для &1"
              ,(if p-obj-type = ''
              then {&cmp} + string(p-host-code)
              else p-obj-type + string(p-obj-code))
              )
    view-as alert-box error .
    undo, return error .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE del-dr-obj Dialog-Frame 
PROCEDURE del-dr-obj :
DEFINE INPUT PARAMETER p-host-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS INTEGER NO-UNDO.

define buffer buf_dr-obj for dr-obj.
FIND FIRST buf_dr-obj WHERE
          buf_dr-obj.host-code = p-host-code
   AND buf_dr-obj.obj-type = p-obj-type
   AND buf_dr-obj.obj-code = p-obj-code NO-ERROR.
IF AVAILABLE buf_dr-obj THEN DO:
   DELETE buf_dr-obj.
END.


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
  DISPLAY t-is-over rs-r-b l-r-b 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help t-is-over rs-r-b b-add b-del b-chg b-lkp 
         BR-dis-rule BR-rcp 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
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

/*параметры p-rule-num-obj p-rule-num-host уже содержатся во временной таблице tt-rule-call-param */

/*заполним вспомогательнубю таблицу по объектам*/
FOR EACH tt-rule-call-param WHERE
    tt-rule-call-param.param-name = "p-rule-num-obj"
  or tt-rule-call-param.param-name = "p-rule-num-host"
    , FIRST X_dis-rule NO-LOCK WHERE X_dis-rule.rule-num = tt-rule-call-param.param-value-integer:
  if tt-rule-call-param.p-index > 0 then do:
    RUN cr-dr-obj IN THIS-PROCEDURE (
                   input no
                  ,INPUT X_dis-rule.host-code
                  ,INPUT X_dis-rule.obj-type
                  ,INPUT X_dis-rule.obj-code
                  ,(buffer tt-rule-call-param:handle)
                  ).
  end.
END.

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
assign
b-add:menu-mouse in frame {&frame-name} = 1.
display
t-is-over
rs-r-b
l-r-b
with frame {&frame-name} .
VIEW FRAME {&frame-name}.
ENABLE
rs-r-b WHEN p-mode <> {&LOOKUP}
b-add WHEN p-mode <> {&LOOKUP}
b-chg WHEN p-mode <> {&LOOKUP}
b-del WHEN p-mode <> {&LOOKUP}
b-lkp
t-is-over WHEN p-mode <> {&LOOKUP}
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
br-dis-rule
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
FRAME {&FRAME-NAME}:TITLE =
substitute("Параметры прогрессивного Алгоритма зависимости Сумма накоплений -> % скидки на товар по фирме/объекту (профайл &1)", p-profile-id).
{&OPEN-QUERY-br-dis-rule}
/*RUN rcps_OpenBr in THIS-PROCEDURE.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-add-dr Dialog-Frame 
PROCEDURE proc-add-dr :
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
    leave.
  end.
end. /*do v-ii = 1 to 99999:*/

run rcps_proc-b-add in this-procedure (
                                        input p-profile-id
                                        ,INPUT p-once-more
                                        ,input p-call-id
                                        ,input p-rp-param-name
                                        ,input v-ii ) no-error.
if error-status:error then return error.
find first tt-rule-call-param where
          tt-rule-call-param.param-name = p-rule-param-name
    and tt-rule-call-param.rule_id = p-rule-id
    and tt-rule-call-param.codex_id = p-codex-id
    and tt-rule-call-param.ruleset_id = p-ruleset-id
    and tt-rule-call-param.p-index = v-ii no-error .
run proc-b-chg in this-procedure ( INPUT yes, input p-rp-param-name ) no-error.
if error-status:error then do:
  for each tt-rule-call-param where
          tt-rule-call-param.param-name = p-rule-param-name
    and tt-rule-call-param.rule_id = p-rule-id
    and tt-rule-call-param.codex_id = p-codex-id
    and tt-rule-call-param.ruleset_id = p-ruleset-id
    and tt-rule-call-param.p-index = v-ii :
    delete tt-rule-call-param.
  end.
  return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER p-add-option AS CHARACTER NO-UNDO.
CASE p-add-option:
  WHEN "host" THEN do:
    run proc-add-dr in this-procedure ( input "p-rule-num-host"
                                  ,input "p-rule-num-host"
                                  ,input {&some-codex-id-host}
                                  ,INPUT {&some-ruleset-id-host}
                                  ,INPUT {&some-rule-id-host}
                                  ) no-error.

  END.
  WHEN  "obj" THEN DO:
    run proc-add-dr in this-procedure ( input "p-rule-num-obj"
                                     ,input "p-rule-num-obj"
                                     ,input {&some-codex-id-obj}
                                     ,INPUT {&some-ruleset-id-obj}
                                     ,INPUT {&some-rule-id-obj}
                                     ) no-error.

  END.
END CASE.
{&open-query-br-dis-rule}
apply "entry" to br-dis-rule IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame 
PROCEDURE proc-b-chg :
DEFINE INPUT PARAMETER p-add AS LOGICAL no-undo.
define input parameter p-rp-param-name as character no-undo.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_dr-obj FOR dr-obj.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-init-rid-list AS CHARACTER NO-UNDO.
define variable v-th-rid-list as character no-undo .
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
define variable v-tt-rid as recid no-undo .
define variable v-host-code as integer   no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-dop-i as integer   no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_clients for ub.clients.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_dis-card-type for ub.dis-card-type.

run gen-row-keyr in this-procedure (
   input  p-call-id
  ,input  ? /* буфер записи которую будем искать. если ищем по key-rec то ? */
  ,input  "ub"
  ,input  ? /* буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
  ,input no-lock
  ,output v-tbl-row
  ,output v-tbl-name) no-error.
if not error-status:error then do:
  find first buf_dis-card-type no-lock where
            rowid(Buf_dis-card-type) = v-tbl-row no-error .
end.
if p-add then do:
  case p-rp-param-name:
    when "p-rule-num-host" then do:
      /*если эмитент фирма - то фирму не выбираем*/
      if available buf_dis-card-type
      and buf_dis-card-type.emitent-host-code <> 0 then do:
        v-host-code = buf_dis-card-type.emitent-host-code.
      end.
      else do:
      run adm/sconfs.w ( input parparentproc
                         ,input "b-sel"
                         ,input no
                         ,input 0
                         ,output v-dop-i
                         ,input-output v-th-rid-list) no-error.
       if v-th-rid-list <> '' then do:
         find first buf_sysconf no-lock
                            where recid(buf_sysconf) = integer(entry(1, v-th-rid-list)).
         v-host-code = buf_sysconf.host-code.
       end.
    end.
    end.
    when "p-rule-num-obj" then do:
       run ref/thobjs.w ( input parparentproc
                         ,input ? /*p-callback-handle*/
                         ,input "b-sel"
                         ,input {&all}
                         ,input ''
                         ,input -1
                         ,input (if available buf_dis-card-type
                                 and buf_dis-card-type.emitent-host-code <> 0
                                 then buf_dis-card-type.emitent-host-code
                                 else 0)
                         ,input-output v-th-rid-list) no-error.
       if v-th-rid-list <> '' then do:
         find first buf_clients no-lock where
                   recid(buf_clients) = integer(v-th-rid-list) .
         v-obj-type = buf_clients.obj-type.
         v-obj-code = buf_clients.obj-code.
         { gbl/hostcode.i v-obj-type v-obj-code v-host-code }
       end.
    end.
  end case.

end.
else do:
  FIND FIRST buf_dis-rule NO-LOCK WHERE
        buf_dis-rule.rule-num = dr-obj.param-value-integer NO-ERROR.
  IF NOT AVAILABLE buf_dis-rule THEN DO:
    MESSAGE
    substitute("Не найдено правило скидки с номером &1",  dr-obj.param-value-integer)
    VIEW-AS ALERT-BOX ERROR.
    undo, RETURN NO-APPLY.
  END.
  v-init-rid-list = STRING(RECID(buf_dis-rule)).
  v-rid-list = v-init-rid-list.
  assign
  v-host-code = buf_dis-rule.host-code
  v-obj-type = buf_dis-rule.obj-type
  v-obj-code = buf_dis-rule.obj-code
  .
end.
run ref/dis-ruls.w (   input  parparentproc
                    ,input v-host-code /*p-host-code*/
                    ,input v-obj-type /*p-curr-obj-type*/
                    ,input v-obj-code /*p-curr-obj-code*/
                    ,input (if v-host-code = v-cntxt-host-code-obj
                            and ((v-obj-type = v-cntxt-obj-type
                            and v-obj-code = v-cntxt-obj-code)
                            or p-rp-param-name = "p-rule-num-host")
                            then "b-sel,b-add"
                            else "b-sel")
                    ,input (if p-rp-param-name = "p-rule-num-obj"
                            then "upper-rule-num-object"
                            else "upper-rule-num-host")
                    ,input {&dis-rule-templ-rl-root}
                    ,input ? /*p-time-templ-rl-root*/
                    ,input 0 /*p-b-code*/
                    ,input-output v-sts /*p-sts*/
                    ,input-OUTPUT v-rid-list) NO-ERROR.
if v-rid-list <> '':U
AND v-rid-list <> v-init-rid-list then do:
  find first buf_dis-rule no-lock where
            recid(buf_dis-rule) = integer(v-rid-list) no-error.
  if not available buf_dis-rule then do:
      MESSAGE substitute("Не найдено правило скидки c recid &1", v-rid-list)
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN NO-APPLY.
  end.
  case p-rp-param-name:
    when "p-rule-num-host" then do:
      if buf_dis-rule.host-code = 0
      or not (buf_dis-rule.obj-type = ''
              and
              buf_dis-rule.obj-code = 0) then do:
        message
        "Для задания правила скидки в контексте фирмы необходимо выбрать правило по фирме!"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    when "p-rule-num-obj" then do:
      if (buf_dis-rule.obj-type = ''
        or
        buf_dis-rule.obj-code = 0) then do:
        message
        "Для задания правила скидки в контексте объекта необходимо выбрать правило по объекту!"
        view-as alert-box error .
        undo, return error.
      end.
    end.
  end case.
  DO TRANSACTION
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      IF p-add THEN do:
        RUN cr-dr-obj IN THIS-PROCEDURE (
                      input yes
                      ,INPUT buf_dis-rule.host-code
                      ,INPUT buf_dis-rule.obj-type
                      ,INPUT buf_dis-rule.obj-code
                      ,(buffer tt-rule-call-param:handle)
                      ).
      end.
      RUN rcps_set-value IN THIS-PROCEDURE (
                                         input (if p-add
                                                then tt-rule-call-param.profile_id
                                                else dr-obj.profile_id)
                                        ,input (if p-add
                                                then tt-rule-call-param.once-more
                                                else dr-obj.once-more)
                                        ,input (if p-add
                                                then tt-rule-call-param.call_id
                                                else dr-obj.call_id)
                                        ,INPUT (if p-list-mode = {&table_rp-rule-param}
                                              then p-rp-param-name
                                              else '':U)
                                        ,INPUT (if p-add
                                               then tt-rule-call-param.p-index
                                               else dr-obj.p-index)
                                        ,INPUT '' /*v-value-character*/
                                        ,INPUT ? /*v-value-date*/
                                        ,INPUT 0 /*v-value-decimal*/
                                        ,INPUT buf_dis-rule.rule-num /*v-value-integer*/
                                        ,INPUT NO /*v-value-logical*/ ) no-error .
    if error-status :error then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error .
    end.
    find first buf_dr-obj where
              buf_dr-obj.host-code = buf_dis-rule.host-code
        and  buf_dr-obj.obj-type = buf_dis-rule.obj-type
        and  buf_dr-obj.obj-code = buf_dis-rule.obj-code.
    v-tt-rid = recid(buf_dr-obj).
    buf_dr-obj.param-value-integer = buf_dis-rule.rule-num.
    release buf_dr-obj.
  END. /*TRANSATION*/
  {&OPEN-QUERY-br-dis-rule}
  reposition br-dis-rule to recid v-tt-rid.
  apply "entry" to br-dis-rule in frame {&frame-name} .
end. /*if v-rid-list <> '':U*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*здесь делаем assig и свои свобсвтенные проверки*/
define buffer buf_prop-ref for ub.prop-ref.
define variable v-ii as integer   no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
v-ii = 0.
assign
frame {&frame-name}
t-is-over
rs-r-b
.

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

/*для параметров p-rule-num-obj p-rule-num-host все изменения уже сделаны!!!*/

run resort-rule-call-param in this-procedure ( input "p-rule-num-host"
                                               ,input {&some-rule-id-host}).
run resort-rule-call-param in this-procedure ( input "p-rule-num-obj"
                                               ,input {&some-rule-id-obj}).

/*сохраним в tt0-rule-call-param*/
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

