&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME vs-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS vs-parts 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по поставщику (партии товара)   СУДЬБА прихода

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
define input parameter gds-art as char no-undo.
define input parameter num-doc as char no-undo.

/* Local Variable Definitions ---                                       */
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i  }
{ rep/v-suppl.i " " new }
{ str/in-vatp.i def }
{ str/get-pr.i def  }
{ gbl/waitfram.i    }
{ cmp/showinf.i     }

define variable  fr-title as char no-undo.

define variable  prev-exch-code like ub.parts.exch-code init ? no-undo.
define variable  cli-val as char init "{&abbr_rub}" no-undo.

define variable var-report-r-b as character no-undo .
{ gbl/curr-r-b.i  var-report-r-b }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME vs-parts
&Scoped-define BROWSE-NAME br-parts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES suppl-parts goods

/* Definitions for BROWSE br-parts                                      */
&Scoped-define FIELDS-IN-QUERY-br-parts suppl-parts.gds-name suppl-parts.in-code suppl-parts.fact-date suppl-parts.in-qnty suppl-parts.in-sum0-rubl suppl-parts.in-sum0-base suppl-parts.in-sum0-base suppl-parts.out-qnty suppl-parts.out-sum0-rubl suppl-parts.out-sum0-base suppl-parts.out-sum-cli suppl-parts.free-qnty suppl-parts.free-sum0-rubl suppl-parts.free-sum0-base suppl-parts.free-sum-cli suppl-parts.price0-rubl suppl-parts.price0-base suppl-parts.qnty-sale (suppl-parts.ls-date - suppl-parts.fs-date) (suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date) ) (suppl-parts.free-qnty / (suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date))) (if suppl-parts.part-code = "" then "------" else suppl-parts.part-code)   
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-parts   
&Scoped-define SELF-NAME br-parts
&Scoped-define QUERY-STRING-br-parts FOR EACH suppl-parts NO-LOCK, ~
           EACH ub.goods WHERE ub.goods.artic = suppl-parts.artic                      AND ub.goods.prod-type = suppl-parts.prod-type                      AND ub.goods.prod-code = suppl-parts.prod-code NO-LOCK     BY ub.goods.artic BY ub.goods.prod-type BY ub.goods.prod-code BY ub.goods.grp-name BY suppl-parts.in-code
&Scoped-define OPEN-QUERY-br-parts OPEN QUERY {&SELF-NAME} FOR EACH suppl-parts NO-LOCK, ~
           EACH ub.goods WHERE ub.goods.artic = suppl-parts.artic                      AND ub.goods.prod-type = suppl-parts.prod-type                      AND ub.goods.prod-code = suppl-parts.prod-code NO-LOCK     BY ub.goods.artic BY ub.goods.prod-type BY ub.goods.prod-code BY ub.goods.grp-name BY suppl-parts.in-code.
&Scoped-define TABLES-IN-QUERY-br-parts suppl-parts ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-br-parts suppl-parts
&Scoped-define SECOND-TABLE-IN-QUERY-br-parts ub.goods


/* Definitions for DIALOG-BOX vs-parts                                  */
&Scoped-define OPEN-BROWSERS-IN-QUERY-vs-parts ~
    ~{&OPEN-QUERY-br-parts}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-print b-docs b-help br-parts 
&Scoped-Define DISPLAYED-OBJECTS tot-in-qnty tot-out-qnty tot-free-qnty ~
tot-in-sum0-rubl tot-out-sum0-rubl tot-free-sum0-rubl tot-in-sum0-base ~
tot-out-sum0-base tot-free-sum0-base 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE SUB-MENU m-cycle 
       MENU-ITEM m-cycle-rubl   LABEL "в abbr_rublyah"
       MENU-ITEM m-cycle-base   LABEL "в базовой валюте"
       MENU-ITEM m-cycle-cli    LABEL "в валюте поставщика".

DEFINE MENU POPUP-MENU-b-print 
       SUB-MENU  m-cycle        LABEL "Оборот по поставщику"
       MENU-ITEM m-order        LABEL "Отчет для заказа товаров".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-docs DEFAULT 
     LABEL "&Обороты" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help DEFAULT 
     LABEL "Помощь" 
     SIZE 10 BY 1.

DEFINE BUTTON b-print DEFAULT 
     LABEL "Пе&чать" 
     SIZE 10 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT 
     LABEL "&Выход " 
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
     LABEL "сумма (abbr_rub)" 
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
DEFINE QUERY br-parts FOR 
      suppl-parts, 
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-parts vs-parts _FREEFORM
  QUERY br-parts DISPLAY
      suppl-parts.gds-name COLUMN-LABEL "Название товара! "
suppl-parts.in-code COLUMN-LABEL "№ ПН! "
suppl-parts.fact-date COLUMN-LABEL "Дата!прихода" FORMAT "99/99/9999"
suppl-parts.in-qnty COLUMN-LABEL "Приход! количество" FORMAT "->,>>>,>>9.<<<"
suppl-parts.in-sum0-rubl COLUMN-LABEL "Приход сумма!уч. цен ({&abbr_rub})" FORMAT "->>>,>>>,>>9.99"
suppl-parts.in-sum0-base COLUMN-LABEL "Приход сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.in-sum0-base COLUMN-LABEL "Приход сумма!вал. поставщика" FORMAT "->>>,>>>,>>9.99"
suppl-parts.out-qnty COLUMN-LABEL "Расход!количество" FORMAT "->,>>>,>>9.<<<"
suppl-parts.out-sum0-rubl COLUMN-LABEL "Расход сумма!уч. цен ({&abbr_rub})" FORMAT "->>>,>>>,>>9.99"
suppl-parts.out-sum0-base COLUMN-LABEL "Расход сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.out-sum-cli COLUMN-LABEL "Расход сумма!вал. поставщика" FORMAT "->>>,>>>,>>9.99"
suppl-parts.free-qnty COLUMN-LABEL "Остаток!количество" FORMAT "->,>>>,>>9.<<<"
suppl-parts.free-sum0-rubl COLUMN-LABEL "Остаток сумма!уч. цен ({&abbr_rub})" FORMAT "->>>,>>>,>>9.99"
suppl-parts.free-sum0-base COLUMN-LABEL "Остаток сумма!уч. цен (б.вал)" FORMAT "->>>,>>>,>>9.99"
suppl-parts.free-sum-cli COLUMN-LABEL "Остаток сумма!вал. поставщика" FORMAT "->>>,>>>,>>9.99"
suppl-parts.price0-rubl COLUMN-LABEL "Учетная!цена ({&abbr_rub})"
suppl-parts.price0-base COLUMN-LABEL "Учетная!цена (б.вал)"
suppl-parts.qnty-sale COLUMN-LABEL "Кол-во дней!продаж" FORMAT "->,>>>,>>9"
(suppl-parts.ls-date - suppl-parts.fs-date) COLUMN-LABEL "Период!продаж" FORMAT "->,>>>,>>9"
(suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date) ) COLUMN-LABEL "Средние!продажи" FORMAT "->>>>>9.<<<"
(suppl-parts.free-qnty / (suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date))) COLUMN-LABEL "Обеспе-!ченность" FORMAT "->>>>>9."
(if suppl-parts.part-code = "" then "------" else suppl-parts.part-code) COLUMN-LABEL "Партия! " FORMAT "x(14)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 17.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME vs-parts
     b-quit AT ROW 1.17 COL 2
     b-print AT ROW 1.17 COL 12
     b-docs AT ROW 1.17 COL 22
     b-help AT ROW 1.17 COL 88.5
     br-parts AT ROW 2.5 COL 2
     tot-in-qnty AT ROW 20.83 COL 18.5 COLON-ALIGNED
     tot-out-qnty AT ROW 20.83 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-qnty AT ROW 20.83 COL 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-rubl AT ROW 22 COL 18.5 COLON-ALIGNED
     tot-out-sum0-rubl AT ROW 22 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-sum0-rubl AT ROW 22 COL 72.5 COLON-ALIGNED NO-LABEL
     tot-in-sum0-base AT ROW 23.17 COL 18.5 COLON-ALIGNED
     tot-out-sum0-base AT ROW 23.17 COL 45 COLON-ALIGNED NO-LABEL
     tot-free-sum0-base AT ROW 23.17 COL 72.5 COLON-ALIGNED NO-LABEL
     "Приход" VIEW-AS TEXT
          SIZE 8.5 BY .63 AT ROW 20 COL 25.5
     "Остаток" VIEW-AS TEXT
          SIZE 10 BY .63 AT ROW 20 COL 77.5
     "Расход" VIEW-AS TEXT
          SIZE 8.5 BY .63 AT ROW 20 COL 51
     SPACE(40.36) SKIP(4.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "отчет по поставщику".


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
/* SETTINGS FOR DIALOG-BOX vs-parts
   FRAME-NAME                                                           */
/* BROWSE-TAB br-parts b-help vs-parts */
ASSIGN 
       FRAME vs-parts:SCROLLABLE       = FALSE
       FRAME vs-parts:HIDDEN           = TRUE.

ASSIGN 
       b-print:MANUAL-HIGHLIGHT IN FRAME vs-parts = TRUE
       b-print:POPUP-MENU IN FRAME vs-parts       = MENU POPUP-MENU-b-print:HANDLE.

/* SETTINGS FOR FILL-IN tot-free-qnty IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-free-sum0-base IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-free-sum0-rubl IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-qnty IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-sum0-base IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-in-sum0-rubl IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-qnty IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-sum0-base IN FRAME vs-parts
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN tot-out-sum0-rubl IN FRAME vs-parts
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-parts
/* Query rebuild information for BROWSE br-parts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH suppl-parts NO-LOCK,
    EACH ub.goods WHERE ub.goods.artic = suppl-parts.artic
                     AND ub.goods.prod-type = suppl-parts.prod-type
                     AND ub.goods.prod-code = suppl-parts.prod-code NO-LOCK
    BY ub.goods.artic BY ub.goods.prod-type BY ub.goods.prod-code BY ub.goods.grp-name BY suppl-parts.in-code.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE br-parts */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX vs-parts
/* Query rebuild information for DIALOG-BOX vs-parts
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX vs-parts */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME vs-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL vs-parts vs-parts
ON WINDOW-CLOSE OF FRAME vs-parts /* отчет по поставщику */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-docs vs-parts
ON CHOOSE OF b-docs IN FRAME vs-parts /* Обороты */
DO:
  if available suppl-parts then
      run rep/vs-cust1.w (
                     input parparentproc
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input from-date
                    ,input to-date).

  APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print vs-parts
ON CHOOSE OF b-print IN FRAME vs-parts /* Печать */
DO:
    run gbl/pop-up.p (self:handle, no) NO-ERROR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-parts
&Scoped-define SELF-NAME br-parts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts vs-parts
ON MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME vs-parts
DO:
  APPLY "CHOOSE" TO b-docs IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-parts vs-parts
ON RETURN OF br-parts IN FRAME vs-parts
DO:
  APPLY "CHOOSE" TO b-docs IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-cycle-base
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-cycle-base vs-parts
ON CHOOSE OF MENU-ITEM m-cycle-base /* в базовой валюте */
DO:
  RUN print-cycle ("base").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-cycle-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-cycle-cli vs-parts
ON CHOOSE OF MENU-ITEM m-cycle-cli /* в валюте поставщика */
DO:
  if prev-exch-code = ? then
      message "Отчет не может быть напечатан!" SKIP
                      "Т.к. были приходы от данного поставщика" SKIP
                      "за данный период в разных валютах." view-as alert-box ERROR.
  else
      do:
          FIND ub.currency WHERE ub.currency.curr-code = prev-exch-code NO-LOCK.
          assign cli-val = ub.currency.curr-abbr.
          RUN print-cycle ("cli").
      end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-cycle-rubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-cycle-rubl vs-parts
ON CHOOSE OF MENU-ITEM m-cycle-rubl /* в abbr_rublyah */
DO:
  RUN print-cycle ("rubl").
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m-order
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m-order vs-parts
ON CHOOSE OF MENU-ITEM m-order /* Отчет для заказа товаров */
DO:
  run print-order.
  APPLY "ENTRY" TO BROWSE {&BROWSE-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK vs-parts 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/app_help.i }
  RUN calc.
  assign
  MENU-ITEM m-cycle-rubl:label in menu m-cycle = "в {&abbr_rublyah}"
  tot-in-sum0-rubl:label = "сумма ({&abbr_rub})"
  .
  RUN enable_UI.
  assign b-print:MENU-MOUSE = 1.
  if gds-art = "" then
      FRAME {&FRAME-NAME}:TITLE = string( "Приходные партии товара: " +
                                                                        suppl-gds.artic + " " + suppl-gds.gds-name ).
  else
      do:
          if num-doc = "" then
              FRAME {&FRAME-NAME}:TITLE = string( "Поставки с: " + string(from-date,"99/99/9999") +
                                                                                " по: " + string(to-date,"99/99/9999") +
                                                                                " Поставщик: " + supplier.obj-name +
                                                                                " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" ).
          else
              do:
                  find ub.trn-doc where ub.trn-doc.doc-code = num-doc no-lock.
                  FRAME {&FRAME-NAME}:TITLE = string( "Поставки по документу: " + num-doc + " от " + string( ub.trn-doc.fact-date, "99/99/9999" ) ).
              end.
      end.
  apply "entry" to br-parts in frame {&frame-name}.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE calc vs-parts 
PROCEDURE calc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer    b-parts    for ub.parts.
define variable  out-qnty  like ub.parts.fact-qnty no-undo.
define variable  free-qnty like ub.parts.fact-qnty no-undo.
define variable  qnty_sale like suppl-gds.qnty-sale no-undo.
define variable  f-date as date no-undo.
define variable  l-date as date no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .

if session:set-wait-state("COMPILER") then.
run waitfram-show in this-procedure ("Подождите...").
{ gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }

if gds-art = "" then do:
    for each ub.parts where ub.parts.host-code = v-host-code
        and ub.parts.artic = suppl-gds.artic
        and ub.parts.prod-type = suppl-gds.prod-type
        and ub.parts.prod-code = suppl-gds.prod-code
        and ub.parts.supp-type = supplier.obj-type
        and ub.parts.supp-code = supplier.obj-code
        and ub.parts.status_ = yes
        and ub.parts.fact-date >= from-date
        and ub.parts.fact-date <= to-date
        and ub.parts.out-code = ub.parts.in-code
        no-lock break by ub.parts.fact-date:
      { rep/vs-part1.i }
    end.
end.
else do:
    if num-doc = "" then do:
        FOR EACH ub.parts WHERE ub.parts.host-code = v-host-code
              AND ub.parts.supp-type = supplier.obj-type
              AND ub.parts.supp-code = supplier.obj-code
              AND ub.parts.status_ = yes
              AND ub.parts.fact-date >= from-date
              AND ub.parts.fact-date <= to-date
              AND ub.parts.out-code = ub.parts.in-code
              NO-LOCK BREAK BY ub.parts.fact-date:
            { rep/vs-part1.i }
        end.
    end.
    else do:
        for each ub.parts where
                  ub.parts.host-code = v-host-code
              and ub.parts.supp-type = supplier.obj-type
              and ub.parts.supp-code = supplier.obj-code
              and ub.parts.status_   = yes
              and ub.parts.out-code  = ub.parts.in-code
              and ub.parts.out-code  = num-doc
            no-lock break by ub.parts.fact-date:
            { rep/vs-part1.i }
        end.
    end.
end.

assign
    tot-in-qnty = (ACCUM TOTAL ub.parts.fact-qnty)
    tot-in-sum0-rubl = (ACCUM TOTAL ub.parts.fact-qnty * ub.parts.price-rubl)
    tot-in-sum0-base = (ACCUM TOTAL ub.parts.fact-qnty * ub.parts.price-base)
    tot-out-qnty = (ACCUM TOTAL out-qnty)
    tot-out-sum0-rubl = (ACCUM TOTAL out-qnty * ub.parts.price-rubl)
    tot-out-sum0-base = (ACCUM TOTAL out-qnty * ub.parts.price-base)
    tot-free-qnty = (ACCUM TOTAL free-qnty)
    tot-free-sum0-rubl = (ACCUM TOTAL free-qnty * price-rubl-with-tax-loc)
    tot-free-sum0-base = (ACCUM TOTAL free-qnty * price-base-with-tax-loc)
    .

if session:set-wait-state("") then.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI vs-parts  _DEFAULT-DISABLE
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
  HIDE FRAME vs-parts.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI vs-parts  _DEFAULT-ENABLE
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
      WITH FRAME vs-parts.
  ENABLE b-quit b-print b-docs b-help br-parts 
      WITH FRAME vs-parts.
  VIEW FRAME vs-parts.
  {&OPEN-BROWSERS-IN-QUERY-vs-parts}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-cycle vs-parts 
PROCEDURE print-cycle :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter val-type as char no-undo.

    define variable  object as char no-undo.
    define variable  PartCode LIKE ub.parts.part-code no-undo.
    define variable  price0 LIKE ub.parts.price-rubl no-undo.
    define variable  in-sum0 LIKE ub.parts.price-rubl no-undo.
    define variable  out-sum0 LIKE ub.parts.price-rubl no-undo.
    define variable  free-sum0 LIKE ub.parts.price-rubl no-undo.

    define variable  sym1 as char init ":"   no-undo.
    define variable  sym2 as char init ":"   no-undo.
    define variable  sym3 as char init ":"   no-undo.
    define variable  sym4 as char init ":"   no-undo.
    define variable  sym5 as char init ":"   no-undo.
    define variable  sym6 as char init ":"   no-undo.
    define variable  sym7 as char init ":"   no-undo.
    define variable  sym8 as char init ":"   no-undo.
    define variable  sym9 as char init ":"   no-undo.
    define variable  sym10 as char init ":"   no-undo.
    define variable  sym11 as char init ":"   no-undo.
    define variable  sym12 as char init ":"   no-undo.
    define variable  sym13 as char init ":"   no-undo.

    define variable  Line as char no-undo.
    define variable base-type as character no-undo .
    define variable v-base-code like ub.sysconf.base-code no-undo .
    define variable v-host-code like ub.sysconf.host-code no-undo .
    define buffer buf_rep_currency for ub.currency.
    { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
    { gbl/basecode.i v-host-code v-base-code }
    find first buf_rep_currency no-lock
    where buf_rep_currency.curr-code = v-base-code
    no-error .
    if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
                else base-type = "б.в." .


    DEFINE FRAME supp-gds
          sym1 column-label ":!:" format "X(1)" space(0)
          suppl-parts.gds-name COLUMN-LABEL "Наименование!товара" FORMAT "x(40)" space(0)
          sym2 column-label ":!:" format "X(1)" space(0)
          suppl-parts.in-code COLUMN-LABEL "№ ПН! " FORMAT "x(16)" space(0)
          sym3 column-label ":!:" format "X(1)" space(0)
          suppl-parts.fact-date COLUMN-LABEL "Дата!прихода" FORMAT "99/99/99" space(0)
          sym4 column-label ":!:" format "X(1)" space(0)
          price0 COLUMN-LABEL "Учетная!цена" FORMAT "->>,>>9.99"  space(0)
          sym5 column-label ":!:" format "X(1)" space(0)
          suppl-parts.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
          sym6 column-label ":!:" format "X(1)" space(0)
          in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
          sym7 column-label ":!:" format "X(1)" space(0)
          suppl-parts.out-qnty COLUMN-LABEL "Расход!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
          sym8 column-label ":!:" format "X(1)" space(0)
          out-sum0 COLUMN-LABEL "Расход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
          sym9 column-label ":!:" format "X(1)" space(0)
          suppl-parts.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
          sym10 column-label ":!:" format "X(1)" space(0)
          free-sum0 COLUMN-LABEL "Остаток сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
          sym11 column-label ":!:" format "X(1)" space(0)
          object COLUMN-LABEL "Объект! " FORMAT "x(10)"  space(0)
          sym12 column-label ":!:" format "X(1)" space(0)
          PartCode COLUMN-LABEL "Партия! " FORMAT "x(14)" space(0)
          sym13 column-label ":!:" format "X(1)" space(0)
        HEADER
            string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
            string( "Отчет по поставщику: " + supplier.obj-name ) AT 45 format "X(71)"
            string( "Cуммы указаны в " + (if val-type = "rubl" then "{&abbr_rub}" else (if val-type = "base" then base-type else cli-val ) ) ) AT 145 format "X(20)"
            string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
            Line format "X(198)" AT 1
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
        Line format "X(198)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 60 SKIP
        with FRAME BottomFrame width {&DOS_CW_2}
        PAGE-BOTTOM no-labels no-box.
    VIEW STREAM PrnLibStream FRAME BottomFrame .

    PUT STREAM PrnLibStream string( "П Р И Х О Д Н Ы Е   П А Р Т И И   за период с: " + string(from-date,"99/99/9999") +
                                                          " по: " + string(to-date,"99/99/9999") )
                                                   AT 62 format "X(198)"
                                               SKIP(1)
                                               string( "ПОСТАВЩИК: " + supplier.obj-name +
                                                          " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" )
                                                   AT 10 format "X(198)"
                                               SKIP.
    if gds-art = "" then
        PUT STREAM PrnLibStream string( "ТОВАР: " + suppl-gds.artic + ' "' + suppl-gds.gds-name + '"' )
                                                       AT 14 format "X(198)"
                                                   SKIP.

    PUT STREAM PrnLibStream " " SKIP.

    FOR EACH suppl-parts NO-LOCK BREAK BY suppl-parts.artic BY suppl-parts.prod-type BY suppl-parts.prod-code BY suppl-parts.in-code:

        CASE val-type:
            WHEN "rubl" THEN
                assign
                    price0 = suppl-parts.price0-rubl
                    in-sum0 = suppl-parts.in-sum0-rubl
                    out-sum0 = suppl-parts.out-sum0-rubl
                    free-sum0 = suppl-parts.free-sum0-rubl
                    .
            WHEN "base" THEN
                assign
                    price0 = suppl-parts.price0-base
                    in-sum0 = suppl-parts.in-sum0-base
                    out-sum0 = suppl-parts.out-sum0-base
                    free-sum0 = suppl-parts.free-sum0-base
                    .
            WHEN "cli" THEN
                assign
                    price0 = suppl-parts.price-cli
                    in-sum0 = suppl-parts.in-sum-cli
                    out-sum0 = suppl-parts.out-sum-cli
                    free-sum0 = suppl-parts.free-sum-cli
                    .
        END CASE.
        DISPLAY STREAM PrnLibStream
            sym1 suppl-parts.in-code
            sym2 string( suppl-parts.artic + " " + suppl-parts.gds-name ) @ suppl-parts.gds-name
            sym3 suppl-parts.fact-date
            sym4 price0
            sym5 suppl-parts.in-qnty
            sym6 in-sum0
            sym7 suppl-parts.out-qnty
            sym8 out-sum0
            sym9 suppl-parts.free-qnty
            sym10 free-sum0
            sym11 (suppl-parts.obj-type + " " + STRING (suppl-parts.obj-code)) @ object
            sym12 (if suppl-parts.part-code = "" then "------" else suppl-parts.part-code) @ PartCode
            sym13
            with FRAME supp-gds .
        DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
        ACCUMULATE
            suppl-parts.in-qnty (TOTAL)
            in-sum0 (TOTAL)
            suppl-parts.out-qnty (TOTAL)
            out-sum0 (TOTAL)
            suppl-parts.free-qnty (TOTAL)
            free-sum0 (TOTAL)
            suppl-parts.prod-code (SUB-COUNT BY suppl-parts.prod-code)
            suppl-parts.in-qnty (SUB-TOTAL BY suppl-parts.prod-code)
            in-sum0 (SUB-TOTAL BY suppl-parts.prod-code)
            suppl-parts.out-qnty (SUB-TOTAL BY suppl-parts.prod-code)
            out-sum0 (SUB-TOTAL BY suppl-parts.prod-code)
            suppl-parts.free-qnty (SUB-TOTAL BY suppl-parts.prod-code)
            free-sum0 (SUB-TOTAL BY suppl-parts.prod-code)
            .
        if LAST-OF( suppl-parts.prod-code ) then
            do:
                if (ACCUM SUB-COUNT BY suppl-parts.prod-code suppl-parts.prod-code) > 1 then
                    do:
                        DISPLAY STREAM PrnLibStream
                            sym1
                            sym2 string( "  Итого по товару" ) @ suppl-parts.gds-name
                            sym3 sym4
                            sym5 (ACCUM SUB-TOTAL BY suppl-parts.prod-code suppl-parts.in-qnty) @ suppl-parts.in-qnty
                            sym6 (ACCUM SUB-TOTAL BY suppl-parts.prod-code in-sum0) @ in-sum0
                            sym7 (ACCUM SUB-TOTAL BY suppl-parts.prod-code suppl-parts.out-qnty) @ suppl-parts.out-qnty
                            sym8 (ACCUM SUB-TOTAL BY suppl-parts.prod-code out-sum0) @ out-sum0
                            sym9 (ACCUM SUB-TOTAL BY suppl-parts.prod-code suppl-parts.free-qnty) @ suppl-parts.free-qnty
                            sym10 (ACCUM SUB-TOTAL BY suppl-parts.prod-code free-sum0) @ free-sum0
                            sym11 sym12 sym13
                            with FRAME supp-gds .
                        DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
                    end.
                DISPLAY STREAM PrnLibStream
                    sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13
                    with FRAME supp-gds .
                DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
            end.
    END.

    PUT STREAM PrnLibStream Line format "X(198)" SKIP.

    DISPLAY STREAM PrnLibStream
        "Итого" @ price0
        (ACCUM TOTAL suppl-parts.in-qnty) @ suppl-parts.in-qnty
        (ACCUM TOTAL in-sum0) @ in-sum0
        (ACCUM TOTAL suppl-parts.out-qnty) @ suppl-parts.out-qnty
        (ACCUM TOTAL out-sum0) @ out-sum0
        (ACCUM TOTAL suppl-parts.free-qnty) @ suppl-parts.free-qnty
        (ACCUM TOTAL free-sum0) @ free-sum0
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

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-order vs-parts 
PROCEDURE print-order :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable  tb-code as char no-undo.
  define variable  price0 LIKE ub.parts.price-rubl no-undo.
  define variable  in-sum0 LIKE ub.parts.price-rubl no-undo.
  define variable  free-noNDS0 LIKE ub.parts.price-rubl no-undo.
  define variable  free-NDS0 LIKE ub.parts.price-rubl no-undo.
  define variable  free-sum0 LIKE ub.parts.price-rubl no-undo.
  define variable  resource as int init ? no-undo.
  define variable  avrg-sale as decimal no-undo.
  define variable  sum-price-s as decimal no-undo.
  define variable  UpFact as decimal no-undo.

  define variable  sym1 as char init ":"   no-undo.
  define variable  sym2 as char init ":"   no-undo.
  define variable  sym3 as char init ":"   no-undo.
  define variable  sym4 as char init ":"   no-undo.
  define variable  sym5 as char init ":"   no-undo.
  define variable  sym6 as char init ":"   no-undo.
  define variable  sym7 as char init ":"   no-undo.
  define variable  sym8 as char init ":"   no-undo.
  define variable  sym9 as char init ":"   no-undo.
  define variable  sym10 as char init ":"   no-undo.
  define variable  sym11 as char init ":"   no-undo.
  define variable  sym12 as char init ":"   no-undo.
  define variable  sym13 as char init ":"   no-undo.
  define variable  sym14 as char init ":"   no-undo.

  define variable  Line as char no-undo.
  define variable base-type as character no-undo .
  define variable v-base-code like ub.sysconf.base-code no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define buffer buf_rep_currency for ub.currency.
  { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = v-base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
              else base-type = "б.в." .


  DEFINE FRAME supp-gds
        sym1 column-label ":!:" format "X(1)" space(0)
        suppl-parts.in-code COLUMN-LABEL "№ ПН! " FORMAT "x(16)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        suppl-parts.fact-date COLUMN-LABEL "Дата!прихода" FORMAT "99/99/9999" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        suppl-parts.in-qnty COLUMN-LABEL "Приход!    количество" FORMAT "->,>>>,>>9.<<<" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        price0 COLUMN-LABEL "Учетная!цена" FORMAT "->>>,>>9.99"  space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        in-sum0 COLUMN-LABEL "Приход сумма!учетных цен" FORMAT "->>>,>>>,>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        resource COLUMN-LABEL "Обеспе-!ченность" FORMAT "->>>>>>9" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        avrg-sale COLUMN-LABEL "Средние!продажи" FORMAT "->>>>>9"
        sym8 column-label ":!:" format "X(1)"
        suppl-parts.free-qnty COLUMN-LABEL "Остаток!    количество" FORMAT "->,>>>,>>9.<<<"
        sym9 column-label ":!:" format "X(1)"
        free-noNDS0 COLUMN-LABEL "Остаток сумма!уч. цен без НДС" FORMAT "->>>,>>>,>>9.99"
        sym10 column-label ":!:" format "X(1)"
        free-NDS0 COLUMN-LABEL "Остаток сумма!НДС" FORMAT "->>>,>>>,>>9.99"
        sym11 column-label ":!:" format "X(1)"
        free-sum0 COLUMN-LABEL "Остаток сумма!уч. цен c НДС" FORMAT "->>>,>>>,>>9.99"
        sym12 column-label ":!:" format "X(1)"
        sum-price-s COLUMN-LABEL "Остаток cумма!продажных цен" FORMAT "->>>,>>>,>>9.99"
        sym13 column-label ":!:" format "X(1)"
        UpFact COLUMN-LABEL "Наценка! " FORMAT "->>>,>>>,>>9.99%"
        sym14 column-label ":!:" format "X(1)" space(0)
      HEADER
          string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
          string( "Отчет для заказа товаров от поставщика: " + supplier.obj-name ) AT 45 format "X(95)"
          string( "Cуммы указаны в " + (if PrintRubl then "{&abbr_rub}" else base-type) ) AT 145 format "X(20)"
          string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) AT 170 format "X(13)" SKIP
          Line format "X(198)" AT 1
      with width {&DOS_CW_2} down stream-io.

  assign PrintRubl = yes .
  if v-base-code <> 0 and var-report-r-b = "base" then
      assign PrintRubl = no .

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
      Line format "X(198)" AT 1 SKIP
      "Продолжение - на следующей странице" AT 60 SKIP
      with FRAME BottomFrame width {&DOS_CW_2}
      PAGE-BOTTOM no-labels no-box.
  VIEW STREAM PrnLibStream FRAME BottomFrame .

  if num-doc = "" then
      PUT STREAM PrnLibStream string( "П Р И Х О Д Н Ы Е   П А Р Т И И   за период с: " + string(from-date,"99/99/9999") +
                                                            " по: " + string(to-date,"99/99/9999") )
                                                     AT 62 format "X(198)"
                                                 SKIP(1)
                                                 .
  else
      PUT STREAM PrnLibStream string( "П Р И Х О Д Н Ы Е   П А Р Т И И   по документу: " + num-doc + " от " + string( ub.trn-doc.fact-date, "99/99/9999" ) )
                                                     AT 62 format "X(198)"
                                                 SKIP(1)
                                                 .
  PUT STREAM PrnLibStream string( "ПОСТАВЩИК: " + supplier.obj-name +
                                                        " (" + supplier.obj-type + " " + string(supplier.obj-code) + ")" )
                                                 AT 10 format "X(198)"
                                               SKIP.
  if gds-art = "" then
      PUT STREAM PrnLibStream string( "ТОВАР: " + suppl-gds.artic + ' "' + suppl-gds.gds-name + '"' )
                                                     AT 14 format "X(198)"
                                                 SKIP.

  PUT STREAM PrnLibStream " " SKIP.

  FOR EACH suppl-parts NO-LOCK,
          EACH ub.goods WHERE ub.goods.artic = suppl-parts.artic
                                             AND ub.goods.prod-type = suppl-parts.prod-type
                                             AND ub.goods.prod-code = suppl-parts.prod-code
                                             NO-LOCK
                                             BREAK BY ub.goods.grp-name BY ub.goods.artic BY ub.goods.prod-type BY ub.goods.prod-code BY suppl-parts.in-code:

      FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
      FIND ub.bar-code WHERE ub.bar-code.gds-code = ub.goods.gds-code
                      AND ub.bar-code.unit-cli = ub.goods.unit-base
                      AND ub.bar-code.node-code = ub.gds-prt.node-code
                      AND ub.bar-code.part-code = ""
                      AND ub.bar-code.in-code = ""
                      NO-LOCK.

      { str/get-pr.i calc p-curr-obj-type p-curr-obj-code ub.goods.gds-code ub.bar-code.node-code "return no-apply." }

      assign
          price0 = (if PrintRubl then suppl-parts.price0-rubl else suppl-parts.price0-base)
/*
          sum-price-s = (if gp-price-sale then gp-price-sale else ?) * suppl-parts.free-qnty
*/
          in-sum0 = (if PrintRubl then suppl-parts.in-sum0-rubl else suppl-parts.in-sum0-base)
          free-sum0 = (if PrintRubl then suppl-parts.free-sum0-rubl else suppl-parts.free-sum0-base)
          free-NDS0 = (if PrintRubl then suppl-parts.free-NDS0-rubl else suppl-parts.free-NDS0-base)
          free-noNDS0 = free-sum0 - free-NDS0
          avrg-sale = suppl-parts.out-qnty / (suppl-parts.ls-date - suppl-parts.fs-date)
          resource = suppl-parts.free-qnty / avrg-sale
          .

      if FIRST-OF (ub.goods.grp-name) then
          do:
              DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
              PUT STREAM PrnLibStream SPACE(20) string("Группа: " + ub.goods.grp-name) format "X(100)".
          end.
      if FIRST-OF (ub.goods.prod-code) then
          do:
              DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
              PUT STREAM PrnLibStream
                  SPACE(5)
                  "Артикул: " ub.goods.artic format "X(16)"
                  SPACE
                  "Код: " string( ub.bar-code.b-code ) format "x(13)"
                  SPACE
                  suppl-parts.gds-name format "x(50)"
                  .
          end.

      DISPLAY STREAM PrnLibStream
          sym1 suppl-parts.in-code
          sym2 suppl-parts.fact-date
          sym3 suppl-parts.in-qnty
          sym4 price0
          sym5 in-sum0
          sym6 resource
          sym7 suppl-parts.free-qnty
          sym8 avrg-sale
          sym9 free-noNDS0
          sym10 free-NDS0
          sym11 free-sum0
          sym12 sum-price-s
          sym13 ( ( sum-price-s - free-sum0 ) / free-sum0 * 100 ) @ UpFact
          sym14
          with FRAME supp-gds .
      DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
      ACCUMULATE
          suppl-parts.in-qnty (TOTAL)
          in-sum0 (TOTAL)
          suppl-parts.free-qnty (TOTAL)
          free-noNDS0 (TOTAL)
          free-NDS0 (TOTAL)
          free-sum0 (TOTAL)
          sum-price-s (TOTAL)
          suppl-parts.prod-code (SUB-COUNT BY ub.goods.prod-code)
          suppl-parts.in-qnty (SUB-TOTAL BY ub.goods.prod-code)
          in-sum0 (SUB-TOTAL BY ub.goods.prod-code)
          suppl-parts.free-qnty (SUB-TOTAL BY ub.goods.prod-code)
          free-noNDS0 (SUB-TOTAL BY ub.goods.prod-code)
          free-NDS0 (SUB-TOTAL BY ub.goods.prod-code)
          free-sum0 (SUB-TOTAL BY ub.goods.prod-code)
          sum-price-s (SUB-TOTAL BY ub.goods.prod-code)
          .
      if LAST-OF( ub.goods.prod-code ) AND (ACCUM SUB-COUNT BY ub.goods.prod-code suppl-parts.prod-code) > 1 then
          do:
              DISPLAY STREAM PrnLibStream
                  sym1 string( "Итого по товару" ) @ suppl-parts.in-code
                  sym2
                  sym3 (ACCUM SUB-TOTAL BY ub.goods.prod-code suppl-parts.in-qnty) @ suppl-parts.in-qnty
                  sym4
                  sym5 (ACCUM SUB-TOTAL BY ub.goods.prod-code in-sum0) @ in-sum0
                  sym6
                  sym7
                  sym8 (ACCUM SUB-TOTAL BY ub.goods.prod-code suppl-parts.free-qnty) @ suppl-parts.free-qnty
                  sym9 (ACCUM SUB-TOTAL BY ub.goods.prod-code free-noNDS0) @ free-noNDS0
                  sym10 (ACCUM SUB-TOTAL BY ub.goods.prod-code free-NDS0) @ free-NDS0
                  sym11 (ACCUM SUB-TOTAL BY ub.goods.prod-code free-sum0) @ free-sum0
                  sym12 (ACCUM SUB-TOTAL BY ub.goods.prod-code sum-price-s) @ sum-price-s
                  sym13 ( ( (ACCUM SUB-TOTAL BY ub.goods.prod-code sum-price-s) - (ACCUM SUB-TOTAL BY ub.goods.prod-code free-sum0) ) /
                                    (ACCUM SUB-TOTAL BY ub.goods.prod-code free-sum0) * 100 ) @ UpFact
                  sym14
                  with FRAME supp-gds .
              DOWN STREAM PrnLibStream 1 with FRAME supp-gds .
          end.
  END.

  PUT STREAM PrnLibStream Line format "X(198)" SKIP.

  DISPLAY STREAM PrnLibStream
      "Итого" @ suppl-parts.in-code
      (ACCUM TOTAL suppl-parts.in-qnty) @ suppl-parts.in-qnty
      (ACCUM TOTAL in-sum0) @ in-sum0
      (ACCUM TOTAL suppl-parts.free-qnty) @ suppl-parts.free-qnty
      (ACCUM TOTAL free-noNDS0) @ free-noNDS0
      (ACCUM TOTAL free-NDS0) @ free-NDS0
      (ACCUM TOTAL free-sum0) @ free-sum0
      (ACCUM TOTAL sum-price-s) @ sum-price-s
      with FRAME supp-gds .
  DOWN STREAM PrnLibStream 1 with FRAME supp-gds .

  HIDE STREAM PrnLibStream FRAME BottomFrame .
  OUTPUT STREAM PrnLibStream CLOSE.

  if session:set-wait-state("") then.

  run prn-lib-prn-file in this-procedure (
                                            input parParentProc
                                            ,input 8
                                            ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

