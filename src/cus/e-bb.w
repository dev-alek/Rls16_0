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

Отчет для Бизнес-Букета

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

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
define variable vss-description as character no-undo init "Отчет для Бизнес-Букета" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i  }
{ cmp/library.i  }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ str/lib-calc.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
{ rep/icm-3df.i  "NEW SHARED" }

define temp-table sj-goods no-undo
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
field uchet-sum   as decimal /*учетные цены с НДС*/
field n-u-sum             as   decimal /*netto -  uchet*/
field u-pcnt          as decimal /*% торговой наценки  = netto / uchet*/
field is-out        as  logical
field grp-code   like ub.gds-grp.node-code
INDEX p1 IS PRIMARY   b-code
INDEX p2 is-out DESCENDING
      b-code ASCENDING
INDEX p3 artic prod-type prod-code
INDEX p4 grp-code
.
define variable cas-shft as logical no-undo.
define variable cas-num as integer no-undo.
&global-define  no-benefits    "Не было никаких закрытых продаж на выбранных объектах ~
в течение заданного Вами периода времени."

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
define buffer t-doc for ub.trn-doc.
define variable jj as integer no-undo.
define variable jj-tot as integer no-undo init 0.
define variable for-netto-without-slt as decimal no-undo.
define variable vat-pc-val-qnty as integer no-undo.

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
          "Потоварно", "B-CODE":U,
"По группам верхнего уровня", "GROUP":U
     SIZE 36.5 BY 3.13 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 4.83.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 3.92.

DEFINE VARIABLE T-neg AS LOGICAL INITIAL no
     LABEL "Отрицательную наценку считать = 0"
     VIEW-AS TOGGLE-BOX
     SIZE 37.75 BY 1.04 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-Method AT ROW 2.58 COL 7 NO-LABEL
     T-neg AT ROW 12.21 COL 5
     "Детализация" VIEW-AS TEXT
          SIZE 33.13 BY .88 AT ROW 1.42 COL 3.25
          FGCOLOR 4
     RECT-6 AT ROW 1.25 COL 2.25
     RECT-7 AT ROW 11.33 COL 2.25
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 47.63 BY 15.


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cre-sj F-Frame-Win
PROCEDURE cre-sj :
define input parameter v-curr-r-b as character no-undo .
define input parameter  doc-num like ub.trn-doc.doc-code no-undo.
define input parameter is-out as integer init 1.
define input parameter offc as logical no-undo.
define variable s-price as decimal no-undo .
define variable cur-discnt as decimal no-undo .
define variable cur-quant like ub.gds-dtl.doc-qnty no-undo.
define variable slt-calc as dec.
define variable vat-cost as dec.
define variable r-bar-code like ub.bar-code.b-code no-undo.
DEFINE VARIABLE varsum-dsc-r-b-acc as decimal no-undo .
DEFINE VARIABLE varvat-r-b-acc     as decimal no-undo .
DEFINE VARIABLE var-qnty              as decimal no-undo .
DEFINE VARIABLE varvat-r-b-doc     as decimal no-undo .
DEFINE VARIABLE varslt-r-b-doc     as decimal no-undo .
define buffer buf-bar for ub.bar-code.
{ cus/e-bb.i }
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Main_cycle F-Frame-Win
PROCEDURE Main_cycle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable i as integer no-undo .
define variable tdoc-code     as      char    no-undo.
define variable real-code like ub.clients.obj-code no-undo.
define variable real-type like ub.clients.obj-type no-undo.
define variable doc-num like ub.trn-doc.doc-code no-undo.
define variable is-out as integer init 1.
define variable offc as logical no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-curr-r-b as character no-undo .
define buffer buf_inkas for ub.inkas.
define buffer buf_sale-doc for ub.sale-doc.
{ gbl/curr-r-b.i
  v-curr-r-b
}
define buffer buf_sysconf for ub.sysconf.
define buffer b-tr-doc  for ub.trn-doc .

FOR EACH sj-goods :
    delete sj-goods .
END .
_obj-list:
FOR EACH obj-list NO-LOCK:
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code}
  FIND FIRST buf_sysconf NO-LOCK WHERE buf_sysconf.host-code = v-host-code.
  IF AVAIL buf_sysconf
  then
  assign
  real-code = buf_sysconf.sale-code
  real-type = buf_sysconf.sale-type
  .
  else NEXT _obj-list.
  _inkas:
  FOR EACH buf_inkas WHERE
            buf_inkas.doc-date >= X-date-start and
            buf_inkas.doc-date <= X-date-end AND
            buf_inkas.obj-code = obj-list.obj-code and
            buf_inkas.obj-type = obj-list.obj-type AND
            buf_inkas.status_ = {&fact} NO-LOCK,
      each buf_sale-doc no-lock where
            buf_sale-doc.inkas-code = buf_inkas.inkas-code
        and buf_sale-doc.order > 0:
    if buf_sale-doc.in-inkas then do:
      FIND FIRST t-doc No-LOCK WHERE
              t-doc.doc-code = buf_sale-doc.doc-code no-error.
      if not available t-doc then do:
        next _inkas.
      end.
      assign
      doc-num = t-doc.doc-code
      is-out = buf_sale-doc.dir
      offc = t-doc.office
      .
      if buf_sale-doc.chr-office = {&gds-office}
      and negparts then NEXT _inkas.
      run cre-sj in this-procedure (
                              input v-curr-r-b
                            ,input doc-num
                            ,input is-out
                            ,input offc
                            ).
    end.
  END. /*FOR EACH inkas*/
END. /*FOR EACH obj*/

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
define variable glog as logical no-undo .
run My-var.
glog = no.
run no-benq-i(output glog).
if NOT glog then do:
    message {&no-benefits} view-as alert-box.
    return.
end.
assign
date_string = cur-time-print()
Line = fill( "-", 187 )
jj = 0
jj-tot = 0
.
if RS-METHOD = "GROUP":U then do:
  run rep/r-shftgr.p
              (input "":U, /*store-type*/
                input 0, /*store-code*/
                input ?, /*X-date-Start*/
                input ?, /*X-Shift-Alone*/
                input "n-level", /*xClassify*/
                input "":U,  /*xSortType*/
                input no, /*xtog-lavel*/
                input 1 /*xvar-lavel*/  ) no-error.
  /*
  output to hh.txt.
  for each t-3:
    put unformatted t-3.serv-name skip.
  end.
  output close.
  */
end.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
CASE RS-METHOD:
  when "b-code":u then do:
    RUN PrintProc in this-procedure .
  end.
  when "GROUP":u then do:
    RUN PrintProcGroup in this-procedure .
  end.
END CASE.


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
Reportname = "Отчет о движении товаров через кассу".
ReportHeader =  "Детализация: " +
                radio-label(string(RS-method), RS-method:radio-buttons) + {&New-line} +
                (if T-neg then t-neg:label else "")
                .

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

define variable Line                as      char    no-undo.
define variable cash_string     as      char    no-undo.
define variable sale_string     as      char    no-undo.
define variable date_string     as      char    no-undo.

define variable namebuf1     as      char    no-undo.
define variable namebuf2     as      char    no-undo.
define variable prodbuf1     as      char    no-undo.
define variable prodbuf2     as      char    no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
define buffer buf_clients for ub.clients.
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Вал. продаж - баз.вал. )" )
  .
end.
else do:
  assign
  v-header-base-curr = string( "( Вал. продаж - {&abbr_rubli_allshift} )" )
  .
end.


DEFINE FRAME SJ-Base
jj-tot column-label "  N  "                                                 format ">>>>>9"
sj-goods.b-code column-label "Код ! "                                       format ">>>>>>>>>9"
sj-goods.artic column-label "Артикул   ! "                                  format "x(16)"
sj-goods.name column-label "Наименование  ! "                               format "x(34)"
ub.clients.obj-name column-label "(Производитель)"                             format "x(25)"
sj-goods.unit column-label "Ед.!изм"                                        format "X(3)"
sj-goods.qnty column-label "Количество ! "                                  format "->>>>>9.<<<"
sj-goods.brutto-sum column-label  "Сумма брутто!в ценах продажи"            format "->>>>>>>>9.99"
sj-goods.discnt-sum column-label  "Сумма скидок!в ценах продажи"            format "->>>>>>>>9.99"
sj-goods.netto-sum column-label  "Сумма нетто!в ценах продажи"              format "->>>>>>>>9.99"
sj-goods.uchet-sum column-label  "Сумма!в учетных ценах"                    format "->>>>>>>>9.99"
sj-goods.u-pcnt column-label  "Торг.!нацен. %"                              format "->>9.99%"       /*netto / uceht*/
sj-goods.n-u-sum column-label "Эффективность"                               format "->>>>>>>>9.99"  /*netto-uceht*/
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr  format "X(25)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER ( PrnLibStream)
  AT 125 FORMAT ">>>>9" SKIP
Line format "X(188)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.
    Line = fill("-", 250).
run waitfram-show in this-procedure ( "Подождите ..." ).
run Main_Cycle.
date_string = cur-time-print() .
run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT STREAM PrnLibStream unformatted
SPACE(25)  "Отчет о движении товаров через кассу " + str1 + " ПО ОБЪЕКТАМ"  format "x(90)"  SKIP(0)
str2  skip(0)
ReportHeader skip(0)
SPACE(25) (if negparts then "(только порожденные партии)" else "") FORMAT "X(42)" SKIP(0)
   .
FOR EACH obj-list :
    FIND clients WHERE clients.obj-type = obj-list.obj-type AND
                                  clients.obj-code = obj-list.obj-code NO-LOCK .
    PUT  STREAM PrnLibStream SPACE(21) clients.obj-name format "X(100)" SKIP.
END.
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
    sj-goods.n-u-sum = (if sj-goods.is-out then 1 else - 1) * (abs(sj-goods.netto-sum) -  abs(sj-goods.uchet-sum))
    sj-goods.u-pcnt =  ( sj-goods.netto-sum / sj-goods.uchet-sum ) * 100.
    if t-neg and abs(sj-goods.uchet-sum) >= abs(sj-goods.netto-sum ) then
    assign
    sj-goods.n-u-sum = 0
    sj-goods.u-pcnt = 0
    .
    find first buf_clients no-lock where
              buf_Clients.obj-type = sj-goods.prod-type
         AND  buf_Clients.obj-code = sj-goods.prod-code no-error.
    ACCUMULATE sj-goods.b-code (SUB-COUNT BY sj-goods.is-out).
    namebuf1 = breakstr(sj-goods.name, 18, namebuf1, namebuf2).
    DISPLAY STREAM PrnLibStream
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code @ jj-tot
    sj-goods.b-code
    sj-goods.artic
    sj-goods.name
    (if available buf_Clients
     then buf_clients.obj-name
     else (sj-goods.prod-type + string(sj-goods.prod-code))
    ) @ clients.obj-name
    sj-goods.qnty
    sj-goods.unit
    sj-goods.brutto-sum
    sj-goods.discnt-sum
    sj-goods.netto-sum
    sj-goods.uchet-sum
    sj-goods.u-pcnt
    sj-goods.n-u-sum
    with FRAME SJ-Base .
    IF method <> "TOTALS":U THEN DO:
    DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
END.
ACCUMULATE
sj-goods.qnty (TOTAL)
sj-goods.qnty ( SUB-TOTAL BY sj-goods.is-out )
sj-goods.brutto-sum (TOTAL)
sj-goods.brutto-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.discnt-sum (TOTAL)
sj-goods.discnt-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.netto-sum (TOTAL)
sj-goods.netto-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.uchet-sum (TOTAL)
sj-goods.uchet-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.n-u-sum (TOTAL)
sj-goods.n-u-sum (SUB-TOTAL BY sj-goods.is-out)
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
    sj-goods.brutto-sum
    sj-goods.discnt-sum
    sj-goods.netto-sum
    sj-goods.uchet-sum
    sj-goods.u-pcnt
    sj-goods.n-u-sum
    with FRAME SJ-Base .
    DISPLAY STREAM PrnLibStream
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
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.brutto-sum @ sj-goods.brutto-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.discnt-sum @ sj-goods.discnt-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum @ sj-goods.netto-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum @ sj-goods.uchet-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.n-u-sum @ sj-goods.n-u-sum
    with FRAME SJ-Base .
    jj-tot = jj-tot  + ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code.
    if NOT last( sj-goods.is-out ) then
    UNDERLINE STREAM PrnLibStream
    jj-tot
    sj-goods.b-code
    sj-goods.artic
    sj-goods.name
    clients.obj-name
    sj-goods.brutto-sum
    sj-goods.discnt-sum
    sj-goods.netto-sum
    sj-goods.uchet-sum
    sj-goods.n-u-sum
    with FRAME SJ-Base .
end.
END . /*FOR EACH sj-goods*/
PUT STREAM PrnLibStream Line format "X(188)" .
DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
UNDERLINE STREAM PrnLibStream
jj-tot
sj-goods.b-code
sj-goods.artic
sj-goods.name
clients.obj-name
sj-goods.qnty
sj-goods.unit
sj-goods.brutto-sum
sj-goods.discnt-sum
sj-goods.netto-sum
sj-goods.uchet-sum
sj-goods.u-pcnt
sj-goods.n-u-sum
with FRAME SJ-Base .

DISPLAY  STREAM PrnLibStream
IF method = "TOTALS":U
THEN ""
ELSE string(jj-tot, ">>>>9")  @ sj-goods.b-code
IF method = "TOTALS":U
THEN ""
ELSE " наименований"  @ sj-goods.artic
"ИТОГО" @ sj-goods.name
(ACCUM TOTAL sj-goods.qnty  ) @ sj-goods.qnty
(ACCUM TOTAL sj-goods.brutto-sum ) @ sj-goods.brutto-sum
(ACCUM TOTAL sj-goods.discnt-sum ) @ sj-goods.discnt-sum
(ACCUM TOTAL sj-goods.netto-sum ) @ sj-goods.netto-sum
(ACCUM TOTAL sj-goods.uchet-sum) @ sj-goods.uchet-sum
(ACCUM TOTAL sj-goods.n-u-sum  ) @ sj-goods.n-u-sum
with FRAME SJ-Base .
UNDERLINE STREAM PrnLibStream
jj-tot
sj-goods.b-code
sj-goods.artic
sj-goods.name
clients.obj-name
sj-goods.qnty
sj-goods.unit
sj-goods.brutto-sum
sj-goods.discnt-sum
sj-goods.netto-sum
sj-goods.uchet-sum
sj-goods.u-pcnt
sj-goods.n-u-sum
with FRAME SJ-Base .

PUT STREAM PrnLibStream
" " SKIP(1) space(10) "Директор ______________" format "X(50)"
"Гл. бухгалтер ___________________" format "X(50)" SKIP .
HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.

run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProcGroup F-Frame-Win
PROCEDURE PrintProcGroup :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable i as integer no-undo .

define variable Line                as      char    no-undo.
define variable cash_string     as      char    no-undo.
define variable sale_string     as      char    no-undo.
define variable date_string     as      char    no-undo.

define variable namebuf1     as      char    no-undo.
define variable namebuf2     as      char    no-undo.
define variable prodbuf1     as      char    no-undo.
define variable prodbuf2     as      char    no-undo.
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Вал. продаж - баз.вал. )" )
  .
end.
else do:
  assign
  v-header-base-curr = string( "( Вал. продаж - {&abbr_rubli_allshift} )" )
  .
end.


DEFINE FRAME SJ-Base
jj-tot column-label "  N "                                                 format ">>>9"
t-3.grp-name column-label "Название группы  ! "                             format "x(32)"
sj-goods.qnty column-label "Количество ! "                                  format "->>>>>9.<<<"
sj-goods.brutto-sum column-label  "Сумма брутто!в ценах продажи"            format "->>>>>>>>9.99"
sj-goods.discnt-sum column-label  "Сумма скидок!в ценах продажи"            format "->>>>>>>>9.99"
sj-goods.netto-sum column-label  "Сумма нетто!в ценах продажи"              format "->>>>>>>>9.99"
sj-goods.uchet-sum column-label  "Сумма!в учетных ценах"                    format "->>>>>>>>9.99"
sj-goods.u-pcnt column-label  "Торг.!нацен. %"                              format "->>9.99%"       /*netto / uceht*/
sj-goods.n-u-sum column-label "Эффективность"                               format "->>>>>>>>9.99"  /*netto-uceht*/
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr  format "X(25)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER ( PrnLibStream)
  AT 125 FORMAT ">>>>9" SKIP
Line format "X(136)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.
    Line = fill("-", 250).
run waitfram-show in this-procedure ( "Подождите ..." ).
run Main_Cycle.
date_string = cur-time-print() .
run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


PUT STREAM PrnLibStream unformatted
SPACE(25)  "Отчет о движении товаров через кассу " + str1 + " ПО ОБЪЕКТАМ"  format "x(90)"  SKIP(0)
str2  skip(0)
ReportHeader skip(0)
SPACE(25) (if negparts then "(только порожденные партии)" else "") FORMAT "X(42)" SKIP(0)
   .
FOR EACH obj-list :
    FIND ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                                  ub.clients.obj-code = obj-list.obj-code NO-LOCK .
    PUT  STREAM PrnLibStream SPACE(21) ub.clients.obj-name format "X(100)" SKIP.
END.
PUT STREAM PrnLibStream " " SKIP(1) .
FORM HEADER
Line format "X(188)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2}  PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME SJ-Base .
for each t-3 no-lock,
    EACH sj-goods where sj-goods.grp-code = t-3.grp-code-sheet
BREAK
BY sj-goods.is-out DESCENDING
BY t-3.grp-name :
    assign
    sj-goods.netto-sum = sj-goods.brutto-sum - sj-goods.discnt-sum
    sj-goods.n-u-sum   = (if sj-goods.is-out then 1 else - 1) * (abs(sj-goods.netto-sum) -  abs(sj-goods.uchet-sum))
    sj-goods.u-pcnt =  ( sj-goods.netto-sum / sj-goods.uchet-sum ) * 100.
    /*if t-neg and abs(sj-goods.uchet-sum) >= abs((sj-goods.netto-sum - sj-goods.SLT-r-b) / (1 + sj-goods.VAT-pc / 100)) then
    assign
    sj-goods.n-u-sum = 0
    sj-goods.u-pcnt = 0
    /*sj-goods.VAT-r-b = 0*/ .
    */

    ACCUMULATE sj-goods.grp-code (SUB-COUNT BY sj-goods.is-out).
    DISPLAY STREAM PrnLibStream
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.grp-code @ jj-tot
    t-3.grp-name
    sj-goods.qnty
    sj-goods.brutto-sum
    sj-goods.discnt-sum
    sj-goods.netto-sum
    sj-goods.uchet-sum
    sj-goods.u-pcnt
    sj-goods.n-u-sum
    with FRAME SJ-Base .
    IF method <> "TOTALS":U THEN DO:
      DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
    END.
ACCUMULATE
sj-goods.qnty (TOTAL)
sj-goods.qnty ( SUB-TOTAL BY sj-goods.is-out )
sj-goods.brutto-sum (TOTAL)
sj-goods.brutto-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.discnt-sum (TOTAL)
sj-goods.discnt-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.netto-sum (TOTAL)
sj-goods.netto-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.uchet-sum (TOTAL)
sj-goods.uchet-sum (SUB-TOTAL BY sj-goods.is-out)
sj-goods.n-u-sum (TOTAL)
sj-goods.n-u-sum (SUB-TOTAL BY sj-goods.is-out)
.
if last-of( sj-goods.is-out ) then do:
    UNDERLINE STREAM PrnLibStream
    jj-tot
    t-3.grp-name
    sj-goods.qnty
    sj-goods.brutto-sum
    sj-goods.discnt-sum
    sj-goods.netto-sum
    sj-goods.uchet-sum
    sj-goods.u-pcnt
    sj-goods.n-u-sum
    with FRAME SJ-Base .
    DISPLAY STREAM PrnLibStream
    substitute("&1 &2 &3"
                ,(IF method = "TOTALS":U
                  THEN ""
                  ELSE
                  string(ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.grp-code , ">>>>9"))
                ,(IF method = "TOTALS":U
                  THEN ""
                  ELSE " групп")
                , string( "Итого " + ( if sj-goods.is-out then "продажи" else "возвраты" ) )
               )
                       @ t-3.grp-name
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty @ sj-goods.qnty
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.brutto-sum @ sj-goods.brutto-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.discnt-sum @ sj-goods.discnt-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum @ sj-goods.netto-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum @ sj-goods.uchet-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.n-u-sum @ sj-goods.n-u-sum
    with FRAME SJ-Base .
    jj-tot = jj-tot  + ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.grp-code.
    if NOT last( sj-goods.is-out ) then
    UNDERLINE STREAM PrnLibStream
    jj-tot
    t-3.grp-name
    sj-goods.brutto-sum
    sj-goods.discnt-sum
    sj-goods.netto-sum
    sj-goods.uchet-sum
    sj-goods.n-u-sum
    with FRAME SJ-Base .
end.
END . /*FOR EACH sj-goods*/
PUT STREAM PrnLibStream Line format "X(188)" .
DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
UNDERLINE STREAM PrnLibStream
jj-tot
t-3.grp-name
sj-goods.qnty
sj-goods.brutto-sum
sj-goods.discnt-sum
sj-goods.netto-sum
sj-goods.uchet-sum
sj-goods.u-pcnt
sj-goods.n-u-sum
with FRAME SJ-Base .

DISPLAY  STREAM PrnLibStream
substitute("&1 &2 &3"
           , (IF method = "TOTALS":U
              THEN ""
              ELSE string(jj-tot, ">>>>9"))
           , (IF method = "TOTALS":U
              THEN ""
              ELSE " групп")
           , "ИТОГО" )
                              @ t-3.grp-name
(ACCUM TOTAL sj-goods.qnty  ) @ sj-goods.qnty
(ACCUM TOTAL sj-goods.brutto-sum ) @ sj-goods.brutto-sum
(ACCUM TOTAL sj-goods.discnt-sum ) @ sj-goods.discnt-sum
(ACCUM TOTAL sj-goods.netto-sum ) @ sj-goods.netto-sum
(ACCUM TOTAL sj-goods.uchet-sum) @ sj-goods.uchet-sum
(ACCUM TOTAL sj-goods.n-u-sum  ) @ sj-goods.n-u-sum
with FRAME SJ-Base .
UNDERLINE STREAM PrnLibStream
jj-tot
t-3.grp-name
sj-goods.qnty
sj-goods.brutto-sum
sj-goods.discnt-sum
sj-goods.netto-sum
sj-goods.uchet-sum
sj-goods.u-pcnt
sj-goods.n-u-sum
with FRAME SJ-Base .

PUT STREAM PrnLibStream
" " SKIP(1) space(10) "Директор ______________" format "X(50)"
"Гл. бухгалтер ___________________" format "X(50)" SKIP .
HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).


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