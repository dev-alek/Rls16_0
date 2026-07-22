&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Строки чеков по чекам с ценой, отличной от прайс на момент чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/15/04
Author: Bakhtadze Natalya
Creation date: 06/15/04

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
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Строки чеков по чекам с ценой, отличной от прайс на момент чека " .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/operlist.i  }
{ gbl/waitfram.i }
{ trg/factord.i }
define variable parparentproc as widget-handle no-undo .
{ gbl/getcntxt.i def }
define variable State-source as Widget-Handle.

DEFINE SHARED VARIABLE cas-shft as logical no-undo init no.
define variable cas-num as integer no-undo.

define variable found as logical no-undo.
&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-checks ByOperations
&Scoped-Define DISPLAYED-OBJECTS ByOperations

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE ByOperations AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Продажи", 1,
"Возвраты", -1,
"Продажи + возвраты", 0
     SIZE 21.38 BY 3 NO-UNDO.

DEFINE RECTANGLE RECT-checks
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 36.5 BY 5.92.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ByOperations AT ROW 8.54 COL 2.88 NO-LABEL
     "Просмотреть операции ( чеки ):" VIEW-AS TEXT
          SIZE 30.25 BY .92 AT ROW 7.17 COL 4
          FGCOLOR 4
     RECT-checks AT ROW 6.5 COL 1.63
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 56.88 BY 11.83.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 11.88
         WIDTH              = 56.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME ByOperations
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ByOperations F-Frame-Win
ON VALUE-CHANGED OF ByOperations IN FRAME F-Main
DO:
    assign ByOperations .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
parparentproc = my-handle.
{ gbl/getcntxt.i get }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

{ rep/e-nobenq.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY ByOperations
      WITH FRAME F-Main.
  ENABLE RECT-checks ByOperations
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Report F-Frame-Win
PROCEDURE My-Report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE VARIABLE v-b-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-grp-name like ub.goods.grp-name no-undo .
DEFINE VARIABLE v-node-name like ub.gds-prt.f-name no-undo .
DEFINE VARIABLE v-root-name like ub.gds-prt.node-name no-undo .
DEFINE VARIABLE v-artic like ub.goods.artic no-undo .
DEFINE VARIABLE v-prod-type like ub.goods.prod-type no-undo .
DEFINE VARIABLE v-prod-code as character no-undo .
DEFINE VARIABLE v-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-ini-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-start-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-end-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-doc-time like ub.chk-doc.chk-time no-undo .
DEFINE VARIABLE v-price-sale like ub.price-list.price-sale no-undo .
DEFINE VARIABLE v-road-tax like ub.price-list.road-tax no-undo .
DEFINE VARIABLE v-excise like ub.price-list.excise no-undo .
DEFINE VARIABLE v-doc-num like ub.price-list.doc-num no-undo .
DEFINE VARIABLE v-prod-name like ub.clients.obj-name no-undo .
DEFINE VARIABLE v-chk-sum as decimal no-undo .
DEFINE VARIABLE v-price-list-sum as decimal no-undo .
DEFINE VARIABLE v-chk-sum-r as decimal no-undo .
DEFINE VARIABLE v-price-list-sum-r as decimal no-undo .
DEFINE VARIABLE v-chk-sum-v as decimal no-undo .
DEFINE VARIABLE v-price-list-sum-v as decimal no-undo .
define variable g#report-num as integer no-undo .

DEFINE VARIABLE v-add as logical no-undo.
DEFINE VARIABLE found as logical init yes no-undo .
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE NotInc as logical no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer root_gds-prt for ub.gds-prt.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_price-list for ub.price-list.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.

run no-benq(output found).
if NOT found then do:
  run waitfram-hide in this-procedure.
  message {&no-benefits} view-as alert-box.
  return.
end.
do
on error undo, return error
:
  /*найдем fact-order 1990 года*/
  assign
  Sheetf.ColFOrmat = '5=@;15=@;16=dd/mm/yyyy'
  .
  run day-begin-fact-order in this-procedure(
                                              input  01/01/1990
                                             ,output v-ini-fact-order
                                            ) .

  run waitfram-show in this-procedure ("Ждите...").
  assign
  sheetf.Excel-Column-Lable =
  "ГРУППА ТОВАРОВ"  + {&comma-char} +
  "ГЛАВНЫЙ КОД ТОВАРА"  + {&comma-char} +
  "БАР-КОД ПРИЗНАКА"  + {&comma-char} +
  "ШКАЛА/ПРИЗНАК"  + {&comma-char} +
  "АРТИКУЛ"  + {&comma-char} +
  "ПР-ЛЬ"  + {&comma-char} +
  "НАЗВАНИЕ ПРОИЗВОДИТЕЛЯ"  + {&comma-char} +
  "КОЛИЧЕСТВО"  + {&comma-char} +
  "ЦЕНА В ЧЕКЕ"  + {&comma-char} +
  "ЦЕНА ПО ПРАЙС-ЛИСТУ"  + {&comma-char} +
  "СУММА ПО ЧЕКУ" + {&comma-char} +
  "СУММА С ЦЕНОЙ ПРАЙС-ЛИСТА" + {&comma-char} +
  "РАЗНИЦА (СУММА ПО ЧЕКУ - СУММА С ЦЕНОЙ ПРАЙС-ЛИСТА))" + {&comma-char} +
  "КОД КАССИРА"  + {&comma-char} +
  "НОМЕР ЧЕКА"  + {&comma-char} +
  "ДАТА ЧЕКА"
  sheetf.sizes =
  "100"  + {&comma-char} +
  "16"  + {&comma-char} +
  "15"  + {&comma-char} +
  "100"  + {&comma-char} +
  "16"  + {&comma-char} +
  "12"  + {&comma-char} +
  "40"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "25"  + {&comma-char} +
  "10"
  str1 = string(( if NotInc
                  then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )"
                  else " " ), "X(40)")
  str3 = " "
  .
  run rep/extitle.p (1) .

  FOR EACH obj-list No-LOCK:
    assign
    v-chk-sum           = 0
    v-price-list-sum    = 0
    v-chk-sum-r         = 0
    v-price-list-sum-r  = 0
    v-chk-sum-v         = 0
    v-price-list-sum-v  = 0
    .



    FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = obj-list.obj-type AND
                buf_clients.obj-code = obj-list.obj-code No-ERROR.
    {&PutExcel}
    (IF AVAIL buf_clients
      then buf_clients.obj-name
      else ("Магазин N " + string(obj-list.obj-code))
    )
    SKIP.
  _chk-gds:
    FOR EACH buf_chk-doc No-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              buf_chk-doc.out-code <> ? AND
              buf_chk-doc.chk-date >= X-date-start AND
              buf_chk-doc.chk-date <= X-date-end:
      if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
      if ByOperations = - 1 and buf_chk-doc.netto >= 0 then NEXT.
      if ByOperations = 1 and buf_chk-doc.netto < 0 then NEXT.

      /*найдем fact-order начала дня чека*/
      run day-begin-fact-order in this-procedure(
                                                  input  buf_chk-doc.chk-date
                                                  ,output v-start-fact-order
                                                ) .
      /*найдем fact-order начала дня следующего за днем чека*/
      run day-begin-fact-order in this-procedure(
                                                  input  (buf_chk-doc.chk-date + 1)
                                                  ,output v-end-fact-order
                                                ) .

      FOR EACH buf_chk-gds No-LOCK WHERE
              buf_chk-gds.doc-code = buf_chk-doc.doc-code,
          FIRST buf_bar-code No-LOCK WHERE
                buf_bar-code.b-code = buf_chk-gds.b-code:
        ACCUMULATE buf_chk-gds.doc-code (COUNT).
        assign
        v-b-code = ?
        .
        { gbl/gdsbcode.i buf_bar-code.gds-code  ? v-b-code no-error }
        /*найдем последний прайс-лист на данный товар*/
        /*сначала просмотрим все переоценки за день, когда выбит чек*/

        assign
        v-doc-time = 0
        v-fact-order = v-start-fact-order
        v-add = yes
        v-found = no
        .
        FOR EACH buf_price-list No-LOCK WHERE
                  buf_price-list.obj-type = obj-list.obj-type AND
                  buf_price-list.obj-code = obj-list.obj-code AND
                  buf_price-list.b-code = v-b-code AND
                  buf_price-list.price-type = "":U AND
                  buf_price-list.fact-order >= v-start-fact-order AND
                  buf_price-list.fact-order < v-end-fact-order use-index fact-close,
            first buf_price-doc No-LOCK where
                  buf_price-doc.doc-num = buf_price-list.doc-num :
          if v-doc-time < buf_chk-doc.chk-time and
             buf_price-doc.fact-time > buf_chk-doc.chk-time and
             v-doc-time <> 0 then do:
            assign
            v-fact-order = buf_price-list.fact-order
            v-add = no
            .
            LEAVE.
          end.
          assign
          v-doc-time = buf_price-doc.fact-time
          v-fact-order = buf_price-list.fact-order
          v-found = yes
          .
        END.
        /*если переоценка была в день чека - fact-order уже нашли и (price-list avail или v-found*/
        if NOT (FOUND and v-doc-time < buf_chk-doc.chk-time) and
            not available buf_price-list then do:
          /*переоценка была раньше чем день чека*/
          /*найдем последний прайс-лист на данный товар*/
          FIND LAST buf_price-list No-LOCK WHERE
                    buf_price-list.obj-type = obj-list.obj-type AND
                    buf_price-list.obj-code = obj-list.obj-code AND
                    buf_price-list.b-code = v-b-code AND
                    buf_price-list.fact-order < v-start-fact-order AND
                    buf_price-list.price-type = "":U use-index fact-close no-error .
          if available buf_price-list then do:
            assign
            v-fact-order = buf_price-list.fact-order
            .
          end.
          else do:
            /*ставим 1990 год*/
            assign
            v-fact-order = v-ini-fact-order
            .
          end.
        end.
        assign
        v-price-sale = ?
        v-fact-order = v-fact-order + (if v-add = no then 0 else 0.0000000001)
        .
        { gbl/bcodeprc.i
          obj-list.obj-type
          obj-list.obj-code
          buf_chk-gds.b-code
          v-b-code
          v-fact-order
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          no-error
        }
        if v-price-sale = ? or
          v-price-sale <> buf_chk-gds.price-base then do:

          find first ub.gds-prt No-LOCK WHERE
                    ub.gds-prt.node-code = ub.bar-code.node-code no-error .
          if avail ub.gds-prt then do:
            assign
            v-node-name =  ub.gds-prt.f-name
            .
          end.
          else do:
            assign
            v-node-name ="?":U
            .
          end.

          FIND FIRST buf_goods no-lock where
                    buf_goods.gds-code = bar-code.gds-code No-error.
          if avail buf_goods then do:
            assign
            v-grp-name = buf_goods.grp-name
            v-artic = buf_goods.artic
            v-prod-type = buf_goods.prod-type
            v-prod-code = string(buf_goods.prod-code)
            .
            find first root_gds-prt no-lock where
                      root_gds-prt.upper-code = buf_goods.prt-root no-error .
            if available root_gds-prt then do:
              assign
              v-root-name = root_gds-prt.node-name
              .
            end.
            else do:
              assign
              v-root-name = "?":U
              .
            end.
            find first buf_clients no-lock where
                       buf_clients.obj-type = buf_goods.prod-type AND
                       buf_clients.obj-code = buf_goods.prod-code no-error .
            if avail buf_clients then do:
              assign
              v-prod-name = string(buf_clients.obj-name, "X(40)")
              .
            end.
            else do:
              assign
              v-prod-name = "?":U
              .
            end.
          end.
          else do:
            assign
            v-grp-name = "?":U
            v-root-name = "?":U
            .
          end.
          {&PUTExcel}
          v-grp-name  {&tabulation}
          v-b-code {&tabulation}
          buf_chk-gds.b-code {&tabulation}
          (v-root-name + (if v-node-name = "":U then "":U else {&slash-char}) + v-node-name) {&tabulation}
          v-artic {&tabulation}
          v-prod-type + string(v-prod-code) {&tabulation}
          v-prod-name {&tabulation}
          buf_chk-gds.doc-qnty {&tabulation}
          buf_chk-gds.price-base {&tabulation}
          v-price-sale {&tabulation}
          buf_chk-gds.price-base * buf_chk-gds.doc-qnty {&tabulation}
          v-price-sale * buf_chk-gds.doc-qnty {&tabulation}
          (buf_chk-gds.price-base *  abs(buf_chk-gds.doc-qnty)  - v-price-sale *  abs(buf_chk-gds.doc-qnty))   {&tabulation}
          buf_chk-doc.cashier {&tabulation}
          buf_chk-doc.doc-code  {&tabulation}
          /*{&space-char} + string(buf_chk-doc.chk-date, "99/99/9999") + {&space-char}*/
          string(buf_chk-doc.chk-date, "99/99/9999")
          SKIP
          .
          assign
          v-chk-sum = v-chk-sum + buf_chk-gds.price-base * (buf_chk-gds.doc-qnty )
          v-price-list-sum = v-price-list-sum +
                             (if v-price-sale <> ?
                              then v-price-sale * ( buf_chk-gds.doc-qnty )
                              else 0)
          .
          if buf_chk-doc.netto >= 0 then do:
            assign
            v-chk-sum-r = v-chk-sum-r + buf_chk-gds.price-base * ( buf_chk-gds.doc-qnty )
            v-price-list-sum-r = v-price-list-sum-r +
                              (if v-price-sale <> ?
                                then v-price-sale * ( buf_chk-gds.doc-qnty )
                                else 0)
            .
          end.
          else do:
            assign
            v-chk-sum-v = v-chk-sum-v + buf_chk-gds.price-base * ( buf_chk-gds.doc-qnty )
            v-price-list-sum-v = v-price-list-sum-v +
                              (if v-price-sale <> ?
                                then v-price-sale * ( buf_chk-gds.doc-qnty )
                                else 0)
            .
          end.
        end.
        IF (ACCUM COUNT buf_chk-gds.doc-code) MODULO 50 = 0 then
        run waitfram-show in this-procedure ("Ждите..." + "Объект " + string(obj-list.obj-code) + " Обработано " +
                      string(ACCUM COUNT buf_chk-gds.doc-code) + " строк чеков").
      END. /*FOR EACH buf_chk-gds*/
    END.  /*FOR EACH buf_chk-doc*/
    if ByOperations = 0 or
     ByOperations = 1 then do:
      {&PUTExcel}
      "ИТОГО по чекам расхода"
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      v-chk-sum-r {&tabulation}
      v-price-list-sum-r {&tabulation}
      v-chk-sum-r - v-price-list-sum-r {&tabulation}
      {&tabulation}
      {&tabulation}
      SKIP
      .
    end.
    if ByOperations = 0 or
     ByOperations = 2 then do:
      {&PUTExcel}
      "ИТОГО по чекам возврата"
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      v-chk-sum-v {&tabulation}
      v-price-list-sum-v {&tabulation}
      (- (v-chk-sum-v - v-price-list-sum-v)) {&tabulation}
      {&tabulation}
      {&tabulation}
      SKIP
      .
    end.
    if ByOperations = 0 then do:
      {&PUTExcel}
      "ИТОГО по чекам расхода и возврата"
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      {&tabulation}
      v-chk-sum {&tabulation}
      v-price-list-sum {&tabulation}
      v-chk-sum - v-price-list-sum {&tabulation}
      {&tabulation}
      {&tabulation}
      SKIP
      .
    end.




  END. /*FOR EACH OBJ-LIST*/

  {&CloseExcel}

end.
run waitfram-hide in this-procedure.
run get-report-num  in parParentProc(output  g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 assign
 FRAME {&frame-name} ByOperations
 .

Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
/*ReportNAme = "Статистика по кассирам".*/
ReportHeader =
               "Операции : " + (if ByOperations = 0
                                then "Продажи + возвраты"
                                else if ByOperations = 1
                                     then "Продажи"
                                     else "Возвраты")
               .


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
