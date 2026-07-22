&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_obj FOR ub.clients.
DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE BUFFER cashier FOR ub.person.
DEFINE BUFFER locked-par_c-chk-pay FOR ub.c-chk-pay.
DEFINE BUFFER locked_c-chk-doc FOR ub.c-chk-doc.
DEFINE BUFFER locked_c-chk-doc-attr FOR ub.c-chk-doc-attr.
DEFINE BUFFER locked_c-chk-pay FOR ub.c-chk-pay.
DEFINE BUFFER sales-man FOR ub.person.
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE ub.chk-doc.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE ub.chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE ub.chk-pay.
DEFINE TEMP-TABLE tt-par-chk-pay NO-UNDO LIKE ub.chk-pay.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История Чека МЦ: добавление, изменение

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/06/05
Author: Bakhtadze Natalya
Creation date: 12/06/05


*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter par-mode AS CHARACTER NO-UNDO.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
define input-output parameter p-doc-rec as recid no-undo .
define input parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "История Чека МЦ: добавление, изменение":U.
{ cmp/vssrevis.i }
{ cmp/showinf.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
DEFINE VARIABLE vardb-num like ub.db.db-num no-undo.
/*DEFINE SHARED QUERY BR-docs FOR chk-doc SCROLLING.*/
DEFINE VARIABLE varbase-curs like ub.curr-shop.exch-rate no-undo.
DEFINE VARIABLE varbase-code like ub.currency.curr-code no-undo.
DEFINE VARIABLE varwth-code like ub.wealth.wth-code no-undo.
DEFINE VARIABLE varwth-name like ub.wealth.wth-name no-undo.
/*настройка - откуда брать номер магазина при чтении чеков из спула - из спула- yes или
по умолчанию номер магазина в котором принимается почта*/
define variable hnum as logical no-undo init no.
/*вспомогат*/
DEFINE VARIABLE conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE conf-par as char no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE par-type as char no-undo.
define variable r-b as character no-undo.
/*текущая смена*/
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable locked-title as logical no-undo.
DEFINE VARIABLE var-doc-rid as recid no-undo .
define variable p-view-log as logical no-undo.
define variable v-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-is-update as logical no-undo .
define variable v-first-mode as character no-undo .
define variable for-wth-code as integer no-undo .
define variable exch-date_ like ub.curr-shop.exch-date no-undo .
define variable exch-time_ like ub.curr-shop.exch-time no-undo .


{ str/get-chkc.i def update }
{ gbl/gbclcode.i }
{ str/shftnmef.i chk-doc shift-name }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-par-chk-pay

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-par-chk-pay locked_c-chk-pay tt-chk-pay ~
tt-chk-doc

/* Definitions for BROWSE br-par-chk-pay                                    */
&Scoped-define FIELDS-IN-QUERY-br-par-chk-pay tt-par-chk-pay.line-num tt-par-chk-pay.is-error tt-par-chk-pay.par-val tt-par-chk-pay.doc-qnty tt-par-chk-pay.tot-sum tt-par-chk-pay.par-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-par-chk-pay tt-par-chk-pay.doc-qnty
&Scoped-define ENABLED-TABLES-IN-QUERY-br-par-chk-pay tt-par-chk-pay
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-br-par-chk-pay tt-par-chk-pay
&Scoped-define SELF-NAME br-par-chk-pay
&Scoped-define QUERY-STRING-br-par-chk-pay FOR EACH tt-par-chk-pay WHERE         tt-par-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-par-chk-pay.pay-code = tt-chk-pay.pay-code     AND tt-par-chk-pay.curr-code = tt-chk-pay.curr-code       INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-par-chk-pay OPEN QUERY {&SELF-NAME} FOR EACH tt-par-chk-pay WHERE         tt-par-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-par-chk-pay.pay-code = tt-chk-pay.pay-code     AND tt-par-chk-pay.curr-code = tt-chk-pay.curr-code       INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-par-chk-pay tt-par-chk-pay
&Scoped-define FIRST-TABLE-IN-QUERY-br-par-chk-pay tt-par-chk-pay


/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines tt-chk-pay.line-num tt-chk-pay.pay-code tt-chk-pay.curr-code get-cash-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, OUTPUT for-wth-code) varwth-code tt-chk-pay.tot-sum varwth-name tt-chk-pay.cash-rate tt-chk-pay.bank-rate tt-chk-pay.bank-scale
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines tt-chk-pay.pay-code tt-chk-pay.curr-code tt-chk-pay.tot-sum tt-chk-pay.cash-rate tt-chk-pay.bank-rate tt-chk-pay.bank-scale
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines tt-chk-pay
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines tt-chk-pay
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH locked_c-chk-pay NO-LOCK WHERE        locked_c-chk-pay.doc-code = tt-chk-doc.doc-code     AND locked_c-chk-pay.chip-num = locked_c-chk-pay.chip-num, ~
           FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_c-chk-pay.line-num
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH locked_c-chk-pay NO-LOCK WHERE        locked_c-chk-pay.doc-code = tt-chk-doc.doc-code     AND locked_c-chk-pay.chip-num = locked_c-chk-pay.chip-num, ~
           FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_c-chk-pay.line-num.
&Scoped-define TABLES-IN-QUERY-BR-lines locked_c-chk-pay tt-chk-pay
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines locked_c-chk-pay
&Scoped-define SECOND-TABLE-IN-QUERY-BR-lines tt-chk-pay


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-chk-doc.chk-date ~
tt-chk-doc.obj-code tt-chk-doc.chk-type tt-chk-doc.pay-desk ~
tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cashier ~
tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.chk-num ~
tt-chk-doc.cash-rate tt-chk-doc.z-number tt-chk-doc.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-chk-doc.chk-date ~
tt-chk-doc.obj-code tt-chk-doc.chk-type tt-chk-doc.pay-desk ~
tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cashier ~
tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.chk-num ~
tt-chk-doc.cash-rate tt-chk-doc.z-number tt-chk-doc.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-chk-doc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-chk-doc
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-par-chk-pay}~
    ~{&OPEN-QUERY-BR-lines}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH tt-chk-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame tt-chk-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame tt-chk-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-chk-doc.chk-date tt-chk-doc.obj-code ~
tt-chk-doc.chk-type tt-chk-doc.pay-desk tt-chk-doc.src-shift-date ~
tt-chk-doc.shift-date tt-chk-doc.cashier tt-chk-doc.shift-name ~
tt-chk-doc.shift-num tt-chk-doc.chk-num tt-chk-doc.cash-rate ~
tt-chk-doc.z-number tt-chk-doc.PS
&Scoped-define ENABLED-TABLES tt-chk-doc
&Scoped-define FIRST-ENABLED-TABLE tt-chk-doc
&Scoped-Define ENABLED-OBJECTS b-quit B-prev B-next B-Help fhour fmin fsec ~
BR-lines br-par-chk-pay f-par-sum
&Scoped-Define DISPLAYED-FIELDS tt-chk-doc.chk-date tt-chk-doc.obj-code ~
tt-chk-doc.chk-type tt-chk-doc.pay-desk tt-chk-doc.src-shift-date ~
tt-chk-doc.shift-date tt-chk-doc.cashier tt-chk-doc.shift-name ~
tt-chk-doc.shift-num tt-chk-doc.chk-num tt-chk-doc.cash-rate ~
tt-chk-doc.z-number tt-chk-doc.PS
&Scoped-define DISPLAYED-TABLES tt-chk-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-chk-doc
&Scoped-Define DISPLAYED-OBJECTS fhour fmin fsec f-par-sum

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-cash-pay Dialog-Frame
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input parpay-code as integer, parcurr-code as integer, OUTPUT p-wth-code AS INTEGER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-par-sum AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     LABEL "Fill 1"
     VIEW-AS FILL-IN
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1 NO-UNDO.

DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1 NO-UNDO.

DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.88 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-par-chk-pay FOR
      tt-par-chk-pay SCROLLING.

DEFINE QUERY BR-lines FOR
      locked_c-chk-pay,
      tt-chk-pay SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-chk-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-par-chk-pay
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-par-chk-pay Dialog-Frame _FREEFORM
  QUERY br-par-chk-pay NO-LOCK DISPLAY
      tt-par-chk-pay.line-num FORMAT "999":U
tt-par-chk-pay.is-error COLUMN-LABEL "ОШ" FORMAT "+/-":U
tt-par-chk-pay.par-val FORMAT ">>>>>9":U
tt-par-chk-pay.doc-qnty FORMAT "->>,>>>,>>9.<<<":U
tt-par-chk-pay.tot-sum FORMAT "->>>>>>>>>9.99":U
tt-par-chk-pay.par-code COLUMN-LABEL "Код!номинала" FORMAT "999":U WIDTH 12.4
ENABLE
tt-par-chk-pay.doc-qnty
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 5.5
         TITLE "Купюрность" FIT-LAST-COLUMN.

DEFINE BROWSE BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-lines Dialog-Frame _FREEFORM
  QUERY BR-lines DISPLAY
      tt-chk-pay.line-num FORMAT "999":U
tt-chk-pay.pay-code FORMAT "-99999":U
tt-chk-pay.curr-code COLUMN-LABEL "Код!валюты" FORMAT ">>9":U
get-cash-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, OUTPUT for-wth-code) COLUMN-LABEL "Тип касс. платежа" FORMAT "X(20)":U
varwth-code COLUMN-LABEL "Код МЦ"
tt-chk-pay.tot-sum FORMAT "->>>>>>>>>9.99":U
varwth-name COLUMN-LABEL "Название МЦ" FORMAT "X(20)":U
tt-chk-pay.cash-rate COLUMN-LABEL "Курс валюты!платежа" FORMAT ">>,>>9.9999":U
tt-chk-pay.bank-rate FORMAT ">>,>>9.9999":U
tt-chk-pay.bank-scale FORMAT ">>>9":U
ENABLE
tt-chk-pay.pay-code
tt-chk-pay.curr-code
tt-chk-pay.tot-sum
tt-chk-pay.cash-rate
tt-chk-pay.bank-rate
tt-chk-pay.bank-scale
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 98 BY 11.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-prev AT ROW 1 COL 41
     B-next AT ROW 1 COL 45
     B-Help AT ROW 1 COL 95
     tt-chk-doc.chk-date AT ROW 2.33 COL 11.25 COLON-ALIGNED
          LABEL "Дата чека"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-chk-doc.obj-code AT ROW 2.33 COL 55 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.chk-type AT ROW 2.42 COL 72.38 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2
          SIZE 20.75 BY 3.25
     fhour AT ROW 3.63 COL 11.38 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.63 COL 15.5 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.63 COL 19.63 COLON-ALIGNED NO-LABEL
     tt-chk-doc.pay-desk AT ROW 3.63 COL 55 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN
          SIZE 5.25 BY 1
     tt-chk-doc.src-shift-date AT ROW 4.83 COL 11 COLON-ALIGNED
          LABEL "Дата смены" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11.5 BY 1
     tt-chk-doc.shift-date AT ROW 4.83 COL 35 COLON-ALIGNED
          LABEL "Дата учета"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          FGCOLOR 12
     tt-chk-doc.cashier AT ROW 4.83 COL 55 COLON-ALIGNED
          LABEL "Кассир"
          VIEW-AS FILL-IN
          SIZE 10 BY 1
     tt-chk-doc.shift-name AT ROW 6 COL 11 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-chk-doc.shift-num AT ROW 6 COL 20.5 COLON-ALIGNED
          LABEL "П."
          VIEW-AS FILL-IN
          SIZE 4.13 BY 1
     tt-chk-doc.chk-num AT ROW 6 COL 55 COLON-ALIGNED
          LABEL "N по кассе"
          VIEW-AS FILL-IN
          SIZE 10.88 BY 1
     tt-chk-doc.cash-rate AT ROW 6 COL 85 COLON-ALIGNED
          LABEL "Курс нац. вал."
          VIEW-AS FILL-IN
          SIZE 11.38 BY 1
     tt-chk-doc.z-number AT ROW 7.21 COL 55 COLON-ALIGNED
          LABEL "z-отчет"
          VIEW-AS FILL-IN
          SIZE 10.75 BY 1
     BR-lines AT ROW 8.5 COL 1
     br-par-chk-pay AT ROW 14 COL 1.5
     f-par-sum AT ROW 15.5 COL 78.5 COLON-ALIGNED
     tt-chk-doc.PS AT ROW 19.75 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2.25
     ":" VIEW-AS TEXT
          SIZE .75 BY 1.08 AT ROW 3.71 COL 16.38
     ":" VIEW-AS TEXT
          SIZE .75 BY 1.08 AT ROW 3.71 COL 20.38
     "Тип чека" VIEW-AS TEXT
          SIZE 11.75 BY .83 AT ROW 1.46 COL 72.25
     "Время:" VIEW-AS TEXT
          SIZE 10.25 BY 1 AT ROW 3.63 COL 2
     SPACE(86.75) SKIP(17.43)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Чек МЦ"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_cash-desk B "?" ? ub cash-desk
      TABLE: buf_cash-pay B "?" ? ub cash-pay
      TABLE: buf_obj B "?" ? ub clients
      TABLE: buf_wealth B "?" ? ub wealth
      TABLE: cashier B "?" ? ub person
      TABLE: locked-par_c-chk-pay B "?" ? ub c-chk-pay
      TABLE: locked_c-chk-doc B "?" ? ub c-chk-doc
      TABLE: locked_c-chk-doc-attr B "?" ? ub c-chk-doc-attr
      TABLE: locked_c-chk-pay B "?" ? ub c-chk-pay
      TABLE: sales-man B "?" ? ub person
      TABLE: tt-chk-doc T "NEW SHARED" NO-UNDO ub chk-doc
      TABLE: tt-chk-doc-attr T "?" NO-UNDO ub chk-doc-attr
      TABLE: tt-chk-pay T "NEW SHARED" NO-UNDO ub chk-pay
      TABLE: tt-par-chk-pay T "?" NO-UNDO ub chk-pay
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines z-number Dialog-Frame */
/* BROWSE-TAB br-par-chk-pay BR-lines Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       br-par-chk-pay:HIDDEN  IN FRAME Dialog-Frame                = TRUE.

/* SETTINGS FOR FILL-IN tt-chk-doc.cash-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.cashier IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.chk-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.chk-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
ASSIGN
       f-par-sum:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN tt-chk-doc.obj-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.pay-desk IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.shift-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.shift-name IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.shift-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.src-shift-date IN FRAME Dialog-Frame
   EXP-LABEL EXP-FORMAT                                                 */
/* SETTINGS FOR FILL-IN tt-chk-doc.z-number IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-par-chk-pay
/* Query rebuild information for BROWSE br-par-chk-pay
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt-par-chk-pay WHERE
        tt-par-chk-pay.doc-code = tt-chk-doc.doc-code
    AND tt-par-chk-pay.pay-code = tt-chk-pay.pay-code
    AND tt-par-chk-pay.curr-code = tt-chk-pay.curr-code


    INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE br-par-chk-pay */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH locked_c-chk-pay NO-LOCK WHERE
       locked_c-chk-pay.doc-code = tt-chk-doc.doc-code
    AND locked_c-chk-pay.chip-num = locked_c-chk-pay.chip-num,
    FIRST tt-chk-pay WHERE
        tt-chk-pay.doc-code = tt-chk-doc.doc-code
    AND tt-chk-pay.line-num = locked_c-chk-pay.line-num.
     _END_FREEFORM
     _JoinCode[1]      = "locked_c-chk-pay.doc-code = Temp-Tables.tt-chk-doc.doc-code"
     _Query            is OPENED
*/  /* BROWSE BR-lines */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "Temp-Tables.tt-chk-doc"
     _Options          = "SHARE-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ANY-KEY OF FRAME Dialog-Frame /* Чек МЦ */
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Чек МЦ */
DO:
   apply "choose" to B-quit in frame {&frame-name}.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Чек МЦ */
DO:
   p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
      run reposition-c-chk-doc in this-procedure
  (input 'next':U
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
     run reposition-c-chk-doc in this-procedure
  (input 'prev':U
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
{ gbl/stdbtn.i }
define variable glog as logical no-undo .
  DO TRANSACTION ON ERROR UNDO, LEAVE :
    p-doc-rec = ?.
    p-next-prev = "QUIT".
  END. /* TRANSACTION */
  p-next-prev = "QUIT".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-lines
&Scoped-define SELF-NAME BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-lines Dialog-Frame
ON VALUE-CHANGED OF BR-lines IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-br-par-chk-pay}
  run get-sums IN THIS-PROCEDURE ( INPUT tt-chk-pay.pay-code, input tt-chk-pay.curr-code) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.chk-type Dialog-Frame
ON VALUE-CHANGED OF tt-chk-doc.chk-type IN FRAME Dialog-Frame
DO:
   { gbl/stdbtn.i }
  IF CAN-FIND(FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
  OR CAN-FIND(FIRST tt-par-chk-pay WHERE tt-par-chk-pay.doc-code = tt-chk-doc.doc-code)
      THEN DO:
      MESSAGE
      "Установить тип чека можно только в самом начале процесса создания чека" SKIP
      "когда еще не созданы строки"
      VIEW-AS ALERT-BOX ERROR.
      display tt-chk-doc.chk-type
      with frame {&frame-name} .
      RETURN NO-APPLY.
  END.
  ASSIGN
  tt-chk-doc.chk-type.
  locked_c-chk-doc.chk-type = tt-chk-doc.chk-type.
  RUN enable-disable-par-chk-pay IN THIS-PROCEDURE .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-par-chk-pay
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
p-next-prev = "".
n-p:
do while p-next-prev = "":U:
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    assign
    v-first-mode = par-mode
    .
    if not par-mode = {&lookup} then
    p-next-prev = "QUIT".
  assign
  shop-type =   p-obj-type
  shop-code = p-obj-code
  .
  { str/get-chkc.i run shop-type shop-code }
  run get-params in this-procedure ( input shop-type, input shop-code) no-error.
  if error-status:error then return error.
  Run fill-tables in this-procedure no-error.
  if error-status:error then return error.
  RUN MyEnable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
RUN disable_UI in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-time Dialog-Frame
PROCEDURE check-time :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter parscreen-value as integer no-undo.
define input parameter par-mode as character no-undo.
define variable var-limit as integer no-undo.
CASE par-mode:
    when "hour":U then do:
         var-limit = 23.
    end.
    when "min":U then do:
          var-limit = 59.
    end.
    when "sec" then do:
          var-limit = 59.
    end.
END.

  if int(parscreen-value) > var-limit then do:
    bell.
    Message "Неверное время!" view-as alert-box ERROR.
    return error.
  end.
  run find-curs in this-procedure (
                                    input date(tt-chk-doc.chk-date:screen-value in frame {&frame-name})
                                    ,input (integer(fhour:screen-value) * 3600 + integer(fmin:screen-value) * 60) + integer(fsec:screen-value)
                                    ,output varbase-curs) no-error.
 if error-status:error then return error.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE control-line Dialog-Frame
PROCEDURE control-line :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER locked-title as logical no-undo.
IF CAN-FIND(FIRST ub.chk-pay No-LOCK WHERE
                  ub.chk-pay.doc-code = tt-chk-doc.doc-code) then
locked-title = yes.
else locked-title = no.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-disable-par-chk-pay Dialog-Frame
PROCEDURE enable-disable-par-chk-pay :
IF tt-chk-doc.chk-type = INTEGER({&cd-drawer}) THEN DO:
   DISPLAY
   br-par-chk-pay
   f-par-sum
   WITH FRAME {&FRAME-NAME}.
   br-lines:HEIGHT-CHARS = 5.5.
   APPLy "ENTRY" to br-par-chk-pay.
   apply "VAlue-changed" to br-par-chk-pay.
END.
ELSE DO:
    hide
    br-par-chk-pay
    f-par-sum
    IN FRAME {&FRAME-NAME}.
    br-lines:HEIGHT-CHARS = 11.

END.
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
  DISPLAY fhour fmin fsec f-par-sum
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.obj-code tt-chk-doc.chk-type
          tt-chk-doc.pay-desk tt-chk-doc.src-shift-date tt-chk-doc.shift-date
          tt-chk-doc.cashier tt-chk-doc.shift-name tt-chk-doc.shift-num
          tt-chk-doc.chk-num tt-chk-doc.cash-rate tt-chk-doc.z-number
          tt-chk-doc.PS
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-prev B-next B-Help tt-chk-doc.chk-date tt-chk-doc.obj-code
         tt-chk-doc.chk-type fhour fmin fsec tt-chk-doc.pay-desk
         tt-chk-doc.src-shift-date tt-chk-doc.shift-date tt-chk-doc.cashier
         tt-chk-doc.shift-name tt-chk-doc.shift-num tt-chk-doc.chk-num
         tt-chk-doc.cash-rate tt-chk-doc.z-number BR-lines br-par-chk-pay f-par-sum
         tt-chk-doc.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable v-first-cashier as integer no-undo .
define variable v-first-seller as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

for each tt-chk-doc:
    delete tt-chk-doc.
end.
for each tt-chk-pay:
    delete tt-chk-pay.
end.
for each tt-par-chk-pay:
    delete tt-par-chk-pay.
end.
FIND FIRST locked_c-chk-doc NO-LOCK WHERE
            recid(locked_c-chk-doc) = p-doc-rec.
IF NOT AVAIL locked_c-chk-doc then
return error.
if locked_c-chk-doc.out-code <> '':U and par-mode <> {&lookup} then do:
  message
  "Чек МЦ с N" locked_c-chk-doc.doc-code  "включен в документ МЦ" SKIP
  "Изменения не допускаются"
  view-as alert-box error.
  return error.
end.
assign
p-obj-type = locked_c-chk-doc.obj-type
p-obj-code = locked_c-chk-doc.obj-code
.

run get-environment in this-Procedure no-error.
if error-status:error then return error.

create tt-chk-doc.
buffer-copy locked_c-chk-doc to tt-chk-doc.
if gbclcode-is-this-db-role ( input {&role-cashier}, input vardb-num, input tt-chk-doc.cashier, input tt-chk-doc.chk-date) = 0 then do:
  message
  "В справочнике нет кассира" tt-chk-doc.cashier
  view-as alert-box WARNING.
end.
FIND FIRST buf_cash-desk where
          buf_cash-desk.db-num = vardb-num and
          buf_cash-desk.obj-code = p-obj-code AND
          buf_cash-desk.cash-num = tt-chk-doc.pay-desk no-error.
if not available buf_cash-desk then dO:
  message
  "В справочнике нет кассы" tt-chk-doc.pay-desk
  view-as alert-box error.
end.
for each locked_c-chk-pay no-lock where
          locked_c-chk-pay.doc-code = tt-chk-doc.doc-code
      and locked_c-chk-pay.chip-num = locked_c-chk-doc.chip-num   :
      create tt-chk-pay.
      buffer-copy locked_c-chk-pay to tt-chk-pay.
  end.
  for each locked-par_c-chk-pay no-lock where
          locked-par_c-chk-pay.doc-code = tt-chk-doc.doc-code
      and locked-par_c-chk-pay.chip-num = locked_c-chk-doc.chip-num   :
      create tt-par-chk-pay.
      buffer-copy locked-par_c-chk-pay to tt-par-chk-pay
      .
  end.
  for each locked_c-chk-doc-attr no-lock where
          locked_c-chk-doc-attr.doc-code = tt-chk-doc.doc-code
      and locked_c-chk-doc-attr.chip-num = locked_c-chk-doc.chip-num  :
      create tt-chk-doc-attr.
      buffer-copy locked_c-chk-doc-attr to tt-chk-doc-attr.

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-curs Dialog-Frame
PROCEDURE find-curs :
DEFINE INPUT PARAMETER par-date as date no-undo.
DEFINE INPUT PARAMETER par-time as integer no-undo.
DEFINE output PARAMETER parbase-curs as decimal no-undo.

DEFINE BUFFER buf_curr-shop FOR ub.curr-shop .

IF varbase-code <> 0 then do:
    FIND LAST buf_curr-shop NO-LOCK Where
                         buf_curr-shop.obj-type = p-obj-type AND
                buf_curr-shop.obj-code  = p-obj-code AND
                buf_curr-shop.curr-code = varbase-code AND
               ( ( buf_curr-shop.exch-date = par-date AND
               buf_curr-shop.exch-time <= par-time ) OR
               buf_curr-shop.exch-date < par-date ) NO-ERROR .
    IF NOT AVAIL buf_curr-shop then do:
        message
        "Нет магазинного курса базовой валюты на дату и время чека!" skip
         " - дата " string(par-date, "99/99/9999")
        " время - " string(par-time, "hh:mm") view-as alert-box ERROR.
       return error.
    end.
    parbase-curs = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale.
END.
else parbase-curs = 1.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE find-uchet-date Dialog-Frame
PROCEDURE find-uchet-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
tt-chk-doc.src-shift-date = if (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
                              then tt-chk-doc.src-shift-date
                              else tt-chk-doc.chk-date
tt-chk-doc.shift-date = if t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
                          then (tt-chk-doc.chk-date - 1)
                          else tt-chk-doc.src-shift-date
.
display
tt-chk-doc.shift-date
with frame {&frame-name}.
run find-curs in this-procedure (
                                      input tt-chk-doc.chk-date
                                     ,input tt-chk-doc.chk-time
                                     ,output cash-rate_
                                     ) no-error.
 if error-status:error then return error.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-environment Dialog-Frame
PROCEDURE get-environment :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  FIND FIRST buf_obj No-LOCK WHERE
                buf_obj.obj-type = p-obj-type and
                buf_obj.obj-code = p-obj-code No-ERROR.
if not avail buf_obj or p-obj-type <> {&shop} then do:
    message vss-workfile vss-revision vss-description skip
    "Неверный параметр вызова p-obj-type и/или p-obj-code" p-obj-type p-obj-code
    view-as alert-box ERROR.
    return.
end.
vardb-num = buf_obj.db-num.
FIND FIRST ub.shop No-LOCK WHERE
                         ub.shop.obj-code = p-obj-code No-ERROR.
        if not available shop then do:
            message "Не найден магазин с кодом" p-obj-code
            view-as alert-box ERROR.
            return error.
        end.
FIND FIRSt ub.sysconf No-LOCK WHERE
                        ub.sysconf.host-code = ub.shop.host-code No-ERROR.
        if not available ub.sysconf then do:
            message "Не найдена фирма с кодом" ub.shop.host-code
            view-as alert-box ERROR.
            return error.
        end.
        assign
        varbase-code = ub.sysconf.base-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-params Dialog-Frame
PROCEDURE get-params :
DEFINE INPUT PARAMETER p-obj-type like ub.clients.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code like ub.clients.obj-code no-undo.
  /*найдем параметр - тип кассы по умолчанию*/
{ gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd }
get-chkc_context.pos-type = dflt-cd.
get-chkc_context.p-log-handle = this-procedure:handle.

if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
  message
  "Внимание! На текущем объекте требуется использование смен" skip
  "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
  view-as alert-box ERROR.
  return ERROR.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-sums Dialog-Frame
PROCEDURE get-sums :
DEFINE INPUT PARAMETER p-pay-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-curr-code AS INTEGER NO-UNDO.

DEFINE BUFFER buf-tt-par-chk-pay FOR tt-par-chk-pay.
f-par-sum = 0.
FOR EACH  buf-tt-par-chk-pay NO-LOCK WHERE
        buf-tt-par-chk-pay.doc-code = tt-chk-doc.doc-code
    AND buf-tt-par-chk-pay.pay-code = p-pay-code
        AND buf-tt-par-chk-pay.curr-code = p-curr-code:

   ASSIGN
   f-par-sum = f-par-sum + buf-tt-par-chk-pay.par-val * buf-tt-par-chk-pay.doc-qnty
   .
END.
IF br-par-chk-pay:VISIBLE IN FRAME {&FRAME-NAME} = YES THEN DO:
    DISPLAY
    f-par-sum
    WITH FRAME {&FRAME-NAME}.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lock-proc Dialog-Frame
PROCEDURE lock-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER locked-title as logical no-undo.
if locked-title then do:
    DISABLE
    fhour fmin fsec
    tt-chk-doc.cash-rate
    tt-chk-doc.chk-date
    tt-chk-doc.chk-type
    with frame {&frame-name}
    .
end.
else do:
    if par-mode <> {&lookup} then
    ENABLE
    fhour when par-mode = {&add-def}
    fmin when par-mode = {&add-def}
    fsec when par-mode = {&add-def}
    tt-chk-doc.cash-rate when par-mode = {&add-def}
    tt-chk-doc.chk-date when par-mode = {&add-def}
    tt-chk-doc.chk-type when par-mode = {&add-def}
    tt-chk-doc.src-shift-date  when (get-chkc_context.cas-shft and not  get-chkc_context.SHiFT-on)
    tt-chk-doc.shift-name when (get-chkc_context.cas-shft and not  get-chkc_context.SHiFT-on)
    with frame {&frame-name}
    .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
define variable var-dopi as integer no-undo.
 tt-chk-doc.chk-type:Radio-buttons in frame {&frame-name} =
 "{&bef-encashment-full}" + {&comma-char} + string({&encashment}) + {&comma-char} +
 "{&bef-cd-fund-full}" + {&comma-char} + string({&cd-fund}) + {&comma-char} +
 "{&bef-pay-transfer-full}" + {&comma-char} + string({&pay-transfer}) + {&comma-char} +
 "{&bef-cd-expense-full}" + {&comma-char} + string({&cd-expense}) + {&comma-char} +
 "{&bef-cd-drawer-full}" + {&comma-char} + string({&cd-drawer})
 .
if get-chkc_context.cas-curs then
assign
tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = no
tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = no
tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = no
.
else
assign
tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
.
assign
fhour = (tt-chk-doc.chk-time - tt-chk-doc.chk-time MODULO 3600) / 3600
var-dopi = tt-chk-doc.chk-time MODULO 3600
fmin =  (var-dopi - var-dopi modulo 60) / 60
var-dopi = var-dopi modulo 60
fsec = (var-dopi - var-dopi modulo 60) / 60
.
IF AVAILABLE tt-chk-doc THEN
DISPLAY
fhour
fmin
fsec
tt-chk-doc.cash-rate
tt-chk-doc.cash-scale
tt-chk-doc.chk-date
tt-chk-doc.obj-code
tt-chk-doc.chk-type
tt-chk-doc.src-shift-date
tt-chk-doc.shift-date
tt-chk-doc.pay-desk
tt-chk-doc.shift-num
tt-chk-doc.shift-name
tt-chk-doc.cashier
tt-chk-doc.z-number
tt-chk-doc.chk-num
tt-chk-doc.ps
WITH FRAME {&frame-name} .
ASSIGN
tt-chk-pay.tot-sum:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.pay-code:READ-ONLY IN BROWSE BR-lines = yes
tt-chk-pay.curr-code:READ-ONLY IN BROWSE BR-lines = yes
tt-par-chk-pay.doc-qnty:READ-ONLY IN BROWSE BR-par-chk-pay = yes
.
b-quit:label = "&Выход".
ENABLE
b-quit
B-Help
b-next
b-prev
BR-lines
br-par-chk-pay
WITH FRAME {&frame-name} .
VIEW FRAME {&frame-name} .
run control-line in this-procedure ( output locked-title).
run lock-proc in this-procedure ( locked-title).
if not cas-shft then do:
  hide
  tt-chk-doc.src-shift-date
  tt-chk-doc.shift-num
  tt-chk-doc.shift-name
  in frame {&frame-name}.
end.
RUN enable-disable-par-chk-pay IN THIS-PROCEDURE .
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-lines TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY":U TO br-lines IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" to br-lines in frame {&frame-name} .
ASSIGN
frame {&frame-name}:title =
                          substitute("ЧЕК № &1 Дата: &2 Время: &3"
                                      ,tt-chk-doc.doc-code
                                      ,tt-chk-doc.chk-date
                                      ,string (tt-chk-doc.chk-time, "HH:MM")) +
                          if (cas-shft OR T-SHFT <> 0)
                          then substitute(" Смена от &1 N смены &2&3"
                                          ,string(tt-chk-doc.src-shift-date, "99/99/9999")
                                          ,tt-chk-doc.shift-name
                                          , (if integer(tt-chk-doc.shift-name) = tt-chk-doc.shift-num
                                              then '':U
                                              else string(tt-chk-doc.shift-num, "(>9)"))
                                          )
                          else substitute("Дата учета &1", string(tt-chk-doc.shift-date))
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-c-chk-doc Dialog-Frame
PROCEDURE reposition-c-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-c-chk-doc-recid as recid no-undo .


do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-c-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-chk-doc-recid
      ).

    if v-new-c-chk-doc-recid <> ?
    then do:
      define buffer buf_c-chk-doc for ub.c-chk-doc .
      find first buf_c-chk-doc no-lock
        where recid(buf_c-chk-doc) = v-new-c-chk-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-c-chk-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список чеков МЦ не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-and-file Dialog-Frame
PROCEDURE write-log-and-file :
define input parameter p-tab-position   as integer   no-undo.
define input parameter p-file-name      as character no-undo .
define input parameter p-log-level      as integer no-undo .
define input parameter p-log-string     as character no-undo .
message
p-log-string
view-as alert-box error .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-cash-pay Dialog-Frame
FUNCTION get-cash-pay RETURNS CHARACTER
  ( input parpay-code as integer, parcurr-code as integer, OUTPUT p-wth-code AS INTEGER ) :
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_wealth FOR ub.wealth.
FIND FIRST buf_cash-pay No-LOCK WHERE
         buf_cash-pay.cdpay-code = parpay-code
    AND buf_cash-pay.curr-code = parcurr-code No-ERROR.
if available buf_cash-pay then do:
  varwth-code = buf_cash-pay.wth-code.
  p-wth-code = varwth-code.

  if varwth-code > 0 then do:
      FIND FIRST buf_wealth No-LOCK WHERE
                      buf_wealth.wth-code = varwth-code No-error.
      if available buf_wealth then do:
        assign
        varwth-code = buf_wealth.wth-code
        varwth-name = buf_wealth.wth-name
        p-wth-code = varwth-code
        .
        return buf_cash-pay.obj-name.
      end.
      else do:
        assign
        varwth-code = 0
        varwth-name = "Неопознанная МЦ"
        p-wth-code = varwth-code
        .
        RETURN buf_cash-pay.obj-name.   /* Function return value. */
      end.
  end.
  else do:
    assign
    varwth-code = 0
    varwth-name = "Неопознанная МЦ"
    p-wth-code = varwth-code
    .
    RETURN buf_cash-pay.obj-name .   /* Function return value. */
  end.
end.
assign
varwth-code = 0
varwth-name = '':U
p-wth-code = varwth-code
.
RETURN "Неопознанная оплата".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME