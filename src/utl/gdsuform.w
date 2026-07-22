&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME u-gds-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS u-gds-form
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форма ввода данных для редактирования списка товаров

вызывается из администратора - утилиты
ВНИМАНИЕ!!!
чтобы открыть UIB надо что-то сделать с calc-method

Автор: Бахтадзе Наталья Викторовна
Дата создания: 17/08/1999
Author: Bakhtadze Natalya
Creation date: 17/08/1999

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Форма ввода данных для редактирования списка товаров" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ cmp/gds-list.i gds-list def "new shared" }
{ str/tt-tax.i "new shared" tt-tax full }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ ref/grplib.i }
{ gbl/getcntxt.i def }

/*переменные хранящие значения для обновления полей дополнительной информации */
define variable destin_ like ub.goods.destin no-undo init ?.
define variable attrib_ like ub.goods.attrib no-undo init ?.
define variable user-rule_ like ub.goods.user-rule no-undo init ?.
define variable sert_ like ub.goods.sert no-undo init ?.
define variable struct_ like ub.goods.struct no-undo init ?.
define variable deadline_ like ub.goods.deadline no-undo init ?.
define variable sort_       like ub.goods.sort no-undo init ?.
define variable nationality_       like ub.goods.nationality no-undo init ?.
define variable tnved_       like ub.goods.tnved no-undo init ?.
define variable unit-cst_       like ub.goods.unit-cst no-undo init ?.
define variable cst-base-rate_       like ub.goods.cst-base-rate no-undo init ?.
define variable normal-wastage_ like ub.goods.normal-wastage no-undo init ?.
define variable normal-waste_ like ub.goods.normal-waste no-undo init ?.
define variable cond-keep-code_       like ub.goods.cond-keep-code no-undo init ?.
define variable proof_       like ub.goods.proof no-undo init ?.
define variable glog as logical no-undo .


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME u-gds-form
&Scoped-define BROWSE-NAME BR-tt-tax

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-tax

/* Definitions for BROWSE BR-tt-tax                                     */
&Scoped-define FIELDS-IN-QUERY-BR-tt-tax tt-tax.tax-code tt-tax.tax-name tt-tax.tax-type tt-tax.rate-code tt-tax.rate-name tt-tax.rate-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-tt-tax
&Scoped-define SELF-NAME BR-tt-tax
&Scoped-define QUERY-STRING-BR-tt-tax FOR EACH tt-tax NO-LOCK
&Scoped-define OPEN-QUERY-BR-tt-tax OPEN QUERY {&SELF-NAME} FOR EACH tt-tax NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-tt-tax tt-tax
&Scoped-define FIRST-TABLE-IN-QUERY-BR-tt-tax tt-tax


/* Definitions for DIALOG-BOX u-gds-form                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-u-gds-form ~
    ~{&OPEN-QUERY-BR-tt-tax}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS ub.gds-prt.node-name
&Scoped-define ENABLED-TABLES ub.gds-prt
&Scoped-define FIRST-ENABLED-TABLE ub.gds-prt
&Scoped-Define ENABLED-OBJECTS b-exit l-negative-rest l-grp-full l-okdp ~
l-max-rate l-tt-tax l-PS l-gds-name l-engl-name l-alpha1 l-wt-cart ~
l-cli-base-rate l-ms-cart l-min-rate l-unit-cli l-qnty-cart l-calc-method ~
l-increase-pc l-node-name l-stts l-chk-name l-label-name l-wt-base ~
l-ms-base b-quit b-list b-help add-inf EDITOR-1 n-grp-full grp-full ~
FILL-IN-4 n-gds-name n-engl-name n-alpha1 n-label-name n-chk-name n-okdp ~
n-ms-base n-unit-cli n-min-rate n-wt-base n-increase-pc n-cli-base-rate ~
n-ms-cart n-max-rate n-qnty-cart n-wt-cart n-PS
&Scoped-Define DISPLAYED-FIELDS ub.gds-prt.node-name
&Scoped-define DISPLAYED-TABLES ub.gds-prt
&Scoped-define FIRST-DISPLAYED-TABLE ub.gds-prt
&Scoped-Define DISPLAYED-OBJECTS gds-name alpha1 engl-name label-name ~
chk-name OKDP ms-base unit-cli v-calc-method wt-base min-rate cli-base-rate ~
ms-cart qnty-cart increase-pc wt-cart max-rate PS negative-rest stts ~
EDITOR-1 n-grp-full grp-full FILL-IN-4 n-gds-name n-engl-name country_name ~
n-alpha1 n-label-name n-chk-name n-okdp n-ms-base n-unit-cli n-min-rate ~
n-wt-base n-increase-pc n-cli-base-rate n-ms-cart n-max-rate n-qnty-cart ~
n-wt-cart n-PS

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON add-inf
     LABEL "Доп.инф."
     SIZE 10 BY 1.

DEFINE BUTTON B-add-tt-tax
     LABEL "Налог+"
     SIZE 7.6 BY 1.

DEFINE BUTTON B-del-tt-tax
     LABEL "Налог-"
     SIZE 7.6 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.

DEFINE BUTTON B-grp
     LABEL "&Группа"
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE BUTTON b-list
     LABEL "Список":L
     SIZE 10 BY 1.

DEFINE BUTTON b-prt
     LABEL "Шкала"
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.

DEFINE BUTTON r-alpha1
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.8 BY .93.

DEFINE BUTTON r-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.8 BY .93.

DEFINE VARIABLE EDITOR-1 AS CHARACTER INITIAL "Для начала редактирования нажмите левой кнопкой мыши на ~"замке~" соответствующего поля, для отказа от редактирования нажмите правой кнопкой мыши на самом поле"
     VIEW-AS EDITOR LARGE NO-BOX
     SIZE 97.4 BY 1.5
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE PS AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 28.4 BY 2.83
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE alpha1 AS CHARACTER FORMAT "X(2)":U
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE chk-name AS CHARACTER FORMAT "X(25)":U
     VIEW-AS FILL-IN
     SIZE 34.6 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE cli-base-rate AS DECIMAL FORMAT ">>,>>9.9999999999":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 19 BY 1 NO-UNDO.

DEFINE VARIABLE country_name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 25.9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE engl-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.8 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Шкала:"
      VIEW-AS TEXT
     SIZE 6.8 BY .67
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE gds-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 75.5 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE grp-full AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.3 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE increase-pc AS DECIMAL FORMAT "->>9.99%":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 6.9 BY 1 NO-UNDO.

DEFINE VARIABLE label-name AS CHARACTER FORMAT "X(80)":U
     VIEW-AS FILL-IN
     SIZE 75.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE max-rate AS DECIMAL FORMAT ">,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11.8 BY 1 NO-UNDO.

DEFINE VARIABLE min-rate AS DECIMAL FORMAT ">,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11.3 BY 1 NO-UNDO.

DEFINE VARIABLE ms-base AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE ms-cart AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE n-alpha1 AS CHARACTER FORMAT "X(256)":U INITIAL "Страна"
      VIEW-AS TEXT
     SIZE 7.6 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-chk-name AS CHARACTER FORMAT "X(80)":U INITIAL "На  чеке"
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-cli-base-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Коэф."
      VIEW-AS TEXT
     SIZE 5.3 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-engl-name AS CHARACTER FORMAT "X(256)":U INITIAL "Англ.назв."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-gds-name AS CHARACTER FORMAT "X(256)":U INITIAL "Название"
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-grp-full AS CHARACTER FORMAT "X(256)":U INITIAL "Группа:"
      VIEW-AS TEXT
     SIZE 6.9 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-increase-pc AS CHARACTER FORMAT "X(256)":U INITIAL "Наценка:"
      VIEW-AS TEXT
     SIZE 9.1 BY 1 NO-UNDO.

DEFINE VARIABLE n-label-name AS CHARACTER FORMAT "X(80)":U INITIAL "Этикетка"
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-max-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Max кол в штуке"
      VIEW-AS TEXT
     SIZE 15.1 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-min-rate AS CHARACTER FORMAT "X(256)":U INITIAL "Min кол в штуке"
      VIEW-AS TEXT
     SIZE 14.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-ms-base AS CHARACTER FORMAT "X(256)":U INITIAL "Объем шт."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-ms-cart AS CHARACTER FORMAT "X(256)":U INITIAL "Объем уп."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-okdp AS CHARACTER FORMAT "X(256)":U INITIAL "ОКДП"
      VIEW-AS TEXT
     SIZE 5.6 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-PS AS CHARACTER FORMAT "X(256)":U INITIAL "Прим."
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-qnty-cart AS CHARACTER FORMAT "X(256)":U INITIAL "Кол. в уп."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-unit-cli AS CHARACTER FORMAT "X(256)":U INITIAL "Ед. пост-ка"
      VIEW-AS TEXT
     SIZE 11.6 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-wt-base AS CHARACTER FORMAT "X(256)":U INITIAL "Вес шт."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE n-wt-cart AS CHARACTER FORMAT "X(256)":U INITIAL "Вес уп."
      VIEW-AS TEXT
     SIZE 10.8 BY 1
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE OKDP AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 8.3 BY 1 NO-UNDO.

DEFINE VARIABLE qnty-cart AS DECIMAL FORMAT ">,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE unit-cli AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 6.4 BY 1 NO-UNDO.

DEFINE VARIABLE wt-base AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE wt-cart AS DECIMAL FORMAT ">>,>>9.9<<":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE IMAGE l-alpha1
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-calc-method
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-chk-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-cli-base-rate
     FILENAME "adeicon\lock":U
     SIZE 2.1 BY .93.

DEFINE IMAGE l-engl-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-gds-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-grp-full
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-increase-pc
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-label-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-max-rate
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-min-rate
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-ms-base
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-ms-cart
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-negative-rest
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-node-name
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-okdp
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-PS
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-qnty-cart
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-stts
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-tt-tax
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-unit-cli
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-wt-base
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE IMAGE l-wt-cart
     FILENAME "adeicon\lock":U
     SIZE 2.9 BY .93.

DEFINE VARIABLE v-calc-method AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     LIST-ITEMS "1,2"
     SIZE 15.3 BY 2.97 NO-UNDO.

DEFINE VARIABLE negative-rest AS LOGICAL INITIAL no
     LABEL "Отрицательные остатки"
     VIEW-AS TOGGLE-BOX
     SIZE 31.4 BY .77
     FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE stts AS LOGICAL INITIAL no
     LABEL "Удаленный товар?"
     VIEW-AS TOGGLE-BOX
     SIZE 31.4 BY .77
     FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-tt-tax FOR
      tt-tax SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-tt-tax u-gds-form _FREEFORM
  QUERY BR-tt-tax DISPLAY
      tt-tax.tax-code
      tt-tax.tax-name
      tt-tax.tax-type
      tt-tax.rate-code
      tt-tax.rate-name
      tt-tax.rate-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SIZE 58.6 BY 6.3
         TITLE "Ставки налогов".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME u-gds-form
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-list AT ROW 1 COL 31
     B-grp AT ROW 1 COL 41
     b-prt AT ROW 1 COL 51
     b-help AT ROW 1 COL 71
     add-inf AT ROW 2 COL 71
     gds-name AT ROW 5.3 COL 15.3 COLON-ALIGNED NO-LABEL
     alpha1 AT ROW 6.3 COL 62.4 COLON-ALIGNED NO-LABEL
     r-alpha1 AT ROW 6.33 COL 69.8
     engl-name AT ROW 6.37 COL 15.4 COLON-ALIGNED NO-LABEL
     label-name AT ROW 7.53 COL 15.5 COLON-ALIGNED NO-LABEL
     chk-name AT ROW 8.53 COL 15.5 COLON-ALIGNED NO-LABEL
     OKDP AT ROW 8.57 COL 69.8 COLON-ALIGNED NO-LABEL
     ms-base AT ROW 9.8 COL 58.8 COLON-ALIGNED NO-LABEL
     unit-cli AT ROW 9.87 COL 14.8 COLON-ALIGNED NO-LABEL
     r-base AT ROW 9.93 COL 24
     v-calc-method AT ROW 10.2 COL 71.4 NO-LABEL
     wt-base AT ROW 10.7 COL 58.8 COLON-ALIGNED NO-LABEL
     min-rate AT ROW 11.13 COL 31.5 COLON-ALIGNED NO-LABEL
     cli-base-rate AT ROW 11.17 COL 6.9 COLON-ALIGNED NO-LABEL
     ms-cart AT ROW 11.7 COL 58.8 COLON-ALIGNED NO-LABEL
     qnty-cart AT ROW 12.47 COL 16.7 COLON-ALIGNED NO-LABEL
     increase-pc AT ROW 12.5 COL 89.6 COLON-ALIGNED NO-LABEL
     wt-cart AT ROW 12.7 COL 58.8 COLON-ALIGNED NO-LABEL
     max-rate AT ROW 13.47 COL 31.1 COLON-ALIGNED NO-LABEL
     B-add-tt-tax AT ROW 13.83 COL 7.8
     B-del-tt-tax AT ROW 13.83 COL 16.9
     PS AT ROW 14.03 COL 68.4 NO-LABEL
     BR-tt-tax AT ROW 14.97 COL 2.5
     negative-rest AT ROW 18.27 COL 65.3
     stts AT ROW 19.3 COL 65.5
     EDITOR-1 AT ROW 21.27 COL 1.8 NO-LABEL
     n-grp-full AT ROW 3.07 COL 32.4 COLON-ALIGNED NO-LABEL
     grp-full AT ROW 3.07 COL 40.1 COLON-ALIGNED NO-LABEL
     FILL-IN-4 AT ROW 4.2 COL 32.8 COLON-ALIGNED NO-LABEL
     ub.gds-prt.node-name AT ROW 4.2 COL 40 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 51.3 BY 1
          BGCOLOR 3 FGCOLOR 15
     n-gds-name AT ROW 5.3 COL 5.3 COLON-ALIGNED NO-LABEL
     n-engl-name AT ROW 6.33 COL 4.4 COLON-ALIGNED NO-LABEL
     country_name AT ROW 6.33 COL 71 COLON-ALIGNED NO-LABEL
     n-alpha1 AT ROW 6.37 COL 54.6 COLON-ALIGNED NO-LABEL
     n-label-name AT ROW 7.53 COL 4.5 COLON-ALIGNED NO-LABEL
     n-chk-name AT ROW 8.63 COL 4.4 COLON-ALIGNED NO-LABEL
     n-okdp AT ROW 8.63 COL 64.9 NO-LABEL
     n-ms-base AT ROW 9.77 COL 47.5 COLON-ALIGNED NO-LABEL
     n-unit-cli AT ROW 9.93 COL 2.6 COLON-ALIGNED NO-LABEL
     n-min-rate AT ROW 10 COL 27.9 COLON-ALIGNED NO-LABEL
     n-wt-base AT ROW 10.7 COL 47.4 COLON-ALIGNED NO-LABEL
     n-increase-pc AT ROW 11.03 COL 87.8 COLON-ALIGNED NO-LABEL
     n-cli-base-rate AT ROW 11.13 COL 1.5 COLON-ALIGNED NO-LABEL
     n-ms-cart AT ROW 11.77 COL 47.5 COLON-ALIGNED NO-LABEL
     n-max-rate AT ROW 12.33 COL 27.8 COLON-ALIGNED NO-LABEL
     n-qnty-cart AT ROW 12.47 COL 5.4 COLON-ALIGNED NO-LABEL
     n-wt-cart AT ROW 12.7 COL 47.4 COLON-ALIGNED NO-LABEL
     n-PS AT ROW 15.27 COL 61.9 NO-LABEL
     l-negative-rest AT ROW 18.17 COL 62.1
     l-grp-full AT ROW 3.13 COL 31.4
     l-okdp AT ROW 8.7 COL 62.5
     l-max-rate AT ROW 13.53 COL 29.8
     l-tt-tax AT ROW 13.93 COL 3
     l-PS AT ROW 14.07 COL 64.5
     l-gds-name AT ROW 5.33 COL 3.1
     l-engl-name AT ROW 6.33 COL 3
     l-alpha1 AT ROW 6.43 COL 53.1
     l-wt-cart AT ROW 13.07 COL 46.5
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-list CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME u-gds-form
     l-cli-base-rate AT ROW 11 COL 1.8
     l-ms-cart AT ROW 12.07 COL 46.5
     l-min-rate AT ROW 11.13 COL 30.1
     l-unit-cli AT ROW 10 COL 1.8
     l-qnty-cart AT ROW 12.53 COL 4.5
     l-calc-method AT ROW 10 COL 87.4
     l-increase-pc AT ROW 9.93 COL 96.4
     l-node-name AT ROW 4.07 COL 31.5
     l-stts AT ROW 19.13 COL 62.1
     l-chk-name AT ROW 8.63 COL 3
     l-label-name AT ROW 7.53 COL 3.1
     l-wt-base AT ROW 11.07 COL 46.5
     l-ms-base AT ROW 10.07 COL 46.5
     SPACE(50.36) SKIP(11.77)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите данные для пакетной обработки по списку товаров"
         DEFAULT-BUTTON b-list CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX u-gds-form
                                                                        */
/* BROWSE-TAB BR-tt-tax PS u-gds-form */
ASSIGN
       FRAME u-gds-form:SCROLLABLE       = FALSE
       FRAME u-gds-form:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN alpha1 IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-add-tt-tax IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-del-tt-tax IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-grp IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON b-prt IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BROWSE BR-tt-tax IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN chk-name IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN cli-base-rate IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN country_name IN FRAME u-gds-form
   NO-ENABLE                                                            */
ASSIGN
       EDITOR-1:RETURN-INSERTED IN FRAME u-gds-form  = TRUE
       EDITOR-1:READ-ONLY IN FRAME u-gds-form        = TRUE.

/* SETTINGS FOR FILL-IN engl-name IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN gds-name IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN increase-pc IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN label-name IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN max-rate IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN min-rate IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ms-base IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ms-cart IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN n-okdp IN FRAME u-gds-form
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN n-PS IN FRAME u-gds-form
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX negative-rest IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.gds-prt.node-name IN FRAME u-gds-form
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN OKDP IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR PS IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN qnty-cart IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-alpha1 IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON r-base IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX stts IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN unit-cli IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR SELECTION-LIST v-calc-method IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN wt-base IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN wt-cart IN FRAME u-gds-form
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-tt-tax
/* Query rebuild information for BROWSE BR-tt-tax
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-tax NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-tt-tax */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME u-gds-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL u-gds-form u-gds-form
ON WINDOW-CLOSE OF FRAME u-gds-form /* Введите данные для пакетной обработки по списку товаров */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME add-inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL add-inf u-gds-form
ON CHOOSE OF add-inf IN FRAME u-gds-form /* Доп.инф. */
DO:
      run utl/pu51121.w (
                     input parparentproc
                    ,input v-cntxt-obj-type
                    ,input v-cntxt-obj-code
                    ,output destin_
                    ,output attrib_
                    ,output user-rule_
                    ,output sert_
                    ,output struct_
                    ,output deadline_
                    ,output sort_
                    ,output nationality_
                    ,output tnved_
                    ,output unit-cst_
                    ,output cst-base-rate_
                    ,output normal-wastage_
                    ,output normal-waste_
                    ,output cond-keep-code_
                    ,output proof_).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME alpha1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL alpha1 u-gds-form
ON LEAVE OF alpha1 IN FRAME u-gds-form
DO:
    APPLY "RETURN" to alpha1.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL alpha1 u-gds-form
ON RETURN OF alpha1 IN FRAME u-gds-form
DO:
 define variable v-rid-list as character no-undo .
    FIND FIRST country where
                        country.alpha1 = input frame {&frame-name} alpha1 No-LOCK No-ERROR.
IF NOT AVAIL country then do:
            run ref/countris.w (
                            input parparentproc
                           ,input "b-sel"
                  ,input-output v-rid-list ).
  if v-rid-list = "" then do:
                    apply "entry" to alpha1 in frame {&frame-name}.
                    return no-apply.
                end.
            FIND country WHERE recid (country) = integer(v-rid-list) NO-LOCK.
            DISPLAY
            country.alpha1 @ alpha1
            country.short-name @ country_name
            with frame {&frame-name}.
    end.
    else do:
        assign
        country_name = country.short-name.
        display country_name with frame {&frame-name}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL alpha1 u-gds-form
ON RIGHT-MOUSE-CLICK OF alpha1 IN FRAME u-gds-form
DO:
    assign
    l-alpha1:fgcolor = 15
    alpha1 = ""
    l-alpha1:visible = true
    country_name = "".
    display alpha1 country_name with frame {&frame-name}.
    disable alpha1 with frame {&frame-name}.
    disable r-alpha1 with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add-tt-tax u-gds-form
ON CHOOSE OF B-add-tt-tax IN FRAME u-gds-form /* Налог+ */
DO:
DEFINE var tax-rate-rid As char NO-UNDO init "".
DEFINE var taxvalue like ub.tax-rate-value.rate-value NO-UNDO.
DEFINE buffer bf-tt-tax for tt-tax.
  run ref/tax-tree.w (
                   input parparentproc
                  ,input "b-seltax-rate":U
                  ,input "ALL-TAX-RATES":U
                  ,input v-cntxt-host-code-obj
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input ?
                  ,input-output tax-rate-rid) no-error .
  IF ERROR-STATUS:error then return no-apply.
  if tax-rate-rid <> "" then do:
    FIND FIRST ub.tax-rate NO-LOCK WHERE recid(ub.tax-rate) = integer(tax-rate-rid) NO-ERROR.
    if NOT AVAIL ub.tax-rate then return no-apply.
    /*сначала проверим нет ли уже в списке ставки налога такого типа*/
    FIND first bf-tt-tax No-LOCK WHERE
                                   bf-tt-tax.tax-code = ub.tax-rate.tax-code NO-ERROR.
    IF avail bf-tt-tax then do:
        message "В списке ставок налогов уже есть ставка по такому налогу!" view-as
        alert-box ERROR.
        return no-apply.
    end.

    FIND FIRST ub.tax NO-LOCK WHERE ub.tax.tax-code = ub.tax-rate.tax-code NO-ERROR.
    if NOT AVAIL ub.tax then return no-apply.
    if ub.tax.individual then do:
        message "Нельзя редактировать налоги на товар, если налог индивидуальный!"
        view-as alert-box ERROR.
        return no-apply.
    end.
    { gbl/pftaxval.i ? ub.tax-rate.tax-code ub.tax-rate.rate-code ? v-cntxt-host-code-obj v-cntxt-obj-type v-cntxt-obj-code taxvalue no-error}
    if error-status:error or taxvalue = ? then return no-apply.
    create
    tt-tax.
    assign
    tt-tax.tax-code = ub.tax.tax-code
    tt-tax.tax-name = ub.tax.tax-name
    tt-tax.rate-code = ub.tax-rate.rate-code
    tt-tax.rate-name = ub.tax-rate.rate-name
    tt-tax.tax-type = ub.tax.tax-type
    tt-tax.rate-value = taxvalue
    tt-tax.tax-rate-gds-rc = ?
    .
    OPEN QUERY br-tt-tax for each tt-tax NO-LOCK.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del-tt-tax u-gds-form
ON CHOOSE OF B-del-tt-tax IN FRAME u-gds-form /* Налог- */
DO:
    DEFINE BUFFER bf-tt-tax for tt-tax.
    IF AVAIL tt-tax then do:
        FIND FIRST bf-tt-tax WHERE bf-tt-tax.tax-code = tt-tax.tax-code NO-ERROR.
        if avail bf-tt-tax then delete bf-tt-tax.
        OPEN QUERY BR-tt-tax for each tt-tax NO-LOCK.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit u-gds-form
ON CHOOSE OF b-exit IN FRAME u-gds-form /* Ввод */
DO:
  define variable v-parameter as character no-undo .
  define variable glog as logical no-undo .
  define variable mystr as char format "X(500)".
  DEFINE VARIABLE par-date as date no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  DEFINE VARIABLE var-fact-order like ub.tax-rate-value.fact-order no-undo .
  define buffer cli-units for ub.units.
  /*определим какие налоги по сути являются НДС и НП*/
  if NOT can-find(first gds-list) then do:
    BELL.
    message "В списке товаров нет ни одного товара!" view-as alert-box WARNING.
    return no-apply.
  end.
  assign
  v-calc-method cli-base-rate engl-name label-name chk-name gds-name grp-full increase-pc
  ms-base wt-base ms-cart negative-rest OKDP PS min-rate max-rate qnty-cart stts unit-cli wt-cart
  alpha1
  .
  IF cli-base-rate:sensitive and cli-base-rate <> 1 then do:
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых базовая ед.изм. совпадает с ед.изм.поставщика,"
    "изменения будут отклонены (задан коэф. не равный 1)!" view-as alert-box
    WARNING.
  end.
  IF unit-cli:sensitive then do:
    FIND FIRST cli-units No-LOCK WHERE cli-units.unit-name = unit-cli No-ERROR.
    if LOOKUP({&petrolium}, cli-units.type) > 0 then
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых ед.изм.поставщика имеет топливный тип, а  базовая ед.изм. нет,"
    "изменения будут отклонены!" view-as alert-box
    WARNING.
    else
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых базовая ед.изм. имеет топливный тип, а ед.изм.поставщика нет,"
    "изменения будут отклонены!" view-as alert-box
    WARNING.
  end.

  IF br-tt-tax:sensitive then do:
    message "ВНИМАНИЕ!" skip
    "Для товаров, у которых тип базовой ед.изм. не включен в список типов базовых ед.изм.," skip
    "для которых определен налог, изменения списка ставок налогов по товару" skip
    "                             будут отклонены!" view-as alert-box
    WARNING.
    run gbl/d-prompt.w (
      'title=':u + "Введите дату, с которой начнут действовать новые ставки налогов" + '\':u
    + 'text1=':u + " ДАТА" + '\':u
    + 'format=' + "99/99/9999" + '\':u
    + 'type=' + {&type-date} + '\':u
    + 'fillin_row=2\':u
    + 'fillin_col=4\':u
    + 'fillin_width=12\':u
    + 'fillin_height=1\':u
    + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
    + 'readonly=no\':u
    , input-output par-date
    ).

    if return-value = 'false':u then do:
            return no-apply.
        end.
    run cur-time in this-procedure ( output v-today, output v-time).
    run factord-end-day in this-procedure ( input (if par-date = ? then v-today else par-date) , output var-fact-order).
  end.
  IF min-rate:sensitive OR max-rate:sensitive then do:
    message "ВНИМАНИЕ!" skip
    "Для товаров у которых тип базовой ед.изм. не " {&twounit} "," skip
    "изменения Min или MAx количества в штуке будут отклонены!"
    view-as alert-box WARNING.
  END.

  mystr =   (IF gds-name:sensitive then ("НАЗВАНИЕ="+ gds-name + {&new-line} ) else "") +
  (IF engl-name:sensitive then ("АНГЛ.НАЗВАНИЕ=" + engl-name + {&new-line} ) else "") +
  (IF label-name:sensitive then ("ЭТИКЕТКА=" + label-name + {&new-line} ) else "") +
  (IF chk-name:sensitive then ("НА ЧЕКЕ=" + chk-name + {&new-line} ) else "") +
  (IF unit-cli:sensitive then ("Един. изм. пост-ка=" + unit-cli + {&new-line} ) else "") +
  (IF cli-base-rate:sensitive then ("Коэффициент к ед. изм. пост-ка=" + string(cli-base-rate)
                                          + {&new-line} ) else "") +
  (IF okdp:sensitive then ("ОКДП=" + okdp + {&new-line} ) else "") +
  (IF v-calc-method:sensitive then ("Расчет цены по=" + v-calc-method + {&new-line} ) else "") +
  (IF increase-pc:sensitive then ("Наценка=" + string(increase-pc) + {&new-line} ) else "") +
  (IF negative-rest:sensitive then ("Отриц.остатки разрешены - " + string(negative-rest,"да/нет") + {&new-line} )
                                                else "") +
  (IF stts:sensitive then ("Товар удален - " + string(stts,"да/нет") + {&new-line} ) else "") +
  (IF min-rate:sensitive then ("Min кол-во в штуке=" + string(min-rate) + {&new-line} ) else "") +
  (IF max-rate:sensitive then ("Max кол-во в штуке=" + string(max-rate) + {&new-line} ) else "") +
  (IF qnty-cart:sensitive then ("Кол-во в упаковке=" + string(qnty-cart) + {&new-line} ) else "") +
  (IF ms-base:sensitive then ("Объем штуки=" + string(ms-base) + {&new-line} ) else "") +
  (IF wt-base:sensitive then ("Вес штуки=" + string(wt-base) + {&new-line} ) else "") +
  (IF ms-cart:sensitive then ("Объем упаковки=" + string(ms-cart) + {&new-line} ) else "") +
  (IF wt-cart:sensitive then ("Вес упаковки=" + string(wt-cart) + {&new-line} ) else "") +
  (IF PS:sensitive then ("Примечание=" + PS + {&new-line} ) else "") +
  (IF destin_ <> ? then ("Назначение=" + destin_ + {&new-line} ) else "") +
  (IF attrib_ <> ? then ("Характеристики=" + attrib_ + {&new-line} ) else "") +
  (IF sert_ <> ? then ("Сертификат=" + sert_ + {&new-line}) else "") +
  (IF sort_ <> ? then ("Сорт=" + sort_ + {&new-line}) else "") +
  (IF normal-wastage_ <> ? then ("Норма ест.убыли=" + string(normal-wastage_, "->9.99%") + {&new-line}) else "") +
  (IF normal-waste_ <> ? then ("Норма отходов=" + string(normal-waste_, "->9.99%") + {&new-line}) else "") +
  (IF cond-keep-code_ <> ? then ("Код услов.хран.=" + string(cond-keep-code_) + {&new-line}) else "") +
  (IF proof_ <> ? then ("Алкоголь %=" + string(proof_) + {&new-line}) else "") +
  (IF Struct_ <> ? then ("Состав(комплектность)=" + struct_ + {&new-line}) else "") +
  (IF user-rule_ <> ? then ("Правила эксплуатации=" + user-rule_ + {&new-line}) else "") +
  (IF Deadline_ <> ? then ("Срок годности=" + string(deadline_) + {&new-line}) else "") +
  (IF tnved_ <> ? then ("Код ТНВЭД=" + tnved_ + {&new-line}) else "") +
  (IF unit-cst_ <> ? then ("Тамож. ед-ца изм.=" + unit-cst_ + {&new-line}) else "") +
  (IF cst-base-rate_ <> ? then ("Коэффициент к тамож.ед=" + string(cst-base-rate_)
                                                             + {&new-line}) else "") +
  (IF nationality_ <> ? then ("Статус товара(национальность)=" + nationality_ + {&new-line}) else "") +
  (IF alpha1:sensitive then ("Страна изготовления=" + alpha1 + {&new-line}) else "").
  IF br-tt-tax:sensitive then do:
    for each tt-tax:
        mystr = mystr + {&new-line} + "Ставка налога " + string(tt-tax.rate-code)
                + " текущее значение ставки " + string(tt-tax.rate-value).
    end.
  end.

  if REPLACE(mystr, {&new-line}, "")  = "" then do:
    message "Не выбраны поля и значения для внесения изменений" view-as alert-box
    Warning.
    return no-apply.
  end.
  message "В выбранных товарах будут произведены следующие изменения:" skip
  mystr skip "Продолжать?"
  view-as alert-box QUESTION buttons YES-NO update glog.
  IF not glog then return no-apply.
  assign
  v-parameter = "gdsuform":U + {&delim-nws} +
                "":U + {&delim-nws} +
              v-cntxt-obj-type                                                                                    + {&delim-par} +
              string(v-cntxt-obj-code)                                                                            + {&delim-par} +
              string(var-fact-order)                                                                              + {&delim-par} +
              (IF gds-name:sensitive then gds-name else "":U)                                                     + {&delim-par} +
              (IF engl-name:sensitive then engl-name else "":U)                                                   + {&delim-par} +
              (IF label-name:sensitive then label-name else "":U)                                                 + {&delim-par} +
              (IF chk-name:sensitive then chk-name else "":U)                                                     + {&delim-par} +
              (IF alpha1:sensitive then alpha1 else "":U)                                                         + {&delim-par} +
              (IF unit-cli:sensitive then unit-cli else "":U)                                                     + {&delim-par} +
              (IF max-rate:sensitive      then string(max-rate)  else "")                                         + {&delim-par} +
              (IF min-rate:sensitive      then string(min-rate)  else "")                                         + {&delim-par} +
              (IF cli-base-rate:sensitive then string(cli-base-rate) else "")                                     + {&delim-par} +
              (IF qnty-cart:sensitive     then string(qnty-cart) else "")                                         + {&delim-par} +
              (IF ms-base:sensitive       then string(ms-base) else "")                                           + {&delim-par} +
              (IF wt-base:sensitive       then string(wt-base) else "")                                           + {&delim-par} +
              (IF ms-cart:sensitive       then string(ms-cart) else "")                                           + {&delim-par} +
              (IF wt-cart:sensitive       then string(wt-cart) else "")                                           + {&delim-par} +
              (IF v-calc-method:sensitive then v-calc-method   else "")                                           + {&delim-par} +
              (IF increase-pc:sensitive   then string(increase-pc) else "")                                       + {&delim-par} +
              (IF negative-rest:sensitive then string(negative-rest) else "")                                     + {&delim-par} +
              (IF okdp:sensitive          then okdp else "")                                                      + {&delim-par} +
              (IF destin_ <> ?            then destin_ else "")                                                   + {&delim-par} +
              (IF attrib_ <> ?            then attrib_ else "")                                                   + {&delim-par} +
              (IF user-rule_<> ?          then user-rule_ else "")                                                + {&delim-par} +
              (IF sert_ <> ?              then sert_ else "")                                                     + {&delim-par} +
              (IF struct_<> ?             then struct_ else "")                                                   + {&delim-par} +
              (IF deadline_ <> ?          then string(deadline_) else "")                                         + {&delim-par} +
              (IF cond-keep-code_ <> ?    then string(cond-keep-code_) else "")                                   + {&delim-par} +
              (IF sort_ <> ?              then sort_ else "")                                                     + {&delim-par} +
              (IF proof_ <> ?             then string(proof_) else "")                                            + {&delim-par} +              
              (IF normal-wastage_ <> ?    then string(normal-wastage_) else "")                                   + {&delim-par} +
              (IF normal-waste_ <> ?      then string(normal-waste_) else "")                                     + {&delim-par} +
              (IF tnved_ <> ?             then tnved_ else "")                                                    + {&delim-par} +
              (IF nationality_ <> ?       then nationality_ else "")                                              + {&delim-par} +
              (IF unit-cst_ <> ?          then unit-cst_ else "")                                                 + {&delim-par} +
              (IF cst-base-rate_ <> ?     then string(cst-base-rate_) else "")                                    + {&delim-par} +
              /*  пока нет todo
              (IF fbr-grp-code:sensitive  then fbr-grp-code else "")                                              + {&delim-par} +
              */
              "":U                                                                                                + {&delim-par} +
              (IF ps:sensitive            then ps else "")                                                        + {&delim-par} +
              (IF br-tt-tax:sensitive     then string(par-date, "99/99/9999") else "":U)                          + {&delim-par} +
              (IF stts:sensitive          then string(stts) else "")
.
v-parameter = v-parameter + {&delim-nws}.
v-parameter = v-parameter +
              (IF gds-name:sensitive      then "yes" else "no":U)                                                 + {&delim-par} +
              (IF engl-name:sensitive     then "yes" else "no":U)                                                 + {&delim-par} +
              (IF label-name:sensitive    then "yes" else "no":U)                                                 + {&delim-par} +
              (IF chk-name:sensitive      then "yes" else "no":U)                                                 + {&delim-par} +
              (IF alpha1:sensitive        then "yes" else "no":U)                                                 + {&delim-par} +
              (IF unit-cli:sensitive      then "yes" else "no":U)                                                 + {&delim-par} +
              (IF max-rate:sensitive      then "yes" else "no":U)                                                 + {&delim-par} +
              (IF min-rate:sensitive      then "yes" else "no":U)                                                 + {&delim-par} +
              (IF cli-base-rate:sensitive then "yes" else "no":U)                                                 + {&delim-par} +
              (IF qnty-cart:sensitive     then "yes" else "no":U)                                                 + {&delim-par} +
              (IF ms-base:sensitive       then "yes" else "no":U)                                                 + {&delim-par} +
              (IF wt-base:sensitive       then "yes" else "no":U)                                                 + {&delim-par} +
              (IF ms-cart:sensitive       then "yes" else "no":U)                                                 + {&delim-par} +
              (IF wt-cart:sensitive       then "yes" else "no":U)                                                 + {&delim-par} +
              (IF v-calc-method:sensitive then "yes" else "no":U)                                                 + {&delim-par} +
              (IF increase-pc:sensitive   then "yes" else "no":U)                                                 + {&delim-par} +
              (IF negative-rest:sensitive then "yes" else "no":U)                                                 + {&delim-par} +
              (IF okdp:sensitive          then "yes" else "no":U)                                                 + {&delim-par} +
              (IF destin_ <> ?            then "yes" else "no":U)                                                 + {&delim-par} +
              (IF attrib_ <> ?            then "yes" else "no":U)                                                 + {&delim-par} +
              (IF user-rule_ <> ?         then "yes" else "no":U)                                                 + {&delim-par} +
              (IF sert_ <> ?              then "yes" else "no":U)                                                 + {&delim-par} +
              (IF struct_ <> ?            then "yes" else "no":U)                                                 + {&delim-par} +
              (IF deadline_ <> ?          then "yes" else "no":U)                                                 + {&delim-par} +
              (IF cond-keep-code_ <> ?    then "yes" else "no":U)                                                 + {&delim-par} +
              (IF sort_ <> ?              then "yes" else "no":U)                                                 + {&delim-par} +
              (IF proof_ <> ?             then "yes" else "no":U)                                                 + {&delim-par} +              
              (IF normal-wastage_ <> ?    then "yes" else "no":U)                                                 + {&delim-par} +
              (IF normal-waste_ <> ?      then "yes" else "no":U)                                                 + {&delim-par} +
              (IF tnved_ <> ?             then "yes" else "no":U)                                                 + {&delim-par} +
              (IF nationality_ <> ?       then "yes" else "no":U)                                                 + {&delim-par} +
              (IF unit-cst_ <> ?          then "yes" else "no":U)                                                 + {&delim-par} +
              (IF cst-base-rate_ <> ?     then "yes" else "no":U)                                                 + {&delim-par} +
              /* пока нет todo
              (IF fbr-grp-code:sensitive  then "yes" else "no":U)                                                 + {&delim-par} +
              */
              "no":U                                                                                              + {&delim-par} +
              (IF ps:sensitive            then "yes" else "no":U)                                                 + {&delim-par} +
              (IF stts:sensitive          then "yes" else "no":U)                                                 + {&delim-par} +
              (IF br-tt-tax:sensitive     then "yes" else "no":U)
 .

  run str/diallog.w (
                input parparentproc
              , input this-procedure
              , input 'utl/goods01r.p':U
              , input v-parameter
              , input no /*p-auto-go*/
              , input "&Стоп"
              , input 'Изменение товаров по списку') .




END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-grp u-gds-form
ON CHOOSE OF B-grp IN FRAME u-gds-form /* Группа */
DO:
define variable v-grp as character no-undo .
define variable glog as logical no-undo .
    glog = yes.
    message "Выберите группу, в которую нужно переместить товары списка."
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
/*       apply "entry" to b-grp in frame {&frame-name}.*/
       return no-apply.
    end.
    run ref/gds-grp.w (
                   input parparentproc
                  ,input ({&g#term} + ',b-sel')
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input-output v-grp ).
    if v-grp = "" then do:
/*       apply "entry" to b-grp in frame {&frame-name}.*/
       return no-apply.
    end.
    FIND ub.gds-grp WHERE recid (ub.gds-grp) = integer (v-grp) .
    grp-full = "".
    RUN grplib-get-full-name in this-procedure
                                               ( input ub.gds-grp.node-code, output grp-full).
    DISPLAY grp-full with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-list u-gds-form
ON CHOOSE OF b-list IN FRAME u-gds-form /* Список */
DO:
    run str/gds-list.w (
                         input parparentproc
                       , input v-cntxt-host-code-obj
                       , input v-cntxt-obj-type
                       , input v-cntxt-obj-code) .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-prt
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-prt u-gds-form
ON CHOOSE OF b-prt IN FRAME u-gds-form /* Шкала */
DO:
define variable glog as logical no-undo .
define variable ref-rec as recid no-undo .
    message "Выберите шкалу, которую надо приписать товарам списка."
    view-as alert-box question buttons OK-Cancel update glog.
    if not glog then do:
/*      apply "entry" to b-prt in frame {&frame-name}.*/
       return no-apply.
    end.
   run ref/gdsprts.w (
                       input parparentproc
                      ,input yes
                      ,output ref-rec).
   if ref-rec = ? then do:
/*      apply "entry" to b-prt in frame {&frame-name}.*/
      return no-apply.
   end.
   FIND ub.gds-prt WHERE recid (ub.gds-prt) = ref-rec.
   DISPLAY ub.gds-prt.node-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit u-gds-form
ON CHOOSE OF b-quit IN FRAME u-gds-form /* Отмена */
DO:
define variable glog as logical no-undo .
    IF can-find( first gds-list) then do:
        message "Вы действительно хотите выйти (список товаров при этом сохранен не будет)?"
        view-as alert-box WARNING buttons YES-NO update glog.
        if not glog then return no-apply.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-tt-tax
&Scoped-define SELF-NAME BR-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-tt-tax u-gds-form
ON RIGHT-MOUSE-CLICK OF BR-tt-tax IN FRAME u-gds-form /* Ставки налогов */
DO:
    for each tt-tax:
        delete tt-tax.
    end.
    OPEN QUERY br-tt-tax for each tt-tax.
    assign
    l-tt-tax:visible = true.
    display BR-tt-tax with frame {&frame-name}.
    disable
    b-add-tt-tax
    b-del-tt-tax
    br-tt-tax
    with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME chk-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL chk-name u-gds-form
ON RIGHT-MOUSE-CLICK OF chk-name IN FRAME u-gds-form
DO:

    assign
    n-chk-NAME:fgcolor = 15
    chk-NAME = ""
    l-chk-NAME:visible = true.
    display chk-NAME with frame {&frame-name}.
    disable chk-NAME with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-base-rate u-gds-form
ON RIGHT-MOUSE-CLICK OF cli-base-rate IN FRAME u-gds-form
DO:

    assign
    n-cli-base-rate:fgcolor = 15
    cli-base-rate = ?
    l-cli-base-rate:visible = true.
    display cli-base-rate with frame {&frame-name}.
    disable cli-base-rate r-base with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME engl-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL engl-name u-gds-form
ON RIGHT-MOUSE-CLICK OF engl-name IN FRAME u-gds-form
DO:

    assign
    n-ENGL-NAME:fgcolor = 15
    ENGL-NAME = ""
    l-ENGL-NAME:visible = true.
    display ENGL-NAME with frame {&frame-name}.
    disable ENGL-NAME with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME gds-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL gds-name u-gds-form
ON RIGHT-MOUSE-CLICK OF gds-name IN FRAME u-gds-form
DO:

    assign
    n-gds-name:fgcolor = 15
    gds-name = ""
    l-gds-name:visible = true.
    display gds-name with frame {&frame-name}.
    disable gds-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME increase-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL increase-pc u-gds-form
ON RIGHT-MOUSE-CLICK OF increase-pc IN FRAME u-gds-form
DO:

    assign
    n-increase-pc:fgcolor = 15
    increase-pc = ?
    l-increase-pc:visible = true.
    display increase-pc with frame {&frame-name}.
    disable increase-pc with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-alpha1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-alpha1 u-gds-form
ON MOUSE-SELECT-CLICK OF l-alpha1 IN FRAME u-gds-form
DO:
   IF l-alpha1:visible then do:
    assign
    n-alpha1:fgcolor = ?
    l-alpha1:visible = false.
    enable alpha1 with frame {&frame-name}.
    enable r-alpha1 with frame {&frame-name}.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-calc-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-calc-method u-gds-form
ON MOUSE-SELECT-CLICK OF l-calc-method IN FRAME u-gds-form
DO:
  IF l-calc-method:visible then do:
    assign
    v-calc-method:fgcolor = ?
    l-calc-method:visible = false.
    enable v-calc-method with frame {&frame-name}.
    APPLY "ENTRY" TO v-calc-method.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-chk-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-chk-name u-gds-form
ON MOUSE-SELECT-CLICK OF l-chk-name IN FRAME u-gds-form
DO:
   IF l-chk-NAME:visible then do:
    assign
    n-chk-NAME:fgcolor = ?
    l-chk-NAME:visible = false.
    enable chk-NAME with frame {&frame-name}.
    APPLY "ENTRY" TO chk-name.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-cli-base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-cli-base-rate u-gds-form
ON MOUSE-SELECT-CLICK OF l-cli-base-rate IN FRAME u-gds-form
DO:
   IF l-cli-base-rate:visible then do:
    assign
    n-cli-base-rate:fgcolor = ?
    l-cli-base-rate:visible = false.
    enable cli-base-rate r-base with frame {&frame-name}.
    APPLY "ENTRY" TO cli-base-rate.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-engl-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-engl-name u-gds-form
ON MOUSE-SELECT-CLICK OF l-engl-name IN FRAME u-gds-form
DO:
   IF l-ENGL-NAME:visible then do:
    assign
    n-ENGL-NAME:fgcolor = ?
    l-ENGL-NAME:visible = false.
    enable ENGL-NAME with frame {&frame-name}.
    APPLY "ENTRY" TO engl-name.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-gds-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-gds-name u-gds-form
ON MOUSE-SELECT-CLICK OF l-gds-name IN FRAME u-gds-form
DO:
   IF l-gds-name:visible then do:
    assign
    n-gds-name:fgcolor = ?
    l-gds-name:visible = false.
    enable gds-name with frame {&frame-name}.
    APPLY "ENTRY" TO gds-name.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-grp-full
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-grp-full u-gds-form
ON MOUSE-SELECT-CLICK OF l-grp-full IN FRAME u-gds-form
DO:
  message "Редактирование этого поля в пакетном режиме еще не реализовано!"
  view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-increase-pc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-increase-pc u-gds-form
ON MOUSE-SELECT-CLICK OF l-increase-pc IN FRAME u-gds-form
DO:
   IF l-increase-pc:visible then do:
    assign
    n-increase-pc:fgcolor = ?
    l-increase-pc:visible = false.
    enable increase-pc with frame {&frame-name}.
    APPLY "ENTRY" TO increase-pc.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-increase-pc u-gds-form
ON RIGHT-MOUSE-CLICK OF l-increase-pc IN FRAME u-gds-form
DO:
  IF l-increase-pc:visible then do:
    assign
    n-increase-pc:fgcolor = ?
    l-increase-pc:visible = false.
    enable increase-pc with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-label-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-label-name u-gds-form
ON MOUSE-SELECT-CLICK OF l-label-name IN FRAME u-gds-form
DO:
   IF l-label-NAME:visible then do:
    assign
    n-label-NAME:fgcolor = ?
    l-label-NAME:visible = false.
    enable label-NAME with frame {&frame-name}.
    APPLY "ENTRY" TO label-name.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-max-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-max-rate u-gds-form
ON MOUSE-SELECT-CLICK OF l-max-rate IN FRAME u-gds-form
DO:
   IF l-max-rate:visible then do:
    assign
    n-max-rate:fgcolor = ?
    l-max-rate:visible = false.
    enable max-rate with frame {&frame-name}.
    APPLY "ENTRY" TO max-rate.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-min-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-min-rate u-gds-form
ON MOUSE-SELECT-CLICK OF l-min-rate IN FRAME u-gds-form
DO:
   IF l-min-rate:visible then do:
    assign
    n-min-rate:fgcolor = ?
    l-min-rate:visible = false.
    enable min-rate with frame {&frame-name}.
    APPLY "ENTRY" TO min-rate.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-ms-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-ms-base u-gds-form
ON MOUSE-SELECT-CLICK OF l-ms-base IN FRAME u-gds-form
DO:
   IF l-ms-base:visible then do:
    assign
    n-ms-base:fgcolor = ?
    l-ms-base:visible = false.
    enable ms-base with frame {&frame-name}.
    APPLY "ENTRY" TO ms-base.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-ms-cart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-ms-cart u-gds-form
ON MOUSE-SELECT-CLICK OF l-ms-cart IN FRAME u-gds-form
DO:
   IF l-ms-cart:visible then do:
    assign
    n-ms-cart:fgcolor = ?
    l-ms-cart:visible = false.
    enable ms-cart with frame {&frame-name}.
    APPLY "ENTRY" TO ms-cart.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-negative-rest
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-negative-rest u-gds-form
ON MOUSE-SELECT-CLICK OF l-negative-rest IN FRAME u-gds-form
DO:
   IF l-negative-rest:visible then do:
    assign
    negative-rest:fgcolor = ?
    l-negative-rest:visible = false.
    enable negative-rest with frame {&frame-name}.
    APPLY "ENTRY" TO negative-rest.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-node-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-node-name u-gds-form
ON MOUSE-SELECT-CLICK OF l-node-name IN FRAME u-gds-form
DO:
  message "Редактирование этого поля в пакетном режиме еще не реализовано!"
  view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-okdp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-okdp u-gds-form
ON MOUSE-SELECT-CLICK OF l-okdp IN FRAME u-gds-form
DO:
   IF l-okdp:visible then do:
    assign
    n-okdp:fgcolor = ?
    l-okdp:visible = false.
    enable okdp with frame {&frame-name}.
    APPLY "ENTRY" TO okdp.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-PS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-PS u-gds-form
ON MOUSE-SELECT-CLICK OF l-PS IN FRAME u-gds-form
DO:
   IF l-PS:visible then do:
    assign
    n-PS:fgcolor = ?
    l-PS:visible = false.
    enable PS with frame {&frame-name}.
    APPLY "ENTRY" TO ps.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-qnty-cart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-qnty-cart u-gds-form
ON MOUSE-SELECT-CLICK OF l-qnty-cart IN FRAME u-gds-form
DO:
   IF l-qnty-cart:visible then do:
    assign
    n-qnty-cart:fgcolor = ?
    l-qnty-cart:visible = false.
    enable qnty-cart with frame {&frame-name}.
    APPLY "ENTRY" TO qnty-cart.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-stts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-stts u-gds-form
ON MOUSE-SELECT-CLICK OF l-stts IN FRAME u-gds-form
DO:
   IF l-stts:visible then do:
    assign
    stts:fgcolor = ?
    l-stts:visible = false.
    enable stts with frame {&frame-name}.
    APPLY "ENTRY" TO stts.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-tt-tax
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-tt-tax u-gds-form
ON MOUSE-SELECT-CLICK OF l-tt-tax IN FRAME u-gds-form
DO:
   IF l-tt-tax:visible then do:
    assign
    l-tt-tax:visible = false.
    enable
    br-tt-tax
    B-add-tt-tax
    b-del-tt-tax
    with frame {&frame-name}.
    APPLY "ENTRY" TO browse br-tt-tax.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-unit-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-unit-cli u-gds-form
ON MOUSE-SELECT-CLICK OF l-unit-cli IN FRAME u-gds-form
DO:
   IF l-unit-cli:visible then do:
    assign
    n-unit-cli:fgcolor = ?
    l-unit-cli:visible = false.
    enable unit-cli with frame {&frame-name}.
    enable r-base with frame {&frame-name}.
    APPLY "ENTRY" TO unit-cli.

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-wt-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-wt-base u-gds-form
ON MOUSE-SELECT-CLICK OF l-wt-base IN FRAME u-gds-form
DO:
   IF l-wt-base:visible then do:
    assign
    n-wt-base:fgcolor = ?
    l-wt-base:visible = false.
    enable wt-base with frame {&frame-name}.
    APPLY "ENTRY" TO wt-base.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-wt-cart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-wt-cart u-gds-form
ON MOUSE-SELECT-CLICK OF l-wt-cart IN FRAME u-gds-form
DO:
   IF l-wt-cart:visible then do:
    assign
    n-wt-cart:fgcolor = ?
    l-wt-cart:visible = false.
    enable wt-cart with frame {&frame-name}.
    APPLY "ENTRY" TO wt-cart.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME label-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL label-name u-gds-form
ON RIGHT-MOUSE-CLICK OF label-name IN FRAME u-gds-form
DO:

    assign
    n-label-NAME:fgcolor = 15
    label-NAME = ""
    l-label-NAME:visible = true.
    display label-NAME with frame {&frame-name}.
    disable label-NAME with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME max-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL max-rate u-gds-form
ON RIGHT-MOUSE-CLICK OF max-rate IN FRAME u-gds-form
DO:

    assign
    n-max-rate:fgcolor = 15
    max-rate = ?
    l-max-rate:visible = true.
    display max-rate with frame {&frame-name}.
    disable max-rate with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME min-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL min-rate u-gds-form
ON RIGHT-MOUSE-CLICK OF min-rate IN FRAME u-gds-form
DO:

    assign
    n-min-rate:fgcolor = 15
    min-rate = ?
    l-min-rate:visible = true.
    display min-rate with frame {&frame-name}.
    disable min-rate with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ms-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ms-base u-gds-form
ON RIGHT-MOUSE-CLICK OF ms-base IN FRAME u-gds-form
DO:

    assign
    n-ms-base:fgcolor = 15
    ms-base = ?
    l-ms-base:visible = true.
    display ms-base with frame {&frame-name}.
    disable ms-base with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ms-cart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ms-cart u-gds-form
ON RIGHT-MOUSE-CLICK OF ms-cart IN FRAME u-gds-form
DO:

    assign
    n-ms-cart:fgcolor = 15
    ms-cart = ?
    l-ms-cart:visible = true.
    display ms-cart with frame {&frame-name}.
    disable ms-cart with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME negative-rest
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL negative-rest u-gds-form
ON RIGHT-MOUSE-CLICK OF negative-rest IN FRAME u-gds-form /* Отрицательные остатки */
DO:
     assign
    negative-rest:fgcolor = 15
    negative-rest = false
    l-negative-rest:visible = true.
    display negative-rest with frame {&frame-name}.
    disable negative-rest with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME OKDP
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL OKDP u-gds-form
ON RIGHT-MOUSE-CLICK OF OKDP IN FRAME u-gds-form
DO:
   assign
    n-okdp:fgcolor = 15
    okdp = ""
    l-okdp:visible = true.
    display okdp with frame {&frame-name}.
    disable okdp with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME PS
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL PS u-gds-form
ON RIGHT-MOUSE-CLICK OF PS IN FRAME u-gds-form
DO:

    assign
    n-PS:fgcolor = 15
    PS = ""
    l-PS:visible = true.
    display PS with frame {&frame-name}.
    disable PS with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME qnty-cart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL qnty-cart u-gds-form
ON RIGHT-MOUSE-CLICK OF qnty-cart IN FRAME u-gds-form
DO:

    assign
    n-qnty-cart:fgcolor = 15
    qnty-cart = ?
    l-qnty-cart:visible = true.
    display qnty-cart with frame {&frame-name}.
    disable qnty-cart with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-alpha1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-alpha1 u-gds-form
ON CHOOSE OF r-alpha1 IN FRAME u-gds-form
DO:
define variable v-rid-list as character no-undo .
    run ref/countris.w (
                    input parparentproc
                   ,input "b-sel"
                ,input-output v-rid-list ).
if v-rid-list <> '' then do:
            apply "entry" to r-alpha1 in frame {&frame-name}.
            return no-apply.
    end.
    FIND ub.country WHERE recid (ub.country) = integer(v-rid-list) NO-LOCK.
    DISPLAY ub.country.alpha1 @ alpha1
                    ub.country.short-name @ country_name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-base u-gds-form
ON CHOOSE OF r-base IN FRAME u-gds-form
DO:
define variable v-ref-rec as recid .
run ref/units.w ( input parparentproc
                , input yes
                , output v-ref-rec ).
if v-ref-rec = ? then do:
  apply "entry" to r-base in frame {&frame-name}.
  return no-apply.
end.
FIND ub.units WHERE recid (ub.units) = v-ref-rec NO-LOCK.
DISPLAY ub.units.unit-name @ unit-cli with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME stts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL stts u-gds-form
ON RIGHT-MOUSE-CLICK OF stts IN FRAME u-gds-form /* Удаленный товар? */
DO:
      assign
    stts:fgcolor = 15
    stts = false
    l-stts:visible = true.
    display stts with frame {&frame-name}.
    disable stts with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME unit-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL unit-cli u-gds-form
ON LEAVE OF unit-cli IN FRAME u-gds-form
DO:
    APPLY "RETURN" to unit-cli.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL unit-cli u-gds-form
ON RETURN OF unit-cli IN FRAME u-gds-form
DO:
define variable ref-rec as recid no-undo .
  if not can-find( ub.units where
                            ub.units.unit-name = input frame {&frame-name} unit-cli ) then do:

     run ref/units.w (
                       input parparentproc
                      ,input yes
                      ,output ref-rec ).
     if ref-rec = ? then   do:
                    apply "entry" to unit-cli in frame {&frame-name}.
                    return no-apply.
      end.
      FIND ub.units WHERE recid (ub.units) = ref-rec NO-LOCK.
      DISPLAY ub.units.unit-name @ unit-cli with frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL unit-cli u-gds-form
ON RIGHT-MOUSE-CLICK OF unit-cli IN FRAME u-gds-form
DO:

    assign
    n-unit-cli:fgcolor = 15
    unit-cli = ""
    l-unit-cli:visible = true.
    display unit-cli with frame {&frame-name}.
    disable unit-cli with frame {&frame-name}.
    disable r-base with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-calc-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-calc-method u-gds-form
ON RIGHT-MOUSE-CLICK OF v-calc-method IN FRAME u-gds-form
DO:
   assign
    v-calc-method:fgcolor = 15
    v-calc-method = {&pr-calc-cost}
    l-calc-method:visible = true.
    display v-calc-method with frame {&frame-name}.
    disable v-calc-method with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME wt-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wt-base u-gds-form
ON RIGHT-MOUSE-CLICK OF wt-base IN FRAME u-gds-form
DO:

    assign
    n-wt-base:fgcolor = 15
    wt-base = ?
    l-wt-base:visible = true.
    display wt-base with frame {&frame-name}.
    disable wt-base with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME wt-cart
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL wt-cart u-gds-form
ON RIGHT-MOUSE-CLICK OF wt-cart IN FRAME u-gds-form
DO:

    assign
    n-wt-cart:fgcolor = 15
    wt-cart = ?
    l-wt-cart:visible = true.
    display wt-cart with frame {&frame-name}.
    disable wt-cart with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK u-gds-form


/* ***************************  Main Block  *************************** */

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
   FIND ub.db WHERE ub.db.db-num = v-cntxt-db-num NO-LOCK .
   IF NOT ub.db.add-goods then do:
        message "В данной БД не разрешено изменять товары!" view-as alert-box ERROR.
        return.
   end.
   FIND ub.sysconf WHERE ub.sysconf.host-code = v-cntxt-host-code-obj NO-LOCK .
  RUN MyEnable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI u-gds-form  _DEFAULT-DISABLE
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
  HIDE FRAME u-gds-form.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI u-gds-form  _DEFAULT-ENABLE
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
  DISPLAY gds-name alpha1 engl-name label-name chk-name OKDP ms-base unit-cli
          v-calc-method wt-base min-rate cli-base-rate ms-cart qnty-cart
          increase-pc wt-cart max-rate PS negative-rest stts EDITOR-1 n-grp-full
          grp-full FILL-IN-4 n-gds-name n-engl-name country_name n-alpha1
          n-label-name n-chk-name n-okdp n-ms-base n-unit-cli n-min-rate
          n-wt-base n-increase-pc n-cli-base-rate n-ms-cart n-max-rate
          n-qnty-cart n-wt-cart n-PS
      WITH FRAME u-gds-form.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.node-name
      WITH FRAME u-gds-form.
  ENABLE b-exit l-negative-rest l-grp-full l-okdp l-max-rate l-tt-tax l-PS
         l-gds-name l-engl-name l-alpha1 l-wt-cart l-cli-base-rate l-ms-cart
         l-min-rate l-unit-cli l-qnty-cart l-calc-method l-increase-pc
         l-node-name l-stts l-chk-name l-label-name l-wt-base l-ms-base b-quit
         b-list b-help add-inf EDITOR-1 n-grp-full grp-full FILL-IN-4
         ub.gds-prt.node-name n-gds-name n-engl-name n-alpha1 n-label-name
         n-chk-name n-okdp n-ms-base n-unit-cli n-min-rate n-wt-base
         n-increase-pc n-cli-base-rate n-ms-cart n-max-rate n-qnty-cart
         n-wt-cart n-PS
      WITH FRAME u-gds-form.
  VIEW FRAME u-gds-form.
  {&OPEN-BROWSERS-IN-QUERY-u-gds-form}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable u-gds-form
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

define variable p-list as character no-undo .
run str/pr-listv.p (
                 input {&pr-calc-methods-list}
               , input "":U
               , output p-list) .
v-calc-method:list-items in frame {&frame-name}  = p-list .

  DISPLAY gds-name alpha1 engl-name label-name chk-name OKDP qnty-cart
          v-calc-method unit-cli ms-base wt-base ms-cart wt-cart cli-base-rate increase-pc PS
          negative-rest stts EDITOR-1 n-grp-full grp-full FILL-IN-4 n-gds-name
          n-engl-name country_name n-alpha1 n-label-name n-chk-name n-okdp
          n-qnty-cart n-unit-cli n-ms-base n-wt-base n-ms-cart n-wt-cart n-cli-base-rate
          n-increase-pc n-PS
          max-rate min-rate
          n-max-rate n-min-rate
      WITH FRAME u-gds-form.
  IF AVAILABLE ub.gds-prt THEN
    DISPLAY ub.gds-prt.node-name
      WITH FRAME u-gds-form.
  ENABLE b-exit b-list b-quit b-help add-inf l-grp-full l-node-name
         l-gds-name l-engl-name l-alpha1 l-label-name l-chk-name l-okdp
         l-qnty-cart l-calc-method
         l-unit-cli l-ms-base l-wt-base l-ms-cart l-cli-base-rate l-wt-cart l-increase-pc l-tt-tax
         l-PS l-negative-rest l-stts EDITOR-1 n-grp-full grp-full FILL-IN-4
         gds-prt.node-name n-gds-name n-engl-name n-alpha1 n-label-name
         n-chk-name n-okdp n-qnty-cart n-unit-cli n-ms-base n-wt-base n-ms-cart n-wt-cart
         n-cli-base-rate n-increase-pc n-PS
         n-max-rate n-min-rate
      WITH FRAME u-gds-form.
  VIEW FRAME u-gds-form.
  {&OPEN-BROWSERS-IN-QUERY-u-gds-form}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME