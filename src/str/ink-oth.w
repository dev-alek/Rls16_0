&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 16/11/05
Author: Bakhtadze Natalya
Creation date: 16/11/05


Author: ?, модификатор Черных В.
Created: 09/10/95 -  5:54 pm

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as WIDGET-HANDLE NO-UNDO.
define input parameter inp-inkas-code like ub.trn-doc.doc-code.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по выручке".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ str/inkas-ps.i }
{ str/trdcalib.i }
{ gbl/getcntxt.i def }
/* Local variable Definitions ---                                       */

define variable gds-amount    as integer   no-undo.
define variable chk-amount    as integer   no-undo.
define variable line-out      as integer   no-undo.
define variable line-ret      as integer   no-undo.
define variable dtl-out       as integer   no-undo.
define variable dtl-ret       as integer   no-undo.
define variable nf-chk-amount as integer   no-undo.
define variable nf-gds-amount as integer   no-undo.
define variable ps-where-rus  as character no-undo.
define variable glog          as logical   no-undo.
define variable v-doc-rec     as recid     no-undo .

define variable pay-tot-rubl  as decimal   no-undo .
define variable pay-desk-tot-rubl as decimal no-undo .

define variable pay-tot-rubl-return      as decimal no-undo .
define variable pay-desk-tot-rubl-return as decimal no-undo .
define variable v-exist-autotank         as logical no-undo .
define variable a-sum-return             as decimal no-undo .
define TEMP-TABLE temp-inkas-cash-desk no-undo
FIELD inkas-code as character
FIELD pay-desk   as integer
FIELD tot-base   as decimal
FIELD tot-rubl   as decimal
FIELD tot-rubl-return as decimal
    INDEX pi IS UNIQUE PRIMARY
inkas-code pay-desk.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DIALOG-1
&Scoped-define BROWSE-NAME BR-cash-desk

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-inkas-cash-desk ub.inkas-pay ~
ub.cash-pay ub.currency ub.inkas-pay-desk

/* Definitions for BROWSE BR-cash-desk                                  */
&Scoped-define FIELDS-IN-QUERY-BR-cash-desk temp-inkas-cash-desk.pay-desk temp-inkas-cash-desk.tot-rubl + temp-inkas-cash-desk.tot-rubl-return temp-inkas-cash-desk.tot-rubl temp-inkas-cash-desk.tot-rubl-return temp-inkas-cash-desk.tot-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-cash-desk
&Scoped-define SELF-NAME BR-cash-desk
&Scoped-define QUERY-STRING-BR-cash-desk FOR EACH temp-inkas-cash-desk
&Scoped-define OPEN-QUERY-BR-cash-desk OPEN QUERY {&SELF-NAME} FOR EACH temp-inkas-cash-desk.
&Scoped-define TABLES-IN-QUERY-BR-cash-desk temp-inkas-cash-desk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-cash-desk temp-inkas-cash-desk


/* Definitions for BROWSE BR-INKAS-PAY                                  */
&Scoped-define FIELDS-IN-QUERY-BR-INKAS-PAY ub.cash-pay.obj-name ~
ub.currency.curr-abbr pay-tot-rubl ub.inkas-pay.tot-rubl ~
pay-tot-rubl-return ub.inkas-pay.tot-sum ub.inkas-pay.tot-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-INKAS-PAY
&Scoped-define QUERY-STRING-BR-INKAS-PAY FOR EACH ub.inkas-pay ~
      WHERE ub.inkas-pay.inkas-code = inp-inkas-code NO-LOCK, ~
      FIRST ub.cash-pay WHERE ub.cash-pay.cdpay-code = inkas-pay.pay-code AND ~
ub.cash-pay.curr-code = ub.inkas-pay.curr-code NO-LOCK, ~
      FIRST ub.currency WHERE ub.currency.curr-code = ub.inkas-pay.curr-code NO-LOCK
&Scoped-define OPEN-QUERY-BR-INKAS-PAY OPEN QUERY BR-INKAS-PAY FOR EACH ub.inkas-pay ~
      WHERE ub.inkas-pay.inkas-code = inp-inkas-code NO-LOCK, ~
      FIRST ub.cash-pay WHERE ub.cash-pay.cdpay-code = ub.inkas-pay.pay-code AND ~
ub.cash-pay.curr-code = ub.inkas-pay.curr-code NO-LOCK, ~
      FIRST ub.currency WHERE ub.currency.curr-code = ub.inkas-pay.curr-code NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-INKAS-PAY ub.inkas-pay ub.cash-pay ~
ub.currency
&Scoped-define FIRST-TABLE-IN-QUERY-BR-INKAS-PAY ub.inkas-pay
&Scoped-define SECOND-TABLE-IN-QUERY-BR-INKAS-PAY ub.cash-pay
&Scoped-define THIRD-TABLE-IN-QUERY-BR-INKAS-PAY ub.currency


/* Definitions for BROWSE BR-pay-desk                                   */
&Scoped-define FIELDS-IN-QUERY-BR-pay-desk ub.inkas-pay-desk.pay-desk ~
ub.inkas-pay-desk.cashier ~
get-cash-pay(ub.inkas-pay-desk.pay-code, ub.inkas-pay-desk.curr-code) ~
pay-desk-tot-rubl ub.inkas-pay-desk.tot-rubl ~
get-currency(ub.inkas-pay-desk.curr-code) ub.inkas-pay-desk.tot-sum ~
get-chk-type(ub.inkas-pay-desk.doc-type) ub.inkas-pay-desk.tot-base
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-pay-desk
&Scoped-define QUERY-STRING-BR-pay-desk FOR EACH ub.inkas-pay-desk ~
      WHERE ub.inkas-pay-desk.inkas-code = inp-inkas-code ~
 AND ub.inkas-pay-desk.pay-code = ub.inkas-pay.pay-code ~
 AND ub.inkas-pay-desk.curr-code = ub.inkas-pay.curr-code NO-LOCK ~
    BY ub.inkas-pay-desk.pay-code
&Scoped-define OPEN-QUERY-BR-pay-desk OPEN QUERY BR-pay-desk FOR EACH ub.inkas-pay-desk ~
      WHERE ub.inkas-pay-desk.inkas-code = inp-inkas-code ~
 AND ub.inkas-pay-desk.pay-code = ub.inkas-pay.pay-code ~
 AND ub.inkas-pay-desk.curr-code = ub.inkas-pay.curr-code NO-LOCK ~
    BY ub.inkas-pay-desk.pay-code.
&Scoped-define TABLES-IN-QUERY-BR-pay-desk ub.inkas-pay-desk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-pay-desk ub.inkas-pay-desk


/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-DIALOG-1 ~
    ~{&OPEN-QUERY-BR-cash-desk}~
    ~{&OPEN-QUERY-BR-INKAS-PAY}~
    ~{&OPEN-QUERY-BR-pay-desk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-print B-help BR-INKAS-PAY ~
BR-pay-desk BR-cash-desk
&Scoped-Define DISPLAYED-FIELDS ub.inkas.tot-doc ub.inkas.num-chk ~
ub.inkas.discnt ub.inkas.sub-discnt
&Scoped-define DISPLAYED-TABLES ub.inkas
&Scoped-define FIRST-DISPLAYED-TABLE ub.inkas
&Scoped-Define DISPLAYED-OBJECTS f% f-num-chk g-discnt autotank-sum-return ~
fnetto accumpay

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cash-pay DIALOG-1
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input p-pay-code as integer, input p-curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-chk-type DIALOG-1
FUNCTION get-chk-type RETURNS CHARACTER
  ( input par-doc-type as character )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-currency DIALOG-1
FUNCTION get-currency RETURNS CHARACTER
  ( input p-curr-code as integer )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "&Выход "
     SIZE 10 BY 1.

DEFINE BUTTON B-help 
     LABEL "Помо&щь"
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "&Печать"
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 0 .

define variable accumpay as decimal FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Выручка"
     VIEW-AS FILL-IN 
     SIZE 20 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE autotank-sum-return AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0 
     LABEL "разн.по запр.за нал"
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE f% AS DECIMAL FORMAT "->>9.<%":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 8 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-num-chk AS INTEGER FORMAT ">>>>9":U INITIAL 0 
     LABEL "фискальных"
     VIEW-AS FILL-IN 
     SIZE 6.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fnetto AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Нетто"
     VIEW-AS FILL-IN 
     SIZE 20 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE g-discnt AS DECIMAL FORMAT "->>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "В т.ч. товарная"
     VIEW-AS FILL-IN 
     SIZE 20 BY 1
     FGCOLOR 0  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-cash-desk FOR 
      temp-inkas-cash-desk SCROLLING.

DEFINE QUERY BR-INKAS-PAY FOR 
      ub.inkas-pay,
      ub.cash-pay,
      ub.currency SCROLLING.

DEFINE QUERY BR-pay-desk FOR 
      ub.inkas-pay-desk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-cash-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-cash-desk DIALOG-1 _FREEFORM
  QUERY BR-cash-desk DISPLAY
      temp-inkas-cash-desk.pay-desk FORMAT ">>>9" WIDTH 5 COLUMN-LABEL "Касса"
temp-inkas-cash-desk.tot-rubl + temp-inkas-cash-desk.tot-rubl-return
          FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Выручка(руб.)"
temp-inkas-cash-desk.tot-rubl FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "abbr_rub_firstshift.эквивалент"
temp-inkas-cash-desk.tot-rubl-return
          FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "Разн.по запр.за нал"
temp-inkas-cash-desk.tot-base FORMAT "->>>,>>>,>>>,>>9.99" COLUMN-LABEL "В баз.вал."
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 74.5 BY 5.46
         BGCOLOR 8 FONT 4
         TITLE BGCOLOR 8 "Выручка по кассам ОБЩАЯ" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.

DEFINE BROWSE BR-INKAS-PAY
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-INKAS-PAY DIALOG-1 _STRUCTURED
  QUERY BR-INKAS-PAY NO-LOCK DISPLAY
      ub.cash-pay.obj-name FORMAT "X(25)":U
      ub.currency.curr-abbr FORMAT "X(3)":U
      pay-tot-rubl COLUMN-LABEL "Выручка(руб.)" FORMAT "->>>,>>>,>>9.99":U
      ub.inkas-pay.tot-rubl COLUMN-LABEL "abbr_rub_firstshift.эквивалент" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 15
      pay-tot-rubl-return COLUMN-LABEL "Разн.по запр.за нал" FORMAT "->>>,>>>,>>9.99":U
      ub.inkas-pay.tot-sum FORMAT "->>>,>>>,>>9.99":U
      ub.inkas-pay.tot-base FORMAT "->>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 85 BY 8
         FONT 4
         TITLE "Выручка по типам  кассовых платежей" ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.

DEFINE BROWSE BR-pay-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-pay-desk DIALOG-1 _STRUCTURED
  QUERY BR-pay-desk DISPLAY
      ub.inkas-pay-desk.pay-desk FORMAT ">>>9":U
      ub.inkas-pay-desk.cashier FORMAT ">>>>9":U
      get-cash-pay(inkas-pay-desk.pay-code, inkas-pay-desk.curr-code) COLUMN-LABEL "Название" FORMAT "X(22)":U
      pay-desk-tot-rubl COLUMN-LABEL "Выручка(руб.)" FORMAT "->>>>>>>>9.99":U
      ub.inkas-pay-desk.tot-rubl COLUMN-LABEL "abbr_rub_firstshift.эквивалент" FORMAT "->>>,>>>,>>9.99":U
      get-currency(inkas-pay-desk.curr-code) COLUMN-LABEL "Вал" FORMAT "X(3)":U
      ub.inkas-pay-desk.tot-sum FORMAT "->>>,>>>,>>9.99":U
      get-chk-type(inkas-pay-desk.doc-type) COLUMN-LABEL "Операция" FORMAT "X(8)":U
      ub.inkas-pay-desk.tot-base FORMAT "->>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         FONT 4
         TITLE "Выручка по кассам по типам кассовых платежей" ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     ub.inkas.tot-doc AT ROW 1 COL 42 COLON-ALIGNED
          LABEL "Сумма товарная"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          FGCOLOR 4
     b-print AT ROW 1 COL 92
     B-help AT ROW 1 COL 95
     ub.inkas.num-chk AT ROW 2 COL 16 COLON-ALIGNED
          LABEL "Чеков"
          VIEW-AS FILL-IN 
          SIZE 6.25 BY 1
          FGCOLOR 4
     ub.inkas.discnt AT ROW 2 COL 42 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          FGCOLOR 4
     f% AT ROW 2 COL 76 COLON-ALIGNED NO-LABEL
     f-num-chk AT ROW 3 COL 16 COLON-ALIGNED
     g-discnt AT ROW 3 COL 42 COLON-ALIGNED
     ub.inkas.sub-discnt AT ROW 3 COL 76 COLON-ALIGNED
          LABEL "Списания"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
          FGCOLOR 0
     autotank-sum-return AT ROW 4 COL 20 COLON-ALIGNED WIDGET-ID 2
     fnetto AT ROW 4 COL 42 COLON-ALIGNED
     accumpay AT ROW 4 COL 76 COLON-ALIGNED
     BR-INKAS-PAY AT ROW 5 COL 10
     BR-pay-desk AT ROW 13 COL 1
     BR-cash-desk AT ROW 19 COL 17 WIDGET-ID 100
     SPACE(8.09) SKIP(0.01)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Отчет о выручке":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-INKAS-PAY accumpay DIALOG-1 */
/* BROWSE-TAB BR-pay-desk BR-INKAS-PAY DIALOG-1 */
/* BROWSE-TAB BR-cash-desk BR-pay-desk DIALOG-1 */
ASSIGN 
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR FILL-IN accumpay IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN autotank-sum-return IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN 
       BR-INKAS-PAY:NUM-LOCKED-COLUMNS IN FRAME DIALOG-1     = 1.

/* SETTINGS FOR FILL-IN ub.inkas.discnt IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f% IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-num-chk IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fnetto IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN g-discnt IN FRAME DIALOG-1
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ub.inkas.num-chk IN FRAME DIALOG-1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.inkas.sub-discnt IN FRAME DIALOG-1
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN ub.inkas.tot-doc IN FRAME DIALOG-1
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-cash-desk
/* Query rebuild information for BROWSE BR-cash-desk
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-inkas-cash-desk.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-cash-desk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-INKAS-PAY
/* Query rebuild information for BROWSE BR-INKAS-PAY
     _TblList          = "ub.inkas-pay,ub.cash-pay WHERE ub.inkas-pay ...,ub.currency WHERE ub.inkas-pay ..."
     _Options          = "NO-LOCK"
     _TblOptList       = ", FIRST, FIRST"
     _Where[1]         = "ub.inkas-pay.inkas-code = inp-inkas-code"
     _JoinCode[2]      = "cash-pay.cdpay-code = inkas-pay.pay-code AND
cash-pay.curr-code = inkas-pay.curr-code"
     _JoinCode[3]      = "currency.curr-code = inkas-pay.curr-code"
     _FldNameList[1]   > ub.cash-pay.obj-name
"cash-pay.obj-name" ? "X(25)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = ub.currency.curr-abbr
     _FldNameList[3]   > "_<CALC>"
"pay-tot-rubl" "Выручка(руб.)" "->>>,>>>,>>9.99" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > ub.inkas-pay.tot-rubl
"ub.inkas-pay.tot-rubl" "abbr_rub_firstshift.эквивалент" ? "decimal" ? ? ? ? ? ? no ? no no "15" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"pay-tot-rubl-return" "Разн.по запр.за нал" "->>>,>>>,>>9.99" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   = ub.inkas-pay.tot-sum
     _FldNameList[7]   = ub.inkas-pay.tot-base
     _Query            is OPENED
*/  /* BROWSE BR-INKAS-PAY */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-pay-desk
/* Query rebuild information for BROWSE BR-pay-desk
     _TblList          = "ub.inkas-pay-desk"
     _OrdList          = "ub.inkas-pay-desk.pay-code|yes"
     _Where[1]         = "inkas-pay-desk.inkas-code = inp-inkas-code
 AND inkas-pay-desk.pay-code = inkas-pay.pay-code
 AND inkas-pay-desk.curr-code = inkas-pay.curr-code"
     _FldNameList[1]   = ub.inkas-pay-desk.pay-desk
     _FldNameList[2]   > ub.inkas-pay-desk.cashier
"cashier" ? ">>>>9" "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"get-cash-pay(inkas-pay-desk.pay-code, inkas-pay-desk.curr-code)" "Название" "X(22)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"pay-desk-tot-rubl" "Выручка(руб.)" ">>>>>>>>9.99" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > ub.inkas-pay-desk.tot-rubl
"tot-rubl" "abbr_rub_firstshift.эквивалент" ? "decimal" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"get-currency(inkas-pay-desk.curr-code)" "Вал" "X(3)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[7]   = ub.inkas-pay-desk.tot-sum
     _FldNameList[8]   > "_<CALC>"
"get-chk-type(inkas-pay-desk.doc-type)" "Операция" "X(8)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[9]   = ub.inkas-pay-desk.tot-base
     _Query            is OPENED
*/  /* BROWSE BR-pay-desk */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX DIALOG-1
/* Query rebuild information for DIALOG-BOX DIALOG-1
     _Options          = "SHARE-LOCK KEEP-EMPTY"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX DIALOG-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print DIALOG-1
ON CHOOSE OF b-print IN FRAME DIALOG-1 /* Печать */
DO:

define variable sym1 as character init ":"   no-undo.
define variable sym3 as character init ":"   no-undo.
define variable sym4 as character init ":"   no-undo.
define variable sym5 as character init ":"   no-undo.
define variable sym6 as character init ":"   no-undo.
define variable sym8 as character init ":"   no-undo.
define variable Log-Res     as  logical      no-undo.
define variable Line        as  character    no-undo.
define variable date_string as  character    no-undo.
define variable v-base-code LIKE ub.sysconf.base-code no-undo.

define BUFFER buf_currency FOR ub.currency.
define buffer b-ink-pay    for ub.inkas-pay .

{ gbl/basecode.i inkas.host-code v-base-code }
FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = v-base-code.

DEFINE FRAME Benefit-Tot
sym1 column-label ":" format "X(1)"
ub.cash-pay.obj-name column-label "Вид оплаты" format "X(30)"
sym3 column-label ":" format "X(1)"
ub.currency.curr-name column-label "Валюта" format "X(20)"
sym4 column-label ":" format "X(1)"
b-ink-pay.tot-sum column-label "Сумма (в валюте)" format "->,>>>,>>>,>>>,>>9.99"
sym5 column-label ":" format "X(1)"
b-ink-pay.tot-base column-label "Сумма (в Б.Вал.)" format "->,>>>>,>>>,>>9.99"
sym6 column-label ":" format "X(1)"
b-ink-pay.tot-rubl column-label "Сумма (в {&abbr_rublyah})" format "->,>>>,>>>,>>>,>>9.99"
sym8 column-label ":" format "X(1)"

HEADER  date_string AT 5 format "X(35)"
string( "( Б.Вал. - " + caps( trim( buf_currency.curr-abbr ) ) + " )" ) format "X(20)" AT 42
string( "Страница " ) format "x(9)" AT 105 PAGE-NUMBER(Prnlibstream) AT 115 FORMAT ">>9" SKIP
Line format "X(126)" AT 1

with width {&A4_CW} down stream-io use-text .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_cur-obj-proceeds_print':U
{&cntxt-firm}
inkas.host-code
'':U
0
0
0
0
true
glog
}

if not glog then return "NO".

if can-find( FIRST b-ink-pay WHERE b-ink-pay.inkas-code = inp-inkas-code ) then do:
  date_string = cur-time-print() .
  Line = fill( "-", 136 ).
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&CS_PS}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).


  FORM HEADER
      Line format "X(126)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 30 SKIP
      with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream PrnLibstream FRAME BottomFrame .
  PUT stream PrnLibstream
  space(15) string( "ВЫРУЧКА  по  отчету  о  продажах  N  " + inp-inkas-code )
  format "X(120)" SKIP(1) .
  FOR EACH b-ink-pay WHERE
           b-ink-pay.inkas-code = inp-inkas-code NO-LOCK
  BREAK
  BY b-ink-pay.inkas-code
  BY b-ink-pay.pay-code
  BY b-ink-pay.curr-code
  with frame Benefit-Tot :
  ACCUMULATE
  b-ink-pay.tot-sum ( SUB-TOTAL BY b-ink-pay.curr-code )
  b-ink-pay.tot-base ( SUB-TOTAL BY b-ink-pay.curr-code )
  b-ink-pay.tot-rubl ( SUB-TOTAL BY b-ink-pay.curr-code )
  b-ink-pay.tot-rubl ( TOTAL )
  b-ink-pay.tot-base ( TOTAL )
  b-ink-pay.curr-code ( COUNT ) .
  if last-of( b-ink-pay.curr-code ) then do:
    FIND FIRST ub.cash-pay WHERE
               ub.cash-pay.cdpay-code = b-ink-pay.pay-code AND
               ub.cash-pay.curr-code = b-ink-pay.curr-code NO-LOCK .
    FIND FIRST ub.currency WHERE
               ub.currency.curr-code = b-ink-pay.curr-code NO-LOCK.
    DISPLAY stream PrnLibstream
    sym1 ub.cash-pay.obj-name
    sym3 ub.currency.curr-name
    sym4 b-ink-pay.tot-sum
    sym5 b-ink-pay.tot-base
    sym6 b-ink-pay.tot-rubl
    sym8    .
    DOWN 1 stream PrnLibstream.
  end.
  if last( b-ink-pay.inkas-code ) then do:
    UNDERLINE stream PRnLibStream
    ub.cash-pay.obj-name
    b-ink-pay.tot-base
    b-ink-pay.tot-rubl .
    DISPLAY stream PrnLibstream
    sym1 " ИТОГО" @ ub.cash-pay.obj-name
                    ( ACCUM TOTAL b-ink-pay.tot-base ) @ b-ink-pay.tot-base
                    ( ACCUM TOTAL b-ink-pay.tot-rubl ) @ b-ink-pay.tot-rubl
                    sym8 .
   end.
 END.
 HIDE FRAME BottomFrame .
 PUT stream PrnLibstream
 Line format "X(126)" SKIP(2)
space(10) "Директор _______________" format "X(30)"
                "Старший продавец ______________" format "X(30)" SKIP(2)
space(10) "Бухгалтер ______________" format "X(30)"
                "Кассир ________________________" format "X(30)" SKIP .
 output stream PrnLibstream  CLOSE.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


end.
else
    message "Выручка НУЛЕВАЯ !" view-as alert-box information .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-INKAS-PAY
&Scoped-define SELF-NAME BR-INKAS-PAY
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-INKAS-PAY DIALOG-1
ON ROW-DISPLAY OF BR-INKAS-PAY IN FRAME DIALOG-1 /* Выручка по типам  кассовых платежей */
DO:
  assign
      pay-tot-rubl = 0
      pay-tot-rubl-return = 0
      .
  IF available ub.inkas-pay THEN
  DO:
      pay-tot-rubl = inkas-pay.tot-rubl .
      RUN autotank-inkas-pay(input ub.inkas-pay.inkas-code  ,
                           input ub.inkas-pay.pay-code    ,
                           input ub.inkas-pay.curr-code   ,
                           input "autotank-sum-return" ,
                           output a-sum-return) .
         assign
             pay-tot-rubl = pay-tot-rubl - a-sum-return
             pay-tot-rubl-return = pay-tot-rubl-return - a-sum-return
             .
      /*
      FOR EACH ub.inkas-pay-attr NO-LOCK WHERE
               ub.inkas-pay-attr.inkas-code = ub.inkas-pay.inkas-code
           AND ub.inkas-pay-attr.pay-code = ub.inkas-pay.pay-code
           AND ub.inkas-pay-attr.curr-code = ub.inkas-pay.curr-code
           AND ub.inkas-pay-attr.attr-code = "autotank-sum-return":
         assign
             pay-tot-rubl = pay-tot-rubl - DECI(ub.inkas-pay-attr.attr-value)
             pay-tot-rubl-return = pay-tot-rubl-return - DECI(ub.inkas-pay-attr.attr-value)
             .

      END.
      */
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-INKAS-PAY DIALOG-1
ON VALUE-CHANGED OF BR-INKAS-PAY IN FRAME DIALOG-1 /* Выручка по типам  кассовых платежей */
DO:
  {&OPEN-QUERY-br-pay-desk}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-pay-desk
&Scoped-define SELF-NAME BR-pay-desk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-pay-desk DIALOG-1
ON ROW-DISPLAY OF BR-pay-desk IN FRAME DIALOG-1 /* Выручка по кассам по типам кассовых платежей */
DO:
    assign
      pay-desk-tot-rubl = 0
      .
  IF available ub.inkas-pay-desk THEN
  DO:
      pay-desk-tot-rubl = ub.inkas-pay-desk.tot-rubl .
      RUN autotank-inkas-pay-desk( input ub.inkas-pay-desk.inkas-code,
                                 input ub.inkas-pay-desk.pay-code ,
                                 input ub.inkas-pay-desk.curr-code ,
                                 input ub.inkas-pay-desk.pay-desk ,
                                 input ub.inkas-pay-desk.cashier ,
                                 input "autotank-sum-return":U    ,
                                 output a-sum-return)
       .
         assign
             pay-desk-tot-rubl = pay-desk-tot-rubl - a-sum-return
             .
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-cash-desk
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/brwrefre.i "V-DOC-REC  = recid(inkas-pay). ~{&OPEN-QUERY-BR-INKAS-pay-desk~}  ~
             reposition br-inkas-pay to recid v-doc-rec no-error. ~{&OPEN-QUERY-BR-pay-desk~} " }

{ gbl/app_help.i }
{ gbl/hot-key.i b-EXIT }
{ gbl/hot-key.i b-print }


/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get }
    find ub.inkas where ub.inkas.inkas-code = inp-inkas-code no-lock no-error.
    if not available ub.inkas then
        do:
            message "Отчет по выручке пустой!" view-as alert-box WARNING.
            return.
        end.
        IF CAN-FIND(FIRST ub.cash-desk WHERE ub.cash-desk.db-num >=0
                       AND ub.cash-desk.obj-code = ub.inkas.obj-code
                       AND ub.cash-desk.pos-type = {&cd-type-Autotank}) THEN
            v-exist-autotank = YES .

        define variable v-curr-r-b as character no-undo .
        { gbl/curr-r-b.i
          v-curr-r-b
        }
        FOR EACH ub.inkas-pay where ub.inkas-pay.inkas-code = ub.inkas.inkas-code no-lock:
            accumpay = accumpay + ROUND(if v-curr-r-b = {&r-b-base}
                             then ub.inkas-pay.tot-base
                             else ub.inkas-pay.tot-rubl, 2) .
            RUN autotank-inkas-pay(input ub.inkas-pay.inkas-code  ,
                                   input ub.inkas-pay.pay-code    ,
                                   input ub.inkas-pay.curr-code   ,
                                   input "autotank-sum-return" ,
                                   output a-sum-return) .
            assign
                  accumpay = accumpay - a-sum-return
                  autotank-sum-return = autotank-sum-return - a-sum-return
                .
            /*
            FOR EACH ub.inkas-pay-attr NO-LOCK WHERE
                     ub.inkas-pay-attr.inkas-code = ub.inkas-pay.inkas-code
                 AND ub.inkas-pay-attr.pay-code = ub.inkas-pay.pay-code
                 AND ub.inkas-pay-attr.curr-code = ub.inkas-pay.curr-code
                 AND ub.inkas-pay-attr.attr-code = "autotank-sum-return":
               assign
                  accumpay = accumpay - DECI(ub.inkas-pay-attr.attr-value)
                  autotank-sum-return = autotank-sum-return - DECI(ub.inkas-pay-attr.attr-value)
                .
            END.
              */

        END.
        assign
        f% = ub.inkas.discnt / ub.inkas.tot-doc * 100
        fnetto = ub.inkas.netto
        frame {&frame-name}:title =
            "Отчет о выручке: " + inp-inkas-code + ". Дата: " + string( ub.inkas.doc-date )
        g-discnt = ub.inkas.discnt .
        run get-inkas-ps in this-procedure (
                                            buffer ub.inkas
                                          , output chk-amount
                                          , output gds-amount
                                          , output line-out
                                          , output dtl-out
                                          , output line-ret
                                          , output dtl-ret
                                          , output nf-chk-amount
                                          , output nf-gds-amount
                                          , output ps-where-rus
                                          ).

  RUN fill-inkas-cash-desk IN THIS-PROCEDURE.
  RUN MYenable IN THIS-PROCEDURE.
  APPLY "VALUE-CHANGED" to BR-INKAS-PAY.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE autotank-inkas-pay DIALOG-1
PROCEDURE autotank-inkas-pay :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  PARAMETER i-code    as CHARACTER no-undo .
define input  parameter p-code    as INTEGER   no-undo .
define input  parameter c-code    as INTEGER   no-undo .
define input  PARAMETER a-code    as CHARacter no-undo .
define output PARAMETER a-return  as DECImal   no-undo .
define BUFFER buf_inkas        FOR ub.inkas .
define BUFFER buf_chk-pay      FOR ub.chk-pay .
define BUFFER buf_chk-pay-attr FOR ub.chk-pay-attr .

assign
    a-return = 0
    .
FIND FIRST buf_inkas NO-LOCK WHERE buf_inkas.inkas-code = i-code NO-ERROR.
IF available buf_inkas THEN
DO:
    FOR EACH buf_chk-pay NO-LOCK where buf_chk-pay.out-code = buf_inkas.inkas-code
                               AND  buf_chk-pay.pay-code = p-code
                               AND  buf_chk-pay.curr-code = c-code,
        FIRST buf_chk-pay-attr NO-LOCK WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                 AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                 AND buf_chk-pay-attr.attr-code = a-code :
       a-return = a-return + decimal(buf_chk-pay-attr.attr-value) .
    END.
END.



END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE autotank-inkas-pay-desk DIALOG-1
PROCEDURE autotank-inkas-pay-desk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter i-code   as character no-undo .
define input  parameter p-code   as integer   no-undo .
define input  parameter c-code   as integer   no-undo .
define input  parameter p-desk   as integer   no-undo .
define input  parameter ccashier as integer   no-undo .
define input  parameter a-code   as character no-undo .
define output parameter a-return as decimal   no-undo .
define BUFFER buf_inkas        FOR ub.inkas .
define BUFFER buf_chk-pay      FOR ub.chk-pay .
define BUFFER buf_chk-pay-attr FOR ub.chk-pay-attr .
define BUFFER buf_chk-doc      FOR ub.chk-doc .


assign
    a-return = 0
    .
FIND FIRST buf_inkas NO-LOCK WHERE buf_inkas.inkas-code = i-code NO-ERROR.
IF available buf_inkas THEN
DO:
    FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas.inkas-code
                              AND buf_chk-doc.pay-desk = p-desk
                              AND buf_chk-doc.cashier = ccashier,
        EACH buf_chk-pay NO-LOCK where buf_chk-pay.doc-code = buf_chk-doc.doc-code
                               AND  buf_chk-pay.pay-code = p-code
                               AND  buf_chk-pay.curr-code = c-code,
        FIRST buf_chk-pay-attr NO-LOCK WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                 AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                                 AND buf_chk-pay-attr.attr-code = a-code:
       a-return = a-return + DECI(buf_chk-pay-attr.attr-value) .
    END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY f% f-num-chk g-discnt autotank-sum-return fnetto accumpay
      WITH FRAME DIALOG-1.
  IF AVAILABLE ub.inkas THEN
    DISPLAY ub.inkas.tot-doc ub.inkas.num-chk ub.inkas.discnt ub.inkas.sub-discnt
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-print B-help BR-INKAS-PAY BR-pay-desk BR-cash-desk 
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-inkas-cash-desk DIALOG-1
PROCEDURE fill-inkas-cash-desk :
define BUFFER buf_temp-inkas-cash-desk FOR temp-inkas-cash-desk .
define BUFFER buf_inkas-pay-desk       FOR ub.inkas-pay-desk .
define BUFFER buf_inkas-pay-desk-attr  FOR ub.inkas-pay-desk-attr .
for each buf_temp-inkas-cash-desk :
  delete buf_temp-inkas-cash-desk .
end.
FOR EACH buf_inkas-pay-desk NO-LOCK WHERE
buf_inkas-pay-desk.inkas-code = inp-inkas-code
BREAK BY buf_inkas-pay-desk.pay-desk:

  FIND FIRST buf_temp-inkas-cash-desk WHERE
        buf_temp-inkas-cash-desk.inkas-code = buf_inkas-pay-desk.inkas-code
    AND buf_temp-inkas-cash-desk.pay-desk = buf_inkas-pay-desk.pay-desk NO-ERROR.
  IF NOT AVAILABLE buf_temp-inkas-cash-desk THEN DO:
      CREATE buf_temp-inkas-cash-desk.
      assign
          buf_temp-inkas-cash-desk.inkas-code = buf_inkas-pay-desk.inkas-code
          buf_temp-inkas-cash-desk.pay-desk = buf_inkas-pay-desk.pay-desk.
  END.
  assign
  buf_temp-inkas-cash-desk.tot-base = buf_temp-inkas-cash-desk.tot-base + buf_inkas-pay-desk.tot-base
  buf_temp-inkas-cash-desk.tot-rubl = buf_temp-inkas-cash-desk.tot-rubl + buf_inkas-pay-desk.tot-rubl
  .
  IF buf_inkas-pay-desk.doc-type <> '':U THEN
   RUN autotank-inkas-pay-desk( input buf_inkas-pay-desk.inkas-code,
                                input buf_inkas-pay-desk.pay-code ,
                                input buf_inkas-pay-desk.curr-code ,
                                input buf_inkas-pay-desk.pay-desk ,
                                input buf_inkas-pay-desk.cashier ,
                                input "autotank-sum-return":U    ,
                                output a-sum-return)
      .
      assign
      buf_temp-inkas-cash-desk.tot-rubl-return = buf_temp-inkas-cash-desk.tot-rubl-return
          - a-sum-return
      .
  /*
  FOR EACH buf_inkas-pay-desk-attr where
                         buf_inkas-pay-desk-attr.inkas-code = buf_inkas-pay-desk.inkas-code
                     and buf_inkas-pay-desk-attr.pay-code = buf_inkas-pay-desk.pay-code
                     and buf_inkas-pay-desk-attr.curr-code = buf_inkas-pay-desk.curr-code
                     and buf_inkas-pay-desk-attr.pay-desk = buf_inkas-pay-desk.pay-desk
                     and buf_inkas-pay-desk-attr.doc-type = buf_inkas-pay-desk.doc-type
                     and buf_inkas-pay-desk-attr.cashier = buf_inkas-pay-desk.cashier
                     and buf_inkas-pay-desk-attr.attr-code = "autotank-sum-return":
      assign
      buf_temp-inkas-cash-desk.tot-rubl-return = buf_temp-inkas-cash-desk.tot-rubl-return
          - deci(buf_inkas-pay-desk-attr.attr-value)
      .

  END.
   */
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable DIALOG-1
PROCEDURE MyEnable :
define buffer buf_sale-doc for ub.sale-doc.
define variable v-hdl as HANDLE no-undo .

find first BUF_sale-doc no-lock where
          buf_sale-doc.inkas-code = inp-inkas-code
      and buf_sale-doc.doc-kind = {&sale-add-tech-refuell} no-error .
assign
f-num-chk = inkas.num-chk - nf-chk-amount - (if available buf_sale-doc
                                             then buf_sale-doc.chk-amount
                                             else 0).
find first BUF_sale-doc no-lock where
          buf_sale-doc.inkas-code = inp-inkas-code
      and buf_sale-doc.doc-kind = {&sale-add-write-off} no-error .
assign
f-num-chk = inkas.num-chk - nf-chk-amount - (if available buf_sale-doc
                                             then buf_sale-doc.chk-amount
                                             else 0).

assign
temp-inkas-cash-desk.tot-rubl:LABEL IN BROWSE br-cash-desk = '{&abbr_rub_firstshift}.эквивалент'
ub.inkas-pay.tot-rubl:LABEL IN BROWSE br-inkas-pay = '{&abbr_rub_firstshift}.эквивалент'
ub.inkas-pay-desk.tot-rubl:LABEL IN BROWSE br-pay-desk = '{&abbr_rub_firstshift}.эквивалент'
.

DISPLAY
f%
f-num-chk
g-discnt
autotank-sum-return
fnetto
accumpay
WITH FRAME {&frame-name}.
IF AVAILABLE ub.inkas THEN
DISPLAY
ub.inkas.num-chk
ub.inkas.tot-doc
ub.inkas.discnt
ub.inkas.sub-discnt
WITH FRAME {&frame-name}.

IF v-exist-autotank = NO THEN
DO:
 assign
  autotank-sum-return:HIDDEN = YES
  autotank-sum-return:VISIBLE = NO
     .
  v-hdl = br-inkas-pay:FIRST-COLUMN .
  DO WHILE VALID-HANDLE(v-hdl):
      IF v-hdl:LABEL BEGINS "Выручка(руб.)":U THEN v-hdl:VISIBLE = NO .
      IF v-hdl:LABEL BEGINS "Разн.по запр.за нал":U THEN v-hdl:VISIBLE = NO .
      v-hdl = v-hdl:NEXT-COLUMN .
  END.
  v-hdl = br-pay-desk:FIRST-COLUMN .
  DO WHILE VALID-HANDLE(v-hdl):
      IF v-hdl:LABEL BEGINS "Выручка(руб.)":U THEN v-hdl:VISIBLE = NO .
      IF v-hdl:LABEL BEGINS "Разн.по запр.за нал":U THEN v-hdl:VISIBLE = NO .
      v-hdl = v-hdl:NEXT-COLUMN .
  END.
  v-hdl = br-cash-desk:FIRST-COLUMN .
  DO WHILE VALID-HANDLE(v-hdl):
      IF v-hdl:LABEL BEGINS "Выручка(руб.)":U THEN v-hdl:VISIBLE = NO .
      IF v-hdl:LABEL BEGINS "Разн.по запр.за нал":U THEN v-hdl:VISIBLE = NO .
      v-hdl = v-hdl:NEXT-COLUMN .
  END.
END.

ENABLE
b-exit
b-print
B-help
BR-INKAS-PAY
BR-pay-desk
BR-cash-desk
WITH FRAME {&frame-name}.
{&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cash-pay DIALOG-1
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input p-pay-code as integer, input p-curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_cash-pay for ub.cash-pay.
find first buf_cash-pay no-lock where
            buf_cash-pay.curr-code = p-curr-code
        AND buf_cash-pay.cdpay-code  = p-pay-code
            no-error.
  if available buf_cash-pay then do:
      return buf_cash-pay.obj-name.
  end.

  RETURN {&question-mark}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-chk-type DIALOG-1
FUNCTION get-chk-type RETURNS CHARACTER
  ( input par-doc-type as character ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
 if par-doc-type = {&income} then return "Продажа".
 RETURN "Возврат".

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-currency DIALOG-1
FUNCTION get-currency RETURNS CHARACTER
  ( input p-curr-code as integer ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
define buffer buf_currency for ub.currency.
find first buf_currency no-lock where
            buf_currency.curr-code = p-curr-code no-error.
if available buf_currency then do:
    return buf_currency.curr-abbr.
end.

  RETURN {&question-mark}.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
