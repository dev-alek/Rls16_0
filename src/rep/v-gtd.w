&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-suppl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-suppl
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по ГТД

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

DEFINE INPUT PARAMETER ParParentProc AS   WIDGET-HANDLE     NO-UNDO.
DEFINE INPUT PARAMETER parcst-code   LIKE ub.parts.cst-code NO-UNDO.
DEFINE INPUT PARAMETER pardate       AS   DATE              NO-UNDO.
DEFINE INPUT PARAMETER parcst-units  AS   CHARACTER         NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по ГТД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ str/libbcrcn.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }

DEFINE VARIABLE p-host-code AS INTEGER   NO-UNDO.
DEFINE VARIABLE p-obj-type  AS CHARACTER NO-UNDO.
DEFINE VARIABLE p-obj-code  AS INTEGER   NO-UNDO.

DEFINE TEMP-TABLE gds-brutto NO-UNDO
    FIELD artic         LIKE ub.goods.artic
    FIELD prod-type     LIKE ub.parts.prod-type
    FIELD prod-code     LIKE ub.parts.prod-code
    FIELD gds-name      LIKE ub.goods.gds-name
    FIELD unit          LIKE ub.goods.unit-base
    FIELD tnved         LIKE ub.goods.tnved
    FIELD in-qnty       LIKE ub.parts.fact-qnty
    FIELD out-qnty      LIKE ub.parts.fact-qnty
    FIELD spi-qnty      LIKE ub.parts.fact-qnty
    INDEX art IS PRIMARY artic ASCENDING
    .
DEFINE BUFFER l-gds-brutto FOR gds-brutto.
DEFINE BUFFER in-doc FOR ub.trn-doc.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.                  /* тип параметра конфигурации */
define variable in-out-spi-qnty like ub.parts.fact-qnty no-undo.
define variable v-line-rec as recid no-undo .
DEFINE BUFFER out-parts FOR ub.parts.
DEFINE BUFFER spi-parts FOR ub.parts.
DEFINE BUFFER out-doc FOR ub.trn-doc.
DEFINE BUFFER spi-doc FOR ub.trn-doc.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME v-suppl
&Scoped-define BROWSE-NAME br-gds-brutto

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES gds-brutto

/* Definitions for BROWSE br-gds-brutto                                 */
&Scoped-define FIELDS-IN-QUERY-br-gds-brutto gds-brutto.artic gds-brutto.gds-name gds-brutto.unit gds-brutto.in-qnty gds-brutto.out-qnty gds-brutto.spi-qnty gds-brutto.in-qnty - gds-brutto.out-qnty - gds-brutto.spi-qnty @ in-out-spi-qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-gds-brutto
&Scoped-define FIELD-PAIRS-IN-QUERY-br-gds-brutto
&Scoped-define SELF-NAME br-gds-brutto
&Scoped-define OPEN-QUERY-br-gds-brutto OPEN QUERY {&SELF-NAME} FOR EACH gds-brutto.
&Scoped-define TABLES-IN-QUERY-br-gds-brutto gds-brutto
&Scoped-define FIRST-TABLE-IN-QUERY-br-gds-brutto gds-brutto


/* Definitions for DIALOG-BOX v-suppl                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-suppl ~
    ~{&OPEN-QUERY-br-gds-brutto}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS a-n-c br-gds-brutto b-excel b-print b-help ~
b-quit
&Scoped-Define DISPLAYED-OBJECTS a-n-c

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-excel DEFAULT
     LABEL "Excel"
     size 9 by 1.

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     size 10 by 1.

DEFINE BUTTON b-print DEFAULT
     LABEL "Пе&чать"
     size 10 by 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "Вы&ход "
     size 10 by 1
     BGCOLOR 8 .

DEFINE VARIABLE loc-art AS CHARACTER FORMAT "X(16)":U
     LABEL "Начало артикула"
     VIEW-AS FILL-IN
     size 17 by 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-code AS CHARACTER FORMAT "X(13)":U
     LABEL "Бар-код (весь)"
     VIEW-AS FILL-IN
     size 14 by 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE loc-name AS CHARACTER FORMAT "X(50)":U
     LABEL "Начало названия"
     VIEW-AS FILL-IN
     size 20 by 1
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     size 15 by 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-gds-brutto FOR
      gds-brutto SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gds-brutto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gds-brutto v-suppl _FREEFORM
  QUERY br-gds-brutto DISPLAY
      gds-brutto.artic         COLUMN-LABEL "Артикул! "
gds-brutto.gds-name      COLUMN-LABEL "Название товара! " FORMAT "x(25)"
gds-brutto.unit          COLUMN-LABEL "Ед.!Изм." FORMAT "X(5)"
gds-brutto.in-qnty       COLUMN-LABEL "Приход!количество" FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-qnty      COLUMN-LABEL "Реализация!количество" FORMAT "->,>>>,>>9.<<<"
gds-brutto.spi-qnty      COLUMN-LABEL "Списание!количество" FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-qnty - gds-brutto.out-qnty - gds-brutto.spi-qnty @
in-out-spi-qnty          COLUMN-LABEL "Остаток!количествo" FORMAT "->,>>>,>>9.<<<"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97 BY 11.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-suppl
     a-n-c at row 2.5 col 2 NO-LABEL
     loc-name at row 2.5 col 33.5 COLON-ALIGNED
     br-gds-brutto AT ROW 3.71 COL 1.38
     b-excel at row 1.17 col 33.25
     b-print at row 1.17 col 12
     b-help at row 1.17 col 22.5
     b-quit at row 1.17 col 2
     loc-code at row 2.5 col 33.5 COLON-ALIGNED
     loc-art at row 2.5 col 33.5 COLON-ALIGNED
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D
         size 98.88 by 15.79
         TITLE "".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-suppl
                                                                        */
/* BROWSE-TAB br-gds-brutto loc-name v-suppl */
ASSIGN
       FRAME v-suppl:SCROLLABLE       = FALSE
       FRAME v-suppl:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN loc-art IN FRAME v-suppl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       loc-art:HIDDEN IN FRAME v-suppl           = TRUE.

/* SETTINGS FOR FILL-IN loc-code IN FRAME v-suppl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       loc-code:HIDDEN IN FRAME v-suppl           = TRUE.

/* SETTINGS FOR FILL-IN loc-name IN FRAME v-suppl
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       loc-name:HIDDEN IN FRAME v-suppl           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-gds-brutto
/* Query rebuild information for BROWSE br-gds-brutto
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH gds-brutto.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-gds-brutto */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX v-suppl
/* Query rebuild information for DIALOG-BOX v-suppl
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX v-suppl */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-suppl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-suppl v-suppl
ON WINDOW-CLOSE OF FRAME v-suppl
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-excel v-suppl
ON CHOOSE OF b-excel IN FRAME v-suppl /* Excel */
DO:
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE.
DEFINE VARIABLE chWorkbook              AS COM-HANDLE.
DEFINE VARIABLE chWorksheet             AS COM-HANDLE.
DEFINE VARIABLE iColumn                 AS INTEGER INITIAL 1.
DEFINE VARIABLE cColumn                 AS CHARACTER.
DEFINE VARIABLE cRange                  AS CHARACTER.
/* create a new Excel Application object */
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        return no-apply .
    end.
/* launch Excel so it is visible to the user */
chExcelApplication:Visible = TRUE.
/* create a new Workbook */
chWorkbook = chExcelApplication:Workbooks:Add().
/* get the active Worksheet */
chWorkSheet = chExcelApplication:Sheets:Item(1).
/* set the column names for the Worksheet */
chWorkSheet:Columns("A":U):ColumnWidth = 17.
chWorkSheet:Columns("B":U):ColumnWidth = 10.
chWorkSheet:Columns("C":U):ColumnWidth = 16.
chWorkSheet:Columns("D":U):ColumnWidth = 40.
chWorkSheet:Columns("E":U):ColumnWidth = 3.
chWorkSheet:Columns("F":U):ColumnWidth = 16.
chWorkSheet:Columns("G":U):ColumnWidth = 15.
chWorkSheet:Columns("H":U):ColumnWidth = 15.
chWorkSheet:Columns("I":U):ColumnWidth = 15.
chWorkSheet:Range("A1:I1"):Font:Bold = TRUE.

chWorkSheet:Range("A1":U):Value = "Номер по порядку".
chWorkSheet:Range("B1":U):Value = "ТаможКод".
chWorkSheet:Range("C1":U):Value = "Артикул".
chWorkSheet:Range("D1":U):Value = "Торговое наименование".
chWorkSheet:Range("E1":U):Value = "Ед".
chWorkSheet:Range("F1":U):Value = "Общее количество".
chWorkSheet:Range("G1":U):Value = "Реализовано".
chWorkSheet:Range("H1":U):Value = "Списано".
chWorkSheet:Range("I1":U):Value = "Остаток".
FOR EACH gds-brutto:
    iColumn = iColumn + 1.
    cColumn = STRING(iColumn).
    cRange = "A":U + cColumn.
    chWorkSheet:Range(cRange):Value = iColumn - 1.
    cRange = "B":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.tnved.
    cRange = "C":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.artic.
    cRange = "D":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.gds-name.
    cRange = "E":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.unit.
    cRange = "F":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.in-qnty.
    cRange = "G":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.out-qnty.
    cRange = "H":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.spi-qnty.
    cRange = "I":U + cColumn.
    chWorkSheet:Range(cRange):Value = gds-brutto.in-qnty - gds-brutto.out-qnty - gds-brutto.spi-qnty.
END.
/* release com-handles */
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print v-suppl
ON CHOOSE OF b-print IN FRAME v-suppl /* Печать */
DO:
define variable num-order as int no-undo.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.
define variable sym8 as char init ":"   no-undo.
define variable sym9 as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.

define variable Line as char no-undo.
define variable varTemp as char no-undo.

DEFINE FRAME gds-brutto
      sym1 column-label ":!:" format "X(1)"
      num-order COLUMN-LABEL "Номер по!порядку "
      sym2 column-label ":!:" format "X(1)"
      gds-brutto.tnved COLUMN-LABEL "Таможенный!код"
      sym3 column-label ":!:" format "X(1)"
      gds-brutto.artic COLUMN-LABEL "Артикул"
      sym4 column-label ":!:" format "X(1)"
      gds-brutto.gds-name COLUMN-LABEL "Торговое!наименование!"
      sym5 column-label ":!:" format "X(1)"
      gds-brutto.unit COLUMN-LABEL "ЕдИзм"
      sym6 column-label ":!:" format "X(1)"
      gds-brutto.in-qnty COLUMN-LABEL "Общее!кол-во"
      sym7 column-label ":!:" format "X(1)"
      gds-brutto.out-qnty COLUMN-LABEL "Реализовано"
      sym8 column-label ":!:" format "X(1)"
      gds-brutto.spi-qnty COLUMN-LABEL "Списано"
      sym9 column-label ":!:" format "X(1)"
      in-out-spi-qnty COLUMN-LABEL "Остаток"
      sym10 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет по ГТД: " + parcst-code) AT 45 format "X(50)"
        string( "Количества указаны в " + (if parcst-units = "Базовая" then "базовых еденицах." else "таможенных еденицах.") ) AT 100 format "X(42)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(169)" AT 1
    with width {&DOS_CW_2} down stream-io.

if session:set-wait-state("COMPILER") then.

assign Line = fill("-", {&DOS_CW_2}).

run prn-lib-open-stream in this-procedure ( input ParParentProc, input {&LS_PS_A4}, input yes, input no ).

FORM with FRAME gds-brutto .

FORM HEADER
    Line format "X(169)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .

PUT STREAM PrnLibStream
    string( "Отчет за дату: " + string(pardate,"99/99/9999"))
    AT 37 format "X(169)" SKIP(1).
    ASSIGN num-order = 0.

FOR EACH gds-brutto:
      ASSIGN num-order = num-order + 1.
      DISPLAY STREAM PrnLibStream
      sym1
      num-order
      sym2
      gds-brutto.tnved
      sym3
      gds-brutto.artic
      sym4
      gds-brutto.gds-name
      sym5
      gds-brutto.unit
      sym6
      gds-brutto.in-qnty
      sym7
      gds-brutto.out-qnty
      sym8
      gds-brutto.spi-qnty
      sym9
      gds-brutto.in-qnty - gds-brutto.out-qnty - gds-brutto.spi-qnty @ in-out-spi-qnty
      sym10
      with FRAME gds-brutto .
      DOWN STREAM PrnLibStream 1 with FRAME gds-brutto  .
END.
PUT STREAM PrnLibStream Line format "X(169)" SKIP.
DOWN STREAM PrnLibStream 1 with FRAME gds-brutto  .

HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.

if session:set-wait-state("") then.

run prn-lib-prn-file in this-procedure ( input ParParentProc, input 0 ).

APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gds-brutto
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-suppl
{ gbl/app_help.i }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

&scop where-cond
&glob sch-rec v-line-rec
&glob store-type p-obj-type
&glob store-code p-obj-code
{ str/sch-line.i gds-brutto br-gds-brutto v-line-rec }
end.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/getcntxt.i get }

  assign
    p-host-code = v-cntxt-host-code-obj
    p-obj-type  = v-cntxt-obj-type
    p-obj-code  = v-cntxt-obj-code
  .

  RUN calc        IN THIS-PROCEDURE.
  RUN enable_UI   IN THIS-PROCEDURE.
  FRAME {&FRAME-NAME}:TITLE = string( "Отчет о товарах по заданной ГТД №" + parcst-code + " за дату " + string(pardate,"99/99/9999")).
  apply "entry" to br-gds-brutto in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc v-suppl
PROCEDURE calc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
if session:set-wait-state("COMPILER") then.
run waitfram-show in this-procedure
  (input "Подождите..."
  ).
FOR EACH ub.trn-doc WHERE ub.trn-doc.host-code = p-host-code AND
                       ub.trn-doc.doc-type  = {&income}   AND
                       NOT trn-doc.internal  NO-LOCK,
       /*Идя по линиям, идем по товарам*/
       EACH ub.doc-line WHERE ub.doc-line.doc-code = ub.trn-doc.doc-code NO-LOCK,
        FIRST ub.goods WHERE ub.goods.artic     = ub.doc-line.artic     AND
                          ub.goods.prod-type = ub.doc-line.prod-type AND
                          ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK,
          /*Проходим по всем приходным партиям*/
          EACH ub.parts WHERE ub.parts.host-code =  ub.trn-doc.host-code AND
                           ub.parts.in-code   =  ub.trn-doc.doc-code  AND
                           ub.parts.artic     =  ub.goods.artic       AND
                           ub.parts.prod-code =  ub.goods.prod-code   AND
                           ub.parts.prod-type =  ub.goods.prod-type   AND
                           ub.parts.in-code   =  ub.parts.out-code    AND
                           ub.parts.status_   =  yes               AND
                           ub.parts.fact-date <= parDate           AND
                           ub.parts.cst-code  =  parcst-code       NO-LOCK
                           BREAK BY trn-doc.doc-code
                                 BY doc-line.artic:

             FIND FIRST gds-brutto WHERE gds-brutto.artic = ub.parts.artic NO-ERROR.
             IF NOT AVAILABLE gds-brutto THEN DO:
                CREATE gds-brutto.
                ASSIGN
                       gds-brutto.artic     = ub.goods.artic
                       gds-brutto.prod-type = ub.parts.prod-type
                       gds-brutto.prod-code = ub.parts.prod-code
                       gds-brutto.gds-name    = ub.goods.gds-name
                       gds-brutto.tnved     = ub.goods.tnved
                       gds-brutto.unit      = ub.goods.unit-base
                       gds-brutto.unit      = (IF parcst-units = "Базовая" THEN ub.goods.unit-base ELSE ub.goods.unit-cst)
                       .
             END.
             ASSIGN gds-brutto.in-qnty = gds-brutto.in-qnty +
             ABSOLUTE(IF parcst-units = "Базовая" THEN ub.parts.fact-qnty ELSE ub.parts.fact-qnty * ub.goods.cst-base-rate).

             IF LAST-OF(doc-line.artic) THEN DO:
                /*Пройдемся по партиям внешних расходам и внешних возвратах по данной накладной*/
                FOR EACH out-parts WHERE out-parts.host-code = ub.parts.host-code AND
                                         out-parts.artic     = ub.parts.artic     AND
                                         out-parts.prod-type = ub.parts.prod-type AND
                                         out-parts.prod-code = ub.parts.prod-code AND
                                         out-parts.in-code   = ub.parts.in-code   AND
                                         out-parts.status_   = yes             AND
                                         out-parts.fact-date <= parDate NO-LOCK,
                    FIRST out-doc where out-doc.doc-code = out-parts.out-code AND
                                        NOT out-doc.internal  AND
                                        (out-doc.doc-type = {&expense} OR
                                         out-parts.doc-type = {&return}) NO-LOCK:
                    ACCUMULATE ABSOLUTE(out-parts.fact-qnty) (TOTAL).
                 END.
                /*Пройдемся по внешним списаниям данной накладной*/
                FOR EACH spi-parts WHERE spi-parts.host-code = ub.parts.host-code AND
                                         spi-parts.artic     = ub.parts.artic     AND
                                         spi-parts.prod-type = ub.parts.prod-type AND
                                         spi-parts.prod-code = ub.parts.prod-code AND
                                         spi-parts.in-code   = ub.parts.in-code   AND
                                         spi-parts.status_   = yes             AND
                                         spi-parts.fact-date <= parDate NO-LOCK,
                    FIRST spi-doc where spi-doc.doc-code = spi-parts.out-code AND
                                        NOT spi-doc.internal  AND
                                        spi-doc.doc-type = {&write-off} NO-LOCK:
                    ACCUMULATE ABSOLUTE(spi-parts.fact-qnty) (TOTAL).
                END.
             END.
             ASSIGN gds-brutto.out-qnty = gds-brutto.out-qnty +
                    ABSOLUTE(IF parcst-units = "Базовая" THEN (ACCUM TOTAL ABSOLUTE(out-parts.fact-qnty)) ELSE (ACCUM TOTAL ABSOLUTE(out-parts.fact-qnty)) * goods.cst-base-rate)
                    gds-brutto.spi-qnty = gds-brutto.spi-qnty +
                    ABSOLUTE(IF parcst-units = "Базовая" THEN (ACCUM TOTAL ABSOLUTE(spi-parts.fact-qnty)) ELSE (ACCUM TOTAL ABSOLUTE(spi-parts.fact-qnty)) * goods.cst-base-rate).
END.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI v-suppl _DEFAULT-DISABLE
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
  HIDE FRAME v-suppl.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI v-suppl _DEFAULT-ENABLE
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
  DISPLAY a-n-c
      WITH FRAME v-suppl.
  ENABLE a-n-c br-gds-brutto b-excel b-print b-help b-quit
      WITH FRAME v-suppl.
  VIEW FRAME v-suppl.
  {&OPEN-BROWSERS-IN-QUERY-v-suppl}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME