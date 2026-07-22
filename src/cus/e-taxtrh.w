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

Накладная по реализации в магазине для Трехгорки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

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
define variable vss-description as character no-undo init "Накладная по реализации в магазине для Трехгорки" .
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ cmp/r-page1.i }
{ cmp/library.i }
{ str/out-vatp.i def }
{ cmp/operlist.i }
{ str/lib-calc.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }


define temp-table sj-goods no-undo
field b-code like ub.bar-code.b-code format "9999999999999"
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field name   like ub.goods.gds-name format "x(30)"
field grp-code like ub.goods.grp-code
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
INDEX p4 grp-code
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


define temp-table t-grp no-undo
FIELD grp-code like ub.goods.grp-code
FIELD grp-name as character
index p1 IS UNIQUE PRIMARY grp-name ASCENDING.

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
define buffer buf-bar for ub.bar-code.
define buffer t-doc for ub.trn-doc.
define variable jj as integer no-undo.
define variable jj-tot as integer no-undo init 0.

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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-8 RECT-7 RS-By
&Scoped-Define DISPLAYED-OBJECTS RS-By

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE RS-By AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Отчеты о продаже (касса)", 1,
"Расх. и возвр. накладные по реализации", 2,
"Отчеты о продаже и накладные", 3
     SIZE 42.25 BY 2.67 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 4.83.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 3.92.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 45 BY 4.5.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RS-By AT ROW 7.75 COL 3.5 NO-LABEL
     "Источник формирования" VIEW-AS TEXT
          SIZE 34.63 BY .83 AT ROW 6.71 COL 3.5
          FGCOLOR 4
     RECT-6 AT ROW 1.25 COL 2.25
     RECT-8 AT ROW 6.46 COL 2.25
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
DEFINE VARIABLE varsum-dsc-r-b-acc as decimal no-undo .
DEFINE VARIABLE varvat-r-b-acc     as decimal no-undo .
DEFINE VARIABLE var-qnty              as decimal no-undo .
DEFINE VARIABLE varvat-r-b-doc     as decimal no-undo .
DEFINE VARIABLE varslt-r-b-doc     as decimal no-undo .
define variable slt-calc as decimal no-undo .
define variable vat-cost as decimal no-undo .
define variable cur-quant like ub.gds-dtl.doc-qnty no-undo.
define variable r-bar-code like ub.bar-code.b-code no-undo.
{ str/tax-mag.i }
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
  DISPLAY RS-By
      WITH FRAME F-Main.
  ENABLE RECT-6 RECT-8 RECT-7 RS-By
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


def buffer b-tr-doc  for ub.trn-doc .
define buffer buf_SYSCONF for UB.SYSCONF.
define variable v-curr-r-b as character no-undo .
define buffer buf_inkas for ub.inkas.
define buffer buf_sale-doc for ub.sale-doc.

{ gbl/curr-r-b.i
  v-curr-r-b
}

FOR EACH sj-goods :
    delete sj-goods .
END .
FOR EACH d-slt-vat :
    delete d-slt-vat .
END .
FOR EACH t-grp:
  delete t-grp.
end.
_obj-list:
FOR EACH obj-list NO-LOCK:
    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
    FIND FIRST buf_sysconf NO-LOCK WHERE buf_sysconf.host-code = v-host-code.
    IF AVAIL buf_sysconf
    then
    assign
    real-code = buf_sysconf.sale-code
    real-type = buf_sysconf.sale-type
    .
    else NEXT _obj-list.

    IF RS-by = 1 then do:
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
        if offc and negparts then NEXT _inkas.
        run cre-sj in this-procedure (
                                        input v-curr-r-b
                                      ,input doc-num
                                      ,input is-out
                                      ,input offc
                                      ).
        end.
      END. /*FOR EACH buf_inkas*/
    END. /* RS-by = 1 */
    IF RS-BY = 3 then do:
    _trn-doc:
      FOR EACH t-doc NO-LOCK WHERE
               t-doc.obj-type = obj-list.obj-type AND
               t-doc.obj-code = obj-list.obj-code AND
               t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} AND
               t-doc.status_ = {&fact} AND
               t-doc.doc-date >= X-date-start AND
               t-doc.doc-date <= X-date-end:
        assign
        doc-num = t-doc.doc-code
        offc = t-doc.office
        is-out = 1.
        if offc and negparts then NEXT _trn-doc.
        run cre-sj in this-procedure (
                                       input v-curr-r-b
                                      ,input doc-num
                                      ,input is-out
                                      ,input offc
                                      ).
      END.
      _ret-doc:
      FOR EACH t-doc NO-LOCK WHERE
               t-doc.obj-type = obj-list.obj-type AND
               t-doc.obj-code = obj-list.obj-code AND
               t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} AND
               t-doc.status_ = {&fact} AND
               t-doc.doc-date >= X-date-start AND
               t-doc.doc-date <= X-date-end:
        assign
        doc-num = t-doc.doc-code
        offc = t-doc.office
        is-out = -1.
        if offc and negparts then NEXT _ret-doc.
        run cre-sj in this-procedure (
                                       input v-curr-r-b
                                      ,input doc-num
                                      ,input is-out
                                      ,input offc
                                      ).
    END.
  END. /*RS-by 2 or 3*/
  IF RS-by = 2 OR RS-BY = 3 then do:
  _trn-doc2:
    FOR EACH t-doc NO-LOCK WHERE
              t-doc.obj-type = obj-list.obj-type AND
              t-doc.obj-code = obj-list.obj-code AND
              t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} AND
              t-doc.status_ = {&fact} AND
              t-doc.doc-date >= X-date-start AND
              t-doc.doc-date <= X-date-end AND
              t-doc.cli-type = real-type AND
              t-doc.cli-code = real-code
              :
      assign
      doc-num = t-doc.doc-code
      offc = t-doc.office
      is-out = 1.
      if offc and negparts then NEXT _trn-doc2.
      run cre-sj in this-procedure (
                                     input v-curr-r-b
                                    ,input doc-num
                                    ,input is-out
                                    ,input offc
                                    ).
    END.
    _ret-doc2:
    FOR EACH t-doc NO-LOCK WHERE
              t-doc.obj-type = obj-list.obj-type AND
              t-doc.obj-code = obj-list.obj-code AND
              t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} AND
              t-doc.status_ = {&fact} AND
              t-doc.doc-date >= X-date-start AND
              t-doc.doc-date <= X-date-end AND
              t-doc.cli-type = real-type AND
              t-doc.cli-code = real-code:
      assign
      doc-num = t-doc.doc-code
      offc = t-doc.office
      is-out = -1.
      if offc and negparts then NEXT _ret-doc2.
      run cre-sj in this-procedure (
                                     input v-curr-r-b
                                    ,input doc-num
                                    ,input is-out
                                    ,input offc
                                    ).
    END.
  end.
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
DEFINE VARIABLE v-append as logical no-undo .
define variable glog as logical no-undo .
run My-var.
run no-benq-i(output glog).
if NOT glog then do:
    message {&no-benefits} view-as alert-box.
    return.
end.
assign
date_string = cur-time-print()
Line = fill( "-", 180 )
jj = 0
jj-tot = 0
.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
run Main_Cycle.
run waitfram-hide in this-procedure .

assign
v-append = can-find(first sj-goods no-lock where
                          sj-goods.is-out = yes )
.
if v-append then
RUN PrintProc( input yes, input no  ).
if can-find(first sj-goods No-lock where
                  sj-goods.is-out = no ) then
RUN PrintProc( input no, input v-append).
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).

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
frame {&frame-name} RS-by
good-choice = (IF X-selectGood = {&g-all} then no else yes)
method = "artic"
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
Reportname = "РЕАЛИЗАЦИЯ В МАГАЗИНЕ".
ReportHeader =  "Источник формирования: " +
                radio-label(string(RS-BY), RS-BY:radio-buttons) + {&New-line}.

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
define input parameter p-is-out as logical no-undo .
define input parameter p-append as logical no-undo .
define variable i as integer no-undo .

define variable Line                as      char    no-undo.
define variable cash_string     as      char    no-undo.
define variable sale_string     as      char    no-undo.
define variable date_string     as      char    no-undo.

DEFINE VARIABLE v-opt-price as decimal no-undo .
DEFINE VARIABLE v-sale-without-tax-price as decimal no-undo .
DEFINE VARIABLE v-sale-without-tax-sum as decimal no-undo .
DEFINE VARIABLE v-direction as character no-undo .
define variable for-netto-without-slt as decimal no-undo.
define buffer buf_shop for ub.shop .
define buffer buf_sysconf for ub.sysconf .
define buffer host-cli for ub.clients.
define buffer buf_firm for ub.firm .
define buffer real-firm for ub.firm .
define buffer real-cli for ub.clients .

DEFINE FRAME SJ-Base
jj-tot column-label "  N  " format ">>>>>9"
sj-goods.artic column-label "    Артикул" format "x(16)"
sj-goods.name column-label "Наименование!Товара" format "x(25)"
sj-goods.unit column-label "Наим!ед изм" format "X(3)"
sj-goods.qnty column-label "Количество ! " format "->>>>>9.<<<"
v-opt-price column-label "Цена!оптовая" format ">>>>9.99"
sj-goods.uchet-sum COLUMN-LABEL "Сумма!оптовая" format "->>>>>>>>9.99"
v-sale-without-tax-price COLUMn-LABEL "Цена без!НДС и НП" format ">>>>9.99"
v-sale-without-tax-sum COLUMn-LABEL "Сумма без!НДС и НП" format "->>>>>>>>9.99"
sj-goods.VAT-pc column-label "Ставка!НДС, %"  format ">9"
sj-goods.VAT-r-b column-label "Сумма!НДС" format "->>>>>>>>9.99"
for-netto-without-slt column-label "Сумма с!учетом!НДС (без НП)"  format "->>>>>>>>9.99"
sj-goods.SLT-r-b column-label "Сумма НП"  format "->>>>>>>>9.99"
sj-goods.netto-sum column-label "Сумма c!учетом!НДС и НП" format "->>>>>>>>9.99"
HEADER  date_string AT 5 format "X(35)"
            string( "Страница " ) format "X(9)" AT 115 page-number(PrnLibStream)
             AT 125 FORMAT ">>9" SKIP
            Line format "X(180)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.
    Line = fill("-", 250).
run waitfram-show in this-procedure ( "Подождите ..." ).

if p-append then do:
  run prn-lib-open-stream  in this-procedure (
                                              input my-handle
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input yes /*p-append*/
                                              ).
  Page Stream PrnLibStream.
  output STREAM PrnLibStream CLOSE.
  run prn-lib-open-stream  in this-procedure (
                                              input my-handle
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input yes /*p-append*/
                                              ).
end.
else do:
  run prn-lib-open-stream  in this-procedure (
                                              input my-handle
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
end.

find first obj-list .
FIND ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                   ub.clients.obj-code = obj-list.obj-code NO-LOCK .
FIND FIRST buf_shop no-lock where
           buf_shop.obj-code = obj-list.obj-code.
find first buf_sysconf No-lock where
           buf_sysconf.host-code = buf_shop.host-code .
find first host-cli  No-LOCK WHERE
           host-cli.obj-type = {&cmp}
      AND host-cli.obj-code = buf_sysconf.host-code .
find first buf_firm No-LOCK where
           buf_firm.firm-code = buf_sysconf.host-code .
find first real-cli No-LOCK WHERE
           real-cli.obj-type = buf_sysconf.sale-type
      AND  real-cli.obj-code  = buf_sysconf.sale-code .
find first real-firm No-LOCK where
           real-firm.firm-code = real-cli.obj-code .

assign
v-direction = if p-is-out
              then "Продажи"
              else "Возвраты"
.
PUT STREAM PrnLibStream unformatted
'{&abbr_inn_allshift}' {&space-char} buf_firm.inn {&space-char} host-cli.obj-name SKIP
clients.obj-name SKIP(2)
"Грузополучатель: {&abbr_inn_allshift}" {&space-char} real-firm.inn {&space-char} real-cli.obj-name SKIP
"Поставщик: " host-cli.obj-name SKIP
"Плательщик: " real-cli.obj-name SKIP
"Основание:" skip
"Примечание:" {&space-char} v-direction skip
"Вид оплаты: Наличные" skip(2)
space(15) "Товарная накладная №" space(15) "от " string(X-date-end, "99/99/9999") skip
space(100) "Группа реализации"
skip.

FORM HEADER
Line format "X(180)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2}  PAGE-BOTTOM NO-LABELS NO-BOX .

VIEW STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME SJ-Base .
FOR EACH sj-goods where sj-goods.is-out = p-is-out
BREAK
BY sj-goods.is-out DESCENDING
BY sj-goods.artic
BY sj-goods.prod-type
By sj-goods.prod-code
:
    assign
    sj-goods.netto-sum = sj-goods.brutto-sum - sj-goods.discnt-sum
    v-opt-price = abs(sj-goods.uchet-sum / sj-goods.qnty)
    v-sale-without-tax-sum = sj-goods.netto-sum - sj-goods.VAT-r-b - sj-goods.SLT-r-b
    v-sale-without-tax-price = v-sale-without-tax-sum / sj-goods.qnty
    for-netto-without-slt = sj-goods.netto-sum - sj-goods.slt-r-b
    .
    ACCUMULATE sj-goods.artic (SUB-COUNT BY sj-goods.is-out).
    DISPLAY STREAM PrnLibStream
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.artic @ jj-tot
    sj-goods.artic
    sj-goods.name
    sj-goods.unit
    sj-goods.qnty
    v-opt-price
    sj-goods.uchet-sum
    v-sale-without-tax-price
    v-sale-without-tax-sum
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    for-netto-without-slt
    sj-goods.SLT-r-b
    sj-goods.netto-sum
    with FRAME SJ-Base .
    DOWN stream PrnLibStream
    with frame SJ-BASE.
    ACCUMULATE
    sj-goods.qnty (TOTAL)
    sj-goods.qnty ( SUB-TOTAL BY sj-goods.is-out )
    sj-goods.uchet-sum (TOTAL)
    sj-goods.uchet-sum (SUB-TOTAL BY sj-goods.is-out)
    sj-goods.SLT-r-b (TOTAL)
    sj-goods.SLT-r-b (SUB-TOTAL BY sj-goods.is-out)
    sj-goods.VAT-r-b (TOTAL)
    sj-goods.VAT-r-b (SUB-TOTAL BY sj-goods.is-out)
    sj-goods.netto-sum (TOTAL)
    sj-goods.netto-sum ( SUB-TOTAL BY sj-goods.is-out )
    v-sale-without-tax-sum (TOTAL)
    v-sale-without-tax-sum ( SUB-TOTAL BY sj-goods.is-out )
    for-netto-without-slt (TOTAL)
    for-netto-without-slt (SUB-TOTAL BY sj-goods.is-out )
    .
  if last( sj-goods.is-out ) then do:
    if ( line-counter (PrnLibStream) + 12 + 3)  > page-size(PrnLibStream) then
      page STREAM PrnLibStream .
      UNDERLINE STREAM PrnLibStream
      jj-tot
      sj-goods.artic
      sj-goods.name
      sj-goods.unit
      sj-goods.qnty
      v-opt-price
      sj-goods.uchet-sum
      v-sale-without-tax-price
      v-sale-without-tax-sum
      sj-goods.VAT-pc
      sj-goods.VAT-r-b
      for-netto-without-slt
      sj-goods.SLT-r-b
      sj-goods.netto-sum
      with FRAME SJ-Base .
      DISPLAY STREAM PrnLibStream
      string(ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.artic , ">>>>9") @ jj-tot
      " наименований"  @ sj-goods.artic
      string( "Итого ") @ sj-goods.name
      ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty @ sj-goods.qnty
          ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum @ sj-goods.uchet-sum
      ACCUM SUB-TOTAL BY sj-goods.is-out v-sale-without-tax-sum @ v-sale-without-tax-sum
      ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.VAT-r-b @ sj-goods.VAT-r-b
      ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b @ sj-goods.SLT-r-b
      ACCUM SUB-TOTAL BY sj-goods.is-out for-netto-without-slt @ for-netto-without-slt
      ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum @ sj-goods.netto-sum
      with FRAME SJ-Base .
      jj-tot = jj-tot  + ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.artic.
      UNDERLINE STREAM PrnLibStream
      jj-tot
      sj-goods.artic
      sj-goods.name
      sj-goods.unit
      sj-goods.qnty
      v-opt-price
      sj-goods.uchet-sum
      v-sale-without-tax-price
      v-sale-without-tax-sum
      sj-goods.VAT-pc
      sj-goods.VAT-r-b
      for-netto-without-slt
      sj-goods.SLT-r-b
      sj-goods.netto-sum
      with FRAME SJ-Base .
      /*PUT STREAM PrnLibStream Line format "X(180)" .*/
      DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
      PUT STREAM PrnLibStream unformatted
      skip(3)
      "Отпустил _______________  ________________  ____________________ товар и тару по количеству и надлежащему качеству" skip
      space(10) "должность" space(9) "подпись" space(9) "расшифровка подписи" skip(2)
      "Всего отпущено на сумму:" skip(2)
      "Получил  _______________  ________________  ____________________" skip
      space(10) "должность" space(9) "подпись" space(9) "расшифровка подписи" skip.
  end.
END . /*FOR EACH sj-goods*/

HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .

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