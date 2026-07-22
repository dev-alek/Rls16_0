&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-loc-rule-i-script NO-UNDO LIKE ub.rule-i-script.
DEFINE SHARED TEMP-TABLE tt-rule NO-UNDO LIKE ub.rule
       field level as integer.
DEFINE SHARED TEMP-TABLE tt-rule-i-script NO-UNDO LIKE ub.rule-i-script.
DEFINE SHARED TEMP-TABLE tt-rule-script NO-UNDO LIKE ub.rule-script
       field level as integer
       field gen-order as character
       field upper_rule_id as integer.
DEFINE SHARED TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.
DEFINE BUFFER X_dtruledict FOR ub.ruledict.
DEFINE BUFFER X_prop-script FOR ub.prop-script.
DEFINE BUFFER X_pscript-ruleset FOR ub.pscript-ruleset.
DEFINE BUFFER X_rule-i-script FOR ub.rule-i-script.
DEFINE BUFFER X_ruledict FOR ub.ruledict.
DEFINE BUFFER X_ruleset FOR ub.ruleset.
DEFINE BUFFER Y_prop-script FOR ub.prop-script.
DEFINE BUFFER Y_pscript-ruleset FOR ub.pscript-ruleset.
DEFINE BUFFER Y_ruledict FOR ub.ruledict.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание одного rule-script

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/19/07
Author: Bakhtadze Natalya
Creation date: 02/19/07

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
define input parameter p-upper-rule-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-salience AS INTEGER NO-UNDO.
define input-output parameter p-script-id as integer no-undo .
/*может быть COND или  CONS ИЛИ GOTO*/
/*соответственно выражение должно быть логическим или void*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание одного rule-script".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }
{ gbl/key-rec.i }
{ rul/real-ind.i }
DEFINE BUFFER tt-l_rule-script FOR tt-rule-script.
define buffer bufv_tt-rule-i-script for tt-rule-i-script.

DEFINE TEMP-TABLE tt-widget
FIELD handle_ AS WIDGET-HANDLE
FIELD name_ AS CHARACTER
FIELD script-al AS CHARACTER
FIELD script-nl AS CHARACTER
FIELD num_ AS INTEGER
FIELD ROW_ AS DECIMAL
FIELD COLUMN_ AS DECIMAL
FIELD WIDTH_ AS DECIMAL
FIELD HEIGHT_ AS DECIMAL
FIELD left-top AS DECIMAL
FIELD right-bottom AS DECIMAL
FIELD LENGTH_ AS DECIMAL
FIELD script-type AS CHARACTER
/*prop-script-type-find prop-script-type-get и т.д.*/
FIELD entry-type AS CHARACTER
 /*{&rdict-etype-prop-script}, {&rdict-etype-operator}, {&rdict-etype-constant} и т.д.*/
FIELD script-value-type AS CHARACTER /**/
FIELD data-type AS CHARACTER /**/
FIELD script-al-fix AS CHARACTER
field dtm-code as integer
field class-dtm-code as integer
field uniq-key-rec as character
INDEX pi IS UNIQUE PRIMARY num_
INDEX ihandle HANDLE_
INDEX irc
ROW_
COLUMN_
.

define temp-table tt-widget-child no-undo
field num_ as integer
field level_ as integer
field position-al as integer
field position-nl as integer
field script-nl as character
field script-al as character
field entry-id AS INTEGER
/*
field init-value-character
field init-value-date
field init-value-decimal
field init-value-integer
field init-value-logical
*/
field param-data-type AS CHARACTER
field param-2-data-type AS CHARACTER
field param-3-data-type AS CHARACTER
field param-label AS CHARACTER
field param-mode AS CHARACTER
field param-name AS CHARACTER
field param-num AS INTEGER
index pi is unique primary
num_ level_ param-num
index p-al
position-al
index p-nl
position-nl
.



DEFINE VARIABLE v-current-row AS DECIMAL NO-UNDO INIT 18.
DEFINE VARIABLE v-current-column AS DECIMAL NO-UNDO INIT 1.

DEFINE TEMP-TABLE tt-complex no-undo
FIELD script-al AS CHARACTER
FIELD script-nl AS CHARACTER
FIELD entry-type AS CHARACTER
/*{&rdict-etype-prop-scrip}, {&rdict-etype-operator}, {&rdict-etype-constant} и т.д.*/
FIELD proc-type AS CHARACTER
FIELD script-name AS CHARACTER
FIELD script-type AS CHARACTER
FIELD script-value-type AS CHARACTER /**/
FIELD data-type AS CHARACTER /**/
field dtm-code as integer
field class-dtm-code as integer
FIEld KEY_ AS INTEGER
INDEX pi IS UNIQUE PRIMARY
KEY_.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-complex

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-complex X_dtruledict Y_ruledict ~
tt-ruledict-param X_prop-script X_pscript-ruleset X_ruledict ~
bufv_tt-rule-i-script

/* Definitions for BROWSE br-complex                                    */
&Scoped-define FIELDS-IN-QUERY-br-complex tt-complex.script-al tt-complex.script-nl
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-complex
&Scoped-define SELF-NAME br-complex
&Scoped-define QUERY-STRING-br-complex FOR EACH tt-complex
&Scoped-define OPEN-QUERY-br-complex OPEN QUERY br-complex FOR EACH tt-complex.
&Scoped-define TABLES-IN-QUERY-br-complex tt-complex
&Scoped-define FIRST-TABLE-IN-QUERY-br-complex tt-complex


/* Definitions for BROWSE br-dtruledict                                 */
&Scoped-define FIELDS-IN-QUERY-br-dtruledict X_dtruledict.script-nl X_dtruledict.script-al
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dtruledict
&Scoped-define SELF-NAME br-dtruledict
&Scoped-define QUERY-STRING-br-dtruledict FOR EACH X_dtruledict NO-LOCK WHERE X_dtruledict.entry-type = {&rdict-etype-datatype} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dtruledict OPEN QUERY {&SELF-NAME} FOR EACH X_dtruledict NO-LOCK WHERE X_dtruledict.entry-type = {&rdict-etype-datatype} INDEXED-REPOSITION .
&Scoped-define TABLES-IN-QUERY-br-dtruledict X_dtruledict
&Scoped-define FIRST-TABLE-IN-QUERY-br-dtruledict X_dtruledict


/* Definitions for BROWSE br-operator                                   */
&Scoped-define FIELDS-IN-QUERY-br-operator Y_ruledict.script-al Y_ruledict.script-nl
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-operator
&Scoped-define SELF-NAME br-operator
&Scoped-define QUERY-STRING-br-operator FOR EACH Y_ruledict NO-LOCK WHERE      (Y_ruledict.ENTRY-TYPE = {&rdict-etype-operator}       OR       Y_ruledict.ENTRY-TYPE = {&rdict-etype-constant}       OR       Y_ruledict.ENTRY-TYPE = {&rdict-etype-datatype}       OR       Y_ruledict.ENTRY-TYPE = {&rdict-etype-control}       )
&Scoped-define OPEN-QUERY-br-operator OPEN QUERY {&SELF-NAME} FOR EACH Y_ruledict NO-LOCK WHERE      (Y_ruledict.ENTRY-TYPE = {&rdict-etype-operator}       OR       Y_ruledict.ENTRY-TYPE = {&rdict-etype-constant}       OR       Y_ruledict.ENTRY-TYPE = {&rdict-etype-datatype}       OR       Y_ruledict.ENTRY-TYPE = {&rdict-etype-control}       ) .
&Scoped-define TABLES-IN-QUERY-br-operator Y_ruledict
&Scoped-define FIRST-TABLE-IN-QUERY-br-operator Y_ruledict


/* Definitions for BROWSE br-parameter                                  */
&Scoped-define FIELDS-IN-QUERY-br-parameter tt-ruledict-param.param-data-type tt-ruledict-param.param-mode tt-ruledict-param.param-name tt-ruledict-param.param-label
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parameter
&Scoped-define SELF-NAME br-parameter
&Scoped-define QUERY-STRING-br-parameter FOR EACH tt-ruledict-param
&Scoped-define OPEN-QUERY-br-parameter OPEN QUERY br-parameter FOR EACH tt-ruledict-param.
&Scoped-define TABLES-IN-QUERY-br-parameter tt-ruledict-param
&Scoped-define FIRST-TABLE-IN-QUERY-br-parameter tt-ruledict-param


/* Definitions for BROWSE br-pscript-ruleset                            */
&Scoped-define FIELDS-IN-QUERY-br-pscript-ruleset X_pscript-ruleset.script-name entry(1, X_prop-script.script-value-type) (IF num-entries(X_prop-script.script-value-type) > 1 THEN entry(2, X_prop-script.script-value-type) ELSE '':U) X_ruledict.script-nl
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-pscript-ruleset
&Scoped-define SELF-NAME br-pscript-ruleset
&Scoped-define QUERY-STRING-br-pscript-ruleset FOR EACH X_prop-script NO-LOCK where        X_prop-script.dtm-code = integer(cb-pscript-ruleset), ~
           FIRST X_pscript-ruleset NO-LOCK WHERE      X_pscript-ruleset.codex_id = p-codex-id     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)     AND  X_prop-script.language = X_pscript-ruleset.LANGUAGE     AND  X_prop-script.script-name = X_pscript-ruleset.script-name     AND  X_prop-script.revis_id = X_pscript-ruleset.revis_id, ~
           FIRST X_ruledict NO-LOCK WHERE      X_ruledict.ENTRY-TYPE = {&rdict-etype-prop-script} AND  X_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec
&Scoped-define OPEN-QUERY-br-pscript-ruleset OPEN QUERY {&SELF-NAME} FOR EACH X_prop-script NO-LOCK where        X_prop-script.dtm-code = integer(cb-pscript-ruleset), ~
           FIRST X_pscript-ruleset NO-LOCK WHERE      X_pscript-ruleset.codex_id = p-codex-id     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)     AND  X_prop-script.language = X_pscript-ruleset.LANGUAGE     AND  X_prop-script.script-name = X_pscript-ruleset.script-name     AND  X_prop-script.revis_id = X_pscript-ruleset.revis_id, ~
           FIRST X_ruledict NO-LOCK WHERE      X_ruledict.ENTRY-TYPE = {&rdict-etype-prop-script} AND  X_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec.
&Scoped-define TABLES-IN-QUERY-br-pscript-ruleset X_prop-script ~
X_pscript-ruleset X_ruledict
&Scoped-define FIRST-TABLE-IN-QUERY-br-pscript-ruleset X_prop-script
&Scoped-define SECOND-TABLE-IN-QUERY-br-pscript-ruleset X_pscript-ruleset
&Scoped-define THIRD-TABLE-IN-QUERY-br-pscript-ruleset X_ruledict


/* Definitions for BROWSE br-variable                                   */
&Scoped-define FIELDS-IN-QUERY-br-variable bufv_tt-rule-i-script.script-name bufv_tt-rule-i-script.script-TYPE
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-variable
&Scoped-define SELF-NAME br-variable
&Scoped-define QUERY-STRING-br-variable FOR EACH bufv_tt-rule-i-script NO-LOCK WHERE bufv_tt-rule-i-script.root_rule_id = p-root-rule-id  AND bufv_tt-rule-i-script.i-script-type = {&prop-script-type-variable} INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-variable OPEN QUERY {&SELF-NAME} FOR EACH bufv_tt-rule-i-script NO-LOCK WHERE bufv_tt-rule-i-script.root_rule_id = p-root-rule-id  AND bufv_tt-rule-i-script.i-script-type = {&prop-script-type-variable} INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-variable bufv_tt-rule-i-script
&Scoped-define FIRST-TABLE-IN-QUERY-br-variable bufv_tt-rule-i-script


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-complex}~
    ~{&OPEN-QUERY-br-dtruledict}~
    ~{&OPEN-QUERY-br-operator}~
    ~{&OPEN-QUERY-br-parameter}~
    ~{&OPEN-QUERY-br-pscript-ruleset}~
    ~{&OPEN-QUERY-br-variable}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-complex b-quit RS-language B-Help ~
cb-pscript-ruleset br-variable br-parameter br-operator br-dtruledict ~
br-complex br-pscript-ruleset b-defvariable B-operator b-parameter ~
B-prop-script b-variable f-prop-script F-operator f-variable f-parameter ~
f-complex f-defvariable
&Scoped-Define DISPLAYED-OBJECTS RS-language cb-pscript-ruleset ~
f-prop-script F-operator f-variable f-parameter f-complex f-defvariable

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-current-column Dialog-Frame
FUNCTION get-current-column RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-current-row Dialog-Frame
FUNCTION get-current-row RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-left-top Dialog-Frame
FUNCTION get-left-top RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-right-bottom Dialog-Frame
FUNCTION get-right-bottom RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD SUBSTITUTE-value-type Dialog-Frame
FUNCTION SUBSTITUTE-value-type RETURNS CHARACTER
  ( INPUT p-value-type AS CHARACTER, buffer buf_tt-widget for tt-widget)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-complex
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.

DEFINE BUTTON b-defvariable
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-operator
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.

DEFINE BUTTON b-parameter
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.

DEFINE BUTTON B-prop-script
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "&1.Перемещ."
     SIZE 14 BY 1.13.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-variable
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.

DEFINE VARIABLE cb-pscript-ruleset AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 98 BY 1 NO-UNDO.

DEFINE VARIABLE f-complex AS CHARACTER FORMAT "X(12)":U INITIAL "Сложн.выр-ние"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-defvariable AS CHARACTER FORMAT "X(12)":U INITIAL "Декл.перем."
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE F-operator AS CHARACTER FORMAT "X(12)":U INITIAL "Оп-ры, конст-ы"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-parameter AS CHARACTER FORMAT "X(12)":U INITIAL "Параметры"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-prop-script AS CHARACTER FORMAT "X(12)" INITIAL "Св-ва, мет-ды"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE f-variable AS CHARACTER FORMAT "X(12)":U INITIAL "Переменные"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.

DEFINE VARIABLE RS-language AS CHARACTER INITIAL "ABL"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "ABL", "ABL",
"lan", "lan"
     SIZE 15 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-complex FOR
      tt-complex SCROLLING.

DEFINE QUERY br-dtruledict FOR
      X_dtruledict SCROLLING.

DEFINE QUERY br-operator FOR
      Y_ruledict SCROLLING.

DEFINE QUERY br-parameter FOR
      tt-ruledict-param SCROLLING.

DEFINE QUERY br-pscript-ruleset FOR
      X_prop-script,
      X_pscript-ruleset,
      X_ruledict SCROLLING.

DEFINE QUERY br-variable FOR
      bufv_tt-rule-i-script SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-complex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-complex Dialog-Frame _FREEFORM
  QUERY br-complex DISPLAY
      tt-complex.script-al FORMAT "X(255)" WIDTH 45
tt-complex.script-nl FORMAT "X(255)" WIDTH 45
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.8 FIT-LAST-COLUMN.

DEFINE BROWSE br-dtruledict
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dtruledict Dialog-Frame _FREEFORM
  QUERY br-dtruledict NO-LOCK DISPLAY
      X_dtruledict.script-nl COLUMN-LABEL "Тип данных" FORMAT "X(255)":U
    WIDTH 20
X_dtruledict.script-al COLUMN-LABEL "Тип данных" FORMAT "X(255)":U
    WIDTH 7
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60 BY 13.8 FIT-LAST-COLUMN.

DEFINE BROWSE br-operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-operator Dialog-Frame _FREEFORM
  QUERY br-operator DISPLAY
      Y_ruledict.script-al FORMAT "X(255)" WIDTH 20 COLUMN-LABEL "Скрипт"
Y_ruledict.script-nl FORMAT "X(255)" WIDTH 20 COLUMN-LABEL "Скрипт"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60 BY 13.8 FIT-LAST-COLUMN.

DEFINE BROWSE br-parameter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parameter Dialog-Frame _FREEFORM
  QUERY br-parameter DISPLAY
      tt-ruledict-param.param-data-type COLUMN-LABEL "Тип" FORMAT "X(16)"
tt-ruledict-param.param-mode COLUMN-LABEL "Мода" FORMAT "X(16)"
tt-ruledict-param.param-name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
tt-ruledict-param.param-label COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 13.8 FIT-LAST-COLUMN.

DEFINE BROWSE br-pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-pscript-ruleset Dialog-Frame _FREEFORM
  QUERY br-pscript-ruleset DISPLAY
      X_pscript-ruleset.script-name FORMAT "X(255)" WIDTH 45 COLUMN-LABEL "Скрипт"
entry(1, X_prop-script.script-value-type) FORMAT "X(12)" WIDTH 45 COLUMN-LABEL "Тип знач"
(IF num-entries(X_prop-script.script-value-type) > 1
 THEN entry(2, X_prop-script.script-value-type)
 ELSE '':U) FORMAT "X(12)"                           COLUMN-LABEL "Тип объ"
X_ruledict.script-nl FORMAT "X(255)" WIDTH 45 COLUMN-LABEL "Скрипт"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.8 FIT-LAST-COLUMN.

DEFINE BROWSE br-variable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-variable Dialog-Frame _FREEFORM
  QUERY br-variable DISPLAY
      bufv_tt-rule-i-script.script-name FORMAT "X(32)" COLUMN-LABEL "Имя переменной"
bufv_tt-rule-i-script.script-TYPE FORMAT "X(20)" COLUMN-LABEL "Тип переменной"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52 BY 13.8 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-complex AT ROW 2.57 COL 57 WIDGET-ID 40
     b-quit AT ROW 1 COL 11
     RS-language AT ROW 1 COL 30 NO-LABEL WIDGET-ID 2
     B-Help AT ROW 1 COL 54.9
     cb-pscript-ruleset AT ROW 4 COL 1 NO-LABEL WIDGET-ID 46
     br-variable AT ROW 4 COL 1 WIDGET-ID 400
     br-parameter AT ROW 4 COL 1 WIDGET-ID 500
     br-operator AT ROW 4 COL 1 WIDGET-ID 200
     br-dtruledict AT ROW 4 COL 1 WIDGET-ID 300
     br-complex AT ROW 4 COL 1 WIDGET-ID 600
     br-pscript-ruleset AT ROW 5 COL 1 WIDGET-ID 100
     b-defvariable AT ROW 2.57 COL 71 WIDGET-ID 22
     B-operator AT ROW 2.57 COL 15 WIDGET-ID 16
     b-parameter AT ROW 2.57 COL 43 WIDGET-ID 34
     B-prop-script AT ROW 2.57 COL 1 WIDGET-ID 14
     b-variable AT ROW 2.57 COL 29 WIDGET-ID 28
     f-prop-script AT ROW 2.93 COL 2.5 NO-LABEL WIDGET-ID 18
     F-operator AT ROW 2.93 COL 16.5 NO-LABEL WIDGET-ID 20
     f-variable AT ROW 2.93 COL 30.5 NO-LABEL WIDGET-ID 26
     f-parameter AT ROW 2.93 COL 44.5 NO-LABEL WIDGET-ID 36
     f-complex AT ROW 2.93 COL 58.5 NO-LABEL WIDGET-ID 42
     f-defvariable AT ROW 2.93 COL 72.5 NO-LABEL WIDGET-ID 24
     SPACE(15.59) SKIP(19.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit DROP-TARGET.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-loc-rule-i-script T "?" NO-UNDO ub rule-i-script
      TABLE: tt-rule T "SHARED" NO-UNDO ub rule
      ADDITIONAL-FIELDS:
          field level as integer
      END-FIELDS.
      TABLE: tt-rule-i-script T "SHARED" NO-UNDO ub rule-i-script
      TABLE: tt-rule-script T "SHARED" NO-UNDO ub rule-script
      ADDITIONAL-FIELDS:
          field level as integer
          field gen-order as character
          field upper_rule_id as integer
      END-FIELDS.
      TABLE: tt-ruledict-param T "SHARED" NO-UNDO ub ruledict-param
      TABLE: X_dtruledict B "?" ? ub ruledict
      TABLE: X_prop-script B "?" ? ub prop-script
      TABLE: X_pscript-ruleset B "?" ? ub pscript-ruleset
      TABLE: X_rule-i-script B "?" ? ub rule-i-script
      TABLE: X_ruledict B "?" ? ub ruledict
      TABLE: X_ruleset B "?" ? ub ruleset
      TABLE: Y_prop-script B "?" ? ub prop-script
      TABLE: Y_pscript-ruleset B "?" ? ub pscript-ruleset
      TABLE: Y_ruledict B "?" ? ub ruledict
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-variable cb-pscript-ruleset Dialog-Frame */
/* BROWSE-TAB br-parameter br-variable Dialog-Frame */
/* BROWSE-TAB br-operator br-parameter Dialog-Frame */
/* BROWSE-TAB br-dtruledict br-operator Dialog-Frame */
/* BROWSE-TAB br-complex br-dtruledict Dialog-Frame */
/* BROWSE-TAB br-pscript-ruleset br-complex Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR COMBO-BOX cb-pscript-ruleset IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-complex IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-defvariable IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN F-operator IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-parameter IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-prop-script IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-variable IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-complex
/* Query rebuild information for BROWSE br-complex
     _START_FREEFORM
OPEN QUERY br-complex FOR EACH tt-complex.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-complex */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dtruledict
/* Query rebuild information for BROWSE br-dtruledict
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_dtruledict NO-LOCK
WHERE X_dtruledict.entry-type = {&rdict-etype-datatype}
INDEXED-REPOSITION .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-dtruledict */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-operator
/* Query rebuild information for BROWSE br-operator
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH Y_ruledict NO-LOCK WHERE
     (Y_ruledict.ENTRY-TYPE = {&rdict-etype-operator}
      OR
      Y_ruledict.ENTRY-TYPE = {&rdict-etype-constant}
      OR
      Y_ruledict.ENTRY-TYPE = {&rdict-etype-datatype}
      OR
      Y_ruledict.ENTRY-TYPE = {&rdict-etype-control}
      )
.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-operator */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parameter
/* Query rebuild information for BROWSE br-parameter
     _START_FREEFORM
OPEN QUERY br-parameter FOR EACH tt-ruledict-param.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-parameter */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-pscript-ruleset
/* Query rebuild information for BROWSE br-pscript-ruleset
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH X_prop-script NO-LOCK where
       X_prop-script.dtm-code = integer(cb-pscript-ruleset),
    FIRST X_pscript-ruleset NO-LOCK WHERE
     X_pscript-ruleset.codex_id = p-codex-id
    AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)
    AND  X_prop-script.language = X_pscript-ruleset.LANGUAGE
    AND  X_prop-script.script-name = X_pscript-ruleset.script-name
    AND  X_prop-script.revis_id = X_pscript-ruleset.revis_id,
    FIRST X_ruledict NO-LOCK WHERE
     X_ruledict.ENTRY-TYPE = {&rdict-etype-prop-script}
AND  X_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-pscript-ruleset */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-variable
/* Query rebuild information for BROWSE br-variable
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH bufv_tt-rule-i-script NO-LOCK
WHERE bufv_tt-rule-i-script.root_rule_id = p-root-rule-id
 AND bufv_tt-rule-i-script.i-script-type = {&prop-script-type-variable} INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-variable */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame
DO:
  RUN proc-undo IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame
DO:
RUN proc-undo IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-complex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-complex Dialog-Frame
ON CHOOSE OF b-complex IN FRAME Dialog-Frame
DO:
run proc-init-b-complex in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-defvariable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-defvariable Dialog-Frame
ON CHOOSE OF b-defvariable IN FRAME Dialog-Frame
DO:
run proc-init-b-defvariable in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-operator Dialog-Frame
ON CHOOSE OF B-operator IN FRAME Dialog-Frame
DO:
run proc-init-b-operator in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parameter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parameter Dialog-Frame
ON CHOOSE OF b-parameter IN FRAME Dialog-Frame
DO:
run proc-init-b-parameter in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prop-script
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prop-script Dialog-Frame
ON CHOOSE OF B-prop-script IN FRAME Dialog-Frame /* 1.Перемещ. */
DO:
   run proc-init-b-prop-script in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-variable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-variable Dialog-Frame
ON CHOOSE OF b-variable IN FRAME Dialog-Frame
DO:
run proc-init-b-variable in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-complex
&Scoped-define SELF-NAME br-complex
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-complex Dialog-Frame
ON DEFAULT-ACTION OF br-complex IN FRAME Dialog-Frame
DO:
    IF AVAILABLE tt-complex THEN DO:
      RUN create-tt-complex IN THIS-PROCEDURE ( rs-language
                                              ,BUFFER tt-complex
                                              ) NO-ERROR.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dtruledict
&Scoped-define SELF-NAME br-dtruledict
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dtruledict Dialog-Frame
ON DEFAULT-ACTION OF br-dtruledict IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_dtruledict THEN DO:
    RUN create-datatype IN THIS-PROCEDURE ( INPUT rs-language
                                            ,BUFFER X_dtruledict) NO-ERROR.
    if error-status:error then do:
      apply "End-error" to frame {&frame-name}  .
    end.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-operator
&Scoped-define SELF-NAME br-operator
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-operator Dialog-Frame
ON DEFAULT-ACTION OF br-operator IN FRAME Dialog-Frame
DO:
  IF AVAILABLE Y_ruledict THEN DO:
    RUN create-operator IN THIS-PROCEDURE ( INPUT rs-language
                                            ,BUFFER Y_ruledict) NO-ERROR.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parameter
&Scoped-define SELF-NAME br-parameter
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parameter Dialog-Frame
ON DEFAULT-ACTION OF br-parameter IN FRAME Dialog-Frame
DO:
    IF AVAILABLE tt-ruledict-param THEN DO:
      RUN create-parameter IN THIS-PROCEDURE ( rs-language
                                              ,BUFFER tt-ruledict-param)
                                               NO-ERROR.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-pscript-ruleset
&Scoped-define SELF-NAME br-pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-pscript-ruleset Dialog-Frame
ON DEFAULT-ACTION OF br-pscript-ruleset IN FRAME Dialog-Frame
DO:
    IF AVAILABLE X_prop-script THEN DO:
      RUN create-prop-script IN THIS-PROCEDURE ( rs-language
                                              ,BUFFER X_prop-script
                                              ,BUFFER X_ruledict) NO-ERROR.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-variable
&Scoped-define SELF-NAME br-variable
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-variable Dialog-Frame
ON DEFAULT-ACTION OF br-variable IN FRAME Dialog-Frame
DO:
    IF AVAILABLE bufv_tt-rule-i-script THEN DO:
      RUN create-variable IN THIS-PROCEDURE ( INPUT rs-language
                                              ,BUFFER bufv_tt-rule-i-script
                                              ) NO-ERROR.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-pscript-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-pscript-ruleset Dialog-Frame
ON VALUE-CHANGED OF cb-pscript-ruleset IN FRAME Dialog-Frame
DO:
  ASSIGN cb-pscript-ruleset.
  {&OPEN-QUERY-br-pscript-ruleset}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-language
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-language Dialog-Frame
ON VALUE-CHANGED OF RS-language IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-language.
  RUN proc-vc-language IN THIS-PROCEDURE ( INPUT rs-language).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-complex
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON DELETE-CHARACTER anywhere
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_tt-widget FOR tt-widget.
  MESSAGE
  "Удалить все выделенные куски?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog  THEN RETURN NO-APPLY.

  FOR EACH buf_tt-widget
  ON error undo, return no-apply
  :
     IF buf_tt-widget.HANDLE:SELECTED THEN DO:
         RUN proc-delete IN THIS-PROCEDURE ( BUFFER buf_tt-widget).
     END.
  END.
END.

ON mouse-menu-click anywhere
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_tt-widget FOR tt-widget.
  MESSAGE
  "Сгруппировать все выделенные куски?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog  THEN RETURN NO-APPLY.
  RUN proc-mouse-menu-click IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

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
  if p-mode <> {&add-def}
  and p-mode <> {&update} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-mode" p-mode
    view-as alert-box error .
    undo, return error .
  end.
  RUN fill-tables IN THIS-PROCEDURE no-error.
  if error-status:error then do:
    undo, return error return-value .
  end.
  RUN Myenable in this-procedure no-error  .
  if error-status:error then do:
    undo, return error return-value .
  end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
FOR EACH tt-widget:
  IF VALID-HANDLE(tt-widget.HANDLE_) THEN DO:
    DELETE WIDGET tt-widget.HANDLE_.
  END.
  DELETE tt-widget.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-script-type-cond Dialog-Frame
PROCEDURE check-script-type-cond :
DEFINE output PARAMETER p-script-al AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE variable v-script-al AS CHARACTER NO-UNDO.
DEFINE variable v-script-al-subs AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
FOR EACH buf_tt-widget
BY buf_tt-widget.right-bottom
    : /*
    message
    buf_tt-widget.row_   skip
    buf_tt-widget.column_  skip
    buf_tt-widget.right-bottom skip buf_tt-widget.script-al view-as alert-box .*/
   ASSIGN
   p-script-al = substitute("&1 &2"
                            ,p-script-al
                            ,buf_tt-widget.script-al)
   v-script-al = substitute("&1 &2"
                              ,v-script-al
                              ,SUBSTITUTE-value-type (buf_tt-widget.script-value-type, buffer buf_tt-widget)
                                )
   p-script-nl = substitute("&1 &2"
                              ,p-script-nl
                              ,buf_tt-widget.script-nl
                              ).
   .
   message buf_tt-widget.script-al skip
   v-script-al
    view-as alert-box .
END.
MESSAGE p-script-al SKIP "from check-script-type-cond"
skip v-script-al
VIEW-AS ALERT-BOX.
define variable v-sub-number as integer no-undo .
IF real-INDEX(p-script-al, "&", 1, output v-sub-number) > 0  THEN DO:
  MESSAGE
  "Подставлены не все параметры!"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
run rul/check-expr-by-query.p ( INPUT v-script-al
                               ,OUTPUT glog) NO-ERROR.
IF NOT glog THEN DO:
  MESSAGE
  "Выражение сформулировано неверно!"
  VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-script-type-cons Dialog-Frame
PROCEDURE check-script-type-cons :
DEFINE output PARAMETER p-script-al AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-first AS LOGICAL NO-UNDO INIT YES.
DEFINE VARIABLE v-is-void AS LOGICAL NO-UNDO INIT YES.
DEFINE variable v-script-al AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
FOR EACH buf_tt-widget
BY buf_tt-widget.right-bottom
    :
   IF buf_tt-widget.script-value-type = {&abl-datatype-void} THEN DO:
      IF NOT v-first THEN DO:
        MESSAGE
        "В одной строке может быть только один скрипт типа" {&abl-datatype-void}
        VIEW-AS alert-box ERROR.
        undo, RETURN ERROR.
      END.
      v-is-void = YES.
   END.
   v-first = NO.
   ASSIGN
   p-script-al = substitute("&1 &2"
                              ,p-script-al
                              ,buf_tt-widget.script-al)
   p-script-nl = substitute("&1 &2"
                              ,p-script-nl
                              ,buf_tt-widget.script-nl
                              )

   v-script-al = substitute("&1 &2"
                              ,p-script-al
                              ,(IF buf_tt-widget.entry-type = {&rdict-etype-prop-script}
                                THEN SUBSTITUTE-value-type (buf_tt-widget.script-value-type, buffer buf_tt-widget)
                                ELSE buf_tt-widget.script-al))
   .
END.
MESSAGE p-script-al "from check-script-type-cons" VIEW-AS ALERT-BOX.
define variable v-sub-number as integer no-undo .
IF real-INDEX(p-script-al, "&", 1, output v-sub-number) > 0  THEN DO:
  MESSAGE
  "Подставлены не все параметры!"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
IF NOT v-is-void  THEN DO:
    run rul/check-expr-by-query.p ( INPUT v-script-al
                                   ,OUTPUT glog) NO-ERROR.
    IF NOT glog THEN DO:
      MESSAGE
      "Выражение сформулировано неверно!"
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
    END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-datatype Dialog-Frame
PROCEDURE create-datatype :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_ruledict FOR ub.ruledict.
DEFINE variable v-ok AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-variable-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-check-name AS CHARACTER NO-UNDO.
define variable v-tbl-row as row no-undo .
define variable v-tbl-name as character no-undo .
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-rule-i-script FOR tt-rule-i-script.
define buffer buf_prop-script for ub.prop-script.
FIND FIRST buf_tt-widget NO-LOCK NO-ERROR .
IF AVAILABLE buf_tt-widget
or p-script-type = {&rule-script-goto}
THEN DO:
  MESSAGE
  "Определение переменной можно поместить только в пустой скрипт типа CONS"
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.
v-format = "X(32)".
run gbl/d-character.w (
      INPUT ?
    , INPUT (
      'title=':u + substitute("Декларирование переменной типа &1", buf_ruledict.script-nl) + '\':u
    + 'text1=':u + "Введите имя переменной" + '\':u
    + 'foemta=' + v-format + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'readonly=' + 'no':u + '\':u)
    , input-output v-variable-name
    , output v-ok
        ).
    if not v-ok then return error.
ASSIGN
v-check-name = TRIM(v-variable-name, "abcdefghijklmnopqrstuvwxyz1234567890-").
IF v-check-name <> '':U
OR lookup(substring(v-variable-name, 1, 1), "0123456789") > 0  THEN DO:
  MESSAGE
  "Имя переменной может содержать только латинские буквы, цифры, символ '-' и начинаться с буквы"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
IF LENGTH(v-variable-name) > 32  THEN DO:
    MESSAGE
    "Имя переменной не может быть длиннее 32 символов"
    VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FIND FIRST buf_tt-rule-i-script NO-LOCK WHERE
          buf_tt-rule-i-script.i-script-type = {&prop-script-type-variable}
     AND  buf_tt-rule-i-script.i-script-name = v-variable-name NO-ERROR.
IF AVAILABLE buf_tt-rule-i-script THEN DO:
    MESSAGE
    "Уже есть переменная с  таким именем"
    VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
/*найдем prop-script класса*/
if lookup(buf_ruledict.script-al, {&ABL-datatype-list}) = 0  then do:
  RUN gen-row-keyr IN THIS-PROCEDURE
    ( input  buf_ruledict.uniq-key-rec
     ,input ?
     ,input "ub":U
     ,input ?
     ,input no-lock
     ,output v-tbl-row
     ,output  v-tbl-name
    ) NO-ERROR.
  if error-status:error then do:
    message
    substitute("Не найден Тип данных &1 (класс)", buf_ruledict.script-al)
    view-as alert-box error .
    undo, return error .
  end.
  if v-tbl-name <> {&table_prop-script} then do:
    message
    substitute("Тип данных &1 в словаре не привязан к классу", buf_ruledict.script-al)
    view-as alert-box error .
    undo, return error .
  end.
  find first buf_prop-script no-lock where
            rowid(buf_prop-script) = v-tbl-row.
end.
ASSIGN
v-script-al = substitute("define variable &1 as &2 &3 no-undo"
                         , v-variable-name
                         , (if lookup(buf_ruledict.script-al, {&ABL-datatype-list}) > 0
                            then '':U
                            else "class")
                         , (if lookup(buf_ruledict.script-al, {&ABL-datatype-list}) > 0
                            then buf_ruledict.script-al
                            else buf_prop-script.script-head)
                         )
v-script-nl = substitute("Декларируем переменную &1 тип &2"
                         , v-variable-name
                         , buf_ruledict.script-nl).
RUN create-widget IN THIS-PROCEDURE (
                                      input (if available buf_prop-script
                                             then buf_prop-script.dtm-code
                                             else 0)
                                     ,input (if available buf_prop-script
                                             then buf_prop-script.class-dtm-code
                                             else 0)
                                     ,INPUT p-language
                                     ,INPUT v-variable-name
                                     ,INPUT v-script-al
                                     ,INPUT v-script-nl
                                     ,INPUT buf_ruledict.entry-type
                                     ,INPUT {&prop-script-type-variable}
                                     ,INPUT {&abl-datatype-void}   /*script-value-type*/
                                     ,INPUT (if lookup(buf_ruledict.script-al, {&ABL-datatype-list}) > 0
                                          then buf_ruledict.script-al
                                          else buf_ruledict.script-al) /*datatype*/
                                     ,input '':U /*proc-type*/
                                     ,input '':U /*uniq-key-rec*/
                                     ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  UNDO, RETURN ERROR.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-operator Dialog-Frame
PROCEDURE create-operator :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_ruledict FOR ub.ruledict.
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-longchar AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-date AS date NO-UNDO.
DEFINE VARIABLE v-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-integer AS integer NO-UNDO.
DEFINE VARIABLE v-logical AS logical NO-UNDO.
DEFINE VARIABLE v-ok AS logical NO-UNDO.
IF buf_ruledict.ENTRY-TYPE = {&rdict-etype-datatype}
THEN DO:
  CASE buf_ruledict.script-al:
    WHEN {&abl-datatype-character} THEN DO:
       run gbl/d-character.w (
                               INPUT ? /*h-callback*/
                              ,INPUT '':U      /*p-parameters*/
                              ,input-output v-character
                              ,output v-ok
                               ) NO-ERROR.
       IF ERROR-STATUS:ERROR
       OR NOT v-ok THEN undo, RETURN error.
       ASSIGN
       v-script-al = substitute('"&1"', v-character)
       v-script-nl = substitute('"&1"', v-character)
       .
    END.
    WHEN {&abl-datatype-longchar} THEN DO:
       run gbl/d-longchar.w (
                               INPUT ? /*h-callback*/
                              ,INPUT '':U      /*p-parameters*/
                              ,input-output v-longchar
                              ,output v-ok
                               ) NO-ERROR.
       IF ERROR-STATUS:ERROR
       OR NOT v-ok THEN undo, RETURN error.
       ASSIGN
       v-script-al = substitute('"&1"', v-longchar)
       v-script-nl = substitute('"&1"', v-longchar)
       v-longchar = '':U
       .
    END.
    WHEN {&abl-datatype-date} THEN DO:
        v-format = "99/99/9999".
      run gbl/d-inpday.w
        (input ?                  /* h-callback    */
        ,input "Календарь"        /* p-title       */
        ,input ""                 /* p-description */
        ,input ""                 /* p-mode        */
        ,input-output v-date      /* p-date        */
        ,output v-ok              /* p-ok          */
        ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR NOT v-ok THEN undo, RETURN error.
      ASSIGN
      v-script-al = substitute('&1', string(v-date, "99/99/9999"))
      v-script-nl = substitute('&1', string(v-date, "99/99/9999"))
      .

    END.
    WHEN {&abl-datatype-decimal} THEN DO:
        v-format = "->>>,>>>,>>9.999".
        run gbl/d-decimal.w (
                                INPUT ? /*h-callback*/
                               ,INPUT ('format=' + v-format + '\':u
                                       )                                /*p-parameters*/
                                 , input-output v-decimal
                                 , output v-ok
                                     ) NO-ERROR.
        IF ERROR-STATUS:ERROR
        OR NOT v-ok THEN undo, RETURN error.
        ASSIGN
        v-script-al = substitute('&1', string(v-decimal))
        v-script-nl = substitute('&1', string(v-decimal))
        .

    END.
    WHEN {&abl-datatype-integer} THEN DO:
        v-format = "->>>,>>>,>>9".
        run gbl/d-integer.w (
                                INPUT ? /*h-callback*/
                               ,INPUT ('format=' + v-format + '\':u
                                         )                                /*p-parameters*/
                                 , input-output v-integer
                                 , output v-ok
                                     ) NO-ERROR.
        ASSIGN
        v-script-al = substitute('&1', string(v-integer))
        v-script-nl = substitute('&1', string(v-integer))
        .
    END.
    WHEN {&abl-datatype-logical} THEN DO:
        v-format = "+/".
        run gbl/d-logical.w (
                                INPUT ? /*h-callback*/
                               ,INPUT ('format=' + v-format + '\':u
                                 )                                /*p-parameters*/
                                 , input-output v-logical
                                 , output v-ok
                                     ) NO-ERROR.
        ASSIGN
        v-script-al = substitute('&1', string(v-logical))
        v-script-nl = substitute('&1', string(v-logical))
        .
    END.
  END CASE.
  message v-script-al view-as alert-box .
END.
ELSE DO:
  ASSIGN
  v-script-nl = buf_ruledict.script-nl
  v-script-al = buf_ruledict.script-al
  .
END.
RUN create-widget IN THIS-PROCEDURE ( INPUT 0 /*p-dtm-code*/
                                     ,input 0 /*p-class-dtm-code*/
                                     ,INPUT p-language
                                     ,INPUT v-script-al
                                     ,INPUT v-script-al
                                     ,INPUT v-script-nl
                                     ,INPUT (IF buf_ruledict.entry-type = {&rdict-etype-control}
                                             or buf_ruledict.entry-type = {&rdict-etype-operator}
                                             THEN buf_ruledict.entry-type
                                             ELSE '':U)
                                     ,INPUT '':U /*p-script-type*/
                                     ,INPUT '':u
                                     ,INPUT (IF buf_ruledict.entry-type = {&rdict-etype-datatype}
                                             THEN buf_ruledict.script-al
                                             ELSE '':U) /*script-value-type*/
                                     ,input '':U /*proc-type*/
                                     ,input buf_ruledict.uniq-key-rec /*uniq-key-rec*/
                                                 ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-parameter Dialog-Frame
PROCEDURE create-parameter :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
RUN create-widget IN THIS-PROCEDURE ( INPUT 0 /*p-dtm-code*/
                                     ,INPUT 0 /*p-class-dtm-code*/
                                     ,INPUT p-language
                                     ,INPUT buf_tt-ruledict-param.param-name
                                     ,INPUT buf_tt-ruledict-param.param-name
                                     ,INPUT buf_tt-ruledict-param.param-label
                                     ,INPUT {&rdict-etype-parameter} /*p-entry-type*/
                                     ,INPUT '':U /*p-script-type*/
                                     ,INPUT buf_tt-ruledict-param.param-data-type
                                     ,INPUT buf_tt-ruledict-param.param-data-type
                                     ,input '':U /*proc-type*/
                                     ,input '':U /*uniq-key-rec*/
                                         ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-prop-script Dialog-Frame
PROCEDURE create-prop-script :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_prop-script FOR ub.prop-script.
DEFINE parameter BUFFER buf_ruledict FOR ub.ruledict.
DEFINE VARIABLE v-object-type AS CHARACTER NO-UNDO.
IF LOOKUP(buf_prop-script.proc-type, {&script-class-child-list}) > 0  THEN DO:
  v-object-type = trim(entry(2, buf_prop-script.script-body, {&space-char}), ".").
  v-object-type = ENTRY(NUM-ENTRIES(v-object-type, "."), v-object-type, ".").
END.
ELSE DO:
  v-object-type = buf_prop-script.script-value-type.
END.
RUN create-widget IN THIS-PROCEDURE ( INPUT buf_prop-script.dtm-code
                                     ,INPUT buf_prop-script.class-dtm-code
                                     ,INPUT p-language
                                     ,INPUT buf_prop-script.script-name
                                     ,INPUT buf_prop-script.script-name
                                     ,INPUT buf_ruledict.script-nl
                                     ,INPUT {&rdict-etype-prop-script} /*p-entry-type*/
                                     ,INPUT buf_prop-script.script-type /*p-script-type*/
                                     ,INPUT buf_prop-script.script-value-type
                                     ,INPUT v-object-type
                                     ,input buf_prop-script.proc-type /*proc-type*/
                                     ,input buf_prop-script.uniq-key-rec
                                     ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-rule-i-script Dialog-Frame
PROCEDURE create-rule-i-script :
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
define input parameter p-class-dtm-code as integer no-undo .
DEFINE INPUT PARAMETER p-i-script-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-i-script-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS CHARACTER NO-UNDO.
define input parameter p-subsid as logical no-undo .

DEFINE VARIABLE v-sub-object AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-script FOR ub.prop-script.
DEFINE BUFFER buf_tt-loc-rule-i-script FOR tt-loc-rule-i-script.

do
on error undo, return error
:
  IF p-i-script-type = {&prop-script-type-variable}
  and not p-subsid
  THEN DO:
      find first buf_tt-loc-rule-i-script where
                buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            and buf_tt-loc-rule-i-script.script-name = p-script-name no-error.
        if not available buf_tt-loc-rule-i-script then do:
          if lookup(p-script-type, {&abl-datatype-list}) = 0 then do:
            find first buf_prop-script no-lock where
                    buf_prop-script.language = 'ABL'
                and buf_prop-script.script-name = p-script-type
                and buf_prop-script.dtm-code = p-dtm-code
                and buf_prop-script.proc-type = {&script-ptype-class} no-error.
            if not available buf_prop-script then do:
              message
              substitute("Не найден класс типа &1", p-script-type)
              view-as alert-box error .
              undo, return error .
            end.
          end.
          create buf_tt-loc-rule-i-script.
          assign
          buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
          buf_tt-loc-rule-i-script.i-script-type = p-i-script-type
          buf_tt-loc-rule-i-script.i-script-name = p-I-script-name
          buf_tt-loc-rule-i-script.script-type = p-script-type
          buf_tt-loc-rule-i-script.script-name = p-script-name
          buf_tt-loc-rule-i-script.dtm-code = (if available buf_prop-script
                                               then buf_prop-script.dtm-code
                                               else 0)
          buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
          buf_tt-loc-rule-i-script.revis_id = (if available buf_prop-script
                                               then buf_prop-script.revis_id
                                               else 0)
          buf_tt-loc-rule-i-script.script_id = p-script-id
          .
        end.
  END.
  ELSE DO:
    if p-subsid = no then do:
      find first buf_prop-script no-lock where
                buf_prop-script.dtm-code = p-dtm-code
            and buf_prop-script.class-dtm-code = p-class-dtm-code
            and buf_prop-script.language = 'ABL'
            and buf_prop-script.script-name = p-script-name no-error.
      if not available buf_prop-script then do:
        message
        "not available buf_prop-script"
        p-script-name p-dtm-code  ("l" + p-script-type + "@") p-i-script-type
        view-as alert-box .
        UNDO, RETURN ERROR.
      end.
      find first buf_tt-loc-rule-i-script where
              buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
          and buf_tt-loc-rule-i-script.i-script-name = p-i-script-name
          AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
      if not available buf_tt-loc-rule-i-script then do:
        create buf_tt-loc-rule-i-script.
        assign
        buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
        buf_tt-loc-rule-i-script.i-script-type = p-i-script-type
        buf_tt-loc-rule-i-script.i-script-name = p-i-script-name
        buf_tt-loc-rule-i-script.script-type = p-script-type
        buf_tt-loc-rule-i-script.script-name = p-script-name
        buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
        buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
        buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
        buf_tt-loc-rule-i-script.script_id = p-script-id
        .
      end.
      v-sub-object = entry(1, p-script-name, '@').
      if p-dtm-code > 0
      AND lookup(buf_prop-script.proc-type, {&script-class-child-list}) = 0  then do:
        if buf_prop-script.script-type = {&prop-script-type-create}
        or buf_prop-script.script-type = {&prop-script-type-find}
        or buf_prop-script.script-type = {&prop-script-type-get}
        or buf_prop-script.script-type = {&prop-script-type-set}
        then do:
          assign
          v-sub-object   = substring(v-sub-object, index(v-sub-object,'_':U) + 1)
          .
          find first buf_tt-loc-rule-i-script where
                    buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
                and buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
                and buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
                and buf_tt-loc-rule-i-script.i-script-type = {&prop-script-type-define-b}
                and buf_tt-loc-rule-i-script.script-name = ('buf_':U + v-sub-object )
                AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
          if not available buf_tt-loc-rule-i-script then do:
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = {&prop-script-type-define-b}
            buf_tt-loc-rule-i-script.i-script-name = 'buf_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = {&prop-script-type-define-b}
            buf_tt-loc-rule-i-script.script-name = 'buf_':U + v-sub-object
            buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = {&prop-script-type-define-tt}
            buf_tt-loc-rule-i-script.i-script-name = 'buft_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = {&prop-script-type-define-tt}
            buf_tt-loc-rule-i-script.script-name = 'buft_':U + v-sub-object
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
          end.
          find first buf_tt-loc-rule-i-script where
                    buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
                and buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
                and buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
                and buf_tt-loc-rule-i-script.i-script-type = 'define_h'
                and buf_tt-loc-rule-i-script.script-name = ('vh_':U + v-sub-object)
                AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
          if not available buf_tt-loc-rule-i-script then do:
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = {&prop-script-type-define-h}
            buf_tt-loc-rule-i-script.i-script-name = 'vh_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = {&prop-script-type-define-h}
            buf_tt-loc-rule-i-script.script-name = 'vh_':U + v-sub-object
            buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
          end.
        end.
        v-sub-object = entry(1, p-script-name, '@').
        if buf_prop-script.script-type = {&prop-script-type-create}
        or buf_prop-script.script-type = {&prop-script-type-set}
        then do:
          assign
          v-sub-object   = substring(v-sub-object, index(v-sub-object,'_':U) + 1)
          .
          find first buf_tt-loc-rule-i-script where
                    buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
                and buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
                and buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
                and buf_tt-loc-rule-i-script.i-script-type = 'hist-nws'
                and buf_tt-loc-rule-i-script.script-name = ('hist-nws_':U + v-sub-object)
                AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
          if not available buf_tt-loc-rule-i-script then do:
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = 'hist-nws'
            buf_tt-loc-rule-i-script.i-script-name = 'hist-nws_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = 'hist-nws'
            buf_tt-loc-rule-i-script.script-name = 'hist-nws_':U + v-sub-object
            buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
          end.
        end. /*if buf_prop-script.script-type = {&prop-script-type-create}*/
      end.
    end. /*if subsid = no*/
    else do:
      define variable v-tbl-row as rowid no-undo .
      define variable v-tbl-name as character no-undo .
      run gen-row-keyr in this-procedure
        ( input  p-i-script-name
         ,input ?
         ,input "ub"
         ,input ?
         ,input no-lock
         ,output v-tbl-row
         ,output v-tbl-name
        ).
      find first buf_prop-script where
              rowid(buf_prop-script) = v-tbl-row.
      find first buf_tt-loc-rule-i-script where
              buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
          and buf_tt-loc-rule-i-script.i-script-name = buf_prop-script.script-foot
          AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
      if not available buf_tt-loc-rule-i-script then do:
        create buf_tt-loc-rule-i-script.
        assign
        buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
        buf_tt-loc-rule-i-script.i-script-type = {&prop-script-type-ifunction}
        buf_tt-loc-rule-i-script.i-script-name = buf_prop-script.script-foot
        buf_tt-loc-rule-i-script.script-type = '':U
        buf_tt-loc-rule-i-script.script-name = replace(buf_prop-script.script-foot
                                                     , "&" + substitute("&1", p-script-type)
                                                     , p-script-name)
        buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
        buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
        buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
        buf_tt-loc-rule-i-script.script_id = p-script-id
        .
      end.
      else do:
        assign
        buf_tt-loc-rule-i-script.script-type = '':U
        buf_tt-loc-rule-i-script.script-name = replace(buf_tt-loc-rule-i-script.script-name
                                                     , "&" + substitute("&1", p-script-type)
                                                     , p-script-name)
        .
      end.
    end.
  END.
end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-tt-complex Dialog-Frame
PROCEDURE create-tt-complex :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE PARAMETER BUFFER buf_tt-complex FOR tt-complex.
DEFINE VARIABLE v-object-type AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-script FOR ub.prop-script.
IF LOOKUP(buf_tt-complex.proc-type, {&script-class-child-list}) > 0  THEN DO:
  FIND FIRST buf_prop-script NO-LOCK WHERE
            buf_prop-script.dtm-code = buf_tt-complex.class-dtm-code
      AND   buf_prop-script.script-name = buf_tt-complex.script-name.
END.
ELSE DO:
  v-object-type = buf_tt-complex.script-value-type.
END.


RUN create-widget IN THIS-PROCEDURE ( INPUT buf_tt-complex.dtm-code /*p-dtm-code*/
                                     ,INPUT buf_tt-complex.class-dtm-code /*p-dtm-code*/
                                     ,INPUT p-language
                                     ,INPUT buf_tt-complex.script-name
                                     ,INPUT buf_tt-complex.script-al
                                     ,INPUT buf_tt-complex.script-nl
                                     ,INPUT buf_tt-complex.entry-type /*p-entry-type*/
                                     ,INPUT buf_tt-complex.script-type /*p-script-type*/
                                     ,INPUT buf_tt-complex.script-value-type
                                     ,INPUT v-object-type
                                     ,input buf_tt-complex.proc-type /*proc-type*/
                                     ,input '':U /*uniq-key-rec*/
                                     ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-variable Dialog-Frame
PROCEDURE create-variable :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_tt-loc-rule-i-script FOR tt-rule-i-script.
RUN create-widget IN THIS-PROCEDURE ( INPUT buf_tt-loc-rule-i-script.dtm-code /*p-dtm-code*/
                                     ,INPUT buf_tt-loc-rule-i-script.class-dtm-code /*p-dtm-code*/
                                     ,INPUT p-language
                                     ,INPUT buf_tt-loc-rule-i-script.i-script-name
                                     ,INPUT buf_tt-loc-rule-i-script.script-name
                                     ,INPUT buf_tt-loc-rule-i-script.script-name
                                     ,INPUT '':U /*p-entry-type*/
                                     ,INPUT {&prop-script-type-variable} /*p-script-type*/
                                     ,INPUT buf_tt-loc-rule-i-script.script-type
                                     ,INPUT buf_tt-loc-rule-i-script.script-type
                                     ,input '':U /*proc-type*/
                                     ,input '':U /*uniq-key-rec*/
                                     ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-widget Dialog-Frame
PROCEDURE create-widget :
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-class-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-al AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-nl AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-entry-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-value-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-DATA-type AS CHARACTER NO-UNDO.
define input parameter p-proc-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
DEFINE VARIABLE v-len AS INTEGER NO-UNDO.
DEFINE VARIABLE v-color AS INTEGER NO-UNDO.
DEFINE VARIABLE v-widget-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ano-script-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ano-script-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-index-al AS INTEGER NO-UNDO.
DEFINE VARIABLE v-index-nl AS INTEGER NO-UNDO.
DEFINE VARIABLE v-in-script AS logical NO-UNDO.
DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
define variable glog as logical no-undo .
define variable v-sub-number as integer no-undo .
define variable v-main-sub-number as integer no-undo .
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER last_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-widget-child FOR tt-widget-child.
RUN debug-proc( INPUT "kk.txt").
FOR EACH buf_tt-widget:
  IF buf_tt-widget.HANDLE_:SELECTED = YES
  and buf_tt-widget.script-type = {&prop-script-type-variable}
  and lookup(p-proc-type, {&script-class-child-list}) > 0
  and (buf_tt-widget.data-type = p-data-type
        or
        buf_tt-widget.class-dtm-code = p-class-dtm-code)
  then do:
    message
    substitute("Использовать объект &1 в скрипте?", buf_tt-widget.script-al)
    view-as alert-box question buttons yes-no update glog.
    if not glog then next.
    entry(1, p-script-al, ':') = buf_tt-widget.script-al.
    entry(1, p-script-nl, ':') = buf_tt-widget.script-nl.
    RUN proc-delete IN THIS-PROCEDURE ( BUFFER buf_tt-widget).
    leave.
  end.
END.
FOR EACH buf_tt-widget:
  IF buf_tt-widget.HANDLE_:SELECTED = YES
  AND real-index(buf_tt-widget.script-al, "&", 1, output v-sub-number) > 0  THEN DO:
     /*найдем первый &*/
     v-index-al = real-index(buf_tt-widget.script-al, "&", 1, v-main-sub-number).
     v-index-nl = real-index(buf_tt-widget.script-nl, "&", 1, v-sub-number).
     FIND FIRST buf_tt-widget-child WHERE
                buf_tt-widget-child.num_ = buf_tt-widget.num_
           AND  buf_tt-widget-child.position-al = v-index-al NO-ERROR.
     IF NOT AVAILABLE buf_tt-widget-child THEN UNDO, RETURN ERROR.
     IF right-trim(buf_tt-widget-child.param-data-type, {&comma-char}) <> trim(p-data-type, {&comma-char})
     AND right-trim(buf_tt-widget-child.param-data-type, {&Comma-char}) <> trim(entry(1, p-data-type, {&comma-char}))
     and not (p-data-type = "-" and buf_tt-widget-child.param-data-type = {&abl-datatype-void})
     THEN DO:
        MESSAGE
        substitute("Вставляемый скрипт &1 имеет тип данных <&2>&3" +
                   "А параметр &4 - имеет тип данных <&5>&3" +
                   "Продолжить?"
                   ,p-script-al
                   ,p-data-type
                   ,{&NEW-LINE}
                   ,buf_tt-widget-child.param-name
                   ,buf_tt-widget-child.param-data-type)
        VIEW-AS ALERT-BOX question buttons yes-no update glog.
        if not glog then next.
     END.
     v-level = buf_tt-widget-child.level_ + 1.
     v-widget-num = buf_tt-widget.num_.
     ASSIGN
     buf_tt-widget-child.script-al = p-script-al
     buf_tt-widget-child.script-nl = p-script-nl
     buf_tt-widget.script-al = substring(buf_tt-widget.script-al, 1, v-index-al - 1) +
                               p-script-al +
                               substring(buf_tt-widget.script-al, v-index-al + 2)

     buf_tt-widget.script-nl = substring(buf_tt-widget.script-nl, 1, v-index-nl - 1) +
                               p-script-nl +
                                  substring(buf_tt-widget.script-nl, v-index-nl + 2).
    FOR EACH buf_tt-widget-child WHERE
            buf_tt-widget-child.num_ = buf_tt-widget.num_:
       ASSIGN
       buf_tt-widget-child.position-al = (IF buf_tt-widget-child.position-al > v-index-al
                                          THEN buf_tt-widget-child.position-al + LENGTH(p-script-al) - 2
                                          ELSE   buf_tt-widget-child.position-al)
       buf_tt-widget-child.position-nl = (IF buf_tt-widget-child.position-nl > v-index-nl
                                          THEN buf_tt-widget-child.position-nl + LENGTH(p-script-nl) - 2
                                          ELSE   buf_tt-widget-child.position-nl)
       .
    END.
    run create-widget-child in this-procedure ( buffer buf_tt-widget
                                              ,INPUT v-level
                                              ,INPUT v-index-al
                                              ,INPUT v-index-nl
                                              ,INPUT p-entry-type
                                              ,INPUT p-script-al
                                              ,input p-script-type
                                              ,output v-sub-number
                                              ).
    if buf_tt-widget.script-type = {&prop-script-type-get-ifunction}
    and v-main-sub-number > 0 then do:
      RUN CREATE-rule-i-script IN THIS-PROCEDURE  ( INPUT buf_tt-widget.dtm-code
                                                  ,input buf_tt-widget.class-dtm-code
                                                  ,INPUT buf_tt-widget.uniq-key-rec /*p-i-script-name*/
                                                  ,INPUT p-script-type  /*p-i-script-type*/
                                                  ,INPUT p-script-al /*script-name*/
                                                  ,INPUT string(v-main-sub-number) /*script-type*/
                                                  ,input yes /*subsid*/ ) NO-ERROR.
      IF error-status:error tHEN DO:
        UNDO, return ERROR.
      END.
    end.
    ASSIGN
    v-in-script = YES.
    leave.
  END.
END.
IF v-in-script = NO  THEN DO:
  CASE p-entry-type:
    WHEN {&rdict-etype-prop-script} THEN DO:
      v-len = 45.
      v-color = BLUE_COLOR.
    END.
    WHEN {&rdict-etype-operator} THEN DO:
      v-len = 5.
      v-color = BROWN_COLOR.
    END.
    WHEN {&rdict-etype-constant} THEN DO:
        v-len = 5.
        v-color = BROWN_COLOR.
    END.
    WHEN {&rdict-etype-datatype} THEN DO:
      v-len = 40.
      v-color = DARK_GREEn_COLOR.
    END.
    WHEN '-':U THEN DO:
        v-len = 60.
        v-color = BLACK_COLOR.
    END.
    WHEN '':U THEN DO:
      ASSIGN
      v-len = length(p-script-al)
      v-color = BLACK_COLOR
      .
    END.
  END CASE.
  FIND LAST buf_tt-widget NO-ERROR.
  V-WIDGET-NUM = (IF AVAILABLE BUF_TT-widget
                    THEN BUF_TT-WIDGET.NUM_
                    ELSE 0) + 1.
  FIND LAST LAST_tt-widget USE-INDEX irc NO-ERROR.
  IF AVAILABLE LAST_tt-widget THEN DO:
    ASSIGN
    v-current-row = get-current-row(last_tt-widget.right-bottom)
    v-current-column = get-current-column(last_tt-widget.right-bottom)
    .
  END.
  else do:
    ASSIGN
    v-current-row = 18
    v-current-column = 1
    .
  end.
  IF MINIMUM(length(p-script-nl), v-len) + v-current-column + 1 > 98 THEN DO:
    ASSIGN
    v-current-row = v-current-row + 1
    v-current-column = 1
    .
  END.
  CREATE buf_tt-widget.
  assign
  buf_tt-widget.num_ = v-widget-num
  buf_tt-widget.NAME_ = "n" + STRING(buf_tt-widget.num_)
  buf_tt-widget.entry-type = p-entry-type
  buf_tt-widget.script-type = p-script-type
  buf_tt-widget.script-value-type = p-script-value-type
  buf_tt-widget.data-type = p-data-type
  buf_tt-widget.script-nl = p-script-nl
  buf_tt-widget.script-al = p-script-al
  buf_tt-widget.ROW_ = v-current-row
  buf_tt-widget.column_ = v-current-column
  buf_tt-widget.WIDTH_ = MINIMUM(length(buf_tt-widget.script-nl), v-len)
  buf_tt-widget.WIDTH_ = (IF buf_tt-widget.width_ < 5
                          THEN 5
                          ELSE buf_tt-widget.WIDTH_)
  buf_tt-widget.dtm-code = p-dtm-code
  buf_tt-widget.class-dtm-code = p-class-dtm-code
  buf_tt-widget.uniq-key-rec = p-uniq-key-rec
  .
  if real-index(buf_tt-widget.script-nl, "&", 1, v-sub-number) > 0 then do:
     run create-widget-child in this-procedure ( buffer buf_tt-widget
                                                ,INPUT 1
                                                ,INPUT 0
                                                ,INPUT 0
                                                ,INPUT p-entry-type
                                                ,INPUT p-script-name
                                                ,input p-script-type
                                                ,output v-sub-number
                                                ) NO-ERROR.
  end.
end. /*if not v-in-script*/
else do:
end.
FIND FIRST buf_tt-widget WHERE
        buf_tt-widget.num_ = v-widget-num.
IF VALID-HANDLE(buf_tt-widget.HANDLE) THEN
assign
buf_tt-widget.handle_:SCREEN-VALUE = (IF p-language = "ABL"
                                        THEN buf_tt-widget.script-al
                                        ELSE buf_tt-widget.script-nl)
  .
RUN debug-proc( INPUT "jj.txt").
ASSIGN
buf_tt-widget.length_ = maximum(LENGTH(buf_tt-widget.script-nl), LENGTH(buf_tt-widget.script-al))
buf_tt-widget.right-bottom = get-right-bottom(buf_tt-widget.ROW_
                                             ,buf_tt-widget.width_
                                             ,buf_tt-widget.COLUMN_
                                             ,buf_tt-widget.HEIGHT_)
buf_tt-widget.left-top = get-left-top(buf_tt-widget.ROW_
                                             ,buf_tt-widget.width_
                                             ,buf_tt-widget.COLUMN_
                                             ,buf_tt-widget.HEIGHT_)
v-current-row = get-current-row(buf_tt-widget.right-bottom)
v-current-column = get-current-column(buf_tt-widget.right-bottom)
.
if not v-in-script then do:
  create EDITOR buf_tt-widget.HANDLE_
  assign
  frame = frame {&frame-name}:handle
  row = buf_tt-widget.ROW_
  column = buf_tt-widget.COLUMN_
  NAME = buf_tt-widget.NAME_
  scrollbar-vertical = yes
  height-chars = 1
  width-chars = buf_tt-widget.width_
  sensitive = yes
  visible = true
  movable = true
  READ-ONLY = YES
  RESIZABLE = YES
  selectable = YES
  FGCOLOR = v-color
  SCREEN-VALUE = (IF p-language = "ABL"
                  THEN buf_tt-widget.script-al
                  ELSE buf_tt-widget.script-nl)

  FONT = 4
  triggers:
    on END-RESIZE
      persistent run do-not-resize .
    on END-MOVE
      persistent run proc-end-move .
  end triggers.
END. /*if v-in-script = no*/
IF lookup(p-entry-type, {&rdict-etype-constant} + {&comma-char} +
                        {&rdict-etype-operator} + {&comma-char} +
                        {&rdict-etype-control} + {&comma-char} +
                        {&rdict-etype-parameter} + {&comma-char} +
                        "-" + {&comma-char} +
                        "":U) = 0 THEN DO:

    ASSIGN
    v-ano-script-name = p-script-name
    v-ano-script-type = p-DATA-type
    .
    RUN CREATE-rule-i-script IN THIS-PROCEDURE  ( INPUT p-dtm-code
                                                 ,input p-class-dtm-code
                                                 ,INPUT p-script-al /*p-i-script-name*/
                                                 ,INPUT p-script-type  /*p-i-script-type*/
                                                 ,INPUT v-ano-script-name
                                                 ,INPUT v-ano-script-type
                                                 ,input no /*p-subsid*/
                                                 ) NO-ERROR.
    IF error-status:error tHEN DO:
       UNDO, return ERROR.
    END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-widget-child Dialog-Frame
PROCEDURE create-widget-child :
DEFINE PARAMETER BUFFER buf_tt-widget FOR tt-widget.
DEFINE INPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-position-al AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-position-nl AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-entry-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS character NO-UNDO.
define input parameter p-script-type as character no-undo .
define output parameter p-sub-number as integer no-undo .
DEFINE BUFFER buf_tt-widget-child FOR tt-widget-child.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
IF p-entry-type = '-'
OR p-entry-type = {&rdict-etype-parameter}
OR p-entry-TYPE = '':U THEN RETURN.
FIND FIRST buf_ruledict NO-LOCK WHERE
          buf_Ruledict.entry-type = p-entry-type
       AND buf_ruledict.script-al = p-script-name NO-ERROR.
IF not available buf_Ruledict THEN DO:
   UNDO, RETURN ERROR.
END.
FOR EACH buf_tt-widget-child WHERE
       buf_tt-widget-child.num_ = buf_tt-widget.num_
    AND buf_tt-widget-child.level_= p-level:
  DELETE buf_tt-widget-child.
END.
FOR EACH buf_ruledict-param NO-LOCK WHERE
        buf_ruledict-param.entry-id = buf_ruledict.entry-id
    and buf_ruledict-param.param-num > 0:
  CREATE buf_tt-widget-child.
  ASSIGN
  buf_tt-widget-child.num_ = buf_tt-widget.num_
  buf_tt-widget-child.level_ = p-level
  buf_tt-widget-child.param-data-type = buf_ruledict-param.param-data-type
  buf_tt-widget-child.param-2-data-type = buf_ruledict-param.param-2-data-type
  buf_tt-widget-child.param-3-data-type = buf_ruledict-param.param-3-data-type
  buf_tt-widget-child.param-label = buf_ruledict-param.param-label
  buf_tt-widget-child.param-mode = buf_ruledict-param.param-mode
  buf_tt-widget-child.param-name = buf_ruledict-param.param-name
  buf_tt-widget-child.param-num = buf_ruledict-param.param-num
  buf_tt-widget-child.script-nl = '':U
  buf_tt-widget-child.script-al = '':U
  buf_tt-widget-child.entry-id = buf_ruledict-param.entry-id
  buf_tt-widget.script-al-fix = buf_ruledict.script-al
  .
  define variable v-al as integer no-undo .
  define variable v-nl as integer no-undo .
  define variable v-sub-number-al as integer no-undo .
  define variable v-sub-number-nl as integer no-undo .
  ASSIGN
  v-al = real-INDEX(buf_tt-widget.script-al, ("&" + STRING(buf_tt-widget-child.param-num)), 1, output v-sub-number-al)
                                                                        + (IF p-level = 1 THEN 0 ELSE (p-position-al - 1))

  v-nl = real-INDEX(buf_ruledict.script-nl, ("&" + STRING(buf_tt-widget-child.param-num)), 1, output v-sub-number-nl)
                                                                       + (IF p-level = 1 THEN 0 ELSE (p-position-nl - 1))
  .
  if v-sub-number-al > 0
  and p-script-type = {&prop-script-type-get-ifunction}
  then do:
    p-sub-number = v-sub-number-al.
  end.
  assign
  buf_tt-widget-child.position-al = v-al
  buf_tt-widget-child.position-nl = v-nl
  .
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE debug-proc Dialog-Frame
PROCEDURE debug-proc :
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-widget-child FOR tt-widget-child.
OUTPUT TO VALUE(p-file-name).
FOR EACH buf_tt-widget-child:
    EXPORT buf_tt-widget-child.
END.
FOR EACH buf_tt-widget:
    EXPORT buf_tt-widget EXCEPT HANDLE_.
END.
OUTPUT close.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE do-not-resize Dialog-Frame
PROCEDURE do-not-resize :
DEFINE BUFFER buf_tt-widget for tt-widget.
FIND FIRST buf_tt-widget NO-LOCK WHERE
          buf_tt-widget.HANDLE_ = SELF.
ASSIGN
SELF:HEIGHT = 1.5
SELF:WIDTH = MINIMUM(length(SELF:SCREEN-VALUE), 45)
buf_tt-widget.WIDTH_ = SELF:WIDTH
.
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
  DISPLAY RS-language cb-pscript-ruleset f-prop-script F-operator f-variable
          f-parameter f-complex f-defvariable
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-complex b-quit RS-language B-Help cb-pscript-ruleset
         br-variable br-parameter br-operator br-dtruledict br-complex
         br-pscript-ruleset b-defvariable B-operator b-parameter B-prop-script
         b-variable f-prop-script F-operator f-variable f-parameter f-complex
         f-defvariable
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
DEFINE BUFFER buf_tt-loc-rule-i-script FOR tt-loc-rule-i-script.
DEFINE BUFFER buf_tt-rule-i-script FOR tt-rule-i-script.
  FOR EACH buf_tt-loc-rule-i-script:
    delete buf_tt-loc-rule-i-script.
  END.
  if p-mode = {&update} then do:
    FOR EACH buf_tt-rule-i-script NO-LOCK WHERE
              buf_tt-rule-i-script.root_rule_id = p-rule-id
         AND  buf_tt-rule-i-script.script_id = p-script-id:
        CREATE buf_tt-loc-rule-i-script.
        BUFFER-COPY buf_tt-rule-i-script TO buf_tt-loc-rule-i-script.
    END.
    FIND FIRST tt-rule-script WHERE
           tt-rule-script.script_id = p-script-id
        and tt-rule-script.language = "ABL".
    FIND FIRST tt-l_rule-script WHERE
           tt-l_rule-script.script_id = p-script-id
           and tt-l_rule-script.language = "{&language}" .

    FIND FIRST tt-rule WHERE
              tt-rule.RULE_id = p-rule-id.
  end.
  else do:
    FIND FIRST tt-rule WHERE
                  tt-rule.RULE_id = p-rule-id.

    CREATE tt-rule-script.
     ASSIGN
     tt-rule-script.script_id = 0
     tt-rule-script.RULE_id = p-rule-id
     tt-rule-script.root_RULE_id = p-root-rule-id
     tt-rule-script.salience = p-salience
     tt-rule-script.script-type = p-script-type
     tt-rule-script.LANGUAGE = "ABL".
     RELEASE tt-rule-script.
     FIND FIRST tt-rule-script WHERE
              tt-rule-script.script_id = 0
          AND tt-rule-script.LANGUAGE = "ABL".
     CREATE tt-l_rule-script.
     ASSIGN
     tt-l_rule-script.script_id = 0
     tt-l_rule-script.RULE_id = p-rule-id
     tt-l_rule-script.root_RULE_id = p-root-rule-id
     tt-l_rule-script.salience = p-salience
     tt-l_rule-script.script-type = p-script-type
     tt-l_rule-script.LANGUAGE = "{&language}".
     RELEASE tt-l_rule-script.
     FIND FIRST tt-l_rule-script WHERE
              tt-l_rule-script.script_id = 0
         AND tt-l_rule-script.LANGUAGE = "{&language}".

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-dtm-label AS CHARACTER no-undo.
DEFINE BUFFER buf_prop-ruleset FOR ub.prop-ruleset.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
assign
cb-pscript-ruleset:DELIMITER in FRAME {&FRAME-NAME} = "|"
cb-pscript-ruleset:list-item-pairs = "|":U
.
_prop-ruleset:
FOR EACH buf_prop-ruleset NO-LOCK WHERE
        buf_prop-ruleset.codex_id = p-codex-id
BREAK BY buf_prop-ruleset.dtm-code:
   IF first-of(buf_prop-ruleset.dtm-CODE) THEN DO:
     FIND FIRST buf_prop-head NO-LOCK WHERE
                buf_prop-head.dtm-code = buf_prop-ruleset.dtm-code NO-ERROR.
     IF NOT AVAILABLE buf_prop-head THEN DO:
        NEXT _prop-ruleset.
     END.
     v-dtm-label = replace(buf_prop-head.prop-label, "|", {&space-char}).
     cb-pscript-ruleset:ADD-LAST(v-dtm-label, string(buf_prop-ruleset.dtm-code)) IN FRAME {&FRAME-NAME}.
   END.
END.
ASSIGN
cb-pscript-ruleset = "0"
rs-language:radio-buttons in frame {&frame-name} = "ABL" + {&comma-char} + "ABL" + {&comma-char} +
                                                   "{&language}" + {&comma-char} + "{&language}"
X_pscript-ruleset.script-name:RESIZABLE IN BROWSE br-pscript-ruleset =  yes
X_ruledict.script-nl:RESIZABLE IN BROWSE br-pscript-ruleset =  yes
Y_ruledict.script-al:RESIZABLE IN BROWSE br-operator =  yes
Y_ruledict.script-nl:RESIZABLE IN BROWSE br-operator =  yes
tt-complex.script-al:RESIZABLE IN BROWSE br-complex =  yes
tt-complex.script-nl:RESIZABLE IN BROWSE br-complex =  yes
FRAME {&FRAME-NAME}:TITLE = SUBSTITUTE("Скрипт типа &1, номер вышестояшего правила &2, номер корневого правила &3"
                                       , p-script-type
                                       ,p-upper-rule-id
                                       ,p-root-rule-id).
.
DISPLAY
RS-language
b-prop-script
b-operator
b-defvariable WHEn p-script-type <> {&rule-script-COND}
b-variable
b-parameter
b-complex
f-prop-script
f-operator
f-defvariable WHEn p-script-type <> {&rule-script-COND}
f-variable
f-parameter
f-complex
CB-PSCRIPT-RULESET
WITH FRAME {&frame-name}.
ENABLE
B-exit
b-quit
RS-language
B-Help
cb-pscript-ruleset
br-operator
br-pscript-ruleset
b-prop-script
b-operator
b-variable
b-parameter
b-complex
b-defvariable WHEn p-script-type <> {&rule-script-COND}
br-dtruledict WHEn p-script-type <> {&rule-script-COND}
br-variable
br-parameter
br-complex
WITH FRAME {&frame-name}.
APPLY "VALUE-CHANGED" TO rs-language.
APPLY "VALUE-CHANGED" TO cb-pscript-ruleset.
VIEW FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "CHOOSE" TO b-prop-script.
IF p-script-type = {&rule-script-COND} THEN DO:
  HIDE
  br-dtruledict
  f-defvariable
  b-defvariable
  IN FRAME {&FRAME-NAME}.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-delete Dialog-Frame
PROCEDURE proc-delete :
DEFINE PARAMETER BUFFER buf_tt-widget FOR tt-widget.
define buffer buf_tt-complex for tt-complex.
define buffer buf_tt-widget-child for tt-widget-child.
if buf_tt-widget.entry-type = '-' then do:
  for each buf_tt-complex where buf_tt-complex.script-al = buf_tt-widget.script-al:
    delete buf_tt-complex.
  end.
  {&open-query-br-complex}
end.
FOR EACH buf_tt-widget-child WHERE
        buf_tt-widget-child.num_ = buf_tt-widget.num_:
  DELETE buf_tt-widget-child.
END.
DELETE WIDGET buf_tt-widget.HANDLE_.
DELETE buf_tt-widget.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-end-move Dialog-Frame
PROCEDURE proc-end-move :
DEFINE BUFFER buf_tt-widget for tt-widget.
FIND FIRST buf_tt-widget NO-LOCK WHERE
          buf_tt-widget.HANDLE_ = SELF.
ASSIGN
SELF:ROW = ROUND(SELF:ROW, 0)
SELF:column = ROUND(SELF:column, 0)
buf_tt-widget.row_ = SELF:ROW
buf_tt-widget.column_ = SELF:column.
buf_tt-widget.right-bottom = get-right-bottom ( INPUT buf_tt-widget.row_
                                              ,INPUT buf_tt-widget.width_
                                              ,INPUT buf_tt-widget.column_
                                              ,INPUT buf_tt-widget.height_).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-b-complex Dialog-Frame
PROCEDURE proc-init-b-complex :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-complex:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-complex:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-variable:fgcolor = ?
 br-operator:VISIBLE IN FRAME {&FRAME-NAME} = NO
 br-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-dtruledict:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-variable:VISIBLE IN FRAME {&FRAME-NAME}  = NO.
 br-parameter:VISIBLE IN FRAME {&FRAME-NAME}  = NO.
 br-complex:VISIBLE IN FRAME {&FRAME-NAME}  = YES.
 glog = br-complex:MOVE-TO-TOP().
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-b-defvariable Dialog-Frame
PROCEDURE proc-init-b-defvariable :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-defvariable:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-defvariable:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-variable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME {&FRAME-NAME} = NO
 br-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-dtruledict:VISIBLE IN FRAME {&FRAME-NAME} =YES.
 br-variable:VISIBLE IN FRAME {&FRAME-NAME} =NO.
 br-parameter:VISIBLE IN FRAME {&FRAME-NAME} =NO.
 br-complex:VISIBLE IN FRAME {&FRAME-NAME} =NO.
 glog = br-dtruledict:MOVE-TO-TOP().
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-b-operator Dialog-Frame
PROCEDURE proc-init-b-operator :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-operator:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 F-operator:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-variable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME {&FRAME-NAME} = YES
 br-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-dtruledict:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-variable:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-parameter:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-complex:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 glog = browse br-operator:MOVE-TO-TOP().
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-b-parameter Dialog-Frame
PROCEDURE proc-init-b-parameter :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-parameter:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-parameter:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-variable:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME {&FRAME-NAME} = NO
 br-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-dtruledict:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-variable:VISIBLE IN FRAME {&FRAME-NAME}  = NO.
 br-parameter:VISIBLE IN FRAME {&FRAME-NAME}  = YES.
 br-complex:VISIBLE IN FRAME {&FRAME-NAME}  = no.
 glog = br-variable:MOVE-TO-TOP().
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-b-prop-script Dialog-Frame
PROCEDURE proc-init-b-prop-script :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-prop-script:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 F-prop-script:fgcolor = 1   .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-variable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME {&FRAME-NAME} = NO
 br-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = YES.
 cb-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = yes.
 br-dtruledict:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-variable:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-parameter:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-complex:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 glog = browse br-pscript-ruleset:MOVE-TO-TOP().
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-init-b-variable Dialog-Frame
PROCEDURE proc-init-b-variable :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:

 b-variable:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame {&frame-name} .
 f-variable:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame {&frame-name} .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME {&FRAME-NAME} = NO
 br-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-dtruledict:VISIBLE IN FRAME {&FRAME-NAME} = NO.
 br-variable:VISIBLE IN FRAME {&FRAME-NAME}  = yes.
 br-parameter:VISIBLE IN FRAME {&FRAME-NAME}  = NO.
 br-complex:VISIBLE IN FRAME {&FRAME-NAME}  = NO.
 glog = br-variable:MOVE-TO-TOP().
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-mouse-menu-click Dialog-Frame
PROCEDURE proc-mouse-menu-click :
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-entry-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-proc-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-value-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-data-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-class-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-includes-operator as logical no-undo .

DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-complex FOR tt-complex.
DEFINE BUFFER buf2_tt-complex FOR tt-complex.
 ASSIGN
 v-script-al = "("
 v-script-nl = "("
 .

  FOR EACH buf_tt-widget
  BY buf_tt-widget.right-bottom
  ON error undo, return no-apply
  :
     IF buf_tt-widget.HANDLE:SELECTED THEN DO:
        if not v-includes-operator
        and  buf_tt-widget.entry-type = {&rdict-etype-operator} then do:
          v-includes-operator = yes.
        end.
        ASSIGN
        v-script-al = v-script-al + {&space-char} + buf_tt-widget.script-al
        v-script-nl = v-script-nl + {&space-char} + buf_tt-widget.script-nl
        v-ii = v-ii + 1
        .
        IF v-ii = 1 THEN DO:
          ASSIGN
          v-entry-type = '-':U
          v-script-type = {&prop-script-type-variable}
          v-script-value-type = buf_tt-widget.script-value-type
          v-data-type = buf_tt-widget.DATA-TYPE
          v-dtm-code = buf_tt-widget.dtm-code
          v-class-dtm-code = buf_tt-widget.class-dtm-code
          .
        END.
        ELSE DO:
            ASSIGN
            v-entry-type = '-':U
            v-script-name  = '':U
            v-script-type = {&prop-script-type-variable}
            v-proc-type = '':U
            v-script-value-type = '-':U
            v-data-type = '-':U
            v-dtm-code = 0
            v-class-dtm-code = 0
            .
        END.
       DELETE WIDGET buf_tt-widget.HANDLE_.
       DELETE buf_tt-widget.
     END.
  END.
  ASSIGN
  v-script-al = v-script-al + " )"
  v-script-nl = v-script-nl + " )"
  .
  if not v-includes-operator then do:
    ASSIGN
    v-script-al = left-trim(v-script-al, "(")
    v-script-nl = left-trim(v-script-nl, "(")
    v-script-al = right-trim(v-script-al, ")")
    v-script-nl = right-trim(v-script-nl, ")")
    .
  end.
  RUN create-widget IN THIS-PROCEDURE ( INPUT v-dtm-code /*p-dtm-code*/
                                   ,input v-class-dtm-code /*p-class-dtm-code*/
                                  ,INPUT rs-language
                                  ,input v-script-al
                                  ,INPUT v-script-al
                                  ,INPUT v-script-nl
                                  ,INPUT v-entry-type /*p-entry-type*/
                                  ,INPUT v-script-type /*p-script-type*/
                                  ,input v-script-value-type /*p-script-value-type*/
                                  ,INPUT v-data-type
                                  ,input v-proc-type /*proc-type*/
                                  ,input '':U /*uniq-key-rec*/
                                  ).
  FIND last buf2_tt-complex NO-ERROR.
  CREATE buf_tt-complex.
  ASSIGN
  buf_tt-complex.script-al = v-script-al
  buf_tt-complex.script-nl = v-script-nl
  buf_tt-complex.key_ = ( IF AVAILABLE buf2_tt-complex
                           THEN buf2_tt-complex.KEY_ + 1
                           ELSE 1)
  buf_tt-complex.entry-type = v-entry-type
  buf_tt-complex.script-name = v-script-name
  buf_tt-complex.proc-type = v-proc-type
  buf_tt-complex.script-type = v-script-type
  buf_tt-complex.script-value-type = v-script-value-type
  buf_tt-complex.data-type = v-data-type
  buf_tt-complex.dtm-code = v-dtm-code
  buf_tt-complex.class-dtm-code = v-class-dtm-code
  .
{&open-query-br-complex}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-id AS integer NO-UNDO.
DEFINE VARIABLE v-rule-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf_tt-rule-i-script FOR tt-rule-i-script.
DEFINE BUFFER buf_tt-loc-rule-i-script FOR tt-loc-rule-i-script.
IF p-script-type = {&rule-script-COND}
or p-script-type = {&rule-script-cycle-COND}
THEN DO:
  RUN check-script-type-cond IN THIS-PROCEDURE ( OUTPUT v-script-al
                                           ,OUTPUT v-script-nl) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN ERROR.
END.
if p-script-type = {&rule-script-CONS}
or p-script-type = {&rule-script-GOTO}
then do:
    RUN check-script-type-cons IN THIS-PROCEDURE ( OUTPUT v-script-al
                                                 ,OUTPUT v-script-nl) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN ERROR.
end.
MESSAGE v-script-al SKIP v-script-nl VIEW-AS ALERT-BOX.
if p-mode = {&update} then do:
  for each buf_tt-loc-rule-i-script where
  on error undo, return error :
    find first buf_tt-rule-i-script where
              buf_tt-rule-i-script.root_rule_id = buf_tt-loc-rule-i-script.root_rule_id
         and  buf_tt-rule-i-script.script_id = buf_tt-loc-rule-i-script.script_id
         and  buf_tt-rule-i-script.i-script-name = buf_tt-loc-rule-i-script.i-script-name no-error.
    if not available buf_tt-rule-i-script then do:
      create buf_tt-rule-i-script.
    end.
    buffer-copy buf_tt-loc-rule-i-script to buf_tt-rule-i-script.
  end.
  for each buf_tt-rule-i-script where
          buf_tt-rule-i-script.root_rule_id = p-rule-id
      and buf_tt-rule-i-script.script_id = p-script-id
  on error undo, return error :
    find first buf_tt-loc-rule-i-script where
              buf_tt-loc-rule-i-script.root_rule_id = buf_tt-rule-i-script.root_rule_id
         and  buf_tt-loc-rule-i-script.script_id = buf_tt-rule-i-script.script_id
         and  buf_tt-loc-rule-i-script.i-script-name = buf_tt-rule-i-script.i-script-name no-error.
    if not available buf_tt-loc-rule-i-script then do:
       delete buf_tt-rule-i-script.
    end.
  end.
  assign
  tt-rule-script.script = v-script-al
  tt-l_rule-script.script = v-script-nl.
end. /*if p-mode = {&update}*/
if p-mode = {&add-def} then do:
  ASSIGN
  v-script-id = NEXT-VALUE(s-rule-script-id, {&db-name_schema})
  tt-rule-script.script_id = v-script-id
  tt-rule-script.script = v-script-al
  tt-l_rule-script.script_id = v-script-id
  tt-l_rule-script.script = v-script-nl
 .
  RELEASE tt-rule-script.
  RELEASE tt-l_rule-script.
  for each buf_tt-loc-rule-i-script where
          buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id:
  end.
  for each buf_tt-loc-rule-i-script where
          buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
      and buf_tt-loc-rule-i-script.script_id = 0
  on error undo, return error :
    create buf_tt-rule-i-script.
    buffer-copy buf_tt-loc-rule-i-script
    except script_id
    to buf_tt-rule-i-script
    assign
    buf_tt-rule-i-script.script_id = v-script-id
    .
  end.
  p-script-id = v-script-id.

end. /*if p-mode = {&add-def}*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-undo Dialog-Frame
PROCEDURE proc-undo :
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
CASE p-mode:
  WHEN {&add-def} THEN DO:
    FOR EACH buf_tt-rule-script WHERE
            buf_tt-rule-script.rule_id = p-rule-id
        and buf_tt-rule-script.script_id = 0:
      DELETE buf_tt-rule-script.
    END.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-vc-language Dialog-Frame
PROCEDURE proc-vc-language :
DEFINE INPUT PARAMETER  p-language AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
ASSIGN
X_pscript-ruleset.script-name:VISIBLE IN BROWSE br-pscript-ruleset =  (p-language = "ABL")
Y_ruledict.script-al:VISIBLE IN BROWSE br-operator =  (p-language = "ABL")
tt-ruledict-param.param-name:VISIBLE IN BROWSE br-parameter =  (p-language = "ABL")
X_dtruledict.script-al:VISIBLE IN BROWSE br-dtruledict =  (p-language = "ABL")
tt-complex.script-al:VISIBLE IN BROWSE br-complex =  (p-language = "ABL")
.
FOR EACH buf_tt-widget NO-LOCK:
   ASSIGN
   buf_tt-widget.HANDLE_:SCREEN-VALUE = (IF p-language = "ABL"
                                         THEN buf_tt-widget.script-al
                                         ELSE buf_tt-widget.script-nl).
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-current-column Dialog-Frame
FUNCTION get-current-column RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL ) :
DEFINE VARIABLE v-c-r AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-c-c AS DECIMAL NO-UNDO.
ASSIGN
v-c-r = TRUNCATE(p-right-bottom / 98, 0) + 1
v-c-c = p-right-bottom - (v-c-r - 1 ) * 98 + 1.
IF v-c-c > 98 THEN DO:
   v-c-r = v-c-r + 1.
   v-c-c = 1.
END.
RETURN v-c-c.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-current-row Dialog-Frame
FUNCTION get-current-row RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL ) :
DEFINE VARIABLE v-c-r AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-c-c AS DECIMAL NO-UNDO.
ASSIGN
v-c-r = TRUNCATE(p-right-bottom / 98, 0) + 1
v-c-c = p-right-bottom - (v-c-r - 1) * 98 + 1.
IF v-c-c > 98 THEN DO:
   v-c-r = v-c-r + 1.
   v-c-c = 1.
END.
RETURN v-c-r.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-left-top Dialog-Frame
FUNCTION get-left-top RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL ) :

RETURN (( p-row - 1.0) * 98.0 + p-column).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-right-bottom Dialog-Frame
FUNCTION get-right-bottom RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL ) :

RETURN ( ( p-row - 1.0)  * 98.0 + p-width + p-column ).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION SUBSTITUTE-value-type Dialog-Frame
FUNCTION SUBSTITUTE-value-type RETURNS CHARACTER
  ( INPUT p-value-type AS CHARACTER, buffer buf_tt-widget for tt-widget) :
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
   if buf_tt-widget.entry-type = {&rdict-etype-prop-script}
   or buf_tt-widget.entry-type = {&rdict-etype-parameter} then do:
   end.
   else do:
      if buf_tt-widget.script-type = {&prop-script-type-variable} then do:
        p-value-type = buf_tt-widget.script-value-type.
      end.
      else do:
        if buf_tt-widget.entry-type = {&rdict-etype-operator} then do:
          find first buf_ruledict no-lock where
                    buf_ruledict.entry-type = {&rdict-etype-operator}
                and buf_ruledict.script-al = buf_tt-widget.script-al-fix no-error .
          if available buf_ruledict then do:
              find first buf_ruledict-param no-lock where
                        buf_ruledict-param.entry-id = buf_ruledict.entry-id
                    and buf_ruledict-param.param-num = 0 no-error .
              if available buf_ruledict-param then do:
                p-value-type = buf_ruledict-param.param-data-type.
              end.
              else do:
                return buf_tt-widget.script-al.
              end.
          end.
          else do:
            return buf_tt-widget.script-al.
          end.
        end.
      end.
   end.


CASE entry(1,p-value-type):
    WHEN {&abl-datatype-character} THEN RETURN '""':U.
    WHEN {&abl-datatype-integer} THEN RETURN '0':U.
    WHEN {&abl-datatype-decimal} THEN RETURN '0.0':U.
    WHEN {&abl-datatype-date} THEN RETURN '?':U.
    WHEN {&abl-datatype-logical} THEN RETURN 'no':U.
    WHEN {&abl-datatype-void} THEN RETURN '(no = no)':U.
END CASE.
RETURN buf_tt-widget.script-al.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME