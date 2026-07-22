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

РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/24/05
Author: Bakhtadze Natalya
Creation date: 10/24/05

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
define variable vss-description as character no-undo init "Отчет о налогах в магазине" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ cmp/library.i  }
{ str/out-vatp.i def }
{ cmp/operlist.i }
{ cmp/breakstr.i }
{ str/lib-calc.i }
{ str/clcprtsl.i }
{ gbl/waitfram.i }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
def temp-table sj-goods no-undo
field b-code like bar-code.b-code format "9999999999999"
field artic     like goods.artic
field prod-type like goods.prod-type
field prod-code like goods.prod-code
field name   like goods.gds-name format "x(30)"
field unit like goods.unit-base
field qnty              as   decimal
field obj-price    like price-list.price-sale
field discnt          as   decimal
field brutto-sum   as   decimal
field discnt-sum  as   decimal
field netto-sum    as   decimal
field uchet-sum   as decimal /*учетные цены*/
field uchet-with-vat-sum   as decimal /*учетные цены*/
field n-u-sum             as   decimal
field u-pcnt          as decimal /*% торговой наценки*/
field is-out        as  logical
field VAT-pc       like doc-line.VAT-pc
field SLT-pc       like doc-line.SLT-pc
field VAT-r-b    as decimal /*сумма НДС*/
field SLT-r-b   as decimal /*сумма налога с продаж */
field grp-code as integer
field grp-name as character
INDEX p1 IS PRIMARY   b-code SLT-pc VAT-pc
INDEX p2                        is-out DESCENDING
                                        b-code ASCENDING
INDEX p3 artic prod-type prod-code SLT-pc VAT-pc
index p4 grp-name
.

DEFINE temp-table sj-grp no-undo
field grp-code AS integer format "9999999999999"
field grp-name   AS character format "x(30)"
field serv-name   AS character format "x(30)"
field qnty              as   decimal
field brutto-sum   as   decimal
field discnt-sum  as   decimal
field netto-sum    as   decimal
field uchet-sum   as decimal /*учетные цены*/
field uchet-with-vat-sum   as decimal /*учетные цены*/
field n-u-sum             as   decimal
field u-pcnt          as decimal /*% торговой наценки*/
field VAT-r-b    as decimal /*сумма НДС*/
field SLT-r-b   as decimal /*сумма налога с продаж */
INDEX p1 IS PRIMARY   grp-code
INDEX p3 grp-name
index p4 serv-name
.
define buffer t-3 for sj-grp.
{ rep/r-shftgr.i }

DEFINE TEMP-TABLE d-slt-vat no-undo
FIELD SLT-pc like doc-line.SLT-pc
FIELD SLT-r-b like inkas.netto /*сумма налога с продаж*/
FIELD SLT-r-b-brutto like inkas.netto /*сумма товаров с таким налогом  с продаж*/
FIELD VAT-pc like doc-line.VAT-pc
FIELD VAT-r-b like inkas.netto
FIELD uchet-sum as decimal
FIELD uchet-with-vat-sum as decimal
FIELD n-u-sum             as   decimal
INDEX p1 IS PRIMARY SLT-pc VAT-pc ASCENDING .
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
define buffer t-doc for trn-doc.
define variable jj as integer no-undo.
define variable jj-tot as integer no-undo init 0.
define variable for-netto-without-slt as decimal no-undo.
define variable vat-pc-val-qnty as integer no-undo.
define variable v-choice-gds as char no-undo.
define variable gds-str as character no-undo init "".
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
&Scoped-Define ENABLED-OBJECTS RECT-6 RECT-8 RECT-7 Classify RS-Method ~
RS-By T-neg
&Scoped-Define DISPLAYED-OBJECTS Classify RS-Method RS-By T-neg

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE var-level AS INTEGER FORMAT ">>9":U INITIAL 1
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY .77
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE Classify AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Нет подитогов по группам", "no-grp-totals":U,
"Группы 1-го уровня", "no-classify":U,
"Группы с n-уровнeм вложенности", "n-level":U,
"Терминальные группы", "t-level":U
     SIZE 33 BY 3.43
     FGCOLOR 0  NO-UNDO.

DEFINE VARIABLE RS-By AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Отчеты о продаже (касса)", 1,
"Расх. и возвр. накладные по реализации", 2,
"Отчеты о продаже и накладные", 3,
"Отчет по всем расходным документам", 4

     SIZE 41.5 BY 2.77 NO-UNDO.

DEFINE VARIABLE RS-Method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Cо шкалами ", "B-CODE":U,
"Без шкал  ", "ARTIC":U,
"Без товаров", "TOTALS":U
     SIZE 22.6 BY 3.13 NO-UNDO.

DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.7 BY 4.83.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.7 BY 3.93.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.7 BY 4.5.

DEFINE VARIABLE T-neg AS LOGICAL INITIAL no
     LABEL "Отрицательную наценку считать = 0"
     VIEW-AS TOGGLE-BOX
     SIZE 37.8 BY 1.03 NO-UNDO.

DEFINE VARIABLE T-partsneg AS LOGICAL INITIAL no
     LABEL "Учитывать только порожденные партии"
     VIEW-AS TOGGLE-BOX
     SIZE 37.8 BY 1.03 NO-UNDO.

DEFINE VARIABLE Tog-level AS LOGICAL INITIAL no
     LABEL "с уровня":L
     VIEW-AS TOGGLE-BOX
     SIZE 12.6 BY .77
     FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     Classify AT ROW 2.07 COL 46.5 NO-LABEL WIDGET-ID 2
     RS-Method AT ROW 2.57 COL 7 NO-LABEL
     Tog-level AT ROW 3.8 COL 80 WIDGET-ID 8
     var-level AT ROW 4.67 COL 78 COLON-ALIGNED NO-LABEL WIDGET-ID 10
     RS-By AT ROW 7.77 COL 3.5 NO-LABEL
     T-neg AT ROW 12.2 COL 5
     T-partsneg AT ROW 13.5 COL 5
     "Подитоги по группам" VIEW-AS TEXT
          SIZE 33.1 BY .87 AT ROW 1.27 COL 47.5 WIDGET-ID 12
          FGCOLOR 4
     "Источник формирования" VIEW-AS TEXT
          SIZE 34.6 BY .83 AT ROW 6.7 COL 3.5
          FGCOLOR 4
     "Детализация" VIEW-AS TEXT
          SIZE 33.1 BY .87 AT ROW 1.43 COL 3.3
          FGCOLOR 4
     RECT-6 AT ROW 1.27 COL 2.3
     RECT-8 AT ROW 6.47 COL 2.3
     RECT-7 AT ROW 11.33 COL 2.3
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 91.9 BY 15.


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
         WIDTH              = 91.9.
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
/* SETTINGS FOR TOGGLE-BOX T-partsneg IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       T-partsneg:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR TOGGLE-BOX Tog-level IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       Tog-level:HIDDEN IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN var-level IN FRAME F-Main
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       var-level:HIDDEN IN FRAME F-Main           = TRUE.

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

&Scoped-define SELF-NAME Classify
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Classify F-Frame-Win
ON VALUE-CHANGED OF Classify IN FRAME F-Main
DO:
  ASSIGN Classify.
  if classify = "n-level":u then do:
    enable
    tog-level
    var-level
    with frame {&frame-name} .
    display
    tog-level
    var-level
    with frame {&frame-name} .
  end.
  else do:
    hide
    tog-level
    var-level
    in frame {&frame-name} .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Tog-level
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Tog-level F-Frame-Win
ON VALUE-CHANGED OF Tog-level IN FRAME F-Main /* с уровня */
DO:
  assign tog-level.
  if tog-level = true then do:
    display var-level with frame {&frame-name} .
    enable  var-level with frame {&frame-name} .
  end.
  else do:
    display var-level with frame {&frame-name} .
    disable var-level with frame {&frame-name} .
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
define input parameter  doc-num like trn-doc.doc-code no-undo.
define input parameter is-out as integer init 1.
define input parameter offc as logical no-undo.
define variable s-price as decimal no-undo .
define variable cur-discnt as decimal no-undo .
define variable cur-quant like gds-dtl.doc-qnty no-undo.
define variable slt-calc as dec.
define variable vat-cost as dec.
define variable r-bar-code like bar-code.b-code no-undo.
DEFINE VARIABLE varsum-dsc-r-b-acc as decimal no-undo .
DEFINE VARIABLE varvat-r-b-acc     as decimal no-undo .
DEFINE VARIABLE var-qnty              as decimal no-undo .
DEFINE VARIABLE varvat-r-b-doc     as decimal no-undo .
DEFINE VARIABLE varslt-r-b-doc     as decimal no-undo .
define buffer buf-bar for bar-code.
{ str/tax-mag.i grp }
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
  DISPLAY Classify RS-Method RS-By T-neg
      WITH FRAME F-Main.
  ENABLE RECT-6 RECT-8 RECT-7 Classify RS-Method RS-By T-neg
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
define variable real-code like clients.obj-code no-undo.
define variable real-type like clients.obj-type no-undo.
define variable doc-num like trn-doc.doc-code no-undo.
define variable is-out as integer init 1.
define variable offc as logical no-undo.
define variable v-host-code like sysconf.host-code no-undo.
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}
define buffer buf_sysconf for ub.sysconf.
define buffer buf_sale-doc for ub.sale-doc.
define buffer b-tr-doc  for trn-doc .


FOR EACH sj-goods :
    delete sj-goods .
END .
FOR EACH d-slt-vat :
    delete d-slt-vat .
END .
_obj-list:
FOR EACH obj-list NO-LOCK:
    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code}
    FIND FIRST buf_sysconf NO-LOCK WHERE buf_sysconf.host-code = v-host-code.
    IF AVAIL buf_sysconf then
        assign
            real-code = buf_sysconf.sale-code
            real-type = buf_sysconf.sale-type
        .
    else NEXT _obj-list.


    IF RS-by = 1 then do:
        if x-tog-shift = no then do:
            _inkas-with--FactDate:
            FOR EACH inkas WHERE
                inkas.fact-date >= X-date-start and
                inkas.fact-date <= X-date-end AND
                inkas.obj-code = obj-list.obj-code and
                inkas.obj-type = obj-list.obj-type AND
                inkas.status_ = {&fact} NO-LOCK,
                each buf_sale-doc  no-lock where
                    buf_sale-doc.inkas-code = inkas.inkas-code
                    and buf_sale-doc.in-inkas = yes,
                    FIRST t-doc No-LOCK WHERE
                        t-doc.doc-code = buf_sale-doc.doc-code:
                assign
                    doc-num = t-doc.doc-code
                    is-out = buf_sale-doc.dir
                .
                if t-doc.office and negparts then NEXT _inkas-with--FactDate.
                run cre-sj in this-procedure (
                    input v-curr-r-b,
                    input doc-num,
                    input is-out,
                    input t-doc.office)
                .
              END. /*FOR EACH inkas*/
        end. /* if x-tog-shift = no then do: */
        else do:
            _inkas-with--ShiftDate-or-Shift:
            FOR EACH inkas WHERE
                inkas.shift-date >= X-date-start and
                inkas.shift-date <= X-date-end AND
                inkas.obj-code = obj-list.obj-code and
                inkas.obj-type = obj-list.obj-type AND
                inkas.status_ = {&fact} NO-LOCK,
                each buf_sale-doc  no-lock where
                    buf_sale-doc.inkas-code = inkas.inkas-code
                and buf_sale-doc.in-inkas = yes,
                    FIRST t-doc No-LOCK WHERE
                    t-doc.doc-code = buf_sale-doc.doc-code:
                if inkas.shift-date = x-date-start and inkas.shift-num < x-shift-start then next _inkas-with--ShiftDate-or-Shift.
                if inkas.shift-date = x-date-end and inkas.shift-num > x-shift-end then next _inkas-with--ShiftDate-or-Shift.
                assign
                    doc-num = t-doc.doc-code
                    is-out = buf_sale-doc.dir
                .
                if t-doc.office and negparts then NEXT _inkas-with--ShiftDate-or-Shift.
                run cre-sj in this-procedure (
                    input v-curr-r-b,
                    input doc-num,
                    input is-out,
                    input t-doc.office)
                .
            END. /*FOR EACH inkas*/
        end. /* else do: */
    END. /* RS-by = 1 then do: */


    IF RS-by = 3 or RS-by = 4 then do:
        if x-tog-shift = no then do:
            _trn-doc:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} AND
                t-doc.status_ = {&fact} AND
                t-doc.fact-date >= X-date-start AND
                t-doc.fact-date <= X-date-end:
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = 1
                    .
                    if offc and negparts then NEXT _trn-doc.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* if x-tog-shift = no then do: */
        else do:
            _trn-doc--with--ShiftDate--or--Shift:
            for each t-doc no-lock where
                t-doc.obj-type = obj-list.obj-type and
                t-doc.obj-code = obj-list.obj-code and
                t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass} and
                t-doc.status_ = {&fact} and
                t-doc.shift-date >= X-date-start and
                t-doc.shift-date <= X-date-end:
                    if t-doc.shift-date = x-date-start and t-doc.shift-num < x-shift-start then next _trn-doc--with--ShiftDate--or--Shift.
                    if t-doc.shift-date = x-date-end and t-doc.shift-num > x-shift-end then next _trn-doc--with--ShiftDate--or--Shift.
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = 1.
                        if offc and negparts then next _trn-doc--with--ShiftDate--or--Shift
                    .
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            end. /* for each t-doc no-lock where */
        end. /* else do: */

        if x-tog-shift = no then do:
            _ret-doc:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} AND
                t-doc.status_ = {&fact} AND
                t-doc.fact-date >= X-date-start AND
                t-doc.fact-date <= X-date-end:
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = -1.
                        if offc and negparts then NEXT _ret-doc
                    .
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* if x-tog-shift = no then do: */
        else do:
            _ret-doc--with--ShiftDate--or--Shift:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} AND
                t-doc.status_ = {&fact} AND
                t-doc.shift-date >= X-date-start AND
                t-doc.shift-date <= X-date-end:
                    if t-doc.shift-date = x-date-start and t-doc.shift-num < x-shift-start then next _ret-doc--with--ShiftDate--or--Shift.
                    if t-doc.shift-date = x-date-end and t-doc.shift-num > x-shift-end then next _ret-doc--with--ShiftDate--or--Shift.
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = -1.
                        if offc and negparts then NEXT _ret-doc--with--ShiftDate--or--Shift
                    .
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            end. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* else do: */
    END. /* IF RS-by = 3 or RS-by = 4 then do: */
  
  
    IF RS-by = 2 OR RS-BY = 3 then do:
        if x-tog-shift = no then do:
            _trn-doc2:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.fact-date >= X-date-start AND
                t-doc.fact-date <= X-date-end AND
                t-doc.cli-type = real-type AND
                t-doc.cli-code = real-code:
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = 1
                    .
                    if offc and negparts then NEXT _trn-doc2.
                        run cre-sj in this-procedure (
                            input v-curr-r-b,
                            input doc-num,
                            input is-out,
                            input offc)
                        .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* if x-tog-shift = no then do: */
        else do:
            _trn-doc2--with--ShiftDate--or--Shift:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.shift-date >= X-date-start AND
                t-doc.shift-date <= X-date-end AND
                t-doc.cli-type = real-type AND
                t-doc.cli-code = real-code:
                    if t-doc.shift-date = x-date-start and t-doc.shift-num < x-shift-start then next _trn-doc2--with--ShiftDate--or--Shift.
                    if t-doc.shift-date = x-date-end and t-doc.shift-num > x-shift-end then next _trn-doc2--with--ShiftDate--or--Shift.
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = 1
                    .
                    if offc and negparts then NEXT _trn-doc2--with--ShiftDate--or--Shift.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* else do: */

        if x-tog-shift = no then do:
            _ret-doc2:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.fact-date >= X-date-start AND
                t-doc.fact-date <= X-date-end AND
                t-doc.cli-type = real-type AND
                t-doc.cli-code = real-code:
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = -1
                    .
                    if offc and negparts then NEXT _ret-doc2.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* if x-tog-shift = no then do: */
        else do:
            _ret-doc2--with--ShiftDate--or--Shift:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.shift-date >= X-date-start AND
                t-doc.shift-date <= X-date-end AND
                t-doc.cli-type = real-type AND
                t-doc.cli-code = real-code:
                    if t-doc.shift-date = x-date-start and t-doc.shift-num < x-shift-start then next _ret-doc2--with--ShiftDate--or--Shift.
                    if t-doc.shift-date = x-date-end and t-doc.shift-num > x-shift-end then next _ret-doc2--with--ShiftDate--or--Shift.
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = -1
                    .
                    if offc and negparts then NEXT _ret-doc2--with--ShiftDate--or--Shift.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* else do: */
  END. /* IF RS-by = 2 OR RS-BY = 3 then do: */
  
  
    IF RS-by = 4 then do:
        if x-tog-shift = no then do:
            _trn-doc3:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.fact-date >= X-date-start AND
                t-doc.fact-date <= X-date-end:
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = 1
                    .
                    if offc and negparts then NEXT _trn-doc3.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* if x-tog-shift = no then do: */
        else do:
            _trn-doc3--with--ShiftDate--or--Shift:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.shift-date >= X-date-start AND
                t-doc.shift-date <= X-date-end:
                    if t-doc.shift-date = x-date-start and t-doc.shift-num < x-shift-start then next _trn-doc3--with--ShiftDate--or--Shift.
                    if t-doc.shift-date = x-date-end and t-doc.shift-num > x-shift-end then next _trn-doc3--with--ShiftDate--or--Shift.
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = 1
                    .
                    if offc and negparts then NEXT _trn-doc3--with--ShiftDate--or--Shift.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* else do: */
        
        if x-tog-shift = no then do:
            _ret-doc3:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.fact-date >= X-date-start AND
                t-doc.fact-date <= X-date-end:
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = -1
                    .
                    if offc and negparts then NEXT _ret-doc3.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* if x-tog-shift = no then do: */
        else do:
            _ret-doc3--with--ShiftDate--or--Shift:
            FOR EACH t-doc NO-LOCK WHERE
                t-doc.obj-type = obj-list.obj-type AND
                t-doc.obj-code = obj-list.obj-code AND
                t-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} AND
                t-doc.status_ = {&fact} AND
                t-doc.shift-date >= X-date-start AND
                t-doc.shift-date <= X-date-end:
                    if t-doc.shift-date = x-date-start and t-doc.shift-num < x-shift-start then next _ret-doc3--with--ShiftDate--or--Shift.
                    if t-doc.shift-date = x-date-end and t-doc.shift-num > x-shift-end then next _ret-doc3--with--ShiftDate--or--Shift.
                    assign
                        doc-num = t-doc.doc-code
                        offc = t-doc.office
                        is-out = -1
                    .
                    if offc and negparts then NEXT _ret-doc3--with--ShiftDate--or--Shift.
                    run cre-sj in this-procedure (
                        input v-curr-r-b,
                        input doc-num,
                        input is-out,
                        input offc)
                    .
            END. /* FOR EACH t-doc NO-LOCK WHERE */
        end. /* else do: */
    END. /* IF RS-by = 4 then do: */

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
run My-var in this-procedure .
/*glog = no.
run no-benq-i in this-procedure ( output glog).
if NOT glog then do:
    message {&no-benefits} view-as alert-box.
    return.
end.*/
assign
date_string = cur-time-print()
Line = fill( "-", 158 )
jj = 0
jj-tot = 0
.

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
run prepare-grp in this-procedure ( input Classify
                                   ,input tog-level
                                   ,input var-level).
RUN PrintProc in this-procedure .

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
frame {&frame-name} classify
frame {&frame-name} RS-Method
frame {&frame-name} T-neg
frame {&frame-name} T-partsneg
frame {&frame-name} RS-by
/*good-choice = (IF X-selectGood = {&g-all} then no else yes)*/

method = RS-method
negparts = t-partsneg
.
if classify = "n-level":u then do:
  assign
  frame {&frame-name} tog-level
  frame {&frame-name} var-level
  .
end.
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
Reportname = "РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ)".
ReportHeader =  "Источник формирования: " +
                radio-label(string(RS-BY), RS-BY:radio-buttons) + {&New-line} +
                "Детализация: " +
                           radio-label(string(RS-method), RS-method:radio-buttons) + {&New-line} +
                (if T-neg then t-neg:label else "") + {&new-line} +
                (if T-partsneg then t-partsneg:label else "")                .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE prepare-grp F-Frame-Win
PROCEDURE prepare-grp :
DEFINE INPUT PARAMETER p-classify AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-tog-level AS logical NO-UNDO.
DEFINE INPUT PARAMETER p-level AS integer NO-UNDO.

define variable loc-classify  as   integer              no-undo .
define variable curr-grp-code like ub.gds-grp.node-code no-undo .
define variable for-grp-name  like ub.gds-grp.node-name no-undo .
define buffer buf_gds-grp for ub.gds-grp.

case p-classify :
  when "no-grp-totals":U
  then do:
    assign
      loc-classify = - 1
    .
  end.
  when "no-classify":U
  then do:
    assign
      loc-classify = 1
    .
  end.
  when "n-level":U
  then do:
    assign
      loc-classify = p-level
    .
  end.
  when "t-level":U
  then do:
    assign
      loc-classify = 0
    .
  end.
end case. /* p-classify */

/* создадим таблицу групп */
for each sj-grp
:
  delete sj-grp .
end.
/*if loc-classify = - 1*/
/*then do:             */
/*  return .           */
/*end.                 */
if X-selectgood = {&g-grp}
then do:
  for each tmp#grp no-lock
  :
    run grplib-get-full-name in this-procedure
      (  input tmp#grp.node-code
      , output for-grp-name
      ) .
    case loc-Classify :
      when 1
      then do:
        create sj-grp .
        assign sj-grp.grp-code  = tmp#grp.node-code
               sj-grp.serv-name = for-grp-name
               sj-grp.grp-name  = tmp#grp.grp-name
        .

      end.
      when  0
      then do:
        if tmp#grp.is-term = yes
        then do:
          create sj-grp .
          assign sj-grp.grp-code  = tmp#grp.node-code
                 sj-grp.serv-name = for-grp-name
                 sj-grp.grp-name  = tmp#grp.grp-name
          .
        end.
        else do:
          run t-level in this-procedure ( input tmp#grp.node-code ) no-error .
        end.
      end.
      
       when - 1 
      then do:
               create sj-grp .
        assign sj-grp.grp-code  = tmp#grp.node-code
               sj-grp.serv-name = for-grp-name
               sj-grp.grp-name  = tmp#grp.grp-name
        .
      
      end.
      
      when p-level
      then do:
        if tmp#grp.lvl-num >= p-level or
         ( tmp#grp.lvl-num <  p-level and
           tmp#grp.is-term  = yes )
        then do:
          create sj-grp .
          assign sj-grp.grp-code  = tmp#grp.node-code
                 sj-grp.serv-name = for-grp-name
                 sj-grp.grp-name  = tmp#grp.grp-name
          .
        end.
        else
        run n-level in this-procedure(tmp#grp.node-code, p-level) no-error.
      end.
    end case. /* loc-Classify */
  end. /* for each tmp#grp */
end. /* X-selectgood = {&g-grp} */
else do:
  for each buf_gds-grp no-lock
  :
    assign
      curr-grp-code = buf_gds-grp.node-code
    .
    run grplib-get-full-name in this-procedure
      (  input buf_gds-grp.node-code
      , output for-grp-name
      ) .
    case loc-Classify :
      when 1
      then do:
        if buf_gds-grp.lvl-num <> 1
        then do:
          next .
        end.
      end.
      when 0
      then do:
        IF not buf_gds-grp.is-term
        then do:
          next .
        end.
      end.
      when p-level
      then do:
        if buf_gds-grp.lvl-num > p-level or
         ( buf_gds-grp.lvl-num < p-level and
           buf_gds-grp.is-term = no )
        then do:
          next .
        end.
      end.
    end case. /* loc-Classify */
    create sj-grp .
    assign sj-grp.grp-code  = curr-grp-code
           sj-grp.serv-name = for-grp-name
           sj-grp.grp-name  = buf_gds-grp.node-name
    .
    release sj-grp.
  end. /* for each buf_gds-grp */
end. /* X-selectgood <> {&g-grp} */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc F-Frame-Win
PROCEDURE PrintProc :
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
define variable v-header-base-curr as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-ii as integer no-undo .
define variable j_row as integer no-undo .
define variable XLS-page-num    as integer   no-undo initial 0 .
define variable sheet-name as character no-undo .
&scop s1 16
&scop s2 25
&scop s3 15
&scop s23 40

{ gbl/curr-r-b.i
  v-curr-r-b
}
if v-curr-r-b = {&r-b-base} then do:
  assign
  v-header-base-curr = string( "( Вал. продаж - Баз.вал. )" )
  .
end.
else do:
  assign
  v-header-base-curr = string( "( Вал. продаж - {&abbr_rubli_allshift} )" )
  .
end.
assign
  XLS-page-num = XLS-page-num + 1
.
if X-selectGood =  {&g-choice} or
         X-selectGood = {&g-spis}     or
      X-selectGood = {&g-one} then
    do:
        v-choice-gds = "По списку товаров: ".

        for each gds-list no-lock:
            if length(gds-str) + length(gds-list.gds-name) <= 115  then do:
                
            gds-str = gds-str + gds-list.gds-name + ", ".
            end.
            else
            do:
                 gds-str = gds-str + "..." .
             leave.
             end.
        end.
        gds-str = right-trim( gds-str, " " ).
        gds-str = right-trim( gds-str, "," ).
/*        if length(gds-str) > 115 then                                           */
/*        do:                                                                     */
/*            v-choice-gds = v-choice-gds + (substring(gds-str, 1, 115) + "..." ).*/
/*        end.                                                                    */
/*        else                                                                    */
/*        do:                                                                     */
            v-choice-gds = v-choice-gds + gds-str.
/*        end.*/
    end.
    
   if error-status :error then next. 

    if X-selectGood = {&g-all} then do:
        v-choice-gds = "Выбор товара: По всем товарам".
        end.
        
if  X-selectGood = {&g-grp} then do: 
/*       if length(str2) > 115 then                      */
/*    do:                                                */
/*                                                       */
/*        v-choice-gds = substring(str2, 1, 115) + "...".*/
/*    end.                                               */
/*    else                                               */
/*    do:                                                */
        v-choice-gds = str2.
/*    end.*/
    end.


for each SheetF where
          SheetF.Sheet-Num > XLS-page-num
:
  delete SheetF .
end.
find first sheetf.
assign
sheet-name = "Товары"
sheetf.sheet-num = 1
/*
sheetf.Excel-Column-Lable =  "№,Код,Артикул,Наименование," +
                             (if method = "artic":u
                              then "Производитель,"
                              else "") +
                              "Ед.изм.,Количество," +
                              "Сумма учетных цен без НДС (вал.продаж),Сумма продажная (вал. продаж),В т.ч. НП (вал. продаж),НП%," +
                              "Сумма продажная без НП (вал. продаж),Сумма торг. нацен. (вал. продаж),Торг.нацен. %," +
                              "НДС%,Сумма НДС (вал. продаж)"
sheetf.sizes = "6,9,{&s1}," + (if method = "artic":u
                               then "{&s2},{&s3},"
                               else "{&s23},") +
               "3,12,"  +
               "13,13,13,2," +
               "13,13,8,2,13"
sheetf.colformat = "1=0;2=0;3=@;"  + (if method = "artic":u
                               then ("4=@;5=@;" +
                                    "6=@;7=0.000;"  +
                                    "8=0.00;9=0.00;10=0.00;11=0;" +
                                    "12=0.00;13=0.00;14=0.00;15=0;16=0.00")
                               else ("4=@;" +
                                    "5=@;6=0.000;"  +
                                    "7=0.00;8=0.00;9=0.00;10=0;" +
                                    "11=0.00;12=0.00;13=0.00;14=0;15=0.00" )
                                )
              + {&delim-par} + {&delim-par} + sheet-name
*/
sheetf.Excel-Column-Lable =  "№,Код,Артикул,Наименование," +
                             (if method = "artic":u
                              then "Производитель,"
                              else "") +
                              "Ед.изм.,Количество," +
                              "Сумма учетных цен c НДС (вал.продаж),Сумма учетных цен без НДС (вал.продаж),Сумма продажная (вал. продаж)," +
                              "Сумма торг. нацен. (вал. продаж),Торг.нацен. %," +
                              "НДС%,Сумма НДС (вал. продаж)"
sheetf.sizes = "6,9,{&s1}," + (if method = "artic":u
                               then "{&s2},{&s3},"
                               else "{&s23},") +
               "3,12,"  +
               "13,13,13," +
               "13,8,2,13"
sheetf.colformat = "1=0;2=0;3=@;"  + (if method = "artic":u
                               then ("4=@;5=@;" +
                                    "6=@;7=0.000;"  +
                                    "8=0.00;9=0.00;10=0.00;" +
                                    "11=0.00;12=0.00;13=0;14=0.00")
                               else ("4=@;" +
                                    "5=@;6=0.000;"  +
                                    "7=0.00;8=0.00;9=0.00;" +
                                    "10=0.00;11=0.00;12=0;13=0.00" )
                                )
              + {&delim-par} + {&delim-par} + sheet-name


Make-Excel = yes
reportname = "РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ) "
  str4 = v-choice-gds
  str2 = v-header-base-curr
Sheetf.Bas-File = "exe/Adjustw.bas".
                  .
DEFINE FRAME SJ-Base
sym1 column-label ":!:"                                                     format "X(1)" space(0)
jj-tot column-label "  N  "                                                 format ">>>>>9" space(0)
sj-goods.b-code column-label "Код ! "                                       format ">>>>>>>>>9"
sj-goods.artic column-label "Артикул   ! "                                  format "x({&s1})"
sj-goods.name column-label "Наименование  ! "                               format "x({&s2})"
clients.obj-name column-label "(Производитель)"                             format "x({&s3})"
sj-goods.unit column-label "Ед.!изм"                                        format "X(3)"
sj-goods.qnty column-label "Количество ! "                                  format "->>>>>9.<<<"
sj-goods.uchet-with-vat-sum column-label "Cумма! учет. c  НДС!(вал. продаж)"         format "->>>>>>>>9.99" space(0)
sj-goods.uchet-sum column-label "Cумма! учет.без НДС!(вал. продаж)"         format "->>>>>>>>9.99" space(0)
sj-goods.netto-sum column-label  "Сумма !продажная!(вал. продаж)"           format "->>>>>>>>9.99" space(0)
/*sj-goods.SLT-r-b column-label    "В т.ч. !налог !с продаж!(вал. продаж)"    format "->>>>>>>>9.99" space(0)
sj-goods.SLT-pc column-label     " НП%"                                     format ">9" space(0)
for-netto-without-slt column-label  "Сумма !продажная!без НП!(вал. продаж)" format "->>>>>>>>9.99" space(0)
*/
sj-goods.n-u-sum column-label        "Сумма !торг. нацен.!(вал. продаж)"    format "->>>>>>>>9.99" space(0)
sj-goods.u-pcnt column-label  "Торг.!нацен. %"                              format "->>9.99%" space(0)
sj-goods.VAT-pc column-label " НДС%"                                        format ">9.9" space(0)
sj-goods.VAT-r-b column-label  "Сумма НДС!(вал. продаж)"                    format "->>>>>>>>9.99" space(0)
sym10 column-label ":!:" format "X(1)"
HEADER  date_string AT 5 format "X(35)"
v-header-base-curr  format "X(25)"
string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER ( PrnLibStream)
  AT 125 FORMAT ">>>>9" SKIP
Line format "X(188)" AT 1
with width {&DOS_CW_2}  down stream-io use-text.
Line = fill("-", 158).
run waitfram-show in this-procedure ( "Подождите ..." ).
run Main_Cycle.
if classify <> "no-grp-totals" then do:
  for each sj-grp:
    for each sj-goods where
            sj-goods.grp-name begins sj-grp.serv-name:
             
      assign
      sj-grp.qnty       = sj-grp.qnty        + sj-goods.qnty
      sj-grp.brutto-sum = sj-grp.brutto-sum  + sj-goods.brutto-sum
      sj-grp.discnt-sum = sj-grp.discnt-sum  + sj-goods.discnt-sum
      sj-grp.netto-sum  = sj-grp.netto-sum   + sj-goods.brutto-sum - sj-goods.discnt-sum
      sj-grp.uchet-sum  = sj-grp.uchet-sum   + sj-goods.uchet-sum
      sj-grp.uchet-with-vat-sum  = sj-grp.uchet-with-vat-sum + sj-goods.uchet-with-vat-sum
      sj-grp.n-u-sum    = sj-grp.n-u-sum     + (sj-goods.brutto-sum - sj-goods.discnt-sum - sj-goods.SLT-r-b) / (1 + sj-goods.VAT-pc / 100) - sj-goods.uchet-sum
      sj-grp.vat-r-b    = sj-grp.vat-r-b     + sj-goods.vat-r-b
      sj-grp.slt-r-b    = sj-grp.slt-r-b     + sj-goods.slt-r-b
      sj-grp.u-pcnt =  (if sj-grp.uchet-sum  = 0
                        then 0
                        else ( sj-grp.n-u-sum / sj-grp.uchet-sum ) * 100
                        )
      .
    end.
  end.
end.
date_string = cur-time-print() .
run waitfram-hide in this-procedure .
run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
run get-report-num in my-handle ( output g#report-num).
run rep/extitle.p (1).
assign
Sheetf.Bas-Params = sheet-name
.
PUT STREAM PrnLibStream unformatted
SPACE(25)  "РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ) " + str1 + " ПО ОБЪЕКТАМ"  format "x(90)"  SKIP(0)


v-choice-gds  skip
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
Line format "X(158)" AT 1 SKIP
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
      FIND clients WHERE clients.obj-type = sj-goods.prod-type AND
                                          clients.obj-code = sj-goods.prod-code NO-LOCK .
          prodbuf1 = breakstr(clients.obj-name, 25, prodbuf1, prodbuf2).
  END.
  namebuf1 = breakstr(sj-goods.name, 18, namebuf1, namebuf2).
  IF method = "b-code":U THEN do:
    DISPLAY STREAM PrnLibStream
    sym1
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code @ jj-tot
    sj-goods.b-code
    sj-goods.artic
    namebuf1 @ sj-goods.name
    namebuf2   @ clients.obj-name
    sj-goods.qnty
    sj-goods.unit
    sj-goods.uchet-with-vat-sum
    sj-goods.uchet-sum
    sj-goods.netto-sum
    /*
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    sj-goods.netto-sum - sj-goods.slt-r-b @ for-netto-without-slt
    */
    sj-goods.n-u-sum
    sj-goods.u-pcnt
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    sym10
    with FRAME SJ-Base .
    {&PutExcel}
    ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code {&tabulation}
    sj-goods.b-code {&tabulation}
    sj-goods.artic  {&tabulation}
    sj-goods.name {&tabulation}
    sj-goods.unit {&tabulation}
    sj-goods.qnty {&tabulation}
    sj-goods.uchet-with-vat-sum {&tabulation}
    sj-goods.uchet-sum {&tabulation}
    sj-goods.netto-sum {&tabulation}
    /*
    sj-goods.SLT-r-b {&tabulation}
    sj-goods.SLT-pc  {&tabulation}
    (sj-goods.netto-sum - sj-goods.slt-r-b) {&tabulation}
    */
    sj-goods.n-u-sum {&tabulation}
    sj-goods.u-pcnt {&tabulation}
    sj-goods.VAT-pc {&tabulation}
    sj-goods.VAT-r-b
    skip.
    run st_excel in this-procedure ( input-output j_row
                                    ,input-output XLS-page-num
                                      ).
  end.
  ELSE do:
    IF method = "artic":U then do:
        DISPLAY STREAM PrnLibStream
        sym1
        ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code @ jj-tot
        sj-goods.b-code
        sj-goods.artic
        namebuf1 @ sj-goods.name
        prodbuf1   @ clients.obj-name
        sj-goods.qnty
        sj-goods.unit
        sj-goods.uchet-with-vat-sum
        sj-goods.uchet-sum
        sj-goods.netto-sum
        /*
        sj-goods.SLT-r-b
        sj-goods.SLT-pc
        sj-goods.netto-sum - sj-goods.slt-r-b @ for-netto-without-slt
        */
        sj-goods.n-u-sum
        sj-goods.u-pcnt
        sj-goods.VAT-pc
        sj-goods.VAT-r-b
        sym10
        with FRAME SJ-Base .
        {&putExcel}
        ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code {&tabulation}
        sj-goods.b-code {&tabulation}
        sj-goods.artic  {&tabulation}
        sj-goods.name {&tabulation}
        clients.obj-name {&tabulation}
        sj-goods.unit {&tabulation}
        sj-goods.qnty {&tabulation}
        sj-goods.uchet-with-vat-sum {&tabulation}
        sj-goods.uchet-sum {&tabulation}
        sj-goods.netto-sum {&tabulation}
        /*
        sj-goods.SLT-r-b {&tabulation}
        sj-goods.SLT-pc  {&tabulation}
        sj-goods.netto-sum - sj-goods.slt-r-b {&tabulation}
        */
        sj-goods.n-u-sum {&tabulation}
        sj-goods.u-pcnt {&tabulation}
        sj-goods.VAT-pc {&tabulation}
        sj-goods.VAT-r-b
        skip.
        run st_excel in this-procedure ( input-output j_row
                                        ,input-output XLS-page-num
                                          ).

    end.
  end.
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
  sj-goods.uchet-with-vat-sum (SUB-TOTAL BY sj-goods.is-out)
  sj-goods.uchet-with-vat-sum (TOTAL)
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
    sj-goods.uchet-with-vat-sum
    sj-goods.uchet-sum
    sj-goods.netto-sum
    /*
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    for-netto-without-slt
    */
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
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-with-vat-sum @ sj-goods.uchet-with-vat-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum @ sj-goods.uchet-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.n-u-sum @ sj-goods.n-u-sum
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.VAT-r-b @ sj-goods.VAT-r-b
    /*
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b @ sj-goods.SLT-r-b
    ((ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum) -
     (ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b)) @ for-netto-without-slt
     */
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
    sj-goods.uchet-with-vat-sum
    sj-goods.uchet-sum
    sj-goods.netto-sum
    /*
    sj-goods.SLT-r-b
    sj-goods.SLT-pc
    for-netto-without-slt
    */
    sj-goods.n-u-sum
    sj-goods.u-pcnt
    sj-goods.VAT-pc
    sj-goods.VAT-r-b
    with FRAME SJ-Base .

    {&putExcel}
    {&tabulation}
    (IF method = "TOTALS":U
    THEN ""
    ELSE string(ACCUM SUB-COUNT BY sj-goods.is-out sj-goods.b-code, ">>>>9")) {&tabulation}
    (IF method = "TOTALS":U
    THEN ""
    ELSE " наименований" ) {&tabulation}
    string( "Итого " + ( if sj-goods.is-out then "продажи" else "возвраты" ) ) {&tabulation}
    (if method = "artic" then {&tabulation} else '')
    {&tabulation}
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.qnty {&tabulation}
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-with-vat-sum  {&tabulation}
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.uchet-sum  {&tabulation}
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum  {&tabulation}
    /*
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b    {&tabulation}
                                                           {&tabulation}
    ((ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.netto-sum) -
     (ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.SLT-r-b)) {&tabulation}
     */

    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.n-u-sum {&tabulation}
    {&tabulation}
    {&tabulation}
    ACCUM SUB-TOTAL BY sj-goods.is-out sj-goods.VAT-r-b
    skip.
    run st_excel in this-procedure ( input-output j_row
                                    ,input-output XLS-page-num
                                      ).
  end.
END . /*FOR EACH sj-goods*/
for each d-slt-vat break by d-slt-vat.vat-pc:
        if first-of(d-slt-vat.vat-pc) then
        vat-pc-val-qnty = vat-pc-val-qnty + 1.
        ACCUMULATE d-slt-vat.slt-pc (COUNT ).
end.
PUT STREAM PrnLibStream Line format "X(188)" .
DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .

if classify <> "no-grp-totals" then do:
  UNDERLINE STREAM PrnLibStream
  jj-tot
  sj-goods.b-code
  sj-goods.artic
  sj-goods.name
  clients.obj-name
  sj-goods.qnty
  sj-goods.unit
  sj-goods.uchet-with-vat-sum
  sj-goods.uchet-sum
  sj-goods.netto-sum
  /*
  sj-goods.SLT-r-b
  sj-goods.SLT-pc
  for-netto-without-slt
  */
  sj-goods.n-u-sum
  sj-goods.u-pcnt
  sj-goods.VAT-pc
  sj-goods.VAT-r-b
  with FRAME SJ-Base .
  v-ii = 0.
  _grp:
  do while true:
    if v-ii = 0 then do:
      find first sj-grp use-index p4 no-error.
    end.
    else do:
      find next sj-grp use-index p4 no-error.
    end.
    v-ii = v-ii + 1.
    if not available sj-grp then do:
     leave _grp.
    end.
    define variable s1 as character no-undo .
    define variable s2 as character no-undo .
    define variable s3 as character no-undo .
    assign
    s1 = substring(sj-grp.serv-name, 1, {&s1})
    s2 = (if length(sj-grp.serv-name) > {&s1}
          then substring(sj-grp.serv-name, {&s1} + 1, {&s2})
          else '')
    s3 = (if length(sj-grp.serv-name) > ({&s1} + {&s2})
          then substring(sj-grp.serv-name, {&s1} + {&s2} + 1, {&s3})
          else '')
    .
    DISPLAY  STREAM PrnLibStream
    sym1
    (if v-ii = 1
    then "Группы:"
    else "")         @ sj-goods.b-code
    s1 @ sj-goods.artic
    s2 @ sj-goods.name
    s3 @ clients.obj-name
    sj-grp.qnty @ sj-goods.qnty
    sj-grp.netto-sum @ sj-goods.netto-sum
    sj-grp.uchet-with-vat-sum @ sj-goods.uchet-with-vat-sum
    sj-grp.uchet-sum @ sj-goods.uchet-sum
    /*
    sj-grp.slt-r-b @ sj-goods.SLT-r-b
    sj-grp.netto-sum - sj-grp.slt-r-b @ for-netto-without-slt
    */
    sj-grp.n-u-sum @ sj-goods.n-u-sum
    sj-grp.u-pcnt @ sj-goods.u-pcnt
    sj-grp.vat-r-b @  sj-goods.VAT-r-b
    sym10
    with FRAME SJ-Base .
    DOWN STREAM PrnLibStream 1 with FRAME SJ-Base .
  end.
  UNDERLINE STREAM PrnLibStream
  jj-tot
  sj-goods.b-code
  sj-goods.artic
  sj-goods.name
  clients.obj-name
  sj-goods.qnty
  sj-goods.unit
  sj-goods.uchet-with-vat-sum
  sj-goods.uchet-sum
  sj-goods.netto-sum
  /*
  sj-goods.SLT-r-b
  sj-goods.SLT-pc
  for-netto-without-slt
  */
  sj-goods.n-u-sum
  sj-goods.u-pcnt
  sj-goods.VAT-pc
  sj-goods.VAT-r-b
  with FRAME SJ-Base .
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
sj-goods.uchet-with-vat-sum
sj-goods.uchet-sum
sj-goods.netto-sum
/*
sj-goods.SLT-r-b
sj-goods.SLT-pc
for-netto-without-slt
*/
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
(ACCUM TOTAL sj-goods.uchet-with-vat-sum) @ sj-goods.uchet-with-vat-sum
(ACCUM TOTAL sj-goods.uchet-sum) @ sj-goods.uchet-sum
/*
(ACCUM TOTAL sj-goods.SLT-r-b ) @ sj-goods.SLT-r-b
((ACCUM TOTAL sj-goods.netto-sum) -
 (ACCUM TOTAL sj-goods.SLT-r-b  )) @ for-netto-without-slt
 */
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
sj-goods.uchet-with-vat-sum
sj-goods.uchet-sum
sj-goods.netto-sum
/*
sj-goods.SLT-r-b
sj-goods.SLT-pc
for-netto-without-slt
*/
sj-goods.n-u-sum
sj-goods.u-pcnt
sj-goods.VAT-pc
sj-goods.VAT-r-b
with FRAME SJ-Base .

{&PutExcel}
"ИТОГО" {&tabulation}
IF method = "TOTALS":U
THEN ""
ELSE string(jj-tot, ">>>>9")  {&tabulation}
IF method = "TOTALS":U
THEN ""
ELSE " наименований"  {&tabulation}
{&tabulation}
(if method = "artic" then {&tabulation} else '')
{&tabulation}
(ACCUM TOTAL sj-goods.qnty  ) {&tabulation}
(ACCUM TOTAL sj-goods.uchet-with-vat-sum)  {&tabulation}
(ACCUM TOTAL sj-goods.uchet-sum)  {&tabulation}
(ACCUM TOTAL sj-goods.netto-sum ) {&tabulation}
/*
(ACCUM TOTAL sj-goods.SLT-r-b )  {&tabulation}
{&tabulation}
((ACCUM TOTAL sj-goods.netto-sum) -
 (ACCUM TOTAL sj-goods.SLT-r-b  )) {&tabulation}
 */
(ACCUM TOTAL sj-goods.n-u-sum  ) {&tabulation}
{&tabulation}
{&tabulation}
(ACCUM TOTAL sj-goods.VAT-r-b  ) skip
.
/*
PUT STREAM PrnLibStream
skip
string( ": НДС :Сумма прод.цен : Сумма  НП      :Сумма прод.цен : Сумма учет. цен : Сумма учет. цен :   Сумма НДС    :% торг.нацен.:сумма торг.нац./:")
AT 33 format "X(160)" SKIP(0)
string( ":     :               :                :  без НП       :    с НДС        :    без НДС      :  с прод.цен    :             :сумма прод.цен  :")
AT 33 FORMAT "X(160)" skip
.
*/

PUT STREAM PrnLibStream
skip
string( ": НДС :Сумма прод.цен : Сумма учет. цен : Сумма учет. цен :   Сумма НДС    :% торг.нацен.:сумма торг.нац./:")
AT 13 format "X(126)" SKIP(0)
string( ":     :               :    с НДС        :    без НДС      :  с прод.цен    :             :сумма прод.цен  :")
AT 13 FORMAT "X(126)" skip
.


XLS-page-num = XLS-page-num + 1.
{&pageExcel}
find first sheetf
  where sheetf.sheet-num = XLS-page-num
no-error .
if not available sheetf then do:
  create sheetf.
end.
/*
&scop at-uchet-sum 91
&scop at-vat-r-b   108
&scop at-n-u-sum  126
&scop at-pcnt-torg-nac 144
&scop at-sum-torg-nac 162
*/


&scop at-uchet-sum 38
&scop at-vat-r-b   56
&scop at-n-u-sum  73
&scop at-pcnt-torg-nac 91
&scop at-sum-torg-nac 109

assign
sheet-name = "Итоги по НДС"
sheetf.sheet-num   = XLS-page-num
/*
sheetf.Excel-Column-Lable =  "НП%,НДС%,Сумма прод.цен,Сумма  НП,Сумма прод.цен без НП," +
                             "Сумма учет. цен с НДС,Сумма учет. цен без НДС,"  +
                             "Сумма НДС с прод.цен,% торг.нацен.,сумма торг.нац./сумма прод.цен"
sheetf.sizes = "10,5,16,16,16,17,17," +
              "16,13,16"
sheetf.colformat = "1=0;2=0.00;3=0.00;4=0.00;5=0.00;" +
                   "6=0.00;7=0.00;" +
                   "8=0.00;9=0.000;10=0.00"
                    + {&delim-par} + {&delim-par} + sheet-name
*/
sheetf.Excel-Column-Lable =  "НДС%,Сумма прод.цен," +
                             "Сумма учет. цен с НДС,Сумма учет. цен без НДС,"  +
                             "Сумма НДС с прод.цен,% торг.нацен.,сумма торг.нац./сумма прод.цен"
sheetf.sizes = "15,16,17,17," +
              "16,13,16"
sheetf.colformat = "1=0.00;2=0.00;" +
                   "3=0.00;4=0.00;" +
                   "5=0.00;6=0.00;7=0.00"
                    + {&delim-par} + {&delim-par} + sheet-name
Make-Excel = yes
reportname = "РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ) ИТОГИ"
str4 = v-choice-gds
str2 = v-header-base-curr
Sheetf.Bas-File = "exe/Adjustw.bas".
.
run rep/extitle.p ( input XLS-page-num).

assign
Sheetf.Bas-Params = sheet-name
.



FOR EACH  d-slt-vat break
by d-slt-vat.VAT-pc
/*by d-slt-vat.slt-pc*/ :

  ACCUMULATE
  d-slt-vat.SLT-r-b (TOTAL by d-slt-vat.vat-pc)
  d-slt-vat.SLT-r-b-brutto (TOTAL by d-slt-vat.vat-pc)
  d-slt-vat.VAT-r-b (TOTAL by d-slt-vat.vat-pc)
  d-slt-vat.uchet-with-vat-sum(TOTAL by d-slt-vat.vat-pc)
  d-slt-vat.uchet-sum (TOTAL by d-slt-vat.vat-pc)
  d-slt-vat.n-u-sum (TOTAL by d-slt-vat.vat-pc)
  .

   IF LAST-OF(d-slt-vat.vat-pc) then do:
       PUT STREAM PrnLibStream
       line AT 14 format "X(106)" SKIP
       string (  "Итого по НДС " + string(d-slt-vat.vat-pc, "99.9%")  + " " +
                 string(  ( ACCUM TOTAL by d-slt-vat.vat-pc d-slt-vat.slt-r-b-brutto ) , "->>>,>>>,>>9.99" )  +  ":"   )
       AT 1 format "X(35)"
       /*AT 14 format "X(43)"
       string (  string( ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   +  ":" )
       AT 57 format "X(16)"
       string (  string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b-brutto) -
               (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b) , "->>>,>>>,>>9.99" )   +  ":" )
       AT 73 format "X(16)"*/
       string (
               string(  ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-with-vat-sum ) , "->>>,>>>,>>9.99" )   +  ":"
              )
       AT {&at-uchet-sum} format "X(16)"
       string (
               string(  ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-sum ) , "->>>,>>>,>>9.99" )   +  ":"
              )
       AT {&at-vat-r-b} format "X(16)"
       string (
               string(  ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.VAT-r-b ) , "->>>,>>>,>>9.99" )   +  ":"
              )
       AT {&at-n-u-sum} format "X(16)"
       string (
               string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.n-u-sum) / (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-sum) * 100 , "->>>,>>9.99" )   +  ":"
              )
       AT {&at-pcnt-torg-nac} format "X(16)"
       string (
               string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.n-u-sum) / (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.slt-r-b-brutto)  * 100  , "->>,>>9.99" )   +  ":"
              )
       AT {&at-sum-torg-nac} format "X(16)"
       SKIP
       .
       if NOT last(d-slt-vat.vat-pc) then
       PUT STREAM PrnLibStream
       line AT 14 format "X(106)" SKIP .
      {&putexcel}
      "Итого по НДС " /*{&tabulation}*/
       d-slt-vat.vat-pc  {&tabulation}
         ( ACCUM TOTAL by d-slt-vat.vat-pc d-slt-vat.slt-r-b-brutto )   {&tabulation}
       /*string( ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   {&tabulation}
       string( (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b-brutto) -
               (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.SLT-r-b) , "->>>,>>>,>>9.99" )  {&tabulation}*/
       ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-with-vat-sum )  {&tabulation}
       ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-sum )   {&tabulation}
       ( ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.VAT-r-b )    {&tabulation}
       (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.n-u-sum) / (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.uchet-sum) * 100    {&tabulation}
       (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.n-u-sum) / (ACCUM TOTAL  by d-slt-vat.vat-pc d-slt-vat.slt-r-b-brutto)  * 100
       skip.

  END.
end.
PUT STREAM PrnLibStream
line AT 14 format "X(106)" SKIP
string (  "Итого по налогам  "  +
string(  ( ACCUM TOTAL d-slt-vat.slt-r-b-brutto ) , "->>>,>>>,>>9.99" )  +  ":"   )
AT 1 format "X(35)"
/*AT 14 format "X(43)"
string (  string( ( ACCUM TOTAL d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   +  ":" )
AT 57 format "X(16)"
string (  string( ( ACCUM TOTAL d-slt-vat.SLT-r-b-brutto) -
( ACCUM TOTAL d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   +  ":" )
AT 73 format "X(16)"*/
string (
        string(  ( ACCUM TOTAL d-slt-vat.uchet-with-vat-sum ) , "->>>,>>>,>>9.99" )   +  ":"
       )
AT {&at-uchet-sum} format "X(16)"
string (
        string(  ( ACCUM TOTAL d-slt-vat.uchet-sum ) , "->>>,>>>,>>9.99" )   +  ":"
       )
AT {&at-vat-r-b} format "X(16)"
string (
        string(  ( ACCUM TOTAL d-slt-vat.VAT-r-b ) , "->>>,>>>,>>9.99" )   +  ":"
       )
AT {&at-n-u-sum} format "X(16)"
string (
        string( (ACCUM TOTAL d-slt-vat.n-u-sum) / (ACCUM TOTAL d-slt-vat.uchet-sum) * 100 , "->>>,>>9.99" )   +  ":"
       )
AT {&at-pcnt-torg-nac} format "X(16)"
string (
        string( (ACCUM TOTAL d-slt-vat.n-u-sum) / (ACCUM TOTAL d-slt-vat.slt-r-b-brutto)  * 100  , "->>,>>9.99" )   +  ":"
       )
AT {&at-sum-torg-nac} format "X(16)"
SKIP.
{&putexcel}
"Итого по налогам          "  {&tabulation}
 /*{&tabulation}*/
string(  ( ACCUM TOTAL d-slt-vat.slt-r-b-brutto ) , "->>>,>>>,>>9.99" )  {&tabulation}
/*string( ( ACCUM TOTAL d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )   {&tabulation}
string( ( ACCUM TOTAL d-slt-vat.SLT-r-b-brutto) -
( ACCUM TOTAL d-slt-vat.SLT-r-b ) , "->>>,>>>,>>9.99" )  {&tabulation}*/
string(  ( ACCUM TOTAL d-slt-vat.uchet-with-vat-sum ) , "->>>,>>>,>>9.99" )   {&tabulation}
string(  ( ACCUM TOTAL d-slt-vat.uchet-sum ) , "->>>,>>>,>>9.99" )  {&tabulation}
string(  ( ACCUM TOTAL d-slt-vat.VAT-r-b ) , "->>>,>>>,>>9.99" )   {&tabulation}
string( (ACCUM TOTAL d-slt-vat.n-u-sum) / (ACCUM TOTAL d-slt-vat.uchet-sum) * 100 , "->>>,>>9.99" )   {&tabulation}
string( (ACCUM TOTAL d-slt-vat.n-u-sum) / (ACCUM TOTAL d-slt-vat.slt-r-b-brutto)  * 100  , "->>,>>9.99" )   skip.
PUT STREAM PrnLibStream
" " SKIP(1) space(10) "Директор ______________" format "X(50)"
"Гл. бухгалтер ___________________" format "X(50)" SKIP .
HIDE STREAM PrnLibStream FRAME BottomFrame .
output STREAM PrnLibStream CLOSE.
if classify <> "no-grp-totals" then do:
  XLS-page-num = XLS-page-num + 1.
  {&pageExcel}
  find first sheetf
    where sheetf.sheet-num = XLS-page-num
  no-error .
  if not available sheetf then do:
    create sheetf.
  end.
  assign
  sheet-name = "Группы"
  sheetf.sheet-num   = XLS-page-num
  /*
  sheetf.Excel-Column-Lable =  "Группа,Количество," +
                                "Сумма учетных цен без НДС (вал.продаж),Сумма продажная (вал. продаж),В т.ч. НП (вал. продаж)," +
                                "Сумма продажная без НП (вал. продаж),Сумма торг. нацен. (вал. продаж),Торг.нацен. %," +
                                "Сумма НДС (вал. продаж)"
  sheetf.sizes = "150,12,"  +
                "13,13,13," +
                "13,13,8,13"
  sheetf.colformat = "1=@;2=0.000;" +
                     "3=0.00;4=0.00;5=0.00;" +
                     "6=0.00;7=0.00;8=0.00;" +
                     "9=0.00" +
                     {&delim-par} + {&delim-par} + sheet-name
  */
  sheetf.Excel-Column-Lable =  "Группа,Количество,Сумма учетных цен с НДС (вал.продаж)," +
                                "Сумма учетных цен без НДС (вал.продаж),Сумма продажная (вал. продаж)," +
                                "Сумма торг. нацен. (вал. продаж),Торг.нацен. %," +
                                "Сумма НДС (вал. продаж)"
  sheetf.sizes = "120,12,13,"  +
                "13,13," +
                "13,8,13"
  sheetf.colformat = "1=@;2=0.000;3=0.00;" +
                     "4=0.00;5=0.00;" +
                     "6=0.00;7=0.00;" +
                     "8=0.00" +
                     {&delim-par} + {&delim-par} + sheet-name

  Make-Excel = yes
  reportname = "РАСЧЕТ НАЛОГОВ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ) - ГРУППЫ"
  str4 = v-choice-gds
  str2 = v-header-base-curr
  Sheetf.Bas-File = "exe/adjustw.bas"
  .
  run rep/extitle.p ( input XLS-page-num).
  assign
  Sheetf.Bas-Params = sheet-name
  .

  v-ii = 0.
  _grp:
  do while true:
    if v-ii = 0 then do:
      find first sj-grp use-index p4 no-error.
    end.
    else do:
      find next sj-grp use-index p4 no-error.
    end.
    v-ii = v-ii + 1.
    if not available sj-grp then do:
     leave _grp.
    end.
    {&putexcel}
    sj-grp.serv-name {&tabulation}
    sj-grp.qnty {&tabulation}
    sj-grp.uchet-with-vat-sum {&tabulation}
    sj-grp.uchet-sum {&tabulation}
    sj-grp.netto-sum {&tabulation}
    /*sj-grp.slt-r-b {&tabulation}
    sj-grp.netto-sum - sj-grp.slt-r-b {&tabulation}
    */
    sj-grp.n-u-sum {&tabulation}
    sj-grp.u-pcnt {&tabulation}
    sj-grp.vat-r-b {&tabulation}
    skip.
  end.
  {&PutExcel}
  "ИТОГО" {&tabulation}
  (ACCUM TOTAL sj-goods.qnty  ) {&tabulation}
  (ACCUM TOTAL sj-goods.uchet-with-vat-sum)  {&tabulation}
  (ACCUM TOTAL sj-goods.uchet-sum)  {&tabulation}
  (ACCUM TOTAL sj-goods.netto-sum ) {&tabulation}
  /*(ACCUM TOTAL sj-goods.SLT-r-b )  {&tabulation}
  ((ACCUM TOTAL sj-goods.netto-sum) -
  (ACCUM TOTAL sj-goods.SLT-r-b  )) {&tabulation}*/
  (ACCUM TOTAL sj-goods.n-u-sum  ) {&tabulation}
  "" {&tabulation}
  (ACCUM TOTAL sj-goods.VAT-r-b  ) skip
  .
end.
{&CloseExcel}
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE st-excel F-Frame-Win
PROCEDURE st_excel :
define input-output parameter p-rows as integer no-undo .
define input-output parameter p-pn as integer no-undo .
define buffer buf_sheetf for sheetf.
p-rows = p-rows + 1.
if p-rows > 50000 then do:
  p-pn = p-pn + 1.
  p-rows = 0.
  find first buf_sheetf where
            buf_sheetf.sheet-num = p-pn no-error.
  if not available buf_sheetf then do:
    create buf_sheetf.
    buffer-copy sheetf except sheet-num to buf_sheetf
    assign
    buf_sheetf.sheet-num = p-pn
    .
    {&pageExcel}
    run rep/extitle.p ( input p-pn).
  end.
end.
end procedure. /* st_excel */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME