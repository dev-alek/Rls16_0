&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_fin-doc FOR fin-doc.
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE payment.
DEFINE BUFFER X_clients-host FOR clients.
DEFINE BUFFER X_firm FOR firm.
DEFINE BUFFER X_sysconf FOR sysconf.
define buffer bf_fin-doc-attr for ub.fin-doc-attr .
define buffer buf_clients-attr for ub.clients-attr .

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision: d3f9048d4e8e, 3106, rls $
$Author: Ostroukhov $
$Date: Вт авг 09 09:15:01 2022 +0300 $
$Workfile: findoci2.w $
$Archive: ref/findoci2.w $

Карточка редактирования расходного ордера

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/10/03
Author: Bakhtadze Natalya
Creation date: 11/10/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

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
define input parameter p-receiver-type like ub.fin-doc.receiver-type no-undo .
define input parameter p-receiver-code like ub.fin-doc.receiver-code no-undo .
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-cor-acc like ub.fin-doc.cor-acc no-undo.
define input parameter p-cor-acc1 like ub.fin-doc.cor-acc1 no-undo.
define input parameter p-an-uchet-code like ub.fin-doc.an-uchet-code no-undo.
define input parameter p-cel-nazn-code like ub.fin-doc.cel-nazn-code no-undo.
define input parameter p-other as character no-undo .

define input-output parameter p-doc-rec as recid no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: d3f9048d4e8e, 3106, rls $":U .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: Вт авг 09 09:15:01 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findoci2.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/findoci2.w $":U .
define variable vss-description as character no-undo init "Карточка редактирования расходного ордера".
{ cmp/vssrevis.i }
/*{ cmp/library.i }*/
/*{ gbl/db-attr.i }*/
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
define variable mprn-doc-code-old as character no-undo. 
define variable current-pko-rko as character no-undo.
define variable current-ruleID  as character no-undo. 
define variable MParam as character no-undo.
define variable paramVne as character no-undo .

define buffer X_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer X_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer X_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer X_fin-code-cor-acc1 for ub.fin-code-cor-acc.
define buffer X_currency for ub.currency.
define buffer X_contract-currency for ub.currency.
DEFINE BUFFER X_receiver FOR ub.clients.
DEFINE BUFFER X_payer FOR ub.clients.
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_contract for ub.contract.
define buffer X_fin-ob for ub.fin-ob.
define buffer X_receiver-firm for ub.firm.
define buffer X_receiver-person for ub.person.
define buffer X_clients-obj for ub.clients.

define buffer X_receiver-fin-schet for ub.fin-schet.
define buffer X_receiver-fin-bank for ub.fin-bank.
define buffer X_payer-fin-schet for ub.fin-schet.
define buffer X_payer-fin-bank for ub.fin-bank.
define buffer X_payer-firm for ub.firm.
define buffer X_payer-person for ub.person.


DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.


define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-tab-order as character no-undo.
define variable v-head-position as character no-undo .
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
{ gbl/key-rec.i }
{ ref/getCliKassa.i }
{ ref/findocip.i &action="define" &doc-type="expense-cash" }
{ ref/fd-attr.i " " tt0-fin-doc-attr }
{ ref/clean_char.i}
function is-fact-and-edit returns logical ():
    return (p-mode = {&update} and locked_fin-doc.status_ = {&fin-fact}).
end.

&scop buttons-tab-order    "b-exit,b-quit,b-tax,b-print,b-hist,b-help,"

&scop cor-acc-tab-order "cor-acc-value,b-cor-acc,"
&scop an-uchet-tab-order "an-uchet-value,b-an-uchet,"
&scop cel-nazn-tab-order "cel-nazn-value,b-cel-nazn,"
&scop cassa-acc-tab-order "cor-acc1-value,b-cor-acc1,"

&scop brief-view-tab-order  ~{&buttons-tab-order~} + ~
                           "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view," + ~
                           v-sum-curr-tab-order + ~
                           "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat,receiver-passport,enclosure," +  ~
                          "PS,payer-sign1,payer-sign2,payer-sign3"
&scop full-view-tab-order   ~{&buttons-tab-order~} + ~
 "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view,str-podr-type,str-podr-code,str-podr-name," + ~
                            v-an-uchet-tab-order +  v-sum-curr-tab-order + ~
                            "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat,receiver-passport,enclosure," +  ~
                            "PS,payer-sign1,payer-sign2"

&scop contract-view-tab-order  ~{&buttons-tab-order~} + ~
                              "prn-doc-code,doc-date,obj-type,obj-code,b-obj,b-payer-view," + ~
                               v-contract-tab-order + v-sum-curr-tab-order +  ~
                               "receiver-type,receiver-code,b-receiver,receiver-name,naznach-plat,receiver-passport,enclosure," +  ~
                               "PS,payer-sign1,payer-sign2"

&scop not-in-form-list "f-an-uchet-descr,f-cel-nazn-descr,f-contract-curr-abbr,f-contract-date,f-contract-prn-code,f-contract-rate," +  ~
                       "f-contract-scale,f-contract-type,f-cor-acc1-descr,f-cor-acc-descr,base-rate,base-scale,curr-code,exch-rate,exch-scale," +  ~
                       "fact-date,fin-doc-code,receiver-code,receiver-type,perm-date,PS,payer-code,payer-type,sum-base,sum-rubl," +  ~
                       "user-name-doc,user-name-fact,user-name-perm"

&scop in-form-list    "F-curr-abbr,an-uchet-value,cel-nazn-value,cor-acc1-value,cor-acc-value,doc-date,enclosure," + ~
                      "naznach-plat,receiver-name,prn-doc-code,payer-name,payer-okpo,receiver-passport,payer-sign1,payer-sign2,payer-sign3" + ~
                      "str-podr-code,str-podr-name,str-podr-type,sum-doc"

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
&Scoped-Define ENABLED-FIELDS tt-fin-doc.shift-date tt-fin-doc.shift-name ~
tt-fin-doc.shift-num tt-fin-doc.prn-doc-code tt-fin-doc.doc-date ~
tt-fin-doc.user-name-doc tt-fin-doc.obj-type tt-fin-doc.obj-code ~
tt-fin-doc.payer-name tt-fin-doc.str-podr-type tt-fin-doc.str-podr-code ~
tt-fin-doc.str-podr-name tt-fin-doc.cor-acc-value tt-fin-doc.an-uchet-value ~
tt-fin-doc.contract-curr tt-fin-doc.cel-nazn-value ~
tt-fin-doc.cor-acc1-value tt-fin-doc.sum-doc tt-fin-doc.curr-code ~
tt-fin-doc.exch-rate tt-fin-doc.exch-scale tt-fin-doc.sum-rubl ~
tt-fin-doc.sum-base tt-fin-doc.contract-rate tt-fin-doc.contract-scale ~
tt-fin-doc.sum-contr tt-fin-doc.receiver-type tt-fin-doc.receiver-code ~
tt-fin-doc.receiver-name tt-fin-doc.naznach-plat ~
tt-fin-doc.receiver-passport tt-fin-doc.enclosure tt-fin-doc.PS ~
tt-fin-doc.payer-sign1 tt-fin-doc.payer-sign2 tt-fin-doc.payer-sign3 
&Scoped-define ENABLED-TABLES tt-fin-doc
&Scoped-define FIRST-ENABLED-TABLE tt-fin-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit r-sht B-tax B-print B-hist ~
B-Help RS-view f-cashbook B-cashbook B-pre-vedom B-obj B-payer-view ~
B-cor-acc B-an-uchet f-contract-curr-abbr B-contract-view B-cel-nazn ~
B-cor-acc1 f-rest-con-sum B-currency B-calc B-receiver B-receiver-view ~
l-cashbook 
&Scoped-Define DISPLAYED-FIELDS tt-fin-doc.shift-date tt-fin-doc.shift-name ~
tt-fin-doc.shift-num tt-fin-doc.prn-doc-code tt-fin-doc.fin-doc-code ~
tt-fin-doc.perm-date tt-fin-doc.user-name-perm tt-fin-doc.doc-date ~
tt-fin-doc.user-name-doc tt-fin-doc.obj-type tt-fin-doc.obj-code ~
tt-fin-doc.fact-date tt-fin-doc.user-name-fact tt-fin-doc.payer-type ~
tt-fin-doc.payer-code tt-fin-doc.payer-okpo tt-fin-doc.payer-name ~
tt-fin-doc.str-podr-type tt-fin-doc.str-podr-code tt-fin-doc.str-podr-name ~
tt-fin-doc.cor-acc-value tt-fin-doc.an-uchet-value tt-fin-doc.contract-curr ~
tt-fin-doc.cel-nazn-value tt-fin-doc.cor-acc1-value tt-fin-doc.sum-doc ~
tt-fin-doc.curr-code tt-fin-doc.exch-rate tt-fin-doc.exch-scale ~
tt-fin-doc.sum-rubl tt-fin-doc.base-rate tt-fin-doc.base-scale ~
tt-fin-doc.sum-base tt-fin-doc.contract-rate tt-fin-doc.contract-scale ~
tt-fin-doc.sum-contr tt-fin-doc.receiver-type tt-fin-doc.receiver-code ~
tt-fin-doc.receiver-name tt-fin-doc.naznach-plat ~
tt-fin-doc.receiver-passport tt-fin-doc.enclosure tt-fin-doc.PS ~
tt-fin-doc.payer-sign1 tt-fin-doc.payer-sign2 tt-fin-doc.payer-sign3 
&Scoped-define DISPLAYED-TABLES tt-fin-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-fin-doc
&Scoped-Define DISPLAYED-OBJECTS RS-view f-cashbook f-cor-acc-descr ~
f-an-uchet-descr f-contract-curr-abbr f-contract-prn-code f-contract-date ~
f-contract-type f-cel-nazn-descr f-cor-acc1-descr f-rest-con-sum ~
F-curr-abbr l-cashbook F-debet F-credit 

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

DEFINE BUTTON B-cashbook 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY 1
     FGCOLOR 4 .

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

DEFINE BUTTON B-cor-acc1 
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

DEFINE BUTTON B-payer-view 
     LABEL "П&лательщик" 
     SIZE 12 BY 1
     FGCOLOR 4 .

DEFINE BUTTON B-pre-vedom 
     LABEL "&Препровод. ведомость" 
     SIZE 25 BY 1.

DEFINE BUTTON B-print 
     LABEL "Пе&чать" 
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-receiver 
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
     SIZE 8 BY 1.

DEFINE BUTTON r-sht 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1" 
     SIZE 2 BY 1.08.

DEFINE VARIABLE f-an-uchet-descr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-cashbook AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 40 BY 1 NO-UNDO.

DEFINE VARIABLE f-cel-nazn-descr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE f-contract-curr-abbr AS CHARACTER FORMAT "X(3)":U INITIAL "0" 
     VIEW-AS FILL-IN 
     SIZE 6.25 BY 1 NO-UNDO.

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

DEFINE VARIABLE f-cor-acc1-descr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE F-credit AS CHARACTER FORMAT "X(256)":U INITIAL "Кредит" 
      VIEW-AS TEXT 
     SIZE 7.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-curr-abbr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-debet AS CHARACTER FORMAT "X(256)":U INITIAL "Дебет" 
      VIEW-AS TEXT 
     SIZE 6.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-rest-con-sum AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0 
     LABEL "Своб.ост.(в.д.)" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1
     FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE l-cashbook AS CHARACTER FORMAT "X(256)":U INITIAL "Кассовая книга:" 
      VIEW-AS TEXT 
     SIZE 15 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-view AS CHARACTER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 21.5 BY .83
     FONT 4 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR 
      locked_fin-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-fin-doc.shift-date AT ROW 1 COL 45 COLON-ALIGNED WIDGET-ID 4
          LABEL "См"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     tt-fin-doc.shift-name AT ROW 1 COL 60 COLON-ALIGNED WIDGET-ID 6
          LABEL "№"
          VIEW-AS FILL-IN 
          SIZE 3 BY 1
     tt-fin-doc.shift-num AT ROW 1 COL 67 COLON-ALIGNED WIDGET-ID 8
          LABEL "П"
          VIEW-AS FILL-IN 
          SIZE 3 BY 1
     r-sht AT ROW 1 COL 72 WIDGET-ID 10
     B-tax AT ROW 1 COL 74
     B-print AT ROW 1 COL 90
     B-hist AT ROW 1 COL 93
     B-Help AT ROW 1 COL 96
     RS-view AT ROW 1.08 COL 21 NO-LABEL
     f-cashbook AT ROW 2 COL 15 COLON-ALIGNED NO-LABEL
     B-cashbook AT ROW 2 COL 59
     B-pre-vedom AT ROW 2 COL 74 WIDGET-ID 20
     tt-fin-doc.prn-doc-code AT ROW 3 COL 16.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 16 BY 1
          FGCOLOR 4 
     tt-fin-doc.fin-doc-code AT ROW 3 COL 46 COLON-ALIGNED
          LABEL "Внутр. №"
          VIEW-AS FILL-IN 
          SIZE 10.38 BY 1
     B-obj AT ROW 3 COL 59
     tt-fin-doc.perm-date AT ROW 3 COL 71.5 COLON-ALIGNED
          LABEL "Дата разр"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     tt-fin-doc.user-name-perm AT ROW 3 COL 82.75 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN 
          SIZE 14.5 BY 1
     tt-fin-doc.doc-date AT ROW 4 COL 11 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
          FGCOLOR 4 
     tt-fin-doc.user-name-doc AT ROW 4 COL 22.38 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN 
          SIZE 14.5 BY 1
     tt-fin-doc.obj-type AT ROW 4 COL 39.38 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Item 1", "1":U
          SIZE 12.63 BY 1
     tt-fin-doc.obj-code AT ROW 4 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 6.5 BY 1
     tt-fin-doc.fact-date AT ROW 4 COL 71.5 COLON-ALIGNED
          LABEL "Дата факт"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     tt-fin-doc.user-name-fact AT ROW 4 COL 82.75 COLON-ALIGNED NO-LABEL FORMAT "X(14)"
          VIEW-AS FILL-IN 
          SIZE 14.5 BY 1
     tt-fin-doc.payer-type AT ROW 5 COL 1.75 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     tt-fin-doc.payer-code AT ROW 5 COL 4.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 6 BY 1
     tt-fin-doc.payer-okpo AT ROW 5 COL 17.25 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
          FGCOLOR 4 
     tt-fin-doc.payer-name AT ROW 5 COL 28.25 COLON-ALIGNED NO-LABEL FORMAT "X(130)"
          VIEW-AS FILL-IN 
          SIZE 50 BY 1
          FGCOLOR 4 
     B-payer-view AT ROW 5 COL 87
     tt-fin-doc.str-podr-type AT ROW 6 COL 1.25
          LABEL "Структ.подразд."
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
          FGCOLOR 4 
     tt-fin-doc.str-podr-code AT ROW 6 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
          FGCOLOR 4 
     tt-fin-doc.str-podr-name AT ROW 6 COL 53.88 COLON-ALIGNED
          VIEW-AS FILL-IN 
          SIZE 43 BY 1
          FGCOLOR 4 
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-fin-doc.cor-acc-value AT ROW 7 COL 16.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 14 BY 1
          FGCOLOR 4 
     B-cor-acc AT ROW 7 COL 33.13
     f-cor-acc-descr AT ROW 7 COL 35.75 COLON-ALIGNED NO-LABEL
     tt-fin-doc.an-uchet-value AT ROW 8 COL 5.25
          LABEL "Код ан. уч."
          VIEW-AS FILL-IN 
          SIZE 14 BY 1
          FGCOLOR 4 
     B-an-uchet AT ROW 8 COL 33.13
     f-an-uchet-descr AT ROW 8 COL 35.75 COLON-ALIGNED NO-LABEL
     f-contract-curr-abbr AT ROW 8.46 COL 53.25 COLON-ALIGNED NO-LABEL
     B-contract-view AT ROW 8.5 COL 1
     f-contract-prn-code AT ROW 8.5 COL 12 COLON-ALIGNED NO-LABEL
     f-contract-date AT ROW 8.5 COL 36.63 COLON-ALIGNED
     tt-fin-doc.contract-curr AT ROW 8.5 COL 49.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     f-contract-type AT ROW 8.5 COL 72 COLON-ALIGNED
     tt-fin-doc.cel-nazn-value AT ROW 9 COL 16.25 COLON-ALIGNED
          LABEL "Код цел.назн."
          VIEW-AS FILL-IN 
          SIZE 14 BY 1
          FGCOLOR 4 
     B-cel-nazn AT ROW 9 COL 33.13
     f-cel-nazn-descr AT ROW 9 COL 35.75 COLON-ALIGNED NO-LABEL
     tt-fin-doc.cor-acc1-value AT ROW 10 COL 16.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 14 BY 1
          FGCOLOR 4 
     B-cor-acc1 AT ROW 10 COL 33.13
     f-cor-acc1-descr AT ROW 10 COL 35.75 COLON-ALIGNED NO-LABEL
     tt-fin-doc.sum-doc AT ROW 11 COL 6 COLON-ALIGNED NO-LABEL FORMAT ">,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN 
          SIZE 24.38 BY 1
          FGCOLOR 4 
     f-rest-con-sum AT ROW 11 COL 72.25 COLON-ALIGNED
     tt-fin-doc.curr-code AT ROW 11.04 COL 41.88 COLON-ALIGNED
          LABEL "Вал"
          VIEW-AS FILL-IN 
          SIZE 4 BY 1
     B-currency AT ROW 11.04 COL 48.88
     F-curr-abbr AT ROW 11.04 COL 50.88 COLON-ALIGNED NO-LABEL
     B-calc AT ROW 12 COL 1.5
     tt-fin-doc.exch-rate AT ROW 12 COL 34.5 COLON-ALIGNED
          LABEL "Курс пл-жа"
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-fin-doc.exch-scale AT ROW 12 COL 44.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 5.63 BY 1
     tt-fin-doc.sum-rubl AT ROW 12 COL 72.25 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
          VIEW-AS FILL-IN 
          SIZE 25 BY 1
     tt-fin-doc.base-rate AT ROW 13 COL 34.5 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-fin-doc.base-scale AT ROW 13 COL 44.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 5.63 BY 1
     tt-fin-doc.sum-base AT ROW 13 COL 72.13 COLON-ALIGNED
          LABEL "Б.в."
          VIEW-AS FILL-IN 
          SIZE 25 BY 1
     tt-fin-doc.contract-rate AT ROW 14 COL 34.5 COLON-ALIGNED
          LABEL "Курс дог."
          VIEW-AS FILL-IN 
          SIZE 10 BY 1
     tt-fin-doc.contract-scale AT ROW 14 COL 44.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 5.63 BY 1
     tt-fin-doc.sum-contr AT ROW 14 COL 72.25 COLON-ALIGNED
          LABEL "в.дог-ра"
          VIEW-AS FILL-IN 
          SIZE 25 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     B-receiver AT ROW 14.96 COL 27.38
     tt-fin-doc.receiver-type AT ROW 15 COL 1 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS 
                    "Item 1", "1":U,
"Item 1", "2":U
          SIZE 13.5 BY 1
     tt-fin-doc.receiver-code AT ROW 15 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 11 BY 1
     tt-fin-doc.receiver-name AT ROW 15 COL 30.25 COLON-ALIGNED NO-LABEL FORMAT "X(130)"
          VIEW-AS FILL-IN 
          SIZE 53 BY 1
          FGCOLOR 4 
     B-receiver-view AT ROW 15 COL 87
     tt-fin-doc.naznach-plat AT ROW 17 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5 TOOLTIP "Основание платежа"
          FGCOLOR 4 
     tt-fin-doc.receiver-passport AT ROW 17 COL 50.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5
          FGCOLOR 4 
     tt-fin-doc.enclosure AT ROW 19.5 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5
          FGCOLOR 4 
     tt-fin-doc.PS AT ROW 19.5 COL 50.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 1.5 TOOLTIP "Дополнительная информация, не печатающаяся в ордере"
     tt-fin-doc.payer-sign1 AT ROW 21 COL 54
          LABEL "Рук. орг-ции" FORMAT "X(37)"
          VIEW-AS FILL-IN 
          SIZE 30.88 BY 1
          FGCOLOR 4 
     tt-fin-doc.payer-sign2 AT ROW 22 COL 6
          LABEL "Гл. бух."
          VIEW-AS FILL-IN 
          SIZE 33 BY 1
          FGCOLOR 4 
     tt-fin-doc.payer-sign3 AT ROW 22 COL 60
          LABEL "Кассир"
          VIEW-AS FILL-IN 
          SIZE 30.88 BY 1
          FGCOLOR 4 
     l-cashbook AT ROW 2.21 COL 1.38 NO-LABEL
     F-debet AT ROW 7.13 COL 1.88 NO-LABEL
     F-credit AT ROW 10.29 COL 8.88 NO-LABEL
     "Сумма:" VIEW-AS TEXT
          SIZE 6.5 BY .67 AT ROW 11.13 COL 1.25 WIDGET-ID 14
          FGCOLOR 4 
     "Корсчет:" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 7.17 COL 9 WIDGET-ID 12
          FGCOLOR 4 
     "Документ, удостоверяющий личность" VIEW-AS TEXT
          SIZE 43.5 BY 1 AT ROW 16 COL 50.5
          FGCOLOR 0 
     "Основание платежа" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 16 COL 1.25
          FGCOLOR 4 
     "(Примечание (доп.информация, не печатается))" VIEW-AS TEXT
          SIZE 47.13 BY 1 AT ROW 18.5 COL 51
     "Приложение" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 18.5 COL 1
          FGCOLOR 0 
     "Дата сост.:" VIEW-AS TEXT
          SIZE 11 BY .67 AT ROW 4.13 COL 1.38 WIDGET-ID 18
          FGCOLOR 4 
     "Номер документа:" VIEW-AS TEXT
          SIZE 16.5 BY .67 AT ROW 3.17 COL 1.38 WIDGET-ID 16
          FGCOLOR 4 
     SPACE(81.42) SKIP(19.20)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Расходный кассовый ордер - Плательщик"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_fin-doc B "?" ? ub fin-doc
      TABLE: tt-fin-doc T "?" NO-UNDO ub fin-doc
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
   ALIGN-L EXP-LABEL                                                    */
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
/* SETTINGS FOR FILL-IN tt-fin-doc.cor-acc1-value IN FRAME Dialog-Frame
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
ASSIGN 
       f-cashbook:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

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
/* SETTINGS FOR FILL-IN f-cor-acc1-descr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-credit IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN F-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-debet IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN tt-fin-doc.fact-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.fin-doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN l-cashbook IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-fin-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-okpo IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-sign1 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT                                         */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-sign2 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-sign3 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-fin-doc.payer-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-fin-doc.perm-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-fin-doc.prn-doc-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.receiver-name IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-fin-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.str-podr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-fin-doc.str-podr-type IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Расходный кассовый ордер - Плательщик */
DO:
    /*Запуск интерфейса препроводительной ведомости*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pre-vedom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pre-vedom Dialog-Frame
ON CHOOSE OF B-pre-vedom IN FRAME Dialog-Frame /* Препровод. ведомость */
DO:
  define buffer bf_fin-doc-attr for ub.fin-doc-attr . 
  find first tt-fin-doc no-error .
  if available (tt-fin-doc) then do:
  run ref/cover_sheet.p (input parParentProc, input p-host-code, input tt-fin-doc.fin-doc-code, input tt-fin-doc.CashBookId, input tt-fin-doc.sum-doc, input p-mode) no-error .
/*      find first bf_fin-doc-attr exclusive-lock where bf_fin-doc-attr.attr-code = "pre-vedom" and bf_fin-doc-attr.host-code = tt-fin-doc.host-code*/
/*      and bf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code no-error .                                                                       */
/*    if available (bf_fin-doc-attr) then                                                                                                           */
/*        tt-fin-doc.enclosure     = tt-fin-doc.enclosure + " " + entry(1,bf_fin-doc-attr.attr-value,";") .                                         */
    display tt-fin-doc.enclosure with frame {&frame-name} .       
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME





&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable v-format as integer no-undo .
define variable v-cmp as character no-undo .
define variable v-log as logical no-undo .
buffer-compare tt-fin-doc except payer-sign1
to locked_fin-doc
case-sensitive
save result in v-cmp .
if v-cmp <> "":U
or  entry((if num-entries(locked_fin-doc.payer-sign1, {&delim-par}) > 1
           then 2
           else 1)
           , locked_fin-doc.payer-sign1, {&delim-par}
         ) <> tt-fin-doc.payer-sign1
then do:
  message
  "Вы изменили ПЛАТЕЖ, но не сохранили его" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log ) no-error.
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
{ ref/findocip.i &action="define2" &doc-type="income-cash"}
{ ref/findocip.i
&action="triggers"
&doc-type="expense-cash"
&my-side=payer
&cli-side=receiver
&my-title="'ПЛАТЕЛЬЩИКА'"
&cli-side-title="'ПОЛУЧАТЕЛЯ'"
&cli-side-title0="'ПОЛУЧАТЕЛЬ'"
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
    input  ({&uf-findoci-p} + {&delim-par} + {&expense-cash})
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
define variable v-can-back-shift as logical no-undo .
if not (tt-fin-doc.obj-type = ''
and tt-fin-doc.obj-code = 0) then do:
  { gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-doc_create-back-shift':U
  {&cntxt-object}
  tt-fin-doc.host-code
  tt-fin-doc.obj-type
  tt-fin-doc.obj-code
  0
  0
  0
  false
  v-can-back-shift
  }
end.
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
tt-fin-doc.receiver-passport
tt-fin-doc.receiver-name
tt-fin-doc.naznach-plat
tt-fin-doc.enclosure
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign2
tt-fin-doc.payer-sign3
tt-fin-doc.PS
.
if p-view = "full" then do:
  assign
  tt-fin-doc.str-podr-code
  tt-fin-doc.str-podr-type
  tt-fin-doc.str-podr-name
  .
end.

/*сначала похайдим все что не видно сразу вов сех VIEW потом понемноэку будем открывать*/
hide
f-debet
f-credit
tt-fin-doc.cor-acc1-value
f-cor-acc1-descr
tt-fin-doc.cor-acc-value
f-cor-acc-descr
tt-fin-doc.an-uchet-value
f-an-uchet-descr
tt-fin-doc.cel-nazn-value
f-cel-nazn-descr
B-cor-acc1
B-cor-acc
B-an-uchet
tt-fin-doc.cel-nazn-value
B-cel-nazn

tt-fin-doc.perm-date
tt-fin-doc.user-name-perm

tt-fin-doc.fact-date
tt-fin-doc.user-name-fact

b-exit
B-receiver

b-contract-view
f-contract-date
f-contract-prn-code
f-contract-type
f-contract-curr-abbr
tt-fin-doc.contract-curr

b-payer-view
tt-fin-doc.payer-type
tt-fin-doc.payer-code
tt-fin-doc.payer-okpo
tt-fin-doc.payer-name
tt-fin-doc.str-podr-type
tt-fin-doc.str-podr-code
tt-fin-doc.str-podr-name

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
  tt-fin-doc.sum-rubl
  tt-fin-doc.curr-code
  tt-fin-doc.obj-type
  tt-fin-doc.obj-code
  tt-fin-doc.sum-doc
  tt-fin-doc.receiver-code
  tt-fin-doc.receiver-type
  tt-fin-doc.receiver-name
  tt-fin-doc.receiver-passport
  tt-fin-doc.naznach-plat
  tt-fin-doc.enclosure
  tt-fin-doc.PS
  tt-fin-doc.payer-sign1
  tt-fin-doc.payer-sign2
  tt-fin-doc.payer-sign3
  with frame {&frame-name}
  .
  if tt-fin-doc.perm-date <> ? then
  display
  tt-fin-doc.perm-date
  usrfulnf(tt-fin-doc.user-name-perm) @ tt-fin-doc.user-name-perm
  with frame {&frame-name}
   .
  if tt-fin-doc.fact-date <> ? then
  display
  tt-fin-doc.fact-date
  usrfulnf(tt-fin-doc.user-name-fact) @ tt-fin-doc.user-name-fact
  with frame {&frame-name}
  .
ENABLE
b-quit
B-tax
B-pre-vedom
B-print when p-mode <> {&add-def}
B-hist when p-mode <> {&add-def}
B-Help
RS-view
b-receiver-view
b-payer-view
WITH FRAME Dialog-Frame.
if p-mode <> {&lookup} and not is-fact-and-edit() then do:
  ENABLE
  B-exit
  B-cashbook
  f-cashbook
  tt-fin-doc.prn-doc-code
  tt-fin-doc.doc-date when v-limit-access = 0
  b-obj   when not v-is-auto-obj
               and lookup("lock-obj", p-other) = 0
               and (tt-fin-doc.shift-flag <> integer({&fin-flag-shift})
                  or
                  tt-fin-doc.status_ = {&fin-new})
  tt-fin-doc.obj-type   when not v-is-auto-obj
                             and lookup("lock-obj", p-other) = 0
                             and (tt-fin-doc.shift-flag <> integer({&fin-flag-shift})
                                  or
                                  tt-fin-doc.status_ = {&fin-new})
  tt-fin-doc.obj-code   when not v-is-auto-obj
                             and lookup("lock-obj", p-other) = 0
                             and (tt-fin-doc.shift-flag <> integer({&fin-flag-shift})
                                  or
                                  tt-fin-doc.status_ = {&fin-new})
  r-sht when (tt-fin-doc.shift-flag = integer({&fin-flag-shift}) and v-limit-access = 0  and v-can-back-shift)
  b-calc  when v-limit-access = 0
  tt-fin-doc.PS
  WITH FRAME Dialog-Frame.
  if v-limit-access = 0  then do:
    ENABLE
    tt-fin-doc.curr-code
    B-currency
    tt-fin-doc.sum-doc
    tt-fin-doc.receiver-code when tt-fin-doc.contract-code = 0
    B-receiver               when tt-fin-doc.contract-code = 0
    tt-fin-doc.receiver-type when tt-fin-doc.contract-code = 0
    tt-fin-doc.receiver-name when tt-fin-doc.contract-code = 0
    tt-fin-doc.naznach-plat
    tt-fin-doc.enclosure
    tt-fin-doc.payer-sign1
    tt-fin-doc.payer-sign2
    tt-fin-doc.payer-sign3
    tt-fin-doc.receiver-passport
    WITH FRAME Dialog-Frame.
    end.
end.
else if is-fact-and-edit() then
    do:
        enable
            b-exit
            tt-fin-doc.prn-doc-code
        with frame Dialog-Frame.            
    end.
else do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
run hide-view-currency in this-procedure.

if is-fact-and-edit() then
    disable
        tt-fin-doc.sum-doc
        with frame Dialog-Frame.
        
CASE p-view:
  when "full":U then do:
    assign
    v-tab-order = {&full-view-tab-order}
    .
    IF AVAILABLE tt-fin-doc THEN
    display
    tt-fin-doc.payer-type
    tt-fin-doc.payer-code
    tt-fin-doc.payer-okpo
    tt-fin-doc.payer-name
    tt-fin-doc.str-podr-type
    tt-fin-doc.str-podr-code
    tt-fin-doc.str-podr-name
    with frame {&frame-name}
    .
    display
    f-debet
    f-credit
    tt-fin-doc.cor-acc1-value
    f-cor-acc1-descr
    tt-fin-doc.cor-acc-value
    f-cor-acc-descr
    tt-fin-doc.an-uchet-value
    f-an-uchet-descr
    tt-fin-doc.cel-nazn-value
    f-cel-nazn-descr
    l-cashbook
    f-cashbook
    with frame {&frame-name}
    .
    if not is-fact-and-edit() then
        do:
            if v-limit-access = 0 then do:
              ENABLE
              tt-fin-doc.str-podr-type
              tt-fin-doc.str-podr-code
              tt-fin-doc.str-podr-name
              WITH FRAME Dialog-Frame.
            end.
            if v-limit-access < 2  then do:
              /*поле открыто всегда по указанию Суслова*/
              ENABLE
              B-cor-acc1                     /*      when X_sysconf.is-cassa-acc        */
              tt-fin-doc.cor-acc1-value      /*      when X_sysconf.is-cassa-acc        */
              tt-fin-doc.cor-acc-value       /*      when X_sysconf.is-corr-acc         */
              B-cor-acc                      /*      when X_sysconf.is-corr-acc         */
              tt-fin-doc.an-uchet-value      /*      when X_sysconf.is-an-uchet         */
              B-an-uchet                     /*      when X_sysconf.is-an-uchet         */
              tt-fin-doc.cel-nazn-value      /*      when X_sysconf.is-code-cel-nazn    */
              B-cel-nazn                     /*      when X_sysconf.is-code-cel-nazn    */
              WITH FRAME Dialog-Frame.
            end.
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
  DISPLAY RS-view f-cashbook f-cor-acc-descr f-an-uchet-descr 
          f-contract-curr-abbr f-contract-prn-code f-contract-date 
          f-contract-type f-cel-nazn-descr f-cor-acc1-descr f-rest-con-sum 
          F-curr-abbr l-cashbook F-debet F-credit 
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-doc THEN 
    DISPLAY tt-fin-doc.shift-date tt-fin-doc.shift-name tt-fin-doc.shift-num 
          tt-fin-doc.prn-doc-code tt-fin-doc.fin-doc-code tt-fin-doc.perm-date 
          tt-fin-doc.user-name-perm tt-fin-doc.doc-date tt-fin-doc.user-name-doc 
          tt-fin-doc.obj-type tt-fin-doc.obj-code tt-fin-doc.fact-date 
          tt-fin-doc.user-name-fact tt-fin-doc.payer-type tt-fin-doc.payer-code 
          tt-fin-doc.payer-okpo tt-fin-doc.payer-name tt-fin-doc.str-podr-type 
          tt-fin-doc.str-podr-code tt-fin-doc.str-podr-name 
          tt-fin-doc.cor-acc-value tt-fin-doc.an-uchet-value 
          tt-fin-doc.contract-curr tt-fin-doc.cel-nazn-value 
          tt-fin-doc.cor-acc1-value tt-fin-doc.sum-doc tt-fin-doc.curr-code 
          tt-fin-doc.exch-rate tt-fin-doc.exch-scale tt-fin-doc.sum-rubl 
          tt-fin-doc.base-rate tt-fin-doc.base-scale tt-fin-doc.sum-base 
          tt-fin-doc.contract-rate tt-fin-doc.contract-scale 
          tt-fin-doc.sum-contr tt-fin-doc.receiver-type tt-fin-doc.receiver-code 
          tt-fin-doc.receiver-name tt-fin-doc.naznach-plat 
          tt-fin-doc.receiver-passport tt-fin-doc.enclosure tt-fin-doc.PS 
          tt-fin-doc.payer-sign1 tt-fin-doc.payer-sign2 tt-fin-doc.payer-sign3 
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-fin-doc.shift-date tt-fin-doc.shift-name 
         tt-fin-doc.shift-num r-sht B-tax B-print B-hist B-Help RS-view 
         f-cashbook B-cashbook B-pre-vedom tt-fin-doc.prn-doc-code B-obj 
         tt-fin-doc.doc-date tt-fin-doc.user-name-doc tt-fin-doc.obj-type 
         tt-fin-doc.obj-code tt-fin-doc.payer-name B-payer-view 
         tt-fin-doc.str-podr-type tt-fin-doc.str-podr-code 
         tt-fin-doc.str-podr-name tt-fin-doc.cor-acc-value B-cor-acc 
         tt-fin-doc.an-uchet-value B-an-uchet f-contract-curr-abbr 
         B-contract-view tt-fin-doc.contract-curr tt-fin-doc.cel-nazn-value 
         B-cel-nazn tt-fin-doc.cor-acc1-value B-cor-acc1 tt-fin-doc.sum-doc 
         f-rest-con-sum tt-fin-doc.curr-code B-currency B-calc 
         tt-fin-doc.exch-rate tt-fin-doc.exch-scale tt-fin-doc.sum-rubl 
         tt-fin-doc.sum-base tt-fin-doc.contract-rate tt-fin-doc.contract-scale 
         tt-fin-doc.sum-contr B-receiver tt-fin-doc.receiver-type 
         tt-fin-doc.receiver-code tt-fin-doc.receiver-name B-receiver-view 
         tt-fin-doc.naznach-plat tt-fin-doc.receiver-passport 
         tt-fin-doc.enclosure tt-fin-doc.PS tt-fin-doc.payer-sign1 
         tt-fin-doc.payer-sign2 tt-fin-doc.payer-sign3 l-cashbook
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

  create tt-fin-doc.
  if p-mode = {&add-copy} then do:
    buffer-copy locked_fin-doc
    using
    payer-type
    payer-code
    payer-name
    payer-okpo
    receiver-type
    receiver-code
    receiver-name
    an-uchet-code
    an-uchet-value
    cel-nazn-code
    cel-nazn-value
    contract-code
    contract-curr
    cor-acc-value
    cor-acc1-value
    cor-acc1
    cor-acc
    curr-code
    enclosure
    obj-type
    obj-code
    receiver-passport
    naznach-plat
    str-podr-code
    str-podr-name
    str-podr-type
    sum-doc
    payer-sign1
    payer-sign2
    payer-sign3
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
                ,input (p-mode  + {&delim-par} + {&manual})
                ,input p-host-code
                ,input p-doc-rec
                ,input p-fin-doc-code
                ,input {&expense-cash} /*p-fin-doc-type*/
                ,input {&FDEDT_expense_cash} /*p-fin-ext-doc-type*/
                ,input p-obj-type
                ,input p-obj-code
                ,input p-contract-code
                ,input p-ob-doc-code
                ,input {&cmp} /*p-payer-type*/
                ,input p-host-code /*p-payer-code*/
                ,input 0 /*p-payer-code-schet*/
                ,input p-receiver-type
                ,input p-receiver-code
                ,input 0 /*p-receiver-code-schet*/
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
                ,input p-mode
                ,input p-host-code
                ,input p-doc-rec
                ,input tt-fin-doc.fin-doc-code
                ,input {&expense-cash} /*p-fin-doc-type*/
                ,input tt-fin-doc.fin-ext-doc-type
                ,input tt-fin-doc.obj-type
                ,input tt-fin-doc.obj-code
                ,input tt-fin-doc.contract-code
                ,input p-ob-doc-code
                ,input {&cmp} /*p-payer-type*/
                ,input p-host-code /*p-payer-code*/
                ,input 0 /*p-payer-code-schet*/
                ,input {&cmp} /*p-receiver-type*/
                ,input tt-fin-doc.receiver-code
                ,input 0 /*p-receiver-code-schet*/
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
define variable g-log as logical no-undo.
define variable v-inn like ub.firm.inn no-undo .
define variable v-kpp like ub.firm.kpp no-undo .
assign
    tt-fin-doc.sum-rubl :label in frame {&frame-name} = "{&abbr_rubli_firstshift}"
.
run uf-get in this-procedure(
    input  ({&uf-findoci-p} + {&delim-par} + {&expense-cash})
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
tt-fin-doc.receiver-type:radio-buttons = "Орг" + {&comma-char} + {&cmp} + {&comma-char} +
                                         "Чел" + {&comma-char} + {&prs}
rs-view:radio-buttons = "&Полн." + {&comma-char} + "full":U +  {&comma-char} +
                                    "&Сокращ." + {&comma-char} + "brief":U + {&comma-char} +
                                    "&Дог-р" + {&comma-char} + "contract":U
tt-fin-doc.obj-type:radio-buttons = "Маг" + {&comma-char} + {&shop} + {&comma-char} +
                                    "Скл" + {&comma-char} + {&stock}

rs-view = v-view
v-an-uchet-tab-order = (if X_sysconf.is-corr-acc then {&cor-acc-tab-order} else "":U) +
                       (if X_sysconf.is-an-uchet then {&an-uchet-tab-order} else "":U) +
                       (if X_sysconf.is-code-cel-nazn then {&cel-nazn-tab-order} else "":U) +
                       (if X_sysconf.is-cassa-acc then {&cassa-acc-tab-order} else "":U)
v-an-uchet-tab-order = {&cor-acc-tab-order}  +
                       {&an-uchet-tab-order} +
                       {&cel-nazn-tab-order} +
                       {&cassa-acc-tab-order}
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
assign
v-head-position = (if num-entries(tt-fin-doc.payer-sign1, {&delim-par}) > 1
                    then entry(1, tt-fin-doc.payer-sign1, {&delim-par})
                    else "":U)
.
if p-mode = {&add-def} and tt-fin-doc.contract-code = 0 then do:
 
  assign
  tt-fin-doc.receiver-type = (if tt-fin-doc.receiver-type = "":U then {&cmp} else tt-fin-doc.receiver-type)
  tt-fin-doc.payer-sign1:label  = tt-fin-doc.payer-sign1:label  +
                                  (if v-head-position <> ''
                                   then " - ":U + v-head-position
                                   else '')
  tt-fin-doc.payer-sign1 =   (if num-entries(tt-fin-doc.payer-sign1, {&delim-par}) > 1
                                    then entry(2, tt-fin-doc.payer-sign1, {&delim-par})
                                    else entry(1, tt-fin-doc.payer-sign1, {&delim-par}))
  .
end.
else do: /* <> {&add-def} */
  assign
  tt-fin-doc.payer-sign1:label  = tt-fin-doc.payer-sign1:label  + " - ":U +
                            v-head-position
  tt-fin-doc.payer-sign1 =   (if num-entries(tt-fin-doc.payer-sign1, {&delim-par}) > 1
                                    then entry(2, tt-fin-doc.payer-sign1, {&delim-par})
                                    else entry(1, tt-fin-doc.payer-sign1, {&delim-par}))

  .
  
end.
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
tt-fin-doc.receiver-passport
tt-fin-doc.receiver-name
tt-fin-doc.naznach-plat
tt-fin-doc.enclosure
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign2
tt-fin-doc.payer-sign3
tt-fin-doc.PS
tt-fin-doc.shift-date when tt-fin-doc.shift-flag = integer({&fin-flag-shift})
tt-fin-doc.shift-num  when tt-fin-doc.shift-flag = integer({&fin-flag-shift})
tt-fin-doc.shift-name when tt-fin-doc.shift-flag = integer({&fin-flag-shift})
with frame {&frame-name}
.
find first ub.cashbook no-lock where ub.cashbook.id = tt-fin-doc.CashBookId no-error.
if available ub.cashbook
then do :
  f-cashbook = ub.CashBook.CashBookName .
  display
    f-cashbook
  with frame {&frame-name} .
end.
if tt-fin-doc.shift-flag <> integer({&fin-flag-shift})  then do:
  hide
  tt-fin-doc.shift-date
  tt-fin-doc.shift-num
  tt-fin-doc.shift-name
  in frame {&frame-name} .
end.

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
if p-mode eq {&add-def}
then 
   run update_prc-doc-code-mask (no).
run change-view in this-procedure(rs-view).
VIEW FRAME Dialog-Frame.
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

if ub.CashBook.CorrRko <> "" and (tt-fin-doc.cor-acc = 0 or tt-fin-doc.cor-acc = ?) then do:
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.CorrRko
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
      end. 
end.
else do: 
  if tt-fin-doc.cor-acc = ? or tt-fin-doc.cor-acc = 0 then do:      
  for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = "57.01"
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc-value = ub.fin-code-cor-acc.code-value .
  end. 
  end.
end.        

if ub.CashBook.OsnAcct <> "" and (tt-fin-doc.cor-acc1 = ? or tt-fin-doc.cor-acc1 = 0) then do:      
      for first ub.fin-code-cor-acc no-lock where ub.fin-code-cor-acc.code-value = ub.CashBook.OsnAcct
        and ub.fin-code-cor-acc.host-code = p-curr-host-code :
        tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code .
        tt-fin-doc.cor-acc1-value = ub.fin-code-cor-acc.code-value .
      end. 
end.      
assign
tt-fin-doc.prn-doc-code frame {&frame-name}
tt-fin-doc.doc-date
tt-fin-doc.obj-code
tt-fin-doc.obj-type
tt-fin-doc.obj-type  = (if tt-fin-doc.obj-code = 0 then "":U else tt-fin-doc.obj-type)
tt-fin-doc.payer-name
tt-fin-doc.str-podr-type
tt-fin-doc.str-podr-code
tt-fin-doc.str-podr-name

/*tt-fin-doc.cor-acc1 = (if available X_fin-code-cor-acc1 */
/*                       then X_fin-code-cor-acc1.fin-code*/
/*                       else 0)                          */
/*tt-fin-doc.cor-acc1-value = (if available X_fin-code-cor-acc1*/
/*                       then X_fin-code-cor-acc1.code-value   */
/*                       else "":U)                            */
/*tt-fin-doc.cor-acc  = (if available X_fin-code-cor-acc */
/*                       then X_fin-code-cor-acc.fin-code*/
/*                       else 0)                         */
/*tt-fin-doc.cor-acc-value  = (if available X_fin-code-cor-acc*/
/*                       then X_fin-code-cor-acc.code-value   */
/*                       else "":U)                           */
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
tt-fin-doc.receiver-code
tt-fin-doc.receiver-type
tt-fin-doc.receiver-name
tt-fin-doc.naznach-plat = clean_char(tt-fin-doc.naznach-plat:screen-value)
tt-fin-doc.receiver-passport = clean_char(tt-fin-doc.receiver-passport:screen-value)
tt-fin-doc.enclosure = clean_char(tt-fin-doc.enclosure:screen-value)
tt-fin-doc.PS = clean_char(tt-fin-doc.PS:screen-value)
tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign1  =   v-head-position + {&delim-par} + tt-fin-doc.payer-sign1
tt-fin-doc.payer-sign2
tt-fin-doc.payer-sign3
tt-fin-doc.doc-author = (if p-mode = {&add-def} then {&manual} else tt-fin-doc.doc-author)
.
if not p-save then return.
run check-sums-rate in this-procedure no-error.
if error-status:error then return error.

&scop prfx tt-fin-doc.

   find first buf_clients-attr no-lock where buf_clients-attr.attr-code = {&attr-is-inkassator} and 
      buf_clients-attr.obj-code = tt-fin-doc.receiver-code and
      buf_clients-attr.obj-code = tt-fin-doc.receiver-code no-error .
   if available (buf_clients-attr) then 
   do:
      find first bf_fin-doc-attr exclusive-lock where bf_fin-doc-attr.attr-code = "pre-vedom" and bf_fin-doc-attr.host-code = p-host-code
         and bf_fin-doc-attr.fin-doc-code = tt-fin-doc.fin-doc-code and bf_fin-doc-attr.attr-value <> "" no-error . 
      if not available (bf_fin-doc-attr) then 
      do:
         message "Для данного получателя нет № Препроводительной ведомости, сохранение невозможно" view-as alert-box error .
         undo, return error .
  end.                                                
end.   
  
run ref/findoc0.p (
input-output p-doc-rec
       ,input p-mode
       ,input no /*p-silent*/
       {&all-fin-doc-params-doc-status-transfer}
       {&all-fin-doc-params-doc-status-transfer-2}
       ,input table tt0-fin-doc-tax
       ,input table tt0-fin-doc-attr
       ,input no /*p-save-payment*/
       ,input table tt0-payment
) no-error.
if error-status:error then do:
 { gbl/reterhnd.i error }
  undo, return error.
end.
if p-mode eq {&add-def}
then 
   run update_prc-doc-code-mask(yes).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE update_prc-doc-code-mask Dialog-Frame 
PROCEDURE update_prc-doc-code-mask :
define variable vCashBook as class ibs.th.ref.cashbookstorage no-undo.
  define input  parameter IFlagSave as logical no-undo. 
  define variable vMask     as character no-undo.
  define variable v-key     as character no-undo.
  define variable vValue    as character no-undo.
  if tt-fin-doc.prn-doc-code:screen-value in frame Dialog-Frame ne "" and IFlagSave
  then 
     if tt-fin-doc.prn-doc-code:screen-value in frame Dialog-Frame ne mprn-doc-code-old
         
     then do:
        return.
     end. 
  vCashBook = new ibs.th.ref.cashbookstorage () .
      
  vmask = vCashBook:getSinglRule(tt-fin-doc.cashbookId, p-obj-type,p-obj-code, "RkoMask") .
  MParam = if vCashBook:getSinglRule(tt-fin-doc.cashbookId, p-obj-type,p-obj-code, "uchet") eq "1"
           then "year," + string(year(tt-fin-doc.shift-date))
           else "".                                      
  
  delete object vCashBook no-error .
  
  if vmask > ""
  then.
  else vmask = "[NNNN]/[obj-code]" .
  find first ub.CashBookRule exclusive-lock where ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
                                              and ub.CashBookRule.Obj-type = p-obj-type
                                              and ub.CashBookRule.Obj-code = p-obj-code
                                           and ub.CashBookRule.Code = "currRko"
                                           no-error .
  if not available ub.CashBookRule
  then do :
     create ub.CashBookRule .
     assign
        ub.CashBookRule.CashBookID = tt-fin-doc.cashbookId
        ub.CashBookRule.Obj-type = p-obj-type    
        ub.CashBookRule.Obj-code = p-obj-code    
        ub.CashBookRule.Code = "currRko"    
        ub.CashBookRule.Status_ = 0
        ub.CashBookRule.RuleValue = "1"                       
     .
      end.  
      run gen-key-rec in this-procedure ( input {&table_CashBookRule}
                                         ,input (buffer CashBookRule:handle)
                                         ,output v-key).
                                         
  subscribe   to "getCounter" anywhere run-procedure if IFlagSave then "Mycounternext" else "MycounterCurr".
   
  assign
        current-pko-rko = "currRKO" 
        current-ruleID = v-key
      .

      run utl/maskproc.p(parparentproc, vmask, "cashbook", tt-fin-doc.cashbookId,  output vValue).
      mprn-doc-code-old =  vValue.
      tt-fin-doc.prn-doc-code = vValue.
      display  tt-fin-doc.prn-doc-code with frame Dialog-Frame.
   unsubscribe to "getCounter".
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MycounterCurr Dialog-Frame 
PROCEDURE MycounterCurr :
define input  parameter iFileName as character no-undo.
define input  parameter ikey      as character no-undo.
define input  parameter icode     as character no-undo.
define output parameter oCount    as int64 no-undo.
 define variable mCounterStor as class ibs.th.ref.counter.counterstorage.
 mCounterStor = new ibs.th.ref.counter.counterstorage().
 oCount = mCounterStor:GetCountValue(G#db-num,"cashbookrule", current-ruleID, current-pko-rko ) + 1.
 delete object mCounterStor.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MycounterNext Dialog-Frame 
PROCEDURE MycounterNext :
define input  parameter iFileName as character no-undo.
define input  parameter ikey      as character no-undo.
define input  parameter icode     as character no-undo.
define output parameter oCount    as int64 no-undo.
 run utl/getnextcount.p ("cashbookrule", current-ruleID, current-pko-rko, MParam ,output oCount    ).
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
