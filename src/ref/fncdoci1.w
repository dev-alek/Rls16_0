&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER locked_c-fin-doc FOR ub.c-fin-doc.
DEFINE TEMP-TABLE tt-c-fin-doc NO-UNDO LIKE ub.c-fin-doc.
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

Карточка истории приходного ордера

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
/*может быть  {&lookup}*/

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
define variable vss-description as character no-undo init "Карточка истории приходного ордера".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-view as character no-undo init "full":U.
define variable v-not-uf-set as logical no-undo.
define variable v-copy-mode as logical no-undo .
define variable v-curr-code like ub.fin-doc.curr-code no-undo .
define variable v-main-sum as character no-undo init "sum-doc":U.
define variable v-main-curr as character no-undo init "exch-rate":U.
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
define buffer X_fin-code-cor-acc1 for ub.fin-code-cor-acc.
define buffer X_currency for ub.currency.
define buffer X_receiver for ub.clients.
DEFINE BUFFER X_payer FOR ub.clients.
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_contract for ub.contract.
define buffer X_fin-ob for ub.fin-ob.


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
                       "f-contract-scale,f-contract-type,f-cor-acc1-descr,f-cor-acc-descr,base-rate,base-scale,curr-code,exch-rate,exch-scale," +  ~
                       "fact-date,fin-doc-code,payer-code,payer-type,perm-date,PS,receiver-code,receiver-type,sum-base,sum-rubl," +  ~
                       "user-name-doc,user-name-fact,user-name-perm"

&scop in-form-list    "F-curr-abbr,an-uchet-value,cel-nazn-value,cor-acc1-value,cor-acc-value,doc-date,enclosure," + ~
                      "including,naznach-plat,payer-name,prn-doc-code,receiver-name,receiver-okpo,receiver-sign2,receiver-sign3," + ~
                      "str-podr-code,str-podr-name,str-podr-type,sum-doc"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_c-fin-doc

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH locked_c-fin-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH locked_c-fin-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame locked_c-fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame locked_c-fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-c-fin-doc.prn-doc-code ~
tt-c-fin-doc.doc-date tt-c-fin-doc.user-name-doc tt-c-fin-doc.obj-type ~
tt-c-fin-doc.obj-code tt-c-fin-doc.str-podr-type tt-c-fin-doc.str-podr-code ~
tt-c-fin-doc.str-podr-name tt-c-fin-doc.cor-acc1-value ~
tt-c-fin-doc.cor-acc-value tt-c-fin-doc.contract-curr ~
tt-c-fin-doc.an-uchet-value tt-c-fin-doc.cel-nazn-value ~
tt-c-fin-doc.sum-doc tt-c-fin-doc.curr-code tt-c-fin-doc.exch-rate ~
tt-c-fin-doc.exch-scale tt-c-fin-doc.sum-rubl tt-c-fin-doc.sum-base ~
tt-c-fin-doc.contract-rate tt-c-fin-doc.contract-scale ~
tt-c-fin-doc.sum-contr tt-c-fin-doc.payer-type tt-c-fin-doc.payer-code ~
tt-c-fin-doc.payer-name tt-c-fin-doc.naznach-plat tt-c-fin-doc.including ~
tt-c-fin-doc.enclosure tt-c-fin-doc.PS tt-c-fin-doc.receiver-sign2 ~
tt-c-fin-doc.receiver-sign3
&Scoped-define ENABLED-TABLES tt-c-fin-doc
&Scoped-define FIRST-ENABLED-TABLE tt-c-fin-doc
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-tax B-Help RS-view ~
B-receiver-view f-contract-curr-abbr B-contract-view B-payer-view
&Scoped-Define DISPLAYED-FIELDS tt-c-fin-doc.perm-date ~
tt-c-fin-doc.prn-doc-code tt-c-fin-doc.fin-doc-code ~
tt-c-fin-doc.user-name-perm tt-c-fin-doc.doc-date ~
tt-c-fin-doc.user-name-doc tt-c-fin-doc.obj-type tt-c-fin-doc.obj-code ~
tt-c-fin-doc.fact-date tt-c-fin-doc.user-name-fact ~
tt-c-fin-doc.receiver-type tt-c-fin-doc.receiver-okpo ~
tt-c-fin-doc.receiver-name tt-c-fin-doc.receiver-code ~
tt-c-fin-doc.str-podr-type tt-c-fin-doc.str-podr-code ~
tt-c-fin-doc.str-podr-name tt-c-fin-doc.cor-acc1-value ~
tt-c-fin-doc.cor-acc-value tt-c-fin-doc.contract-curr ~
tt-c-fin-doc.an-uchet-value tt-c-fin-doc.cel-nazn-value ~
tt-c-fin-doc.sum-doc tt-c-fin-doc.curr-code tt-c-fin-doc.exch-rate ~
tt-c-fin-doc.exch-scale tt-c-fin-doc.sum-rubl tt-c-fin-doc.base-rate ~
tt-c-fin-doc.base-scale tt-c-fin-doc.sum-base tt-c-fin-doc.contract-rate ~
tt-c-fin-doc.contract-scale tt-c-fin-doc.sum-contr tt-c-fin-doc.payer-type ~
tt-c-fin-doc.payer-code tt-c-fin-doc.payer-name tt-c-fin-doc.naznach-plat ~
tt-c-fin-doc.including tt-c-fin-doc.enclosure tt-c-fin-doc.PS ~
tt-c-fin-doc.receiver-sign2 tt-c-fin-doc.receiver-sign3
&Scoped-define DISPLAYED-TABLES tt-c-fin-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-c-fin-doc
&Scoped-Define DISPLAYED-OBJECTS RS-view f-cor-acc1-descr f-cor-acc-descr ~
f-contract-curr-abbr f-contract-prn-code f-contract-date f-contract-type ~
f-an-uchet-descr f-cel-nazn-descr F-curr-abbr F-debet F-credit

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

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-payer-view
     LABEL "П&лательщик"
     SIZE 12 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-receiver-view
     LABEL "П&олучатель"
     SIZE 12 BY 1
     FGCOLOR 4 .

DEFINE BUTTON B-tax
     LABEL "&Налоги"
     SIZE 10 BY 1.

DEFINE VARIABLE f-an-uchet-descr AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 60 BY 1 NO-UNDO.

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
     SIZE 10 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-view AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 36.5 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      locked_c-fin-doc SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-tax AT ROW 1 COL 59
     B-Help AT ROW 1 COL 89
     RS-view AT ROW 1.08 COL 22.25 NO-LABEL
     tt-c-fin-doc.perm-date AT ROW 1.96 COL 71.5 COLON-ALIGNED
          LABEL "Дата разр"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-doc.prn-doc-code AT ROW 2 COL 16.5 COLON-ALIGNED
          LABEL "Номер документа"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
          FGCOLOR 4
     tt-c-fin-doc.fin-doc-code AT ROW 2 COL 46 COLON-ALIGNED
          LABEL "Внутр. №"
          VIEW-AS FILL-IN
          SIZE 10.38 BY 1
     tt-c-fin-doc.user-name-perm AT ROW 2 COL 82.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.doc-date AT ROW 3 COL 11 COLON-ALIGNED
          LABEL "Дата сост."
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-doc.user-name-doc AT ROW 3 COL 22.38 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.obj-type AT ROW 3 COL 39.38 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U
          SIZE 12.63 BY 1
     tt-c-fin-doc.obj-code AT ROW 3 COL 50.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6.5 BY 1
     tt-c-fin-doc.fact-date AT ROW 3 COL 71.38 COLON-ALIGNED
          LABEL "Дата факт"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-doc.user-name-fact AT ROW 3 COL 82.75 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14.5 BY 1
     tt-c-fin-doc.receiver-type AT ROW 4 COL 1.75 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     tt-c-fin-doc.receiver-okpo AT ROW 4 COL 17.25 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-doc.receiver-name AT ROW 4 COL 28.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
          FGCOLOR 4
     B-receiver-view AT ROW 4 COL 87
     tt-c-fin-doc.receiver-code AT ROW 4.04 COL 4.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-c-fin-doc.str-podr-type AT ROW 5 COL 1.25
          LABEL "Структ.подразд."
          VIEW-AS FILL-IN
          SIZE 4 BY 1
          FGCOLOR 4
     tt-c-fin-doc.str-podr-code AT ROW 5 COL 20.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 4
     tt-c-fin-doc.str-podr-name AT ROW 5 COL 46.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 50 BY 1
          FGCOLOR 4
     tt-c-fin-doc.cor-acc1-value AT ROW 6 COL 16.25 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     f-cor-acc1-descr AT ROW 6 COL 35.38 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.cor-acc-value AT ROW 7 COL 9.25
          LABEL "Корсчет"
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     f-cor-acc-descr AT ROW 7 COL 35.38 COLON-ALIGNED NO-LABEL
     f-contract-curr-abbr AT ROW 7.46 COL 55.25 COLON-ALIGNED NO-LABEL
     B-contract-view AT ROW 7.5 COL 1
     f-contract-prn-code AT ROW 7.5 COL 12 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     f-contract-date AT ROW 7.5 COL 36.63 COLON-ALIGNED
     tt-c-fin-doc.contract-curr AT ROW 7.5 COL 49.13 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     f-contract-type AT ROW 7.5 COL 72 COLON-ALIGNED
     tt-c-fin-doc.an-uchet-value AT ROW 8 COL 5.25
          LABEL "Код ан. уч."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     f-an-uchet-descr AT ROW 8 COL 35.38 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.cel-nazn-value AT ROW 9 COL 3.25
          LABEL "Код цел.назн."
          VIEW-AS FILL-IN
          SIZE 14 BY 1
          FGCOLOR 4
     f-cel-nazn-descr AT ROW 9 COL 35.38 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.sum-doc AT ROW 10 COL 6 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          FGCOLOR 4
     tt-c-fin-doc.curr-code AT ROW 10.04 COL 41.88 COLON-ALIGNED
          LABEL "Вал"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     F-curr-abbr AT ROW 10.04 COL 50.88 COLON-ALIGNED NO-LABEL
     tt-c-fin-doc.exch-rate AT ROW 11 COL 39.63 COLON-ALIGNED
          LABEL "Курс пл-жа"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-c-fin-doc.exch-scale AT ROW 11 COL 49.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.63 BY 1
     tt-c-fin-doc.sum-rubl AT ROW 11 COL 72.25 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-doc.base-rate AT ROW 12 COL 39.63 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-c-fin-doc.base-scale AT ROW 12 COL 49.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.63 BY 1
     tt-c-fin-doc.sum-base AT ROW 12 COL 72.13 COLON-ALIGNED
          LABEL "Б.в."
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-doc.contract-rate AT ROW 13 COL 39.63 COLON-ALIGNED
          LABEL "Курс дог-ра"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-c-fin-doc.contract-scale AT ROW 13 COL 49.88 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 5.63 BY 1
     tt-c-fin-doc.sum-contr AT ROW 13 COL 72.25 COLON-ALIGNED
          LABEL "вал.дог-ра"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
     tt-c-fin-doc.payer-type AT ROW 14 COL 1.13 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 1", "2":U
          SIZE 13.5 BY 1.04
     tt-c-fin-doc.payer-code AT ROW 14 COL 13.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-c-fin-doc.payer-name AT ROW 14 COL 30.25 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 53 BY 1
          FGCOLOR 4
     B-payer-view AT ROW 14 COL 87
     tt-c-fin-doc.naznach-plat AT ROW 16 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 2 TOOLTIP "Основание платежа"
          FGCOLOR 4
     tt-c-fin-doc.including AT ROW 16 COL 50.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 2
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     tt-c-fin-doc.enclosure AT ROW 19 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 2
          FGCOLOR 4
     tt-c-fin-doc.PS AT ROW 19 COL 50.5 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 48 BY 2 TOOLTIP "Дополнительная информация, не печатающаяся в ордере"
     tt-c-fin-doc.receiver-sign2 AT ROW 21.04 COL 1
          LABEL "Гл. бухгалтер"
          VIEW-AS FILL-IN
          SIZE 30.88 BY 1
          FGCOLOR 4
     tt-c-fin-doc.receiver-sign3 AT ROW 21.04 COL 57.75 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 24.38 BY 1
          FGCOLOR 4
     F-debet AT ROW 6.21 COL 5 COLON-ALIGNED NO-LABEL
     F-credit AT ROW 7.21 COL 1.38 NO-LABEL
     "Приложение" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 18 COL 1.88
          FGCOLOR 4
     "В том числе" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 15 COL 50.5
          FGCOLOR 4
     "Основание платежа" VIEW-AS TEXT
          SIZE 19.38 BY 1 AT ROW 15 COL 1.25
          FGCOLOR 4
     "(Примечание (доп.информация, не печатается))" VIEW-AS TEXT
          SIZE 47.13 BY 1 AT ROW 18 COL 51
     SPACE(1.24) SKIP(3.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Приходный кассовый ордер - Получатель"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: locked_c-fin-doc B "?" ? ub c-fin-doc
      TABLE: tt-c-fin-doc T "?" NO-UNDO ub c-fin-doc
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
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.base-rate IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.base-scale IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.cel-nazn-value IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.contract-curr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.contract-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.contract-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.cor-acc-value IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.cor-acc1-value IN FRAME Dialog-Frame
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
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.fact-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.fin-doc-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.payer-name IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.perm-date IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.prn-doc-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-okpo IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL EXP-FORMAT                                       */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-sign2 IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-sign3 IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.receiver-type IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L EXP-LABEL                                          */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.str-podr-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.str-podr-type IN FRAME Dialog-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-base IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-contr IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-doc IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.sum-rubl IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.user-name-fact IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-c-fin-doc.user-name-perm IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.locked_c-fin-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Приходный кассовый ордер - Получатель */
DO:
  APPLY "END-ERROR":U TO SELF.
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
  and p-mode <> {&add-copy}
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
    input  ({&uf-findoci-p} + {&delim-par} + {&income-cash})
    ,input  v-cntxt-userid
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
f-debet
f-credit
tt-c-fin-doc.cor-acc1-value
f-cor-acc1-descr
tt-c-fin-doc.cor-acc-value
f-cor-acc-descr
tt-c-fin-doc.an-uchet-value
f-an-uchet-descr
tt-c-fin-doc.cel-nazn-value
f-cel-nazn-descr
tt-c-fin-doc.cel-nazn-value

tt-c-fin-doc.perm-date
tt-c-fin-doc.user-name-perm

tt-c-fin-doc.fact-date
tt-c-fin-doc.user-name-fact

b-exit

b-contract-view
f-contract-date
f-contract-prn-code
f-contract-type
f-contract-curr-abbr
tt-c-fin-doc.contract-curr

b-receiver-view
tt-c-fin-doc.receiver-type
tt-c-fin-doc.receiver-code
tt-c-fin-doc.receiver-okpo
tt-c-fin-doc.receiver-name
tt-c-fin-doc.str-podr-type
tt-c-fin-doc.str-podr-code
tt-c-fin-doc.str-podr-name

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
  tt-c-fin-doc.obj-type
  tt-c-fin-doc.obj-code
  tt-c-fin-doc.sum-rubl
  tt-c-fin-doc.curr-code
  tt-c-fin-doc.sum-doc
  tt-c-fin-doc.payer-code
  tt-c-fin-doc.payer-type
  tt-c-fin-doc.payer-name
  tt-c-fin-doc.including
  tt-c-fin-doc.naznach-plat
  tt-c-fin-doc.enclosure
  tt-c-fin-doc.PS
  tt-c-fin-doc.receiver-sign2
  tt-c-fin-doc.receiver-sign3
  with frame {&frame-name}
  .
  if tt-c-fin-doc.perm-date <> ? then
  display
  tt-c-fin-doc.perm-date
  tt-c-fin-doc.user-name-perm
  with frame {&frame-name}
   .
  if tt-c-fin-doc.fact-date <> ? then
  display
  tt-c-fin-doc.fact-date
  tt-c-fin-doc.user-name-fact
  with frame {&frame-name}
  .
ENABLE
b-quit
B-tax
B-Help
RS-view
b-receiver-view
b-payer-view
WITH FRAME Dialog-Frame.
assign
b-quit:label = "&Выход".
run hide-view-currency in this-procedure.
CASE p-view:
  when "full":U then do:
    IF AVAILABLE tt-c-fin-doc THEN
    display
    tt-c-fin-doc.receiver-type
    tt-c-fin-doc.receiver-code
    tt-c-fin-doc.receiver-okpo
    tt-c-fin-doc.receiver-name
    tt-c-fin-doc.str-podr-type
    tt-c-fin-doc.str-podr-code
    tt-c-fin-doc.str-podr-name
    with frame {&frame-name}
    .
    display
    f-debet                          when X_sysconf.is-cassa-acc
    f-credit                         when (X_sysconf.is-corr-acc or  X_sysconf.is-an-uchet or X_sysconf.is-code-cel-nazn)
    tt-c-fin-doc.cor-acc1-value      when X_sysconf.is-cassa-acc
    f-cor-acc1-descr                 when X_sysconf.is-cassa-acc
    tt-c-fin-doc.cor-acc-value       when X_sysconf.is-corr-acc
    f-cor-acc-descr                  when X_sysconf.is-corr-acc
    tt-c-fin-doc.an-uchet-value      when X_sysconf.is-an-uchet
    f-an-uchet-descr                 when X_sysconf.is-an-uchet
    tt-c-fin-doc.cel-nazn-value      when X_sysconf.is-code-cel-nazn
    f-cel-nazn-descr                 when X_sysconf.is-code-cel-nazn
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
  DISPLAY RS-view f-cor-acc1-descr f-cor-acc-descr f-contract-curr-abbr
          f-contract-prn-code f-contract-date f-contract-type f-an-uchet-descr
          f-cel-nazn-descr F-curr-abbr F-debet F-credit
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-c-fin-doc THEN
    DISPLAY tt-c-fin-doc.perm-date tt-c-fin-doc.prn-doc-code
          tt-c-fin-doc.fin-doc-code tt-c-fin-doc.user-name-perm
          tt-c-fin-doc.doc-date tt-c-fin-doc.user-name-doc tt-c-fin-doc.obj-type
          tt-c-fin-doc.obj-code tt-c-fin-doc.fact-date
          tt-c-fin-doc.user-name-fact tt-c-fin-doc.receiver-type
          tt-c-fin-doc.receiver-okpo tt-c-fin-doc.receiver-name
          tt-c-fin-doc.receiver-code tt-c-fin-doc.str-podr-type
          tt-c-fin-doc.str-podr-code tt-c-fin-doc.str-podr-name
          tt-c-fin-doc.cor-acc1-value tt-c-fin-doc.cor-acc-value
          tt-c-fin-doc.contract-curr tt-c-fin-doc.an-uchet-value
          tt-c-fin-doc.cel-nazn-value tt-c-fin-doc.sum-doc
          tt-c-fin-doc.curr-code tt-c-fin-doc.exch-rate tt-c-fin-doc.exch-scale
          tt-c-fin-doc.sum-rubl tt-c-fin-doc.base-rate tt-c-fin-doc.base-scale
          tt-c-fin-doc.sum-base tt-c-fin-doc.contract-rate
          tt-c-fin-doc.contract-scale tt-c-fin-doc.sum-contr
          tt-c-fin-doc.payer-type tt-c-fin-doc.payer-code
          tt-c-fin-doc.payer-name tt-c-fin-doc.naznach-plat
          tt-c-fin-doc.including tt-c-fin-doc.enclosure tt-c-fin-doc.PS
          tt-c-fin-doc.receiver-sign2 tt-c-fin-doc.receiver-sign3
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-tax B-Help RS-view tt-c-fin-doc.prn-doc-code
         tt-c-fin-doc.doc-date tt-c-fin-doc.user-name-doc tt-c-fin-doc.obj-type
         tt-c-fin-doc.obj-code B-receiver-view tt-c-fin-doc.str-podr-type
         tt-c-fin-doc.str-podr-code tt-c-fin-doc.str-podr-name
         tt-c-fin-doc.cor-acc1-value tt-c-fin-doc.cor-acc-value
         f-contract-curr-abbr B-contract-view tt-c-fin-doc.contract-curr
         tt-c-fin-doc.an-uchet-value tt-c-fin-doc.cel-nazn-value
         tt-c-fin-doc.sum-doc tt-c-fin-doc.curr-code tt-c-fin-doc.exch-rate
         tt-c-fin-doc.exch-scale tt-c-fin-doc.sum-rubl tt-c-fin-doc.sum-base
         tt-c-fin-doc.contract-rate tt-c-fin-doc.contract-scale
         tt-c-fin-doc.sum-contr tt-c-fin-doc.payer-type tt-c-fin-doc.payer-code
         tt-c-fin-doc.payer-name B-payer-view tt-c-fin-doc.naznach-plat
         tt-c-fin-doc.including tt-c-fin-doc.enclosure tt-c-fin-doc.PS
         tt-c-fin-doc.receiver-sign2 tt-c-fin-doc.receiver-sign3
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
  { gbl/curdbnum.i v-db-num }
  { gbl/basecode.i p-host-code v-base-code }
  find first X_curr_sysconf no-lock where
                  X_curr_sysconf.host-code = p-curr-host-code.
  find first X_sysconf no-lock where
                X_sysconf.host-code = p-host-code.
  if p-mode <> {&lookup} then do:
    if p-curr-host-code <> p-host-code
    or (v-db-num <> X_sysconf.firm-db-num)
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
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
  "Не найдена запись ИСТОРИИ ПРИХОДНОГО ОРДЕРА"
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
define variable g-log as logical no-undo.
assign
    tt-c-fin-doc.sum-rubl :label in frame {&frame-name} = "{&abbr_rubli_firstshift}"
.
run uf-get in this-procedure(
    input  ({&uf-findoci-p} + {&delim-par} + {&income-cash})
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
rs-view = v-view
tt-c-fin-doc.obj-type:radio-buttons = "Маг" + {&comma-char} + {&shop} + {&comma-char} +
                                      "Скл" + {&comma-char} + {&stock}

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
if tt-c-fin-doc.contract-code <> 0 then do:
  find first X_currency no-lock where
                X_currency.curr-code = tt-c-fin-doc.contract-curr.
  assign
  f-contract-curr-abbr = X_Currency.curr-abbr.
end.

if tt-c-fin-doc.cor-acc1 <> 0 then do:
    find first X_fin-code-cor-acc1 no-lock where
                X_fin-code-cor-acc1.fin-code  = tt-c-fin-doc.cor-acc1 no-error.
    if available X_fin-code-cor-acc1 then do:
      assign
      f-cor-acc1-descr = X_fin-code-cor-acc1.descr.
    end.
    if not available X_fin-code-cor-acc1 then do:
      assign
      f-cor-acc1-descr = "!!!Код больше не существует".
    end.
end.
if tt-c-fin-doc.cor-acc <> 0 then do:
    find first X_fin-code-cor-acc no-lock where
                X_fin-code-cor-acc.fin-code  = tt-c-fin-doc.cor-acc no-error.
    if available X_fin-code-cor-acc then do:
      assign
      f-cor-acc-descr = X_fin-code-cor-acc.descr.
    end.
    if not available X_fin-code-cor-acc then do:
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
    if not available X_fin-code-an-uchet then do:
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
    if not available X_fin-code-cel-nazn then do:
      assign
      f-cel-nazn-descr = "!!!Код больше не существует".
    end.
end.

run proc-color-widgets in this-procedure({&not-in-form-list}, no, yes, ?, grey_color).
run proc-color-widgets in this-procedure({&in-form-list}, no, yes, ?, grey_color).
run change-view in this-procedure(rs-view).
VIEW FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
