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

Остатки товаров на указанную дату, оприходованных до заданной даты

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

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
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Остатки товаров на указанную дату, оприходованных до заданной даты":U .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/showinf.i      }
{ gbl/cur-time.i     }
{ cmp/r-pril.i   new }
{ cmp/r-page1.i      }
{ gbl/waitfram.i     }
{ trg/factord.i      }
{ trg/partslib.i     }
{ str/trdcalib.i     }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }

define temp-table sj-goods no-undo
    field b-code like bar-code.b-code format "9999999999999"
    field artic     like goods.artic
    field prod-type like goods.prod-type
    field prod-code like goods.prod-code
    field gds-name   like goods.gds-name format "x(30)"
    field engl-name   like goods.engl-name format "x(30)"
    field unit like goods.unit-base
    field qnty              as   decimal
    field uchet-sum-rubl   as decimal /*учетные цены*/
    field uchet-sum-base   as decimal /*учетные цены*/
    field sale-sum-rubl as decimal /*продажные цены*/
    field sale-sum-base as decimal /*продажные цены*/
    field VAT-pc       like doc-line.VAT-pc
    field SLT-pc       like doc-line.SLT-pc
    field VAT-supp      like parts.VAT-pc
    field SLT-supp like parts.SLT-pc
    field prt-root like goods.prt-root
    field is-prt as logical init no /*товар со шкалами*/
    field supp-type like parts.supp-type
    field supp-code like parts.supp-code
    field purch-code as integer
    field pay-code as integer
    field uchet-price-base like parts.price-base
    field uchet-price-rubl like parts.price-base
    field uchet-sum-base-without-tax like parts.price-base
    field uchet-sum-rubl-without-tax like parts.price-base
    field in-code like parts.in-code
    field fact-date like parts.fact-date
    field s-price as decimal
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field cst-code like ub.parts.cst-code
    field nids as character
    field dids as date
    field nsf  as character
    field dsf  as date
    INDEX p1 IS PRIMARY prod-type prod-code artic supp-type supp-code SLT-pc VAT-pc VAT-supp SLT-supp purch-code in-code pay-code

    .
DEFINE TEMP-TABLE d-slt-vat no-undo
              FIELD SLT-pc like doc-line.SLT-pc
              FIELD VAT-pc like doc-line.VAT-pc
              field VAT-supp      like parts.VAT-pc
              field SLT-supp      like parts.VAT-pc
              field uchet-sum-rubl   as decimal /*учетные цены*/
              field uchet-sum-base   as decimal /*учетные цены*/
              field sale-sum-rubl as decimal /*продажные цены*/
              field sale-sum-base as decimal /*продажные цены*/
              field supp-type like parts.supp-type
              field supp-code like parts.supp-code
              field purch-code as integer
              field pay-code as integer
              INDEX p1 IS PRIMARY supp-type supp-code SLT-pc VAT-pc VAT-supp SLT-supp purch-code pay-code ASCENDING .
{ str/in-vatp.i def }

define stream Rest-Stream.

define variable cdate as date no-undo.
define variable sdate as date      no-undo .
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
&Scoped-Define ENABLED-OBJECTS T-cons T-supp T-parts date-calc date-cred
&Scoped-Define DISPLAYED-OBJECTS T-cons T-supp T-parts date-calc date-cred

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE date-calc AS DATE FORMAT "99/99/9999":U
     LABEL "Остатки на"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-cred AS DATE FORMAT "99/99/9999":U
     LABEL "Оприходованы до"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE T-cons AS LOGICAL INITIAL no
     LABEL "Разделять консигнацию и выкуп"
     VIEW-AS TOGGLE-BOX
     SIZE 34.2 BY .91 NO-UNDO.

DEFINE VARIABLE T-parts AS LOGICAL INITIAL no
     LABEL "Каждую партию отдельной строкой"
     VIEW-AS TOGGLE-BOX
     SIZE 33.8 BY .91 NO-UNDO.

DEFINE VARIABLE T-supp AS LOGICAL INITIAL no
     LABEL "Указывать поставщика"
     VIEW-AS TOGGLE-BOX
     SIZE 34.2 BY .86 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     T-cons AT ROW 2.14 COL 2.4
     T-supp AT ROW 3.81 COL 2.4
     T-parts AT ROW 5.76 COL 2.4
     date-calc AT ROW 7.67 COL 19 COLON-ALIGNED
     date-cred AT ROW 9.33 COL 19 COLON-ALIGNED
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 37 BY 14.


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
         HEIGHT             = 14.05
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

&Scoped-define SELF-NAME date-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-calc F-Frame-Win
ON LEAVE OF date-calc IN FRAME F-Main /* Остатки на дату */
DO:
  RUN verify-date.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-cred
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-cred F-Frame-Win
ON LEAVE OF date-cred IN FRAME F-Main /* Оприходованы до */
DO:
  RUN verify-date.
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
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

{ gbl/ed_date.i date-calc }
{ gbl/ed_date.i date-cred }
ASSIGN
    date-calc = TODAY .
    date-cred = TODAY .
.

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
  DISPLAY T-cons T-supp T-parts date-calc date-cred
      WITH FRAME F-Main.
  ENABLE T-cons T-supp T-parts date-calc date-cred
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
define buffer supplier for clients.
define variable ocons-pay like sysconf.purch-code no-undo.
define variable ocons-pay-old like sysconf.purch-code no-undo.

define variable v-vat-pc        like doc-line.vat-pc    no-undo.
define variable v-slt-pc        like doc-line.slt-pc    no-undo.
define variable v-host-code     like sysconf.host-code  no-undo.

DEFINE VARIABLE         v-parts-VAt-pc  like ub.parts-attr.vat-pc           no-undo .
DEFINE VARIABLE         v-parts-SLT-pc  like ub.parts-attr.SLT-pc           no-undo .
DEFINE VARIABLE         v-supp-type     like ub.parts-attr.supp-type        no-undo .
DEFINE VARIABLE         v-supp-code     like ub.parts-attr.supp-code        no-undo .
DEFINE VARIABLE         v-purch-code    like ub.parts-attr.purch-code       no-undo .
DEFINE VARIABLE         v-in-code       like ub.parts-attr.income-in-code   no-undo .
DEFINE VARIABLE         v-fact-date     like ub.parts-attr.fact-date        no-undo .
DEFINE VARIABLE         v-obj-type      like ub.parts.obj-type              no-undo .
DEFINE VARIABLE         v-obj-code      like ub.parts.obj-code              no-undo .
DEFINE VARIABLE         v-is-attr       as logical                          no-undo .
DEFINE VARIABLE         v-supplier      like ub.clients.obj-name            no-undo .
DEFINE VARIABLE         v-producer      like ub.clients.obj-name            no-undo .
define variable         v-pay-code      like ub.parts.pay-code              no-undo .
DEFINE VARIABLE         v-cst-code      like ub.parts.cst-code              no-undo .
define variable v-curr-r-b              as character                        no-undo .
define variable v-nids                  as character                        no-undo .
define variable v-dids                  as date                             no-undo .
define variable v-nsf                   as character                        no-undo .
define variable v-dsf                   as date                             no-undo .
define variable v-trdcattr-type         as character                        no-undo .
define variable v-end-fact-order        as decimal                          no-undo .
define variable v-shift-end-fact-order  as decimal                          no-undo .
define variable v-day-start-fact-order  as decimal                          no-undo .
define variable p-XL-delim              as character                        no-undo .
define variable type-par1               as character                        no-undo .
define variable tmp-var1                as character                        no-undo .
define variable g#report-num            as integer                          no-undo .

define buffer buf_parts-attr  for ub.parts-attr.
define buffer buf_pay-type    for ub.pay-type.
define buffer buf_trn-doc     for ub.trn-doc.
define buffer buf_temp-parts  for temp-parts.


run get-report-num in my-handle (output g#report-num).
{ gbl/getcntxt.i get " " my-handle }

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

{ gbl/curr-r-b.i
  v-curr-r-b
}

assign
frame {&frame-name} T-cons
frame {&frame-name} T-supp
frame {&frame-name} T-parts
frame {&frame-name} date-calc
frame {&frame-name} date-cred
cdate = date-cred
sdate = date-calc
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
      FIND FIRST shop NO-LOCK WHERE shop.obj-code = obj-list.obj-code no-error.
      FIND FIRST Sysconf No-LOCK WHERE sysconf.host-code = shop.host-code No-ERROR.
      assign
      odoc-prt = shop.doc-prt
      ocons-pay = integer({&consignation-code})
      ocons-pay-old = integer({&old-consignation-code})
      .
  end.
  else do:
      FIND FIRST store NO-LOCK WHERE store.obj-code = obj-list.obj-code no-error.
      FIND FIRST Sysconf No-LOCK WHERE sysconf.host-code = store.host-code No-ERROR.
      assign
      odoc-prt = store.doc-prt
      ocons-pay = integer({&consignation-code})
      ocons-pay-old = integer({&old-consignation-code})
      .
  end.
  run factord in this-procedure
      (input  sdate                   /* p-fact-date            */
      ,input  1                       /* p-fact-time            */
      ,input  1                       /* p-fact-num             */
      ,input  ?                       /* p-shift-date           */
      ,input  0                       /* p-shift-num            */
      ,input  false                   /* p-shift-on             */
      ,output v-end-fact-order        /* p-fact-order           */
      ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
      ,output v-day-start-fact-order    /* p-day-end-fact-order   */
      ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  FOR each gds-obj NO-LOCk WHERE
          gds-obj.obj-type = obj-list.obj-type AND
          gds-obj.obj-code = obj-list.obj-code :
    ACCUMULATE gds-obj.artic (COUNT).
    IF (ACCUM COUNT gds-obj.artic ) MODULO 50  = 0 then do:
        run waitfram-show in this-procedure ("Обработано " + string(ACCUM COUNT gds-obj.artic) + " товаров на объекте " ).
    end.
    run partslib-init-temp-parts-by-factord in this-procedure(
                                                          input gds-obj.obj-type,
                                                          input gds-obj.obj-code,
                                                          input gds-obj.artic,
                                                          input gds-obj.prod-type,
                                                          input gds-obj.prod-code,
                                                          input v-day-start-fact-order,
                                                          input false
                                                          ) .
    FOR EACH buf_temp-parts NO-LOCK WHERE
            buf_temp-parts.artic = gds-obj.artic AND
            buf_temp-parts.prod-type = gds-obj.prod-type AND
            buf_temp-parts.prod-code = gds-obj.prod-code AND
            buf_temp-parts.obj-type = gds-obj.obj-type AND
            buf_temp-parts.obj-code = gds-obj.obj-code
                                            :
      FIND FIRST buf_parts-attr No-LOCK WHERE
                 buf_parts-attr.in-code = buf_temp-parts.in-code
             AND buf_parts-attr.gds-code = gds-obj.gds-code
             AND buf_parts-attr.part-code = buf_temp-parts.part-code
                 No-ERROR.
      find first buf_trn-doc no-lock where
                   buf_trn-doc.doc-code = buf_temp-parts.in-code no-error .


      if available buf_trn-doc and buf_trn-doc.fact-date <= cdate then do:
          /* если нашли документ, читаем его атрибуты */
          { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-nids v-trdcattr-type no-error }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры tdat-val":U skip
              "Документ: " buf_trn-doc.doc-code skip
              "Атрибут: " {&trdcattr-nids} skip
              "Значение: " v-nids skip
              trim( error-status :get-message (1) ) skip
              return-value skip
              view-as alert-box error.
            undo, return error return-value.
          end.
          { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dids} v-dids v-trdcattr-type no-error }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры tdat-val":U skip
              "Документ: " buf_trn-doc.doc-code skip
              "Атрибут: " {&trdcattr-dids} skip
              "Значение: " v-dids skip
              trim( error-status :get-message (1) ) skip
              return-value skip
              view-as alert-box error.
            undo, return error return-value.
          end.
          { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nsf} v-nsf v-trdcattr-type no-error }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры tdat-val":U skip
              "Документ: " buf_trn-doc.doc-code skip
              "Атрибут: " {&trdcattr-nsf} skip
              "Значение: " v-nsf skip
              trim( error-status :get-message (1) ) skip
              return-value skip
              view-as alert-box error.
            undo, return error return-value.
          end.
          { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-dsf} v-dsf v-trdcattr-type no-error }
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры tdat-val":U skip
              "Документ: " buf_trn-doc.doc-code skip
              "Атрибут: " {&trdcattr-dsf} skip
              "Значение: " v-dsf skip
              trim( error-status :get-message (1) ) skip
              return-value skip
              view-as alert-box error.
            undo, return error return-value.
          end.
      end. /* available buf_trn-doc and buf_trn-doc.fact-date <= cdate */
      else do:
          assign
            v-dids  = ?
            v-nids  = ?
            v-dsf   = ?
            v-nsf   = ?
          .
      end.

      IF AVAILABLE buf_parts-attr then do:
        if buf_parts-attr.fact-date > cdate then NEXT.
        assign
          v-is-attr       = yes
          v-parts-VAt-pc  = buf_parts-attr.vat-pc
          v-parts-SLT-pc  = buf_parts-attr.SLT-pc
          v-supp-type     = buf_parts-attr.supp-type
          v-supp-code     = buf_parts-attr.supp-code
          v-purch-code    = buf_parts-attr.purch-code
          v-pay-code      = buf_parts-attr.pay-code
          v-in-code       = buf_parts-attr.income-in-code
          v-fact-date     = buf_parts-attr.fact-date
          v-obj-type      = buf_temp-parts.obj-type
          v-obj-code      = buf_temp-parts.obj-code
          v-cst-code      = buf_parts-attr.cst-code
        .
      end.
      else do:
        assign
          v-is-attr = no
        .
        if available buf_trn-doc and buf_trn-doc.fact-date > cdate then NEXT.
        /*скорее всего если мы здесь значит партия не преобразовывалась и ее можно по старому обрабатывать*/
        assign
          v-parts-VAt-pc  = buf_temp-parts.vat-pc
          v-parts-SLT-pc  = buf_temp-parts.SLT-pc
          v-supp-type     = buf_temp-parts.supp-type
          v-supp-code     = buf_temp-parts.supp-code
          v-purch-code    = buf_temp-parts.purch-code
          v-pay-code      = buf_temp-parts.pay-code
          v-in-code       = buf_temp-parts.in-code
          v-fact-date     = (if available buf_trn-doc then buf_trn-doc.fact-date else ?)
          v-obj-type      = buf_temp-parts.obj-type
          v-obj-code      = buf_temp-parts.obj-code
          v-cst-code      = buf_temp-parts.cst-code
        .
      end.
      IF NOT T-parts then do:
        IF T-supp then
        FIND FIRST sj-goods WHERE
                  sj-goods.artic = gds-obj.artic AND
                  sj-goods.prod-type = gds-obj.prod-type AND
                  sj-goods.prod-code = gds-obj.prod-code AND
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
                  sj-goods.artic = gds-obj.artic AND
                  sj-goods.prod-type = gds-obj.prod-type AND
                  sj-goods.prod-code = gds-obj.prod-code AND
                  sj-goods.VAT-supp = v-parts-VAT-pc AND
                  sj-goods.SLT-supp = v-parts-SLT-pc AND
                  (NOT T-cons OR
                  (sj-goods.purch-code = v-purch-code
                   AND
                  sj-goods.pay-code = v-pay-code))
                  No-error.
      END.
      if not avail sj-goods or T-parts then do:
        FIND FIRST goods No-LOCK WHERE
                    goods.gds-code = gds-obj.gds-code  NO-ERROR.
        FIND FIRST gds-prt where
                    gds-prt.upper-code = goods.prt-root NO-LOCK .
        FIND FIRST bar-code No-LOCK WHERE
                    bar-code.gds-code = gds-obj.gds-code AND
                    bar-code.in-code = "" AND
                    bar-code.part-code = "" AND
                    bar-code.node-code =  gds-prt.node-code  AND
                    bar-code.unit-cli = goods.unit-base NO-ERROR.
        create sj-goods.
        { gbl/hostcode.i gds-obj.obj-type gds-obj.obj-code v-host-code }
        { gbl/pftxvalg.i goods.gds-code {&vat-tax-code} ? v-host-code gds-obj.obj-type gds-obj.obj-code v-vat-pc no-error }
        { gbl/pftxvalg.i goods.gds-code {&slt-tax-code} ? v-host-code gds-obj.obj-type gds-obj.obj-code v-slt-pc no-error }
        assign
        sj-goods.artic      = goods.artic
        sj-goods.b-code     = bar-code.b-code
        sj-goods.prod-type  = goods.prod-type
        sj-goods.prod-code  = goods.prod-code
        sj-goods.VAT-PC     = v-vat-pc
        sj-goods.SLT-pc     = v-slt-pc
        sj-goods.unit       = goods.unit-base
        sj-goods.is-prt     = gds-prt.node-name <> {&empty-scale}
        sj-goods.prt-root   = goods.prt-root
        sj-goods.gds-name   = REPLACE(goods.gds-name, " ", "_")
        sj-goods.engl-name  = REPLACE(goods.engl-name, " ", "_")
        sj-goods.VAT-supp   = v-parts-VAT-pc
        sj-goods.SLT-supp   = v-parts-SLT-pc
        sj-goods.supp-type  = IF T-supp OR T-parts then v-supp-type else ""
        sj-goods.supp-code  = IF T-supp OR T-parts then v-supp-code else 0
        sj-goods.purch-code = IF T-cons or T-parts
                                then v-purch-code
                                else 0
        sj-goods.pay-code   = IF T-cons or T-parts
                                then v-pay-code
                                else 0
        sj-goods.in-code    = if T-parts then v-in-code else ""
        sj-goods.fact-date  = if T-parts then v-fact-date else ?
        sj-goods.obj-type   = if T-parts then v-obj-type else "":U
        sj-goods.obj-code   = if T-parts then v-obj-code else 0
        sj-goods.cst-code   = if T-parts then v-cst-code else "":U
        sj-goods.nids       = v-nids
        sj-goods.dids       = v-dids
        sj-goods.nsf        = v-nsf
        sj-goods.dsf        = v-dsf
        /*надо найти общую сумму продажных цен на товар на объекте, а потом размазать по партиям*/
        sj-goods.s-price    = gds-obj.fact-sale / gds-obj.fact-qnty
        .
        if sj-goods.s-price = ? then do:
          assign
            sj-goods.s-price = 0
          .
        end.
      END. /*if not avail sj-goods*/
      { str/in-vatp.i calc-parts buf_temp-parts. " " g }
      assign
      prt-qnty =  (IF buf_temp-parts.out-code = {&free-code}
                   then
                   buf_temp-parts.qnty
                   else abs(buf_temp-parts.qnty))
      sj-goods.qnty = sj-goods.qnty +  prt-qnty
      sj-goods.sale-sum-rubl = if v-curr-r-b = {&r-b-base}
                               then sj-goods.sale-sum-rubl
                               else (sj-goods.sale-sum-rubl + sj-goods.s-price * prt-qnty)
      sj-goods.sale-sum-base = if v-curr-r-b = {&r-b-base}
                               then (sj-goods.sale-sum-base + sj-goods.s-price * prt-qnty)
                               else sj-goods.sale-sum-base
      sj-goods.uchet-price-base = if T-parts then buf_temp-parts.price-base else 0
      sj-goods.uchet-price-rubl = if T-parts then buf_temp-parts.price-rubl else 0
      sj-goods.uchet-sum-base = sj-goods.uchet-sum-base + buf_temp-parts.price-base * prt-qnty
      sj-goods.uchet-sum-rubl = sj-goods.uchet-sum-rubl + buf_temp-parts.price-rubl * prt-qnty
      sj-goods.uchet-sum-base-without-tax = sj-goods.uchet-sum-base-without-tax +
                                           (price-base-with-tax-loc - slt-base-loc - vat-base-loc) * prt-qnty
      sj-goods.uchet-sum-rubl-without-tax = sj-goods.uchet-sum-rubl-without-tax +
                                           (price-rubl-with-tax-loc  - slt-rubl-loc - vat-rubl-loc) * prt-qnty
      .
    END. /*FOR EACH parts*/
  END. /*FOR EACH gds-obj*/
END. /*FOR EACH obj-list*/
run waitfram-hide in this-procedure.

{ cmp/open-exp.i stream Rest-Stream " " }
  assign
    sheetf.Excel-Column-Lable =
    "Тип производителя" + {&comma-char} +
    "Код производителя" + {&comma-char} +
    "Производитель"     + {&comma-char} +
    "Артикул"           + {&comma-char} +
    "Бар-код"           + {&comma-char} +
    "Название"          + {&comma-char} +
    "Англ.название"     + {&comma-char} +
    "Ед.изм"            + {&comma-char} +
    "НДС"               + {&comma-char} +
    "НП"                + {&comma-char} +
    (
      IF T-supp then
      (
        "Тип поставщика" + {&comma-char} +
        "Код поставщика" + {&comma-char} +
        "Поставщик" + {&comma-char}
      )
      else ""
    )
    +
    (
      IF T-cons then
      (
        "Консигнационный товар" + {&comma-char}
      )
      else ""
    )
    +
    (
      IF T-cons or T-parts then
      (
        "Тип оплаты" + {&comma-char}
      )
      else "":U
    )
    +
    "НДС поставщ" + {&comma-char} +
    "НП поставщ"  + {&comma-char} +
    (
      if T-parts then
      (
        "Тип объекта"                       + {&comma-char} +
        "Код объекта"                       + {&comma-char} +
        "Учетн.цена с НДС НП баз.вал."      + {&comma-char} +
        "Учетн.цена с НДС НП {&abbr_rubli}" + {&comma-char} +
        "N прих.док-та"                     + {&comma-char} +
        "Факт дата"                         + {&comma-char} +
        "ГТД"                               + {&comma-char}
      )
      else ""
    )
    +
    "Номер приходной накладной поставщика"    + {&comma-char} +
    "Дата приходной накладной поставщика"     + {&comma-char} +
    "Номер счета-фактуры поставщика"          + {&comma-char} +
    "Дата счета-фактуры поставщика"           + {&comma-char} +
    "Остаток"                                 + {&comma-char} +
    "Сумма учет цен баз.вал"                  + {&comma-char} +
    "Сумма учет цен баз.вал без НДС НП"       + {&comma-char} +
    "Сумма учет цен {&abbr_rubli}"            + {&comma-char} +
    "Сумма учет цен {&abbr_rubli} без НДС НП" + {&comma-char} +
    string( if v-curr-r-b = {&r-b-base} then "Сумма продаж цен баз.вал" else "Сумма продаж цен {&abbr_rubli}" )
    sheetf.sizes =
    "18" + {&comma-char} +
    "18" + {&comma-char} +
    "20" + {&comma-char} +
    "10" + {&comma-char} +
    "10" + {&comma-char} +
    "40" + {&comma-char} +
    "40" + {&comma-char} +
    "10" + {&comma-char} +
    "10" + {&comma-char} +
    "10" + {&comma-char} +
    (
      IF T-supp then
      (
        "14" + {&comma-char} +
        "14" + {&comma-char} +
        "14" + {&comma-char}
      )
      else ""
    )
    +
    (
      IF T-cons then
      (
        "18" + {&comma-char}
      )
      else ""
    )
    +
    (
      IF T-cons or T-parts then
      (
        "10" + {&comma-char}
      )
      else "":U
    )
    +
    "10" + {&comma-char} +
    "10"  + {&comma-char} +
    (
      if T-parts then
      (
        "10" + {&comma-char} +
        "10" + {&comma-char} +
        "12" + {&comma-char} +
        "12" + {&comma-char} +
        "16" + {&comma-char} +
        "12" + {&comma-char} +
        "10" + {&comma-char}
      )
      else ""
    )
    +
    "16" + {&comma-char} +
    "16" + {&comma-char} +
    "16" + {&comma-char} +
    "16" + {&comma-char} +
    "16" + {&comma-char} +
    "18" + {&comma-char} +
    "18" + {&comma-char} +
    "18" + {&comma-char} +
    "18" + {&comma-char} +
    "18" + {&comma-char}
    Sheetf.colformat = "1=@;2=@;3=@;4=@;5=@;6=@;7=@;8=@;9=@;10=@;11=@;12=@;13=@;14=@;15=@;16=@;17=@;18=@;19=@;20=@;21=@;22=@;23=@;24=@;25=@;26=@;27=@;28=@;29=@;30=@;31=@;32=@;"
  .
  run rep/extitle.p (1).

run waitfram-show in this-procedure ("Ждите...").
PUT stream Rest-Stream UNFORMATTED
    "Остатки на " + string(sdate, "99/99/9999") + " по товарам, оприходованным до " +
    string( cdate, "99/99/9999" ) + "."      format "x(110)" SKIP(1).
PUT stream Rest-Stream UNFORMATTED ReportHeader skip.
PUT stream Rest-Stream string("По объектам: "  )
        format "X(20)" SKIP.

FOR EACH obj-list :
    FIND FIRST clients WHERE clients.obj-type = obj-list.obj-type AND
                                      clients.obj-code = obj-list.obj-code NO-LOCK .
    PUT stream Rest-Stream UNFORMATTED clients.obj-name  ", ".
END.

PUT stream Rest-Stream UNFORMATTED
        SKIP
        cur-time-print() SKIP.


PUT stream Rest-Stream " " SKIP(1) .
PUT stream Rest-Stream UNFORMATTED
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
      "ГТД" + p-XL-DELIM
     )
else ""
)
"Номер приходной накладной поставщика" p-XL-delim
"Дата приходной накладной поставщика" p-XL-delim
"Номер счета-фактуры поставщика" p-XL-delim
"Дата счета-фактуры поставщика" p-XL-delim
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

    accumulate
      sj-goods.uchet-price-base (TOTAL)
      sj-goods.uchet-price-rubl (TOTAL)
      sj-goods.qnty (TOTAL)
      sj-goods.uchet-sum-base (TOTAL)
      sj-goods.uchet-sum-base-without-tax (TOTAL)
      sj-goods.uchet-sum-rubl (TOTAL)
      sj-goods.uchet-sum-rubl-without-tax (TOTAL)
      sj-goods.sale-sum-base (TOTAL)
      sj-goods.sale-sum-rubl (TOTAL)
    .
    PUT stream Rest-Stream UNFORMATTED
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
      sj-goods.cst-code + p-XL-DELIM
    )
     else ""
     )
    (if sj-goods.nids  = ? or sj-goods.nids = "" then " " else sj-goods.nids) p-XL-delim
    (if sj-goods.dids  = ? then " " else string(sj-goods.dids, "99/99/9999")) p-XL-delim
    (if sj-goods.nsf   = ? or sj-goods.nsf = "" then " " else sj-goods.nsf ) p-XL-delim
    (if sj-goods.dsf   = ? then " " else string(sj-goods.dsf, "99/99/9999")) p-XL-delim
    sj-goods.qnty p-XL-delim
    sj-goods.uchet-sum-base p-XL-delim
    sj-goods.uchet-sum-base-without-tax  p-XL-delim
    sj-goods.uchet-sum-rubl p-XL-delim
    sj-goods.uchet-sum-rubl-without-tax p-XL-delim
    (if v-curr-r-b = {&r-b-base}
     then sj-goods.sale-sum-base
     else sj-goods.sale-sum-rubl)   p-XL-delim
    SKIP(0).
    {&PutExcel}
      sj-goods.prod-type            {&tabulation}
      sj-goods.prod-code            {&tabulation}
      REPLACE(v-producer, " ", "_") {&tabulation}
      sj-goods.artic                {&tabulation}
      sj-goods.b-code               {&tabulation}
      sj-goods.gds-name             {&tabulation}
      sj-goods.engl-name            {&tabulation}
      sj-goods.unit                 {&tabulation}
      sj-goods.VAT-pc               {&tabulation}
      sj-goods.SLT-pc               {&tabulation}
      if T-supp then string
      (
        sj-goods.SUPP-type + {&tabulation} +
        string(sj-goods.SUPP-code) + {&tabulation} +
        replace(v-supplier, " ", "_") + {&tabulation}
      )
      else ""
      IF T-cons then string
      (
          {&purchase-codes-name} + {&tabulation}
      )
      ELSE ""
      IF T-cons or T-parts then string
      (
          if available buf_pay-type
          then (buf_pay-type.obj-name + {&tabulation})
          else (" ":U + {&tabulation})
      )
      ELSE "":U
      sj-goods.VAT-supp {&tabulation}
      sj-goods.SLT-supp {&tabulation}

      (
        if T-parts then
        (
          sj-goods.obj-type                 + {&tabulation} +
          string(sj-goods.obj-code)         + {&tabulation} +
          string(sj-goods.uchet-price-base) + {&tabulation} +
          string(sj-goods.uchet-price-rubl) + {&tabulation} +
          sj-goods.in-code                  + {&tabulation} +
          (if sj-goods.fact-date = ? then "?" else string(sj-goods.fact-date, "99/99/9999")) + {&tabulation} +
          sj-goods.cst-code                 + {&tabulation}
        )
        else ("")
      )
      (if sj-goods.nids  = ? or sj-goods.nids = "" then " " else sj-goods.nids)  {&tabulation}
      (if sj-goods.dids  = ? then " " else string(sj-goods.dids, "99/99/9999"))  {&tabulation}
      (if sj-goods.nsf   = ? or sj-goods.nsf = "" then " " else sj-goods.nsf )   {&tabulation}
      (if sj-goods.dsf   = ? then " " else string(sj-goods.dsf, "99/99/9999"))   {&tabulation}
      sj-goods.qnty                                                              {&tabulation}
      sj-goods.uchet-sum-base                                                    {&tabulation}
      sj-goods.uchet-sum-base-without-tax                                        {&tabulation}
      sj-goods.uchet-sum-rubl                                                    {&tabulation}
      sj-goods.uchet-sum-rubl-without-tax                                        {&tabulation}
      (if v-curr-r-b = {&r-b-base} then sj-goods.sale-sum-base else sj-goods.sale-sum-rubl)
    SKIP.

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
    {&PutExcel}
      skip(1)
      " ИТОГО:"            {&tabulation}
      " "            {&tabulation}
      " "             {&tabulation}
      " "                {&tabulation}
      " "               {&tabulation}
      " "             {&tabulation}
      " "            {&tabulation}
      " "                 {&tabulation}
      " "               {&tabulation}
      " "               {&tabulation}
      if T-supp then string
      (
        " " + {&tabulation} +
        " " + {&tabulation} +
        " " + {&tabulation}
      )
      else ""
      IF T-cons then string
      (
          " " + {&tabulation}
      )
      ELSE ""
      IF T-cons or T-parts then string
      (
          " ":U + {&tabulation}
      )
      ELSE "":U
      " " {&tabulation}
      " " {&tabulation}

      (
        if T-parts then
        (
          " "                 + {&tabulation} +
          " "         + {&tabulation} +
          string( accum TOTAL sj-goods.uchet-price-base ) + {&tabulation} +
          string( accum TOTAL sj-goods.uchet-price-rubl) + {&tabulation} +
          " "                  + {&tabulation} +
          " " + {&tabulation} +
          " "                 + {&tabulation}
        )
        else ("")
      )
      " "  {&tabulation}
      " "  {&tabulation}
      " "   {&tabulation}
      " "   {&tabulation}
      accum TOTAL sj-goods.qnty                                                              {&tabulation}
      accum TOTAL sj-goods.uchet-sum-base                                                    {&tabulation}
      accum TOTAL sj-goods.uchet-sum-base-without-tax                                        {&tabulation}
      accum TOTAL sj-goods.uchet-sum-rubl                                                    {&tabulation}
      accum TOTAL sj-goods.uchet-sum-rubl-without-tax                                        {&tabulation}
      (if v-curr-r-b = {&r-b-base} then accum TOTAL sj-goods.sale-sum-base else accum TOTAL sj-goods.sale-sum-rubl)
    SKIP.
output stream Rest-Stream CLOSE .
run waitfram-hide in this-procedure .
{&CloseExcel}
run rep/runexcel.p
        (
        input string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
        ) no-error .
if error-status :error then do:
        if session :set-wait-state("") then .
end.
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
frame {&frame-name} date-calc
frame {&frame-name} date-cred
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
ReportNAme = "Остатки на " + string( date-calc , "99/99/9999" ) + " по товарам, оприходованным до " + string( date-cred , "99/99/9999" ).
ReportHeader = (if T-cons
                then "Разделять консигнацию и выкуп "
                else "Не разделять консигнацию и выкуп ") + {&new-line} +
               (if T-supp
                then "Указывать поставщика "
                else "Не указывать поставщика ") + {&new-line} +
               (if T-parts
                then "Каждую партию отдельной строкой" + {&new-line}
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
define input parameter        c     like ub.gds-prt.node-code no-undo.
define       parameter buffer b-g-p for  ub.gds-prt.

define buffer b-gds-prt for ub.gds-prt.

define variable no-nodes as logical initial yes.

if odoc-prt = yes then /* есть разбиение по признакам */
    FOR EACH b-gds-prt where b-gds-prt.upper-code = c  NO-LOCK:
        no-nodes = no.
        RUN tree-prt( b-gds-prt.node-code, buffer b-gds-prt ).
    END .  /*  for each b-gds-prt  */

if no-nodes = yes then do: /* терминальный узел или нет разбиения по признакам */
   FIND FIRST prt-obj No-LOCK WHERE
              prt-obj.artic = gds-obj.artic AND
            prt-obj.prod-type = gds-obj.prod-type AND
            prt-obj.prod-code = gds-obj.prod-code AND
            prt-obj.prt-code = b-g-p.node-code No-ERROR.
  sale-stoim = sale-stoim  + prt-obj.fact-qnty * prt-obj.price-sale.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-date F-Frame-Win
PROCEDURE verify-date :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
IF DATE(date-cred:SCREEN-VALUE IN FRAME {&FRAME-NAME}) > DATE(date-calc:SCREEN-VALUE IN FRAME {&FRAME-NAME}) THEN DO:
    BELL.
    message "Интервал дат введен неверно !" view-as alert-box error TITLE "О Ш И Б К А !!!".
    Return error.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME