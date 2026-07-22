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

Таможенный отчет

Автор: Суслов Алексей Юрьевич
Дата создания: 09/19/05
Author: Alexey Suslov
Creation date: 09/19/05


*/

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter parobj-type  like ub.parts.obj-type no-undo.
define input parameter parobj-code  like ub.parts.obj-code no-undo.
define input parameter from-date    as date no-undo .
define input parameter to-date      as date no-undo .
define input parameter partnved     as character        no-undo.
define input parameter parcst-units as character        no-undo.
define input parameter parkindrep   as character        no-undo.


def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Таможенный отчет".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i  }
{ cmp/t-tnved.i  }
{ rep/v-cst.i  new }
{ str/libbcrcn.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }

define variable line-rec as recid no-undo .
&SCOPED-DEFINE out-exp   (parts.doc-type = {&expense} OR ~
                          parts.doc-type = {&write-off} OR ~
                         (parts.doc-type = {&inventory} AND parts.fact-qnty < 0))


/* ***************************  Definitions  ************************** */


IF partnved = "Всё" THEN ASSIGN partnved = "".
/* Local Variable Definitions ---                                       */

DEFINE BUFFER l-gds-brutto FOR gds-brutto.
DEFINE BUFFER in-doc FOR ub.trn-doc.
DEFINE BUFFER in-line FOR ub.doc-line.

def var conf-par as char no-undo.                  /* для чтения параметра конфигурации */
def var par-type as char no-undo.                  /* тип параметра конфигурации */
def var in-out-qnty like ub.parts.fact-qnty no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .

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
&Scoped-define FIELDS-IN-QUERY-br-gds-brutto gds-brutto.artic gds-brutto.gds-name gds-brutto.cst-code gds-brutto.unit gds-brutto.in-qnty gds-brutto.in-wt-brutto gds-brutto.in-fact-place gds-brutto.out-qnty gds-brutto.out-wt-brutto gds-brutto.out-fact-place gds-brutto.in-qnty - gds-brutto.out-qnty
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
&Scoped-Define ENABLED-OBJECTS b-excel b-print b-help b-quit b-parts a-n-c ~
br-gds-brutto
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
     size 9 by 1.

DEFINE BUTTON b-parts DEFAULT
     LABEL "&Детализация"
     size 12 by 1.

DEFINE BUTTON b-print DEFAULT
     LABEL "Пе&чать"
     size 9 by 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "Вы&ход "
     size 9 by 1
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
gds-brutto.gds-name      COLUMN-LABEL "Название товара! "
gds-brutto.cst-code      COLUMN-LABEL "Номер ГТД" FORMAT "X(31)"
gds-brutto.unit          COLUMN-LABEL "Ед.!Изм." FORMAT "X(5)"
gds-brutto.in-qnty       COLUMN-LABEL "Приход! количество"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-wt-brutto  COLUMN-LABEL "Приход! вес брутто"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-fact-place COLUMN-LABEL "Приход! кол-во мест"  FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-qnty      COLUMN-LABEL "Расход! количество"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-wt-brutto COLUMN-LABEL "Расход! вес брутто"   FORMAT "->,>>>,>>9.<<<"
gds-brutto.out-fact-place COLUMN-LABEL "Расход! кол-во мест" FORMAT "->,>>>,>>9.<<<"
gds-brutto.in-qnty - gds-brutto.out-qnty COLUMN-LABEL "Остаток! по приходу"  FORMAT "->,>>>,>>9.<<<"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 97.13 BY 11.75.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-suppl
     b-excel at row 1.17 col 45
     b-print at row 1.17 col 12
     b-help at row 1.17 col 35
     b-quit at row 1.17 col 2
     loc-art at row 2.5 col 33.5 COLON-ALIGNED
     b-parts at row 1.17 col 22
     a-n-c at row 2.5 col 2 NO-LABEL
     loc-code at row 2.5 col 33.5 COLON-ALIGNED
     loc-name at row 2.5 col 33.5 COLON-ALIGNED
     br-gds-brutto AT ROW 3.71 COL 1.38
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
chWorkSheet:Columns("B":U):ColumnWidth = 15.
chWorkSheet:Columns("C":U):ColumnWidth = 22.
chWorkSheet:Columns("D":U):ColumnWidth = 10.
chWorkSheet:Columns("E":U):ColumnWidth = 16.
chWorkSheet:Columns("F":U):ColumnWidth = 40.
chWorkSheet:Columns("G":U):ColumnWidth = 20.
chWorkSheet:Columns("H":U):ColumnWidth = 3.
chWorkSheet:Columns("I":U):ColumnWidth = 25.
chWorkSheet:Columns("J":U):ColumnWidth = 25.
chWorkSheet:Columns("K":U):ColumnWidth = 25.
chWorkSheet:Columns("L":U):ColumnWidth = 25.
chWorkSheet:Columns("M":U):ColumnWidth = 10.
chWorkSheet:Columns("N":U):ColumnWidth = 25.
chWorkSheet:Columns("O":U):ColumnWidth = 25.
chWorkSheet:Columns("P":U):ColumnWidth = 25.
chWorkSheet:Columns("Q":U):ColumnWidth = 25.
chWorkSheet:Columns("R":U):ColumnWidth = 25.
chWorkSheet:Columns("S":U):ColumnWidth = 25.

chWorkSheet:Range("A1:S1"):Font:Bold = TRUE.
chWorkSheet:Range("A1"):Value = "Номер по порядку".
chWorkSheet:Range("B1"):Value = "Дата поступления".
chWorkSheet:Range("C1"):Value = "ГТД".
chWorkSheet:Range("D1"):Value = "ТаможКод".
chWorkSheet:Range("E1"):Value = "Артикул".
chWorkSheet:Range("F1"):Value = "Наименование товара".
chWorkSheet:Range("G1"):Value = "Статус товара".
chWorkSheet:Range("H1"):Value = "Ед".
chWorkSheet:Range("I1"):Value = "Кол-во ед. при поступлении".
chWorkSheet:Range("J1"):Value = "Кол-во уп. при поступлении".
chWorkSheet:Range("K1"):Value = "Вес при поступлении".
chWorkSheet:Range("L1"):Value = "Кол-во мест при поступлении".
chWorkSheet:Range("M1"):Value = "Дата выбытия".
chWorkSheet:Range("N1"):Value = "Кол-во ед. при выбытии".
chWorkSheet:Range("O1"):Value = "Кол-во уп. при выбытии".
chWorkSheet:Range("P1"):Value = "Вес при выбытии".
chWorkSheet:Range("Q1"):Value = "Кол-во мест при выбытии".
chWorkSheet:Range("R1"):Value = "Остаток".
chWorkSheet:Range("S1"):Value = "Примечание".
FOR EACH prt-parts-brutto:
  iColumn = iColumn + 1.
  cColumn = STRING(iColumn).
  cRange = "A":U + cColumn.
  chWorkSheet:Range(cRange):Value = iColumn - 1.
  cRange = "B":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-date.
  cRange = "C":U + cColumn.
  chWorkSheet:Range(cRange):NumberFormat = "@" .
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.cst-code.
  cRange = "D":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.tnved.
  cRange = "E":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.artic.
  cRange = "F":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.gds-name.
  cRange = "G":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.nationality.
  cRange = "H":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.unit.
  cRange = "I":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-qnty.
  cRange = "J":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-qnty-up.
  cRange = "K":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-wt-brutto.
  cRange = "L":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.in-fact-place.
  cRange = "M":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-date.
  cRange = "M":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-qnty.
  cRange = "N":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-qnty-up.
  cRange = "O":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-wt-brutto.
  cRange = "P":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.out-fact-place.
  cRange = "R":U + cColumn.
  chWorkSheet:Range(cRange):Value = decimal(prt-parts-brutto.in-qnty) - decimal(prt-parts-brutto.out-qnty).
  cRange = "S":U + cColumn.
  chWorkSheet:Range(cRange):Value = prt-parts-brutto.des.

END.
/* release com-handles */
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts v-suppl
ON CHOOSE OF b-parts IN FRAME v-suppl /* Детализация */
DO:
  if available gds-brutto then
  run rep/v-cst-dt.w (input from-date, input to-date, input gds-brutto.cst-code, input gds-brutto.artic).
  APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print v-suppl
ON CHOOSE OF b-print IN FRAME v-suppl /* Печать */
DO:
def var num-order as int no-undo.
def var sym1 as char init ":"   no-undo.
def var sym2 as char init ":"   no-undo.
def var sym3 as char init ":"   no-undo.
def var sym4 as char init ":"   no-undo.
def var sym5 as char init ":"   no-undo.
def var sym6 as char init ":"   no-undo.
def var sym7 as char init ":"   no-undo.
def var sym8 as char init ":"   no-undo.
def var sym9 as char init ":"   no-undo.
def var sym10 as char init ":"   no-undo.
def var sym11 as char init ":"   no-undo.
def var sym12 as char init ":"   no-undo.
def var sym13 as char init ":"   no-undo.
def var sym14 as char init ":"   no-undo.
def var sym15 as char init ":"   no-undo.

def var Line as char no-undo.
def var varTemp as char no-undo.

DEFINE FRAME gds-brutto-store
      sym1 column-label ":!:" format "X(1)"
      num-order COLUMN-LABEL "Номер по!порядку "
      sym2 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-date COLUMN-LABEL "Поступ! на склад"
      sym3 column-label ":!:" format "X(1)"
      prt-parts-brutto.cst-code COLUMN-LABEL "Номер!ГТД" FORMAT "X(31)"
      sym4 column-label ":!:" format "X(1)"
      prt-parts-brutto.tnved COLUMN-LABEL "Тамож.код"
      sym5 column-label ":!:" format "X(1)"
      prt-parts-brutto.gds-name format "x(25)" COLUMN-LABEL "Таможенное название!"
      sym6 column-label ":!:" format "X(1)"
      prt-parts-brutto.artic COLUMN-LABEL "Артикул"
      sym7 column-label ":!:" format "X(1)"
      prt-parts-brutto.nationality COLUMN-LABEL "Статус!товара"
      sym8 column-label ":!:" format "X(1)"
      prt-parts-brutto.unit COLUMN-LABEL "ЕдИзм"
      sym9 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-qnty COLUMN-LABEL "Кол-во пост."
      sym10 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-wt-brutto COLUMN-LABEL "Вес брутто! пост."
      sym11 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-date  COLUMN-LABEL "Дата! выпуска"
      sym12 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-qnty COLUMN-LABEL "Кол-во вып."
      sym13 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-wt-brutto  COLUMN-LABEL "Вес брутто! вып."
      sym14 column-label ":!:" format "X(1)"
      varTemp format "X(2)" column-label "Прим"
      sym15 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет по таможенной позиции: " + partnved) AT 45 format "X(40)"
        string( "Количества указаны в " + (if parcst-units = "Базовая" then "базовых еденицах." else "таможенных еденицах.") ) AT 100 format "X(42)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(229)" AT 1
    with width {&DOS_CW_2} down stream-io.

DEFINE FRAME gds-brutto-shop
      sym1 column-label ":!:" format "X(1)"
      num-order COLUMN-LABEL "Номер по!порядку "
      sym2 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-date COLUMN-LABEL "Дата пост! в магазин"
      sym3 column-label ":!:" format "X(1)"
      prt-parts-brutto.cst-code COLUMN-LABEL "Номер!ГТД" FORMAT "X(31)"
      sym4 column-label ":!:" format "X(1)"
      prt-parts-brutto.tnved COLUMN-LABEL "Тамож. код"
      sym5 column-label ":!:" format "X(1)"
      prt-parts-brutto.artic COLUMN-LABEL "Артикул"
      sym6 column-label ":!:" format "X(1)"
      prt-parts-brutto.gds-name FORMAT "X(25)" COLUMN-LABEL "Таможенное название!"
      sym7 column-label ":!:" format "X(1)"
      prt-parts-brutto.nationality COLUMN-LABEL "Статус!товара"
      sym8 column-label ":!:" format "X(1)"
      prt-parts-brutto.unit COLUMN-LABEL "ЕдИзм"
      sym9 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-qnty COLUMN-LABEL "Кол-во пост."
      sym10 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-fact-place COLUMN-LABEL "Кол-во мест"
      sym11 column-label ":!:" format "X(1)"
      prt-parts-brutto.in-wt-brutto COLUMN-LABEL "Вес брутто в кг"
      sym12 column-label ":!:" format "X(1)"
      prt-parts-brutto.out-qnty COLUMN-LABEL "Реализовано"
      sym13 column-label ":!:" format "X(1)"
      in-out-qnty COLUMN-LABEL "Остаток"
      sym14 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет по таможенной позиции: " + partnved) AT 45 format "X(40)"
        string( "Количества указаны в " + (if parcst-units = "Базовая" then "базовых еденицах." else "таможенных еденицах.") ) AT 100 format "X(42)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 150 format "X(13)" SKIP
        Line format "X(229)" AT 1
    with width {&DOS_CW_2} down stream-io.
if session:set-wait-state("COMPILER") then.

assign Line = fill("-", {&DOS_CW_2}).
if parkindrep = "OUT" THEN DO:
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
   FORM with FRAME gds-brutto-store.
END.
ELSE DO:
  run prn-lib-open-stream  in this-procedure (
                                              input parParentProc
                                              ,input {&LS_PS_A4}
                                              ,input yes /*p-is-stream*/
                                              ,input no /*p-append*/
                                              ).
     FORM with FRAME gds-brutto-shop.
END.

FORM HEADER
    Line format "X(229)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .

PUT STREAM PrnLibStream
    string( "Отчет за период с: " + string(from-date,"99/99/9999") + " по: " + string(to-date,"99/99/9999"))
    AT 37 format "X(229)" SKIP(1).
    ASSIGN num-order = 0.

FOR EACH prt-parts-brutto:
      ASSIGN num-order = num-order + 1.
      if parkindrep = "OUT" THEN DO:
         DISPLAY STREAM PrnLibStream
         sym1
         num-order
         sym2
         prt-parts-brutto.in-date
         sym3
         prt-parts-brutto.cst-code
         sym4
         prt-parts-brutto.tnved
         sym5
         prt-parts-brutto.gds-name
         sym6
         prt-parts-brutto.artic
         sym7
         prt-parts-brutto.nationality
         sym8
         prt-parts-brutto.unit
         sym9
         prt-parts-brutto.in-qnty
         sym10
         prt-parts-brutto.in-wt-brutto
         sym11
         prt-parts-brutto.out-date
         sym12
         prt-parts-brutto.out-qnty
         sym13
         prt-parts-brutto.out-wt-brutto
         sym14
         varTemp
         sym15
         with FRAME gds-brutto-store.
         DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-store .
      END.
      ELSE DO:
         DISPLAY STREAM PrnLibStream
         sym1
         num-order
         sym2
         prt-parts-brutto.in-date
         sym3
         prt-parts-brutto.cst-code
         sym4
         prt-parts-brutto.tnved
         sym5
         prt-parts-brutto.artic
         sym6
         prt-parts-brutto.gds-name
         sym7
         prt-parts-brutto.nationality
         sym8
         prt-parts-brutto.unit
         sym9
         prt-parts-brutto.in-qnty
         sym10
         prt-parts-brutto.in-fact-place
         sym11
         prt-parts-brutto.in-wt-brutto
         sym12
         prt-parts-brutto.out-qnty
         sym13
         STRING(DECIMAL(prt-parts-brutto.in-qnty) -
         DECIMAL(prt-parts-brutto.out-qnty)) @ in-out-qnty
         sym14
         with FRAME gds-brutto-shop.
         DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-shop.
      END.
END.
IF parkindrep = "OUT" THEN DO:
   PUT STREAM PrnLibStream Line format "X(229)" SKIP.
   DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-store .
END.
ELSE DO:
    PUT STREAM PrnLibStream Line format "X(229)" SKIP.
    DOWN STREAM PrnLibStream 1 with FRAME gds-brutto-shop .
END.

HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.

if session:set-wait-state("") then.
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gds-brutto
&Scoped-define SELF-NAME br-gds-brutto
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gds-brutto v-suppl
ON MOUSE-SELECT-DBLCLICK OF br-gds-brutto IN FRAME v-suppl
DO:
  APPLY "CHOOSE" TO b-parts IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gds-brutto v-suppl
ON RETURN OF br-gds-brutto IN FRAME v-suppl
DO:
  APPLY "CHOOSE" TO b-parts IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-suppl


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

&scop where-cond
&scop sch-rec line-rec
&scop store-type parobj-type
&scop store-code parobj-code
{ str/sch-line.i gds-brutto br-gds-brutto }
end.
{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   { gbl/hostcode.i parobj-type parobj-code v-host-code }
   IF parobj-type = "all" THEN DO:
      for each ub.store where ub.store.host-code = v-host-code no-lock:
          RUN calc (input {&stock}, input ub.store.obj-code) no-error.
          IF ERROR-STATUS:ERROR THEN RETURN ERROR.
      end.
      for each ub.shop where ub.shop.host-code = v-host-code no-lock:
          RUN calc (input {&shop}, input ub.shop.obj-code) no-error.
          IF ERROR-STATUS:ERROR THEN RETURN ERROR.
      end.
  END.
  ELSE RUN calc (input parobj-type, input parobj-code) no-error.

  RUN enable_UI.
  IF parobj-type = "all" THEN
  FRAME {&FRAME-NAME}:TITLE =  "Сводный отчет c: " + string(from-date,"99/99/9999") +
                               " по: " + string(to-date,"99/99/9999").
  ELSE IF parkindrep = "OUT" THEN
  FRAME {&FRAME-NAME}:TITLE =  "Книга учета товаров на объекте:" + parobj-type + " " + STRING(parobj-code) +
                               " c: " + string(from-date,"99/99/9999") +
                               " по: " + string(to-date,"99/99/9999").
  ELSE
  FRAME {&FRAME-NAME}:TITLE =  "Отчет о поступлении и реализации товаров:" + parobj-type + " " + STRING(parobj-code) +
                               " c: " + string(from-date,"99/99/9999") +
                               " по: " + string(to-date,"99/99/9999").
  apply "entry" to br-gds-brutto in frame {&frame-name}.

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE bef-parts v-suppl
PROCEDURE bef-parts :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER basis-parts-type AS CHARACTER NO-UNDO.
FOR EACH bf-parts-brutto WHERE parts-brutto.part-type = basis-parts-type
    NO-LOCK BREAK BY bf-parts-brutto.host-code
                  BY bf-parts-brutto.obj-code
                  BY bf-parts-brutto.obj-type
                  BY bf-parts-brutto.artic
                  BY bf-parts-brutto.prod-code
                  BY bf-parts-brutto.prod-type
                  BY bf-parts-brutto.in-code:
    IF FIRST-OF(bf-parts-brutto.in-code) THEN DO:
       FOR EACH ub.parts WHERE  ub.parts.host-code  = bf-parts-brutto.host-code
                         AND ub.parts.obj-code   = bf-parts-brutto.obj-code
                         AND ub.parts.obj-type   = bf-parts-brutto.obj-type
                         AND ub.parts.artic      = bf-parts-brutto.artic
                         AND ub.parts.prod-code  = bf-parts-brutto.prod-code
                         AND ub.parts.prod-type  = bf-parts-brutto.prod-type
                         AND ub.parts.status_    = yes
                         AND ub.parts.fact-date  < from-date
                         AND ub.parts.in-code    = bf-parts-brutto.in-code
                         AND ub.parts.doc-type <> {&act-overvalue}
                         NO-LOCK:
              /*Ищем внешнюю приходную накладную*/
              find first in-doc where in-doc.doc-code  = ub.parts.in-code no-lock no-error.
              IF AVAILABLE in-doc THEN DO:
                 FIND FIRST in-line WHERE in-line.doc-code  = in-doc.doc-code AND
                                          in-line.artic     = parts.artic     AND
                                          in-line.prod-code = parts.prod-code AND
                                          in-line.prod-type = parts.prod-type NO-LOCK NO-ERROR.
                 IF NOT AVAILABLE in-line THEN DO:
                    MESSAGE "Во внешней приходной накладной:" in-doc.doc-code SKIP
                            "Не найдена строка по товару:" parts.artic " " parts.prod-code " " parts.prod-type SKIP
                    VIEW-AS ALERT-BOX ERROR.
                    RETURN ERROR.
                 END.
              END.
              FIND FIRST ub.goods WHERE ub.goods.artic     = ub.parts.artic     AND
                                     ub.goods.prod-code = ub.parts.prod-code AND
                                     ub.goods.prod-type = ub.parts.prod-type NO-LOCK.
              RUN cr-parts-brutto.
       END.
    END.
END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc v-suppl
PROCEDURE calc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER lparobj-type LIKE ub.parts.obj-type NO-UNDO.
DEFINE INPUT PARAMETER lparobj-code LIKE ub.parts.obj-code NO-UNDO.
def buffer b-parts for ub.parts.
if session:set-wait-state("COMPILER") then.
run waitfram-show in this-procedure
  (input "Подождите..."
  ).

/*Пройдем по всем партиям на объекте за данный период*/
FOR EACH ub.goods WHERE ub.goods.tnved begins partnved NO-LOCK,
    EACH ub.parts WHERE ub.parts.host-code  = v-host-code
                 AND ub.parts.obj-code   = lparobj-code
                 AND ub.parts.obj-type   = lparobj-type
                 AND ub.parts.artic      = ub.goods.artic
                 AND ub.parts.prod-code  = ub.goods.prod-code
                 AND ub.parts.prod-type  = ub.goods.prod-type
                 AND ub.parts.status_    = yes
                 AND ub.parts.fact-date <= to-date
                 AND ub.parts.fact-date >= from-date
                 AND ub.parts.doc-type <> {&act-overvalue} NO-LOCK:
    /*Для отчета по всем объектам будем брать только внешние документы*/
    IF parobj-type = "all" THEN DO:
       FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = ub.parts.out-code no-lock.
       IF ub.trn-doc.internal = yes THEN NEXT.
    END.
    IF (parcst-units = "Базовая" AND ub.parts.fact-qnty = 0)
       OR (parcst-units <> "Базовая" and ub.parts.fact-qnty * ub.goods.cst-base-rate = 0) THEN NEXT.
   /*Ищем внешнюю приходную накладную*/
    find first in-doc where in-doc.doc-code  = ub.parts.in-code no-lock no-error.
    IF AVAILABLE in-doc THEN DO:
       FIND FIRST in-line WHERE in-line.doc-code  = in-doc.doc-code AND
                                in-line.artic     = ub.parts.artic     AND
                                in-line.prod-code = ub.parts.prod-code AND
                                in-line.prod-type = ub.parts.prod-type NO-LOCK NO-ERROR.
       IF NOT AVAILABLE in-line THEN DO:
          MESSAGE "Во внешней приходной накладной:" in-doc.doc-code SKIP
                  "Не найдена строка по товару:" ub.parts.artic " " ub.parts.prod-code " " ub.parts.prod-type SKIP
          VIEW-AS ALERT-BOX ERROR.
          RETURN ERROR.
       END.
    END.
    ELSE
    FIND FIRST ub.doc-line WHERE ub.doc-line.doc-code  = ub.parts.out-code  AND
                              ub.doc-line.artic     = ub.parts.artic          AND
                              ub.doc-line.prod-type = ub.parts.prod-type      AND
                              ub.doc-line.prod-code = ub.parts.prod-code      NO-LOCK.
    RUN cr-parts-brutto.

    FIND FIRST gds-brutto WHERE gds-brutto.artic    = parts-brutto.artic    AND
                                gds-brutto.cst-code = parts-brutto.cst-code NO-LOCK NO-ERROR.
    IF NOT AVAILABLE gds-brutto THEN DO:
       CREATE gds-brutto.
       ASSIGN gds-brutto.artic     = parts-brutto.artic
              gds-brutto.prod-type = parts-brutto.prod-type
              gds-brutto.prod-code = parts-brutto.prod-code
              gds-brutto.cst-code  = parts-brutto.cst-code
              gds-brutto.gds-name  = goods.gds-name
              gds-brutto.unit      = (IF parcst-units = "Базовая" THEN goods.unit-base ELSE goods.unit-cst).
    END.
    IF {&out-exp} THEN
    ASSIGN gds-brutto.out-qnty      = gds-brutto.out-qnty      + (IF parcst-units = "Базовая" THEN parts.fact-qnty ELSE parts.fact-qnty * goods.cst-base-rate)
           gds-brutto.out-wt-brutto = gds-brutto.out-wt-brutto +
           (IF AVAILABLE in-doc
            THEN (in-line.wt-brutto  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.wt-brutto / doc-line.fact-qnty) * parts.fact-qnty)
           gds-brutto.out-fact-place  = gds-brutto.out-fact-place  +
           (IF AVAILABLE in-doc
            THEN (in-line.num-place  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.num-place / doc-line.fact-qnty) * parts.fact-qnty)            .
    ELSE
    ASSIGN gds-brutto.in-qnty       = gds-brutto.in-qnty       + (IF parcst-units = "Базовая" THEN parts.fact-qnty ELSE parts.fact-qnty * goods.cst-base-rate)
           gds-brutto.in-wt-brutto  = gds-brutto.in-wt-brutto  +
           (IF AVAILABLE in-doc
            THEN (in-line.wt-brutto  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.wt-brutto / doc-line.fact-qnty) * parts.fact-qnty)
           gds-brutto.in-fact-place  = gds-brutto.in-fact-place  +
           (IF AVAILABLE in-doc
            THEN (in-line.num-place  / in-line.fact-qnty) * parts.fact-qnty
            ELSE (doc-line.num-place / doc-line.fact-qnty) * parts.fact-qnty)            .
END.
/*Пройдемся по расходным партиям на складе или приходным в магазине
 и соберем все предидущие их приходы и выпуски*/
/*На складе нам неинтересны партии, не имеющие расходов в указаннный период.
  В магазине нам интересны только партии по приходам данного периода*/
IF parkindrep = "OUT" then run bef-parts ("OUT").
                      else run bef-parts ("IN").
/*Идем по всем приходам и гасим их расходами*/
FOR EACH parts-brutto WHERE  parts-brutto.part-type = "IN"
    BY parts-brutto.fact-num:
    IF parkindrep = "IN"                 AND
       parts-brutto.fact-date >= from-date THEN DO:
       CREATE prt-parts-brutto.
       ASSIGN
       prt-parts-brutto.des           = STRING(parts-brutto.out-code)
       prt-parts-brutto.in-date       = STRING(parts-brutto.fact-date)
       prt-parts-brutto.cst-code      = parts-brutto.cst-code
       prt-parts-brutto.obj-code      = parts-brutto.obj-code
       prt-parts-brutto.obj-type      = parts-brutto.obj-type
       prt-parts-brutto.host-code     = parts-brutto.host-code
       prt-parts-brutto.artic         = parts-brutto.artic
       prt-parts-brutto.prod-code     = parts-brutto.prod-code
       prt-parts-brutto.prod-type     = parts-brutto.prod-type
       prt-parts-brutto.in-num        = parts-brutto.fact-num
       prt-parts-brutto.tnved         = parts-brutto.tnved
       prt-parts-brutto.gds-name      = parts-brutto.gds-name
       prt-parts-brutto.nationality   = parts-brutto.nationality
       prt-parts-brutto.unit          = parts-brutto.unit
       prt-parts-brutto.in-qnty       = STRING(parts-brutto.fact-qnty)
       prt-parts-brutto.in-qnty-up    = string(parts-brutto.qnty-up)
       prt-parts-brutto.in-wt-brutto  = STRING(parts-brutto.fact-brutto)
       prt-parts-brutto.in-fact-place = STRING(parts-brutto.fact-place)
       prt-parts-brutto.out-qnty      = "0"
       prt-parts-brutto.out-qnty-up   = "0"
       prt-parts-brutto.out-wt-brutto = "0"
       prt-parts-brutto.out-fact-place = "0".
    END.
    IF parkindrep = "OUT" AND
       NOT CAN-FIND (FIRST out-parts-brutto WHERE out-parts-brutto.part-type = "OUT"                   AND
                                                  out-parts-brutto.host-code  = parts-brutto.host-code AND
                                                  out-parts-brutto.obj-code   = parts-brutto.obj-code  AND
                                                  out-parts-brutto.obj-type   = parts-brutto.obj-type  AND
                                                  out-parts-brutto.artic      = parts-brutto.artic     AND
                                                  out-parts-brutto.prod-type  = parts-brutto.prod-type AND
                                                  out-parts-brutto.prod-code  = parts-brutto.prod-code AND
                                                  out-parts-brutto.in-code    = parts-brutto.in-code   AND
                                                  out-parts-brutto.fact-num   > parts-brutto.fact-num  AND
                                                  out-parts-brutto.fact-qnty  - parts-brutto.down-qnty > 0)
                                    THEN DO:
       /*------------------------------------------------------------------*/
       /*  Создаем запись вида ПРИХОД Х - РАСХОД НЕТ                       */
       /*  Такие приходы существуют только в заданном периоде  */
       /*------------------------------------------------------------------*/
       CREATE prt-parts-brutto.
       ASSIGN
       prt-parts-brutto.des           = STRING(parts-brutto.out-code)
       prt-parts-brutto.in-date       = STRING(parts-brutto.fact-date)
       prt-parts-brutto.cst-code      = parts-brutto.cst-code
       prt-parts-brutto.obj-code      = parts-brutto.obj-code
       prt-parts-brutto.obj-type      = parts-brutto.obj-type
       prt-parts-brutto.host-code     = parts-brutto.host-code
       prt-parts-brutto.artic         = parts-brutto.artic
       prt-parts-brutto.prod-code     = parts-brutto.prod-code
       prt-parts-brutto.prod-type     = parts-brutto.prod-type
       prt-parts-brutto.in-num        = parts-brutto.fact-num
       prt-parts-brutto.out-num       = ?
       prt-parts-brutto.tnved         = parts-brutto.tnved
       prt-parts-brutto.gds-name      = parts-brutto.gds-name
       prt-parts-brutto.nationality   = parts-brutto.nationality
       prt-parts-brutto.unit          = parts-brutto.unit
       prt-parts-brutto.in-qnty       = STRING(parts-brutto.fact-qnty)
       prt-parts-brutto.in-qnty-up    = string(parts-brutto.qnty-up)
       prt-parts-brutto.in-wt-brutto  = STRING(parts-brutto.fact-brutto)
       prt-parts-brutto.in-fact-place = STRING(parts-brutto.fact-place)
       prt-parts-brutto.out-date      = "НЕТ"
       prt-parts-brutto.out-qnty      = ""
       prt-parts-brutto.out-qnty-up   = ""
       prt-parts-brutto.out-wt-brutto = ""
       prt-parts-brutto.out-fact-place = "".

    END.
    FOR EACH out-parts-brutto WHERE out-parts-brutto.part-type  = "OUT"                       AND
                                    out-parts-brutto.host-code  = parts-brutto.host-code      AND
                                    out-parts-brutto.obj-code   = parts-brutto.obj-code       AND
                                    out-parts-brutto.obj-type   = parts-brutto.obj-type       AND
                                    out-parts-brutto.artic      = parts-brutto.artic          AND
                                    out-parts-brutto.prod-type  = parts-brutto.prod-type      AND
                                    out-parts-brutto.prod-code  = parts-brutto.prod-code      AND
                                    out-parts-brutto.in-code    = parts-brutto.in-code        AND
                                    out-parts-brutto.fact-num   > parts-brutto.fact-num       AND
                                    out-parts-brutto.fact-qnty  - parts-brutto.down-qnty > 0
                                    BREAK BY out-parts-brutto.fact-num:
        /*
        /*Если собираемся гасить больше чем осталось по приходу из внешней приходной накладной, то ошибка*/
        IF out-parts-brutto.fact-qnty >
           parts-brutto.fact-qnty     - parts-brutto.down-qnty THEN DO:
           MESSAGE "Ошибка при формировании отчета."                  SKIP
                   "По товару:" parts-brutto.artic                    SKIP
                   "Полученому от поставщика:" parts-brutto.prod-type " "
                                               parts-brutto.prod-code SKIP
                   "На объекте:" parts-brutto.obj-code " "
                                 parts-brutto.obj-type SKIP
                   "Накладная:"  parts-brutto.out-code SKIP
                   "Накладная по приему товара:" parts-brutto.in-code ". ГТД "
                                                 parts-brutto.cst-code SKIP
           VIEW-AS ALERT-BOX ERROR BUTTONS OK.
           RETURN ERROR.
        END.
        */
        ASSIGN out-parts-brutto.down-qnty = out-parts-brutto.fact-qnty
               parts-brutto.down-qnty     = parts-brutto.down-qnty + out-parts-brutto.fact-qnty.
        IF (out-parts-brutto.fact-date >= from-date OR
            parts-brutto.fact-date     >= from-date )
           AND parkindrep = "OUT" THEN DO:
              CREATE prt-parts-brutto.
              ASSIGN
               prt-parts-brutto.des           = STRING(parts-brutto.out-code)
               prt-parts-brutto.in-date       = IF FIRST(out-parts-brutto.fact-num) THEN STRING(parts-brutto.fact-date) ELSE ""
               prt-parts-brutto.cst-code      = parts-brutto.cst-code
               prt-parts-brutto.artic         = parts-brutto.artic
               prt-parts-brutto.obj-code      = parts-brutto.obj-code
               prt-parts-brutto.obj-type      = parts-brutto.obj-type
               prt-parts-brutto.host-code     = parts-brutto.host-code
               prt-parts-brutto.prod-code     = parts-brutto.prod-code
               prt-parts-brutto.prod-type     = parts-brutto.prod-type
               prt-parts-brutto.in-num        = parts-brutto.fact-num
               prt-parts-brutto.out-num       = out-parts-brutto.fact-num
               prt-parts-brutto.tnved         = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.tnved       ELSE ""
               prt-parts-brutto.gds-name      = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.gds-name    ELSE ""
               prt-parts-brutto.nationality   = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.nationality ELSE ""
               prt-parts-brutto.unit          = IF FIRST(out-parts-brutto.fact-num) THEN parts-brutto.unit        ELSE ""
               prt-parts-brutto.in-qnty       = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.fact-qnty) ELSE ""
               prt-parts-brutto.in-qnty-up    = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.qnty-up) ELSE ""
               prt-parts-brutto.in-wt-brutto  = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.fact-brutto) ELSE ""
               prt-parts-brutto.in-fact-place  = IF FIRST(out-parts-brutto.fact-num)    AND
                                                   parts-brutto.fact-date >= from-date THEN STRING(parts-brutto.fact-place) ELSE ""
               prt-parts-brutto.out-date      = STRING(out-parts-brutto.fact-date)
               prt-parts-brutto.out-qnty      = STRING(out-parts-brutto.fact-qnty)
               prt-parts-brutto.out-qnty-up   = STRING(out-parts-brutto.qnty-up)
               prt-parts-brutto.out-wt-brutto = STRING(out-parts-brutto.fact-brutto)
               prt-parts-brutto.out-fact-place = STRING(out-parts-brutto.fact-place).
        END.
        ELSE IF parkindrep = "IN"  AND
                parts-brutto.fact-date >= from-date THEN DO:
              ASSIGN
               prt-parts-brutto.out-qnty       = STRING(DECIMAL(prt-parts-brutto.out-qnty) + out-parts-brutto.fact-qnty)
               prt-parts-brutto.out-wt-brutto  = STRING(DECIMAL(prt-parts-brutto.out-wt-brutto) + out-parts-brutto.fact-brutto)
               prt-parts-brutto.out-fact-place = STRING(DECIMAL(prt-parts-brutto.out-fact-place) + out-parts-brutto.fact-place).
        END.
        IF parts-brutto.fact-qnty - parts-brutto.down-qnty = 0 THEN LEAVE.
    END.
END.
/*При составлении отчета по складу могут присутствовать расходы без приходов.
  Оформим их отдельными строками.*/
IF parkindrep = "OUT" THEN
FOR EACH parts-brutto WHERE parts-brutto.part-type = "OUT" AND
                            NOT CAN-FIND(FIRST in-parts-brutto WHERE
                                          in-parts-brutto.part-type  = "IN"                        AND
                                          in-parts-brutto.host-code  = parts-brutto.host-code      AND
                                          in-parts-brutto.obj-code   = parts-brutto.obj-code       AND
                                          in-parts-brutto.obj-type   = parts-brutto.obj-type       AND
                                          in-parts-brutto.artic      = parts-brutto.artic          AND
                                          in-parts-brutto.prod-type  = parts-brutto.prod-type      AND
                                          in-parts-brutto.prod-code  = parts-brutto.prod-code      AND
                                          in-parts-brutto.in-code    = parts-brutto.in-code NO-LOCK) :
       /*------------------------------------------------------------------*/
       /*  Создаем запись вида ПРИХОД ? - РАСХОД Y                       */
       /*------------------------------------------------------------------*/
       CREATE prt-parts-brutto.
       ASSIGN
       prt-parts-brutto.in-date       = ?
       prt-parts-brutto.des           = STRING(parts-brutto.out-code)
       prt-parts-brutto.cst-code      = parts-brutto.cst-code
       prt-parts-brutto.obj-code      = parts-brutto.obj-code
       prt-parts-brutto.obj-type      = parts-brutto.obj-type
       prt-parts-brutto.host-code     = parts-brutto.host-code
       prt-parts-brutto.artic         = parts-brutto.artic
       prt-parts-brutto.prod-code     = parts-brutto.prod-code
       prt-parts-brutto.prod-type     = parts-brutto.prod-type
       prt-parts-brutto.in-num        = ?
       prt-parts-brutto.out-num       = ?
       prt-parts-brutto.tnved         = parts-brutto.tnved
       prt-parts-brutto.gds-name      = parts-brutto.gds-name
       prt-parts-brutto.nationality   = parts-brutto.nationality
       prt-parts-brutto.unit          = parts-brutto.unit
       prt-parts-brutto.in-qnty       = ?
       prt-parts-brutto.in-qnty-up    = ?
       prt-parts-brutto.in-wt-brutto  = ?
       prt-parts-brutto.in-fact-place = ?
       prt-parts-brutto.out-date      = STRING(parts-brutto.fact-date)
       prt-parts-brutto.out-qnty      = STRING(parts-brutto.fact-qnty)
       prt-parts-brutto.out-qnty-up   = string(parts-brutto.qnty-up)
       prt-parts-brutto.out-wt-brutto = STRING(parts-brutto.fact-brutto)
       prt-parts-brutto.out-fact-place = STRING(parts-brutto.fact-place).
END.
output close.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cr-parts-brutto v-suppl
PROCEDURE cr-parts-brutto :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    FIND FIRST parts-brutto WHERE
                            parts-brutto.host-code     = ub.parts.host-code  AND
                            parts-brutto.obj-code      = ub.parts.obj-code   AND
                            parts-brutto.obj-type      = ub.parts.obj-type   AND
                            parts-brutto.artic         = ub.parts.artic      AND
                            parts-brutto.prod-type     = ub.parts.prod-type  AND
                            parts-brutto.prod-code     = ub.parts.prod-code  AND
                            parts-brutto.in-code       = ub.parts.in-code    AND
                            parts-brutto.part-type     = IF {&out-exp} THEN "OUT" ELSE "IN" NO-ERROR.

    IF NOT AVAILABLE parts-brutto THEN DO:
       CREATE parts-brutto.
       ASSIGN
       parts-brutto.in-code       = ub.parts.in-code
       parts-brutto.out-code      = ub.parts.out-code
       parts-brutto.part-code     = ub.parts.part-code
       parts-brutto.host-code     = v-host-code
       parts-brutto.obj-code      = ub.parts.obj-code
       parts-brutto.obj-type      = ub.parts.obj-type
       parts-brutto.artic         = ub.parts.artic
       parts-brutto.prod-type     = ub.parts.prod-type
       parts-brutto.prod-code     = ub.parts.prod-code
       parts-brutto.gds-name      = ub.goods.gds-name
       parts-brutto.tnved         = ub.goods.tnved
       parts-brutto.nationality   = ub.goods.nationality
       parts-brutto.unit          = (IF parcst-units = "Базовая" THEN ub.goods.unit-base ELSE ub.goods.unit-cst)
       parts-brutto.part-type     = (IF {&out-exp} THEN "OUT" ELSE "IN")
       parts-brutto.fact-date     = if available in-doc then in-doc.exch-date else parts.fact-date
       parts-brutto.fact-num      = ub.parts.fact-num
       parts-brutto.cst-code      = if ub.parts.cst-code <> ? then ub.parts.cst-code else ?.
    END.
    ASSIGN
    parts-brutto.fact-qnty     = parts-brutto.fact-qnty + (IF parcst-units = "Базовая" THEN parts.fact-qnty ELSE parts.fact-qnty * goods.cst-base-rate)
    parts-brutto.qnty-up       = parts-brutto.fact-qnty / ub.goods.qnty-cart
    parts-brutto.fact-brutto   = parts-brutto.fact-brutto +
    (IF AVAILABLE in-doc
     THEN (in-line.wt-brutto  / in-line.fact-qnty) * ub.parts.fact-qnty
     ELSE (ub.doc-line.wt-brutto / ub.doc-line.fact-qnty) * ub.parts.fact-qnty)
    parts-brutto.fact-place   = parts-brutto.fact-place +
    (IF AVAILABLE in-doc
     THEN (in-line.num-place  / in-line.fact-qnty) * ub.parts.fact-qnty
     ELSE (doc-line.num-place / ub.doc-line.fact-qnty) * ub.parts.fact-qnty).

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
  ENABLE b-excel b-print b-help b-quit b-parts a-n-c br-gds-brutto
      WITH FRAME v-suppl.
  VIEW FRAME v-suppl.
  {&OPEN-BROWSERS-IN-QUERY-v-suppl}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME