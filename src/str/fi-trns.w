&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр списка складских документов по фин.обязательству

Автор: Чернова Светлана Александровна
Дата создания: 11/01/05
Author: Svetlana Chernova
Creation date: 11/01/05

Просмотр списка складских документов по fin-ob-trn
Creation date: 01/09/04 1:45


*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр списка складских документов по фин.обязательству".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ rep/gn-extp.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter par-host-code  like ub.clients.obj-code no-undo.
define input parameter p-fin-ob-doc-code like ub.fin-ob.doc-code no-undo.
define input parameter p-fin-ob-trn-doc  like ub.fin-ob.trn-doc-code no-undo.
define input parameter p-mode as character no-undo .

/* Local Variable Definitions ---                                       */
define new shared variable next-prev as logical no-undo .
define new shared variable br-handle as handle  no-undo .

define new shared buffer buf_fin-liab for ub.fin-ob .
define new shared buffer buf_fin-liab-before for ub.fin-ob-before .
define new shared buffer bufs_ord-doc-rcv for ub.ord-doc-rcv.
define new shared variable br-rcv-handle as handle no-undo   .

define variable v-U            AS char NO-UNDO.


define variable v-ext-doc-type AS CHAR NO-UNDO.
define variable v-doc-date  like ub.trn-doc.doc-date  NO-UNDO.
define variable v-fact-date like ub.trn-doc.fact-date NO-UNDO.
define variable v-cli-name  like ub.trn-doc.cli-name  NO-UNDO.
define variable v-fact-fo   like ub.fin-ob.sum-rubl   NO-UNDO.
define variable v-fact-qnty like ub.trn-doc.doc-qnty NO-UNDO.
define variable v-fact-rubl like ub.trn-doc.tot-fact NO-UNDO.
define variable v-creid     like ub.trn-doc.creid     NO-UNDO.
define variable v-fact-time as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES fin-ob-trn trn-doc c-trn-doc ord-doc add-doc ~
ord-doc-rcv

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 v-U @ v-U fin-ob-trn.trn-doc-code fin-ob-trn.doc-code fin-ob-trn.sum-rubl v-ext-doc-type @ v-ext-doc-type v-doc-date @ v-doc-date v-fact-date @ v-fact-date v-cli-name @ v-cli-name v-fact-rubl @ v-fact-rubl v-creid @ v-creid v-fact-time @ v-fact-time
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH fin-ob-trn WHERE                                  fin-ob-trn.doc-code = p-fin-ob-doc-code  NO-LOCK, ~
             EACH trn-doc WHERE            trn-doc.doc-code = fin-ob-trn.trn-doc-code AND            fin-ob-trn.doc-type  = ""  OUTER-JOIN NO-LOCK, ~
             EACH c-trn-doc WHERE            c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and            c-trn-doc.is-del = yes AND            fin-ob-trn.doc-type  = "" OUTER-JOIN NO-LOCK, ~
             FIRST ord-doc WHERE             ord-doc.doc-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "order" OUTER-JOIN NO-LOCK, ~
             FIRST add-doc WHERE             add-doc.doc-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "add" OUTER-JOIN NO-LOCK, ~
              FIRST ord-doc-rcv WHERE             ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "rcv" OUTER-JOIN NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH fin-ob-trn WHERE                                  fin-ob-trn.doc-code = p-fin-ob-doc-code  NO-LOCK, ~
             EACH trn-doc WHERE            trn-doc.doc-code = fin-ob-trn.trn-doc-code AND            fin-ob-trn.doc-type  = ""  OUTER-JOIN NO-LOCK, ~
             EACH c-trn-doc WHERE            c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and            c-trn-doc.is-del = yes AND            fin-ob-trn.doc-type  = "" OUTER-JOIN NO-LOCK, ~
             FIRST ord-doc WHERE             ord-doc.doc-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "order" OUTER-JOIN NO-LOCK, ~
             FIRST add-doc WHERE             add-doc.doc-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "add" OUTER-JOIN NO-LOCK, ~
              FIRST ord-doc-rcv WHERE             ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code AND             fin-ob-trn.doc-type  = "rcv" OUTER-JOIN NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 fin-ob-trn trn-doc c-trn-doc ~
ord-doc add-doc ord-doc-rcv
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 fin-ob-trn
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1 trn-doc
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-1 c-trn-doc
&Scoped-define FOURTH-TABLE-IN-QUERY-BROWSE-1 ord-doc
&Scoped-define FIFTH-TABLE-IN-QUERY-BROWSE-1 add-doc
&Scoped-define SIXTH-TABLE-IN-QUERY-BROWSE-1 ord-doc-rcv


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 ~
var-ps FILL-IN-1 v-U-full FILL-IN_prn-doc-code FILL-IN_status_ ~
FILL-IN_user-name-doc FILL-IN_fin-doc-type FILL-IN_user-name-fact ~
FILL-IN_doc-date FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code ~
FILL-IN_sum-doc FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code ~
FILL-IN_doc-type FILL-IN_contract-type FILL-IN_usl-opl FILL-IN-sr-op ~
FILL-IN_srok-opl
&Scoped-Define DISPLAYED-OBJECTS var-ps FILL-IN-1 v-U-full ~
FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc ~
FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date ~
FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc ~
FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type ~
FILL-IN_contract-type FILL-IN_usl-opl FILL-IN-sr-op FILL-IN_srok-opl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "&Документ"
     SIZE 10 BY 1 TOOLTIP "Просмотр складского документа".

DEFINE BUTTON B-lkp-2
     LABEL "&Фин.Обяз."
     SIZE 10 BY 1 TOOLTIP "Просмотр ФО или ПФО".

DEFINE BUTTON B-lkp-3
     LABEL "&Договор"
     SIZE 10 BY 1 TOOLTIP "Просмотр Договора".

DEFINE VARIABLE var-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 56.5 BY 2.5 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Финансовое обязательство:"
      VIEW-AS TEXT
     SIZE 26 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Договор:"
      VIEW-AS TEXT
     SIZE 26 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-sr-op AS CHARACTER FORMAT "X(256)":U INITIAL "Срок оплаты:"
      VIEW-AS TEXT
     SIZE 11.88 BY .67 NO-UNDO.

DEFINE VARIABLE FILL-IN_contract-prn-code AS CHARACTER FORMAT "X(16)"
     LABEL "№ договора"
      VIEW-AS TEXT
     SIZE 17 BY .67.

DEFINE VARIABLE FILL-IN_contract-type AS CHARACTER FORMAT "X(20)"
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 21.5 BY .67.

DEFINE VARIABLE FILL-IN_curr-code AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 5.38 BY .67
     FGCOLOR 4 .

DEFINE VARIABLE FILL-IN_doc-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата ФО"
      VIEW-AS TEXT
     SIZE 11 BY .67.

DEFINE VARIABLE FILL-IN_doc-type AS CHARACTER FORMAT "X(4)"
     LABEL "Вид"
      VIEW-AS TEXT
     SIZE 5 BY .67.

DEFINE VARIABLE FILL-IN_fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 11 BY .67.

DEFINE VARIABLE FILL-IN_fin-doc-type AS CHARACTER FORMAT "X(14)"
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 37.38 BY .67.

DEFINE VARIABLE FILL-IN_pay-date AS DATE FORMAT "99/99/9999"
     LABEL "Платеж"
      VIEW-AS TEXT
     SIZE 11 BY .67.

DEFINE VARIABLE FILL-IN_prn-doc-code AS CHARACTER FORMAT "X(16)"
     LABEL "№"
      VIEW-AS TEXT
     SIZE 17 BY .67.

DEFINE VARIABLE FILL-IN_srok-opl AS INTEGER FORMAT "->,>>>" INITIAL 0
      VIEW-AS TEXT
     SIZE 3.75 BY .67.

DEFINE VARIABLE FILL-IN_status_ AS CHARACTER FORMAT "X(8)"
     LABEL "Статус ФО"
      VIEW-AS TEXT
     SIZE 9 BY .67.

DEFINE VARIABLE FILL-IN_sum-doc AS DECIMAL FORMAT "->,>>>,>>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма"
      VIEW-AS TEXT
     SIZE 22 BY .67 TOOLTIP "Сумма в ценах документа".

DEFINE VARIABLE FILL-IN_sum-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL 0
     LABEL "Сумма "
      VIEW-AS TEXT
     SIZE 22 BY .67.

DEFINE VARIABLE FILL-IN_user-name-doc AS CHARACTER FORMAT "X(8)"
     LABEL "Создал"
      VIEW-AS TEXT
     SIZE 9 BY .67.

DEFINE VARIABLE FILL-IN_user-name-fact AS CHARACTER FORMAT "X(8)"
     LABEL "Закрыл"
      VIEW-AS TEXT
     SIZE 9 BY .67.

DEFINE VARIABLE FILL-IN_usl-opl AS CHARACTER FORMAT "X(40)"
     LABEL "Условия"
      VIEW-AS TEXT
     SIZE 40.63 BY .67.

DEFINE VARIABLE v-U-full AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 48 BY .67
     FGCOLOR 12  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
    fin-ob-trn,
    trn-doc,
    c-trn-doc,
    ord-doc,
    add-doc,
    ord-doc-rcv
    SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 NO-LOCK DISPLAY
      v-U @ v-U COLUMN-LABEL "У" FORMAT "x(1)":U
      fin-ob-trn.trn-doc-code COLUMN-LABEL "№ документа" FORMAT "X(14)":U
      fin-ob-trn.doc-code FORMAT "X(16)":U
      fin-ob-trn.sum-rubl COLUMN-LABEL "Сумма ФО" FORMAT "->,>>>,>>>,>>>,>>9.99":U
      WIDTH 12
      v-ext-doc-type @ v-ext-doc-type COLUMN-LABEL "Тип!документа" FORMAT "x(15)":U
      v-doc-date @ v-doc-date COLUMN-LABEL "Дата!документа" FORMAT "99/99/99":U
      v-fact-date @ v-fact-date COLUMN-LABEL "Факт" FORMAT "99/99/99":U
      v-cli-name @ v-cli-name COLUMN-LABEL "Контрагент" FORMAT "X(40)":U
            WIDTH 30
/*      v-fact-qnty @ v-fact-qnty COLUMN-LABEL "Фактически" FORMAT "->>,>>>,>>9.<<<":U*/
/*            WIDTH 12                                                                */
      v-fact-rubl @ v-fact-rubl COLUMN-LABEL "Сумма докум." FORMAT "->,>>>,>>>,>>>,>>9.99":U
      v-creid @ v-creid COLUMN-LABEL "Создал!документ" FORMAT "X(8)":U
      v-fact-time @ v-fact-time COLUMN-LABEL "Время" FORMAT "x(5)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 94.5 BY 12.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-lkp AT ROW 1 COL 11
     B-lkp-2 AT ROW 1 COL 21
     B-lkp-3 AT ROW 1 COL 31
     B-Help AT ROW 1.04 COL 85.75
     BROWSE-1 AT ROW 2.25 COL 1
     var-ps AT ROW 18.5 COL 38.5 NO-LABEL
     FILL-IN-1 AT ROW 14.96 COL 1.38 NO-LABEL
     v-U-full AT ROW 15 COL 45 COLON-ALIGNED NO-LABEL
     FILL-IN_prn-doc-code AT ROW 15.71 COL 13.25 COLON-ALIGNED
     FILL-IN_status_ AT ROW 15.71 COL 42 COLON-ALIGNED
     FILL-IN_user-name-doc AT ROW 15.71 COL 65.5 COLON-ALIGNED
     FILL-IN_fin-doc-type AT ROW 16.63 COL 13.5 COLON-ALIGNED
     FILL-IN_user-name-fact AT ROW 16.63 COL 65.5 COLON-ALIGNED
     FILL-IN_doc-date AT ROW 17.54 COL 13.25 COLON-ALIGNED
     FILL-IN_fact-date AT ROW 17.54 COL 32.63 COLON-ALIGNED
     FILL-IN_pay-date AT ROW 18.38 COL 13.25 COLON-ALIGNED
     FILL-IN_curr-code AT ROW 19.25 COL 2.25 NO-LABEL
     FILL-IN_sum-doc AT ROW 19.29 COL 13.13 COLON-ALIGNED
     FILL-IN_sum-rubl AT ROW 20.17 COL 13.13 COLON-ALIGNED
     FILL-IN-2 AT ROW 20.88 COL 1.25 NO-LABEL
     FILL-IN_contract-prn-code AT ROW 21.58 COL 12.25 COLON-ALIGNED
     FILL-IN_doc-type AT ROW 21.58 COL 35.25 COLON-ALIGNED
     FILL-IN_contract-type AT ROW 22.46 COL 5.38 COLON-ALIGNED
     FILL-IN_usl-opl AT ROW 22.46 COL 36 COLON-ALIGNED
     FILL-IN-sr-op AT ROW 22.46 COL 77 COLON-ALIGNED NO-LABEL
     FILL-IN_srok-opl AT ROW 22.46 COL 89.13 COLON-ALIGNED NO-LABEL
     SPACE(0.87) SKIP(0.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Накладные по фин.обязательству".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.

/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN-2 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN FILL-IN_curr-code IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       var-ps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH fin-ob-trn WHERE
                                 fin-ob-trn.doc-code = p-fin-ob-doc-code  NO-LOCK,
      EACH trn-doc WHERE
           trn-doc.doc-code = fin-ob-trn.trn-doc-code AND
           fin-ob-trn.doc-type  = ""  OUTER-JOIN NO-LOCK,
      EACH c-trn-doc WHERE
           c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and
           c-trn-doc.is-del = yes AND
           fin-ob-trn.doc-type  = "" OUTER-JOIN NO-LOCK,
      FIRST ord-doc WHERE
            ord-doc.doc-code = fin-ob-trn.trn-doc-code AND
            fin-ob-trn.doc-type  = "order" OUTER-JOIN NO-LOCK,
      FIRST add-doc WHERE
            add-doc.doc-code = fin-ob-trn.trn-doc-code AND
            fin-ob-trn.doc-type  = "add" OUTER-JOIN NO-LOCK,

      FIRST ord-doc-rcv WHERE
            ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code AND
            fin-ob-trn.doc-type  = "rcv" OUTER-JOIN NO-LOCK.
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE QUERY BROWSE-1 FOR
    fin-ob-trn,
    trn-doc,
    c-trn-doc,
    ord-doc,
    add-doc,
    ord-doc-rcv
    SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Накладные по фин.обязательству */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Документ */
DO:
define variable v-r as recid no-undo .
if not available fin-ob-trn then return no-apply .

    case  fin-ob-trn.doc-type :
    when "" then do:
      find  first trn-doc  where trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = ""  no-lock no-error .
      IF AVAILABLE trn-doc THEN
      run str/fishdoc.p (  parparentproc,
                    par-host-code ,
                    trn-doc.obj-type,
                    trn-doc.obj-code,
                    trn-doc.doc-code , ? ) .

      else do:
      find first c-trn-doc WHERE
                 c-trn-doc.is-del = yes and
                 c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "" no-lock no-error .
      if available c-trn-doc then do:
        run str/c-doc.w ( input parparentproc, input c-trn-doc.doc-code, input c-trn-doc.chip-num ).
      end.
                end.
    end.

    when "order" then do:
      find first ord-doc WHERE ord-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "order"    NO-LOCK no-error .
      if available ord-doc then do:
          run cus/show-ord.p ( input parParentProc, input recid(ord-doc) ).
      end.
    end.

    when "rcv" then do:
      find first ord-doc-rcv WHERE ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "rcv" no-lock no-error .
      if available ord-doc-rcv then do:
          v-r = recid(ord-doc-rcv) .
          run cus/lkp-rcv.w (
              input parParentProc,
              input-output v-r
              ).
      end.
    end.
    when "add" then do:
        find first add-doc no-lock where add-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "add" no-error .
        if available add-doc then do:
          v-r = recid(add-doc) .
          run str/add-docu.w ( input parparentproc  ,
                               input-output v-r ,
                               input {&lookup}  ,
                               input ?
                               ).
        end.
    end.
    end case.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp-2 Dialog-Frame
ON CHOOSE OF B-lkp-2 IN FRAME Dialog-Frame /* Фин.Обяз. */
DO:
   if not available  fin-ob-trn then return .
define variable p-doc-type   as character no-undo .
define variable  p-status_   as character no-undo .

define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define variable g-log as logical no-undo .

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_fin-liability_lookup':U
  {&cntxt-firm}
  par-host-code
  '':U
  0
  0
  0
  0
  true
  g-log
}
if not g-log then  return .
define variable rr as recid no-undo .


find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .
    if available buf_fin-ob then do:
        rr = recid( buf_fin-ob ).
        p-doc-type = buf_fin-ob.doc-type .
        p-status_  = buf_fin-ob.status_  .
        br-handle = ? .
        next-prev = ? .
        find first buf_fin-liab no-lock where recid(buf_fin-liab) = rr no-error .
        run str/fi-liabi.w ( parParentProc, {&lookup} , input-output rr , input par-host-code  , input p-doc-type, input p-status_).

     end.
   else do:
   /* ПФО */
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
        rr = recid( buf_fin-ob-before ).
        p-doc-type = buf_fin-ob-before.doc-type .
        p-status_  = buf_fin-ob-before.status_  .
        br-handle = ? .
        next-prev = ? .
        find first buf_fin-liab-before no-lock where recid(buf_fin-liab-before) = rr no-error .
        run str/fi-liabb.w ( parParentProc, {&lookup} , input-output rr , input par-host-code  , input p-doc-type, input p-status_).
        if br-handle = ? then reposition {&browse-name} to recid rr no-error.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp-3 Dialog-Frame
ON CHOOSE OF B-lkp-3 IN FRAME Dialog-Frame /* Договор */
DO:
define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define buffer b_contract for contract .
define variable loc_contract-code as integer no-undo .

if not available fin-ob-trn then return .


find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .

if available buf_fin-ob then do:
      loc_contract-code = buf_fin-ob.contract-code .
end.
else do:
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
      loc_contract-code = buf_fin-ob-before.contract-code .
end.

define variable ri as recid no-undo .

find first b_contract no-lock  where b_contract.contract-code = loc_contract-code and
                                     b_contract.host-code     = par-host-code
                                     no-error .
if error-status :error then return no-apply.

ri = recid (b_contract) .
run str/sh-contr.p (
  input   parParentProc ,
  input  ri      )
  .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1 IN FRAME Dialog-Frame
DO:

define buffer buf1_fin-ob for ub.fin-ob  .

case  fin-ob-trn.doc-type :
when "" then do:
     find  first trn-doc  WHERE trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = ""  no-lock no-error .
      IF AVAILABLE trn-doc THEN
          ASSIGN
          v-U = " "
          v-ext-doc-type = func-get-name-from-ext-type(trn-doc.ext-doc-type,no)
          v-doc-date  = trn-doc.doc-date
          v-fact-date = trn-doc.fact-date
          v-cli-name  = trn-doc.cli-name
          v-fact-qnty = trn-doc.doc-qnty
          v-fact-rubl = trn-doc.tot-fact
          v-creid     = trn-doc.creid
          v-fact-time =  string(trn-doc.fact-time,"hh:mm")
          .
  ELSE DO:
     find first c-trn-doc WHERE c-trn-doc.is-del = yes and c-trn-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "" no-lock no-error .
        IF AVAILABLE c-trn-doc THEN DO:
            ASSIGN
            v-U = "+"
            v-ext-doc-type = func-get-name-from-ext-type(c-trn-doc.ext-doc-type,no)
            v-doc-date  = c-trn-doc.doc-date
            v-fact-date = c-trn-doc.fact-date
            v-cli-name  = c-trn-doc.cli-name
            v-fact-qnty = c-trn-doc.doc-qnty
            v-fact-rubl = c-trn-doc.tot-fact
            v-creid     = c-trn-doc.creid
            v-fact-time =  string(c-trn-doc.fact-time,"hh:mm")
            .
        END.
    END.

end.
when "order" then do:
   find first ord-doc WHERE ord-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "order"    NO-LOCK no-error .
   if available ord-doc then
      ASSIGN
      v-U = " "
      v-ext-doc-type = {&pmnt-ord-doc}
      v-doc-date  = ord-doc.doc-date
      v-fact-date = ord-doc.fact-date
      v-cli-name  = ord-doc.cli-name
      v-fact-qnty = ord-doc.qnty
      v-fact-rubl = ord-doc.sum-rubl
      v-creid     = ord-doc.creid
      v-fact-time =  string(ord-doc.fact-time,"hh:mm")
      .

end.

when "rcv" then do:
   find    first ord-doc-rcv WHERE ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "rcv" no-lock no-error .
      if available ord-doc-rcv then
      ASSIGN
      v-U = " "
      v-ext-doc-type = {&ord-rcv}
      v-doc-date  = ord-doc-rcv.doc-date
      v-fact-date = ord-doc-rcv.fact-date
      v-creid     = ord-doc-rcv.creid
      v-fact-time =  string(ord-doc-rcv.fact-time,"hh:mm")      .

      define buffer buf_clients for ub.clients  .
      define buffer buf_ord-line-rcv for ub.ord-line-rcv  .

      find first buf_clients no-lock where buf_clients.obj-code =   ord-doc-rcv.cli-code and
                                           buf_clients.obj-type =   ord-doc-rcv.cli-type no-error .
      if available buf_clients then v-cli-name = buf_clients.obj-name .
                               else v-cli-name = "".
      v-fact-qnty = 0 .
      v-fact-rubl = 0 .
       for each buf_ord-line-rcv no-lock where buf_ord-line-rcv.rcv-code = ord-doc-rcv.rcv-code and
                                               buf_ord-line-rcv.doc-code = ord-doc-rcv.doc-code :
              v-fact-qnty = v-fact-qnty +  buf_ord-line-rcv.qnty .
              v-fact-rubl = v-fact-rubl +  buf_ord-line-rcv.sum-rubl .
       end.

end.
when "add" then do:
   find first add-doc no-lock where
              add-doc.doc-code    =  fin-ob-trn.trn-doc-code and
              fin-ob-trn.doc-type =  "add"
              no-error .
   find first buf1_fin-ob no-lock where
              buf1_fin-ob.doc-code    =  fin-ob-trn.doc-code and
              fin-ob-trn.doc-type =  "add"
              no-error .
   if not available buf1_fin-ob then do:
      message
        error-status :get-message(1) skip
        return-value skip
        "Не найдено ФО"
        view-as alert-box error
      .
   end.

   if available add-doc then do:
      assign
        v-u = " "
        v-ext-doc-type = 'ДопРасход'
        v-doc-date  = add-doc.doc-date
        v-fact-date = add-doc.fact-date
        v-cli-name  = buf1_fin-ob.receiver-name
        v-fact-qnty = ?
        v-fact-rubl = add-doc.sum-rubl
        v-creid     = add-doc.creid
        v-fact-time =  string(add-doc.fact-time,"hh:mm")
        .
    end.
    else do:
      /* TODO истории нет */
      find first c-add-doc WHERE c-add-doc.doc-code = fin-ob-trn.trn-doc-code and fin-ob-trn.doc-type = "add" and c-add-doc.is-del = true    NO-LOCK no-error .
      if available c-add-doc then do:
      assign
        v-doc-date  = c-add-doc.doc-date
        v-fact-date = c-add-doc.fact-date
        v-fact-rubl = c-add-doc.sum-rubl
        v-creid     = c-add-doc.creid
        v-fact-time =  string(c-add-doc.fact-time,"hh:mm")
        .
       end.
       Assign
        v-U = " "
        v-ext-doc-type = 'ДопРасх-УДАЛЕН'
        v-cli-name  = '---'
        v-fact-qnty = 0
        .

    end.
end.

end case.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
/* то что видно внизу экрана */
if not available fin-ob-trn  then return.
define buffer buf_fin-ob   for fin-ob .
define buffer buf_fin-ob-before   for fin-ob-before  .
define buffer buf_contract for contract .
define variable v-contract as integer no-undo .

find first buf_fin-ob no-lock where buf_fin-ob.doc-code = fin-ob-trn.doc-code no-error .
if available buf_fin-ob then do:
      v-contract = buf_fin-ob.contract-code .
      assign
        FILL-IN_curr-code      = sel-abbr(buf_fin-ob.curr-code)
        FILL-IN_doc-date       = buf_fin-ob.doc-date
        FILL-IN_fact-date      = buf_fin-ob.fact-date
        FILL-IN_fin-doc-type   = if buf_fin-ob.doc-type = {&income} then "с покупателем" else "с поставщиком"
        FILL-IN_pay-date       = buf_fin-ob.pay-date
        FILL-IN_prn-doc-code   = buf_fin-ob.prn-doc-code
        FILL-IN_status_        = buf_fin-ob.status_
        FILL-IN_sum-rubl       = buf_fin-ob.sum-rubl
        FILL-IN_user-name-doc  = buf_fin-ob.user-name-doc
        FILL-IN_user-name-fact = buf_fin-ob.user-name-fact
        FILL-IN_sum-doc        = buf_fin-ob.sum-doc
        var-ps =                 buf_fin-ob.PS
      .


   end.
   else do:
      find first buf_fin-ob-before no-lock where buf_fin-ob-before.before-code = fin-ob-trn.doc-code no-error .
      if not available  buf_fin-ob-before  then return.
      v-contract = buf_fin-ob-before.contract-code .
      assign
        FILL-IN_curr-code      = sel-abbr(buf_fin-ob-before.curr-code)
        FILL-IN_doc-date       = buf_fin-ob-before.doc-date
        FILL-IN_fact-date      = buf_fin-ob-before.fact-date
        FILL-IN_fin-doc-type   = "ПФО"
        FILL-IN_pay-date       = buf_fin-ob-before.pay-date
        FILL-IN_prn-doc-code   = buf_fin-ob-before.prn-doc-code
        FILL-IN_status_        = buf_fin-ob-before.status_
        FILL-IN_sum-rubl       = buf_fin-ob-before.sum-rubl
        FILL-IN_user-name-doc  = buf_fin-ob-before.user-name-doc
        FILL-IN_user-name-fact = buf_fin-ob-before.user-name-fact
        FILL-IN_sum-doc        = buf_fin-ob-before.sum-doc
        var-ps =                 buf_fin-ob-before.PS
      .

   end.
  { gbl/usrfulnm.i
    FILL-IN_user-name-doc
    FILL-IN_user-name-doc }
  { gbl/usrfulnm.i
    FILL-IN_user-name-fact
    FILL-IN_user-name-fact }

  find first buf_contract no-lock where  buf_contract.contract-code  =  v-contract  no-error .
    if not available buf_contract then return .

  assign
    FILL-IN_contract-prn-code  = buf_contract.contract-prn-code
    FILL-IN_contract-type      = buf_contract.contract-type
    FILL-IN_usl-opl            = buf_contract.usl-opl
    FILL-IN_srok-opl           = buf_contract.srok-opl
    FILL-IN_doc-type           = buf_contract.doc-type
  .
 if  buf_contract.usl-opl  = {&contr-pay-fact-out-prc} or
     buf_contract.usl-opl  = {&contr-buyer-ord-prc}
     then do:
     FILL-IN-sr-op = "        % :".
 end.
 else do:
    FILL-IN-sr-op = "Срок оплаты:".
 end.

 display
  FILL-IN_contract-prn-code FILL-IN_contract-type FILL-IN_curr-code FILL-IN_doc-date FILL-IN_doc-type FILL-IN_fact-date FILL-IN_fin-doc-type FILL-IN_pay-date FILL-IN_prn-doc-code FILL-IN_srok-opl FILL-IN_status_ FILL-IN_sum-rubl FILL-IN_user-name-doc FILL-IN_user-name-fact FILL-IN_usl-opl
  FILL-IN_sum-doc  FILL-IN-sr-op var-ps
  with frame {&frame-name}.
 if fin-ob-trn.doc-type = "" then do:
    IF AVAILABLE c-trn-doc THEN DO:
        ASSIGN
          v-U-full = "Накладная УДАЛЕНА !!!"
        .
    END.
    ELSE DO:
        ASSIGN
          v-U-full = ""
        .
    END.
    DISPLAY v-U-full WITH FRAME {&FRAME-NAME}.
  end.

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

{ gbl/getcntxt.i get }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  FILL-IN_sum-rubl:label = "Сумма ({&abbr_rub})" .
/*
if  p-mode =  "fin-ob" and fin-ob-trn.doc-type = "order":U then  p-mode =  fin-ob-trn.doc-type .
if  p-mode =  "fin-ob" and fin-ob-trn.doc-type = "rcv":U then  p-mode =  fin-ob-trn.doc-type .
*/
  case p-mode :
    when "all":U then do:
      message "НЕ РЕАЛИЗОВАНО".
      return .
    end.
    when "fin-ob":U then do:
       RUN enable_UI.
    end.
    when "trn-doc":U then do:
       RUN enable-my.
    end.
    when "order":U then do:
       RUN enable-my-order.
    end.
    when "rcv":U then do:
       RUN enable-my-rcv.
    end.
    when "add":U then do:
       RUN enable-my-add.
    end.

  end case.

  apply "VALUE-CHANGED" TO {&browse-name} IN FRAME  {&FRAME-NAME}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-my Dialog-Frame
PROCEDURE enable-my :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op

      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

 ASSIGN
 frame {&frame-name}:TITLE = "Фин. обязательства по накладной: " +  p-fin-ob-trn-doc
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc   AND ub.fin-ob-trn.doc-type  = ""  NO-LOCK,
      EACH trn-doc WHERE trn-doc.doc-code = fin-ob-trn.trn-doc-code   OUTER-JOIN NO-LOCK,
      EACH c-trn-doc WHERE c-trn-doc.is-del = yes and  c-trn-doc.doc-code = fin-ob-trn.trn-doc-code  OUTER-JOIN NO-LOCK,
      first ord-doc OUTER-JOIN no-lock ,
      first add-doc OUTER-JOIN no-lock ,
      first ord-doc-rcv OUTER-JOIN no-lock .

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-my-order Dialog-Frame
PROCEDURE enable-my-order :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op

      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

 ASSIGN
 frame {&frame-name}:TITLE = "Фин. обязательства по заказу: " +  p-fin-ob-trn-doc
 v-fact-rubl:label in browse {&browse-name}  = "По заказу ({&abbr_rubl})"
 ub.fin-ob-trn.trn-doc-code:label = "№ заказа"
 B-lkp:label = "&Заказ"
 B-lkp:tooltip = "Просмотр Заказа"
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc  and fin-ob-trn.doc-type = "order"
      NO-LOCK,
      first trn-doc no-lock OUTER-JOIN,
      first c-trn-doc no-lock OUTER-JOIN,
      EACH ord-doc WHERE ord-doc.doc-code = fin-ob-trn.trn-doc-code OUTER-JOIN NO-LOCK,
      first add-doc  OUTER-JOIN NO-LOCK,
      first ord-doc-rcv no-lock OUTER-JOIN
      .

  end.  /* do */
END PROCEDURE.
PROCEDURE enable-my-rcv :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op

      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

 ASSIGN
 frame {&frame-name}:TITLE = "Фин. обязательства по поставке: " +  p-fin-ob-trn-doc
 v-fact-rubl:label in browse {&browse-name}  = "По поставке ({&abbr_rubl})"
 ub.fin-ob-trn.trn-doc-code:label = "№ поставки"
 B-lkp:label = "&Поставка"
 B-lkp:tooltip = "Просмотр Поставки по заказу"
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc  and fin-ob-trn.doc-type = "rcv"
      NO-LOCK,
      first trn-doc no-lock OUTER-JOIN,
      first c-trn-doc no-lock OUTER-JOIN,
      first ord-doc no-lock OUTER-JOIN,
      first add-doc no-lock OUTER-JOIN,
      EACH ord-doc-rcv WHERE ord-doc-rcv.rcv-code = fin-ob-trn.trn-doc-code OUTER-JOIN NO-LOCK
      .

  end.  /* do */
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
  DISPLAY var-ps FILL-IN-1 v-U-full FILL-IN_prn-doc-code FILL-IN_status_
          FILL-IN_user-name-doc FILL-IN_fin-doc-type FILL-IN_user-name-fact
          FILL-IN_doc-date FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code
          FILL-IN_sum-doc FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code
          FILL-IN_doc-type FILL-IN_contract-type FILL-IN_usl-opl FILL-IN-sr-op
          FILL-IN_srok-opl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 var-ps FILL-IN-1 v-U-full
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN-sr-op FILL-IN_srok-opl
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION sel-abbr Dialog-Frame
FUNCTION sel-abbr RETURNS CHARACTER
 ( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable-my-add W-Win
PROCEDURE enable-my-add :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :

  DISPLAY FILL-IN-1 FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
          FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
          FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
          FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
          FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op

      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-lkp B-lkp-2 B-lkp-3 B-Help BROWSE-1 FILL-IN-1
         FILL-IN_prn-doc-code FILL-IN_status_ FILL-IN_user-name-doc
         FILL-IN_fin-doc-type FILL-IN_user-name-fact FILL-IN_doc-date
         FILL-IN_fact-date FILL-IN_pay-date FILL-IN_curr-code FILL-IN_sum-doc
         FILL-IN_sum-rubl FILL-IN-2 FILL-IN_contract-prn-code FILL-IN_doc-type
         FILL-IN_contract-type FILL-IN_usl-opl FILL-IN_srok-opl FILL-IN-sr-op
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.

 ASSIGN
 frame {&frame-name}:TITLE = "Фин. обязательства по ДопРасходу: " +  p-fin-ob-trn-doc
 v-fact-rubl:label in browse {&browse-name}  = "по ДопРасходу ({&abbr_rubl})"
 ub.fin-ob-trn.trn-doc-code:label = "№ ДопРасхода"
 B-lkp:label = "&ДопРасход"
 B-lkp:tooltip = "Просмотр ДопРасхода"
 .
 OPEN QUERY BROWSE-1 FOR EACH fin-ob-trn
      WHERE fin-ob-trn.trn-doc-code = p-fin-ob-trn-doc  and fin-ob-trn.doc-type = "add" NO-LOCK,
      first trn-doc no-lock OUTER-JOIN,
      first c-trn-doc no-lock OUTER-JOIN,
      first ord-doc no-lock OUTER-JOIN,
      EACH add-doc WHERE add-doc.doc-code = fin-ob-trn.trn-doc-code OUTER-JOIN NO-LOCK,
      first ord-doc-rcv no-lock OUTER-JOIN
      .

  end.  /* do */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME