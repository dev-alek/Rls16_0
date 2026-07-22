&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER locked_thbj-attr FOR ub.thbj-attr.
DEFINE NEW SHARED TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER Xobj_clients FOR ub.clients.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование атрибутов (thbj-attr) имеющих ГЛОБ и ОБЪЕКТНЫЕ КОНТЕКСТ С ПОКАЗОМ ДЕРЕВА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/06/08
Author: Bakhtadze Natalya
Creation date: 05/06/08

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-prop-list-global as character no-undo .
define input parameter p-prop-list-obj as character no-undo .
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO. /*{&all} {&db} {&g___object}*/
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибутов (thbj-attr) имеющих ГЛОБ и ОБЪЕКТНЫЕ КОНТЕКСТ С ПОКАЗОМ ДЕРЕВА".
{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/thbjattr.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/key-rec.i }
{ rul/calldscr.i }
{ gbl/get-regf.i }
{ rul/rcpscont.i ub.rule-by-call {&OPEN-QUERY-br-rule-by-call} }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc3 }

define variable p-upper-code as character no-undo init {&attr-rum}. /*название секции В ГЛОБ КОНТЕКСТЕ*/
define variable p-obj-upper-code as character no-undo init {&attr-rum_obj}.


DEFINE VARIABLE v-db-num LIKE ub.db.db-num NO-UNDO.
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-to-create AS logical NO-UNDO.
define variable v-host-code as integer no-undo .
DEFINE VARIABLE v-uniq-key-rec AS CHARACTER NO-UNDO.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
DEFINE VARIABLE rule-proc-option AS CHARACTER NO-UNDO.

define variable v-label          as character no-undo . /* лабел атрибута */
define variable v-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
define variable v-output-display as logical   no-undo . /* виден в броусе */
define variable v-other          as character no-undo . /* еще чего - нибудь */
define variable v-prop-list-global      as character no-undo . /*список членов секции*/
define variable v-prop-list-obj    as character no-undo . /*список членов секции*/
define variable v-prop-type-list as character no-undo . /*список типов членов секции*/
define variable v-prop-label-list as character no-undo . /*список лейблов членов секции*/
define variable v-global          as logical no-undo .   /*может ли быть задан в глобальном контексте*/
define variable v-host           as logical no-undo .    /*может ли быть задан в контексте фирмы*/
define variable v-shop           as logical no-undo .    /*может ли быть задан в контексте маг*/
define variable v-store          as logical no-undo .    /*может ли быть задан в контексте склад*/
define variable v-level as character no-undo .
define variable v-up-way as character no-undo .
define variable v-prop-list as character no-undo .


define variable v-current-upper-prop-code as character no-undo .
DEFINE BUFFER buf_thbj-attr FOR ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define variable prop-option as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-profile

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_rp-by-call X_rule-by-call X_rule-profile ~
buf_thbj-attr X_clients

/* Definitions for BROWSE br-profile                                    */
&Scoped-define FIELDS-IN-QUERY-br-profile X_rp-by-call.profile_id get-profile-name ( INPUT X_rp-by-call.profile_id) get-profile-dynamic ( INPUT X_rp-by-call.profile_id) X_rp-by-call.once-more has-object-context(X_rp-by-call.profile_id)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-profile
&Scoped-define SELF-NAME br-profile
&Scoped-define QUERY-STRING-br-profile FOR EACH X_rp-by-call WHERE          X_rp-by-call.call_id = v-uniq-key-rec NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-profile OPEN QUERY {&SELF-NAME} FOR EACH X_rp-by-call WHERE          X_rp-by-call.call_id = v-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-profile X_rp-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-br-profile X_rp-by-call


/* Definitions for BROWSE br-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-call X_rule-by-call.can-calc X_rule-by-call.algo-des X_rule-by-call.is_dynamic X_rule-by-call.codex_id X_rule-by-call.ruleset_id X_rule-by-call.order_id X_rule-by-call.rule_id X_rule-by-call.profile_id has-object-context(X_rule-by-call.profile_id)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&Scoped-define QUERY-STRING-br-rule-by-call FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = v-uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-by-call OPEN QUERY {&SELF-NAME} FOR EACH X_rule-by-call       WHERE X_rule-by-call.call_id = v-uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE          X_rule-profile.profile_id = X_rule-by-call.profile_id      AND (rs-algo-types = 1 OR          X_rule-profile.is_dynamic = yes) BY X_rule-by-call.codex_id BY X_rule-by-call.ruleset_id BY X_rule-by-call.order_id INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-by-call X_rule-by-call ~
X_rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-call X_rule-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-call X_rule-profile


/* Definitions for BROWSE BR-thbj-attr                                  */
&Scoped-define FIELDS-IN-QUERY-BR-thbj-attr get-region(0, buf_thbj-attr.obj-type, buf_thbj-attr.obj-code) get-prop-label(buf_thbj-attr.upper-prop-code, buf_thbj-attr.prop-code) buf_thbj-attr.property-value-logical
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-thbj-attr
&Scoped-define SELF-NAME BR-thbj-attr
&Scoped-define QUERY-STRING-BR-thbj-attr FOR EACH buf_thbj-attr WHERE     buf_thbj-attr.obj-type = p-obj-type AND buf_thbj-attr.obj-code = p-obj-code, ~
       FIRST X_clients NO-LOCK
&Scoped-define OPEN-QUERY-BR-thbj-attr OPEN QUERY {&SELF-NAME} FOR EACH buf_thbj-attr WHERE     buf_thbj-attr.obj-type = p-obj-type AND buf_thbj-attr.obj-code = p-obj-code, ~
       FIRST X_clients NO-LOCK                                                     .
&Scoped-define TABLES-IN-QUERY-BR-thbj-attr buf_thbj-attr X_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BR-thbj-attr buf_thbj-attr
&Scoped-define SECOND-TABLE-IN-QUERY-BR-thbj-attr X_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-profile}~
    ~{&OPEN-QUERY-br-rule-by-call}~
    ~{&OPEN-QUERY-BR-thbj-attr}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-add rs-active b-ruleproc B-Help ~
BR-thbj-attr Rs-algo-profile rs-algo-types b-rule b-params B-ruleset ~
br-rule-by-call br-profile E-rule-name
&Scoped-Define DISPLAYED-OBJECTS rs-active Rs-algo-profile rs-algo-types ~
E-rule-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-dynamic Dialog-Frame
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( INPUT p-profile-id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-profile-name Dialog-Frame
FUNCTION get-profile-name RETURNS CHARACTER
  ( INPUT p-profile-id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-prop-label Dialog-Frame
FUNCTION get-prop-label RETURNS CHARACTER
  ( INPUT p-upper-prop-code AS character
  ,INPUT p-prop-code AS character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD has-object-context Dialog-Frame
FUNCTION has-object-context RETURNS LOGICAL
  ( INPUT p-profile-id AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-b-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Схема"         .

DEFINE MENU menu-b-ruleproc
       MENU-ITEM m_proc_text    LABEL "Текст"
       MENU-ITEM m_proc_graph   LABEL "Графика"       .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg  NO-FOCUS
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-params
     LABEL "Пар-ры"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-rule
     LABEL "Правило"
     SIZE 10 BY 1.

DEFINE BUTTON b-ruleproc
     LABEL "Процессы"
     SIZE 12 BY 1.

DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.

DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.17
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rs-active AS LOGICAL
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", no,
"Активные", yes
     SIZE 21.5 BY 1 NO-UNDO.

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
     SIZE 36 BY .77 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-profile FOR
      X_rp-by-call SCROLLING.

DEFINE QUERY br-rule-by-call FOR
      X_rule-by-call,
      X_rule-profile SCROLLING.

DEFINE QUERY BR-thbj-attr FOR
      buf_thbj-attr,
      X_clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-profile Dialog-Frame _FREEFORM
  QUERY br-profile NO-LOCK DISPLAY
      X_rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9"
get-profile-name ( INPUT X_rp-by-call.profile_id) COLUMN-LABEL "Название" FORMAT "X(255)"
get-profile-dynamic ( INPUT X_rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
X_rp-by-call.once-more COLUMN-LABEL "№!привязки" FORMAT ">9"
has-object-context(X_rp-by-call.profile_id) COLUMN-LABEL "Имеет объектный!контекст" FORMAT "+/"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10
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
has-object-context(X_rule-by-call.profile_id) COLUMN-LABEL "Имеет объектный!контекст" FORMAT "+/"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 10
         FONT 4
         TITLE "Правила" ROW-HEIGHT-CHARS .67.

DEFINE BROWSE BR-thbj-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-thbj-attr Dialog-Frame _FREEFORM
  QUERY BR-thbj-attr DISPLAY
      get-region(0, buf_thbj-attr.obj-type, buf_thbj-attr.obj-code) COLUMN-LABEL "Действует" FORMAT "X(15)"
 get-prop-label(buf_thbj-attr.upper-prop-code, buf_thbj-attr.prop-code) COLUMN-LABEL "Вид алгоритмов" FORMAT "X(255)" width 70
buf_thbj-attr.property-value-logical COLUMN-LABEL "Активен" FORMAT "+/"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 8 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-chg AT ROW 1 COL 41
     b-quit AT ROW 1 COL 1
     b-add AT ROW 1 COL 31 WIDGET-ID 26
     rs-active AT ROW 1 COL 54.5 NO-LABEL WIDGET-ID 28
     b-ruleproc AT ROW 1 COL 79 WIDGET-ID 24
     B-Help AT ROW 1 COL 95
     BR-thbj-attr AT ROW 2 COL 1 WIDGET-ID 300
     Rs-algo-profile AT ROW 10 COL 1 NO-LABEL WIDGET-ID 16
     rs-algo-types AT ROW 10 COL 28.5 NO-LABEL WIDGET-ID 20
     b-rule AT ROW 10 COL 64.5 WIDGET-ID 14
     b-params AT ROW 10 COL 74.5 WIDGET-ID 6
     B-ruleset AT ROW 10 COL 84.5 WIDGET-ID 12
     br-rule-by-call AT ROW 11 COL 1 WIDGET-ID 100
     br-profile AT ROW 11 COL 1 WIDGET-ID 200
     E-rule-name AT ROW 21.47 COL 1 NO-LABEL WIDGET-ID 2
     SPACE(0.29) SKIP(0.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Машина правил (встраиваемые проц-ры)"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_thbj-attr B "NEW SHARED" ? ub thbj-attr
      TABLE: tt0-rule-call-param T "NEW SHARED" NO-UNDO ub rule-call-param
      TABLE: Xobj_clients B "?" ? ub clients
      TABLE: X_clients B "?" ? ub clients
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule-by-call B "?" ? ub rule-by-call
      TABLE: X_rule-profile B "?" ? ub rule-profile
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-thbj-attr B-Help Dialog-Frame */
/* BROWSE-TAB br-rule-by-call B-ruleset Dialog-Frame */
/* BROWSE-TAB br-profile br-rule-by-call Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-chg IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-rule:HANDLE.

ASSIGN
       b-ruleproc:POPUP-MENU IN FRAME Dialog-Frame       = MENU menu-b-ruleproc:HANDLE.

ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-profile
/* Query rebuild information for BROWSE br-profile
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_rp-by-call WHERE
         X_rp-by-call.call_id = v-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_rule-by-call.call_id = v-uniq-key-rec"
     _Query            is OPENED
*/  /* BROWSE br-profile */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-call
/* Query rebuild information for BROWSE br-rule-by-call
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_rule-by-call
      WHERE X_rule-by-call.call_id = v-uniq-key-rec,
    FIRST X_rule-profile NO-LOCK WHERE
         X_rule-profile.profile_id = X_rule-by-call.profile_id
     AND (rs-algo-types = 1 OR
         X_rule-profile.is_dynamic = yes)
BY X_rule-by-call.codex_id
BY X_rule-by-call.ruleset_id
BY X_rule-by-call.order_id INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_rule-by-call.call_id = v-uniq-key-rec"
     _Query            is OPENED
*/  /* BROWSE br-rule-by-call */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-thbj-attr
/* Query rebuild information for BROWSE BR-thbj-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH buf_thbj-attr WHERE
    buf_thbj-attr.obj-type = p-obj-type
AND buf_thbj-attr.obj-code = p-obj-code, FIRST X_clients NO-LOCK
                                                    .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-thbj-attr */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Машина правил (встраиваемые проц-ры) */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add Dialog-Frame
ON CHOOSE OF b-add IN FRAME Dialog-Frame /* Добавить */
DO:

  IF prop-option = '':U THEN DO:
    run gbl/pop-up.p ( INPUT SELF :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if prop-option = "":U then do:
      return no-apply.
  end.
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT prop-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      prop-option = ''.
      RETURN NO-APPLY.
  END.
  prop-option = ''.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
  DEFINE VARIABLE v-code AS integer NO-UNDO.
  define variable v-name as character no-undo.
  DEFINE VARIABLE v-log AS logical NO-UNDO.
  DEFINE variable v-rid AS RECID NO-UNDO.
  define variable v-rec as recid no-undo .
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define variable v-host-code as integer no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-param-type as character no-undo .
  define variable v-tbl-row as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  define buffer buf_thbj-attr for ub.thbj-attr.
  if p-obj-type = {&shop}
  or p-obj-type = {&stock} then do:
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  end.
  run gen-row-keyr in this-procedure (
                                        input  v-uniq-key-rec
                                      ,input  ? /* p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                      ,input  "ub"
                                      ,input  ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                      ,input  NO-LOCK
                                      ,output v-tbl-row
                                      ,output v-tbl-name
                                      ).
  find first buf_thbj-attr no-lock where
            rowid(buf_thbj-attr) = v-tbl-row no-error.
  v-rec = recid(buf_thbj-attr).
  run adm/thbj-rum.w (
                       input parparentproc
                      ,input p-mode
                      ,input v-host-code
                      ,input (if buf_thbj-attr.obj-type = {&shop}
                              or buf_thbj-attr.obj-type = {&stock}
                              then buf_thbj-attr.obj-type
                              else '')
                      ,input (if buf_thbj-attr.obj-type = {&shop}
                             or buf_thbj-attr.obj-type = {&stock}
                             then buf_thbj-attr.obj-code
                             else 0)
                      ,input buf_thbj-attr.prop-code
                      ,input v-uniq-key-rec) no-error.
  run openbr in this-procedure ( input rs-active).
  reposition br-thbj-attr to recid v-rec no-error.
  apply "entry" to br-thbj-attr.
  APPLY "VALUE-CHANGED" to browse br-thbj-attr.
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
      IF ERROR-STATUS:ERROR THEN do:
        message
        error-status:get-message(1)
        view-as alert-box .
        return no-apply.
      end.
    end.
  end case.

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
  IF NOT AVAILABLE buf_thbj-attr THEN RETURN NO-APPLY.

IF rule-proc-option = '':U THEN DO:
   run gbl/pop-up.p ( INPUT SELF:handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
end.
if rule-proc-option = "":U then do:
      return no-apply.
end.
run rule-proc IN THIS-PROCEDURE ( v-uniq-key-rec, INPUT rule-proc-option) no-error .
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


&Scoped-define BROWSE-NAME BR-thbj-attr
&Scoped-define SELF-NAME BR-thbj-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-thbj-attr Dialog-Frame
ON VALUE-CHANGED OF BR-thbj-attr IN FRAME Dialog-Frame
DO:

  IF NOT AVAILABLE buf_thbj-attr THEN v-uniq-key-rec = ''.
  RUN gen-key-rec IN THIS-PROCEDURE (
   input  {&table_thbj-attr}
  ,INPUT (BUFFER buf_thbj-attr:handle)
  ,OUTPUT v-uniq-key-rec) no-error.
   RUN proc-value-changed IN THIS-PROCEDURE NO-ERROR.
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


&Scoped-define SELF-NAME m_proc_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_proc_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_proc_graph /* Графика */
DO:
  IF NOT AVAILABLE buf_thbj-attr THEN RETURN NO-APPLY.
  ASSIGN
  rule-proc-option = "graph".
  run rule-proc IN THIS-PROCEDURE ( v-uniq-key-rec, INPUT rule-proc-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      rule-proc-option = '':U.
      RETURN NO-APPLY.
  END.
  rule-proc-option = '':U.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_proc_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_proc_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_proc_text /* Текст */
DO:
   IF NOT AVAILABLE buf_thbj-attr THEN RETURN NO-APPLY.
  ASSIGN
  rule-proc-option = "text".
  run rule-proc IN THIS-PROCEDURE ( INPUT v-uniq-key-rec, INPUT rule-proc-option) NO-ERROR.
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


&Scoped-define SELF-NAME rs-active
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-active Dialog-Frame
ON VALUE-CHANGED OF rs-active IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-active .
  RUN openbr IN THIS-PROCEDURE ( INPUT rs-active).
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


&Scoped-define BROWSE-NAME br-profile
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

DEFINE MENU MENU-b-add .

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
{ gbl/getcntxt.i get }
{ ref/tabhndmv.i v-tab-order underline-tb }
  IF p-mode <> {&lookup}
  and p-mode <> {&update} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-list-mode <> {&all}
  and p-list-mode <> {&g___object}
  AND p-list-mode <> {&db} THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-list-mode" p-list-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  if p-mode <> {&lookup}
  and v-cntxt-db-num > 0
  and (p-obj-type = '' and p-obj-code = 0)
  then do:
    message
    "Нельзя изменять настройки в УБД"
    view-as alert-box error .
    undo, return error .
  end.
  IF p-obj-type <> {&shop}
  and p-obj-type <> {&cmp}
  and p-obj-type <> '':U
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-obj-type" p-obj-type
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.

  if p-obj-type = {&shop}
  or p-obj-type = {&stock}
  then do:
    FIND FIRST Xobj_clients NO-LOCK WHERE
             Xobj_clients.obj-code = p-obj-code
         and Xobj_clients.obj-type = p-obj-type
             NO-ERROR.
    IF NOT AVAILABLE Xobj_clients THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code/p-obj-type" p-obj-code p-obj-type
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    { gbl/objdbnum.i Xobj_clients.obj-type Xobj_clients.obj-code v-db-num }
    IF v-db-num <> v-cntxt-db-num
    AND v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    THEN DO:
        MESSAGE
        "Нельзя менять параметры магазина в чужой БД" skip
        "магазин принадлежит БД" v-db-num "текущая БД" v-cntxt-db-num
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.

    END.
    { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
    v-current-upper-prop-code = p-obj-upper-code.
  end.
  if p-obj-type = {&cmp} then do:
    FIND FIRST X_sysconf NO-LOCK WHERE X_sysconf.host-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE X_sysconf THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-obj-code" p-obj-code
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    END.
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять параметры ФИРМЫ в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
    v-host-code = p-obj-code.
  end.
  if p-obj-type = '':U then do:
    if v-cntxt-db-num <> 0
    and p-mode <> {&lookup}
    then do:
        MESSAGE
        "Нельзя менять ГЛОБАЛЬНЫЕ параметры в УБД" skip
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
    end.
    v-current-upper-prop-code = p-upper-code.
  end.
  IF p-mode = {&UPDATE} THEN DO:
    do transaction:
      FIND FIRST LOCKED_thbj-attr EXCLUSIVE-LOCK WHERE
                LOCKED_thbj-attr.obj-type = p-obj-type
          AND   LOCKED_thbj-attr.obj-code = p-obj-code
          AND   LOCKED_thbj-attr.upper-prop-code = v-current-upper-prop-code
          AND   locked_thbj-attr.prop-code = '':U NO-ERROR.
      if locked locked_thbj-attr then do:
          message
          vss-workfile vss-revision vss-description skip
          "Запись ПАРАМЕТРЫ(АТРИБУТЫ) МАГАЗИНА занята"
          view-as alert-box error .
          undo, return error.
        end.
     end.
  END.
  ELSE DO:
      FIND FIRST LOCKED_thbj-attr no-LOCK WHERE
          LOCKED_thbj-attr.obj-type = p-obj-type
    AND   LOCKED_thbj-attr.obj-code = p-obj-code
    AND   LOCKED_thbj-attr.upper-prop-code = v-current-upper-prop-code
    AND   locked_thbj-attr.prop-code = '':U NO-ERROR.
  END.
  if not available locked_thbj-attr then do:
    ASSIGN
    v-to-create  = YES.
    message
    substitute ("Внимание!!!&1Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
    view-as alert-box WARNING.
  end.
  /*получим пересечение списков*/
  { ref/attr-pop.i prepare }
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.
run attr-pop-clean-up in this-procedure ( input {&table_thbj-attr} ).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-edit Dialog-Frame
PROCEDURE choose-to-edit :
define input parameter p-upper-code as character no-undo .
define input parameter p-attr-code as character no-undo .

assign
prop-option = p-attr-code
.
APPLY "CHOOSE" to b-add in frame {&frame-name} .
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
  DISPLAY rs-active Rs-algo-profile rs-algo-types E-rule-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-add rs-active b-ruleproc B-Help BR-thbj-attr Rs-algo-profile
         rs-algo-types b-rule b-params B-ruleset br-rule-by-call br-profile
         E-rule-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
define variable v-entry as character no-undo .
define variable v-label as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-tooltip-code as character no-undo .
ASSIGN
   b-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-add:HANDLE.
do ii = 1 to num-entries(p-prop-list-global):
  v-entry = entry(ii, p-prop-list-global).
  run thbjattr_tooltip in this-procedure ( input  p-upper-code
                                          ,input  v-entry
                                          ,output v-tooltip
                                          ,output v-label
                                          ,output v-tooltip-code  ) .
  assign
  frame {&frame-name}:title = substitute("&1 &2", frame {&frame-name}:title, v-tooltip-code).
end.

run attr-pop-create-items in this-procedure  (
                                              input {&table_thbj-attr}
                                              ,input 'thbjattr_manual-edit'   /*p-get-section-num-proc-name*/
                                              ,input 'thbjattr_tooltip'
                                              ,input 'choose-to-edit'
                                              ,input menu menu-b-add:handle
                                              ,input p-upper-code
                                              ,input p-prop-list-global
                                            ).

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
                                "Правила" + {&comma-char} + {&TABLE_rule-by-call}
rs-algo-profile = {&TABLE_rp-by-call}
b-add:MENU-MOUSE = 1  .
ASSIGN
X_rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES
b-rule:menu-mouse in frame {&frame-name} = 1
b-ruleproc:menu-mouse in frame {&frame-name} = 1
.
DISPLAY
rs-algo-profile
rs-algo-types
WITH FRAME {&FRAME-NAME}.
ASSIGN
v-tab-order = "b-chg".
ENABLE
b-quit
B-Help
rs-active
b-chg when p-mode = {&update}
b-add when p-mode = {&update}
BR-thbj-attr
br-rule-by-call
br-profile
b-params
b-rule
b-ruleset
b-ruleproc
rs-algo-types
rs-algo-profile
br-thbj-attr
e-rule-name
WITH FRAME {&frame-name}.
VIEW FRAME {&frame-name}.
IF p-mode = {&LOOKUP} THEN DO:
    ASSIGN
    b-quit:LABEL = "&Выход"
    .
END.
run Openbr in this-procedure ( input no).
APPLY "ENTRY" TO br-thbj-attr.
APPLY "VALUE-CHANGED" TO br-thbj-attr.
APPLY "VALUE-CHANGED" TO rs-algo-profile.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input parameter p-active as logical no-undo .
case p-active :
  when yes then do:
    CASE p-list-mode:
      WHEN {&ALL} THEN DO:
          OPEN QUERY br-thbj-attr
      FOR EACH buf_thbj-attr no-lock WHERE
          ((buf_thbj-attr.upper-prop-code = p-upper-code
      AND lookup(buf_thbj-attr.prop-code, p-prop-list-global) > 0)
          or
          (buf_thbj-attr.upper-prop-code = p-obj-upper-code
          and
          lookup(buf_thbj-attr.prop-code, p-prop-list-obj) > 0))
      AND
          buf_thbj-attr.property-value-logical =  yes
          ,
          FIRST X_clients NO-LOCK            .
      END.
      WHEN {&db} THEN DO:
          OPEN QUERY br-thbj-attr
      FOR EACH buf_thbj-attr no-lock WHERE
          ((buf_thbj-attr.upper-prop-code = p-upper-code
      AND lookup(buf_thbj-attr.prop-code, p-prop-list-global) > 0)
          or
          (buf_thbj-attr.upper-prop-code = p-obj-upper-code
          and
          lookup(buf_thbj-attr.prop-code, p-prop-list-obj) > 0))
      AND
          buf_thbj-attr.property-value-logical =  yes
          ,
          FIRST X_clients NO-LOCK WHERE
              X_clients.obj-code = buf_thbj-attr.obj-code
          AND X_clients.obj-type = buf_thbj-attr.obj-type
          AND X_clients.db-num = v-cntxt-db-num.
      END.
      WHEN {&g___object} THEN DO:
              OPEN QUERY br-thbj-attr
          FOR EACH buf_thbj-attr no-lock WHERE
              buf_thbj-attr.obj-type = p-obj-type
          AND buf_thbj-attr.obj-code = p-obj-code
          AND buf_thbj-attr.upper-prop-code = p-obj-upper-code
          AND lookup(buf_thbj-attr.prop-code, p-prop-list-obj) > 0
              and buf_thbj-attr.property-value-logical = p-active
              ,
                  FIRST X_clients NO-LOCK WHERE
                  X_clients.obj-type = buf_thbj-attr.obj-type
              AND X_clients.obj-code = buf_thbj-attr.obj-code
              AND X_clients.db-num = v-cntxt-db-num.

          END.

    END CASE.
  end.
  when no then do:
    CASE p-list-mode:
      WHEN {&ALL} THEN DO:
          OPEN QUERY br-thbj-attr
      FOR EACH buf_thbj-attr no-lock WHERE
          ((buf_thbj-attr.upper-prop-code = p-upper-code
      AND lookup(buf_thbj-attr.prop-code, p-prop-list-global) > 0)
          or
          (buf_thbj-attr.upper-prop-code = p-obj-upper-code
          and
          lookup(buf_thbj-attr.prop-code, p-prop-list-obj) > 0))
          ,
          FIRST X_clients NO-LOCK            .

      END.
      WHEN {&db} THEN DO:
          OPEN QUERY br-thbj-attr
      FOR EACH buf_thbj-attr no-lock WHERE
          ((buf_thbj-attr.upper-prop-code = p-upper-code
      AND lookup(buf_thbj-attr.prop-code, p-prop-list-global) > 0)
          or
          (buf_thbj-attr.upper-prop-code = p-obj-upper-code
          and
          lookup(buf_thbj-attr.prop-code, p-prop-list-obj) > 0))
          ,
          FIRST X_clients NO-LOCK  WHERE
              X_clients.obj-code = buf_thbj-attr.obj-code
          AND X_clients.obj-type = buf_thbj-attr.obj-type
          AND X_clients.db-num = v-cntxt-db-num.
      END.
      WHEN {&g___object} THEN DO:
              OPEN QUERY br-thbj-attr
          FOR EACH buf_thbj-attr no-lock WHERE
              buf_thbj-attr.obj-type = p-obj-type
          AND buf_thbj-attr.obj-code = p-obj-code
          AND buf_thbj-attr.upper-prop-code = p-obj-upper-code
          AND lookup(buf_thbj-attr.prop-code, p-prop-list-obj) > 0
              ,
                  FIRST X_clients NO-LOCK WHERE
                  X_clients.obj-type = buf_thbj-attr.obj-type
              AND X_clients.obj-code = buf_thbj-attr.obj-code
              AND X_clients.db-num = v-cntxt-db-num.

          END.

    END CASE.

  end.
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT PARAMETER prop-option AS CHARACTER NO-UNDO.
define variable v-rid-list as character no-undo .
define variable v-loc-uniq-key-rec as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character AS character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical as logical no-undo .
define variable v-recid as recid no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.

define buffer bufobj_clients for ub.clients.

    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-sel"
        , input {&all}
        , input '' /*p-obj-type*/
        , input ? /*p-db-num*/
        , input ? /*p-host-code*/
        , input-output v-rid-list ) no-error .

  if v-rid-list = '':U
  or v-rid-list = string(recid(bufobj_clients)) then return error.
  find first bufobj_clients no-lock where
            recid(bufobj_clients) = integer(v-rid-list) no-error.
  if not available bufobj_clients then return ERROR.
  /*проверим есть ли thbj-attr - считаем*/
  run adm/shattri.p (
                input "init":U
              , input bufobj_clients.obj-type
              , input bufobj_clients.obj-code
              , input p-obj-upper-code
              , input ''
              , output v-value-character
              , output v-value-date
              , output v-value-decimal
              , output v-value-integer
              , output v-value-logical
              , output v-param-type
              , INPUT-OUTPUT TABLE-handle v-tth
              ) no-error .
  if error-status:error then do:
    message
    "Не удалось получить начальные значения настроек" skip
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo, return ERROR.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = bufobj_clients.obj-type
       and thbjattr_thbj-attr.obj-code = bufobj_clients.obj-code
       and thbjattr_thbj-attr.upper-prop-code = p-obj-upper-code
       and thbjattr_thbj-attr.prop-code = prop-option.
  RUN gen-key-rec IN THIS-PROCEDURE (
   input  {&table_thbj-attr}
  ,INPUT (BUFFER thbjattr_thbj-attr:handle)
  ,OUTPUT v-loc-uniq-key-rec) no-error.

  run thbjattr_write in this-procedure (
                                          input  bufobj_clients.obj-type
                                        ,input  bufobj_clients.obj-code
                                        ,input  p-obj-upper-code
                                        ,input  prop-code
                                        ,input  thbjattr_thbj-attr.property-value-character
                                        ,input  thbjattr_thbj-attr.property-value-date
                                        ,input  thbjattr_thbj-attr.property-value-decimal
                                        ,input  thbjattr_thbj-attr.property-value-integer
                                        ,input  thbjattr_thbj-attr.property-value-logical
                                          ) no-error .
  IF ERROR-STATUS:error THEN do:
    MESSAGE ERROR-STATUS:get-message(1)  SKIP
    RETURN-VALUE
    VIEW-AS ALERT-BOX.
    UNDO, RETURN ERROR.
  END.
  run adm/thbj-rum.w (
                       input parparentproc
                      ,input p-mode
                      ,input v-host-code
                      ,input bufobj_clients.obj-type
                      ,input bufobj_clients.obj-code
                      ,input prop-option
                      ,input v-loc-uniq-key-rec) no-error.
  run openbr in this-procedure ( input rs-active).
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.prop-code = thbjattr_thbj-attr.prop-code
        and buf_thbj-attr.upper-prop-code = thbjattr_thbj-attr.upper-prop-code
        and buf_thbj-attr.obj-type = thbjattr_thbj-attr.obj-type
        and buf_thbj-attr.obj-code = thbjattr_thbj-attr.obj-code no-error .
  assign
  v-recid = recid(buf_thbj-attr).
  reposition br-thbj-attr to recid v-recid no-error.
  APPLy "ENTRY" to br-thbj-attr in frame {&frame-name} .
  APPLY "VALUE-CHANGED" to browse br-thbj-attr.

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
DEFINE INPUT PARAMETER p-uniq-key-rec AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
run rul/run-rule-proc-view.p ( INPUT buf_thbj-attr.prop-code
                              ,INPUT p-uniq-key-rec
                              ,INPUT 0 /*p-profile-id*/
                              ,INPUT p-option
                              ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-dynamic Dialog-Frame
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( INPUT p-profile-id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile-id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ?.   /* Function return value. */
RETURN buf_rule-profile.is_dynamic.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-profile-name Dialog-Frame
FUNCTION get-profile-name RETURNS CHARACTER
  ( INPUT p-profile-id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile-id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN {&question-mark}.   /* Function return value. */
RETURN buf_rule-profile.NAME.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-prop-label Dialog-Frame
FUNCTION get-prop-label RETURNS CHARACTER
  ( INPUT p-upper-prop-code AS character
  ,INPUT p-prop-code AS character ) :
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-label AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip-code AS CHARACTER NO-UNDO.
run thbjattr_tooltip IN THIS-PROCEDURE (
  input  p-upper-prop-code
 ,INPUT p-prop-code
  ,OUTPUT v-tooltip
  ,OUTPUT v-label
  ,OUTPUT v-tooltip-code ) NO-ERROR.
RETURN entry(2, v-label, ":").   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION has-object-context Dialog-Frame
FUNCTION has-object-context RETURNS LOGICAL
  ( INPUT p-profile-id AS INTEGER ) :
define BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile WHERE buf_rule-profile.profile_id = p-profile-id NO-ERROR.
IF AVAILABLE buf_rule-profile THEN DO:
    RETURN LOOKUP("obj", buf_rule-profile.short-name) > 0.
END.
RETURN ?.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME