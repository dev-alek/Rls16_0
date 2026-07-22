&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE acc-stk-line NO-UNDO LIKE ub.stk-line
       field ext-doc-type-full as character
       field order as integer
       field sum-base-sale like ub.stk-line.sum-base
       field sum-rubl-sale like ub.stk-line.sum-base
       field vat-base-sale like ub.stk-line.sum-base
       field vat-rubl-sale like ub.stk-line.sum-base
       field slt-base-sale like ub.stk-line.sum-base
       field slt-rubl-sale like ub.stk-line.sum-base
       field road-tax-base-sale like ub.stk-line.sum-base
       field road-tax-rubl-sale like ub.stk-line.sum-base
       field excise-base-sale like ub.stk-line.sum-base
       field excise-rubl-sale like ub.stk-line.sum-base
       field transport-base-sale like ub.stk-line.sum-base
       field transport-rubl-sale like ub.stk-line.sum-base
       field other-base-sale like ub.stk-line.sum-base
       field other-rubl-sale like ub.stk-line.sum-base
       field sum-base-doc like ub.stk-line.sum-base
       field sum-rubl-doc like ub.stk-line.sum-base
       field vat-base-doc like ub.stk-line.sum-base
       field vat-rubl-doc like ub.stk-line.sum-base
       field slt-base-doc like ub.stk-line.sum-base
       field slt-rubl-doc like ub.stk-line.sum-base
       field road-tax-base-doc like ub.stk-line.sum-base
       field road-tax-rubl-doc like ub.stk-line.sum-base
       field excise-base-doc like ub.stk-line.sum-base
       field excise-rubl-doc like ub.stk-line.sum-base
       field transport-base-doc like ub.stk-line.sum-base
       field transport-rubl-doc like ub.stk-line.sum-base
       field other-base-doc like ub.stk-line.sum-base
       field other-rubl-doc like ub.stk-line.sum-base
       index pi order
       .
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.
DEFINE TEMP-TABLE tt-ot-line NO-UNDO LIKE ub.ot-line.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр складского архива по товару

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич
no_app_help.i
*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр складского архива по товару".
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ arc/show_arh.i def }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }

define shared variable varparentproc as widget-handle no-undo.

define variable fact-order-start like ub.stk-tot.fact-order no-undo.
define variable fact-order-end   like ub.stk-tot.fact-order no-undo.
define variable fact-order-min   like ub.stk-tot.fact-order no-undo.
define variable fact-order-max   like ub.stk-tot.fact-order no-undo.
define variable varh_caller-main as widget-handle no-undo.
define variable varsum-type-ot-line like ub.ot-line.sum-type no-undo.
define variable rdtaxcdvalue  as character initial ? no-undo.
define variable rdtaxcdtype   as character initial ? no-undo.
define buffer   rt_tax        for ub.tax.

define temp-table tt-kind-sum no-undo
field sum-kind as character format "x(15)"
field order as integer
field sum-start-base      like ub.stk-line.sum-base
field sum-start-rubl      like ub.stk-line.sum-base
field sum-end-base        like ub.stk-line.sum-base
field sum-end-rubl        like ub.stk-line.sum-base
field sum-start-base-sale like ub.stk-line.sum-base
field sum-start-rubl-sale like ub.stk-line.sum-base
field sum-end-base-sale   like ub.stk-line.sum-base
field sum-end-rubl-sale   like ub.stk-line.sum-base
index pi order
index sum-kind sum-kind.

{ cmp/str-glbl.i }
{ gbl/lastordr.i }
{ gbl/dfactord.i }
{ arc/stk-lnst.i def}
{ arc/stk-lnst.i }
{ arc/stk-lnrv.i }
{ gbl/tax-name.i }
define variable rdtaxname as character no-undo.
define variable varsum-start like ub.stk-line.sum-base no-undo.
define variable varsum-end like ub.stk-line.sum-base no-undo.
define variable varsum-start-sale like ub.stk-line.sum-base no-undo.
define variable varsum-end-sale like ub.stk-line.sum-base no-undo.
define variable varorder as integer no-undo.
define variable varroad-tax like ub.ot-line.sum-base no-undo.
define variable varroad-tax-doc like ub.ot-line.sum-base no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME b-kind-type

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-kind-sum acc-stk-line

/* Definitions for BROWSE b-kind-type                                   */
&Scoped-define FIELDS-IN-QUERY-b-kind-type tt-kind-sum.sum-kind func-sum-start-sale (buffer tt-kind-sum) @ varsum-start-sale func-sum-start (buffer tt-kind-sum) @ varsum-start func-sum-end-sale (buffer tt-kind-sum) @ varsum-end-sale func-sum-end (buffer tt-kind-sum) @ varsum-end
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-kind-type
&Scoped-define SELF-NAME b-kind-type
&Scoped-define QUERY-STRING-b-kind-type FOR EACH tt-kind-sum NO-LOCK
&Scoped-define OPEN-QUERY-b-kind-type OPEN QUERY {&SELF-NAME} FOR EACH tt-kind-sum NO-LOCK.
&Scoped-define TABLES-IN-QUERY-b-kind-type tt-kind-sum
&Scoped-define FIRST-TABLE-IN-QUERY-b-kind-type tt-kind-sum


/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 acc-stk-line.ext-doc-type-full acc-stk-line.fact-qnty func-sum-doc (buffer acc-stk-line) func-sum (buffer acc-stk-line) func-sum-sale (buffer acc-stk-line) func-other-doc(buffer acc-stk-line) func-VAT-doc (buffer acc-stk-line) func-SLT-doc (buffer acc-stk-line) func-VAT (buffer acc-stk-line) func-SLT (buffer acc-stk-line) func-excise-doc (buffer acc-stk-line) func-excise (buffer acc-stk-line) func-road-tax-doc (buffer acc-stk-line) @ varroad-tax-doc func-road-tax (buffer acc-stk-line) @ varroad-tax func-transport-doc (buffer acc-stk-line) func-transport (buffer acc-stk-line) func-other (buffer acc-stk-line) func-price-doc (buffer acc-stk-line) func-price-sale (buffer acc-stk-line)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH acc-stk-line NO-LOCK
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH acc-stk-line NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 acc-stk-line
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 acc-stk-line


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-b-kind-type}~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-13 RECT-11 RECT-12 b-kind-type BROWSE-1
&Scoped-Define DISPLAYED-OBJECTS varqnty-start varqnty-end

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-excise V-table-Win
FUNCTION func-excise RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-excise-doc V-table-Win
FUNCTION func-excise-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-other V-table-Win
FUNCTION func-other RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-other-doc V-table-Win
FUNCTION func-other-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-price-doc V-table-Win
FUNCTION func-price-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-price-sale V-table-Win
FUNCTION func-price-sale RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-road-tax V-table-Win
FUNCTION func-road-tax RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-road-tax-doc V-table-Win
FUNCTION func-road-tax-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-slt V-table-Win
FUNCTION func-slt RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-slt-doc V-table-Win
FUNCTION func-slt-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum V-table-Win
FUNCTION func-sum RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-doc V-table-Win
FUNCTION func-sum-doc RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-end V-table-Win
FUNCTION func-sum-end RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-end-sale V-table-Win
FUNCTION func-sum-end-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-sale V-table-Win
FUNCTION func-sum-sale RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-start V-table-Win
FUNCTION func-sum-start RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-start-sale V-table-Win
FUNCTION func-sum-start-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-transport V-table-Win
FUNCTION func-transport RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-transport-doc V-table-Win
FUNCTION func-transport-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-vat V-table-Win
FUNCTION func-vat RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-vat-doc V-table-Win
FUNCTION func-vat-doc RETURNS DECIMAL
    ( buffer bf_acc-stk-line for acc-stk-line )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE varqnty-end AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE varqnty-start AS DECIMAL FORMAT "->>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98 BY 1.83.

DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE .38 BY 1.58.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE .13 BY 1.88.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-kind-type FOR
      tt-kind-sum SCROLLING.

DEFINE QUERY BROWSE-1 FOR
      acc-stk-line SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-kind-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-kind-type V-table-Win _FREEFORM
  QUERY b-kind-type DISPLAY
      tt-kind-sum.sum-kind column-label " "
      func-sum-start-sale (buffer tt-kind-sum) @ varsum-start-sale column-label "продажные" format " ->>>,>>>,>>>,>>9.99"
      func-sum-start (buffer tt-kind-sum) @ varsum-start column-label "учетные" format "->>,>>>>,>>>,>>9.99"
      func-sum-end-sale (buffer tt-kind-sum) @ varsum-end-sale column-label "продажные" format " ->>>,>>>,>>>,>>9.99"
      func-sum-end (buffer tt-kind-sum) @ varsum-end column-label "учетные" format "->>>,>>>,>>>,>>9.99"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 98.25 BY 3.92.

DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 V-table-Win _FREEFORM
  QUERY BROWSE-1 DISPLAY
      acc-stk-line.ext-doc-type-full COLUMN-LABEL "Оборот по док." FORMAT "X(20)"
      acc-stk-line.fact-qnty COLUMN-LABEL "Количество"
      func-sum-doc (buffer acc-stk-line) FORMAT "->>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма(по док)"
      func-sum (buffer acc-stk-line) FORMAT "->>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма(учет)"
      func-sum-sale (buffer acc-stk-line) FORMAT "->>,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма(прод)"
      func-other-doc(buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Скидка(Проч.расх.)(по док)"
      func-VAT-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НДС(по док)"
      func-SLT-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НП(по док)"
      func-VAT (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НДС(учет)"
      func-SLT (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "НП(учет)"
      func-excise-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Акциз(по док)"
      func-excise (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Акциз(учет)"
      func-road-tax-doc (buffer acc-stk-line) @ varroad-tax-doc   FORMAT "->,>>>,>>>,>>9.99"
      func-road-tax (buffer acc-stk-line) @ varroad-tax       FORMAT "->,>>>,>>>,>>9.99"
      func-transport-doc (buffer acc-stk-line)  FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Транспортные расходы(по док)"
      func-transport (buffer acc-stk-line)      FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Транспортные расходы"
      func-other (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Проч.расх.(Скидка)(учет)"
      func-price-doc (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма/кол-во(по док)"
      func-price-sale (buffer acc-stk-line) FORMAT "->,>>>,>>>,>>9.99" COLUMN-LABEL "Сумма/кол-во(прод)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.25 BY 12.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     varqnty-start AT ROW 1.79 COL 27.88 COLON-ALIGNED NO-LABEL
     varqnty-end AT ROW 1.79 COL 72.75 COLON-ALIGNED NO-LABEL
     b-kind-type AT ROW 2.96 COL 1
     BROWSE-1 AT ROW 6.96 COL 1
     "Остаток на конец периода" VIEW-AS TEXT
          SIZE 24.63 BY .67 AT ROW 1.04 COL 69
          FGCOLOR 3
     "Остаток на начало периода" VIEW-AS TEXT
          SIZE 25.88 BY .67 AT ROW 1.04 COL 25.5
          FGCOLOR 3
     "  Количество" VIEW-AS TEXT
          SIZE 15.38 BY 1 AT ROW 1.83 COL 1.63
          FGCOLOR 3
     RECT-13 AT ROW 1 COL 56.38
     RECT-11 AT ROW 1.13 COL 1
     RECT-12 AT ROW 1.25 COL 17.75
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
   Temp-Tables and Buffers:
      TABLE: acc-stk-line T "?" NO-UNDO ub ub.stk-line
      ADDITIONAL-FIELDS:
          field ext-doc-type-full as character
          field order as integer
          field sum-base-sale like ub.stk-line.sum-base
          field sum-rubl-sale like ub.stk-line.sum-base
          field vat-base-sale like ub.stk-line.sum-base
          field vat-rubl-sale like ub.stk-line.sum-base
          field slt-base-sale like ub.stk-line.sum-base
          field slt-rubl-sale like ub.stk-line.sum-base
          field road-tax-base-sale like ub.stk-line.sum-base
          field road-tax-rubl-sale like ub.stk-line.sum-base
          field excise-base-sale like ub.stk-line.sum-base
          field excise-rubl-sale like ub.stk-line.sum-base
          field transport-base-sale like ub.stk-line.sum-base
          field transport-rubl-sale like ub.stk-line.sum-base
          field other-base-sale like ub.stk-line.sum-base
          field other-rubl-sale like ub.stk-line.sum-base
          field sum-base-doc like ub.stk-line.sum-base
          field sum-rubl-doc like ub.stk-line.sum-base
          field vat-base-doc like ub.stk-line.sum-base
          field vat-rubl-doc like ub.stk-line.sum-base
          field slt-base-doc like ub.stk-line.sum-base
          field slt-rubl-doc like ub.stk-line.sum-base
          field road-tax-base-doc like ub.stk-line.sum-base
          field road-tax-rubl-doc like ub.stk-line.sum-base
          field excise-base-doc like ub.stk-line.sum-base
          field excise-rubl-doc like ub.stk-line.sum-base
          field transport-base-doc like ub.stk-line.sum-base
          field transport-rubl-doc like ub.stk-line.sum-base
          field other-base-doc like ub.stk-line.sum-base
          field other-rubl-doc like ub.stk-line.sum-base
          index pi order

      END-FIELDS.
      TABLE: tt-clients T "NEW GLOBAL SHARED" NO-UNDO ub clients
      TABLE: tt-goods T "NEW GLOBAL SHARED" NO-UNDO ub goods
      TABLE: tt-ot-line T "?" NO-UNDO ub ot-line
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 18.42
         WIDTH              = 99.25.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
/* BROWSE-TAB b-kind-type varqnty-end F-Main */
/* BROWSE-TAB BROWSE-1 b-kind-type F-Main */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       BROWSE-1:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 2.

/* SETTINGS FOR FILL-IN varqnty-end IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varqnty-start IN FRAME F-Main
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-kind-type
/* Query rebuild information for BROWSE b-kind-type
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-kind-sum NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-kind-type */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH acc-stk-line NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME F-Main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-Main V-table-Win
ON END-ERROR OF FRAME F-Main
DO:
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-Main V-table-Win
ON ENDKEY OF FRAME F-Main
DO:
    return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 V-table-Win
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1 IN FRAME F-Main
DO:
  /*посылаем в основной экран*/
  run set-attribute-list ('varext-doc-type=' + string(acc-stk-line.ext-doc-type)).
  run notify ('read_doc-type,doctype-target':u).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-kind-type
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */

{ gbl/personly.i }

{ gbl/getcntxt.i get " " varparentproc }

run tax-name ({&road-tax}, output rdtaxname).
assign varroad-tax-doc :label in browse browse-1 = rdtaxname
       varroad-tax     :label in browse browse-1 = rdtaxname.
&GLOB road-tax-name rdtaxname
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc-field-frame V-table-Win
PROCEDURE calc-field-frame :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define variable varqnty-is-calc-start as logical   no-undo initial no .
  define variable varqnty-is-calc-end   as logical   no-undo initial no .
  define variable g-cost-arc            as logical   no-undo .
  define variable varcost               as character no-undo .
  define variable varcsdt               as character no-undo .
  define variable varcrsa               as character no-undo .
  define variable varcgdt               as character no-undo .
  define variable varsadt               as character no-undo .

  for each acc-stk-line
  :
    delete acc-stk-line.
  end.
  for each tt-kind-sum
  :
    delete tt-kind-sum.
  end.

  assign
    varqnty-start = 0
    varqnty-end   = 0
  .

  define variable v-chk-act-host-code as integer   no-undo .
  assign
    g-cost-arc = true
  .
  scan_block:
  for each tt-clients
  on error undo, return error return-value
  :
    { gbl/hostcode.i
      tt-clients.obj-type
      tt-clients.obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-chk-act-host-code
      tt-clients.obj-type
      tt-clients.obj-code
      0
      0
      0
      false
      g-cost-arc
    }
    if g-cost-arc <> true
    then do:
      leave scan_block.
    end.
  end.

  { arc/fnfactod.i }

  define variable v-ind as integer   no-undo .

  define variable v-r-b-base as logical   no-undo .

  { gbl/rbisbase.i
    v-r-b-base
  }

  for each tt-goods
  :
    assign
      v-ind = v-ind + 1
    .
    if v-ind modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Обработано товаров &1. Артикул &2", v-ind, tt-goods.artic)
        ) .
    end.

    assign
      varqnty-is-calc-start = no
      varqnty-is-calc-end   = no
    .
    assign
      varcost = (if tt-goods.gds-type = {&gds-office} then {&arh-cost-service} else {&arh-cost})
      varcsdt = (if tt-goods.gds-type = {&gds-office} then {&arh-csdt-service} else {&arh-csdt})
      varcrsa = (if tt-goods.gds-type = {&gds-office} then {&arh-crsa-service} else {&arh-crsa})
      varcgdt = (if tt-goods.gds-type = {&gds-office} then {&arh-cgdt-service} else {&arh-cgdt})
      varsadt = (if tt-goods.gds-type = {&gds-office} then {&arh-sadt-service} else {&arh-sadt})
    .
    /*Остаток в учетных ценах на начало*/
    { arc/main-arc.i start   varcost " " g-cost-arc }
    /*Остаток в учетных ценах на конец*/
    { arc/main-arc.i end     varcost " " g-cost-arc }
    /*Обороты в учетных ценах*/
    { arc/main-arr.i varcsdt g-cost-arc }
    /*Остаток в текущих продажных ценах на начало*/
    { arc/main-arc.i start   varcrsa " " g-cost-arc }
    /*Остаток в текущих продажных ценах на конец*/
    { arc/main-arc.i end     varcrsa " " g-cost-arc }
    /*Обороты в текущих продажных ценах*/
    { arc/main-arr.i varcgdt g-cost-arc }
    /*Обороты в ценах документа*/
    { arc/main-arr.i varsadt g-cost-arc }
  end.
end. /*e n d for workfile fnfactod.i*/

run waitfram-hide in this-procedure .

{&OPEN-BROWSERS-IN-QUERY-F-Main}
display varqnty-start varqnty-end with frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "tt-kind-sum"}
  {src/adm/template/snd-list.i "acc-stk-line"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show_arh V-table-Win
PROCEDURE show_arh :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  { arc/show_arh.i body }
  run calc-field-frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:

      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-excise V-table-Win
FUNCTION func-excise RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.excise-rubl.
                      else return bf_acc-stk-line.excise-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-excise-doc V-table-Win
FUNCTION func-excise-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.excise-rubl-doc.
                      else return bf_acc-stk-line.excise-base-doc.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-other V-table-Win
FUNCTION func-other RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.other-rubl.
                      else return bf_acc-stk-line.other-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-other-doc V-table-Win
FUNCTION func-other-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.other-rubl-doc.
                      else return bf_acc-stk-line.other-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-price-doc V-table-Win
FUNCTION func-price-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return (bf_acc-stk-line.sum-rubl-doc / bf_acc-stk-line.fact-qnty).
                      else return (bf_acc-stk-line.sum-base-doc / bf_acc-stk-line.fact-qnty).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-price-sale V-table-Win
FUNCTION func-price-sale RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return (bf_acc-stk-line.sum-rubl-sale / bf_acc-stk-line.fact-qnty).
                      else return (bf_acc-stk-line.sum-base-sale / bf_acc-stk-line.fact-qnty).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-road-tax V-table-Win
FUNCTION func-road-tax RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.road-tax-rubl.
                      else return bf_acc-stk-line.road-tax-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-road-tax-doc V-table-Win
FUNCTION func-road-tax-doc RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.road-tax-rubl-doc.
                      else return bf_acc-stk-line.road-tax-base-doc.



END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-slt V-table-Win
FUNCTION func-slt RETURNS DECIMAL
 ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.slt-rubl.
                      else return bf_acc-stk-line.slt-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-slt-doc V-table-Win
FUNCTION func-slt-doc RETURNS DECIMAL
( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.slt-rubl-doc.
                      else return bf_acc-stk-line.slt-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum V-table-Win
FUNCTION func-sum RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.sum-rubl.
                      else return bf_acc-stk-line.sum-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-doc V-table-Win
FUNCTION func-sum-doc RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.sum-rubl-doc.
                      else return bf_acc-stk-line.sum-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-end V-table-Win
FUNCTION func-sum-end RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-end-rubl.
                      else return bf_tt-kind-sum.sum-end-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-end-sale V-table-Win
FUNCTION func-sum-end-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-end-rubl-sale.
                      else return bf_tt-kind-sum.sum-end-base-sale.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-sale V-table-Win
FUNCTION func-sum-sale RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.sum-rubl-sale.
                      else return bf_acc-stk-line.sum-base-sale.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-start V-table-Win
FUNCTION func-sum-start RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-start-rubl.
                      else return bf_tt-kind-sum.sum-start-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-start-sale V-table-Win
FUNCTION func-sum-start-sale RETURNS DECIMAL
  ( buffer bf_tt-kind-sum for tt-kind-sum ) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
  if varrubl-base = 1 then return bf_tt-kind-sum.sum-start-rubl-sale.
                      else return bf_tt-kind-sum.sum-start-base-sale.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-transport V-table-Win
FUNCTION func-transport RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.transport-rubl.
                      else return bf_acc-stk-line.transport-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-transport-doc V-table-Win
FUNCTION func-transport-doc RETURNS DECIMAL
  ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.transport-rubl-doc.
                      else return bf_acc-stk-line.transport-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-vat V-table-Win
FUNCTION func-vat RETURNS DECIMAL
   ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.vat-rubl.
                      else return bf_acc-stk-line.vat-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-vat-doc V-table-Win
FUNCTION func-vat-doc RETURNS DECIMAL
    ( buffer bf_acc-stk-line for acc-stk-line ) :
  if varrubl-base = 1 then return bf_acc-stk-line.vat-rubl-doc.
                      else return bf_acc-stk-line.vat-base-doc.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME