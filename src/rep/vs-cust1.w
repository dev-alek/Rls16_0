&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME v-cust
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS v-cust 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет о движении партии товара   СУДЬБА

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06


------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter from-date as date no-undo .
define input parameter to-date as date no-undo .


/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет о движении партии товара   СУДЬБА".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i  }
{ cmp/library.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i }
{ rep/v-suppl.i  }
{ rep/gn-extp.i  }
define new shared buffer t-doc for ub.trn-doc.
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable base-type as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_rep_currency for ub.currency.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME v-cust
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES parts t-doc

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs (substring (t-doc.doc-type, 1, 1)) t-doc.status_ t-doc.flag_ t-doc.doc-code (substring ((string (t-doc.doc-date)), 1, 5)) t-doc.fact-date t-doc.internal t-doc.cli-name ub.parts.fact-qnty ub.parts.price-base ub.parts.price-rubl (if ub.parts.part-code = "" then "------" else ub.parts.part-code) (trim (t-doc.obj-type) + string (t-doc.obj-code, ">>>>9")) t-doc.inv-num t-doc.ord-num t-doc.ship-num t-doc.ship-date t-doc.out-code t-doc.acc-date func-get-name-from-ext-type ( t-doc.ext-doc-type , false )   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs   
&Scoped-define SELF-NAME br-docs
&Scoped-define QUERY-STRING-br-docs FOR EACH ub.parts WHERE ub.parts.artic = suppl-parts.artic                      AND ub.parts.prod-type = suppl-parts.prod-type                      AND ub.parts.prod-code = suppl-parts.prod-code                      AND ub.parts.in-code = suppl-parts.in-code                      AND ub.parts.part-code = suppl-parts.part-code                      AND ub.parts.status_ = yes NO-LOCK, ~
           EACH t-doc WHERE t-doc.doc-code = ub.parts.out-code NO-LOCK BY t-doc.fact-date BY t-doc.fact-num
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY {&SELF-NAME} FOR EACH ub.parts WHERE ub.parts.artic = suppl-parts.artic                      AND ub.parts.prod-type = suppl-parts.prod-type                      AND ub.parts.prod-code = suppl-parts.prod-code                      AND ub.parts.in-code = suppl-parts.in-code                      AND ub.parts.part-code = suppl-parts.part-code                      AND ub.parts.status_ = yes NO-LOCK, ~
           EACH t-doc WHERE t-doc.doc-code = ub.parts.out-code NO-LOCK BY t-doc.fact-date BY t-doc.fact-num.
&Scoped-define TABLES-IN-QUERY-br-docs ub.parts t-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs ub.parts
&Scoped-define SECOND-TABLE-IN-QUERY-br-docs t-doc


/* Definitions for DIALOG-BOX v-cust                                    */
&Scoped-define OPEN-BROWSERS-IN-QUERY-v-cust ~
    ~{&OPEN-QUERY-br-docs}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-print b-help br-docs 
&Scoped-Define DISPLAYED-OBJECTS tot-in-qnty tot-out-qnty tot-free-qnty ~
tot-in-sum0-rubl tot-out-sum0-rubl tot-free-sum0-rubl tot-in-sum0-base ~
tot-out-sum0-base tot-free-sum0-base 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help 
     LABEL "Помощь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print DEFAULT 
     LABEL "Печать" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY 
     LABEL "Выход " 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE tot-free-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-free-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-free-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-in-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ? 
     LABEL "кол-во" 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-in-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ? 
     LABEL "сумма (б.вал)" 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-in-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ? 
     LABEL "сумма ()" 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-out-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.<<<":U INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-out-sum0-base AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE tot-out-sum0-rubl AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ? 
     VIEW-AS FILL-IN 
     SIZE 17 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-docs FOR 
      ub.parts, 
      t-doc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs v-cust _FREEFORM
  QUERY br-docs DISPLAY
      (substring (t-doc.doc-type, 1, 1)) COLUMN-LABEL "Т" FORMAT "x(1)"
      t-doc.status_ COLUMN-LABEL "Стат" format "x(4)"
      t-doc.flag_ COLUMN-LABEL "OK" FORMAT "+/-"
      t-doc.doc-code format "x(12)"
      (substring ((string (t-doc.doc-date)), 1, 5)) format "x(5)" column-label "Дата"
      t-doc.fact-date COLUMN-LABEL "Факт"
      t-doc.internal COLUMN-LABEL "В" FORMAT "+/-"
      t-doc.cli-name format "x(27)"
      ub.parts.fact-qnty COLUMN-LABEL "Количество" FORMAT "->>>,>>9.<<<"
      ub.parts.price-base COLUMN-LABEL "Цена (б.вал)"
      ub.parts.price-rubl
      (if ub.parts.part-code = "" then "------" else ub.parts.part-code) COLUMN-LABEL "Партия" FORMAT "x(14)"
      (trim (t-doc.obj-type) + string (t-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объекты" FORMAT "x(8)"
      t-doc.inv-num column-label "Инвойс "
      t-doc.ord-num column-label "Заказ"
      t-doc.ship-num column-label "Отгрузка"
      t-doc.ship-date column-label "Дата"
      t-doc.out-code column-label "На док-т" format "x(12)"
      t-doc.acc-date column-label "Проводка"
      func-get-name-from-ext-type ( t-doc.ext-doc-type , false )   COLUMN-LABEL "Тип" FORMAT "x(20)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 17.33.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME v-cust
     b-quit AT ROW 1.17 COL 2
     b-print AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 88.5
     br-docs AT ROW 2.33 COL 2
     tot-in-qnty AT ROW 20.83 COL 18.5 COLON-ALIGNED
     tot-out-qnty AT ROW 20.83 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-qnty AT ROW 20.83 COL 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-rubl AT ROW 22 COL 18.5 COLON-ALIGNED
     tot-out-sum0-rubl AT ROW 22 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-sum0-rubl AT ROW 22 COL 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-base AT ROW 23.17 COL 18.5 COLON-ALIGNED
     tot-out-sum0-base AT ROW 23.17 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-sum0-base AT ROW 23.17 COL 72.5 COLON-ALIGNED NO-LABEL
     "Остаток" VIEW-AS TEXT
          SIZE 10 BY .63 AT ROW 20 COL 77.5
     "Расход" VIEW-AS TEXT
          SIZE 8.5 BY .63 AT ROW 20 COL 51
     "Приход" VIEW-AS TEXT
          SIZE 8.5 BY .63 AT ROW 20 COL 25.5
     SPACE(65.86) SKIP(4.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Документы"
         DEFAULT-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX v-cust
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs b-help v-cust */
ASSIGN 
       FRAME v-cust:SCROLLABLE       = FALSE
       FRAME v-cust:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN tot-free-qnty IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-free-sum0-base IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-free-sum0-rubl IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-qnty IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-sum0-base IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-sum0-rubl IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-qnty IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-sum0-base IN FRAME v-cust
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-sum0-rubl IN FRAME v-cust
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH ub.parts WHERE ub.parts.artic = suppl-parts.artic
                     AND ub.parts.prod-type = suppl-parts.prod-type
                     AND ub.parts.prod-code = suppl-parts.prod-code
                     AND ub.parts.in-code = suppl-parts.in-code
                     AND ub.parts.part-code = suppl-parts.part-code
                     AND ub.parts.status_ = yes NO-LOCK,
    EACH t-doc WHERE t-doc.doc-code = ub.parts.out-code NO-LOCK
BY t-doc.fact-date BY t-doc.fact-num.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME v-cust
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-cust v-cust
ON WINDOW-CLOSE OF FRAME v-cust /* Документы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print v-cust
ON CHOOSE OF b-print IN FRAME v-cust /* Печать */
DO:

def var object as char no-undo.
def var price0 LIKE ub.parts.price-rubl no-undo.
def var stoim0 as decimal no-undo.
def var DocDate as char no-undo.

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

def var Line as char no-undo.

DEFINE FRAME supp-gds
      sym1 column-label ":" format "X(1)"
      t-doc.doc-type COLUMN-LABEL "Тип" FORMAT "x(3)"
      sym2 column-label ":" format "X(1)"
      t-doc.status_ COLUMN-LABEL "Стат" format "x(4)"
      sym3 column-label ":" format "X(1)"
      t-doc.flag_ COLUMN-LABEL "OK" FORMAT "+/-"
      sym4 column-label ":" format "X(1)"
      t-doc.doc-code COLUMN-LABEL "Номер документа" format "x(16)"
      sym5 column-label ":" format "X(1)"
      DocDate COLUMN-LABEL "Дата" format "x(5)"
      sym6 column-label ":" format "X(1)"
      t-doc.fact-date COLUMN-LABEL "Дата закр."  FORMAT "99/99/9999"
      sym7 column-label ":" format "X(1)"
      t-doc.internal COLUMN-LABEL "В" FORMAT "+/-"
      sym8 column-label ":" format "X(1)"
      t-doc.cli-name COLUMN-LABEL "Контрагент" format "x(47)"
      sym9 column-label ":" format "X(1)"
      ub.parts.fact-qnty COLUMN-LABEL "    Количество" FORMAT "->,>>>,>>9.<<<"
      sym10 column-label ":" format "X(1)"
      price0 COLUMN-LABEL "Учетная цена" FORMAT "->,>>>,>>9.99"
      sym11 column-label ":" format "X(1)"
      stoim0 COLUMN-LABEL "Сумма учетных цен" FORMAT "->>,>>>,>>>,>>9.99"
      sym12 column-label ":" format "X(1)"
      ub.parts.part-code COLUMN-LABEL "Партия" FORMAT "x(14)"
      sym13 column-label ":" format "X(1)"
      object COLUMN-LABEL "Объект" FORMAT "x(8)"
      sym14 column-label ":" format "X(1)"
    HEADER
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
        string( "Отчет по поставщику: " + supplier.obj-name ) AT 45 format "X(71)"
        string( "Cуммы указаны в " + (if PrintRubl then "{&abbr_rub}" else base-type) ) AT 145 format "X(20)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
        Line format "X(195)" AT 1
    with width {&DOS_CW_2} down stream-io.

assign PrintRubl = yes .
if v-base-code <> 0 then
message "Печатать в {&abbr_rublyah_allshift} ?"
VIEW-AS ALERT-BOX QUESTION BUTTONS yes-no TITLE "" UPDATE PrintRubl.

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

PUT STREAM PrnLibStream string( "Д О К У М Е Н Т Ы за период с: " + string(from-date,"99/99/9999") +
                                                      " по: " + string(to-date,"99/99/9999") )
                                               AT 69 format "X(195)"
                                           SKIP(1)
                                           string( "ПОСТАВЩИК: " + supplier.obj-name +
                                                      " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" )
                                               AT 10 format "X(195)"
                                           SKIP
                                           string( "ТОВАР: " + suppl-parts.artic + ' "' + suppl-parts.gds-name + '"' )
                                               AT 14 format "X(195)"
                                           SKIP
                                           string( "ПАРТИЯ: " + suppl-parts.part-code +
                                                      "из " + caps(substring(suppl-parts.doc-type, 1, 1)) + "Н № " + suppl-parts.out-code )
                                               AT 13 format "X(195)"
                                           SKIP(1).

    DO WHILE available ub.parts :
        GET prev br-docs.
    END.
    GET next br-docs.
    DO WHILE available ub.parts :
        assign price0 = (if PrintRubl then suppl-parts.price0-rubl else suppl-parts.price0-base).
        assign stoim0 = price0 * ub.parts.fact-qnty.
        DISPLAY STREAM PrnLibStream
            sym1 t-doc.doc-type
            sym2 t-doc.status_
            sym3 t-doc.flag_
            sym4 t-doc.doc-code
            sym5 (substring ((string (t-doc.doc-date)), 1, 5)) @ DocDate
            sym6 t-doc.fact-date
            sym7 t-doc.internal
            sym8 t-doc.cli-name
            sym9 ub.parts.fact-qnty
            sym10 price0
            sym11 stoim0
            sym12 (if ub.parts.part-code = "" then "------" else ub.parts.part-code) @ ub.parts.part-code
            sym13 (trim (t-doc.obj-type) + string (t-doc.obj-code, ">>>>9")) @ object
            sym14
            with FRAME supp-gds .
        DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
        GET next br-docs.
    END.

PUT STREAM PrnLibStream Line format "X(195)" SKIP.

DISPLAY STREAM PrnLibStream
    "Остаток" @ t-doc.cli-name
    tot-free-qnty @ ub.parts.fact-qnty
    (if PrintRubl then tot-free-sum0-rubl else tot-free-sum0-base) @ stoim0
    with FRAME supp-gds .
DOWN STREAM PrnLibStream 1 with FRAME supp-gds .

HIDE STREAM PrnLibStream FRAME BottomFrame .
OUTPUT STREAM PrnLibStream CLOSE.

if session:set-wait-state("") then.

run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).

APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK v-cust 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = v-base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
              else base-type = "б.в." .

  assign
      tot-in-qnty = suppl-parts.in-qnty
      tot-in-sum0-base = suppl-parts.in-sum0-base
      tot-in-sum0-rubl = suppl-parts.in-sum0-rubl
      tot-out-qnty = suppl-parts.out-qnty
      tot-out-sum0-base = suppl-parts.out-sum0-base
      tot-out-sum0-rubl = suppl-parts.out-sum0-rubl
      tot-free-qnty = suppl-parts.free-qnty
      tot-free-sum0-base = suppl-parts.free-sum0-base
      tot-free-sum0-rubl = suppl-parts.free-sum0-rubl
      .

  RUN enable_UI.
  FRAME {&FRAME-NAME}:TITLE = string("Документы по партии " + suppl-parts.part-code +
                                     " из " + caps(substring(suppl-parts.doc-type, 1, 1)) + "Н № " + suppl-parts.out-code +
                                     " товара " + suppl-parts.artic + " " + suppl-parts.gds-name ).
  APPLY "ENTRY" TO BROWSE {&BROWSE-NAME} .
  APPLY "ITERATION-CHANGED" TO BROWSE {&BROWSE-NAME} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI v-cust  _DEFAULT-DISABLE
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
  HIDE FRAME v-cust.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI v-cust  _DEFAULT-ENABLE
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
  DISPLAY tot-in-qnty tot-out-qnty tot-free-qnty tot-in-sum0-rubl 
          tot-out-sum0-rubl tot-free-sum0-rubl tot-in-sum0-base 
          tot-out-sum0-base tot-free-sum0-base 
      WITH FRAME v-cust.
  ENABLE b-quit b-print b-help br-docs 
      WITH FRAME v-cust.
  VIEW FRAME v-cust.
  {&OPEN-BROWSERS-IN-QUERY-v-cust}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

