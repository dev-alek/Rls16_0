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

Печать Партии товара по документам

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
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Печать Партии товара по документам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i  }
{ gbl/prn-lib.i }
{ cmp/operlist.i }
{ rep/f-fdec.i   }
{ cmp/isengfrm.i }
{ gbl/waitfram.i }
{ ref/grplibfn.i }
{ cmp/doc-list.i doc-list def "NEW SHARED" }
{ gbl/getcntxt.i def " " my-handle }
{ rep/lhstprex.i doc-list-hist }
{ gbl/getsect.i  def }

def temp-table sj-goods no-undo
field b-code like ub.bar-code.b-code format "9999999999999"
field artic     like ub.goods.artic
field prod-type like ub.goods.prod-type
field prod-code like ub.goods.prod-code
field gds-name   like ub.goods.gds-name format "x(30)"
field grp-name   like ub.goods.grp-name
field unit like ub.goods.unit-base
field struct  like ub.goods.struct
field cst-code like ub.parts.cst-code
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
field price-base  as decimal
field price-rubl  as decimal
field arch-date as date format "99/99/9999"
field obj-type like ub.parts.obj-type
field obj-code like ub.parts.obj-code
field is-out_ as integer
INDEX p1 IS PRIMARY
prod-type
prod-code
artic
supp-type
supp-code
SLT-pc
VAT-pc
VAT-supp
SLT-supp
purch-code
pay-code
in-code
obj-type
obj-code
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

{ str/in-vatp.i def}
def var date_string     as      char    no-undo.
def var sale-stoim as decimal no-undo .
def var prt-qnty as decimal no-undo .
def var odoc-prt like ub.shop.doc-prt.
def buffer supplier for ub.clients.
def var ocons-pay like ub.sysconf.purch-code no-undo.
def var ocons-pay-2 like ub.sysconf.purch-code no-undo.
def var real-code like ub.sysconf.sale-code no-undo.
def var real-type like ub.sysconf.sale-type no-undo.
def buffer ret-doc for ub.trn-doc.
def buffer for-doc for ub.trn-doc.
def var doc-num like ub.trn-doc.doc-code.
define variable v-doc-type like ub.trn-doc.doc-type no-undo .
define variable v-internal like ub.trn-doc.internal no-undo .
def var my-accum as integer no-undo.
def var is-out as integer no-undo.
def var method as char no-undo.
def var for-title as char no-undo.
def var sale_sum_base as decimal no-undo.
def var sale_sum_rubl as decimal no-undo.
def var v-vat-pc        like ub.doc-line.vat-pc    no-undo.
def var v-slt-pc        like ub.doc-line.slt-pc    no-undo.
def var v-host-code     like ub.sysconf.host-code  no-undo.

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
&Scoped-Define ENABLED-OBJECTS RECT-method RECT-supp T-supp T-cons T-parts ~
T-sostav T-split RS-method
&Scoped-Define DISPLAYED-OBJECTS T-supp T-cons T-parts T-GTD T-sostav ~
T-split RS-method F-one

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE F-one AS CHARACTER FORMAT "X(256)":U
     LABEL "N накл."
     VIEW-AS FILL-IN
     SIZE 22.13 BY 1 NO-UNDO.

DEFINE VARIABLE RS-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Розница", "Sale":U,
"Расходные накладные", "RAS":U,
"Возвратные накладные", "VOZ":U,
"Расходные и возвратные накладные", "RAS+VOZ":U,
"Накладные списания", "SPI":U,
"Все", "ALL":U,
"СПИСОК док-тов(расход и возврат)", "LIST":U,
"Накладная N", "ONE":U
     SIZE 36.25 BY 4.54 NO-UNDO.

DEFINE RECTANGLE RECT-method
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.38 BY 6.33.

DEFINE RECTANGLE RECT-supp
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.38 BY 8.58.

DEFINE VARIABLE T-cons AS LOGICAL INITIAL no
     LABEL "Разделять конс. и выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 25.5 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-GTD AS LOGICAL INITIAL no
     LABEL "ГТД"
     VIEW-AS TOGGLE-BOX
     SIZE 36.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-parts AS LOGICAL INITIAL no
     LABEL "Каждую партию отдельной строкой"
     VIEW-AS TOGGLE-BOX
     SIZE 36.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-sostav AS LOGICAL INITIAL no
     LABEL "Состав сырья"
     VIEW-AS TOGGLE-BOX
     SIZE 36.88 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-split AS LOGICAL INITIAL no
     LABEL "Разделять расход/возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-supp AS LOGICAL INITIAL no
     LABEL "Указывать поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 22.88 BY 1
     FGCOLOR 4  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-supp AT ROW 1.46 COL 4.13
     T-cons AT ROW 3 COL 3.88
     T-parts AT ROW 4.42 COL 3.88
     T-GTD AT ROW 5.54 COL 6.5
     T-sostav AT ROW 6.83 COL 4
     T-split AT ROW 8.29 COL 3.75
     RS-method AT ROW 10.21 COL 14.38 NO-LABEL
     F-one AT ROW 14.96 COL 12.5 COLON-ALIGNED
     "расчета" VIEW-AS TEXT
          SIZE 10.38 BY 1 AT ROW 11.21 COL 3
          FGCOLOR 4
     "Источник" VIEW-AS TEXT
          SIZE 10.25 BY .83 AT ROW 10.29 COL 3.25
          FGCOLOR 4
     RECT-method AT ROW 9.96 COL 2.25
     RECT-supp AT ROW 1.17 COL 2.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 53.38 BY 15.54.


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
         HEIGHT             = 15.58
         WIDTH              = 53.38.
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
/* SETTINGS FOR FILL-IN F-one IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-GTD IN FRAME F-Main
   NO-ENABLE                                                            */
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

&Scoped-define SELF-NAME RS-method
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RS-method F-Frame-Win
ON VALUE-CHANGED OF RS-method IN FRAME F-Main
DO:
  assign RS-METHOD.
  IF RS-METHOD = "ONE" then
  ENABLE
  f-ONE
  WITH FRAME {&frame-name}.
  ELSE
  HIDE
  f-ONE
  IN FRAME {&frame-name}.
  if rs-method = "LIST":U then do:
    run str/doc-list.w (my-handle, v-cntxt-host-code-obj, v-cntxt-obj-type, v-cntxt-obj-code).
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


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
    ENABLE T-GTD
        with frame {&frame-name}.
    DISPLAY
    T-cons
    T-supp

    WITH FRAME {&frame-name}.
  end.
  else do:
    assign
    T-GTD = no
    .
    DISPLAY
    T-GTD
    WITH FRAME {&frame-name}.
    DISABLE T-GTD
        with frame {&frame-name}.

  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-sj-goods F-Frame-Win
PROCEDURE cr-sj-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE VARIABLE         v-parts-VAt-pc  like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-parts-SLT-pc  like ub.parts-attr.SLT-pc           no-undo .
DEFINE VARIABLE         v-supp-type     like ub.parts-attr.supp-type        no-undo .
DEFINE VARIABLE         v-supp-code     like ub.parts-attr.supp-code        no-undo .
DEFINE VARIABLE         v-purch-code    like ub.parts-attr.purch-code       no-undo .
define variable         v-pay-code      like ub.parts.pay-code              no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-fact-date     like ub.parts-attr.fact-date        no-undo .
DEFINE VARIABLE         v-obj-type      like ub.parts.obj-type              no-undo .
DEFINE VARIABLE         v-obj-code      like ub.parts.obj-code              no-undo .
DEFINE VARIABLE         v-cst-code      like ub.parts.cst-code              no-undo .
DEFINE VARIABLE         v-is-attr       as logical no-undo .
define variable         v-is-primary    as logical no-undo .
define variable         v-grp-name      as character no-undo .

define buffer buf_parts-attr for ub.parts-attr.
define buffer buf_pay-type  for ub.pay-type.
define buffer bf-in_parts-attr for ub.parts-attr.
define buffer buf_trn-stp for ub.trn-doc.
define buffer buf_parts-stp for ub.parts.


{ rep/e-slprts.i }

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
  DISPLAY T-supp T-cons T-parts T-GTD T-sostav T-split RS-method F-one
      WITH FRAME F-Main.
  ENABLE RECT-method RECT-supp T-supp T-cons T-parts T-sostav T-split RS-method
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
DEFINE VARIABLE         v-supplier      like ub.clients.obj-name            no-undo .
DEFINE VARIABLE         v-producer      like ub.clients.obj-name            no-undo .
define buffer buf_pay-type for ub.pay-type  .
run My-var.
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

assign
date_string = cur-time-print() .

run waitfram-show in this-procedure ( input "Подождите ..." ).
FOR EACH sj-goods :
    delete sj-goods.
END .
FOR EACH d-slt-vat :
    delete d-slt-vat .
END .
/*соберем данные по объектам*/

if not can-find(first obj-list) then do:
  run waitfram-hide in this-procedure .
  message
  "Не выбрано ни одного объекта по текущей фирме!"
  view-as alert-box WARNING.
  return.
end.
my-accum = 0.
FOR EACH obj-list NO-LOCK:
    IF obj-list.obj-type = {&shop} then do:
        FIND FIRST ub.shop NO-LOCK WHERE ub.shop.obj-code = obj-list.obj-code no-error.
        FIND FIRST ub.Sysconf No-LOCK WHERE ub.sysconf.host-code = ub.shop.host-code No-ERROR.
        assign
        odoc-prt = ub.shop.doc-prt
        ocons-pay = integer({&consignation-code})
        ocons-pay-2 = integer({&old-consignation-code})
        real-code = ub.sysconf.sale-code
        real-type = ub.sysconf.sale-type
        .
    end.
    else do:
        FIND FIRST ub.store NO-LOCK WHERE ub.store.obj-code = obj-list.obj-code no-error.
        FIND FIRST ub.Sysconf No-LOCK WHERE ub.sysconf.host-code = ub.store.host-code No-ERROR.
        assign
        odoc-prt = ub.store.doc-prt
        ocons-pay = integer({&consignation-code})
        ocons-pay-2 = integer({&old-consignation-code})
        real-code = ub.sysconf.sale-code
        real-type = ub.sysconf.sale-type
        .
    end.
    CASE Rs-method:
    WHEN "SALE":U then do:
    if obj-list.obj-type = {&stock} then NEXT.
    FOR EACH ub.inkas no-LOCK where
            ub.inkas.doc-date >= X-date-start
        AND ub.inkas.doc-date <= X-date-end
        AND ub.inkas.obj-type = obj-list.obj-type
        AND ub.inkas.obj-code = obj-list.obj-code
        AND   ub.inkas.status_ = {&fact},
       each buf_sale-doc  no-lock where
            buf_sale-doc.inkas-code = ub.inkas.inkas-code
        and buf_sale-doc.in-inkas = yes
        and buf_sale-doc.chr-office = {&gds-goods}:
        assign
        doc-num = buf_sale-doc.doc-code
        v-doc-type = buf_sale-doc.doc-type
        v-internal = buf_sale-doc.internal
        is-out = buf_sale-doc.dir
        .
        run cr-sj-goods in this-procedure.
      END. /*FOR EACH inkasj*/
      FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
              for-doc.obj-code = obj-list.obj-code AND
              for-doc.internal = no AND
              for-doc.doc-date >= X-date-start AND
              for-doc.doc-date <= X-date-end AND
              for-doc.doc-type  =  {&return} AND
              for-doc.status_ = {&fact} AND
              for-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}:
        if NOT (for-doc.cli-code = real-code and for-doc.cli-type = real-type) then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = - 1
        .
        run cr-sj-goods in this-procedure.
      END.
      FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
              for-doc.obj-code = obj-list.obj-code AND
              for-doc.internal = no AND
              for-doc.doc-date >= X-date-start AND
              for-doc.doc-date <= X-date-end AND
              for-doc.doc-type  =  {&expense} AND
              for-doc.status_ = {&fact} AND
              for-doc.ext-doc-type = {&TDEDT_RAS_Vnesh}:
        if NOT (for-doc.cli-code = real-code and for-doc.cli-type = real-type) then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
      END.
    END.
    WHEN "RAS":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  {&expense} AND
                for-doc.status_ = {&fact}:
        if for-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
          or for-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
          or for-doc.office
        then do:
          next.
        end.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "VOZ":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  {&return} AND
                for-doc.status_ = {&fact}:
        if for-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        OR for-doc.office
        then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = - 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "RAS+VOZ":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  {&expense} AND
                for-doc.status_ = {&fact}:
        if for-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
          or for-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
          or for-doc.office
        then do:
          next.
        end.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
        END.
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  {&return} AND
                for-doc.status_ = {&fact}:
        if for-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
        OR for-doc.office
        then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = - 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "SPI":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.doc-type  =  {&write-off} AND
                for-doc.status_ = {&fact}:
        if for-doc.office
        then NEXT.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = 1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "ALL":U then do:
        FOR EACH for-doc No-LOCK WHERE
                for-doc.obj-type = obj-list.obj-type AND
                for-doc.obj-code = obj-list.obj-code AND
                for-doc.internal = no AND
                for-doc.doc-date >= X-date-start AND
                for-doc.doc-date <= X-date-end AND
                for-doc.status_ = {&fact}:
        if for-doc.doc-type = {&inventory}
          or for-doc.doc-type = {&write-off}
          or for-doc.doc-type = {&income}
          or for-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP}
          or for-doc.office
        then do:
          next.
        end.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = if for-doc.doc-type = {&expense} then 1 else -1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "ONE":U then do:
        FOR EACH for-doc No-LOCK WHERE for-doc.doc-code = f-one:
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = if for-doc.doc-type = {&expense} then 1 else -1
        .
        run cr-sj-goods in this-procedure.
        END.
    END.
    WHEN "LIST":U then do:
      _doc-list:
      for each doc-list no-lock where
               doc-list.obj-type = obj-list.obj-type
           AND doc-list.obj-code = obj-list.obj-code,
         first for-doc No-LOCK WHERE for-doc.doc-code = doc-list.doc-code:
        if doc-list.doc-type <> {&expense}
        and doc-list.doc-type <> {&return} then next _doc-list.
        assign
        doc-num = for-doc.doc-code
        v-doc-type = for-doc.doc-type
        v-internal = for-doc.internal
        is-out = if for-doc.doc-type = {&expense} then 1 else -1
        .
        run cr-sj-goods in this-procedure.
      END.
    END.
    END CASE.
END. /*FOR EACH obj-list*/
run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

run waitfram-show in this-procedure ("Ждите...").
PUT stream PrnLibStream UNFORMATTED
("Партии товара" +
(if Rs-method <> "ONE"
then (", реализованного с " +
string( X-date-start, "99/99/9999" ) + " по " + string(X-date-end, "99/99/9999") + ".")
else "") )     format "x(110)" SKIP(1).
PUT stream PrnLibStream ("Источник расчета: "  + for-title) format "X(60)" SKIP(0).
PUT stream PrnLibStream string("По объектам: "  )
    format "X(20)" SKIP.

FOR EACH obj-list :
FIND FIRST ub.clients WHERE ub.clients.obj-type = obj-list.obj-type AND
                                  ub.clients.obj-code = obj-list.obj-code NO-LOCK .
PUT stream PrnLibStream UNFORMATTED ub.clients.obj-name  ", ".
END.

PUT stream PrnLibStream UNFORMATTED
SKIP
cur-time-print() format "x(35)" SKIP.


PUT stream PrnLibStream " " SKIP(1) .
PUT stream PrnLibStream UNFORMATTED
"Тип_производителя" p-XL-delim
"Код_производителя"  p-XL-delim
"Производитель"  p-XL-delim
"Артикул" p-XL-delim
"Бар-код" p-XL-delim
"Название" p-XL-delim
"Ед.изм" p-XL-delim
(if T-sostav
then ("Состав сырья" + p-XL-delim)
else "":U)
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
("Тип оплаты"  + p-XL-delim)
else "":U)
"НДС_поставщ" p-XL-delim
"НП_поставщ" p-XL-delim
(IF T-GTD then
("ГТД" + p-XL-delim)
else "")
(if T-parts
then ("Учетн.цена_с НДС_НП_баз.вал." + p-XL-delim +
         "Учетн.цена_с НДС_НП_{&abbr_rubli}" + p-XL-delim +
         "N_прих.док-та" + p-XL-delim +
         "Дата_приходного_док-та" + p-XL-delim)
else ""
)
"Реализованное_количество" p-XL-delim
"Сумма_учет_цен_баз.вал" p-XL-delim
"Сумма_учет_цен_баз.вал_без_НДС_НП" p-XL-delim
"Сумма_учет_цен_{&abbr_rubli}" p-XL-delim
"Сумма_учет_цен_{&abbr_rubli}_без_НДС_НП" p-XL-delim
"Сумма_продаж_цен_баз.вал" p-XL-delim
"Сумма_продаж_цен_{&abbr_rubli}" p-XL-delim
(if T-parts
then
("Тип_объекта" + p-XL-delim +
"Код_объекта" + p-XL-delim +
"Факт.дата_партии" + p-XL-delim)
else "") +
"Группа товара"
SKIP(0).
run rep/extitle.p (1).
FOR EACH sj-goods NO-LOCK use-index p1
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
if T-cons or T-parts then
find first buf_pay-type no-lock where
          buf_pay-type.obj-code = sj-goods.pay-code no-error .
    PUT stream PrnLibStream UNFORMATTED
    sj-goods.prod-type p-XL-delim
    sj-goods.prod-code p-XL-delim
    REPLACE(v-producer, " ", "_") p-XL-delim
    sj-goods.artic p-XL-delim
    sj-goods.b-code p-XL-delim
    sj-goods.gds-name p-XL-delim
    sj-goods.unit p-XL-delim
    (if T-sostav
    then (sj-goods.struct + p-XL-delim)
    else "":U)
    sj-goods.VAT-pc p-XL-delim
    sj-goods.SLT-pc p-XL-delim
    (IF T-supp then
    (sj-goods.SUPP-type + p-XL-delim +
    string(sj-goods.SUPP-code) + p-XL-delim +
    REPLACE(v-supplier, " ", "_") + p-XL-delim
    )
    ELSE "")
    (IF T-cons then
    ({&purchase-codes-name} + p-XL-delim)
    ELSE "")
    (IF T-cons or T-parts
    then
    (if available buf_pay-type
    then (buf_pay-type.obj-name + p-XL-delim)
    else p-XL-delim)
    ELSE "":U
    )
    sj-goods.VAT-supp p-XL-delim
    sj-goods.SLT-supp p-XL-delim
    (if T-GTD
     then
     (sj-goods.cst-code + p-XL-delim)
     else "":U
     )
    (if T-parts
    then (
     (if sj-goods.uchet-price-base <> ?
      then string(sj-goods.uchet-price-base)
      else "":U)  +  p-XL-delim +
     (if sj-goods.uchet-price-rubl <> ?
      then string(sj-goods.uchet-price-rubl)
      else "":U)  +  p-XL-delim +
      (if sj-goods.in-code <> ?
       then sj-goods.in-code
       else "":U) + p-XL-delim +
     (if sj-goods.fact-date = ?
       then "":U
       else string(sj-goods.fact-date, "99/99/9999")) + p-XL-delim
        )
     else ""
     )
    sj-goods.qnty p-XL-delim
    sj-goods.uchet-sum-base p-XL-delim
    sj-goods.uchet-sum-base-without-tax  p-XL-delim
    sj-goods.uchet-sum-rubl p-XL-delim
    sj-goods.uchet-sum-rubl-without-tax p-XL-delim
    sj-goods.sale-sum-base p-XL-delim
    sj-goods.sale-sum-rubl p-XL-delim
    (if T-parts
    then (
     sj-goods.obj-type + p-XL-delim +
     string(sj-goods.obj-code, "99999") + p-XL-delim +
     (if sj-goods.arch-date = ?
     then "":U
     else string(sj-goods.arch-date, "99/99/9999")) + p-XL-delim
          )
    else "")
    sj-goods.grp-name
    SKIP(0).
    {&PutExcel}
    sj-goods.prod-type {&tabulation}
    sj-goods.prod-code {&tabulation}
    REPLACE(v-producer, " ", "_") {&tabulation}
    ({&delim-par} + sj-goods.artic)  {&tabulation}
    sj-goods.b-code {&tabulation}
    sj-goods.gds-name {&tabulation}
    sj-goods.unit {&tabulation}
    (if T-sostav
     then (sj-goods.struct + {&tabulation})
     else "")
    sj-goods.VAT-pc {&tabulation}
    sj-goods.SLT-pc {&tabulation}
    (IF T-supp then
    (sj-goods.SUPP-type + {&tabulation} +
    string(sj-goods.SUPP-code) + {&tabulation} +
    REPLACE(v-SUPPLIER, " ", "_") + {&tabulation}
    )
    ELSE "")
    (IF T-cons then
    ({&purchase-codes-name} + {&tabulation})
    ELSE "")
    (IF T-cons or T-parts
    then
    (if available buf_pay-type
    then (buf_pay-type.obj-name + {&tabulation})
    else {&tabulation})
    ELSE "":U
    )
    sj-goods.VAT-supp {&tabulation}
    sj-goods.SLT-supp {&tabulation}
    (if T-GTD
     then (sj-goods.cst-code + {&tabulation})
     else "":U
     )
     (if T-parts
     then (
           (if sj-goods.uchet-price-base <> ?
            then string(sj-goods.uchet-price-base)
            else "":U)  +  {&tabulation} +
           (if sj-goods.uchet-price-rubl <> ?
            then string(sj-goods.uchet-price-rubl)
            else "":U)  +  {&tabulation} +
            (if sj-goods.in-code <> ?
            then sj-goods.in-code
            else "":U) + {&tabulation} +
           (if sj-goods.fact-date = ?
            then "":U
            else string(sj-goods.fact-date, "99/99/9999")) + {&tabulation}
           )
     else ""
     )
    sj-goods.qnty {&tabulation}
    sj-goods.uchet-sum-base {&tabulation}
    sj-goods.uchet-sum-base-without-tax  {&tabulation}
    sj-goods.uchet-sum-rubl {&tabulation}
    sj-goods.uchet-sum-rubl-without-tax {&tabulation}
    sj-goods.sale-sum-base {&tabulation}
    sj-goods.sale-sum-rubl {&tabulation}
    (if T-parts
     then
     (sj-goods.obj-type + {&tabulation} +
     string(sj-goods.obj-code, "99999") + {&tabulation} +
      (if sj-goods.arch-date = ?
      then '':U
      else string(sj-goods.arch-date, "99/99/9999")) + {&tabulation})
     else ""
    ) {&tabulation}
    sj-goods.grp-name
    SKIP(0).



/*зарезервировано на будущее*/
/*
    IF T-supp then
    FIND FIRST d-slt-vat WHERE d-slt-vat.vat-pc = sj-goods.vat-pc AND
                                                    d-slt-vat.slt-pc = sj-goods.slt-pc AND
                                                    d-slt-vat.VAT-supp = sj-goods.VAT-supp AND
                                                    d-slt-vat.supp-type = sj-goods.supp-type AND
                                                    d-slt-vat.supp-code = sj-goods.supp-code AND
                                                    d-slt-vat.purch-code = sj-goods.purch-code AND
                                                    d-slt-vat.pay-code = sj-goods.pay-code
                                                    No-ERROR.
    ELSE
    FIND FIRST d-slt-vat WHERE d-slt-vat.vat-pc = sj-goods.vat-pc AND
                                                    d-slt-vat.slt-pc = sj-goods.slt-pc AND
                                                    d-slt-vat.VAT-supp = sj-goods.VAT-supp AND
                                                    d-slt-vat.purch-code = sj-goods.purch-code AND
                                                    d-slt-vat.pay-code = sj-goods.pay-code
                                                    No-ERROR.
    IF NOT AVAILABLE(d-slt-vat) then do:
        create d-slt-vat.
        assign
        d-slt-vat.vat-pc = sj-goods.vat-pc
        d-slt-vat.slt-pc = sj-goods.slt-pc
        d-slt-vat.VAT-supp = sj-goods.VAT-supp
        d-slt-vat.supp-type = (IF T-supp then sj-goods.supp-type esle "")
        d-slt-vat.supp-code = (IF T-supp then sj-goods.supp-code esle 0)
        d-slt-vat.purch-code = sj-goods.purch-code
        d-slt-vat.pay-code = sj-goods.pay-code
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
if Print-List-hist
and rs-method = "LIST" then do:
  run lhistprex-print-doc-list-hist-excel  in this-procedure (input yes, input yes, 2).
end.
output stream PrnLibStream CLOSE .
{&CloseExcel}
assign
sheetf.colformat = sheetf.colformat + {&delim-par} + "4=@"
.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 11
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
DEFINE VARIABLE vnum-t-cons as integer no-undo .
DEFINE VARIABLE vnum-t-parts as integer no-undo .
DEFINE VARIABLE vnum-t-supp as integer no-undo .
DEFINE VARIABLE vnum-t-sostav as integer no-undo .
DEFINE VARIABLE vnum-t-GTD as integer no-undo .

assign
frame {&frame-name} RS-method
frame {&frame-name} T-cons
frame {&frame-name} T-parts
frame {&frame-name} T-supp
frame {&frame-name} F-one
frame {&frame-name} T-sostav
frame {&frame-name} T-GTD
frame {&frame-name} T-split
.
for-title = radio-label(string(RS-method), Rs-method:radio-buttons).
Assign
 STR-obj-type = ''
 STR-obj-code = ''
 STR-obj-name = ''
 STR-obj      = ''.
assign
vnum-t-cons = (IF T-cons then (1  + if T-parts then 1 else 0) else 0)
vnum-t-parts = (IF T-parts then 7 else 0)
vnum-t-supp = (IF T-supp then 3 else 0)
vnum-t-sostav = (IF T-sostav then 1 else 0)
vnum-t-gtd = (IF t-gtd then 1 else 0)
sheetf.colformat = (if t-parts
                   then
                   ("4=0;":U + /*это артикул*/
                   string(7 + vnum-T-sostav + 2 + vnum-T-supp + vnum-t-cons + vnum-t-gtd + 2 + 4) + "=dd/mm/yyyy":U + ";":U +
                   string(7 + vnum-T-sostav + 2 + vnum-T-supp + vnum-t-cons + vnum-t-gtd + 2 + 7 + vnum-t-parts) + "=dd/mm/yyyy":U
                   )
                   else "4=0":U)
sheetf.Excel-Column-Lable =
"Тип_производителя" + {&comma-char} +
"Код_производителя" +  {&comma-char} +
"Производитель" +  {&comma-char} +
"Артикул" + {&comma-char} +
"Бар-код" + {&comma-char} +
"Название" + {&comma-char} +
"Ед.изм" + {&comma-char} +
(if T-sostav
then ("Состав_сырья" + {&comma-char})
else "":U) +
"НДС" + {&comma-char} +
"НП" + {&comma-char} +
(IF T-supp then
("Тип_поставщика" + {&comma-char} + "Код_поставщика" + {&comma-char} + "Поставщик" + {&comma-char} )
else "") +
(IF T-cons then
("Консигнационный_товар" + {&comma-char} )
else "")  +
(IF T-cons or T-parts then
("Вид_оплаты" + {&comma-char} )
else "")  +
"НДС_поставщ" + {&comma-char} +
"НП_поставщ" + {&comma-char} +
(IF T-GTD then
("ГТД" + {&comma-char} )
else "")  +
(if T-parts
then ("Учетн.цена_с НДС_НП_баз.вал." + {&comma-char} +
         "Учетн.цена_с НДС_НП_{&abbr_rubli}" + {&comma-char} +
         "N_прих.док-та" + {&comma-char} +
         "Дата_приходного_док-та" + {&comma-char})
else ""
) +
"Реализованное_количество" + {&comma-char} +
"Сумма_учет_цен_баз.вал" + {&comma-char} +
"Сумма_учет_цен_баз.вал_без_НДС_НП" + {&comma-char} +
"Сумма_учет_цен_{&abbr_rubli}" + {&comma-char} +
"Сумма_учет_цен_{&abbr_rubli}_без_НДС_НП" + {&comma-char} +
"Сумма_продаж_цен_баз.вал" + {&comma-char} +
"Сумма_продаж_цен_{&abbr_rubli}" + {&comma-char} +
(if T-parts
then
("Тип_объекта" + {&comma-char} +
"Код_объекта" + {&comma-char} +
"Факт.дата_партии" + {&comma-char})
else "") + {&comma-char} +
"Группа товара"
sheetf.Sizes =
"3" + {&comma-char} +
"9" +  {&comma-char} +
"40" +  {&comma-char} +
"16" + {&comma-char} +
"9" + {&comma-char} +
"45" + {&comma-char} +
"3" + {&comma-char} +
(if T-sostav
then ("50" + {&comma-char})
else "":U) +
"5" + {&comma-char} +
"5" + {&comma-char} +
(IF T-supp then
("3" + {&comma-char} + "9" + {&comma-char} + "40" + {&comma-char} )
else "") +
(IF T-cons then
("12" + {&comma-char} )
else "")  +
(IF T-cons or T-parts then
("12" + {&comma-char} )
else "")  +
"5" + {&comma-char} +
"5" + {&comma-char} +
(IF T-GTD then
("26" + {&comma-char})
else "") +
(if T-parts
then ("15" + {&comma-char} +
         "15" + {&comma-char} +
         "14" + {&comma-char} +
         "10" + {&comma-char})
else ""
) +
"15" + {&comma-char} +
"15" + {&comma-char} +
"15" + {&comma-char} +
"15" + {&comma-char} +
"15" + {&comma-char} +
"15" + {&comma-char} +
"15" + {&comma-char} +
(if T-parts
then
("3" + {&comma-char} +
"9" + {&comma-char} +
"10" + {&comma-char})
else "") + {&comma-char} +
"60"
str2 = " "
.

For each obj-list no-lock:
 Assign
 STR-obj-type = STR-obj-type + obj-list.obj-type + ','
 STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
 STR-obj-name = STR-obj-name + obj-list.obj-name + ','
 STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ',' .
End.
assign
str1 =     (if Rs-method <> "ONE"
                then str1
                else "" )
ReportNAme = "Партии товаров по документам "
ReportHeader =  "Источник расчета: " + for-title +
                            (if Rs-method <> "ONE"
                            then ""
                            else (" " + F-one) ) + {&new-line} +
                            (if T-cons
                             then "Разделять консигнацию и выкуп "
                             else "Не разделять консигнацию и выкуп ") + {&new-line} +
                            (if T-supp
                             then "Указывать поставщика "
                             else "Не указывать поставщика ") + {&new-line} +
                            (if T-parts
                             then "Каждую партию отдельной строкой"
                            else "") + {&new-line} +
                            ( if T-sostav
                              then "Указывать состав сырья"
                              else "":U) + {&new-line} +
                            ( if T-split
                              then "Разделять расход/возврат"
                              else "":U) + {&new-line} +
                            ( if T-GTD
                              then "Указывать ГТД"
                              else "":U)
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