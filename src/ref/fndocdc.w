&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_dis-card FOR ub.dis-card.
DEFINE BUFFER locked_c-fin-doc FOR ub.c-fin-doc.
DEFINE BUFFER locked_fin-doc FOR ub.fin-doc.
DEFINE TEMP-TABLE tt-payment NO-UNDO LIKE ub.payment
       field line-num as integer.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разброс по ДК для финансового документа

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
/*может быть {&add-def} {&update} {&lookup} ({&lookup} + {&delim-par} + "history")*/

define input parameter p-host-code like ub.fin-doc.host-code no-undo.
define input parameter p-fin-doc-code like ub.fin-doc.fin-doc-code no-undo.
define input parameter p-fin-doc-type like ub.fin-doc.fin-doc-type no-undo.
define input parameter p-fin-ext-doc-type like ub.fin-doc.fin-ext-doc-type no-undo.
define input parameter p-cash-book-place as character no-undo .
define input parameter p-payer-type like ub.fin-doc.payer-type no-undo .
define input parameter p-payer-code like ub.fin-doc.payer-code no-undo .
define input parameter p-sum-doc like ub.fin-doc.sum-doc no-undo .
define input parameter p-doc-date  like ub.fin-doc.doc-date no-undo .
define input parameter p-pay-date like ub.fin-doc.pay-date no-undo .
define input parameter p-curr-code like ub.fin-doc.curr-code no-undo .
define input parameter p-base-rate like ub.fin-doc.base-rate no-undo .
define input parameter p-base-scale like ub.fin-doc.base-scale no-undo .
define input parameter p-exch-rate like ub.fin-doc.exch-rate no-undo .
define input parameter p-exch-scale like ub.fin-doc.exch-scale no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .

define INPUT-OUTPUT parameter table for tt0-payment.
define input parameter p-chip-num like ub.c-fin-doc.chip-num no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Налоги для финансового документа".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo.
define variable v-base-code like ub.sysconf.host-code no-undo.
define variable v-add-chg as character no-undo.
define variable v-rest-sum-doc like ub.payment.tot-cli no-undo.
define variable v-change-tab-order as character no-undo .
define variable v-updated-line-num as integer no-undo .
define variable last-line as integer no-undo.
DEFINE VARIABLE v-pmnt-code AS CHARACTER NO-UNDO.
define buffer X_curr_sysconf for ub.sysconf.
define buffer X_currency for ub.currency.

{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ str/lib-farh.i }
&scop tab-order "b-add,b-del,b-quit,b-exit"

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-payment

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-payment buf_dis-card buf_clients ~
locked_fin-doc

/* Definitions for BROWSE BR-payment                                    */
&Scoped-define FIELDS-IN-QUERY-BR-payment tt-payment.d-card tt-payment.pmnt-code tt-payment.tot-cli buf_dis-card.cli-type + STRING(buf_dis-card.cli-code) buf_clients.obj-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-payment tt-payment.tot-cli
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-payment tt-payment
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-payment tt-payment
&Scoped-define SELF-NAME BR-payment
&Scoped-define QUERY-STRING-BR-payment FOR EACH tt-payment NO-LOCK, ~
           FIRST buf_dis-card NO-LOCK, ~
           FIRST buf_clients NO-LOCK
&Scoped-define OPEN-QUERY-BR-payment OPEN QUERY {&SELF-NAME} FOR EACH tt-payment NO-LOCK, ~
           FIRST buf_dis-card NO-LOCK, ~
           FIRST buf_clients NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-payment tt-payment buf_dis-card ~
buf_clients
&Scoped-define FIRST-TABLE-IN-QUERY-BR-payment tt-payment
&Scoped-define SECOND-TABLE-IN-QUERY-BR-payment buf_dis-card
&Scoped-define THIRD-TABLE-IN-QUERY-BR-payment buf_clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH locked_fin-doc SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame locked_fin-doc
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame locked_fin-doc


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-add B-del b-dc B-Help ~
F-curr-code BR-payment
&Scoped-Define DISPLAYED-OBJECTS f-all-sum-doc F-curr-code f-curr-abbr ~
f-rest-sum-doc

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

DEFINE BUTTON b-dc
     LABEL "&Карта"
     SIZE 10 BY 1.

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE f-all-sum-doc AS DECIMAL FORMAT ">,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма по док-ту"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-curr-code AS INTEGER FORMAT ">>9" INITIAL 0
     LABEL "Валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1.

DEFINE VARIABLE f-rest-sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Осталось разнести"
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1
     FGCOLOR 4 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-payment FOR
      tt-payment,
      buf_dis-card,
      buf_clients SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      locked_fin-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-payment
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-payment Dialog-Frame _FREEFORM
  QUERY BR-payment DISPLAY
      tt-payment.d-card COLUMN-LABEL "№ карты" FORMAT "X(19)":U
tt-payment.pmnt-code COLUMN-LABEL "№ платежа" FORMAT "X(19)":U
tt-payment.tot-cli COLUMN-LABEL "Сумма" FORMAT "->>>,>>>,>>9.99":U
buf_dis-card.cli-type + STRING(buf_dis-card.cli-code)
buf_clients.obj-name
ENABLE
tt-payment.tot-cli
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-add AT ROW 1 COL 31
     B-del AT ROW 1 COL 41
     b-dc AT ROW 1 COL 51 WIDGET-ID 2
     B-Help AT ROW 1 COL 95
     f-all-sum-doc AT ROW 2.27 COL 16 COLON-ALIGNED
     F-curr-code AT ROW 2.27 COL 45 COLON-ALIGNED
     f-curr-abbr AT ROW 2.27 COL 50 COLON-ALIGNED NO-LABEL
     f-rest-sum-doc AT ROW 2.27 COL 75 COLON-ALIGNED WIDGET-ID 4
     BR-payment AT ROW 3.47 COL 1
     SPACE(0.24) SKIP(0.56)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязки к ДК"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_dis-card B "?" ? ub dis-card
      TABLE: locked_c-fin-doc B "?" ? ub c-fin-doc
      TABLE: locked_fin-doc B "?" ? ub fin-doc
      TABLE: tt-payment T "?" NO-UNDO ub payment
      ADDITIONAL-FIELDS:
          field line-num as integer
      END-FIELDS.
      TABLE: tt0-payment T "?" NO-UNDO ub payment
      TABLE: X_clients-host B "?" ? ub clients
      TABLE: X_sysconf B "?" ? ub sysconf
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-payment f-rest-sum-doc Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-all-sum-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-curr-abbr IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-rest-sum-doc IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-payment
/* Query rebuild information for BROWSE BR-payment
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH tt-payment NO-LOCK,
    FIRST buf_dis-card NO-LOCK,
    FIRST buf_clients NO-LOCK.
     _END_FREEFORM
     _Query            is NOT OPENED
*/  /* BROWSE BR-payment */
&ANALYZE-RESUME

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
ON GO OF FRAME Dialog-Frame /* Привязки к ДК */
DO:
  run check-sums in this-procedure no-error.
  if error-status:error then return no-apply.
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Привязки к ДК */
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
run proc-b-add in this-procedure  no-error.
if error-status:error then do:
    return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dc Dialog-Frame
ON CHOOSE OF b-dc IN FRAME Dialog-Frame /* Карта */
DO:
DEFINE VARIABLE v-rid AS RECID NO-UNDO.
IF NOT AVAILABLE tt-payment  THEN RETURN NO-APPLY.
v-rid = recid( buf_dis-card ) .
run ref/dcardi.w (
              input parparentproc
            , input {&lookup}
            , input buf_dis-card.emitent-host-code
            , input v-cntxt-host-code-obj
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input ?
            , input-output v-rid ) NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
{ gbl/stdbtn.i }

define variable v-line-num as integer no-undo .

DEFINE BUFFER buf_tt-payment for tt-payment.
IF AVAIL tt-payment then do:
  do
  on error undo, return no-apply
  :
      FIND FIRST buf_tt-payment WHERE
                        recid(buf_tt-payment) = RECID(tt-payment) NO-ERROR.
      if avail buf_tt-payment then do:
          assign
          v-line-num = buf_tt-payment.line-num
          .
          delete buf_tt-payment.
      end.
      for each buf_tt-payment where
                  buf_tt-payment.host-code = p-host-code
              AND buf_tt-payment.source-ref = string(p-fin-doc-code)
              AND buf_tt-payment.line-num > v-line-num
              by buf_tt-payment.pmnt-code:
          assign
          buf_tt-payment.line-num = buf_tt-payment.line-num - 1
          .
      end.
    end. /*doe*/
    run openbr in this-procedure.
    RUN get-rest-sum in this-procedure(output v-rest-sum-doc).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  { gbl/stdbtn.i }

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-payment
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
{ ref/tabhndmv.i ~{&tab-order~} "underline-tb" }
{ gbl/brwrepos.i
&line-num=5
}

ON LEAVE OF tt-payment.tot-cli IN BROWSE br-payment do:
  assign
  tt-payment.tot-cli = decimal(tt-payment.tot-cli:screen-value in browse br-payment)
  tt-payment.tot-base =  (tt-payment.tot-cli * p-exch-rate / p-exch-scale) /  (p-base-rate / p-base-scale)
  tt-payment.tot-rubl =  (tt-payment.tot-cli * p-exch-rate / p-exch-scale)
  .
  RUN get-rest-sum in this-procedure(output v-rest-sum-doc).
end.


/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  if p-mode <> {&update}
  and p-mode <> {&lookup}
  and p-mode <> {&add-def}
  and p-mode <> ({&lookup} + {&delim-par} + "history":U)
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
  end.
  { gbl/curdbnum.i v-db-num }
  { gbl/basecode.i p-host-code v-base-code }
    find first X_curr_sysconf no-lock where
                    X_curr_sysconf.host-code = p-curr-host-code.
    find first X_sysconf no-lock where
                  X_sysconf.host-code = p-host-code.
    find first X_clients-host no-lock where
              X_clients-host.obj-type = {&cmp}
          AND X_clients-host.obj-code = p-host-code.
/*  if LOOKUP({&lookup} , p-mode, {&delim-par}) = 0 then do:*/
/*    define variable v-ok as logical no-undo .             */
/*    define variable v-mess as character no-undo .         */
/*    { str/finchkdb.i                                      */
/*      p-host-code                                         */
/*      p-fin-doc-code                                      */
/*      p-obj-type                                          */
/*      p-obj-code                                          */
/*      p-fin-ext-doc-type                                  */
/*      p-cash-book-place                                   */
/*      ?                                                   */
/*      v-ok                                                */
/*      v-mess                                              */
/*    no-error }                                            */
/*    if not v-ok then do:                                  */
/*      message v-mess                                      */
/*      view-as alert-box error .                           */
/*      undo main-block, return error .                     */
/*    end.                                                  */
/*  end.                                                    */
  if p-mode = {&update}
  or p-mode = {&lookup} then do:
    if p-mode = {&update} then do:
      find first locked_fin-doc EXclusive-lock where
                 locked_fin-doc.host-code  = p-host-code
             AND locked_fin-doc.fin-doc-code  = p-fin-doc-code
                   no-wait no-error.
      if locked locked_fin-doc then do:
        message
        vss-workfile vss-revision vss-description skip
        "Запись Платежа занята"
        "фирма" p-host-code
        "внутр. № документа" p-fin-doc-code
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_fin-doc no-lock where
                 locked_fin-doc.host-code  = p-host-code
             AND locked_fin-doc.fin-doc-code  = p-fin-doc-code no-error .
    end.
    if not available locked_fin-doc
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ПЛАТЕЖА"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  if p-mode = ({&lookup} + {&delim-par} + "history":U)
  then do:
    find first locked_c-fin-doc no-lock where
                locked_c-fin-doc.host-code  = p-host-code
            AND locked_c-fin-doc.fin-doc-code  = p-fin-doc-code no-error .
    if not available locked_c-fin-doc
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись истории ПЛАТЕЖА"
      view-as alert-box error .
      undo, return error.
    end.
  end.
  find first X_currency no-lock where
               X_currency.curr-code = p-curr-code.
  run fill-tables in this-procedure.
  RUN Myenable.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-sums Dialog-Frame
PROCEDURE check-sums :
define variable acc as decimal no-undo.
define buffer buf_tt-payment for tt-payment.
for each buf_tt-payment:
    assign
    acc = acc + buf_tt-payment.tot-cli
    .
end.
if acc <> p-sum-doc then do:
message
substitute("Общая сумма платежа &1, а сумма по картам - &2", p-sum-doc, acc)
view-as alert-box ERROR.
return error.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-payment-line Dialog-Frame
PROCEDURE create-payment-line :
DEFINE PARAMETER BUFFER buf_dis-card FOR ub.dis-card.
define buffer buf_tt-payment for tt-payment.
FIND FIRST buf_tt-payment NO-LOCK WHERE
        buf_tt-payment.d-card = buf_dis-card.d-card no-error.
IF AVAILABLE buf_tt-payment THEN DO:
  MESSAGE
  SUBSTITUTE("Уже есть строка привязки к карте &1", buf_dis-card.d-card)
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FIND LAST buf_tt-payment  NO-ERROR.
IF AVAILABLE buf_tt-payment THEN DO:
  last-line = integer(entry(2, buf_tt-payment.pmnt-code, "_")).

END.
CREATE buf_tt-payment.
ASSIGN
buf_tt-payment.host-code = p-host-code
buf_tt-payment.source-type = {&pmnt-fin-doc}
buf_tt-payment.source-ref = string(p-fin-doc-code)
buf_tt-payment.pmnt-code = substitute("&1_&2", v-pmnt-code, string(last-line + 1, "999999999"))
buf_tt-payment.line-num = last-line + 1
last-line = last-line + 1
buf_tt-payment.d-card = buf_dis-card.d-card
buf_tt-payment.cli-type = buf_dis-card.cli-type
buf_tt-payment.cli-code = buf_dis-card.cli-code
buf_tt-payment.payer-type = p-payer-type
buf_tt-payment.payer-code = p-payer-code
buf_tt-payment.exch-date = p-doc-date
buf_tt-payment.exch-code = p-curr-code
buf_tt-payment.exch-rate = p-exch-rate
buf_tt-payment.exch-scale = p-exch-scale
buf_tt-payment.base-rate = p-base-rate
buf_tt-payment.base-scale = p-base-scale
buf_tt-payment.due-date = p-pay-date
buf_tt-payment.STATUS_ = {&expected}
buf_tt-payment.PS = '':U
buf_tt-payment.pay-code = (if p-fin-ext-doc-type = {&FDEDT_Income_Cash}
                          then 1
                          else (if p-fin-ext-doc-type = {&FDEDT_Income_Cashless}
                               then 3
                               else 5)
                          )
.
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
  DISPLAY f-all-sum-doc F-curr-code f-curr-abbr f-rest-sum-doc
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-add B-del b-dc B-Help F-curr-code BR-payment
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
define variable v-found as logical no-undo .
define buffer buf_payment for ub.payment.
define buffer buf_c-payment for ub.payment.
define buffer buf_tt-payment for tt-payment.
do on error undo, return error:
  if p-mode = {&lookup} + {&delim-par} + "History":U then do:
    for each buf_c-payment no-lock where
                buf_c-payment.host-code = p-host-code
          AND buf_c-payment.source-type = {&pmnt-fin-doc}
          AND buf_c-payment.source-ref = string(p-fin-doc-code)
          :
      create buf_tt-payment.
      buffer-copy buf_c-payment to buf_tt-payment.
    END.
  end.
  else do:
    find first tt0-payment no-lock no-error.
    if available tt0-payment then do:
      for each tt0-payment no-lock where
                  tt0-payment.host-code = p-host-code
            AND tt0-payment.source-type = {&pmnt-fin-doc}
            AND tt0-payment.source-ref = string(p-fin-doc-code):
        create buf_tt-payment.
        buffer-copy tt0-payment to buf_tt-payment
        assign
        buf_tt-payment.line-num = integer(entry(2, tt0-payment.pmnt-code, "_"))
        .
      END.
    end.
    else do:
      for each buf_payment no-lock where
                  buf_payment.host-code = p-host-code
            AND buf_payment.source-type = {&pmnt-fin-doc}
            AND buf_payment.source-ref = string(p-fin-doc-code):
        create buf_tt-payment.
        buffer-copy buf_payment to buf_tt-payment
        assign
        buf_tt-payment.line-num = integer(entry(2, buf_payment.pmnt-code, "_"))
        v-pmnt-code = entry(1, buf_payment.pmnt-code, "_")
        .
        v-found = YES.
      END.
      IF v-found = NO
      AND p-mode = {&add-def} THEN DO:
         FOR EACH buf_dis-card NO-LOCK WHERE
                 buf_Dis-card.cli-type = p-payer-type
             AND buf_Dis-card.cli-code = p-payer-code:
           RUN create-payment-line IN THIS-PROCEDURE ( BUFFER buf_dis-card).
         END.
      END.
    end.
  end.
  RUN get-rest-sum in this-procedure(output v-rest-sum-doc).
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-rest-sum Dialog-Frame
PROCEDURE get-rest-sum :
define output parameter p-rest-sum like ub.payment.tot-cli no-undo.
define buffer buf_tt-payment for tt-payment.
for each buf_tt-payment no-lock:
    assign
    p-rest-sum = p-rest-sum + buf_tt-payment.tot-cli
    .
end.
assign
p-rest-sum = p-sum-doc - p-rest-sum
.
DISPLAY
p-rest-sum @ f-rest-sum-doc
WITH FRAME {&FRAME-NAME}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
assign
frame {&frame-name}:title = substitute("&1 для платежа &2", frame {&frame-name}:title
                                             , p-fin-doc-code)
b-quit:label = (if lookup({&lookup}, p-mode, {&delim-par}) > 0 then "&Выход" else b-quit:label)
.
DISPLAY
p-sum-doc @ f-all-sum-doc
p-curr-code @ f-curr-code
X_currency.curr-abbr @ f-curr-abbr
WITH FRAME {&frame-name}.
ENABLE
b-quit
B-exit when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-add  when lookup({&lookup}, p-mode, {&delim-par}) = 0
B-del  when lookup({&lookup}, p-mode, {&delim-par}) = 0
b-dc
B-Help
BR-payment
WITH FRAME {&frame-name}.
if lookup({&lookup}, p-mode, {&delim-par}) > 0 then do:
  assign
  tt-payment.tot-cli:read-only in browse br-payment = yes
  .
  hide
  b-exit
  in frame {&frame-name} .
  b-quit:column = 1.
end.
VIEW FRAME {&frame-name}.
RUN openbr in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
output to kk.txt.
for each tt-payment:
export tt-payment.
end.
output close.
Open query br-payment
for each tt-payment no-lock where
            tt-payment.source-type = {&pmnt-fin-doc}
        AND tt-payment.source-ref = string(p-fin-doc-code)
        AND tt-payment.host-code = p-host-code,
    first buf_dis-card no-lock where
          buf_dis-card.d-card = tt-payment.d-card,
    first buf_clients no-lock where
        buf_clients.obj-type = buf_dis-card.cli-type
     and buf_clients.obj-code = buf_dis-card.cli-code.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-ii as integer no-undo .
DEFINE BUFFER buf_clients FOR ub.clients.
define buffer buf_dis-card for ub.dis-card.
FIND FIRST buf_clients NO-LOCK WHERE
        buf_clients.obj-type = p-payer-type
    AND buf_clients.obj-code = p-payer-code.
run ref/discards.w ( INPUT parparentproc
                    ,INPUT "b-sel,b-mark"
                    ,INPUT "client" /*p-list-mode */
                    ,INPUT v-cntxt-host-code-obj
                    ,INPUT v-cntxt-obj-type
                    ,INPUT v-cntxt-obj-code
                    ,INPUT '':U /*p-first-main-card   */
                    ,INPUT RECID(buf_clients)
                    ,OUTPUT v-rid-list) NO-ERROR.
IF v-rid-list <> '' THEN DO:
  DO v-ii = 1 TO NUM-ENTRIES(v-rid-list):
      FIND FIRST buf_dis-card NO-LOCK WHERE
          recid(buf_Dis-card) = integer(ENTRY(v-ii, v-rid-list)) NO-ERROR.
      IF AVAILABLE buf_dis-card THEN DO:
         RUN create-payment-line IN THIS-PROCEDURE ( BUFFER buf_dis-card).
      END.
  END.
  RUN Openbr IN THIS-PROCEDURE NO-ERROR.
  RUN get-rest-sum in this-procedure(output v-rest-sum-doc).
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
do on error undo, return error:
  for each tt0-payment where
          tt0-payment.host-code = p-host-code
       AND tt0-payment.source-type = {&pmnt-fin-doc}
       AND tt0-payment.source-ref = string(p-fin-doc-code):
    find first tt-payment no-lock where
               tt-payment.host-code = p-host-code
           AND tt-payment.source-ref = string(p-fin-doc-code)
           AND tt-payment.pmnt-code = tt0-payment.pmnt-code no-error .
    if not available tt-payment then do:
      delete tt0-payment.
    end.
  end.
 for each tt-payment :
    find first tt0-payment where
               tt0-payment.host-code = p-host-code
           AND tt0-payment.source-type = {&pmnt-fin-doc}
           AND tt0-payment.source-ref = string(p-fin-doc-code)
           AND tt0-payment.pmnt-code   = tt-payment.pmnt-code
           no-error .
    if not available tt0-payment then do:
      create tt0-payment.
      assign
      tt0-payment.host-code = p-host-code
      tt0-payment.source-type = {&pmnt-fin-doc}
      tt0-payment.source-ref = string(p-fin-doc-code)
      tt0-payment.pmnt-code = tt-payment.pmnt-code
      .
    end.
    buffer-copy tt-payment except host-code source-type source-ref pmnt-code
    to tt0-payment
    assign
    tt-payment.tot-base =  (tt0-payment.tot-cli * p-exch-rate / p-exch-scale) /  (p-base-rate / p-base-scale)
    tt-payment.tot-rubl =  (tt0-payment.tot-cli * p-exch-rate / p-exch-scale)
    tt-payment.exch-date = p-doc-date
    tt-payment.exch-code =  p-curr-code
    tt-payment.exch-rate = p-exch-rate
    tt-payment.exch-scale = p-exch-scale
    tt-payment.base-rate = p-base-rate
    tt-payment.base-scale = p-base-scale
    tt-payment.due-date = p-pay-date
    .
  end.
end.
for each tt0-payment where
        tt0-payment.host-code = p-host-code
  AND tt0-payment.source-type = {&pmnt-fin-doc}
  AND tt0-payment.source-ref = string(p-fin-doc-code):
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
