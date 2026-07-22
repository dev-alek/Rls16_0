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
DEFINE BUFFER locked_chk-doc FOR ub.chk-doc.
DEFINE BUFFER locked_chk-doc-attr FOR ub.chk-doc-attr.
DEFINE BUFFER locked_chk-pay FOR ub.chk-pay.
DEFINE BUFFER sales-man FOR ub.person.
DEFINE NEW SHARED TEMP-TABLE tt-chk-doc NO-UNDO LIKE ub.chk-doc.
DEFINE TEMP-TABLE tt-chk-doc-attr NO-UNDO LIKE ub.chk-doc-attr.
DEFINE NEW SHARED TEMP-TABLE tt-chk-pay NO-UNDO LIKE ub.chk-pay.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чек МЦ: добавление, изменение, просмотр

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
define INPUT parameter p-call-prog as handle no-undo .
define input-output parameter p-next-prev as character no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "чек МЦ: добавление, изменение, просмотр":U.
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
{ gbl/getcntxt.i def }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-lines

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES locked_chk-pay tt-chk-pay tt-chk-doc

/* Definitions for BROWSE BR-lines                                      */
&Scoped-define FIELDS-IN-QUERY-BR-lines tt-chk-pay.line-num tt-chk-pay.pay-code tt-chk-pay.curr-code get-cash-pay(tt-chk-pay.pay-code, tt-chk-pay.curr-code, OUTPUT for-wth-code) varwth-code tt-chk-pay.tot-sum varwth-name tt-chk-pay.cash-rate tt-chk-pay.bank-rate tt-chk-pay.bank-scale tt-chk-pay.doc-qnty tt-chk-pay.src-qnty tt-chk-pay.par-val tt-chk-pay.src-val tt-chk-pay.par-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-lines tt-chk-pay.pay-code tt-chk-pay.curr-code tt-chk-pay.src-qnty tt-chk-pay.src-val tt-chk-pay.tot-sum tt-chk-pay.cash-rate tt-chk-pay.bank-rate tt-chk-pay.bank-scale
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-lines tt-chk-pay
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-lines tt-chk-pay
&Scoped-define SELF-NAME BR-lines
&Scoped-define QUERY-STRING-BR-lines FOR EACH locked_chk-pay NO-LOCK WHERE        locked_chk-pay.doc-code = tt-chk-doc.doc-code, ~
           FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_chk-pay.line-num
&Scoped-define OPEN-QUERY-BR-lines OPEN QUERY {&SELF-NAME} FOR EACH locked_chk-pay NO-LOCK WHERE        locked_chk-pay.doc-code = tt-chk-doc.doc-code, ~
           FIRST tt-chk-pay WHERE         tt-chk-pay.doc-code = tt-chk-doc.doc-code     AND tt-chk-pay.line-num = locked_chk-pay.line-num.
&Scoped-define TABLES-IN-QUERY-BR-lines locked_chk-pay tt-chk-pay
&Scoped-define FIRST-TABLE-IN-QUERY-BR-lines locked_chk-pay
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
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-prev B-next B-hist B-Help ~
fhour fmin fsec b-cd B-add B-del BR-lines
&Scoped-Define DISPLAYED-FIELDS tt-chk-doc.chk-date tt-chk-doc.obj-code ~
tt-chk-doc.chk-type tt-chk-doc.pay-desk tt-chk-doc.src-shift-date ~
tt-chk-doc.shift-date tt-chk-doc.cashier tt-chk-doc.shift-name ~
tt-chk-doc.shift-num tt-chk-doc.chk-num tt-chk-doc.cash-rate ~
tt-chk-doc.z-number tt-chk-doc.PS
&Scoped-define DISPLAYED-TABLES tt-chk-doc
&Scoped-define FIRST-DISPLAYED-TABLE tt-chk-doc
&Scoped-Define DISPLAYED-OBJECTS fhour fmin fsec

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
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON b-cd
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

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

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fhour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.9 BY 1 NO-UNDO.

DEFINE VARIABLE fmin AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.9 BY 1 NO-UNDO.

DEFINE VARIABLE fsec AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 2.9 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-lines FOR
      locked_chk-pay,
      tt-chk-pay SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      tt-chk-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
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
tt-chk-pay.doc-qnty FORMAT "->>,>>>,>>9.<<<":U column-label "Кол-во!в БД"
tt-chk-pay.src-qnty FORMAT "->>,>>>,>>9.<<<":U column-label "Кол-во!в чеке"
tt-chk-pay.par-val FORMAT ">>>>>9":U column-label "Номинал!в БД"
tt-chk-pay.src-val FORMAT ">>>>>9":U column-label "Номинал!в чеке"
tt-chk-pay.par-code column-label "Код!номинала" format ">>9"
ENABLE
tt-chk-pay.pay-code
tt-chk-pay.curr-code
tt-chk-pay.src-qnty
tt-chk-pay.src-val
tt-chk-pay.tot-sum
tt-chk-pay.cash-rate
tt-chk-pay.bank-rate
tt-chk-pay.bank-scale
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 98 BY 11.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-prev AT ROW 1 COL 41
     B-next AT ROW 1 COL 45
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-chk-doc.chk-date AT ROW 2.33 COL 11.3 COLON-ALIGNED
          LABEL "Дата чека"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-chk-doc.obj-code AT ROW 2.33 COL 55 COLON-ALIGNED
          LABEL "N магазина"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
     tt-chk-doc.chk-type AT ROW 2.43 COL 72.4 NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2
          SIZE 20.8 BY 3.27
     fhour AT ROW 3.63 COL 11.4 COLON-ALIGNED NO-LABEL
     fmin AT ROW 3.63 COL 15.5 COLON-ALIGNED NO-LABEL
     fsec AT ROW 3.63 COL 19.6 COLON-ALIGNED NO-LABEL
     tt-chk-doc.pay-desk AT ROW 3.63 COL 55 COLON-ALIGNED
          LABEL "N кассы"
          VIEW-AS FILL-IN
          SIZE 5.3 BY 1
     b-cd AT ROW 3.67 COL 63 WIDGET-ID 2
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
          SIZE 4.1 BY 1
     tt-chk-doc.chk-num AT ROW 6 COL 55 COLON-ALIGNED format "99999999999"
          LABEL "N по кассе"
          VIEW-AS FILL-IN
          SIZE 10.9 BY 1
     tt-chk-doc.cash-rate AT ROW 6 COL 85 COLON-ALIGNED
          LABEL "Курс нац. вал."
          VIEW-AS FILL-IN
          SIZE 11.4 BY 1
     tt-chk-doc.z-number AT ROW 7.2 COL 55 COLON-ALIGNED
          LABEL "z-отчет"
          VIEW-AS FILL-IN
          SIZE 10.8 BY 1
     B-add AT ROW 7.43 COL 79.5
     B-del AT ROW 7.43 COL 89.5
     BR-lines AT ROW 8.5 COL 1.6
     tt-chk-doc.PS AT ROW 19.77 COL 1.3 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98.6 BY 2.27
     ":" VIEW-AS TEXT
          SIZE .8 BY 1.07 AT ROW 3.7 COL 20.4
     "Время:" VIEW-AS TEXT
          SIZE 10.3 BY 1 AT ROW 3.63 COL 2
     ":" VIEW-AS TEXT
          SIZE .8 BY 1.07 AT ROW 3.7 COL 16.4
     "Тип чека" VIEW-AS TEXT
          SIZE 11.8 BY .83 AT ROW 1.47 COL 72.3
     SPACE(16.27) SKIP(19.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Чек МЦ"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


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
      TABLE: locked_chk-doc B "?" ? ub chk-doc
      TABLE: locked_chk-doc-attr B "?" ? ub chk-doc-attr
      TABLE: locked_chk-pay B "?" ? ub chk-pay
      TABLE: sales-man B "?" ? ub person
      TABLE: tt-chk-doc T "NEW SHARED" NO-UNDO ub chk-doc
      TABLE: tt-chk-doc-attr T "?" NO-UNDO ub chk-doc-attr
      TABLE: tt-chk-pay T "NEW SHARED" NO-UNDO ub chk-pay
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-lines B-del Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tt-chk-doc.cash-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.cashier IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.chk-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-chk-doc.chk-num IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
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

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-lines
/* Query rebuild information for BROWSE BR-lines
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH locked_chk-pay NO-LOCK WHERE
       locked_chk-pay.doc-code = tt-chk-doc.doc-code,
    FIRST tt-chk-pay WHERE
        tt-chk-pay.doc-code = tt-chk-doc.doc-code
    AND tt-chk-pay.line-num = locked_chk-pay.line-num.
     _END_FREEFORM
     _JoinCode[1]      = "locked_chk-pay.doc-code = Temp-Tables.tt-chk-doc.doc-code"
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


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
  run proc-b-add in this-procedure no-error.
  if error-status:error THEN return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd Dialog-Frame
ON CHOOSE OF b-cd IN FRAME Dialog-Frame /* Btn 1 */
DO:
  run sel-cd in this-procedure no-error.
  if error-status:error then return no-apply.
  else do:
    assign
    tt-chk-doc.pay-desk = buf_cash-desk.cash-num
    .
    display
    tt-chk-doc.pay-desk
    with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
  APPLY "DELETE-CHARACTER" to br-lines.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
{ gbl/stdbtn.i }
  if par-mode = {&lookup} then.
  else do:
    run check-this-check in this-procedure no-error.
    if error-status:error then do:
      return no-apply.
    end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
define variable v-rid-list as character no-undo .
    if available locked_chk-doc THEN
    run str/cchkdocs.w (
                        input parparentproc
                       ,input "":U /*bttns*/
                       ,input "one":U
                       ,input locked_chk-doc.doc-code
                       ,input p-obj-type
                       ,input p-obj-code
                       ,input-output v-rid-list
                    ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
   run reposition-chk-doc in this-procedure
  (input 'next':U
  ).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
   run reposition-chk-doc in this-procedure
  (input 'prev':U
  ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отмена */
DO:
{ gbl/stdbtn.i }
define variable glog as logical no-undo .
   IF par-mode = {&add-def} THEN DO:
    IF CAN-FIND( FIRST ub.chk-pay NO-LOCK WHERE
                       ub.chk-pay.doc-code = tt-chk-doc.doc-code ) THEN DO:
      MESSAGE
        "Чек не будет сохранен, а вся введенная Вами информация будет потеряна!" SKIP
        "Для того, чтобы сохранить документ, нужно нажать кнопку ~"" +
        B-exit:LABEL IN FRAME {&FRAME-NAME} + "~"." SKIP( 1 )
        "Вы уверены, что хотите выйти БЕЗ СОХРАНЕНИЯ?" SKIP
        "YES[ДА] - Выйти БЕЗ СОХРАНЕНИЯ;" SKIP
        "NO[НЕТ] - Остаться в документе."
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
      TITLE "Выход из чека без сохранения" UPDATE glog.
      IF glog = NO THEN DO:
        RETURN NO-APPLY.
      END.
    END.
    DO TRANSACTION ON ERROR UNDO, LEAVE :
      case par-mode:
        when {&add-def} then do:
          if available locked_chk-doc then
          delete locked_chk-doc.
          p-doc-rec = ?.
        end.
      END CASE.
      p-doc-rec = ?.
      p-next-prev = ?.
    END. /* TRANSACTION */
  END.
  p-next-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-lines
&Scoped-define SELF-NAME BR-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-lines Dialog-Frame
ON DELETE-CHARACTER OF BR-lines IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
if par-mode <> {&add-def} then return no-apply.
glog = yes.
message
"Удалить строчку из чека ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.
FIND FIRST locked_chk-pay where
      locked_chk-pay.doc-code = tt-chk-pay.doc-code
  AND locked_chk-pay.line-num = tt-chk-pay.line-num.
DELETE tt-chk-pay.
delete locked_chk-pay.
{&OPEN-QUERY-br-lines}
run control-line in this-procedure ( output locked-title).
run lock-proc in this-procedure ( input locked-title).
APPLY "entry" TO br-lines.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.chk-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.chk-type Dialog-Frame
ON VALUE-CHANGED OF tt-chk-doc.chk-type IN FRAME Dialog-Frame
DO:
   { gbl/stdbtn.i }
  IF CAN-FIND(FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
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
  locked_chk-doc.chk-type = tt-chk-doc.chk-type.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fhour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fhour Dialog-Frame
ON LEAVE OF fhour IN FRAME Dialog-Frame
DO:
  run check-time in this-procedure ( input fhour:screen-value, input "hour":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fmin
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fmin Dialog-Frame
ON LEAVE OF fmin IN FRAME Dialog-Frame
DO:
  run check-time in this-procedure ( input fmin:screen-value, input "min":U) no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fsec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fsec Dialog-Frame
ON LEAVE OF fsec IN FRAME Dialog-Frame
DO:
    run check-time in this-procedure ( input fsec:screen-value, input "sec":U)  no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.shift-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.shift-name Dialog-Frame
ON LEAVE OF tt-chk-doc.shift-name IN FRAME Dialog-Frame /* № */
DO:
    define variable v-dopi as integer no-undo .
  define variable v-old-shift-name as character no-undo .
    assign
    v-old-shift-name = tt-chk-doc.shift-name
    tt-chk-doc.shift-name
    .
    assign
    v-dopi = integer(tt-chk-doc.shift-name) no-error .
    if error-status:error
    or v-dopi < 0
    or v-dopi > 99 then do:
      message
      "Неверное значение № смены"
      view-as alert-box error .
      tt-chk-doc.shift-name = v-old-shift-name .
      display
      tt-chk-doc.shift-name
      with frame {&frame-name} .
      return no-apply.
    end.
    display
    v-dopi @ tt-chk-doc.shift-num
    with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-chk-doc.src-shift-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-chk-doc.src-shift-date Dialog-Frame
ON LEAVE OF tt-chk-doc.src-shift-date IN FRAME Dialog-Frame /* Дата смены */
DO:
   assign
  tt-chk-doc.src-shift-date.
  run find-uchet-date in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
ON LEAVE OF tt-chk-pay.tot-sum IN BROWSE br-lines,
            tt-chk-pay.pay-code IN BROWSE br-lines,
            tt-chk-pay.curr-code IN BROWSE br-lines DO:
define variable old-sum      like tt-chk-pay.tot-sum no-undo .
define variable old-pay-code like tt-chk-pay.pay-code no-undo .
define variable old-curr-code like tt-chk-pay.curr-code no-undo .
define variable old-src-qnty like tt-chk-pay.src-qnty no-undo .
define variable old-src-val like tt-chk-pay.src-val no-undo .

DEFINE VARIABLE varopl-curs as decimal no-undo .
DEFINE VARIABLE varbase-curs as decimal no-undo .
define buffer buf_wth-par for ub.wth-par.


if avail tt-chk-pay then DO:
assign
old-sum      = tt-chk-pay.tot-sum
old-pay-code = tt-chk-pay.pay-code
old-curr-code = tt-chk-pay.curr-code
old-src-qnty = tt-chk-pay.src-qnty
old-src-val = tt-chk-pay.src-val

.

assign
tt-chk-pay.tot-sum = decimal(tt-chk-pay.tot-sum:screen-value in browse br-lines)
tt-chk-pay.pay-code = integer(tt-chk-pay.pay-code:screen-value in browse br-lines)
tt-chk-pay.curr-code = decimal(tt-chk-pay.curr-code:screen-value in browse br-lines    )
tt-chk-pay.src-qnty = decimal(tt-chk-pay.src-qnty:screen-value in browse br-lines    )
tt-chk-pay.src-val = integer(tt-chk-pay.src-val:screen-value in browse br-lines    )
.
FIND FIRST LOCKED_chk-pay NO-LOCK WHERE
          LOCKED_chk-pay.doc-code = tt-chk-doc.doc-code
     AND  LOCKED_chk-pay.line-num = tt-chk-pay.line-num.

run trg/chkins02.p (
              input  tt-chk-doc.doc-code
             ,input  1 /*товарный чек - 0 или чек МЦ  - 1*/
             ,input  tt-chk-doc.chk-type
             ,input  tt-chk-doc.obj-type
             ,input  tt-chk-doc.obj-code
             ,input  tt-chk-doc.chk-date
             ,input  tt-chk-doc.chk-time
             ,input  tt-chk-pay.pay-code
             ,input  tt-chk-pay.curr-code
             ,input  varbase-code
             ,input  get-chkc_context.r-b
             ,input  get-chkc_context.cas-curs
             ,input-output  tt-chk-pay.cash-rate
             ,input-output  tt-chk-pay.bank-rate
             ,input-output  tt-chk-pay.bank-scale
             ,input  recid(locked_chk-pay)
             ,output varbase-curs
             ,output varopl-curs
             ,output tt-chk-pay.par-code
           ) no-error.

  if error-status:error then do:
    assign
    tt-chk-pay.tot-sum        =   old-sum
    tt-chk-pay.pay-code   =   old-pay-code
    tt-chk-pay.curr-code  =   old-curr-code
    tt-chk-pay.src-qnty = old-src-qnty
    tt-chk-pay.src-val = old-src-val
    .
    display
    tt-chk-pay.tot-sum
    tt-chk-pay.pay-code
    tt-chk-pay.curr-code
    tt-chk-pay.src-qnty
    tt-chk-pay.src-val
    with browse br-lines.
  end.
 END.
end. /*of leave*/

ON RETURN OF tt-chk-pay.tot-sum IN BROWSE br-lines,
            tt-chk-pay.pay-code IN BROWSE br-lines,
            tt-chk-pay.curr-code IN BROWSE br-lines,
            tt-chk-pay.src-qnty IN BROWSE br-lines,
            tt-chk-pay.src-val IN BROWSE br-lines
            DO:
  APPLY "LEAVE" TO SELF.
END.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
p-next-prev = ''.
n-p:
do while p-next-prev = '':U:
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  if par-mode <> {&update} and par-mode <> {&add-def} and par-mode <> {&lookup} then do:
      message vss-workfile vss-revision vss-description skip
                  "Неверный параметр вызова par-mode"
      view-as alert-box ERROR.
      return error.
  end.
  assign
  v-first-mode = par-mode
  .
  if par-mode <> {&lookup} then do:
    p-next-prev = 'quit'.
  end.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-dublicate Dialog-Frame
PROCEDURE check-dublicate :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer dub_chk-doc for ub.chk-doc.
      FIND  dub_chk-doc where
            dub_chk-doc.obj-type = tt-chk-doc.obj-type and
            dub_chk-doc.obj-code = tt-chk-doc.obj-code and
            dub_chk-doc.chk-date = tt-chk-doc.chk-date and
            dub_chk-doc.pay-desk = tt-chk-doc.pay-desk and
            dub_chk-doc.chk-time = tt-chk-doc.chk-time and
            dub_chk-doc.chk-num = tt-chk-doc.chk-num and
            dub_chk-doc.sales-man = tt-chk-doc.sales-man NO-ERROR .
if available dub_chk-doc  and
recid(dub_chk-doc) <> recid(locked_chk-doc) then do:
    message
    "Уже есть чек" dub_chk-doc.doc-code      "по магазину" tt-chk-doc.obj-code "в котором"
    "дата" tt-chk-doc.chk-date SKIP
    "время" string(tt-chk-doc.chk-time, "HH:MM:SS":U)  SKIP
    "касса" tt-chk-doc.pay-desk SKIP
    "номер чека на кассе" tt-chk-doc.chk-num SKIP
    "продавец" tt-chk-doc.sales-man
    view-as alert-box ERROR.
    return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-manual Dialog-Frame
PROCEDURE check-manual :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if not can-find(first locked_chk-pay where locked_chk-pay.doc-code = tt-chk-doc.doc-code) then do:
  message
  "В чеке нет строк товаров и/или строк оплат" skip
  "Такой чек не может быть сохранен"
  view-as alert-box error .
  return error.
end.
if tt-chk-doc.pay-desk = 0 then do:
  message
  "Нельзя создать чек для кассы с номером 0"
  view-as alert-box error .
  return error .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-this-check Dialog-Frame
PROCEDURE check-this-check :
define variable v-num as integer no-undo.
define buffer loc_chk-pay for ub.chk-pay.
assign
mc-prev-code = tt-chk-doc.doc-code.
if par-mode = {&add-def} then do:
    run proc-save-doc in this-procedure ( input yes, input yes) no-error.
    if error-status:error then return error.
    run check-dublicate in this-procedure no-error.
    if error-status:error then return error.
    run check-manual in this-procedure no-error .
    if error-status:error then return error.
end.
run proc-save-doc in this-procedure  ( input yes, input yes) no-error.
if error-status:error then return error.
assign
locked_chk-doc.discnt = 0
locked_chk-doc.correct = yes
for-chk-type = "":U
.

/*перезаполнить некоторые (реляционные) поля chk-pay*/

for each loc_chk-pay where
            loc_chk-pay.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-pay.obj-code =   tt-chk-doc.obj-code
    loc_chk-pay.line-sign = (if tt-chk-doc.chk-type = integer({&encashment})
                                    or tt-chk-doc.chk-type =  integer({&cd-expense}
                                   )
                                  then (loc_chk-pay.tot-sum <= 0)
                                  else (loc_chk-pay.tot-sum >= 0)
                                  )
    loc_chk-pay.time-oper = (if par-mode = {&add-def}
                                          then tt-chk-doc.chk-time
                                          else loc_chk-pay.time-oper)
    .
End.
for each loc_chk-pay where
            loc_chk-pay.doc-code = tt-chk-doc.doc-code:
    assign
    loc_chk-pay.obj-code =   tt-chk-doc.obj-code
    loc_chk-pay.line-sign = (if tt-chk-doc.chk-type = integer({&encashment})
                                    or tt-chk-doc.chk-type =  integer({&cd-expense}
                                   )
                                  then (loc_chk-pay.tot-sum <= 0)
                                  else (loc_chk-pay.tot-sum >= 0)
                                  )
    loc_chk-pay.time-oper = (if par-mode = {&add-def}
                                          then tt-chk-doc.chk-time
                                          else loc_chk-pay.time-oper)
    .
End.
{ str/libchkvl_getwcheck.i
"buffer get-chkc_context:handle"
~{&update~}
par-mode
yes
yes
?
mc-prev-code
no-error
}
assign
p-view-log = (p-view-log or get-chkc_context.view-log)
.
if locked_chk-doc.correct = no then do:
  if par-mode = {&add-def} then do:
        run gbl/d-askw.w (
           input "Выход из режима создания чека МЦ" /* Заголовок окна */
          ,input "Созданный Вами чек является ошибочным" + {&new-line} /* Общее сообщение */
            + "Вы действительно хотите сделать это?" + {&new-line}
          ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                      /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                      /* второй символ - разделитель атрибутов в описании кнопок */
          ,input "Сохранить|Редактировать|Не сохранять" /* список названий кнопок  */
                                          /* каждая кнопка может иметь необязательный */
                                          /* список атрибутов, влияющих на поведение кнопки */
          ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|" /* список описаний кнопок */
               + "Продолжить редактирование и постараться исправить все ошибки в чеке|"
               + "Чек не будет сохранен"
          ,input 2 /* значение возвращаемое при нажатии enter */
          ,input 3 /* значение возвращаемое при нажатии escape */
          ,output v-num /* выбор пользователя */
          ).
        CASE v-num:
            when 2 then do:
                return error.
            end.
             when 3 then do:
                p-doc-rec = ?.
                delete locked_chk-doc .
                return.
             end.
        END CASE.
  end.
  else do:
    run gbl/d-askw.w (
       input "Выход из режима редактирования чека МЦ" /* Заголовок окна */
      ,input "Редактируемый Вами чек МЦ является ошибочным" + {&new-line} /* Общее сообщение */
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input "Сохр ошибочный|Редактировать" /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input "Чек будет сохранен как ошибочный и к нему можно будет вернуться для последующего редактирования|" /* список описаний кнопок */
            + "Постараться исправить все ошибки в чеке"
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 2 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).
      if v-num = 2 then return error.
  end.
end.
if par-mode = {&update} then
run trg/chk-doch.p (
                buffer locked_chk-doc
              , input yes
              , input no /*p-add*/
              , input no /*p-del*/
              , input-output v-chip-num
              , output v-is-update).
if par-mode = {&add-def} then do:
  run trg/chk-doch.p (
                  buffer locked_chk-doc
                , input no
                , input yes /*p-add*/
                , input no /*p-del*/
                , input-output v-chip-num
                , output v-is-update).
end.
if v-is-update or par-mode = {&add-def} then do:
  assign
  locked_chk-doc.PS = "!":U + (if index(locked_chk-doc.ps, "shift!") > 0 then "shift!" else '':U) +
                              (if index(locked_chk-doc.ps, "shift!") > 0
                              then substring(left-trim(locked_chk-doc.ps, "!"), 7)
                              else left-trim(locked_chk-doc.PS, "!":U))

  tt-chk-doc.PS = locked_chk-doc.pS
  .
  display
  tt-chk-doc.ps
  with frame {&frame-name} .
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY fhour fmin fsec
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-chk-doc THEN
    DISPLAY tt-chk-doc.chk-date tt-chk-doc.obj-code tt-chk-doc.chk-type
          tt-chk-doc.pay-desk tt-chk-doc.src-shift-date tt-chk-doc.shift-date
          tt-chk-doc.cashier tt-chk-doc.shift-name tt-chk-doc.shift-num
          tt-chk-doc.chk-num tt-chk-doc.cash-rate tt-chk-doc.z-number
          tt-chk-doc.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-prev B-next B-hist B-Help tt-chk-doc.chk-date
         tt-chk-doc.obj-code tt-chk-doc.chk-type fhour fmin fsec
         tt-chk-doc.pay-desk b-cd tt-chk-doc.src-shift-date
         tt-chk-doc.shift-date tt-chk-doc.cashier tt-chk-doc.shift-name
         tt-chk-doc.shift-num tt-chk-doc.chk-num tt-chk-doc.cash-rate
         tt-chk-doc.z-number B-add B-del BR-lines tt-chk-doc.PS
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
IF par-mode = {&add-def} then do:
   p-doc-rec = ?.
   run get-environment in this-Procedure no-error.
   if error-status:error then return error.
   /*получим buf_cash-desk выбором из списка!!! а то теперь у нас и autotank еще окторый может быть не dflt-cd!!!*/
    message
    "Выберите из списка кассу, для которой Вы хотите создать чек!"
    view-as alert-box.
    run sel-cd in this-procedure no-error.
    if error-status:error then do:
      undo, return error .
    end.

   run gbl/factdate.p (
                     INPUT        p-obj-type
                    ,INPUT        p-obj-code
                    ,INPUT-OUTPUT chk-date_
                    ,INPUT-OUTPUT chk-time_
                    ,INPUT-OUTPUT shift-date_
                    ,INPUT-OUTPUT shift-num_
                    ,input-output shift-name_
                    ,INPUT        YES
               ) NO-ERROR.

    IF ERROR-STATUS:ERROR THEN DO:
      return error.
    END.
    if shift-name_ = ? then do:
      shift-name_ = "":U.
    end.
    /*найдем курс базовой валюты кассы по отношению к национальной*/
    cash-scale_ = 1.
    run find-curs in this-procedure
                        (
                         input chk-date_
                        ,input chk-time_
                        ,output cash-rate_
                         )  no-error.
    if error-status:error then undo, return error .
    assign
    v-first-cashier = gbclcode-get-this-db-first-role ( input {&role-cashier}, input vardb-num, input ?) no-error .
    if v-first-cashier = 0 then do:
      message
      "В справочнике нет ни одного кассира для текущей БД" skip
      "невозможно создать чек"
      view-as alert-box error.
      return error.
    end.
    run cur-time in THIS-PROCEDURE ( output v-today, output v-time).
    DO TRANSACTION ON ERROR UNDO, RETURN ERROR:
      create tt-chk-doc.
      ASSIGN
      tt-chk-doc.chk-date = chk-date_
      tt-chk-doc.src-shift-date = (if shift-date_ = ? then chk-date_ else shift-date_)
      tt-chk-doc.shift-num  = shift-num_
      tt-chk-doc.shift-name = shift-name_
      tt-chk-doc.cashier   = v-first-cashier
      tt-chk-doc.sales-man   = v-first-seller
      tt-chk-doc.doc-code =   (if get-chkc_context.db-num = 0
                                then string(next-value(s-chk, {&db-name_schema} ))
                                else string( p-obj-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
      tt-chk-doc.obj-type = p-obj-type
      tt-chk-doc.obj-code = p-obj-code
      /*tt-chk-doc.cash-rate
      */
      tt-chk-doc.chk-num  = 1
      tt-chk-doc.chk-time  = v-time
      tt-chk-doc.chk-type  = integer({&encashment})
      tt-chk-doc.correct  = yes
      tt-chk-doc.pay-desk = buf_cash-desk.cash-num
      tt-chk-doc.cash-rate = if get-chkc_context.r-b = {&r-b-base}
                                  then cash-rate_
                                  else 1
      tt-chk-doc.cash-scale = if get-chkc_context.r-b = {&r-b-base}
                                        then cash-scale_
                                        else 1
      .

      create locked_chk-doc.
      buffer-copy tt-chk-doc to locked_chk-doc.
      assign
      .
  END. /*TRANSACTION*/
  FIND FIRST buf_obj No-LOCK WHERe
            buf_obj.obj-type = shop-type
        AND buf_obj.obj-code = shop-code No-ERROR.
end.
else do:
  if par-mode = {&lookup} then do:
    FIND FIRST locked_chk-doc NO-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.
  end.
  ELSE do:
    DO TRANSACTION
      ON ERROR UNDO, RETURN ERROR:
    FIND FIRST locked_chk-doc EXCLUSIVE-LOCK WHERE
                recid(locked_chk-doc) = p-doc-rec.

    END.
  END.
  IF NOT AVAIL locked_chk-doc then
  return error.
  if locked_chk-doc.out-code <> ?
  and par-mode <> {&lookup} then do:
    message
    "Чек МЦ с N" locked_chk-doc.doc-code  "включен в документ МЦ" SKIP
    "Изменения не допускаются"
    view-as alert-box error.
    return error.
  end.
  assign
  p-obj-type = locked_chk-doc.obj-type
  p-obj-code = locked_chk-doc.obj-code
  .

  run get-environment in this-Procedure no-error.
  if error-status:error then return error.

  create tt-chk-doc.
  buffer-copy locked_chk-doc to tt-chk-doc.
  if gbclcode-is-this-db-role ( input {&role-cashier}, input vardb-num, input tt-chk-doc.cashier, input tt-chk-doc.chk-date) = 0 then do:
    message
    "В справочнике нет кассира" tt-chk-doc.cashier
    view-as alert-box WARNING.
  end.
  FIND FIRST buf_cash-desk no-lock where
            buf_cash-desk.db-num = vardb-num and
            buf_cash-desk.obj-code = p-obj-code AND
            buf_cash-desk.cash-num = tt-chk-doc.pay-desk no-error.
  if not available buf_cash-desk then dO:
    message
    "В справочнике нет кассы" tt-chk-doc.pay-desk
    view-as alert-box error.
  end.
  for each locked_chk-pay where
           locked_chk-pay.doc-code = tt-chk-doc.doc-code no-lock:
        create tt-chk-pay.
        buffer-copy locked_chk-pay to tt-chk-pay.
    end.
    for each locked_chk-doc-attr no-lock where
           locked_chk-doc-attr.doc-code = tt-chk-doc.doc-code:
        create tt-chk-doc-attr.
        buffer-copy locked_chk-doc-attr to tt-chk-doc-attr.

    end.
end. /*lookup update*/
if not par-mode = {&lookup} then do:
  if par-mode = {&add-def}
  and (not get-chkc_context.shift-on
  and get-chkc_context.cas-shft) then do:
    assign
    tt-chk-doc.src-shift-date = tt-chk-doc.chk-date
    tt-chk-doc.shift-date = tt-chk-doc.chk-date
    .
  end.
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
tt-chk-doc.shift-date = if get-chkc_context.t-shft < 0 AND tt-chk-doc.chk-time < abs(t-shft)
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
if par-mode = {&add-def} then do:
  ASSIGN
  tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.pay-code:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.curr-code:READ-ONLY IN BROWSE BR-lines = yes
  tt-chk-pay.doc-qnty:visible IN BROWSE BR-lines = no
  tt-chk-pay.par-val:visible IN BROWSE BR-lines = no
  tt-chk-pay.par-code:visible IN BROWSE BR-lines = no
  .
  ENABLE
  B-exit
  b-quit
  B-Help
  B-add
  B-del
  fhour
  fmin
  fsec
  tt-chk-doc.cash-rate when cas-curs
  tt-chk-doc.chk-date
  tt-chk-doc.chk-type
  tt-chk-doc.src-shift-date  when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
  b-cd
  tt-chk-doc.shift-name  when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
  tt-chk-doc.cashier
  tt-chk-doc.z-number
  tt-chk-doc.chk-num
  BR-lines
  tt-chk-doc.ps
  WITH FRAME {&frame-name}.
  hide b-hist
  in frame {&frame-name}.
  end.
  if par-mode = {&update} then do:
    assign
    tt-chk-pay.src-qnty:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.src-val:READ-ONLY IN BROWSE BR-lines = yes
    .
    ENABLE
    b-quit
    B-exit
    B-Help
    b-hist
    BR-lines
    tt-chk-doc.src-shift-date  when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)
    tt-chk-doc.shift-name when (get-chkc_context.cas-shft and not get-chkc_context.shift-on)

    tt-chk-doc.ps
    tt-chk-doc.z-number
    WITH FRAME {&frame-name} .
  end.
  if par-mode = {&lookup} then do:
    ASSIGN
    tt-chk-pay.tot-sum:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.cash-rate:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.bank-rate:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.bank-scale:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.pay-code:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.curr-code:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.src-qnty:READ-ONLY IN BROWSE BR-lines = yes
    tt-chk-pay.src-val:READ-ONLY IN BROWSE BR-lines = yes
    .
    b-quit:label = "&Выход".
    ENABLE
    b-quit
    B-Help
    b-next
    b-prev
    b-hist
    BR-lines
    WITH FRAME {&frame-name} .
    HIDE
    b-exit
    in frame {&frame-name}.
  end.
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
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-lines TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY":U TO br-lines IN FRAME {&FRAME-NAME}.
APPLY "VALUE-CHANGED" to br-lines in frame {&frame-name} .
ASSIGN
frame {&frame-name}:title = if par-mode = {&add-def}
                            then substitute("ЧЕК № &1"
                                      ,tt-chk-doc.doc-code)
                          else (
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
                          else substitute("Дата учета &1", string(tt-chk-doc.shift-date)))
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
define variable ii as integer no-undo.
DEFINE VARIABLE var-rid as recid no-undo.
DEFINE VARIABLE rid-list as character no-undo.
define variable par-rid-list as character no-undo .
DEFINE VARIABLE varopl-curs as decimal no-undo .
DEFINE VARIABLE varbase-curs as decimal no-undo .

define buffer count_chk-pay for ub.chk-pay.
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
DEFINE BUFFER buf_wealth FOR ub.wealth.
DEFINE BUFFER loc_tt-chk-pay FOR tt-chk-pay.
define buffer buf_wth-par for ub.wth-par.

if not par-mode = {&add-def} then return.
rid-list = "" .
run proc-save-doc ( INPUT CAN-FIND (FIRST tt-chk-pay WHERE tt-chk-pay.doc-code = tt-chk-doc.doc-code)
                   ,INPUT NO) No-ERROR.
if error-status:error then return error.

run ref/cashpays.w (
             input parparentproc
            ,input "b-mark,b-sel":U
            ,input {&all}
            ,input get-chkc_context.host-code
            ,input locked_chk-doc.obj-type
            ,input locked_chk-doc.obj-code
            ,output rid-list ) .
IF rid-list = '':U THEN UNDO, RETURN ERROR.
ii = 1.
find last count_chk-pay No-LOCK WHERE
                count_chk-pay.doc-code = tt-chk-doc.doc-code  use-index ln No-ERROR.
if available count_chk-pay then lnp = count_chk-pay.line-num.
ELSE lnp = 0.
 _ii:
 DO WHILE (ii <= num-entries(rid-list) )
 on error undo _ii, next _ii
 :
  FIND FIRST buf_cash-pay WHERE recid( buf_cash-pay ) = integer( entry(ii, rid-list ) ) NO-LOCK .
  if buf_cash-pay.wth-code = 0 then do:
    message
    substitute("Выбранному типу кассового платежа с кодом &1 и кодом валюты &2 не соответствует ни одна МЦ!"
               , buf_cash-pay.cdpay-code
               , buf_cash-pay.curr-code)
    view-as alert-box ERROR.
    ii = ii + 1.
    UNDO _ii, NEXT _ii.
  end.
  FIND FIRST buf_wealth No-LOCK WHERE
                   buf_wealth.wth-code = buf_cash-pay.wth-code No-ERROR.
  if not avail buf_wealth then do:
    message
    substitute("Не найдена МЦ с кодом &1",buf_cash-pay.wth-code)
    view-as alert-box ERROR.
    ii = ii + 1.
    UNDO _ii, NEXT _ii.
  end.
  if buf_wealth.get-qnty-method = {&wth-qnty-val-qnty} then do:
    par-rid-list = ''.
    if available buf_wth-par then release buf_wth-par.
    run ref/wthp-ref.w (
                        input parparentproc
                       ,input "b-sel,b-mark"
                       ,input get-chkc_context.host-code
                       ,input tt-chk-doc.obj-type
                       ,input tt-chk-doc.obj-code
                       ,input {&wealth}  /*p-list-mode      */
                       ,input buf_wealth.wth-code
                       ,input-output par-rid-list ) no-error.
    if par-rid-list = '' then do:
      ii = ii + 1.
      undo _ii, next _ii.
    end.
    find first buf_wth-par no-lock where
              recid(buf_wth-par) = integer(par-rid-list) no-error.
    if not available buf_wth-par then do:
      message
      substitute("Не найдена номинал для МЦ с кодом &1", buf_cash-pay.wth-code)
      view-as alert-box ERROR.
      ii = ii + 1.
      undo _ii, next _ii.
    end.
  end.
  assign
  lnp = lnp + 1
  .
  CREATE tt-chk-pay.
  ASSIGN
  tt-chk-pay.doc-code = tt-chk-doc.doc-CODE
  tt-chk-pay.line-num = lnp
  tt-chk-pay.pay-code = buf_cash-pay.cdpay-code
  tt-chk-pay.curr-code = buf_cash-pay.curr-code
  tt-chk-pay.wth-code = buf_cash-pay.wth-code
  tt-chk-pay.obj-code = tt-chk-doc.obj-code
  tt-chk-pay.obj-type = tt-chk-doc.obj-type
  tt-chk-pay.time-oper = tt-chk-doc.chk-time
  tt-chk-pay.tot-sum = 0
  tt-chk-pay.cash-rate = 0
  tt-chk-pay.bank-rate = 0
  tt-chk-pay.bank-scale = 0
  tt-chk-pay.src-qnty = 0
  tt-chk-pay.doc-qnty = 0
  tt-chk-pay.src-val = (if available buf_wth-par then buf_wth-par.par-val else 0)
  tt-chk-pay.par-val = 0
  tt-chk-pay.par-code = 0
  var-rid = (IF var-rid = ? THEN RECID(tt-chk-pay) ELSE var-rid)
  .
  create locked_chk-pay.
  buffer-copy tt-chk-pay to locked_chk-pay
  .
  run trg/chkins02.p (
                  input  tt-chk-doc.doc-code
                 ,input  1 /*товарный чек - 0 или чек МЦ  - 1*/
                 ,input  tt-chk-doc.chk-type
                 ,input  tt-chk-doc.obj-type
                 ,input  tt-chk-doc.obj-code
                 ,input  tt-chk-doc.chk-date
                 ,input  tt-chk-doc.chk-time
                 ,input  buf_cash-pay.cdpay-code
                 ,input  buf_cash-pay.curr-code
                 ,input  get-chkc_context.base-code
                 ,input  get-chkc_context.r-b
                 ,input  get-chkc_context.cas-curs
                 ,input-output  tt-chk-pay.cash-rate
                 ,input-output  tt-chk-pay.bank-rate
                 ,input-output  tt-chk-pay.bank-scale
                 ,input  recid(locked_chk-pay)
                 ,output varbase-curs
                 ,output varopl-curs
                 ,output tt-chk-pay.par-code
               ) no-error.
    if error-status:error then do:
      var-rid = ?.
      delete tt-chk-pay.
      run control-line in THIS-PROCEDURE ( output locked-title).
      run lock-proc in THIS-PROCEDURE ( INPUT locked-title).
      ii = ii + 1.
      UNDO _ii, NEXT _ii.
    end.
    run control-line in THIS-PROCEDURE ( output locked-title).
    run lock-proc in THIS-PROCEDURE ( INPUT locked-title).
  ii = ii + 1.
END. /*do _ii*/
{&OPEN-QUERY-br-lines}
find first loc_tt-chk-pay WHERE
           loc_tt-chk-pay.doc-code = tt-chk-doc.doc-code AND
           loc_tt-chk-pay.tot-sum = 0 NO-LOCK NO-ERROR.
IF avail loc_tt-chk-pay then do:
  reposition br-lines to recid var-rid NO-ERROR.
end.
apply "entry" to br-lines in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save-doc Dialog-Frame
PROCEDURE proc-save-doc :
DEFINE INPUT PARAMETER parlines-exist as logical no-undo.
define input parameter par-check-lines as logical no-undo .

DEFINE VARIABLE var-rid as recid no-undo.
define variable var-chk-type as character no-undo.
DEFINE VARIABLE varline-rid as recid no-undo .
define buffer check_chk-pay for ub.chk-pay .
DEFINE BUFFER buf-tt-chk-pay FOR tt-chk-pay.

do
on error undo, return ERROR return-value
:

assign
frame {&frame-name} fhour
frame {&frame-name} fmin
frame {&frame-name} fsec
.
/*пишем в историю*/
if par-mode = {&update} then
run trg/chk-doch.p (
                 buffer locked_chk-doc
              , input no
              , input no /*p-add*/
              , input no /*p-del*/
              , input-output v-chip-num
              , output v-is-update).

assign
tt-chk-doc.cash-rate
tt-chk-doc.cashier
tt-chk-doc.chk-date
tt-chk-doc.chk-num
tt-chk-doc.chk-time = fhour * 3600 + fmin * 60 + fsec * 60
tt-chk-doc.chk-type
tt-chk-doc.obj-code
tt-chk-doc.pay-desk
tt-chk-doc.ps
tt-chk-doc.src-shift-date
tt-chk-doc.shift-num
tt-chk-doc.shift-name
tt-chk-doc.z-number
.
buffer-copy tt-chk-doc
except
discnt
correct
cashier-psn-code
out-code
to locked_chk-doc
assign
locked_chk-doc.correct = yes
.
display tt-chk-doc.ps
with frame {&frame-name} .


assign
locked_chk-doc.correct = yes
.
display tt-chk-doc.ps
with frame {&frame-name} .
for each buf-tt-chk-pay no-lock where
         buf-tt-chk-pay.doc-code = tt-chk-doc.doc-code,
    first locked_chk-pay where
          locked_chk-pay.doc-code = buf-tt-chk-pay.doc-code
     AND  locked_chk-pay.line-num = buf-tt-chk-pay.line-num:
  assign
  locked_chk-pay.pay-code = buf-tt-chk-pay.pay-code
  locked_chk-pay.curr-code = buf-tt-chk-pay.curr-code
  locked_chk-pay.tot-sum       = buf-tt-chk-pay.tot-sum
  locked_chk-pay.wth-code  = buf-tt-chk-pay.wth-code
  locked_chk-pay.cash-rate  = buf-tt-chk-pay.cash-rate
  locked_chk-pay.bank-rate  = buf-tt-chk-pay.bank-rate
  locked_chk-pay.bank-scale  = buf-tt-chk-pay.bank-scale
  locked_chk-pay.src-qnty = buf-tt-chk-pay.src-qnty
  locked_chk-pay.src-val = buf-tt-chk-pay.src-val
  .
END.

end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reposition-chk-doc Dialog-Frame
PROCEDURE reposition-chk-doc :
define input parameter p-direction as character no-undo .
define variable v-new-chk-doc-recid as recid no-undo .


do
on error undo, return error
:


  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-chk-doc in p-call-prog
      (input  p-direction
      ,output v-new-chk-doc-recid
      ).

    if v-new-chk-doc-recid <> ?
    then do:
      define buffer buf_chk-doc for ub.chk-doc .
      find first buf_chk-doc no-lock
        where recid(buf_chk-doc) = v-new-chk-doc-recid
        no-error .
      assign
      p-doc-rec = v-new-chk-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список чеков не определен." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-cd Dialog-Frame
PROCEDURE sel-cd :
define variable ri-list as character no-undo .
define variable glog as logical no-undo .
define buffer loc_cash-desk  for ub.cash-desk.
run ref/cashlist.w
    (input  parparentproc
    ,input  'b-sel':U
    ,input  {&g___object}
    ,input  get-chkc_context.db-num
    ,input  get-chkc_context.host-code
    ,input  {&shop}
    ,input  shop-code
    ,input  ?
    ,output ri-list
    ) no-error.
if ri-list = '' then do:
  undo, return error .
end.
FIND FIRST loc_cash-desk No-LOCK WHERE
          recid(loc_cash-desk) = integer(ri-list) no-error.
if not available loc_cash-desk then do:
  undo, return error .
end.
if loc_cash-desk.autonomy = integer({&cd-manager}) then do:
  message
  "Нельзя создать чек для КАССОВОГО МЕНЕДЖЕРА!"
  view-as alert-box error.
  undo, return error .
end.
if loc_cash-desk.pos-type <> dflt-cd then do:
  message
  substitute("На &1&2 установлен тип кассы по умолчанию - &3&4" +
            "Вы уверены, что хотите создать чек для кассы с типом &5?"
            , {&shop}
            , shop-code
            , dflt-cd
            , {&new-line}
            , loc_cash-desk.pos-type)
  view-as alert-box question buttons yes-no update glog.
  if not glog then undo, return error .
end.
find first buf_cash-desk no-lock where
          recid(buf_cash-desk) = recid(loc_cash-desk).

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

