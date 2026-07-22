&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE NEW SHARED BUFFER X_dis-card-type FOR ub.dis-card-type.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник типов дисконтных карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/05
Author: Bakhtadze Natalya
Creation date: 12/09/05

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
/*{&all} {&company} или "":U*/
DEFINE INPUT PARAMETER BTTNS AS CHAR NO-UNDO.
DEFINE INPUT PARAMETER paremitent-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parhost-code like ub.sysconf.host-code no-undo.
DEFINE INPUT PARAMETER parobj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER parobj-code like ub.clients.obj-code no-undo.
DEFINE input-OUTPUT PARAMETER p-rid-list As char NO-UNDO. /* фиктивный параметр для вызовов процедур*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Справочник типов дисконтных карт " .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ rul/calldscr.i }
{ gbl/key-rec.i }

define variable ri as recid no-undo.
define variable v-is-dc as character no-undo .
define variable v-conf-type as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE rule-proc-option AS CHARACTER NO-UNDO.
&SCOP dc-d-pcnt-code string(X_dis-card-type.dflt-d-pcnt-method)

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dctype

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES x_dis-card-type X_rp-by-call X_rule-by-call ~
X_rule-profile

/* Definitions for BROWSE BR-dctype                                     */
&Scoped-define FIELDS-IN-QUERY-BR-dctype get-mark(recid(X_dis-card-type), v-rid-list) X_dis-card-type.type X_dis-card-type.emitent-host-code get-emitent(X_dis-card-type.emitent-host-code) get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code ,INPUT X_dis-card-type.type ,INPUT X_dis-card-type.host-code ,INPUT X_dis-card-type.obj-type ,INPUT X_dis-card-type.obj-code ,INPUT {&ddctr-def-pcnt}) X_dis-card-type.d-pcnt-byshop X_dis-card-type.dflt-credit-card X_dis-card-type.lim-kr get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code ,INPUT X_dis-card-type.type ,INPUT X_dis-card-type.host-code ,INPUT X_dis-card-type.obj-type ,INPUT X_dis-card-type.obj-code ,INPUT {&ddctr-def-cash-pcnt}) get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code ,INPUT X_dis-card-type.type ,INPUT X_dis-card-type.host-code ,INPUT X_dis-card-type.obj-type ,INPUT X_dis-card-type.obj-code ,input {&ddctr-def-categ}) {&dc-d-pcnt-name}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dctype
&Scoped-define SELF-NAME BR-dctype
&Scoped-define QUERY-STRING-BR-dctype FOR EACH x_dis-card-type NO-LOCK     BY x_dis-card-type.type
&Scoped-define OPEN-QUERY-BR-dctype OPEN QUERY {&SELF-NAME} FOR EACH x_dis-card-type NO-LOCK     BY x_dis-card-type.type.
&Scoped-define TABLES-IN-QUERY-BR-dctype x_dis-card-type
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dctype x_dis-card-type


/* Definitions for BROWSE br-profile                                    */
&Scoped-define FIELDS-IN-QUERY-br-profile X_rp-by-call.profile_id get-profile-name ( INPUT X_rp-by-call.profile_id) get-profile-dynamic ( INPUT X_rp-by-call.profile_id) X_rp-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-profile
&Scoped-define SELF-NAME br-profile
&Scoped-define QUERY-STRING-br-profile FOR EACH X_rp-by-call WHERE          X_rp-by-call.call_id = x_dis-card-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-profile OPEN QUERY {&SELF-NAME} FOR EACH X_rp-by-call WHERE          X_rp-by-call.call_id = x_dis-card-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-profile X_rp-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-br-profile X_rp-by-call


/* Definitions for BROWSE br-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-call X_rule-by-call.can-calc X_rule-by-call.algo-des X_rule-by-call.is_dynamic X_rule-by-call.codex_id X_rule-by-call.ruleset_id X_rule-by-call.order_id X_rule-by-call.rule_id X_rule-by-call.profile_id
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&Scoped-define QUERY-STRING-br-rule-by-call FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = x_dis-card-type.uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-by-call OPEN QUERY {&SELF-NAME} FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = x_dis-card-type.uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-by-call X_rule-by-call ~
X_rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-call X_rule-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-call X_rule-profile


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-profile}~
    ~{&OPEN-QUERY-br-rule-by-call}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-mark B-sel B-add B-lookup B-chg ~
B-del b-prop-ref b-disc B-hist B-Help B-mask b-ruleproc BR-dctype ~
Rs-algo-profile rs-algo-types b-rule b-params B-ruleset br-rule-by-call ~
br-profile E-rule-name mark-num
&Scoped-Define DISPLAYED-OBJECTS Rs-algo-profile rs-algo-types E-rule-name ~
mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-dflt-dct-rule Dialog-Frame
FUNCTION get-dflt-dct-rule RETURNS CHARACTER
  (
     INPUT p-emitent-host-code AS INTEGER
    ,INPUT p-type AS CHARACTER
    ,INPUT p-host-code AS INTEGER
    ,INPUT p-obj-type AS CHARACTER
    ,INPUT p-obj-code AS INTEGER
    ,INPUT p-discnt-role AS CHARACTER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-emitent Dialog-Frame
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( par-rid as recid, parv-rid-list as character  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-dynamic Dialog-Frame
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-name Dialog-Frame
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Схема"         .

DEFINE MENU menu-b-ruleproc
       MENU-ITEM m_rpoc_text    LABEL "Текст"
       MENU-ITEM m_rpoc_graph   LABEL "Графика"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-disc
     LABEL "Пр-ла скидок"
     SIZE 12 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3 BY 1.

DEFINE BUTTON B-mask
     LABEL "&Маски"
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-params
     LABEL "Пар-ры"
     SIZE 10 BY 1.

DEFINE BUTTON b-prop-ref
     LABEL "Итоги/Срезы"
     SIZE 15 BY 1.

DEFINE BUTTON b-rule
     LABEL "Правило"
     SIZE 10 BY 1.

DEFINE BUTTON b-ruleproc
     LABEL "Процессы"
     SIZE 12 BY 1.

DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.17
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 9.88 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-algo-profile AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 28 BY 1 NO-UNDO.

DEFINE VARIABLE rs-algo-types AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Определенные пользователем", 2
     SIZE 36 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dctype FOR
      x_dis-card-type SCROLLING.

DEFINE QUERY br-profile FOR
      X_rp-by-call SCROLLING.

DEFINE QUERY br-rule-by-call FOR
      X_rule-by-call,
      X_rule-profile SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dctype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dctype Dialog-Frame _FREEFORM
  QUERY BR-dctype DISPLAY
      get-mark(recid(X_dis-card-type), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_dis-card-type.type COLUMN-LABEL "Тип" FORMAT "X(8)":U
X_dis-card-type.emitent-host-code COLUMN-LABEL "Код!эмитента" FORMAT ">>>>99999":U
get-emitent(X_dis-card-type.emitent-host-code) COLUMN-LABEL "Эмитент" FORMAT "X(15)":U
get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code
                    ,INPUT X_dis-card-type.type
                    ,INPUT X_dis-card-type.host-code
                    ,INPUT X_dis-card-type.obj-type
                    ,INPUT X_dis-card-type.obj-code
                    ,INPUT {&ddctr-def-pcnt})
 COLUMN-LABEL "%скидки!по умолч!на товар" FORMAT "X(7)":U
X_dis-card-type.d-pcnt-byshop COLUMN-LABEL "Скидка!по!объ./фирм." FORMAT "+/":U
X_dis-card-type.dflt-credit-card COLUMN-LABEL "Кре!дит!ная" FORMAT "+/":U
X_dis-card-type.lim-kr FORMAT ">>>,>>>,>>>,>>9.99":U
get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code
                  ,INPUT X_dis-card-type.type
                  ,INPUT X_dis-card-type.host-code
                  ,INPUT X_dis-card-type.obj-type
                  ,INPUT X_dis-card-type.obj-code
                  ,INPUT {&ddctr-def-cash-pcnt})
COLUMN-LABEL "%скидки!по умолч!на итог" FORMAT "X(7)":U
get-dflt-dct-rule ( INPUT X_dis-card-type.emitent-host-code
                ,INPUT X_dis-card-type.type
                ,INPUT X_dis-card-type.host-code
                ,INPUT X_dis-card-type.obj-type
                ,INPUT X_dis-card-type.obj-code
                ,input {&ddctr-def-categ})
COLUMN-LABEL "кате!гория!по умолч" FORMAT "X(4)":U
{&dc-d-pcnt-name} COLUMN-LABEL "Использ.скидки" FORMAT "X(12)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.

DEFINE BROWSE br-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-profile Dialog-Frame _FREEFORM
  QUERY br-profile NO-LOCK DISPLAY
      X_rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9"
get-profile-name ( INPUT X_rp-by-call.profile_id) COLUMN-LABEL "Название" FORMAT "X(255)"
get-profile-dynamic ( INPUT X_rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
X_rp-by-call.once-more COLUMN-LABEL "№!привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.88
         TITLE "Алгоритмы" ROW-HEIGHT-CHARS .67.

DEFINE BROWSE br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-by-call Dialog-Frame _FREEFORM
  QUERY br-rule-by-call NO-LOCK DISPLAY
      X_rule-by-call.can-calc COLUMN-LABEL "Включен?" FORMAT "+/":U
X_rule-by-call.algo-des FORMAT "X(255)":U COLUMN-LABEL "Описание алгоритма/правила" WIDTH 56
X_rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое" FORMAT "+/":U
X_rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">>>>>>9":U WIDTH 7
X_rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">>>>>>9":U width 7
X_rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
X_rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>>>>>>9":U WIDTH 9
X_rule-by-call.profile_id COLUMN-LABEL "Алгоритм" FORMAT ">>9":U WIDTH 8
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.88
         FONT 4
         TITLE "Правила" ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14
     B-add AT ROW 1 COL 24
     B-lookup AT ROW 1 COL 34
     B-chg AT ROW 1 COL 44
     B-del AT ROW 1 COL 54 WIDGET-ID 16
     b-prop-ref AT ROW 1 COL 64 WIDGET-ID 8
     b-disc AT ROW 1 COL 79 WIDGET-ID 10
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-mask AT ROW 2 COL 64
     b-ruleproc AT ROW 2 COL 79 WIDGET-ID 14
     BR-dctype AT ROW 3.46 COL 1
     Rs-algo-profile AT ROW 12.5 COL 1.5 NO-LABEL WIDGET-ID 2
     rs-algo-types AT ROW 12.5 COL 29 NO-LABEL
     b-rule AT ROW 12.5 COL 65
     b-params AT ROW 12.5 COL 75 WIDGET-ID 6
     B-ruleset AT ROW 12.5 COL 85 WIDGET-ID 12
     br-rule-by-call AT ROW 13.5 COL 1
     br-profile AT ROW 13.5 COL 1 WIDGET-ID 100
     E-rule-name AT ROW 21.5 COL 1 NO-LABEL
     mark-num AT ROW 2.17 COL 2.88 NO-LABEL
     SPACE(86.24) SKIP(20.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Типы дисконтных карт"
         DEFAULT-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt0-rule-call-param T "NEW SHARED" NO-UNDO ub rule-call-param
      TABLE: X_dis-card-type B "NEW SHARED" ? ub dis-card-type
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-dctype b-ruleproc Dialog-Frame */
/* BROWSE-TAB br-rule-by-call B-ruleset Dialog-Frame */
/* BROWSE-TAB br-profile br-rule-by-call Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-rule:HANDLE.

ASSIGN
       b-ruleproc:POPUP-MENU IN FRAME Dialog-Frame       = MENU menu-b-ruleproc:HANDLE.

ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dctype
/* Query rebuild information for BROWSE BR-dctype
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH x_dis-card-type NO-LOCK
    BY x_dis-card-type.type.
     _END_FREEFORM
     _OrdList          = "ub.dis-card-type.type|yes"
     _Query            is NOT OPENED
*/  /* BROWSE BR-dctype */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-profile
/* Query rebuild information for BROWSE br-profile
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_rp-by-call WHERE
         X_rp-by-call.call_id = x_dis-card-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_rule-by-call.call_id = dis-card-type.uniq-key-rec"
     _Query            is OPENED
*/  /* BROWSE br-profile */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-call
/* Query rebuild information for BROWSE br-rule-by-call
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_rule-by-call
      WHERE X_rule-by-call.call_id = x_dis-card-type.uniq-key-rec,
    FIRST X_rule-profile NO-LOCK WHERE
         X_rule-profile.profile_id = X_rule-by-call.profile_id
     AND (rs-algo-types = 1 OR
         X_rule-profile.is_dynamic = yes)
BY X_rule-by-call.codex_id
BY X_rule-by-call.ruleset_id
BY X_rule-by-call.order_id INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_rule-by-call.call_id = dis-card-type.uniq-key-rec"
     _Query            is OPENED
*/  /* BROWSE br-rule-by-call */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Типы дисконтных карт */
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Типы дисконтных карт */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference-dc-type_input-deletion-updating':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
  }
  if NOT glog then
  return no-apply .
  ri = ?.
  run ref/dc-typei.w (  input parparentproc
                    ,input {&add-def}
                    ,input parhost-code
                    ,input parobj-type
                    ,input parobj-code
                    ,input-output ri ).
  if ri <> ? then do:
    run OpenBr in this-procedure .
    reposition br-dctype to recid ri no-error.
    apply "ENTRY" to br-dctype.
    apply "VALUE-CHANGED" to br-dctype.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  define variable cur-ri as recid no-undo.
  define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference-dc-type_input-deletion-updating':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
  }


    if NOT glog then return no-apply .
    If available X_dis-card-type then do:
        cur-ri = recid( X_dis-card-type ).
        ri = recid( X_dis-card-type ) .
       run ref/dc-typei.w ( input parparentproc
                        ,input {&update}
                       ,input parhost-code
                       ,input parobj-type
                       ,input parobj-code
                       ,input-output ri ).
        RUn openBr in this-procedure .
        reposition br-dctype to recid cur-ri no-error.
        apply "ENTRY" to br-dctype.
        apply "VALUE-CHANGED" to br-dctype.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  define variable cur-ri as recid no-undo.
  define variable glog as logical no-undo .
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_reference-dc-type_input-deletion-updating':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  glog
  }


if NOT glog then return no-apply .
If available X_dis-card-type then do:
    glog = NO.
    MESSAGE
    substitute("Вы действительно хотите удалить тип ДК &1 эмитент &3"
               , X_dis-card-type.TYPE
               , X_dis-card-type.emitent-host-code)
    VIEW-AS ALERT-BOX QUESTION buttons YES-NO UPDATE glog.
    IF NOT glog THEN UNDO, RETURN NO-APPLY.
    cur-ri = recid(X_dis-card-type).
    run ref/dctypei3.p ( INPUT NO /*p-silent*/
                         ,INPUT cur-ri) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    RUn openBr in this-procedure .
    reposition br-dctype to row 1 no-error.
    apply "ENTRY" to br-dctype.
    apply "VALUE-CHANGED" to br-dctype.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-disc Dialog-Frame
ON CHOOSE OF b-disc IN FRAME Dialog-Frame /* Пр-ла скидок */
DO:
  DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
        run ref/dis-dcts.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT {&table_Dis-card-type}  /*p-list-mode */
                            ,input X_dis-card-type.emitent-host-code
                            ,input X_dis-card-type.type
                            ,input 0 /*host-code*/
                            ,input '':U /*p-obj-type*/
                            ,input 0 /*p-obj-code*/
                            ,input 0 /*p-templ-rl-root = 0*/
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input 0
                            ,input-output v-loc-rid-list ) no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-ri-list AS CHARACTER NO-UNDO.
  IF NOT AVAIL X_dis-card-type THEN RETURN NO-APPLY.
  run ref/dcctypes.w ( input parparentproc
                    , input '':U
                    , input ?
                    , input X_dis-card-type.emitent-host-code
                    , input parhost-code
                    , input parobj-type
                    , input parobj-code
                    , input X_dis-card-type.TYPE
                    , input "one":U
                    , input "subject"
                    , output v-ri-list ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
 If available X_dis-card-type then do:
   ri = recid( X_dis-card-type ) .
   run ref/dc-typei.w ( input parparentproc
                      , input {&lookup}
                      , input parhost-code
                      , input parobj-type
                      , input parobj-code
                      , input-output ri ).
   apply "ENTRY" to br-dctype.
 end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
DEFINE VARIABLE loc#log as logical no-undo.
if available X_dis-card-type then do:
  { gbl/markstrn.i X_dis-card-type v-rid-list }
  loc#log = br-dctype:refresh() .

  if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
      loc#log = br-dctype:select-next-row ().
      apply "iteration-changed" to br-dctype in frame {&frame-name}.
  end.
  if num-entries( v-rid-list ) = 0
  then
      hide mark-num in frame {&frame-name}.
  else
      disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
end.
apply "entry" to br-dctype in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mask Dialog-Frame
ON CHOOSE OF B-mask IN FRAME Dialog-Frame /* Маски */
DO:
define variable v-rid-list AS CHARACTER NO-UNDO.
IF NOT AVAIL X_dis-card-type THEN RETURN NO-APPLY.
  run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,input "b-add":U
                   ,INPUT "one":U
                   ,INPUT X_dis-card-type.TYPE
                   ,INPUT X_dis-card-type.emitent-host-code
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
IF ERROR-STATUS:error  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Пар-ры */
DO:
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
  CASE Rs-algo-profile:
    when {&TABLE_rule-by-call} then do:
      IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
      FOR EACH tt0-rule-call-param NO-LOCK:
        DELETE tt0-rule-call-param.
      END.
      FOR EACH buf_rule-call-param NO-LOCK WHERE
              buf_rule-call-param.codex_id = X_rule-by-call.codex_id
          AND buf_rule-call-param.ruleset_id = X_rule-by-call.ruleset_id
          AND buf_rule-call-param.call_id = X_rule-by-call.call_id:
          CREATE tt0-rule-call-param.
          BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
      END.
      run ref/rulercps.w (
                               input parparentproc
                              ,input this-procedure:handle
                              ,input '':U /**/
                              ,input {&lookup}
                              ,input {&table_rule-call-param}
                              ,input 0
                              ,input ? /*once-more*/
                              ,input X_rule-by-call.call_id /*p-call-id*/
                              ,input X_rule-by-call.codex_id /*p-codex-id*/
                              ,input X_rule-by-call.ruleset_id /*p-ruleset-id*/
                              ,input X_rule-by-call.order_id /*p-order-id*/
                              ,input X_rule-by-call.RULE_id /*p-rule-id*/
                              ,INput substitute("Правило &1", X_rule-by-call.RULE_id)  /**/
                              ,input-output table tt0-rule-call-param  ) no-error.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    end.
    when {&TABLE_rp-by-call} then do:
      IF NOT AVAILABLE X_rp-by-call THEN RETURN NO-APPLY.
      FOR EACH tt0-rule-call-param NO-LOCK:
        DELETE tt0-rule-call-param.
      END.
      for each buf_rule-by-call no-lock where
            buf_rule-by-call.call_id = X_rp-by-call.call_id
        and buf_rule-by-call.profile_id = X_rp-by-call.profile_id
        and buf_rule-by-call.once-more = X_rp-by-call.once-more,
         EACH buf_rule-call-param NO-LOCK WHERE
              buf_rule-call-param.call_id = buf_rule-by-call.call_id
          AND buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
          AND buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
          AND buf_rule-call-param.order_id = buf_rule-by-call.order_id :
          CREATE tt0-rule-call-param.
          BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
      END.
      define variable v-param-form as character no-undo .
      define buffer buf_rule-profile for ub.rule-profile.
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = X_rp-by-call.profile_id.
      assign
      v-param-form = (if buf_rule-profile.custom-param-form > 0
                      then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                      else "ref/rulercps.w")
      .
      run value(v-param-form) (
                               input parparentproc
                              ,input this-procedure:handle
                              ,input '':U /**/
                              ,input {&lookup}
                              ,input {&table_rp-rule-param}
                              ,input X_rp-by-call.profile_id
                              ,input X_rp-by-call.once-more
                              ,input X_rp-by-call.call_id /*p-call-id*/
                              ,input 0 /*p-codex-id*/
                              ,input 0 /*p-ruleset-id*/
                              ,input ? /*p-order-id*/
                              ,input 0 /*p-rule-id*/
                              ,INput substitute("Профайл &1 Номер привязки &2 &3"
                                    , X_rp-by-call.profile_id
                                    , X_rp-by-call.once-more
                                    , calldscr(X_rp-by-call.call_id)
                                    )  /**/
                              ,input-output table tt0-rule-call-param  ) no-error.
      IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
    end.
  end case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop-ref Dialog-Frame
ON CHOOSE OF b-prop-ref IN FRAME Dialog-Frame /* Итоги/Срезы */
DO:
  IF NOT AVAILABLE X_dis-card-type  THEN RETURN NO-APPLY.
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run ref/proprefs.w ( INPUT parparentproc
                  ,INPUT (if v-cntxt-db-num = 0
                         and lookup("b-add", bttns) > 0
                         then "b-add":U
                         else '':U) /*bttns*/
                  ,INPUT "call_id" /*p-list-mode*/
                  ,INPUT 0 /*p-dtm-code*/
                  ,input '':U
                  ,INPUT X_dis-card-type.uniq-key-rec /*p-call-id*/
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule Dialog-Frame
ON CHOOSE OF b-rule IN FRAME Dialog-Frame /* Правило */
DO:
  IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:

   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                            INPUT rule-display-option
                                           ,INPUT X_rule-by-call.codex_id
                                           ,INPUT X_rule-by-call.ruleset_id
                                           ,INPUT X_rule-by-call.call_Id
                                           ,INPUT X_rule-by-call.order_id
                                           ,INPUT X_rule-by-call.rule_id) NO-ERROR.
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


&Scoped-define SELF-NAME b-ruleproc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ruleproc Dialog-Frame
ON CHOOSE OF b-ruleproc IN FRAME Dialog-Frame /* Процессы */
DO:
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.

IF rule-proc-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if rule-proc-option = "":U then do:
      return no-apply.
end.
run rule-proc IN THIS-PROCEDURE ( BUFFER X_dis-card-type, INPUT rule-proc-option) no-error .
IF ERROR-STATUS:ERROR THEN DO:
    rule-proc-option = '':U.
    RETURN NO-APPLY.
END.
rule-proc-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ruleset Dialog-Frame
ON CHOOSE OF B-ruleset IN FRAME Dialog-Frame /* Т-ка вызова */
DO:
  DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe X_rule-by-call THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = X_rule-by-call.codex_id
        AND buf_ruleset.ruleset_id = X_rule-by-call.ruleset_id.

  run rul/ruleset-i.w ( input parparentproc
                       ,input {&lookup}
                       ,input buf_ruleset.codex_id
                       ,input buf_ruleset.ruleset_id
                       ,input-output v-rec) no-error.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if available X_dis-card-type then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
     then  v-rid-list = string( recid( X_dis-card-type ) ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dctype
&Scoped-define SELF-NAME BR-dctype
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dctype Dialog-Frame
ON VALUE-CHANGED OF BR-dctype IN FRAME Dialog-Frame
DO:
  RUN proc-value-changed IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-profile
&Scoped-define SELF-NAME br-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-profile Dialog-Frame
ON VALUE-CHANGED OF br-profile IN FRAME Dialog-Frame /* Алгоритмы */
DO:
  IF NOT AVAILABLE X_rp-by-call THEN DO:
     e-rule-name:SCREEN-VALUE = ''.
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = X_rp-by-call.ps.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-by-call Dialog-Frame
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame /* Правила */
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = X_rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", X_rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = buf_rule.name + {&NEW-LINE} + buf_rule.documentation.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_graph /* Схема */
DO:
  IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                              ,INPUT X_rule-by-call.codex_id
                                              ,INPUT X_rule-by-call.ruleset_id
                                              ,INPUT X_rule-by-call.call_Id
                                              ,INPUT X_rule-by-call.order_id
                                              ,INPUT X_rule-by-call.rule_id) NO-ERROR.

  ASSIGN
  rule-display-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rpoc_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rpoc_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rpoc_graph /* Графика */
DO:
  IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
  ASSIGN
  rule-proc-option = "graph".
  run rule-proc IN THIS-PROCEDURE ( BUFFER X_dis-card-type, INPUT rule-proc-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-proc-option = '':U.
      RETURN NO-APPLY.
  END.
  rule-proc-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_rpoc_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_rpoc_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_rpoc_text /* Текст */
DO:
   IF NOT AVAILABLE X_dis-card-type THEN RETURN NO-APPLY.
  ASSIGN
  rule-proc-option = "text".
  run rule-proc IN THIS-PROCEDURE ( BUFFER X_dis-card-type, INPUT rule-proc-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-proc-option = '':U.
      RETURN NO-APPLY.
  END.
  rule-proc-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_text /* Текст */
DO:
IF NOT AVAILABLE X_rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "text".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT X_rule-by-call.codex_id
                                            ,INPUT X_rule-by-call.ruleset_id
                                            ,INPUT X_rule-by-call.call_Id
                                            ,INPUT X_rule-by-call.order_id
                                            ,INPUT X_rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Rs-algo-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Rs-algo-profile Dialog-Frame
ON VALUE-CHANGED OF Rs-algo-profile IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-profile.
  CASE rs-algo-profile:
    WHEN {&TABLE_rule-by-call} THEN DO:
      HIDE
      br-profile
      IN FRAME {&FRAME-NAME}.
      .
      DISPLAY
      rs-algo-types
      br-rule-by-call
      b-rule
      b-ruleset
      WITH FRAME {&FRAME-NAME}.
    END.
    WHEN {&TABLE_rp-by-call} THEN DO:
        HIDE
        br-rule-by-call
        rs-algo-types
        b-rule
        b-ruleset
        IN FRAME {&FRAME-NAME}.
        DISPLAY
        br-profile
        WITH FRAME {&FRAME-NAME}.

    END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-algo-types
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-algo-types Dialog-Frame
ON VALUE-CHANGED OF rs-algo-types IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-types.
  {&OPEN-QUERY-br-rule-by-call}
  APPLY "VALUE-CHANGED" TO br-rule-by-call IN FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dctype
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/brwrefre.i " RUN proc-refresh IN THIS-PROCEDURE. "}
{ rul/rcpscont.i ub.rule-by-call }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  { gbl/conf-rd.i
  "'is-dc'"
  0
  "''":U
  0
  "''":U
  "''":U
  "''":U
  NO
  v-is-dc
  v-conf-type
  NO-ERROR
  }
  IF ERROR-STATUS:ERROR OR
    v-conf-type <> {&type-log} THEN
    v-is-dc = "no".
  if logical(v-is-dc) = no then do:
    message
    "В Вашей системе недоступна функциональность работы с дисконтными картами"
    view-as alert-box WARNING.
    undo main-block, return error .
  end.
  v-rid-list = p-rid-list.
  RUN Myenable in this-procedure .
  Run OpenBR in this-procedure .
  if v-rid-list <> '':U then do:
    reposition br-dctype to recid( integer(entry(1, v-rid-list))) no-error .
  end.
  HIDE mark-num in frame {&frame-name} .
  APPLY "ENTRY" TO br-dctype.
  APPLY "VALUE-CHANGED" TO br-dctype.
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
  DISPLAY Rs-algo-profile rs-algo-types E-rule-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-mark B-sel B-add B-lookup B-chg B-del b-prop-ref b-disc
         B-hist B-Help B-mask b-ruleproc BR-dctype Rs-algo-profile
         rs-algo-types b-rule b-params B-ruleset br-rule-by-call br-profile
         E-rule-name mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-dis-dct-value Dialog-Frame
PROCEDURE get-dis-dct-value :
DEFINE INPUT PARAMETER p-emitent-host-code AS integer no-undo.
DEFINE INPUT PARAMETER p-type AS CHARACTER no-undo.
DEFINE INPUT PARAMETER p-host-code AS integer no-undo.
DEFINE INPUT PARAMETER p-obj-type AS character no-undo.
DEFINE INPUT PARAMETER p-obj-code AS integer no-undo.
DEFINE INPUT PARAMETER p-discnt-role AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-discnt-value AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_dis-dct-rule FOR ub.dis-dct-rule.
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-dct-rule no-lock where
          buf_dis-dct-rule.emitent-host-code = p-emitent-host-code
      and buf_dis-dct-rule.type = p-TYPE
      and buf_dis-dct-rule.host-code = p-host-code
      and buf_dis-dct-rule.obj-type = p-obj-type
      and buf_dis-dct-rule.obj-code = p-obj-code
      and buf_dis-dct-rule.pos-type = {&cd-type-bo}
      and buf_dis-dct-rule.discnt-role = p-discnt-role no-error.

if available buf_dis-dct-rule then do:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-dct-rule.rule-num no-error.
  if available buf_dis-rule then do:
    assign
    p-discnt-value        = (IF p-discnt-role = {&ddctr-def-categ}
                             THEN string(buf_dis-rule.dis-kat)
                             ELSE string(buf_dis-rule.discnt-value, "->9.99%")).
    .
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
DO ii = 1 TO br-profile:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    clh = BROWSE br-profile:get-browse-column(ii).
    IF clh:LABEL BEGINS "Название" THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
      clh:width = 72
      .
    END.
END.
ASSIGN
rs-algo-profile:RADIO-BUTTONS = "Алгоритмы" + {&comma-char} +
                                 {&TABLE_rp-by-call} + {&comma-char} +
                                "Правила" + {&comma-char} + {&TABLE_rule-by-call}.
rs-algo-profile = {&TABLE_rp-by-call}.
ASSIGN
X_rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES
b-rule:menu-mouse in frame {&frame-name} = 1
b-ruleproc:menu-mouse in frame {&frame-name} = 1
.
DISPLAY
rs-algo-profile
rs-algo-types
WITH FRAME {&FRAME-NAME}.
ENABLE
B-exit
b-sel when lookup("b-sel":U, bttns) > 0
b-mark when lookup("b-mark":U, bttns) > 0
B-add when lookup("b-add":U, bttns) > 0 and v-cntxt-db-num = 0
B-chg when lookup("b-add":U, bttns) > 0 and v-cntxt-db-num = 0
B-del when lookup("b-add":U, bttns) > 0 and v-cntxt-db-num = 0
b-lookup
B-Help
b-mask
b-hist
BR-dctype
br-rule-by-call
br-profile
b-params
b-rule
b-ruleset
b-prop-ref
b-disc
b-ruleproc
rs-algo-types
rs-algo-profile
e-rule-name
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
APPLY "VALUE-CHANGED" TO rs-algo-profile.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
CASE p-mode:
  when {&all} then do:
    Open query br-dctype
    for each X_dis-card-type No-LOCK where
            X_dis-card-type.emitent-host-code = 0
        AND X_dis-card-type.host-code = 0
        AND X_dis-card-type.obj-type = "":U
        and X_dis-card-type.obj-code = 0.
 end.
 when {&company} then do:
    Open query br-dctype
    for each X_dis-card-type No-LOCK where
            X_dis-card-type.emitent-host-code = paremitent-code
        and X_dis-card-type.host-code = 0
        AND X_dis-card-type.obj-type = "":U
        and X_dis-card-type.obj-code = 0.
 end.
 otherwise do:
    Open query br-dctype
    for each X_dis-card-type NO-LOCK WHERE
            X_dis-card-type.host-code = 0
        AND X_dis-card-type.obj-type = "":U
        and X_dis-card-type.obj-code = 0.
  end.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-display-rule Dialog-Frame
PROCEDURE proc-display-rule :
DEFINE INPUT PARAMETER p-DISPLAY-MODE AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-refresh Dialog-Frame
PROCEDURE proc-refresh :
DEFINE VARIABLE v-doc-rec as RECID NO-UNDO.

if available X_dis-card-type then do:
     v-doc-rec = recid(X_dis-card-type).
END.
RUN Openbr in this-procedure.
REPOSITION br-dctype TO RECID v-doc-rec NO-ERROR.
APPLY 'ENTRY' to br-dctype IN FRAME {&frame-name}.
APPLY 'VALUE-CHANGED' to br-dctype.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-changed Dialog-Frame
PROCEDURE proc-value-changed :
{&OPEN-QUERY-br-rule-by-call}
{&OPEN-QUERY-br-profile}
IF rs-algo-profile = {&table_rule-by-call} THEN DO:
  APPLY "VAlue-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
END.
IF rs-algo-profile = {&table_rp-by-call} THEN DO:
  APPLY "VAlue-changed" TO br-profile IN FRAME {&FRAME-NAME}.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rule-proc Dialog-Frame
PROCEDURE rule-proc :
DEFINE PARAMETER BUFFER buf_dis-card-type FOR ub.dis-card-type.
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
run rul/run-rule-proc-view.p ( INPUT {&table_dis-card-type}
                              ,INPUT buf_dis-card-type.uniq-key-rec
                              ,INPUT 0 /*p-profile-id*/
                              ,INPUT p-option
                              ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-dflt-dct-rule Dialog-Frame
FUNCTION get-dflt-dct-rule RETURNS CHARACTER
  (
     INPUT p-emitent-host-code AS INTEGER
    ,INPUT p-type AS CHARACTER
    ,INPUT p-host-code AS INTEGER
    ,INPUT p-obj-type AS CHARACTER
    ,INPUT p-obj-code AS INTEGER
    ,INPUT p-discnt-role AS CHARACTER) :
DEFINE variable v-discnt-value AS CHARACTER NO-UNDO .
v-discnt-value = {&question-mark}.
RUN get-dis-dct-value IN THIS-PROCEDURE (
                                             INPUT p-emitent-host-code
                                            ,INPUT p-type
                                            ,INPUT p-host-code
                                            ,INPUT p-obj-type
                                            ,INPUT p-obj-code
                                            ,INPUT p-discnt-role
                                            ,OUTPUT v-discnt-value) NO-ERROR.
RETURN v-discnt-value.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-emitent Dialog-Frame
FUNCTION get-emitent RETURNS CHARACTER
  ( input par-emitent-host-code  as integer) :
define buffer buf_clients for ub.clients.
  if par-emitent-host-code = 0 then return "Глобальная".

  find first buf_clients no-lock where
                 buf_clients.obj-type = {&cmp} and
                  buf_clients.obj-code = par-emitent-host-code no-error.
     if not avail buf_clients then return "?".
     return buf_clients.obj-name.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-mark Dialog-Frame
FUNCTION get-mark RETURNS CHARACTER
  ( par-rid as recid, parv-rid-list as character  ) :
if lookup(string(par-rid), parv-rid-list) > 0 then return "*":U.
RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-dynamic Dialog-Frame
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ?.   /* Function return value. */
RETURN buf_rule-profile.is_dynamic.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-name Dialog-Frame
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN {&question-mark}.   /* Function return value. */
RETURN buf_rule-profile.NAME.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME