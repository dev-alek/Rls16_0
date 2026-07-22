&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE temp-dc-type NO-UNDO LIKE ub.dis-card-type.
DEFINE TEMP-TABLE tt-2-hist-nws-option NO-UNDO LIKE ub.hist-nws-option.
DEFINE TEMP-TABLE tt-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-dis-dct-rule NO-UNDO LIKE ub.dis-dct-rule.
DEFINE TEMP-TABLE tt0-hist-nws-option NO-UNDO LIKE ub.hist-nws-option.
DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt2-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка типа дисконтной карты

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
define input parameter p-mode as char no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input-output param rid as recid init ? no-undo.
/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка типа дисконтной карты" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }

{ cmp/operlist.i }
{ ref/dcthnfll.i }
define variable old-emitent-host-code like ub.dis-card-type.emitent-host-code no-undo.
define variable v-r-b-code like ub.currency.curr-code no-undo .
define variable v-curr-r-b  as character no-undo .
{ gbl/1bascur.i }
{ gbl/key-rec.i }
{ rul/calldscr.i }
{ ref/dc-typei.i }

define variable add-option as character no-undo.
&SCOP dc-d-pcnt-code temp-dc-type.dflt-d-pcnt-method

&SCOPED-DEFINE default-glob-val-rs-value "{&abbr_rub_firstshift}." + ~{&comma-char~} + ~{&r-b-rubl~} + {&comma-char} + "Баз.вал." + ~{&comma-char~} + ~{&r-b-base~}

DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO EXTENT 3.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
define variable v-start as logical no-undo .

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
&Scoped-define INTERNAL-TABLES tt0-rp-by-call tt0-rule-by-call ~
X_rule-profile temp-dc-type

/* Definitions for BROWSE br-profile                                    */
&Scoped-define FIELDS-IN-QUERY-br-profile tt0-rp-by-call.profile_id get-profile-name ( INPUT tt0-rp-by-call.profile_id) get-profile-dynamic ( INPUT tt0-rp-by-call.profile_id) tt0-rp-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-profile
&Scoped-define SELF-NAME br-profile
&Scoped-define QUERY-STRING-br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-profile OPEN QUERY {&SELF-NAME} FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-profile tt0-rp-by-call
&Scoped-define FIRST-TABLE-IN-QUERY-br-profile tt0-rp-by-call


/* Definitions for BROWSE br-rule-by-call                               */
&Scoped-define FIELDS-IN-QUERY-br-rule-by-call tt0-rule-by-call.can-calc tt0-rule-by-call.algo-des tt0-rule-by-call.is_dynamic tt0-rule-by-call.codex_id tt0-rule-by-call.ruleset_id tt0-rule-by-call.order_id tt0-rule-by-call.rule_id tt0-rule-by-call.profile_id tt0-rule-by-call.once-more
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&Scoped-define QUERY-STRING-br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-rule-by-call OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec, ~
           FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-rule-by-call tt0-rule-by-call ~
X_rule-profile
&Scoped-define FIRST-TABLE-IN-QUERY-br-rule-by-call tt0-rule-by-call
&Scoped-define SECOND-TABLE-IN-QUERY-br-rule-by-call X_rule-profile


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame temp-dc-type.type ~
temp-dc-type.emitent-host-code temp-dc-type.d-pcnt-byshop ~
temp-dc-type.dflt-credit-card temp-dc-type.dflt-debet-card ~
temp-dc-type.dflt-staff-card temp-dc-type.card-media temp-dc-type.lim-kr ~
temp-dc-type.fiscal-pay temp-dc-type.mixed-pay temp-dc-type.dcbyshop
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame temp-dc-type.type ~
temp-dc-type.emitent-host-code temp-dc-type.d-pcnt-byshop ~
temp-dc-type.dflt-credit-card temp-dc-type.dflt-debet-card ~
temp-dc-type.dflt-staff-card temp-dc-type.card-media temp-dc-type.lim-kr ~
temp-dc-type.fiscal-pay temp-dc-type.mixed-pay temp-dc-type.dcbyshop
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame temp-dc-type
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame temp-dc-type
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-profile}~
    ~{&OPEN-QUERY-br-rule-by-call}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH temp-dc-type SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH temp-dc-type SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame temp-dc-type
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame temp-dc-type


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS temp-dc-type.type ~
temp-dc-type.emitent-host-code temp-dc-type.d-pcnt-byshop ~
temp-dc-type.dflt-credit-card temp-dc-type.dflt-debet-card ~
temp-dc-type.dflt-staff-card temp-dc-type.card-media temp-dc-type.lim-kr ~
temp-dc-type.fiscal-pay temp-dc-type.mixed-pay temp-dc-type.dcbyshop
&Scoped-define ENABLED-TABLES temp-dc-type
&Scoped-define FIRST-ENABLED-TABLE temp-dc-type
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-3 RECT-4 B-exit b-quit B-mask ~
b-hn b-cd b-prop-ref b-disc B-history B-Help T-check-by-mask T-ho-join ~
B-emitent f-dflt-pcnt B-def-pcnt b-d-pcnt-byshop f-dflt-cash-pcnt ~
f-dflt-pcnt-kat B-def-cash-pcnt B-def-categ v-dflt-d-pcnt-method b-addalgo ~
b-delalgo b-params B-rule B-ruleset b-rule-on-off Rs-algo-profile ~
rs-algo-types br-rule-by-call br-profile E-rule-name B-cashpay B-dcbyshop ~
emitent-name var-r-b-abbr
&Scoped-Define DISPLAYED-FIELDS temp-dc-type.type ~
temp-dc-type.emitent-host-code temp-dc-type.d-pcnt-byshop ~
temp-dc-type.dflt-credit-card temp-dc-type.dflt-debet-card ~
temp-dc-type.dflt-staff-card temp-dc-type.card-media temp-dc-type.lim-kr ~
temp-dc-type.fiscal-pay temp-dc-type.mixed-pay temp-dc-type.dcbyshop
&Scoped-define DISPLAYED-TABLES temp-dc-type
&Scoped-define FIRST-DISPLAYED-TABLE temp-dc-type
&Scoped-Define DISPLAYED-OBJECTS T-check-by-mask T-ho-join f-dflt-pcnt ~
f-dflt-cash-pcnt f-dflt-pcnt-kat v-dflt-d-pcnt-method Rs-algo-profile ~
rs-algo-types E-rule-name f-cash-pay-name emitent-name var-r-b-abbr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

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
DEFINE MENU MENU-B-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Граф"          .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-addalgo
     LABEL "Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-cashpay
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-cd
     LABEL "На кассу"
     SIZE 10 BY 1.

DEFINE BUTTON b-d-pcnt-byshop
     LABEL "Все скидки по умолч."
     SIZE 22 BY 1.

DEFINE BUTTON B-dcbyshop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-def-cash-pcnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-def-categ
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-def-pcnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-delalgo
     LABEL "Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON b-disc
     LABEL "Пр-ла скидок"
     SIZE 15 BY 1.

DEFINE BUTTON B-emitent
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-hn
     LABEL "Маршрутиз. и ист."
     SIZE 20 BY 1.

DEFINE BUTTON B-mask
     LABEL "&Маски"
     SIZE 10 BY 1.

DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.

DEFINE BUTTON b-prop-ref
     LABEL "Итоги/Срезы"
     SIZE 15 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-rule
     LABEL "Правило"
     SIZE 10 BY 1.

DEFINE BUTTON b-rule-on-off
     LABEL "Вкл"
     SIZE 5 BY 1.

DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.

DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.17
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE emitent-name AS CHARACTER FORMAT "X(25)":U
      VIEW-AS TEXT
     SIZE 47.88 BY 1 NO-UNDO.

DEFINE VARIABLE f-cash-pay-name LIKE ub.cash-pay.obj-name
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE f-dflt-cash-pcnt AS DECIMAL FORMAT "->>9.99" INITIAL 0
     LABEL "%скидки по умолч. на итог чека"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 TOOLTIP "Используется только для POS NCR и IBS TH POS".

DEFINE VARIABLE f-dflt-pcnt AS DECIMAL FORMAT "->>9.99" INITIAL 0
     LABEL "%скидки по умолч. на товары"
     VIEW-AS FILL-IN
     SIZE 7 BY 1.

DEFINE VARIABLE f-dflt-pcnt-kat AS INTEGER FORMAT ">9" INITIAL 0
     LABEL "Катег. по умолч."
     VIEW-AS FILL-IN
     SIZE 6 BY 1.

DEFINE VARIABLE var-r-b-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 9.5 BY 1 NO-UNDO.

DEFINE VARIABLE Rs-algo-profile AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-algo-types AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Настраив.", 2
     SIZE 18 BY .75 NO-UNDO.

DEFINE VARIABLE v-dflt-d-pcnt-method AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 4", "3"
     SIZE 39.88 BY .88 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.5 BY 2.54.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 74.25 BY 3.79.

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23 BY 4.75.

DEFINE VARIABLE T-check-by-mask AS LOGICAL INITIAL no
     LABEL "Пров. № ДК по маске"
     VIEW-AS TOGGLE-BOX
     SIZE 22.5 BY .75 TOOLTIP "Проверка номеров при вводе ДК по маске, действующей на фирме/объекте" NO-UNDO.

DEFINE VARIABLE T-ho-join AS LOGICAL INITIAL no
     LABEL "Привязка по фирме/объекту"
     VIEW-AS TOGGLE-BOX
     SIZE 28 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-profile FOR
      tt0-rp-by-call SCROLLING.

DEFINE QUERY br-rule-by-call FOR
      tt0-rule-by-call,
      X_rule-profile SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      temp-dc-type SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-profile
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-profile Dialog-Frame _FREEFORM
  QUERY br-profile NO-LOCK DISPLAY
      tt0-rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9":U
get-profile-name ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Название алгоритма" FORMAT "X(255)"
get-profile-dynamic ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
tt0-rp-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.75
         FONT 4 ROW-HEIGHT-CHARS .67.

DEFINE BROWSE br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-rule-by-call Dialog-Frame _FREEFORM
  QUERY br-rule-by-call NO-LOCK DISPLAY
      tt0-rule-by-call.can-calc COLUMN-LABEL "Вкл." FORMAT "+/":U
tt0-rule-by-call.algo-des COLUMN-LABEL "Описание алгоритма/правила" FORMAT "X(255)":U WIDTH 40
tt0-rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое?" FORMAT "+/":U
tt0-rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
tt0-rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>,>>>,>>9":U WIDTH 9
tt0-rule-by-call.profile_id COLUMN-LABEL "Алгоритм" FORMAT ">>9":U WIDTH 8
tt0-rule-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.75
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-mask AT ROW 1 COL 21
     b-hn AT ROW 1 COL 31
     b-cd AT ROW 1 COL 51 WIDGET-ID 10
     b-prop-ref AT ROW 1 COL 61 WIDGET-ID 8
     b-disc AT ROW 1 COL 76 WIDGET-ID 12
     B-history AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     temp-dc-type.type AT ROW 2.13 COL 10.25 COLON-ALIGNED
          LABEL "Тип карты"
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Буквенно-цифровой код типа карты"
          FGCOLOR 4
     T-check-by-mask AT ROW 2.25 COL 23.5
     T-ho-join AT ROW 2.25 COL 47
     temp-dc-type.emitent-host-code AT ROW 3.38 COL 10.25 COLON-ALIGNED
          LABEL "Эмитент"
		  FORMAT ">>>>>>>>99"
          VIEW-AS FILL-IN
          SIZE 10 BY 1 TOOLTIP "Код фирмы эмитента или 0 (если карта глобальна)"
          FGCOLOR 4
     B-emitent AT ROW 3.42 COL 23.13
     f-dflt-pcnt AT ROW 4.46 COL 32 COLON-ALIGNED
     temp-dc-type.d-pcnt-byshop AT ROW 4.46 COL 47.5 WIDGET-ID 20
          LABEL "Скидка/катег. по объектам"
          VIEW-AS TOGGLE-BOX
          SIZE 27.63 BY 1 TOOLTIP "Процент скидки дифференциирован по объектам и фирмам"
     B-def-pcnt AT ROW 4.5 COL 41.5 WIDGET-ID 14
     b-d-pcnt-byshop AT ROW 4.5 COL 76 WIDGET-ID 24
     f-dflt-cash-pcnt AT ROW 5.46 COL 32 COLON-ALIGNED
     f-dflt-pcnt-kat AT ROW 5.46 COL 64 COLON-ALIGNED
     B-def-cash-pcnt AT ROW 5.5 COL 41.5 WIDGET-ID 16
     B-def-categ AT ROW 5.5 COL 72.5 WIDGET-ID 18
     v-dflt-d-pcnt-method AT ROW 6.58 COL 34.13 NO-LABEL
     b-addalgo AT ROW 7.67 COL 40
     b-delalgo AT ROW 7.67 COL 50
     b-params AT ROW 7.67 COL 60 WIDGET-ID 6
     B-rule AT ROW 7.67 COL 70
     B-ruleset AT ROW 7.67 COL 80 WIDGET-ID 26
     b-rule-on-off AT ROW 7.67 COL 94
     Rs-algo-profile AT ROW 7.75 COL 1 NO-LABEL WIDGET-ID 2
     rs-algo-types AT ROW 7.75 COL 22 NO-LABEL
     br-rule-by-call AT ROW 8.75 COL 1
     br-profile AT ROW 8.75 COL 1 WIDGET-ID 100
     E-rule-name AT ROW 14.75 COL 1 NO-LABEL
     temp-dc-type.dflt-credit-card AT ROW 17.13 COL 2
          LABEL "Кредитная карта"
          VIEW-AS TOGGLE-BOX
          SIZE 19.5 BY 1
     temp-dc-type.dflt-debet-card AT ROW 17.13 COL 24.5
          LABEL "Дебетовая карта"
          VIEW-AS TOGGLE-BOX
          SIZE 21 BY 1
     temp-dc-type.dflt-staff-card AT ROW 17.13 COL 46
          LABEL "Карта персонала"
          VIEW-AS TOGGLE-BOX
          SIZE 21 BY 1
     temp-dc-type.card-media AT ROW 18 COL 77 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2,
"Item 3", 3,
"Item 4", 4
          SIZE 21.5 BY 3.42
     temp-dc-type.lim-kr AT ROW 18.25 COL 24.5 COLON-ALIGNED
          LABEL "Лимит кредита по умолч."
          VIEW-AS FILL-IN
          SIZE 24.13 BY 1
     temp-dc-type.fiscal-pay AT ROW 19.5 COL 3
          LABEL "Фиск-ный пл-ж"
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY 1
     temp-dc-type.mixed-pay AT ROW 19.5 COL 19.5
          LABEL "Разр.смеш.оплату"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     B-cashpay AT ROW 19.5 COL 46.5
     f-cash-pay-name AT ROW 19.5 COL 48 COLON-ALIGNED HELP
          "" NO-LABEL
     B-dcbyshop AT ROW 22 COL 72
     emitent-name AT ROW 3.38 COL 24.75 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     var-r-b-abbr AT ROW 18.25 COL 54.38 COLON-ALIGNED NO-LABEL
     temp-dc-type.dcbyshop AT ROW 22 COL 2 NO-LABEL
           VIEW-AS TEXT
          SIZE 69.5 BY 1
     "Использование процента скидки" VIEW-AS TEXT
          SIZE 30.63 BY 1 AT ROW 6.58 COL 2.75
     "Магазины, принимающие только СВОИ карты" VIEW-AS TEXT
          SIZE 52.25 BY 1 TOOLTIP "Магазины, принимающие только карты, выданные в этом же магазине" AT ROW 21 COL 2
     "Тип носителя" VIEW-AS TEXT
          SIZE 21.5 BY .67 AT ROW 17.29 COL 77
     "Платеж" VIEW-AS TEXT
          SIZE 7 BY 1 AT ROW 19.5 COL 40
     RECT-1 AT ROW 20.71 COL 1
     RECT-3 AT ROW 17 COL 1
     RECT-4 AT ROW 17 COL 76
     SPACE(0.00) SKIP(1.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Тип дисконтной карты"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: temp-dc-type T "?" NO-UNDO ub dis-card-type
      TABLE: tt-2-hist-nws-option T "?" NO-UNDO ub hist-nws-option
      TABLE: tt-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt0-dis-dct-rule T "?" NO-UNDO ub dis-dct-rule
      TABLE: tt0-hist-nws-option T "?" NO-UNDO ub hist-nws-option
      TABLE: tt0-rp-by-call T "?" NO-UNDO ub rp-by-call
      TABLE: tt0-rule-by-call T "?" NO-UNDO ub rule-by-call
      TABLE: tt0-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: tt2-rule-call-param T "?" NO-UNDO ub rule-call-param
      TABLE: X_rp-by-call B "?" ? ub rp-by-call
      TABLE: X_rule-profile B "?" ? ub rule-profile
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-rule-by-call rs-algo-types Dialog-Frame */
/* BROWSE-TAB br-profile br-rule-by-call Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rule:HANDLE.

/* SETTINGS FOR TOGGLE-BOX temp-dc-type.d-pcnt-byshop IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dc-type.dcbyshop IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR TOGGLE-BOX temp-dc-type.dflt-credit-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX temp-dc-type.dflt-debet-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX temp-dc-type.dflt-staff-card IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN temp-dc-type.emitent-host-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-cash-pay-name IN FRAME Dialog-Frame
   NO-ENABLE LIKE = ub.cash-pay.obj-name EXP-LABEL EXP-SIZE             */
ASSIGN
       f-cash-pay-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-dflt-cash-pcnt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

ASSIGN
       f-dflt-pcnt:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR TOGGLE-BOX temp-dc-type.fiscal-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dc-type.lim-kr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR TOGGLE-BOX temp-dc-type.mixed-pay IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN temp-dc-type.type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-profile
/* Query rebuild information for BROWSE br-profile
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt0-rp-by-call WHERE
         tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "X_rule-by-call.call_id = dis-card-type.uniq-key-rec"
     _Query            is OPENED
*/  /* BROWSE br-profile */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-rule-by-call
/* Query rebuild information for BROWSE br-rule-by-call
     _START_FREEFORM
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE
    tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec,
    FIRST X_rule-profile NO-LOCK WHERE
        X_rule-profile.profile_id = tt0-rule-by-call.profile_id
  AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)
 BY tt0-rule-by-call.codex_id
 BY tt0-rule-by-call.ruleset_id
 BY tt0-rule-by-call.order_id
 INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Where[1]         = "Temp-Tables.tt-rule-by-call.emitent-host-code = 0
 AND Temp-Tables.tt-rule-by-call.type = ""66"""
     _Query            is OPENED
*/  /* BROWSE br-rule-by-call */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.temp-dc-type"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Тип дисконтной карты */
DO:
    rid = ?.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-addalgo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-addalgo Dialog-Frame
ON CHOOSE OF b-addalgo IN FRAME Dialog-Frame /* Добавить */
DO:
DEFINE VARIABLE v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
run ref/rulprofs.w (
                     INPUT parparentproc
                    ,INPUT "b-sel"
                    ,INPUT {&TABLE_dis-card-type}
                    ,INPUT-OUTPUT v-ref-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-apply.
END.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          recid(buf_rule-profile) = INTEGER(v-ref-list) NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN NO-APPLY.
  RUN proc-b-addalgo IN THIS-PROCEDURE ( BUFFER buf_rule-profile) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-cashpay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-cashpay Dialog-Frame
ON CHOOSE OF B-cashpay IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
 run ref/cashpays.w (
                 input parparentproc
                ,input "b-sel":U
                ,input {&all}
                ,input parhost-code
                ,input parobj-type
                ,input parobj-code
                ,output v-rid-list ) .
  IF v-rid-list <> "":U THEN DO:
      FIND FIRST buf_cash-pay NO-LOCK WHERE
                recid(buf_cash-pay) = INTEGER(v-rid-list) NO-ERROR.
      IF NOT AVAILABLE buf_cash-pay THEN DO:
          ASSIGN
          temp-dc-type.pay-code = 0
         f-cash-pay-name = "":U.
      END.
      ELSE DO:
          IF AVAILABLE buf_cash-pay
          AND buf_cash-pay.curr-code <> v-r-b-code THEN DO:
              MESSAGE
              substitute("Дебетовой или кредитовой карте для данного эмитента можно сопоставить тип кассового платежа только с кодом валюты &1", v-r-b-code)
              VIEW-AS ALERT-BOX ERROR.
              ASSIGN
              temp-dc-type.pay-code = 0
              f-cash-pay-name = "":U.

          END.
          ASSIGN
          temp-dc-type.pay-code = buf_cash-pay.cdpay-code
          f-cash-pay-name = buf_cash-pay.obj-name.
      END.
  END.
  DISPLAY
  f-cash-pay-name
  WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd Dialog-Frame
ON CHOOSE OF b-cd IN FRAME Dialog-Frame /* На кассу */
DO:
  define variable glog as logical no-undo .
  if p-mode <> {&lookup} then do:
    message
    substitute("Внимание! Если Вы уже делали какие-либо изменения,&1" +
               "то перед настройкой данных, передаваемых на кассы&1"  +
               "рекомендуется сначала сохранить ТИП ДК&1&1" +
               "Все равно продолжить?"
               , {&new-line})
    view-as alert-box warning buttons YES-NO update glog.
    if not glog then return no-apply.
  end.
  RUN proc-b-cd IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-d-pcnt-byshop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-d-pcnt-byshop Dialog-Frame
ON CHOOSE OF b-d-pcnt-byshop IN FRAME Dialog-Frame /* Все скидки по умолч. */
DO:
  run ref/dis-dcti.w ( INPUt parparentproc
                        ,INPUT p-mode
                        ,INPUT temp-dc-type.TYPE
                        ,INPUT temp-dc-type.emitent-host-code
                        ,INPUT parhost-code
                        ,INPUT parobj-type
                        ,INPUT parobj-code
                        ,INPUT {&cd-type-bo}
                        ,input ({&ddctr-def-pcnt} + {&comma-char} +
                                {&ddctr-def-cash-pcnt} + {&comma-char} +
                                {&ddctr-def-categ}
                               )
                        ,INPUT-OUTPUT TABLE tt0-dis-dct-rule) NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
run proc-b-dis-dct-rule ( INPUT {&ddctr-def-pcnt}, input {&lookup}) NO-ERROR.
run proc-b-dis-dct-rule ( INPUT {&ddctr-def-cash-pcnt}, input {&lookup}) NO-ERROR.
run proc-b-dis-dct-rule ( INPUT {&ddctr-def-categ}, input {&lookup}) NO-ERROR.
run dpcnt-byshop-enable-disable in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dcbyshop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dcbyshop Dialog-Frame
ON CHOOSE OF B-dcbyshop IN FRAME Dialog-Frame
DO:
  run proc-dcbyshop no-error.
    if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-def-cash-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-def-cash-pcnt Dialog-Frame
ON CHOOSE OF B-def-cash-pcnt IN FRAME Dialog-Frame
DO:
  run proc-b-dis-dct-rule ( INPUT {&ddctr-def-cash-pcnt}, input {&update}) NO-ERROR.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-def-categ
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-def-categ Dialog-Frame
ON CHOOSE OF B-def-categ IN FRAME Dialog-Frame
DO:
  run proc-b-dis-dct-rule ( INPUT {&ddctr-def-categ}, input {&update}) NO-ERROR.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-def-pcnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-def-pcnt Dialog-Frame
ON CHOOSE OF B-def-pcnt IN FRAME Dialog-Frame
DO:
  run proc-b-dis-dct-rule ( INPUT {&ddctr-def-pcnt}, input {&update}) NO-ERROR.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-delalgo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-delalgo Dialog-Frame
ON CHOOSE OF b-delalgo IN FRAME Dialog-Frame /* Удалить */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
  run proc-b-delalgo IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "value-changed" TO br-rule-by-call.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-disc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-disc Dialog-Frame
ON CHOOSE OF b-disc IN FRAME Dialog-Frame /* Пр-ла скидок */
DO:
  DEFINE VARIABLE v-loc-rid-list AS CHARACTER NO-UNDO.
  IF NOT AVAILABLE temp-dc-type THEN RETURN NO-APPLY.
        run ref/dis-dcts.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT (if p-mode = {&lookup}
                                   then {&table_Dis-card-type}
                                   else ({&table_Dis-card-type}   + {&comma-char} + "temp")
                                   )
                                   /*p-list-mode */
                            ,input temp-dc-type.emitent-host-code
                            ,input temp-dc-type.type
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


&Scoped-define SELF-NAME B-emitent
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-emitent Dialog-Frame
ON CHOOSE OF B-emitent IN FRAME Dialog-Frame
DO:
  run proc-b-emitent no-error.
  if error-status:error then return no-apply.
  APPLY "LEAVE" to temp-dc-type.emitent-host-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:
    DEFINE VARIABLE ri-list AS CHARACTER NO-UNDO.
   run ref/dcctypes.w (
                   input parparentproc
                  ,input '':U
                  ,input  ?
                  ,input  ub.dis-card-type.emitent-host-code
                  ,input  parhost-code
                  ,input  parobj-type
                  ,input  parobj-code
                  ,input  dis-card-type.TYPE
                  ,input "one":U
                  ,input '':U /*subject*/
                  ,output ri-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-hn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-hn Dialog-Frame
ON CHOOSE OF b-hn IN FRAME Dialog-Frame /* Маршрутиз. и ист. */
DO:
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
define buffer last_tt0-hist-nws-option for tt0-hist-nws-option.
FOR EACH tt-2-hist-nws-option:
  DELETE tt-2-hist-nws-option.
END.
FOR EACH tt0-hist-nws-option :
  CREATE tt-2-hist-nws-option.
  BUFFER-COPY tt0-hist-nws-option TO tt-2-hist-nws-option.
END.
run ref/dcta-1.w (
                INPUT parparentproc
               ,INPUT p-mode
               ,INPUT temp-dc-type.TYPE
               ,INPUT temp-dc-type.emitent-host-code
               ,INPUT-OUTPUT TABLE tt-2-hist-nws-option
               ,OUTPUT v-ok) NO-ERROR.
IF v-ok THEN DO:
   FOR EACH tt-2-hist-nws-option:
     FIND FIRST tt0-hist-nws-option WHERE
           tt0-hist-nws-option.db-num = tt-2-hist-nws-option.db-num
       and tt0-hist-nws-option.table-name = tt-2-hist-nws-option.table-name
       AND tt0-hist-nws-option.host-code = tt-2-hist-nws-option.host-code
       AND tt0-hist-nws-option.obj-type = tt-2-hist-nws-option.obj-type
       AND tt0-hist-nws-option.obj-code = tt-2-hist-nws-option.obj-code
       and tt0-hist-nws-option.key#_one = tt-2-hist-nws-option.key#_one
       and tt0-hist-nws-option.charkey_one = tt-2-hist-nws-option.charkey_one no-error.

     IF NOT AVAILABLE tt0-hist-nws-option THEN DO:
       find last last_tt0-hist-nws-option where
            last_tt0-hist-nws-option.db-num = tt-2-hist-nws-option.db-num no-error .

       CREATE tt0-hist-nws-option.
       ASSIGN
       tt0-hist-nws-option.db-num = tt-2-hist-nws-option.db-num
       tt0-hist-nws-option.table-name = tt-2-hist-nws-option.table-name
       tt0-hist-nws-option.host-code = tt-2-hist-nws-option.host-code
       tt0-hist-nws-option.obj-type = tt-2-hist-nws-option.obj-type
       tt0-hist-nws-option.obj-code = tt-2-hist-nws-option.obj-code
       tt0-hist-nws-option.key#_one = tt-2-hist-nws-option.key#_one
       tt0-hist-nws-option.charkey_one = tt-2-hist-nws-option.charkey_one
       tt0-hist-nws-option.option-descr = tt-2-hist-nws-option.option-descr
       tt0-hist-nws-option.hn-id = (if available last_tt0-hist-nws-option
                                    then (last_tt0-hist-nws-option.hn-id  + 1)
                                    else 1)
      .
      END.
      ASSIGN
      tt0-hist-nws-option.hist-to-nws = tt-2-hist-nws-option.hist-to-nws
      tt0-hist-nws-option.nws-to-hist = tt-2-hist-nws-option.nws-to-hist
      tt0-hist-nws-option.hist-from-prim = tt-2-hist-nws-option.hist-from-prim
      tt0-hist-nws-option.nws-to-cd = tt-2-hist-nws-option.nws-to-cd
      tt0-hist-nws-option.smart-nws = tt-2-hist-nws-option.smart-nws
      tt0-hist-nws-option.get-hist-from-nws = tt-2-hist-nws-option.get-hist-from-nws
      .
      release tt0-hist-nws-option.
      delete tt-2-hist-nws-option.
   END.
 END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mask Dialog-Frame
ON CHOOSE OF B-mask IN FRAME Dialog-Frame /* Маски */
DO:
  define variable v-rid-list as character no-undo .
  run ref/dc-masks.w (
                    INPUT parparentproc
                   ,INPUT parhost-code
                   ,INPUT parobj-type
                   ,INPUT parobj-code
                   ,input "":U
                   ,INPUT "one":U
                   ,INPUT ub.dis-card-type.TYPE
                   ,INPUT ub.dis-card-type.emitent-host-code
                   ,INPUT ?
                   ,input-output v-rid-list
                    ) NO-ERROR.
  IF ERROR-STATUS:error  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-params
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-params Dialog-Frame
ON CHOOSE OF b-params IN FRAME Dialog-Frame /* Параметры */
DO:
  if tt0-rp-by-call.call_id = '' then do:
    message
    "Пожалуйста, заполните поле <тип ДК>"
    view-as alert-box warning.
    return no-apply.
  end.
  CASE Rs-algo-profile:
    when {&table_rule-by-call} then do:
      IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
      run ref/rulercps.w (
                             input parparentproc
                            ,input this-procedure:handle
                            ,input '':U
                            ,input p-mode
                            ,input {&table_rule-call-param}
                            ,input 0 /*p-profile-id*/
                            ,input ? /*p-once-more*/
                            ,input tt0-rule-by-call.call_id /*p-call-id*/
                            ,input tt0-rule-by-call.codex_id /*p-codex-id*/
                            ,input tt0-rule-by-call.ruleset_id /*p-codex-id*/
                            ,input tt0-rule-by-call.order_id /*p-order-id*/
                            ,input tt0-rule-by-call.RULE_id /*p-rule-id*/
                            ,INput substitute("Правило &1 &2"
                                             , tt0-rule-by-call.RULE_id
                                             , calldscr(tt0-rule-by-call.call_id)
                                             )  /**/
                            ,input-output table tt0-rule-call-param  ) no-error.

     end.
     when {&table_rp-by-call} then do:
      IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
      define variable v-param-form as character no-undo .
      define buffer buf_rule-profile for ub.rule-profile.
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
      assign
      v-param-form = (if buf_rule-profile.custom-param-form > 0
                      then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                      else "ref/rulercps.w")
      .

      run value(v-param-form) (
                            input parparentproc
                            ,input this-procedure:handle
                            ,input 'b-chg':U
                            ,input p-mode
                            ,input {&table_rp-rule-param}
                            ,input tt0-rp-by-call.profile_id /*p-profile-id*/
                            ,input tt0-rp-by-call.once-more /*p-once-more*/
                            ,input tt0-rp-by-call.call_id /*p-call-id*/
                            ,input 0 /*p-codex-id*/
                            ,input 0 /*p-codex-id*/
                            ,input ? /*p-order-id*/
                            ,input 0 /*p-rule-id*/
                            ,INput substitute("Профайл &1 № привязки &2 &3"
                                              ,tt0-rp-by-call.profile
                                              ,tt0-rp-by-call.once-more
                                              ,calldscr(tt0-rp-by-call.call_id)
                                              )  /**/
                            ,input-output table tt0-rule-call-param  ) no-error.

     end.
   end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prop-ref
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prop-ref Dialog-Frame
ON CHOOSE OF b-prop-ref IN FRAME Dialog-Frame /* Итоги/Срезы */
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  run ref/proprefs.w ( INPUT parparentproc
                  ,INPUT "":U /*bttns*/
                  ,INPUT "call_id" /*p-list-mode*/
                  ,INPUT 0 /*p-dtm-code*/
                  ,input '':U
                  ,INPUT temp-dc-type.uniq-key-rec
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
  rid = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rule Dialog-Frame
ON CHOOSE OF B-rule IN FRAME Dialog-Frame /* Правило */
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:

   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                             INPUT rule-display-option
                                            ,input tt0-rule-by-call.codex_id
                                            ,input tt0-rule-by-call.ruleset_id
                                            ,input tt0-rule-by-call.call_id
                                            ,input tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
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


&Scoped-define SELF-NAME b-rule-on-off
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rule-on-off Dialog-Frame
ON CHOOSE OF b-rule-on-off IN FRAME Dialog-Frame /* Вкл */
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  if Rs-algo-profile <> {&TABLE_rule-by-call} then return no-apply.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF X_rule-profile.IS_dynamic = NO  THEN DO:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "так как принадлежит алгоритму, приписанному к карте ПО УМОЛЧАНИЮ!"
                , {&NEW-LINE})
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  if tt0-rule-by-call.is_dynamic = no then do:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "согласно определенной профайлом логике!"
                , {&NEW-LINE})
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.

  end.
  IF tt0-rule-by-call.can-calc THEN DO:
    MESSAGE
    "Вы уверены, что хотите выключить правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
    IF NOT glog THEN RETURN NO-APPLY.
  END.
  ELSE DO:
      MESSAGE
      "Вы уверены, что хотите включить правило?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
      IF NOT glog THEN RETURN NO-APPLY.
  END.
  ASSIGN
  tt0-rule-by-call.can-calc = NOT (tt0-rule-by-call.can-calc).
  glog = br-rule-by-call:REFRESH() IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-ruleset
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-ruleset Dialog-Frame
ON CHOOSE OF B-ruleset IN FRAME Dialog-Frame /* Т-ка вызова */
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe tt0-rule-by-call THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = tt0-rule-by-call.codex_id
        AND buf_ruleset.ruleset_id = tt0-rule-by-call.ruleset_id.

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
ON VALUE-CHANGED OF br-profile IN FRAME Dialog-Frame
DO:
if br-profile:visible in frame {&frame-name} then do:
  IF NOT AVAILABLE tt0-rp-by-call THEN DO:
     e-rule-name:SCREEN-VALUE = ''.
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = tt0-rp-by-call.ps.
  END.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-rule-by-call
&Scoped-define SELF-NAME br-rule-by-call
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-rule-by-call Dialog-Frame
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  define buffer buf_rule-profile for ub.rule-profile.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = tt0-rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", tt0-rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = buf_rule.name + {&NEW-LINE} + buf_rule.documentation.
  END.
  find first buf_rule-profile no-lock where
            buf_rule-profile.profile_id = tt0-rule-by-call.profile_id.
  b-rule-on-off:sensitive in frame {&frame-name} = (p-mode <> {&lookup})
                                               and buf_rule-profile.custom-param-form = 0
                                               and (Rs-algo-profile = {&table_rule-by-call}).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dc-type.dflt-credit-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dc-type.dflt-credit-card Dialog-Frame
ON VALUE-CHANGED OF temp-dc-type.dflt-credit-card IN FRAME Dialog-Frame /* Кредитная карта */
DO:
 RUN BUTTONS IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dc-type.dflt-debet-card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dc-type.dflt-debet-card Dialog-Frame
ON VALUE-CHANGED OF temp-dc-type.dflt-debet-card IN FRAME Dialog-Frame /* Дебетовая карта */
DO:
  RUN BUTTONS IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME E-rule-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL E-rule-name Dialog-Frame
ON LEAVE OF E-rule-name IN FRAME Dialog-Frame
DO:
  run local-notes in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dc-type.emitent-host-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dc-type.emitent-host-code Dialog-Frame
ON ENTRY OF temp-dc-type.emitent-host-code IN FRAME Dialog-Frame /* Эмитент */
DO:
  old-emitent-host-code = integer(temp-dc-type.emitent-host-code:screen-value).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dc-type.emitent-host-code Dialog-Frame
ON LEAVE OF temp-dc-type.emitent-host-code IN FRAME Dialog-Frame /* Эмитент */
DO:
 /*define variable var-r-b-abbr as character no-undo.*/
if integer(temp-dc-type.emitent-host-code:screen-value) <>   old-emitent-host-code then do:
  display
  "":U @ temp-dc-type.dcbyshop
  with frame {&frame-name}.
end.
run display-r-b-abbr in this-procedure ( output v-r-b-code) no-error.
RUN proc-refresh-tt IN THIS-PROCEDURE NO-ERROR.
{&OPEN-QUERY-br-profile}
APPLY "VALUE-CHANGED" to br-profile.
{&OPEN-QUERY-br-rule-by-call}
APPLY "VALUE-CHANGED" to br-rule-by-call.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_graph
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_graph Dialog-Frame
ON CHOOSE OF MENU-ITEM m_graph /* Граф */
DO:
    IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_text
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_text Dialog-Frame
ON CHOOSE OF MENU-ITEM m_text /* Текст */
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "text".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
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
      e-rule-name:read-only = yes.

      HIDE
      br-profile
      b-addalgo
      b-delalgo

      IN FRAME {&FRAME-NAME}.
      .
      DISPLAY
      rs-algo-types
      br-rule-by-call
      b-rule
      b-ruleset
      b-rule-on-off
      WITH FRAME {&FRAME-NAME}.
      APPLY "VALUE-CHANGED" to br-rule-by-call.
    END.
    WHEN {&TABLE_rp-by-call} THEN DO:
      e-rule-name:read-only = (if p-mode <> {&lookup} then no else yes).
      HIDE
      br-rule-by-call
      rs-algo-types
      b-rule
      b-ruleset
      b-rule-on-off
      IN FRAME {&FRAME-NAME}.
      DISPLAY
      br-profile
      b-addalgo
      b-delalgo
      WITH FRAME {&FRAME-NAME}.
      APPLY "VALUE-CHANGED" to br-profile.
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


&Scoped-define SELF-NAME T-check-by-mask
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-check-by-mask Dialog-Frame
ON VALUE-CHANGED OF T-check-by-mask IN FRAME Dialog-Frame /* Пров. № ДК по маске */
DO:
  ASSIGN
  t-check-by-mask.
  CASE t-check-by-mask:
  WHEN YES THEN DO:
    IF p-mode = {&add-def} THEN DO:
      ENABLE
      t-ho-join
      WITH FRAME {&FRAME-NAME}.
    END.
    else do:
      disable
      t-ho-join
      WITH FRAME {&FRAME-NAME}.
    end.
  END.
  WHEN NO THEN DO:
    ASSIGN
    t-ho-join = NO.
    display
    t-ho-join
    with frame {&frame-name} .
    DISABLE
    t-ho-join
    WITH FRAME {&FRAME-NAME}.
  END.
END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME temp-dc-type.type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL temp-dc-type.type Dialog-Frame
ON LEAVE OF temp-dc-type.type IN FRAME Dialog-Frame /* Тип карты */
DO:
  IF p-mode = {&add-def}  THEN DO:
     ASSIGN
     temp-dc-type.TYPE.
     RUN proc-refresh-tt IN THIS-PROCEDURE no-error.
     {&OPEN-QUERY-br-profile}
     APPLY "VALUE-CHANGED" to br-profile.
     {&OPEN-QUERY-br-rule-by-call}
      APPLY "VALUE-CHANGED" to br-rule-by-call.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-dflt-d-pcnt-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-dflt-d-pcnt-method Dialog-Frame
ON VALUE-CHANGED OF v-dflt-d-pcnt-method IN FRAME Dialog-Frame
DO:
 ASSIGN
  v-dflt-d-pcnt-method.
  CASE v-dflt-d-pcnt-method:
      WHEN {&dc-d-pcnt-good} THEN DO:
         ASSIGN
         v-mode[{&pcnt-cash-calc}] = {&LOOKUP}
         v-mode[{&pcnt-calc}] = p-mode
         .
      END.
      WHEN {&dc-d-pcnt-cash} THEN DO:
          ASSIGN
          v-mode[{&pcnt-calc}] = {&LOOKUP}
          v-mode[{&pcnt-cash-calc}] = p-mode
          .
      END.
      WHEN {&dc-d-pcnt-both} THEN DO:
          ASSIGN
          v-mode[{&pcnt-calc}] = p-mode
          v-mode[{&pcnt-cash-calc}] = p-mode
          .
      END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-profile
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ rul/rcpscont.i tt0-rule-by-call ~{&OPEN-QUERY-br-rule-by-call~} }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/curr-r-b.i v-curr-r-b   }
  if p-mode <> {&update} and p-mode <> {&add-def} AND p-mode <> {&lookup} then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова p-mode"
        view-as alert-box ERROR.
        return error.
    end.
    for each temp-dc-type:
        delete temp-dc-type.
    end.
  if p-mode = {&update} or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      do transaction
      on error undo, return error
      on stop undo, return error
      :
        find first dis-card-type EXclusive-lock where recid(dis-card-type) = rid no-wait no-error.
        if locked dis-card-type then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись типа дисконтной карты занята"
          view-as alert-box error .
          return error.
        end.
      end.
    end.
    else do:
      find first dis-card-type no-lock where recid(dis-card-type) = rid.
    end.
    if not available dis-card-type then do:
      message vss-workfile vss-revision vss-description skip
              "Не найдена запись типа дисконтной карты"
      view-as alert-box error .
    end.
    create temp-dc-type.
    buffer-copy dis-card-type to temp-dc-type.
  end.
  ELSE DO:
    CREATE temp-dc-type.
    assign
    temp-dc-type.cardname-sent = {&dc-cn-sent-name}
    temp-dc-type.custom-sent = substitute("&1,&1"
                                            ,{&question-mark} )
    .
  END.
  RUN dc-typei_FILL-table IN THIS-PROCEDURE ( input p-mode
                                             ,input no /*p-silent*/
                                             ,output f-dflt-pcnt
                                             ,output f-dflt-cash-pcnt
                                             ,output f-dflt-pcnt-kat
                                            ) no-error .
  if error-status:error then do:
    message
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo main-block, return error .
  end.
  {&OPEN-QUERY-br-profile}
  APPLY "VALUE-CHANGED" to br-profile IN FRAME {&FRAME-NAME}.
  {&OPEN-QUERY-br-rule-by-call}
  APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE buttons Dialog-Frame
PROCEDURE buttons :
define variable v-found as logical no-undo .
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
if temp-dc-type.dflt-credit-card:screen-value IN FRAME {&frame-name} = "yes":U
AND p-mode <> {&lookup} THEN DO:
  enable
  temp-dc-type.lim-kr
  with frame {&frame-name}.
  assign
  temp-dc-type.dflt-debet-card = no
  .
  display
  temp-dc-type.dflt-debet-card
  with frame {&frame-name}.
  DISABLE
  temp-dc-type.dflt-debet-card
  with frame {&frame-name}.

 END.
  else do:
    if p-mode <> {&add-def}
    and
    ub.dis-card-type.emitent-host-code = 0
    then do:
      DISABLE
      temp-dc-type.dflt-credit-card
      with frame {&frame-name}.
    end.
    if p-mode = {&add-def} then
    display
    0 @ temp-dc-type.lim-kr
    with frame {&frame-name}.
    disable
    temp-dc-type.lim-kr
    with frame {&frame-name}.
    IF p-mode <> {&LOOKUP} THEN
    ENABLE
    temp-dc-type.dflt-debet-card
    with frame {&frame-name}.
    IF temp-dc-type.dflt-credit-card:screen-value = "no":U THEN DO:
        DISABLE
        temp-dc-type.fiscal-pay
        with frame {&frame-name}.
    END.
  end.
  IF (temp-dc-type.dflt-credit-card:screen-value = "yes":U
  OR    temp-dc-type.dflt-debet-card:screen-value = "yes":U)
  THEN DO:
      IF p-mode <> {&LOOKUP} THEN
      ENABLE
      temp-dc-type.fiscal-pay
      temp-dc-type.mixed-pay
      b-cashpay
      WITH FRAME {&FRAME-NAME}.
  END.
  ELSE DO:
     DISABLE
      temp-dc-type.fiscal-pay
      temp-dc-type.mixed-pay
      b-cashpay
      WITH FRAME {&FRAME-NAME}.
      ASSIGN
      f-cash-pay-name = "":U
      temp-dc-type.pay-code = 0    .

      DISPLAY
      f-cash-pay-name
      with frame {&frame-name} .
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-r-b-abbr Dialog-Frame
PROCEDURE display-r-b-abbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-r-b-curr-code LIKE ub.currency.curr-code NO-UNDO.
define var varemitent-host-code like ub.dis-card-type.emitent-host-code no-undo.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
varemitent-host-code = integer(temp-dc-type.emitent-host-code:screen-value in frame {&frame-name}).
if varemitent-host-code = 0
and v-curr-r-b = {&r-b-base}
then do:
  ASSIGN
  p-r-b-curr-code = 0
  var-r-b-abbr = ?.
end.
else do:
 { gbl/r-b-abbr.i varemitent-host-code var-r-b-abbr no-error }
    IF varemitent-host-code = 0 or
     v-curr-r-b = {&r-b-rubl}
     THEN DO:
        ASSIGN
        p-r-b-curr-code = 0
        .
    END.
    ELSE DO:
       FIND FIRST buf_sysconf NO-LOCK WHERE
                 buf_sysconf.host-code = varemitent-host-code .
       ASSIGN
       p-r-b-curr-code = buf_sysconf.base-code
        .
  END.
end.

display
var-r-b-abbr
with frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dpcnt-byshop-enable-disable Dialog-Frame
PROCEDURE dpcnt-byshop-enable-disable :
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
define variable v-found as logical no-undo .
disable
temp-dc-type.d-pcnt-byshop
with frame {&frame-name} .
for each buf_tt0-dis-dct-rule no-lock :
  if not (buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
          or
          buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
          or
          buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-categ}) then next.
  if buf_tt0-dis-dct-rule.host-code = 0
  and buf_tt0-dis-dct-rule.obj-type = '':U
  and buf_tt0-dis-dct-rule.obj-code = 0 then next.
  v-found = yes.
end.
/*  ne budem besslovno vikluchat
if p-mode <> {&lookup} then do:
  temp-dc-type.d-pcnt-byshop = v-found.
  display
  temp-dc-type.d-pcnt-byshop
  with frame {&frame-name} .
end.
*/
if not v-found
and p-mode <> {&lookup} then do:
  enable
  temp-dc-type.d-pcnt-byshop
  with frame {&frame-name} .
end.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY T-check-by-mask T-ho-join f-dflt-pcnt f-dflt-cash-pcnt f-dflt-pcnt-kat
          v-dflt-d-pcnt-method Rs-algo-profile rs-algo-types E-rule-name
          f-cash-pay-name emitent-name var-r-b-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE temp-dc-type THEN
    DISPLAY temp-dc-type.type temp-dc-type.emitent-host-code
          temp-dc-type.d-pcnt-byshop temp-dc-type.dflt-credit-card
          temp-dc-type.dflt-debet-card temp-dc-type.dflt-staff-card
          temp-dc-type.card-media temp-dc-type.lim-kr temp-dc-type.fiscal-pay
          temp-dc-type.mixed-pay temp-dc-type.dcbyshop
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-3 RECT-4 B-exit b-quit B-mask b-hn b-cd b-prop-ref b-disc
         B-history B-Help temp-dc-type.type T-check-by-mask T-ho-join
         temp-dc-type.emitent-host-code B-emitent f-dflt-pcnt
         temp-dc-type.d-pcnt-byshop B-def-pcnt b-d-pcnt-byshop f-dflt-cash-pcnt
         f-dflt-pcnt-kat B-def-cash-pcnt B-def-categ v-dflt-d-pcnt-method
         b-addalgo b-delalgo b-params B-rule B-ruleset b-rule-on-off
         Rs-algo-profile rs-algo-types br-rule-by-call br-profile E-rule-name
         temp-dc-type.dflt-credit-card temp-dc-type.dflt-debet-card
         temp-dc-type.dflt-staff-card temp-dc-type.card-media
         temp-dc-type.lim-kr temp-dc-type.fiscal-pay temp-dc-type.mixed-pay
         B-cashpay B-dcbyshop emitent-name var-r-b-abbr temp-dc-type.dcbyshop
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt0-dis-card-type Dialog-Frame
PROCEDURE fill-tt0-dis-card-type :
define input parameter p-dis-card-type-bh as handle no-undo.
p-dis-card-type-bh:buffer-create().
p-dis-card-type-bh:buffer-copy(buffer temp-dc-type:handle).
p-dis-card-type-bh:buffer-release().

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tt0-dis-dct-rule Dialog-Frame
PROCEDURE fill-tt0-dis-dct-rule :
define input parameter p-dis-dct-rule-bh as handle no-undo.
define buffer buf_tt0-dis-dct-rule for tt0-dis-dct-rule.
for each buf_tt0-dis-dct-rule:
  p-dis-dct-rule-bh:buffer-create().
  p-dis-dct-rule-bh:buffer-copy(buffer buf_tt0-dis-dct-rule:handle).
  p-dis-dct-rule-bh:buffer-release().
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-notes Dialog-Frame
PROCEDURE local-notes :
define variable v-updated as logical no-undo .
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
do on stop undo, return no-apply:
  find buf_tt0-rp-by-call where recid (buf_tt0-rp-by-call) = recid(tt0-rp-by-call) exclusive no-error no-wait.
  if not available buf_tt0-rp-by-call then do:
  end.
  else do:
    assign
    buf_tt0-rp-by-call.PS = input frame {&frame-name} e-rule-name
    v-updated = yes
    .
  end.
  if not v-updated then do:
    e-rule-name:edit-undo().
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
DEFINE VARIABLE v-check-by-mask AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.


define buffer b_clients for ub.clients.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
{&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
ASSIGN
v-mode[{&pcnt-calc}] = p-mode
v-mode[{&pcnt-cash-calc}] = p-mode
v-mode[{&pcnt-kat-calc}] = p-mode
v-mode[{&pcnt-calc}] = (IF temp-dc-type.dflt-d-pcnt-method = integer({&dc-d-pcnt-cash})
                        THEN {&LOOKUP}
                        ELSE p-mode)
v-mode[{&pcnt-cash-calc}] = (IF temp-dc-type.dflt-d-pcnt-method = integer({&dc-d-pcnt-good})
                        THEN {&LOOKUP}
                        ELSE p-mode)
.
ASSIGN
rs-algo-profile:RADIO-BUTTONS IN FRAME {&FRAME-NAME} = "Алгоритмы" + {&comma-char} +
                                 {&TABLE_rp-by-call} + {&comma-char} +
                                "Правила" + {&comma-char} + {&TABLE_rule-by-call}.
rs-algo-profile = {&TABLE_rp-by-call}.
ASSIGN
tt0-rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES .
DO ii = 1 TO br-profile:NUM-COLUMNS IN FRAME {&FRAME-NAME}:
    clh = BROWSE br-profile:get-browse-column(ii).
    IF clh:LABEL BEGINS "Название" THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
      clh:width = 72
      .
    END.
END.
  assign
   v-dflt-d-pcnt-method:Radio-buttons in frame {&frame-name} =
     "{&bef-dc-d-pcnt-good-full}" + {&comma-char} + string({&dc-d-pcnt-good}) + {&comma-char} +
     "{&bef-dc-d-pcnt-cash-full}" + {&comma-char} + string({&dc-d-pcnt-cash}) + {&comma-char} +
     "{&bef-dc-d-pcnt-both-full}" + {&comma-char} + string({&dc-d-pcnt-both})
    b-rule:MENU-MOUSE in frame {&frame-name} = 1
    temp-dc-type.card-media:RADIO-BUTTONS = mixlist({&dc-cm-types-full}, {&dc-cm-types}, {&comma-char}, {&comma-char})

    .
  if p-mode = {&update} or p-mode = {&lookup} then do:
    if temp-dc-type.emitent-host-code > 0 then do:
        find first b_clients No-LOCK WHERE
                    b_clients.obj-type = {&cmp} and
                    b_clients.obj-code = temp-dc-type.emitent-host-code No-ERROR.
        if avail b_clients then
        emitent-name = b_clients.obj-name.
    end.
    else do:
        emitent-name = "Глобальная".
    end.
  end.

  if p-mode = {&add-def} then do:
    display
    0 @ temp-dc-type.emitent-host-code
    0 @ f-dflt-pcnt
    0 @ f-dflt-cash-pcnt
    0 @ temp-dc-type.lim-kr
    WITH FRAME {&frame-name}.
  end.
  assign
   v-dflt-d-pcnt-method = (if p-mode = {&add-def}
                            then string({&dc-d-pcnt-good})
                            else string(temp-dc-type.dflt-d-pcnt-method)
                            ).

assign
T-check-by-mask  = (if temp-dc-type.check-by-mask = 1 then yes else no)
T-ho-join        = (if temp-dc-type.ho-join = 1 then yes else no)
T-check-by-mask:tooltip = v-tooltip
no-error .
DISPLAY
emitent-name
var-r-b-abbr
rs-algo-types
rs-algo-profile
WITH FRAME {&FRAME-NAME}.
IF AVAILABLE temp-dc-type THEN DO:
  DISPLAY
  temp-dc-type.type
  temp-dc-type.emitent-host-code
  f-dflt-pcnt
  f-dflt-pcnt-kat
  f-dflt-cash-pcnt
  temp-dc-type.dflt-credit-card
  temp-dc-type.dflt-debet-card
  temp-dc-type.dflt-staff-card
  temp-dc-type.fiscal-pay
  temp-dc-type.mixed-pay
  temp-dc-type.card-media
  temp-dc-type.lim-kr
  temp-dc-type.dcbyshop
  temp-dc-type.d-pcnt-byshop
  v-dflt-d-pcnt-method
  T-check-by-mask
  t-ho-join
  WITH FRAME {&frame-name}.
END.
ENABLE
B-exit when p-mode <> {&lookup}
b-quit
b-mask WHEN p-mode <> {&add-def}
b-history WHEN p-mode <> {&add-def}
b-cd WHEN p-mode <> {&add-def}
b-hn
B-Help
rs-algo-profile
b-rule
b-ruleset
b-addalgo when p-mode <> {&lookup}
b-delalgo when p-mode <> {&lookup}
b-rule-on-off when p-mode <> {&lookup}
b-cd when p-mode <> {&lookup}
b-params
temp-dc-type.type when p-mode = {&add-def}
temp-dc-type.emitent-host-code when p-mode = {&add-def}
B-emitent when p-mode = {&add-def}
b-def-pcnt when p-mode <> {&lookup}
b-def-cash-pcnt when p-mode <> {&lookup}
b-def-categ when p-mode <> {&lookup}
temp-dc-type.dflt-credit-card when p-mode <> {&lookup}
temp-dc-type.dflt-staff-card when p-mode <> {&lookup}
temp-dc-type.lim-kr when p-mode <> {&lookup}
temp-dc-type.dcbyshop when p-mode <> {&lookup}
B-dcbyshop when p-mode <> {&lookup}
temp-dc-type.d-pcnt-byshop when p-mode <> {&lookup} AND (p-mode = {&add-def} or not temp-dc-type.d-pcnt-byshop)
v-dflt-d-pcnt-method when p-mode <> {&lookup}
temp-dc-type.card-media WHEN p-mode  <> {&LOOKUP}
t-check-by-mask WHEN p-mode  <> {&LOOKUP}
t-ho-join WHEN (p-mode  <> {&LOOKUP} and t-check-by-mask)
br-rule-by-call
br-profile
b-prop-ref WHEN p-mode  <> {&add-def}
rs-algo-types
b-disc WHEN p-mode <> {&add-def}
b-d-pcnt-byshop
e-rule-name
WITH FRAME {&frame-name}.
if p-mode = {&lookup} then do:
    HIDE
    b-exit in frame {&frame-name}.
    assign
    b-quit:label in frame {&frame-name} = "&Выход"
    b-quit:column in frame {&frame-name} = 1
    e-rule-name:read-only in frame {&frame-name} = yes
    .
end.
VIEW FRAME {&frame-name}.
RUN BUTTONS IN THIS-PROCEDURE NO-ERROR.
run display-r-b-abbr in this-procedure ( output v-r-b-code) no-error.
IF temp-dc-type.pay-code <> 0 THEN DO:
FIND FIRST buf_cash-pay NO-LOCK WHERE
          buf_cash-pay.cdpay-code = temp-dc-type.pay-code
       AND buf_cash-pay.curr-code = v-r-b-code NO-ERROR.
  IF NOT AVAILABLE buf_cash-pay THEN DO:
      ASSIGN
     f-cash-pay-name = "":U.
  END.
  ELSE DO:
      f-cash-pay-name = buf_cash-pay.obj-name.
  END.
  DISPLAY
  f-cash-pay-name
  WITH FRAME {&FRAME-NAME}.
END.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "VALUE-CHANGED" TO rs-algo-profile.
APPLY "VALUE-CHANGED" TO T-check-by-mask.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-addalgo Dialog-Frame
PROCEDURE proc-b-addalgo :
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
run dc-typei_proc-b-addalgo in this-procedure (
                                                 input no /*p-silent*/
                                                ,input v-start
                                                ,buffer buf_rule-profile) no-error .
    if error-status:error then do:
      message
  return-value
  view-as alert-box .
  return.
end.
{&OPEN-QUERY-br-profile}
APPLY "VALUE-CHANGED" to br-profile IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-rule-by-call}
APPLY "value-changed" TO br-rule-by-call IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-cd Dialog-Frame
PROCEDURE proc-b-cd :
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-cardname-sent AS character NO-UNDO.
DEFINE VARIABLE v-custom-sent AS character NO-UNDO.
ASSIGN
v-cardname-sent = temp-dc-type.cardname-sent
v-custom-sent = temp-dc-type.custom-sent
.

run ref/dctypecd.w ( INPUT parparentproc
                    ,INPUT p-mode
                    ,input temp-dc-type.emitent-host-code
                    ,input temp-dc-type.type
                    ,INPUT-OUTPUT v-cardname-sent
                    ,INPUT-OUTPUT v-custom-sent
                    ,OUTPUT v-ok) NO-ERROR.
IF NOT ERROR-STATUS:ERROR
AND v-ok THEN DO:
   ASSIGN
   temp-dc-type.cardname-sent = v-cardname-sent
   temp-dc-type.custom-sent = v-custom-sent
   .

END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-delalgo Dialog-Frame
PROCEDURE proc-b-delalgo :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-rule-nums AS INTEGER NO-UNDO.
DEFINE VARIABLE v-profile-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
IF NOT AVAILABLE tt0-rp-by-call THEN RETURN ERROR.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN DO:
   MESSAGE
   substitute("Не найден алгоритм с кодом &1", tt0-rp-by-call.profile_id)
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
IF buf_rule-profile.IS_dynamic = NO THEN DO:
   MESSAGE
   "Привязку к данному алгоритму НЕЛЬЗЯ удалить!"
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
MESSAGE
"Вы уверены, что хотите удалить привязку к данному алгоритму?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
/*заблокируем*/
FIND FIRST buf_rule-profile EXCLUSIVE-LOCK WHERE buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
FOR EACH buf_tt0-rule-by-call where
      buf_tt0-rule-by-call.profile_id = tt0-rp-by-call.profile_id
  and buf_tt0-rule-by-call.once-more = tt0-rp-by-call.once-more
ON error UNDO, RETURN ERROR:
  for each buf_tt0-rule-call-param where
          buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
    and buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
    and buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
    and buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
    ON error UNDO, RETURN ERROR:
    delete buf_tt0-rule-call-param.
  end.
  DELETE buf_tt0-rule-by-call.
END.
DELETE tt0-rp-by-call.
{&OPEN-QUERY-br-profile}
APPLY "VALUE-CHANGED" to br-profile IN FRAME {&FRAME-NAME}.
{&OPEN-QUERY-br-rule-by-call}
APPLY "value-changed" TO br-rule-by-call  IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-dis-dct-rule Dialog-Frame
PROCEDURE proc-b-dis-dct-rule :
DEFINE INPUT PARAMETER p-discnt-role AS CHARACTER NO-UNDO.
define input parameter p-mode as character no-undo .
DEFINE BUFFER buf_dis-dct-rule FOR ub.dis-dct-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS integer NO-UNDO.
define variable glog as logical no-undo .
DEFINE BUFFER buf_tt0-dis-dct-rule FOR tt0-dis-dct-rule.
FIND FIRST buf_tt0-dis-dct-rule NO-LOCK WHERE
          buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
      AND buf_tt0-dis-dct-rule.type = temp-dc-type.TYPE
      AND buf_tt0-dis-dct-rule.host-code = 0
      AND buf_tt0-dis-dct-rule.obj-type = '':U
      AND buf_tt0-dis-dct-rule.obj-code = 0
    AND buf_tt0-dis-dct-rule.pos-type = {&cd-type-bo}
    AND buf_tt0-dis-dct-rule.discnt-role = p-discnt-role NO-ERROR.
IF AVAILABLE buf_tt0-dis-dct-rule  THEN DO:
  FIND FIRST buf_dis-rule NO-LOCK WHERE
            buf_Dis-rule.rule-num = buf_tt0-dis-dct-rule.rule-num NO-ERROR.
  IF AVAILABLE buf_dis-rule THEN DO:
    v-rid-list = STRING(recid(buf_Dis-rule)).
  END.
END.
if p-mode <> {&lookup} then do:
  run ref/dis-ruls.w ( input  parparentproc
                      ,input 0 /*p-host-code*/
                      ,input '':U /*p-curr-obj-type*/
                      ,input 0 /*p-curr-obj-code*/
                      ,input "b-sel,b-add"
                      ,input {&table_dis-dct-rule} + "=" + p-discnt-role
                      ,input 0
                      ,input ? /*p-time-templ-rl-root*/
                      ,input 0 /*p-b-code*/
                      ,input-output v-sts /*p-sts*/
                      ,input-OUTPUT v-rid-list) NO-ERROR.
  if NOT ERROR-STATUS:ERROR
  AND v-rid-list <> '':U then do:
      find first buf_dis-rule no-lock where
                recid(buf_dis-rule) = integer(v-rid-list) no-error.
      if not available buf_dis-rule then do:
          message
          substitute("Не найдено правило скидки c recid &1", v-rid-list)
          VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.
      END.
      IF NOT AVAILABLE buf_tt0-dis-dct-rule THEN DO:
        CREATE buf_tt0-dis-dct-rule.
        assign
        buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
        buf_tt0-dis-dct-rule.type = temp-dc-type.type
        buf_tt0-dis-dct-rule.host-code = buf_dis-rule.host-code
        buf_tt0-dis-dct-rule.obj-type = '':U
        buf_tt0-dis-dct-rule.obj-code = 0
        buf_tt0-dis-dct-rule.pos-type = {&cd-type-bo}
        buf_tt0-dis-dct-rule.discnt-role = p-discnt-role
        buf_tt0-dis-dct-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        buf_tt0-dis-dct-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root
        buf_tt0-dis-dct-rule.rule-num = buf_dis-rule.rule-num
        buf_tt0-dis-dct-rule.rl-root = buf_dis-rule.rl-root
        .
    END.
    ASSIGN
    buf_tt0-dis-dct-rule.templ-rl-root = buf_dis-rule.templ-rl-root
    buf_tt0-dis-dct-rule.time-templ-rl-root = buf_dis-rule.time-templ-rl-root
    buf_tt0-dis-dct-rule.rule-num = buf_dis-rule.rule-num
    buf_tt0-dis-dct-rule.rl-root = buf_dis-rule.rl-root
    .
  end.
end.
CASE p-discnt-role:
  WHEN {&ddctr-def-categ} THEN DO:
    DISPLAY
    (if available buf_Dis-rule
    then buf_dis-rule.dis-kat
    else 0)
    @ f-dflt-pcnt-kat
    WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&ddctr-def-pcnt} THEN DO:
    DISPLAY
    (if available buf_Dis-rule
    then buf_dis-rule.discnt-value
    else 0.0)
    @ f-dflt-pcnt
    WITH FRAME {&FRAME-NAME}.
  END.
  WHEN {&ddctr-def-cash-pcnt} THEN DO:
    DISPLAY
    (if available buf_Dis-rule
    then buf_dis-rule.discnt-value
    else 0.0)
    @ f-dflt-cash-pcnt
    WITH FRAME {&FRAME-NAME}.
  END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-emitent Dialog-Frame
PROCEDURE proc-b-emitent :
define variable ref-list as char no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer h-cli for ub.clients.
run adm/sconfs.w (
                INPUT parparentproc
                ,INPUT "b-sel":U
                ,input no
                ,input 0
                ,output v-host-code
                ,input-output ref-list
                ).
if v-host-code = 0
or v-host-code = ?
then do:
  return error.
end.
find h-cli no-lock where
      h-cli.obj-type = {&cmp}
  AND h-cli.obj-code = v-host-code  .
      .
if not can-find (ub.sysconf where ub.sysconf.host-code = v-host-code no-lock) then do:
  message "Выбранная организация не является одной из фирм БД."
          view-as alert-box error.
  return error.
end.
old-emitent-host-code  = integer(temp-dc-type.emitent-host-code:screen-value in frame {&frame-name}).
  display
h-cli.obj-code @ temp-dc-type.emitent-host-code
with frame {&frame-name}.
RUN proc-refresh-tt IN THIS-PROCEDURE NO-ERROR.
{&OPEN-QUERY-br-profile}
APPLY "VALUE-CHANGED" to br-profile.
{&OPEN-QUERY-br-rule-by-call}
APPLY "VALUE-CHANGED" to br-rule-by-call.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-dcbyshop Dialog-Frame
PROCEDURE proc-dcbyshop :
define variable var-sel-value as char no-undo.
define variable var-input-value as char no-undo.
define variable var-output-value as char no-undo.
define variable var-labels as char no-undo.
define variable jj as integer no-undo.
do jj = 1 to num-entries(temp-dc-type.dcbyshop:screen-value in frame {&frame-name}):
find first ub.clients No-LOCK WHERE
            ub.clients.obj-type = {&shop} and
            ub.clients.obj-code = integer(entry(jj, temp-dc-type.dcbyshop:screen-value)) no-error.
if avail ub.clients then do:
  assign
  var-sel-value = var-sel-value + (if var-sel-value = "":U then "":U else {&comma-char}) + entry(jj, temp-dc-type.dcbyshop:screen-value)
  .
end.
end.
for each ub.clients NO-LOCK WHERE
            ub.clients.obj-type = {&shop},
  first ub.shop no-lock where
          ub.shop.obj-code = ub.clients.obj-code AND
          (integer(temp-dc-type.emitent-host-code:screen-value) = 0 OR
            ub.shop.host-code = integer(temp-dc-type.emitent-host-code:screen-value)):
  assign
  var-input-value = var-input-value + (if var-input-value = "":U then "":U else {&comma-char}) + string(clients.obj-code)
  var-labels = var-labels + (if var-labels = "":U
                              then "":U
                              else {&comma-char}) +
                string(ub.shop.obj-code, "99999") + {&space-char} +
                replace(ub.clients.obj-name, {&comma-char}, "":U)
  .
end.
run gbl/d-list.w (
                   input "b-sel,b-mark":U
                  ,input "Выберите магазины"
                  ,input var-input-value
                  ,input var-labels
                  ,input {&comma-char}
                  ,input var-sel-value
                  ,output var-output-value) no-error.
if error-status:error then return error.
if var-output-value = var-sel-value  then do:
  return error.
end.
else do:
  display
  var-output-value @ temp-dc-type.dcbyshop
  with frame {&frame-name}.
end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-refresh-tt Dialog-Frame
PROCEDURE proc-refresh-tt :
DEFINE VARIABLE v-old-call-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new-call-id AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
DEFINE BUFFER buf_tt0-rule-call-param FOR tt0-rule-call-param.
DEFINE BUFFER buf_tt0-hist-nws-option FOR tt0-hist-nws-option.
DEFINE BUFFER buf_tt0-dis-dct-rule FOR tt0-dis-dct-rule.
IF p-mode = {&add-def} THEN DO:
   FOR EACH buf_tt0-dis-dct-rule:
      buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code.
   END.
   run gen-key-rec in this-procedure (
                                     input {&table_dis-card-type}
                                     ,input  BUFFER temp-dc-type:handle
                                     ,output temp-dc-type.uniq-key-rec
                                       ).
    FOR EACH buf_tt0-rp-by-call:
       buf_tt0-rp-by-call.CALL_id = temp-dc-type.uniq-key-rec.
    END.
    FOR EACH buf_tt0-rule-by-call:
      v-old-call-id = buf_tt0-rule-by-call.call_id.
      ASSIGN
      buf_tt0-rule-by-call.call_id = temp-dc-type.uniq-key-rec
      .
       FOR EACH buf_tt0-rule-call-param WHERE
               buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
           AND buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
           AND buf_tt0-rule-call-param.call_id = v-old-call-id:
          ASSIGN
          buf_tt0-rule-call-param.CALL_id = buf_tt0-rule-by-call.call_id.
       END.
    END.
END.
FOR EACH buf_tt0-hist-nws-option:
   ASSIGN
   buf_tt0-hist-nws-option.charkey_one = temp-dc-type.TYPE
   buf_tt0-hist-nws-option.host-code = temp-dc-type.emitent-host-code
   .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
DEFINE VARIABLE v-old-call-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new-call-id AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable v-found-new as logical no-undo .
define variable v-found-d-pcnt-byshop as logical   no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
DEFINE BUFFER buf_tt0-dis-dct-rule FOR tt0-dis-dct-rule.
define buffer buf_rule-profile for ub.rule-profile.
find first temp-dc-type  no-error.

ASSIGN FRAME {&FRAME-NAME}
temp-dc-type.emitent-host-code
temp-dc-type.type
temp-dc-type.host-code = 0
temp-dc-type.obj-type  = "":U
temp-dc-type.obj-code  = 0
.
assign
temp-dc-type.dflt-credit-card
temp-dc-type.lim-kr
temp-dc-type.d-pcnt-byshop
temp-dc-type.dcbyshop
temp-dc-type.dc-pfx  = "":U
v-dflt-d-pcnt-method
temp-dc-type.dflt-d-pcnt-method = integer(v-dflt-d-pcnt-method)
temp-dc-type.card-media
temp-dc-type.dflt-debet-card
temp-dc-type.fiscal-pay
temp-dc-type.mixed-pay
temp-dc-type.dflt-staff-card
t-check-by-mask
t-ho-join
.
RUN proc-refresh-tt IN this-procedure.

  for each buf_tt0-dis-dct-rule no-lock where
          buf_tt0-dis-dct-rule.emitent-host-code = temp-dc-type.emitent-host-code
      and buf_tt0-dis-dct-rule.type = temp-dc-type.type
      and (buf_tt0-dis-dct-rule.host-code > 0
      or  buf_tt0-dis-dct-rule.obj-code  > 0)
      and buf_tt0-dis-dct-rule.pos-type = {&cd-type-bo}:
    if buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
    or buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
    or buf_tt0-dis-dct-rule.discnt-role = {&ddctr-def-categ} then do:
    v-found-d-pcnt-byshop = yes.
    if temp-dc-type.d-pcnt-byshop = no then do:
      message
      "Для данного типа ДК НЕ установлен флаг СКИДКА/КАТЕГОРИЯ ПО ФИРМАМ/ОБЪЕКТАМ" skip
      "но ЗАДАНЫ скидки по умолчанию для объектов" skip
      "Данные скидки НЕ будут сохранены" skip
      "Продолжать?"
      view-as alert-box question buttons yes-no update glog.
      if not glog then do:
        undo, return error.
      end.
      else do:
        leave.
      end.
    end.
  end. /*if temp-dc-typ.d-cpnt-byshop = no */
end.
if v-found-d-pcnt-byshop = no and
temp-dc-type.d-pcnt-byshop = yes then do:
  message
  "Для данного типа ДК УСТАНОВЛЕН флаг СКИДКА/КАТЕГОРИЯ ПО ФИРМАМ/ОБЪЕКТАМ," skip
  "но НЕ заданы скидки по умолчанию для объектов" skip
  "Продолжать?"
  view-as alert-box question buttons yes-no update glog.
  if not glog then do:
    undo, return error.
  end.
end.
if p-mode = {&update}
and dis-card-type.d-pcnt-byshop <> temp-dc-type.d-pcnt-byshop then do:
 message
 "ВНИМАНИЕ! Вы изменили флаг СКИДКА/КАТЕГОРИЯ ПО ФИРМАМ/ОБЪЕКТАМ!" skip
 "Для того, чтобы на кассах были корректные данные по скидкам по ДК (соответствующие текущему значению флага"
 "рекомендуется послать ДК данного типу на кассу ВО ВСЕХ МАГАЗИНАХ СЕТИ!"
 "Продолжить?"
 view-as alert-box QUESTION buttons yes-no  update glog.
 if not glog then do:
   undo, return error.
  end.
end.
/*проверка - не удален ли какой нибудь профайл*/
for each buf_rp-by-call where
          buf_rp-by-call.call_id = temp-dc-type.uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = buf_rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_tt0-rp-by-call where
            buf_tt0-rp-by-call.call_id = buf_rp-by-call.call_id
        and buf_tt0-rp-by-call.profile_id =  buf_rp-by-call.profile_id
        and buf_tt0-rp-by-call.once-more =  buf_rp-by-call.once-more no-error.
  if not available buf_tt0-rp-by-call then do:
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь удалить профайл(ы), привязанные к данному типу ДК" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы лояльности по данному типу ДК" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к РАССИНХРОНИЗАЦИИ данных по ДК данного типа - например, к несоответствию данных по объекту и фирме и т.д." skip(0)
     "2. Даже если Вы передумаете и вновь добавите удаленные профайл(ы)," skip(0)
     "данные по продажам(накладным), закрытым в этот период будут отсутствовать" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
/*проверка - не добавлен ли какой нибудь профайл*/
for each tt0-rp-by-call where
          tt0-rp-by-call.call_id = temp-dc-type.uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_rp-by-call where
            buf_rp-by-call.call_id = buf_tt0-rp-by-call.call_id
        and buf_rp-by-call.profile_id =  buf_tt0-rp-by-call.profile_id
        and buf_rp-by-call.once-more =  buf_tt0-rp-by-call.once-more no-error.
  if not available buf_rp-by-call then do:
     v-found-new = yes.
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь добавить профайл(ы) к данному типу ДК" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы лояльности по данному типу ДК" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к неполноте данных по некоторым объектам и т.д." skip(0)
     "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
     "несвоевременное включение/выключение любого из этих правил МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
if not v-found-new  then do:
  message
  "ВНИМАНИЕ!!!" skip(0)
  "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
  "1. Изменения в работе системы лояльности по данному типу ДК" skip(0)
  "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
  "Это может привести к неполноте данных по некоторым объектам и т.д." skip(0)
  "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
  "несвоевременное включение/выключение любого правил из этих МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
   view-as alert-box WARNING buttons yes-no update v-ok.
  if not v-ok then do:
    undo, return .
  end.
end.



run ref/dctypei1.p (
                 input-output rid
                ,input p-mode
                ,input temp-dc-type.emitent-host-code
                ,input temp-dc-type.type
                ,input temp-dc-type.uniq-key-rec
                ,input 0
                ,input "":U
                ,input 0
                ,INPUT temp-dc-type.d-pcnt-byshop
                ,input temp-dc-type.dflt-d-pcnt-method
                ,input temp-dc-type.dflt-credit-card
                ,input (if temp-dc-type.dflt-credit-card then temp-dc-type.lim-kr else 0)
                ,INPUT temp-dc-type.dflt-debet-card
                ,INPUT temp-dc-type.dflt-staff-card
                ,INPUT temp-dc-type.fiscal-pay
                ,INPUT temp-dc-type.mixed-pay
                ,INPUT temp-dc-type.pay-code
                ,INPUT temp-dc-type.card-media
                ,INPUT temp-dc-type.cardname-sent
                ,INPUT temp-dc-type.custom-sent
                ,input temp-dc-type.dcbyshop
                ,input temp-dc-type.dc-pfx
                ,INPUT t-check-by-mask
                ,input t-ho-join
                ,input table tt0-dis-dct-rule
                ,INPUT TABLE tt0-hist-nws-option
                ,INPUT TABLE tt0-rp-by-call
                ,INPUT TABLE tt0-rule-by-call
                ,INPUT TABLE tt0-rule-call-param) no-error .
if error-status:error then do:
{ gbl/reterhnd.i error }
if return-value <> '':U then do:
  message
  error-status:get-message(1)
  return-value
  view-as alert-box .
end.
return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

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