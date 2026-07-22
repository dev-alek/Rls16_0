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

Остатки товаров, оприходованных до заданной даты

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
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Остатки товаров, оприходованных до заданной даты".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i def }

def temp-table sj-goods no-undo
    field b-code like ub.bar-code.b-code format "9999999999999"
    field artic     like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field gds-name   like ub.goods.gds-name format "x(30)"
    field engl-name   like ub.goods.engl-name format "x(30)"
    field unit like ub.goods.unit-base
    field qnty              as   decimal
    field uchet-sum-rubl   as decimal /*учетные цены*/
    field uchet-sum-base   as decimal /*учетные цены*/
    field sale-sum-rubl as decimal /*продажные цены*/
    field sale-sum-base as decimal /*продажные цены*/
    field VAT-pc       like ub.doc-line.VAT-pc
    field SLT-pc       like ub.doc-line.SLT-pc
    field VAT-supp      like ub.parts.VAT-pc
    field SLT-supp like ub.parts.SLT-pc
    field prt-root like ub.goods.prt-root
    field is-prt as logical init no /*товар со шкалами*/
    field supp-type like ub.parts.supp-type
    field supp-code like ub.parts.supp-code
    field purch-code as integer
    field pay-code as integer
    field uchet-price-base like ub.parts.price-base
    field uchet-price-rubl like ub.parts.price-base
    field uchet-sum-base-without-tax like ub.parts.price-base
    field uchet-sum-rubl-without-tax like ub.parts.price-base
    field in-code like ub.parts.in-code
    field fact-date like ub.parts.fact-date
    field s-price as decimal
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field cst-code like ub.parts.cst-code
    INDEX p1 IS PRIMARY prod-type prod-code artic supp-type supp-code SLT-pc VAT-pc VAT-supp SLT-supp purch-code in-code pay-code

    .
DEFINE TEMP-TABLE d-slt-vat no-undo
              FIELD SLT-pc like ub.doc-line.SLT-pc
              FIELD VAT-pc like ub.doc-line.VAT-pc
              field VAT-supp      like ub.parts.VAT-pc
              field SLT-supp      like ub.parts.VAT-pc
              field uchet-sum-rubl   as decimal /*учетные цены*/
              field uchet-sum-base   as decimal /*учетные цены*/
              field sale-sum-rubl as decimal /*продажные цены*/
              field sale-sum-base as decimal /*продажные цены*/
              field supp-type like ub.parts.supp-type
              field supp-code like ub.parts.supp-code
              field purch-code as integer
              field pay-code as integer
              INDEX p1 IS PRIMARY supp-type supp-code SLT-pc VAT-pc VAT-supp SLT-supp purch-code pay-code ASCENDING .
{ str/in-vatp.i def }

define variable cdate as date no-undo.
define variable odoc-prt like ub.shop.doc-prt.
define variable sale-stoim as decimal no-undo .

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
&Scoped-Define ENABLED-OBJECTS T-cons T-supp T-parts
&Scoped-Define DISPLAYED-OBJECTS T-cons T-supp T-parts

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE T-cons AS LOGICAL INITIAL no
     LABEL "Разделять консигнацию и выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 34.13 BY .92 NO-UNDO.

DEFINE VARIABLE T-parts AS LOGICAL INITIAL no
     LABEL "Каждую партию отдельной строкой"
     VIEW-AS TOGGLE-BOX
     SIZE 33.88 BY .92 NO-UNDO.

DEFINE VARIABLE T-supp AS LOGICAL INITIAL no
     LABEL "Указывать поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 34.13 BY .88 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-cons AT ROW 2.13 COL 2.38
     T-supp AT ROW 3.83 COL 2.38
     T-parts AT ROW 5.75 COL 2.38
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 37 BY 14.


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
         HEIGHT             = 14.04
         WIDTH              = 37.
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





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME T-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-parts F-Frame-Win
ON VALUE-CHANGED OF T-parts IN FRAME F-Main /* Каждую партию отдельной строкой */
DO:
  assign
  T-parts.
  if T-parts then do:
    assign
    T-cons = yes
    T-supp = yes
    .
    DISPLAY
    T-cons
    T-supp
    WITH FRAME {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
{ gbl/getcntxt.i get " " my-handle }
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

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
  DISPLAY T-cons T-supp T-parts
      WITH FRAME F-Main.
  ENABLE T-cons T-supp T-parts
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
define variable date_string     as      char    no-undo.
define variable prt-qnty as decimal no-undo .
def buffer supplier for ub.clients.
define variable ocons-pay like ub.sysconf.purch-code no-undo.
define variable ocons-pay-old like ub.sysconf.purch-code no-undo.

define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-host-code     like ub.sysconf.host-code  no-undo.

DEFINE VARIABLE         v-parts-VAt-pc  like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-parts-SLT-pc  like ub.parts-attr.SLT-pc           no-undo .
DEFINE VARIABLE         v-supp-type     like ub.parts-attr.supp-type        no-undo .
DEFINE VARIABLE         v-supp-code     like ub.parts-attr.supp-code        no-undo .
DEFINE VARIABLE         v-purch-code    like ub.parts-attr.purch-code       no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-fact-date     like ub.parts-attr.fact-date        no-undo .
DEFINE VARIABLE         v-obj-type      like ub.parts.obj-type              no-undo .
DEFINE VARIABLE         v-obj-code      like ub.parts.obj-code              no-undo .
DEFINE VARIABLE         v-is-attr       as logical no-undo .
DEFINE VARIABLE         v-supplier      like ub.clients.obj-name            no-undo .
DEFINE VARIABLE         v-producer      like ub.clients.obj-name            no-undo .
define variable         v-pay-code      like ub.parts.pay-code              no-undo .
DEFINE VARIABLE         v-cst-code      like ub.parts.cst-code              no-undo .
define variable g#log as logical no-undo .
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .

{ gbl/getsect.i run {&cmp} v-cntxt-host-code-obj {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.



define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}


define buffer buf_parts-attr for ub.parts-attr.
define buffer buf_pay-type  for ub.pay-type.


assign
frame {&frame-name} T-cons
frame {&frame-name} T-supp
frame {&frame-name} T-parts
cdate = X-date-alone
.
run My-var.
assign
date_string = cur-time-print()
.
run waitfram-show in this-procedure ( "Подождите ..." ).
FOR EACH sj-goods :
    delete sj-goods.
END .
FOR EACH d-slt-vat :
    delete d-slt-vat .
END .
/*соберем данные по объектам*/

FOR EACH obj-list NO-LOCK:
  IF obj-list.obj-type = {&shop} then do:
      FIND FIRST ub.shop NO-LOCK WHERE ub.shop.obj-code = obj-list.obj-code no-error.
      FIND FIRST ub.Sysconf No-LOCK WHERE ub.sysconf.host-code = ub.shop.host-code No-ERROR.
      assign
      odoc-prt = ub.shop.doc-prt
      ocons-pay = integer({&consignation-code})
      ocons-pay-old = integer({&old-consignation-code})
      .
  end.
  else do:
      FIND FIRST ub.store NO-LOCK WHERE ub.store.obj-code = obj-list.obj-code no-error.
      FIND FIRST ub.Sysconf No-LOCK WHERE ub.sysconf.host-code = store.host-code No-ERROR.
      assign
      odoc-prt = ub.store.doc-prt
      ocons-pay = integer({&consignation-code})
      ocons-pay-old = integer({&old-consignation-code})
      .
  end.

  FOR each ub.gds-obj NO-LOCk WHERE
          ub.gds-obj.obj-type = obj-list.obj-type AND
          ub.gds-obj.obj-code = obj-list.obj-code AND
          ub.gds-obj.fact-qnty <> 0 :
    ACCUMULATE gds-obj.artic (COUNT).
    IF (ACCUM COUNT gds-obj.artic ) MODULO 50  = 0 then do:
        run waitfram-show in this-procedure ("Обработано " + string(ACCUM COUNT gds-obj.artic) + " товаров на объекте " ).
    end.

    FOR EACH ub.parts NO-LOCK WHERE
            ub.parts.artic = ub.gds-obj.artic AND
            ub.parts.prod-type = ub.gds-obj.prod-type AND
            ub.parts.prod-code = ub.gds-obj.prod-code AND
            ub.parts.obj-type = ub.gds-obj.obj-type AND
            ub.parts.obj-code = ub.gds-obj.obj-code AND
            ub.parts.status_ = no AND
            ub.parts.rsrv-free = YES AND
            ub.parts.in-code <> ub.parts.out-code
                                            :
      FIND FIRST buf_parts-attr No-LOCK WHERE
                 buf_parts-attr.in-code = parts.in-code
             AND buf_parts-attr.gds-code = gds-obj.gds-code
             AND buf_parts-attr.part-code = parts.part-code
                 No-ERROR.
      IF AVAILABLE buf_parts-attr then do:
        if buf_parts-attr.fact-date > cdate then NEXT.
        assign
        v-is-attr      = yes
        v-parts-VAt-pc = buf_parts-attr.vat-pc
        v-parts-SLT-pc = buf_parts-attr.SLT-pc
        v-supp-type = buf_parts-attr.supp-type
        v-supp-code = buf_parts-attr.supp-code
        v-purch-code = buf_parts-attr.purch-code
        v-pay-code  = buf_parts-attr.pay-code
        v-in-code = buf_parts-attr.income-in-code
        v-fact-date = buf_parts-attr.fact-date
        v-obj-type =  parts.obj-type
        v-obj-code =  parts.obj-code
        v-cst-code = buf_parts-attr.cst-code
        .
      end.
      else do:
        assign
        v-is-attr = no
        .
        find first ub.trn-doc no-lock where
                   ub.trn-doc.doc-code = ub.parts.in-code no-error .
        if available ub.trn-doc and ub.trn-doc.fact-date > cdate then NEXT.
        /*скорее всего если мы здесь значит партия не преобразовывалась и ее можно по старому обрабатывать*/
        assign
          v-parts-VAt-pc = ub.parts.vat-pc
          v-parts-SLT-pc = ub.parts.SLT-pc
          v-supp-type = ub.parts.supp-type
          v-supp-code = ub.parts.supp-code
          v-purch-code = ub.parts.purch-code
          v-pay-code = ub.parts.pay-code
          v-in-code = ub.parts.in-code
          v-fact-date = (if available ub.trn-doc then ub.trn-doc.fact-date else ?)
          v-obj-type =  ub.parts.obj-type
          v-obj-code =  ub.parts.obj-code
          v-cst-code = ub.parts.cst-code
          .
      end.
      IF NOT T-parts then do:
        IF T-supp then
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.gds-obj.artic AND
                  sj-goods.prod-type = ub.gds-obj.prod-type AND
                  sj-goods.prod-code = ub.gds-obj.prod-code AND
                  sj-goods.VAT-supp = v-parts-VAT-pc AND
                  sj-goods.SLT-supp = v-parts-SLT-pc AND
                  sj-goods.supp-type = v-supp-type AND
                  sj-goods.supp-code = v-supp-code AND
                  (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                   AND
                  sj-goods.pay-code = v-pay-code))
                  No-error.
        ELSE
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = ub.gds-obj.artic AND
                  sj-goods.prod-type = ub.gds-obj.prod-type AND
                  sj-goods.prod-code = ub.gds-obj.prod-code AND
                  sj-goods.VAT-supp = v-parts-VAT-pc AND
                  sj-goods.SLT-supp = v-parts-SLT-pc AND
                  (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                   AND
                  sj-goods.pay-code = v-pay-code))
                  No-error.
      END.
      if not avail sj-goods or T-parts then do:
        FIND FIRST ub.goods No-LOCK WHERE
                    ub.goods.gds-code = ub.gds-obj.gds-code  NO-ERROR.
        FIND FIRST ub.gds-prt where
                    ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK .
        FIND FIRST ub.bar-code No-LOCK WHERE
                    ub.bar-code.gds-code = ub.gds-obj.gds-code AND
                    ub.bar-code.in-code = "" AND
                    ub.bar-code.part-code = "" AND
                    ub.bar-code.node-code =  ub.gds-prt.node-code  AND
                    ub.bar-code.unit-cli = ub.goods.unit-base NO-ERROR.
        create sj-goods.
        { gbl/hostcode.i gds-obj.obj-type gds-obj.obj-code v-host-code }
        { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-host-code gds-obj.obj-type gds-obj.obj-code v-vat-pc no-error }
        { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code gds-obj.obj-type gds-obj.obj-code v-slt-pc no-error }
        assign
        sj-goods.artic = goods.artic
        sj-goods.b-code = bar-code.b-code
        sj-goods.prod-type = goods.prod-type
        sj-goods.prod-code = goods.prod-code
        sj-goods.VAT-PC = v-vat-pc
        sj-goods.SLT-pc = v-slt-pc
        sj-goods.unit = goods.unit-base
        sj-goods.is-prt = gds-prt.node-name <> {&empty-scale}
        sj-goods.prt-root = goods.prt-root
        sj-goods.gds-name = REPLACE(goods.gds-name, " ", "_")
        sj-goods.engl-name = REPLACE(goods.engl-name, " ", "_")
        sj-goods.VAT-supp = v-parts-VAT-pc
        sj-goods.SLT-supp = v-parts-SLT-pc
        sj-goods.supp-type = IF T-supp OR T-parts then v-supp-type else ""
        sj-goods.supp-code = IF T-supp OR T-parts then v-supp-code else 0
        sj-goods.purch-code = IF T-cons or T-parts
                           then v-purch-code
                           else 0
        sj-goods.pay-code = IF T-cons or T-parts
                            then v-pay-code
                            else 0
        sj-goods.in-code = if T-parts then v-in-code else ""
        sj-goods.fact-date = if T-parts then v-fact-date else ?
        sj-goods.obj-type = if T-parts then v-obj-type else "":U
        sj-goods.obj-code = if T-parts then v-obj-code else 0
        sj-goods.cst-code = if T-parts then v-cst-code else "":U
        .
        /*надо найти общую сумму продажных цен на товар на объекте, а потом размазать по партиям*/

        sj-goods.s-price = gds-obj.fact-sale / gds-obj.fact-qnty.

      END. /*if not avail sj-goods*/
      { str/in-vatp.i calc-parts parts. " " g }
      assign
      prt-qnty =  (IF parts.out-code = {&free-code}
                   then
                   parts.qnty
                   else abs(parts.qnty))
      sj-goods.qnty = sj-goods.qnty +  prt-qnty
      sj-goods.sale-sum-rubl = if v-curr-r-b = {&r-b-base}
                               then sj-goods.sale-sum-rubl
                               else (sj-goods.sale-sum-rubl + sj-goods.s-price * prt-qnty)
      sj-goods.sale-sum-base = if v-curr-r-b = {&r-b-base}
                               then (sj-goods.sale-sum-base + sj-goods.s-price * prt-qnty)
                               else sj-goods.sale-sum-base
      sj-goods.uchet-price-base = if T-parts then parts.price-base else 0
      sj-goods.uchet-price-rubl = if T-parts then parts.price-rubl else 0
      sj-goods.uchet-sum-base = sj-goods.uchet-sum-base + parts.price-base * prt-qnty
      sj-goods.uchet-sum-rubl = sj-goods.uchet-sum-rubl + parts.price-rubl * prt-qnty
      sj-goods.uchet-sum-base-without-tax = sj-goods.uchet-sum-base-without-tax +
                                           (price-base-with-tax-loc - slt-base-loc - vat-base-loc) * prt-qnty
      sj-goods.uchet-sum-rubl-without-tax = sj-goods.uchet-sum-rubl-without-tax +
                                           (price-rubl-with-tax-loc  - slt-rubl-loc - vat-rubl-loc) * prt-qnty
      /*  бредятина
      sj-goods.sale-sum-rubl = if v-curr-r-b = {&r-b-base}
                               then  (sj-goods.sale-sum-rubl + sj-goods.s-price * prt-qnty * 1)
                               else sj-goods.sale-sum-rubl
      sj-goods.sale-sum-base = if v-curr-r-b = {&r-b-base}
                               then sj-goods.sale-sum-base
                               else (sj-goods.sale-sum-base + sj-goods.s-price * prt-qnty * 1)
       */
      .
    END. /*FOR EACH parts*/
  END. /*FOR EACH gds-obj*/
END. /*FOR EACH obj-list*/
run waitfram-hide in this-procedure.

{ cmp/open-exp.i stream PrnLibStream " " }
run waitfram-show in this-procedure ("Ждите...").
PUT stream PrnLibStream UNFORMATTED
    "Остатки на текущий момент  по товарам, оприходованным до " +
    string( cdate, "99/99/9999" ) + "."      format "x(110)" SKIP(1).
PUT stream PrnLibStream UNFORMATTED ReportHeader skip.
PUT stream PrnLibStream string("По объектам: "  )
        format "X(20)" SKIP.

FOR EACH obj-list :
    FIND FIRST ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                                      ub.clients.obj-code = obj-list.obj-code NO-LOCK .
    PUT stream PrnLibStream UNFORMATTED ub.clients.obj-name  ", ".
END.

PUT stream PrnLibStream UNFORMATTED
        SKIP
        cur-time-print() SKIP.


PUT stream PrnLibStream " " SKIP(1) .
PUT stream PrnLibStream UNFORMATTED
"Тип_производителя" p-XL-delim
"Код_производителя"  p-XL-delim
"Производитель"  p-XL-delim
"Артикул" p-XL-delim
"Бар-код" p-XL-delim
"Название" p-XL-delim
"Англ.название" p-XL-DELIM
"Ед.изм" p-XL-delim
"НДС" p-XL-delim
"НП" p-XL-delim
(IF T-supp then
("Тип_поставщика" + p-XL-delim + "Код_поставщика" + p-XL-delim + "Поставщик" + p-XL-delim)
else "")
(IF T-cons then
("Консигнационный_товар" + p-XL-delim)
else "")
(IF T-cons or T-parts
then
("Тип оплаты"  + p-XL-DELIM)
else "":U)
"НДС_поставщ" p-XL-delim
"НП_поставщ" p-XL-delim
(if T-parts
then ("Тип_объекта" + p-XL-delim +
      "Код_объекта" + p-XL-delim +
      "Учетн.цена_с НДС_НП_баз.вал." + p-XL-delim +
      "Учетн.цена_с НДС_НП_{&abbr_rubli}" + p-XL-delim +
      "N_прих.док-та" + p-XL-delim +
      "Факт_дата" + p-XL-delim +
      "ГТД" + p-XL-DELIM)
else ""
)
"Остаток" p-XL-delim
"Сумма_учет_цен_баз.вал" p-XL-delim
"Сумма_учет_цен_баз.вал_без_НДС_НП" p-XL-delim
"Сумма_учет_цен_{&abbr_rubli}" p-XL-delim
"Сумма_учет_цен_{&abbr_rubli}_без_НДС_НП" p-XL-delim
(if v-curr-r-b = {&r-b-base}
 then "Сумма_продаж_цен_баз.вал"
 else "Сумма_продаж_цен_{&abbr_rubli}") p-XL-delim
SKIP(0).

FOR EACH sj-goods NO-LOCK
use-index p1
break by sj-goods.prod-type
by sj-goods.prod-code
by sj-goods.supp-type
BY sj-goods.supp-code:
    IF FIRST-OF(sj-goods.supp-code) then do:
        FIND FIRST supplier NO-LOCK WHERE
                  supplier.obj-type = sj-goods.supp-type AND
                  supplier.obj-code = sj-goods.supp-code NO-ERROR.
       assign
       v-supplier = (if available supplier
                     then supplier.obj-name
                     else "":U)
       .
    end.

    IF FIRST-OF(sj-goods.prod-code) then do:
        FIND FIRST clients NO-LOCK WHERE
                  clients.obj-type = sj-goods.prod-type AND
                  clients.obj-code = sj-goods.prod-code NO-ERROR.
       assign
       v-producer = (if available clients
                     then clients.obj-name
                     else "":U)
       .
    end.

&scop purchase-code string(sj-goods.purch-code)
if t-parts or T-cons then
find first buf_pay-type no-lock where
          buf_pay-type.obj-code = sj-goods.pay-code no-error .

    PUT stream PrnLibStream UNFORMATTED
    sj-goods.prod-type p-XL-delim
    sj-goods.prod-code p-XL-delim
    REPLACE(v-producer, " ", "_") p-XL-delim
    sj-goods.artic p-XL-delim
    sj-goods.b-code p-XL-delim
    sj-goods.gds-name p-XL-delim
    sj-goods.engl-name p-XL-DELIM
    sj-goods.unit p-XL-delim
    sj-goods.VAT-pc p-XL-delim
    sj-goods.SLT-pc p-XL-delim
    (IF T-supp then
    (sj-goods.SUPP-type + p-XL-delim +
    string(sj-goods.SUPP-code) + p-XL-delim +
    REPLACE(v-supplier, " ", "_") + p-XL-delim
    )
    ELSE "")
    (IF T-cons then
    ({&purchase-codes-name} + p-XL-DELIM)
    ELSE "")
    (IF T-cons or T-parts
    then
    (if available buf_pay-type
    then (buf_pay-type.obj-name + p-XL-DELIM)
    else "":U)
    ELSE "":U
    )
    sj-goods.VAT-supp p-XL-delim
    sj-goods.SLT-supp p-XL-delim
    (if T-parts then
    (
     sj-goods.obj-type +  p-XL-delim +
     string(sj-goods.obj-code) +  p-XL-delim +
     string(sj-goods.uchet-price-base) +  p-XL-delim +
     string(sj-goods.uchet-price-rubl) +  p-XL-delim +
     sj-goods.in-code + p-XL-delim +
     (if sj-goods.fact-date = ? then "?" else string(sj-goods.fact-date, "99/99/9999")) + p-XL-delim +
      sj-goods.cst-code + p-XL-DELIM)
     else ""
     )
    sj-goods.qnty p-XL-delim
    sj-goods.uchet-sum-base p-XL-delim
    sj-goods.uchet-sum-base-without-tax  p-XL-delim
    sj-goods.uchet-sum-rubl p-XL-delim
    sj-goods.uchet-sum-rubl-without-tax p-XL-delim
    (if v-curr-r-b = {&r-b-base}
     then sj-goods.sale-sum-base
     else sj-goods.sale-sum-rubl)   p-XL-delim
    SKIP(0).
/*зарезервировано на будущее*/
/*
    IF T-supp then
    FIND FIRST d-slt-vat WHERE d-slt-vat.vat-pc = sj-goods.vat-pc AND
                                                    d-slt-vat.slt-pc = sj-goods.slt-pc AND
                                                    d-slt-vat.VAT-supp = sj-goods.VAT-supp AND
                                                    d-slt-vat.supp-type = sj-goods.supp-type AND
                                                    d-slt-vat.supp-code = sj-goods.supp-code AND
                                                    d-slt-vat.purch-code = sj-goods.purch-code  No-ERROR.
    ELSE
    FIND FIRST d-slt-vat WHERE d-slt-vat.vat-pc = sj-goods.vat-pc AND
                                                    d-slt-vat.slt-pc = sj-goods.slt-pc AND
                                                    d-slt-vat.VAT-supp = sj-goods.VAT-supp AND
                                                    d-slt-vat.purch-code  = sj-goods.purch-code  No-ERROR.
    IF NOT AVAILABLE(d-slt-vat) then do:
        create d-slt-vat.
        assign
        d-slt-vat.vat-pc = sj-goods.vat-pc
        d-slt-vat.slt-pc = sj-goods.slt-pc
        d-slt-vat.VAT-supp = sj-goods.VAT-supp
        d-slt-vat.supp-type = (IF T-supp then sj-goods.supp-type esle "")
        d-slt-vat.supp-code = (IF T-supp then sj-goods.supp-code esle 0)
        d-slt-vat.purch-code  = sj-goods.purch-code
        .
    end.
        assign
        d-slt-vat.uchet-sum-base = d-slt-vat.uchet-sum-base + sj-goods.uchet-sum-base
        d-slt-vat.uchet-sum-rubl = d-slt-vat.uchet-sum-rubl + sj-goods.uchet-sum-rubl
        d-slt-vat.sale-sum-base = d-slt-vat.sale-sum-base + sj-goods.sale-sum-base
        d-slt-vat.sale-sum-rubl = d-slt-vat.sale-sum-rubl + sj-goods.sale-sum-rubl
        .
*/
END.
output stream PrnLibStream CLOSE .
run waitfram-hide in this-procedure .
message
"Отчет выведен в файл"
view-as alert-box.
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
frame {&frame-name} T-cons
frame {&frame-name} T-supp
frame {&frame-name} T-parts
.
str1 = "".
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
ReportNAme = "Остатки товаров, оприходованных до " + string( X-date-alone, "99/99/9999" ).
ReportHeader = (if T-cons
                then "Разделять консигнацию и выкуп "
                else "Не разделять консигнацию и выкуп ") + {&new-line} +
               (if T-supp
                then "Указывать поставщика "
                else "Не указывать поставщика ") + {&new-line} +
               (if T-parts
                then "Каждую партию отдельной строкой"
                else "")
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tree-prt F-Frame-Win
PROCEDURE tree-prt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*заполняет таблицу cash-gds сканируя бар-коды и ДОПБК*/
def input param c like ub.gds-prt.node-code no-undo.
def param buffer b-g-p for ub.gds-prt.
def buffer b-gds-prt for ub.gds-prt.
define variable no-nodes as logical initial yes.

if odoc-prt then /* есть разбиение по признакам */
    FOR EACH b-gds-prt where b-gds-prt.upper-code = c  NO-LOCK:
        no-nodes = no.
        RUN tree-prt( b-gds-prt.node-code, buffer b-gds-prt ).
    END .  /*  for each b-gds-prt  */

if no-nodes then do: /* терминальный узел или нет разбиения по признакам */
   FIND FIRST ub.prt-obj No-LOCK WHERE
              ub.prt-obj.artic = ub.gds-obj.artic AND
            ub.prt-obj.prod-type = ub.gds-obj.prod-type AND
            ub.prt-obj.prod-code = ub.gds-obj.prod-code AND
            ub.prt-obj.prt-code = b-g-p.node-code No-ERROR.
  sale-stoim = sale-stoim  + ub.prt-obj.fact-qnty * ub.prt-obj.price-sale.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME