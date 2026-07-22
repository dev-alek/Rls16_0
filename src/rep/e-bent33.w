&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по скидкам по реализации в магазине(закладка № 2)

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Отчет по скидкам по реализации в магазине (закладка № 2)".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new}
{ rep/f-fdec.i }

&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."

define SHARED variable method   as character no-undo.
define SHARED variable cas-shft as logical no-undo init no.

def stream BenStream .

define variable  State-source as  WIDGET-HANDLE.

define variable NotInc          as logical   no-undo .
define variable Line            as char      no-undo.
define variable date_string     as char      no-undo.
define variable cas-num         as integer   no-undo.
define variable found           as logical init yes no-undo.
define variable multi-obj       as logical   no-undo.
define variable dopd            as decimal   no-undo.
define variable dopd1           as decimal   no-undo.
define variable g#report-num as integer no-undo .

{ rep/e-nobenq.i }

def temp-table benefits no-undo
/*    Field obj-type like chk-doc.obj-type*/
    field obj-code like chk-doc.obj-code
    Field gds-code like goods.gds-code
    Field artic like goods.artic
/*  field gds-name like goods.gds-name*/
    /*% скидки с точностью до целых как обговорено с ПИКАЛОВОЙ*/
    field dcpc as decimal format "->>9.9%"
    field dcpc1 as decimal format "->>9.9%"
    field price-base like chk-gds.price-base
    field price-netto like chk-gds.price-base
    field qnty like gds-dtl.fact-qnty
    field discnt    like chk-gds.discnt
    INDEX pi IS PRIMARY obj-code dcpc1 gds-code price-base
    INDEX i-artic obj-code dcpc1 artic price-base
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-5 SumsOnly 
&Scoped-Define DISPLAYED-OBJECTS SumsOnly 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 42.75 BY 3.25.

DEFINE VARIABLE SumsOnly AS LOGICAL INITIAL no 
     LABEL "Только итоги по ставкам скидок":L 
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY 1
     FGCOLOR 0  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SumsOnly AT ROW 2.29 COL 2
     "Показать :" VIEW-AS TEXT
          SIZE 15 BY .75 AT ROW 1.33 COL 9.5
          FGCOLOR 4 
     RECT-5 AT ROW 1.13 COL 1.63
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 9.75
         WIDTH              = 51.25.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
FOR EACH benefits:
    delete benefits.
  END.

  run no-benqi(OUTPUT Notinc).

  FIND obj-list No-LOCK NO-ERROR.
  IF NOT AVAIL obj-list then assign multi-obj = yes .

  FOR EACH obj-list No-LOCK:
    _chk-gds: /* метка */
    FOR EACH chk-doc No-LOCK
      WHERE chk-doc.obj-type = obj-list.obj-type AND
           chk-doc.obj-code = obj-list.obj-code AND
           chk-doc.out-code <> ? AND
           chk-doc.chk-date >= X-date-start AND
           chk-doc.chk-date <= X-date-end,
      EACH chk-gds No-LOCK
        WHERE chk-gds.doc-code = chk-doc.doc-code,
        FIRST bar-code No-LOCK WHERE bar-code.b-code = chk-gds.b-code
      :
      if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
      ACCUMULATE chk-gds.doc-code (COUNT).
      IF x-SelectGood > 1 then do:
        FIND FIRST goods No-LOCK WHERE goods.gds-code = bar-code.gds-code NO-ERROR.
        IF NOT CAN-FIND(first gds-list WHERE
                            gds-list.artic = goods.artic AND
                            gds-list.prod-type  = goods.prod-type AND
                            gds-list.prod-code = goods.prod-code
                            ) then NEXT _chk-gds.
      end.
      dopd1 = ROUND(chk-gds.discnt / chk-gds.price-base * 100, 1).
      dopd = chk-gds.discnt / chk-gds.price-base * 100 .
/*    if dopd1 = 0 then NEXT _chk-gds.*/
      FIND FIRST benefits WHERE
               benefits.gds-code = bar-code.gds-code AND
               benefits.dcpc1 = dopd1 AND
               benefits.price-base = chk-gds.price-base AND
               benefits.obj-code = chk-doc.obj-code No-ERROR.
      IF NOT avail benefits then do:
        FIND FIRST goods NO-LOCK WHERE goods.gds-code = bar-code.gds-code NO-ERROR.
        create benefits.
        assign
          benefits.artic = goods.artic
          benefits.gds-code = bar-code.gds-code
          benefits.dcpc =  dopd
          benefits.dcpc1 =  dopd1
          benefits.price-base = chk-gds.price-base
          benefits.discnt = benefits.dcpc * benefits.price-base / 100
          benefits.price-netto = benefits.price-base - benefits.discnt
/*      benefits.obj-type = chk-doc.obj-type*/
          benefits.obj-code = chk-doc.obj-code
        .
      end.
      assign benefits.qnty = benefits.qnty + chk-gds.doc-qnty .
    END.  /*FOR EACH CHK-DOC*/
  END. /*FOR EACH OBJ-LIST*/

  assign
    sheetf.Excel-Column-Lable = "Артикул" + {&comma-char} + "Количество"  + {&comma-char} + "Цена исх" + {&comma-char} + "Цена со скидкой"  + {&comma-char} + "Сумма скидки"
    sheetf.sizes = "16" + {&comma-char} + "15"  + {&comma-char} + "15"  + {&comma-char} + "15"  + {&comma-char} + "15"
    str2 = string(( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ), "X(40)")
  .
  run rep/extitle.p (1).
  FOR EACH benefits NO-LOCK BREAK BY BENEFITS.OBJ-CODE BY BENEFITS.DCPC1 BY BENEFITS.ARTIC  BY BENEFITS.PRICE-BASE:
    IF FIRST-OF(BENEFITS.OBj-CODE) THEN DO:
      FIND FIRST clients NO-LOCK WHERE clients.obj-type = {&shop} AND clients.obj-code = benefits.obj-code No-ERROR.
      {&PutExcel} (IF AVAIL clients then clients.obj-name  else ("Магазин N " + string(benefits.obj-code)) )  SKIP.
    END.
    IF FIRST-OF(BENEFITS.dcpc1) THEN DO:
      {&PutExcel}  ("Скидка " + string(BENEFITS.dcpc1, "->>9.9%"))  SKIP.
    END.
    if SumsOnly = no then do :
      {&PutExcel}
      BENEFITS.artic {&tabulation}
      excel-qnty ( BENEFITS.qnty ) {&tabulation}
      excel-sum  ( BENEFITS.PRICE-BASE ) {&tabulation}
      excel-sum  ( BENEFITS.PRICE-NETTO ) {&tabulation}
      excel-sum  ( BENEFITS.DISCNT )
      SKIP.
    end.
    ACCUMULATE
      BENEFITS.qnty (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc1)
      (BENEFITS.qnty * BENEFITS.price-base) (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc1)
      (BENEFITS.qnty * BENEFITS.price-netto) (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc1)
      (BENEFITS.qnty * BENEFITS.discnt) (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc1)
    .
    IF LAST-OF(BENEFITS.dcpc1) THEN DO:
      {&PutExcel}
      ("ИТОГО: (" + string(BENEFITS.dcpc1, "->>9.9%") + ")") {&tabulation}
      excel-qnty ( ACCUM TOTAL BY BENEFITS.dcpc1 BENEFITS.qnty ) {&tabulation}
      excel-sum  ( ACCUM TOTAL BY BENEFITS.dcpc1 (BENEFITS.qnty * BENEFITS.PRICE-BASE) ) {&tabulation}
      excel-sum  ( ACCUM TOTAL BY BENEFITS.dcpc1 (BENEFITS.qnty * BENEFITS.PRICE-NETTo) ) {&tabulation}
      excel-sum  ( ACCUM TOTAL BY BENEFITS.dcpc1 (BENEFITS.qnty * BENEFITS.DISCNT) )
      SKIP.
    END.
    IF Multi-obj AND LAST-OF(BENEFITS.OBJ-CODE) THEN DO:
      {&PutExcel}
      ("ИТОГО ПО МАГАЗИНУ " + string(BENEFITS.OBJ-CODE)) {&tabulation}
      excel-qnty ( ACCUM TOTAL BY BENEFITS.obj-code BENEFITS.qnty ) {&tabulation}
      excel-sum  ( ACCUM TOTAL BY BENEFITS.obj-code (BENEFITS.qnty * BENEFITS.PRICE-BASE) ) {&tabulation}
      excel-sum  ( ACCUM TOTAL BY BENEFITS.obj-code (BENEFITS.qnty * BENEFITS.PRICE-NETTo) ) {&tabulation}
      excel-sum  ( ACCUM TOTAL BY BENEFITS.obj-code (BENEFITS.qnty * BENEFITS.DISCNT) )
      SKIP.
    END.
    IF LAST(BENEFITS.OBJ-CODE) THEN DO:
      {&PutExcel}
      "ИТОГО ПО ВСЕМ " {&tabulation}
      excel-qnty ( ACCUM TOTAL BENEFITS.qnty ) {&tabulation}
      excel-sum  ( ACCUM TOTAL (BENEFITS.qnty * BENEFITS.PRICE-BASE) ) {&tabulation}
      excel-sum  ( ACCUM TOTAL (BENEFITS.qnty * BENEFITS.PRICE-NETTo) ) {&tabulation}
      excel-sum  ( ACCUM TOTAL (BENEFITS.qnty * BENEFITS.DISCNT) )
      SKIP.
    END.
  END. /*FOR EACH benefits*/
  {&CloseExcel}
  run  get-report-num in my-handle (output g#report-num).
  run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
assign frame {&frame-name} SumsOnly .
/* { rep/claslabl.i }*/

 ReportNAme = "Отчет по скидкам по реализации в магазине".
 ReportHeader = (if SumsOnly then "Только итоги "  else " " )  .
 if X-SET_PAY_TYPE <> 2 then str3 =  "в ценах РЕАЛИЗАЦИИ".
 str1 = "за период с: " + string(x-date-start,"99/99/9999") + "г. по: "  + string(x-date-end,"99/99/9999") + "г." .
 str2 = "" .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

