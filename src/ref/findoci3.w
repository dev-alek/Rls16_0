&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_fin-doc FOR ub.fin-doc.
DEFINE NEW SHARED TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_firm FOR ub.firm.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision: 12c0f79a3864, 3013, rls $
$Author: EShklyar $
$Date: Ср апр 06 16:23:44 2022 +0300 $
$Workfile: findoci3.w $
$Archive: ref/findoci3.w $

Карточка редактирования приходного платежного поручени

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
/*может быть {&add-def} {&update} {&lookup}*/

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-obj-type  like ub.fin-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.fin-doc.obj-code no-undo .
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-contract-code like ub.fin-doc.contract-code no-undo .
define input parameter p-ob-doc-code like ub.fin-ob.doc-code no-undo .
define input parameter p-payer-type like ub.fin-doc.payer-type no-undo .
define input parameter p-payer-code like ub.fin-doc.payer-code no-undo .
define input parameter p-receiver-code-schet like ub.fin-doc.receiver-code-schet no-undo.
define input parameter p-payer-code-schet like ub.fin-doc.payer-code-schet no-undo.
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define input parameter p-other as character no-undo .



define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 12c0f79a3864, 3013, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoci3.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoci3.w $":U .
define variable vss-description as character no-undo init "Карточка редактирования приходного платежного поручения".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-view as character no-undo init "full":U.
define variable v-not-uf-set as logical no-undo.
define variable v-copy-mode as logical no-undo .
define variable v-main-sum as character no-undo init "sum-doc":U.
define variable v-main-curr as character no-undo init "":U.
define variable v-rubf          as logical no-undo .
define variable v-exchf         as logical no-undo .
define variable v-basef         as logical no-undo .
define variable v-baseratef     as logical no-undo .
define variable v-contractf     as logical no-undo .
define variable v-contractratef as logical no-undo .
define variable v-limit-access  as integer no-undo .
define variable paramVne as character no-undo .

define buffer X_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer X_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer X_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer X_currency for ub.currency.
define buffer X_contract-currency for ub.currency.
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
define buffer X_clients-obj for ub.clients.

define buffer X_receiver-firm for ub.firm.
define buffer X_receiver-person for ub.person.
define buffer X_fin-code-cor-acc1 for ub.fin-code-cor-acc.
DEFINE BUFFER X_fin-statement FOR ub.fin-statement.
define variable f-cor-acc1-descr as character no-undo .


DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.


define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-tab-order as character no-undo.
define variable v-buttons-tab-order as character no-undo .
define variable v-an-uchet-tab-order as character no-undo.
define variable v-sum-curr-tab-order as character no-undo.
define variable v-contract-tab-order as character no-undo init "b-contract-view,":U.
define variable v-sum-doc-tab-order  as character no-undo init "sum-doc,curr-code,b-currency,b-calc,":U.

{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ cmp/showinf.i  }
{ ref/fndocip.i  }
{ gbl/usr-flt.i  }
{ cmp/operlist.i }
{ gbl/color.i    }
{ gbl/getcntxt.i def }
{ gbl/usrfulnf.i }
{ ref/getCliKassa.i }
{ ref/findocip.i &action="define" }

&scop buttons-tab-order    "b-exit,b-quit,b-tax,b-cards,b-print,b-hist,b-help,"

&scop cor-acc-tab-order "cor-acc-value,b-cor-acc,"
&scop an-uchet-tab-order "an-uchet-value,b-an-uchet,"
&scop cel-nazn-tab-order "cel-nazn-value,b-cel-nazn,"


&scop brief-view-tab-order   ~{&buttons-tab-order~} + ~
                             "prn-doc-code,vid-plat,doc-date," + ~
                            "obj-type,obj-code,b-obj,payer-type,payer-code,b-payer,payer-name,b-payer-schet,b-payer-view," + ~
                             v-sum-curr-tab-order + "b-receiver-schet,b-receiver-view," +  ~
                            "naznach-plat,PS,payer-sign1,payer-sign2"

&scop full-view-tab-order   ~{&buttons-tab-order~} + ~
"prn-doc-code,vid-plat,doc-date,obj-type,obj-code,b-obj," + ~
                            v-an-uchet-tab-order + ~
                            "payer-type,payer-code,b-payer,payer-name,b-payer-schet,b-payer-view," +  ~
                            v-sum-curr-tab-order + "b-receiver-schet,b-receiver-view," +  ~
                            "naznach-plat,PS,payer-sign1,payer-sign2"

&scop contract-view-tab-order  ~{&buttons-tab-order~} + ~
                             "prn-doc-code,vid-plat,doc-date,obj-type,obj-code,b-obj," + ~
                             v-contract-tab-order +  ~
                            "payer-type,payer-code,b-payer,payer-name,b-payer-schet,b-payer-view," +  ~
                            v-sum-curr-tab-order + "b-receiver-schet,b-receiver-view," +  ~
                            "naznach-plat,PS,payer-sign1,payer-sign2"

&scop not-in-form-list "f-an-uchet-descr,f-cel-nazn-descr,f-contract-curr-abbr,f-contract-date,f-contract-prn-code,f-contract-rate," +  ~
                       "f-contract-scale,f-contract-type,f-cor-acc-descr,base-rate,base-scale,curr-code,exch-rate,exch-scale,contract-rate,contract-scale," +  ~
                       "fact-date,fin-doc-code,payer-code,payer-type,pay-date,perm-date,PS,receiver-code,receiver-type,sum-base,sum-rubl,sum-contr," +  ~
                       "user-name-doc,user-name-fact,user-name-perm.user-name-pl"

&scop in-form-list    "F-curr-abbr,an-uchet-value,cel-nazn-value,cor-acc-value,doc-date," + ~
                      "naznach-plat,payer-name,payer-inn,payer-kpp,payer-bank-name,payer-bank-city,payer-bik,payer-r-schet,payer-c-schet," + ~
                      "prn-doc-code,receiver-name,receiver-inn,receiver-kpp,receiver-bank-name,receiver-bank-city,receiver-bik,receiver-r-schet,receiver-c-schet,payer-sign1,payer-sign2" + ~
                      "sum-doc"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_fin-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame locked_fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame locked_fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-fin-doc.prn-doc-code tt-fin-doc.vid-plat ~
tt-fin-doc.doc-date tt-fin-doc.user-name-doc tt-fin-doc.obj-type ~
tt-fin-doc.obj-code tt-fin-doc.cor-acc-value tt-fin-doc.an-uchet-value ~
tt-fin-doc.contract-curr tt-fin-doc.cel-nazn-value tt-fin-doc.payer-type ~
tt-fin-doc.payer-code tt-fin-doc.payer-name tt-fin-doc.payer-bank-city ~
tt-fin-doc.sum-doc tt-fin-doc.curr-code tt-fin-doc.exch-rate ~
tt-fin-doc.exch-scale tt-fin-doc.sum-rubl tt-fin-doc.sum-base ~
tt-fin-doc.contract-rate tt-fin-doc.contract-scale tt-fin-doc.sum-contr ~
tt-fin-doc.receiver-name tt-fin-doc.receiver-bank-name ~
tt-fin-doc.receiver-bank-city tt-fin-doc.receiver-c-schet ~
tt-fin-doc.naznach-plat tt-fin-doc.PS tt-fin-doc.payer-sign1 ~
tt-fin-doc.payer-sign2
&Scoped-define ENABLED-TABLES tt-fin-doc
&Scoped-define FIRST-ENABLED-TABLE tt-fin-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit b-other B-tax B-cards B-print ~
B-hist B-Help RS-view B-obj B-cor-acc B-an-uchet f-contract-curr-abbr ~
B-contract-view B-cel-nazn B-payer B-payer-schet B-payer-view ~
f-rest-con-sum B-currency B-calc B-receiver-schet B-receiver-view
&Scoped-Define DISPLAYED-FIELDS tt-fin-doc.prn-doc-code tt-fin-doc.vid-plat ~
tt-fin-doc.fin-doc-code tt-fin-doc.perm-date tt-fin-doc.user-name-perm ~
tt-fin-doc.pay-date tt-fin-doc.doc-date tt-fin-doc.user-name-doc ~
tt-fin-doc.obj-type tt-fin-doc.obj-code tt-fin-doc.user-name-pl ~
tt-fin-doc.sttm-code tt-fin-doc.fact-date tt-fin-doc.user-name-fact ~
tt-fin-doc.cor-acc-value tt-fin-doc.an-uchet-value tt-fin-doc.contract-curr ~
tt-fin-doc.cel-nazn-value tt-fin-doc.payer-inn tt-fin-doc.payer-kpp ~
tt-fin-doc.payer-type tt-fin-doc.payer-code tt-fin-doc.payer-name ~
tt-fin-doc.payer-bank-name tt-fin-doc.payer-bank-city ~
tt-fin-doc.payer-r-schet tt-fin-doc.payer-bik tt-fin-doc.payer-c-schet ~
tt-fin-doc.sum-doc tt-fin-doc.curr-code tt-fin-doc.exch-rate ~
tt-fin-doc.exch-scale tt-fin-doc.sum-rubl tt-fin-doc.base-rate ~
tt-fin-doc.base-scale tt-fin-doc.sum-base tt-fin-doc.contract-rate ~
tt-fin-doc.contract-scale tt-fin-doc.sum-contr tt-fin-doc.receiver-inn ~
tt-fin-doc.receiver-kpp tt-fin-doc.receiver-type tt-fin-doc.receiver-name ~
tt-fin-doc.receiver-code tt-fin-doc.receiver-bank-name ~
tt-fin-doc.receiver-bank-city tt-fin-doc.receiver-r-schet ~
tt-fin-doc.receiver-bik tt-fin-doc.receiver-c-schet tt-fin-doc.naznach-plat ~
tt-fin-doc.PS tt-fin-doc.payer-sign1 tt-fin-doc.payer-sign2
&Scoped-define DISPLAYED-TABLES tt-fin-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-fin-doc
&Scoped-Define DISPLAYED-OBJECTS RS-view v-sttm-prn-doc-code ~
f-cor-acc-descr f-an-uchet-descr f-contract-curr-abbr f-contract-prn-code ~
f-contract-date f-contract-type f-cel-nazn-descr f-rest-con-sum F-curr-abbr ~
f-bank

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-an-uchet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-calc
     LABEL "Расчет сумм и курсов"
     SIZE 22 BY 1.

DEFINE BUTTON B-cards
     LABEL "&Карты"
     SIZE 10 BY 1.

DEFINE BUTTON B-cel-nazn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-contract-view
     LABEL "&Договор"
     SIZE 12 BY 1
     FGCOLOR 4 .

DEFINE BUTTON B-cor-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-currency
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-cashbook
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

DEFINE BUTTON B-hist
     LABEL "&История"
     SIZE 3 BY 1.

DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON b-other
     LABEL "До&полн."
     SIZE 10 BY 1.

DEFINE BUTTON B-payer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY .77.

DEFINE BUTTON B-payer-schet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-payer-view
     LABEL "П&лательщик"
     SIZE 12 BY 1
     FGCOLOR 4 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-receiver-schet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

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
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE l-cashbook AS CHARACTER FORMAT "X(256)":U INITIAL "Кассовая книга:"
      VIEW-AS TEXT
     SIZE 15 BY .67
     NO-UNDO.
     
DEFINE VARIABLE f-cashbook AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.

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

DEFINE VARIABLE f-rest-con-sum AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Своб.ост.(в.д.)"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 9  NO-UNDO.

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
      locked_fin-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-other AT ROW 1 COL 49
     B-tax AT ROW 1 COL 59
     B-cards AT ROW 1 COL 69 WIDGET-ID 2
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     RS-view AT ROW 1.07 COL 21.1 NO-LABEL
     tt-fin-doc.prn-doc-code AT ROW 2 COL 1
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     tt-fin-doc.vid-plat AT ROW 2 COL 29.1 COLON-ALIGNED
          LABEL "Вид пл-жа"
          VIEW-AS COMBO-BOX INNER-LINES 4
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 11 BY 1
     tt-fin-doc.fin-doc-code AT ROW 2 COL 49.5 COLON-ALIGNED
          LABEL "Внутр.№"
          VIEW-AS FILL-IN
          SIZE 10.4 BY 1
     tt-fin-doc.perm-date AT ROW 2 COL 71.5 COLON-ALIGNED
          LABEL "Дата разр"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-fin-doc.user-name-perm AT ROW 2 COL 82.8 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.pay-date AT ROW 2.97 COL 71.5 COLON-ALIGNED
          LABEL "В банк"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-doc.doc-date AT ROW 3 COL 11 COLON-ALIGNED
          LABEL "Дата сост."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-doc.user-name-doc AT ROW 3 COL 22.4 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.obj-type AT ROW 3 COL 39.4 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U
          SIZE 12.6 BY 1
     tt-fin-doc.obj-code AT ROW 3 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1
     B-obj AT ROW 3 COL 59
     tt-fin-doc.user-name-pl AT ROW 3 COL 82.8 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.sttm-code AT ROW 3.93 COL 11 COLON-ALIGNED
          LABEL "Выписка"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     v-sttm-prn-doc-code AT ROW 3.93 COL 22.4 COLON-ALIGNED NO-LABEL
     tt-fin-doc.fact-date AT ROW 4 COL 71.5 COLON-ALIGNED
          LABEL "Дата факт(списано со сч.)"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-fin-doc.user-name-fact AT ROW 4 COL 82.8 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-fin-doc.cor-acc-value AT ROW 5 COL 16.3 COLON-ALIGNED
          LABEL "Корсчет"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     B-cor-acc AT ROW 5 COL 32.5
     f-cor-acc-descr AT ROW 5 COL 35.4 COLON-ALIGNED NO-LABEL
     tt-fin-doc.an-uchet-value AT ROW 6 COL 16.3 COLON-ALIGNED
          LABEL "Код ан. уч."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     B-an-uchet AT ROW 6 COL 32.5
     f-an-uchet-descr AT ROW 6 COL 35.4 COLON-ALIGNED NO-LABEL
     f-contract-curr-abbr AT ROW 6.2 COL 55.3 COLON-ALIGNED NO-LABEL
     B-contract-view AT ROW 6.27 COL 1
     f-contract-prn-code AT ROW 6.27 COL 12 COLON-ALIGNED NO-LABEL
     f-contract-date AT ROW 6.27 COL 36.6 COLON-ALIGNED
     tt-fin-doc.contract-curr AT ROW 6.27 COL 49.1 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-contract-type AT ROW 6.27 COL 72 COLON-ALIGNED
     tt-fin-doc.cel-nazn-value AT ROW 7 COL 16.3 COLON-ALIGNED
          LABEL "Код цел.назн."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
     B-cel-nazn AT ROW 7 COL 32.5
     f-cel-nazn-descr AT ROW 7 COL 35.4 COLON-ALIGNED NO-LABEL
     tt-fin-doc.payer-inn AT ROW 8 COL 1
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 13 BY .77
          FGCOLOR 4
     tt-fin-doc.payer-kpp AT ROW 8 COL 22.5 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 10 BY .77
          FGCOLOR 4
     tt-fin-doc.payer-type AT ROW 8 COL 35 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 1", "2":U
          SIZE 11.4 BY .77
          FGCOLOR 4
     tt-fin-doc.payer-code AT ROW 8 COL 43 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 9 BY .77
     B-payer AT ROW 8 COL 54.3
     tt-fin-doc.payer-name AT ROW 8 COL 56.6 COLON-ALIGNED NO-LABEL FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 40.6 BY .77
          FGCOLOR 4
     B-payer-schet AT ROW 8.77 COL 5.5
     tt-fin-doc.payer-bank-name AT ROW 8.77 COL 7 COLON-ALIGNED NO-LABEL FORMAT "X(52)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          FGCOLOR 4
     tt-fin-doc.payer-bank-city AT ROW 8.77 COL 59 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 26.5 BY 1
     B-payer-view AT ROW 8.77 COL 87.3
     tt-fin-doc.payer-r-schet AT ROW 9.77 COL 4.1 COLON-ALIGNED
          LABEL "Р/с"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 4
     tt-fin-doc.payer-bik AT ROW 9.77 COL 33.9 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     tt-fin-doc.payer-c-schet AT ROW 9.77 COL 58.9 COLON-ALIGNED
          LABEL "Кор.счет"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 4
     tt-fin-doc.sum-doc AT ROW 10.77 COL 6 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          FGCOLOR 4
     f-rest-con-sum AT ROW 10.77 COL 72.3 COLON-ALIGNED
     tt-fin-doc.curr-code AT ROW 10.8 COL 41.9 COLON-ALIGNED
          LABEL "Вал"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-currency AT ROW 10.8 COL 48.9
     F-curr-abbr AT ROW 10.8 COL 50.9 COLON-ALIGNED NO-LABEL
     B-calc AT ROW 11.77 COL 1.5
     tt-fin-doc.exch-rate AT ROW 11.77 COL 34.5 COLON-ALIGNED
          LABEL "Курс пл-жа"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-fin-doc.exch-scale AT ROW 11.77 COL 44.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-fin-doc.sum-rubl AT ROW 11.77 COL 72.3 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-fin-doc.base-rate AT ROW 12.77 COL 34.5 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-fin-doc.base-scale AT ROW 12.77 COL 44.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-fin-doc.sum-base AT ROW 12.77 COL 72.1 COLON-ALIGNED
          LABEL "Б.в."
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-fin-doc.contract-rate AT ROW 13.77 COL 34.5 COLON-ALIGNED
          LABEL "Курс дог."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-fin-doc.contract-scale AT ROW 13.77 COL 44.8 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.6 BY 1
     tt-fin-doc.sum-contr AT ROW 13.77 COL 72.3 COLON-ALIGNED
          LABEL "в.дог-ра"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-fin-doc.receiver-inn AT ROW 14.77 COL 1
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 13 BY .77
          FGCOLOR 4
     tt-fin-doc.receiver-kpp AT ROW 14.77 COL 22.5 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 10 BY .77
          FGCOLOR 4
     tt-fin-doc.receiver-type AT ROW 14.77 COL 41.6 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY .77
     tt-fin-doc.receiver-name AT ROW 14.77 COL 44.1 COLON-ALIGNED NO-LABEL FORMAT "X(130)"
          VIEW-AS FILL-IN
          SIZE 53.1 BY .77
          FGCOLOR 4
     tt-fin-doc.receiver-code AT ROW 14.83 COL 33.3 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY .77
     B-receiver-schet AT ROW 15.5 COL 5.5
     tt-fin-doc.receiver-bank-name AT ROW 15.5 COL 7 COLON-ALIGNED NO-LABEL FORMAT "X(52)"
          VIEW-AS FILL-IN
          SIZE 52 BY 1
          FGCOLOR 4
     tt-fin-doc.receiver-bank-city AT ROW 15.5 COL 59 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 25.5 BY 1
     B-receiver-view AT ROW 15.5 COL 86.8
     tt-fin-doc.receiver-r-schet AT ROW 16.5 COL 4.1 COLON-ALIGNED
          LABEL "Р/c"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 4
     tt-fin-doc.receiver-bik AT ROW 16.5 COL 33.9 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     tt-fin-doc.receiver-c-schet AT ROW 16.5 COL 58.9 COLON-ALIGNED
          LABEL "Кор.счет"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
          FGCOLOR 4
     tt-fin-doc.naznach-plat AT ROW 18.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5 TOOLTIP "Основание платежа"
          FGCOLOR 4
     tt-fin-doc.PS AT ROW 18.5 COL 50 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5 TOOLTIP "Дополнительная информация, не печатающаяся в ордере"
     tt-fin-doc.payer-sign1 AT ROW 20 COL 1.4
          LABEL "Рук. орг-ции"
          VIEW-AS FILL-IN
          SIZE 30.9 BY 1
          FGCOLOR 4
     tt-fin-doc.payer-sign2 AT ROW 20 COL 64.6 COLON-ALIGNED
          LABEL "Гл. бухгалтер"
          VIEW-AS FILL-IN
          SIZE 30.9 BY 1
          FGCOLOR 4
     l-cashbook at row 21.2 col 1 no-label
     f-cashbook at row 21 col 19 no-label
     b-cashbook at row 21 col 61 FGCOLOR 4    
     f-bank AT ROW 15.5 COL 1 NO-LABEL
     "(Примечание (доп.информация, не печатается))" VIEW-AS TEXT
          SIZE 47.1 BY 1 AT ROW 17.5 COL 50.5
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     "Назначение платежа" VIEW-AS TEXT
          SIZE 19.4 BY 1 AT ROW 17.5 COL 1.1
          FGCOLOR 4
     "Банк" VIEW-AS TEXT
          SIZE 4.4 BY 1 AT ROW 8.77 COL 1
          FGCOLOR 4
     SPACE(93.90) SKIP(11.23)
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
      TABLE: locked_fin-doc B "?" ? ub fin-doc
      TABLE: tt-fin-doc T "NEW SHARED" NO-UNDO ub fin-doc
      TABLE: tt0-fin-doc-attr T "?" NO-UNDO ub fin-doc-attr
      TABLE: tt0-fin-doc-tax T "?" NO-UNDO ub fin-doc-tax
      TABLE: tt0-payment T "?" NO-UNDO ub payment
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_firm B "?" ? ub firm
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-fin-doc.an-uchet-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.base-rate IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.base-scale IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.cel-nazn-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.contract-curr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.contract-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.contract-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.cor-acc-value IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.curr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.doc-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.exch-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.exch-scale IN FRAME Dialog-Frame
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
/* SETTINGS FOR FILL-IN tt-fin-doc.fact-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.fin-doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.pay-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-bank-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-bank-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-bik IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-c-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-inn IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-kpp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-r-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-sign1 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-sign2 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.perm-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.prn-doc-code IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-bank-city IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-bank-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-bik IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-c-schet IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-inn IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-kpp IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-r-schet IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-fin-doc.sttm-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.sum-base IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.sum-contr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.sum-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.user-name-doc IN FRAME Dialog-Frame
   EXP-FORMAT                                                           */
/* SETTINGS FOR FILL-IN tt-fin-doc.user-name-fact IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-fin-doc.user-name-perm IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-fin-doc.user-name-pl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN v-sttm-prn-doc-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX tt-fin-doc.vid-plat IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.locked_fin-doc"
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
  run ref/fndoci4d.w (
 INPUT     parParentProc
/*текущая фирма*/
,input p-curr-host-code
,input p-mode
,input tt-fin-doc.host-code
,input tt-fin-doc.fin-doc-code
,input tt-fin-doc.fin-ext-doc-type
,input-output p-doc-rec ) no-error.
if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-format as integer no-undo .
define variable v-log as logical no-undo .
define variable v-cmp as character no-undo .
buffer-compare tt-fin-doc to locked_fin-doc
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
  message
  "Вы изменили ПЛАТЕЖ, но не сохранили его" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log) no-error.
run ref/fdoc-prn.p (
        input parparentproc
      , input this-procedure
      , input string(recid(locked_fin-doc))
                      ) no-error.

if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/colorhnd.i }

{ ref/findocip.i &action="define2" }
{ ref/findocip.i &action="define3" }
{ ref/findocip.i
&action="triggers"
&doc-type="income-cashless"
&my-side=receiver
&cli-side=payer
&my-title="'ПОЛУЧАТЕЛЯ'"
&cli-side-title="'ПЛАТЕЛЬЩИКА'"
&cli-side-title0="'ПЛАТЕЛЬЩИК'"
&cli-sign=payer-sign1
 }

{ gbl/app_help.i }
{ ref/tabhndmv.i v-tab-order underline-tb }
{ gbl/rethndmv.i v-tab-order underline-tb "APPLY 'CHOOSE' TO b-exit in frame {&frame-name}." }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  if p-mode  <> {&add-def}
  and p-mode <> {&update}
  and p-mode <> {&lookup}
  and p-mode <> {&add-copy}
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.
  run fill-main-table in this-procedure no-error .
  if error-status:error then do:
    if return-value = "exit":U then undo, return .
    undo, return error.
  end.
  run fill-tables in this-procedure.
  RUN MYEnable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
if v-not-uf-set = no then
run uf-set in this-procedure(
    input  ({&uf-findoci-p} + {&delim-par} + {&income-cashless})
    ,input  g#userid
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
tt-fin-doc.exch-rate frame {&frame-name}
tt-fin-doc.exch-scale
tt-fin-doc.obj-type
tt-fin-doc.obj-code
tt-fin-doc.sum-doc
tt-fin-doc.prn-doc-code
tt-fin-doc.payer-name
tt-fin-doc.naznach-plat
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign2
tt-fin-doc.PS
.
/*сначала похайдим все что не видно сразу вов сех VIEW потом понемножку будем открывать*/
hide
tt-fin-doc.cor-acc-value
f-cor-acc-descr
tt-fin-doc.an-uchet-value
f-an-uchet-descr
tt-fin-doc.cel-nazn-value
f-cel-nazn-descr
B-cor-acc
B-an-uchet
tt-fin-doc.cel-nazn-value
B-cel-nazn

tt-fin-doc.perm-date
tt-fin-doc.user-name-perm

tt-fin-doc.pay-date
tt-fin-doc.user-name-pl

tt-fin-doc.fact-date
tt-fin-doc.user-name-fact


b-exit
B-payer

b-contract-view
f-contract-date
f-contract-prn-code
f-contract-type
f-contract-curr-abbr
tt-fin-doc.contract-curr

f-bank
b-receiver-view
tt-fin-doc.receiver-type
tt-fin-doc.receiver-code
tt-fin-doc.receiver-name
tt-fin-doc.receiver-inn
tt-fin-doc.receiver-kpp
tt-fin-doc.receiver-bank-name
tt-fin-doc.receiver-bank-city
tt-fin-doc.receiver-bik
tt-fin-doc.receiver-r-schet
tt-fin-doc.receiver-c-schet
b-receiver-schet
tt-fin-doc.sttm-code
v-sttm-prn-doc-code
IN FRAME Dialog-Frame.

display
F-curr-abbr
b-currency
with frame {&frame-name}
.
IF AVAILABLE tt-fin-doc THEN
  display
  tt-fin-doc.fin-doc-code
  tt-fin-doc.prn-doc-code
  tt-fin-doc.doc-date
  usrfulnf(tt-fin-doc.user-name-doc) @ tt-fin-doc.user-name-doc
  tt-fin-doc.curr-code
  tt-fin-doc.obj-type
  tt-fin-doc.obj-code
  tt-fin-doc.sum-doc
  tt-fin-doc.vid-plat
  tt-fin-doc.receiver-bank-name
  tt-fin-doc.receiver-bank-city
  tt-fin-doc.receiver-bik
  tt-fin-doc.receiver-r-schet
  tt-fin-doc.receiver-c-schet
  tt-fin-doc.payer-code
  tt-fin-doc.payer-type
  tt-fin-doc.payer-name
  tt-fin-doc.payer-inn
  tt-fin-doc.payer-kpp
  tt-fin-doc.payer-bank-name
  tt-fin-doc.payer-bank-city
  tt-fin-doc.payer-bik
  tt-fin-doc.payer-r-schet
  tt-fin-doc.payer-c-schet
  tt-fin-doc.naznach-plat
  tt-fin-doc.PS
  tt-fin-doc.payer-sign1
  tt-fin-doc.payer-sign2
  with frame {&frame-name}
  .
  if tt-fin-doc.perm-date <> ? then
  display
  tt-fin-doc.perm-date
  usrfulnf(tt-fin-doc.user-name-perm) @ tt-fin-doc.user-name-perm
  with frame {&frame-name}
   .
  if tt-fin-doc.pay-date <> ? then
  display
  tt-fin-doc.pay-date
  usrfulnf(tt-fin-doc.user-name-pl) @ tt-fin-doc.user-name-pl
  with frame {&frame-name}
   .

  if tt-fin-doc.fact-date <> ? then
  display
  tt-fin-doc.fact-date
  usrfulnf(tt-fin-doc.user-name-fact) @ tt-fin-doc.user-name-fact
  tt-fin-doc.sttm-code
  v-sttm-prn-doc-code
  with frame {&frame-name}
  .
ENABLE
b-quit
B-tax
b-cards
b-other
B-print when p-mode <> {&add-def}
B-hist when p-mode <> {&add-def}
B-Help
RS-view
b-payer-view
b-receiver-view
WITH FRAME Dialog-Frame.
if p-mode <> {&lookup} then do:
  ENABLE
  B-exit
  tt-fin-doc.prn-doc-code  when v-limit-access < 2
  tt-fin-doc.doc-date when v-limit-access = 0
  b-calc  when v-limit-access = 0
  b-obj   when not v-is-auto-obj
  tt-fin-doc.obj-type   when not v-is-auto-obj
  tt-fin-doc.obj-code   when not v-is-auto-obj
  tt-fin-doc.PS
  WITH FRAME Dialog-Frame.
  if v-limit-access = 0 then do:
    ENABLE
    tt-fin-doc.vid-plat
    tt-fin-doc.curr-code
    B-currency
    tt-fin-doc.sum-doc
    b-receiver-schet
    tt-fin-doc.payer-code when tt-fin-doc.contract-code = 0
    B-payer               when tt-fin-doc.contract-code = 0
    b-payer-schet
    tt-fin-doc.payer-type when tt-fin-doc.contract-code = 0
    tt-fin-doc.payer-name when tt-fin-doc.contract-code = 0
    tt-fin-doc.naznach-plat
    tt-fin-doc.payer-sign1
    tt-fin-doc.payer-sign2
    WITH FRAME Dialog-Frame.
    end.
end.
else do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
run hide-view-currency in this-procedure.
CASE p-view:
  when "full":U then do:
    assign
    v-tab-order = {&full-view-tab-order}
    .
    IF AVAILABLE tt-fin-doc THEN
    display
    f-bank
    tt-fin-doc.receiver-type
    tt-fin-doc.receiver-code
    tt-fin-doc.receiver-name
    tt-fin-doc.receiver-inn
    tt-fin-doc.receiver-kpp
    with frame {&frame-name}
    .
    display
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    with frame {&frame-name}
    .
    if v-limit-access < 3 then do:
      /*поле открыто всегда по указанию Суслова*/
      ENABLE
      tt-fin-doc.cor-acc-value       /*when X_sysconf.is-corr-acc*/
      B-cor-acc                      /*when X_sysconf.is-corr-acc*/
      tt-fin-doc.an-uchet-value      /*when X_sysconf.is-an-uchet*/
      B-an-uchet                     /*when X_sysconf.is-an-uchet*/
      tt-fin-doc.cel-nazn-value      /*when X_sysconf.is-code-cel-nazn*/
      B-cel-nazn                     /*when X_sysconf.is-code-cel-nazn*/
      WITH FRAME Dialog-Frame.
    end.
  end. /*whne full*/
  when "brief":U then do:
     assign
     v-tab-order = {&brief-view-tab-order}
     .
  end.
  when "contract":U then do:
    assign
    v-tab-order = {&contract-view-tab-order}
    .
    display
    b-contract-view
    f-contract-date when tt-fin-doc.contract-code <> 0
    f-contract-prn-code when tt-fin-doc.contract-code <> 0
    f-contract-type when tt-fin-doc.contract-code <> 0
    f-contract-curr-abbr when tt-fin-doc.contract-code <> 0
    tt-fin-doc.contract-curr when tt-fin-doc.contract-code <> 0
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
          f-contract-type f-cel-nazn-descr f-rest-con-sum F-curr-abbr f-bank
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-doc THEN
    DISPLAY tt-fin-doc.prn-doc-code tt-fin-doc.vid-plat tt-fin-doc.fin-doc-code
          tt-fin-doc.perm-date tt-fin-doc.user-name-perm tt-fin-doc.pay-date
          tt-fin-doc.doc-date tt-fin-doc.user-name-doc tt-fin-doc.obj-type
          tt-fin-doc.obj-code tt-fin-doc.user-name-pl tt-fin-doc.sttm-code
          tt-fin-doc.fact-date tt-fin-doc.user-name-fact
          tt-fin-doc.cor-acc-value tt-fin-doc.an-uchet-value
          tt-fin-doc.contract-curr tt-fin-doc.cel-nazn-value
          tt-fin-doc.payer-inn tt-fin-doc.payer-kpp tt-fin-doc.payer-type
          tt-fin-doc.payer-code tt-fin-doc.payer-name tt-fin-doc.payer-bank-name
          tt-fin-doc.payer-bank-city tt-fin-doc.payer-r-schet
          tt-fin-doc.payer-bik tt-fin-doc.payer-c-schet tt-fin-doc.sum-doc
          tt-fin-doc.curr-code tt-fin-doc.exch-rate tt-fin-doc.exch-scale
          tt-fin-doc.sum-rubl tt-fin-doc.base-rate tt-fin-doc.base-scale
          tt-fin-doc.sum-base tt-fin-doc.contract-rate tt-fin-doc.contract-scale
          tt-fin-doc.sum-contr tt-fin-doc.receiver-inn tt-fin-doc.receiver-kpp
          tt-fin-doc.receiver-type tt-fin-doc.receiver-name
          tt-fin-doc.receiver-code tt-fin-doc.receiver-bank-name
          tt-fin-doc.receiver-bank-city tt-fin-doc.receiver-r-schet
          tt-fin-doc.receiver-bik tt-fin-doc.receiver-c-schet
          tt-fin-doc.naznach-plat tt-fin-doc.PS tt-fin-doc.payer-sign1
          tt-fin-doc.payer-sign2
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-other B-tax B-cards B-print B-hist B-Help RS-view
         tt-fin-doc.prn-doc-code tt-fin-doc.vid-plat tt-fin-doc.doc-date
         tt-fin-doc.user-name-doc tt-fin-doc.obj-type tt-fin-doc.obj-code B-obj
         tt-fin-doc.cor-acc-value B-cor-acc tt-fin-doc.an-uchet-value
         B-an-uchet f-contract-curr-abbr B-contract-view
         tt-fin-doc.contract-curr tt-fin-doc.cel-nazn-value B-cel-nazn
         tt-fin-doc.payer-type tt-fin-doc.payer-code B-payer
         tt-fin-doc.payer-name B-payer-schet tt-fin-doc.payer-bank-city
         B-payer-view tt-fin-doc.sum-doc f-rest-con-sum tt-fin-doc.curr-code
         B-currency B-calc tt-fin-doc.exch-rate tt-fin-doc.exch-scale
         tt-fin-doc.sum-rubl tt-fin-doc.sum-base tt-fin-doc.contract-rate
         tt-fin-doc.contract-scale tt-fin-doc.sum-contr
         tt-fin-doc.receiver-name B-receiver-schet
         tt-fin-doc.receiver-bank-name tt-fin-doc.receiver-bank-city
         B-receiver-view tt-fin-doc.receiver-c-schet tt-fin-doc.naznach-plat
         tt-fin-doc.PS tt-fin-doc.payer-sign1 tt-fin-doc.payer-sign2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-main-table Dialog-Frame
PROCEDURE fill-main-table :
{ gbl/curdbnum.i v-db-num }
{ gbl/basecode.i p-host-code v-base-code }
for each tt-fin-doc:
  delete tt-fin-doc.
end.
for each tt0-fin-doc-attr:
  delete tt0-fin-doc-attr.
end.
for each tt0-fin-doc-tax:
  delete tt0-fin-doc-tax.
end.
if p-mode = {&update}
or p-mode = {&lookup}
or p-mode = {&add-copy}
then do:
  if p-mode = {&update} then do:
    find first locked_fin-doc EXclusive-lock where
                  recid(locked_fin-doc) = p-doc-rec no-wait no-error.
    if locked locked_fin-doc then do:
      message
      substitute("Запись &1 занята", p-fin-doc-code)
      view-as alert-box error .
      undo, return error.
    end.
  end.
  else do:
    find first locked_fin-doc no-lock where
                recid(locked_fin-doc) = p-doc-rec no-error .
      if not available locked_fin-doc then do:
        find first locked_fin-doc no-lock where
                    locked_fin-doc.host-code = p-host-code
                AND locked_fin-doc.fin-doc-code = p-fin-doc-code no-error .
      end.
  end.
  if not available locked_fin-doc then do:
    message
    substitute("&1 &2 &3&4 Не найдена запись &5"
                ,vss-workfile
                ,vss-revision
                ,vss-description
                ,{&new-line}
                ,p-fin-doc-code)
    view-as alert-box error .
    undo, return error.
  end.
  if p-mode = {&update}
  AND not (locked_fin-doc.status_ = {&fin-new}
            or locked_fin-doc.status_ = {&fin-permitted} )
  then do:
    message
    substitute("Финансовый документ &1 находится в статусе &2&3Изменение невозможно"
              ,p-fin-doc-code
              ,locked_fin-doc.status_
              ,{&new-line})
    view-as alert-box error .
    undo, return error.
  end.
  create tt-fin-doc.
  if p-mode = {&add-copy} then do:
    buffer-copy locked_fin-doc
    using
    obj-type
    obj-code
    payer-type
    payer-code
    payer-name
    payer-inn
    payer-kpp
    receiver-code
    receiver-name
    payer-code-schet
    receiver-code-schet
    payer-bank-name
    payer-bank-city
    payer-BIK
    payer-c-schet
    payer-r-schet
    receiver-type
    receiver-code
    receiver-name
    receiver-bank-name
    receiver-bank-city
    receiver-BIK
    receiver-INN
    receiver-kpp
    receiver-c-schet
    receiver-r-schet
    an-uchet-code
    an-uchet-value
    cel-nazn-code
    cel-nazn-value
    contract-code
    contract-curr
    cor-acc-value
    cor-acc
    curr-code
    naznach-plat
    sum-doc
    stat-pl
    ocher-pl
    payer-sign1
    payer-sign2
    CashBookId
    to tt-fin-doc
    assign
    tt-fin-doc.host-code = p-host-code
    .
  end.
  else do:   /* не add-copy*/
    buffer-copy locked_fin-doc to tt-fin-doc.
  end.
end. /**/
if p-mode = {&add-def}
or p-mode = {&add-copy} then do:
  run ref/finfnoco.p (
                  INPUT parParentProc
                ,INPUT this-procedure:handle
                ,input p-curr-host-code
                ,input (p-mode + {&delim-par} + {&manual})
                ,input p-host-code
                ,input p-doc-rec
                ,input p-fin-doc-code
                ,input {&income-cashless} /*p-fin-doc-type*/
                ,input {&FDEDT_income_cashless} /*p-fin-ext-doc-type*/
                ,input p-obj-type
                ,input p-obj-code
                ,input p-contract-code
                ,input p-ob-doc-code
                ,input p-payer-type
                ,input p-payer-code
                ,input p-payer-code-schet
                ,input {&cmp} /*p-receiver-type*/
                ,input p-host-code /*p-receiver-code*/
                ,input p-receiver-code-schet
                ,input p-curr-code
                ,input p-cor-acc
                ,input p-cor-acc1
                ,input p-an-uchet-code
                ,input p-cel-nazn-code
                ,input (if available tt-fin-doc then tt-fin-doc.CashBookId else 0)
                ,input ""
                ,INPUT-OUTPUT table tt-fin-doc
                ,INPUT-OUTPUT table ttc-fin-doc
                ,output table tt0-fin-doc-attr
                ,output v-limit-access ) no-error .
end.
else do:
  run ref/finfnoco.p (
                  INPUT parParentProc
                ,INPUT this-procedure:handle
                ,input p-curr-host-code
                ,input p-mode  + {&delim-par} + {&manual}
                ,input p-host-code
                ,input p-doc-rec
                ,input tt-fin-doc.fin-doc-code
                ,input {&income-cashless} /*p-fin-doc-type*/
                ,input tt-fin-doc.fin-ext-doc-type
                ,input tt-fin-doc.obj-type
                ,input tt-fin-doc.obj-code
                ,input tt-fin-doc.contract-code
                ,input p-ob-doc-code
                ,input tt-fin-doc.payer-type
                ,input tt-fin-doc.payer-code
                ,input tt-fin-doc.payer-code-schet
                ,input {&cmp} /*p-receiver-type*/
                ,input p-host-code /*p-receiver-code*/
                ,input tt-fin-doc.receiver-code-schet
                ,input tt-fin-doc.curr-code
                ,input tt-fin-doc.cor-acc
                ,input tt-fin-doc.cor-acc1
                ,input tt-fin-doc.an-uchet-code
                ,input tt-fin-doc.cel-nazn-code
                ,input tt-fin-doc.CashBookId
                ,input ""
                ,INPUT-OUTPUT table ttc-fin-doc
                ,INPUT-OUTPUT table tt-fin-doc
                ,output table tt0-fin-doc-attr
                ,output v-limit-access ) no-error .
end.
if error-status:error then do:
  if not return-value = "exit" then do:
    message
    vss-workfile vss-revision vss-description skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box .
  end.
  undo, return error.
end.
find first tt-fin-doc.
run recalc in this-procedure ( input "curr-code":U).
if p-mode = {&add-copy} then do:
  assign
  v-copy-mode = yes
  p-mode = {&add-def}.
  if tt-fin-doc.curr-code = 0  then
  run recalc in this-procedure ( input "sum-doc").
end.
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
tt-fin-doc.payer-inn:label in frame {&frame-name} = "{&abbr_inn_allshift}".
tt-fin-doc.receiver-inn:label in frame {&frame-name} = "{&abbr_inn_allshift}".
tt-fin-doc.payer-kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}".
tt-fin-doc.receiver-kpp:label in frame {&frame-name} = "{&abbr_kpp_allshift}".
define variable v-inn like ub.firm.inn no-undo .
define variable v-kpp like ub.firm.kpp no-undo .
define variable g-log as logical no-undo.
assign
    tt-fin-doc.sum-rubl :label in frame {&frame-name} = "{&abbr_rubli_firstshift}"
.
run uf-get in this-procedure(
    input  ({&uf-findoci-p} + {&delim-par} + {&income-cashless})
    ,input  g#userid
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
tt-fin-doc.payer-type:radio-buttons = "Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                                         "Чел" + {&comma-char} + {&prs}
rs-view:radio-buttons = "&Полн." + {&comma-char} + "full":U +  {&comma-char} +
                                    "&Сокращ." + {&comma-char} + "brief":U + {&comma-char} +
                                    "&Дог-р" + {&comma-char} + "contract":U
tt-fin-doc.obj-type:radio-buttons = "Маг" + {&comma-char} + {&shop} + {&comma-char} +
                                    "Скл" + {&comma-char} + {&stock}

tt-fin-doc.vid-plat:list-items = {&fin-vp-codes}
rs-view = v-view
v-an-uchet-tab-order = (if X_sysconf.is-corr-acc then {&cor-acc-tab-order} else "":U) +
                       (if X_sysconf.is-an-uchet then {&an-uchet-tab-order} else "":U) +
                       (if X_sysconf.is-code-cel-nazn then {&cel-nazn-tab-order} else "":U)
v-an-uchet-tab-order =  {&cor-acc-tab-order} +
                        {&an-uchet-tab-order} +
                        {&cel-nazn-tab-order}
v-limit-access = (if p-mode = {&lookup} then 10 else v-limit-access)
tt-fin-doc.obj-type:screen-value  = (if tt-fin-doc.obj-type = {&shop}
                                    or tt-fin-doc.obj-type = {&stock}
                                    then tt-fin-doc.obj-type
                                    else tt-fin-doc.obj-type:screen-value)

.
if p-mode = {&lookup} and
tt-fin-doc.contract-code = 0 then do:
    assign
    g-log = rs-view:disable(radio-label("contract":U, RS-view:radio-buttons))
    .
    if rs-view = "contract":U then
    assign
    rs-view = "full":U
    v-not-uf-set = yes.
end.

find first X_currency no-lock where
              X_currency.curr-code = tt-fin-doc.curr-code.
assign
  f-curr-abbr = X_Currency.curr-abbr.
if p-mode = {&add-def} and tt-fin-doc.payer-type = "":U  then do:
  assign
  tt-fin-doc.payer-type = {&cmp}
  .
end.
IF tt-fin-doc.sttm-code <> 0 THEN DO:
  FIND FIRST X_fin-statement NO-LOCK WHERE
            X_fin-statement.host-code  = tt-fin-doc.host-code
        AND X_fin-statement.sttm-code  = tt-fin-doc.sttm-code NO-ERROR.
  IF NOT AVAILABLE X_fin-statement THEN DO:
    ASSIGN
    v-sttm-prn-doc-CODE = "@НЕИЗВЕСТНАЯ ВЫПИСКА".
  END.
  ELSE DO:
      ASSIGN
      v-sttm-prn-doc-CODE = X_fin-statement.prn-doc-code.
  END.
END.
if p-mode = {&lookup} then do:
    run proc-color-widgets in this-procedure({&not-in-form-list}, no, yes, ?, ?).
    run proc-color-widgets in this-procedure({&in-form-list}, no, yes, ?, ?).
end.
display
tt-fin-doc.exch-rate
tt-fin-doc.exch-scale
tt-fin-doc.sum-doc
(tt-fin-doc.sum-contr - tt-fin-doc.con-sum-contr ) @ f-rest-con-sum
tt-fin-doc.prn-doc-code
tt-fin-doc.payer-name
tt-fin-doc.naznach-plat
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign2
tt-fin-doc.PS
tt-fin-doc.payer-kpp
tt-fin-doc.receiver-kpp
with frame {&frame-name}.
.
if tt-fin-doc.contract-code <> 0 then do:
    find first X_contract-currency no-lock where
              X_contract-currency.curr-code = tt-fin-doc.contract-curr .
    assign
    f-contract-prn-code = X_contract.contract-prn-code
    f-contract-date     = X_contract.contract-date
    f-contract-type     = X_contract.contract-type
    f-contract-curr-abbr = X_contract-currency.curr-abbr
    .
end.
run change-view in this-procedure(rs-view).

VIEW FRAME {&FRAME-NAME}.
if p-mode <> {&lookup} then APPLY "ENTRY" to tt-fin-doc.prn-doc-code.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-save as logical no-undo .
if p-mode = {&lookup} or not available tt-fin-doc then do:
    return error.
end.
assign
tt-fin-doc.prn-doc-code frame {&frame-name}
tt-fin-doc.doc-date
tt-fin-doc.obj-code
tt-fin-doc.obj-type
tt-fin-doc.obj-type  = (if tt-fin-doc.obj-code = 0 then "":U else tt-fin-doc.obj-type)
tt-fin-doc.receiver-bik
tt-fin-doc.receiver-name
tt-fin-doc.receiver-kpp
tt-fin-doc.receiver-bank-name
tt-fin-doc.receiver-bank-city
tt-fin-doc.receiver-c-schet
tt-fin-doc.receiver-r-schet
tt-fin-doc.receiver-kpp
tt-fin-doc.payer-code
tt-fin-doc.payer-type
tt-fin-doc.payer-inn
tt-fin-doc.payer-kpp
tt-fin-doc.payer-bik
tt-fin-doc.payer-name
tt-fin-doc.payer-bank-name
tt-fin-doc.payer-bank-city
tt-fin-doc.payer-c-schet
tt-fin-doc.payer-r-schet
tt-fin-doc.vid-plat
tt-fin-doc.cor-acc  = (if available X_fin-code-cor-acc
                       then X_fin-code-cor-acc.fin-code
                       else 0)
tt-fin-doc.cor-acc-value  = (if available X_fin-code-cor-acc
                       then X_fin-code-cor-acc.code-value
                       else "":U)
tt-fin-doc.an-uchet-code  = (if available X_fin-code-an-uchet
                        then X_fin-code-an-uchet.fin-code
                        else 0)
tt-fin-doc.an-uchet-value  = (if available X_fin-code-an-uchet
                        then X_fin-code-an-uchet.code-value
                        else "":U)
tt-fin-doc.cel-nazn-code  = (if available X_fin-code-cel-nazn
                       then X_fin-code-cel-nazn.fin-code
                       else 0)
tt-fin-doc.cel-nazn-value  = (if available X_fin-code-cel-nazn
                       then X_fin-code-cel-nazn.code-value
                       else "":U)
tt-fin-doc.curr-code
tt-fin-doc.contract-curr
tt-fin-doc.contract-rate
tt-fin-doc.contract-scale
tt-fin-doc.sum-doc
tt-fin-doc.naznach-plat
tt-fin-doc.PS
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign2
.
if not p-save then return.
run check-sums-rate in this-procedure no-error.
if error-status:error then return error.

&scop prfx tt-fin-doc.


run ref/findoc0.p (
input-output p-doc-rec
       ,input p-mode
       ,input no /*p-silent*/
       {&all-fin-doc-params-doc-status-transfer}
       {&all-fin-doc-params-doc-status-transfer-2}
       ,input table tt0-fin-doc-tax
       ,input table tt0-fin-doc-attr
       ,input yes /*p-save-payment*/
       ,input table tt0-payment
) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
