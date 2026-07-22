&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-dis-rule-bc NO-UNDO LIKE ub.dis-rule
       field price-brutto like ub.gds-obj.price-sale
       field price-netto like ub.gds-obj.price-sale
       field price-discnt like ub.gds-obj.price-sale
       field sum-brutto like ub.trn-doc.tot-sale
       field sum-netto like ub.trn-doc.tot-sale
       field sum-discnt like ub.trn-doc.tot-sale
       field d-pcnt like ub.dis-rule.discnt-value
       field sale-qnty like ub.dis-rule.doc-qnty.
DEFINE TEMP-TABLE tt0-template_dis-rule NO-UNDO LIKE ub.dis-cfg-rule.
DEFINE BUFFER X_bar-code FOR ub.bar-code.
DEFINE BUFFER X_curr_clients FOR ub.clients.
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_dis-time-rule FOR ub.dis-time-rule.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_term-dis-rule FOR ub.dis-rule.
DEFINE BUFFER X_upper-dis-rule FOR ub.dis-rule.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список ПРАВИЛ СКИДОК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 16/03/04
Author: Bakhtadze Natalya
Creation date: 16/03/04

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo.
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo.
define input parameter bttns  as char   no-undo .
/*кнопки для нажатия*/
define input parameter p-mode  as char   no-undo .
/*{&all}  "upper-rule-num"  "template" {&g___object} "time-rule-num" upper-rule-num-object upper-rule-num-host upper-rule-num-global
"upper-rule-num-gds-obj  dis-gds-rule-gds-obj cd-obj  "template-value-type" "upper-rule-num-all-obj"
{&table_dis-gds-rule}
{&table_dis-dc-rule}
{&table_dis-cp-rule}
{&table_dis-dct-rule}
{&table_dis-grp-rule}
{&table_dis-some-rule}
*/
define input parameter p-upper-rule-num like ub.dis-rule.upper-rule-num no-undo .  /*для p-mode = time-rule-num ьам дежит time-rule-num*/
define input parameter p-time-templ-rl-root like ub.dis-rule.time-templ-rl-root no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input-output parameter p-sts like ub.dis-rule.sts no-undo .
define input-output param p-rid-list    as  char no-undo .
/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "Список ПРАВИЛ СКИДОК":U.
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-pril.i new }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ gbl/disrules.i "work" }
{ gbl/distruls.i "work" }
{ ref/disgdsru.i }
{ ref/gtregion.i template }
{ gbl/getcntxt.i def }
{ gbl/fltopend.i defproc }

define variable p-value-type as character no-undo .
define variable v-rid-list as character no-undo .
DEFINE VARIABLE v-doc-rec AS RECID NO-UNDO.
define variable add-option as character no-undo .
define variable sort-column-name as character no-undo .
define variable v-db-num LIKE ub.db.db-num no-undo.
define variable filter-point as character no-undo init "dis-ruls" .
define variable filter-point0 as character no-undo init "dis-ruls" .
define variable filter-label as character no-undo init "Правила скидок" .
define variable filter-label0 as character no-undo init "dis-ruls" .

DEFINE variable v-display-time-rule-num AS CHARACTER NO-UNDO.
DEFINE variable v-display-dis-kat AS CHARACTER  NO-UNDO.
DEFINE variable v-display-doc-qnty AS CHARACTER  NO-UNDO.
DEFINE variable v-display-tot-sum AS CHARACTER  NO-UNDO.
DEFINE variable v-display-key#_one AS CHARACTER  NO-UNDO.
DEFINE variable v-display-key#_two AS CHARACTER  NO-UNDO.
DEFINE variable v-display-key#_three AS CHARACTER  NO-UNDO.
DEFINE variable v-display-charkey_one AS CHARACTER  NO-UNDO.
DEFINE variable v-display-charkey_two AS CHARACTER  NO-UNDO.
DEFINE variable v-display-charkey_three AS CHARACTER  NO-UNDO.
DEFINE variable v-display-deckey_one AS CHARACTER  NO-UNDO.
DEFINE variable v-display-deckey_two AS CHARACTER  NO-UNDO.
DEFINE variable v-display-deckey_three AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-display-discnt-value AS CHARACTER  NO-UNDO.
DEFINE VARIABLE v-price-sale LIKE ub.price-list.price-sale NO-UNDO.
define varIABLE v-attr-type as character no-undo .          /* тип атрибута      */
define varIABLE v-attr-format as character no-undo .        /* формат атрибута   */
define varIABLE v-attr-label as character no-undo .         /* лабел атрибута    */
define variable v-attr-range as integer no-undo.            /* область действия атрибута */
define varIABLE v-attr-value as character no-undo .         /* значение атрибута */
define varIABLE v-attr-user-can-edit as logical no-undo .   /* пользователь может изменять в броусе */
define varIABLE v-attr-output-display as logical no-undo .  /* виден в броусе    */
define varIABLE v-attr-other as char no-undo .              /* еще чего - нибудь */
define variable v-cd   as character no-undo .
define variable v-discnt-role as character no-undo .
define variable v-region as character no-undo .
DEFINE VARIABLE lookup-option AS CHARACTER NO-UNDO.
define variable v-using-fields as character no-undo .
define temp-table print-dis-rule no-undo
field srule-num as integer
field display-time-rule-num AS CHARACTER
field display-dis-kat AS CHARACTER
field display-doc-qnty AS CHARACTER
field display-tot-sum AS CHARACTER
field display-key#_one AS CHARACTER
field display-key#_two AS CHARACTER
field display-key#_three AS CHARACTER
field display-charkey_one AS CHARACTER
field display-charkey_two AS CHARACTER
field display-charkey_three AS CHARACTER
field display-deckey_one AS CHARACTER
field display-deckey_two AS CHARACTER
field display-deckey_three AS CHARACTER
field display-discnt-value AS CHARACTER
index pi is unique primary srule-num

.

&SCOPED-DEFINE used-status-code STRING(X_dis-rule.sts)
&SCOPED-DEFINE discnt-type-code string(X_dis-rule.discnt-type)
&SCOPED-DEFINE discnt-target-code STRING(X_dis-rule.subject-type)
&SCOPED-DEFINE discnt-v-code STRING(X_dis-rule.value-type)
define buffer pos_dis-rule for ub.dis-rule.

DEFINE BUFFER tt-template_dis-rule FOR tt0-template_dis-rule.

&scop cant-positioning   if error-status:error then do: ~
                          find first pos_dis-rule no-lock where ~
                                  recid(pos_dis-rule) = loc-doc-rec no-error . ~
                            message ~
                            "Невозможно позиционироваться на записи ПРАВИЛО СКИДКИ" skip~
                            string(if avail pos_dis-rule ~
                                    then  substitute("номер правила скидки: &1" ~
                                                    , pos_dis-rule.rule-num) ~
                                    else "":U) skip ~
                            "Запись была добавлена (или изменена или удалена) -" skip ~
                            "и теперь не попадает в текущую выборку" ~
                            view-as alert-box WARNING. ~
                          end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-dis-rule

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_dis-rule tt-template_dis-rule ~
tt-dis-rule-bc

/* Definitions for BROWSE br-dis-rule                                   */
&Scoped-define FIELDS-IN-QUERY-br-dis-rule mark-string(buffer X_dis-rule, v-rid-list) X_dis-rule.des v-display-discnt-value gtregion(X_dis-rule.host-code, X_dis-rule.obj-type, X_dis-rule.obj-code, X_dis-rule.templ-rl-root, X_dis-rule.lvl-num = 0, no) {&discnt-type-name} {&discnt-target-name} {&discnt-v-name} v-display-dis-kat v-display-doc-qnty v-display-tot-sum v-display-time-rule-num v-display-deckey_one v-display-deckey_two v-display-deckey_three v-display-charkey_one v-display-charkey_two v-display-charkey_three v-display-key#_one v-display-key#_two v-display-key#_three {&used-status-int-name} X_dis-rule.rule-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-dis-rule
&Scoped-define SELF-NAME br-dis-rule
&Scoped-define QUERY-STRING-br-dis-rule FOR EACH X_dis-rule NO-LOCK, ~
             EACH tt-template_dis-rule OF ub.X_dis-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-dis-rule OPEN QUERY {&SELF-NAME} FOR EACH X_dis-rule NO-LOCK, ~
             EACH tt-template_dis-rule OF ub.X_dis-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-dis-rule X_dis-rule tt-template_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-br-dis-rule X_dis-rule
&Scoped-define SECOND-TABLE-IN-QUERY-br-dis-rule tt-template_dis-rule


/* Definitions for BROWSE BR-gds-obj                                    */
&Scoped-define FIELDS-IN-QUERY-BR-gds-obj entry (lookup (string(tt-dis-rule-bc.value-type), {&discnt-v-list}), {&discnt-v-list-full}) tt-dis-rule-bc.dis-kat tt-dis-rule-bc.doc-qnty tt-dis-rule-bc.tot-sum tt-dis-rule-bc.time-rule-num tt-dis-rule-bc.discnt-value tt-dis-rule-bc.d-pcnt tt-dis-rule-bc.sale-qnty tt-dis-rule-bc.price-brutto tt-dis-rule-bc.price-discnt tt-dis-rule-bc.price-netto tt-dis-rule-bc.sum-brutto tt-dis-rule-bc.sum-discnt tt-dis-rule-bc.sum-netto tt-dis-rule-bc.charkey_one tt-dis-rule-bc.charkey_two tt-dis-rule-bc.charkey_three tt-dis-rule-bc.key#_one tt-dis-rule-bc.key#_two tt-dis-rule-bc.key#_three
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-gds-obj
&Scoped-define SELF-NAME BR-gds-obj
&Scoped-define QUERY-STRING-BR-gds-obj FOR EACH tt-dis-rule-bc OF ub.X_dis-rule NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BR-gds-obj OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-rule-bc OF ub.X_dis-rule NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BR-gds-obj tt-dis-rule-bc
&Scoped-define FIRST-TABLE-IN-QUERY-BR-gds-obj tt-dis-rule-bc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH X_dis-rule SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH X_dis-rule SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame X_dis-rule
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame X_dis-rule


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-copy B-lookup ~
B-chg B-del b-history B-print B-sch B-Help RS-sts Cb-pos-type B-stat ~
B-dis-rules B-time-rule br-dis-rule BR-gds-obj mark-num v-des
&Scoped-Define DISPLAYED-OBJECTS RS-sts Cb-pos-type mark-num v-des

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-rule FOR ub.dis-rule, input mark-list as CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-add
       MENU-ITEM m_global       LABEL "Глобально"
       MENU-ITEM m_host         LABEL "Фирма"
       MENU-ITEM m_object       LABEL "Объект"        .

DEFINE MENU MENU-B-copy
       MENU-ITEM m_global-copy  LABEL "Глобально"
       MENU-ITEM m_host-copy    LABEL "Фирма"
       MENU-ITEM m_object-copy  LABEL "Объект"
       RULE
       MENU-ITEM m_list-copy    LABEL "На другие объекты по списку" .

DEFINE MENU MENU-B-lookup
       MENU-ITEM M_rule         LABEL "Правило"
       MENU-ITEM m_subject      LABEL "Объекты приложения правила".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-copy
     LABEL "&Копия"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-dis-rules
     LABEL "Пр&авила"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-history
     LABEL "Ис&тория"
     SIZE 3 BY 1.

DEFINE BUTTON B-lookup
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE BUTTON B-stat
     LABEL "&Статус"
     SIZE 10 BY 1.

DEFINE BUTTON B-time-rule
     LABEL "&Распис."
     SIZE 10 BY 1.

DEFINE VARIABLE Cb-pos-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 15
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-des AS CHARACTER FORMAT "X(255)"
      VIEW-AS TEXT
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-sts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 32 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-dis-rule FOR
                X_dis-rule,
                tt-template_dis-rule SCROLLING.


DEFINE QUERY BR-gds-obj FOR
      tt-dis-rule-bc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      X_dis-rule SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-dis-rule Dialog-Frame _FREEFORM
  QUERY br-dis-rule NO-LOCK DISPLAY
      mark-string(buffer X_dis-rule, v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
X_dis-rule.des FORMAT "X(255)":U
    WIDTH 50
v-display-discnt-value COLUMN-LABEL "Знач. скидки" FORMAT "X(15)":U
gtregion(X_dis-rule.host-code, X_dis-rule.obj-type, X_dis-rule.obj-code, X_dis-rule.templ-rl-root, X_dis-rule.lvl-num = 0, no) COLUMN-LABEL "Область действия" FORMAT "X(15)":U
{&discnt-type-name} COLUMN-LABEL "Тип скидки" FORMAT "X(20)":U
    WIDTH 22
{&discnt-target-name} COLUMN-LABEL "Объект!воздействия!скидки" FORMAT "X(20)":U
    WIDTH 12
{&discnt-v-name} COLUMN-LABEL "Тип!знач." FORMAT "X(7)":U
v-display-dis-kat COLUMN-LABEL "Катег." FORMAT "X(4)":U
v-display-doc-qnty COLUMN-LABEL "Кол-во для!скидки" FORMAT "X(10)":U
v-display-tot-sum COLUMN-LABEL "Сумма для!скидки" FORMAT "X(14)":U
v-display-time-rule-num COLUMN-LABEL "Расписание" FORMAT "X(9)":U
v-display-deckey_one COLUMN-LABEL "ДПоле1" FORMAT "->>,>>9.99"
v-display-deckey_two COLUMN-LABEL "ДПоле2" FORMAT "->>,>>9.99"
v-display-deckey_three COLUMN-LABEL "ДПоле3" FORMAT "->>,>>9.99"
v-display-charkey_one COLUMN-LABEL "Поле1" FORMAT "X(12)"
v-display-charkey_two COLUMN-LABEL "Поле2" FORMAT "X(12)"
v-display-charkey_three COLUMN-LABEL "Поле3" FORMAT "X(12)"
v-display-key#_one COLUMN-LABEL "ИнтПоле1" FORMAT "X(10)"
v-display-key#_two COLUMN-LABEL "ИнтПоле2" FORMAT "X(10)"
v-display-key#_three COLUMN-LABEL "ИнтПоле3" FORMAT "X(10)"
{&used-status-int-name} COLUMN-LABEL "Статус"
X_dis-rule.rule-num COLUMN-LABEL "№ правила" FORMAT ">>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9.

DEFINE BROWSE BR-gds-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-gds-obj Dialog-Frame _FREEFORM
  QUERY BR-gds-obj NO-LOCK DISPLAY
      entry (lookup (string(tt-dis-rule-bc.value-type), {&discnt-v-list}), {&discnt-v-list-full}) COLUMN-LABEL "Тип" FORMAT "X(10)":U
            WIDTH 10
tt-dis-rule-bc.dis-kat COLUMN-LABEL "Катег" FORMAT "->>>9":U
tt-dis-rule-bc.doc-qnty COLUMN-LABEL "Кол-во!для скидки" FORMAT "->>,>>>,>>9.<<<":U
tt-dis-rule-bc.tot-sum COLUMN-LABEL "Сумма для!скидки" FORMAT "->>>,>>>,>>9.99":U
tt-dis-rule-bc.time-rule-num FORMAT "->>>>>>>>9":U
tt-dis-rule-bc.discnt-value COLUMN-LABEL "Знач. скидки" FORMAT "->>>,>>>,>>9.99":U
tt-dis-rule-bc.d-pcnt COLUMN-LABEL "% скидки"
tt-dis-rule-bc.sale-qnty COLUMN-LABEL "Кол-во!для скидки" FORMAT ">>,>>>,>>9.<<<":U
tt-dis-rule-bc.price-brutto COLUMN-LABEL "Цена без скидки" FORMAT ">>,>>>,>>9.99":U
tt-dis-rule-bc.price-discnt COLUMN-LABEL "Скидка за ед" FORMAT "->>,>>>,>>9.99":U
tt-dis-rule-bc.price-netto COLUMN-LABEL "Цена со скидкой" FORMAT ">>,>>>,>>9.99":U
tt-dis-rule-bc.sum-brutto COLUMN-LABEL "Сумма без скидки" FORMAT ">,>>>,>>>,>>9.99":U
tt-dis-rule-bc.sum-discnt COLUMN-LABEL "Сумма скидки" FORMAT ">,>>>,>>>,>>9.99":U
tt-dis-rule-bc.sum-netto COLUMN-LABEL "Сумма со скидкой" FORMAT ">,>>>,>>>,>>9.99":U
tt-dis-rule-bc.charkey_one COLUMN-LABEL "Поле1" FORMAT "X(12)":U
tt-dis-rule-bc.charkey_two COLUMN-LABEL "Поле2" FORMAT "X(12)":U
tt-dis-rule-bc.charkey_three COLUMN-LABEL "Поле3" FORMAT "X(12)":U
tt-dis-rule-bc.key#_one COLUMN-LABEL "ИнтПоле1" FORMAT "->>>>>>>>9":U
tt-dis-rule-bc.key#_two COLUMN-LABEL "ИнтПоле2" FORMAT "->>>>>>>>9":U
tt-dis-rule-bc.key#_three COLUMN-LABEL "ИНтПоле3" FORMAT "->>>>>>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9
         FGCOLOR 1 FONT 4
         TITLE FGCOLOR 1 "Суммы и цены по товару после применения скидки" FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 26
     B-add AT ROW 1 COL 36
     B-copy AT ROW 1 COL 46 WIDGET-ID 4
     B-lookup AT ROW 1 COL 56
     B-chg AT ROW 1 COL 66
     B-del AT ROW 1 COL 76
     b-history AT ROW 1 COL 86
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     RS-sts AT ROW 2 COL 1.5 NO-LABEL
     Cb-pos-type AT ROW 2 COL 32 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     B-stat AT ROW 2 COL 56
     B-dis-rules AT ROW 2 COL 66
     B-time-rule AT ROW 2 COL 76
     br-dis-rule AT ROW 3.25 COL 1
     BR-gds-obj AT ROW 12.25 COL 1
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL
     v-des AT ROW 21.38 COL 1 NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Правила скидок".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-dis-rule-bc T "?" NO-UNDO ub dis-rule
      ADDITIONAL-FIELDS:
          field price-brutto like ub.gds-obj.price-sale
          field price-netto like ub.gds-obj.price-sale
          field price-discnt like ub.gds-obj.price-sale
          field sum-brutto like ub.trn-doc.tot-sale
          field sum-netto like ub.trn-doc.tot-sale
          field sum-discnt like ub.trn-doc.tot-sale
          field d-pcnt like ub.dis-rule.discnt-value
          field sale-qnty like ub.dis-rule.doc-qnty
      END-FIELDS.
      TABLE: tt0-template_dis-rule T "?" NO-UNDO ub dis-cfg-rule
      TABLE: X_bar-code B "?" ? ub bar-code
      TABLE: X_curr_clients B "?" ? ub clients
      TABLE: X_dis-rule B "?" ? ub dis-rule
      TABLE: X_dis-time-rule B "?" ? ub dis-time-rule
      TABLE: X_goods B "?" ? ub goods
      TABLE: X_term-dis-rule B "?" ? ub dis-rule
      TABLE: X_upper-dis-rule B "?" ? ub dis-rule
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-dis-rule B-time-rule Dialog-Frame */
/* BROWSE-TAB BR-gds-obj br-dis-rule Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-add:HIDDEN IN FRAME Dialog-Frame           = TRUE
       B-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-add:HANDLE.

ASSIGN
       B-chg:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-copy:HIDDEN IN FRAME Dialog-Frame           = TRUE
       B-copy:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-copy:HANDLE.

ASSIGN
       B-del:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-dis-rules:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       B-lookup:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-lookup:HANDLE.

ASSIGN
       B-time-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.

ASSIGN
       BR-gds-obj:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* SETTINGS FOR FILL-IN v-des IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-dis-rule
/* Query rebuild information for BROWSE br-dis-rule
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_dis-rule NO-LOCK,
      EACH tt-template_dis-rule OF ub.X_dis-rule NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY br-dis-rule FOR
                X_dis-rule,
                tt-template_dis-rule SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE br-dis-rule */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-gds-obj
/* Query rebuild information for BROWSE BR-gds-obj
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-dis-rule-bc OF ub.X_dis-rule NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is NOT OPENED
*/  /* BROWSE BR-gds-obj */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.X_dis-rule"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Правила скидок */
DO:
  ASSIGN
  p-rid-list = v-rid-list.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Правила скидок */
OR ENDKEY OF FRAME Dialog-Frame DO:
  run gbl/markqwa.p (
                           input b-mark:sensitive
                          , input v-rid-list) no-error.
  if error-status:error then return no-apply.

  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT {&add-def} ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
    RUN proc-b-chg IN THIS-PROCEDURE NO-ERROR.
    IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-copy Dialog-Frame
ON CHOOSE OF B-copy IN FRAME Dialog-Frame /* Копия */
DO:
  RUN proc-b-add IN THIS-PROCEDURE ( INPUT {&add-copy} ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
if not available X_dis-rule then return no-apply.
  run proc-b-del in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-dis-rules
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-dis-rules Dialog-Frame
ON CHOOSE OF B-dis-rules IN FRAME Dialog-Frame /* Правила */
DO:
RUN proc-b-dis-rules IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
  RUN proc-b-history IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lookup Dialog-Frame
ON CHOOSE OF B-lookup IN FRAME Dialog-Frame /* Просмотр */
DO:
 IF lookup-option = '':U  THEN DO:
   run gbl/pop-up.p ( INPUT self :handle, input no ) no-error.
   if error-status :error then do: return no-apply. end.
 end.
 if lookup-option = "":U then do:
      return no-apply.
 end.
 RUN proc-b-lookup IN THIS-PROCEDURE ( INPUT lookup-option) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN do:
    lookup-option = '':U.
    RETURN NO-APPLY.
 END.
 lookup-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
  RUN proc-b-mark IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then do:
    return no-apply.
  end.
  APPLY "ENTRY" to br-dis-rule.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_dis-rule ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_dis-rule ) ) .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-stat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-stat Dialog-Frame
ON CHOOSE OF B-stat IN FRAME Dialog-Frame /* Статус */
DO:
define variable loc#log as logical no-undo .
  IF NOT AVAILABLE X_dis-rule THEN RETURN NO-APPLY.
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_discount_work':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  loc#log
  }
  if not loc#log then return no-apply.
  v-doc-rec = recid(X_dis-rule).
  RUN proc-b-stat IN THIS-PROCEDURE ( input recid(X_dis-rule)) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
  RUN openbr IN THIS-PROCEDURE( input YES, input NO, input '':U) NO-ERROR.
   REPOSITION br-dis-rule to recid v-doc-rec No-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-time-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-time-rule Dialog-Frame
ON CHOOSE OF B-time-rule IN FRAME Dialog-Frame /* Распис. */
DO:
  RUN proc-b-time-rule IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-dis-rule
&Scoped-define SELF-NAME br-dis-rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-rule Dialog-Frame
ON RETURN OF br-dis-rule IN FRAME Dialog-Frame
or MOUSE-SELECT-DBLCLICK OF br-dis-rule IN FRAME Dialog-Frame
    DO:
    run proc-br-dis-rule in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-dis-rule Dialog-Frame
ON VALUE-CHANGED OF br-dis-rule IN FRAME Dialog-Frame
DO:

  IF AVAILABLE X_dis-rule  THEN DO:
    ASSIGN
    v-des = X_dis-rule.des
    .
  END.
  ELSE DO:
    ASSIGN
    v-des = "":U.
  END.
  DISPLAY
  v-des
  WITH FRAME {&FRAME-NAME}.
  assign
  menu-item m_subject:sensitive  in menu menu-b-lookup =   (available X_dis-rule and X_dis-rule.upper-rule-num <  {&max-num-dr-template})
  .
  RUN OpenBrgds-obj IN THIS-PROCEDURE.
  APPLY "ENTRY" TO br-dis-rule.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Cb-pos-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Cb-pos-type Dialog-Frame
ON VALUE-CHANGED OF Cb-pos-type IN FRAME Dialog-Frame
DO:
  assign
  cb-pos-type
  v-cd = cb-pos-type
  .
  run fill-tables in this-procedure .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global /* Глобально */
DO:
  ASSIGN
  ADD-OPTION = "global":U.
  APPLY "CHOOSE" TO b-add IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_global-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_global-copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_global-copy /* Глобально */
DO:
  ASSIGN
  ADD-OPTION = "global":U.
  APPLY "CHOOSE" TO b-copy IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host /* Фирма */
DO:
  ASSIGN
  ADD-OPTION = "host":U.
  APPLY "CHOOSE" TO b-add  IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_host-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_host-copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_host-copy /* Фирма */
DO:
  ASSIGN
  ADD-OPTION = "host":U.
  APPLY "CHOOSE" TO b-copy  IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object /* Объект */
DO:
  ASSIGN
  ADD-OPTION = "object":U.
  APPLY "CHOOSE" TO b-add  IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object-copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list-copy /* Объект */
DO:
define variable loc-doc-rec as recid no-undo .
  case p-mode:
    when {&g___object} then do:
      if available X_dis-rule then do:
        loc-doc-rec = recid(X_dis-rule).
      end.
      run utl/drc_obj.w ( input parparentproc
                     ,input {&g___object}
                     ,input 0
                     ,input p-curr-obj-type
                     ,input p-curr-obj-code
                     ) no-error.
    end.
    when "template" then do:
      if not available X_dis-rule then do:
        undo, return no-apply.
      end.
      run utl/drc_obj.w ( input parparentproc
                     ,input "template"
                     ,input X_dis-rule.templ-rl-root
                     ,input ''
                     ,input 0
                     ) no-error.
    end.
    otherwise do:
      if not available X_dis-rule then do:
        undo, return no-apply.
      end.
      if not (X_dis-rule.obj-type = {&shop}
              or
              X_dis-rule.obj-type = {&stock}) then do:
        message
        "Нельзя скопировать с правила скидки, которое действует НЕ ПО ОБЪЕКТУ"
        view-as alert-box error .
        undo, return no-apply.
      end.
      loc-doc-rec = recid(X_dis-rule).
      run utl/drc_obj.w ( input parparentproc
                     ,input "rule-num"
                     ,input X_dis-rule.rule-num
                     ,input ''
                     ,input 0
                     ) no-error.
    end.
  end case.
RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
reposition br-dis-rule to recid loc-doc-rec no-error.
{&cant-positioning}
apply "entry" to br-dis-rule in frame {&frame-name}.
apply "value-changed" to br-dis-rule in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_object-copy
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_object-copy Dialog-Frame
ON CHOOSE OF MENU-ITEM m_object-copy /* Объект */
DO:
  ASSIGN
  ADD-OPTION = "object":U.
  APPLY "CHOOSE" TO b-copy  IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME M_rule
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL M_rule Dialog-Frame
ON CHOOSE OF MENU-ITEM M_rule /* Правило */
DO:
   ASSIGN
  lookup-option = "rule".
  RUN proc-b-lookup IN THIS-PROCEDURE ( INPUT lookup-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      lookup-option = '':U.
      RETURN NO-APPLY.
  END.
  ASSIGN
  lookup-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_subject
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_subject Dialog-Frame
ON CHOOSE OF MENU-ITEM m_subject /* Объекты приложения правила */
DO:
  ASSIGN
  lookup-option = "subject".
  RUN proc-b-lookup IN THIS-PROCEDURE ( INPUT lookup-option) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      lookup-option = '':U.
      RETURN NO-APPLY.
  END.
  ASSIGN
  lookup-option = '':U.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-sts Dialog-Frame
ON VALUE-CHANGED OF RS-sts IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-sts
  p-sts = (IF rs-sts = {&all} THEN -1 ELSE INTEGER(rs-sts))
  .
  RUN openbr IN THIS-PROCEDURE ( input YES, input NO, input '':U) NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i &disable_diasize=true }
{ gbl/diasize.i  &browse-name="br-dis-rule" }
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_dis-rule then v-doc-rec = recid(X_dis-rule). run openbr in this-procedure ( input yes, input no, input '':U).  reposition br-dis-rule to recid v-doc-rec no-error. ~
               apply 'entry' to br-dis-rule in frame ~{&frame-name~}.  ~
               APPLY 'value-changed' to br-dis-rule. " }


{ gbl/setfltnm.i }
{ gbl/srt-clmd.i
  &browse-name    = "{&browse-name}"
  &frame-name     = "{&frame-name}"
  &table-name     = "{&first-table-in-query-{&browse-name}}"
  &sort-clmn_1    = "X_dis-rule.rule-num"
  &open-query     = "run OpenBr in this-procedure ( input YES, input NO, input '':U)."
  &open-query-otherwise = "run OpenBr in this-procedure ( input YES, input NO, input '':U)."
  &sort-column-name = "sort-column-name"
  &re-move-clmn   = "yes"
  &mv-brw-default = "yes"
}


{ gbl/brwrepos.i
  &line-num=5
}

{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel  }
&scop b-lookup ~{&b-lkp~}
{ gbl/hot-key.i b-lookup }
{ gbl/hot-key.i b-add  }
{ gbl/hot-key.i b-chg  }
{ gbl/hot-key.i b-del  }
{ gbl/hot-key.i b-print  }
{ gbl/hot-key.i b-history }


on f6 anywhere do:
define buffer buf0_dis-rule for ub.dis-rule.
find first buf0_dis-rule no-lock where
        buf0_dis-rule.rule-num = 0 no-error .
if available buf0_dis-rule then do:
  message
  "Версия структуры скидок" buf0_dis-rule.des
  view-as alert-box .
end.
else do:
  message
  "Не найдена головная запись структуры скидок!"
  view-as alert-box error .
end.

end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  if p-time-templ-rl-root = ? then do:
    p-time-templ-rl-root = -1.
  end.
  if p-sts = ? then do:
    p-sts = -1.
  end.
  RUN main-proc IN this-procedure no-error.
  if error-status:error then  undo, return error .
    { gbl/mv-clmn.i
    &browse-name = "br-dis-rule"
    &frame-name = "{&frame-name}"
    &ext-col = 19
    &start-column = 1
    &prev-order-column_1 = "'1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19'"
    &prev-order-column-condition_1 = " p-mode = ~{&all~} or p-mode = 'template':U "
    &prev-order-column_2 = "'1,2,3,4,8,9,10,11,5,6,7,12,13,14,15,16,17,18,19'"
    &prev-order-column-condition_2 = " p-mode = 'upper-rule-num':U "
    }
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse BR-gds-obj :handle
    ) .
  run diasize_init in this-procedure .
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY RS-sts Cb-pos-type mark-num v-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-copy B-lookup B-chg B-del b-history
         B-print B-sch B-Help RS-sts Cb-pos-type B-stat B-dis-rules B-time-rule
         br-dis-rule BR-gds-obj mark-num v-des
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable jj as integer no-undo .
define buffer buf_tt0-template_dis-rule for tt0-template_dis-rule.
define buffer buf_dis-rule  for ub.dis-rule.
define buffer buf0_dis-rule  for ub.dis-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
if p-mode = {&table_dis-gds-rule}
or p-mode = {&table_dis-dc-rule}
or p-mode = {&table_dis-dct-rule}
or p-mode = {&table_dis-cp-rule}
or p-mode = {&table_dis-thbj-rule}
or p-mode = {&table_dis-grp-rule}
or p-mode = {&table_dis-some-rule}
or p-mode = "dis-gds-rule-gds-obj"
or p-mode = "cd-obj":U then do:
end.
else do:
  for each buf_tt0-template_dis-rule:
    delete buf_tt0-template_dis-rule.
  end.
  if v-cd = '':U then do:
    find first buf_dis-rule no-lock where buf_dis-rule.rule-num = 0 no-error .
    if available buf_dis-rule then do:
      create buf_tt0-template_Dis-rule.
      buffer-copy buf_dis-rule to
      buf_tt0-template_dis-rule.
    end.
  end.
  else do:
    for each buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.pos-type = v-cd:
      create buf_tt0-template_Dis-rule.
      buffer-copy buf_dis-cfg-rule to
      buf_tt0-template_dis-rule.
    end.
  end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables-gds-obj Dialog-Frame
PROCEDURE fill-tables-gds-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
define buffer buf_units for ub.units.
define variable v-meas as integer no-undo init 3.
define variable ii as integer no-undo .

FOR EACH tt-dis-rule-bc:
  DELETE tt-dis-rule-bc.
END.

IF NOT AVAILABLE X_dis-rule THEN DO:
    return.
END.
find first buf_units no-lock where
           buf_units.unit-name = X_goods.unit-base no-error.
if available buf_units then do:
  assign
  v-meas = if( LOOKUP({&pieces}, buf_units.type) > 0 or LOOKUP({&serial}, buf_units.type) > 0 )
           then 0
           else v-meas.
end.

&SCOPED-DEFINE calc-values                                                                                         ~
   if X_dis-rule.tot-sum = - 1 then do:                                                                            ~
     /*это скидка на строку товара*/                                                                               ~
       assign  tt-dis-rule-bc.d-pcnt      = tt-dis-rule-bc.discnt-value .                                          ~
       CASE tt-dis-rule-bc.value-type:                                                                                 ~
           WHEN INTEGER(~{&discnt-v-pcnt~}) THEN DO:                                                               ~
              ASSIGN                                                                                               ~
              tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.discnt-value / 100            ~
              tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt               ~
              tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)               ~
              tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                 ~
              tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).              ~
           END.                                                                                                    ~
           WHEN INTEGER(~{&discnt-v-abs~}) THEN DO:                                                                ~
               ASSIGN                                                                                              ~
               tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.discnt-value                                           ~
               tt-dis-rule-bc.d-pcnt       = 100 * (1 - tt-dis-rule-bc.price-netto / tt-dis-rule-bc.price-brutto)  ~
               tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt              ~
               tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)              ~
               tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                ~
               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).             ~
           END.                                                                                                    ~
           WHEN INTEGER(~{&discnt-v-FP~}) THEN DO:                                                                 ~
               ASSIGN                                                                                              ~
               tt-dis-rule-bc.price-netto = tt-dis-rule-bc.discnt-value                                            ~
               tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-netto              ~
               tt-dis-rule-bc.sum-brutto = ABS(tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.doc-qnty)              ~
               tt-dis-rule-bc.sum-netto = ABS(tt-dis-rule-bc.price-netto * tt-dis-rule-bc.doc-qnty)                ~
               tt-dis-rule-bc.sum-discnt = ABS(tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.doc-qnty).             ~
            END.                                                                                                   ~
       END CASE.                                                                                                   ~
    end.                                                                                                           ~
    else do:                                                                                                       ~
    /*это скидка на сумму товара по строке*/                                                                       ~
       assign  tt-dis-rule-bc.sale-qnty = truncate(tt-dis-rule-bc.tot-sum / tt-dis-rule-bc.price-brutto, v-meas).  ~
       CASE tt-dis-rule-bc.value-type:                                                                                 ~
           WHEN INTEGER(~{&discnt-v-pcnt~}) THEN DO:                                                               ~
              ASSIGN                                                                                               ~
              tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.discnt-value / 100            ~
              tt-dis-rule-bc.d-pcnt      = tt-dis-rule-bc.discnt-value                                             ~
              tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt               ~
              tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                   ~
              tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                     ~
              tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                  ~
           END.                                                                                                    ~
           WHEN INTEGER(~{&discnt-v-abs~}) THEN DO:                                                                ~
               ASSIGN                                                                                              ~
               tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.discnt-value                                           ~
               tt-dis-rule-bc.d-pcnt       = 100 * (1 - tt-dis-rule-bc.price-netto / tt-dis-rule-bc.price-brutto)  ~
               tt-dis-rule-bc.price-netto = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-discnt              ~
               tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                  ~
               tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                    ~
               tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                ~
           END.                                                                                                    ~
           WHEN INTEGER(~{&discnt-v-FP~}) THEN DO:                                                                 ~
               ASSIGN                                                                                              ~
               tt-dis-rule-bc.price-netto = tt-dis-rule-bc.discnt-value                                            ~
               tt-dis-rule-bc.price-discnt = tt-dis-rule-bc.price-brutto - tt-dis-rule-bc.price-netto              ~
               tt-dis-rule-bc.sum-brutto = tt-dis-rule-bc.price-brutto * tt-dis-rule-bc.sale-qnty                  ~
               tt-dis-rule-bc.sum-netto = tt-dis-rule-bc.price-netto * tt-dis-rule-bc.sale-qnty                    ~
               tt-dis-rule-bc.sum-discnt = tt-dis-rule-bc.price-discnt * tt-dis-rule-bc.sale-qnty .                ~
            END.                                                                                                   ~
       END CASE.                                                                                                   ~
    end

CASE X_dis-rule.is-term:
    WHEN YES THEN DO:
       CREATE tt-dis-rule-bc.
       BUFFER-COPY X_dis-rule to tt-dis-rule-bc
       ASSIGN
       tt-dis-rule-bc.price-brutto = v-price-sale
       .
       {&calc-values}.
    END.
    WHEN NO  THEN DO:
        FOR EACH buf_dis-rule NO-LOCK WHERE
                buf_dis-rule.upper-rule-num = X_dis-rule.rule-num:
            CREATE tt-dis-rule-bc.
            BUFFER-COPY buf_dis-rule to tt-dis-rule-bc
            ASSIGN
            tt-dis-rule-bc.price-brutto = v-price-sale
            .
            {&calc-values}.
        END.
    END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-tree Dialog-Frame
PROCEDURE get-tree :
DEFINE PARAMETER BUFFER loc_dis-rule for ub.dis-rule.
DEFINE OUTPUT PARAMETER p-display-time-rule-num AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER p-display-dis-kat AS CHARACTER  NO-UNDO.
DEFINE OUTPUT PARAMETER p-display-doc-qnty AS CHARACTER  NO-UNDO.
DEFINE OUTPUT PARAMETER p-display-tot-sum AS CHARACTER  NO-UNDO.
define output parameter p-display-charkey_one as character no-undo .
define output parameter p-display-charkey_two as character no-undo .
define output parameter p-display-charkey_three as character no-undo .
define output parameter p-display-deckey_one as character no-undo .
define output parameter p-display-deckey_two as character no-undo .
define output parameter p-display-deckey_three as character no-undo .
define output parameter p-display-key#_one as character no-undo .
define output parameter p-display-key#_two as character no-undo .
define output parameter p-display-key#_three as character no-undo .
DEFINE OUTPUT PARAMETER p-display-discnt-value AS CHARACTER  NO-UNDO.
define output parameter p-using-fields as character no-undo .

DEFINE VARIABLE v-entry AS CHARACTER NO-UNDO INIT ?.
DEFINE VARIABLE ii AS INTEGER NO-UNDO.
define variable v-level-1 as character no-undo .
define variable v-level-2 as character no-undo .
define variable v-curr-level as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
&SCOPED-DEFINE etc "...    "
IF loc_dis-rule.uniq-field <> "":U
AND loc_dis-rule.upper-rule-num <= {&max-num-dr-template} THEN DO:
  DO ii = 1 TO NUM-ENTRIES(loc_dis-rule.uniq-field):
    v-entry = ENTRY(ii, loc_dis-rule.uniq-field).
    CASE v-entry:
      WHEN "time-rule-num" THEN DO:
        ASSIGN
        p-display-time-rule-num = {&etc}.
      END.
      WHEN "doc-qnty" THEN DO:
        ASSIGN
        p-display-doc-qnty = {&etc}.
      END.
      WHEN "tot-sum" THEN DO:
        ASSIGN
        p-display-tot-sum = {&etc}.
      END.
      WHEN "dis-kat" THEN DO:
        ASSIGN
        p-display-dis-kat = {&etc}.
      END.
      WHEN "charkey_one" THEN DO:
        ASSIGN
        p-display-charkey_one = {&etc}.
      END.
      WHEN "charkey_two" THEN DO:
        ASSIGN
        p-display-charkey_two = {&etc}.
      END.
      WHEN "charkey_three" THEN DO:
        ASSIGN
        p-display-charkey_three = {&etc}.
      END.
      WHEN "deckey_one" THEN DO:
        ASSIGN
        p-display-deckey_one = {&etc}.
      END.
      WHEN "deckey_two" THEN DO:
        ASSIGN
        p-display-deckey_two = {&etc}.
      END.
      WHEN "deckey_three" THEN DO:
        ASSIGN
        p-display-deckey_three = {&etc}.
      END.
      WHEN "key#_one" THEN DO:
        ASSIGN
        p-display-key#_one = {&etc}.
      END.
      WHEN "key#_two" THEN DO:
        ASSIGN
        p-display-key#_two = {&etc}.
      END.
      WHEN "key#_three" THEN DO:
        ASSIGN
        p-display-key#_three = {&etc}.
      END.
    END CASE.
  END.
  ASSIGN
  p-using-fields = ?
  .
END.
find first buf_Dis-cfg-rule no-lock where
          buf_Dis-cfg-rule.templ-rl-root = loc_dis-rule.templ-rl-root
     and  buf_Dis-cfg-rule.table-name = '':U
     and  buf_Dis-cfg-rule.pos-type = '':U
     and  buf_Dis-cfg-rule.discnt-role = '':U
     and  buf_Dis-cfg-rule.self-nonunique = '':U
     and buf_Dis-cfg-rule.time-templ-rl-root = 0 no-error .
if error-status:error then do:
end.
if loc_dis-rule.rule-num > {&max-num-dr-template} then do:
  assign
  v-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
  v-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                else '')
  p-using-fields = (if loc_dis-rule.upper-rule-num <= {&max-num-dr-template}
                  then v-level-1
                  else v-level-2).

  ASSIGN
  p-display-time-rule-num = (if p-display-time-rule-num = {&etc}
                             then p-display-time-rule-num
                             else (if lookup("time-rule-num", p-using-fields) = 0
                                  then "":U
                                  else string(loc_dis-rule.time-rule-num))
                            )
  p-display-dis-kat =  (if p-display-dis-kat = {&etc}
                        then p-display-dis-kat
                        else  (if lookup("dis-kat", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.dis-kat))
                                )
  p-display-doc-qnty = (if p-display-doc-qnty = {&etc}
                        then p-display-doc-qnty
                        else (if lookup("doc-qnty", p-using-fields) = 0
                              then "":U else string(loc_dis-rule.doc-qnty))
                        )
  p-display-tot-sum  = (if p-display-tot-sum = {&etc}
                        then p-display-tot-sum
                        else (if lookup("tot-sum", p-using-fields) = 0
                             then "":U else string(loc_dis-rule.tot-sum))
                        )
  p-display-discnt-value = (if p-display-discnt-value = {&etc}
                            then p-display-discnt-value
                            else (if loc_dis-rule.value-type = integer({&discnt-v-pcnt})
                                  then STRING(loc_dis-rule.discnt-value, "->9.99%")
                                  else STRING(loc_dis-rule.discnt-value))
                            )
  p-display-charkey_one = (if p-display-charkey_one = {&etc}
                           then p-display-charkey_one
                           else (if lookup("charkey_one", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.charkey_one))
                           )
  p-display-charkey_two = (if p-display-charkey_two = {&etc}
                           then p-display-charkey_two
                           else (if lookup("charkey_two", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.charkey_two))
                           )
  p-display-charkey_three = (if p-display-charkey_three = {&etc}
                             then p-display-charkey_three
                             else (if lookup("charkey_three", p-using-fields) = 0
                                  then "":U else string(loc_dis-rule.charkey_three))
                             )
  p-display-deckey_one = (if p-display-deckey_one = {&etc}
                          then p-display-deckey_one
                          else (if lookup("deckey_one", p-using-fields) = 0
                                then "":U else string(loc_dis-rule.deckey_one))
                          )
  p-display-deckey_two = (if p-display-deckey_two = {&etc}
                          then p-display-deckey_two
                          else (if lookup("deckey_two", p-using-fields) = 0
                               then "":U else string(loc_dis-rule.deckey_two))
                          )
  p-display-deckey_three = (if p-display-deckey_three = {&etc}
                            then p-display-deckey_three
                            else (if lookup("deckey_three", p-using-fields) = 0
                               then "":U else string(loc_dis-rule.deckey_three))
                           )
  p-display-key#_one = (if p-display-key#_one = {&etc}
                        then p-display-key#_one
                        else (if lookup("key#_one", p-using-fields) = 0
                              then "":U else string(loc_dis-rule.key#_one))
                        )
  p-display-key#_two = (if p-display-key#_two = {&etc}
                        then p-display-key#_two
                        else (if lookup("key#_two", p-using-fields) = 0
                             then "":U else string(loc_dis-rule.key#_two))
                        )
  p-display-key#_three = (if p-display-key#_three = {&etc}
                          then  p-display-key#_three
                          else (if lookup("key#_three", p-using-fields) = 0
                               then "":U else string(loc_dis-rule.key#_three))
                          )
  .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main-proc Dialog-Frame
PROCEDURE main-proc :
define variable  vget-des     as character no-undo .
define variable  vget-dis-kat           like ub.dis-rule.dis-kat           no-undo .
define variable  vget-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  vget-doc-qnty          like ub.dis-rule.doc-qnty          no-undo .
define variable  vget-tot-sum           like ub.dis-rule.tot-sum           no-undo .
define variable  vget-charkey_one       like ub.dis-rule.charkey_one       no-undo .
define variable  vget-charkey_two       like ub.dis-rule.charkey_two       no-undo .
define variable  vget-charkey_theree    like ub.dis-rule.charkey_three     no-undo .
define variable  vget-key#_one          like ub.dis-rule.key#_one          no-undo .
define variable  vget-key#_two          like ub.dis-rule.key#_two          no-undo .
define variable  vget-key#_theree       like ub.dis-rule.key#_three        no-undo .
define variable  vget-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  vget-time-rule-num     like ub.dis-rule.time-rule-num     no-undo .
define variable  vget-upper-rule-num    like ub.dis-rule.upper-rule-num    no-undo .
define variable  vget-value-type        like ub.dis-rule.value-type        no-undo .
define variable  vget-global            as integer no-undo .
define variable  vget-host              as integer no-undo .
define variable  vget-object            as integer no-undo .
define variable  vget-output-display as logical   no-undo . /* виден в броусе статус 0*/
define variable  vget-tree            as character no-undo .
define variable  vget-other          as character no-undo . /* еще чего - нибудь */
define buffer get_dis-rule for ub.dis-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf_tt0-template_dis-rule for tt0-template_dis-rule.

if not (p-curr-obj-type = "":U and p-curr-obj-code = 0)
 OR p-mode = "upper-rule-num-gds-obj"
 or p-mode  = "dis-gds-rule-gds-obj"
 or p-mode = "cd-obj"
 then do:
  find first X_curr_clients no-lock where
            X_curr_clients.obj-type = p-curr-obj-type
       AND X_curr_clients.obj-code = p-curr-obj-code no-error.
  if not available X_curr_clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра вызова p-curr-obj-type p-curr-obj-code"
    p-curr-obj-type p-curr-obj-code
    view-as alert-box ERROR.
    return error .
  end.
 end.
 if LOOKUP(p-mode,  ({&all} + {&delim-par} +
                    "upper-rule-num":U + {&delim-par} +
                    "upper-rule-num-object":U + {&delim-par} +
                    "upper-rule-num-all-obj":U + {&delim-par} +
                    "upper-rule-num-host":U + {&delim-par} +
                    "upper-rule-num-global":U + {&delim-par} +
                    "upper-rule-num-gds-obj":U + {&delim-par} +
                    "template":U + {&delim-par} +
                    "time-rule-num" + {&delim-par} +
                    {&g___object}),
                {&delim-par}) = 0
    and entry(1, p-mode, "=") <> {&table_dis-gds-rule}
    and entry(1, p-mode, "=") <> "dis-gds-rule-gds-obj":U
    and entry(1, p-mode, "=") <> "cd-obj":U
    and entry(1, p-mode, "=") <> {&table_dis-dc-rule}
    and entry(1, p-mode, "=") <> {&table_dis-dct-rule}
    and entry(1, p-mode, "=") <> {&table_dis-cp-rule}
    and entry(1, p-mode, "=") <> {&table_dis-grp-rule}
    and entry(1, p-mode, "=") <> {&table_dis-some-rule}
    and entry(1, p-mode, "=") <> "template-value-type"
     then dO:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"
    p-mode
    view-as alert-box ERROR.
    return error .
 end.
 if entry(1, p-mode, "=":U) = "template-value-type" then do:
   assign
   p-value-type = entry(2, p-mode, "=":U)
   no-error .
   p-mode = entry(1, p-mode, "=":U).
 end.
 IF entry(1, p-mode, "=":U) = {&table_dis-gds-rule}
 or entry(1, p-mode, "=":U) = "dis-gds-rule-gds-obj" then do:
   assign
   v-discnt-role = entry(2, p-mode, "=":U)
   no-error .
   for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.table-name = {&table_dis-gds-rule}
      and buf_dis-cfg-rule.discnt-role = v-discnt-role  :
     if p-time-templ-rl-root <> -1
     and buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root then do:
       next.
     end.
     create buf_tt0-template_dis-rule.
     buffer-copy buf_dis-cfg-rule to
     buf_tt0-template_dis-rule.
   end.
   if entry(1, p-mode, "=":U) = {&table_dis-gds-rule} then do:
     assign
     p-mode = {&table_dis-gds-rule}.
   end.
 end.
 IF entry(1, p-mode, "=":U) = {&table_dis-cp-rule}
 or entry(1, p-mode, "=":U) = {&table_dis-dc-rule}
 or entry(1, p-mode, "=":U) = {&table_dis-dct-rule}
 or entry(1, p-mode, "=":U) = {&table_dis-grp-rule}
 or entry(1, p-mode, "=":U) = {&table_dis-some-rule}
 then do:
   if num-entries(p-mode, "=") > 2 then do:
     v-region = entry(3, p-mode, "=").
   end.
   assign
   v-discnt-role = entry(2, p-mode, "=":U)
   p-mode = entry(1, p-mode, "=":U)
   no-error .
   for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.table-name = p-mode
      and buf_dis-cfg-rule.discnt-role = v-discnt-role :
     if p-time-templ-rl-root <> -1
     and buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root then do:
       next.
     end.
     create buf_tt0-template_dis-rule.
     buffer-copy buf_dis-cfg-rule to
     buf_tt0-template_dis-rule.
   end.
 end.
 /*выбор правил пор кассам*/
 IF entry(1, p-mode, "=":U) = "cd-obj"
 THEN DO:
   assign
   v-cd = entry(2, p-mode, "=":U)
   p-mode = entry(1, p-mode, "=":U)
   .

    for each buf_dis-cfg-rule no-lock where
          buf_dis-cfg-rule.pos-type = v-cd :
     if p-time-templ-rl-root <> -1
     and buf_dis-cfg-rule.time-templ-rl-root <> p-time-templ-rl-root then do:
       next.
     end.
     create buf_tt0-template_dis-rule.
     buffer-copy buf_dis-cfg-rule to
     buf_tt0-template_dis-rule.
   end.
 END.
  if p-mode = "upper-rule-num"
  or p-mode = "upper-rule-num-object"
  or p-mode = "upper-rule-num-all-obj"
  or p-mode = "upper-rule-num-gds-obj"
  or p-mode = "upper-rule-num-host"
  or p-mode = "upper-rule-num-global"
  then do:
   find first X_upper-dis-rule no-lock where
          X_upper-dis-rule.rule-num = p-upper-rule-num no-error.
   if not available X_upper-dis-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
   if X_upper-dis-rule.rule-num > {&max-num-dr-template}
   and (lookup(bttns, "b-sel") > 0 or lookup(bttns, "b-mark") > 0) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова bttn или p-upper-rule-num"
    bttns p-upper-rule-num
    view-as alert-box ERROR.
    return error .

   end.
  end.
  if p-mode = "time-rule-num" then do:
   find first X_dis-time-rule no-lock where
          X_dis-time-rule.time-rule-num = p-time-templ-rl-root no-error.
   if not available X_dis-time-rule then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-upper-rule-num"
    p-upper-rule-num
    view-as alert-box ERROR.
    return error .
   end.
  end.
  if p-mode = "upper-rule-num-gds-obj"
  or p-mode = "dis-gds-rule-gds-obj"
  then do:
    find first X_bar-code no-lock where
              X_bar-code.b-code = p-b-code no-error.
    if not available X_bar-code then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-b-code" p-b-code
      view-as alert-box ERROR.
      return error .
    end.
    find first X_goods no-lock where
             X_goods.gds-code = x_bar-code.gds-code no-error .
    if not available X_goods then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-b-code" p-b-code skip
      "Не найден товар для бар-кода" p-b-code
      view-as alert-box ERROR.
      return error .
    end.
  end.
 { gbl/curdbnum.i v-db-num }
 run fill-tables in this-procedure no-error.
 if error-status:error then  undo, return error .
 RUN MyEnable in this-procedure .
 assign
 v-doc-rec = integer(entry(1, v-rid-list))
 .
 RUn OpenBR IN THIS-PROCEDURE ( input YES, input NO, input '':U).
 if v-doc-rec <> ?
 and v-doc-rec <> 0
 then do:
   reposition br-dis-rule to recid v-doc-rec no-error.
   apply "ENTRY" to br-dis-rule in frame {&frame-name} .
   APPLY "VALUE-CHANGED" to br-dis-rule.
 end.
 HIDE mark-num in frame {&frame-name} .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display as logical   no-undo . /* виден в броусе */
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo . /* еще чего - нибудь */
DEFINE VARIABLE v-doc-num LIKE ub.price-list.doc-num NO-UNDO.
DEFINE VARIABLE v-road-tax LIKE ub.price-list.road-tax NO-UNDO.
DEFINE VARIABLE v-excise LIKE ub.price-list.excise NO-UNDO.
DEFINE VARIABLE ii AS INTEGer NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-curr-level as character no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable v-h as handle no-undo .
define variable v-real-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
if p-upper-rule-num <> ?
and  p-upper-rule-num <> 0 then do:
  v-templ-rl-root = (if p-upper-rule-num <= {&max-num-dr-template}
                     then p-upper-rule-num
                     else X_upper-dis-rule.templ-rl-root).
  run dr-code  in this-procedure (
                                   input  v-templ-rl-root
                                  ,output v-des
                                  ,output v-discnt-type
                                  ,output v-subject-type
                                  ,output v-value-type
                                  ,output v-level-1
                                  ,output v-level-2
                                  ,OUTPUT v-global
                                  ,OUTPUT v-host
                                  ,OUTPUT v-object
                                  ,output v-output-display
                                  ,output v-tree
                                  ,output v-other
                                                            )  NO-ERROR.
  run disrules-fill-properties in this-procedure ( input v-templ-rl-root).
end.

ASSIGN
b-lookup:MENU-MOUSE IN FRAME {&FRAME-NAME} = 1
X_dis-rule.des:resizable in browse br-dis-rule = yes
.
assign
v-list-items = "":U + {&comma-char} + "":U.
DO v-ii = 1 TO NUM-ENTRIES({&cd-type-codes-discnt}):
    ASSIGN
    v-list-items = v-list-items +  {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt-full}) + {&comma-char} +
                   ENTRY(v-ii, {&cd-type-codes-discnt}).
END.
assign
cb-pos-type:list-item-pairs in frame {&frame-name} = v-list-items.
IF v-cd > '':U THEN DO:
   ASSIGN
   cb-pos-type = v-cd.
END.
IF p-mode = "upper-rule-num-gds-obj"
or p-mode = "dis-gds-rule-gds-obj"
THEN DO:
  if X_upper-dis-rule.value-type = integer({&discnt-v-pcnt}) then do:
    tt-dis-rule-bc.discnt-value:LABEL in browse br-gds-obj =
    tt-dis-rule-bc.discnt-value:LABEL in browse br-gds-obj + "%".
  end.
  { gbl/bcodeprc.i
      p-curr-obj-type
      p-curr-obj-code
      p-b-code
      0
      0
      v-doc-num
      v-price-sale
      v-road-tax
      v-excise
      no-error }
  ASSIGN
  tt-dis-rule-bc.doc-qnty:VISIBLE IN BROWSE br-gds-obj = NO
  tt-dis-rule-bc.sum-brutto:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.sum-discnt:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.sum-netto:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.tot-sum:VISIBLE IN BROWSE br-gds-obj = NO
  tt-dis-rule-bc.dis-kat:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.charkey_one:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.charkey_two:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.charkey_three:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.key#_one:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.key#_two:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.key#_three:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.d-pcnt:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.sale-qnty:VISIBLE IN BROWSE br-gds-obj = no
  tt-dis-rule-bc.time-rule-num:VISIBLE IN BROWSE br-gds-obj = no
  .
  v-h = br-gds-obj:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
  DO while valid-handle(v-h) :
    if lookup(v-h:name, v-level-1) > 0
    or lookup(v-h:name, v-level-2) > 0
    then do:
      ASSIGN
      v-h:visible = yes
      .
      find first buf_temp-drt-prop no-lock where
                buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
            and buf_temp-drt-prop.upper-prop-code = v-h:name
            and buf_temp-drt-prop.prop-code = "column-label" no-error.
      if available buf_temp-drt-prop then do:
        assign
        v-h:label = buf_temp-drt-prop.property-value.
      end.
      find first buf_temp-drt-prop no-lock where
                buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
            and buf_temp-drt-prop.upper-prop-code = v-h:name
            and buf_temp-drt-prop.prop-code = "format":U no-error.
      if available buf_temp-drt-prop then do:
        assign
        v-h:format = buf_temp-drt-prop.property-value.
      end.
      case v-h:name:
        when "doc-qnty" then do:
          assign
          tt-dis-rule-bc.sum-brutto:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-discnt:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-netto:VISIBLE IN BROWSE br-gds-obj = YES
           .
         end.
         when "tot-sum" then do:
           assign
          tt-dis-rule-bc.sale-qnty:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.doc-qnty:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-brutto:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-discnt:VISIBLE IN BROWSE br-gds-obj = YES
          tt-dis-rule-bc.sum-netto:VISIBLE IN BROWSE br-gds-obj = YES
          .
         end.
       end case.
    end.
    v-h = v-h:NEXT-COLUMN.
  END.
  if X_upper-dis-rule.value-type <> integer({&discnt-v-pcnt}) then
  tt-dis-rule-bc.d-pcnt:VISIBLE IN BROWSE br-gds-obj = YES.
END.

ASSIGN
rs-sts:RADIO-BUTTONS IN FRAME {&FRAME-NAME}
                       = "Использ&+" + {&comma-char} +  {&used-status-int} + {&comma-char} +
                       "Все&!" + {&comma-char} + {&all} + {&comma-char} +
                        "Неиспольз&-" + {&comma-char} + {&non-used-status-int}
rs-sts = (IF p-sts = -1 THEN {&all} ELSE string(p-sts))
.

if not (p-curr-obj-type = "":U and p-curr-obj-code = 0) then do:
  if p-curr-obj-type = {&cmp} then do:
    assign
    v-host-code = p-curr-obj-code
    v-obj-type = v-cntxt-obj-type
    v-obj-code = v-cntxt-obj-code
    .
  end.
  else do:
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
  assign
  v-obj-type = p-curr-obj-type
  v-obj-code = p-curr-obj-code
  .
end.
end.
else do:
  assign
  v-host-code = v-cntxt-host-code-obj
  v-obj-type = v-cntxt-obj-type
  v-obj-code = v-cntxt-obj-code
  .
end.
assign
b-add:MENU-MOUSE in frame {&frame-name} = 1
b-copy:MENU-MOUSE in frame {&frame-name} = 1
menu-item m_global:sensitive in menu menu-b-add = (if  v-cntxt-db-num = 0 then yes else no)
menu-item m_host:sensitive in menu menu-b-add = (if v-cntxt-db-num = 0 then yes else no)
menu-item m_object:sensitive in menu menu-b-add = yes
menu-item m_host:label in menu menu-b-add = "Фирма" + {&space-char} + string(v-host-code)
menu-item m_object:label in menu menu-b-add = v-obj-type + string(v-obj-code)
menu-item m_global-copy:sensitive in menu menu-b-copy = (if  v-cntxt-db-num = 0 then yes else no)
menu-item m_host-copy:sensitive in menu menu-b-copy = (if v-cntxt-db-num = 0 then yes else no)
menu-item m_object-copy:sensitive in menu menu-b-copy = yes
menu-item m_host-copy:label in menu menu-b-copy = "Фирма" + {&space-char} + string(v-host-code)
menu-item m_object-copy:label in menu menu-b-copy = v-obj-type + string(v-obj-code)
.
IF p-upper-rule-num = ?
or p-upper-rule-num = 0
or p-upper-rule-num > {&max-num-dr-template} then do:
  ASSIGN
  MENU-ITEM m_global :SENSITIVE IN MENU menu-b-add = NO
  MENU-ITEM m_host :SENSITIVE IN MENU menu-b-add = NO
  MENU-ITEM m_object :SENSITIVE IN MENU menu-b-add = NO
  MENU-ITEM m_global-copy :SENSITIVE IN MENU menu-b-copy = NO
  MENU-ITEM m_host-copy :SENSITIVE IN MENU menu-b-copy = NO
  MENU-ITEM m_object-copy :SENSITIVE IN MENU menu-b-copy = NO
  .
END.
ELSE DO:
  ASSIGN
  MENU-ITEM m_global :SENSITIVE IN MENU menu-b-add = (v-global > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_host :SENSITIVE IN MENU menu-b-add = (v-host > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_object :SENSITIVE IN MENU menu-b-add = (v-object > 0)
  MENU-ITEM m_global-copy :SENSITIVE IN MENU menu-b-copy = (v-global > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_host-copy :SENSITIVE IN MENU menu-b-copy = (v-host > 0 AND v-cntxt-db-num = 0)
  MENU-ITEM m_object-copy:SENSITIVE IN MENU menu-b-copy = (v-object > 0)
  .
END.
if p-mode = {&g___object}
or p-mode = "template" then do:
   assign
   MENU-ITEM m_global-copy :SENSITIVE IN MENU menu-b-copy =  no
   MENU-ITEM m_host-copy :SENSITIVE IN MENU menu-b-copy = no
   MENU-ITEM m_object-copy:SENSITIVE IN MENU menu-b-copy = no
   .
end.
if p-mode = "template" then do:
  MENU-ITEM m_list-copy:label IN MENU menu-b-copy =  "Правила скидок этого типа на другие объекты по списку".
end.
if p-mode = {&g___object} then do:
  MENU-ITEM m_list-copy:label IN MENU menu-b-copy =  "Скидки, действующие на этом объекте на другие объекты по списку".
end.

IF p-mode <> "upper-rule-num-gds-obj"
and p-mode <> "dis-gds-rule-gds-obj"
THEN DO:
  ASSIGN
   br-dis-rule:HEIGHT = br-dis-rule:height * 2.
END.
DISPLAY mark-num
rs-sts
br-gds-obj WHEN (p-mode = "upper-rule-num-gds-obj" or p-mode = "dis-gds-rule-gds-obj")
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-mark when LOOKUP("b-mark":U, bttns) > 0
B-sel when LOOKUP("b-sel":U, bttns) > 0
B-add when LOOKUP("b-add":U, bttns) > 0 and
(p-mode = "upper-rule-num":U OR
 p-mode = "upper-rule-num-object":U OR
 p-mode = "upper-rule-num-all-obj":U OR
 p-mode = "upper-rule-num-gds-obj":U or
 p-mode = "upper-rule-num-host":U or
 p-mode = "upper-rule-num-global":U
 )
    AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0
and not TRANSACTION
B-copy when ((LOOKUP("b-add":U, bttns) > 0 and
(p-mode = "upper-rule-num":U OR
 p-mode = "upper-rule-num-object":U OR
 p-mode = "upper-rule-num-all-obj":U OR
 p-mode = "upper-rule-num-gds-obj":U or
 p-mode = "upper-rule-num-host":U or
 p-mode = "upper-rule-num-global":U
 )
    AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0)
    or p-mode = {&g___object} or p-mode = "template")
and not TRANSACTION
B-lookup
B-chg when LOOKUP("b-add":U, bttns) > 0 and
     (p-mode = "upper-rule-num":U OR
 p-mode = "upper-rule-num-object":U OR
 p-mode = "upper-rule-num-all-obj":U OR
 p-mode = "upper-rule-num-gds-obj":U OR
 p-mode = "upper-rule-num-global":U OR
 p-mode = "upper-rule-num-host":U
 )
   AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0
and not TRANSACTION
B-del when LOOKUP("b-add":U, bttns) > 0 and
    (p-mode = "upper-rule-num":U OR
p-mode = "upper-rule-num-object":U OR
p-mode = "upper-rule-num-all-obj":U OR
p-mode = "upper-rule-num-gds-obj":U OR
p-mode = "upper-rule-num-global":U OR
p-mode = "upper-rule-num-host":U
)
AND X_upper-dis-rule.upper-rule-num  = 0 AND p-upper-rule-num <> 0
and not TRANSACTION
B-print
B-Help
b-history
b-stat when LOOKUP("b-add", bttns) > 0
and
 (p-mode = "upper-rule-num":U OR
  p-mode = "upper-rule-num-object":U OR
  p-mode = "upper-rule-num-all-obj":U OR
  p-mode = "upper-rule-num-gds-obj":U OR
p-mode = "upper-rule-num-global":U OR
p-mode = "upper-rule-num-host":U

  )
  and not TRANSACTION
B-dis-rules WHEN p-mode = "template":U or p-mode = "template-value-type" OR p-upper-rule-num = 0 or v-tree <> "":U
br-dis-rule
b-time-rule when
    not ((p-mode = "upper-rule-num"
         or
         p-mode = "upper-rule-num-object"
         or
         p-mode = "upper-rule-num-all-obj"
         or
         p-mode = "upper-rule-num-gds-obj"
         or
         p-mode = "upper-rule-num-global"
         or
         p-mode = "upper-rule-num-host")
         and X_upper-dis-rule.time-rule-num = 0
        )
b-sch
mark-num
rs-sts when not (p-mode = "template":U
                 or p-mode = "template-value-type"
                 or (p-upper-rule-num = 0 and p-mode = "upper-rule-num":U)
                 or
                  (p-mode =  "upper-rule-num":U
                  and X_upper-dis-rule.rule-num > {&max-num-dr-template})
                  )
with FRAME {&frame-name}.

VIEW FRAME {&frame-name}.
IF not (p-mode = "template":U
        or
        p-mode = "template-value-type")
or p-upper-rule-num <> 0 THEN DO:
  assign
  b-dis-rules:label in frame {&frame-name} = "Детально"
  .
END.
if p-mode = "template"
or p-mode = "template-value-type"
or (p-upper-rule-num = 0  and p-mode = "upper-rule-num":U)
then do:
  DISABLE
  rs-sts
  with FRAME {&frame-name}.
end.
assign
v-display-discnt-value:visible in browse br-dis-rule = no
v-display-dis-kat:visible in browse br-dis-rule = no
v-display-doc-qnty:visible in browse br-dis-rule = no
v-display-tot-sum:visible in browse br-dis-rule = no
v-display-time-rule-num:visible in browse br-dis-rule = no
v-display-charkey_one:visible in browse br-dis-rule = no
v-display-charkey_two:visible in browse br-dis-rule = no
v-display-charkey_three:visible in browse br-dis-rule = no
v-display-deckey_one:visible in browse br-dis-rule = no
v-display-deckey_two:visible in browse br-dis-rule = no
v-display-deckey_three:visible in browse br-dis-rule = no
v-display-key#_one:visible in browse br-dis-rule = no
v-display-key#_two:visible in browse br-dis-rule = no
v-display-key#_three:visible in browse br-dis-rule = no
.
case p-mode:
  when "template"
  or
  when {&all}
  or
  when "template-value-type"
  then do:
    /*уже всн невидно*/
  end.
  otherwise do:
    /*
    "upper-rule-num"
    "upper-rule-num-object"
    "upper-rule-num-all-obj"
    "upper-rule-num-host"
    "upper-rule-num-global"
    "upper-rule-num-gds-obj":U
    "time-rule-num":U
    {&g___object}
    {&table_dis-gds-rule}
   "cd-obj":U
    {&table_dis-dc-rule}
    {&table_dis-dct-rule}
    {&table_dis-cp-rule}
    {&table_dis-grp-rule}
    "dis-gds-rule-gds-obj":U
    */
    if p-upper-rule-num = 0
    or p-upper-rule-num = ?
    then do:
      /*уже все невидно*/
    end.
    else do:
      if p-upper-rule-num <= {&max-num-dr-template} then do:
        v-curr-level = v-level-1.
      end.
      else do:
        v-curr-level = v-level-2.
      end.
      v-h = br-dis-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}.
      DO while valid-handle(v-h) :
        v-real-name = replace(v-h:name, "v-display-", "").
        if lookup(v-real-name, v-curr-level) > 0
        then do:
          ASSIGN
          v-h:visible = yes
          .
          find first buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
                and buf_temp-drt-prop.upper-prop-code = v-real-name
                and buf_temp-drt-prop.prop-code = "column-label" no-error.
          if available buf_temp-drt-prop then do:
            assign
            v-h:label = buf_temp-drt-prop.property-value.
          end.
          find first buf_temp-drt-prop no-lock where
                    buf_temp-drt-prop.templ-rl-root = v-templ-rl-root
                and buf_temp-drt-prop.upper-prop-code = v-real-name
                and buf_temp-drt-prop.prop-code = "format":U no-error.
          if available buf_temp-drt-prop then do:
            assign
            v-h:format = buf_temp-drt-prop.property-value.
          end.
        end.
        v-h = v-h:NEXT-COLUMN.
      end. /*DO while valid-handle(v-h) :*/
    end.
  end.
end case.
IF p-mode <> "upper-rule-num-gds-obj"
and p-mode <> "dis-gds-rule-gds-obj"
THEN DO:
   HIDE br-gds-obj
   IN FRAME {&frame-name}.
END.
else do:
  enable
  BR-gds-obj
  with frame {&frame-name} .
end.
if p-mode = "upper-rule-num" and X_upper-dis-rule.rule-num > {&max-num-dr-template} then do:
  HIDE
  b-add
  b-copy
  b-chg
  b-del
  b-stat
  IN FRAME {&frame-name}.
end.
IF v-cd = '':U THEN DO:
   enable
   cb-pos-type
   WITH FRAME {&FRAME-NAME}.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo init "Правила скидок".
define variable v-jj as integer   no-undo .
run waitfram-show in this-procedure ( input "Ждите...").

define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
/* определяем здесь общие параметры для процедуры открытия query fltopend.i */
if not( p-curr-obj-type = "":U and p-curr-obj-code = 0 ) then do:
  if p-curr-obj-type = {&cmp} then do:
    assign
    p-host-code = p-curr-obj-code
    .
  end.
  else do:
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code p-host-code }
end.
end.


&scop flt-open-open-query OPEN QUERY br-dis-rule FOR EACH X_dis-rule

&scop flt-open-dyn_open-query FOR EACH X_dis-rule

&scop flt-open-query-handle query br-dis-rule:handle

&scop flt-open-open-query-tail , FIRST tt-template_dis-rule where (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd ~
and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)

&scop flt-open-dyn_open-query-tail  substitute(', FIRST tt-template_dis-rule     where (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 ~
and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)',  ~{&double-quote~}, v-cd)


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name X_dis-rule

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name  X_dis-rule


&scop flt-open-waitfram true

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .

&SCOPED-DEFINE used-status-code STRING(p-sts)
CASE p-mode :
  WHEN {&all}        THEN DO:
    assign
    filter-point = filter-point0 + p-mode
    filter-label = substitute("&1", filter-label0)
    .
    if v-cd <> '':U then
        ASSIGN
        frame {&frame-name}:TITLE = substitute("&1 для POS &2", v-cd).
    IF p-sts = -1  THEN DO:
      { gbl/fltopend.i
          &where-cond = " TRUE "
          &use-ind    = "  "
          &by         = "  "
          }
    END.
    ELSE DO:
&SCOPED-DEFINE used-status-code STRING(p-sts)
      if v-cd = '':U then do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("&1 &2", title0, {&used-status-int-name}).
      end.
      else do:
        ASSIGN
        frame {&frame-name}:TITLE = substitute("&1 &2 для POS &3", title0, {&used-status-int-name}, v-cd).
      end.

      { gbl/fltopend.i
          &where-cond = " X_dis-rule.sts = p-sts "
          &dyn_where-cond = " substitute('X_dis-rule.sts = &1', p-sts )"
          &use-ind    = "  "
          &by         = "  "
          }
    END.
  END.
  WHEN "upper-rule-num":U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1", filter-label0) .
    if X_upper-dis-rule.rule-num > {&max-num-dr-template} then do:
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute(" Правило скидок №&1: &2: Детализация"
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    end.
    else do:
      if v-cd = '':U then
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute(" Правила скидок типа: &1 &2"
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                  )
                                  .
      else
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute(" Правила скидок типа: &1 POS &2 &3"
                                  , X_upper-dis-rule.des
                                  , v-cd
                                  , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                  )
                                  .
    end.
    IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = " ~
          X_dis-rule.upper-rule-num  = p-upper-rule-num ~
          and ((p-time-templ-rl-root = -1) or (X_dis-rule.time-templ-rl-root = p-time-templ-rl-root))  ~
                      "
        &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1 ~
          and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', p-upper-rule-num, p-time-templ-rl-root ) "

        &use-ind    = "  "
        &by         = "  "
        }
    END.
    ELSE DO:
        { gbl/fltopend.i
        &where-cond = " ~
            X_dis-rule.upper-rule-num  = p-upper-rule-num    ~
            and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
            AND X_dis-rule.sts = p-sts "
        &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1    ~
            and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ~
            AND X_dis-rule.sts = &3 ', p-upper-rule-num, p-time-templ-rl-root, p-sts)"

        &use-ind    = "  "
        &by         = "  "
        }
    END.
  END.
  WHEN "upper-rule-num-object":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 для одного объекта", filter-label0).
      if X_upper-dis-rule.rule-num > {&max-num-dr-template}
      then
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("&1&2 Правило скидок №&3: &4: Детализация"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("&1&2 Правила скидок типа: &1 &3"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                  )
                                  .


    IF p-sts = -1 THEN DO:
      { gbl/fltopend.i
      &where-cond = " ~
        X_dis-rule.upper-rule-num  = p-upper-rule-num   ~
        AND X_dis-rule.host-code  = p-host-code   ~
        AND X_dis-rule.obj-type = p-curr-obj-type   ~
        AND X_dis-rule.obj-code = p-curr-obj-code   ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ~
                    "
      &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1   ~
        AND X_dis-rule.host-code  = &2   ~
        AND X_dis-rule.obj-type = &3&4&3   ~
        AND X_dis-rule.obj-code = &5   ~
        and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ' ~
        , p-upper-rule-num, p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root)"

      &use-ind    = "  "
      &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
        &where-cond = " ~
            X_dis-rule.upper-rule-num  = p-upper-rule-num    ~
        AND X_dis-rule.host-code  = p-host-code   ~
        AND X_dis-rule.obj-type = p-curr-obj-type   ~
        AND X_dis-rule.obj-code = p-curr-obj-code   ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
            AND X_dis-rule.sts = p-sts "
        &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1    ~
        AND X_dis-rule.host-code  = &2   ~
        AND X_dis-rule.obj-type = &3&4&3   ~
        AND X_dis-rule.obj-code = &5   ~
        and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
            AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts)"

        &use-ind    = "  "
        &by         = "  " }

    END.
  END.
  WHEN "upper-rule-num-all-obj":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 все для одного объекта", filter-label0).
      if X_upper-dis-rule.rule-num > {&max-num-dr-template}
      then
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("&1&2 Правило скидок №&3: &4: Детализация"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("&1&2 Правила скидок типа: &1 &3"
                                  , p-curr-obj-type
                                  , p-curr-obj-code
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                  )
                                  .


    IF p-sts = -1 THEN DO:
      { gbl/fltopend.i
      &where-cond = " ~
        X_dis-rule.upper-rule-num  = p-upper-rule-num   ~
        AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  ) ~
        AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U ) ~
        AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    ) ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ~
                    "
      &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1   ~
        AND X_dis-rule.host-code  = &2   ~
        AND X_dis-rule.obj-type = &3&4&3   ~
        AND X_dis-rule.obj-code = &5   ~
        and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ' ~
        , p-upper-rule-num, p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root)"

      &use-ind    = "  "
      &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
        &where-cond = " ~
            X_dis-rule.upper-rule-num  = p-upper-rule-num    ~
        AND ( X_dis-rule.host-code  = p-host-code   OR X_dis-rule.host-code  = 0  ) ~
        AND ( X_dis-rule.obj-type = p-curr-obj-type OR X_dis-rule.obj-type = '':U ) ~
        AND ( X_dis-rule.obj-code = p-curr-obj-code OR X_dis-rule.obj-code = 0    ) ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
            AND X_dis-rule.sts = p-sts "
        &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1    ~
        AND X_dis-rule.host-code  = &2   ~
        AND X_dis-rule.obj-type = &3&4&3   ~
        AND X_dis-rule.obj-code = &5   ~
        and ((&6 = -1) or (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
            AND X_dis-rule.sts = &7 ', p-upper-rule-num, p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts)"

        &use-ind    = "  "
        &by         = "  " }

    END.
  END.
  WHEN "upper-rule-num-host":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 для одной фирмы", filter-label0).
      if X_upper-dis-rule.rule-num > {&max-num-dr-template}
      then
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("Фирма &1 Правило скидок №&2: &3: Детализация"
                                  , p-host-code
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("Фирма &1 Правила скидок типа: &2 &3"
                                  , p-host-code
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                  )
                                  .


    IF p-sts = -1 THEN DO:
      { gbl/fltopend.i
      &where-cond = " ~
        X_dis-rule.upper-rule-num  = p-upper-rule-num   ~
        AND X_dis-rule.host-code  = p-host-code   ~
        AND X_dis-rule.obj-type = '':U   ~
        AND X_dis-rule.obj-code = 0   ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
                    "
      &dyn_where-cond = " substitute('X_dis-rule.upper-rule-num  = &1 ~
        AND X_dis-rule.host-code  = &2  ~
        AND X_dis-rule.obj-type = &3&3   ~
        AND X_dis-rule.obj-code = 0   ~
        and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4)) ', p-upper-rule-num, p-host-code, ~{&double-quote~}, p-time-templ-rl-root ) "

      &use-ind    = "  "
      &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
        &where-cond = " ~
            X_dis-rule.upper-rule-num  = p-upper-rule-num    ~
        AND X_dis-rule.host-code  = p-host-code   ~
        AND X_dis-rule.obj-type = '':U   ~
        AND X_dis-rule.obj-code = 0   ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
            AND X_dis-rule.sts = p-sts "
        &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1    ~
        AND X_dis-rule.host-code  = &2   ~
        AND X_dis-rule.obj-type = &3&3   ~
        AND X_dis-rule.obj-code = 0   ~
        and ((&4 = -1) or (X_dis-rule.time-templ-rl-root = &4 ))~
            AND X_dis-rule.sts = &5 ',  p-upper-rule-num , p-host-code, ~{&double-quote~}, p-time-templ-rl-root, p-sts)"

        &use-ind    = "  "
        &by         = "  " }

    END.
  END.
  WHEN "upper-rule-num-global":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 ", filter-label0).
      if X_upper-dis-rule.rule-num > {&max-num-dr-template}
      then
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("Правило скидок №&1: &2: Детализация"
                                  , X_upper-dis-rule.rule-num
                                  , X_upper-dis-rule.des
                                  )
                                  .
    else
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute("Правила скидок типа: &1 &2"
                                  , X_upper-dis-rule.des
                                  , (if p-sts = -1 then "":U else  {&used-status-int-name})
                                  )
                                  .


    IF p-sts = -1 THEN DO:
      { gbl/fltopend.i
      &where-cond = " ~
        X_dis-rule.upper-rule-num  = p-upper-rule-num   ~
        AND X_dis-rule.host-code  = 0   ~
        AND X_dis-rule.obj-type = '':U   ~
        AND X_dis-rule.obj-code = 0   ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
                    "
      &dyn_where-cond = " substitute('X_dis-rule.upper-rule-num  = &1 ~
        AND X_dis-rule.host-code  = 0   ~
        AND X_dis-rule.obj-type = &2&2   ~
        AND X_dis-rule.obj-code = 0   ~
        and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3))', p-upper-rule-num, ~{&double-quote~}, p-time-templ-rl-root )"

      &use-ind    = "  "
      &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
        &where-cond = " ~
            X_dis-rule.upper-rule-num  = p-upper-rule-num    ~
        AND X_dis-rule.host-code  = 0   ~
        AND X_dis-rule.obj-type = '':U   ~
        AND X_dis-rule.obj-code = 0   ~
        and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
            AND X_dis-rule.sts = p-sts "
        &dyn_where-cond = " substitute('X_dis-rule.upper-rule-num  = &1 ~
        AND X_dis-rule.host-code  = 0   ~
        AND X_dis-rule.obj-type = &2&2   ~
        AND X_dis-rule.obj-code = 0   ~
        and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3)) ~
            AND X_dis-rule.sts = &4 ', p-upper-rule-num, ~{&double-quote~}, p-time-templ-rl-root, p-sts )"

        &use-ind    = "  "
        &by         = "  " }

    END.
  END.
  WHEN "upper-rule-num-gds-obj":U THEN DO:
        filter-point = filter-point0 + p-mode.
        filter-label = substitute("&1 товарные", filter-label0).
        ASSIGN
        frame {&frame-name}:TITLE =
                                    substitute("&1&2 Правила скидок к товару &3 &4: для бар-кода &5"
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , X_goods.gds-code
                                    , string(X_goods.gds-name, "X(20)")
                                    , p-b-code
                                    )
                                    .
        { gbl/fltopend.i
        &where-cond = " ~
          X_dis-rule.upper-rule-num  = p-upper-rule-num   ~
          AND X_dis-rule.host-code  = p-host-code   ~
          AND X_dis-rule.obj-type = p-curr-obj-type   ~
          AND X_dis-rule.obj-code = p-curr-obj-code   ~
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
          and (p-sts = -1 or X_dis-rule.sts = p-sts) ~
                      "
        &dyn_where-cond = " substitute(' X_dis-rule.upper-rule-num  = &1   ~
          AND X_dis-rule.host-code  = &2   ~
          AND X_dis-rule.obj-type = &3&4&3  ~
          AND X_dis-rule.obj-code = &5   ~
          and (&6 = -1 or X_dis-rule.time-templ-rl-root = &6  or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
          and ((&7 = -1) or (X_dis-rule.sts = &7)) ', p-upper-rule-num, p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, p-sts)"

        &use-ind    = "  "
        &by         = "  " }
  END.
  WHEN "time-rule-num":U THEN DO:
      filter-point = filter-point0 + p-mode.
      filter-label = substitute("&1 с опред. расписанием", filter-label0).
      ASSIGN
      frame {&frame-name}:TITLE =
                                  substitute(" Правила скидок с расписанием &1: &2"
                                  , X_dis-time-rule.time-rule-num
                                  , X_dis-time-rule.des
                                  )
                                  .
    IF p-sts = -1 THEN DO:
      { gbl/fltopend.i
      &where-cond = " ~
        X_dis-rule.time-rule-num  = p-time-templ-rl-root   ~
                    "
      &dyn_where-cond = " substitute(' X_dis-rule.time-rule-num  = &1', p-time-templ-rl-root )"

      &use-ind    = "  "
      &by         = "  " }
    END.
    ELSE DO:
        { gbl/fltopend.i
        &where-cond = " ~
            X_dis-rule.time-rule-num  = p-upper-rule-num    ~
            AND X_dis-rule.sts = p-sts "
        &dyn_where-cond = " substitute(' X_dis-rule.time-rule-num  = &1    ~
            AND X_dis-rule.sts = &2 ', p-upper-rule-num, p-sts) "

        &use-ind    = "  "
        &by         = "  " }
    END.
  END.
WHEN {&g___object} THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1 действующие на объекте", filter-label0).
    ASSIGN
    frame {&frame-name}:TITLE = title0 +
                                substitute(" действующие на объекте: &1&2"
                                , p-curr-obj-type
                                , p-curr-obj-code
                                )
                                .

    { gbl/fltopend.i
    &where-cond = " X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer(~{&used-status-int~}) ~
    AND (X_dis-rule.host-code = 0 ~
    or (X_dis-rule.host-code = p-host-code ~
      and X_dis-rule.obj-type = '':U ~
      AND X_dis-rule.obj-code = 0) ~
    or (X_dis-rule.host-code = p-host-code ~
      and X_dis-rule.obj-type = p-curr-obj-type ~
      AND X_dis-rule.obj-code = p-curr-obj-code)) ~
     and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
                  "
    &dyn_where-cond = " substitute('X_dis-rule.upper-rule-num > 0 and X_dis-rule.sts = integer(&2&6&2) ~
    AND (X_dis-rule.host-code = 0 ~
    or (X_dis-rule.host-code = &1 ~
      and X_dis-rule.obj-type = &2&2 ~
      AND X_dis-rule.obj-code = 0) ~
    or (X_dis-rule.host-code = &1 ~
      and X_dis-rule.obj-type = &2&3&2 ~
      AND X_dis-rule.obj-code = &4)) ~
     and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) ' ~
     , p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, ~{&used-status-int~})"

    &use-ind    = "  "
    &by         = "  " }
END.
WHEN "template":U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1 - ШАБЛОНЫ", filter-label0).
    ASSIGN
    frame {&frame-name}:TITLE =  substitute(" Типы правил (Шаблоны) скидок &1"
                                            ,(if p-sts = -1 then "":U else  {&used-status-int-name})
                                            )
                                            .
  IF p-sts = -1 THEN DO:
    { gbl/fltopend.i
    &where-cond = " ~
      X_dis-rule.rule-num  <= ~{&num-dr-templates~}    ~
      and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
                  "
    &dyn_where-cond = " substitute('X_dis-rule.rule-num  <= &1  ~
      and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) ', ~{&num-dr-templates~}, p-time-templ-rl-root)"

    &use-ind    = " "
    &by         = "  " }
  END.
  ELSE DO:
      { gbl/fltopend.i
      &where-cond = " ~
          X_dis-rule.rule-num  <= ~{&num-dr-templates~}    ~
          AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root ) ~
                    "
      &dyn_where-cond = " substitute('  X_dis-rule.rule-num  <= &1   ~
          AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) ', ~{&num-dr-templates~},  p-sts, p-time-templ-rl-root) "

      &use-ind    = "  "
      &by         = " by X_dis-rule.rule-num  " }

  END.
END.
WHEN "template-value-type":U THEN DO:
    filter-point = filter-point0 + p-mode.
    filter-label = substitute("&1 - ШАБЛОНЫ (опред тип значения скидки)", filter-label0).
    ASSIGN
    frame {&frame-name}:TITLE =  substitute(" Типы правил (Шаблоны) скидок &1:"
                                            ,(if p-sts = -1 then "":U else  {&used-status-int-name})).
    DO V-jj = 1 TO num-entries(p-value-type):
&scop discnt-v-code ENTRY(V-jj, p-value-type)
       frame {&frame-name}:TITLE = frame {&frame-name}:TITLE + {&space-char} + {&discnt-v-name}.
    end.
  IF p-sts = -1 THEN DO:
    { gbl/fltopend.i
    &where-cond = " ~
      X_dis-rule.rule-num  <= ~{&num-dr-templates~}    ~
      and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
      and lookup(string(X_dis-rule.value-type), p-value-type) > 0 ~
                  "
    &dyn_where-cond = " substitute('X_dis-rule.rule-num  <= &1  ~
      and ((&2 = -1) or (X_dis-rule.time-templ-rl-root = &2)) and lookup(string(X_dis-rule.value-type), &3) > 0', ~{&num-dr-templates~}, p-time-templ-rl-root, p-value-type)"

    &use-ind    = " "
    &by         = "  " }
  END.
  ELSE DO:
      { gbl/fltopend.i
      &where-cond = " ~
          X_dis-rule.rule-num  <= ~{&num-dr-templates~}    ~
          AND X_dis-rule.sts = p-sts
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root ) ~
           and lookup(string(X_dis-rule.value-type), p-value-type) > 0 ~
                    "
      &dyn_where-cond = " substitute('  X_dis-rule.rule-num  <= &1   ~
          AND X_dis-rule.sts = &2
          and ((&3 = -1) or (X_dis-rule.time-templ-rl-root = &3 )) and LOOKUP(STRING(X_dis-rule.value-type), &4) > 0 ', ~{&num-dr-templates~},  p-sts, p-time-templ-rl-root, p-value-type) "

      &use-ind    = "  "
      &by         = " by X_dis-rule.rule-num  " }

  END.
END.

WHEN {&table_dis-gds-rule}
OR
WHEN "cd-obj":U
OR
WHEN {&table_dis-dc-rule}
OR
WHEN {&table_dis-dct-rule}
OR
WHEN {&table_dis-cp-rule}
OR
WHEN {&table_dis-grp-rule}
THEN DO:
  filter-point = filter-point0 + p-mode.
  filter-label = substitute("&1 по объекту приложения скидки", filter-label0).
&scoped-define dis-gds-rule-code v-discnt-role
  IF p-mode = {&table_dis-gds-rule}  THEN
  ASSIGN
  frame {&frame-name}:TITLE =
                              substitute("&1&2 Правила скидок, действующие для товара на объекте &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , {&dis-gds-rule-name}
                              )
                              .
  if p-mode = "cd-obj" then
  ASSIGN
  frame {&frame-name}:TITLE =
                              substitute("&1&2 Правила скидок, применимые к кассе &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , v-cd
                                )
                              .
&scoped-define dis-dc-rule-code v-discnt-role
  if p-mode = {&table_dis-dc-rule} then
  ASSIGN
  frame {&frame-name}:TITLE =
                              substitute("&1&2 Правила скидок для карт"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , {&dis-dc-rule-name}
                              )
                              .
&scoped-define dis-dct-rule-code v-discnt-role
  if p-mode = {&table_dis-dct-rule} then
  ASSIGN
  frame {&frame-name}:TITLE =
                              substitute("&1&2 Правила скидок для типов ДК &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code) )
                              , {&dis-dct-rule-name}
                              )
                              .
&scoped-define dis-cp-rule-code v-discnt-role
  if p-mode = {&table_dis-cp-rule} then
  ASSIGN
  frame {&frame-name}:TITLE =
                              substitute("&1&2 Правила скидок для платежей &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , {&dis-cp-rule-name}
                              )
                              .
&scoped-define dis-ggr-rule-code v-discnt-role
  if p-mode = {&table_dis-grp-rule} then
  ASSIGN
  frame {&frame-name}:TITLE =
                              substitute("&1&2 Правила скидок для групп &3"
                              , (if p-curr-obj-type = '':U then "" else p-curr-obj-type)
                              , (if p-curr-obj-type = '':U then "" else string(p-curr-obj-code))
                              , {&dis-ggr-rule-name}
                              )
                              .


    &scop flt-open-open-query-tail , FIRST tt-template_dis-rule NO-LOCK WHERE tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root
  case v-region:
    when '' then do:
      IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = " ~
              ((X_dis-rule.host-code  = p-host-code   ~
          AND X_dis-rule.obj-type = p-curr-obj-type   ~
          AND X_dis-rule.obj-code = p-curr-obj-code)   ~
          or (X_dis-rule.host-code  = p-host-code   ~
          AND X_dis-rule.obj-type = '':U   ~
          AND X_dis-rule.obj-code = 0)   ~
          or (X_dis-rule.host-code  = 0))   ~
          AND X_dis-rule.upper-rule-num < {&max-num-dr-template} ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
                      "
        &dyn_where-cond = " substitute('((X_dis-rule.host-code  = &1   ~
          AND X_dis-rule.obj-type = &2&3&2   ~
          AND X_dis-rule.obj-code = &4)   ~
          or (X_dis-rule.host-code  = &1   ~
          AND X_dis-rule.obj-type = &2&2   ~
          AND X_dis-rule.obj-code = 0)   ~
          or (X_dis-rule.host-code  = 0))   ~
          AND X_dis-rule.upper-rule-num < &6 ~
          AND X_dis-rule.rule-num > &6 ~
          and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ', ~
          p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, ~{&max-num-dr-template~})"

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " ~
              ((X_dis-rule.host-code  = p-host-code   ~
                AND X_dis-rule.obj-type = p-curr-obj-type   ~
                AND X_dis-rule.obj-code = p-curr-obj-code)   ~
          or (X_dis-rule.host-code  = p-host-code   ~
                AND X_dis-rule.obj-type = '':U   ~
                AND X_dis-rule.obj-code = 0)   ~
          or (X_dis-rule.host-code  = 0))   ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
              AND X_dis-rule.sts = p-sts ~
              and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ~
                        "
          &dyn_where-cond = " substitute('((X_dis-rule.host-code  = &1   ~
                AND X_dis-rule.obj-type = &2&3&2   ~
                AND X_dis-rule.obj-code = &4)   ~
          or (X_dis-rule.host-code  = &1   ~
                AND X_dis-rule.obj-type = &2&2   ~
                AND X_dis-rule.obj-code = 0)   ~
          or (X_dis-rule.host-code  = 0))   ~
          AND X_dis-rule.rule-num > &7 ~
              AND X_dis-rule.sts = &5 ~
              and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ' ~
              , p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, ~{&max-num-dr-template~}) "

          &use-ind    = "  "
          &by         = "  " }

      END.
    end. /*""*/
    when "global" then do:
      IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = " ~
              X_dis-rule.host-code  = 0   ~
          AND X_dis-rule.obj-type = ''   ~
          AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.upper-rule-num < {&max-num-dr-template} ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
                      "
        &dyn_where-cond = " substitute('X_dis-rule.host-code  = 0   ~
          AND X_dis-rule.obj-type = &2&2   ~
          AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.upper-rule-num < &6 ~
          AND X_dis-rule.rule-num > &6 ~
          and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ', ~
          p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, ~{&max-num-dr-template~})"

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " ~
              X_dis-rule.host-code  = 0   ~
                AND X_dis-rule.obj-type = ''   ~
                AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
              AND X_dis-rule.sts = p-sts ~
              and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ~
                        "
          &dyn_where-cond = " substitute('X_dis-rule.host-code  = 0   ~
                AND X_dis-rule.obj-type = &2&2   ~
                AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.rule-num > &7 ~
              AND X_dis-rule.sts = &5 ~
              and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ' ~
              , p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, ~{&max-num-dr-template~}) "

          &use-ind    = "  "
          &by         = "  " }

      END.
    end. /*when "GLOBAL*/
    when "host" then do:
      IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = " ~
              X_dis-rule.host-code  = p-host-code   ~
          AND X_dis-rule.obj-type = ''   ~
          AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.upper-rule-num < {&max-num-dr-template} ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
                      "
        &dyn_where-cond = " substitute('X_dis-rule.host-code  = &1   ~
          AND X_dis-rule.obj-type = &2&2   ~
          AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.upper-rule-num < &6 ~
          AND X_dis-rule.rule-num > &6 ~
          and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ', ~
          p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, ~{&max-num-dr-template~})"

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " ~
              X_dis-rule.host-code  = p-host-code   ~
                AND X_dis-rule.obj-type = ''   ~
                AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
              AND X_dis-rule.sts = p-sts ~
              and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ~
                        "
          &dyn_where-cond = " substitute('X_dis-rule.host-code  = &1   ~
                AND X_dis-rule.obj-type = &2&2   ~
                AND X_dis-rule.obj-code = 0   ~
          AND X_dis-rule.rule-num > &7 ~
              AND X_dis-rule.sts = &5 ~
              and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ' ~
              , p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, ~{&max-num-dr-template~}) "

          &use-ind    = "  "
          &by         = "  " }
      END.
    end. /*"host"*/
    when "object" then do:
      IF p-sts = -1 THEN DO:
        { gbl/fltopend.i
        &where-cond = " ~
              X_dis-rule.host-code  = p-host-code   ~
          AND X_dis-rule.obj-type = p-curr-obj-type   ~
          AND X_dis-rule.upper-rule-num < {&max-num-dr-template} ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no)) ~
                      "
        &dyn_where-cond = " substitute('X_dis-rule.host-code  = &1   ~
          AND X_dis-rule.obj-type = &2&3&2   ~
          AND X_dis-rule.obj-code = &4   ~
          AND X_dis-rule.upper-rule-num < &6 ~
          AND X_dis-rule.rule-num > &6 ~
          and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ', ~
          p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, ~{&max-num-dr-template~})"

        &use-ind    = "  "
        &by         = "  " }
      END.
      ELSE DO:
          { gbl/fltopend.i
          &where-cond = " ~
              X_dis-rule.host-code  = p-host-code   ~
                AND X_dis-rule.obj-type = p-curr-obj-type   ~
                AND X_dis-rule.obj-code = p-curr-obj-code   ~
          AND X_dis-rule.rule-num > {&max-num-dr-template} ~
              AND X_dis-rule.sts = p-sts ~
              and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ~
                        "
          &dyn_where-cond = " substitute('X_dis-rule.host-code  = &1   ~
                AND X_dis-rule.obj-type = &2&3&2   ~
                AND X_dis-rule.obj-code = &4   ~
          AND X_dis-rule.rule-num > &7 ~
              AND X_dis-rule.sts = &5 ~
              and ((&6 = -1) or  (X_dis-rule.time-templ-rl-root = &6) or (X_dis-rule.time-templ-rl-root = 0 and X_dis-rule.is-term = no) ) ' ~
              , p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-sts, p-time-templ-rl-root, ~{&max-num-dr-template~}) "

          &use-ind    = "  "
          &by         = "  " }

      END.
    end.
  end case.
END.
WHEN "dis-gds-rule-gds-obj":U THEN DO:

        filter-point = filter-point0 + p-mode.
        filter-label = substitute("&1 для товаров на определ. объекте", filter-label0).
        ASSIGN
        frame {&frame-name}:TITLE =
                                    substitute("&1&2 Правила скидок для тов. на объекте товар &3 &4: для бар-кода &5"
                                    , p-curr-obj-type
                                    , p-curr-obj-code
                                    , X_goods.gds-code
                                    , string(X_goods.gds-name, "X(20)")
                                    , p-b-code
                                    )
                                    .
    &scop flt-open-open-query-tail , FIRST tt-template_dis-rule NO-LOCK WHERE (v-cd = '':U) or (tt-template_dis-rule.pos-type = v-cd and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)

    &scop flt-open-dyn_open-query-tail substitute(', FIRST tt-template_dis-rule     NO-LOCK WHERE (&1&2&1 = &1&1) or (tt-template_dis-rule.pos-type = &1&2&1 and tt-template_dis-rule.templ-rl-root = X_dis-rule.templ-rl-root)' ~
                                       , ~{&double-quote~}, v-cd)

        { gbl/fltopend.i
        &where-cond = " ~
              X_dis-rule.host-code  = p-host-code   ~
          AND X_dis-rule.obj-type = p-curr-obj-type   ~
          AND X_dis-rule.obj-code = p-curr-obj-code   ~
          AND X_dis-rule.upper-rule-num < {&max-num-dr-template} ~
          and (p-time-templ-rl-root = -1 or X_dis-rule.time-templ-rl-root = p-time-templ-rl-root) ~
                      "
        &dyn_where-cond = " substitute(' X_dis-rule.host-code  = &1  ~
          AND X_dis-rule.obj-type = &2&3&2   ~
          AND X_dis-rule.obj-code = &4   ~
          AND X_dis-rule.upper-rule-num < &6 ~
          and ((&5 = -1) or (X_dis-rule.time-templ-rl-root = &5)) ' ~
          , p-host-code, ~{&double-quote~}, p-curr-obj-type, p-curr-obj-code, p-time-templ-rl-root, ~{&max-num-dr-template~} ) "

        &use-ind    = "  "
        &by         = "  " }
  END.
END CASE.

if not p-open-query then
REPOSITION br-dis-rule to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-dis-rule:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

if error-status:error then do:
  REPOSITION br-dis-rule to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-dis-rule in frame {&frame-name}.
APPLY "ENTRY" TO br-dis-rule.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBrgds-obj Dialog-Frame
PROCEDURE OpenBrgds-obj :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if available X_dis-rule and X_dis-rule.templ-rl-root = 34 then do:
  hide
  br-gds-obj
  in frame {&frame-name} .
end.
else do:
  display
  br-gds-obj WHEN (p-mode = "upper-rule-num-gds-obj" or p-mode = "dis-gds-rule-gds-obj")
  with frame {&frame-name} .
  RUN fill-tables-gds-obj IN THIS-PROCEDURE NO-ERROR.
  OPEN QUERY br-gds-obj FOR EACH tt-dis-rule-bc NO-LOCK.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE INPUT parameter p-add-mode AS CHARACTER NO-UNDO.
define variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-rule-num like ub.dis-rule.rule-num no-undo .
define variable  v-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display as logical   no-undo . /* виден в броусе статус 0*/
define variable v-tree            as character no-undo .
define variable  v-other          as character no-undo . /* еще чего - нибудь */
define variable v-obj-type like ub.dis-rule.obj-type no-undo .
define variable v-obj-code like ub.dis-rule.obj-code no-undo .
define variable v-attr-codes as character no-undo .
define variable v-attr-labels as character no-undo .
define variable v-presel-codes as character no-undo .
define variable v-sel-codes as character no-undo .
define variable v-upper-rule-num as integer   no-undo .
define buffer buf_tt-template_dis-rule for tt0-template_dis-rule .
define buffer buf_dis-rule for ub.dis-rule.
define buffer root_dis-rule for ub.dis-rule.
IF p-add-mode = {&add-copy}
AND NOT AVAILABLE X_dis-rule THEN RETURN ERROR.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}
if not loc#log then return no-apply.
if not ( p-curr-obj-type = '':U
        and
        p-curr-obj-code = 0) then do:
  if p-curr-obj-type = {&cmp} then do:
    assign
    v-host-code = p-curr-obj-code
    v-obj-type = v-cntxt-obj-type
    v-obj-code = v-cntxt-obj-code
    .
  end.
  else do:
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
end.
end.
else do:
  if p-host-code > 0 then v-host-code = p-host-code.
end.
IF p-add-mode = {&add-def} THEN DO:
  if p-upper-rule-num = 0 then do:
    for each buf_tt-template_dis-rule no-lock,
          first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = buf_tt-template_dis-rule.templ-rl-root
            and buf_dis-rule.sts = integer({&used-status-int}):
      assign
      v-attr-codes   =  v-attr-codes +  {&delim-par} + string(buf_tt-template_dis-rule.templ-rl-root)
      v-attr-labels  =  v-attr-labels +  {&delim-par} + buf_dis-rule.des
      .
    end.
    assign
    v-attr-codes = trim (v-attr-codes, {&delim-par})
    v-attr-labels = trim (v-attr-labels, {&delim-par})
    .
    run gbl/d-list.w (
                      input "b-sel":U
                      ,input "Выберите тип правила"
                      ,input v-attr-codes
                      ,input v-attr-labels
                      ,input {&delim-par}
                      ,input v-presel-codes
                      ,output v-sel-codes).
    if v-sel-codes = "":U then return no-apply.

    assign
    v-upper-rule-num = integer(v-sel-codes)
    .
  end.
  else do:
    ASSIGN
    v-upper-rule-num = p-upper-rule-num
    .
  end.
  find first root_dis-rule where
          root_dis-rule.rule-num = v-upper-rule-num.
  do while root_dis-rule.upper-rule-num <> 0:
    assign
    v-upper-rule-num = root_dis-rule.upper-rule-num
    .
    find first root_dis-rule where
          root_dis-rule.rule-num = v-upper-rule-num .
  end.
  assign
  v-templ-rl-root = v-upper-rule-num
  .
end. /*IF p-add-mode = {&add-def} THEN DO:*/
IF p-add-mode = {&add-copy} THEN DO:
  ASSIGN
  v-templ-rl-root = X_dis-rule.templ-rl-root
  loc-doc-rec = RECID(X_dis-rule)
  .
END.
run dr-code  in this-procedure (
                                input  v-templ-rl-root
                                ,output v-des
                                ,output v-discnt-type
                                ,output v-subject-type
                                ,output v-value-type
                                ,output v-level-1
                                ,output v-level-2
                                ,OUTPUT v-global
                                ,OUTPUT v-host
                                ,OUTPUT v-object
                                ,output v-output-display
                                ,output v-tree
                                ,output v-other
                                                          )  .

IF add-option = "":U  THEN DO:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
  if error-status:error or add-option = "":U then return no-apply.

END.
CASE add-option:
  when "global":U then do:
    if v-global > 0 then do:
      if v-cntxt-db-num = 0  THEN DO:
       assign
      v-host-code = 0
      v-obj-type = "":U
      v-obj-code = 0
      .
      END.
      else do:
        assign
        add-option = "":U.
        message
        "Невозможно добавить правило скидки такого типа в УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  when "host":U then do:
    if v-host > 0 then do:
      if v-cntxt-db-num = 0  then
      assign
      v-obj-type = "":U
      v-obj-code = 0
      .
      else do:
        assign
        add-option = "":U.
        message
        "Невозможно добавить правило скидки такого типа в УБД"
        view-as alert-box error .
        return no-apply.
      end.
    end.
  end.
  when "object":U then do:
    if v-object > 0 then do:
      assign
      v-obj-type = p-curr-obj-type
      v-obj-code = p-curr-obj-code
      .
    end.
  end.
END CASE.
assign
add-option = "":U.
define variable v-form-name as character no-undo init "ref/dis-ruli.w".
run disrules-get-interface-form in this-procedure ( input v-templ-rl-root
                                                   ,output v-form-name) .
run value(v-form-name) (
                    input parParentProc
                    ,input p-add-mode
                    ,input v-templ-rl-root
                    ,input v-host-code
                    ,input v-obj-type
                    ,input v-obj-code
                    ,input (IF p-add-mode = {&add-def} THEN 0 ELSE X_dis-rule.rule-num) /*p-rule-num*/
                    ,input p-upper-rule-num
                    ,input (if p-mode = "upper-rule-num-gds-obj":U
                          or p-mode ="dis-gds-rule-gds-obj"
                          then p-b-code else 0)
                    ,input 0
                    ,input v-cd
                    ,input-output loc-doc-rec
                                ) no-error.

if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
  reposition br-dis-rule to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-dis-rule in frame {&frame-name}.
apply "value-changed" to br-dis-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
if not available X_dis-rule then return no-apply.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}

if not loc#log then return no-apply.
if (X_dis-rule.host-code = 0
    or X_dis-rule.obj-code = 0)
and v-cntxt-db-num <> 0 then do:
  message
  "Невозможно редактировать данное правило скидки в УБД"
  view-as alert-box error .
  return no-apply.
end.
assign
loc-doc-rec = recid(X_dis-rule)
.
define variable v-form-name as character no-undo init "ref/dis-ruli.w".
run disrules-get-interface-form in this-procedure ( input X_dis-rule.templ-rl-root
                                                   ,output v-form-name) .

run value(v-form-name) (
                      input parParentProc
                      ,input {&update}
                      ,input X_dis-rule.templ-rl-root
                      ,input X_dis-rule.host-code
                      ,input X_dis-rule.obj-type
                      ,input X_dis-rule.obj-code
                      ,input X_dis-rule.rule-num /*p-rule-num*/
                      ,input X_dis-rule.upper-rule-num
                      ,input (if p-mode = "upper-rule-num-gds-obj":U
                              or p-mode = "dis-gds-rule-gds-obj"
                              then p-b-code else 0)
                      ,input X_dis-rule.time-templ-rl-root
                      ,input '':U
                      ,input-output loc-doc-rec
                                  ) no-error.
if loc-doc-rec <> ? then do:
  RUn OpenBR in this-procedure ( input YES, input NO, input '':U).
  reposition br-dis-rule to recid loc-doc-rec no-error.
  {&cant-positioning}
end.
apply "entry" to br-dis-rule in frame {&frame-name}.
apply "value-changed" to br-dis-rule in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-del Dialog-Frame
PROCEDURE proc-b-del :
define variable loc#log as logical no-undo.
define variable v-sts like ub.dis-rule.sts no-undo .
DEFINE VARIABLE loc-doc-rec AS RECID NO-UNDO.
define buffer loc_dis-rule for ub.dis-rule.
if not available X_dis-rule then return error.
do
on error undo, return error
on stop undo, return error
:
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_discount_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
loc#log
}


if not loc#log then return error.
  if (X_dis-rule.host-code = 0
      or X_dis-rule.obj-code = 0)
  and v-cntxt-db-num <> 0 then do:
    message
    "Невозможно удалять данное правило скидки в УБД"
    view-as alert-box error .
    return no-apply.
  end.
  loc#log = no.
  message
  "Вы действительно хотите удалить это правило скидки?"
  view-as alert-box question buttons YES-NO update loc#log.
  if not loc#log then undo, return error .

  assign
  loc-doc-rec = RECID(X_dis-rule)
  .
  find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = loc-doc-rec no-error .
  if not available loc_dis-rule then do:
    message
    "Запись уже отсутствует или недоступна"
    view-as alert-box warning.
    return.
  end.
  run ref/disrul30.p (
                    buffer loc_dis-rule
                  ) no-error.
  if error-status:error then do:
    message
    "Ошибка при удалении ПРАВИЛА СКИДКИ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
  end.
  RUN OpenBr in this-procedure ( input YES, input NO, input '':U).
  REPOSITION br-dis-rule to row 1 No-error.
  {&cant-positioning}
  if available X_dis-rule then do:
    loc#log = br-dis-rule:select-focused-row( ) IN FRAME {&FRAME-NAME}.
  end.
  apply "ENTRY" to br-dis-rule.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-dis-rules Dialog-Frame
PROCEDURE proc-b-dis-rules :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-sts as integer no-undo init -1.

  IF NOT AVAILABLE X_dis-rule THEN RETURN no-apply.
  IF X_dis-rule.sts = INTEGER({&non-used-status-int}) THEN RETURN NO-APPLY.
  if X_dis-rule.uniq-field <> "":U
  and X_dis-rule.rule-num > {&max-num-dr-template}
  then do:
    v-sts = -1. /*integer({&non-root-status-int})*/
  end.
  else do:
    v-sts = integer({&current-status-int}).
  end.

  run ref/dis-ruls.w (
                       input parParentProc
                      ,input  p-host-code
                      ,input  p-curr-obj-type
                      ,input  p-curr-obj-code
                      ,input  "b-add":U
                      ,input  "upper-rule-num":U
                      ,input   X_dis-rule.rule-num
                      ,input p-time-templ-rl-root
                      ,input 0
                      ,input-output v-sts
                      ,input-output v-rid-list ) no-error .
  APPLY "ENTRY" TO br-dis-rule IN FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-history Dialog-Frame
PROCEDURE proc-b-history :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable loc-doc-rec as recid no-undo .
define variable v-rid-list as character no-undo.
  if NOT available X_dis-rule then return no-apply.
  loc-doc-rec = recid (X_dis-rule).
  run ref/discruls.w (
                      INPUT parParentProc
                      ,input "":U /*bttns*/
                      ,input (if X_dis-rule.uniq-field = "":U then "one":U else "rl-root":U) /*p-mode*/
                      ,input X_dis-rule.rule-num
                      ,input X_dis-rule.upper-rule-num
                      ,input "":U /*p-obj-type*/
                      ,input 0 /*p-obj-code*/
                      ,input-output v-rid-list ).

  reposition br-dis-rule to recid loc-doc-rec no-error.
  apply "entry" to br-dis-rule in frame {&frame-name}.
  apply "value-changed" to br-dis-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-lookup Dialog-Frame
PROCEDURE proc-b-lookup :
DEFINE INPUT PARAMETER p-option AS CHARACTER NO-UNDO.
DEFINE variable loc#log as logical no-undo.
define variable loc-doc-rec as recid no-undo .
define variable v-mode as character no-undo .
define variable v-rid-list as character no-undo .
define variable v-table-name as character no-undo .
define variable v-table-name-list as character no-undo .
define variable v-table-labels as character no-undo .
define variable v-classif-type as character no-undo .
define variable v-link-prop as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
if not available X_dis-rule then return error.
CASE p-option:
  WHEN "rule" THEN DO:
    { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_discount_work':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    true
    loc#log
    }
    if not loc#log then return no-apply.
    ASSIGN
    loc-doc-rec = recid(X_dis-rule)
    .
    define variable v-form-name as character no-undo init "ref/dis-ruli.w".
    run disrules-get-interface-form in this-procedure ( input X_dis-rule.templ-rl-root
                                                      ,output v-form-name) .

    run value(v-form-name) (
                             input parParentProc
                            ,input {&lookup}
                            ,input X_dis-rule.templ-rl-root
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input X_dis-rule.rule-num /*p-rule-num*/
                            ,input X_dis-rule.upper-rule-num
                            ,input (if p-mode = "upper-rule-num-gds-obj":U
                                    or p-mode = "dis-gds-rule-gds-obj"
                                    then p-b-code
                                    else 0)
                            ,input X_dis-rule.time-templ-rl-root
                            ,input '':U /*p-pos-type*/
                            ,input-output loc-doc-rec
                                        ) no-error .

  END.
  WHEN "subject" THEN DO:
/*{&all}
"upper-rule-num"                      1
"template"                            1
{&g___object}                         1
"time-rule-num"
upper-rule-num-object
upper-rule-num-all-obj
"upper-rule-num-gds-obj
{&table_dis-gds-rule}
dis-gds-rule-gds-obj
cd-obj
{&table_dis-dc-rule}
{&table_dis-cp-rule}
{&table_dis-dct-rule}
{&table_dis-dct-rule}
*/

&scop dis-cfg-rule-table-code buf_Dis-cfg-rule.table-name
   for each buf_dis-cfg-rule no-lock where
             buf_Dis-cfg-rule.templ-rl-root = X_dis-rule.templ-rl-root
         and buf_Dis-cfg-rule.table-name > '':U
    break
    by buf_dis-cfg-rule.table-name
    /*
    by buf_dis-cfg-rule.pos-type
    by buf_dis-cfg-rule.templ-rl-root
    by buf_dis-cfg-rule.time-templ-rl-root
    */
    by buf_dis-cfg-rule.self-nonunique
    :
      if first-of(buf_dis-cfg-rule.self-nonunique)
      then do:
&scop dis-grp-classif-code buf_dis-cfg-rule.self-nonunique
&scop dr-link-code string(buf_dis-cfg-rule.link-prop)
        assign
        v-table-name-list = v-table-name-list + {&delim-par} +
                           buf_Dis-cfg-rule.table-name  + ":" +
                           buf_dis-cfg-rule.self-nonunique + ":" +
                           string(buf_dis-cfg-rule.link-prop)
        v-table-labels = v-table-labels + {&delim-par} + {&dis-cfg-rule-table-name} +  ":" +
                         {&dis-grp-classif-name} + {&space-char} +
                         {&dr-link-name}
        .
      end.
    end.
    assign
    v-table-name-list = trim(v-table-name-list, {&delim-par} )
    v-table-labels = trim(v-table-labels, {&delim-par} )
    .
    if num-entries(v-table-name-list, {&delim-par}) > 1 then  do:
      run gbl/d-list.w (
                    INPUT "b-sel":U
                    ,INPUT "Выберите тип объекта приложения/условия правила"
                    ,INPUT v-table-name-list
                    ,INPUT v-table-labels
                    ,INPUT {&delim-par}
                    ,INPUT "":U
                    ,output v-table-name) no-error .
      if v-table-name = '':U then do:
        undo, return error .
      end.
      assign
      v-classif-type = entry(2, v-table-name, ":")
      v-link-prop = entry(3, v-table-name, ":")
      v-table-name = entry(1, v-table-name, ":")
      .
    end.
    else do:
      assign
      v-table-name = entry(1, v-table-name-list, ":")
      v-classif-type = entry(2, v-table-name-list, ":")
      v-link-prop = entry(3, v-table-name-list, ":")
      .
    end.
    case v-table-name:
      when {&table_dis-gds-rule} then do:
        if p-mode = "upper-rule-num-gds-obj"
        or p-mode = {&table_dis-gds-rule}
        or p-mode = "dis-gds-rule-gds-obj" then do:
           message
           "Просмотр объектов приложения скидок в данном режиме недоступен"
           view-as alert-box error .
           return error.
        end.
        if X_dis-rule.rule-num <  {&max-num-dr-template}  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = {&g___object} then do:
             v-mode = ({&g___Object} + {&comma-char} + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ({&g___Object} + {&comma-char} + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = {&dr-appl-object} then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.

        /*список возможных list-mode
        ({&all}
        "pos"
        "templ-rl-root"
        "discnt-role"
        {&g___object}
        ({&g___Object} + {&comma-char} + "pos-type":U)
        ({&g___Object} + {&comma-char} + "templ-rl-root":U)
        ({&g___Object} + {&comma-char} + "discnt-role":U)
        "rule-num":U
        "rl-root":U
        ) , {&delim-par})

        */
        run ref/dis-gdss.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT v-mode  /*p-list-mode */
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when {&table_dis-dc-rule} then do:
        if X_dis-rule.rule-num <  {&max-num-dr-template}  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = {&g___object} then do:
             v-mode = ({&g___Object} + {&comma-char} + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ({&g___Object} + {&comma-char} + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = {&dr-appl-object} then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        /*список возможных list-mode
        ({&all}
        "pos"
        "templ-rl-root"
        "discnt-role"
        {&g___object}
        ({&g___Object} + {&comma-char} + "pos-type":U)
        ({&g___Object} + {&comma-char} + "templ-rl-root":U)
        ({&g___Object} + {&comma-char} + "discnt-role":U)
        "rule-num":U) , {&delim-par})
        "rl-root":U
        */
        run ref/dis-dcs.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT v-mode  /*p-list-mode */
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when {&table_dis-dct-rule} then do:
        if X_dis-rule.rule-num <  {&max-num-dr-template}  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = {&g___object} then do:
             v-mode = ({&g___Object} + {&comma-char} + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ({&g___Object} + {&comma-char} + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = {&dr-appl-object} then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        /*список возможных list-mode
        ({&all}
        "pos"
        "templ-rl-root"
        "discnt-role"
        {&g___object}
        ({&g___Object} + {&comma-char} + "pos-type":U)
        ({&g___Object} + {&comma-char} + "templ-rl-root":U)
        ({&g___Object} + {&comma-char} + "discnt-role":U)
        "rule-num":U) , {&delim-par})
        "rl-root":U
        */
        run ref/dis-dcts.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT v-mode  /*p-list-mode */
                            ,input 0 /*p-emitent-host-code*/
                            ,input '':U /*p-type*/
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when {&table_dis-cp-rule} then do:
        if X_dis-rule.rule-num <  {&max-num-dr-template}  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = {&g___object} then do:
             v-mode = ({&g___Object} + {&comma-char} + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ({&g___Object} + {&comma-char} + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = {&dr-appl-object} then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        /*список возможных list-mode
        ({&all}
        "pos"
        "templ-rl-root"
        "discnt-role"
        {&g___object}
        ({&g___Object} + {&comma-char} + "pos-type":U)
        ({&g___Object} + {&comma-char} + "templ-rl-root":U)
        ({&g___Object} + {&comma-char} + "discnt-role":U)
        "rule-num":U) , {&delim-par})
        "rl-root":U
        */
        run ref/dis-cps.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT v-mode  /*p-list-mode */
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when {&table_dis-grp-rule} then do:
        if X_dis-rule.rule-num <  {&max-num-dr-template}  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = {&g___object} then do:
             v-mode = ({&g___Object} + {&comma-char} + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ({&g___Object} + {&comma-char} + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = {&dr-appl-object} then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.
        /*список возможных list-mode
        ({&all}
        "pos"
        "templ-rl-root"
        "discnt-role"
        {&g___object}
        ({&g___Object} + {&comma-char} + "pos-type":U)
        ({&g___Object} + {&comma-char} + "templ-rl-root":U)
        ({&g___Object} + {&comma-char} + "discnt-role":U)
        "rule-num":U) , {&delim-par})
        "rl-root":U
        */
        run ref/dis-grps.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT v-mode  /*p-list-mode */
                            ,input v-classif-type
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.
      when {&table_dis-thbj-rule} then do:
        if X_dis-rule.rule-num <  {&max-num-dr-template}  then do:
           if p-mode = "upper-rule-num"
           or p-mode = "template"
           or p-mode = "template"
           then do:
             v-mode = "templ-rl-root".
           end.
           if p-mode = {&g___object} then do:
             v-mode = ({&g___Object} + {&comma-char} + "templ-rl-root":U).
           end.
           if p-mode = "cd-obj" then do:
              v-mode = ({&g___Object} + {&comma-char} + "pos-type":U).
           end.
        end.
        else do:
          if v-link-prop = {&dr-appl-object}
          or v-link-prop = {&dr-rule-ref-object}
          then do:
             v-mode = "rule-num".
          end.
          else do:
             v-mode = "rl-root".
          end.
        end.

        /*список возможных list-mode
        ({&all}
        "pos"
        "templ-rl-root"
        "discnt-role"
        {&g___object}
        {&company}
        ({&g___Object} + {&comma-char} + "pos-type":U)
        ({&g___Object} + {&comma-char} + "templ-rl-root":U)
        ({&g___Object} + {&comma-char} + "discnt-role":U)
        "rule-num":U) , {&delim-par})
        "rl-root":U
        */
        run ref/disthbjs.w (
                             INPUT parparentproc
                            ,INPUT '':U /*bttn */
                            ,INPUT v-mode  /*p-list-mode */
                            ,input X_dis-rule.host-code
                            ,input X_dis-rule.obj-type
                            ,input X_dis-rule.obj-code
                            ,input (if tt-template_dis-rule.templ-rl-root = 0
                                    then X_dis-rule.templ-rl-root
                                    else tt-template_dis-rule.templ-rl-root)
                            ,input '':U /*p-pos-type*/
                            ,input '':U /*p-discnt-role*/
                            ,input X_dis-rule.rule-num
                            ,input-output v-rid-list ) no-error.
      end.

    end case.
  END.
END CASE.
apply "entry" to br-dis-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-mark Dialog-Frame
PROCEDURE proc-b-mark :
define variable loc#log as logical no-undo .
  if available X_dis-rule then do:
    { gbl/markstrn.i X_dis-rule v-rid-list }
    loc#log = br-dis-rule:refresh() IN FRAME {&FRAME-NAME} .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-dis-rule:select-next-row ().
        apply "VALUE-CHANGED" to br-dis-rule in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-dis-rule in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
define variable v-doc-rec as recid no-undo .
define variable accum-count as integer.
define variable date_string     as      char    no-undo.
define variable Line            as      char    no-undo.
DEFINE VARIABLE v-sts-chr AS CHARACTER NO-UNDO.
define variable v-region as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-subject-type as character no-undo .
define variable v-value-type as character no-undo .
define variable v-discnt-value as character no-undo .
DEFINE VARIABLE v1-sts-chr AS CHARACTER NO-UNDO.
define variable v1-region as character no-undo .
define variable v1-discnt-type as character no-undo .
define variable v1-subject-type as character no-undo .
define variable v1-value-type as character no-undo .
define variable v1-discnt-value as character no-undo .
define variable v-mark as character no-undo .
DEFINE variable v1-display-time-rule-num AS CHARACTER NO-UNDO.
DEFINE variable v1-display-dis-kat AS CHARACTER  NO-UNDO.
DEFINE variable v1-display-doc-qnty AS CHARACTER  NO-UNDO.
DEFINE variable v1-display-tot-sum AS CHARACTER  NO-UNDO.
define variable v1-display-charkey_one as character no-undo .
define variable v1-display-charkey_two as character no-undo .
define variable v1-display-charkey_three as character no-undo .
define variable v1-display-deckey_one as character no-undo .
define variable v1-display-deckey_two as character no-undo .
define variable v1-display-deckey_three as character no-undo .
define variable v1-display-key#_one as character no-undo .
define variable v1-display-key#_two as character no-undo .
define variable v1-display-key#_three as character no-undo .
DEFINE VARIABLE v1-display-discnt-value AS CHARACTER  NO-UNDO.
define variable v-h as handle no-undo .
define variable v-fh as handle no-undo .
define variable v-realname as character no-undo .
define variable v-realname2 as character no-undo .
define variable v-char as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-found as logical no-undo .
define variable v-using-fields as character no-undo .

define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_print-dis-rule for print-dis-rule.

DEFINE FRAME dis-rule-list
X_dis-rule.des FORMAT "X(40)"
v-sts-chr FORMAT "X(8)" COLUMN-LABEL "Статус"
v-region FORMAT "X(15)" COLUMN-LABEL "Обл-ть действия"
v-discnt-type COLUMN-LABEL "Тип скидки" FORMAT "X(20)":U
v-subject-type COLUMN-LABEL "Объект!воздействия!скидки" FORMAT "X(12)":U
v-value-type COLUMN-LABEL "Тип!знач." FORMAT "X(7)":U
X_dis-rule.rule-num COLUMN-LABEL "Номер!правила"
v-char column-label "Значения" format "X(72)"
HEADER  date_string AT 5 format "X(35)"
 string( "Страница " ) format "X(9)" AT 145 PAGE-NUMBER(PrnLibStream) AT 155 FORMAT ">>9" SKIP
Line format "X(195)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .
Line = fill("-", 195).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(130)" SKIP(1) .
FORM HEADER
Line format "X(195)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME dis-rule-list  .
run waitfram-show in this-procedure ( input "Ждите...").
v-doc-rec = recid(X_dis-rule).
DO WHILE available X_dis-rule :
  GET prev br-dis-rule.
END.
for each buf_print-dis-rule:
  delete buf_print-dis-rule.
end.
create buf_print-dis-rule.
GET next br-dis-rule.
do jj = 1 to 4 :
  assign
  v-h = br-dis-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}
  v-char = '':U
  ii = 0
  v-found = no
  .
  DO while valid-handle(v-h) :
    if v-h:visible
    and v-h:name <> ?
    then do:
      v-realname = replace(v-h:name, "v-", "").
      assign
      v-fh = buffer buf_print-dis-rule:buffer-field(v-realname) no-error .
      if valid-handle(v-fh) then do:
        assign
        v-char = v-char + (if ii = 0 then '':U else {&space-char} ) +
        (if num-entries(v-h:label, "!") >= jj then
        string(entry(jj, v-h:label, "!"), substitute("X(&1)", round(v-h:width, 0)))
        else fill( {&space-char}, integer(round(v-h:width, 0)))
        )
        ii = ii + 1
        .
        if num-entries(v-h:label, "!") = jj then do:
          v-found = yes.
        end.
      end.
    end.
    v-h = v-h:NEXT-COLUMN.
  end.
  if not v-found and jj > 1 then leave.
  display stream prnlibstream
  v-char
  with FRAME dis-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-rule-list  .
end.
&scop used-status-code string(X_dis-rule.sts)
DO WHILE available X_dis-rule :
&scop discnt-v-code string(X_dis-rule.value-type)
  assign
  v-sts-chr = {&used-status-int-name}
  v-region = gtregion(X_dis-rule.host-code, X_dis-rule.obj-type, X_dis-rule.obj-code, X_dis-rule.templ-rl-root, X_dis-rule.lvl-num = 0, NO)
  v-discnt-type = {&discnt-type-name}
  v-subject-type = {&discnt-target-name}
  v-value-type = {&discnt-v-name}
  v-mark = mark-string(buffer X_dis-rule, v-rid-list)
  .
  RUN get-tree IN THIS-PROCEDURE(
                                   BUFFER X_dis-rule
                                  ,output buf_print-dis-rule.display-time-rule-num
                                  ,OUTPUT buf_print-dis-rule.display-dis-kat
                                  ,OUTPUT buf_print-dis-rule.display-doc-qnty
                                  ,OUTPUT buf_print-dis-rule.display-tot-sum
                                  ,OUTPUT buf_print-dis-rule.display-charkey_one
                                  ,OUTPUT buf_print-dis-rule.display-charkey_two
                                  ,OUTPUT buf_print-dis-rule.display-charkey_three
                                  ,OUTPUT buf_print-dis-rule.display-deckey_one
                                  ,OUTPUT buf_print-dis-rule.display-deckey_two
                                  ,OUTPUT buf_print-dis-rule.display-deckey_three
                                  ,OUTPUT buf_print-dis-rule.display-key#_one
                                  ,OUTPUT buf_print-dis-rule.display-key#_two
                                  ,OUTPUT buf_print-dis-rule.display-key#_three
                                  ,OUTPUT buf_print-dis-rule.display-discnt-value
                                  ,output v-using-fields
                                  ) .
  assign
  v-h = br-dis-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}
  v-char = '':U
  ii = 0
  .
  DO while valid-handle(v-h) :
    if v-h:visible
    and v-h:name <> ?
    then do:
      v-realname = replace(v-h:name, "v-", "").
      assign
      v-fh = buffer buf_print-dis-rule:buffer-field(v-realname) no-error .
      if valid-handle(v-fh) then do:
        assign
        v-char = v-char + (if ii = 0 then '':U else {&space-char} ) +
        string(v-fh:buffer-value, substitute("X(&1)", round(v-h:width, 0)))
        ii = ii + 1
        .
      end.
    end.
    v-h = v-h:NEXT-COLUMN.
  end.
  Display STREAM PrnLibStream
  X_dis-rule.des
  v-sts-chr
  v-region
  v-discnt-type
  v-subject-type
  v-value-type
  X_dis-rule.rule-num
  v-char
  with FRAME dis-rule-list .
  DOWN STREAM PrnLibStream 1
  with FRAME dis-rule-list  .
  assign
  accum-count = accum-count + 1
  .
  if X_dis-rule.is-term = no
  and X_dis-rule.root = yes
  then do:
&SCOPED-DEFINE used-status-code STRING(buf_dis-rule.sts)
&SCOPED-DEFINE discnt-type-code string(buf_dis-rule.discnt-type)
&SCOPED-DEFINE discnt-target-code STRING(buf_dis-rule.subject-type)
&SCOPED-DEFINE discnt-v-code STRING(buf_dis-rule.value-type)
    for each buf_dis-rule no-lock where
            buf_dis-rule.rl-root = X_dis-rule.rule-num
        and buf_dis-rule.is-term = yes
            :
      assign
      v1-sts-chr = {&used-status-int-name}
      v1-region = gtregion(buf_dis-rule.host-code, buf_dis-rule.obj-type, buf_dis-rule.obj-code, buf_dis-rule.templ-rl-root, buf_dis-rule.lvl-num = 0, NO)
      v1-discnt-type = {&discnt-type-name}
      v1-subject-type = {&discnt-target-name}
      v1-value-type = {&discnt-v-name}
      .
      RUN get-tree IN THIS-PROCEDURE(
                                      BUFFER buf_dis-rule
                                      ,output buf_print-dis-rule.display-time-rule-num
                                      ,OUTPUT buf_print-dis-rule.display-dis-kat
                                      ,OUTPUT buf_print-dis-rule.display-doc-qnty
                                      ,OUTPUT buf_print-dis-rule.display-tot-sum
                                      ,OUTPUT buf_print-dis-rule.display-charkey_one
                                      ,OUTPUT buf_print-dis-rule.display-charkey_two
                                      ,OUTPUT buf_print-dis-rule.display-charkey_three
                                      ,OUTPUT buf_print-dis-rule.display-deckey_one
                                      ,OUTPUT buf_print-dis-rule.display-deckey_two
                                      ,OUTPUT buf_print-dis-rule.display-deckey_three
                                      ,OUTPUT buf_print-dis-rule.display-key#_one
                                      ,OUTPUT buf_print-dis-rule.display-key#_two
                                      ,OUTPUT buf_print-dis-rule.display-key#_three
                                      ,OUTPUT buf_print-dis-rule.display-discnt-value
                                      ,output v-using-fields
                                      ) .
      assign
      v-h = br-dis-rule:FIRST-COLUMN IN FRAME {&FRAME-NAME}
      v-char = '':U
      ii = 0
      .
      DO while valid-handle(v-h) :
        if v-h:name <> ?
        then do:
          assign
          v-realname = replace(v-h:name, "v-", "")
          v-realname2 = replace(v-h:name, "v-display-", "")
          .
          assign
          v-fh = buffer buf_print-dis-rule:buffer-field(v-realname) no-error .
          if valid-handle(v-fh)
          and lookup(v-realname2, v-using-fields) > 0
          then do:
            assign
            v-char = v-char + (if ii = 0 then '':U else {&space-char} ) +
            string(v-fh:buffer-value, substitute("X(&1)", round(v-h:width, 0)))
            ii = ii + 1
            .
          end.
        end.
        v-h = v-h:NEXT-COLUMN.
      end.
      display STREAM PrnLibStream
      buf_dis-rule.des           @ X_dis-rule.des
      {&used-status-int-name}    @ v-sts-chr
      v1-region                  @ v-region
      v1-discnt-type             @ v-discnt-type
      v1-subject-type            @ v-subject-type
      v1-value-type              @ v-value-type
      buf_dis-rule.rule-num      @ X_dis-rule.rule-num
      v-char
      with FRAME dis-rule-list .
      DOWN STREAM PrnLibStream 1
      with FRAME dis-rule-list .
      .
&SCOPED-DEFINE used-status-code STRING(X_dis-rule.sts)
&SCOPED-DEFINE discnt-type-code string(X_dis-rule.discnt-type)
&SCOPED-DEFINE discnt-target-code STRING(X_dis-rule.subject-type)
&SCOPED-DEFINE discnt-v-code STRING(X_dis-rule.value-type)

    end.
    DOWN STREAM PrnLibStream 1
    with FRAME dis-rule-list .
    .
  end.
  GET next br-dis-rule.
END.
UNDERLINE  STREAM PrnLibStream
X_dis-rule.des
v-sts-chr
v-region
v-discnt-type
v-subject-type
v-value-type
X_dis-rule.rule-num
v-char
with FRAME dis-rule-list .
DISPLAY STREAM PrnLibStream
"ИТОГО" @ X_dis-rule.des
accum-count @ v-sts-chr
with frame dis-rule-list.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME dis-rule-List.
output  STREAM PrnLibStream CLOSE.
REPOSITION br-dis-rule to recid v-doc-rec no-error.
APPLY "entry" to br-dis-rule.
run waitfram-hide in this-procedure .
if true /*frame dis-rule-list:width <= 198*/  then do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
end.
else do:
  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input (if frame dis-rule-list:width <= 255 then 1 else 20)
                                            ).
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'dis-rule'
  join-tbl = 'X_dis-rule'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('des', 'Описание правила скидок', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if not (p-mode = "template" or p-mode = "template-value-type") and not (p-upper-rule-num = 0 and p-mode = "upper-rule-num") then do:
  run fltfield-add in this-procedure('templ-rl-root', 'Номер типа(шаблона) правила', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('host-code', 'Фирма', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('discnt-value', 'Значение скидки', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc
                   , INPUT filter-point + {&delim-par} + filter-label
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-stat Dialog-Frame
PROCEDURE proc-b-stat :
define input parameter p-doc-rec as recid no-undo .
define variable v-sts like ub.dis-rule.sts no-undo .
define buffer loc_dis-rule for ub.dis-rule.
do
on error undo, return error
:

  find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = p-doc-rec no-error .
  v-sts =?.
 if not available loc_dis-rule then do:
    message
    "Запись уже отсутствует или недоступна"
    view-as alert-box warning.
    return.
  end.
  run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input no /*p-silent*/
                  , input ? /*p-pos-type*/
                  , input-output v-sts
                  ) no-error.
  if error-status:error then do:
    if error-status:get-message(1) <> '':U
    or return-value <> '':U then
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
  end.

end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-time-rule Dialog-Frame
PROCEDURE proc-b-time-rule :
define variable loc-doc-rec as recid no-undo .
define variable v-sts as integer no-undo init -1.
define variable v-rid-list as character no-undo .

IF NOT AVAILABLE X_dis-rule THEN RETURN no-apply.
if not can-find(first ub.dis-cfg-rule where
                    ub.dis-cfg-rule.templ-rl-root = X_dis-rule.templ-rl-root
                and  ub.dis-cfg-rule.time-templ-rl-root > 0)
then do:
  message
  "С правилами скидок данных типов не может быть связано расписание"
  view-as alert-box error .
  return no-apply.
end.
if X_dis-rule.lvl-num = 0 then do:
  /*для типов показываем те, которые могут использоваться*/
  run ref/dist-rls.w (
                  input parparentproc
                ,input "b-add"
                ,input "dis-rule"
                ,input X_dis-rule.templ-rl-root
                ,input 0
                ,input ''
                ,input-output v-sts
                ,input-output v-rid-list) no-error .
end.
else do:
  if lookup("time-rule-num", X_dis-rule.uniq-field) > 0 then do:
      /*для непосредственно парвил показываем то что прописано*/
      run ref/dist-rls.w (
                    input parparentproc
                    ,input ""
                    ,input "rule-num"
                    ,input (if X_dis-rule.lvl-num = 1
                        then X_dis-rule.rule-num
                        else X_dis-rule.upper-rule-num)
                    ,input 0
                    ,input ''
                    ,input-output v-sts
                    ,input-output v-rid-list) no-error .
  end.
  else do:
    if X_dis-rule.time-rule-num <> 0 then
    run ref/dis-timi.w (
                  input parParentProc
                , input {&lookup}
                , input 0 /*p-templ-rl-root*/
                , input  X_dis-rule.time-rule-num
                , input 0 /*p-upper-time-rule-num*/
                , input-output loc-doc-rec
                ) no-error .
  end.
end.
APPLY "ENTRY" TO br-dis-rule in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-br-dis-rule Dialog-Frame
PROCEDURE proc-br-dis-rule :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ ref/brwsretr.i }
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-string Dialog-Frame
FUNCTION mark-string RETURNS CHARACTER
  ( BUFFER loc-dis-rule FOR ub.dis-rule, input mark-list as CHARACTER ) :
  RUN get-tree IN THIS-PROCEDURE(
                                  BUFFER loc-dis-rule
                                  ,output v-display-time-rule-num
                                  ,OUTPUT v-display-dis-kat
                                  ,OUTPUT v-display-doc-qnty
                                  ,OUTPUT v-display-tot-sum
                                  ,output v-display-charkey_one
                                  ,output v-display-charkey_two
                                  ,output v-display-charkey_three
                                  ,output v-display-deckey_one
                                  ,output v-display-deckey_two
                                  ,output v-display-deckey_three
                                  ,output v-display-key#_one
                                  ,output v-display-key#_two
                                  ,output v-display-key#_three
                                  ,OUTPUT v-display-discnt-value
                                  ,output v-using-fields
                              ).
RETURN ( IF LOOKUP( STRING( RECID( loc-dis-rule ) ), mark-list ) > 0 THEN "*" ELSE "":U ).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME