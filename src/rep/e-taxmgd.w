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

Отчет о налогах по документам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

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
define variable vss-description as character no-undo init "Отчет о налогах по документам" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ str/out-vatp.i def}
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ str/lib-calc.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
define variable parparentproc as widget-handle no-undo .
{ str/getctxtp.i def }


DEFINE SHARED VAR objects as integer no-undo.
DEFINE SHARED VAR FRAME-TITLE as char no-undo.

def temp-table sj-goods no-undo
field b-code like ub.bar-code.b-code format "9999999999999"
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field name   like ub.goods.gds-name format "x(30)"
field unit like ub.goods.unit-base
field qnty              as   decimal
field obj-price    like ub.price-list.price-sale
field discnt          as   decimal
field brutto-sum   as   decimal
field discnt-sum  as   decimal
field netto-sum    as   decimal
field uchet-sum   as decimal /*учетные цены*/
field uchet-with-vat-sum   as decimal /*учетные цены*/
field n-u-sum             as   decimal
field u-pcnt          as decimal /*% торговой наценки*/
field is-out        as  logical
field VAT-pc       like ub.doc-line.VAT-pc
field SLT-pc       like ub.doc-line.SLT-pc
field VAT-r-b    as decimal /*сумма НДС*/
field SLT-r-b   as decimal /*сумма налога с продаж */
INDEX p1 IS PRIMARY   b-code SLT-pc VAT-pc
INDEX p2                        is-out DESCENDING
                                        b-code ASCENDING
INDEX p3 artic prod-type prod-code SLT-pc VAT-pc
.
DEFINE TEMP-TABLE d-slt-vat no-undo
FIELD SLT-pc like ub.doc-line.SLT-pc
FIELD SLT-r-b like ub.inkas.netto /*сумма налога с продаж*/
FIELD SLT-r-b-brutto like ub.inkas.netto /*сумма товаров с таким налогом  с продаж*/
FIELD VAT-pc like ub.doc-line.VAT-pc
FIELD VAT-r-b like ub.inkas.netto
FIELD uchet-sum as decimal
FIELD uchet-with-vat-sum as decimal
FIELD n-u-sum             as   decimal
INDEX p1 IS PRIMARY SLT-pc VAT-pc ASCENDING .

define variable     NotInc          as  log     no-undo.

define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.

define variable     choice               as      logical     no-undo.
define variable     DatePrinted      as      logical     no-undo.
define variable     FrameType      as      char        no-undo.
define variable     method            as    char no-undo.
/*yes - выборочно по товарам*/
define variable     good-choice as logical init no.
/*разделять простые и порожденные партии*/
define variable negparts as logical NO-UNDO.
/*вспомогательные*/
define variable slt-calc as dec.
define variable vat-cost as dec.
def buffer buf-bar for ub.bar-code.
DEFINE SHARED BUFFER t-doc FOR ub.trn-doc.
{ cmp/doc-list.i  doc-list def "shared" }
define shared buffer temp-trn-doc for doc-list.
define shared query br-docs for t-doc except ,temp-trn-doc scrolling.
def buffer ras-doc for ub.trn-doc.
define variable is-out as integer init 1.
define variable doc-num like ub.trn-doc.doc-code no-undo.
define variable jj as integer no-undo.
define variable jj-tot as integer no-undo init 0.
define variable cur-quant like ub.gds-dtl.doc-qnty no-undo.
define variable offc as logical no-undo.
define variable for-netto-without-slt as decimal no-undo.
define variable vat-pc-val-qnty as integer no-undo.
define var loc#retail as logical no-undo.
DEFINE VAR v-host-code like ub.sysconf.host-code no-undo.
define variable cas-shft as logical no-undo.
define variable cas-num as integer no-undo.
define variable found as logical no-undo.
&global-define  no-benefits    "Не было никаких документов на выбранных объектах ~
в течение заданного Вами периода времени."
define variable raz as integer no-undo.
define variable trid as recid no-undo.
DEFINE var r-bar-code like ub.bar-code.b-code no-undo.
DEFINE VARIABLE varsum-dsc-r-b-acc as decimal no-undo .
DEFINE VARIABLE varvat-r-b-acc     as decimal no-undo .
DEFINE VARIABLE var-qnty              as decimal no-undo .
DEFINE VARIABLE varvat-r-b-doc     as decimal no-undo .
DEFINE VARIABLE varslt-r-b-doc     as decimal no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-7 RS-Method T-neg
&Scoped-Define DISPLAYED-OBJECTS RS-Method T-neg

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-Method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Cо шкалами ", "B-CODE":U,
"Без шкал  ", "ARTIC":U,
"Без товаров", "TOTALS":U
     SIZE 22.63 BY 3.13 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 4.83.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 44.5 BY 4.63.

DEFINE VARIABLE T-neg AS LOGICAL INITIAL no
     LABEL "Отрицательную наценку считать = 0"
     VIEW-AS TOGGLE-BOX
     SIZE 37.75 BY 1.04 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-Method AT ROW 2.58 COL 7 NO-LABEL
     T-neg AT ROW 7.75 COL 5.13
     "Детализация" VIEW-AS TEXT
          SIZE 33.13 BY .88 AT ROW 1.42 COL 3.25
          FGCOLOR 4
     RECT-6 AT ROW 1.25 COL 2.25
     RECT-7 AT ROW 6.5 COL 2.63
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 47.63 BY 15.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 15
         WIDTH              = 47.63.
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
   NOT-VISIBLE                                                          */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
parparentproc = my-handle.
{ str/getctxtp.i get }
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
  DISPLAY RS-Method T-neg
      WITH FRAME F-Main.
  ENABLE RECT-6 RECT-7 RS-Method T-neg
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-report F-Frame-Win
PROCEDURE My-report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
run My-var.

assign
date_string = cur-time-print()
Line = fill( "-", 175 )
jj = 0
jj-tot = 0.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .

RUN PrintProc.

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
Assign
frame {&frame-name} RS-Method
frame {&frame-name} T-neg
good-choice = (IF X-selectGood = {&g-all} then no else yes)
method = RS-method
negparts = no
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
ReportName = "РАСЧЕТ НАЛОГОВ ПО ТОВАРАМ СПИСКА ДОКУМЕНТОВ".
ReportHeader = "Детализация: " +
                           radio-label(string(RS-method), RS-method:radio-buttons) + {&New-line} +
                           (if T-neg then t-neg:label else "").


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc F-Frame-Win
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable i as integer no-undo .

define variable sym1 as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.

define variable Line                as      char    no-undo.
define variable cash_string     as      char    no-undo.
define variable sale_string     as      char    no-undo.
define variable date_string     as      char    no-undo.

define variable namebuf1     as      char    no-undo.
define variable namebuf2     as      char    no-undo.
define variable prodbuf1     as      char    no-undo.
define variable prodbuf2     as      char    no-undo.
define variable tdoc-code     as      char    no-undo.

define variable s-price as decimal no-undo .
define variable cur-discnt as decimal no-undo .

def buffer b-tr-doc  for ub.trn-doc .
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Вал. продаж - " + caps( base-type ) + " )" )
  .
end.
else do:
  assign
  v-header-base-curr = string( "( Вал. продаж - {&abbr_rubli_allshift} )" )
  .
end.

DEFINE FRAME SJ-Base
sym1 column-label ":!:"                                                               format "X(1)" space(0)
jj-tot column-label "  N  "                                                           format ">>>>>9" space(0)
sj-goods.b-code column-label "Код ! "                                                 format ">>>>>>>>>9"
sj-goods.artic column-label "Артикул   ! "                                            format "x(16)"
sj-goods.name column-label "Наименование  ! "                                         format "x(25)"
ub.clients.obj-name column-label "(Производитель)"                                       format "x(15)"
sj-goods.unit column-label "Ед.!изм"                                                  format "X(3)"
sj-goods.qnty column-label "Количество ! "                                            format "->>>>>9.<<<"
sj-goods.uchet-sum column-label   "Сумма !учет.без НДС!(вал. продаж)"                 format "->>>>>>>>9.99" space(0)
sj-goods.netto-sum column-label  "Сумма !продажная!(вал. продаж)"                     format "->>>>>>>>9.99" space(0)
sj-goods.SLT-r-b column-label "В т.ч. !налог !с продаж!(вал. продаж)"                 format "->>>>>>>>9.99" space(0)
sj-goods.SLT-pc column-label " НП%"                                                   format ">9" space(0)
for-netto-without-slt column-label "Сумма !продажная!без НП!(вал.продаж)"             format "->>>>>>>>9.99" space(0)
sj-goods.n-u-sum column-label   "Сумма !торг. нацен.!(вал. продаж)"                   format "->>>>>>>>9.99" space(0)
sj-goods.u-pcnt column-label "Торг.!нацен. %"                                         format "->>9.99%" space(0)
sj-goods.VAT-pc column-label " НДС%"                                                  format ">9" space(0)
sj-goods.VAT-r-b column-label   "Сумма НДС!(вал. продаж)"                             format "->>>>>>>>9.99" space(0)
sym10 column-label ":!:" format "X(1)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr  format "X(20)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER ( PrnLibStream)
AT 125 FORMAT ">>>>9" SKIP
Line format "X(188)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.
    Line = fill("-", 250).
if raz > 1 and trid = ? then do:
  message "Выборка документов для отчета изменилась"
          "Отчет сделать невозможно"
  view-as alert-box ERROR.
  return error.
end.
run waitfram-show in this-procedure ( "Подождите ..." ).
FOR EACH sj-goods :
    delete sj-goods .
END .
FOR EACH d-slt-vat :
    delete d-slt-vat .
END .
raz = raz + 1.
if avail t-doc then
trid = recid(t-doc).
if not avail t-doc then do:
  GET prev br-docs.
  if avail t-doc then trid = recid(t-doc).
end.
DO WHILE available t-doc :
  GET prev br-docs.
  if avail t-doc then trid = recid(t-doc).
END.
GET next br-docs.
if objects > 0 then do:
        /*в выборке документы только по объектам одной фирмы*/
    FIND FIRST ub.sysconf where ub.sysconf.host-code = t-doc.host-code No-LOCK.
    loc#retail = ub.sysconf.ord-prt.
end.
else loc#retail = v-cntxp-retail.
DO WHILE available t-doc :
    if NOT (t-doc.fact-date >= X-date-start and t-doc.fact-date <= X-date-end AND
            t-doc.status_ = {&fact} AND
            t-doc.internal = no AND
           (t-doc.doc-type = {&expense} OR t-doc.doc-type = {&return}))
    then do:
        GET NEXT br-docs.
        next.
    end.
    if objects < 2 AND not
    can-find(first obj-list where obj-list.obj-code = t-doc.obj-code AND
                                  obj-list.obj-type = t-doc.obj-type) then do:
        GET NEXT br-docs.
        next.
    end.
    FIND FIRST ub.pay-type WHERE ub.pay-type.obj-code = t-doc.pay-code NO-LOCK .
    IF objects  = 0 then
    FIND FIRST ub.sysconf where ub.sysconf.host-code = t-doc.host-code No-LOCK.
    /* по требованию Назаркиной ограничение снято
    if NOT ub.pay-type.obj-code = sub.ysconf.cash-pay  then DO:
      GET NEXT br-docs.
      next.
    END.
    */
    /*по разному проверять на соответствие фильтру даты накладные*/
    if t-doc.cli-code = ub.sysconf.sale-code and t-doc.cli-type = {&cmp} then do:
         /*накладная по реализации - чек был выбит за дату t-doc.doc-date*/
        if t-doc.doc-date > X-date-end OR t-doc.doc-date < X-date-start then do:
        end.
    end.
    assign
    doc-num = t-doc.doc-code
    is-out = if t-doc.doc-type = {&expense} then 1 else -1
    offc = t-doc.office
    .
    { str/tax-mag.i }
    GET next br-docs.
END. /*REPEATE*/
IF NOT CAN-FIND(first SJ-GOODS) then do:
  run waitfram-hide in this-procedure .
  message "За указанные период времени в данном списке" skip
          "не нашлось ни одного документа, закрытого по факту,"
          "оплаченного наличными"
  view-as alert-box.
  return.
end.
date_string = cur-time-print() .
run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT STREAM PrnLibStream UNFORMATTED
SPACE(25)  "РАСЧЕТ НАЛОГОВ ПО ТОВАРАМ СПИСКА ЗАКРЫТЫХ ПО ФАКТУ ДОКУМЕНТОВ C " + string(X-date-start) +
" ПО " + string(X-date-end) + " ОПЛАЧЕННЫХ НАЛИЧНЫМИ" format "x(110)"  SKIP(0)
str2 skip(0)
SPACE(25) FRAME-TITLE FORMAT "X(110)" SKIP(0)
ReportHeader skip(0)
.
FOR EACH obj-list :
    ACCUMULATE obj-list.obj-code (COUNT).
END.
if (ACCUM COUNT obj-list.obj-code) > 1 then do:
    PUT STREAM PrnLibStream SPACE(21) "По объектам " SKIP(0) .
    FOR EACH obj-list :
        FIND FIRST clients WHERE clients.obj-type = obj-list.obj-type AND
                                 clients.obj-code = obj-list.obj-code NO-LOCK .
        PUT  STREAM PrnLibStream SPACE(21) clients.obj-name format "X(100)" SKIP.
    END.
end.
PUT STREAM PrnLibStream " " SKIP(1) .
FORM HEADER
Line format "X(188)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2}  PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME SJ-Base .
FOR EACH sj-goods use-index p2 BREAK BY sj-goods.is-out DESCENDING :
    assign
    sj-goods.netto-sum = sj-goods.brutto-sum - sj-goods.discnt-sum
    sj-goods.n-u-sum = (sj-goods.netto-sum - sj-goods.SLT-r-b) / (1 + sj-goods.VAT-pc / 100) - sj-goods.uchet-sum
    sj-goods.u-pcnt =  ( sj-goods.n-u-sum / sj-goods.uchet-sum ) * 100.
    if t-neg and abs(sj-goods.uchet-sum) >= abs((sj-goods.netto-sum - sj-goods.SLT-r-b) / (1 + sj-goods.VAT-pc / 100)) then
    assign
    sj-goods.n-u-sum = 0
    sj-goods.u-pcnt = 0
    /*sj-goods.VAT-r-b = 0*/ .
    FIND FIRST d-slt-vat WHERE d-slt-vat.SLT-pc = sj-goods.SLT-pc AND
                               d-slt-vat.VAT-pc = sj-goods.VAT-pc NO-LOCK NO-ERROR.
    IF NOT AVAILABLE d-slt-vat then do:
          create d-slt-vat.
          assign d-slt-vat.SLT-pc = sj-goods.SLT-pc
                      d-slt-vat.VAT-pc = sj-goods.VAT-pc.
    end.
   assign
   d-slt-vat.SLT-r-b-brutto =  d-slt-vat.SLT-r-b-brutto +  sj-goods.netto-sum
   d-slt-vat.SLT-r-b = d-slt-vat.SLT-r-b + sj-goods.SLT-r-b
   d-slt-vat.VAT-r-b = d-slt-vat.VAT-r-b + sj-goods.VAT-r-b
   d-slt-vat.uchet-sum = d-slt-vat.uchet-sum + sj-goods.uchet-sum
   d-slt-vat.uchet-with-vat-sum = d-slt-vat.uchet-with-vat-sum + sj-goods.uchet-with-vat-sum
   d-slt-vat.n-u-sum = d-slt-vat.n-u-sum + sj-goods.n-u-sum
   .

    ACCUMULATE sj-goods.b-code (SUB-COUNT BY sj-goods.is-out).
    IF method = "artic":u THEN DO:
        FIND clients WHERE
             clients.obj-type = sj-goods.prod-type AND
             clients.obj-code = sj-goods.prod-code NO-LOCK .
            prodbuf1 = breakstr(clients.obj-name, 25, prodbuf1, prodbuf2).
    END.
    namebuf1 = breakstr(sj-goods.name, 18, namebuf1, namebuf2).
    IF method = "b-code":U THEN
    DISPLAY STREAM PrnLibStream
    sym1
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code @ jj-tot
    sj-goods.b-code
    sj-goods.artic
    namebuf1 @ sj-goods.name
    namebuf2   @ clients.obj-name
    sj-goods.qnty
    sj-goods.unit
    sj-goods.uchet-sum
    sj-goods.netto-sum
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    sj-goods.netto-sum - sj-goods.slt-r-b @ for-netto-without-slt
    sj-goods.n-u-sum
    sj-goods.u-pcnt
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    sym10
    with FRAME SJ-Base .
    ELSE  IF method = "artic":U
    THEN
    DISPLAY STREAM PrnLibStream
    sym1
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code @ jj-tot
    sj-goods.b-code
    sj-goods.artic
    namebuf1 @ sj-goods.name
    prodbuf1   @ clients.obj-name
    sj-goods.qnty
    sj-goods.unit
    sj-goods.uchet-sum
    sj-goods.netto-sum
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    sj-goods.netto-sum - sj-goods.slt-r-b @ for-netto-without-slt
    sj-goods.n-u-sum
    sj-goods.u-pcnt
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    sym10
    with FRAME SJ-Base .
    IF method <> "TOTALS":U THEN DO:
    DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
    if method = "artic":U AND ( namebuf2 <> "" ) OR ( prodbuf2 <> "" ) then do:
        DISPLAY STREAM PrnLibStream
        sym1
        namebuf2 @ sj-goods.name
        prodbuf2 @ clients.obj-name
        sym10
        with FRAME SJ-Base .
        DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
    end.
END.
ACCUMULATE
sj-goods.qnty (TOTAL)
sj-goods.uchet-sum (TOTAL)
sj-goods.uchet-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.SLT-r-b (TOTAL)
sj-goods.SLT-r-b (SUB-TOTAL BY sj-goods.is-out)
sj-goods.n-u-sum (TOTAL)
sj-goods.n-u-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.VAT-r-b (TOTAL)
sj-goods.VAT-r-b (SUB-TOTAL BY sj-goods.is-out)
sj-goods.netto-sum (TOTAL)
sj-goods.qnty ( SUB-TOTAL BY sj-goods.is-out )
sj-goods.netto-sum ( SUB-TOTAL BY sj-goods.is-out )
.
if last-of( sj-goods.is-out ) then do:
    UNDERLINE STREAM PrnLibStream
    jj-tot
    sj-goods.b-code
    sj-goods.artic
    sj-goods.name
    clients.obj-name
    sj-goods.qnty
    sj-goods.unit
    sj-goods.uchet-sum
    sj-goods.netto-sum
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    for-netto-without-slt
    sj-goods.n-u-sum
    sj-goods.u-pcnt
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    with FRAME SJ-Base .
    DISPLAY STREAM PrnLibStream
    sym1
    IF method = "TOTALS":U
    THEN ""
    ELSE
    string(ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code , ">>>>9") @ sj-goods.b-code
    IF method = "TOTALS":U
    THEN ""
    ELSE " наименований"  @ sj-goods.artic
    string( "Итого " + ( if sj-goods.is-out then "продажи" else "возвраты" ) )
            @ sj-goods.name
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty @ sj-goods.qnty
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum @ sj-goods.netto-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum @ sj-goods.uchet-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.n-u-sum @ sj-goods.n-u-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.VAT-r-b @ sj-goods.VAT-r-b
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b @ sj-goods.SLT-r-b
    ((ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum) -
     (ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b)) @ for-netto-without-slt
    sym10
    with FRAME SJ-Base .
    jj-tot = jj-tot  + ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code.
    if NOT last( sj-goods.is-out ) then
    UNDERLINE STREAM PrnLibStream
    jj-tot
    sj-goods.b-code
    sj-goods.artic
    sj-goods.name
    clients.obj-name
    sj-goods.uchet-sum
    sj-goods.netto-sum
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    for-netto-without-slt
    sj-goods.n-u-sum
    sj-goods.u-pcnt
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    with FRAME SJ-Base .
end.
END . /*FOR EACH sj-goods*/
PUT STREAM PrnLibStream Line format "X(188)" .
DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
for each d-slt-vat break by d-slt-vat.vat-pc:
        if first-of(d-slt-vat.vat-pc) then
        vat-pc-val-qnty = vat-pc-val-qnty + 1.
        ACCUMULATE d-slt-vat.slt-pc (COUNT ).
end.
if ( line-counter (PrnLibStream) + 7 + 3 + (ACCUM COUNT d-slt-vat.SLT-pc) + vat-pc-val-qnty * 3 - 1) > page-size(PrnLibStream) then
    page STREAM PrnLibStream .

UNDERLINE STREAM PrnLibStream
jj-tot
sj-goods.b-code
sj-goods.artic
sj-goods.name
clients.obj-name
sj-goods.qnty
sj-goods.unit
sj-goods.uchet-sum
sj-goods.netto-sum
sj-goods.SLT-r-b
sj-goods.SLT-pc
for-netto-without-slt
sj-goods.n-u-sum
sj-goods.u-pcnt
sj-goods.VAT-pc
sj-goods.VAT-r-b
with FRAME SJ-Base .

DISPLAY  STREAM PrnLibStream
sym1
IF method = "TOTALS":U
THEN ""
ELSE string(jj-tot, ">>>>9")  @ sj-goods.b-code
IF method = "TOTALS":U
THEN ""
ELSE " наименований"  @ sj-goods.artic
"ИТОГО" @ sj-goods.name
(ACCUM TOTAL sj-goods.qnty  ) @ sj-goods.qnty
(ACCUM TOTAL sj-goods.netto-sum ) @ sj-goods.netto-sum
(ACCUM TOTAL sj-goods.uchet-sum) @ sj-goods.uchet-sum
(ACCUM TOTAL sj-goods.SLT-r-b ) @ sj-goods.SLT-r-b
((ACCUM TOTAL sj-goods.netto-sum) -
 (ACCUM TOTAL sj-goods.SLT-r-b  )) @ for-netto-without-slt
(ACCUM TOTAL sj-goods.n-u-sum  ) @ sj-goods.n-u-sum
(ACCUM TOTAL sj-goods.VAT-r-b  ) @  sj-goods.VAT-r-b
sym10
with FRAME SJ-Base .
UNDERLINE STREAM PrnLibStream
jj-tot
sj-goods.b-code
sj-goods.artic
sj-goods.name
clients.obj-name
sj-goods.qnty
sj-goods.unit
sj-goods.uchet-sum
sj-goods.netto-sum
sj-goods.SLT-r-b
sj-goods.SLT-pc
for-netto-without-slt
sj-goods.n-u-sum
sj-goods.u-pcnt
sj-goods.VAT-pc
sj-goods.VAT-r-b
with FRAME SJ-Base .

PUT STREAM PrnLibStream
skip
string( ": НДС :Сумма прод.цен : Сумма  налога  :Сумма прод.цен : Сумма учет. цен : Сумма учет. цен :   Сумма НДС    :% торг.нацен.:сумма торг.нац./:")
AT 33 format "X(160)" SKIP(0)
string( ":     :               :                :  без НП       :    с НДС        :    без НДС      :  с прод.цен    :             :сумма прод.цен  :")
AT 33 FORMAT "X(160)" skip
.

FOR EACH  d-slt-vat break by d-slt-vat.VAT-pc by d-slt-vat.slt-pc :

    ACCUMULATE
    d-slt-vat.SLT-r-b (TOTAL by d-slt-vat.vat-pc)
    d-slt-vat.SLT-r-b-brutto (TOTAL by d-slt-vat.vat-pc)
    d-slt-vat.VAT-r-b (TOTAL by d-slt-vat.vat-pc)
    d-slt-vat.uchet-with-vat-sum(TOTAL by d-slt-vat.vat-pc)
    d-slt-vat.uchet-sum (TOTAL by d-slt-vat.vat-pc)
    d-slt-vat.n-u-sum (TOTAL by d-slt-vat.vat-pc)
    .
    PUT STREAM PrnLibStream
    string( "Налог с продаж" + string( d-slt-vat.slt-pc, ">>9.<<%") +
            " " + string( d-slt-vat.VAT-pc, ">>9.<<%") + " " +
            string(d-slt-vat.slt-r-b-brutto, "->>>,>>>,>>9.99" )  +  ":")
    AT 14 format "X(42)"
    string( string( d-slt-vat.SLT-r-b, "->>>,>>>,>>9.99" ) + ":" )
    AT 57 format "X(16)"
    string( string((d-slt-vat.slt-r-b-brutto - d-slt-vat.SLT-r-b),"->>>,>>>,>>9.99" ) + ":" )
    AT 73 format "X(16)"
    (  string(d-slt-vat.uchet-with-vat-sum, "->>>,>>>,>>9.99" )  +  ":")
    AT 91 format "X(16)"
    (  string(d-slt-vat.uchet-sum, "->>>,>>>,>>9.99" )  +  ":")
       AT 108 format "X(16)"
    (  string(d-slt-vat.VAT-r-b, "->>>,>>>,>>9.99" )  +  ":")
       AT 126 format "X(16)"
    (  string(( d-slt-vat.n-u-sum / d-slt-vat.uchet-sum ) * 100, "->>>,>>9.99" )  +  ":")
       AT 144 format "X(16)"
    (  string(( d-slt-vat.n-u-sum / d-slt-vat.slt-r-b-brutto ) * 100, "->>,>>9.99" )  +  ":")
       AT 162 format "X(16)"
   SKIP.
   IF LAST-OF(d-slt-vat.vat-pc) then do:
       PUT STREAM PrnLibStream
       line AT 14 format "X(163)" SKIP
       string (  "Итого по НДС " + string(d-slt-vat.vat-pc, ">>>>>>99.99%")  + " " +
                 string(  ( ACCUM TOTAL by d-slt-vat.vat-pc d-slt-vat.slt-r-b-brutto ) , "->>>,>>>,>>9.99" )  +  ":"   )
       AT 14 format "X(43)"
       string (  string( ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   +  ":" )
       AT 57 format "X(16)"
       string (  string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b-brutto) -
               (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b) , "->>>,>>>,>>9.99" )   +  ":" )
       AT 73 format "X(16)"
       string (
               string(  ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-with-vat-sum ) , "->>>,>>>,>>9.99" )   +  ":"
              )
       AT 91 format "X(16)"
       string (
               string(  ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-sum ) , "->>>,>>>,>>9.99" )   +  ":"
              )
       AT 108 format "X(16)"
       string (
               string(  ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.VAT-r-b ) , "->>>,>>>,>>9.99" )   +  ":"
              )
       AT 126 format "X(16)"
       string (
               string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.n-u-sum) / (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-sum) * 100 , "->>>,>>9.99" )   +  ":"
              )
       AT 144 format "X(16)"
       string (
               string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.n-u-sum) / (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.slt-r-b-brutto)  * 100  , "->>,>>9.99" )   +  ":"
              )
       AT 162 format "X(16)"
       SKIP
       .
       if NOT last(d-slt-vat.vat-pc) then
       PUT STREAM PrnLibStream
       line AT 14 format "X(163)" SKIP .

  END.
end.
PUT STREAM PrnLibStream
line AT 14 format "X(163)" SKIP
string (  "Итого по налогам          "  +
string(  ( ACCUM TOTAL d-slt-vat.slt-r-b-brutto ) , "->>>,>>>,>>9.99" )  +  ":"   )
AT 14 format "X(43)"
string (  string( ( ACCUM TOTAL d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   +  ":" )
AT 57 format "X(16)"
string (  string( ( ACCUM TOTAL d-slt-vat.SLT-r-b-brutto) -
( ACCUM TOTAL d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   +  ":" )
AT 73 format "X(16)"
string (
        string(  ( ACCUM TOTAL d-slt-vat.uchet-with-vat-sum ) , "->>>,>>>,>>9.99" )   +  ":"
       )
AT 91 format "X(16)"
string (
        string(  ( ACCUM TOTAL d-slt-vat.uchet-sum ) , "->>>,>>>,>>9.99" )   +  ":"
       )
AT 108 format "X(16)"
string (
        string(  ( ACCUM TOTAL d-slt-vat.VAT-r-b ) , "->>>,>>>,>>9.99" )   +  ":"
       )
AT 126 format "X(16)"
string (
        string( (ACCUM TOTAL d-slt-vat.n-u-sum) / (ACCUM TOTAL d-slt-vat.uchet-sum) * 100 , "->>>,>>9.99" )   +  ":"
       )
AT 144 format "X(16)"
string (
        string( (ACCUM TOTAL d-slt-vat.n-u-sum) / (ACCUM TOTAL d-slt-vat.slt-r-b-brutto)  * 100  , "->>,>>9.99" )   +  ":"
       )
AT 162 format "X(16)"
SKIP.
PUT STREAM PrnLibStream
" " SKIP(1) space(10) "Директор ______________" format "X(50)"
"Гл. бухгалтер ___________________" format "X(50)" SKIP .
HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -116
g#rep-updflds = "Расчет налогов|" + str1.
*/

run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).

REPOSITION br-docs to recid trid NO-ERROR.
if error-status:error then trid = ?.
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