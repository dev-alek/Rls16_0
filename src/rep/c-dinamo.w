&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
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

Динамика движения товара-учетная карточка

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/03
Author: Bakhtadze Natalya
Creation date: 05/27/03

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-sign as integer no-undo.
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define input parameter p-cost-view as logical no-undo .
define input-output parameter p-curr as character no-undo .
define input-output parameter p-doc-rec as recid no-undo .
define input-output parameter p-br-handle as handle no-undo .
define input-output parameter p-next-prev as logical no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Динамика движения товара-учетная карточка".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ gbl/color.i }
{ trg/factord.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i }
{ gbl/fltfield.i }
{ rep/r-dinamo.i shared }
{ gbl/waitfram.i }
{ gbl/fltopend.i defproc }

define temp-table temp_trn-doc-code no-undo
    field doc-code as character
    index pi is primary unique doc-code
.

FUNCTION Last-Day RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  ASSIGN t_date = DATE( MONTH( i-date ), 28, YEAR( i-date ) ).
  RETURN ( DAY( t_date - DAY( t_date + 4 ) + 4 ) ).
END FUNCTION. /* LastMonthDay */

define variable filter-point as character no-undo init "c-dinamo" .
define variable filter-point0 as character no-undo init "c-dinamo" .
define variable filter-label as character no-undo init "Динамика" .
define variable filter-label0 as character no-undo init "Динамика" .

define variable sort-column-name as character no-undo .
define variable v-contra like ub.clients.obj-name no-undo.
define variable v-fact-date as date no-undo.
define variable print-option as character no-undo.
DEFINE VARIABLE v-fact-qnty as decimal no-undo .
DEFINE VARIABLE v-sale-sum-rubl as decimal no-undo .
DEFINE VARIABLE v-sale-sum-base as decimal no-undo .
DEFINE VARIABLE v-cost-sum-rubl as decimal no-undo .
DEFINE VARIABLE v-cost-sum-base as decimal no-undo .
DEFINE VARIABLE v-line-cost-sum-rubl as decimal no-undo .
DEFINE VARIABLE v-line-cost-sum-base as decimal no-undo .
DEFINE VARIABLE loc-flt-rec as logical no-undo.
define variable v-doc-rec as recid no-undo .

define shared buffer t-month for t-month0.
define shared buffer t-fo for t-fo0.
define buffer buf_goods for ub.goods.
define buffer lkp_t-stk for t-stk.
define buffer lkp_t-dinamo for t-dinamo.

define new shared temp-table temp-ot-line0 no-undo
like ub.ot-line
.
define new shared buffer temp-ot-line for temp-ot-line0.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dinamo

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES lkp_t-dinamo temp-ot-line lkp_t-stk

/* Definitions for BROWSE BR-dinamo                                     */
&Scoped-define FIELDS-IN-QUERY-BR-dinamo string((if loc-flt-rec then v-fact-qnty else lkp_t-dinamo.fact-qnty), {&f-qnty}) (if RS-curr = "rubl":U then string((if loc-flt-rec then v-sale-sum-rubl else lkp_t-dinamo.sale-sum-rubl) ,{&f-sum}) else string((if loc-flt-rec then v-sale-sum-base else lkp_t-dinamo.sale-sum-base),{&f-sum})) (if p-cost-view then (if RS-curr = "rubl":U then string((if loc-flt-rec then v-cost-sum-rubl else lkp_t-dinamo.cost-sum-rubl) , {&f-sum}) else string((if loc-flt-rec then v-cost-sum-base else lkp_t-dinamo.cost-sum-base), {&f-sum})) else "":U)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dinamo
&Scoped-define SELF-NAME BR-dinamo
&Scoped-define QUERY-STRING-BR-dinamo FOR EACH lkp_t-dinamo no-lock where                                  lkp_t-dinamo.ym = t-month.ym                                AND LKP_T-DINAMO.EXT-doc-type = p-mode                                AND lkp_t-dinamo.sign = p-sign
&Scoped-define OPEN-QUERY-BR-dinamo OPEN QUERY {&SELF-NAME} FOR EACH lkp_t-dinamo no-lock where                                  lkp_t-dinamo.ym = t-month.ym                                AND LKP_T-DINAMO.EXT-doc-type = p-mode                                AND lkp_t-dinamo.sign = p-sign.
&Scoped-define TABLES-IN-QUERY-BR-dinamo lkp_t-dinamo
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dinamo lkp_t-dinamo


/* Definitions for BROWSE BR-docs                                       */
&Scoped-define FIELDS-IN-QUERY-BR-docs get-doc( input temp-ot-line.doc-code, input temp-ot-line.ext-doc-type, (if temp-ot-line.fact-qnty > 0 then 1 else - 1), output v-fact-date, output v-contra) temp-ot-line.doc-code temp-ot-line.obj-type + string(temp-ot-line.obj-code ) v-fact-date v-contra temp-ot-line.fact-qnty (If Rs-curr = "rubl":U then temp-ot-line.sum-rubl else temp-ot-line.sum-base) (If Rs-curr = "rubl":U then temp-ot-line.sum-rubl / temp-ot-line.fact-qnty else temp-ot-line.sum-base / temp-ot-line.fact-qnty) decimal(entry(1, temp-ot-line.cat-id)) (If Rs-curr = "rubl":U then temp-ot-line.VAT-rubl else temp-ot-line.VAT-base) decimal(entry(2, temp-ot-line.cat-id)) (If Rs-curr = "rubl":U then temp-ot-line.SLT-rubl else temp-ot-line.SLT-base) (If Rs-curr = "rubl":U then temp-ot-line.transport-rubl else temp-ot-line.transport-base) (if Rs-curr = "rubl":U then temp-ot-line.other-rubl else temp-ot-line.other-base) (if Rs-curr = "rubl":U then temp-ot-line.road-tax-rubl else temp-ot-line.road-tax-base) (if Rs-curr = "rubl":U then temp-ot-line.excise-rubl else temp-ot-line.excise-base)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-docs
&Scoped-define SELF-NAME BR-docs
&Scoped-define QUERY-STRING-BR-docs FOR EACH temp-ot-line no-lock
&Scoped-define OPEN-QUERY-BR-docs OPEN QUERY {&SELF-NAME} FOR EACH temp-ot-line no-lock.
&Scoped-define TABLES-IN-QUERY-BR-docs temp-ot-line
&Scoped-define FIRST-TABLE-IN-QUERY-BR-docs temp-ot-line


/* Definitions for BROWSE BR-stk                                        */
&Scoped-define FIELDS-IN-QUERY-BR-stk lkp_t-stk.b-a-full string(lkp_t-stk.fact-qnty, {&f-qnty}) (if Rs-curr = "rubl":U then string(lkp_t-stk.sale-sum-rubl, {&f-sum}) else string(lkp_t-stk.sale-sum-base, {&f-sum})) (if p-cost-view then (if Rs-curr = "rubl":U then string(lkp_t-stk.cost-sum-rubl, {&f-sum}) else string(lkp_t-stk.cost-sum-base, {&f-sum})) else "":U)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-stk
&Scoped-define SELF-NAME BR-stk
&Scoped-define QUERY-STRING-BR-stk FOR EACH lkp_t-stk no-lock where lkp_t-stk.ym = t-month.ym
&Scoped-define OPEN-QUERY-BR-stk OPEN QUERY {&SELF-NAME} FOR EACH lkp_t-stk no-lock where lkp_t-stk.ym = t-month.ym.
&Scoped-define TABLES-IN-QUERY-BR-stk lkp_t-stk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-stk lkp_t-stk


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dinamo}~
    ~{&OPEN-QUERY-BR-docs}~
    ~{&OPEN-QUERY-BR-stk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit RS-curr B-prev B-next B-objects B-doc ~
B-print B-sch B-Help BR-docs BR-stk BR-dinamo
&Scoped-Define DISPLAYED-OBJECTS RS-curr

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD get-doc Dialog-Frame
FUNCTION get-doc RETURNS character
  ( input p-doc-code as character, input p-ext-doc-type as character, input p-sign-int as integer, output p-fact-date  as date, output p-contra as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_docum        LABEL "Документ"
       MENU-ITEM m_list         LABEL "Список документов"
       MENU-ITEM m_card         LABEL "Учетная карточка"
       MENU-ITEM m_oborot       LABEL "Оборотная ведомость".


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-doc
     LABEL "&Документ"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-objects
     LABEL "&Объекты?"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE RS-curr AS CHARACTER INITIAL "rubl"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Баз.вал.", "base",
"", "rubl"
     SIZE 25.5 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dinamo FOR
      lkp_t-dinamo SCROLLING.

DEFINE QUERY BR-docs FOR
      temp-ot-line SCROLLING.

DEFINE QUERY BR-stk FOR
      lkp_t-stk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dinamo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dinamo Dialog-Frame _FREEFORM
  QUERY BR-dinamo DISPLAY
      string((if loc-flt-rec then v-fact-qnty else lkp_t-dinamo.fact-qnty), {&f-qnty})
column-label "Кол-во" format {&f-sqnty}
(if RS-curr = "rubl":U
then string((if loc-flt-rec then v-sale-sum-rubl  else lkp_t-dinamo.sale-sum-rubl) ,{&f-sum})
else string((if loc-flt-rec then v-sale-sum-base  else lkp_t-dinamo.sale-sum-base),{&f-sum}))
COLUMn-LABEL "Сумма продаж. цен" format {&f-ssum}


(if p-cost-view then
(if RS-curr = "rubl":U
then string((if loc-flt-rec then v-cost-sum-rubl  else lkp_t-dinamo.cost-sum-rubl) , {&f-sum})
else string((if loc-flt-rec then v-cost-sum-base  else lkp_t-dinamo.cost-sum-base), {&f-sum}))
else "":U)
COLUMn-LABEL "Сумма учетных цен" format {&f-ssum}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 82 BY 4.92
         BGCOLOR 8
         TITLE BGCOLOR 8 "Итого по документам".

DEFINE BROWSE BR-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-docs Dialog-Frame _FREEFORM
  QUERY BR-docs DISPLAY
      get-doc( input temp-ot-line.doc-code, input temp-ot-line.ext-doc-type, (if temp-ot-line.fact-qnty > 0 then 1 else - 1), output v-fact-date, output v-contra)
  COLUMN-LABEL "Тип док-та" format "X(18)"
temp-ot-line.doc-code
temp-ot-line.obj-type + string(temp-ot-line.obj-code ) COLUMn-LABEL "Объект" format "X(8)"
v-fact-date COLUMN-LABEL "Факт.дата" format "99/99/9999"
v-contra column-label "Контрагент" format "X(20)"
temp-ot-line.fact-qnty COLUMN-LABEL "Кол-во" format {&f-qnty}
(If Rs-curr = "rubl":U
then temp-ot-line.sum-rubl
else temp-ot-line.sum-base)
COLUMN-LABEL "Сумма"  format {&f-sum}
(If Rs-curr = "rubl":U
then temp-ot-line.sum-rubl / temp-ot-line.fact-qnty
else temp-ot-line.sum-base / temp-ot-line.fact-qnty)
column-label "Цена приведенная" format {&f-sum}
decimal(entry(1, temp-ot-line.cat-id)) COLUMn-LABEL "НДС" format "99.99"
(If Rs-curr = "rubl":U
then temp-ot-line.VAT-rubl
else temp-ot-line.VAT-base)
 COLUMN-LABEL "Сумма НДС" format {&f-sum}
decimal(entry(2, temp-ot-line.cat-id)) COLUMn-LABEL "НП" format "99.99"
(If Rs-curr = "rubl":U
then temp-ot-line.SLT-rubl
else temp-ot-line.SLT-base) COLUMN-LABEL "Сумма НП"  format {&f-sum}
(If Rs-curr = "rubl":U
then temp-ot-line.transport-rubl
else temp-ot-line.transport-base) COLUMN-LABEL "Транспортные расходы"  format {&f-sum}
(if  Rs-curr = "rubl":U
then temp-ot-line.other-rubl
else temp-ot-line.other-base) COLUMN-LABEL "Сумма др.расходов"  format {&f-sum}
(if  Rs-curr = "rubl":U
then temp-ot-line.road-tax-rubl
else temp-ot-line.road-tax-base) COLUMN-LABEL "Сумма дор.налога"  format {&f-sum}
(if  Rs-curr = "rubl":U
then temp-ot-line.excise-rubl
else temp-ot-line.excise-base) COLUMN-LABEL "Сумма акциза"  format {&f-sum}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.17.

DEFINE BROWSE BR-stk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-stk Dialog-Frame _FREEFORM
  QUERY BR-stk DISPLAY
      lkp_t-stk.b-a-full
column-label "":U
FORMAT "X(18)"

string(lkp_t-stk.fact-qnty, {&f-qnty})
column-label "Кол-во" format {&f-Sqnty}

(if Rs-curr = "rubl":U
then string(lkp_t-stk.sale-sum-rubl, {&f-sum})
else string(lkp_t-stk.sale-sum-base, {&f-sum}))
column-label "Сумма продаж. цен" format {&f-ssum}

(if p-cost-view then
(if Rs-curr = "rubl":U
then string(lkp_t-stk.cost-sum-rubl, {&f-sum})
else string(lkp_t-stk.cost-sum-base, {&f-sum}))
else "":U)
column-label "Сумма учетных цен" format {&f-ssum}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 82 BY 4.92
         BGCOLOR 8
         TITLE BGCOLOR 8 "Остатки".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     RS-curr AT ROW 1 COL 12.63 NO-LABEL
     B-prev AT ROW 1 COL 41
     B-next AT ROW 1 COL 45
     B-objects AT ROW 1 COL 49
     B-doc AT ROW 1 COL 59
     B-print AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     BR-docs AT ROW 2.5 COL 1
     BR-stk AT ROW 15.96 COL 10
     BR-dinamo AT ROW 15.96 COL 10
     SPACE(7.25) SKIP(1.17)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Учетная карточка"
         CANCEL-BUTTON b-quit.


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
/* BROWSE-TAB BR-docs B-Help Dialog-Frame */
/* BROWSE-TAB BR-stk BR-docs Dialog-Frame */
/* BROWSE-TAB BR-dinamo BR-stk Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dinamo
/* Query rebuild information for BROWSE BR-dinamo
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH lkp_t-dinamo no-lock where
                                 lkp_t-dinamo.ym = t-month.ym
                               AND LKP_T-DINAMO.EXT-doc-type = p-mode
                               AND lkp_t-dinamo.sign = p-sign.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-dinamo */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-docs
/* Query rebuild information for BROWSE BR-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-ot-line no-lock.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-stk
/* Query rebuild information for BROWSE BR-stk
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH lkp_t-stk no-lock where lkp_t-stk.ym = t-month.ym.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-stk */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Учетная карточка */
DO:
  assign
  p-curr = Rs-curr.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-doc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-doc Dialog-Frame
ON CHOOSE OF B-doc IN FRAME Dialog-Frame /* Документ */
DO:
  run proc-b-doc in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-next
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-next Dialog-Frame
ON CHOOSE OF B-next IN FRAME Dialog-Frame /* >> */
DO:
    run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-objects Dialog-Frame
ON CHOOSE OF B-objects IN FRAME Dialog-Frame /* Объекты? */
DO:
  run proc-view-objects in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-prev
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-prev Dialog-Frame
ON CHOOSE OF B-prev IN FRAME Dialog-Frame /* << */
DO:
    run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Выход */
DO:
    assign
    p-curr = rs-curr.
    p-next-prev = ?.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
    run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_card
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_card Dialog-Frame
ON CHOOSE OF MENU-ITEM m_card /* Учетная карточка */
DO:
  assign
  print-option = "card":U.
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_docum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_docum Dialog-Frame
ON CHOOSE OF MENU-ITEM m_docum /* Документ */
DO:
   print-option = "document":U.
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_list Dialog-Frame
ON CHOOSE OF MENU-ITEM m_list /* Список документов */
DO:
   print-option = "list":U.
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_oborot
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_oborot Dialog-Frame
ON CHOOSE OF MENU-ITEM m_oborot /* Оборотная ведомость */
DO:
   print-option = "oborot":U.
  run proc-b-print in this-procedure no-error.
  if error-status:error then return no-apply.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-curr Dialog-Frame
ON VALUE-CHANGED OF RS-curr IN FRAME Dialog-Frame
DO:
  assign
  Rs-curr.
 br-docs:refresh().
 if br-stk:visible in frame {&frame-name} then br-stk:refresh().
 if br-dinamo:visible in frame {&frame-name} then br-dinamo:refresh().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dinamo
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i
  &disable_diasize_init=true &browse-name="br-docs"
}

{ gbl/setfltnm.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
p-next-prev = yes.
n-p: do while p-next-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if not avail t-month then return error.
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
  RUN Myenable.
  run diasize_add_browse in this-procedure
    (input  'width':u
    ,input  browse br-dinamo :handle
    ) .
  run diasize_init in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
end. /* do while */
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
  DISPLAY RS-curr
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RS-curr B-prev B-next B-objects B-doc B-print B-sch B-Help
         BR-docs BR-stk BR-dinamo
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-tables Dialog-Frame
PROCEDURE fill-tables :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE bfact-order like ub.ot-line.fact-order no-undo .
DEFINE VARIABLE afact-order like ub.ot-line.fact-order no-undo .
DEFINE VARIABLE v-sale-sum-type as character no-undo .
DEFINE VARIABLE v-last-day as integer no-undo .

for each temp-ot-line :
    delete temp-ot-line.
end.

if buf_goods.gds-type = {&gds-goods} then do:
  assign
  v-sale-sum-type = {&arh-crsa}
  .
end.
else do:
  assign
  v-sale-sum-type = {&arh-crsa-service}
  .
end.
ASSIGN v-last-day = last-day( date( t-month.month_, 1, t-month.year_ ) ).
run day-begin-fact-order in this-procedure (
                                             input date(t-month.month_, 1, t-month.year)
                                             ,output bfact-order).
run factord-end-day  in this-procedure (
                                             input  date(t-month.month_, v-last-day, t-month.year_)
                                             ,output afact-order).

CASE p-mode :
    WHEN {&all}        THEN DO:
        for each obj-list no-lock,
            each ub.ot-line no-lock where
                     ub.ot-line.artic = buf_goods.artic
                AND ub.ot-line.prod-type = buf_goods.prod-type
                AND ub.ot-line.prod-code = buf_goods.prod-code
                AND ub.OT-LINE.OBJ-TYPE = OBJ-LIST.OBJ-TYPE
                AND ub.OT-LINE.OBJ-CODE = OBJ-LIST.OBJ-CODE
                AND ub.ot-line.sum-type = v-sale-sum-type
                and ub.ot-line.fact-order >= bfact-order
                and ub.ot-line.fact-order <= afact-order,
             first t-fo no-lock where
                   t-fo.obj-type = obj-list.OBJ-TYPE
                        and t-fo.obj-code = obj-list.obj-code
                        and t-fo.fact-order >= ot-line.fact-order:
            create temp-ot-line.
            buffer-copy ot-line to  temp-ot-line.
        end.
     end. /*when {&all}*/
     otherwise do:
        for each obj-list no-lock,
            each ub.ot-line no-lock where
                     ub.ot-line.artic = buf_goods.artic
                AND ub.ot-line.prod-type = buf_goods.prod-type
                AND ub.ot-line.prod-code = buf_goods.prod-code
                AND ub.OT-LINE.OBJ-TYPE = OBJ-LIST.OBJ-TYPE
                AND ub.OT-LINE.OBJ-CODE = OBJ-LIST.OBJ-CODE
                AND ub.ot-line.sum-type = v-sale-sum-type
                and ub.ot-line.fact-order >= bfact-order
                and ub.ot-line.fact-order <= afact-order
              AND ub.ot-line.ext-doc-type = p-mode,
             first t-fo no-lock where
                   t-fo.obj-type = obj-list.OBJ-TYPE
                        and t-fo.obj-code = obj-list.obj-code
                        and t-fo.fact-order >= ot-line.fact-order:
            create temp-ot-line.
            buffer-copy ot-line to  temp-ot-line.
        end.
    END.
END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
b-print:MENU-MOUSE IN FRAME {&frame-name} = 1.
if p-mode <> {&all} then do:
    assign
    menu-item m_card:sensitive in menu menu-b-print = no
    menu-item m_oborot:sensitive in menu menu-b-print = no
    .
end.
  ENABLE
  b-quit
  B-prev
  B-next
  B-objects
  B-doc
  B-sch
  B-print
  B-Help
  BR-docs
  BR-dinamo
  BR-stk
  RS-curr
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  Rs-curr = p-curr.
  display RS-curr WITH FRAME Dialog-Frame.
   CASE p-mode:
    when {&all} then do:
      hide br-dinamo in frame {&frame-name}.
       {&open-query-br-stk}
    end.
    otherwise do:
      hide br-stk in frame {&frame-name}.
      {&open-query-br-dinamo}
    end.
  END.
  run waitfram-show in this-procedure("Ждите...").
  run fill-tables in this-procedure .
RUn OpenBR in this-procedure ( input yes, input no, input '':U).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
DEFINE VARIABLE l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.

define variable v-month-name as character no-undo.
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-ext-doc-type as character no-undo .
DEFINE VARIABLE v-ext-doc-type-full as character no-undo .
DEFINE VARIABLE v-doc-type as character no-undo .
DEFINE VARIABLE v-doc-type-full as character no-undo .
DEFINE VARIABLE v-idoc-type as character no-undo .
DEFINE VARIABLE v-sign as character no-undo .
DEFINE VARIABLE v-sign-int as integer no-undo .
define buffer cost_ot-line for ub.ot-line.


if available t-month then do:
    assign
    v-month-name = string(t-month.month_).
    run gbl/monthnam.p (input t-month.month_, output v-month-name) no-error.
end.
assign
title0 =    {&frame-title}
.
run waitfram-show in this-procedure("Ждите...").
DEFINE VARIABLE sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query OPEN QUERY br-docs FOR EACH temp-ot-line

&scop flt-open-dyn_open-query FOR EACH temp-ot-line

&scop flt-open-query-handle QUERY br-docs:handle

&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition indexed-reposition

&scop flt-open-query p-open-query

&scop flt-open-table-name temp-ot-line

&scop flt-open-search-option no-lock

&scop flt-open-find-next p-find-next

&scop flt-open-find-recid v-doc-rec

&scop flt-open-find-condition p-find-condition

&scop flt-open-find-buffer-name temp-ot-line
&scop flt-open-open-query-tail

&scop flt-open-debug-file

define variable l-open-query as logical   no-undo .

  CASE p-mode :
    WHEN {&all}        THEN DO:
      ASSIGN
      frame {&frame-name}:TITLE = title0
      filter-point = filter-point0 + p-mode
      filter-label = substitute("&1", filter-label0)
      .
      { gbl/fltopend.i
          &where-cond = "  TRUE "
          &use-ind    = "  "
          &by         = " by temp-ot-line.fact-order descending " }
    END.
    otherwise do:
       assign
       v-sign = string(p-sign)
       v-ext-doc-type = p-mode
       ii = lookup(v-ext-doc-type, {&TDEDT_List})
       v-doc-type = get-doc-type(input ii,
                                 input-output p-mode,
                                 input-output v-sign,
                                 output v-ext-doc-type-full,
                                 output v-doc-type-full,
                                 output v-idoc-type)
       v-sign-int = integer(v-sign)
       .
       assign
       filter-point = filter-point0 + v-ext-doc-type-full
       filter-label = substitute("&1 v-ext-doc-type-full", filter-label0)
       .
       ASSIGN
       frame {&frame-name}:TITLE = title0 + {&space-char} + v-ext-doc-type-full
       .
       if p-sign = 0 then do:
       { gbl/fltopend.i
         &where-cond = " TRUE "
         &use-ind    = "  "
         &by         = " by temp-ot-line.fact-order descending " }
       end.
       else do:
        if p-sign = 1 then do:
          { gbl/fltopend.i
            &where-cond = " ~  temp-ot-line.fact-qnty >= 0  "
            &use-ind    = "  "
            &by         = " by temp-ot-line.fact-order descending " }
        end.
        else do:
          { gbl/fltopend.i
            &where-cond = " ~ temp-ot-line.fact-qnty < 0  "
         &use-ind    = "  "
         &by         = "  " }


        end.
      end.
    END.
END CASE.

if loc-flt-rec then do:
  assign
  v-fact-qnty     = 0
  v-sale-sum-rubl = 0
  v-sale-sum-base = 0
  v-cost-sum-rubl = 0
  v-cost-sum-base = 0
  loc-flt-rec = yes
  .
  get first br-docs  .
  repeat while avail temp-ot-line:
    find first cost_ot-line no-lock where
                  cost_ot-line.artic = buf_goods.artic
              AND cost_ot-line.prod-type = buf_goods.prod-type
              AND cost_ot-line.prod-code = buf_goods.prod-code
              AND cost_ot-line.obj-type = temp-ot-line.obj-type
              AND cost_ot-line.obj-code = temp-ot-line.obj-code
              AND cost_ot-line.sum-type = {&arh-cost}
              AND cost_ot-line.fact-order = temp-ot-line.fact-order
              no-error .
    if avail cost_ot-line then do:
      assign
      v-cost-sum-rubl = cost_ot-line.sum-rubl
      v-cost-sum-base = cost_ot-line.sum-base
      .
    end.
    else do:
      assign
      v-line-cost-sum-rubl = 0
      v-line-cost-sum-base = 0
      .
    end.
    assign
    v-fact-qnty     = v-fact-qnty     + temp-ot-line.fact-qnty
    v-sale-sum-rubl = v-sale-sum-rubl + temp-ot-line.sum-rubl
    v-sale-sum-base = v-sale-sum-base + temp-ot-line.sum-base
    v-cost-sum-rubl = v-cost-sum-rubl + v-line-cost-sum-rubl
    v-cost-sum-base = v-cost-sum-base + v-line-cost-sum-base
    .
    get next br-docs.
  END.
  {&open-query-br-dinamo}
end.
if not p-open-query then
REPOSITION br-docs to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-docs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  REPOSITION br-docs to row 1 No-ERROR.
end.
run waitfram-hide in this-procedure.
APPLY "VALUE-CHANGED" TO br-docs in frame {&frame-name}.
APPLY "ENTRY" TO br-docs.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-line-doc Dialog-Frame
PROCEDURE print-line-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_temp_trn-doc-code     for temp_trn-doc-code.

if not available temp-ot-line then return error.
CASE temp-ot-line.ext-doc-type:
    when {&TDEDT_Overturn}
    then do:
        find first buf_price-doc no-lock where buf_price-doc.doc-num = temp-ot-line.doc-code no-error.
        if not available buf_price-doc then return error.
        run rep/pr-dprn.w ( input parparentproc, recid( buf_price-doc ) ).
    end.
    otherwise do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = temp-ot-line.doc-code no-error.
        if not available buf_trn-doc then return error.
        empty temp-table buf_temp_trn-doc-code.
        create buf_temp_trn-doc-code.
        assign
            buf_temp_trn-doc-code.doc-code = buf_trn-doc.doc-code
        .
        run rep/d-docm.w ( input parparentproc, input this-procedure, input table buf_temp_trn-doc-code ).
    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-list-doc Dialog-Frame
PROCEDURE print-list-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-get-doc as character no-undo .
define variable v-contra like ub.clients.obj-name no-undo.
define variable v-fact-date as date no-undo.
DEFINE VARIABLE v-obj as character no-undo .
DEFINE VARIABLE v-vat-pc as decimal no-undo .
DEFINE VARIABLE v-slt-pc as decimal no-undo .
DEFINE VARIABLE v-price-base as decimal no-undo .
DEFINE VARIABLE v-price-rubl as decimal no-undo .
DEFINE VARIABLE accum-fact-qnty as decimal no-undo .
DEFINE VARIABLE accum-sum-rubl as decimal no-undo .
DEFINE VARIABLE accum-sum-base as decimal no-undo .
DEFINE VARIABLE accum-VAT-rubl as decimal no-undo .
DEFINE VARIABLE accum-VAT-base as decimal no-undo .
DEFINE VARIABLE accum-SLT-rubl as decimal no-undo .
DEFINE VARIABLE accum-SLT-base as decimal no-undo .
DEFINE VARIABLE accum-transport-base as decimal no-undo .
DEFINE VARIABLE accum-transport-rubl as decimal no-undo .
DEFINE VARIABLE accum-other-base as decimal no-undo .
DEFINE VARIABLE accum-other-rubl as decimal no-undo .
DEFINE VARIABLE accum-road-tax-base as decimal no-undo .
DEFINE VARIABLE accum-road-tax-rubl as decimal no-undo .
DEFINE VARIABLE accum-excise-base as decimal no-undo .
DEFINE VARIABLE accum-excise-rubl as decimal no-undo .
DEFINE VARIABLE accum-count     as integer no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE Line as character no-undo .
define variable v-doc-rec as recid no-undo .
define buffer buf_t-stk for t-stk.


define frame Fdinamo
v-get-doc COLUMN-LABEL "Тип док-та" format "X(18)"
temp-ot-line.doc-code
v-obj COLUMn-LABEL "Объект" format "X(8)"
v-fact-date COLUMN-LABEL "Факт.дата" format "99/99/9999"
v-contra column-label "Контрагент" format "X(20)"
temp-ot-line.fact-qnty COLUMN-LABEL "Кол-во" format {&f-qnty}
temp-ot-line.sum-rubl COLUMN-LABEL "Сумма"  format {&f-sum}
v-price-rubl column-label "Цена приведенная" format {&f-sum}
v-vat-pc COLUMn-LABEL "НДС" format "99.99"
temp-ot-line.VAT-rubl COLUMN-LABEL "Сумма НДС" format {&f-sum}
v-slt-pc COLUMn-LABEL "НП" format "99.99"
temp-ot-line.SLT-rubl COLUMN-LABEL "Сумма НП" format {&f-sum}
/*temp-ot-line.transport-rubl COLUMN-LABEL "Транспортные расходы"  format {&f-sum}*/
/*temp-ot-line.other-rubl COLUMN-LABEL "Сумма др.расходов"  format {&f-sum}*/
/*temp-ot-line.road-tax-rubl COLUMN-LABEL "Сумма дор.налога"  format {&f-sum}*/
/*temp-ot-line.excise-rubl COLUMN-LABEL "Сумма акциза"  format {&f-sum}*/
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER(PrnLibStream) AT 60 FORMAT ">>9" SKIP
Line format "X(181)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 181).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&DOS_CW_2}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream unformatted
frame {&frame-name}:title format "x(181)" {&new-line}
(fill({&space-char}, 20) +
 "(":U +  (if RS-curr = "rubl":U then "{&abbr_rubli_firstshift}" else "Баз.вал.") + ")":U) skip
 str4
 SKIP(1) .
FORM HEADER
Line format "X(181)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
run waitfram-show in this-procedure("Ждите...").
v-doc-rec = recid( temp-ot-line ).
DO WHILE available temp-ot-line :
   GET prev br-docs.
END.
GET next br-docs.
FORM with FRAME FDinamo  .
DO WHILE available temp-ot-line :
display stream PrnLibStream
get-doc( input temp-ot-line.doc-code, input temp-ot-line.ext-doc-type, (if temp-ot-line.fact-qnty > 0 then 1 else - 1), output v-fact-date, output v-contra)
  @ v-get-doc
temp-ot-line.doc-code
(temp-ot-line.obj-type + string(temp-ot-line.obj-code )) @ v-obj
v-fact-date
v-contra
temp-ot-line.fact-qnty
(IF Rs-curr = "rubl":U
then  temp-ot-line.sum-rubl
 else  temp-ot-line.sum-base) @ temp-ot-line.sum-rubl
(IF Rs-curr = "rubl":U
then  temp-ot-line.sum-rubl / temp-ot-line.fact-qnty
else temp-ot-line.sum-base / temp-ot-line.fact-qnty) @ v-price-rubl
decimal(entry(1, temp-ot-line.cat-id)) @ v-vat-pc
(IF Rs-curr = "rubl":U
then  temp-ot-line.VAT-rubl
else temp-ot-line.VAT-base) @ temp-ot-line.Vat-rubl
decimal(entry(2, temp-ot-line.cat-id)) @ v-slt-pc
(IF Rs-curr = "rubl":U
then  temp-ot-line.SLT-rubl
else temp-ot-line.SLT-base) @ temp-ot-line.SLt-rubl
/*
(IF Rs-curr = "rubl":U
then temp-ot-line.transport-rubl
else temp-ot-line.transport-base @ temp-ot-line.transport-rubl)
(IF Rs-curr = "rubl":U
then temp-ot-line.other-rubl
else temp-ot-line.other-base) @ temp-ot-line.other-rubl
(IF Rs-curr = "rubl":U
then temp-ot-line.road-tax-rubl
else temp-ot-line.road-tax-base) @ temp-ot-line.road-tax-rubl
(IF Rs-curr = "rubl":U
then temp-ot-line.excise-rubl
else  temp-ot-line.excise-base) @ temp-ot-line.excise-rubl
*/
  WITH FRAME Fdinamo.
  DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
  assign
  accum-count            = accum-count            +    1
  accum-fact-qnty        = accum-fact-qnty        +    temp-ot-line.fact-qnty
  accum-sum-rubl         = accum-sum-rubl         +    temp-ot-line.sum-rubl
  accum-sum-base         = accum-sum-base         +    temp-ot-line.sum-base
  accum-VAT-rubl         = accum-VAT-rubl         +    temp-ot-line.VAT-rubl
  accum-VAT-base         = accum-VAT-base         +    temp-ot-line.VAT-base
  accum-SLT-rubl         = accum-SLT-rubl         +    temp-ot-line.SLT-rubl
  accum-SLT-base         = accum-SLT-base         +    temp-ot-line.SLT-base
  accum-transport-base   = accum-transport-base   +    temp-ot-line.transport-base
  accum-transport-rubl   = accum-transport-rubl   +    temp-ot-line.transport-rubl
  accum-other-base       = accum-other-base       +    temp-ot-line.other-base
  accum-other-rubl       = accum-other-rubl       +    temp-ot-line.other-rubl
  accum-road-tax-base    = accum-road-tax-base    +    temp-ot-line.road-tax-base
  accum-road-tax-rubl    = accum-road-tax-rubl    +    temp-ot-line.road-tax-rubl
  accum-excise-base      = accum-excise-base      +    temp-ot-line.excise-base
  accum-excise-rubl      = accum-excise-rubl      +    temp-ot-line.excise-rubl
  .
  GET next br-docs.
END.
UNDERLINE stream PrnLibStream
v-get-doc
temp-ot-line.doc-code
v-obj
v-fact-date
v-contra
temp-ot-line.fact-qnty
temp-ot-line.sum-rubl
v-price-rubl
v-vat-pc
temp-ot-line.VAT-rubl
v-slt-pc
temp-ot-line.SLT-rubl
/*temp-ot-line.transport-rubl*/
/*temp-ot-line.other-rubl*/
/*temp-ot-line.road-tax-rubl*/
/*temp-ot-line.excise-rubl*/
WITH FRAME Fdinamo.
DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
display stream PrnLibStream
string(accum-count)      @   v-get-doc
accum-fact-qnty          @   temp-ot-line.fact-qnty
(If RS-curr = "rubl":U
then accum-sum-rubl
else accum-sum-base)      @   temp-ot-line.sum-rubl
(If RS-curr = "rubl":U
then accum-VAT-rubl
else accum-VAT-base)           @   temp-ot-line.VAT-rubl
accum-SLT-rubl           @   temp-ot-line.SLT-rubl
/*
(If RS-curr = "rubl":U
accum-transport-rubl
else accum-transport-base)     @   temp-ot-line.transport-rubl
(If RS-curr = "rubl":U
then accum-other-rubl
else accum-other-base)         @   temp-ot-line.other-rubl
(If RS-curr = "rubl":U
then accum-road-tax-rubl
else accum-road-tax-base)      @   temp-ot-line.road-tax-rubl
(If RS-curr = "rubl":U
then accum-excise-rubl
else accum-excise-rubl)        @   temp-ot-line.excise-rubl
*/
WITH FRAME Fdinamo.
DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
if p-mode = {&all} then do:
  /*остатки покажем только если все документы*/
  DISPLAY stream PrnLibStream
  "Остатки"  @ v-get-doc
  WITH FRAME Fdinamo.
  DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
  for each buf_t-stk no-lock where
          buf_t-stk.ym = t-month.ym:
    DISPLAY stream PrnLibStream
    buf_t-stk.b-a-full  @ v-get-doc
    buf_t-stk.fact-qnty @ temp-ot-line.fact-qnty
    (If RS-curr = "rubl":U
  then  buf_t-stk.sale-sum-rubl
  else   buf_t-stk.sale-sum-base)  @ temp-ot-line.sum-rubl
    WITH FRAME Fdinamo.

    DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
  end.
end. /*остатки*/


HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Fdinamo.
output STREAM PrnLibStream CLOSE.

run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

reposition br-docs to recid v-doc-rec no-error.
APPLY "entry" to br-docs.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-other Dialog-Frame
PROCEDURE print-other :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-last-day as integer no-undo.
ASSIGN v-last-day = last-day( date( t-month.month_, 1, t-month.year_ ) ).
CASE print-option:
    when "card":U then dO:

      run proc-print-crd in this-procedure  (
                                                 buf_goods.artic
                                                ,buf_goods.prod-type
                                                ,buf_goods.prod-code
                                                ,date(t-month.month_, 1, t-month.year_)
                                                ,date(t-month.month_, v-last-day, t-month.year_   )


                           ) no-error  .

    end.
    when "oborot":U then do:
      run proc-print-oborot in this-procedure  (
                                                 buf_goods.artic
                                                ,buf_goods.prod-type
                                                ,buf_goods.prod-code
                                                ,date(t-month.month_, 1, t-month.year_)
                                                ,date(t-month.month_, v-last-day, t-month.year_   )
                                                 )

      no-error.
    end.
END CASE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-doc Dialog-Frame
PROCEDURE proc-b-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if not available temp-ot-line then do:
    return error.
end.

run str/showdoc.p (input parparentproc,
                        input temp-ot-line.doc-code
                       ,input buf_goods.artic
                       ,input buf_goods.prod-type
                       ,input buf_goods.prod-code
                       ,input ?).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-move Dialog-Frame
PROCEDURE proc-b-move :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER par-action as character No-UNDO.
DEFINE VARIABLE  loc#log as logical no-undo .
  ASSIGN p-doc-rec = RECID( t-month ).
  CASE par-action:
    when "b-next":U then do:
      if valid-handle (p-br-handle) then do:
        loc#log = p-br-handle:select-next-row().
      end.
    end.
    when "b-prev":U then do:
      if valid-handle (p-br-handle) then do:
        loc#log = p-br-handle:select-prev-row().
      end.
    end.
  END CASE.
  ASSIGN p-doc-rec = RECID( t-month ).
  if not loc#log then DO:
    MESSAGE
      "Это" ( IF par-action = "B-Next":U THEN "последний" ELSE "первый" )
      "месяц в списке!"
    VIEW-AS ALERT-BOX INFORMATION.
    RETURN NO-APPLY.
  END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-print Dialog-Frame
PROCEDURE proc-b-print :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
   if print-option = "" then do:
     run gbl/pop-up.p (self:handle, no) no-error.
   end.
   if print-option = "":U then return error.
   CASE print-option:
    when "document" then do:
        run print-line-doc in this-procedure no-error.
    end.
    when "list" then do:
        run print-list-doc in this-procedure no-error.
    end.
    otherwise do:
        run print-other in this-procedure no-error.
    end.
   END.
   assign
   print-option = "":U.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  tbl = 'ot-line'
  join-tbl = 'temp-ot-line'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер док-та', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('fact-order', 'Факт.дата', 'fact-order-d',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
if p-mode = {&all} then do:
  run fltfield-add in this-procedure('ext-doc-type', 'Тип док-та', 'ext-doc-type',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
end.
run fltfield-add in this-procedure('sum-rubl', 'Сумма {&abbr_rubli}', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sum-base', 'Сумма баз.вал.', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT (filter-point + {&delim-par} + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  if return-value = {&flt-undo-value} then return error.
  RUN OpenBr in this-procedure ( input yes, input no, input '':U).
END. /* Filter-Block */




END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION get-doc Dialog-Frame
FUNCTION get-doc RETURNS character
  ( input p-doc-code as character, input p-ext-doc-type as character, input p-sign-int as integer, output p-fact-date  as date, output p-contra as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-ext-doc-type as character no-undo .
DEFINE VARIABLE v-ext-doc-type-full as character no-undo .
DEFINE VARIABLE v-doc-type as character no-undo .
DEFINE VARIABLE v-doc-type-full as character no-undo .
DEFINE VARIABLE v-idoc-type as character no-undo .
DEFINE VARIABLE v-sign as character no-undo .
DEFINE VARIABLE v-sign-int as integer no-undo .
DEFINE VARIABLE ii as integer no-undo.

define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_price-doc for ub.price-doc .


  assign
  v-ext-doc-type = p-ext-doc-type
  ii = lookup(v-ext-doc-type, {&TDEDT_List})
  v-sign = string(p-sign-int)
  v-doc-type = get-doc-type(input ii, input-output v-ext-doc-type, input-output v-sign, output v-ext-doc-type-full, output v-doc-type-full, output v-idoc-type)
  .


CASE p-ext-doc-type:
    when {&TDEDT_Overturn} then do:
        find first buf_price-doc no-lock where buf_price-doc.doc-num = p-doc-code.
            assign
    p-fact-date = buf_price-doc.fact-date
    p-contra = "":U
    .
    end.
    otherwise do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code.
                    assign
    p-fact-date = buf_trn-doc.fact-date
    p-contra = buf_trn-doc.cli-name
    .

 end.
END CASE.

  RETURN v-ext-doc-type-full.   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
