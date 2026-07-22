&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_dis-rule FOR ub.dis-rule.
DEFINE BUFFER root_dis-rule FOR ub.dis-rule.
DEFINE BUFFER template_dis-rule FOR ub.dis-rule.
DEFINE BUFFER term_dis-rule FOR ub.dis-rule.
DEFINE TEMP-TABLE tt-bc-dis-rule NO-UNDO LIKE ub.bar-code
       field rule-num like ub.dis-rule.rule-num
       field price-brutto like ub.gds-obj.price-sale
       field price-netto like ub.gds-obj.price-sale
       field price-discnt like ub.gds-obj.price-sale
       field sum-brutto like ub.trn-doc.tot-sale
       field sum-netto like ub.trn-doc.tot-sale
       field sum-discnt like ub.trn-doc.tot-sale
       field d-pcnt like ub.dis-rule.discnt-value
       field sale-qnty like ub.dis-rule.doc-qnty
       index pi is unique primary rule-num.
DEFINE TEMP-TABLE tt-dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_goods FOR ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/02/04
Author: Bakhtadze Natalya
Creation date: 09/02/04

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS widget-handle NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS character NO-UNDO.
DEFINE INPUT PARAMETER p-templ-rl-root like ub.dis-rule.templ-rl-root NO-UNDO.
DEFINE INPUT PARAMETER p-host-code LIKE ub.sysconf.host-code NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT PARAMETER p-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define input parameter p-upper-rule-num like ub.dis-rule.upper-rule-num no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-recid AS recid NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование правил скидок".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/disrules.i "work" }
{ ref/gtregion.i }
define variable  v-rule-num          like ub.dis-rule.rule-num          no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
define variable  v-dis-kat-tree      as logical no-undo .
define variable  v-doc-qnty-tree     as logical no-undo .
define variable  v-tot-sum-tree      as logical no-undo .
define variable  v-charkey_one-tree  as logical no-undo .
define variable  v-charkey_two-tree  as logical no-undo .
define variable  v-charkey_three-tree  as logical no-undo .
define variable  v-deckey_one-tree  as logical no-undo .
define variable  v-deckey_two-tree  as logical no-undo .
define variable  v-deckey_three-tree  as logical no-undo .
define variable  v-key#_one-tree  as logical no-undo .
define variable  v-key#_two-tree  as logical no-undo .
define variable  v-key#_three-tree  as logical no-undo .
define variable  v-time-rule-num-tree as logical no-undo .
define variable  v-output-display as logical   no-undo . /* виден в броусе */
define variable  v-global         as integer no-undo .
define variable  v-host           as integer no-undo .
define variable  v-object         as integer no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo . /* еще чего - нибудь */
DEFINE VARIABLE v-tab-order       AS CHARACTER NO-UNDO.
define variable  is-good-mode as logical   no-undo . /* виден в броусе */
define variable v-meas as integer no-undo init 3.
DEFINE VARIABLE v-price-sale LIKE ub.price-list.price-sale NO-UNDO.
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
define variable v-doc-rec as recid no-undo .
define variable v-radio-integer-handle as handle no-undo .
define variable v-pos-type as character no-undo .
define variable v-is-copy as logical no-undo .
define variable v-start-br-term-dr-format as logical no-undo init yes.

define temp-table temp-gds-rule-attr no-undo
   field attr-code as char column-label "N!акции"
   field b-str like prod-bc.b-str
   field type-rec as char
   field r-id     as rowid
   .
def buffer buf_dis-gds-rule for dis-gds-rule.
def buffer buf_dis-gds-rule-attr for dis-gds-rule-attr.


DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE BUFFER X_cli-obj FOR ub.clients.
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule.
define buffer buf_units for ub.units.
define buffer buf_temp-drt-prop for temp-drt-prop.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-gds-rule-attr

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-gds-rule-attr tt0-term_dis-rule ~
tt-bc-dis-rule tt-dis-rule locked_dis-rule

/* Definitions for BROWSE BR-gds-rule-attr                              */
&Scoped-define FIELDS-IN-QUERY-BR-gds-rule-attr temp-gds-rule-attr.attr-code temp-gds-rule-attr.type-rec temp-gds-rule-attr.b-str
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds-rule-attr
&Scoped-define SELF-NAME BR-gds-rule-attr
&Scoped-define QUERY-STRING-BR-gds-rule-attr FOR EACH temp-gds-rule-attr
&Scoped-define OPEN-QUERY-BR-gds-rule-attr OPEN QUERY {&SELF-NAME} FOR EACH temp-gds-rule-attr .
&Scoped-define TABLES-IN-QUERY-BR-gds-rule-attr temp-gds-rule-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds-rule-attr temp-gds-rule-attr


/* Definitions for BROWSE BR-term-dr                                    */
&Scoped-define FIELDS-IN-QUERY-BR-term-dr entry (lookup (string(tt0-term_dis-rule.value-type), {&discnt-v-list}), {&discnt-v-list-full}) tt0-term_dis-rule.doc-qnty tt0-term_dis-rule.tot-sum tt0-term_dis-rule.dis-kat tt0-term_dis-rule.time-rule-num tt0-term_dis-rule.charkey_one tt0-term_dis-rule.charkey_two tt0-term_dis-rule.charkey_three tt0-term_dis-rule.deckey_one tt0-term_dis-rule.deckey_two tt0-term_dis-rule.deckey_three tt0-term_dis-rule.key#_one tt0-term_dis-rule.key#_two tt0-term_dis-rule.key#_three tt0-term_dis-rule.discnt-value tt0-term_dis-rule.des tt0-term_dis-rule.rule-num tt-bc-dis-rule.d-pcnt tt-bc-dis-rule.sale-qnty tt-bc-dis-rule.price-brutto tt-bc-dis-rule.price-discnt tt-bc-dis-rule.price-netto tt-bc-dis-rule.sum-brutto tt-bc-dis-rule.sum-discnt tt-bc-dis-rule.sum-netto
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-term-dr tt0-term_dis-rule.discnt-value
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-term-dr tt0-term_dis-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-term-dr tt0-term_dis-rule
&Scoped-define SELF-NAME BR-term-dr
&Scoped-define QUERY-STRING-BR-term-dr FOR EACH tt0-term_dis-rule OF ub.tt-dis-rule NO-LOCK, ~
             EACH tt-bc-dis-rule WHERE TRUE /* Join to tt0-term_dis-rule incomplete */ NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-term-dr OPEN QUERY {&SELF-NAME} FOR EACH tt0-term_dis-rule OF ub.tt-dis-rule NO-LOCK, ~
             EACH tt-bc-dis-rule WHERE TRUE /* Join to tt0-term_dis-rule incomplete */ NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-term-dr tt0-term_dis-rule tt-bc-dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-BR-term-dr tt0-term_dis-rule
&Scoped-define SECOND-TABLE-IN-QUERY-BR-term-dr tt-bc-dis-rule


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-dis-rule.des ~
tt-dis-rule.value-type tt-dis-rule.doc-qnty tt-dis-rule.tot-sum ~
tt-dis-rule.dis-kat tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One ~
tt-dis-rule.Deckey_one tt-dis-rule.Key#_One tt-dis-rule.CharKey_Two ~
tt-dis-rule.Deckey_two tt-dis-rule.Key#_Two tt-dis-rule.CharKey_Three ~
tt-dis-rule.Deckey_three tt-dis-rule.Key#_Three tt-dis-rule.discnt-value ~
tt-dis-rule.rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-dis-rule.des ~
tt-dis-rule.value-type tt-dis-rule.doc-qnty tt-dis-rule.tot-sum ~
tt-dis-rule.dis-kat tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One ~
tt-dis-rule.Deckey_one tt-dis-rule.Key#_One tt-dis-rule.CharKey_Two ~
tt-dis-rule.Deckey_two tt-dis-rule.Key#_Two tt-dis-rule.CharKey_Three ~
tt-dis-rule.Deckey_three tt-dis-rule.Key#_Three tt-dis-rule.discnt-value ~
tt-dis-rule.rule-num
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-dis-rule
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-dis-rule
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-gds-rule-attr}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-dis-rule SHARE-LOCK, ~
      EACH locked_dis-rule WHERE TRUE /* Join to tt-dis-rule incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-dis-rule SHARE-LOCK, ~
      EACH locked_dis-rule WHERE TRUE /* Join to tt-dis-rule incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-dis-rule locked_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-dis-rule
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame locked_dis-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-dis-rule.des tt-dis-rule.value-type ~
tt-dis-rule.doc-qnty tt-dis-rule.tot-sum tt-dis-rule.dis-kat ~
tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One tt-dis-rule.Deckey_one ~
tt-dis-rule.Key#_One tt-dis-rule.CharKey_Two tt-dis-rule.Deckey_two ~
tt-dis-rule.Key#_Two tt-dis-rule.CharKey_Three tt-dis-rule.Deckey_three ~
tt-dis-rule.Key#_Three tt-dis-rule.discnt-value tt-dis-rule.rule-num
&Scoped-define ENABLED-TABLES tt-dis-rule
&Scoped-define FIRST-ENABLED-TABLE tt-dis-rule
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-time-rule-lookup B-hist ~
B-Help f-pos-type B-add B-del BR-term-dr BR-gds-rule-attr f-d-pcnt ~
f-price-discnt t-flag f-price-netto f-sum-discnt f-sum-netto ~
B-dis-time-rule B-exit-1 B-quit-1 F-region F-price-brutto f-sale-qnty
&Scoped-Define DISPLAYED-FIELDS tt-dis-rule.des tt-dis-rule.value-type ~
tt-dis-rule.doc-qnty tt-dis-rule.tot-sum tt-dis-rule.dis-kat ~
tt-dis-rule.time-rule-num tt-dis-rule.CharKey_One tt-dis-rule.Deckey_one ~
tt-dis-rule.Key#_One tt-dis-rule.CharKey_Two tt-dis-rule.Deckey_two ~
tt-dis-rule.Key#_Two tt-dis-rule.CharKey_Three tt-dis-rule.Deckey_three ~
tt-dis-rule.Key#_Three tt-dis-rule.discnt-value tt-dis-rule.rule-num
&Scoped-define DISPLAYED-TABLES tt-dis-rule
&Scoped-define FIRST-DISPLAYED-TABLE tt-dis-rule
&Scoped-Define DISPLAYED-OBJECTS s-discnt-type f-pos-type s-subject-type ~
f-d-pcnt f-price-discnt t-flag f-price-netto f-sum-discnt f-sum-netto ~
F-region F-price-brutto f-sale-qnty f-sum-brutto

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-dis-time-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit-1
     LABEL "Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-quit-1
     LABEL "Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON B-time-rule-lookup
     LABEL "&Распис."
     SIZE 10 BY 1.

DEFINE VARIABLE f-pos-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Место исп."
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE s-discnt-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE s-subject-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Объект скидки"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-d-pcnt AS DECIMAL FORMAT ">9.99":U INITIAL 0
     LABEL "%"
     VIEW-AS FILL-IN
     SIZE 6 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE F-price-brutto AS DECIMAL FORMAT "->,>>>,>>9.99":U INITIAL 0
     LABEL "Цена б/скидки"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-price-discnt AS DECIMAL FORMAT "->,>>>,>>9.99":U INITIAL 0
     LABEL "Скидка за ед."
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-price-netto AS DECIMAL FORMAT ">,>>>,>>9.99":U INITIAL 0
     LABEL "Цена с/скидкой"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE F-region AS CHARACTER FORMAT "X(256)":U
     LABEL "Действует"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-sale-qnty AS DECIMAL FORMAT ">>,>>>,>>9.<<<" INITIAL 0
     LABEL "Кол-во товара для скидки"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-sum-brutto AS DECIMAL FORMAT "->,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма б/скидки"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-sum-discnt AS DECIMAL FORMAT "->,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма скидки"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-sum-netto AS DECIMAL FORMAT "->,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма со скидкой"
     VIEW-AS FILL-IN
     SIZE 13 BY 1
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE rs-radio-integer AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Item 1", 1,
"Item 2", 2
     SIZE 2.5 BY 1.25 NO-UNDO.

DEFINE VARIABLE t-flag AS LOGICAL INITIAL no
     LABEL "Toggle 1"
     VIEW-AS TOGGLE-BOX
     SIZE 3.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-gds-rule-attr FOR
      temp-gds-rule-attr SCROLLING.

DEFINE QUERY BR-term-dr FOR
      tt0-term_dis-rule,
      tt-bc-dis-rule SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-dis-rule,
      locked_dis-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-gds-rule-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds-rule-attr Dialog-Frame _FREEFORM
  QUERY BR-gds-rule-attr DISPLAY
      temp-gds-rule-attr.attr-code column-label "Номер!акции" format 'x(10)'
  temp-gds-rule-attr.type-rec format 'x(1)' column-label "тип!записи"
  temp-gds-rule-attr.b-str  format 'x(40)'
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 55.5 BY 16.75 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE BR-term-dr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-term-dr Dialog-Frame _FREEFORM
  QUERY BR-term-dr NO-LOCK DISPLAY
      entry (lookup (string(tt0-term_dis-rule.value-type), {&discnt-v-list}), {&discnt-v-list-full}) COLUMN-LABEL "Тип" FORMAT "X(10)":U
tt0-term_dis-rule.doc-qnty COLUMN-LABEL "Кол-во!для скидки" FORMAT ">>,>>>,>>9.<<<":U
tt0-term_dis-rule.tot-sum COLUMN-LABEL "Сумма для!скидки" FORMAT "->>>,>>>,>>9.99":U
tt0-term_dis-rule.dis-kat COLUMN-LABEL "Катег" FORMAT "->>>9":U
tt0-term_dis-rule.time-rule-num FORMAT "->>>>>>>>9":U
tt0-term_dis-rule.charkey_one FORMAT "X(12)":U
tt0-term_dis-rule.charkey_two FORMAT "X(12)":U
tt0-term_dis-rule.charkey_three FORMAT "X(12)":U
tt0-term_dis-rule.deckey_one FORMAT "->>,>>9.99":U
tt0-term_dis-rule.deckey_two FORMAT "->>,>>9.99":U
tt0-term_dis-rule.deckey_three FORMAT "->>,>>9.99":U
tt0-term_dis-rule.key#_one FORMAT "->>>>>>>>9":U
tt0-term_dis-rule.key#_two FORMAT "->>>>>>>>9":U
tt0-term_dis-rule.key#_three FORMAT "->>>>>>>>9":U
tt0-term_dis-rule.discnt-value COLUMN-LABEL "Знач. скидки" FORMAT "->>>,>>>,>>9.99":U
tt0-term_dis-rule.des FORMAT "X(255)":U
tt0-term_dis-rule.rule-num FORMAT ">>>>>>>>9":U
tt-bc-dis-rule.d-pcnt COLUMN-LABEL "%скидки" FORMAT "->>>,>>9.99":U
tt-bc-dis-rule.sale-qnty COLUMN-LABEL "Кол-во!для скидки" FORMAT ">>,>>>,>>9.999":U
tt-bc-dis-rule.price-brutto COLUMN-LABEL "Цена без скидки" FORMAT "->>,>>>,>>9.99":U
tt-bc-dis-rule.price-discnt COLUMN-LABEL "Скидка за ед." FORMAT "->>,>>>,>>9.99":U
tt-bc-dis-rule.price-netto COLUMN-LABEL "Цена со скидкой" FORMAT "->>,>>>,>>9.99":U
tt-bc-dis-rule.sum-brutto COLUMN-LABEL "Сумма без скидки" FORMAT ">,>>>,>>>,>>9.99":U
tt-bc-dis-rule.sum-discnt COLUMN-LABEL "Сумма скидки" FORMAT "->,>>>,>>>,>>9.99":U
tt-bc-dis-rule.sum-netto COLUMN-LABEL "Сумма со скидкой" FORMAT "->,>>>,>>>,>>9.99":U
ENABLE
tt0-term_dis-rule.discnt-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 56.5 BY 17.29
         FONT 4
         TITLE "Детализация" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-time-rule-lookup AT ROW 1 COL 41
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-dis-rule.des AT ROW 2 COL 10 COLON-ALIGNED
          LABEL "Описание"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
          FGCOLOR 4
     tt-dis-rule.value-type AT ROW 3 COL 10 COLON-ALIGNED WIDGET-ID 2
          LABEL "Тип знач."
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "0",1
          DROP-DOWN-LIST
          SIZE 31 BY 1
     s-discnt-type AT ROW 3.92 COL 14 COLON-ALIGNED
     f-pos-type AT ROW 3.92 COL 46 COLON-ALIGNED WIDGET-ID 6
     B-add AT ROW 3.92 COL 69
     B-del AT ROW 3.92 COL 79
     s-subject-type AT ROW 4.92 COL 14 COLON-ALIGNED
     BR-term-dr AT ROW 5 COL 42.5
     BR-gds-rule-attr AT ROW 5.25 COL 43 WIDGET-ID 100
     f-d-pcnt AT ROW 6.92 COL 2.5 COLON-ALIGNED
     f-price-discnt AT ROW 6.92 COL 27 COLON-ALIGNED
     t-flag AT ROW 7.88 COL 9 WIDGET-ID 4
     rs-radio-integer AT ROW 7.92 COL 4.5 NO-LABEL
     f-price-netto AT ROW 7.92 COL 27 COLON-ALIGNED
     tt-dis-rule.doc-qnty AT ROW 9.17 COL 26 COLON-ALIGNED
          LABEL "Кол-во тов-ра для скидки"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     f-sum-discnt AT ROW 11.42 COL 27 COLON-ALIGNED
     f-sum-netto AT ROW 12.42 COL 27 COLON-ALIGNED
     tt-dis-rule.tot-sum AT ROW 13.46 COL 26 COLON-ALIGNED
          LABEL "Сумма товара для скидки"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     tt-dis-rule.dis-kat AT ROW 14.46 COL 12.5 COLON-ALIGNED
          LABEL "Катег." FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1 TOOLTIP "Для категорийных клиентов"
     tt-dis-rule.time-rule-num AT ROW 14.46 COL 28.5 COLON-ALIGNED
          LABEL "№ расп."
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     B-dis-time-rule AT ROW 14.46 COL 39
     tt-dis-rule.CharKey_One AT ROW 15.46 COL 8.5 COLON-ALIGNED WIDGET-ID 8
          LABEL "Поле1"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-dis-rule.Deckey_one AT ROW 15.46 COL 19.5 COLON-ALIGNED WIDGET-ID 20
          LABEL "Дполе1"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     tt-dis-rule.Key#_One AT ROW 15.46 COL 30.5 COLON-ALIGNED WIDGET-ID 10
          LABEL "ИПоле1"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-dis-rule.CharKey_Two AT ROW 16.46 COL 8.5 COLON-ALIGNED WIDGET-ID 12
          LABEL "Поле2"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-dis-rule.Deckey_two AT ROW 16.46 COL 18.5 COLON-ALIGNED WIDGET-ID 22
          LABEL "Дполе2"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-dis-rule.Key#_Two AT ROW 16.46 COL 30.5 COLON-ALIGNED WIDGET-ID 14
          LABEL "Иполе2"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-dis-rule.CharKey_Three AT ROW 17.46 COL 8.5 COLON-ALIGNED WIDGET-ID 16
          LABEL "Поле3"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-dis-rule.Deckey_three AT ROW 17.46 COL 18.5 COLON-ALIGNED WIDGET-ID 24
          LABEL "Дполе3"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-dis-rule.Key#_Three AT ROW 17.46 COL 30.5 COLON-ALIGNED WIDGET-ID 18
          LABEL "ИПоле3"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-dis-rule.discnt-value AT ROW 18.58 COL 23.5 COLON-ALIGNED
          LABEL "Ск-ка (надб.)"
          VIEW-AS FILL-IN
          SIZE 16.5 BY 1 TOOLTIP "Для скидки -значение положительно, для надбавки отрицательно"
          FGCOLOR 4
     B-exit-1 AT ROW 19.67 COL 22
     B-quit-1 AT ROW 19.67 COL 32
     tt-dis-rule.rule-num AT ROW 1.25 COL 71.5 COLON-ALIGNED
          LABEL "№ правила"
           VIEW-AS TEXT
          SIZE 14 BY .67
          FGCOLOR 4
     F-region AT ROW 3 COL 74.5 COLON-ALIGNED
     F-price-brutto AT ROW 6.17 COL 27 COLON-ALIGNED
     f-sale-qnty AT ROW 9.21 COL 2
     f-sum-brutto AT ROW 10.42 COL 27 COLON-ALIGNED
     "!!! Для надбавки - отрицательно" VIEW-AS TEXT
          SIZE 35.5 BY .75 AT ROW 21.46 COL 1
          FGCOLOR 4
     "!!! Для скидки - значение  положительно" VIEW-AS TEXT
          SIZE 39.5 BY .75 AT ROW 20.75 COL 1
          FGCOLOR 4
     SPACE(58.74) SKIP(0.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правило скидки ТИПА:"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_dis-rule B "?" ? ub dis-rule
      TABLE: root_dis-rule B "?" ? ub dis-rule
      TABLE: template_dis-rule B "?" ? ub dis-rule
      TABLE: term_dis-rule B "?" ? ub dis-rule
      TABLE: tt-bc-dis-rule T "?" NO-UNDO ub bar-code
      ADDITIONAL-FIELDS:
          field rule-num like ub.dis-rule.rule-num
          field price-brutto like ub.gds-obj.price-sale
          field price-netto like ub.gds-obj.price-sale
          field price-discnt like ub.gds-obj.price-sale
          field sum-brutto like ub.trn-doc.tot-sale
          field sum-netto like ub.trn-doc.tot-sale
          field sum-discnt like ub.trn-doc.tot-sale
          field d-pcnt like ub.dis-rule.discnt-value
          field sale-qnty like ub.dis-rule.doc-qnty
          index pi is unique primary rule-num
      END-FIELDS.
      TABLE: tt-dis-rule T "?" NO-UNDO ub dis-rule
      TABLE: tt0-term_dis-rule T "?" NO-UNDO ub dis-rule
      TABLE: X_bar-code B "?" ? ub bar-code
      TABLE: X_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: X_goods B "?" ? ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-term-dr s-subject-type Dialog-Frame */
/* BROWSE-TAB BR-gds-rule-attr BR-term-dr Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-dis-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-exit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-quit-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-time-rule-lookup:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.CharKey_One IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.CharKey_One:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.CharKey_Three IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.CharKey_Three:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.CharKey_Two IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.CharKey_Two:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.Deckey_one IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Deckey_one:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.Deckey_three IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Deckey_three:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.Deckey_two IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Deckey_two:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.des IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-dis-rule.dis-kat IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
ASSIGN
       tt-dis-rule.dis-kat:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.discnt-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.discnt-value:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.doc-qnty IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.doc-qnty:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-d-pcnt:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       F-price-brutto:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-price-discnt:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-price-netto:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-sale-qnty IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       f-sale-qnty:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN f-sum-brutto IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       f-sum-brutto:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-sum-discnt:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       f-sum-netto:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.Key#_One IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Key#_One:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.Key#_Three IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Key#_Three:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.Key#_Two IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.Key#_Two:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR RADIO-SET rs-radio-integer IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       rs-radio-integer:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.rule-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR COMBO-BOX s-discnt-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX s-subject-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       t-flag:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.time-rule-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.time-rule-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-dis-rule.tot-sum IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       tt-dis-rule.tot-sum:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR COMBO-BOX tt-dis-rule.value-type IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds-rule-attr
/* Query rebuild information for BROWSE BR-gds-rule-attr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-gds-rule-attr .
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-gds-rule-attr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-term-dr
/* Query rebuild information for BROWSE BR-term-dr
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt0-term_dis-rule OF ub.tt-dis-rule NO-LOCK,
      EACH tt-bc-dis-rule WHERE TRUE /* Join to tt0-term_dis-rule incomplete */ NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-term-dr */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-dis-rule,Temp-Tables.locked_dis-rule WHERE Temp-Tables.tt-dis-rule ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Правило скидки ТИПА: */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  { gbl/stdbtn.i }
  IF b-exit-1:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
      BELL.
      RETURN NO-APPLY.
  END.
  RUN proc-b-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN do:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }
IF b-exit-1:VISIBLE IN FRAME {&FRAME-NAME} THEN DO:
    BELL.
    RETURN NO-APPLY.
END.

  RUN proc-b-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-time-rule Dialog-Frame
ON CHOOSE OF B-dis-time-rule IN FRAME Dialog-Frame
DO:
 run proc-b-dis-time-rule in this-procedure no-error.
 if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit-1 Dialog-Frame
ON CHOOSE OF B-exit-1 IN FRAME Dialog-Frame /* Ввод */
DO:
    { gbl/stdbtn.i }
  RUN proc-b-exit-1 IN THIS-PROCEDURE NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  define variable v-rid-list as character no-undo.
  if NOT available locked_dis-rule then return no-apply.
  run ref/discruls.w (
                   INPUT parParentProc
                  ,input "":U /*bttns*/
                  ,input "rl-root":U /**p-mode*/
                  ,input tt-dis-rule.rule-num
                  ,input tt-dis-rule.upper-rule-num
                  ,input "":U /*p-curr-obj-type*/
                  ,input 0 /*p-curr-obj-code*/
                  ,input-output v-rid-list ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-quit-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-quit-1 Dialog-Frame
ON CHOOSE OF B-quit-1 IN FRAME Dialog-Frame /* Отмена */
DO:
  { gbl/stdbtn.i }
  RUN proc-b-quit-1 IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-time-rule-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-time-rule-lookup Dialog-Frame
ON CHOOSE OF B-time-rule-lookup IN FRAME Dialog-Frame /* Распис. */
DO:
  RUN proc-time-rule-lookup IN THIS-PROCEDURE (V-TREE) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds-rule-attr
&Scoped-define SELF-NAME BR-gds-rule-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-gds-rule-attr Dialog-Frame
ON RETURN OF BR-gds-rule-attr IN FRAME Dialog-Frame
DO:
  def var v-upd as char no-undo .

  IF AVAIL TEMP-GDS-RULE-ATTR then
  do:

    if temp-gds-rule-attr.type-rec = "A" then
    do:
      assign
      v-upd = "D"
      .
    end.
    else
    do:
      assign
      v-upd = "A"
      .

    end.

    find buf_dis-gds-rule-attr where
        rowid(buf_dis-gds-rule-attr) = temp-gds-rule-attr.r-id
        exclusive-lock no-error.
    if avail buf_dis-gds-rule-attr then
    do:
      find current temp-gds-rule-attr no-error.
      if avail temp-gds-rule-attr then
      do:
        assign
          temp-gds-rule-attr.type-rec = v-upd
          buf_dis-gds-rule-attr.attr-value = temp-gds-rule-attr.b-str + "," + v-upd
           .
        find current temp-gds-rule-attr no-lock no-error.
        find current buf_dis-gds-rule-attr no-lock .

        browse {&self-name}:refresh().
      end.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-term-dr
&Scoped-define SELF-NAME BR-term-dr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-term-dr Dialog-Frame
ON VALUE-CHANGED OF BR-term-dr IN FRAME Dialog-Frame /* Детализация */
DO:
  IF AVAILABLE tt0-term_dis-rule
  AND tt0-term_dis-rule.time-rule-num > 0
  AND lookup("time-rule-num", v-level-2) > 0 THEN DO:
     ENABLE
     b-time-rule-lookup
     WITH FRAME {&FRAME-NAME}.
  END.
  if available tt0-term_dis-rule then do:
    assign
    v-term-value-type = tt0-term_dis-rule.value-type.
  end.
  else do:
    assign
    v-term-value-type = v-value-type.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.CharKey_One
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.CharKey_One Dialog-Frame
ON LEAVE OF tt-dis-rule.CharKey_One IN FRAME Dialog-Frame /* Поле1 */
DO:
    { gbl/stdbtn.i }
     RUN recalc IN THIS-PROCEDURE(
                                     INPUT f-price-brutto
                                     ,INPUT "discnt-value"
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                     )
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.CharKey_Three
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.CharKey_Three Dialog-Frame
ON LEAVE OF tt-dis-rule.CharKey_Three IN FRAME Dialog-Frame /* Поле3 */
DO:
    { gbl/stdbtn.i }
     RUN recalc IN THIS-PROCEDURE(
                                     INPUT f-price-brutto
                                     ,INPUT "discnt-value"
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                     )
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.CharKey_Two
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.CharKey_Two Dialog-Frame
ON LEAVE OF tt-dis-rule.CharKey_Two IN FRAME Dialog-Frame /* Поле2 */
DO:
    { gbl/stdbtn.i }
     RUN recalc IN THIS-PROCEDURE(
                                     INPUT f-price-brutto
                                     ,INPUT "discnt-value"
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                     )
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.dis-kat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.dis-kat Dialog-Frame
ON LEAVE OF tt-dis-rule.dis-kat IN FRAME Dialog-Frame /* Катег. */
DO:
{ gbl/stdbtn.i }
   RUN recalc IN THIS-PROCEDURE(
                                   INPUT f-price-brutto
                                   ,INPUT "discnt-value"
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                   )
 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.discnt-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.discnt-value Dialog-Frame
ON LEAVE OF tt-dis-rule.discnt-value IN FRAME Dialog-Frame /* Ск-ка (надб.) */
DO:
{ gbl/stdbtn.i }
   RUN recalc IN THIS-PROCEDURE(
                                   INPUT f-price-brutto
                                   ,INPUT "discnt-value"
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                   ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.doc-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.doc-qnty Dialog-Frame
ON LEAVE OF tt-dis-rule.doc-qnty IN FRAME Dialog-Frame /* Кол-во тов-ра для скидки */
DO:
{ gbl/stdbtn.i }
  RUN recalc IN THIS-PROCEDURE(
                                  INPUT f-price-brutto
                                  ,INPUT "discnt-value"
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                  )
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-price-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-price-discnt Dialog-Frame
ON LEAVE OF f-price-discnt IN FRAME Dialog-Frame /* Скидка за ед. */
DO:
{ gbl/stdbtn.i }
  ASSIGN
  f-price-discnt
  .
  RUN recalc IN THIS-PROCEDURE(
                                  INPUT f-price-brutto
                                  ,INPUT "price-discnt"
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                  )
.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-price-netto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-price-netto Dialog-Frame
ON LEAVE OF f-price-netto IN FRAME Dialog-Frame /* Цена с/скидкой */
DO:
{ gbl/stdbtn.i }
  ASSIGN
  f-price-netto
  .
  RUN recalc IN THIS-PROCEDURE(
                                  INPUT f-price-brutto
                                  ,INPUT "price-netto"
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                  )
.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-discnt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-discnt Dialog-Frame
ON LEAVE OF f-sum-discnt IN FRAME Dialog-Frame /* Сумма скидки */
DO:
{ gbl/stdbtn.i }
  ASSIGN
  f-sum-discnt
  .
  RUN recalc IN THIS-PROCEDURE(
                                  INPUT f-price-brutto
                                  ,INPUT "sum-discnt"
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                  )
.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-sum-netto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-sum-netto Dialog-Frame
ON LEAVE OF f-sum-netto IN FRAME Dialog-Frame /* Сумма со скидкой */
DO:
{ gbl/stdbtn.i }
  ASSIGN
  f-sum-netto
  .
  RUN recalc IN THIS-PROCEDURE(
                                  INPUT f-price-brutto
                                  ,INPUT "sum-netto"
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                  ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                  )
.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.Key#_One
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.Key#_One Dialog-Frame
ON LEAVE OF tt-dis-rule.Key#_One IN FRAME Dialog-Frame /* ИПоле1 */
DO:
    { gbl/stdbtn.i }
     RUN recalc IN THIS-PROCEDURE(
                                     INPUT f-price-brutto
                                     ,INPUT "discnt-value"
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                     )
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.Key#_Three
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.Key#_Three Dialog-Frame
ON LEAVE OF tt-dis-rule.Key#_Three IN FRAME Dialog-Frame /* ИПоле3 */
DO:
    { gbl/stdbtn.i }
     RUN recalc IN THIS-PROCEDURE(
                                     INPUT f-price-brutto
                                     ,INPUT "discnt-value"
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                     )
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.Key#_Two
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.Key#_Two Dialog-Frame
ON LEAVE OF tt-dis-rule.Key#_Two IN FRAME Dialog-Frame /* Иполе2 */
DO:
    { gbl/stdbtn.i }
     RUN recalc IN THIS-PROCEDURE(
                                     INPUT f-price-brutto
                                     ,INPUT "discnt-value"
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                     ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                     )
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.time-rule-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.time-rule-num Dialog-Frame
ON LEAVE OF tt-dis-rule.time-rule-num IN FRAME Dialog-Frame /* № расп. */
DO:
{ gbl/stdbtn.i }
    if   input frame {&frame-name} tt-dis-rule.time-rule-num <> 0 then do:
    run check-time-rule in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-dis-rule.tot-sum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-dis-rule.tot-sum Dialog-Frame
ON LEAVE OF tt-dis-rule.tot-sum IN FRAME Dialog-Frame /* Сумма товара для скидки */
DO:
{ gbl/stdbtn.i }
   RUN recalc IN THIS-PROCEDURE(
                                   INPUT f-price-brutto
                                   ,INPUT "discnt-value"
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.discnt-value )
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty )
                                   ,INPUT (INPUT FRAME {&frame-name} tt-dis-rule.tot-sum )
                                   )
 .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-gds-rule-attr
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }
{ gbl/disrules.i "interface" }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode <> {&add-def}
  and p-mode <> {&lookup}
  and p-mode <> {&update}
  and p-mode <> {&add-copy}
  THEN DO:
      MESSAGE
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметра p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  IF p-mode <> {&add-def} THEN DO:

  END.
  if p-mode = {&add-copy} then do:
    v-is-copy = yes.
    p-mode = {&add-def}.
  end.
  for each tt-dis-rule:
    delete tt-dis-rule.
  end.
  for each tt0-term_dis-rule:
    delete tt0-term_dis-rule.
  end.
  run dr-code  in this-procedure (
     input  p-templ-rl-root
    ,output v-des
    ,output v-discnt-type
    ,output v-subject-type
    ,output v-value-type
    ,output v-level-1
    ,output v-level-2
    ,output v-global
    ,output v-host
    ,output v-object
    ,output v-output-display
    ,output v-tree
    ,output v-other
                               ) no-error .
  IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-templ-rl-root" p-templ-rl-root SKIP
     error-status:get-message(1) SKIP
     RETURN-VALUE
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.

  END.
  v-term-value-type = v-value-type.
  run disrules-fill-properties in this-procedure ( input p-templ-rl-root).
  /*для BOSCI мы не можем посчитать конерктные скидки - они зависят от скидки на ДК*/
  if can-find(first temp-drt-prop where
                   temp-drt-prop.templ-rl-root = p-templ-rl-root
               and temp-drt-prop.prop-code = "CalcGoodsPrice":U
               and temp-drt-prop.upper-prop-code = "":U
               and temp-drt-prop.property-value  = "no") then do:
    assign
    p-b-code = 0
    .
  end.

  IF p-b-code <> 0  THEN DO:

    IF v-subject-type <> INTEGER({&discnt-gds}) THEN DO:
        MESSAGE
            vss-workfile vss-revision vss-description skip
            "Неверное значение параметра p-b-code" p-b-code SKIP
             error-status:get-message(1) SKIP
             RETURN-VALUE
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.
    END.
    FIND FIRST X_bar-code NO-LOCK WHERE
                X_bar-code.b-code = p-b-code NO-ERROR.
    IF NOT AVAILABLE X_bar-code THEN DO:
      MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-b-code" p-b-code SKIP
         error-status:get-message(1) SKIP
         RETURN-VALUE
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
     END.
     FIND FIRST X_goods NO-LOCK WHERE X_goods.gds-code = X_bar-code.gds-code NO-ERROR.
     IF NOT AVAILABLE X_goods THEN DO:
    MESSAGE
        vss-workfile vss-revision vss-description skip
        "Неверное значение параметра p-b-code" p-b-code SKIP
         error-status:get-message(1) SKIP
         RETURN-VALUE
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
     END.
    ASSIGN
    is-good-mode = YES.
    find first buf_units no-lock where
               buf_units.unit-name = X_goods.unit-base no-error.
    if available buf_units then do:
      assign
      v-meas = if( LOOKUP({&pieces}, buf_units.type) > 0 or LOOKUP({&serial}, buf_units.type) > 0 )
               then 0
               else v-meas.
    end.

    { gbl/bcodeprc.i
        p-obj-type
        p-obj-code
        p-b-code
        0
        0
        v-doc-num
        v-price-sale
        v-road-tax
        v-excise
        no-error }

  END.
  run fill-main-table in this-procedure.
  if p-upper-rule-num > {&max-num-dr-template} then do:
    assign
    v-tree = "":U.
  end.
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-time-rule Dialog-Frame
PROCEDURE check-time-rule :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
              buf_dis-time-rule.time-rule-num = input frame {&frame-name} tt-dis-rule.time-rule-num
         no-error.
if not available buf_dis-time-rule then do:
  if input frame {&frame-name} tt-dis-rule.time-rule-num <> ?  then
    message "Неправильный номер расписания" .
  apply "entry" to tt-dis-rule.time-rule-num in frame {&frame-name}.
  return error.
end.
find first X_dis-time-rule no-lock where recid(X_dis-time-rule) = recid(buf_dis-time-rule).
assign
tt-dis-rule.time-rule-num = buf_dis-time-rule.time-rule-num
tt-dis-rule.time-templ-rl-root = buf_dis-time-rule.templ-rl-root
.

display
tt-dis-rule.time-rule-num
with frame {&frame-name}.

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE display-hide-fields Dialog-Frame
PROCEDURE display-hide-fields :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-main AS LOGICAL NO-UNDO. /*какую записб редактируем 1 - main 0 терминальную - подчин*/
DEFINE INPUT PARAMETER p-display-hide AS integer NO-UNDO. /*1 - display 0 hide*/

hide br-gds-rule-attr in frame {&frame-name}.

CASE p-display-hide:
  WHEN 1 THEN DO:
    IF p-main THEN DO:
      IF lookup("dis-kat", v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.dis-kat
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.dis-kat WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.dis-kat
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("doc-qnty":U, v-level-1) > 0 THEN DO:

        DISPLAY
        tt-dis-rule.doc-qnty
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.doc-qnty WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
        IF is-good-mode  THEN DO:
          if available locked_dis-rule
          and locked_dis-rule.templ-rl-root <> 91 then
          do:
           DISPLAY
            f-sum-brutto
            f-sum-discnt
            f-sum-netto
            WITH FRAME {&FRAME-NAME}.
           ENABLE
            f-sum-brutto WHEN p-mode <> {&lookup}
            f-sum-discnt WHEN p-mode <> {&lookup}
            f-sum-netto WHEN p-mode <> {&lookup}
            WITH FRAME {&FRAME-NAME}.
          end.
        END.

      END.
      else do:
        hide
        tt-dis-rule.doc-qnty
        in FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          HIDE
          f-sum-brutto
          f-sum-discnt
          f-sum-netto
          IN FRAME {&FRAME-NAME}.
        END.
      end.
      IF lookup("tot-sum":U, v-level-1) > 0 THEN DO:
        DISPLAY
        tt-dis-rule.tot-sum
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.tot-sum WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          DISPLAY
          f-sum-brutto
          f-sum-discnt
          f-sum-netto
          f-sale-qnty
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          f-sum-brutto WHEN p-mode <> {&lookup}
          f-sum-discnt WHEN p-mode <> {&lookup}
          f-sum-netto WHEN p-mode <> {&lookup}
          f-sale-qnty WHEN p-mode <> {&lookup}
          WITH FRAME {&FRAME-NAME}.
        END.
      END.
      else do:
        hide
        tt-dis-rule.tot-sum
        in FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          IF lookup("doc-qnty", v-level-1) = 0  THEN
          HIDE
          f-sum-brutto
          f-sum-discnt
          f-sum-netto
          IN FRAME {&FRAME-NAME}.
          HIDE
          f-sale-qnty
          IN FRAME {&FRAME-NAME}.
        END.
      end.
      IF lookup("time-rule-num":U, v-level-1) > 0 THEN DO:
        ASSIGN
        b-time-rule-lookup:ROW = 1
        b-time-rule-lookup:column = b-hist:COLUMN - 10
        .
        DISPLAY
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        b-time-rule-lookup
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.time-rule-num WHEN p-mode <> {&LOOKUP}
        b-dis-time-rule WHEN p-mode <> {&LOOKUP}
        b-time-rule-LOOKUP
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        b-time-rule-lookup
        in FRAME {&FRAME-NAME}.
      END.
      IF lookup("key#_one":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.key#_one
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.key#_one WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.key#_one
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("key#_two":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.key#_two
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.key#_two WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.key#_two
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("key#_three":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.key#_three
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.key#_three WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.key#_three
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_one":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.charkey_one
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.charkey_one WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_one
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_two":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.charkey_two
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.charkey_two WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_two
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_three":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.charkey_three
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.charkey_three WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_three
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("deckey_one":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.deckey_one
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.deckey_one WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.deckey_one
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("deckey_two":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.deckey_two
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.deckey_two WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.deckey_two
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("deckey_three":U, v-level-1) > 0 THEN DO:
         DISPLAY
         tt-dis-rule.deckey_three
         WITH FRAME {&FRAME-NAME}.
         ENABLE
         tt-dis-rule.deckey_three WHEN p-mode <> {&LOOKUP}
         WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.deckey_three
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("discnt-value", v-level-1) > 0 THEN DO:
        DISPLAY tt-dis-rule.discnt-value
        WITH FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.discnt-value WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
        IF is-good-mode
        and (v-value-type = integer({&discnt-v-pcnt})
             or
             v-value-type = integer({&discnt-v-abs})
             or
             v-value-type = integer({&discnt-v-FP}))
        THEN DO:
          DISPLAY
          f-price-brutto
          f-price-discnt
          f-price-netto
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          f-price-discnt WHEN p-mode <> {&LOOKUP}
          f-price-netto  WHEN p-mode <> {&LOOKUP}
          WITH FRAME {&FRAME-NAME}.
          if v-value-type <> integer({&discnt-v-pcnt}) THEN DO:
            DISPLAY
            f-d-pcnt
            WITH FRAME {&FRAME-NAME}.
            ENABLE
            f-d-pcnt
            WITH FRAME {&FRAME-NAME}.
          END.
        END.
      END.
      /*
      IF lookup("time-rule-num":U, v-level-1) > 0  THEN DO:
          ASSIGN
          b-time-rule-lookup:ROW = b-add:ROW
          b-time-rule-lookup:column = b-add:COLUMN + 20
          .
          DISPLAY
          b-time-rule-lookup
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          b-time-rule-LOOKUP
          WITH FRAME {&FRAME-NAME}.

      END.
        HIDE
        tt-dis-rule.discnt-value
        IN FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          hide
          f-price-brutto
          f-price-discnt
          f-price-netto
          in FRAME {&FRAME-NAME}.
          if v-value-type <> integer({&discnt-v-pcnt}) THEN DO:
            hide
            f-d-pcnt
            in FRAME {&FRAME-NAME}.
        END.
      END.
    END.  */
    END. /*p-main = 1*/
    ELSE DO: /*p-main = 0*/
      IF lookup("dis-kat", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.dis-kat
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.dis-kat WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.dis-kat
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("doc-qnty", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.doc-qnty
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.doc-qnty WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          DISPLAY
          f-sum-brutto f-sum-discnt f-sum-netto
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          f-sum-brutto WHEN p-mode <> {&lookup}
          f-sum-discnt WHEN p-mode <> {&lookup}
          f-sum-netto WHEN p-mode <> {&lookup}
          WITH FRAME {&FRAME-NAME}.
        END.
      END.
      else do:
        hide
        tt-dis-rule.doc-qnty
        in FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          HIDE
          f-sum-brutto f-sum-discnt f-sum-netto
          IN FRAME {&FRAME-NAME}.
        END.
      end.
      IF lookup("tot-sum", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.tot-sum
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.tot-sum WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
        IF is-good-mode
        and (v-term-value-type = integer({&discnt-v-pcnt})
             or
             v-term-value-type = integer({&discnt-v-abs})
             or
             v-term-value-type = integer({&discnt-v-FP}))
        THEN DO:
          DISPLAY
          f-sum-brutto f-sum-discnt f-sum-netto f-sale-qnty
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          f-sum-brutto WHEN p-mode <> {&lookup}
          f-sum-discnt WHEN p-mode <> {&lookup}
          f-sum-netto WHEN p-mode <> {&lookup}
          f-sale-qnty WHEN p-mode <> {&lookup}
          WITH FRAME {&FRAME-NAME}.
        END.
      END.
      else do:
        hide
        tt-dis-rule.tot-sum
        in FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          IF lookup("doc-qnty", v-level-2) = 0  THEN
          HIDE
          f-sum-brutto
          f-sum-discnt
          f-sum-netto
          IN FRAME {&FRAME-NAME}.
          HIDE
          f-sale-qnty
          IN FRAME {&FRAME-NAME}.
        END.
      end.
      IF lookup("time-rule-num", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.time-rule-num WHEN p-mode <> {&LOOKUP}
        b-dis-time-rule WHEN p-mode <> {&LOOKUP}
        B-time-rule-lookup
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.time-rule-num
        b-dis-time-rule
        B-time-rule-lookup
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("key#_one", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.key#_one
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.key#_one WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.key#_one
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("key#_two", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.key#_two
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.key#_two WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.key#_two
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("key#_three", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.key#_three
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.key#_three WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.key#_three
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_one", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.charkey_one
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.charkey_one WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_one
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_two", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.charkey_two
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.charkey_two WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_two
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("charkey_three", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.charkey_three
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.charkey_three WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.charkey_three
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("deckey_one", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.deckey_one
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.deckey_one WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.deckey_one
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("deckey_two", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.deckey_two
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.deckey_two WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.deckey_two
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("deckey_three", v-level-2) > 0 THEN DO:
        view
        tt-dis-rule.deckey_three
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.deckey_three WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
      END.
      else do:
        hide
        tt-dis-rule.deckey_three
        in FRAME {&FRAME-NAME}.
      end.
      IF lookup("discnt-value", v-level-2) > 0 THEN DO:
        view tt-dis-rule.discnt-value
        in FRAME {&FRAME-NAME}.
        ENABLE
        tt-dis-rule.discnt-value WHEN p-mode <> {&LOOKUP}
        WITH FRAME {&FRAME-NAME}.
        IF is-good-mode
        and (v-term-value-type = integer({&discnt-v-pcnt})
             or
             v-term-value-type = integer({&discnt-v-abs})
             or
             v-term-value-type = integer({&discnt-v-FP}))
        THEN DO:
          DISPLAY
          f-price-brutto
          f-price-discnt
          f-price-netto
          WITH FRAME {&FRAME-NAME}.
          ENABLE
          f-price-discnt WHEN p-mode <> {&LOOKUP}
          f-price-netto  WHEN p-mode <> {&LOOKUP}
          WITH FRAME {&FRAME-NAME}.
          if v-term-value-type <> integer({&discnt-v-pcnt}) THEN DO:
            DISPLAY
            f-d-pcnt
            WITH FRAME {&FRAME-NAME}.
            ENABLE
            f-d-pcnt
            WITH FRAME {&FRAME-NAME}.
          END.
        END.
      END.
      ELSE DO:
        HIDE
        tt-dis-rule.discnt-value
        IN FRAME {&FRAME-NAME}.
        IF is-good-mode THEN DO:
          hide
          f-price-brutto
          f-price-discnt
          f-price-netto
          in FRAME {&FRAME-NAME}.
        if v-term-value-type <> integer({&discnt-v-pcnt}) THEN DO:
          hide
          f-d-pcnt
          in FRAME {&FRAME-NAME}.
        END.
      END.
    END.
    END. /*p-main = 0*/
  END. /*when 1 = display*/
  WHEN 0 THEN DO:
    HIDE
    tt-dis-rule.doc-qnty
    tt-dis-rule.tot-sum
    tt-dis-rule.dis-kat
    tt-dis-rule.key#_one
    tt-dis-rule.key#_two
    tt-dis-rule.key#_three
    tt-dis-rule.charkey_one
    tt-dis-rule.charkey_two
    tt-dis-rule.charkey_three
    tt-dis-rule.deckey_one
    tt-dis-rule.deckey_two
    tt-dis-rule.deckey_three
    tt-dis-rule.time-rule-num
    b-time-rule-lookup
    b-dis-time-rule
    tt-dis-rule.discnt-value
    f-d-pcnt
    f-sale-qnty
    F-price-brutto
    f-price-discnt
    f-price-netto
    f-sum-brutto
    f-sum-discnt
    f-sum-netto
    in FRAME {&FRAME-NAME}.
  END.
END CASE.

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
  DISPLAY s-discnt-type f-pos-type s-subject-type f-d-pcnt f-price-discnt t-flag
          f-price-netto f-sum-discnt f-sum-netto F-region F-price-brutto
          f-sale-qnty f-sum-brutto
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-dis-rule THEN
    DISPLAY tt-dis-rule.des tt-dis-rule.value-type tt-dis-rule.doc-qnty
          tt-dis-rule.tot-sum tt-dis-rule.dis-kat tt-dis-rule.time-rule-num
          tt-dis-rule.CharKey_One tt-dis-rule.Deckey_one tt-dis-rule.Key#_One
          tt-dis-rule.CharKey_Two tt-dis-rule.Deckey_two tt-dis-rule.Key#_Two
          tt-dis-rule.CharKey_Three tt-dis-rule.Deckey_three
          tt-dis-rule.Key#_Three tt-dis-rule.discnt-value tt-dis-rule.rule-num
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-time-rule-lookup B-hist B-Help tt-dis-rule.des
         tt-dis-rule.value-type f-pos-type B-add B-del BR-term-dr
         BR-gds-rule-attr f-d-pcnt f-price-discnt t-flag f-price-netto
         tt-dis-rule.doc-qnty f-sum-discnt f-sum-netto tt-dis-rule.tot-sum
         tt-dis-rule.dis-kat tt-dis-rule.time-rule-num B-dis-time-rule
         tt-dis-rule.CharKey_One tt-dis-rule.Deckey_one tt-dis-rule.Key#_One
         tt-dis-rule.CharKey_Two tt-dis-rule.Deckey_two tt-dis-rule.Key#_Two
         tt-dis-rule.CharKey_Three tt-dis-rule.Deckey_three
         tt-dis-rule.Key#_Three tt-dis-rule.discnt-value B-exit-1 B-quit-1
         tt-dis-rule.rule-num F-region F-price-brutto f-sale-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-main-table Dialog-Frame
PROCEDURE fill-main-table :
if p-mode = {&update}
or p-mode = {&lookup}
or (p-mode = {&add-def} and v-is-copy)
then do:
  find first locked_dis-rule no-lock where
          recid(locked_dis-rule) = p-recid no-error .
  if not available locked_dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена запись ПРАВИЛО СКИДОК с номером" p-rule-num
    view-as alert-box error .
    undo, return error.
  end.
  if locked_dis-rule.root = no then do:
    message
    substitute("Невозможен просмотр не корневого правила &1", p-rule-num)
    view-as alert-box error .
    undo, return error .
  end.
  if p-mode = {&update} then do:
    find first locked_dis-rule EXclusive-lock where
                  recid(locked_dis-rule) = p-recid no-wait no-error.
    if locked locked_dis-rule then do:
      message
      vss-workfile vss-revision vss-description skip
        "Запись ПРАВИЛО СКИДОК занята"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_dis-rule no-lock where
                      recid(locked_dis-rule) = p-recid no-error .
    if not avail locked_dis-rule then do:
      find first locked_dis-rule no-lock where
                  locked_dis-rule.rule-num = p-rule-num no-error .
    end.
  end.
  if locked_dis-rule.rule-num <= {&max-num-dr-template}
  and p-mode = {&update} then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя редактировать ШАБЛОНЫ СКИДОК"
    view-as alert-box error .
    undo, return error.
  end.
  create tt-dis-rule.
  buffer-copy locked_dis-rule to tt-dis-rule
  .
   if p-mode = {&add-def}
   and v-is-copy = yes then do:
    assign
    tt-dis-rule.rule-num = locked_dis-rule.templ-rl-root
    tt-dis-rule.host-code = p-host-code
    tt-dis-rule.obj-type = p-obj-type
    tt-dis-rule.obj-code = p-obj-code
    .
   end.
   if is-good-mode and locked_dis-rule.templ-rl-root= 91 then
   do:
      for each buf_dis-gds-rule no-lock
          where buf_dis-gds-rule.rule-num = locked_dis-rule.rule-num
            and buf_dis-gds-rule.gds-code = X_bar-code.gds-code
            and buf_dis-gds-rule.nonunique = string(X_bar-code.b-code)
            and buf_dis-gds-rule.pos-type = {&cd-type-NCR-AS-R},
          each  buf_dis-gds-rule-attr no-lock where
                buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
            AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
            AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
            AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
            AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
            and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique:
         create temp-gds-rule-attr.
         assign
           temp-gds-rule-attr.attr-code = buf_dis-gds-rule-attr.attr-code
           temp-gds-rule-attr.b-str = entry(1,buf_dis-gds-rule-attr.attr-value,',')
           temp-gds-rule-attr.type-rec = entry(2,buf_dis-gds-rule-attr.attr-value,',')
           temp-gds-rule-attr.r-id = rowid(buf_dis-gds-rule-attr)
          .

      end.
   end.
  end.
else do:
      FIND FIRST template_dis-rule NO-LOCK WHERE
                  template_dis-rule.rule-num = p-templ-rl-root .
      create tt-dis-rule.
      BUFFER-COPY template_dis-rule TO tt-dis-rule
      ASSIGN
      tt-dis-rule.upper-rule-num = template_dis-rule.rule-num
      tt-dis-rule.templ-rl-root  = template_dis-rule.rule-num
      tt-dis-rule.root        = yes
      tt-dis-rule.host-code = p-host-code
      tt-dis-rule.obj-type = p-obj-type
      tt-dis-rule.obj-code = p-obj-code
      tt-dis-rule.des = trim(template_dis-rule.des, "@":U)
      tt-dis-rule.lvl-num = 1
      .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable v-ii as integer no-undo .
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
IF p-mode = {&add-def} AND tt-dis-rule.is-term = no and not v-is-copy then  RETURN.
IF tt-dis-rule.time-rule-num <> 0 THEN
FIND FIRST X_dis-time-rule WHERE X_dis-time-rule.time-rule-num = tt-dis-rule.time-rule-num NO-ERROR.

FOR EACH buf_tt0-term_dis-rule:
    DELETE buf_tt0-term_dis-rule.
END.
run ref/dcr-pos.p (
                   input p-mode
                  ,input no /*p-silent*/
                  ,input p-templ-rl-root
                  ,input tt-dis-rule.host-code
                  ,input tt-dis-rule.obj-type
                  ,input tt-dis-rule.obj-code
                  ,input tt-dis-rule.sts
                  ,input tt-dis-rule.rule-num
                  ,output v-pos-type) no-error.
if error-status:error then do:
  message
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo,  return error.
end.
assign
v-dis-kat-tree   = lookup("dis-kat":U, v-tree) > 0
v-doc-qnty-tree  = lookup("doc-qnty":U, v-tree) > 0
v-tot-sum-tree   = lookup("tot-sum":U,  v-tree) > 0
v-time-rule-num-tree = lookup("time-rule-num":U, v-tree) > 0
v-charkey_one-tree = lookup("charkey_one":U, v-tree) > 0
v-charkey_two-tree = lookup("charkey_two":U, v-tree) > 0
v-charkey_three-tree = lookup("charkey_three":U, v-tree) > 0
v-deckey_one-tree = lookup("deckey_one":U, v-tree) > 0
v-deckey_two-tree = lookup("deckey_two":U, v-tree) > 0
v-deckey_three-tree = lookup("deckey_three":U, v-tree) > 0
v-key#_one-tree = lookup("key#_one":U, v-tree) > 0
v-key#_two-tree = lookup("key#_two":U, v-tree) > 0
v-key#_three-tree = lookup("key_#three":U, v-tree) > 0
.


&SCOPED-DEFINE calc-values                                                                                         ~
if buf_dis-rule.tot-sum = - 1 then do:                                                                            ~
  /*это скидка на строку товара*/                                                                               ~
    CASE buf_dis-rule.value-type:                                                                                 ~
        WHEN INTEGER(~{&discnt-v-pcnt~}) THEN DO:                                                               ~
          ASSIGN                                                                                               ~
          tt-bc-dis-rule.d-pcnt      = buf_dis-rule.discnt-value                                              ~
          tt-bc-dis-rule.price-discnt = tt-bc-dis-rule.price-brutto * buf_dis-rule.discnt-value / 100            ~
          tt-bc-dis-rule.price-netto = tt-bc-dis-rule.price-brutto - tt-bc-dis-rule.price-discnt               ~
          tt-bc-dis-rule.sum-brutto = ABS(tt-bc-dis-rule.price-brutto * buf_dis-rule.doc-qnty)               ~
          tt-bc-dis-rule.sum-netto = ABS(tt-bc-dis-rule.price-netto * buf_dis-rule.doc-qnty)                 ~
          tt-bc-dis-rule.sum-discnt = ABS(tt-bc-dis-rule.price-discnt * buf_dis-rule.doc-qnty).              ~
        END.                                                                                                    ~
        WHEN INTEGER(~{&discnt-v-abs~}) THEN DO:                                                                ~
            ASSIGN                                                                                              ~
            tt-bc-dis-rule.price-discnt = buf_dis-rule.discnt-value                                           ~
            tt-bc-dis-rule.price-netto = tt-bc-dis-rule.price-brutto - tt-bc-dis-rule.price-discnt              ~
            tt-bc-dis-rule.d-pcnt       = 100 * (1 - tt-bc-dis-rule.price-netto / tt-bc-dis-rule.price-brutto)  ~
            tt-bc-dis-rule.sum-brutto = ABS(tt-bc-dis-rule.price-brutto * buf_dis-rule.doc-qnty)              ~
            tt-bc-dis-rule.sum-netto = ABS(tt-bc-dis-rule.price-netto * buf_dis-rule.doc-qnty)                ~
            tt-bc-dis-rule.sum-discnt = ABS(tt-bc-dis-rule.price-discnt * buf_dis-rule.doc-qnty).             ~
        END.                                                                                                    ~
        WHEN INTEGER(~{&discnt-v-FP~}) THEN DO:                                                                 ~
            ASSIGN                                                                                              ~
            tt-bc-dis-rule.price-netto = buf_dis-rule.discnt-value                                            ~
            tt-bc-dis-rule.price-discnt = tt-bc-dis-rule.price-brutto - tt-bc-dis-rule.price-netto              ~
            tt-bc-dis-rule.sum-brutto = ABS(tt-bc-dis-rule.price-brutto * buf_dis-rule.doc-qnty)              ~
            tt-bc-dis-rule.sum-netto = ABS(tt-bc-dis-rule.price-netto * buf_dis-rule.doc-qnty)                ~
            tt-bc-dis-rule.sum-discnt = ABS(tt-bc-dis-rule.price-discnt * buf_dis-rule.doc-qnty).             ~
        END.                                                                                                   ~
    END CASE.                                                                                                   ~
end.                                                                                                           ~
else do:                                                                                                       ~
/*это скидка на сумму товара по строке*/                                                                       ~
    assign  tt-bc-dis-rule.sale-qnty = truncate(buf_dis-rule.tot-sum / tt-bc-dis-rule.price-brutto, v-meas).  ~
    CASE buf_dis-rule.value-type:                                                                                 ~
        WHEN INTEGER(~{&discnt-v-pcnt~}) THEN DO:                                                               ~
          ASSIGN                                                                                               ~
          tt-bc-dis-rule.price-discnt = tt-bc-dis-rule.price-brutto * buf_dis-rule.discnt-value / 100            ~
          tt-bc-dis-rule.d-pcnt      = buf_dis-rule.discnt-value                                             ~
          tt-bc-dis-rule.price-netto = tt-bc-dis-rule.price-brutto - tt-bc-dis-rule.price-discnt               ~
          tt-bc-dis-rule.sum-brutto = tt-bc-dis-rule.price-brutto * tt-bc-dis-rule.sale-qnty                   ~
          tt-bc-dis-rule.sum-netto = tt-bc-dis-rule.price-netto * tt-bc-dis-rule.sale-qnty                     ~
          tt-bc-dis-rule.sum-discnt = tt-bc-dis-rule.price-discnt * tt-bc-dis-rule.sale-qnty .                  ~
        END.                                                                                                    ~
        WHEN INTEGER(~{&discnt-v-abs~}) THEN DO:                                                                ~
            ASSIGN                                                                                              ~
            tt-bc-dis-rule.price-discnt = buf_dis-rule.discnt-value                                           ~
            tt-bc-dis-rule.price-netto = tt-bc-dis-rule.price-brutto - tt-bc-dis-rule.price-discnt              ~
            tt-bc-dis-rule.d-pcnt       = 100 * (1 - tt-bc-dis-rule.price-netto / tt-bc-dis-rule.price-brutto)  ~
            tt-bc-dis-rule.sum-brutto = tt-bc-dis-rule.price-brutto * tt-bc-dis-rule.sale-qnty                  ~
            tt-bc-dis-rule.sum-netto = tt-bc-dis-rule.price-netto * tt-bc-dis-rule.sale-qnty                    ~
            tt-bc-dis-rule.sum-discnt = tt-bc-dis-rule.price-discnt * tt-bc-dis-rule.sale-qnty .                ~
        END.                                                                                                    ~
        WHEN INTEGER(~{&discnt-v-FP~}) THEN DO:                                                                 ~
            ASSIGN                                                                                              ~
            tt-bc-dis-rule.price-netto = buf_dis-rule.discnt-value                                            ~
            tt-bc-dis-rule.price-discnt = tt-bc-dis-rule.price-brutto - tt-bc-dis-rule.price-netto              ~
            tt-bc-dis-rule.sum-brutto = tt-bc-dis-rule.price-brutto * tt-bc-dis-rule.sale-qnty                  ~
            tt-bc-dis-rule.sum-netto = tt-bc-dis-rule.price-netto * tt-bc-dis-rule.sale-qnty                    ~
            tt-bc-dis-rule.sum-discnt = tt-bc-dis-rule.price-discnt * tt-bc-dis-rule.sale-qnty .                ~
        END.                                                                                                   ~
    END CASE.                                                                                                   ~
end
v-ii = 0.
if tt-dis-rule.is-term = no then do:
  FOR EACH buf_dis-rule NO-LOCK WHERE
          buf_dis-rule.upper-rule-num = (if v-is-copy then p-rule-num else tt-dis-rule.rule-num):
    v-ii = v-ii + 1.
    CREATE buf_tt0-term_dis-rule.
    BUFFER-COPY buf_dis-rule
    except rule-num upper-rule-num
    TO buf_tt0-term_dis-rule
    ASSIGN
    buf_tt0-term_dis-rule.rule-num = (if v-is-copy then v-ii else buf_dis-rule.rule-num)
    buf_tt0-term_dis-rule.upper-rule-num = (if v-is-copy then abs(tt-dis-rule.rule-num) else buf_dis-rule.upper-rule-num)
    buf_tt0-term_dis-rule.doc-qnty = (IF lookup("discnt-value":U, v-level-2) = 0
                                      THEN 0
                                      ELSE buf_dis-rule.discnt-value)
    buf_tt0-term_dis-rule.doc-qnty = (IF lookup("doc-qnty":U, v-level-2) = 0
                                      THEN 0
                                      ELSE buf_dis-rule.doc-qnty)
    buf_tt0-term_dis-rule.dis-kat = (IF lookup("dis-kat":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.dis-kat)
    buf_tt0-term_dis-rule.tot-sum = (IF lookup("tot-sum":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.tot-sum)
    buf_tt0-term_dis-rule.time-rule-num = (IF lookup("time-rule-num":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.time-rule-num)
    buf_tt0-term_dis-rule.charkey_one = (IF lookup("charkey_one":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_one)
    buf_tt0-term_dis-rule.charkey_two = (IF lookup("charkey_two":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_two)
    buf_tt0-term_dis-rule.charkey_three = (IF lookup("charkey_three":U, v-level-2) = 0
                                          THEN "":U
                                          ELSE buf_dis-rule.charkey_three)
    buf_tt0-term_dis-rule.deckey_one = (IF lookup("deckey_one":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_one)
    buf_tt0-term_dis-rule.deckey_two = (IF lookup("deckey_two":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_two)
    buf_tt0-term_dis-rule.deckey_three = (IF lookup("deckey_three":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.deckey_three)
    buf_tt0-term_dis-rule.key#_one = (IF lookup("key#_one":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_one)
    buf_tt0-term_dis-rule.key#_two = (IF lookup("key#_two":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_two)
    buf_tt0-term_dis-rule.key#_three = (IF lookup("key#_three":U, v-level-2) = 0
                                          THEN 0
                                          ELSE buf_dis-rule.key#_three)
    .
    create tt-bc-dis-rule.
    assign
    tt-bc-dis-rule.rule-num = (if p-mode = {&add-def}
                               then (if v-is-copy
                                     then v-ii
                                     else - buf_dis-rule.rule-num )
                               else  buf_dis-rule.rule-num)
    tt-bc-dis-rule.price-brutto = v-price-sale
    f-price-brutto = tt-bc-dis-rule.price-brutto
    .
    {&calc-values}.
  END.
end.
else do:
  FOR EACH buf_dis-rule NO-LOCK WHERE
          buf_dis-rule.rule-num = (if v-is-copy then p-rule-num else tt-dis-rule.rule-num):
    create tt-bc-dis-rule.
    assign
    tt-bc-dis-rule.rule-num = (if p-mode = {&add-def}
                               then (if v-is-copy
                                     then - p-rule-num
                                     else - buf_dis-rule.rule-num)
                                else buf_dis-rule.rule-num)
    tt-bc-dis-rule.price-brutto = v-price-sale
    .
    {&calc-values}.
    if is-good-mode then do:
      assign
      f-price-brutto = tt-bc-dis-rule.price-brutto
      f-price-netto = tt-bc-dis-rule.price-netto
      f-price-discnt = tt-bc-dis-rule.price-discnt
      f-d-pcnt = tt-bc-dis-rule.d-pcnt
      f-sum-brutto = tt-bc-dis-rule.sum-brutto
      f-sum-netto = tt-bc-dis-rule.sum-netto
      f-sum-discnt = tt-bc-dis-rule.sum-discnt
      f-sale-qnty = tt-bc-dis-rule.sale-qnty
      .
    end.
    leave.
  end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable ii AS INTEGER NO-UNDO.
define variable v-lookup-dtr1 AS CHARACTER NO-UNDO.
define variable v-lookup-dtr2 AS CHARACTER NO-UNDO.
define variable v-dop as character no-undo .
define variable v-entry as character no-undo .
define variable jj as integer no-undo .
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-h AS handle NO-UNDO.
define buffer buf_temp-drt-prop for temp-drt-prop.

v-h = br-term-dr:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
DO while valid-handle(v-h) :
  find first buf_temp-drt-prop no-lock where
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
        and buf_temp-drt-prop.upper-prop-code = v-h:name
        and buf_temp-drt-prop.prop-code = "column-label" no-error.
  if available buf_temp-drt-prop then do:
    assign
    v-h:label = buf_temp-drt-prop.property-value.
  end.
  if v-h:LABEL = "Тип" then do:
    v-h:RESIZABLE = YES.
    v-h:visible = (v-value-type = integer({&discnt-v-hybrid1})).
  end.
  /*
  find first buf_temp-drt-prop no-lock where
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
        and buf_temp-drt-prop.upper-prop-code = v-h:name
        and buf_temp-drt-prop.prop-code = "format":U no-error.
  if available buf_temp-drt-prop then do:
    assign
    v-h:format = buf_temp-drt-prop.property-value.
  end.
  */
  v-h = v-h:NEXT-COLUMN.

END.

v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt}).
END.
assign
f-pos-type:list-item-pairs in frame {&frame-name} = v-list-items.

ASSIGN
tt-bc-dis-rule.d-pcnt:VISIBLE IN BROWSE br-term-dr = NO
tt-bc-dis-rule.sum-brutto:VISIBLE IN BROWSE br-term-dr = no
tt-bc-dis-rule.sum-discnt:VISIBLE IN BROWSE br-term-dr = no
tt-bc-dis-rule.sum-netto:VISIBLE IN BROWSE br-term-dr = no
tt-bc-dis-rule.price-brutto:VISIBLE IN BROWSE br-term-dr = NO
tt-bc-dis-rule.price-discnt:VISIBLE IN BROWSE br-term-dr = NO
tt-bc-dis-rule.price-netto:VISIBLE IN BROWSE br-term-dr = NO
tt-bc-dis-rule.sale-qnty:VISIBLE IN BROWSE br-term-dr = no
tt0-term_dis-rule.discnt-value:visible IN BROWSE BR-term-dr = false
tt0-term_dis-rule.doc-qnty:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.tot-sum:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.dis-kat:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.time-rule-num:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.discnt-value:COLUMN-READ-ONLY IN BROWSE BR-term-dr = TRUE
tt0-term_dis-rule.charkey_one:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.charkey_two:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.charkey_three:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.deckey_one:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.deckey_two:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.deckey_three:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.key#_one:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.key#_two:VISIBLE IN BROWSE BR-term-dr = FALSE
tt0-term_dis-rule.key#_three:VISIBLE IN BROWSE BR-term-dr = FALSE
tt-bc-dis-rule.d-pcnt:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.sum-brutto:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.sum-discnt:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.sum-netto:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.price-brutto:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.price-discnt:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.price-netto:auto-resize IN BROWSE br-term-dr = yes
tt-bc-dis-rule.sale-qnty:auto-resize IN BROWSE br-term-dr = yes
tt0-term_dis-rule.discnt-value:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.doc-qnty:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.tot-sum:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.dis-kat:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.time-rule-num:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.charkey_one:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.charkey_two:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.charkey_three:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.deckey_one:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.deckey_two:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.deckey_three:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.key#_one:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.key#_two:auto-resize IN BROWSE BR-term-dr = true
tt0-term_dis-rule.key#_three:auto-resize IN BROWSE BR-term-dr = true
.
if can-find( first ub.dis-cfg-rule no-lock where
                   ub.dis-cfg-rule.templ-rl-root = p-templ-rl-root
               and ub.dis-cfg-rule.table-name = {&table_dis-thbj-rule})
or p-mode = {&add-def} then do:
  f-pos-type = v-pos-type.
  f-pos-type:VISIBLE IN FRAME {&FRAME-NAME} = YES.
  display f-pos-type
  with frame {&frame-name} .
END.
ASSIGN
v-lookup-dtr1 = IF lookup("time-rule-num":U, v-level-1) > 0 THEN "b-time-rule-lookup"
                ELSE "":U
v-lookup-dtr2 = if lookup("time-rule-num":U, v-level-2) > 0 THEN "b-time-rule-lookup"
                ELSE "":U
v-tab-order = "b-exit,b-quit," + v-lookup-dtr1 +
              "des,b-add,b-del," + v-lookup-dtr2 +
              "f-d-pcnt,f-price-discnt,f-price-netto,doc-qnty,f-sum-discnt,f-sum-netto,f-sale-qnty," +
              "tot-sum,dis-kat,time-rule-num,b-dis-time-rule,"  +
              "charkey_one,deckey_one,key#_one,charkey_two,deckey_two,key#_two,charkey_three,deckey_three,key#_three," +
              "discnt-value,b-exit-1,b-quit-1"
s-discnt-type:LIST-ITEMS IN FRAME {&FRAME-NAME} = {&discnt-type-list-full}
s-discnt-type:PRIVATE-DATA = {&discnt-type-list}
S-subject-type:LIST-ITEMS = {&discnt-target-list-full}
s-subject-type:PRIVATE-DATA = {&discnt-target-list}
FRAME {&FRAME-NAME}:TITLE = FRAME {&FRAME-NAME}:TITLE + {&space-char} + v-des
f-region = gtregion(tt-dis-rule.host-code, tt-dis-rule.obj-type, tt-dis-rule.obj-code, no)
tt-dis-rule.discnt-value:LABEL = (IF v-value-type = INTEGER({&discnt-v-pcnt})
                                  THEN (tt-dis-rule.discnt-value:LABEL + " %")
                                  ELSE tt-dis-rule.discnt-value:LABEL)
.

DO ii = 1 TO NUM-ENTRIES({&discnt-v-list}):
    ASSIGN
    tt-dis-rule.value-type:list-item-pairs = (if ii = 1 then "":U else tt-dis-rule.value-type:list-item-pairs) +
                                           (IF ii = 1 THEN "":U ELSE {&comma-char}) +
                                           ENTRY(ii, {&discnt-v-list-full}) + {&comma-char} +
                                           ENTRY(ii, {&discnt-v-list})
    .
END.
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, YES /*main record*/, 1 /*display*/).
IF v-tree = "":U THEN DO:
  HIDE
  br-term-dr
  b-exit-1
  b-quit-1
  b-add
  b-del
  in FRAME {&FRAME-NAME}.
END.
ELSE DO:
    HIDE
    tt-dis-rule.discnt-value
    IN FRAME {&FRAME-NAME}.
    DO ii = 1 TO NUM-ENTRIES(v-level-2):
      case ENTRY(ii, v-level-2):
        when "discnt-value":U then do:
          ASSIGN
          tt0-term_dis-rule.discnt-value:VISIBLE IN BROWSE br-term-dr = YES
          .
        end.
        WHEN "doc-qnty":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.doc-qnty:VISIBLE IN BROWSE br-term-dr = YES
          .
          IF is-good-mode  THEN DO:
              ASSIGN
              tt-bc-dis-rule.sum-brutto:VISIBLE IN BROWSE br-term-dr = YES
              tt-bc-dis-rule.sum-discnt:VISIBLE IN BROWSE br-term-dr = YES
              tt-bc-dis-rule.sum-netto:VISIBLE IN BROWSE br-term-dr = YES
              .
          END.
        END.
        WHEN "dis-kat":U THEN DO:
            ASSIGN
            tt0-term_dis-rule.dis-kat:VISIBLE IN BROWSE br-term-dr = YES
            .
        END.
        WHEN "tot-sum":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.tot-sum:VISIBLE IN BROWSE br-term-dr = YES
          .
          if is-good-mode then do:
            assign
            tt-bc-dis-rule.sale-qnty:VISIBLE IN BROWSE br-term-dr = YES
            tt-bc-dis-rule.sum-brutto:VISIBLE IN BROWSE br-term-dr = YES
            tt-bc-dis-rule.sum-discnt:VISIBLE IN BROWSE br-term-dr = YES
            tt-bc-dis-rule.sum-netto:VISIBLE IN BROWSE br-term-dr = YES
            tt-bc-dis-rule.sale-qnty:VISIBLE IN BROWSE br-term-dr = YES
            .
          end.
        END.
        WHEN "time-rule-num":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.time-rule-num:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "charkey_one":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.charkey_one:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "charkey_two":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.charkey_two:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "charkey_three":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.charkey_three:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "deckey_one":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.deckey_one:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "deckey_two":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.deckey_two:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "deckey_three":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.deckey_three:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "key#_one":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.key#_one:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "key#_two":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.key#_two:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
        WHEN "key#_three":U THEN DO:
          ASSIGN
          tt0-term_dis-rule.key#_three:VISIBLE IN BROWSE br-term-dr = YES
          .
        END.
      END CASE.
    END. /*do ii*/
    if v-value-type <> integer({&discnt-v-pcnt})
    and p-b-code > 0 then do:
      tt-bc-dis-rule.d-pcnt:VISIBLE IN BROWSE br-term-dr = YES.
    end.
    assign
    tt0-term_dis-rule.discnt-value:LABEL IN BROWSE br-term-dr = (IF v-value-type = INTEGER({&discnt-v-pcnt})
                              THEN (tt0-term_dis-rule.discnt-value:LABEL IN BROWSE br-term-dr + " %")
                              ELSE tt0-term_dis-rule.discnt-value:LABEL IN BROWSE br-term-dr).
    ENABLE
    b-add WHEN p-mode <> {&LOOKUP}
    b-DEL WHEN p-mode <> {&LOOKUP}
    WITH FRAME {&FRAME-NAME}.
END.

&scop discnt-type-code  string(tt-dis-rule.discnt-type)

assign
s-discnt-type = {&discnt-type-name}
.
&scop discnt-target-code string(tt-dis-rule.subject-type)

ASSIGN
s-subject-type =  {&discnt-target-name}
.

if is-good-mode then do:
   assign
   frame {&frame-name}:title = frame {&frame-name}:title + substitute("в применении к товару &1, цены для бар-кода &2"
                                                                       , X_goods.gds-code
                                                                       , p-b-code) .
end.


DISPLAY
S-discnt-type
S-subject-type
f-region
WITH FRAME {&frame-name}.
  IF AVAILABLE tt-dis-rule THEN
  DISPLAY
  tt-dis-rule.des
  tt-dis-rule.rule-num
  tt-dis-rule.value-type
  WITH FRAME {&frame-name}.
  IF lookup("discnt-value", v-level-1) > 0 THEN
  DISPLAY
  tt-dis-rule.discnt-value when (tt-dis-rule.discnt-type <> integer({&discnt-t-manual}) and
                                tt-dis-rule.discnt-type <> integer({&discnt-t-alt-condition}) )
                                and lookup("discnt-value", v-level-1) > 0
  WITH FRAME {&frame-name}.
  /*
  DISPLAY
  tt-dis-rule.dis-kat WHEN  tt-dis-rule.dis-kat <> - 1
  tt-dis-rule.doc-qnty WHEN  tt-dis-rule.doc-qnty <> - 1
  tt-dis-rule.time-rule-num WHEN  tt-dis-rule.time-rule-num <> 0
  WITH FRAME {&frame-name}.
  */
  ENABLE
  b-quit
  B-exit WHEN p-mode <> {&lookup}
  b-hist when p-mode <> {&add-def}
  B-Help
  tt-dis-rule.des WHEN p-mode <> {&lookup}
  WITH FRAME {&frame-name}.
  /*
  ENABLE
  tt-dis-rule.dis-kat WHEN p-mode <> {&LOOKUP} AND tt-dis-rule.dis-kat <> - 1
  tt-dis-rule.doc-qnty WHEN p-mode <> {&LOOKUP} AND tt-dis-rule.doc-qnty <> - 1
  tt-dis-rule.time-rule-num WHEN p-mode <> {&LOOKUP} AND tt-dis-rule.time-rule-num <> 0
  B-dis-time-rule WHEN p-mode <> {&LOOKUP} AND tt-dis-rule.time-rule-num <>  0
  tt-dis-rule.discnt-value WHEN p-mode <> {&LOOKUP} AND v-tree = "":U
  WITH FRAME {&frame-name}.
  */
VIEW FRAME {&frame-name}.
if v-value-type = integer({&discnt-v-radio-integer}) then do:
  find first buf_temp-drt-prop no-lock where
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
        and buf_temp-drt-prop.upper-prop-code = "Discnt-value"
        and buf_temp-drt-prop.prop-code  = "radio":U no-error.
  v-dop = buf_temp-drt-prop.property-value.
  assign
  rs-radio-integer:sensitive  = (p-mode <> {&lookup})
  rs-radio-integer:visible  = yes
  rs-radio-integer:row           = 10
  rs-radio-integer:column        = 1
  rs-radio-integer:width         = 35
  rs-radio-integer:height        = 2
  rs-radio-integer:radio-buttons = v-dop
  .
  hide
  tt-dis-rule.discnt-value
  t-flag
  in frame {&frame-name} .
end.
if v-value-type = integer({&discnt-v-flag}) then do:
  assign
  t-flag:sensitive  = no
  t-flag            = yes
  t-flag:visible  = yes
  t-flag:screen-value = string(t-flag, "yes/no")
  t-flag:row           = 10
  t-flag:column        = 10
  t-flag:width         = 35
  t-flag:height        = 2
  t-flag:label         = "Флаг"
  .

  hide
  tt-dis-rule.discnt-value
  rs-radio-integer
  in frame {&frame-name} .
end.
IF p-mode = {&LOOKUP} THEN DO:
  HIDE
  b-exit
  B-dis-time-rule IN FRAME {&FRAME-NAME}.
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:column = 1
  tt0-term_dis-rule.discnt-value:READ-ONLY IN BROWSE br-term-dr = YES
  .
END.
IF v-tree <> "":u THEN DO:
  ENABLE
  br-term-dr
  WITH FRAME {&FRAME-NAME}.
  RUN openbr-term-dr in this-procedure .
  APPLY "VALUE-CHANGED" TO br-term-dr IN FRAME {&FRAME-NAME}.
END.
IF p-mode = {&LOOKUP} THEN APPLY "ENTRY" TO b-exit.

ELSE do:
  IF v-tree <> "":U THEN
  APPLY "entry" to b-add.
  ELSE APPLY "entry" TO f-price-discnt.
END.
if tt-dis-rule.discnt-type = integer({&discnt-t-manual}) then do:
  hide
  tt-dis-rule.discnt-value
  in frame {&frame-name} .
end.
run disrules-override-labels(input p-templ-rl-root) no-error .
if p-mode = {&add-def}
and v-pos-type <> '' then do:
  define buffer buf3_dis-cfg-rule for ub.dis-cfg-rule.
  find first buf3_dis-cfg-rule no-lock where
            buf3_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and buf3_dis-cfg-rule.pos-type = v-pos-type
        and buf3_dis-cfg-rule.time-templ-rl-root > 0
        and lookup("time-rule-num", v-level-1) > 0
        no-error.
  if available buf3_dis-cfg-rule then do:
    disable
    tt-dis-rule.time-rule-num
    with frame {&frame-name}   .
    apply "CHOOSE" to b-dis-time-rule.
  end.
end.
if p-templ-rl-root = 91 and is-good-mode then
do:
  enable BR-gds-rule-attr with frame {&frame-name} .
  open query br-gds-rule-attr
     for each temp-gds-rule-attr no-lock. 

  
end.
else
do:
  hide BR-gds-rule-attr  in frame {&frame-name} .

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr-term-dr Dialog-Frame 
PROCEDURE OpenBr-term-dr :
define variable v-h as widget-handle no-undo .
v-h = br-term-dr:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
if p-templ-rl-root = 80 then do:
  OPEN QUERY BR-term-dr
    FOR  EACH tt0-term_dis-rule WHERE
            tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num,
    FIRST tt-bc-dis-rule NO-LOCK WHERE tt-bc-dis-rule.rule-num = tt0-term_dis-rule.rule-num
  BY tt0-term_dis-rule.discnt-value
  BY tt0-term_dis-rule.dis-kat
  .
end.
else do:
OPEN QUERY BR-term-dr
  FOR  EACH tt0-term_dis-rule WHERE
           tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num,
  FIRST tt-bc-dis-rule NO-LOCK WHERE tt-bc-dis-rule.rule-num = tt0-term_dis-rule.rule-num
BY tt0-term_dis-rule.doc-qnty
BY tt0-term_dis-rule.tot-sum
BY tt0-term_dis-rule.dis-kat
BY tt0-term_dis-rule.time-rule-num
.
end.
if available tt0-term_dis-rule
and v-start-br-term-dr-format
then do:
  v-start-br-term-dr-format = no.
  DO while valid-handle(v-h) :
    find first buf_temp-drt-prop no-lock where
              buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
          and buf_temp-drt-prop.upper-prop-code = v-h:name
          and buf_temp-drt-prop.prop-code = "format":U no-error.
    if available buf_temp-drt-prop then do:
      assign
      v-h:format = buf_temp-drt-prop.property-value.
    end.
    v-h = v-h:NEXT-COLUMN.
  END.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame 
PROCEDURE proc-b-add :
define variable choice as integer no-undo .
IF v-tree = "":U THEN RETURN ERROR.
if v-value-type = integer({&discnt-v-hybrid1}) then do:

  run gbl/d-askw.w ( input "Рекомендация"
              ,input  ("Выберите тип скидки" + {&new-line}
                      + "(% или Abs или Фиксированная цена)")
              ,input "|"
              ,input "%|Abs|Фиксированная цена|Отмена"
              ,input "|||"
              ,input 1
              ,input 4
              ,output choice).
  if choice = 4 then do:
    undo, return error .
  end.
  case choice:
    when 1 then do:
      v-term-value-type = integer({&discnt-v-pcnt}).
    end.
    when 2 then do:
      v-term-value-type = integer({&discnt-v-abs}).
    end.
    when 3 then do:
      v-term-value-type = integer({&discnt-v-FP}).
    end.
  end case.
end.
IF tt-dis-rule.discnt-value:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.discnt-value
.
IF tt-dis-rule.dis-kat:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.dis-kat
.

IF tt-dis-rule.doc-qnty:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.doc-qnty
.

IF tt-dis-rule.tot-sum:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.tot-sum
.

IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.time-rule-num
.
IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.charkey_one
.
IF tt-dis-rule.charkey_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.charkey_two
.
IF tt-dis-rule.charkey_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.charkey_three
.
IF tt-dis-rule.deckey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.deckey_one
.
IF tt-dis-rule.deckey_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.deckey_two
.
IF tt-dis-rule.deckey_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.deckey_three
.
IF tt-dis-rule.key#_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.key#_one
.
IF tt-dis-rule.key#_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.key#_two
.
IF tt-dis-rule.key#_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN
ASSIGN
tt-dis-rule.key#_three
.
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, NO /*main record*/, 1 /*display*/).
IF v-doc-qnty-tree
AND tt-dis-rule.doc-qnty:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.doc-qnty
   WITH FRAME {&FRAME-NAME}.
END.
IF v-tot-sum-tree
AND tt-dis-rule.tot-sum:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.tot-sum
   WITH FRAME {&FRAME-NAME}.
END.
IF v-dis-kat-tree
AND tt-dis-rule.dis-kat:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.dis-kat
   WITH FRAME {&FRAME-NAME}.
END.
IF v-time-rule-num-tree
AND tt-dis-rule.time-rule-num:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.time-rule-num
   WITH FRAME {&FRAME-NAME}.
END.
IF v-charkey_one-tree
AND tt-dis-rule.charkey_one:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.charkey_one
   WITH FRAME {&FRAME-NAME}.
END.
IF v-charkey_two-tree
AND tt-dis-rule.charkey_two:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.charkey_two
   WITH FRAME {&FRAME-NAME}.
END.
IF v-charkey_three-tree
AND tt-dis-rule.charkey_three:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.charkey_three
   WITH FRAME {&FRAME-NAME}.
END.
IF v-deckey_one-tree
AND tt-dis-rule.deckey_one:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.deckey_one
   WITH FRAME {&FRAME-NAME}.
END.
IF v-deckey_two-tree
AND tt-dis-rule.deckey_two:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.deckey_two
   WITH FRAME {&FRAME-NAME}.
END.
IF v-deckey_three-tree
AND tt-dis-rule.deckey_three:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   '':U @ tt-dis-rule.deckey_three
   WITH FRAME {&FRAME-NAME}.
END.
IF v-key#_one-tree
AND tt-dis-rule.key#_one:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.key#_one
   WITH FRAME {&FRAME-NAME}.
END.
IF v-key#_two-tree
AND tt-dis-rule.key#_two:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.key#_two
   WITH FRAME {&FRAME-NAME}.
END.
IF v-key#_three-tree
AND tt-dis-rule.key#_three:sensitive  IN FRAME {&FRAME-NAME} THEN DO:
   DISPLAY
   0 @ tt-dis-rule.key#_three
   WITH FRAME {&FRAME-NAME}.
END.


ENABLE
b-exit-1
b-quit-1
WITH FRAME {&FRAME-NAME}.
disable
b-exit
with frame {&frame-name} .
APPLY "ENTRY" TO f-price-discnt.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame 
PROCEDURE proc-b-del :
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
DEFINE BUFFER buf_tt-bc-dis-rule    FOR tt-bc-dis-rule.
IF v-tree = "":U THEN RETURN ERROR.
IF NOT AVAILABLE tt0-term_dis-rule THEN RETURN.
FIND first buf_tt0-term_dis-rule WHERE RECID(buf_tt0-term_dis-rule) = RECID(tt0-term_dis-rule).
FIND first buf_tt-bc-dis-rule WHERE RECID(buf_tt-bc-dis-rule) = RECID(tt-bc-dis-rule).
DELETE buf_tt0-term_dis-rule.
DELETE buf_tt-bc-dis-rule.
RUN rename-term_dis-rule in this-procedure .
RUN openbr-term-dr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-dis-time-rule Dialog-Frame 
PROCEDURE proc-b-dis-time-rule :
define variable v-time-rule-num like ub.dis-rule.time-rule-num no-undo .
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO INIT -1.
DEFINE VARIABLE v-rid-list AS character NO-UNDO  .
DEFINE BUFFER buf_dis-time-rule FOR ub.dis-time-rule .
{ gbl/stdbtn.i }
if input frame {&frame-name} tt-dis-rule.time-rule-num <> 0
and input frame {&frame-name} tt-dis-rule.time-rule-num <> ? then do:
  find first buf_dis-time-rule no-lock where
            buf_dis-time-rule.time-rule-num = input frame {&frame-name} tt-dis-rule.time-rule-num no-error .
  if available buf_dis-time-rule then do:
    assign
    v-rid-list = string(recid(buf_dis-time-rule)).
  end.
end.
/* показываем те, которые могут использоваться*/
run ref/dist-rls.w (
                input parparentproc
              ,input "b-sel,b-add"
              ,input ( if p-mode = {&add-def} then {&table_dis-rule} else ("rule-num" + {&comma-char} + {&update}))
              ,input (if p-mode = {&add-def} then tt-dis-rule.templ-rl-root else tt-dis-rule.rule-num)
              ,input ( if p-mode = {&add-def} then 0 else tt-dis-rule.time-templ-rl-root)
              ,input ( if p-mode = {&add-def} then v-pos-type else '')
              ,input-output v-sts
              ,input-output v-rid-list) no-error .
IF v-rid-list = "":U THEN RETURN ERROR.
FIND FIRST buf_dis-time-rule NO-LOCK WHERE
          RECID(buf_dis-time-rule) = INTEGER(ENTRY(1, v-rid-list)) NO-ERROR.
if error-status:error
  then  do:
  return error.
end.
ASSIGN
v-time-rule-num = buf_dis-time-rule.time-rule-num.

find first X_dis-time-rule no-lock where
          X_dis-time-rule.time-rule-num = v-time-rule-num NO-ERROR.
      .
assign
tt-dis-rule.time-rule-num =  X_dis-time-rule.time-rule-num
tt-dis-rule.time-templ-rl-root = X_dis-time-rule.templ-rl-root
.
display
tt-dis-rule.time-rule-num
with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit-1 Dialog-Frame 
PROCEDURE proc-b-exit-1 :
DEFINE VARIABLE v-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE VARIABLE v-dis-kat LIKE ub.dis-rule.dis-kat NO-UNDO.
DEFINE VARIABLE v-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-rule.time-rule-num NO-UNDO.
define variable v-charkey_one like ub.dis-rule.charkey_one no-undo .
define variable v-charkey_two like ub.dis-rule.charkey_two no-undo .
define variable v-charkey_three like ub.dis-rule.charkey_three no-undo .
define variable v-deckey_one like ub.dis-rule.deckey_one no-undo .
define variable v-deckey_two like ub.dis-rule.deckey_two no-undo .
define variable v-deckey_three like ub.dis-rule.deckey_three no-undo .
define variable v-key#_one like ub.dis-rule.key#_one no-undo .
define variable v-key#_two like ub.dis-rule.key#_two no-undo .
define variable v-key#_three like ub.dis-rule.key#_three no-undo .
DEFINE VARIABLE v-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.

DEFINE VARIABLE v-dub AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
IF v-tree = "":U  THEN RETURN ERROR.
/*проверим что такого нет*/
ASSIGN
v-doc-qnty = tt-dis-rule.doc-qnty
v-dis-kat = tt-dis-rule.dis-kat
v-tot-sum = tt-dis-rule.tot-sum
v-time-rule-num = tt-dis-rule.time-rule-num
v-charkey_one = tt-dis-rule.charkey_one
v-charkey_two = tt-dis-rule.charkey_two
v-charkey_three = tt-dis-rule.charkey_three
v-deckey_one = tt-dis-rule.deckey_one
v-deckey_two = tt-dis-rule.deckey_two
v-deckey_three = tt-dis-rule.deckey_three
v-key#_one = tt-dis-rule.key#_one
v-key#_two = tt-dis-rule.key#_two
v-key#_three = tt-dis-rule.key#_three
.


IF tt-dis-rule.doc-qnty:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-doc-qnty = INPUT FRAME {&frame-name} tt-dis-rule.doc-qnty
  .
END.
IF tt-dis-rule.dis-kat:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-dis-kat = INPUT FRAME {&frame-name} tt-dis-rule.dis-kat
  .
END.
IF tt-dis-rule.tot-sum:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-tot-sum = INPUT FRAME {&frame-name} tt-dis-rule.tot-sum
  .
END.
IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-time-rule-num = INPUT FRAME {&frame-name} tt-dis-rule.time-rule-num
  .
END.
IF tt-dis-rule.discnt-value:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-discnt-value = INPUT FRAME {&frame-name} tt-dis-rule.discnt-value
  .
END.
IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-charkey_one = INPUT FRAME {&frame-name} tt-dis-rule.charkey_one
  .
END.
IF tt-dis-rule.charkey_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-charkey_two = INPUT FRAME {&frame-name} tt-dis-rule.charkey_two
  .
END.
IF tt-dis-rule.charkey_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-charkey_three = INPUT FRAME {&frame-name} tt-dis-rule.charkey_three
  .
END.
IF tt-dis-rule.deckey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-deckey_one = INPUT FRAME {&frame-name} tt-dis-rule.deckey_one
  .
END.
IF tt-dis-rule.deckey_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-deckey_two = INPUT FRAME {&frame-name} tt-dis-rule.deckey_two
  .
END.
IF tt-dis-rule.deckey_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-deckey_three = INPUT FRAME {&frame-name} tt-dis-rule.deckey_three
  .
END.
IF tt-dis-rule.key#_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-key#_one = INPUT FRAME {&frame-name} tt-dis-rule.key#_one
  .
END.
IF tt-dis-rule.key#_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-key#_two = INPUT FRAME {&frame-name} tt-dis-rule.key#_two
  .
END.
IF tt-dis-rule.key#_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN DO:
  ASSIGN
  v-key#_three = INPUT FRAME {&frame-name} tt-dis-rule.key#_three
  .
END.
define variable v-entry-entry as character no-undo .
define variable v-entry as character no-undo .
define variable v-entry-list as character no-undo .
define variable v-new-entry as character no-undo .
define variable nn as integer no-undo .
do nn = 1 to num-entries(v-tree):
  v-entry-entry = '':U.
  case entry(nn, v-tree):
    when "dis-kat" then do:
      if v-dis-kat <> -1
      then do:
        v-entry-entry = string(v-dis-kat).
      end.
    end.
    when "doc-qnty" then do:
      if v-doc-qnty <> -1
      then do:
        v-entry-entry = string(v-doc-qnty).
      end.
    end.
    when "tot-sum" then do:
      if v-tot-sum <> -1
      then do:
        v-entry-entry = string(v-tot-sum).
      end.
    end.
    when "time-rule-num" then do:
      if v-time-rule-num <> -1
      then do:
        v-entry-entry = string(v-time-rule-num).
      end.
    end.
    when "key#_one" then do:
      if v-key#_one <> ?
      then do:
        v-entry-entry = string(v-key#_one).
      end.
    end.
    when "key#_two" then do:
      if v-key#_two <> ?
      then do:
        v-entry-entry = string(v-key#_two).
      end.
    end.
    when "key#_three" then do:
      if v-key#_three <> ?
      then do:
        v-entry-entry = string(v-key#_three).
      end.
    end.
    when "charkey_one" then do:
      if v-charkey_one <> ?
      then do:
        v-entry-entry = string(v-charkey_one).
      end.
    end.
    when "charkey_two" then do:
      if v-charkey_two <> ?
      then do:
        v-entry-entry = string(v-charkey_two).
      end.
    end.
    when "charkey_three" then do:
      if v-charkey_three <> ?
      then do:
        v-entry-entry = string(v-charkey_three).
      end.
    end.
    when "deckey_one" then do:
      if v-deckey_one <> ?
      then do:
        v-entry-entry = string(v-deckey_one).
      end.
    end.
    when "deckey_two" then do:
      if v-deckey_two <> ?
      then do:
        v-entry-entry = string(v-deckey_two).
      end.
    end.
    when "deckey_three" then do:
      if v-deckey_three <> ?
      then do:
        v-entry-entry = string(v-deckey_three).
      end.
    end.
  end case.
  v-new-entry = v-new-entry +
            (if v-new-entry = '':U then "" else {&delim-par}) + v-entry-entry.
end.

_dub:
FOR EACH buf_tt0-term_dis-rule WHERE
        buf_tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num:
  ASSIGN
  v-rule-num = max(buf_tt0-term_dis-rule.rule-num, v-rule-num)
  .
  v-entry = '':U.

  do nn = 1 to num-entries(v-tree):
    assign
    v-entry-entry = string(buffer buf_tt0-term_dis-rule:buffer-field(entry(nn, v-tree)):buffer-value)
    .
    assign
    v-entry = v-entry +
              (if v-entry = '':U then "" else {&delim-par}) + v-entry-entry.
    v-entry-list = v-entry-list + (if v-entry-list = '':U then "" else {&delim-key}) + v-entry.
    if lookup(v-new-entry, v-entry-list, {&delim-key}) > 0 then do:
      assign
      v-dub = yes
      .
      MESSAGE
      substitute("Уже есть такое подправило с той же областью действия или параметрами")
      VIEW-AS ALERT-BOX.
      LEAVE _dub.
    end.
  end.
END.
IF v-dub THEN UNDO, RETURN ERROR.
CREATE buf_tt0-term_dis-rule.
BUFFER-COPY tt-dis-rule
EXCEPT rule-num
    upper-rule-num des
    lvl-num
    is-term
    root
TO buf_tt0-term_dis-rule
ASSIGN
buf_tt0-term_dis-rule.rule-num = v-rule-num + 1
buf_tt0-term_dis-rule.upper-rule-num = tt-dis-rule.rule-num
buf_tt0-term_dis-rule.doc-qnty = (IF v-doc-qnty = - 1 THEN 0 ELSE v-doc-qnty)
buf_tt0-term_dis-rule.dis-kat = (IF v-dis-kat = - 1 THEN 0 ELSE v-dis-kat)
buf_tt0-term_dis-rule.tot-sum = (IF v-tot-sum = -1 THEN 0 ELSE v-tot-sum)
buf_tt0-term_dis-rule.time-rule-num = (IF v-time-rule-num = 0 THEN 0 ELSE v-time-rule-num)
buf_tt0-term_dis-rule.key#_one = (IF v-key#_one = ? THEN 0 ELSE v-key#_one)
buf_tt0-term_dis-rule.key#_two = (IF v-key#_two = ? THEN 0 ELSE v-key#_two)
buf_tt0-term_dis-rule.key#_three = (IF v-key#_three = ? THEN 0 ELSE v-key#_three)
buf_tt0-term_dis-rule.charkey_one = (IF v-charkey_one = ? THEN "":U ELSE v-charkey_one)
buf_tt0-term_dis-rule.charkey_two = (IF v-charkey_two = ? THEN "":U ELSE v-charkey_two)
buf_tt0-term_dis-rule.charkey_three = (IF v-charkey_three = ? THEN "":U ELSE v-charkey_three)
buf_tt0-term_dis-rule.deckey_one = (IF v-deckey_one = ? THEN 0 ELSE v-deckey_one)
buf_tt0-term_dis-rule.deckey_two = (IF v-deckey_two = ? THEN 0 ELSE v-deckey_two)
buf_tt0-term_dis-rule.deckey_three = (IF v-deckey_three = ? THEN 0 ELSE v-deckey_three)
buf_tt0-term_dis-rule.discnt-value = v-discnt-value
buf_tt0-term_dis-rule.sts   = INTEGER({&non-root-status-int})
buf_tt0-term_dis-rule.root   = no
buf_tt0-term_dis-rule.is-term   = yes
buf_tt0-term_dis-rule.lvl-num   = tt-dis-rule.lvl-num + 1
buf_tt0-term_dis-rule.value-type = v-term-value-type
.
CREATE tt-bc-dis-rule.
ASSIGN
tt-bc-dis-rule.rule-num = v-rule-num + 1
tt-bc-dis-rule.price-brutto = f-price-netto
tt-bc-dis-rule.price-discnt = INPUT FRAME {&frame-name} f-price-discnt
tt-bc-dis-rule.price-netto = INPUT FRAME {&frame-name} f-price-netto
tt-bc-dis-rule.sum-brutto = INPUT FRAME {&frame-name} f-sum-brutto
tt-bc-dis-rule.sum-discnt = INPUT FRAME {&frame-name} f-sum-discnt
tt-bc-dis-rule.sum-netto = INPUT FRAME {&frame-name} f-sum-netto
tt-bc-dis-rule.d-pcnt = INPUT FRAME {&frame-name} f-d-pcnt
tt-bc-dis-rule.sale-qnty = INPUT FRAME {&frame-name} f-sale-qnty
.
RELEASE buf_tt0-term_dis-rule.
RELEASE tt-bc-dis-rule.
RUN display-hide-fields IN THIS-PROCEDURE(v-tree, NO, 0).


HIDE
b-exit-1
IN FRAME {&FRAME-NAME}
b-quit-1
IN FRAME {&FRAME-NAME}.
RUN rename-term_dis-rule in this-procedure .
RUN openbr-term-dr in this-procedure .
RUN display-hide-fields IN THIS-PROCEDURE(v-tree, yes, 1).
if p-mode <> {&lookup}
then
enable
b-exit
with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-quit-1 Dialog-Frame 
PROCEDURE proc-b-quit-1 :
RUN display-hide-fields IN THIS-PROCEDURE ( v-tree, NO /*main record*/, 0 /*display*/).

HIDE
b-exit-1
IN FRAME {&FRAME-NAME}
b-quit-1
IN FRAME {&FRAME-NAME}.
if p-mode <> {&lookup}
then
enable
b-exit
with frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
DEFINE VARIABLE v-log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-dub-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
if p-mode = {&lookup} then do:
    return error.
end.

if not available tt-dis-rule then do:
    create tt-dis-rule.
end.

assign frame {&frame-name}
tt-dis-rule.des
.
IF v-tree = "":U THEN DO:
  IF tt-dis-rule.discnt-value:SENSITIVE IN FRAME {&FRAME-NAME} THEN
  ASSIGN
  tt-dis-rule.discnt-value
  .
  IF tt-dis-rule.dis-kat:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.dis-kat
    .

  IF tt-dis-rule.doc-qnty:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.doc-qnty
    .

  IF tt-dis-rule.tot-sum:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.tot-sum
    .

  IF tt-dis-rule.time-rule-num:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.time-rule-num
    .
  else do:
    if lookup("time-rule-num", v-level-1) = 0 then do:
      assign
      tt-dis-rule.time-rule-num = 0
      tt-dis-rule.time-templ-rl-root = 0
      .
    end.
  end.
  IF tt-dis-rule.key#_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_one
    .
  IF tt-dis-rule.key#_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_two
    .
  IF tt-dis-rule.key#_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_three
    .
  IF tt-dis-rule.charkey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_one
    .
  IF tt-dis-rule.charkey_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_two
    .
  IF tt-dis-rule.charkey_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_three
    .
  IF tt-dis-rule.deckey_one:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.deckey_one
    .
  IF tt-dis-rule.deckey_two:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.deckey_two
    .
  IF tt-dis-rule.deckey_three:SENSITIVE IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.deckey_three
    .
END.
ELSE DO:
  IF tt-dis-rule.discnt-value:VISIBLE IN FRAME {&FRAME-NAME} THEN
  ASSIGN
  tt-dis-rule.discnt-value
  .
  IF tt-dis-rule.dis-kat:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.dis-kat
    .

  IF tt-dis-rule.doc-qnty:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.doc-qnty
    .

  IF tt-dis-rule.tot-sum:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.tot-sum
    .

  IF tt-dis-rule.time-rule-num:VISIBLE  IN FRAME {&FRAME-NAME} THEN do:
    ASSIGN
    tt-dis-rule.time-rule-num
    .
  end.
  else do:
    if lookup("time-rule-num", v-level-1) = 0 then do:
      assign
      tt-dis-rule.time-rule-num = 0
      tt-dis-rule.time-templ-rl-root = 0
      .
    end.
  end.
  IF tt-dis-rule.key#_one:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_one
    .
  IF tt-dis-rule.key#_two:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_two
    .
  IF tt-dis-rule.key#_three:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.key#_three
    .
  IF tt-dis-rule.charkey_one:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_one
    .
  IF tt-dis-rule.charkey_two:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_two
    .
  IF tt-dis-rule.charkey_three:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.charkey_three
    .
  IF tt-dis-rule.deckey_one:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.deckey_one
    .
  IF tt-dis-rule.deckey_two:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.deckey_two
    .
  IF tt-dis-rule.deckey_three:VISIBLE  IN FRAME {&FRAME-NAME} THEN
    ASSIGN
  tt-dis-rule.deckey_three
    .
  ASSIGN
  tt-dis-rule.discnt-value = 0
  .
END.
if v-value-type = integer({&discnt-v-radio-integer}) then do:
  assign
  rs-radio-integer
  tt-dis-rule.discnt-value = rs-radio-integer
  .
end.
if v-value-type = integer({&discnt-v-flag}) then do:
  assign
  t-flag
  tt-dis-rule.discnt-value = (if t-flag then 1 else 0)
  .
end.
if (p-templ-rl-root = 73
or p-templ-rl-root = 74) then do:
 define variable glog as logical no-undo init yes.
_tt:
  for each tt0-term_dis-rule :
    if tt0-term_dis-rule.key#_one = 0 then do:
      message
      "Вы не определили тип кассового платежа, при котором будет действовать скидка!" skip
      "В этом случае скидка будет срабатывать при любом типе кассового платежа!" skip
      "Сохранять правило?"
      view-as alert-box warning buttons yes-no update glog.
      leave _tt.
    end.
  end.
  if not glog then return  error.
end.

run ref/diffdisr.p ( input p-mode
              , INPUT TABLE tt-dis-rule
              , INPUT TABLE tt0-term_dis-rule
              , OUTPUT v-dub-rule-num) NO-ERROR.
IF ERROR-STATUS:ERROR
OR v-dub-rule-num <> 0 THEN DO:
   IF is-good-mode THEN DO:
       MESSAGE
        substitute("В системе уже существует точно такое же правило скидок (правило № &1)", v-dub-rule-num) SKIP
        VIEW-AS ALERT-BOX ERROR.
        undo, RETURN ERROR.
    END.
   ELSE DO:
       MESSAGE
        substitute("В системе уже существует точно такое же правило скидок (правило № &1)", v-dub-rule-num) SKIP
        "Вы уверены, что хотите создать еще одно такое же правило?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE v-log.
        IF NOT v-log THEN undo, RETURN ERROR.
  END.
END.
run ref/dis-rul1.p (
input (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num )/* p-rule-num */
,input v-pos-type
,input p-templ-rl-root
,input p-templ-rl-root
,input tt-dis-rule.des
,input tt-dis-rule.dis-kat
,input tt-dis-rule.discnt-type
,input tt-dis-rule.doc-qnty
,input tt-dis-rule.tot-sum
,input tt-dis-rule.charkey_one
,input tt-dis-rule.charkey_two
,input tt-dis-rule.charkey_three
,input tt-dis-rule.deckey_one
,input tt-dis-rule.deckey_two
,input tt-dis-rule.deckey_three
,input tt-dis-rule.key#_one
,input tt-dis-rule.key#_two
,input tt-dis-rule.key#_three
,input tt-dis-rule.subject-type
,input tt-dis-rule.time-templ-rl-root
,input tt-dis-rule.time-rule-num
,input tt-dis-rule.upper-rule-num
,input tt-dis-rule.value-type
,input tt-dis-rule.host-code
,INPUT tt-dis-rule.obj-type
,INPUT tt-dis-rule.obj-code
,INPUT tt-dis-rule.discnt-value
,input table tt0-term_dis-rule
,input-output p-recid
,input p-mode
,input NO /*p-silent */
) NO-ERROR.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-time-rule-lookup Dialog-Frame 
PROCEDURE proc-time-rule-lookup :
DEFINE INPUT PARAMETER p-tree AS CHARACTER NO-UNDO.
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
IF lookup("time-rule-num", v-level-1) > 0
or lookup("time-rule-num", v-level-2) > 0
tHEN DO:
  IF lookup("time-rule-num":U, v-level-1) > 0 THEN DO:
        run ref/dis-timi.w (
                   input parParentProc
                  ,input {&lookup}
                  ,input 0 /*p-templ-rl-root*/
                  ,input tt-dis-rule.time-rule-num
                  ,input 0 /*p-upper-time-rule-num*/
                  ,input-output loc-doc-rec
                  ) no-error .
  END.
  ELSE DO:
   IF AVAILABLE tt0-term_dis-rule THEN DO:
     run ref/dis-timi.w (
                   input parParentProc
                  ,input {&lookup}
                  ,input 0 /*p-templ-rl-root*/
                  ,input tt0-term_dis-rule.time-rule-num
                  ,input 0 /*p-upper-time-rule-num*/
                  ,input-output loc-doc-rec
                  ) no-error .
    END.
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE recalc Dialog-Frame 
PROCEDURE recalc :
DEFINE INPUT PARAMETER p-price-brutto LIKE ub.gds-obj.price-sale NO-UNDO.
DEFINE INPUT PARAMETER p-main AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE INPUT PARAMETER p-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE INPUT PARAMETER p-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
ASSIGN
f-sum-brutto = ABS(p-price-brutto * p-doc-qnty)
f-sale-qnty = truncate(p-tot-sum / p-price-brutto, v-meas).

IF tt-dis-rule.tot-sum:VISIBLE IN FRAME {&frame-name} = NO   THEN DO:
/*это скидка на строку товара*/                                                                               ~
CASE p-main:
    WHEN "price-discnt" THEN DO:
        ASSIGN
        f-price-netto = p-price-brutto - f-price-discnt
        f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
        f-sum-netto = ABS(f-price-netto * p-doc-qnty)
        f-sum-discnt = ABS(f-price-discnt * p-doc-qnty)
        .

    END.
    WHEN "price-netto" THEN DO:
        ASSIGN
        f-price-discnt = p-price-brutto - f-price-netto
        f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
        f-sum-netto = ABS(f-price-netto * p-doc-qnty)
        f-sum-discnt = ABS(f-price-discnt * p-doc-qnty)
        .

    END.
    WHEN "d-pcnt" THEN DO:
        ASSIGN
        f-price-discnt = p-price-brutto - p-price-brutto * f-d-pcnt / 100
        f-price-netto  = p-price-brutto - f-price-discnt
        f-sum-netto = ABS(f-price-netto * p-doc-qnty)
        f-sum-discnt = ABS(f-price-discnt * p-doc-qnty)
        .
    END.
    WHEN "sum-netto" THEN DO:
        ASSIGN
        f-price-netto = f-sum-netto / p-doc-qnty
        f-sum-discnt = f-sum-brutto - f-sum-netto
        f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
        f-price-discnt = p-price-brutto - f-price-netto
        .

    END.
    WHEN "sum-discnt" THEN DO:
        ASSIGN
        f-sum-netto = f-sum-brutto - f-sum-discnt
        f-price-netto = f-sum-netto / p-doc-qnty
        f-price-discnt = (f-sum-brutto - f-sum-netto) / p-doc-qnty
        f-d-pcnt = 100 * (1 - f-price-netto / p-price-brutto)  .
    END.
    WHEN "discnt-value" THEN DO:
        CASE v-term-value-type:
            WHEN  integer({&discnt-v-pcnt})THEN DO:
                ASSIGN
                f-d-pcnt = p-discnt-value
                f-price-discnt = p-price-brutto * f-d-pcnt / 100
                f-price-netto  = p-price-brutto - f-price-discnt
                f-sum-netto = ABS(f-price-netto * p-doc-qnty)
                f-sum-discnt = ABS(f-price-discnt * p-doc-qnty)
                .
            END.
            WHEN  integer({&discnt-v-abs})THEN DO:
                ASSIGN
                f-price-discnt = f-price-brutto -  p-discnt-value
                f-price-netto = p-price-brutto - f-price-discnt
                f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
                f-sum-netto = ABS(f-price-netto * p-doc-qnty)
                f-sum-discnt = ABS(f-price-discnt * p-doc-qnty).
                .
            END.
            WHEN  integer({&discnt-v-FP})THEN DO:
                ASSIGN
                f-price-netto = p-discnt-value
                f-price-discnt = p-price-brutto - f-price-netto
                f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
                f-sum-netto = ABS(f-price-netto * p-doc-qnty)
                f-sum-discnt = ABS(f-price-discnt * p-doc-qnty).
               .
            END.
        END CASE.
    END.
  END CASE.
  IF p-main <> "discnt-value" THEN DO:
    CASE v-term-value-type:
      WHEN  integer({&discnt-v-pcnt}) THEN DO:
        p-discnt-value = f-d-pcnt.
      END.
      WHEN  integer({&discnt-v-abs}) THEN DO:
          p-discnt-value = f-price-brutto - f-price-netto.
      END.
      WHEN  integer({&discnt-v-FP}) THEN DO:
          p-discnt-value = f-price-netto.
      END.
    END CASE.
  END.
END.
ELSE DO:
  CASE p-main:
    /*это скидка на сумму товара по строке*/                                                                       ~
    WHEN "price-discnt" THEN DO:
        ASSIGN
        f-price-netto = p-price-brutto - f-price-discnt
        f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
        f-sum-netto = ABS(f-price-netto * f-sale-qnty)
        f-sum-discnt = ABS(f-price-discnt * p-doc-qnty).

    END.
    WHEN "price-netto" THEN DO:
        ASSIGN
        f-price-discnt = p-price-brutto - f-price-netto
        f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
        f-sum-netto = ABS(f-price-netto * f-sale-qnty)
        f-sum-discnt = ABS(f-price-discnt * f-sale-qnty).

    END.
    WHEN "d-pcnt" THEN DO:
        ASSIGN
        f-price-discnt = p-price-brutto - p-price-brutto * f-d-pcnt / 100
        f-price-netto  = p-price-brutto - f-price-discnt
        f-sum-netto = ABS(f-price-netto * f-sale-qnty)
        f-sum-discnt = ABS(f-price-discnt * f-sale-qnty)
        .
    END.
    WHEN "sum-netto" THEN DO:
        ASSIGN
        f-price-netto = f-sum-netto / p-doc-qnty
        f-sum-discnt = f-sum-brutto - f-sum-netto
        f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
        f-price-discnt = p-price-brutto - f-price-netto
        .

    END.
    WHEN "sum-discnt" THEN DO:
        ASSIGN
        f-sum-netto = f-sum-brutto - f-sum-discnt
        f-price-netto = f-sum-netto / f-sale-qnty
        f-price-discnt = (f-sum-brutto - f-sum-netto) / p-doc-qnty
        f-d-pcnt = 100 * (1 - f-price-netto / p-price-brutto)  .
    END.
    WHEN "discnt-value" THEN DO:
      CASE v-term-value-type:
        WHEN  integer({&discnt-v-pcnt})THEN DO:
          ASSIGN
          f-d-pcnt = p-discnt-value
          f-price-discnt = p-price-brutto * f-d-pcnt / 100
          f-price-netto  = p-price-brutto - f-price-discnt
          f-sum-netto = ABS(f-price-netto * f-sale-qnty)
          f-sum-discnt = ABS(f-price-discnt * f-sale-qnty)
          .
        END.
        WHEN  integer({&discnt-v-abs})THEN DO:
          ASSIGN
          f-price-discnt = f-price-brutto -  p-discnt-value
          f-price-netto = p-price-brutto - f-price-discnt
          f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
          f-sum-netto = ABS(f-price-netto * f-sale-qnty)
          f-sum-discnt = ABS(f-price-discnt * f-sale-qnty).
          .
        END.
        WHEN  integer({&discnt-v-FP})THEN DO:
          ASSIGN
          f-price-netto = p-discnt-value
          f-price-discnt = p-price-brutto - f-price-netto
          f-d-pcnt       = 100 * (1 - f-price-netto / p-price-brutto)
          f-sum-netto = ABS(f-price-netto * f-sale-qnty)
          f-sum-discnt = ABS(f-price-discnt * f-sale-qnty).
          .
        END.
      END CASE.
    END.
  END CASE.
  IF p-main <> "discnt-value" THEN DO:
    CASE v-term-value-type:
      WHEN  integer({&discnt-v-pcnt}) THEN DO:
        p-discnt-value = f-d-pcnt.
      END.
      WHEN  integer({&discnt-v-abs}) THEN DO:
          p-discnt-value = f-price-brutto - f-price-netto.
      END.
      WHEN  integer({&discnt-v-FP}) THEN DO:
          p-discnt-value = f-price-netto.
      END.
    END CASE.
  END.
END.
DISPLAY
f-d-pcnt WHEN (v-term-value-type <> INTEGER({&discnt-v-pcnt})) AND f-d-pcnt:VISIBLE IN FRAME {&FRAME-NAME}
f-price-discnt when f-price-discnt:VISIBLE IN FRAME {&FRAME-NAME}
f-price-netto when f-price-netto:VISIBLE IN FRAME {&FRAME-NAME}
f-sale-qnty WHEN f-sale-qnty:VISIBLE IN FRAME {&frame-name} = yes
f-sum-discnt WHEN f-sum-discnt:VISIBLE IN FRAME {&FRAME-NAME}
f-sum-netto  WHEN f-sum-netto:VISIBLE IN FRAME {&FRAME-NAME}
f-sum-brutto WHEN f-sum-brutto:VISIBLE IN FRAME {&FRAME-NAME}
WITH FRAME {&FRAME-NAME}.
display
p-discnt-value @ tt-dis-rule.discnt-value
WITH FRAME {&FRAME-NAME}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE rename-term_dis-rule Dialog-Frame 
PROCEDURE rename-term_dis-rule :
DEFINE VARIABLE v-doc-qnty LIKE ub.dis-rule.doc-qnty NO-UNDO.
DEFINE VARIABLE v-dis-kat LIKE ub.dis-rule.dis-kat NO-UNDO.
DEFINE VARIABLE v-tot-sum LIKE ub.dis-rule.tot-sum NO-UNDO.
DEFINE VARIABLE v-time-rule-num LIKE ub.dis-rule.time-rule-num NO-UNDO.
define variable v-charkey_one like ub.dis-rule.charkey_one no-undo .
define variable v-charkey_two like ub.dis-rule.charkey_two no-undo .
define variable v-charkey_three like ub.dis-rule.charkey_three no-undo .
define variable v-deckey_one like ub.dis-rule.deckey_one no-undo .
define variable v-deckey_two like ub.dis-rule.deckey_two no-undo .
define variable v-deckey_three like ub.dis-rule.deckey_three no-undo .
define variable v-key#_one like ub.dis-rule.key#_one no-undo .
define variable v-key#_two like ub.dis-rule.key#_two no-undo .
define variable v-key#_three like ub.dis-rule.key#_three no-undo .
DEFINE VARIABLE v-discnt-value LIKE ub.dis-rule.discnt-value NO-UNDO.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable v-label as character no-undo .
define variable v-label0 as character no-undo .
DEFINE BUFFER buf_tt0-term_dis-rule FOR tt0-term_dis-rule.
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer upper_temp-drt-prop for temp-drt-prop.
IF v-tree = "":U  THEN RETURN ERROR.

&scop find-label ~
  assign ~
  ii = 0 ~
  v-label0 = ~{&branch-label~} ~
  v-label = v-label0. ~
  for each buf_temp-drt-prop no-lock where ~
            buf_temp-drt-prop.templ-rl-root = p-templ-rl-root ~
        and buf_temp-drt-prop.prop-code = "Label":U ~
        and buf_temp-drt-prop.upper-prop-code = ~{&branch-code~}, ~
      first upper_temp-drt-prop no-lock where ~
          upper_temp-drt-prop.templ-rl-root = p-templ-rl-root ~
      and upper_temp-drt-prop.prop-code = buf_temp-drt-prop.upper-prop-code ~
      and upper_temp-drt-prop.upper-prop-code = "Level2_UsingFields":U: ~
    assign ~
    v-label = buf_temp-drt-prop.property-value. ~
    leave. ~
  end


FOR EACH buf_tt0-term_dis-rule:
  buf_tt0-term_dis-rule.des = "".
END.
IF LOOKUP("doc-qnty", v-tree) > 0 THEN DO:
&scop branch-label "Количество"
&scop branch-code "doc-qnty":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.doc-qnty DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("На &1: &2"
                                          , v-label
                                          ,(IF ii = 1
                                            THEN SUBstitute("свыше &1", buf_tt0-term_dis-rule.doc-qnty)
                                            ELSE SUBSTITUTE("от &1 до &2"
                                                            , buf_tt0-term_dis-rule.doc-qnty
                                                            , v-doc-qnty)
                                            )
                                            )
    v-doc-qnty = buf_tt0-term_dis-rule.doc-qnty
    .
  END.
END.
IF LOOKUP("tot-sum", v-tree) > 0 THEN DO:
&scop branch-label "Сумма"
&scop branch-code "tot-sum":U
{&find-label}.
  if v-label = v-label0 then do:
    FOR EACH buf_tt0-term_dis-rule
    BY buf_tt0-term_dis-rule.tot-sum DESCENDING:
      ASSIGN
      ii = ii + 1
      buf_tt0-term_dis-rule.des =  buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                  substitute("&1 &2"
                                            ,(IF ii = 1
                                              THEN SUBstitute("свыше &1", buf_tt0-term_dis-rule.tot-sum)
                                              ELSE SUBSTITUTE("от &1 до &2"
                                                            , buf_tt0-term_dis-rule.tot-sum
                                                            , v-tot-sum)
                                              ))
      v-tot-sum = buf_tt0-term_dis-rule.tot-sum
    .
    END.
  end.
  else do:
    FOR EACH buf_tt0-term_dis-rule
    BY buf_tt0-term_dis-rule.tot-sum DESCENDING:
      ASSIGN
      ii = ii + 1
      buf_tt0-term_dis-rule.des =  buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                  substitute("&1: &2"
                                              ,v-label
                                              ,buf_tt0-term_dis-rule.tot-sum
                                              )
      v-tot-sum = buf_tt0-term_dis-rule.tot-sum
      .
    END.
  end.
END. /*IF LOOKUP("tot-sum", v-tree) > 0 THEN DO:*/
IF LOOKUP("dis-kat", v-tree) > 0 THEN DO:
&scop branch-label "Категория"
&scop branch-code "dis-kat":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.dis-kat DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1: &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.dis-kat)
    .
  END.
END.
IF LOOKUP("time-rule-num", v-tree) > 0 THEN DO:
&scop branch-label "Расписание"
&scop branch-code "time-rule-num":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 №&2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.time-rule-num)
    .
  END.
END.
IF LOOKUP("key#_one", v-tree) > 0 THEN DO:
&scop branch-label "Интполе1"
&scop branch-code "key#_one":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.key#_one)
    .
  END.
END.
IF LOOKUP("key#_two", v-tree) > 0 THEN DO:
&scop branch-label "Интполе2"
&scop branch-code "key#_two":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.key#_two)
    .
  END.
END.
IF LOOKUP("key#_three", v-tree) > 0 THEN DO:
&scop branch-label "Интполе3"
&scop branch-code "key#_three":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.key#_three)
    .
  END.
END.
IF LOOKUP("charkey_one", v-tree) > 0 THEN DO:
&scop branch-label "Поле1"
&scop branch-code "charkey_one":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.charkey_one)
    .
  END.
END.
IF LOOKUP("charkey_two", v-tree) > 0 THEN DO:
&scop branch-label "Поле2"
&scop branch-code "charkey_two":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.charkey_two)
    .
  END.
END.
IF LOOKUP("charkey_three", v-tree) > 0 THEN DO:
&scop branch-label "Поле3"
&scop branch-code "charkey_three":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.charkey_three)
    .
  END.
END.
IF LOOKUP("deckey_one", v-tree) > 0 THEN DO:
&scop branch-label "ДПоле1"
&scop branch-code "deckey_one":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.deckey_one)
    .
  END.
END.
IF LOOKUP("deckey_two", v-tree) > 0 THEN DO:
&scop branch-label "ДПоле2"
&scop branch-code "deckey_two":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.deckey_two)
    .
  END.
END.
IF LOOKUP("deckey_three", v-tree) > 0 THEN DO:
&scop branch-label "ДПоле3"
&scop branch-code "deckey_three":U
{&find-label}.
  FOR EACH buf_tt0-term_dis-rule
  BY buf_tt0-term_dis-rule.time-rule-num DESCENDING:
    ASSIGN
    ii = ii + 1
    buf_tt0-term_dis-rule.des = buf_tt0-term_dis-rule.des + (IF buf_tt0-term_dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                substitute("&1 &2 "
                                          , v-label
                                          , buf_tt0-term_dis-rule.deckey_three)
    .
  END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

