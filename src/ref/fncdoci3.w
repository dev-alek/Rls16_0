&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-doc FOR ub.c-fin-doc.
DEFINE NEW SHARED TEMP-TABLE tt-c-fin-doc NO-UNDO LIKE ub.c-fin-doc.
DEFINE NEW SHARED TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_firm FOR ub.firm.
DEFINE BUFFER X_sysconf FOR ub.sysconf.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка истории приходного платежного поручени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/10/03
Author: Bakhtadze Natalya
Creation date: 11/10/03

*/


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
/*текущая фирма*/
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.


define input parameter p-mode as character no-undo.
/*может быть {&lookup}*/

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.

define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка истории приходного платежного поручения".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-view as character no-undo init "full":U.
define variable v-not-uf-set as logical no-undo.
define variable v-rubf          as logical no-undo .
define variable v-exchf         as logical no-undo .
define variable v-basef         as logical no-undo .
define variable v-baseratef     as logical no-undo .
define variable v-contractf     as logical no-undo .
define variable v-contractratef as logical no-undo .
define variable v-us            as logical no-undo .


define buffer X_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer X_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer X_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer X_currency for ub.currency.
DEFINE BUFFER X_payer FOR ub.clients.
DEFINE BUFFER X_receiver FOR ub.clients.
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_receiver-fin-schet for ub.fin-schet.
define buffer X_receiver-fin-bank for ub.fin-bank.
define buffer X_payer-fin-schet for ub.fin-schet.
define buffer X_payer-fin-bank for ub.fin-bank.
define buffer X_payer-firm for ub.firm.
define buffer X_payer-person for ub.person.
define buffer X_contract for ub.contract.
define buffer X_fin-ob for ub.fin-ob.
DEFINE BUFFER X_fin-statement FOR ub.fin-statement.
DEFINE BUFFER X_c-fin-statement FOR ub.c-fin-statement.

define variable v-base-code like ub.sysconf.host-code no-undo.

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ ref/fndocip.i }
{ gbl/usr-flt.i  }
{ cmp/operlist.i }
{ gbl/color.i }
{ gbl/getcntxt.i def }

&scop not-in-form-list "f-an-uchet-descr,f-cel-nazn-descr,f-contract-curr-abbr,f-contract-date,f-contract-prn-code,f-contract-rate," +  ~
                       "f-contract-scale,f-contract-type,f-cor-acc-descr,base-rate,base-scale,curr-code,exch-rate,exch-scale,contract-rate,contract-scale," +  ~
                       "fact-date,fin-doc-code,payer-code,payer-type,pay-date,perm-date,PS,receiver-code,receiver-type,sum-base,sum-rubl,sum-contr," +  ~
                       "user-name-doc,user-name-fact,user-name-perm.user-name-pl"

&scop in-form-list    "F-curr-abbr,an-uchet-value,cel-nazn-value,cor-acc-value,doc-date," + ~
                      "naznach-plat,payer-name,payer-inn,payer-kpp,payer-bank-name,payer-bik,payer-r-schet,payer-c-schet," + ~
                      "prn-doc-code,receiver-name,receiver-inn,receiver-kpp,receiver-bank-name,receiver-bik,receiver-r-schet,receiver-c-schet,payer-sign1,payer-sign2" + ~
                      "sum-doc"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_c-fin-doc tt-fin-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-fin-doc.sttm-code
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH locked_c-fin-doc SHARE-LOCK, ~
      EACH tt-fin-doc WHERE TRUE /* Join to locked_c-fin-doc incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH locked_c-fin-doc SHARE-LOCK, ~
      EACH tt-fin-doc WHERE TRUE /* Join to locked_c-fin-doc incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame locked_c-fin-doc tt-fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame locked_c-fin-doc
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame tt-fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-fin-doc.prn-doc-code ~
tt-c-fin-doc.vid-plat tt-c-fin-doc.doc-date tt-c-fin-doc.user-name-doc ~
tt-c-fin-doc.obj-type tt-c-fin-doc.obj-code tt-c-fin-doc.cor-acc-value ~
tt-c-fin-doc.an-uchet-value tt-c-fin-doc.contract-curr ~
tt-c-fin-doc.cel-nazn-value tt-c-fin-doc.sum-doc tt-c-fin-doc.curr-code ~
tt-c-fin-doc.exch-rate tt-c-fin-doc.exch-scale tt-c-fin-doc.sum-base ~
tt-c-fin-doc.contract-rate tt-c-fin-doc.contract-scale ~
tt-c-fin-doc.sum-contr tt-c-fin-doc.payer-type tt-c-fin-doc.payer-name ~
tt-c-fin-doc.payer-code tt-c-fin-doc.receiver-name ~
tt-c-fin-doc.receiver-bank-name tt-c-fin-doc.receiver-c-schet ~
tt-c-fin-doc.naznach-plat tt-c-fin-doc.PS tt-c-fin-doc.payer-sign1 ~
tt-c-fin-doc.payer-sign2
&Scoped-define ENABLED-TABLES tt-c-fin-doc
&Scoped-define FIRST-ENABLED-TABLE tt-c-fin-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-other B-tax B-Help RS-view ~
f-contract-curr-abbr B-contract-view B-get-rate B-get-contract-rate ~
B-payer-view B-receiver-view
&Scoped-Define DISPLAYED-FIELDS tt-c-fin-doc.prn-doc-code ~
tt-c-fin-doc.vid-plat tt-c-fin-doc.fin-doc-code tt-c-fin-doc.perm-date ~
tt-c-fin-doc.user-name-perm tt-c-fin-doc.pay-date tt-c-fin-doc.doc-date ~
tt-c-fin-doc.user-name-doc tt-c-fin-doc.obj-type tt-c-fin-doc.obj-code ~
tt-c-fin-doc.user-name-pl tt-с-fin-doc.sttm-code tt-c-fin-doc.fact-date ~
tt-c-fin-doc.user-name-fact tt-c-fin-doc.cor-acc-value ~
tt-c-fin-doc.an-uchet-value tt-c-fin-doc.contract-curr ~
tt-c-fin-doc.cel-nazn-value tt-c-fin-doc.sum-doc tt-c-fin-doc.curr-code ~
tt-c-fin-doc.sum-rubl tt-c-fin-doc.exch-rate tt-c-fin-doc.exch-scale ~
tt-c-fin-doc.base-rate tt-c-fin-doc.base-scale tt-c-fin-doc.sum-base ~
tt-c-fin-doc.contract-rate tt-c-fin-doc.contract-scale ~
tt-c-fin-doc.sum-contr tt-c-fin-doc.payer-inn tt-c-fin-doc.payer-kpp ~
tt-c-fin-doc.payer-type tt-c-fin-doc.receiver-code tt-c-fin-doc.payer-name ~
tt-c-fin-doc.payer-bank-name tt-c-fin-doc.payer-r-schet ~
tt-c-fin-doc.payer-bik tt-c-fin-doc.payer-c-schet tt-c-fin-doc.receiver-inn ~
tt-c-fin-doc.receiver-kpp tt-c-fin-doc.receiver-type ~
tt-c-fin-doc.payer-code tt-c-fin-doc.receiver-name ~
tt-c-fin-doc.receiver-bank-name tt-c-fin-doc.receiver-r-schet ~
tt-c-fin-doc.receiver-bik tt-c-fin-doc.receiver-c-schet ~
tt-c-fin-doc.naznach-plat tt-c-fin-doc.PS tt-c-fin-doc.payer-sign1 ~
tt-c-fin-doc.payer-sign2
&Scoped-define DISPLAYED-TABLES tt-c-fin-doc tt-fin-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-fin-doc
&Scoped-define SECOND-DISPLAYED-TABLE tt-fin-doc
&Scoped-Define DISPLAYED-OBJECTS RS-view v-sttm-prn-doc-code ~
f-cor-acc-descr f-an-uchet-descr f-contract-curr-abbr f-contract-prn-code ~
f-contract-date f-contract-type f-cel-nazn-descr F-curr-abbr f-bank

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-contract-view
     LABEL "&Договор"
     SIZE 12 BY 1
     FGCOLOR 4 .

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-get-contract-rate
     LABEL "Курс из справочника"
     SIZE 20 BY .77.

DEFINE BUTTON B-get-rate
     LABEL "Курс из справочника"
     SIZE 20 BY .77.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-other
     LABEL "До&полн."
     SIZE 10 BY 1.

DEFINE BUTTON B-payer-view
     LABEL "П&лательщик"
     SIZE 12 BY 1
     FGCOLOR 4 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-receiver-view
     LABEL "П&олучатель"
     SIZE 12 BY 1.

DEFINE BUTTON B-tax
     LABEL "&Налоги"
     SIZE 10 BY 1.

DEFINE VARIABLE f-an-uchet-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-bank AS CHARACTER FORMAT "X(256)":U INITIAL "Банк"
      VIEW-AS TEXT
     SIZE 4.4 BY .77
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE f-cel-nazn-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-contract-curr-abbr AS CHARACTER FORMAT "X(3)":U INITIAL "0"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE f-contract-date AS DATE FORMAT "99/99/9999":U
     LABEL "от"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE f-contract-prn-code AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE f-contract-type AS CHARACTER FORMAT "X(23)":U
     LABEL "тип дог-ра"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE f-cor-acc-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE F-curr-abbr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sttm-prn-doc-code AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 21 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-view AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 27.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      locked_c-fin-doc,
      tt-fin-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-other AT ROW 1 COL 49
     B-tax AT ROW 1 COL 59
     B-Help AT ROW 1 COL 89
     RS-view AT ROW 1.07 COL 21.1 NO-LABEL
     tt-c-fin-doc.prn-doc-code AT ROW 2 COL 1
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     tt-c-fin-doc.vid-plat AT ROW 2 COL 29.1 COLON-ALIGNED
          LABEL "Вид пл-жа"
          VIEW-AS COMBO-BOX INNER-LINES 4
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 11 BY 1
     tt-c-fin-doc.fin-doc-code AT ROW 2 COL 49.5 COLON-ALIGNED
          LABEL "Внутр.№"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-c-fin-doc.perm-date AT ROW 2 COL 71.5 COLON-ALIGNED
          LABEL "Дата разр"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-doc.user-name-perm AT ROW 2 COL 82.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.pay-date AT ROW 2.97 COL 71.5 COLON-ALIGNED
          LABEL "В банк"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-doc.doc-date AT ROW 3 COL 11 COLON-ALIGNED
          LABEL "Дата сост."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-doc.user-name-doc AT ROW 3 COL 22.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.obj-type AT ROW 3 COL 39.4 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U
          SIZE 12.6 BY 1
     tt-c-fin-doc.obj-code AT ROW 3 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1
     tt-c-fin-doc.user-name-pl AT ROW 3 COL 82.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.sttm-code AT ROW 3.93 COL 11 COLON-ALIGNED
          LABEL "Выписка"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     v-sttm-prn-doc-code AT ROW 3.93 COL 22.4 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.fact-date AT ROW 4 COL 71.5 COLON-ALIGNED
          LABEL "Дата факт(списано со сч.)"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-doc.user-name-fact AT ROW 4 COL 82.77 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.cor-acc-value AT ROW 5 COL 16.3 COLON-ALIGNED
          LABEL "Корсчет"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     f-cor-acc-descr AT ROW 5 COL 35.4 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.an-uchet-value AT ROW 6 COL 16.3 COLON-ALIGNED
          LABEL "Код ан. уч."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     f-an-uchet-descr AT ROW 6 COL 35.4 COLON-ALIGNED NO-LABEL
     f-contract-curr-abbr AT ROW 6.2 COL 55.3 COLON-ALIGNED NO-LABEL
     B-contract-view AT ROW 6.27 COL 1
     f-contract-prn-code AT ROW 6.27 COL 12 COLON-ALIGNED NO-LABEL
     f-contract-date AT ROW 6.27 COL 36.6 COLON-ALIGNED
     tt-c-fin-doc.contract-curr AT ROW 6.27 COL 49.1 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     f-contract-type AT ROW 6.27 COL 72 COLON-ALIGNED
     tt-c-fin-doc.cel-nazn-value AT ROW 7 COL 16.3 COLON-ALIGNED
          LABEL "Код цел.назн."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-cel-nazn-descr AT ROW 7 COL 35.4 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.sum-doc AT ROW 8 COL 6 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          FGCOLOR 4
     tt-c-fin-doc.curr-code AT ROW 8 COL 41.9 COLON-ALIGNED
          LABEL "Вал"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     F-curr-abbr AT ROW 8 COL 50.9 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.sum-rubl AT ROW 8 COL 72.3 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-doc.exch-rate AT ROW 8.97 COL 37.5 COLON-ALIGNED
          LABEL "Курс пл-жа"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-c-fin-doc.exch-scale AT ROW 8.97 COL 47.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     B-get-rate AT ROW 9.2 COL 1
     tt-c-fin-doc.base-rate AT ROW 9.97 COL 37.5 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-c-fin-doc.base-scale AT ROW 9.97 COL 47.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-c-fin-doc.sum-base AT ROW 9.97 COL 72.1 COLON-ALIGNED
          LABEL "Б.в."
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     B-get-contract-rate AT ROW 10.93 COL 1
     tt-c-fin-doc.contract-rate AT ROW 10.97 COL 37.5 COLON-ALIGNED
          LABEL "Курс дог-ра"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-c-fin-doc.contract-scale AT ROW 10.97 COL 47.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-c-fin-doc.sum-contr AT ROW 10.97 COL 72.1 COLON-ALIGNED
          LABEL "вал.дог-ра"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-doc.payer-inn AT ROW 12 COL 1
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 12 BY .77
          FGCOLOR 4
     tt-c-fin-doc.payer-kpp AT ROW 12 COL 21.5 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 9 BY .77
          FGCOLOR 4
     tt-c-fin-doc.payer-type AT ROW 12 COL 33 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 1", "2":U
          SIZE 11.4 BY .77
          FGCOLOR 4
     tt-c-fin-doc.receiver-code AT ROW 12 COL 35.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY .77
     tt-c-fin-doc.payer-name AT ROW 12 COL 54.6 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 42.6 BY .77
          FGCOLOR 4
     tt-c-fin-doc.payer-bank-name AT ROW 12.77 COL 7 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 77.9 BY 1
          FGCOLOR 4
     B-payer-view AT ROW 12.77 COL 87.3
     tt-c-fin-doc.payer-r-schet AT ROW 13.77 COL 4.1 COLON-ALIGNED
          LABEL "Р/с"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 4
     tt-c-fin-doc.payer-bik AT ROW 13.77 COL 33.9 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-c-fin-doc.payer-c-schet AT ROW 13.77 COL 58.9 COLON-ALIGNED
          LABEL "Кор.счет"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 4
     tt-c-fin-doc.receiver-inn AT ROW 14.77 COL 1
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 12 BY .77
          FGCOLOR 1
     tt-c-fin-doc.receiver-kpp AT ROW 14.77 COL 21.5 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 9 BY .77
          FGCOLOR 1
     tt-c-fin-doc.receiver-type AT ROW 14.77 COL 35.1 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY .77
     tt-c-fin-doc.payer-code AT ROW 14.77 COL 42 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY .77
     tt-c-fin-doc.receiver-name AT ROW 14.77 COL 42.1 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 55.1 BY .77
          FGCOLOR 1
     tt-c-fin-doc.receiver-bank-name AT ROW 15.5 COL 7 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 77.5 BY 1
          FGCOLOR 1
     B-receiver-view AT ROW 15.5 COL 86.8
     tt-c-fin-doc.receiver-r-schet AT ROW 16.5 COL 4.1 COLON-ALIGNED
          LABEL "Р/c"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 1
     tt-c-fin-doc.receiver-bik AT ROW 16.5 COL 33.9 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 1
     tt-c-fin-doc.receiver-c-schet AT ROW 16.5 COL 58.9 COLON-ALIGNED
          LABEL "Кор.счет"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 1
     tt-c-fin-doc.naznach-plat AT ROW 18.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5 TOOLTIP "Основание платежа"
          FGCOLOR 4
     tt-c-fin-doc.PS AT ROW 18.5 COL 50 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5 TOOLTIP "Дополнительная информация, не печатающаяся в ордере"
     tt-c-fin-doc.payer-sign1 AT ROW 20 COL 1.4
          LABEL "Рук. орг-ции"
          VIEW-AS FILL-IN
          SIZE 30.9 BY 1
          FGCOLOR 4
     tt-c-fin-doc.payer-sign2 AT ROW 20 COL 64.6 COLON-ALIGNED
          LABEL "Гл. бухгалтер"
          VIEW-AS FILL-IN
          SIZE 30.9 BY 1
          FGCOLOR 4
     f-bank AT ROW 15.5 COL 1 NO-LABEL
     "(Примечание (доп.информация, не печатается))" VIEW-AS TEXT
          SIZE 47.1 BY 1 AT ROW 17.5 COL 50.5
     "Назначение платежа" VIEW-AS TEXT
          SIZE 19.4 BY 1 AT ROW 17.5 COL 1.1
          FGCOLOR 4
     "Банк" VIEW-AS TEXT
          SIZE 4.4 BY 1 AT ROW 13 COL 1
          FGCOLOR 4
     SPACE(93.86) SKIP(7.00)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Приходное платежное поручение - Получатель"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-doc B "?" ? ub c-fin-doc
      TABLE: tt-c-fin-doc T "NEW SHARED" NO-UNDO ub c-fin-doc
      TABLE: tt-fin-doc T "NEW SHARED" NO-UNDO ub fin-doc
      TABLE: tt0-fin-doc-attr T "?" NO-UNDO ub fin-doc-attr
      TABLE: tt0-fin-doc-tax T "?" NO-UNDO ub fin-doc-tax
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_firm B "?" ? ub firm
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-c-fin-doc.an-uchet-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.base-rate IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.base-scale IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.cel-nazn-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.contract-curr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.contract-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.contract-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.cor-acc-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.curr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.exch-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.exch-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN f-an-uchet-descr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-bank IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN f-cel-nazn-descr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-contract-date IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-contract-prn-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-contract-type IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-cor-acc-descr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.fact-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.fin-doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.pay-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-bank-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-bik IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-c-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-inn IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-kpp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-r-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-sign1 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-sign2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.perm-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.prn-doc-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-bank-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-bik IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-c-schet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-inn IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-kpp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-r-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sttm-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-base IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-contr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-rubl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.user-name-fact IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.user-name-perm IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.user-name-pl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN v-sttm-prn-doc-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX tt-c-fin-doc.vid-plat IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.locked_c-fin-doc,Temp-Tables.tt-fin-doc WHERE Temp-Tables.locked_c-fin-doc ..."
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Приходное платежное поручение - Получатель */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-other
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-other Dialog-Frame
ON CHOOSE OF b-other IN FRAME Dialog-Frame /* Дополн. */
DO:
  for each tt-fin-doc:
    delete tt-fin-doc.
  end.
  create tt-fin-doc.
  buffer-copy tt-c-fin-doc to tt-fin-doc.
  run ref/fndoci4d.w (
 INPUT     parParentProc
/*текущая фирма*/
,input p-curr-host-code
,input p-mode
,input tt-c-fin-doc.host-code
,input tt-c-fin-doc.fin-doc-code
,input tt-c-fin-doc.fin-ext-doc-type
,input-output p-doc-rec ) no-error.
if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/colorhnd.i }
{ ref/fncdocip.i }
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/getcntxt.i get }
  if p-mode  <> {&lookup}
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.
  run fill-main-table in this-procedure no-error .
  if error-status:error then undo, return error.
  run fill-tables in this-procedure.
  RUN MYEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
if v-not-uf-set = no then
run uf-set in this-procedure(
    input  ({&uf-findoci-p} + {&delim-par} + {&income-cashless})
    ,input v-cntxt-userid
    ,input RS-view
    ,input v-uf-Naim
    ,input v-uf-print-graft
    ,input v-uf-sort-gr
    ,input v-uf-type-price
    ,input v-uf-type-val
)  no-error .

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE change-view Dialog-Frame
PROCEDURE change-view :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-view as character no-undo.
display
rs-view
with frame {&frame-name}.
assign
tt-c-fin-doc.exch-rate frame {&frame-name}
tt-c-fin-doc.exch-scale
tt-c-fin-doc.sum-doc
.

/*сначала похайдим все что не видно сразу вов сех VIEW потом понемноэку будем открывать*/
hide
tt-c-fin-doc.cor-acc-value
f-cor-acc-descr
tt-c-fin-doc.an-uchet-value
f-an-uchet-descr
tt-c-fin-doc.cel-nazn-value
f-cel-nazn-descr
tt-c-fin-doc.cel-nazn-value

tt-c-fin-doc.perm-date
tt-c-fin-doc.user-name-perm

tt-c-fin-doc.pay-date
tt-c-fin-doc.user-name-pl

tt-c-fin-doc.fact-date
tt-c-fin-doc.user-name-fact


b-exit

b-contract-view
f-contract-date
f-contract-prn-code
f-contract-type
f-contract-curr-abbr
tt-c-fin-doc.contract-curr

f-bank
b-receiver-view
tt-c-fin-doc.receiver-type
tt-c-fin-doc.receiver-code
tt-c-fin-doc.receiver-name
tt-c-fin-doc.receiver-inn
tt-c-fin-doc.receiver-kpp
tt-c-fin-doc.receiver-bank-name
tt-c-fin-doc.receiver-bik
tt-c-fin-doc.receiver-r-schet
tt-c-fin-doc.receiver-c-schet
tt-c-fin-doc.sttm-code
v-sttm-prn-doc-code
IN FRAME Dialog-Frame.

display
F-curr-abbr
with frame {&frame-name}
.
IF AVAILABLE tt-c-fin-doc THEN
  display
  tt-c-fin-doc.fin-doc-code
  tt-c-fin-doc.prn-doc-code
  tt-c-fin-doc.doc-date
  tt-c-fin-doc.user-name-doc
  tt-c-fin-doc.curr-code
  tt-c-fin-doc.obj-type
  tt-c-fin-doc.obj-code
  tt-c-fin-doc.sum-doc
  tt-c-fin-doc.vid-plat
  tt-c-fin-doc.receiver-bank-name
  tt-c-fin-doc.receiver-bik
  tt-c-fin-doc.receiver-r-schet
  tt-c-fin-doc.receiver-c-schet
  tt-c-fin-doc.payer-code
  tt-c-fin-doc.payer-type
  tt-c-fin-doc.payer-name
  tt-c-fin-doc.payer-inn
  tt-c-fin-doc.payer-kpp
  tt-c-fin-doc.payer-bank-name
  tt-c-fin-doc.payer-bik
  tt-c-fin-doc.payer-r-schet
  tt-c-fin-doc.payer-c-schet
  tt-c-fin-doc.naznach-plat
  tt-c-fin-doc.PS
  tt-c-fin-doc.payer-sign1
  tt-c-fin-doc.payer-sign2
  with frame {&frame-name}
  .
  if tt-c-fin-doc.perm-date <> ? then
  display
  tt-c-fin-doc.perm-date
  tt-c-fin-doc.user-name-perm
  with frame {&frame-name}
   .
  if tt-c-fin-doc.pay-date <> ? then
  display
  tt-c-fin-doc.pay-date
  tt-c-fin-doc.user-name-pl
  with frame {&frame-name}
   .

  if tt-c-fin-doc.fact-date <> ? then
  display
  tt-c-fin-doc.fact-date
  tt-c-fin-doc.user-name-fact
  tt-c-fin-doc.sttm-code
  v-sttm-prn-doc-code
  with frame {&frame-name}
  .
ENABLE
b-quit
B-tax
b-other
B-Help
RS-view
b-payer-view
b-receiver-view
WITH FRAME Dialog-Frame.
assign
b-quit:label = "&Выход".
run hide-view-currency in this-procedure.
CASE p-view:
  when "full":U then do:
    IF AVAILABLE tt-c-fin-doc THEN
    display
    f-bank
    tt-c-fin-doc.receiver-type
    tt-c-fin-doc.receiver-code
    tt-c-fin-doc.receiver-name
    tt-c-fin-doc.receiver-inn
    tt-c-fin-doc.receiver-kpp
    with frame {&frame-name}
    .
    display
    tt-c-fin-doc.cor-acc-value    when X_sysconf.is-corr-acc
    f-cor-acc-descr               when X_sysconf.is-corr-acc
    tt-c-fin-doc.an-uchet-value   when X_sysconf.is-an-uchet
    f-an-uchet-descr              when X_sysconf.is-an-uchet
    tt-c-fin-doc.cel-nazn-value   when X_sysconf.is-code-cel-nazn
    f-cel-nazn-descr              when X_sysconf.is-code-cel-nazn
    with frame {&frame-name}
    .
  end. /*whne full*/
  when "brief":U then do:
  end.
  when "contract":U then do:
    display
    b-contract-view
    f-contract-date when tt-c-fin-doc.contract-code <> 0
    f-contract-prn-code when tt-c-fin-doc.contract-code <> 0
    f-contract-type when tt-c-fin-doc.contract-code <> 0
    f-contract-curr-abbr when tt-c-fin-doc.contract-code <> 0
    tt-c-fin-doc.contract-curr when tt-c-fin-doc.contract-code <> 0
    with frame {&frame-name}
    .
    ENABLE
    b-contract-view
    with frame {&frame-name}.
  end.
END CASE.
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

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY RS-view v-sttm-prn-doc-code f-cor-acc-descr f-an-uchet-descr
          f-contract-curr-abbr f-contract-prn-code f-contract-date
          f-contract-type f-cel-nazn-descr F-curr-abbr f-bank
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-fin-doc THEN
    DISPLAY tt-c-fin-doc.prn-doc-code tt-c-fin-doc.vid-plat
          tt-c-fin-doc.fin-doc-code tt-c-fin-doc.perm-date
          tt-c-fin-doc.user-name-perm tt-c-fin-doc.pay-date
          tt-c-fin-doc.doc-date tt-c-fin-doc.user-name-doc tt-c-fin-doc.obj-type
          tt-c-fin-doc.obj-code tt-c-fin-doc.user-name-pl tt-c-fin-doc.fact-date
          tt-c-fin-doc.user-name-fact tt-c-fin-doc.cor-acc-value
          tt-c-fin-doc.an-uchet-value tt-c-fin-doc.contract-curr
          tt-c-fin-doc.cel-nazn-value tt-c-fin-doc.sum-doc
          tt-c-fin-doc.curr-code tt-c-fin-doc.sum-rubl tt-c-fin-doc.exch-rate
          tt-c-fin-doc.exch-scale tt-c-fin-doc.base-rate tt-c-fin-doc.base-scale
          tt-c-fin-doc.sum-base tt-c-fin-doc.contract-rate
          tt-c-fin-doc.contract-scale tt-c-fin-doc.sum-contr
          tt-c-fin-doc.payer-inn tt-c-fin-doc.payer-kpp tt-c-fin-doc.payer-type
          tt-c-fin-doc.receiver-code tt-c-fin-doc.payer-name
          tt-c-fin-doc.payer-bank-name tt-c-fin-doc.payer-r-schet
          tt-c-fin-doc.payer-bik tt-c-fin-doc.payer-c-schet
          tt-c-fin-doc.receiver-inn tt-c-fin-doc.receiver-kpp
          tt-c-fin-doc.receiver-type tt-c-fin-doc.payer-code
          tt-c-fin-doc.receiver-name tt-c-fin-doc.receiver-bank-name
          tt-c-fin-doc.receiver-r-schet tt-c-fin-doc.receiver-bik
          tt-c-fin-doc.receiver-c-schet tt-c-fin-doc.naznach-plat
          tt-c-fin-doc.PS tt-c-fin-doc.payer-sign1 tt-c-fin-doc.payer-sign2
          tt-c-fin-doc.sttm-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-other B-tax B-Help RS-view tt-c-fin-doc.prn-doc-code
         tt-c-fin-doc.vid-plat tt-c-fin-doc.doc-date tt-c-fin-doc.user-name-doc
         tt-c-fin-doc.obj-type tt-c-fin-doc.obj-code tt-c-fin-doc.cor-acc-value
         tt-c-fin-doc.an-uchet-value f-contract-curr-abbr B-contract-view
         tt-c-fin-doc.contract-curr tt-c-fin-doc.cel-nazn-value
         tt-c-fin-doc.sum-doc tt-c-fin-doc.curr-code tt-c-fin-doc.exch-rate
         tt-c-fin-doc.exch-scale B-get-rate tt-c-fin-doc.sum-base
         B-get-contract-rate tt-c-fin-doc.contract-rate
         tt-c-fin-doc.contract-scale tt-c-fin-doc.sum-contr
         tt-c-fin-doc.payer-type tt-c-fin-doc.payer-name B-payer-view
         tt-c-fin-doc.payer-code tt-c-fin-doc.receiver-name
         tt-c-fin-doc.receiver-bank-name B-receiver-view
         tt-c-fin-doc.receiver-c-schet tt-c-fin-doc.naznach-plat
         tt-c-fin-doc.PS tt-c-fin-doc.payer-sign1 tt-c-fin-doc.payer-sign2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-main-table Dialog-Frame
PROCEDURE fill-main-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-recid-schet as recid no-undo .
define variable v-recid-bank as recid no-undo .
{ gbl/curdbnum.i v-db-num }
{ gbl/basecode.i p-host-code v-base-code }
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code.
find first X_sysconf no-lock where
              X_sysconf.host-code = p-host-code.
find first X_clients-host no-lock where
            X_clients-host.obj-type = {&cmp}
        AND   X_clients-host.obj-code = p-host-code  no-error.
if not available X_clients-host then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра вызова p-host-code"  p-host-code
  view-as alert-box ERROR.
  undo, return error.
end.
find first X_firm no-lock where
            X_firm.firm-code = p-host-code.
for each tt-c-fin-doc:
  delete tt-c-fin-doc.
end.
for each tt0-fin-doc-attr:
  delete tt0-fin-doc-attr.
end.
for each tt0-fin-doc-tax:
  delete tt0-fin-doc-tax.
end.

find first locked_c-fin-doc no-lock where
          recid(locked_c-fin-doc) = p-doc-rec no-error .
if not available locked_c-fin-doc then do:
find first locked_c-fin-doc no-lock where
            locked_c-fin-doc.host-code = p-host-code
        AND locked_c-fin-doc.fin-doc-code = p-fin-doc-code no-error .
end.

if not available locked_c-fin-doc then do:
message
vss-workfile vss-revision vss-description skip
"Не найдена запись ПРИХОДНОЕ ПЛАТЕЖНОЕ ПОРУЧЕНИЕ"
view-as alert-box error .
undo, return error.
end.
create tt-c-fin-doc.
buffer-copy locked_c-fin-doc to tt-c-fin-doc.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-inn like ub.firm.inn no-undo .
define variable v-kpp like ub.firm.kpp no-undo .
define variable g-log as logical no-undo.
assign
    tt-c-fin-doc.sum-rubl :label in frame {&frame-name} = "{&abbr_rubli_firstshift}"
.
tt-c-fin-doc.payer-inn:label in frame {&frame-name} = "{&abbr_inn_allshift}".
tt-c-fin-doc.receiver-inn:label in frame {&frame-name} = "{&abbr_inn_allshift}".
tt-c-fin-doc.payer-kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}".
tt-c-fin-doc.receiver-kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}".

run uf-get in this-procedure(
    input  ({&uf-findoci-p} + {&delim-par} + {&income-cashless})
    ,input  v-cntxt-userid
    ,output v-uf-List_
    ,output v-uf-Naim
    ,output v-uf-print-graft
    ,output v-uf-sort-gr
    ,output v-uf-type-price
    ,output v-uf-type-val
)  no-error.
if not error-status:error
and not v-uf-LIst_ = "":U
then do:
    assign
    v-view =  entry(1, v-uf-List_, {&delim-par})
    .
end.
assign
frame {&frame-name}:title = frame {&frame-name}:title + {&space-char} + x_clients-host.obj-name
tt-c-fin-doc.payer-type:radio-buttons = "Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                                         "Чел" + {&comma-char} + {&prs}
rs-view:radio-buttons = "&Полностью" + {&comma-char} + "full":U +  {&comma-char} +
                                    "&Сокращ." + {&comma-char} + "brief":U + {&comma-char} +
                                    "&Договор" + {&comma-char} + "contract":U
tt-c-fin-doc.obj-type:radio-buttons = "Маг" + {&comma-char} + {&shop} + {&comma-char} +
                                      "Скл" + {&comma-char} + {&stock}

tt-c-fin-doc.vid-plat:list-items = {&fin-vp-codes}
rs-view = v-view
.
if tt-c-fin-doc.contract-code = 0 then do:
    assign
    g-log = rs-view:disable(radio-label("contract":U, RS-view:radio-buttons))
    .
    if rs-view = "contract":U then
    assign
    rs-view = "full":U
    v-not-uf-set = yes.
end.

find first X_currency no-lock where
              X_currency.curr-code = tt-c-fin-doc.curr-code.
assign
f-curr-abbr = X_Currency.curr-abbr.
if tt-c-fin-doc.cor-acc <> 0 then do:
  find first X_fin-code-cor-acc no-lock where
              X_fin-code-cor-acc.fin-code  = tt-c-fin-doc.cor-acc no-error.
  if available X_fin-code-cor-acc then do:
    assign
    f-cor-acc-descr = X_fin-code-cor-acc.descr.
  end.
  if not available X_fin-code-cor-acc
  or (p-mode = {&update} and X_fin-code-cor-acc.code-value <> tt-c-fin-doc.cor-acc-value ) then do:
    assign
    f-cor-acc-descr = "!!!Код больше не существует".
  end.
end.
if tt-c-fin-doc.an-uchet-code <> 0 then do:
find first X_fin-code-an-uchet no-lock where
              X_fin-code-an-uchet.fin-code  = tt-c-fin-doc.an-uchet-code no-error.
  if available X_fin-code-an-uchet then do:
    assign
    f-an-uchet-descr = X_fin-code-an-uchet.descr.
  end.
  if not available X_fin-code-an-uchet
  or (p-mode = {&update} and X_fin-code-an-uchet.code-value <> tt-c-fin-doc.an-uchet-value ) then do:
    assign
    f-an-uchet-descr = "!!!Код больше не существует".
  end.
end.
if tt-c-fin-doc.cel-nazn-code <> 0 then do:
  find first X_fin-code-cel-nazn no-lock where
                X_fin-code-cel-nazn.fin-code  = tt-c-fin-doc.cel-nazn-code no-error.
  if available X_fin-code-cel-nazn then do:
    assign
    f-cel-nazn-descr = X_fin-code-cel-nazn.descr.
  end.
  if not available X_fin-code-cel-nazn
  or (p-mode = {&update} and X_fin-code-cel-nazn.code-value <> tt-c-fin-doc.cel-nazn-value ) then do:
    assign
    f-cel-nazn-descr = "!!!Код больше не существует".
  end.
end.
IF tt-c-fin-doc.sttm-code <> 0 THEN DO:
  FIND FIRST X_fin-statement NO-LOCK WHERE
            X_fin-statement.host-code  = tt-c-fin-doc.host-code
        AND X_fin-statement.sttm-code  = tt-c-fin-doc.sttm-code NO-ERROR.
  IF NOT AVAILABLE X_fin-statement THEN DO:
      FIND FIRST X_c-fin-statement NO-LOCK WHERE
                X_c-fin-statement.host-code  = tt-c-fin-doc.host-code
            AND X_c-fin-statement.sttm-code  = tt-c-fin-doc.sttm-code NO-ERROR.
    IF AVAILABLE X_c-fin-statement THEN DO:
       ASSIGN
       v-sttm-prn-doc-CODE = X_c-fin-statement.prn-doc-code.
    END.
    ELSE DO:
        ASSIGN
        v-sttm-prn-doc-CODE = "@НЕИЗВЕСТНАЯ ВЫПИСКА".
    END.
  END.
  ELSE DO:
      ASSIGN
      v-sttm-prn-doc-CODE = X_fin-statement.prn-doc-code.
  END.
END.
run proc-color-widgets in this-procedure({&not-in-form-list}, no, yes, ?, grey_color).
run proc-color-widgets in this-procedure({&in-form-list}, no, yes, ?, grey_color).
run change-view in this-procedure(rs-view).
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME