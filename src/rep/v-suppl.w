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

Отчет по поставщику (товары)

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter from-date as date no-undo .
define input parameter to-date as date no-undo .
DEFINE INPUT PARAMETER suppl-rid AS RECID NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по поставщику (товары)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i  }
{ cmp/library.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i new }
{ gbl/prn-lib.i }
{ rep/v-suppl.i new new }
{ str/libbcrcn.i }
define variable g#report-num as integer no-undo .
{ rep/opclexcl.i }
{ gbl/waitfram.i }
def buffer l-suppl-gds for suppl-gds. /* для поиска  */
define buffer buf-trn-doc for trn-doc.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.                  /* тип параметра конфигурации */
define variable base-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable line-rec as recid no-undo .
define buffer buf_rep_currency for ub.currency.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME v-suppl
&Scoped-define BROWSE-NAME br-suppl

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES suppl-gds

/* Definitions for BROWSE br-suppl                                      */
&Scoped-define FIELDS-IN-QUERY-br-suppl suppl-gds.artic suppl-gds.gds-name suppl-gds.unit-base suppl-gds.in-qnty suppl-gds.in-sum0-rubl suppl-gds.in-sum0-base suppl-gds.out-qnty suppl-gds.out-sum0-rubl suppl-gds.out-sum0-base suppl-gds.free-qnty suppl-gds.free-sum0-rubl suppl-gds.free-sum0-base suppl-gds.qnty-sale (suppl-gds.ls-date - suppl-gds.fs-date)
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-suppl
&Scoped-define FIELD-PAIRS-IN-QUERY-br-suppl
&Scoped-define SELF-NAME br-suppl
&Scoped-define OPEN-QUERY-br-suppl OPEN QUERY {&SELF-NAME} FOR EACH suppl-gds NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-suppl suppl-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-suppl suppl-gds


/* Definitions for DIALOG-BOX v-suppl                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-suppl ~
    ~{&OPEN-QUERY-br-suppl}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS rect-in br-suppl b-parts a-n-c b-quit ~
b-print b-help
&Scoped-Define DISPLAYED-OBJECTS tot-out-sum0-rubl tot-in-qnty ~
tot-out-sum0-base tot-free-qnty tot-in-sum0-rubl a-n-c tot-free-sum0-rubl ~
tot-out-qnty tot-in-sum0-base tot-free-sum0-base

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     size 10 by 1.

DEFINE BUTTON b-parts DEFAULT
     LABEL "&Партии"
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

DEFINE VARIABLE tot-free-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ?
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-free-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-free-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-in-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ?
     LABEL "кол-во"
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-in-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     LABEL "сумма (б.вал)"
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-in-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     LABEL "сумма (abbr_rub)"
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-out-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ?
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-out-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-out-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     size 17 by 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     size 15 by 1 NO-UNDO.

DEFINE RECTANGLE rect-in
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     size 96.5 by 4.83
     BGCOLOR 8 .

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-suppl FOR
      suppl-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-suppl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-suppl v-suppl _FREEFORM
  QUERY br-suppl DISPLAY
      suppl-gds.artic COLUMN-LABEL "Артикул! "
suppl-gds.gds-name COLUMN-LABEL "Название товара! "
suppl-gds.unit-base COLUMN-LABEL "Ед.!Изм." FORMAT "X(5)"
suppl-gds.in-qnty COLUMN-LABEL "Приход! количество" FORMAT "->,>>>,>>9.<<<"
suppl-gds.in-sum0-rubl COLUMN-LABEL "Приход сумма!уч. цен ({&abbr_rub})" FORMAT "->>>,>>>,>>9.99"
suppl-gds.in-sum0-base COLUMN-LABEL "Приход сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-gds.out-qnty COLUMN-LABEL "Расход!количество" FORMAT "->,>>>,>>9.<<<"
suppl-gds.out-sum0-rubl COLUMN-LABEL "Расход сумма!уч. цен ({&abbr_rub})" FORMAT "->>>,>>>,>>9.99"
suppl-gds.out-sum0-base COLUMN-LABEL "Расход сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-gds.free-qnty COLUMN-LABEL "Остаток!количество" FORMAT "->,>>>,>>9.<<<"
suppl-gds.free-sum0-rubl COLUMN-LABEL "Остаток сумма!уч. цен ({&abbr_rub})" FORMAT "->>>,>>>,>>9.99"
suppl-gds.free-sum0-base COLUMN-LABEL "Остаток сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-gds.qnty-sale COLUMN-LABEL "Кол-во!продаж" FORMAT "->,>>>,>>9"
(suppl-gds.ls-date - suppl-gds.fs-date) COLUMN-LABEL "Кол-во дней!продаж" FORMAT "->,>>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 16.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-suppl
     tot-out-sum0-rubl at row 22 col 45 COLON-ALIGNED NO-LABEL
     br-suppl AT ROW 3.67 COL 2
     tot-in-qnty at row 20.83 col 18.5 COLON-ALIGNED
     tot-out-sum0-base at row 23.17 col 45 COLON-ALIGNED NO-LABEL
     tot-free-qnty at row 20.83 col 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-rubl at row 22 col 18.5 COLON-ALIGNED
     b-parts at row 1.17 col 22
     loc-art at row 2.5 col 33.5 COLON-ALIGNED
     a-n-c at row 2.5 col 2 NO-LABEL
     tot-free-sum0-rubl at row 22 col 72.5 COLON-ALIGNED NO-LABEL
     tot-out-qnty at row 20.83 col 45 COLON-ALIGNED NO-LABEL
     tot-in-sum0-base at row 23.17 col 18.5 COLON-ALIGNED
     tot-free-sum0-base at row 23.17 col 72.5 COLON-ALIGNED NO-LABEL
     b-quit at row 1.17 col 2
     loc-name at row 2.5 col 33.5 COLON-ALIGNED
     loc-code at row 2.5 col 33.5 COLON-ALIGNED
     b-print at row 1.17 col 12
     b-help at row 1.17 col 88.5
     "Остаток" VIEW-AS TEXT
          size 10 by 0.63 at row 20 col 77.5
     rect-in at row 19.67 col 2
     "Приход" VIEW-AS TEXT
          size 8.5 by 0.63 at row 20 col 25.5
     "Расход" VIEW-AS TEXT
          size 8.5 by 0.63 at row 20 col 51
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D
         size 100.13 by 24.88
         TITLE "отчет по поставщику".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-suppl
                                                                        */
/* BROWSE-TAB br-suppl TEXT-3 v-suppl */
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

/* SETTINGS FOR FILL-IN tot-free-qnty IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-free-sum0-base IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-free-sum0-rubl IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-qnty IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-sum0-base IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-sum0-rubl IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-qnty IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-sum0-base IN FRAME v-suppl
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-sum0-rubl IN FRAME v-suppl
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-suppl
/* Query rebuild information for BROWSE br-suppl
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH suppl-gds NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-suppl */
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
ON WINDOW-CLOSE OF FRAME v-suppl /* отчет по поставщику */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-parts v-suppl
ON CHOOSE OF b-parts IN FRAME v-suppl /* Партии */
DO:
  if available suppl-gds then
      run rep/vs-parts.w ( input parparentproc, p-curr-obj-type, p-curr-obj-code, from-date, to-date, input " ", input " " ).
  APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print v-suppl
ON CHOOSE OF b-print IN FRAME v-suppl /* Печать */
DO:

define variable in-sum0 LIKE parts.price-rubl no-undo.
define variable out-sum0 LIKE parts.price-rubl no-undo.
define variable free-sum0 LIKE parts.price-rubl no-undo.

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
define variable sym11 as char init ":"   no-undo.
define variable sym12 as char init ":"   no-undo.
define variable sym13 as char init ":"   no-undo.

define variable Line as char no-undo.

assign PrintRubl = yes .
if v-base-code <> 0 then
message "Печатать в {&abbr_rublyah} ?" VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.


assign
sheetf.Excel-Column-Lable = "Артикул,Название,Ед.изм,Приход количество,Приход сумма учетных цен," +
                            "Расход количество,Расход сумма учетных цен,Остаток количество,Остаток сумма учетных цен"
sheetf.sizes =  "16,50,5,15,18," +
                "15,18,15,18"
sheetf.colformat = {&delim-par} + "1=@"
Make-Excel = yes
reportname =  "ОТЧЕТ ПО ПОСТАВЩИКУ: " + supplier.obj-name +
            " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")"
str2 =  " за период с: " + string(from-date,"99/99/9999") + " по: " + string(to-date,"99/99/9999")
str4 = "Cуммы указаны в " + (if PrintRubl then "{&abbr_rub}" else base-type)
.


DEFINE FRAME supp-gds
      sym1 column-label ":!:" format "X(1)"
      suppl-gds.artic COLUMN-LABEL "Артикул! " FORMAT "x(16)"
      sym2 column-label ":!:" format "X(1)"
      suppl-gds.gds-name COLUMN-LABEL "Название! " FORMAT "x(50)"
      sym3 column-label ":!:" format "X(1)"
      suppl-gds.unit-base COLUMN-LABEL "Ед.!изм." FORMAT "x(5)"
      sym4 column-label ":!:" format "X(1)"
      suppl-gds.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<"
      sym5 column-label ":!:" format "X(1)"
      in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>,>>>,>>>,>>9.99"
      sym6 column-label ":!:" format "X(1)"
      suppl-gds.out-qnty COLUMN-LABEL "Расход!    количество" FORMAT "->,>>>,>>9.<<<"
      sym7 column-label ":!:" format "X(1)"
      out-sum0 COLUMN-LABEL "Расход сумма!учетных цен" FORMAT "->>,>>>,>>>,>>9.99"
      sym8 column-label ":!:" format "X(1)"
      suppl-gds.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<"
      sym9 column-label ":!:" format "X(1)"
      free-sum0 COLUMN-LABEL "Остаток сумма!учетных цен" FORMAT "->>,>>>,>>>,>>9.99"
      sym10 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Отчет по поставщику: " + supplier.obj-name ) AT 45 format "X(71)"
        string( str4 ) AT 145 format "X(20)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
        Line format "X(195)" AT 1
    with width {&DOS_CW_2} down stream-io.


if session:set-wait-state("COMPILER") then.

assign Line = fill("-", {&DOS_CW_2}).

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


FORM with FRAME supp-gds.

FORM HEADER
    Line format "X(195)" AT 1 SKIP
    "Продолжение - на следующей странице" AT 60 SKIP
    with FRAME BottomFrame width {&DOS_CW_2}
    PAGE-BOTTOM no-labels no-box.
VIEW STREAM PrnLibStream FRAME BottomFrame .

PUT STREAM PrnLibStream
    string( ReportName + {&space-char} + str2)  AT 37 format "X(195)" SKIP(1).

RUN OpenForExcel in this-procedure .

run rep/extitle.p (1).


    FOR EACH suppl-gds:
        assign
            in-sum0 = (if PrintRubl then suppl-gds.in-sum0-rubl else suppl-gds.in-sum0-base)
            out-sum0 = (if PrintRubl then suppl-gds.out-sum0-rubl else suppl-gds.out-sum0-base)
            free-sum0 = (if PrintRubl then suppl-gds.free-sum0-rubl else suppl-gds.free-sum0-base)
            .
        DISPLAY STREAM PrnLibStream
            sym1 suppl-gds.artic
            sym2 suppl-gds.gds-name
            sym3 suppl-gds.unit-base
            sym4 suppl-gds.in-qnty
            sym5 in-sum0
            sym6 suppl-gds.out-qnty
            sym7 out-sum0
            sym8 suppl-gds.free-qnty
            sym9 free-sum0
            sym10
            with FRAME supp-gds .
        DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
        {&PutExcel}
        suppl-gds.artic          {&tabulation}
        suppl-gds.gds-name       {&tabulation}
        suppl-gds.unit-base      {&tabulation}
        suppl-gds.in-qnty        {&tabulation}
        in-sum0                  {&tabulation}
        suppl-gds.out-qnty       {&tabulation}
        out-sum0                 {&tabulation}
        suppl-gds.free-qnty      {&tabulation}
        free-sum0
        skip.
        ACCUMULATE
            suppl-gds.in-qnty (TOTAL)
            in-sum0 (TOTAL)
            suppl-gds.out-qnty (TOTAL)
            out-sum0 (TOTAL)
            suppl-gds.free-qnty (TOTAL)
            free-sum0 (TOTAL)
            .
    END.

PUT STREAM PrnLibStream Line format "X(195)" SKIP.

DISPLAY STREAM PrnLibStream
    "Итого" @ suppl-gds.unit-base
    (ACCUM TOTAL suppl-gds.in-qnty) @ suppl-gds.in-qnty
    (ACCUM TOTAL in-sum0) @ in-sum0
    (ACCUM TOTAL suppl-gds.out-qnty) @ suppl-gds.out-qnty
    (ACCUM TOTAL out-sum0) @ out-sum0
    (ACCUM TOTAL suppl-gds.free-qnty) @ suppl-gds.free-qnty
    (ACCUM TOTAL free-sum0) @ free-sum0
    with FRAME supp-gds .
DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
{&PutExcel}
"Итого"                                             {&tabulation}
                                                    {&tabulation}
                                                    {&tabulation}
(ACCUM TOTAL suppl-gds.in-qnty)                     {&tabulation}
(ACCUM TOTAL in-sum0)                               {&tabulation}
(ACCUM TOTAL suppl-gds.out-qnty)                    {&tabulation}
(ACCUM TOTAL out-sum0)                              {&tabulation}
(ACCUM TOTAL suppl-gds.free-qnty)                   {&tabulation}
(ACCUM TOTAL free-sum0)
skip.



HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.
{&CloseExcel}

if session:set-wait-state("") then.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-suppl
&Scoped-define SELF-NAME br-suppl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-suppl v-suppl
ON MOUSE-SELECT-DBLCLICK OF br-suppl IN FRAME v-suppl
DO:
  APPLY "CHOOSE" TO b-parts IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-suppl v-suppl
ON RETURN OF br-suppl IN FRAME v-suppl
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
&scop store-type p-curr-obj-type
&scop store-code p-curr-obj-code
{ str/sch-line.i suppl-gds br-suppl }
end.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  FIND supplier WHERE recid(supplier) = suppl-rid NO-LOCK.
  run get-report-num in parparentproc(output g#report-num).
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = v-base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
              else base-type = "б.в." .

  RUN calc.

  RUN enable_UI.
  FRAME {&FRAME-NAME}:TITLE = string( "Поставки с: " + string(from-date,"99/99/9999") +
                                                                    " по: " + string(to-date,"99/99/9999") +
                                                                    " Поставщик: " + supplier.obj-name +
                                                                    " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" ).
  apply "entry" to br-suppl in frame {&frame-name}.
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
def buffer b-parts for parts.
define variable out-qnty    like parts.fact-qnty        no-undo.
define variable free-qnty   like parts.fact-qnty        no-undo.
define variable qnty_sale   like suppl-gds.qnty-sale    no-undo.
define variable f-date      as date                     no-undo.
define variable l-date      as date                     no-undo.
define variable v-today     as date                     no-undo.
define variable v-time      as integer                  no-undo.


if session:set-wait-state("COMPILER") then.
run waitfram-show in this-procedure ("Подождите...").
FOR EACH parts WHERE parts.host-code = v-host-code
                     AND parts.supp-type = supplier.obj-type
                     AND parts.supp-code = supplier.obj-code
                     AND parts.status_ = yes
                     AND parts.fact-date >= from-date
                     AND parts.fact-date <= to-date
                     AND parts.out-code = parts.in-code NO-LOCK,
    EACH goods WHERE goods.artic = parts.artic
                     AND goods.prod-type = parts.prod-type
                     AND goods.prod-code = parts.prod-code NO-LOCK
                     BREAK BY parts.fact-date:

    assign
        l-date = parts.fact-date
        qnty_sale = 0
        .
    FOR EACH b-parts WHERE b-parts.artic = parts.artic
                                                AND b-parts.prod-type = parts.prod-type
                                                AND b-parts.prod-code = parts.prod-code
                                                AND b-parts.in-code = parts.in-code
                                                AND b-parts.part-code = parts.part-code
                                                AND b-parts.status_ = yes
                                                AND b-parts.doc-type = {&expense} NO-LOCK,
            EACH trn-doc WHERE trn-doc.doc-code = b-parts.out-code
                                                AND trn-doc.internal = no NO-LOCK
                                                BREAK BY b-parts.fact-date:
        if LAST-OF( b-parts.fact-date ) then
            assign qnty_sale = qnty_sale + 1.
        if LAST( b-parts.fact-date ) AND l-date - 1 < b-parts.fact-date then
            assign l-date = b-parts.fact-date + 1.
    END.
    FOR EACH b-parts WHERE b-parts.artic = parts.artic
                         AND b-parts.prod-type = parts.prod-type
                         AND b-parts.prod-code = parts.prod-code
                         AND b-parts.in-code = parts.in-code
                         AND b-parts.part-code = parts.part-code
                         AND b-parts.out-code = {&output-code}
                         NO-LOCK:
        ACCUMULATE b-parts.fact-qnty (TOTAL).
    END.
    assign out-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
    /*
    FOR EACH b-parts WHERE b-parts.artic = parts.artic
                                                AND b-parts.prod-type = parts.prod-type
                                                AND b-parts.prod-code = parts.prod-code
                                                AND b-parts.in-code = parts.in-code
                                                AND b-parts.part-code = parts.part-code
                                                AND b-parts.rsrv-free = yes
                                                NO-LOCK:
        ACCUMULATE b-parts.fact-qnty (TOTAL).
    END.
    assign free-qnty = (ACCUM TOTAL b-parts.fact-qnty) .
    FOR EACH b-parts WHERE b-parts.artic = parts.artic
                                                AND b-parts.prod-type = parts.prod-type
                                                AND b-parts.prod-code = parts.prod-code
                                                AND b-parts.in-code = parts.in-code
                                                AND b-parts.part-code = parts.part-code
                                                AND b-parts.status_ = no
                                                AND b-parts.doc-type = {&income} NO-LOCK,
            EACH trn-doc WHERE trn-doc.doc-code = b-parts.out-code
                                                AND trn-doc.internal = yes NO-LOCK:
        ACCUMULATE b-parts.qnty (TOTAL).
    END.
    assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
    FOR EACH b-parts WHERE b-parts.artic = parts.artic
                                                AND b-parts.prod-type = parts.prod-type
                                                AND b-parts.prod-code = parts.prod-code
                                                AND b-parts.in-code = parts.in-code
                                                AND b-parts.part-code = parts.part-code
                                                AND b-parts.status_ = no
                                                AND b-parts.doc-type = {&return} NO-LOCK,
            EACH trn-doc WHERE trn-doc.doc-code = b-parts.out-code
                                                AND trn-doc.internal = yes NO-LOCK:
        ACCUMULATE b-parts.qnty (TOTAL).
    END.
    assign free-qnty = free-qnty + (ACCUM TOTAL b-parts.qnty) .
    */
    FOR EACH b-parts WHERE b-parts.artic = parts.artic
                         AND b-parts.prod-type = parts.prod-type
                         AND b-parts.prod-code = parts.prod-code
                         AND b-parts.in-code = parts.in-code
                         AND b-parts.part-code = parts.part-code
                         AND b-parts.out-code = {&free-code}
                         NO-LOCK:
        ACCUMULATE b-parts.fact-qnty (TOTAL).
    END.
    assign free-qnty = (ACCUM TOTAL b-parts.fact-qnty) .

    if free-qnty > 0 then do:
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign l-date = v-today + 1.
    end.
    find    first  buf-trn-doc where
            buf-trn-doc.doc-code =   parts.in-code  and
            buf-trn-doc.doc-type <> {&inventory} no-lock no-error .
     if available buf-trn-doc then  dO:
        ACCUMULATE
            parts.fact-qnty (TOTAL)
            parts.fact-qnty * parts.price-rubl (TOTAL)
            parts.fact-qnty * parts.price-base (TOTAL)
          .
       end.

    ACCUMULATE
        out-qnty (TOTAL)
        out-qnty * parts.price-rubl (TOTAL)
        out-qnty * parts.price-base (TOTAL)
        free-qnty (TOTAL)
        free-qnty * parts.price-rubl (TOTAL)
        free-qnty * parts.price-base (TOTAL)
        .

    FIND suppl-gds WHERE suppl-gds.artic = parts.artic
                         AND suppl-gds.prod-type = parts.prod-type
                         AND suppl-gds.prod-code = parts.prod-code
                         NO-ERROR.
    if available suppl-gds then
        assign
            suppl-gds.in-qnty = suppl-gds.in-qnty + parts.fact-qnty
            suppl-gds.in-sum0-rubl = suppl-gds.in-sum0-rubl + parts.fact-qnty * parts.price-rubl
            suppl-gds.in-sum0-base = suppl-gds.in-sum0-base + parts.fact-qnty * parts.price-base
            suppl-gds.out-qnty = suppl-gds.out-qnty + out-qnty
            suppl-gds.out-sum0-rubl = suppl-gds.out-sum0-rubl + out-qnty * parts.price-rubl
            suppl-gds.out-sum0-base = suppl-gds.out-sum0-base + out-qnty * parts.price-base
            suppl-gds.free-qnty = suppl-gds.free-qnty + free-qnty
            suppl-gds.free-sum0-rubl = suppl-gds.free-sum0-rubl + free-qnty * parts.price-rubl
            suppl-gds.free-sum0-base = suppl-gds.free-sum0-base + free-qnty * parts.price-base
            suppl-gds.qnty-sale = suppl-gds.qnty-sale + qnty_sale
            .
    else
        do:
            CREATE suppl-gds.
            assign
                suppl-gds.artic = parts.artic
                suppl-gds.prod-type = parts.prod-type
                suppl-gds.prod-code = parts.prod-code
                suppl-gds.gds-name = goods.gds-name
                suppl-gds.unit-base = goods.unit-base
                suppl-gds.in-qnty = parts.fact-qnty
                suppl-gds.in-sum0-rubl = parts.fact-qnty * parts.price-rubl
                suppl-gds.in-sum0-base = parts.fact-qnty * parts.price-base
                suppl-gds.out-qnty = out-qnty
                suppl-gds.out-sum0-rubl = out-qnty * parts.price-rubl
                suppl-gds.out-sum0-base = out-qnty * parts.price-base
                suppl-gds.free-qnty = free-qnty
                suppl-gds.free-sum0-rubl = free-qnty * parts.price-rubl
                suppl-gds.free-sum0-base = free-qnty * parts.price-base
                suppl-gds.qnty-sale = qnty_sale
                suppl-gds.fs-date = parts.fact-date
                suppl-gds.ls-date = parts.fact-date
                .
        end.
    if l-date >  suppl-gds.ls-date then
        assign suppl-gds.ls-date = l-date.

END.

assign
    tot-in-qnty = (ACCUM TOTAL parts.fact-qnty)
    tot-in-sum0-rubl = (ACCUM TOTAL parts.fact-qnty * parts.price-rubl)
    tot-in-sum0-base = (ACCUM TOTAL parts.fact-qnty * parts.price-base)
    tot-out-qnty = (ACCUM TOTAL out-qnty)
    tot-out-sum0-rubl = (ACCUM TOTAL out-qnty * parts.price-rubl)
    tot-out-sum0-base = (ACCUM TOTAL out-qnty * parts.price-base)
    tot-free-qnty = (ACCUM TOTAL free-qnty)
    tot-free-sum0-rubl = (ACCUM TOTAL free-qnty * parts.price-rubl)
    tot-free-sum0-base = (ACCUM TOTAL free-qnty * parts.price-base)
    .

hide loc-art in frame {&frame-name} loc-name loc-code in frame {&frame-name}.
assign loc-art = "".
if session:set-wait-state("") then.
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
  DISPLAY tot-out-sum0-rubl tot-in-qnty tot-out-sum0-base tot-free-qnty
          tot-in-sum0-rubl a-n-c tot-free-sum0-rubl tot-out-qnty tot-in-sum0-base
          tot-free-sum0-base
      WITH FRAME v-suppl.
  ENABLE rect-in br-suppl b-parts a-n-c b-quit b-print b-help
      WITH FRAME v-suppl.
  VIEW FRAME v-suppl.
  {&OPEN-BROWSERS-IN-QUERY-v-suppl}
  assign tot-in-sum0-rubl:label = "сумма ({&abbr_rub})" .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME