&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE rule-call-param.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE rule-call-param.
DEFINE BUFFER X_rp-rule-param FOR rp-rule-param.
DEFINE BUFFER X_rule FOR rule.
DEFINE BUFFER X_ruledict-param FOR ruledict-param.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание и просмотр параметров вызова правил для профайла 1

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/10/10
Author: Bakhtadze Natalya
Creation date: 06/10/10

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
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 1".
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
{ ref/cgrplbfn.i }
{ rul/ruleset_.i }
{ ref/dctpass.i }
&scop rule-sale-in  1308
&scop rule-sale-out 1308
&scop rule-trn-in   1308
&scop rule-trn-out  1308
&scop rule-import   1308
&scop rule-payment  1797

&scop rule-sale-in-obj  1303
&scop rule-sale-out-obj 1303
&scop rule-trn-in-obj   1303
&scop rule-trn-out-obj  1303
&scop rule-import-obj   1303



define variable v-running-mode as logical no-undo .
define variable v-old-on-off as logical no-undo .

DEFINE BUFFER X_dis-rule FOR ub.dis-rule.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-rcp

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_ruledict-param X_rp-rule-param ~
tt-rule-call-param TERM_tt-rule-call-param

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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help RECT-1 f-issue-code ~
b-issue-code EDITOR-1 f-dis-tot-obj-code b-dis-tot-obj-code f-issue-date ~
f-valid-date f-cli-grp-code b-cli-grp f-grp-name f-category f-lim-cr ~
t-on-off BR-rcp 
&Scoped-Define DISPLAYED-OBJECTS f-issue-code EDITOR-1 f-issue-name ~
f-dis-tot-obj-code f-dis-tot-obj-name f-issue-date f-valid-date ~
f-cli-grp-code f-grp-name f-category f-lim-cr t-on-off 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cli-grp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-dis-tot-obj-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "Помо&щь" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-issue-code 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "данные параметры используются при импорте новых карт из текстового файла для установки значений по умолчанию" 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 27.5 BY 4.25 NO-UNDO.

DEFINE VARIABLE f-category AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Категория карты" 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE f-cli-grp-code AS INTEGER FORMAT ">,>>>,>>>>9":U INITIAL 0 
     LABEL "Группа клиентов, в которую попадет клиент новой карты" 
     VIEW-AS FILL-IN 
     SIZE 15.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dis-tot-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Код магазина для начисления общих итогов" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-dis-tot-obj-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-grp-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 96.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-issue-code AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "Код магазина, выдавшего карту" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-issue-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата выдачи карты" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-issue-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 55 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-lim-cr AS DECIMAL FORMAT "->>,>>9,999.99":U INITIAL 0 
     LABEL "Лимит кредита (только для КРЕДИТНЫХ карт)" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1.08 NO-UNDO.

DEFINE VARIABLE f-valid-date AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата действия карты" 
     VIEW-AS FILL-IN 
     SIZE 11 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 97.5 BY 13.58.

DEFINE VARIABLE t-on-off AS LOGICAL INITIAL no 
     LABEL "Включен обсчет ОБЩИХ итогов по ДК (по объекту, фирме и глобально)" 
     VIEW-AS TOGGLE-BOX
     SIZE 88 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-rcp FOR 
      X_ruledict-param, 
      X_rp-rule-param, 
      tt-rule-call-param, 
      TERM_tt-rule-call-param SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
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
     f-issue-code AT ROW 2 COL 43 COLON-ALIGNED WIDGET-ID 150
     b-issue-code AT ROW 2 COL 53 WIDGET-ID 170
     EDITOR-1 AT ROW 2.08 COL 71 NO-LABEL WIDGET-ID 168
     f-issue-name AT ROW 3 COL 12 COLON-ALIGNED NO-LABEL WIDGET-ID 174
     f-dis-tot-obj-code AT ROW 4 COL 43 COLON-ALIGNED WIDGET-ID 152
     b-dis-tot-obj-code AT ROW 4 COL 53 WIDGET-ID 172
     f-dis-tot-obj-name AT ROW 5 COL 11.5 COLON-ALIGNED NO-LABEL WIDGET-ID 176
     f-issue-date AT ROW 7.42 COL 42.5 COLON-ALIGNED WIDGET-ID 154
     f-valid-date AT ROW 8.46 COL 42.5 COLON-ALIGNED WIDGET-ID 156
     f-cli-grp-code AT ROW 10.58 COL 72 COLON-ALIGNED WIDGET-ID 158
     b-cli-grp AT ROW 10.58 COL 89.5 WIDGET-ID 166
     f-grp-name AT ROW 11.67 COL 2 NO-LABEL WIDGET-ID 160
     f-category AT ROW 12.75 COL 43 COLON-ALIGNED WIDGET-ID 164
     f-lim-cr AT ROW 13.79 COL 43 COLON-ALIGNED WIDGET-ID 162
     t-on-off AT ROW 15.67 COL 2 WIDGET-ID 180
     BR-rcp AT ROW 17 COL 1 WIDGET-ID 100
     RECT-1 AT ROW 2 COL 1.5 WIDGET-ID 182
     SPACE(1.10) SKIP(7.68)
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
/* BROWSE-TAB BR-rcp t-on-off Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

ASSIGN 
       EDITOR-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-dis-tot-obj-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       f-dis-tot-obj-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN f-grp-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-issue-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN 
       f-issue-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

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


&Scoped-define SELF-NAME b-cli-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cli-grp Dialog-Frame
ON CHOOSE OF b-cli-grp IN FRAME Dialog-Frame /* Btn 1 */
DO:

  DEFINE VARIABLE rid-list as CHARACTER no-undo.
  define variable v-full-name as character no-undo .
  DEFINE BUFFER buf_cli-grp FOR ub.cli-grp.
  if f-cli-grp-code <> 0 then do:
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-code = f-cli-grp-code no-error.
    if available buf_cli-grp then do:
      rid-list = string(recid(buf_cli-grp)).
    end.
  end.
  run ref/cli-grps.w (
                 input parparentproc
                ,input ({&g#term} + {&comma-char} + "b-sel")
                ,input-output rid-list).
  if rid-list <> "" then do:
    FIND FIRST buf_cli-grp NO-LOCK WHERE
              recid(buf_cli-grp) = integer(rid-list) NO-ERROR.
    IF NOT AVAIL buf_cli-grp then return no-apply.
    assign
    f-cli-grp-code = buf_cli-grp.node-code
    .
    run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code
                                                    ,output v-full-name).

    DISPLAY
    f-cli-grp-code
    v-full-name @ f-grp-name
    WITH FRAME {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dis-tot-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dis-tot-obj-code Dialog-Frame
ON CHOOSE OF b-dis-tot-obj-code IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE rid-list as CHARACTER no-undo.
  DEFINE BUFFER buf_shop FOR ub.shop.
  DEFINE BUFFER buf_clients FOR ub.clients.
  if f-dis-tot-obj-code <> 0 then do:
    find first buf_shop no-lock where
             buf_shop.obj-code = f-dis-tot-obj-code no-error.
    if available buf_shop then do:
      rid-list = string(recid(buf_shop)).
    end.
  end.
  run adm/shops.w (
               input parparentproc
              ,input "b-sel"
              ,input-output rid-list
              ,input no /*p-only-cur-db-num*/
              ).
  if rid-list <> "" then do:
     FIND FIRST buf_shop NO-LOCK WHERE recid(buf_shop) = integer(rid-list) NO-ERROR.
     IF NOT AVAILABLE buf_shop then return no-apply.
      FIND FIRST buf_clients No-LOCK WHERE
                buf_clients.obj-type = {&shop}
           AND buf_clients.obj-code = buf_shop.obj-code NO-ERROR.

    IF NOT AVAIL buf_clients then return no-apply.
    assign
    f-dis-tot-obj-code = buf_clients.obj-code
    f-dis-tot-obj-name = BUF_clients.obj-name
    .
    DISPLAY
    f-dis-tot-obj-code
    f-dis-tot-obj-name
    WITH FRAME {&frame-name}.
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


&Scoped-define SELF-NAME b-issue-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-issue-code Dialog-Frame
ON CHOOSE OF b-issue-code IN FRAME Dialog-Frame /* Btn 1 */
DO:
  DEFINE VARIABLE rid-list as CHARACTER no-undo.
  DEFINE BUFFER buf_shop FOR ub.shop.
  DEFINE BUFFER buf_clients FOR ub.clients.
  if f-issue-code <> 0 then do:
    find first buf_shop no-lock where
             buf_shop.obj-code = f-issue-code no-error.
    if available buf_shop then do:
      rid-list = string(recid(buf_shop)).
    end.
  end.
  run adm/shops.w (
               input parparentproc
              ,input "b-sel"
              ,input-output rid-list
              ,input no /*p-only-cur-db-num*/
              ).
  if rid-list <> "" then do:
     FIND FIRST buf_shop NO-LOCK WHERE recid(buf_shop) = integer(rid-list) NO-ERROR.
     IF NOT AVAILABLE buf_shop then return no-apply.
      FIND FIRST buf_clients No-LOCK WHERE
                buf_clients.obj-type = {&shop}
           AND buf_clients.obj-code = buf_shop.obj-code NO-ERROR.

    IF NOT AVAIL buf_clients then return no-apply.
    assign
    f-issue-code = buf_clients.obj-code
    f-issue-name = BUF_clients.obj-name
    .
    DISPLAY
    f-issue-code
    f-issue-name
    WITH FRAME {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-rcp
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

{ gbl/ed_date.i f-issue-date }
{ gbl/ed_date.i f-valid-date }

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
  DISPLAY f-issue-code EDITOR-1 f-issue-name f-dis-tot-obj-code 
          f-dis-tot-obj-name f-issue-date f-valid-date f-cli-grp-code f-grp-name 
          f-category f-lim-cr t-on-off 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help RECT-1 f-issue-code b-issue-code EDITOR-1 
         f-dis-tot-obj-code b-dis-tot-obj-code f-issue-date f-valid-date 
         f-cli-grp-code b-cli-grp f-grp-name f-category f-lim-cr t-on-off 
         BR-rcp 
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
define variable v-full-grp-name as character no-undo .
define variable v-rule-sale-out as logical no-undo .
define variable v-rule-sale-in as logical no-undo .
define variable v-rule-trn-out as logical no-undo .
define variable v-rule-trn-in as logical no-undo .
define variable v-rule-import as logical no-undo .
define variable v-rule-sale-out-obj as logical no-undo .
define variable v-rule-sale-in-obj as logical no-undo .
define variable v-rule-trn-out-obj as logical no-undo .
define variable v-rule-trn-in-obj as logical no-undo .
define variable v-rule-import-obj as logical no-undo .
define variable v-rule-payment as logical no-undo .


define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_cli-grp for ub.cli-grp.
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf2_clients FOR ub.clients.

run rcps_Myenable0 in this-procedure .
/*здесьс делаем получение наших данных*/
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-issue-code"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output f-issue-code  /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-dis-tot-obj-code"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output f-dis-tot-obj-code  /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).


v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-issue-date"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output f-issue-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-valid-date"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output f-valid-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-cli-grp-code"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output f-cli-grp-code /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-category"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output v-value-decimal /*p-value-decimal*/
                                ,output f-category /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-lim-cr"
                                ,INPUT-output v-index-id
                                ,output v-value-character /*p-value-character*/
                                ,output v-value-date /*p-value-date*/
                                ,output f-lim-cr /*p-value-decimal*/
                                ,output v-value-integer /*p-value-integer*/
                                ,output v-value-logical /*p-value-logical*/
                                ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_1}
                                            ,input {&dct-proc_1_sale-close_1}
                                            ,input {&rule-sale-out-obj}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-sale-out-obj ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_1}
                                            ,input {&dct-proc_1_sale-delete_2}
                                            ,input {&rule-sale-in-obj}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-sale-in-obj ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_1}
                                            ,input {&dct-proc_1_trn-doc-close_3}
                                            ,input {&rule-trn-out-obj}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-trn-out-obj ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_1}
                                            ,input {&dct-proc_1_trn-doc-delete_4}
                                            ,input {&rule-trn-in-obj}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-trn-in-obj ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_1}
                                            ,input {&dct-proc_1_import_5}
                                            ,input {&rule-import-obj}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-import-obj ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_sale-close_1}
                                            ,input {&rule-sale-out}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-sale-out ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_sale-delete_2}
                                            ,input {&rule-sale-in}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-sale-in ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_trn-doc-close_3}
                                            ,input {&rule-trn-out}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-trn-out ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_trn-doc-delete_4}
                                            ,input {&rule-trn-in}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-trn-in ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_import_6}
                                            ,input {&rule-import}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-import ).

run rcps_get-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_payment-on-card}
                                            ,input {&rule-payment}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output v-rule-payment ).
if p-mode = {&add-def} then do:
  assign
  t-on-off = yes
  v-old-on-off = t-on-off
  .
end.
else do:
assign
t-on-off = v-rule-sale-out
                and
                v-rule-sale-in
                and
                v-rule-trn-out
                and
                v-rule-trn-in
                and
                v-rule-import
and
v-rule-sale-out-obj
                and
                v-rule-sale-in-obj
                and
                v-rule-trn-out-obj
                and
                v-rule-trn-in-obj
                and
                v-rule-import-obj
                and
                  (v-rule-payment or true)
v-old-on-off = t-on-off
.
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

find first buf_cli-grp no-lock where
          buf_cli-grp.node-code = f-cli-grp-code no-error.
if available buf_cli-grp then do:
    run cli-grplib-get-full-name in this-procedure ( input buf_cli-grp.node-code
                                                    ,output v-full-grp-name).
end.
if f-issue-code > 0 then do:
  FIND FIRST buf_clients No-LOCK WHERE
            buf_clients.obj-type = {&shop}
        AND buf_clients.obj-code = f-issue-code NO-ERROR.
end.
if f-dis-tot-obj-code > 0 then do:
  FIND FIRST buf2_clients No-LOCK WHERE
            buf2_clients.obj-type = {&shop}
        AND buf2_clients.obj-code = f-dis-tot-obj-code NO-ERROR.
end.
editor-1:screen-value in frame {&frame-name} = "данные параметры используются при импорте новых карт из текстового файла для установки значений по умолчанию"  .
display
f-dis-tot-obj-code
f-issue-code
f-issue-date
f-valid-date
f-cli-grp-code
f-grp-name
f-category
f-lim-cr
(if available buf_cli-grp then v-full-grp-name else "Не найдена группа клиентов!!!") @ f-grp-name
(if available buf_clients then buf_clients.obj-name else "Не найден магазин!!!") @ f-issue-name
(if available buf2_clients then buf2_clients.obj-name else "Не найден магазин!!!") @ f-dis-tot-obj-name
t-on-off
with frame {&frame-name} .
VIEW FRAME {&frame-name}.
ENABLE
f-issue-date WHEN p-mode <> {&LOOKUP}
f-valid-date WHEN p-mode <> {&LOOKUP}
b-cli-grp WHEN p-mode <> {&LOOKUP}
f-category WHEN p-mode <> {&LOOKUP}
f-lim-cr WHEN p-mode <> {&LOOKUP}
b-cli-grp WHEN p-mode <> {&LOOKUP}
b-issue-code WHEN p-mode <> {&LOOKUP}
b-dis-tot-obj-code WHEN p-mode <> {&LOOKUP}
t-on-off WHEN p-mode <> {&LOOKUP}
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
editor-1
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
substitute("Параметры Неизменяемого Алгоритма по умолчанию (профайл &1)", p-profile-id).
{&OPEN-QUERY-br-dis-gds-rule}
/*RUN rcps_OpenBr in THIS-PROCEDURE.*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
/*здесь делаем assig и свои свобсвтенные проверки*/
define variable v-ii as integer   no-undo .
define variable glog as logical no-undo .
v-ii = 0.
assign
frame {&frame-name}
f-issue-code
f-dis-tot-obj-code
f-category
f-valid-date
f-issue-date
f-lim-cr
f-cli-grp-code
t-on-off
.
if f-issue-code = 0 then do:
  message
  "Вы не определили код магазина выдачи карты"
  view-as alert-box error .
  undo, return error .
end.
if f-dis-tot-obj-code = 0 then do:
  message
  "Вы не определили код магазина для начисления общих итогов"
  view-as alert-box error .
  undo, return error .
end.
if f-issue-date = ? then do:
  message
  "Вы не определили дату выдачи карты"
  view-as alert-box error .
  undo, return error .
end.
if f-issue-date = ? then do:
  message
  "Вы не определили дату действия карты" skip
  "Вы действительно хотите, чтобы карты НЕ ИМЕЛИ СРОКА ДЕЙСТВИЯ?"
   view-as alert-box question buttons yes-no update glog .
end.
if f-cli-grp-code = 0 then do:
  message
  "Вы не определили группу, в которую будут попадать клиенты при создании новой карты"
  view-as alert-box error .
  undo, return error .
end.
if t-on-off = yes
and v-old-on-off = no then do:
  message
  "ПОВТОРНОЕ ВКЛЮЧЕНИЕ ОБСЧЕТА ИТОГОВ ПО ДК НЕВОЗМОЖНО!!!!"
  view-as alert-box error .
  undo, return error .
end.
if t-on-off = no
and v-old-on-off = yes
then do:
  /*затребуем пароль*/
  message
  "ВНИМАНИЕ!!!!" skip(2)
  "Выключение обсчета итогов по картам является НЕОБРАТИМОЙ операцией!" skip(0)
  "Вы действительно хотите продолжить?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then return error.
  /*
  define variable v-password as character no-undo .
  define variable v-dc-type as character no-undo .
  define variable v-value as character no-undo .
  define variable v-emitent-host-code-chr as character no-undo .
  define variable v-field-list as character no-undo .
  define variable v-value-list as character no-undo .
  run gen-key-fv in this-procedure ( input p-call-id
                                    ,output v-field-list
                                    ,output v-value-list).
  assign
  v-dc-type  = entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
  v-emitent-host-code-chr = entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key})
  .
  v-password = dctpass_set-pswd(  input today
                                 ,input v-emitent-host-code-chr
                                 ,input v-dc-type).
  run gbl/d-prompt.w
    ( 'title=':u + "Отключить обсчет итогов по ДК &1 НАВСЕГДА?" + '\':u
      + 'format=' + "X(24)" + '\':u
      + 'type=' + {&type-char} + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=30\':u
      + 'fillin_height=1\':u
      + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=no\':u
    , input-output v-value
    ).
  if return-value = 'false':u
  then do:
    undo, return error.
  end.
  /*message v-password "v-password" skip v-value "v-value" view-as alert-box .*/
  IF v-value <> v-password THEN DO:
      MESSAGE
     "Неверный пароль!"
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
  */
end.
  /*все правила выключаются одной галкой!!!!*/
  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_1}
                                            ,input {&dct-proc_1_sale-close_1}
                                            ,input {&rule-sale-out-obj}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-on-off).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_1}
                                              ,input {&dct-proc_1_sale-delete_2}
                                              ,input {&rule-sale-in-obj}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_1}
                                              ,input {&dct-proc_1_trn-doc-close_3}
                                              ,input {&rule-trn-out-obj}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_1}
                                              ,input {&dct-proc_1_trn-doc-delete_4}
                                              ,input {&rule-trn-in-obj}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_1}
                                              ,input {&dct-proc_1_import_5}
                                              ,input {&rule-import-obj}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                            ,input {&dct-proc_2_sale-close_1}
                                            ,input {&rule-sale-out}
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-on-off).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                              ,input {&dct-proc_2_sale-delete_2}
                                              ,input {&rule-sale-in}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                              ,input {&dct-proc_2_trn-doc-close_3}
                                              ,input {&rule-trn-out}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                              ,input {&dct-proc_2_trn-doc-delete_4}
                                              ,input {&rule-trn-in}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                              ,input {&dct-proc_2_import_6}
                                              ,input {&rule-trn-in}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).


  run rcps_set-rule-on-off in this-procedure ( input {&dct-proc_2}
                                              ,input {&dct-proc_payment-on-card}
                                              ,input {&rule-payment}
                                              ,input p-profile-id
                                              ,input p-once-more
                                              ,input t-on-off ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-issue-code"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT f-issue-code /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-dis-tot-obj-code"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT f-dis-tot-obj-code /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-issue-date"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT f-issue-date /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-valid-date"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT f-valid-date /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-category"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0.0 /*p-value-decimal*/
                                ,INPUT f-category /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-lim-cr"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT f-lim-cr /*p-value-decimal*/
                                ,INPUT 0 /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).

RUN rcps_set-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-cli-grp-code"
                                ,INPUT 0 /*p-index-id*/
                                ,INPUT '' /*p-value-character*/
                                ,INPUT ? /*p-value-date*/
                                ,INPUT 0 /*p-value-decimal*/
                                ,INPUT f-cli-grp-code /*p-value-integer*/
                                ,INPUT no /*p-value-logical*/
                                ).


run rcps_proc-save0 in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

