&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_clients FOR ub.clients.
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE BUFFER locked_payment FOR ub.payment.
DEFINE TEMP-TABLE tt-payment NO-UNDO LIKE ub.payment.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обещанный платеж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/16/06
Author: Bakhtadze Natalya
Creation date: 03/16/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
/*{&update} {&LOOKUP} {&add-def}*/
define input parameter p-mode as char  no-undo.
/*recid payment*/
define input-output param  p-rid   as   recid           no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
DEFINE INPUT PARAMETER psource-type like ub.payment.source-type no-undo.
DEFINE INPUT PARAMETER psource-ref  like ub.payment.source-ref no-undo.
define input parameter p-d-card as character no-undo .
DEFINE INPUT PARAMETER ptot-cli like ub.payment.tot-cli no-undo.
DEFINE INPUT PARAMETER pexch-code like ub.payment.exch-code no-undo.
DEFINE INPUT PARAMETER pbase-rate like ub.payment.base-rate no-undo.
DEFINE INPUT PARAMETER pbase-scale like ub.payment.base-scale no-undo.
DEFINE INPUT PARAMETER pexch-rate like ub.payment.exch-rate no-undo.
DEFINE INPUT PARAMETER pexch-scale like ub.payment.exch-scale no-undo.
DEFINE INPUT PARAMETER pexch-date like ub.payment.exch-date no-undo.
DEFINE INPUT PARAMETER ppay-code like ub.payment.pay-code no-undo.
DEFINE INPUT PARAMETER pdate-pay like ub.payment.fact-date no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Обещанный платеж" .
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ gbl/cur-time.i }
{ ref/tmpchgs.i "NEW SHARED" temp-labels update }
{ ref/tmpchgs.i  }
{ rul/tempcont.i }

DEFINE VARIABLE for-pay-name like ub.pay-type.obj-name no-undo.
DEFINE BUFFER payer for ub.clients.
DEFINE BUFFER buf_Dis-card for ub.dis-card.
DEFINE BUFFER buf_ord-doc for ub.ord-doc.
DEFINE BUFFER buf_pay-type for ub.pay-type.
DEFINE BUFFER buf_curr-chk FOR ub.currency.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.payment ub.clients ub.currency tt-payment

/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define FIELDS-IN-QUERY-Dialog-Frame tt-payment.fact-date ~
tt-payment.cli-type tt-payment.cli-code tt-payment.due-date ~
tt-payment.payer-type tt-payment.payer-code tt-payment.status_ ~
tt-payment.pay-code tt-payment.creid tt-payment.source-type ~
tt-payment.source-ref tt-payment.closid tt-payment.tot-cli ~
tt-payment.exch-code tt-payment.exch-rate tt-payment.exch-scale ~
tt-payment.exch-date tt-payment.tot-base tt-payment.base-rate ~
tt-payment.base-scale tt-payment.tot-rubl tt-payment.PS
&Scoped-define ENABLED-FIELDS-IN-QUERY-Dialog-Frame tt-payment.fact-date ~
tt-payment.due-date tt-payment.payer-type tt-payment.payer-code ~
tt-payment.status_ tt-payment.pay-code tt-payment.tot-cli ~
tt-payment.exch-code tt-payment.exch-rate tt-payment.exch-scale ~
tt-payment.exch-date tt-payment.base-rate tt-payment.base-scale ~
tt-payment.PS
&Scoped-define ENABLED-TABLES-IN-QUERY-Dialog-Frame tt-payment
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-Dialog-Frame tt-payment
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH ub.payment SHARE-LOCK, ~
      EACH ub.clients WHERE clients.obj-type = payment.cli-type ~
  AND clients.obj-code = payment.cli-code SHARE-LOCK, ~
      EACH ub.currency WHERE currency.curr-code = payment.exch-code SHARE-LOCK, ~
      EACH tt-payment WHERE TRUE /* Join to ub.payment incomplete */ SHARE-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH ub.payment SHARE-LOCK, ~
      EACH ub.clients WHERE clients.obj-type = payment.cli-type ~
  AND clients.obj-code = payment.cli-code SHARE-LOCK, ~
      EACH ub.currency WHERE currency.curr-code = payment.exch-code SHARE-LOCK, ~
      EACH tt-payment WHERE TRUE /* Join to ub.payment incomplete */ SHARE-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame ub.payment ub.clients ~
ub.currency tt-payment
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame ub.payment
&Scoped-define SECOND-TABLE-IN-QUERY-Dialog-Frame ub.clients
&Scoped-define THIRD-TABLE-IN-QUERY-Dialog-Frame ub.currency
&Scoped-define FOURTH-TABLE-IN-QUERY-Dialog-Frame tt-payment


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS tt-payment.fact-date tt-payment.due-date ~
tt-payment.payer-type tt-payment.payer-code tt-payment.status_ ~
tt-payment.pay-code tt-payment.tot-cli tt-payment.exch-code ~
tt-payment.exch-rate tt-payment.exch-scale tt-payment.exch-date ~
tt-payment.base-rate tt-payment.base-scale tt-payment.PS
&Scoped-define ENABLED-TABLES tt-payment
&Scoped-define FIRST-ENABLED-TABLE tt-payment
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-Help B-payer B-pay-code ~
B-exch-code payer-name pay-type-name exch-code-name
&Scoped-Define DISPLAYED-FIELDS tt-payment.fact-date tt-payment.cli-type ~
tt-payment.cli-code tt-payment.due-date tt-payment.payer-type ~
tt-payment.payer-code tt-payment.status_ tt-payment.pay-code ~
tt-payment.creid tt-payment.source-type tt-payment.source-ref ~
tt-payment.closid tt-payment.tot-cli tt-payment.exch-code ~
tt-payment.exch-rate tt-payment.exch-scale tt-payment.exch-date ~
tt-payment.tot-base tt-payment.base-rate tt-payment.base-scale ~
tt-payment.tot-rubl tt-payment.PS buf_clients.obj-name
&Scoped-define DISPLAYED-TABLES tt-payment buf_clients
&Scoped-define FIRST-DISPLAYED-TABLE tt-payment
&Scoped-define SECOND-DISPLAYED-TABLE buf_clients
&Scoped-Define DISPLAYED-OBJECTS payer-name pay-type-name exch-code-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exch-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-pay-code
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON B-payer
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "B"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE exch-code-name AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 7.6 BY 1
     FGCOLOR 4 .

DEFINE VARIABLE pay-type-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 33 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE payer-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY Dialog-Frame FOR
      ub.payment,
      ub.clients,
      ub.currency,
      tt-payment SCROLLING.
&ANALYZE-RESUME

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     B-Help AT ROW 1 COL 95
     tt-payment.fact-date AT ROW 3.13 COL 83.4 COLON-ALIGNED
          LABEL "Дата"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
          FGCOLOR 4
     tt-payment.cli-type AT ROW 3.2 COL 11.8 COLON-ALIGNED
          LABEL "Контрагент"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-payment.cli-code AT ROW 3.2 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-payment.due-date AT ROW 4.43 COL 83.8 COLON-ALIGNED
          LABEL "Ожид."
          VIEW-AS FILL-IN
          SIZE 12 BY 1.07
          FGCOLOR 4
     tt-payment.payer-type AT ROW 4.53 COL 11.8 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 5 BY 1
     tt-payment.payer-code AT ROW 4.53 COL 19 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 12.5 BY 1
     B-payer AT ROW 4.53 COL 33.9
     tt-payment.status_ AT ROW 5.67 COL 80 COLON-ALIGNED
          LABEL "Статус"
          VIEW-AS FILL-IN
          SIZE 15.8 BY 1
          FGCOLOR 4
     tt-payment.pay-code AT ROW 5.8 COL 11.8 COLON-ALIGNED
          LABEL "Код оплаты"
          VIEW-AS FILL-IN
          SIZE 7.5 BY 1
     B-pay-code AT ROW 5.8 COL 22.5
     tt-payment.creid AT ROW 6.93 COL 80 COLON-ALIGNED
          LABEL "Создал"
          VIEW-AS FILL-IN
          SIZE 15.8 BY 1
          FGCOLOR 4
     tt-payment.source-type AT ROW 7.13 COL 13 COLON-ALIGNED
          LABEL "К документу"
          VIEW-AS FILL-IN
          SIZE 13.3 BY 1
     tt-payment.source-ref AT ROW 7.17 COL 33.3 COLON-ALIGNED
          LABEL "№"
          VIEW-AS FILL-IN
          SIZE 18.4 BY 1
     tt-payment.closid AT ROW 8.2 COL 80 COLON-ALIGNED
          LABEL "Закрыл"
          VIEW-AS FILL-IN
          SIZE 15.8 BY 1
          FGCOLOR 4
     tt-payment.tot-cli AT ROW 9.63 COL 14 COLON-ALIGNED
          LABEL "Сумма платежа"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 4
     tt-payment.exch-code AT ROW 9.63 COL 41.6 COLON-ALIGNED
          LABEL "Вал."
          VIEW-AS FILL-IN
          SIZE 4.5 BY .97
     B-exch-code AT ROW 9.63 COL 49
     tt-payment.exch-rate AT ROW 9.63 COL 64.4 COLON-ALIGNED
          LABEL "Курс"
          VIEW-AS FILL-IN
          SIZE 11 BY 1.17
          FGCOLOR 4
     tt-payment.exch-scale AT ROW 9.63 COL 76.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.9 BY 1
     tt-payment.exch-date AT ROW 9.63 COL 82.5 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 13.3 BY 1.17
     tt-payment.tot-base AT ROW 10.8 COL 14 COLON-ALIGNED
          LABEL "Сумма (б.в.)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-payment.base-rate AT ROW 10.8 COL 64.4 COLON-ALIGNED
          LABEL "Курс б.в."
          VIEW-AS FILL-IN
          SIZE 11.1 BY 1
          FGCOLOR 4
     tt-payment.base-scale AT ROW 10.8 COL 76.4 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 4.9 BY 1
     tt-payment.tot-rubl AT ROW 12.03 COL 14 COLON-ALIGNED
          LABEL "Сумма (rub)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-payment.PS AT ROW 14 COL 1 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 2
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Dialog-Frame
     buf_clients.obj-name AT ROW 3.2 COL 34 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 43 BY 1
          FGCOLOR 4
     payer-name AT ROW 4.53 COL 35.1 COLON-ALIGNED NO-LABEL
     pay-type-name AT ROW 5.8 COL 27 NO-LABEL
     exch-code-name AT ROW 9.63 COL 50.4 COLON-ALIGNED NO-LABEL
     SPACE(39.00) SKIP(6.23)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Платеж"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Add Fields to: Neither
   Temp-Tables and Buffers:
      TABLE: buf_clients B "?" ? ub clients
      TABLE: buf_currency B "?" ? ub currency
      TABLE: locked_payment B "?" ? ub payment
      TABLE: tt-payment T "?" NO-UNDO ub payment
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

/* SETTINGS FOR FILL-IN tt-payment.base-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.base-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.cli-code IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.cli-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.closid IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.creid IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.due-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.exch-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.exch-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.exch-rate IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.exch-scale IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.fact-date IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN buf_clients.obj-name IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.pay-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN pay-type-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN tt-payment.payer-code IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.source-ref IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.source-type IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.status_ IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.tot-base IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* SETTINGS FOR FILL-IN tt-payment.tot-cli IN FRAME Dialog-Frame
   EXP-LABEL                                                            */
/* SETTINGS FOR FILL-IN tt-payment.tot-rubl IN FRAME Dialog-Frame
   NO-ENABLE EXP-LABEL                                                  */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "ub.payment,ub.clients WHERE ub.payment ...,ub.currency WHERE ub.payment ...,Temp-Tables.tt-payment WHERE ub.payment ..."
     _Options          = "SHARE-LOCK"
     _JoinCode[2]      = "clients.obj-type = payment.cli-type
  AND clients.obj-code = payment.cli-code"
     _JoinCode[3]      = "currency.curr-code = payment.exch-code"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Платеж */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exch-code Dialog-Frame
ON CHOOSE OF B-exch-code IN FRAME Dialog-Frame /* B */
DO:
  RUN local-curr-chk in this-procedure ("exch-code", "button").
  apply "entry" to tt-payment.exch-code in FRAME {&FRAME-NAME}.
  /*найти и показать курсы*/
  run calc-sums in this-procedure ( input "exch-code") no-error.
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:

IF p-mode = {&LOOKUP} THEN DO:
  UNDO, RETURN NO-APPLY.
END.
RUN proc-save IN THIS-PROCEDURE NO-ERROR.
IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pay-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pay-code Dialog-Frame
ON CHOOSE OF B-pay-code IN FRAME Dialog-Frame /* B */
DO:
define variable v-ref-rec as character no-undo .
    run ref/paytype.w ( input parparentproc
                       ,input "b-sel"
                       ,output  v-ref-rec ).
    find FIRST buf_pay-type where
               recid(buf_pay-type) = integer(v-ref-rec) no-lock no-error.
   if not available buf_pay-type then return no-apply.
   DISPLAY
   buf_pay-type.obj-code @ tt-payment.pay-code
   buf_pay-type.obj-name @ pay-type-name
   WITH FRAME {&frame-name}.
   RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-payer
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-payer Dialog-Frame
ON CHOOSE OF B-payer IN FRAME Dialog-Frame /* B */
DO:
DEFINE VARIABLE ref-list as char no-undo.
define variable v-ref-rec as recid no-undo .
run ref/cli-all.w ( input parparentproc
               ,input "b-sel"
               ,input {&all}
               ,input ?
               ,input ?
               ,input ?
               ,input ?
               ,input ?
               ,output ref-list) NO-ERROR .

if ref-list <> "" then do:
  v-ref-rec = integer (ref-list).
  find payer where recid ( payer ) = v-ref-rec no-lock.
  display
  payer.obj-code @ tt-payment.payer-code
  payer.obj-type @ tt-payment.payer-type
  payer.obj-name @ payer-name
  with frame {&frame-name}.
END.
RUN check-payer in this-procedure No-error.
IF error-status:error then do:
    return no-apply.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.base-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.base-rate Dialog-Frame
ON LEAVE OF tt-payment.base-rate IN FRAME Dialog-Frame /* Курс б.в. */
DO:
  APPLY "RETURN" TO tt-payment.base-rate.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.base-rate Dialog-Frame
ON RETURN OF tt-payment.base-rate IN FRAME Dialog-Frame /* Курс б.в. */
DO:
  run calc-sums in this-procedure ( input "base-rate") no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.base-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.base-scale Dialog-Frame
ON LEAVE OF tt-payment.base-scale IN FRAME Dialog-Frame /* base-scale */
DO:
  APPLY "RETURN" TO tt-payment.base-scale.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.base-scale Dialog-Frame
ON RETURN OF tt-payment.base-scale IN FRAME Dialog-Frame /* base-scale */
DO:
  run calc-sums in this-procedure ( input "base-rate") no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.exch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-code Dialog-Frame
ON LEAVE OF tt-payment.exch-code IN FRAME Dialog-Frame /* Вал. */
DO:
  if input frame {&frame-name} tt-payment.exch-code <> tt-payment.exch-code then do:
    run local-curr-chk in this-procedure ("exch-code", "leave").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-code Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF tt-payment.exch-code IN FRAME Dialog-Frame /* Вал. */
OR RETURN OF tt-payment.exch-code IN FRAME {&frame-name} DO:
  run local-curr-chk in this-procedure ("exch-code", "ret-mouse").
  apply "entry" to tt-payment.exch-code in frame {&frame-name}.
  return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.exch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-date Dialog-Frame
ON LEAVE OF tt-payment.exch-date IN FRAME Dialog-Frame /* exch-date */
DO:
  APPLY "RETURN" TO tt-payment.exch-date.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-date Dialog-Frame
ON RETURN OF tt-payment.exch-date IN FRAME Dialog-Frame /* exch-date */
DO:
  /**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.exch-rate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-rate Dialog-Frame
ON LEAVE OF tt-payment.exch-rate IN FRAME Dialog-Frame /* Курс */
DO:
  APPLY "RETURN" to tt-payment.exch-rate.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-rate Dialog-Frame
ON RETURN OF tt-payment.exch-rate IN FRAME Dialog-Frame /* Курс */
DO:
  run calc-sums in this-procedure ( input "exch-code") no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.exch-scale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-scale Dialog-Frame
ON LEAVE OF tt-payment.exch-scale IN FRAME Dialog-Frame /* exch-scale */
DO:
  APPLY "RETURN" to tt-payment.exch-scale.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.exch-scale Dialog-Frame
ON RETURN OF tt-payment.exch-scale IN FRAME Dialog-Frame /* exch-scale */
DO:
  run calc-sums in this-procedure ( input "exch-code") no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.pay-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.pay-code Dialog-Frame
ON LEAVE OF tt-payment.pay-code IN FRAME Dialog-Frame /* Код оплаты */
DO:
  APPLY "RETURN" to tt-payment.pay-code.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.pay-code Dialog-Frame
ON RETURN OF tt-payment.pay-code IN FRAME Dialog-Frame /* Код оплаты */
DO:
run check-pay-code in this-procedure no-error.
if error-status:error then return no-apply.
display
buf_pay-type.obj-name @ pay-type-name
with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.payer-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.payer-code Dialog-Frame
ON LEAVE OF tt-payment.payer-code IN FRAME Dialog-Frame /* payer-code */
DO:
   FIND FIRST payer No-LOCK WHERE
              payer.obj-type = input frame {&frame-name} tt-payment.payer-type
          AND payer.obj-code = input frame {&frame-name} tt-payment.payer-code no-error.
   if available payer then
   DISPLAY
   payer.obj-name @ payer-name
   with frame {&frame-name}.
   run check-payer in this-procedure no-error.
   if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.payer-code Dialog-Frame
ON RETURN OF tt-payment.payer-code IN FRAME Dialog-Frame /* payer-code */
DO:
    DEFINE VARIABLE ref-list as char no-undo.
    define variable v-ref-rec as recid no-undo .
    FIND FIRST payer NO-LOCK WHERE
               payer.obj-type = input frame {&frame-name} tt-payment.payer-type
           AND payer.obj-code = input frame {&frame-name} tt-payment.payer-code no-error.
    if available payer then do:
        DISPLAY
        payer.obj-name @ payer-name
        with frame {&frame-name}.
        return no-apply.
    end.
    else do:
        run ref/cli-all.w ( input parparentproc
                        ,input "b-add,b-sel":U
                        ,input ?
                        ,input ?
                        ,input ?
                        ,input ?
                        ,input ?
                        ,input ?
                        ,output ref-list) .
        if ref-list = "" then do:
            apply "entry" to tt-payment.payer-code in frame {&frame-name}.
            return no-apply.
        end.
        v-ref-rec = integer (ref-list).
        FIND FIRST payer NO-LOCK WHERE
                   recid (payer) = v-ref-rec .
        DISPLAY
        payer.obj-type @ tt-payment.payer-type
        payer.obj-code @ tt-payment.payer-code
        payer.obj-name @ payer-name
        with frame {&frame-name}.
        return no-apply.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tt-payment.tot-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.tot-cli Dialog-Frame
ON LEAVE OF tt-payment.tot-cli IN FRAME Dialog-Frame /* Сумма платежа */
DO:
  APPLY "RETURN" to tt-payment.tot-cli.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tt-payment.tot-cli Dialog-Frame
ON RETURN OF tt-payment.tot-cli IN FRAME Dialog-Frame /* Сумма платежа */
DO:
  run calc-sums in this-procedure ( input "tot-cli").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
   { gbl/getcntxt.i get }
  if lookup(p-mode
            ,( {&add-def} + {&delim-par} +
              {&update} + {&delim-par} + {&lookup}
              )
            , {&delim-par} ) = 0 then do:
    message
    substitute("Неверное значение параметра вызова p-mode=&1", p-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if lookup ( psource-type, {&pmnt-ord-doc} + {&delim-par} + {&table_payment}, {&delim-par}) = 0
  and p-mode <> {&LOOKUP}
  then do:
    message
    substitute("Неверное значение параметра вызова psource-type=&1", psource-type)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if psource-type = {&table_payment}
  and p-d-card = '':U then do:
    message
    substitute("Неверное значение параметра вызова p-d-card=&1", p-d-card)
    view-as alert-box error .
    undo main-block, return error .
  end.
  RUN fill-table IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    UNDO main-block, RETURN ERROR.
  END.
  RUN MYenable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-sums Dialog-Frame
PROCEDURE calc-sums :
DEFIN INPUT PARAMETER changed as char no-undo.
CASE changed:
    WHEN "exch-code" then do:
        /*найти tot-cli из р_у_блей*/
        tt-payment.tot-cli = tt-payment.tot-rubl * (input frame {&frame-name} tt-payment.exch-rate) /
                                     (input frame {&frame-name} tt-payment.exch-scale).

    END.
    WHEN "tot-cli" then do:
        /*найти tot-base и tot-rubl*/
        assign
        tt-payment.tot-cli = input frame {&frame-name} tt-payment.tot-cli
        tt-payment.tot-rubl = tt-payment.tot-cli / ( input frame {&frame-name} tt-payment.exch-rate /
                                       input frame {&frame-name} tt-payment.exch-scale
                                     )
        tt-payment.tot-base = tt-payment.tot-rubl / ( input frame {&frame-name} tt-payment.base-rate /
                                       input frame {&frame-name} tt-payment.base-scale
                                     )
        .
    END.
    WHEN "base-rate" then do:
        assign
        tt-payment.tot-base = tt-payment.tot-rubl / ( input frame {&frame-name} tt-payment.base-rate /
                                       input frame {&frame-name} tt-payment.base-scale
                                     )
        .

    END.

END CASE.
DISPLAY
tt-payment.tot-cli
tt-payment.tot-base
tt-payment.tot-rubl
with frame {&frame-name}
.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-pay-code Dialog-Frame
PROCEDURE check-pay-code :
find FIRST buf_pay-type where
           buf_pay-type.obj-code = input frame {&frame-name} tt-payment.pay-code no-lock no-error.
if not available buf_pay-type then do:
  message "Нет вида оплаты с таким кодом.".
  apply "entry" TO tt-payment.pay-code in frame {&frame-name}.
  return error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-payer Dialog-Frame
PROCEDURE check-payer :
if input frame {&frame-name} tt-payment.payer-type = ? or
   input frame {&frame-name} tt-payment.payer-type = "" then do:
   if can-find (ub.clients where
                ub.clients.obj-code = input frame {&frame-name} tt-payment.payer-code AND
                ub.clients.obj-type = {&cmp} no-lock) then
    display
    {&cmp} @ tt-payment.cli-type
    with frame {&frame-name}.
    else
    display
    {&prs} @ tt-payment.cli-type with frame {&frame-name}.
end.
find first payer where
          payer.obj-code = input frame {&frame-name} tt-payment.payer-code
     AND payer.obj-type = input frame {&frame-name} tt-payment.payer-type no-error.
if not available payer then do:
  if input frame {&frame-name} tt-payment.payer-code <> ? and
     input frame {&frame-name} tt-payment.payer-type <> ? then
    message "Неправильный код или тип плательщика.".
  apply "entry" to tt-payment.payer-code in frame {&frame-name}.
  return error.
end.
display
payer.obj-type @ tt-payment.payer-type
with frame {&frame-name}.
if payer.obj-type = {&cmp}
and payer.obj-code = p-curr-host-code then do:
  release payer no-error.
  message "Запрещенный код и тип плательщика.".
  apply "entry" to tt-payment.payer-code in frame {&frame-name}.
  return error.
end.
if payer.obj-type = {&shop}
or payer.obj-type = {&stock} then do:
    release payer no-error.
    message "Выберите организацию или человека."
    view-as alert-box.
    apply "entry" to tt-payment.payer-type in frame {&frame-name}.
    return error.
end.
display
payer.obj-name @ payer-name
with frame {&frame-name}.
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
  DISPLAY payer-name pay-type-name exch-code-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE buf_clients THEN
    DISPLAY buf_clients.obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-payment THEN
    DISPLAY tt-payment.fact-date tt-payment.cli-type tt-payment.cli-code
          tt-payment.due-date tt-payment.payer-type tt-payment.payer-code
          tt-payment.status_ tt-payment.pay-code tt-payment.creid
          tt-payment.source-type tt-payment.source-ref tt-payment.closid
          tt-payment.tot-cli tt-payment.exch-code tt-payment.exch-rate
          tt-payment.exch-scale tt-payment.exch-date tt-payment.tot-base
          tt-payment.base-rate tt-payment.base-scale tt-payment.tot-rubl
          tt-payment.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help tt-payment.fact-date tt-payment.due-date
         tt-payment.payer-type tt-payment.payer-code B-payer tt-payment.status_
         tt-payment.pay-code B-pay-code tt-payment.tot-cli tt-payment.exch-code
         B-exch-code tt-payment.exch-rate tt-payment.exch-scale
         tt-payment.exch-date tt-payment.base-rate tt-payment.base-scale
         tt-payment.PS payer-name pay-type-name exch-code-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-table Dialog-Frame
PROCEDURE fill-table :
DEFINE VARIABLE for-tot-cli as decimal No-UNDO.
DEFINE VARIABLE for-tot-base as decimal No-UNDO.
DEFINE VARIABLE for-date-pay as date no-undo.
DEFINE VARIABLE for-fact-date as date no-undo.
DEFINE VARIABLE for-status_ like ub.payment.status_ no-undo.
DEFINE VARIABLE max-for-tot-base as decimal No-UNDO.
DEFINE VARIABLE for-tot-rubl as decimal No-UNDO.
DEFINE VARIABLE v-base-rate as decimal no-undo.
DEFINE VARIABLE v-base-scale as decimal no-undo.
DEFINE VARIABLE v-exch-rate as decimal no-undo.
DEFINE VARIABLE v-exch-scale as decimal no-undo.
DEFINE VARIABLE v-exch-date as date no-undo.
DEFINE VARIABLE for-exch-code like ub.currency.curr-code no-undo.
DEFINE VARIABLE for-pay-code like ub.pay-type.obj-code no-undo.
DEFINE VARIABLE for-sign as decimal no-undo.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-curr-abbr as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE BUFFER buf_sysconf FOR ub.sysconf.

FIND FIRST buf_clients NO-LOCK WHERE
           buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code  No-ERROR.
IF NOT avail buf_clients then do:
    message
    substitute("Не найден контрагент &1&2 для ввода платежа"
              , p-cli-type
              , p-cli-code)
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
END.
IF buf_clients.obj-type = {&stock} OR
   buf_clients.obj-type = {&shop} then do:
    message
    substitute("Неверный тип контрагента &1 для ввода платежа"
                , buf_clients.obj-type )
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
end.
IF buf_clients.obj-code = p-curr-host-code and
   buf_clients.obj-type = {&cmp} then do:
    message
    substitute("Неверный контрагент &1 для ввода платежа"
              , buf_clients.obj-type )
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
end.
{ gbl/basecode.i p-curr-host-code v-base-code }
run cur-time in this-procedure ( output v-today, output v-time).
for-date-pay = v-today.
FIND FIRST buf_currency NO-LOCK WHERE
            buf_currency.curr-code = v-BASE-CODE No-ERROR.
IF NOT AVAIL buf_currency then do:
    message
    substitute("Не найдена валюта с кодом &1 для платежа &2"
                ,v-BASE-CODE
                ,locked_payment.pmnt-code)
    view-as alert-box ERROR.
    p-rid = ?.
    return error.
END.
CASE p-mode:
WHEN {&add-def} then do:
  FIND FIRST payer No-LOCK WHERE
            payer.obj-type = p-cli-type
        and payer.obj-code = p-cli-code No-ERROR.
  CASE psource-type:
    WHEN {&pmnt-ord-doc} then do:
      FIND FIRST buf_ord-doc No-LOCK WHERE
                  buf_ord-doc.doc-code = psource-ref NO-ERROR.
      if not avail buf_ord-doc then do:
        message
        substitute("Не найден заказ с N &1 для платежа"
                    , psource-ref )
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
      end.
      if buf_ord-doc.cli-type <> buf_clients.obj-type OR
      buf_ord-doc.cli-code <> buf_clients.obj-code then do:
        message
        substitute("Неверно выбран документ для платежа:&1" +
                    "Плательщик платежа =&2&3, клиент для заказа = &4&5"
                    ,buf_clients.obj-type
                    ,buf_clients.obj-code
                    ,buf_ord-doc.cli-type
                    ,buf_ord-doc.cli-code
                    )
        view-as alert-box ERROR.
      END.
      if buf_ord-doc.host-code <> p-curr-host-code then do:
          message
          "Выбран заказ чужой фирмы "
          view-as alert-box ERROR.
          return error.
      end.
      if buf_ord-doc.sum-cli = ?
      or buf_ord-doc.sum-cli = 0 then do:
          message "Нельзя создать платеж" skip
                  "сумма по заказу неопределена"
          view-as alert-box.
          return error.
      end.
      if NOT (buf_ord-doc.status_ = {&fact}
              and buf_ord-doc.flag_ = yes) then do:
          message
          substitute("Нельзя создать платеж&1" +
                      "для заказа в статусе &2"
                      , {&NEW-LINE}
                      ,(buf_ord-doc.status_ + string(buf_ord-doc.flag_, "+/-"))
                      )
          view-as alert-box.
          return error.
      end.
      /*
      if ptot-cli = ? or ptot-cli = 0 then do:
          message "Нельзя создать платеж" skip
                  "сумма неопределена"
          view-as alert-box.
          return error.
      end.
       */
      /*в заказах суммы шапки должны быть в base ?*/
      ASSIGN
      for-sign = (if (buf_ord-doc.doc-type = {&p-o})
                  then -1
                  else 1)
      for-tot-cli = for-sign * (buf_Ord-doc.sum-cli + buf_Ord-doc.sum-ship +  buf_ord-doc.Sum-service)
      for-exch-code = buf_ord-doc.exch-code
      v-base-rate = buf_ord-doc.base-rate
      v-base-scale = buf_ord-doc.base-scale
      v-exch-rate = buf_ord-doc.exch-rate
      v-exch-scale = buf_ord-doc.exch-scale
      v-exch-date = buf_ord-doc.exch-date
      for-pay-code = (if buf_ord-doc.pay-code <> ?
                      then buf_ord-doc.pay-code
                      else ?)
      for-date-pay = (if buf_ord-doc.date-pay <> ?
                      then buf_ord-doc.date-pay
                      else for-date-pay)
      for-status_ = {&expected}
      for-fact-date = ?
      .
    END.
    when {&table_payment} then do:
      FIND FIRST buf_sysconf NO-LOCK WHERE
                buf_sysconf.host-code = p-curr-host-code .
      FIND FIRST buf_pay-type NO-LOCK WHERE
                buf_pay-type.obj-code = buf_sysconf.ret-credit-pay NO-ERROR.
      IF NOT AVAILABLE buf_pay-type THEN DO:
        MESSAGE
        substitute("Неверно определен код оплаты для возврата кредита для фирмы &1"
                   , p-curr-host-code)
        VIEW-AS ALERT-BOX ERROR.
        p-rid = ?.
        UNDO, RETURN ERROR.
      END.
      for-pay-code = buf_pay-type.obj-code.
      FIND FIRST buf_dis-card No-LOCK WHERE
                  buf_dis-card.d-card = p-d-card NO-ERROR.
      if not avail buf_dis-card then do:
          message
          substitute("Не найдена дисконтная карта с номером &1"
                      ,p-d-card)
          view-as alert-box ERROR.
          p-rid = ?.
          return error.
      end.
      if buf_dis-card.cli-type <> buf_clients.obj-type OR
          buf_dis-card.cli-code <> buf_clients.obj-code then do:
          message
          "Неверно выбрана карта для платежа "
          view-as alert-box ERROR.
      END.
      if buf_dis-card.emitent-host-code <> p-curr-host-code
      AND buf_dis-card.emitent-host-code <> 0 then do:
          message
          "Выбрана карта чужой фирмы "
          view-as alert-box ERROR.
          return error.
      end.
      if buf_dis-card.status_ = {&blocked-status}
      OR buf_dis-card.status_ = {&deleted-status} then do:
          message
          substitute("Нельзя создать платеж&1" +
                      "для карты в статусе &2"
                      ,{&NEW-LINE}
                      ,buf_dis-card.status_)
          view-as alert-box.
          return error.
      end.
      run cur-time in this-procedure( output v-today, output v-time).
      { gbl/exchrate.i v-base-code v-today v-base-rate v-base-scale v-curr-abbr }
      { gbl/curr-r-b.i v-curr-r-b }
      if v-curr-r-b = {&r-b-rubl} then do:
        assign
        for-exch-code = 0
        v-exch-rate = 1
        v-exch-scale = 1
        .
      end.
      else do:
        assign
        for-exch-code = v-base-code
        v-exch-rate   = v-base-rate
        v-exch-scale = v-base-scale
        .
      end.
      assign
      v-exch-date = v-today
      for-date-pay = v-today
      FOR-fact-date = v-today
      for-tot-cli = 0
      for-status_ = {&fact}
      .
    end. /*when {&table_payment}*/
  END CASE.
  assign
  for-tot-rubl = for-tot-cli / ( v-exch-rate / v-exch-scale)
  for-tot-base = for-tot-rubl / (v-base-rate / v-base-scale)
  .
  if for-pay-code <> ? then do:
      FIND FIRST buf_pay-type where
                  buf_pay-type.obj-code = for-pay-code No-ERROR.
      IF NOT avail buf_pay-type then do:
          message
          substitute("Не найден вид оплаты с кодом &1"
                      ,for-pay-code)
          view-as alert-box ERROR.
          p-rid = ?.
          return error.
      END.
      for-pay-name = buf_pay-type.obj-name.
  end.
  CREATE tt-payment.
  ASSIGN
  tt-payment.host-code = p-curr-host-code
  tt-payment.payer-type = payer.obj-type
  tt-payment.payer-code = payer.obj-code
  tt-payment.cli-type = buf_clients.obj-type
  tt-payment.cli-code = buf_clients.obj-code
  tt-payment.pay-code = for-pay-code
  tt-payment.tot-cli  = for-tot-cli
  tt-payment.exch-code = for-exch-code
  tt-payment.base-rate = v-base-rate
  tt-payment.base-scale = v-base-scale
  tt-payment.exch-rate = v-exch-rate
  tt-payment.exch-scale = v-exch-scale
  tt-payment.exch-date = v-exch-date
  tt-payment.due-date = for-date-pay
  tt-payment.STATUS_ = for-status_
  tt-payment.fact-date = for-fact-date
  tt-payment.source-ref = psource-ref
  tt-payment.source-type = (if psource-type = {&table_payment}
                            then '':U
                            else psource-type)
  tt-payment.creid = v-cntxt-userid
  tt-payment.closid = (if psource-type = {&table_payment}
                       then v-cntxt-userid
                       else '':U)
  .
END. /*{&add-def}*/
otherwise /* {&update} {&lookup} */ do:
    FIND FIRST locked_payment where
               recid(locked_payment) = p-rid No-ERROR.
    IF NOT avail locked_payment then do:
        message "Не найден платеж"
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    end.
    if locked_payment.status_ =  {&fact} then do:
        message
        substitute("Нельзя редактировать платеж в статусе &1"
                   ,LOCKED_payment.status_)
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    END.
    IF locked_payment.host-code <> p-curr-host-code then do:
      message "Выбран платеж другой фирмы"
      view-as alert-box ERROR.
      p-rid = ?.
      return error.
    end.
    FIND FIRST payer No-LOCK WHERE
               payer.obj-type = locked_payment.payer-type AND
               payer.obj-code = locked_payment.payer-code No-ERROR.
    IF NOT AVAIL PAYER then do:
        message
        substitute("Не найден плательщик &1&2 для платежа &3"
                   ,LOCKED_payment.payer-type
                   ,locked_payment.payer-code
                   ,locked_payment.pmnt-code )

        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    END.
    FIND FIRST buf_currency NO-LOCK WHERE
               buf_currency.curr-code = locked_payment.exch-code No-ERROR.
    IF NOT AVAIL buf_currency then do:
        message
        substitute("Не найдена валюта с кодом &1 для платежа &2"
                  ,locked_payment.exch-code
                ,locked_payment.pmnt-code)
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    END.
    FIND FIRST buf_pay-type No-LOCK WHERE
               buf_pay-type.obj-code = locked_payment.pay-code No-ERROR.
    if not avail buf_pay-type then do:
        message
        substitute("Не найден вид оплаты с кодом &1 для платежа &2"
                   ,locked_payment.pay-code
                   ,locked_payment.pmnt-code)
        view-as alert-box ERROR.
        p-rid = ?.
        return error.
    end.
    CREATE tt-payment.
    BUFFER-COPY LOCKED_payment TO tt-payment
    .
    CASE psource-type:
      when {&pmnt-ord-doc} then do:
        FIND FIRST buf_ord-doc No-LOCK WHERE
                    buf_ord-doc.doc-code = psource-ref NO-ERROR.
        if not avail buf_ord-doc then do:
            message
            substitute("Не найден заказ с N &1 для платежа"
                       ,psource-ref )
            view-as alert-box ERROR.
            p-rid = ?.
            return error.
        end.
        frame {&frame-name}:title = substitute("&1 N &1 к заказу &3"
                                               ,frame {&frame-name}:title
                                               ,locked_payment.pmnt-code
                                               ,buf_ord-doc.doc-code).


      END.
    END CASE.
END.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-curr-chk Dialog-Frame
PROCEDURE local-curr-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "exch-code" and p-action = "ret-mouse" then do:
   { ref/curr-chk.i exch-code ret-mouse tt-payment }
end.
if p-man = "exch-code" and p-action = "button" then do:
   { ref/curr-chk.i exch-code button tt-payment }
end.
if p-man = "exch-code" and p-action = "leave" then do:
   { ref/curr-chk.i exch-code leave tt-payment }
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Myenable Dialog-Frame
PROCEDURE Myenable :
assign
tt-payment.tot-rubl :label in frame {&frame-name} = "Сумма ({&abbr_rub})"
.
{ ref/curr-chk.i exch-code on tt-payment }
CASE psource-type:
  WHEN {&pmnt-ord-doc} THEN DO:
    assign
    frame {&frame-name}:title = substitute("&1  к заказу &2"
                                                ,frame {&frame-name}:title
                                                ,buf_ord-doc.doc-code).


  END.
  WHEN {&table_payment} THEN DO:
      ASSIGN
      frame {&frame-name}:title = substitute("&1 к карте &2"
                                        ,frame {&frame-name}:title
                                        ,buf_dis-card.d-card).

  END.
END CASE.
DISPLAY
tt-payment.cli-type
tt-payment.cli-code
buf_clients.obj-name
tt-payment.payer-type
tt-payment.payer-code
payer.obj-name @ payer-name
tt-payment.pay-code
for-pay-name @ pay-type-name
tt-payment.fact-date
tt-payment.due-date
tt-payment.status_
tt-payment.exch-code
tt-payment.exch-date
tt-payment.base-rate
tt-payment.base-scale
tt-payment.exch-rate
tt-payment.exch-scale
tt-payment.source-type
tt-payment.tot-cli
tt-payment.tot-base
tt-payment.tot-rubl
tt-payment.creid
tt-payment.closid
tt-payment.PS
WITH FRAME {&frame-name}.
ENABLE
B-exit WHEN p-mode <> {&LOOKUP}
b-quit
B-Help
tt-payment.payer-type when p-mode <> {&lookup}
tt-payment.payer-code when p-mode <> {&lookup}
B-payer when p-mode <> {&lookup}
tt-payment.pay-code when p-mode <> {&lookup}
B-pay-code when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.due-date when p-mode <> {&lookup} AND tt-payment.status_ = {&expected}
tt-payment.tot-cli when p-mode <> {&lookup}
tt-payment.exch-rate when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.exch-date when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.exch-code when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
B-exch-code when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.exch-scale when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.base-rate when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.base-scale when p-mode <> {&lookup} AND NOT psource-type = {&table_payment}
tt-payment.PS when p-mode <> {&lookup}
WITH FRAME {&frame-name}.
CASE psource-type:
  when {&pmnt-ord-doc} then do:
    DISABLE
    tt-payment.exch-code
    tt-payment.base-rate
    tt-payment.base-scale
    tt-payment.exch-rate
    tt-payment.exch-code
    tt-payment.pay-code
    tt-payment.exch-date
    WITH FRAME {&frame-name}.
  end.
END.
VIEW FRAME {&Frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame 
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
define buffer buf_payment for ub.payment.
ASSIGN
FRAME {&FRAME-NAME}
tt-payment.due-date
tt-payment.payer-type = payer.obj-type
tt-payment.payer-code = payer.obj-code
tt-payment.tot-cli
tt-payment.PS
tt-payment.exch-date
tt-payment.exch-code
tt-payment.exch-rate
tt-payment.exch-scale
tt-payment.base-rate
tt-payment.base-scale
tt-payment.tot-base
tt-payment.tot-rubl
tt-payment.source-type
tt-payment.source-ref
tt-payment.d-card = p-d-card
tt-payment.fact-date = tt-payment.fact-date
tt-payment.creid = v-cntxt-userid
tt-payment.closid = (if tt-payment.status_ = {&fact}
                 then v-cntxt-userid
                 else "")
tt-payment.pay-code
v-rid = (if p-mode = {&update} then p-rid else ?)
.
main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run ref/payment1.p (
                    input p-mode
                   ,input  no /*p-silent*/
                   ,input-output tt-payment.pmnt-code
                   ,input tt-payment.cli-type
                   ,input tt-payment.cli-code
                   ,input tt-payment.payer-type
                   ,input tt-payment.payer-code
                   ,input tt-payment.host-code
                   ,input tt-payment.tot-cli
                   ,input tt-payment.tot-base
                   ,input tt-payment.tot-rubl
                   ,input tt-payment.exch-date
                   ,input tt-payment.exch-code
                   ,input tt-payment.exch-rate
                   ,input tt-payment.exch-scale
                   ,input tt-payment.base-rate
                   ,input tt-payment.base-scale
                   ,input tt-payment.due-date
                   ,input tt-payment.fact-date
                   ,input tt-payment.source-type
                   ,input tt-payment.source-ref
                   ,input tt-payment.d-card
                   ,input tt-payment.pay-code
                   ,input tt-payment.status_
                   ,input tt-payment.PS
                   ,INPUT tt-payment.creid
                   ,INPUT tt-payment.closid
                   ) no-error .
  if error-status:error then do:
  { gbl/reterhnd.i error }
    message error-status:get-message(1) skip
    return-value view-as alert-box .
    undo main-block, return error.
  end.
  find first buf_payment no-lock where
            buf_payment.pmnt-code = tt-payment.pmnt-code no-error.
  if not available buf_payment then do:
    message
    "Не удается найти созданный платеж"
    view-as alert-box error .
    undo, return error.
  end.
  if (psource-type = {&table_payment}
     or
     psource-type = {&pmnt-fin-doc} )
  and p-d-card <> '':U then do:
    run str/saledc.p
      (
      input parparentproc
      ,input this-procedure :handle
      ,input ? /*p-log-handle*/
      ,input {&dct-proc_payment-on-card}
      ,input ? /*p-emitent-host-code*/
      ,input "" /*p-type*/
      ,input 0 /*p-profile-id*/
      ,input 0 /*p-codex-id*/
      ,input 0 /*p-ruleset-id*/
      ,input v-cntxt-db-num
      ,input buf_payment.pmnt-code
      ,input buf_payment.exch-date
      ,input buf_payment.fact-date
      ,input 0 /*cre-pay*/
      ,input 1 /*par-sign*/
      ,input ? /*par-direction*/
      ,input yes /*p-save*/
      ) no-error .
    if error-status:error then do:
      message error-status:get-message(1) skip
      return-value view-as alert-box .
      undo main-block, return error return-value .
    end.
  end.
  p-rid = recid(buf_payment).
end. /*doe*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

