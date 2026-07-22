&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-clients NO-UNDO LIKE ub.clients.
DEFINE NEW GLOBAL SHARED TEMP-TABLE tt-goods NO-UNDO LIKE ub.goods.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS B-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр оборота по товару

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create Суслов Алексей Юрьевич

no_app_help.i
*/


CREATE WIDGET-POOL.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр оборота по товару".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }

define shared variable varparentproc as widget-handle no-undo.

/*Для просмотра строки по документу*/
define new shared variable line-rec as recid no-undo.

{ gbl/dfactord.i }
{ gbl/lastordr.i }
define variable fact-order-start like ub.ot-line.fact-order no-undo.
define variable fact-order-end   like ub.ot-line.fact-order no-undo.
define variable fact-order-min   like ub.ot-line.fact-order no-undo.
define variable fact-order-max   like ub.ot-line.fact-order no-undo.
define variable varh_caller-main as widget-handle no-undo.
define variable varh_arh as widget-handle no-undo.

define variable vardoc-code  as character no-undo.
define variable varfact-date as date      no-undo.

{ arc/show_arh.i def}
define variable varsum-type as character no-undo.
define variable varcontragent as char no-undo.
define variable varsum like ub.ot-line.sum-base no-undo.
define variable varsum-doc like ub.ot-line.sum-base no-undo.
define variable varsum-sale like ub.ot-line.sum-base no-undo.
define variable varprice-doc like ub.ot-line.sum-base no-undo.
define variable varprice-sale like ub.ot-line.sum-base no-undo.
define variable varvat like ub.ot-line.sum-base no-undo.
define variable varvat-doc like ub.ot-line.sum-base no-undo.
define variable varslt like ub.ot-line.sum-base no-undo.
define variable varslt-doc like ub.ot-line.sum-base no-undo.
define variable varroad-tax like ub.ot-line.sum-base no-undo.
define variable varroad-tax-doc like ub.ot-line.sum-base no-undo.
define variable varexcise like ub.ot-line.sum-base no-undo.
define variable varexcise-doc like ub.ot-line.sum-base no-undo.
define variable vartransport like ub.ot-line.sum-base no-undo.
define variable vartransport-doc like ub.ot-line.sum-base no-undo.
define variable varother like ub.ot-line.sum-base no-undo.
define variable varother-doc like ub.ot-line.sum-base no-undo.
define variable rdtaxname as character no-undo.
define variable varext-doc-type-short like ub.ot-line.ext-doc-type no-undo.
{ gbl/tax-name.i }
define buffer rt_tax   for ub.tax.
define temp-table ot-full no-undo
field doc-code like ub.ot-line.doc-code
field doc-type like ub.trn-doc.doc-type
field cli-type like ub.clients.obj-type
field cli-code like ub.clients.obj-code
field cli-name like ub.clients.obj-name
field fact-date like ub.trn-doc.fact-date
field fact-order like ub.ot-line.fact-order
field ext-doc-type like ub.ot-line.ext-doc-type
field ext-doc-type-full as character
field fact-qnty like ub.ot-line.fact-qnty
field sum-base like ub.ot-line.sum-base
field sum-rubl like ub.ot-line.sum-base
field sum-base-doc like ub.ot-line.sum-base
field sum-rubl-doc like ub.ot-line.sum-base
field sum-base-sale like ub.ot-line.sum-base
field sum-rubl-sale like ub.ot-line.sum-base
field vat-base like ub.ot-line.sum-base
field vat-rubl like ub.ot-line.sum-base
field vat-base-doc like ub.ot-line.sum-base
field vat-rubl-doc like ub.ot-line.sum-base
field vat-base-sale like ub.ot-line.sum-base
field vat-rubl-sale like ub.ot-line.sum-base
field slt-base like ub.ot-line.sum-base
field slt-rubl like ub.ot-line.sum-base
field slt-base-doc like ub.ot-line.sum-base
field slt-rubl-doc like ub.ot-line.sum-base
field slt-base-sale like ub.ot-line.sum-base
field slt-rubl-sale like ub.ot-line.sum-base
field excise-base like ub.ot-line.sum-base
field excise-rubl like ub.ot-line.sum-base
field excise-base-doc like ub.ot-line.sum-base
field excise-rubl-doc like ub.ot-line.sum-base
field excise-base-sale like ub.ot-line.sum-base
field excise-rubl-sale like ub.ot-line.sum-base
field road-tax-base like ub.ot-line.sum-base
field road-tax-rubl like ub.ot-line.sum-base
field road-tax-base-doc like ub.ot-line.sum-base
field road-tax-rubl-doc like ub.ot-line.sum-base
field road-tax-base-sale like ub.ot-line.sum-base
field road-tax-rubl-sale like ub.ot-line.sum-base
field transport-base like ub.ot-line.sum-base
field transport-rubl like ub.ot-line.sum-base
field transport-base-doc like ub.ot-line.sum-base
field transport-rubl-doc like ub.ot-line.sum-base
field transport-base-sale like ub.ot-line.sum-base
field transport-rubl-sale like ub.ot-line.sum-base
field other-base like ub.ot-line.sum-base
field other-rubl like ub.ot-line.sum-base
field other-base-doc like ub.ot-line.sum-base
field other-rubl-doc like ub.ot-line.sum-base
field other-base-sale like ub.ot-line.sum-base
field other-rubl-sale like ub.ot-line.sum-base
field artic like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field gds-type  like ub.goods.gds-type
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is primary fact-order
index doc-code doc-code
index edt ext-doc-type.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main
&Scoped-define BROWSE-NAME b-ot-line

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ot-full

/* Definitions for BROWSE b-ot-line                                     */
&Scoped-define FIELDS-IN-QUERY-b-ot-line ot-full.fact-date @ varfact-date ot-full.doc-code @ vardoc-code ot-full.ext-doc-type-full ot-full.cli-name @ varcontragent ot-full.fact-qnty func-sum-doc (buffer ot-full) @ varsum-doc func-sum (buffer ot-full) @ varsum func-sum-sale (buffer ot-full) @ varsum-sale func-other-doc (buffer ot-full) @ varother-doc func-VAT-doc (buffer ot-full) @ varvat-doc func-SLT-doc (buffer ot-full) @ varslt-doc func-VAT (buffer ot-full) @ varvat func-SLT (buffer ot-full) @ varslt func-excise-doc (buffer ot-full) @ varexcise-doc func-excise (buffer ot-full) @ varexcise func-road-tax-doc (buffer ot-full) @ varroad-tax-doc func-road-tax (buffer ot-full) @ varroad-tax func-transport-doc (buffer ot-full) @ vartransport-doc func-transport (buffer ot-full) @ vartransport func-other (buffer ot-full) @ varother func-price-doc (buffer ot-full) @ varprice-doc func-price-sale (buffer ot-full) @ varprice-sale ot-full.artic ot-full.prod-type ot-full.prod-code ot-full.obj-type ot-full.obj-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-ot-line
&Scoped-define SELF-NAME b-ot-line
&Scoped-define QUERY-STRING-b-ot-line FOR EACH ot-full
&Scoped-define OPEN-QUERY-b-ot-line OPEN QUERY {&SELF-NAME} FOR EACH ot-full.
&Scoped-define TABLES-IN-QUERY-b-ot-line ot-full
&Scoped-define FIRST-TABLE-IN-QUERY-b-ot-line ot-full


/* Definitions for FRAME F-Main                                         */
&Scoped-define OPEN-BROWSERS-IN-QUERY-F-Main ~
    ~{&OPEN-QUERY-b-ot-line}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-lookup b-all-docs b-ot-line

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" B-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Advanced Query Options" B-table-Win _INLINE
/* Actions: ? adm/support/advqedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
&BROWSE-NAME
</KEY-OBJECT>
<SORTBY-OPTIONS>
</SORTBY-OPTIONS>
<SORTBY-RUN-CODE>
************************
* Set attributes related to SORTBY-OPTIONS */
RUN set-attribute-list (
    'SortBy-Options = ""':U).
/************************
</SORTBY-RUN-CODE>
<FILTER-ATTRIBUTES>
</FILTER-ATTRIBUTES> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-excise B-table-Win
FUNCTION func-excise RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-excise-doc B-table-Win
FUNCTION func-excise-doc RETURNS DECIMAL
   ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-other B-table-Win
FUNCTION func-other RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-other-doc B-table-Win
FUNCTION func-other-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-price-doc B-table-Win
FUNCTION func-price-doc RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-price-sale B-table-Win
FUNCTION func-price-sale RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-road-tax B-table-Win
FUNCTION func-road-tax RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-road-tax-doc B-table-Win
FUNCTION func-road-tax-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-SLT B-table-Win
FUNCTION func-SLT RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-slt-doc B-table-Win
FUNCTION func-slt-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum B-table-Win
FUNCTION func-sum RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-doc B-table-Win
FUNCTION func-sum-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-sum-sale B-table-Win
FUNCTION func-sum-sale RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-transport B-table-Win
FUNCTION func-transport RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-transport-doc B-table-Win
FUNCTION func-transport-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-VAT B-table-Win
FUNCTION func-VAT RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD func-VAT-doc B-table-Win
FUNCTION func-VAT-doc RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-all-docs
     LABEL "Все документы"
     SIZE 16 BY 1.

DEFINE BUTTON b-lookup
     LABEL "Просмотр"
     SIZE 14 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-ot-line FOR
      ot-full SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-ot-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-ot-line B-table-Win _FREEFORM
  QUERY b-ot-line NO-LOCK DISPLAY
      ot-full.fact-date @ varfact-date column-label "Дата"
      ot-full.doc-code @ vardoc-code column-label "Документ"
      ot-full.ext-doc-type-full format "x(11)" column-label " "
      ot-full.cli-name @ varcontragent format "x(15)" column-label "Контрагент"
      ot-full.fact-qnty column-label "Кол-во"
      func-sum-doc (buffer ot-full) @ varsum-doc format "->,>>>,>>>,>>9.99" column-label "Сумма(по док)"
      func-sum (buffer ot-full) @ varsum format "->,>>>,>>>,>>9.99" column-label "Сумма(учет)"
      func-sum-sale (buffer ot-full) @ varsum-sale format "->,>>>,>>>,>>9.99" column-label "Сумма(прод)"
      func-other-doc (buffer ot-full) @ varother-doc format "->,>>>,>>>,>>9.99" column-label "Скидка(Прочие расходы)(по док)"
      func-VAT-doc (buffer ot-full) @ varvat-doc format "->,>>>,>>>,>>9.99" column-label "НДС(по док)"
      func-SLT-doc (buffer ot-full) @ varslt-doc format "->,>>>,>>>,>>9.99" column-label "НП(по док)"
      func-VAT (buffer ot-full) @ varvat format "->,>>>,>>>,>>9.99" column-label "НДС(учет)"
      func-SLT (buffer ot-full) @ varslt format "->,>>>,>>>,>>9.99" column-label "НП(учет)"
      func-excise-doc (buffer ot-full) @ varexcise-doc format "->,>>>,>>>,>>9.99" column-label "Акциз(по док)"
      func-excise (buffer ot-full) @ varexcise format "->,>>>,>>>,>>9.99" column-label "Акциз(учет)"
      func-road-tax-doc (buffer ot-full) @ varroad-tax-doc format "->,>>>,>>>,>>9.99"
      func-road-tax (buffer ot-full) @ varroad-tax format "->,>>>,>>>,>>9.99"
      func-transport-doc (buffer ot-full) @ vartransport-doc format "->,>>>,>>>,>>9.99" column-label "Трансп.расх.(по док)"
      func-transport (buffer ot-full) @ vartransport format "->,>>>,>>>,>>9.99" column-label "Трансп.расх.(учет)"
      func-other (buffer ot-full) @ varother format "->,>>>,>>>,>>9.99" column-label "Прочие расх.(Скидка)(учет)"
      func-price-doc (buffer ot-full) @ varprice-doc format "->,>>>,>>>,>>9.99" column-label "Сумма/Кол-во(по док)"
      func-price-sale (buffer ot-full) @ varprice-sale format "->,>>>,>>>,>>9.99" column-label "Сумма/Кол-во(учет)"
      ot-full.artic
      ot-full.prod-type
      ot-full.prod-code
      ot-full.obj-type
      ot-full.obj-code
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.88 BY 14.08
         BGCOLOR 15 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     b-lookup AT ROW 1.13 COL 3
     b-all-docs AT ROW 1.13 COL 18
     b-ot-line AT ROW 2.63 COL 1.13
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY
         THREE-D
         AT COL 1 ROW 1
         SIZE 97.25 BY 16.71
         BGCOLOR 8 FGCOLOR 0
         TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse
   Frames: 1
   Add Fields to: External-Tables
   Temp-Tables and Buffers:
      TABLE: tt-clients T "NEW GLOBAL SHARED" NO-UNDO ub clients
      TABLE: tt-goods T "NEW GLOBAL SHARED" NO-UNDO ub goods
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW B-table-Win ASSIGN
         HEIGHT             = 16.71
         WIDTH              = 97.25.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB B-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/browser.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW B-table-Win
  NOT-VISIBLE,,RUN-PERSISTENT                                           */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME UNDERLINE                                     */
/* BROWSE-TAB b-ot-line b-all-docs F-Main */
ASSIGN
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       b-ot-line:NUM-LOCKED-COLUMNS IN FRAME F-Main     = 4.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-ot-line
/* Query rebuild information for BROWSE b-ot-line
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH ot-full
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE b-ot-line */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME F-Main
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-Main B-table-Win
ON END-ERROR OF FRAME F-Main
DO:
     run return-up.
   return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-Main B-table-Win
ON ENDKEY OF FRAME F-Main
DO:
     run return-up.
   return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-all-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-all-docs B-table-Win
ON CHOOSE OF b-all-docs IN FRAME F-Main /* Все документы */
DO:
run notify ('read_doc-type-all,doctype-target':u).
run show_arh.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lookup
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lookup B-table-Win
ON CHOOSE OF b-lookup IN FRAME F-Main /* Просмотр */
DO:
  if available ot-full then do:
     run lookup-doc.
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-ot-line
&Scoped-define SELF-NAME b-ot-line
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ot-line B-table-Win
ON MOUSE-SELECT-DBLCLICK OF b-ot-line IN FRAME F-Main
DO:
  if available ot-full  then run lookup-doc.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK B-table-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

{ gbl/getcntxt.i get " " varparentproc }
/* no_gbl/app_help.i */
run tax-name ({&road-tax}, output rdtaxname).
assign varroad-tax-doc :label in browse {&browse-name} = rdtaxname
       varroad-tax     :label in browse {&browse-name} = rdtaxname.

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available B-table-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI B-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize B-table-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
  run show_arh no-error.

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lookup-doc B-table-Win
PROCEDURE lookup-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable g-log as logical no-undo.
case ot-full.ext-doc-type:
/*переоценка*/
when {&TDEDT_Overturn} then do:
   find first ub.price-doc where ub.price-doc.doc-num = ot-full.doc-code no-lock.
   if not available ub.price-doc then do:
      message "Не найден документ переоценки для просмотра" view-as alert-box.
      return error.
   end.
   find ub.price-list where ub.price-list.doc-num   = ub.price-doc.doc-num  and
                         ub.price-list.artic     = ot-full.artic     and
                         ub.price-list.prod-type = ot-full.prod-type and
                         ub.price-list.prod-code = ot-full.prod-code no-lock no-error.
   assign line-rec = recid(ub.price-list).

   run str/pr-lkp.p
     (input varparentproc
     ,recid(ub.price-doc)
     ).
end.
otherwise do:
   find first ub.trn-doc where ub.trn-doc.doc-code = ot-full.doc-code no-lock.
   if not available ub.trn-doc then do:
      message "Не найден документ для просмотра" view-as alert-box.
      return error.
   end.

   case ub.trn-doc.doc-type
   :
     when {&income}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_income_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        0
        0
        0
        true
        g-log
      }
     end.
     when {&expense}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_expense_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        0
        0
        0
        true
        g-log
      }
     end.
     when {&write-off}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_write-off_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        0
        0
        0
        true
        g-log
      }
     end.
     when {&inventory}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_inventory_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        0
        0
        0
        true
        g-log
      }
     end.
     when {&return}
     then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_return_lookup':U
        {&cntxt-object}
        ub.trn-doc.host-code
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        0
        0
        0
        true
        g-log
      }
     end.
     otherwise do:
       message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" skip
         "Тип документа" ub.trn-doc.doc-type skip
         "Код документа" ub.trn-doc.doc-code skip
         view-as alert-box error .
       undo, return error return-value .
     end.
   end case .

   if not g-log then return no-apply.
   find ub.doc-line where ub.doc-line.doc-code  = ub.trn-doc.doc-code  and
                       ub.doc-line.artic     = ot-full.artic     and
                       ub.doc-line.prod-type = ot-full.prod-type and
                       ub.doc-line.prod-code = ot-full.prod-code no-lock no-error.
   assign line-rec = recid(ub.doc-line).
   run str/trn-lkp.p (varparentproc, recid(ub.trn-doc), recid(ub.doc-line)).
end.
end case.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE return-up B-table-Win
PROCEDURE return-up :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records B-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.               */
  {src/adm/template/snd-head.i}

  /* For each requested table, put it's ROWID in the output list.      */
  {src/adm/template/snd-list.i "ot-full"}

  /* Deal with any unexpected table requests before closing.           */
  {src/adm/template/snd-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE show_arh B-table-Win
PROCEDURE show_arh :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
{ arc/show_arh.i body}
if varext-doc-type = "?" then do:
   message "Не считаны атрибуты для запроса." view-as alert-box error.
   return error.
end.
{ arc/fnfactod.i }
end.
assign varsum-type = "all".
for each ot-full:
    delete ot-full.
end.

define variable g-cost as logical no-undo.
assign frame {&frame-name}:title = "Документы: " +
(if varext-doc-type = 'all' then 'Все' else varext-doc-type).
if varext-doc-type <> 'all' then
   assign varext-doc-type-short = entry(lookup(varext-doc-type, {&tdedt_list-full}), {&tdedt_list}).

define variable v-chk-act-host-code as integer   no-undo .
assign
  g-cost = true
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
    g-cost
  }
  if g-cost <> true
  then do:
    leave scan_block.
  end.
end.

if varext-doc-type = 'all'
then do:
   if g-cost
   then do:
      { arc/b-otlina.i
       &prep-ext-doc-type = " "
       &prep-sum-type     = " " }
      {&open-query-{&browse-name}}
   end.
   else do:
      { arc/b-otlina.i
       &prep-ext-doc-type = " "
       &prep-sum-type     = "and ub.ot-line.sum-type <> {&arh-cost}" }
      {&open-query-{&browse-name}}
   end.
end.
else do:
   if g-cost
   then do:
      { arc/b-otlina.i
       &prep-ext-doc-type = "and ub.ot-line.ext-doc-type = varext-doc-type-short"
       &prep-sum-type     = " " }
      {&open-query-{&browse-name}}
   end.
   else do:
      { arc/b-otlina.i
       &prep-ext-doc-type = "and ub.ot-line.ext-doc-type = varext-doc-type-short"
       &prep-sum-type     = "and ub.ot-line.sum-type <> {&arh-cost}" }
      {&open-query-{&browse-name}}
   end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed B-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
       when 'detail' then do:
          assign varh_arh = p-issuer-hdl.
       end.
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/bstates.i}
  END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-excise B-table-Win
FUNCTION func-excise RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.excise-rubl.
                        else return bf_ot-full.excise-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-excise-doc B-table-Win
FUNCTION func-excise-doc RETURNS DECIMAL
   ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.excise-rubl-doc.
                        else return bf_ot-full.excise-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-other B-table-Win
FUNCTION func-other RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.other-rubl.
                        else return bf_ot-full.other-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-other-doc B-table-Win
FUNCTION func-other-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.other-rubl-doc.
                        else return bf_ot-full.other-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-price-doc B-table-Win
FUNCTION func-price-doc RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return (bf_ot-full.sum-rubl-doc / bf_ot-full.fact-qnty).
                        else return (bf_ot-full.sum-base-doc / bf_ot-full.fact-qnty).
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-price-sale B-table-Win
FUNCTION func-price-sale RETURNS DECIMAL
  ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return (bf_ot-full.sum-rubl-sale / bf_ot-full.fact-qnty).
                        else return (bf_ot-full.sum-base-sale / bf_ot-full.fact-qnty).

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-road-tax B-table-Win
FUNCTION func-road-tax RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.road-tax-rubl.
                        else return bf_ot-full.road-tax-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-road-tax-doc B-table-Win
FUNCTION func-road-tax-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.road-tax-rubl-doc.
                        else return bf_ot-full.road-tax-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-SLT B-table-Win
FUNCTION func-SLT RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.slt-rubl.
                        else return bf_ot-full.slt-base.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-slt-doc B-table-Win
FUNCTION func-slt-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.slt-rubl-doc.
                        else return bf_ot-full.slt-base-doc.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum B-table-Win
FUNCTION func-sum RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.sum-rubl.
                        else return bf_ot-full.sum-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-doc B-table-Win
FUNCTION func-sum-doc RETURNS DECIMAL
    ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.sum-rubl-doc.
                        else return bf_ot-full.sum-base-doc.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-sum-sale B-table-Win
FUNCTION func-sum-sale RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.sum-rubl-sale.
                        else return bf_ot-full.sum-base-sale.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-transport B-table-Win
FUNCTION func-transport RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.transport-rubl.
                        else return bf_ot-full.transport-base.
END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-transport-doc B-table-Win
FUNCTION func-transport-doc RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.transport-rubl-doc.
                        else return bf_ot-full.transport-base-doc.


END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-VAT B-table-Win
FUNCTION func-VAT RETURNS DECIMAL
      ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.vat-rubl.
                        else return bf_ot-full.vat-base.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION func-VAT-doc B-table-Win
FUNCTION func-VAT-doc RETURNS DECIMAL
     ( buffer bf_ot-full for ot-full ) :
    if varrubl-base = 1 then return bf_ot-full.vat-rubl-doc.
                        else return bf_ot-full.vat-base-doc.



END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
