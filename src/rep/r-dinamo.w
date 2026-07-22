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

Динамика движения товара-форма

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/27/03
Author: Bakhtadze Natalya
Creation date: 05/27/03

*/
/*
         ! ! !  В Н И М А Н И Е  ! ! !
   не забудь: после исправления файла в UIB

   САМОЕ ГЛАВНОЕ - подставить new shared в DEFINE QUERY br-month !!!!!!!
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.goods.gds-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Динамика движения товара-форма".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ cmp/r-page1.i }
{ gbl/color.i }
{ trg/factord.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ rep/r-dinamo.i "NEW SHARED" }
{ gbl/clntattr.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }

FUNCTION Last-Day RETURNS INTEGER ( INPUT i-date AS DATE ) :
  DEFINE VARIABLE t_date AS DATE NO-UNDO.
  ASSIGN t_date = DATE( MONTH( i-date ), 28, YEAR( i-date ) ).
  RETURN ( DAY( t_date - DAY( t_date + 4 ) + 4 ) ).
END FUNCTION. /* LastMonthDay */

DEFINE NEW SHARED var br-handle as handle no-undo.
define buffer buf_goods for ub.goods.
define new shared buffer t-month  for t-month0.
define new shared buffer t-fo  for t-fo0.
DEFINE VARIABLE v-enable-cost as logical no-undo init yes.
DEFINE VARIABLE v-cost-obj as logical no-undo .
DEFINE VARIABLE v-cost-view as logical no-undo .
DEFINE VARIABLE v-cut-ym as integer no-undo .
define variable v-row as integer no-undo.
define variable v-MontYear_List as character no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-dinamo

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES t-dinamo t-month t-stk

/* Definitions for BROWSE BR-dinamo                                     */
&Scoped-define FIELDS-IN-QUERY-BR-dinamo t-dinamo.doc-type-full /* t-dinamo.ext-doc-type-full */ (if t-dinamo.ext-doc-type <> "":U and not t-dinamo.is-zuka then string(t-dinamo.fact-qnty, {&f-qnty}) else "":U) (if t-dinamo.ext-doc-type <> "":U then string((if RS-curr = "rubl":U then t-dinamo.sale-sum-rubl else t-dinamo.sale-sum-base), (if t-dinamo.is-zuka then {&f-pcnt} else {&f-sum}) ) else "":U) (if t-dinamo.ext-doc-type <> "":U and v-cost-view then string((if RS-curr = "rubl":U then t-dinamo.cost-sum-rubl else t-dinamo.cost-sum-base), {&f-sum}) else "":U)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-dinamo
&Scoped-define SELF-NAME BR-dinamo
&Scoped-define QUERY-STRING-BR-dinamo FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym
&Scoped-define OPEN-QUERY-BR-dinamo OPEN QUERY {&SELF-NAME} FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym.
&Scoped-define TABLES-IN-QUERY-BR-dinamo t-dinamo
&Scoped-define FIRST-TABLE-IN-QUERY-BR-dinamo t-dinamo


/* Definitions for BROWSE BR-month                                      */
&Scoped-define FIELDS-IN-QUERY-BR-month t-month.month_ t-month.year_
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-month
&Scoped-define SELF-NAME BR-month
&Scoped-define OPEN-QUERY-BR-month define variable v-last-ym as integer no-undo. if not can-find(first t-month no-lock where                         t-month.ym > v-cut-ym) and          can-find(first t-month no-lock where                         t-month.ym <= v-cut-ym) then do:     find last t-month no-lock where                 t-month.ym < v-cut-ym .     assign     v-last-ym = t-month.ym     .     OPEN QUERY {&self-name} FOR EACH t-month no-lock where t-month .ym = v-last-ym.  end.  else do: OPEN QUERY {&SELF-NAME} FOR EACH t-month no-lock where t-month.ym >= v-cut-ym. end.
&Scoped-define TABLES-IN-QUERY-BR-month t-month
&Scoped-define FIRST-TABLE-IN-QUERY-BR-month t-month


/* Definitions for BROWSE BR-stk                                        */
&Scoped-define FIELDS-IN-QUERY-BR-stk t-stk.b-a-full string(t-stk.fact-qnty, {&f-qnty}) string((if RS-curr = "rubl":U then t-stk.sale-sum-rubl else t-stk.sale-sum-base), {&f-sum}) (if v-cost-view then string((if RS-curr = "rubl":U then t-stk.cost-sum-rubl else t-stk.cost-sum-base), {&f-sum}) else "":U)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-stk
&Scoped-define SELF-NAME BR-stk
&Scoped-define QUERY-STRING-BR-stk FOR EACH t-stk no-lock where t-stk.ym = t-month.ym
&Scoped-define OPEN-QUERY-BR-stk OPEN QUERY {&SELF-NAME} FOR EACH t-stk no-lock where t-stk.ym = t-month.ym.
&Scoped-define TABLES-IN-QUERY-BR-stk t-stk
&Scoped-define FIRST-TABLE-IN-QUERY-BR-stk t-stk


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-dinamo}~
    ~{&OPEN-QUERY-BR-month}~
    ~{&OPEN-QUERY-BR-stk}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-Help RECT-2 BR-dinamo RS-curr ~
BR-month BR-stk B-uchet B-objects B-print
&Scoped-Define DISPLAYED-OBJECTS T-cost RS-curr f-date-start F-unit-base

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-objects
     LABEL "&Объекты?"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-uchet
     LABEL "&Уч. карт"
     SIZE 10 BY 1.

DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/9999":U
     LABEL "Данные по совокупности объектов с"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE F-unit-base AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 7.38 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE RS-curr AS CHARACTER INITIAL "rubl"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Баз.вал.", "base",
"abbr_rubli_firstshift", "rubl"
     SIZE 10.75 BY 1.92 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 12.63 BY 3.5.

DEFINE VARIABLE T-cost AS LOGICAL INITIAL no
     LABEL "Учетные цены"
     VIEW-AS TOGGLE-BOX
     SIZE 23.75 BY .88 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-dinamo FOR
      t-dinamo SCROLLING.

DEFINE QUERY BR-month FOR
      t-month SCROLLING.

DEFINE QUERY BR-stk FOR
      t-stk SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-dinamo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-dinamo Dialog-Frame _FREEFORM
  QUERY BR-dinamo DISPLAY
      t-dinamo.doc-type-full
FORMAT "X(18)"
column-label "":U
/*
      t-dinamo.ext-doc-type-full
FORMAT "X(18)"
column-label "":U
*/
(if t-dinamo.ext-doc-type <> "":U and not t-dinamo.is-zuka
 then string(t-dinamo.fact-qnty, {&f-qnty})
 else "":U)
 column-label "Кол-во" format {&f-sqnty}


(if t-dinamo.ext-doc-type <> "":U
then string((if RS-curr = "rubl":U then t-dinamo.sale-sum-rubl else t-dinamo.sale-sum-base),
            (if t-dinamo.is-zuka
             then {&f-pcnt}
             else {&f-sum})
            )
else "":U)
COLUMn-LABEL "Сумма продаж. цен" format {&f-ssum}

(if t-dinamo.ext-doc-type <> "":U and v-cost-view
then string((if RS-curr = "rubl":U then t-dinamo.cost-sum-rubl else t-dinamo.cost-sum-base), {&f-sum})
else "":U)
COLUMn-LABEL "Сумма учетных цен" format {&f-ssum}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 82 BY 14.5
         TITLE "Обороты".

DEFINE BROWSE BR-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-month Dialog-Frame _FREEFORM
  QUERY BR-month DISPLAY
      t-month.month_ column-label "М" format "99":U
t-month.year_ column-label "Г" format "9999":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 9.5 BY 12.

DEFINE BROWSE BR-stk
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-stk Dialog-Frame _FREEFORM
  QUERY BR-stk DISPLAY
      t-stk.b-a-full
column-label "":U
FORMAT "X(18)"

string(t-stk.fact-qnty, {&f-qnty})
column-label "Кол-во" format {&f-Sqnty}

string((if RS-curr = "rubl":U then t-stk.sale-sum-rubl else t-stk.sale-sum-base), {&f-sum})
column-label "Сумма продаж. цен" format {&f-ssum}

(if v-cost-view then
string((if RS-curr = "rubl":U then t-stk.cost-sum-rubl else t-stk.cost-sum-base), {&f-sum})
else "":U)
column-label "Сумма учетных цен" format {&f-ssum}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 82 BY 5.13
         TITLE "Остатки".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     T-cost AT ROW 1 COL 64.63
     B-Help AT ROW 1 COL 89
     BR-dinamo AT ROW 2 COL 17
     RS-curr AT ROW 3.96 COL 2.5 NO-LABEL
     BR-month AT ROW 6.5 COL 1
     BR-stk AT ROW 16.75 COL 17
     B-uchet AT ROW 18.5 COL 1
     B-objects AT ROW 19.5 COL 1
     B-print AT ROW 20.5 COL 1
     f-date-start AT ROW 1.08 COL 46.88 COLON-ALIGNED
     F-unit-base AT ROW 3 COL 3.25 NO-LABEL
     RECT-2 AT ROW 2.71 COL 1.5
     SPACE(85.12) SKIP(15.82)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Динамика движения товара"
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
                                                                        */
/* BROWSE-TAB BR-dinamo RECT-2 Dialog-Frame */
/* BROWSE-TAB BR-month RS-curr Dialog-Frame */
/* BROWSE-TAB BR-stk BR-month Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-date-start IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN F-unit-base IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR TOGGLE-BOX T-cost IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-dinamo
/* Query rebuild information for BROWSE BR-dinamo
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-dinamo */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-month
/* Query rebuild information for BROWSE BR-month
     _START_FREEFORM
define variable v-last-ym as integer no-undo.
if not can-find(first t-month no-lock where
                        t-month.ym > v-cut-ym) and
         can-find(first t-month no-lock where
                        t-month.ym <= v-cut-ym) then do:
    find last t-month no-lock where
                t-month.ym < v-cut-ym .
    assign
    v-last-ym = t-month.ym
    .
    OPEN QUERY {&self-name} FOR EACH t-month no-lock where t-month .ym = v-last-ym.
 end.
 else do:
OPEN QUERY {&SELF-NAME} FOR EACH t-month no-lock where t-month.ym >= v-cut-ym.
end.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-month */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-stk
/* Query rebuild information for BROWSE BR-stk
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH t-stk no-lock where t-stk.ym = t-month.ym.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-stk */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Динамика движения товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-objects
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-objects Dialog-Frame
ON CHOOSE OF B-objects IN FRAME Dialog-Frame /* Объекты? */
DO:
  run proc-view-objects in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run proc-b-print in this-procedure(t-month.year_, t-month.month_).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-uchet
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-uchet Dialog-Frame
ON CHOOSE OF B-uchet IN FRAME Dialog-Frame /* Уч. карт */
DO:
  if not avail t-month then return no-apply.
  run proc-uchet-card in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-dinamo
&Scoped-define SELF-NAME BR-dinamo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dinamo Dialog-Frame
ON LEFT-MOUSE-DBLCLICK OF BR-dinamo IN FRAME Dialog-Frame /* Обороты */
DO:
if not avail t-dinamo then return no-apply.

  run proc-c-dinamo in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dinamo Dialog-Frame
ON RETURN OF BR-dinamo IN FRAME Dialog-Frame /* Обороты */
DO:
  if not avail t-dinamo then return no-apply.
  run proc-c-dinamo in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-dinamo Dialog-Frame
ON VALUE-CHANGED OF BR-dinamo IN FRAME Dialog-Frame /* Обороты */
DO:
  if available t-dinamo then do:
    assign
    v-row = br-dinamo:focused-row in frame {&frame-name}.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-month
&Scoped-define SELF-NAME BR-month
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-month Dialog-Frame
ON LEFT-MOUSE-DBLCLICK OF BR-month IN FRAME Dialog-Frame
DO:
   if not avail t-month then return no-apply.
  run proc-uchet-card in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-month Dialog-Frame
ON RETURN OF BR-month IN FRAME Dialog-Frame
DO:
   if not avail t-month then return no-apply.
  run proc-uchet-card in this-procedure no-error.
  if error-status:error then return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-month Dialog-Frame
ON VALUE-CHANGED OF BR-month IN FRAME Dialog-Frame
DO:
  run proc-value-change in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RS-curr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-curr Dialog-Frame
ON VALUE-CHANGED OF RS-curr IN FRAME Dialog-Frame
DO:
  assign
  Rs-curr.
  run proc-value-change in this-procedure no-error.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-cost
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-cost Dialog-Frame
ON VALUE-CHANGED OF T-cost IN FRAME Dialog-Frame /* Учетные цены */
DO:
  assign
  T-cost.
  assign
  v-cost-view = T-cost AND v-enable-cost
  .
  run proc-value-change in this-procedure no-error.

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
{ gbl/app_help.i }


ON ROW-DISPLAY OF br-dinamo IN frame {&frame-name}
DO:
  IF AVAIL t-dinamo THEN DO:
    RUN set-row-color.
  END.
END.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }


  find first buf_goods no-lock where buf_goods.gds-code = p-gds-code.
  assign
    RS-curr :radio-buttons in frame Dialog-Frame = "Баз.вал.,base,{&abbr_rubli_firstshift},rubl"
  .
  assign
    RS-curr = "rubl":U
  .
  for each obj-list no-lock
  :
    define variable v-chk-act-host-code as integer   no-undo .
    { gbl/hostcode.i
      obj-list.obj-type
      obj-list.obj-code
      v-chk-act-host-code
    }
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_archive_cost':U
      {&cntxt-object}
      v-chk-act-host-code
      obj-list.obj-type
      obj-list.obj-code
      0
      0
      0
      false
      v-cost-obj
    }
    assign
    v-enable-cost = v-enable-cost AND v-cost-obj
    .
  end.
  run fill-tables in this-procedure .
  RUN Myenable.
  APPLY "VALUE-CHANGED" to browse br-month.
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE do-zuka Dialog-Frame
PROCEDURE do-zuka :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-year as integer no-undo.
define input parameter p-month as integer no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

DEFINE VARIABLE v-doc-ext-doc-type as character no-undo .
DEFINE VARIABLE jj as integer no-undo .
define buffer buf_t-dinamo for t-dinamo.
define buffer z_t-dinamo for t-dinamo.

do jj = 1 to num-entries {&doc-ext-doc-type-list}:
  assign
  v-doc-ext-doc-type = entry(jj, {&doc-ext-doc-type-list})
  .
  find first buf_t-dinamo no-lock where
            buf_t-dinamo.ym = p-year * 100 + p-month
        AND buf_t-dinamo.ext-doc-type = v-doc-ext-doc-type .
  find first z_t-dinamo where
             z_t-dinamo.ym = buf_t-dinamo.ym
         AND z_t-dinamo.ext-doc-type =  (buf_t-dinamo.ext-doc-type + {&comma-char} + "discount":U)
         no-error .
  if not avail z_t-dinamo then do:
    create z_t-dinamo.
    buffer-copy buf_t-dinamo except doc-type-full to z_t-dinamo
    assign
    z_t-dinamo.ext-doc-type = buf_t-dinamo.ext-doc-type + {&comma-char} + "discount":U
    z_t-dinamo.doc-type-full = fill({&space-char}, 5) +  "Скидка"
    z_t-dinamo.is-zuka = yes
    .
  end.
  assign
  z_t-dinamo.sale-sum-rubl =  if buf_t-dinamo.sale-sum-rubl = 0
                              then 0
                              else
                              (buf_t-dinamo.sale-sum-rubl - buf_t-dinamo.doc-sum-rubl) / buf_t-dinamo.sale-sum-rubl * 100
  z_t-dinamo.cost-sum-rubl = buf_t-dinamo.sale-sum-rubl - buf_t-dinamo.doc-sum-rubl
  z_t-dinamo.sale-sum-base = if buf_t-dinamo.sale-sum-base = 0
                            then 0
                            else
                            (buf_t-dinamo.sale-sum-base - buf_t-dinamo.doc-sum-base) / buf_t-dinamo.sale-sum-base * 100
  z_t-dinamo.cost-sum-base = buf_t-dinamo.sale-sum-base - buf_t-dinamo.doc-sum-base
  .
  find first z_t-dinamo where
             z_t-dinamo.ym = buf_t-dinamo.ym
         AND z_t-dinamo.ext-doc-type = (buf_t-dinamo.ext-doc-type + {&comma-char} + "benefit":U)
         no-error .
  if not avail z_t-dinamo then do:
    create z_t-dinamo.
    buffer-copy buf_t-dinamo except ext-doc-type to z_t-dinamo
    assign
    z_t-dinamo.ext-doc-type = buf_t-dinamo.ext-doc-type + {&comma-char} + "benefit":U
    z_t-dinamo.doc-type-full = fill({&space-char}, 5) +  "Доход"
    z_t-dinamo.is-zuka = yes
    .
  end.
  assign
  z_t-dinamo.sale-sum-rubl = if buf_t-dinamo.cost-sum-rubl = 0
                            then 0
                            else
                            (buf_t-dinamo.doc-sum-rubl - buf_t-dinamo.cost-sum-rubl) / buf_t-dinamo.cost-sum-rubl * 100
  z_t-dinamo.cost-sum-rubl = buf_t-dinamo.doc-sum-rubl - buf_t-dinamo.cost-sum-rubl
  z_t-dinamo.sale-sum-base = if buf_t-dinamo.cost-sum-rubl = 0
                            then 0
                            else
                            (buf_t-dinamo.doc-sum-base - buf_t-dinamo.cost-sum-base) / buf_t-dinamo.cost-sum-base * 100
  z_t-dinamo.cost-sum-base = buf_t-dinamo.doc-sum-base - buf_t-dinamo.cost-sum-base
  .
end. /*do jj*/

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
  DISPLAY T-cost RS-curr f-date-start F-unit-base
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help RECT-2 BR-dinamo RS-curr BR-month BR-stk B-uchet
         B-objects B-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-dinamo Dialog-Frame
PROCEDURE fill-dinamo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-year as integer no-undo .
define input parameter p-month as integer no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

if lookup( string( p-year * 100 + p-month ), v-MontYear_List ) > 0 then
  return.

v-MontYear_List = v-MontYear_List + (if v-MontYear_List = '' then '' else ',' )
                + string( p-year * 100 + p-month ).

DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-ext-doc-type as character no-undo .
DEFINE VARIABLE v-ext-doc-type-full as character no-undo .
DEFINE VARIABLE v-doc-type as character no-undo .
DEFINE VARIABLE v-doc-type-full as character no-undo .
DEFINE VARIABLE v-idoc-type as character no-undo .
DEFINE VARIABLE v-sign as character no-undo .
DEFINE VARIABLE v-sign-int as integer no-undo .
DEFINE VARIABLE v-sale-sum-type as character no-undo .
DEFINE VARIABLE v-cost-sum-type as character no-undo .
DEFINE VARIABLE v-doc-sum-type as character no-undo .
DEFINE VARIABLE v-last-day as integer no-undo .
DEFINE VARIABLE bfact-order like ub.ot-line.fact-order no-undo .
DEFINE VARIABLE afact-order like ub.ot-line.fact-order no-undo .

define buffer m_t-dinamo  for t-dinamo.
define buffer sale_ot-line for ub.ot-line  .
define buffer cost_ot-line for ub.ot-line  .
define buffer doc_ot-line for ub.ot-line.

assign
v-sign = string(0)
.
_ii:
do ii = 1 to num-entries({&TDEDT_List}):
  assign
  v-ext-doc-type = entry(ii, {&TDEDT_List})
  v-doc-type = get-doc-type(input ii, input-output v-ext-doc-type, input-output v-sign, output v-ext-doc-type-full, output v-doc-type-full, output v-idoc-type)
  .
  if v-idoc-type = "0" then next _ii.
  do jj = 1 to num-entries(v-ext-doc-type):

    find first t-dinamo where
              t-dinamo.ym = p-year * 100 + p-month
          AND t-dinamo.ext-doc-type = entry(jj, v-ext-doc-type)
          AND t-dinamo.idoc-type = integer(entry(jj, v-idoc-type))
          AND t-dinamo.sign_ = integer(entry(jj, v-sign)) no-error .

    if not available t-dinamo then do:
      create t-dinamo.
      assign
      t-dinamo.ym = p-year * 100 + p-month
      t-dinamo.year_ = p-year
      t-dinamo.month_ = p-month
      t-dinamo.ext-doc-type = entry(jj, v-ext-doc-type)
      t-dinamo.doc-type = entry(jj, v-doc-type)
      t-dinamo.ext-doc-type-full = entry(jj, v-ext-doc-type-full)
      t-dinamo.doc-type-full = t-dinamo.ext-doc-type-full
      t-dinamo.idoc-type = integer(entry(jj, v-idoc-type))
      t-dinamo.sign_ = integer(entry(jj, v-sign))
      .
      /*создадими заглавочную запись*/
      find first m_t-dinamo no-lock where
                 m_t-dinamo.ym = t-dinamo.ym
            AND m_t-dinamo.idoc-type = t-dinamo.idoc-type
            AND m_t-dinamo.ext-doc-type = "":U no-error .
      if not avail m_t-dinamo then do:
        create m_t-dinamo.
        assign
        m_t-dinamo.ym = p-year * 100 + p-month
        m_t-dinamo.year_ = p-year
        m_t-dinamo.month_ = p-month
        m_t-dinamo.ext-doc-type = "":U
        m_t-dinamo.doc-type = entry(jj, v-doc-type)
        m_t-dinamo.ext-doc-type-full = "":U
        m_t-dinamo.doc-type-full = v-doc-type-full
        m_t-dinamo.idoc-type = integer(entry(jj, v-idoc-type))
        m_t-dinamo.sign = 0
        .
      end.
    end.
  end. /*jj*/
end. /*ii*/
ASSIGN v-last-day = last-day( date( p-month, 1, p-year ) ).
run day-begin-fact-order in this-procedure (
                                             input date(p-month, 1, p-year)
                                             ,output bfact-order).
run factord-end-day  in this-procedure (
                                             input  date(p-month, v-last-day, p-year)
                                             ,output afact-order).

if buf_goods.gds-type = {&gds-goods} then do:
  assign
  v-sale-sum-type = {&arh-crsa}
  v-cost-sum-type = {&arh-cost}
  v-doc-sum-type = {&arh-sale}
  .
end.
else do:
  assign
  v-sale-sum-type = {&arh-crsa-service}
  v-cost-sum-type = {&arh-cost-service}
  v-doc-sum-type = {&arh-sale-service}
  .
end.
find first t-fo no-lock where
           t-fo.obj-type = p-obj-type
       AND t-fo.obj-code = p-obj-code no-error .
if avail t-fo and t-fo.fact-order <> 0 then do:
  /*это будет только последний период по объекту*/
  assign
  bfact-order = min(bfact-order, t-fo.fact-order)
  afact-order = min(afact-order, t-fo.fact-order)
  .
end.
_sale:
for each sale_ot-line no-lock where
         sale_ot-line.artic = buf_goods.artic
     AND sale_ot-line.prod-type = buf_goods.prod-type
     AND sale_ot-line.prod-code = buf_goods.prod-code
     AND sale_ot-line.obj-type = p-obj-type
     AND sale_ot-line.obj-code = p-obj-code
     AND sale_ot-line.sum-type = v-sale-sum-type
     and sale_ot-line.fact-order >= bfact-order
     and sale_ot-line.fact-order <= afact-order
     :
  find first cost_ot-line no-lock where
         cost_ot-line.artic = buf_goods.artic
     AND cost_ot-line.prod-type = buf_goods.prod-type
     AND cost_ot-line.prod-code = buf_goods.prod-code
     AND cost_ot-line.obj-type = p-obj-type
     AND cost_ot-line.obj-code = p-obj-code
     AND cost_ot-line.cat-id = {&root-cat-id}
     AND cost_ot-line.sum-type = v-cost-sum-type
     and cost_ot-line.doc-code = sale_ot-line.doc-code no-error .
  assign
  v-sign = string(if (sale_ot-line.fact-qnty >= 0) then 1 else -1)
  v-ext-doc-type = sale_ot-line.ext-doc-type
  ii = lookup(v-ext-doc-type, {&TDEDT_List})
  v-doc-type = get-doc-type(input ii,
                            input-output v-ext-doc-type,
                            input-output v-sign,
                            output v-ext-doc-type-full,
                            output v-doc-type-full,
                            output v-idoc-type)
  v-sign-int = integer(v-sign)
  .
  if v-idoc-type = "0" then next _sale.
  find first t-dinamo where
             t-dinamo.ym = p-year * 100 + p-month
         AND t-dinamo.ext-doc-type = sale_ot-line.ext-doc-type
         AND t-dinamo.sign_ = v-sign-int no-error .
  if avail t-dinamo then do:
    assign
    t-dinamo.fact-qnty = t-dinamo.fact-qnty + sale_ot-line.fact-qnty
    t-dinamo.sale-sum-rubl = t-dinamo.sale-sum-rubl + sale_ot-line.sum-rubl
    t-dinamo.sale-sum-base = t-dinamo.sale-sum-base +  sale_ot-line.sum-base
    t-dinamo.cost-sum-rubl = t-dinamo.cost-sum-rubl +  (if avail cost_ot-line then cost_ot-line.sum-rubl else 0)
    t-dinamo.cost-sum-base = t-dinamo.cost-sum-base +  (if avail cost_ot-line then cost_ot-line.sum-base else 0)
    .
  end.
end.

do jj = 1 to num-entries({&doc-ext-doc-type-list}):

  find first t-dinamo where
            t-dinamo.ym =p-year * 100 + p-month
        AND t-dinamo.ext-doc-type = entry(jj, {&doc-ext-doc-type-list}) .
  for each doc_ot-line no-lock where
          doc_ot-line.artic = buf_goods.artic
      AND doc_ot-line.prod-type = buf_goods.prod-type
      AND doc_ot-line.prod-code = buf_goods.prod-code
      AND doc_ot-line.obj-type = p-obj-type
      AND doc_ot-line.obj-code = p-obj-code
      AND doc_ot-line.sum-type = v-doc-sum-type
      and doc_ot-line.ext-doc-type = entry(jj, {&doc-ext-doc-type-list})
      and doc_ot-line.fact-order >= bfact-order
      and doc_ot-line.fact-order <= afact-order
      :
    assign
    t-dinamo.doc-sum-rubl = t-dinamo.doc-sum-rubl + doc_ot-line.sum-rubl
    t-dinamo.doc-sum-base = t-dinamo.doc-sum-base + doc_ot-line.sum-base
    .
  end.
end. /*do jj*/
run do-zuka in this-procedure (p-year, p-month, p-obj-type, p-obj-code).

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
DEFINE VARIABLE v-before-fact-date      like ub.stk-line.fact-date no-undo .
DEFINE VARIABLE v-before-ym             as integer no-undo .
DEFINE VARIABLE v-before-fact-order     like ub.stk-line.fact-order no-undo .
DEFINE VARIABLE v-before-fact-qnty      like ub.stk-line.fact-qnty no-undo .
DEFINE VARIABLE v-before-sale-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-before-sale-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-before-cost-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-before-cost-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-after-fact-qnty      like ub.stk-line.fact-qnty no-undo .
DEFINE VARIABLE v-after-sale-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-after-sale-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-after-cost-sum-rubl  like ub.stk-line.sum-rubl no-undo .
DEFINE VARIABLE v-after-cost-sum-base  like ub.stk-line.sum-base no-undo .
DEFINE VARIABLE v-date-start           as date no-undo init 01/01/1990.
DEFINE VARIABLE v-date-end             as date no-undo  init {&end-of-age}.
DEFINE VARIABLE v-ret                  as logical no-undo .
define variable p-comment              as character no-undo .
define variable v-can-print            as logical   no-undo .

define buffer sale_stk-line for ub.stk-line.
define buffer cost_stk-line for ub.stk-line.
define buffer before_t-stk-obj for t-stk-obj.
define buffer after_t-stk-obj for t-stk-obj.
define buffer skip_t-stk for t-stk .
run waitfram-show in this-procedure ( "Ждите" ).

for each t-month:
  delete t-month.
end.
for each t-stk:
  delete t-stk.
end.
for each t-stk-obj:
  delete t-stk-obj.
end.
for each t-dinamo:
  delete t-dinamo.
end.
for each t-fo:
  delete t-fo.
end.
assign
f-date-start = 01/01/1990
.

for each obj-list no-lock
:
  run rep/chk-ahz.p
    (input        obj-list.obj-type /* p-obj-type          */
    ,input        obj-list.obj-code /* p-obj-code          */
    ,input        false             /* p-verify-detail     */
    ,input        yes               /* p-verify-arh        */
    ,input        no                /* p-verify-ahsp       */
    ,input        no                /* p-verify-aht        */
    ,input        yes               /* p-check-act         */
    ,input        v-cntxt-db-num    /* p-check-act-db-num  */
    ,input        v-cntxt-userid    /* p-check-act-user-id */
    ,input-output v-date-start      /* p-date-start        */
    ,input-output v-date-end        /* p-date-end          */
    ,output       v-ret             /* p-archive-ok        */
    ,output       p-comment         /* p-comment           */
    ,output       v-can-print       /* p-can-print         */
    ) no-error .
  if error-status :error = yes then do:
    error-status :error = no.
  end.
  create t-fo.
  assign
  t-fo.obj-type = obj-list.obj-type
  t-fo.obj-code = obj-list.obj-code
  t-fo.cfact-date = v-date-start /*дата начала оборотов*/
  t-fo.ym = year(v-date-start) * 100 + month(v-date-start)
  v-cut-ym = maximum(v-cut-ym, t-fo.ym)
  f-date-start = maximum(f-date-start, v-date-start)
  .
end. /*for each obj-list*/
if buf_goods.gds-type = {&gds-goods} then do:
  for each obj-list no-lock,
    each sale_stk-line no-lock
      where sale_stk-line.obj-type = obj-list.obj-type
        AND sale_stk-line.obj-code = obj-list.obj-code
        AND sale_stk-line.artic = buf_goods.artic
        AND sale_stk-line.prod-type = buf_goods.prod-type
        AND sale_stk-line.prod-code = buf_goods.prod-code
        AND sale_stk-line.cat-id = {&root-cat-id}
        AND sale_stk-line.sum-type = {&arh-crsa}
  break
  by sale_stk-line.obj-type
  by sale_stk-line.obj-code
  by sale_stk-line.fact-order
  :
    if first-of(sale_stk-line.obj-code) then do:
      assign
      v-before-fact-date = ?
      v-before-ym  = 0
      v-before-fact-order = 0
      v-before-fact-qnty  = 0
      v-after-fact-qnty  = 0
      v-before-cost-sum-rubl = 0
      v-before-cost-sum-base = 0
      v-after-cost-sum-rubl = 0
      v-after-cost-sum-base = 0
      v-before-sale-sum-rubl = 0
      v-before-sale-sum-base = 0
      v-after-sale-sum-rubl = 0
      v-after-sale-sum-base = 0
      v-MontYear_List = ''
      .
    end.

    find first t-month where
              t-month.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
              no-error .
    if not avail t-month then do:
      /*найдем учетные цены для конца предыдущего периода!*/
      find first cost_stk-line no-lock where
                cost_stk-line.artic = buf_goods.artic
            AND cost_stk-line.prod-type = buf_goods.prod-type
            AND cost_stk-line.prod-code = buf_goods.prod-code
            AND cost_stk-line.obj-type = obj-list.obj-type
            AND cost_stk-line.obj-code = obj-list.obj-code
            AND cost_stk-line.sum-type = {&arh-cost}
            AND cost_stk-line.fact-order = v-before-fact-order no-error .
      /*может не найтись если это первый период тогда v-before-fact-order = 0*/
      if avail cost_stk-line then do:
        assign
          v-before-cost-sum-rubl = cost_stk-line.sum-rubl
          v-before-cost-sum-base = cost_stk-line.sum-base
          v-after-cost-sum-rubl = cost_stk-line.sum-rubl
          v-after-cost-sum-base = cost_stk-line.sum-base
        .
      end.
      /*запись о том что было движение в данном месяце*/
      create t-month.
      assign
        t-month.month_ = month(sale_stk-line.fact-date)
        t-month.year_ = year(sale_stk-line.fact-date)
        t-month.ym = t-month.year_ * 100 + t-month.month_
        t-month.obj-type = obj-list.obj-type
        t-month.obj-code = obj-list.obj-code
      .
      /*создадим запись о остатках на начало месяца*/
      create t-stk-obj.
      assign
        t-stk-obj.month_ = month(sale_stk-line.fact-date)
        t-stk-obj.year_ = year(sale_stk-line.fact-date)
        t-stk-obj.ym = t-stk-obj.year_ * 100 + t-stk-obj.month_
        t-stk-obj.b-a = 0 /*начало месяца*/
        t-stk-obj.b-a-full = "Начало месяца"
        t-stk-obj.fact-qnty  = v-before-fact-qnty
        t-stk-obj.sale-sum-rubl = v-before-sale-sum-rubl
        t-stk-obj.sale-sum-base  = v-before-sale-sum-base
        t-stk-obj.cost-sum-rubl = v-before-cost-sum-rubl
        t-stk-obj.cost-sum-base  = v-before-cost-sum-base
        t-stk-obj.obj-type = obj-list.obj-type
        t-stk-obj.obj-code = obj-list.obj-code
      .
      run fill-dinamo in this-procedure (t-stk-obj.year_, t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
      /*создадим запись об остатках на конец предудыщего периода при необходимости*/
      /*найдем - а предыдущий период вообще был?*/
      if v-before-ym > 0 then do: /*предыдущий период вообще был*/
        find first before_t-stk-obj
          where before_t-stk-obj.ym = v-before-ym
            AND before_t-stk-obj.b-a = 0
            AND before_t-stk-obj.obj-type = obj-list.obj-type
            AND before_t-stk-obj.obj-code = obj-list.obj-code
          no-error .
      end.
      else do: /*предыдущего периода нет*/
        if avail before_t-stk-obj then do:
          release before_t-stk-obj.
        end.
      end.
      if not avail before_t-stk-obj then do:
        /*это первый период жизни товара */
      end.
      else do:
        /*товар живет уже не первый период*/
        /*надо создать запись об остатках на конец предыдущий - цифры такие же как на начало текцщего периода*/
        find first after_t-stk-obj
          where after_t-stk-obj.ym = before_t-stk-obj.ym
            AND after_t-stk-obj.b-a = 1
            AND after_t-stk-obj.obj-type = obj-list.obj-type
            AND after_t-stk-obj.obj-code = obj-list.obj-code
          no-error .
        if not avail after_t-stk-obj then do:
          create after_t-stk-obj.
          assign
          after_t-stk-obj.ym = before_t-stk-obj.ym
          after_t-stk-obj.year_ = before_t-stk-obj.year_
          after_t-stk-obj.month_ = before_t-stk-obj.month_
          after_t-stk-obj.b-a = 1
          after_t-stk-obj.b-a-full = "Конец месяца"
          after_t-stk-obj.obj-type = obj-list.obj-type
          after_t-stk-obj.obj-code = obj-list.obj-code
          .
          run fill-dinamo in this-procedure (after_t-stk-obj.year_, after_t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
        end.
        assign
        after_t-stk-obj.fact-qnty     =  after_t-stk-obj.fact-qnty     +   v-after-fact-qnty
        after_t-stk-obj.sale-sum-rubl =  after_t-stk-obj.sale-sum-rubl +   v-after-sale-sum-rubl
        after_t-stk-obj.sale-sum-base =  after_t-stk-obj.sale-sum-base +   v-after-sale-sum-base
        after_t-stk-obj.cost-sum-rubl =  after_t-stk-obj.cost-sum-rubl +   v-after-cost-sum-rubl
        after_t-stk-obj.cost-sum-base =  after_t-stk-obj.cost-sum-base +   v-after-cost-sum-base
        .
      end.
    end.
    else do:
      /*непервое движение месяца*/
      if t-month.obj-type = obj-list.obj-type AND
        t-month.obj-code = obj-list.obj-code then do:
        /*промежуточная запись по тому же объекту - ничего нового не создаем  - за предыдущ период*/
      end.
      else do:
        /*запишем обрабатываемый объект в запись движения*/
        assign
          t-month.obj-type = obj-list.obj-type
          t-month.obj-code = obj-list.obj-code
        .
        /*запись о движении уже есть - значит на другом объекте движение уже было*/
        /*ищем запись о начале текущего периода*/
        find first t-stk-obj
          where t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
            AND t-stk-obj.b-a = 0
            AND t-stk-obj.obj-type = obj-list.obj-type
            AND t-stk-obj.obj-code = obj-list.obj-code
          no-error.
        if not available t-stk-obj then do:
          create t-stk-obj.
          assign
          t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
          t-stk-obj.year_ = year(sale_stk-line.fact-date)
          t-stk-obj.month_ = month(sale_stk-line.fact-date)
          t-stk-obj.b-a = 0
          t-stk-obj.b-a-full = "Начало месяца"
          t-stk-obj.obj-type = obj-list.obj-type
          t-stk-obj.obj-code = obj-list.obj-code
          .
          run fill-dinamo in this-procedure (t-stk-obj.year_, t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
        end.
        /*найдем учетные цены*/
        find first cost_stk-line no-lock where
                  cost_stk-line.artic = buf_goods.artic
              AND cost_stk-line.prod-type = buf_goods.prod-type
              AND cost_stk-line.prod-code = buf_goods.prod-code
              AND cost_stk-line.obj-type = obj-list.obj-type
              AND cost_stk-line.obj-code = obj-list.obj-code
              AND cost_stk-line.sum-type = {&arh-cost}
              AND cost_stk-line.fact-order = v-before-fact-order no-error .
        if avail cost_stk-line then do:
          assign
            v-before-cost-sum-rubl = cost_stk-line.sum-rubl
            v-before-cost-sum-base = cost_stk-line.sum-base
            v-after-cost-sum-rubl = cost_stk-line.sum-rubl
            v-after-cost-sum-base = cost_stk-line.sum-base
          .
        end.
        /*добавим суммы с обрабатываемого объекта*/
        assign
          t-stk-obj.fact-qnty  = t-stk-obj.fact-qnty + v-before-fact-qnty
          t-stk-obj.sale-sum-rubl = t-stk-obj.sale-sum-rubl + v-before-sale-sum-rubl
          t-stk-obj.sale-sum-base  = t-stk-obj.sale-sum-base + v-before-sale-sum-base
          t-stk-obj.cost-sum-rubl = t-stk-obj.cost-sum-rubl + v-before-cost-sum-rubl
          t-stk-obj.cost-sum-base  = t-stk-obj.cost-sum-base + v-before-cost-sum-base
        .
        /*теперь те же суммы пропишем в запись на конец предыдущего периода*/
        find first after_t-stk-obj
          where after_t-stk-obj.ym = v-before-ym
            AND after_t-stk-obj.b-a = 1
            AND after_t-stk-obj.obj-type = obj-list.obj-type
            AND after_t-stk-obj.obj-code = obj-list.obj-code
          no-error .
        if not avail after_t-stk-obj and v-before-ym <> 0 then do:
          create after_t-stk-obj.
          assign
            after_t-stk-obj.year_ = year(v-before-fact-date)
            after_t-stk-obj.month_ = month(v-before-fact-date)
            after_t-stk-obj.ym = v-before-ym
            after_t-stk-obj.b-a = 1
            after_t-stk-obj.b-a-full = "Конец месяца"
            after_t-stk-obj.obj-type = obj-list.obj-type
            after_t-stk-obj.obj-code = obj-list.obj-code
          .
          run fill-dinamo in this-procedure (after_t-stk-obj.year_, after_t-stk-obj.month_, obj-list.obj-type, obj-list.obj-code) .
        end.
        if avail after_t-stk-obj then do:
          assign
            after_t-stk-obj.fact-qnty  = after_t-stk-obj.fact-qnty + v-after-fact-qnty
            after_t-stk-obj.sale-sum-rubl = after_t-stk-obj.sale-sum-rubl + v-after-sale-sum-rubl
            after_t-stk-obj.sale-sum-base  = after_t-stk-obj.sale-sum-base + v-after-sale-sum-base
            after_t-stk-obj.cost-sum-rubl = after_t-stk-obj.cost-sum-rubl + v-after-cost-sum-rubl
            after_t-stk-obj.cost-sum-base  = after_t-stk-obj.cost-sum-base + v-after-cost-sum-base
          .
        end.
      end. /* NOT(f t-month.obj-type = obj-list.obj-type AND  t-month.obj-code = obj-list.obj-code */

    end. /*avail t-month*/
    assign
      v-before-fact-date      = sale_stk-line.fact-date
      v-before-ym             = year(sale_stk-line.fact-date) * 100 + month(sale_stk-line.fact-date)
      v-before-fact-order     = sale_stk-line.fact-order
      v-before-fact-qnty     = sale_stk-line.fact-qnty
      v-before-sale-sum-rubl = sale_stk-line.sum-rubl
      v-before-sale-sum-base = sale_stk-line.sum-base
      v-after-fact-qnty     =  sale_stk-line.fact-qnty
      v-after-sale-sum-rubl =  sale_stk-line.sum-rubl
      v-after-sale-sum-base =  sale_stk-line.sum-base
    .
    if last-of(sale_stk-line.obj-code) then do:
      /*надо создать запись для конца последнего периода*/
      /*найдем учетные цены*/
      find first cost_stk-line no-lock where
                cost_stk-line.artic = buf_goods.artic
            AND cost_stk-line.prod-type = buf_goods.prod-type
            AND cost_stk-line.prod-code = buf_goods.prod-code
            AND cost_stk-line.obj-type = obj-list.obj-type
            AND cost_stk-line.obj-code = obj-list.obj-code
            AND cost_stk-line.sum-type = {&arh-cost}
            AND cost_stk-line.fact-order = v-before-fact-order no-error .
      if avail cost_stk-line then do:
        assign
          v-after-cost-sum-rubl =  cost_stk-line.sum-rubl
          v-after-cost-sum-base =  cost_stk-line.sum-base
        .
      end.
      else do:
        assign
          v-after-cost-sum-rubl =  0
          v-after-cost-sum-base =  0
        .
      end.
      find first after_t-stk-obj
        where after_t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 + month(sale_stk-line.fact-date)
          AND after_t-stk-obj.b-a = 1
          AND after_t-stk-obj.obj-type = obj-list.obj-type
          AND after_t-stk-obj.obj-code = obj-list.obj-code
        no-error .
      if not available after_t-stk-obj then do:
        create after_t-stk-obj.
        assign
          after_t-stk-obj.ym = year(sale_stk-line.fact-date) * 100 + month(sale_stk-line.fact-date)
          after_t-stk-obj.year_ = year(sale_stk-line.fact-date)
          after_t-stk-obj.month_ =  month(sale_stk-line.fact-date)
          after_t-stk-obj.b-a = 1
          after_t-stk-obj.b-a-full = "Конец месяца"
          after_t-stk-obj.obj-type = obj-list.obj-type
          after_t-stk-obj.obj-code = obj-list.obj-code
        .
      end.
      assign
        after_t-stk-obj.fact-qnty = after_t-stk-obj.fact-qnty + v-after-fact-qnty
        after_t-stk-obj.sale-sum-rubl = after_t-stk-obj.sale-sum-rubl + v-after-sale-sum-rubl
        after_t-stk-obj.sale-sum-base  = after_t-stk-obj.sale-sum-base + v-after-sale-sum-base
        after_t-stk-obj.cost-sum-rubl = after_t-stk-obj.cost-sum-rubl + v-after-cost-sum-rubl
        after_t-stk-obj.cost-sum-base  = after_t-stk-obj.cost-sum-base + v-after-cost-sum-base
      .
      find first t-fo where
                  t-fo.obj-type = obj-list.obj-type
              AND t-fo.obj-code = obj-list.obj-code no-error .
      if not avail t-fo then do:
        create t-fo.
        assign
        t-fo.obj-type = obj-list.obj-type
        t-fo.obj-code = obj-list.obj-code
        .
      end.
      assign
      t-fo.fact-order = sale_stk-line.fact-order
      .
    end.
  end.
  /*это товар поэтому надо сложить все записи по остаткам в единую*/
    for each t-month no-lock,
      each obj-list no-lock,
      first t-stk-obj where
           t-stk-obj.obj-type = obj-list.obj-type
       AND t-stk-obj.obj-code = obj-list.obj-code
       AND (
            (t-stk-obj.ym = t-month.ym
        AND  t-stk-obj.b-a = 0 )
       OR   t-stk-obj.ym < t-month.ym
            )
           by t-stk-obj.ym descending
           by t-stk-obj.b-a descending
           :
    find first t-stk where
                t-stk.ym = t-month.ym
            AND t-stk.b-a = 0 no-error .
    if not avail t-stk then do:
      create t-stk.
      assign
      t-stk.ym = t-month.ym
      t-stk.year_ = t-month.year_
      t-stk.month_ = t-month.month_
      t-stk.b-a = 0
      t-stk.b-a-full = "Начало месяца"
      .
    end.
    assign
    t-stk.fact-qnty     = t-stk.fact-qnty     + t-stk-obj.fact-qnty
    t-stk.sale-sum-rubl = t-stk.sale-sum-rubl + t-stk-obj.sale-sum-rubl
    t-stk.sale-sum-base = t-stk.sale-sum-base + t-stk-obj.sale-sum-base
    t-stk.cost-sum-rubl = t-stk.cost-sum-rubl + t-stk-obj.cost-sum-rubl
    t-stk.cost-sum-base = t-stk.cost-sum-base + t-stk-obj.cost-sum-base
    .
  end.
  for each t-month no-lock,
      each obj-list no-lock,
      first t-stk-obj where
           t-stk-obj.obj-type = obj-list.obj-type
       AND t-stk-obj.obj-code = obj-list.obj-code
       AND
           (
           (t-stk-obj.ym = t-month.ym
       AND t-stk-obj.b-a = 1)
        OR t-stk-obj.ym < t-month.ym
           )
       by t-stk-obj.ym descending
       by t-stk-obj.b-a descending
           :
    find first t-stk where
                t-stk.ym = t-month.ym
            AND t-stk.b-a = 1 no-error .
    if not avail t-stk then do:
      create t-stk.
      assign
      t-stk.ym = t-month.ym
      t-stk.year_ = t-month.year_
      t-stk.month_ = t-month.month_
      t-stk.b-a = 1
      t-stk.b-a-full = "Конец месяца"
      .
    end.
    assign
    t-stk.fact-qnty     = t-stk.fact-qnty     + t-stk-obj.fact-qnty
    t-stk.sale-sum-rubl = t-stk.sale-sum-rubl + t-stk-obj.sale-sum-rubl
    t-stk.sale-sum-base = t-stk.sale-sum-base + t-stk-obj.sale-sum-base
    t-stk.cost-sum-rubl = t-stk.cost-sum-rubl + t-stk-obj.cost-sum-rubl
    t-stk.cost-sum-base = t-stk.cost-sum-base + t-stk-obj.cost-sum-base
    .
  end.
end. /*товар!*/
else do: /*услуга*/
  for each obj-list no-lock,
      each sale_stk-line no-lock where
          sale_stk-line.obj-type = obj-list.obj-type AND
          sale_stk-line.obj-code = obj-list.obj-code AND
          sale_stk-line.artic = buf_goods.artic AND
          sale_stk-line.prod-type = buf_goods.prod-type AND
          sale_stk-line.prod-code = buf_goods.prod-code AND
          sale_stk-line.cat-id = {&root-cat-id} AND
          sale_stk-line.sum-type begins  {&arh-cgdt}
  break
  by sale_stk-line.obj-type
  by sale_stk-line.obj-code
  by sale_stk-line.fact-order:
    find first t-month where
              t-month.ym = year(sale_stk-line.fact-date) * 100 +  month(sale_stk-line.fact-date)
              no-error .
    if not avail t-month then do:
      /*запись о том что было движение в данном месяце*/
      create t-month.
      assign
      t-month.month_ = month(sale_stk-line.fact-date)
      t-month.year_ = year(sale_stk-line.fact-date)
      t-month.ym = t-month.year_ * 100 + t-month.month_
      t-month.obj-type = obj-list.obj-type
      t-month.obj-code = obj-list.obj-code
      .
    end.
    if last-of (sale_stk-line.obj-code) then do:
      find first t-fo where
                  t-fo.obj-type = obj-list.obj-type
              AND t-fo.obj-code = obj-list.obj-code no-error .
      if not avail t-fo then do:
        create t-fo.
        assign
        t-fo.obj-type = obj-list.obj-type
        t-fo.obj-code = obj-list.obj-code
        .
      end.
      assign
      t-fo.fact-order = sale_stk-line.fact-order
      .
    end.
    run fill-dinamo in this-procedure (t-month.year_, t-month.month_, obj-list.obj-type, obj-list.obj-code) .
  end. /*for each sale_stk*/
end. /*gds-office*/
run waitfram-hide in this-procedure .
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
DISPLAY T-cost RS-curr
buf_goods.unit-base @ f-unit-base
f-date-start
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-Help BR-dinamo RS-curr BR-month BR-stk B-uchet B-objects
  T-cost when v-enable-cost
         B-print
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 {&OPEN-QUERY-BR-month}
 if avail t-month then do:
    {&OPEN-QUERY-BR-dinamo}
      {&OPEN-QUERY-BR-stk}
  end.
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
define input parameter p-year as integer no-undo.
define input parameter p-month as integer no-undo.

DEFINE VARIABLE v-fact-qnty-s as character no-undo .
DEFINE VARIABLE v-sale-sum-s as character no-undo .
DEFINE VARIABLE v-cost-sum-s as character no-undo .
DEFINE VARIABLE Line as character no-undo .
DEFINE VARIABLE date_string as character no-undo .
DEFINE VARIABLE v-ym as integer no-undo .
define buffer buf_t-dinamo for t-dinamo.
define buffer buf_t-stk for t-stk.


define frame Fdinamo
buf_t-dinamo.doc-type-full FORMAT "X(18)" column-label "":U
v-fact-qnty-s column-label "Кол-во" format {&f-sqnty}
v-sale-sum-s COLUMn-LABEL "Сумма продаж. цен" format {&f-ssum}
v-cost-sum-s COLUMn-LABEL "Сумма учетных цен" format {&f-ssum}
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER(PrnLibStream) AT 60 FORMAT ">>9" SKIP
Line format "X(80)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 80).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream unformatted
frame {&frame-name}:title format "x(90)" {&new-line}
(fill({&space-char}, 20) +
 "(":U +  (if RS-curr = "rubl":U then "{&abbr_rubli_firstshift}" else "Баз.вал.") + ")":U) skip
 str4
 SKIP(1) .
FORM HEADER
Line format "X(80)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME FDinamo  .
run waitfram-show in this-procedure("Ждите...").
assign
v-ym = p-year * 100 + p-month
.
for each buf_t-dinamo no-lock where
         buf_t-dinamo.ym = v-ym
break
by buf_t-dinamo.idoc-type
by buf_t-dinamo.ext-doc-type:
  display stream PrnLibStream
  buf_t-dinamo.doc-type-full
  (if buf_t-dinamo.ext-doc-type <> "":U and not buf_t-dinamo.is-zuka
  then string(buf_t-dinamo.fact-qnty, {&f-qnty})
  else "":U)      @  v-fact-qnty-s
  (if buf_t-dinamo.ext-doc-type <> "":U
  then string((if RS-curr = "rubl":U then buf_t-dinamo.sale-sum-rubl else buf_t-dinamo.sale-sum-base),
              (if buf_t-dinamo.is-zuka
              then {&f-pcnt}
              else {&f-sum})
              )
  else "":U) @ v-sale-sum-s
  (if v-cost-view then
  (if buf_t-dinamo.ext-doc-type <> "":U
  then string((if RS-curr = "rubl":U then buf_t-dinamo.cost-sum-rubl else buf_t-dinamo.cost-sum-base), {&f-sum})
  else "":U)
  else "":U)
  @  v-cost-sum-s
  WITH FRAME Fdinamo.
  if last-of(buf_t-dinamo.idoc-type) then do:
    DOWN STREAM PrnLibStream 2 with FRAME FDinamo .
  end.
  else do:
    DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
  end.
END.
UNDERLINE stream PrnLibStream
buf_t-dinamo.doc-type-full
v-fact-qnty-s
v-sale-sum-s
v-cost-sum-s
WITH FRAME Fdinamo.
DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
DISPLAY stream PrnLibStream
"Остатки"  @ buf_t-dinamo.doc-type-full
WITH FRAME Fdinamo.
DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
for each buf_t-stk no-lock where
         buf_t-stk.ym = v-ym:
  DISPLAY stream PrnLibStream
  buf_t-stk.b-a-full
    @ buf_t-dinamo.doc-type-full
  string(buf_t-stk.fact-qnty, {&f-qnty})
    @  v-fact-qnty-s
  string((if RS-curr = "rubl":U then buf_t-stk.sale-sum-rubl else buf_t-stk.sale-sum-base), {&f-sum})
    @ v-sale-sum-s
 (if v-cost-view then
  string((if RS-curr = "rubl":U then buf_t-stk.cost-sum-rubl else buf_t-stk.cost-sum-base), {&f-sum})
  else "":U)
    @  v-cost-sum-s
  WITH FRAME Fdinamo.
  DOWN STREAM PrnLibStream 1 with FRAME FDinamo .
end.

HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME Fdinamo.
output STREAM PrnLibStream CLOSE.

run waitfram-hide in this-procedure.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-c-dinamo Dialog-Frame
PROCEDURE proc-c-dinamo :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-curr as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable next-prev as logical no-undo .
if t-dinamo.ext-doc-type = "":U then return error.
if num-entries(t-dinamo.doc-type-full) > 1 then return error.
br-handle = br-month:handle in frame {&frame-name}.
v-curr = RS-curr.
assign
v-doc-rec = ?
next-prev = yes
.

       run rep/c-dinamo.w
                      (
                       input parparentproc
                      ,input t-dinamo.ext-doc-type
                      ,input t-dinamo.sign_
                      ,input p-gds-code
                      ,input v-cost-view
                      ,input-output v-curr
                      ,input-output v-doc-rec
                      ,input-output br-handle
                      ,input-output next-prev

                                    ) no-error.
    if error-status:error then return error.
    rs-curr = v-curr.
    display RS-curr
    with frame {&frame-name} .
    apply "VALUE-CHANGED" to Rs-curr.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-uchet-card Dialog-Frame
PROCEDURE proc-uchet-card :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE v-curr as character no-undo .
define variable v-doc-rec as recid no-undo .
define variable next-prev as logical no-undo .
    assign
    next-prev = yes.
    br-handle = br-month:handle in frame {&frame-name}.
    v-curr = RS-curr.
    DO WHILE next-prev <> ?:
        if NOT available t-month then do:
                message "Неправильно выбран месяц." view-as alert-box ERROR.
                return error.
        end.
        v-doc-rec = recid (t-month).
        .
       run rep/c-dinamo.w
                      (
                       input parparentproc
                      ,input {&all}
                      ,input 0
                      ,input p-gds-code
                      ,input v-cost-view
                      ,input-output v-curr
                      ,input-output v-doc-rec
                      ,input-output br-handle
                      ,input-output next-prev
                                    ) no-error
        .
    END .
    if br-handle = ? then
    reposition br-month to recid v-doc-rec no-error.
    rs-curr = v-curr.
    display RS-curr
    with frame {&frame-name} .
    apply "VALUE-CHANGED" to Rs-curr.
    apply "entry" to br-month in frame {&frame-name}.
    apply "value-changed" to br-month in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-value-change Dialog-Frame
PROCEDURE proc-value-change :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-month-name as character no-undo.
if available t-month then do:
    assign
    v-month-name = string(t-month.month_).
    run gbl/monthnam.p (input t-month.month_, output v-month-name) no-error.
end.
assign
frame {&frame-name}:title = {&frame-title}.
if available t-month and t-month.ym >= v-cut-ym then do:
    OPEN QUERY br-dinamo FOR EACH t-dinamo no-lock where t-dinamo.ym = t-month.ym.
    OPEN QUERY br-stk FOR EACH t-stk no-lock where t-stk.ym = t-month.ym .
end.
else do:

  if not can-find(first t-month no-lock where
                        t-month.ym > v-cut-ym) and
         can-find(first t-month no-lock where
                        t-month.ym <= v-cut-ym) then do:
    OPEN QUERY br-dinamo FOR EACH t-dinamo no-lock where false.
    OPEN QUERY br-stk FOR EACH t-stk no-lock where
                               t-stk.ym = t-month.ym
                           AND t-stk.b-a = 1 .
  end.
  else do:
    OPEN QUERY br-dinamo FOR EACH t-dinamo no-lock where false.
    OPEN QUERY br-stk FOR EACH t-stk no-lock where false .
  end.
end.
REPOSITION br-dinamo to row v-row no-error.
br-dinamo :SET-REPOSITIONED-ROW(5, "CONDITIONAL").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR iFGColor AS INTEGER NO-UNDO.
  DEF VAR iBGColor AS INTEGER NO-UNDO.

  IF t-dinamo.ext-doc-type = "":U THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = DARK_GREEN_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.

    ASSIGN
      t-dinamo.doc-type-full:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      t-dinamo.doc-type-full:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor
    .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME